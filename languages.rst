.. _languages:


Supported Languages
===================

NStack is language-agnostic and allows you to write modules in multiple languages and connect them together -- currently we support Python, with R and Java coming soon. More languages will be added over time -- if there's something you really need, please let us know!

Python
------


Basic Structure
^^^^^^^^^^^^^^^

NStack services in Python inherit from a base class, called ``BaseService`` within the ``nstack`` module::

  import nstack

  class Service(nstack.BaseService):
      def numChars(self, msg):
          return len(msg)

.. note:: Ensure you import the nstack module in your service, e.g. ``import nstack`` 

Any function that you export within the ``API`` section of your ``nstack yaml`` must exist as a method on this class (you can add private methods on this class for internal use as expected in Python).

Data comes into this function via the method arguments - for ``nstack`` all the data is passed within a single argument that follows the ``self`` parameter. For instance, in the example above there is a single argument ``msg`` consisting of a single ``string`` element that may be used as-is. However if your function was defined as taking ``(Double, Double)``, you would need to unpack the tuple in Python first as follows, ::

  def test(self, msg):
      x, y = msg
      ...

Similarly, to return data from your NStack function, simply return it as a single element within your Python method, as in the top example above.

The NStack object lasts for the life-time of the workflow. Any initialisation can be performed within the object ``startup`` method that will be called automatically on service start, e.g. open a database connection, load a data-set, etc.
Similarly a ``shutdown`` method is called on service shutdown, this provides a short time window, 90s, to perform any required shutdown routines before the service is terminated i.e. ::


  import nstack

  class Service(nstack.BaseService):
      def startup(self):
          # custom initialisation here

      def shutdown(self):
          # custom shutdown here

Notes
^^^^^

* Anything your``print`` will show up in ``nstack log`` to aid debugging. (all output on ``stdout`` and ``stderr`` is sent to the NStack logs)
* Extra libraries from pypi using ``pip`` can be installed by adding them to the ``requirements.txt`` file in the project directory - they will be installed during ``nstack build``

Mapping NStack types to Python types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The table below show you what python types to expect and to return when dealing with types defined in the NStack IDL as defined in :ref:`nstack_types`:

============== ============================ 
NStack Type    Python Type                
============== ============================ 
``Integer``    ``int``              
``Double``     ``double.Double``  
``Boolean``    ``bool``  
``Text``       ``str``   
Tuple          ``tuple``    
Struct         ``collections.namedtuple`` *
Array          ``list``                  
``[Byte]``     ``bytes``                  
``x optional`` ``None`` or ``x``              
``Json``       a ``json``-encoded string **
============== ============================

`\*You can return a normal tuple (see Structs section below)`

`\**Allows you to specify services that either take or receive Json-encoded strings as parameters.`


Structs
"""""""

Given the following example definitions of types in the nstack IDL::

  type URL = Text;
  type Event = { referrer: URL, target: URL };

When you receive this data into your service method from nstack it will appear as a ``namedtuple`` from the ``collections`` module in the standard-library. eg:

.. code:: python

  nstack.Event = collections.namedtuple("Event", ["referrer", "target"])

This means you can treat the data as both a normal tuple (each field appears in the order it was defined) but also access each field as a property of the value::

  >> input = nstack.Event(("http://www.nstack.com/", "http://demo.nstack.com/")) 
  >> input.referrer
  "http://www.nstack.com/"
  >> input.target
  "http://demo.nstack.com/" 


To construct a struct to return from a Python method we have several options.

For unnamed structs we return a normal tuple, making sure that ordering of the tuple fields are the same as the struct as defined in NStack, e.g.

.. code::

  fun foo : Text -> { referrer: URL, target: URL }

.. code:: python

  return ("http://www.nstack.com/", "http://demo.nstack.com/")

For named structs, we can still return a normal tuple, 
or construct the return object directly 
by using an appropriately named function on the ``nstack`` object
and giving it either a tuple or a dict, e.g.

.. code::

  fun foo : Text -> Event

.. code:: python

  return nstack.Event(dict(referrer="http://www.nstack.com/", target="http://demo.nstack.com/"))

.. code:: python

  return nstack.Event({ "referrer"="http://www.nstack.com/", "target"="http://demo.nstack.com/"})


.. code:: python

  return nstack.Event(("http://www.nstack.com/", "http://demo.nstack.com/"))

.. note:: If using a plain tuple, you must still ensure the fields are in the order declared in the ``.nml``

.. note:: It's not currently possible to return a ``namedtuple`` or ``dict`` directly from Python for use as an NStack struct.

R
-

Coming soon

Java
---- 

Coming soon
