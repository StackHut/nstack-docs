.. _concepts:

NStack Concepts
***************

Example
-------

.. image:: resources/readme-flowchart-example.svg

We can express this within the NStack scripting language locally as follows (it can help to think of it akin to Bash-style piping for microservices),

.. code:: fsharp

  module Demo:0.1.0 {
    import NStack.Transformers:0.1.4 as T
    import Acme.Classifiers:0.3.0 as C

    // our analytics workflow
    def workflow = Sources.Postgresql<(Text, Int)> 
                   | T.transform { strength = 5 }
                   | C.classify { model = "RandomForest" }
                   | Sinks.S3blob<Text>
  }



Intro Screencast
^^^^^^^^^^^^^^^^

.. raw:: html

    <script type="text/javascript" src="https://asciinema.org/a/112733.js" id="asciicast-112733" async></script>


.. _concepts-module:

Modules
-------

A *module* is a piece of code that has been deployed to NStack, either by you or someone else. It has an input schema and an output schema, which defines what kind of data it can receive, and the kind of data that it returns.

.. _concepts-sink-source:

Sources & Sinks
---------------

* A *source* is something which emits a stream of data. 
* A *sink* is something which can receive a stream of data.

Example sources and sinks are databases, files, message-queues, and HTTP endpoints. Like modules, you can define the input and output schemas for your sources and sinks.

.. _concepts-workflows:

Workflows
---------

Modules, sources, and sinks can be combined together to build *workflows*. This is accomplished using the *NStack Workflow Language*, a simple, high-level language for connecting things together on the *NStack Platform*.

Processes
---------

When a workflow is started, it becomes a running `process`. You can have multiple processes of the same workflow.

