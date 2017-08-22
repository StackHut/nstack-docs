.. _bigquery_walkthrough:


BigQuery Walkthrough
====================

NStack offers Google Cloud BigQuery integration
which you use by extending a built-in BigQuery module
with your own data types, SQL, and credentials.

This walkthrough will show you how to use this module to upload data,
download data,
delete tables,
and run queries.

Supported Operations
--------------------

There are four interactions you can have with BigQuery,
which are exposed as NStack functions

================  ===========   
Function          Description     
================  ===========
``runQuery``      Execute an SQL query on BigQuery 
``downloadData``  Download rows of data from a table
``uploadData``    Upload rows of data to a table
``dropTable``     Delete a table from BigQery
================  ===========

How To
------

Init a new BigQuery Module
--------------------------

BigQuery exists as a ``Framework`` Module within NStack.
Framework modules contain pre-built functions,
but require you to add your own files,
configuration,
and type signatures. 
In this case, it is our credentials,
SQL files,
and the type signatures of the data we are uploading or downloading.

.. note:: Learn more about :ref:`features-framework`

To use it, we ``nstack init`` a new module
and change it to use the BigQuery module as its parent.

::

  > mkdir CustomerTable; cd CustomerTable
  > nstack init python nstack/BigQuery:0.2.0

The extra parameter to the init command here 
sets the parent framework module to be BigQuery,
rather than the default Python image.

As the BigQuery module already has the functionality we need baked into it,
we can delete the python files that ``init`` creates by default, as we will not be using them:

::

  > rm service.py setup.py requirements.txt

Add your credentials
--------------------

To interact with BigQuery,
the module must be able to authenticate with the BigQuery servers
and therefore must have a copy of valid BigQuery credentials.

To add your credentials, you generate them from Google Auth in JSON format.

.. note:: 

  See https://cloud.google.com/bigquery/authentication 
  for details on how to generate json credentials 

Then place them in a file in the module directory, e.g. ``credentials.json``.

::

  {
    "type": "service_account",
    "project_id": "fake-project-462733",
    "private_key_id": "5eb41c28aede90da40529221be4ac85f514134ba",
    "private_key": "-----BEGIN PRIVATE KEY-----...private key here...-----END PRIVATE KEY-----\n",
    "client_email": "my-user@fake-project-462733.iam.gserviceaccount.com",
    "client_id": "981722325615647221019",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://accounts.google.com/o/oauth2/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/tmg-user%40fake-project-462733.iam.gserviceaccount.com"
  }

Then add this file to the ``files`` list in the ``nstack.yaml`` build file:

::

  files: 
    - credentials.json

Doing this this will include the file in the module.
When we use our BigQuery module in a workflow, we will tell the module to use this file by specifying it as a configuration parameter.

Add your SQL
------------

Similarly, if we're going to use ``runQuery`` to execute SQL,
we include our SQL script in the module files list in the same way. 

.. note:: 

   If you are only using ``downloadData``, ``uploadData`` or ``dropTable``, you do not need to include this file as you are not executing any SQL.

If your SQL query lives in ``example_query_job.sql``, copy that file into your module directory,
and add it to the files list (which already includes your credentials):

::

  files:
    - credentials.json
    - example_query_job.sql

Define your types and declare your function
-------------------------------------------

If you're uploading data from NStack or downloading data into NStack, 
you declare the types of data your function will take or return.
This is either the data you are going to be uploading,
or the data you expect to download from the table.
Either way, the type signature should match the Database Schema.

E.g. if you have a table with the following columns:

::

  ---------------------------------------------------------------------------------------
  | CustomerName VarChar | CustomerAddress VarChar | CustomerId Int64 | CountryId Int64 |
  ---------------------------------------------------------------------------------------

Then you define a ``Customer`` type in you module's ``module.nml`` as follows:

::

  type Customer = {
                    name : Text,
                    address: Text,
                    id : Int,
                    countryId : Int
                  }

.. Note::

  The fields must be in the correct order to match the DB table. 
  The names do not need to match,
  and if you misorder two or more fields -
  but the types still match -
  then you will get results containing the wrong fields

Once you have the type declared,
you can then declare the BigQuery action you wish to take
as an NStack function.

Open the ``module.nml`` file and remove the example function ``numChars``.
Instead you must write a function definition for one or more of the 
``runQuery``, ``downloadData`` or ``uploadData`` functions that exist in the BigQuery parent image.
If downloading or uploading,
you declare them to use a list of the data type you just declared
as input or output.

For instance, to upload a list of customer records to a table:

::

  uploadData : [Customer] -> ()

Download a table as a list of customer records:

::

  downloadData : () -> [Customer]

Execute a single SQL query:

::

  runQuery : () -> ()

Delete a table

::

  dropTable : () -> ()

Build your module
-----------------

Once the previous steps have been completed, 
you can build your module as normal using ``nstack build``.

If you run ``nstack list functions`` 
you should see your new functions listed there:

::

  nstack/CustomerTable:0.0.1-SNAPSHOT
    downloadData :: () -> [Customer]

Configure and Run
-----------------

Now that your module is registered with the server, 
you can use the functions in workflows like any other function.

The BigQuery module takes a number of configuration parameters
to allow you to configure it correctly 
for working with your particular BigQuery project

All BigQuery functions need the following configuration parameters supplied:

======================= ===========   
Configuration           Description     
======================= ===========
``bq_credentials_file`` Path to the credentials file used to authenticate with BigQuery. 
``bq_project``          Name of the BigQuery Project to use
``bq_dataset``          Name of the BigQuery Dataset in the above project to use
======================= ===========

The ``uploadData``, ``downloadData`` and ``dropTable`` functions also need the following parameter:

================  ===========   
Configuration     Description     
================  ===========
``bq_table``      Name of the table to upload to, download from, or delete, respectively. 
================  ===========

The ``runQuery`` function needs the following parameters

=================  ===========   
Configuration      Description     
=================  ===========
``bq_query_file``  SQL query to execute. 
``bq_query_dest``  Table to store the results of the sql query. 
=================  ===========

The following parameters may be used when using ``runQuery``,
but are optional and can be ommitted if unneeded.

===========================  ===========   
Configuration                Description     
===========================  ===========
``bq_maximum_billing_Tier``  Maximum billing tier if not default, must be an integer
``bq_use_legacy_sql``        Boolean flag to use legacy bigquery SQL format, rather than standard SQL. Should be "Yes", "No", "True" or "False"
===========================  ===========

For instance, to expose a database uploader as an HTTP endpoint, you might do the following:

::

  def upload = CustomerTable.uploadData {
                  bq_credentials_file = "credentials.json",
                  bq_project = "AcmeCorp",
                  bq_dataset = "AcmeCorpSales"
                  bq_table = "CustomerTable",
                }

  def workflow = Sources.http<[Customer]> { http_path = "/addCustomers" } | upload | Sinks.log<()>

Or to run a query on a given schedule:

::

  def query = CustomerTable.runQuery {
                bq_credentials_file = "credentials.json",
                bq_project = "AcmeCorp",
                bq_dataset = "AcmeCorpSales"
                bq_query_file = "SalesQuery.sql",
                bq_query_dst = "SalesAnalysisResults"
              }

  def workflow = Sources.schedule<()> { cron = "* * * * * *" } | query | Sinks.log<()>


Template Configuration
----------------------

The BigQuery module supports using Jinja2 templates 
inside of its configuration parameters
and in the SQL queries it executes.

This allows you to build more flexible functions
that can cover a wider range of behaviors.

.. note::

  For full details on Jinja2 templates, see http://jinja.pocoo.org/docs/2.9/templates/

The syntax you will use most is the standard expression template, 
which uses double curly braces:

::

  prefix_{{ some.template.expression }}_suffix

Here the expression in curly braces will be evalated and replaced with its result.

The Jinja2 templates are evaluated in a sandbox for security reasons,
so you do not have access to the full python standard library.

However, date and time functionality is exposed from the ``datetime`` package
and can be accessed through the 
``date``, ``time``, ``datetime`` and ``timedelta`` variables.

E.g. to specify a target table for a query based on todays date, you can use

::

  runQuery { bq_query_dest = "MyTablePrefix_{{ date.today().strftime('%Y%m%d') }}" }

On the 6th of July 2017, this would write to a table called ``MyTablePrefix_20170706``.

These value are evaluated every time the function processes a message,
so if you keep the workflow running 
and send events to the function over multiple days
you will write to a different table each time.

.. note::

  For Python datetime formatting help, see: https://docs.python.org/2/library/datetime.html

In the SQL query itself, you have access to the same date and time functionality, 
including calculing offsets via timedelta.

E.g. to query last weeks table:

::

	SELECT * FROM MyTablePrefix_{{ (date.today() - timedelta(days=7)).strftime('%Y%m%d') }} LIMIT 1000

In the SQL, you can also refer to the function configuration parameters 
(as defined in your workflow DSL)
under a ``config`` object.

E.g. to access a parameter named ``source_table``, you can write:

::

	SELECT * FROM MyTablePrefix_{{ config.source_table }} LIMIT 1000

and then specify it in the DSL:

::

  runQuery { source_table = "SomeTable" }

.. note::

  You can add as many config parameters to a function as you like, even if they're not normally used by the function
