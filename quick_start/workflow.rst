.. _quick-start-workflow:

Building a Workflow
=========================

In the previous tutorial, we built and published a Python module, `Demo`.
This module had a single function on it, ``numChars``, which counted the number of characters in some text. Although it has been published, it needs to be connected to a `source` and a `sink`.

.. note:: Sources generate data which gets sent to your function, and sinks receive the data which your function outputs. Learn more in :ref:`Concepts<concepts>`

Let's refresh ourselves on what the input and output types of our function were by asking NStack:

.. code:: bash
  
  > nstack list functions
  Demo:0.0.1-SNAPSHOT.numChars : Text -> Integer

This means that our function can be connected to any source which generates ``Text``, and can write to any sink which can take an ``Integer`` as input. 

One of the sources that NStack provides is ``http``;
if you use this source, NStack sets up an HTTP endpoint which you can send ``JSON``-encoded data to.
As a sink, we are going to use the NStack ``log``,
which is a sink for seeing the output from your function. We are going to use these two integrations in our tutorial.

.. note:: See a list of available sources and sinks in :ref:`Supported Integrations<supported-integrations>`

Creating a workflow module
---------------------------

To write workflows, we create a special NStack workflow module, which we create in the same way we create a Python module -- by using ``init``.

Let's create a new directory called ``DemoWorkflow``, ``cd`` into the directory, and create a new workflow module.

.. code :: bash
  
  ~/DemoWorkflow/ nstack init --workflow
  Module 'DemoWorkflow:0.0.1-SNAPSHOT' successfully initialised at /home/nstack/Demo/DemoWorkflow

``init`` has created a single file, ``module.nml``, which is where we write our workflow module using NStack's scripting language. If we look inside the file, we see that NStack has created an example module for us.

.. note :: Just like Python modules, workflow modules are versioned.

::

 module DemoWorkflow:0.0.1-SNAPSHOT

 import Demo.NumChars:0.0.1-SNAPSHOT as D

 // A sample workflow
 def w = Sources.http<Text> { http_path = "/demo" } | D.numChars | Sinks.log<Integer>

This currently has a single workflow on it, ``w``, which uses a function imported from a module called ``Demo.NumChars`` with the version number of ``0.0.1``.
Like the workflow we will create, this example workflow creates an HTTP endpoint which pipes data to a function, and pipes data from the function to the NStack log.

.. note ::
  There is no need to create a separate module in order to define a
  workflow. You could have included the definition of ``w`` in the
  ``module.nml`` of the original Python module ``Demo.NumChars``.
  In that case, you would not need to prefix ``numChars`` with ``D.``,
  as it is defined in the same module.

When we created our Python module, we defined the input and output types of our function in our API. On NStack, sources and sinks also have types: this workflow specifies that the HTTP source only receives and passes on ``Text``, and the log only accepts ``Integer``\s. Because our Python function takes ``Text``, counts it, and returns ``Integer``\s, that means it can fit in the middle of the workflow.

.. note :: The http source is configured in this example to expose an endpoint on ``/demo``. If you are using the demo server, we would recommend changing ``/demo`` to something more unique -- as someone else may have already taken that endpoint.

Let's break these parts to see what we're doing:

===============================================  ===========
Part                                             Description
===============================================  ===========
``Sources.http<Text> { http_path = "/demo" }``   Use ``http`` as a source, which creates an endpoint on ``/demo``. The ``<Text>`` statement means it can only accept and pass on Text.

``Demo.numChars``                                The name of the function which we built.

``Sinks.log<Integer>``                           Use NStack's log as a sink. The ``<Integer>`` statement means it can only accept Integers.
===============================================  ===========

NStack uses the ``|`` operator to connect statements together, just like in a shell such as ``bash``. 

Building our workflow
---------------------

Before we start our workflow, we need to build it in the cloud with NStack. We do this in the same way we build a Python module. We save our ``module.nml`` file and run:

.. code :: bash

 ~/DemoWorkflow/ nstack build
 Building NStack Workflow module DemoWorkflow:0.0.1-SNAPSHOT. Please wait. This may take some time.
 Workflow module DemoWorkflow:0.0.1-SNAPSHOT built successfully. Use `nstack list all` to see all available functions.

We can now see our workflow is live by using the list command.

.. code :: bash

  ~/DemoWorkflow/ nstack list workflows
  DemoWorkflow:0.0.1-SNAPSHOT
    w : Workflow

This means our workflow is ready to be started.

Starting and using our workflow
---------------------------------

To start our workflow in the cloud, we use the start command:

.. code :: bash
 
 ~/DemoWorkflow/ $ nstack start DemoWorkflow:0.0.1-SNAPSHOT w

We now have a live HTTP endpoint on ``localhost:8080/demo``. The HTTP endpoint is configured to accept JSON-encoded values. We defined it to use an input schema of ``Text``, so we will be able to send it any JSON ``string``. In our JSON, we put ``params`` as the key, and our input as the value:

We can call it using ``nstack send``:

.. code:: bash

 ~/DemoWorkflow/ $ nstack send "/demo" '"Foo"'
 > Message Accepted

When workflows are started, they become *processes* which have numerical identifiers (_ids_). We can see the id of our process by running:

.. code :: bash

 ~/DemoWorkflow/ $ nstack ps 
 1

And if we look at the log of our process, which we configured as the sink, we will be able to see the result. Because our process was started with an id of ``1``, we run the following:

.. code:: bash

 > nstack log 1
 Feb 17 09:59:26 nostromo nstack-server[8925]: OUTPUT: 3

Great - we can see that the output of our function (and the number of characters in "Foo") is 3.
