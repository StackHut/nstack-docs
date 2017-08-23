.. _creating-structure:

Module Structure
================

Introduction
------------

The following files are created when you create an nstack module using:

.. code:: bash

    $ nstack init <stack>

.. _creating-structure-yaml:


module.nml
----------

See :ref:`workflow_language`.

nstack.yaml 
-----------

The ``nstack.yaml`` file describes the configuration of your nstack module. It has several fields that describe the project and let you control the packaging of your module.

Sample ``nstack.yaml`` file:

.. code-block:: yaml

    # The language stack to use
    stack:
      language: python
      api-version: 1
      snapshot: [25, 0]

    # (Optional) System-level packages needed
    packages: []

    # (Optional) Commands to run when building the module (Bash-compatible)
    commands: []

    # (Optional) Files/Dir to copy across into the module (can use regex/glob syntax)
    files: []


``stack``
^^^^^^^^^

*Optional*

The base language stack and version to use when creating an image. Currently we support:

=======     ===========
Name        Description    
=======     ===========
python      `Python 3.5 <http://python.org/>`_ 
python2     `Python 2.7 <http://python.org/>`_ 
=======     ===========

The ``stack`` is specified using the following three elements, as demonstrated in the sample:
  * ``language`` - the programming language to use, taken from the supported table above
  * ``api-version`` - the version of the language support to use - this is used to ensure compatibility between the server and your functions. The ``api-version`` changes only when there is a major change to the way code interacts with the server, and NStack will warn you if it detects a compatibility issue
  * ``snapshot`` - the specific major and minor versions of the system packages repository to use. These are tied to `Fedora Linux <https://getfedora.org/>`_ versions, e.g. 24, 25, 26, where the second number indicates a snapshot version of the upstream packages that is incremented every fortnight. These are fully reproducible, and it is recommended to keep them at their initial version


``parent``
^^^^^^^^^^

*Optional*

The base-image your module builds from. This is typically generated automatically from the ``stack`` entry above, but can be explicitly specified to reference custom base-images that may include standardised packages (e.g. a pre-built ``scipy`` stack)


.. note:: Either a ``stack`` or ``parent`` element is **required** to build an nstack module containing user-created code in a supported language

``files``
^^^^^^^^^

*Optional*

A list of files and directories within the project directory to include and bundle in alongside the image.

``packages``
^^^^^^^^^^^^

*Optional*

A list of operating systems packages your module requires. These can be any packages installable via ``dnf`` on RHEL or Fedora.
