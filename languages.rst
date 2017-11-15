.. _languages:


Supported Languages
===================

NStack is language-agnostic and allows you to write modules in multiple languages and connect them together -- currently we support Python, with R and Java coming soon. More languages will be added over time -- if there's something you really need, please let us know!

Python
------


Basic Structure
^^^^^^^^^^^^^^^

NStack services in Python inherit from a base class, called ``Module`` within the ``nstack`` module::

  import nstack

  class Module(nstack.Module):
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

  class Module(nstack.Module):
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
Struct         ``dict``
Array          ``list``                  
``[Byte]``     ``bytes``                  
``x optional`` ``None`` or ``x``              
``Json``       a ``json``-encoded string *
============== ============================

`\*Allows you to specify services that either take or receive Json-encoded strings as parameters.`

R
-

Coming soon

Java
---- 

Coming soon
