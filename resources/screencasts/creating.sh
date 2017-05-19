# NStack allows you to create, deploy, and compose streaming microservices
# this screencast show creating and running a demo service on NStack

# first, let's make sure we have the NStack CLI installed
# (NOTE - on Windows use 'nstack.exe')
nstack --version

# great! next we'll register our username with a remote NStack Server 
# by default this uses our demo server at demo.nstack.com
nstack register nstack nstack@nstack.com

# your credentials will arrive via email to paste as follows
nstack set-server demo.nstack.com 443 123456 abcdef

# let's create a Python module
mkdir Demo.NumChars
cd Demo.NumChars
nstack init python

# the project is set up, with a Git repo too - aren't we nice...
ls

# 'nstack.yaml' is a config file containing our stack, dependencies, and
# most importantly, the typed API for our module
cat ./nstack.yaml

# we're exposing a single function, 'numChars', that takes Text and
# returns an Integer, presumably the number of characters in the input

# let's look at our service code, this lives in 'service.py' for Python
cat service.py

# the service is a Python class with a method for each entrypoint
# 'numChars' has already been implemented, let's build it
nstack build

# it's now available as a versioned, streaming function on the NStack server
nstack list functions

# let's compose our function with a source and sink to form a Workflow
cd ..
mkdir Demo.Workflow
cd Demo.Workflow
nstack init workflow

# our workflow project is now set up
ls

# 'workflow.nml' is a module using the NStack Workflow Language to compose
# and define higher-level workflows
# think of it like Bash-piping for typed, containerised, microservices
cat ./workflow.nml

# again we can build this module and view it on the remote NStack Server
nstack build
nstack list workflows

# let's start our complete workflow, with NStack handling the runtime
nstack start nstack/Demo.Workflow:0.0.1-SNAPSHOT w

# we can send events into our workflow from the CLI for testing
# let's try it...
nstack send "/demo" '"HelloWorld"'

# the workflow was configured to send output to the logs
nstack log 338

# great, that works as expected. Now, we can stop the service
nstack stop 338

# we've successfully created a module, composed it into a higher-level
# workflow, and executed it
# further examples are at https://www.github.com/nstack/nstack-examples
# along with docs at https://docs.nstack.com
# thanks for your time - do let us know how you get on at hi@nstack.com :)

