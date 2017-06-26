.. _nstack_types:

NStack Types
============

Primitive types
---------------

NStack supports the following primitive types

============== ============================
NStack Type    Notes
============== ============================
``Integer``    A signed integer
``Double``     A 64-bit floating-point value
``Boolean``    A ``true`` or ``false`` value
``Text``       Unicode text
``Json``       Text containing with JSON-encoded content
============== ============================

Complex types
-------------

More complex types can be built out of primitive ones:

================ =========================    =========================================
NStack Type      Syntax                       Notes
================ =========================    =========================================
Optional types   ``T optional``               Optional value of type ``T``
Tuples           ``(A, B, ...)``              A tuple must have at least two fields
Structs          ``{ x: A, y: B, ... }``      
Arrays:          ``[T]``                      Use ``[Byte]`` to specify a byte-array, i.e. a Blob
Void             ``Void``                     Used to define custom sources and sinks, see :ref:`supported-integrations`
Unit             ``()``                       Signifies an event which contains no data
================ =========================    =========================================

.. `Sums <https://en.wikipedia.org/wiki/Algebraic_data_type>`_: ``Name1 type1a ... | Name2 type2a ... | ...``


A user can make use of these types and define their own type in the :ref:`workflow_language`.
Look at :ref:`languages` to see how they can be used from Python, R, etc. in your own modules.

Sending untyped data
--------------------

Most types can be built from combinations of primitive and complex types. 
However, if you find your types are too complex, or change too often, you can use the ``Json`` or ``[Byte]`` types to send data between modules either as ``Json`` or binary blobs.
By doing this ``nstack`` won't be able to ensure that the contracts in you workflow are correct and this disables automatically decoding/encoding data. 

This is helpful when sending data such as Python pickled objects, when prototyping, or when you are in a pinch. However, we recommend creating proper types and contracts for your modules and workflows when possible.


