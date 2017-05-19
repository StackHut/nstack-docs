.. highlight:: none

.. _workflow_language:

Workflow Language
=================

Overview
--------

A module consists of:


1. module header
2. import statements
3. type definitions
4. external function declarations
5. function definitions

in this order, for instance: ::

  module ModuleB:0.1.0

  import ModuleA:0.1.0 as A

  type BType = A.Type

  fun b : Text -> (BType, A.OtherType)

  def x = A.y | b

All sections except the module header are optional.

Import Statements
-----------------

An import statement includes the module to be imported (``MyModule:0.1.0``)
and its alias (``A``).
The alias is used to qualify types and functions imported from the module,
e.g. ``A.y``.

Type Definitions
----------------

Types are defined using the ``type`` keyword: ::

  type PlantInfo = { petalLength : Double
                   , petalWidth : Double
                   , sepalLength : Double
                   , sepalWidth : Double
                   }
  type PlantSpecies = Text

The left-hand side of a type declaration is the new type name;
the right-hand side must be an :ref:`existing type<supported_types>`.

A type defined in one module can be used in other module by prefixing it with
the module alias: ::

  module ModuleA:0.0.1
  type AText = Text

::

  module ModuleB:0.0.1
  import ModuleA:0.0.1 as A
  type B = (A.AText, A.AText)

Function Declarations
---------------------

This section declares the types of functions that are backed by containers.
Functions are declared with the ``fun`` keyword: ::

  fun gotham : MovieRecordImage -> MovieRecordImage

Function Definitions
--------------------

Definitions bind function names (``x``) to expressions (``A.y | b``).
They start with the ``def`` keyword: ::

  def z = filter x

If a name is not prefixed by a module alias, it refers to a function defined in
the current module.

Expressions
-----------

Expressions combine already defined functions through the following operations:

Pipe
^^^^^
``A.y | A.z``

  Every value produced by ``A.y`` is passed to ``A.z``.

  The output type of ``A.y`` must match the input type of ``A.z``.

Concat 
^^^^^^
``concat A.y`` or ``A.y*``
  
  ``A.y`` must be a function that produces lists of values,
  in which case ``concat A.y`` is a function that "unpacks" the lists
  and yields the same values one by one.

Filter
^^^^^^
``filter A.y`` or ``A.y?``

  ``A.y`` must be a function that produces "optional" (potentially missing) values,
  in which case ``filter A.y`` is a function that filters out missing values.

Type application 
^^^^^^^^^^^^^^^^
``Sources.A<T>``

Some functions (notably, most sources and sinks) can be specialized
to multiple input or output types.
This is done with type application: ``Sources.http<Text>`` specializes
``Sources.http`` to the type ``Text``.

Parameter application
^^^^^^^^^^^^^^^^^^^^^
``A.y { one = "...", two = "..." }``.

Parameters are analogous to UNIX environment variables in the following ways:

1. Parameters are inherited. E.g. in ::

      def y = x
      def z = y { foo = "bar" }

  both functions ``x`` and ``y`` will have access to ``foo`` when ``z`` is
  called.

2. Parameters can be overridden. E.g. in ::

      def y = x { foo = "baz" }
      def z = y { foo = "bar" }

  ``y`` overrides the value of ``foo`` that is passed to ``x``.
  Therefore, ``x`` will see the value of ``foo`` as ``baz``, not ``bar``.

Parameters are used to configure sources and sinks —
for instance, to specify how to connect to a PostgreSQL database.

Parameters can also be used to configure user-defined modules.
Inside a Python nstack method, the value of parameter ``foo`` can be accessed as
``self.args["foo"]``.

Comments 
^^^^^^^^

The workflow language supports line and block comments.
Line comments start with ``//`` and extend until the end of line.
Block comments are enclosed in ``/*`` and ``*/`` and cannot be nested.

EBNF grammar
------------

The syntax is defined in EBNF (ISO/IEC 14977) in terms of tokens.

.. highlight:: ebnf

::

  module = 'module', module name
         , {import}
         , {type}
         , {declaration}
         , {definition}
         ;
  import = 'import', module name, 'as', module alias;
  type = 'type', name, '=', ( type expression | sum type );
  declaration = 'fun', name, ':', type expression,
                            '->', top-level type expression;
  definition = 'def', name, '=', expression;
  top-level type expression = type expression | 'Void';
  type expression = type expression1
                  | 'optional', type expression 1
                  ;
  type expression1 = tuple
                   | struct
                   | array
                   | qualified name;
  tuple = '(', ')'
        | '(', type expression, ',', type expression,
         {',', type expression}, ')';
  struct = '{', name, ':', type expression,
          {',', name, ':', type expression}, '}';
  sum type = name, type expression1, '|', name, type expression1,
          {'|', name, type expression1};
  expression = expression1, {'|', expression1};
  expression1 = application, '*'
              | application, '?'
              | 'concat', application
              | 'filter', application
              ;
  application = term [arguments];
  arguments = '{', argument binding, {',', argument binding}, '}';
  argument binding = name, '=', literal;
  term = '(', expression, ')'
       | qualified name ['<', type, '>']
       ;
