.. _nstack_cli:

nstack CLI
==========

The nstack CLI is used to build modules and workflows on a linked NStack server.
It can be configured via the ``nstack.conf`` ``yaml`` file found in ``~\.config`` on Linux/macOS, and in ``HOME/AppUser/Roaming`` on Windows, or indirectly via the ``nstack set-server`` command described below.


Usage
-----

Having installed the CLI, make sure it's accessible from your path

.. code:: bash
    
    $ nstack --version
    > nstack 0.0.3

You can find the list of commands and options available by running

.. code:: bash

    $ nstack --help

Commands
--------

This section explains the commands supported by the CLI toolkit.



``register`` 
^^^^^^^^^^^^

.. code:: bash

    $ nstack register username email [-s SERVER]

=============    ===========
Option           Description
=============    ===========
``username``     A unique username to assign on the the server.
``email``        An email address to validate the user and send login credentials to.
``SERVER``       The remote NStack Server to register with, by default this will use our demo server.
=============    ===========

A simple command to register with a remote NStack server so you can login, build modules, start workflows, etc.
Upon successful registration you will receive credentials over email that you can paste into the ``nstack`` CLI and get started.


``set-server``
^^^^^^^^^^^^^^

.. code:: bash

    $ nstack set-server server-addr server-port id key

=============    ===========
Option           Description
=============    ===========
``server-addr``  URL of a remote NStack Server.
``server-port``  Port of a remote NStack Server.
``id``           Your unique id used to communicate with the remote NStack Server.
``key``          Your secret key used to communicate with the remote NStack Server
=============    ===========

This command configures your local NStack CLI to communicate with a remote NStack Server with which you have registered (see previous command). You usually don't have to enter this command by hand, it will be contained with an email after successful registration that you can paste directly into your terminal.

Internally this modifies the ``nstack.conf`` CLI config file on your behalf (found in ``~\.config`` on Linux/macOS, and in ``HOME/AppUser/Roaming`` on Windows).


``info``
^^^^^^^^
.. code:: bash

    $ nstack info

Displays information regarding the entire current state of NStack, including:

 - Modules 
 - Sources 
 - Sinks 
 - Running processes 
 - Base images

``init``
^^^^^^^^
.. code:: bash

    $ nstack init <stack>

============    ===========
Option          Description
============    ===========
``stack``       The default stack to use to build your service, e.g. ``python`` or ``workflow`` (``.nml`` NStack Workflow Language).
============    ===========

Initialises a new nstack module in the current directory using the specified base language stack. This creates a working skeleton project which you can use to write your module.

If you are creating a module in an existing programming language, such as Python, ``init`` creates a module with a single ``numChars`` function already created. The initial project is comprised of the following files,

* ``nstack.yaml``, your service's configuration file  (see :ref:`module_structure`),
* ``service.py``, an application file (or service.js, etc.), where your business-logic lives
* an empty packages file (e.g. ``requirements.txt`` for Python, or ``package.json`` for Node, etc.).

``init`` is the command used to create a new workflow. In this case, NStack creates a skeleton ``workflow.nml`` file.

``build`` 
^^^^^^^^^

.. code:: bash

    $ nstack build 

Builds a module on your hosted nstack instance.  

.. note:: ``build`` is also used to build workflows. Remember, workflows are modules too!


``start``
^^^^^^^^^
.. code:: bash

    $ nstack start <workflow>


==============  ===========
Option          Description
==============  ===========
``<workflow>``  The workflow to start, in NStack Workflow Language
==============  ===========


Used to start a workflow as a process. Workflows can either be provided as an argument such as:

.. code:: bash
    $ nstack start
    > import MySource:0.0.1 as MySource;
    > import MySink:0.0.1 as MySink;
    > import MyModule:0.0.1 as MyModule;
    > MySource.src | MyModule.myMethod | MySink.snk

Or, if you have built a workflow as a module, you can start it with:

.. code:: bash
    $ nstack start "Import MyWorkflow:0.0.1 as W; W.myWorkflow"


``notebook`` 
^^^^^^^^^^^^

.. code:: bash

    $ nstack notebook
   
Create an interactive session within the terminal that provides a mini-REPL (you can also redirect a file/stream into the notebook command to provide for rapid service testing and development). 

From this command-line, you can import modules as needed, and enter a single workflow that will be compiled and run immediately on the server (press ``<Ctrl-D>`` on Linux/macOS or ``<Ctrl-Z>`` on Windows to submit your input).

.. code:: bash

    $ nstack notebook
    import Demo.Classify:0.0.3 as D;
    Sources.http<Text> { http_path = "/classify" } | D.numChars | Sinks.log<Text>
    <Ctrl-D>
    > Service started successfully as process 5



``send`` 
^^^^^^^^

.. code:: bash

    $ nstack send "route" 'data'

=============    ===========
Option           Description
=============    ===========
``route``        The endpoint to send the data where a workflow is running.
``data``         A json snippet to send to the endpoint and pass into a workflow.
=============    ===========

Used with the HTTP source, ``nstack send`` sends a JSON-encoded element to an endpoint on the NStack server where a workflow has been started. Useful for testing workflows that are to be used as web-hooks.





``ps`` 
^^^^^^

.. code:: bash

    $ nstack ps


Shows a list of all processes, which are workflows that are running on your your nstack server.

``stop`` 
^^^^^^^^

.. code:: bash

    $ nstack stop <process-id>

Stop a running process.

``list`` 
^^^^^^^^

.. code:: bash

    $ nstack list <primitive>

===============    ===========
Option             Description
===============    ===========
``<primitive>``    The primitive you want to list.
===============    ===========

Shows a list of available primitives. Support primitives are modules, workflows, functions, sources, and sinks.

``delete`` 
^^^^^^^^^^

.. code:: bash

    $ nstack delete <module>

============    ===========
Option          Description
============    ===========
``<module>``    The module's name.
============    ============

Deletes a module (and thus its functions) from NStack.


``log`` 
^^^^^^^

.. code:: bash

    $ nstack log <process>

=============    ===========
Option           Description
=============    ===========
``<process>``    The id of the process.
=============    ===========
    
View the logs of a running process.

``server-logs`` 
^^^^^^^^^^^^^^^^

.. code:: bash

    $ nstack server-logs
   
View the full logs of the NStack server.

``gc`` 
^^^^^^^^^^^^^^^^

.. code:: bash

    $ nstack gc

Expert: Garbage-collect unused module images to free up space on the server.


