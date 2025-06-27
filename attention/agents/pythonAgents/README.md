# Python Scheduler and Agent base

## Overview

This directory holds 2 python scripts agent_base.py and scheduler.py used for 
calling all agent instances in the same metta instance in individual threads 
and calling them in a loop unitl patterns that are stimulated are finished.

## Agent Run

This class inherits from the builtin AgentObject so it can add 2 functionaliy
allowing agents to accpet a precreated metta instance and createing a run
function to run them.

### __init__
On init the class takes as argument a metta instance and path to a code that 
will be run by the Scheduler.

### run

The run function takes the code found at the path specified and runs all code
inside by simple calling it as `agent.run()`

## Scheduler

The scheduler class is used to interact with metta instance by importing scripts
into the instance running agents in the instance and exposing functions to 
update hyper parameters.

### __init__

To initialize an instance of `ParallelScheduler` it requires an instance of
`MeTTa` class which will be the space all agents will run on and a path to a file
that has all imports to the so that the `MeTTa` instance can be populated with the
required functions. The path should be defined relative to the root of the project.

Additionally you can define a path to a .log file relative to the project root
if not it defaults to *af_agent.log*.

```py
# create a metta instance
metta = MeTTa()

# create parallerscheduler instance with metta instance for all agents and a file with all relvent imports
scheduler = ParallelScheduler(metta, "attention/agents/mettaAgents/paths.metta")
```

### Importing to metta instance

Once initialized by providing a metta instance and all necessary imports that 
refence files it you can insert any number of files defining knowledge base via
`load_imports` function which takes in a path to a metta filein string form 
definded relative to project root.

To import files that hold sentences for the system to stimulate use 
`load_sent_files` which is a function that takes an list of files holding
sentences that the system will take one word at a time which will be stimulated
after which all agents will run before stimulating another word.

```py
# load any file that is to be used as knowledge base
scheduler.load_imports("attention/data/adagram_sm_links.metta")

# load list of files to for ECAN to read through
scheduler.load_sent_files(["experiments/experiment2/data/insect-sent.metta", "experiments/experiment2/data/poison-sent.metta"])
```

### Update ECAN hyperparameters

The `update_attention_param` function takes a string and a value argument
which will set parameters the will modify ecans behaviour.

```py
# Optional: adjust parameters
scheduler.update_attention_param("MAX_AF_SIZE", 7)
```

### Stimulating Value

The default inplementation stimulates all words by a value of 200 users can change
get or change this value as follows.

```py
# Get stimulate value
scheduler.get_stimulate_value() # 200 default Value

# Set stimlate Value to desired preference
scheduler.set_stimulate_value(100)
```
### Registering Agents

Agents are registed using the `register_agent` which will take a name for the
agent and a function to create an Agentrun instance with a path directing it
to a metta file that calls the function for starting the agent.

```py
scheduler.register_agent("AFImportanceDiffusionAgent",
    lambda: Agentrun(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent-runner.metta")))
```

### Continous Running

After all necessary imports and agent registration the `run_continuously` function
is called. 

The function intializes by writing the current hyperparameters to a json file
then creates a generator function for the text that will be read.

While the generator function still has value it takes one word at a time stimulates
it and calls all registered agents. Until thier are no files to be read.

On each call to an agent it logs the agents start and finish time to the log file
discssed above.

Upon completion it logs to the file the AV value of all atoms in the AttentionalFocus

### Iterative Running

Similar to `run_continuously` the `run_iterativly` function but operates by pciking random word for 
and stimulating it for a specific number of iteration.

The function is takes an int input to specifiy how many iterations to call the agents
```py
scheduler.run_iterativly(3)
```

The function puts all words from files in the self.sent_paths it is made with the
assumption that only 2 contexts will be given. it takes those files and puts
all words for a file in a list.

Based on the count of the current iteration it will switch the context from 
the file in index 0 to the file in index 1.

It has similar logging behaviour as `run_continuously`.
