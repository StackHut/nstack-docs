.. _module:

Building a Module
=========================

*Modules* contain the *functions* that you want to publish to the NStack platform. 

After this tutorial, we will have a simple Python module deployed to our NStack instance. This module will have a single function in it which counts the number of characters in some text. 

.. note:: Before starting, check that NStack is installed by running ``nstack --version`` in your terminal. If you got information about the version of NStack you have, you're good to go. If that didn't work, check out :doc:`Installation </installation>` again.


Step 1: ``init``
----------------

We want to create a new Python module.

Create a directory called ``Demo`` where you would like to build your module and ``cd`` into that directory using your terminal. NStack uses the name of the directory as the default name of the module

To create a new module, run ``nstack init -l python``.
You should see the following output confirming that this operation was successful.

.. code:: bash

  ~> mkdir Demo.NumChars
  ~> cd Demo.NumChars
  ~/Demo> nstack init -l python
  python module 'Demo.NumChars:0.0.1-SNAPSHOT' successfully initialised at ~/Demo.NumChars

Because NStack versions your modules, it has given ``Demo.NumChars`` a version number (``0.0.1-SNAPSHOT``). Because the version number has a ``SNAPSHOT`` appended to it, this means NStack allows you to override it every time you build. This is helpful for development, as you do not need to constantly increase the version number. When you deem your module is ready for release, you can remove ``SNAPSHOT`` and NStack will create an immutable version of ``0.0.1``.

A successful ``init`` will have created some files.

.. code:: bash

 ~/Demo.NumChars> ls
 nstack.yaml  requirements.txt  service.py  setup.py  module.nml

This is the skeleton of an NStack module. ``nstack.yaml`` is the configuration file for your module, ``module.nml`` describes the functions and types defined in your module, and ``service.py`` is where the code of your module lives (in this case, it's a Python class). ``requirements.txt`` and ``setup.py`` are both standard files for configuring Python.

We're going to be concerned with ``module.nml`` and ``service.py``. For a more in-depth look at all these files, refer to :doc:`Module Structure </reference/module_structure>`.

In ``service.py``, there is a ``Service`` class. This is where we write the functions we want to use on NStack. It is pre-populated with a sample function, ``numChars``, that counts the number of characters in some text.

.. code:: python

  #!/usr/bin/env python3
  # -*- coding: utf-8 -*-
  """
  Demo.NumChars Module
  """
  import nstack

  class Module(nstack.Module):
      def numChars(self, x):
          return len(x)


``module.nml`` is where you tell NStack which of the functions in ``service.py`` you want to publish as functions on NStack,
and their input and output schemas (also known as types).

::

  module Demo.NumChars:0.0.1-SNAPSHOT

  fun numChars : Text -> Integer

In this instance, we are telling NStack to publish one function, ``numChars``, which takes ``Text`` and returns an ``Integer``.

.. note:: The schema -- or type -- system is a key feature of NStack that lets you define the sort of data your function can take as input, and produce as output. This helps you ensure that your module can be reused and works as intended in production.

Step 2: ``build``
-------------

To build and publish our module on NStack, we use the ``build`` command. 

.. code:: bash

  ~/Demo.NumChars> nstack build
  Building NStack Container module Demo.NumChars:0.0.1-SNAPSHOT. Please wait. This may take some time.
  Module Demo.NumChars:0.0.1-SNAPSHOT built successfully. Use `nstack list functions` to see all available functions

When we run ``build``, the code is packaged up and sent to the server.

We can check that our ``numChars`` function is live by running the suggested ``nstack list functions`` command:

.. code:: bash

  ~/Demo.NumChars> nstack list functions
  Demo.NumChars:0.0.1-SNAPSHOT
    numChars : Text -> Integer

That's it! Our ``numChars`` function is live in the cloud, and is ready to be connected to input and output data streams, which the next tutorial will cover.


