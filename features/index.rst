.. _features:

Features
========

In this section, we're going to describe some of the more advanced features you can do with NStack when building your modules and composing them together to build workflows.

.. _features-composition:

Composition
-----------

Workflows can contain as many steps as you like, as long as the output type of one matches the input type of the other. For instance, let's say we wanted to create the following workflow based on the Iris example in :ref:`in-depth-tutorial` and available on `GitHub <https://github.com/nstack/nstack-examples/tree/master/iris>`_

- Expose an HTTP endpoint which takes four ``Double``\s
- Send these ``Double``\s to our classifier, ``Iris.Classify``, which will tell us the species of the iris
- Count the number of characters in the species of the iris using our ``Demo.numChars`` function
- Write the result to the log

We could write the following workflow:

::
   
  module Iris.Workflow:0.0.1-SNAPSHOT
  import Iris.Classify:0.0.1-SNAPSHOT as Classifier
  import Demo:0.0.1-SNAPSHOT as Demo

  def multipleSteps =
    Sources.http<(Double, Double, Double, Double)> { http_path = "/irisendpoint" } |
    Classifier.predict |
    Demo.numChars |
    sinks.log<Integer>

.. note :: ``numChars`` and ``predict`` can be `composed` together because their types -- or schemas -- match. If ``predict`` wasn't configured to output ``Text``, or ``numChars`` wasn't configured to take ``Text`` as input, NStack would not let you build the following workflow.

.. _features-streaming:

.. include:: ./streaming.rst

.. _features-reuse:

Workflow Reuse
--------------

All of the workflows that we have written so far have been `fully composed`, which means that they contain a source and a sink. Many times, you want to split up sources, sinks, and functions into separate pieces you can share and reuse. In this case, we say that a workflow is `partially composed`, which just means it does not contain a source and a sink. These workflows cannot be ``start``\ed by themselves, but can be shared and attached to other sources and/or sinks to become `fully composed`. 

For instance, we could combine ``Iris.Classify.predict`` and ``demo.numChars`` from the previous example to form a new workflow ``speciesLength`` like so:

::
  
  module Iris.Workflow:0.0.1-SNAPSHOT
  import Iris.Classify:0.0.1-SNAPSHOT as Classifier
  import Demo:0.0.1-SNAPSHOT as Demo

  def speciesLength = Classifier.predict | Demo.numChars

Because our workflow ``Iris.Workflow.speciesLength`` has not been connected to a source or a sink, it in itself is still a function. If we build this workflow, we can see ``speciesLength`` alongside our other functions by using the ``list`` command:

.. code :: bash
  
  ~/Iris.Workflow/ $ nstack list functions
  Iris.Classify:0.0.1-SNAPSHOT
    predict : (Double, Double, Double, Double) -> Text
  Demo:0.0.1
    numChars : Text -> Integer
  Iris.Workflow:0.0.1-SNAPSHOT
    speciesLength : (Double, Double, Double, Double) -> Integer

As we would expect, the input type of the workflow is the input type of ``Iris.Classify.predict``, and the output type is the output type of ``demo.numChars``. Like other functions, this must be connected to a source and a sink to make it `fully composed`, which means we could use this workflow it in *another* workflow.

::

  module Iris.Endpoint:0.0.1-SNAPSHOT
  import Iris.Workflow:0.0.1-SNAPSHOT as IrisWF
  def http = Sources.http<(Double, Double, Double, Double)> |
    IrisWF.speciesLength |
    Sinks.log<Integer>

Often times you want to re-use a source or a sink without reconfiguring them. To do this, we can similarly separate the sources and sinks into separate workflows, like so:

::
  
  module Iris.Workflow:0.0.1-SNAPSHOT
  import Iris.Classify:0.0.1-SNAPSHOT as Classifier

  def httpEndpoint = sources.http<(Double, Double, Double, Double)> { http_path = "speciesLength" }
  def logSink = sinks.log<Text>

  def speciesWf = httpEndpoint | Classifier.predict | logSink

Separating sources and sinks becomes useful when you're connecting to more complex integrations which you don't want to configure each time you use it -- many times you want to reuse a source or sink in multiple workflows. In the following example, we are defining a module which provides a source and a sink which both sit ontop of Postgres. 

::

  module Iris.DB:0.0.1-SNAPSHOT

  def petalsAndSepals = Sources.postgres<(Double, Double, Double, Double)> {
    pg_database = "flowers",
    pg_query = "SELECT * FROM iris"
  }

  def irisSpecies = Sinks.postgres<Text> {
    pg_database = "flowers",
    pg_table = "iris"
  }

If we built this module, ``petalsAndSepals`` and ``irisSpecies`` could be used in other modules as sources and sinks, themselves.

We may also want to add a functions to do some pre- or post- processing to a source or sink. For instance:

::

  module IrisCleanDbs:0.0.1-SNAPSHOT

  import PetalTools:1.0.0 as PetalTools
  import TextTools:1.1.2 as TextTools
  import Iris.DB:0.0.1-SNAPSHOT as DB

  def roundedPetalsSource = DB.petalsAndSepals | PetalsTools.roundPetalLengths
  def irisSpeciesUppercase = TextTools.toUppercase | DB.irisSpecies

Because ``roundedPetalsSource`` is a combination of a source and a function, it is still a valid source. Similarly, ``irisSpeciesUppercase`` is a combination of a function and a sink, so it is still a valid sink.

Because NStack functions, source, and sinks can be composed and reused, this lets you build powerful abstractions over infrastructure.


.. _features-versioning:

Versioning
----------

Modules in NStack are versioned with a 3-digit suffix that is intended to follow semantic versioning, e.g.::
  
  Demo:0.0.1
  
This is specified in the ``nstack.yaml`` for code-based modules, and in ``module.nml`` for workflow modules.
A module of a specific version is completely immutable, and it's not possible to build another copy of the module with the same version without deleting it first.

Snapshots
^^^^^^^^^

When creating a new module, i.e. with ``nstack init``, your module will have the version number (``0.0.1-SNAPSHOT``). 
The ``SNAPSHOT`` tag tells NStack to allow you to override it every time you build. 
This is helpful for development, as you do not need to constantly increase the version number. 
When you deem your module is ready for release, you can remove the ``SNAPSHOT`` suffix and NStack will create an immutable version of ``0.0.1``.

.. note :: Care is needed importing SNAPSHOT modules, NStack will warn you if your snapshot module changes in such a way that your imports/pipeline are no longer valid and ask you to rebuild if needed. You can also resolve this using project files that rebuild all dependencies as needed - see :ref:`features-project`

.. _features-configuration:

Configuration
-------------

In addition to receiving input at runtime, modules, sources, and sinks often need to be able to configured by a workflow author. To do this, we use brackets and pass in a list of named records: ::

   Sources.Postgres<Text> {
        pg_host = "localhost", 
        pg_port = "5432",
        pg_user = "user", 
        pg_password = "123456",
        pg_database = "db", 
        pg_query = "SELECT * FROM tbl;" 
    }

For sources and sinks, some parameters are mandatory, and some provide sensible defaults. This is documented in `Supported Integrations <supported_integrations>`_.

To pass configuration parameters to a module, we use the same syntax ::

  FirstLastName.full_name { first_name = "John" }

NStack passes in configuration parameters as a dictionary, ``args``, which is added to the base class of your module.
For instance, in Python you can access configuration parameters in the following manner:

.. code :: python 
  
  class Service(nstack.BaseService):
  
      def full_name(self, second_name):
        full_name = "{} {}".format(self.args.get("first_name", "Tux"), second_name)
        return full_name


.. _features-framework:


Framework Modules
-----------------

It is often useful to create a common parent module with dependencies already installed, either to save time or for standardisation. NStack supports this with *Framework Modules*. Simply create a new module similar to above, ``nstack init framework [parent]``, and modify the resulting ``nstack.yaml`` as needed.

You can then build this module using ``nstack build``, and refer to it from later modules within the ``parent`` field of their ``nstack.yaml`` config file.

.. _features-project:

NStack Projects
---------------

When using NStack you may find that you are working on several different modules at once that are imported into a main module where they are composed into a workflow. In these cases it can be cumbersome to to ensure you rebuilt every module manually to ensure all changes are propagated. NStack provides *projects* in these cases that are used to logically group a set of modules together so that they are all built together in the correct order.

Assuming your modules are all contained as directories within ``./modules``, an NStack project can be formed by creating a file called ``nstack-project.yaml`` in the root directory, e.g.

.. code :: bash

  modules/
  ├── Acme.PCA/
  ├── Acme.CustomerChurn/
  └── nstack-project.yaml

where ``nstack-project.yaml`` simply contains the list of module directories that can be ordered as needed, e.g.

.. code :: yaml

  # NStack Acme Project File
  modules:
    - Acme.PCA
    - Acme.CustomerChurn

Simply run ``nstack build`` from the root ``modules`` directory and all listed modules will be compiled in the order given.

