Mapping NStack types to Python types
====================================

The table below show you what python types to expect and to return when dealing with types defined in the NStack IDL:

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
Sum            see section below         
``[Byte]``     ``bytes``                  
``x optional`` ``None`` or x              
============== ============================

`\*you can return a normal tuple (see Structs section below)`

Sum Types
---------

Python doesn't have support for Sum types (aka tagged/disjoint unions) but we still support them via inheritance.

Here's some example definitions of types in the nstack IDL::

  type URL = Text;
  type Referrer = URL;
  type Target = URL;
  type Event = PageImpression URL | Click (Referrer, Target);

You can imagine that we create classes for Event and its constructors something like the following::

  class Event(object):
    ...
    class PageImpression(Event):
      ...
    class Click(Event):
      ...

As the sum is defined as a type alias (this is the only way to define sums in the IDL) then the types will be available as members of the ``nstack`` package module, and we can construct new values (to return them from an nstack service method) like this:

.. code:: python

  import nstack
  ex_impression = nstack.Event.PageImpression("http://www.nstack.com/")
  ex_click = nstack.Event.Click(("http://www.nstack.com/", "http://demo.nstack.com/"))

And we can see the class inheritance by asking python about the instances' types::

  >> isinstance(ex_impression, nstack.Event)
  True
  >> isinstance(ex_impression, nstack.Event.PageImpression)
  True
  >> isinstance(ex_impression, nstack.Event.Click)
  False

You will usually need to handle each branch of the sum type differently. Case analysis can be achieved using python's `isinstance` function as above...

.. code:: python

  if isinstance(v, nstack.Event.PageImpression):
    ... # do something with a page impression
  elif isinstance(v, nstack.Event.Click):
    ... # do something with a click
    
The classes have some other useful properties/methods as shown below::

  >> ex_impression.value
  "http://www.nstack.com/"
  >> ex_click.value
  ("http://www.nstack.com/", "http://demo.nstack.com/")
  >> ex_impression.getPageImpression()
  "http://www.nstack.com/"
  >> ex_impression.getClick()
  Traceback (most recent call last):
    File "<stdin>", line 1, in <module>
  TypeError: Not a Click
  >> ex_impression.match(lambda i: "got a page impression",
                         lambda i: "got a click")
  "got a page impression"
    
Structs
-------

We an modify the `Click` branch from the sample above to be a struct/record instead::

  type URL = Text;
  type Event = PageImpression URL | Click { referrer: URL, target: URL };
  
When you receive this data into your service method from nstack it will appear as a ``namedtuple`` from the ``collections`` module in the standard-library. eg:

.. code:: python

  ClickData = collections.namedtuple("ClickData", ["referrer", "target"])

This means you can treat the data as both a normal tuple (each field appears in the order it was defined) but also access each field as a property of the value::

  >> input = nstack.Event.Click(("http://www.nstack.com/", "http://demo.nstack.com/")) 
  >> input.getClick().referrer
  "http://www.nstack.com/"
  >> input.getClick().target
  "http://demo.nstack.com/" 

In the example IDL we didn't give the struct a name, it was defined in-line inside the `Click` branch of the `Event` type, this means we can't construct it directly if we need to return it from our method. That's ok, ``namedtuple``\s are just ``tuple``\s so we can just return a normal tuple and ``nstack`` ensure it is correct. We can see this at work in the code example above where the `Click` constructor is called with a standard python ``tuple`` but when we inspect the value we get a ``namedtuple`` with the ``referrer`` and ``target`` properties.
