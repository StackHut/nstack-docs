.. _supported-integrations:

Supported Integrations
======================

NStack is built to integrate with existing infrastructure, event, and data-sources. Typically, this is by using them as *sources* and *sinks* in the NStack Workflow Language.

.. seealso:: Learn more about *sources* and *sinks* in :ref:`Concepts<concepts>` 

Sources
-------


Schedule
^^^^^^^^

::

 Sources.schedule<()> {
   cron = "* * * * * *"
 }

NStack's Schedule source allows you to run a workflow in intervals over a time period. It takes a single argument of a *crontab*, which specifies the interval to use. 
Note that NStack's scheduler expects six fields: minute, hour, day of month, month, day(s) of week, year. As the scheduler emits events, it is of type Unit, which is represented by ``()``



Postgres
^^^^^^^^

::

    Sources.postgres<Text> {
      pg_host = "localhost", pg_port = "5432",
      pg_user = "user", pg_password = "123456",
      pg_database = "db", pg_query = "SELECT * FROM tbl;" }

``pg_port`` defaults to 5432, ``pg_user`` defaults to ``postgres``, and
``pg_password`` defaults to the empty string. The other parameters are mandatory.

HTTP
^^^^

::

    Sources.http<Text> { http_path = "/foo" }

NStack's HTTP source allows you to expose an NStack workflow as an HTTP endpoint with a very simple API.

The HTTP source must be configured with the ``http_path``,
a relative URL for the endpoint
on which it will listen for requests, e.g ``/foo``.
All HTTP source endpoints listen on port ``8080``,

Calling
"""""""

To call the endpoint,
you need to send an HTTP request
with the following properties:

Verb: ``PUT`` or ``POST``
content-type: any allowed, but suggest ``application/json``

The request should have a body 
containing a single JSON object
with a single property called ``params``,
which contains a JSON encoded value
of the type expected by the Source.

With ``curl``:

Using the command line utility ``curl``, you can easily run a single command to call the endpoint.

::

    curl -X PUT -d '{ "params" : "Hello World" }' demo.nstack.com:8080/foo


With ``nstack send``:

The ``nstack`` cli utility has a built-in ``send`` command
for interacting with HTTP sources,
to use it just pass in the endpoint relative url,
and the JSON encoded value to send 
(no need to specify the full params object).

::

    nstack send "/foo" '"Hello World"'

.. note:: Note the double quoting on the value - the outer pair of (single) quotes are consumed by the shell, the inner quotes are part of the JSON representation for a string.

RabbitMQ (AMQP)
^^^^^^^^^^^^^^^

::
 
    Sources.amqp<Text> {
      amqp_host = "localhost", amqp_port = "5672",
      amqp_vhost = "/", amqp_exchange = "ex",
      amqp_key = "key"
    }

``amqp_port`` defaults to 5672 and ``amqp_vhost`` defaults to ``/``.
The other parameters are mandatory.


Stdin
^^^^^


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


BigQuery
^^^^^^^^

A module which uploads data from BigQuery, downloads data from BigQuery, or run an SQL query.

::

  import GCP.BigQuery:0.0.1-SNAPSHOT as BQ
  BQ.uploadData { ...config... }


Usage
"""""

* BigQuery is structured as a framework module which you use as a parent to a new Python3 module
* Add your credentials file and BigQuery SQL files to the `files` section of `nstack.yaml`
* Implement one or more of the methods `uploadData`, `downloadData` or `runQuery` with the correct types, e.g.

::

    uploadData : [a] -> ()
    downloadData : () -> [a]
    uploadData : () -> ()

where ``a`` is the row type you want to use

Config
""""""

The following configuration parameters are needed to configure the module when running:

* `bq_credentials_file` - the path to a credentials file (added in the `files` section of `nstack.yaml` in your child module; see above) used to authenticate with BigQuery. This should be in the JSON format.
* `bq_project` - the name of the BigQuery Project to use
* `bq_dataset` - the name of the BigQuery Dataset in the above project to use
* `bq_query_file` - for `runQuery` only; the sql query to execute
* `bq_query_dest` - for `runQuery` only; name of the table to store the results of the sql query
* `bq_table` - for `uploadData` and `downloadData` only; the name of the table to upload to or download from, respectively


Custom
^^^^^^

You can define a custom source in Python by declaring a function of type
``Void -> t`` (where ``t`` is any supported type except ``Void``)
and implementing this function in Python.
The return type of this function must be a generator that returns values of type ``t``.


Sinks
-----

Postgres
^^^^^^^^

::

    Sinks.postgres<Text> {
      pg_host = "localhost", pg_port = "5432",
      pg_user = "user", pg_password = "123456",
      pg_database = "db", pg_table = "tbl" }

Like for Postgres source,
``pg_port`` defaults to 5432, ``pg_user`` defaults to ``postgres``, and
``pg_password`` defaults to the empty string. The other parameters are mandatory.


RabbitMQ (AMQP)
^^^^^^^^^^^^^^^

::

    Sinks.amqp<Text> {
      amqp_host = "localhost", amqp_port = "5672",
      amqp_vhost = "/", amqp_exchange = "ex",
      amqp_key = "key"
    }

Like for AMQP source,
``amqp_port`` defaults to 5672 and ``amqp_vhost`` defaults to ``/``.
The other parameters are mandatory.


AWS S3
^^^^^^

An NStack sink for uploading files to S3 storage on Amazon Web Services

::

  import AWS.S3:0.0.1-SNAPSHOT as S3
  S3.upload { ...config... }

Functions
"""""""""

::

    upload : {filepath: Text, data: [Byte]} -> Text


Uploads a file (represented as a sequence of bytes) to S3 with the given filepath, and returns a ``Text`` indicating the item ``URL``.

Config
""""""

The following configuration parameters are used for uploading to S3:

* ``s3_key_id`` - Your AWS Credentials KeyId
* ``s3_secret_key`` - Your AWS Credentials secret key
* ``s3_bucket`` - The S3 bucket to upload items into


NStack Log 
^^^^^^^^^^
::

    Sinks.log<Text>

The Log sink takes no parameters.


Stdout
^^^^^^

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


Custom
^^^^^^

You can define a custom sink in Python by declaring a function of type
``t -> Void`` (where ``t`` is any supported type except ``Void``)
and implementing this function in Python as usual.
The return type of this function will be ignored.



Conversions
-----------


JSON
^^^^

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
^^^

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
