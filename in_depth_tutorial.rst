.. _in-depth-tutorial:


In-Depth Tutorial - Productionising a Classifier
================================================

In this section, we're going to productionise a Random Forest classifier written with `sklearn <http://scikit-learn.org/>`_, deploy it to the cloud, and use it in a more sophisticated workflow. 

By the end of the tutorial, you will learn how to build modules with dependencies, write more sophisticated workflows, and build abstractions over data-sources. Enjoy!

So far, we have built and published a Python module with a single function on it, ``numChars``, and built a workflow which connects our function to an HTTP endpoint. This in itself isn't particularly useful, so, now that you've got the gist of how NStack works, it's time to build something more realistic!

In this tutorial, we're going to create and productionise a simple classifier which uses the famous `iris dataset <https://en.wikipedia.org/wiki/Iris_flower_data_set>`_. 
We're going to train our classifier to classify which species an iris is, given measurements of its sepals and petals. You can find the dataset we're using to train our model `here  <https://raw.githubusercontent.com/nstackcom/nstack-examples/master/iris/Iris.Classify/train.csv>`_.

First, let's look at the the format of our data to see how we should approach the problem. We see that we have five fields: 

================  =======================  ===========
Field Name        Description              Type
================  =======================  ===========
``species``       The species of iris      Text

``sepal_width``   The width of the sepal   Double

``sepal_length``  The length of the sepal  Double

``petal_width``   The width of the petal   Double

``petal_length``  The length of the petal  Double
================  =======================  ===========

If we are trying to find the species based on the sepal and petal measurements, this means these measurements are going to be the input to our classifier module, with text being the output. This means we need to write a function in Python which takes four ``Double``\s and returns ``Text``.

Creating your classifier module
------------------------------

To begin, let's make a new directory called ``Iris.Classify``, ``cd`` into it, and initialise a new Python module:

.. code:: bash
    
    ~/ $ mkdir Iris.Classify; cd Iris.Classify
    ~/Iris.Classify/ $ nstack init python
    python module 'Iris.Classify' successfully initialised at ~/Iris.Classify

Next, let's download our training data into this directory so we can use it in our module. We have hosted it for you as a CSV on GitHub.

.. code:: bash

    ~/Iris.Classify/ $ curl -O https://raw.githubusercontent.com/nstackcom/nstack-examples/master/iris/Iris.Classify/train.csv

Defining our API
----------------

As we know what the input and output of our classifier is going to look like, let's edit ``module.nml`` to define our API (i.e. the entry-point into our module). By default, a new module contains a sample function ``numChars``, which we replace with our definition. We're going to call the function we write in Python ``predict``, which means we write our ``module.nml`` as follows:

::

  module Iris.Classify:0.1.0

  fun predict : (Double, Double, Double, Double) -> Text

This means we want to productionise a single function, ``predict``, which takes four ``Double``\s (the measurements) and returns ``Text`` (the iris species).


Writing our classifier
----------------------
 
Now that we've defined our API, let's jump into our Python module, which lives in ``service.py``.
We see that NStack has created a class ``Service``. This is where we add the functions for our module. Right now it also has a sample function in it, ``numChars``, which we can remove. 

Let's import the libaries we're using.

.. code :: python

    import nstack
    import pandas as pd

    from sklearn.ensemble import RandomForestClassifier

.. note :: Python modules must also import ``nstack``

Before we add our ``predict`` function, we're going to add ``__init__``, the Python constructor function which runs upon the creation of our module. It's going to load our data from ``train.csv``, and use it to train our Random Forest classifier:

.. code :: python

    def __init__(self):
        train = pd.read_csv("train.csv")
        
        self.cols = ['petal_length', 'petal_width', 'sepal_length', 'sepal_width'] 
        colsRes = ['class']
        trainArr = train.as_matrix(self.cols) 
        trainRes = train.as_matrix(colsRes) 
        
        rf = RandomForestClassifier(n_estimators=100)
        rf.fit(trainArr, trainRes)
        self.rf = rf

Now we can write our ``predict`` function. The second argument, ``inputArr``, is the input -- in this case, our four ``Double``\s. To return text, we simply return from the function in Python.

.. code :: python

    def predict(self, inputArr):
        points = [inputArr]
        df = pd.DataFrame(points, columns=self.cols)

        results = self.rf.predict(df)
        return results.item()

Configuring your module
-----------------------

When your module is started, it is run in a Linux container on the NStack server. Because our module uses libraries like ``pandas`` and ``sklearn``, we have to tell NStack to install some extra operating system libraries inside your module's container. NStack lets us specify these in our ``nstack.yaml`` configuration file in the ``packages`` section. Let's add the following packages:

.. code :: yaml

    packages: ['numpy', 'python3-scikit-learn', 'scipy', 'python3-scikit-image', 'python3-pandas']

Additionally, we want to tell NStack to copy our ``train.csv`` file into our module, so we can use it in ``__init__``. ``nstack.yaml`` also has a section for specifying files you'd like to include:

.. code :: yaml

    files: ['train.csv']

Publishing and starting
-----------------------

Now we're ready to build and publish our classifier. Remember, even though we run this command locally, our module gets built and published on your NStack server in the cloud.

.. code :: bash

    ~/Iris.Classify/ $ nstack build
    Building NStack Container module Iris.Classify. Please wait. This may take some time.
    Module Iris.Classify built successfully. Use `nstack list functions` to see all available functions.

We can now see ``Iris.Classify.predict`` in the list of existing functions (along with previously built functions like ``demo.numChars``),

.. code :: bash
 
   ~/Iris.Classify/ $ nstack list functions
    Iris.Classify:0.0.1-SNAPSHOT
        predict : (Double, Double, Double, Double) -> Text
    Demo:0.0.1-SNAPSHOT
        numChars : Text -> Integer

Our classifier is now published, but to use it we need to connect it to an event source and sink. In the previous tutorial, we used HTTP as a source, and the NStack log as a sink. We can do the same here. This time, instead of creating a workflow module right away, we can use nstack's ``notebook`` command to test our workflow first. ``notebook`` opens an interactive shell where we can write our workflow. When we are finished, we can ``Ctrl-D``.

.. code :: bash
   
    ~/Iris.Classify/ $ nstack notebook
    import Iris.Classify:0.0.1-SNAPSHOT as Classifier;
    Sources.http<(Double, Double, Double, Double)> | Classifier.predict | Sinks.log<Text>
    [Ctrl-D]

This creates an HTTP endpoint on ``http://localhost:8080/irisendpoint`` which can receive four ``Double``\s, and writes the results to the log as ``Text``. Let's check it is running as a process:

.. code :: bash

 ~/Iris.Classify/ $ nstack ps 
 1
 2

In this instance, it is running as process ``2``. We can test our classifier by sending it some of the sample data from ``train.csv``. 

.. code :: bash

   ~/Iris.Classify/ $ nstack send "/irisendpoint" '[4.7, 1.4, 6.1, 2.9]'
   Message Accepted
   ~/Iris.Classify/ $ nstack log 2  
   Feb 17 10:32:30 nostromo nstack-server[8925]: OUTPUT: "Iris-versicolor"

Our classifier is now productionised.

