.. _supported-integrations:

Supported Integrations
======================

NStack is built to integrate with existing infrastructure, event, and data-sources. Typically, this is by using them as *sources* and *sinks* in the NStack Workflow Language.

.. seealso:: Learn more about *sources* and *sinks* in :ref:`Concepts<concepts>` 

Sources
^^^^^^^

Postgres
-------

::

    Sources.postgres<Text> {
      pg_host = "localhost", pg_port = "5432",
      pg_user = "user", pg_password = "123456",
      pg_database = "db", pg_query = "SELECT * FROM tbl;" }

``pg_port`` defaults to 5432, ``pg_user`` defaults to ``postgres``, and
``pg_password`` defaults to the empty string. The other parameters are mandatory.

HTTP
----

::

    Sources.http<Text> { http_path = "/foo" }

RabbitMQ (AMQP)
--------------

::
 
    Sources.amqp<Text> {
      amqp_host = "localhost", amqp_port = "5672",
      amqp_vhost = "/", amqp_exchange = "ex",
      amqp_key = "key"
    }

``amqp_port`` defaults to 5672 and ``amqp_vhost`` defaults to ``/``.
The other parameters are mandatory.


Stdin
-----


::

  Sources.stdin<Text>

``Sources.stdin`` has type ``Text``.
It does not take any arguments and does not require a type annotation,
but if the type annotation is present,
it must be ``Text``.

When ``Sources.stdin`` is used as a process's source,
you can connect to that process by running ::

  nstack connect $PID

where ``$PID`` is the process id
(as reported by ``nstack start`` and ``nstack ps``).

After that,
every line fed to the standard input of ``nstack connect``
will be passed to the process as a separate ``Text`` value,
without the trailing newline.

To disconnect, simulate end-of-file by pressing ``Ctrl-D`` on UNIX
or ``Ctrl-Z`` on Windows.



Sinks
^^^^^

Postgres
-------

::

    Sinks.postgres<Text> {
      pg_host = "localhost", pg_port = "5432",
      pg_user = "user", pg_password = "123456",
      pg_database = "db", pg_table = "tbl" }

Like for Postgres source,
``pg_port`` defaults to 5432, ``pg_user`` defaults to ``postgres``, and
``pg_password`` defaults to the empty string. The other parameters are mandatory.


RabbitMQ (AMQP)
---------------

::

    Sinks.amqp<Text> {
      amqp_host = "localhost", amqp_port = "5672",
      amqp_vhost = "/", amqp_exchange = "ex",
      amqp_key = "key"
    }

Like for AMQP source,
``amqp_port`` defaults to 5672 and ``amqp_vhost`` defaults to ``/``.
The other parameters are mandatory.


NStack Log 
---------
::

    Sinks.log<Text>

The Log sink takes no parameters.


Stdout
------

::

     Sinks.stdout<Text>

``Sinks.stdout`` has type ``Text``.
It does not take any arguments and does not require a type annotation,
but if the type annotation is present,
it must be ``Text``.

When ``Sinks.stdout`` is used as a process's source,
you can connect to that process by running ::

    nstack connect $PID

where ``$PID`` is the process id
(as reported by ``nstack start`` and ``nstack ps``).

After that,
every ``Text`` value produced by the process
will be printed to the standard output by ``nstack connect``.

To disconnect, simulate end-of-file by pressing ``Ctrl-D`` on UNIX
or ``Ctrl-Z`` on Windows.


Firebase
--------

::

    Sinks.firebase {
      firebase_host = "localhost",
      firebase_port = "111",
      firebase_path = "..."
    }

All parameters are mandatory.


Custom
------

You can define a custom sink in Python by declaring a function of type
``t -> Void`` (where ``t`` is any supported type except ``Void``)
and implementing this function in Python as usual.
The return type of this function will be ignored.



Conversions
^^^^^^^^^^^


JSON
----

::

  Conv.from_json<(Integer,Boolean)>
  Conv.to_json<(Integer,Boolean)>

These functions convert between nstack values and ``Text`` values
containing JSON. They have types ::

  Conv.from_json<type> : Text -> type
  Conv.to_json<type>   : type -> Text

Supported types are:

  * ``Integer``
  * ``Double``
  * ``Boolean``
  * ``Text``
  * ``[Byte]``
  * Arrays of supported types
  * Tuples of supported types
  * Structs of supported types

CSV
---

::

    Conv.from_csv<(Integer,Boolean)>
    Conv.to_csv<(Integer,Boolean)>

These functions convert between nstack values and ``Text`` values
containing comma-separated fields. They have types ::

  Conv.from_csv<type> : Text -> type
  Conv.to_csv<type>   : type -> Text

Supported field types are:

  * ``Integer``
  * ``Double``
  * ``Boolean`` (encoded as ``TRUE`` or ``FALSE``)
  * ``Text``
  * ``[Byte]``
  * Optional of another supported field type

Supported row types are:

  * Arrays of supported field types
  * Tuples of supported field types
  * Structs of supported field types

If the row type is a struct,
then the first emitted or consumed value is the CSV header.
The column names in the header correspond to
the field names of the struct.

If the row type is an array or a tuple,
no header is expected or produced.

Text values produced by ``to_csv`` are not newline-terminated.
Text values consumed by ``from_csv`` may or may not be newline-terminated.
