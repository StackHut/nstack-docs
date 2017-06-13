.. _supported-types:

Supported Types
===============

Primitive types
---------------

NStack supports the following primitive types:

* ``Integer``
* ``Double``
* ``Boolean``
* ``Text``
* ``Json``

When an external function (such as one written in Python)
receives an argument of type ``Json``,
it is represented as a string with JSON-encoded content.

.. ByteArray

More complex types can be built out of primitive ones:

* Optional types: ``type1 optional``
* Tuples: ``(type1, type2, ...)``. A tuple must have at least two fields.
* Structs: ``{ name1: type1, name2: type2, ... }``
* Arrays: ``[type1]``
* `Sums <https://en.wikipedia.org/wiki/Algebraic_data_type>`_: ``Name1 type1a ... | Name2 type2a ... | ...``

``Void`` is a special type that is used to define custom sources and sinks,
see :ref:`supported-integrations`.

``()`` represents Unit, which signifies an event which contains no data. 

A user can define their own type in the :ref:`workflow_language`.
