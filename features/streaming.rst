.. _features_streaming:

Streaming multiple values
-------------------------

Sometimes it's desirable to return more than one value from a function.
For example, we might want to asynchronously query an HTTP endpoint and process each response independently.
If we don't care about any connection between the different results,
we can return each result independently.

Let's look at a toy example:
a function that takes in a list of numbers and returns them as strings.
In this case, each transformation takes a reasonable amount of time to compute.

.. code:: python

  #!/usr/bin/env python3
  # -*- coding: utf-8 -*-
  """
  NumString:0.0.1-SNAPSHOT Service
  """
  import nstack

  class Service(nstack.BaseService):
      def stringToNum (self, xs):
          return [self.transform(x) for x in xs]
      
      def transform(self, x):
          time.sleep(5) # TODO: Work out how to make this more efficient
          return str(x)

If we don't need the entire list at once, we can change this to a Python generator.
Rather than working on a list, our next function will have to work on an individual string.
That is, **when we return a generator, each output is passed individually to the next function**.


.. code:: python

  #!/usr/bin/env python3
  # -*- coding: utf-8 -*-
  """
  NumString:0.0.1-SNAPSHOT Service
  """
  import nstack

  class Service(nstack.BaseService):
      def stringToNum (self, xs):
          return (self.transform(x) for x in xs)
      
      def transform(self, x):
          time.sleep(5) # TODO: Work out how to make this more efficient
          return str(x)

