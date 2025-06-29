# ECAN Agents Framework in MeTTa

A proof-of-concept (POC) for an agent-based system implemented in MeTTa, leveraging a shared MeTTa atomspace for inter-agent communication and knowledge sharing.

## Overview

This framework provides a way to implement a cognitive controller for ECAN Agents using MeTTa.  Crucially, all agents operate within the **same, shared MeTTa environment (atomspace)**.  This allows agents to directly observe and interact with each other's knowledge and actions. The state within the shared atomspace is preserved until the system is stopped.

## Core Components

### Base Architecture

- `AgentObject`: The foundational class that enables both MeTTa scripts and Python classes to function as agents.  It now takes a shared `MeTTa` instance as an argument.
- `ParallelScheduler`: Manages the concurrent execution of multiple agents within the shared `MeTTa` environment.

### Agents to be Implemented

1.  **Importance Diffusion Agents**
    *   `AFImportanceDiffusionAgent`: Implements attentional-focus importance diffusion.
    *   `WAImportanceDiffusionAgent`: Handles Whole Atomspace importance diffusion.

2.  **Rent Collection Agents**
    *   `AFRentCollectionAgent`: Manages attentional-focus Rent collection.
    *   `WARentCollectionAgent`: Manages Whole-atomspace Rent collection.

3.  **Learning and Memory Agents**
    *   `HebbianCreationAgent`: Manages Hebbian Link creation between atoms.
    *   `HebbianUpdatingAgent`: Manages updates to Hebbian link weights.
    *   `ForgettingAgent`: Handles memory decay and cleanup operations.

## Key Features

-   **Parallel Execution**: Agents can run concurrently using the `ParallelScheduler`.
-   **Shared Atomspace**: All agents operate within a single, shared `MeTTa` atomspace, enabling direct communication and knowledge sharing.
-   **Stateful**: State is persisted in the shared atomspace throughout the execution of the agents.
-   **Flexible Integration**: Supports both MeTTa and Python-based agent implementations.

## Usage

### Prerequisites

*   Make sure you have hyperon installed
*   Make sure all the dependency installed

### Registering with Scheduler

```python
metta = MeTTa() #create metta instance
scheduler = ParallelScheduler(metta) # Initialize the scheduler with the metta instance
scheduler.register_agent("agent_id", lambda: AgentObject(metta=metta, ...)) #register the agent using lambda
metta: a metta instance that created for sharing space
AgentObject: takes metta instance and can work on the shared space
lambda: create an anonymous funciton that returns an instance of AgentObject, making sure that all agents are initialized in the same space
...: all the extra paramaters that required to initialize the agent
```

### Running Agents
# Run all agents in parallel

```
python3 main.py
```

# Expected output

```
   Registering agents...
   Registered agent: AFImportanceDiffusionAgent
   Registered agent: AFRentCollectionAgent
   
   Agent System Ready!
   
   Running agents in continuous mode. Press Ctrl+C to stop.
   
   Starting continuous agent execution... (Press Ctrl+C to stop)
   Created new agent: AFImportanceDiffusionAgent
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Created new agent: AFRentCollectionAgent
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFRentCollectionAgent.metta")], [2]]
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFImportanceDiffusionAgent.metta")], [()], [("AFImportanceDiffusionAgent.metta")], [()], [2, 2]]
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFRentCollectionAgent.metta")], [2, 2]]
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFImportanceDiffusionAgent.metta")], [()], [("AFImportanceDiffusionAgent.metta")], [()], [2, 2, 2]]
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFRentCollectionAgent.metta")], [2, 2, 2]]
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFImportanceDiffusionAgent.metta")], [()], [("AFImportanceDiffusionAgent.metta")], [()], [2, 2, 2, 2]]
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Running agent: <class 'agents.agent_base.AgentObject'> from !(import! &self attention:agents:mettaAgents:adder...
   Execution result for <class 'agents.agent_base.AgentObject'>: [[()], [("AFRentCollectionAgent.metta")], [2, 2, 2, 2]]
```

### Architecture Details
# Agent Lifecycle
 * Initialization: A single MeTTa instance is created.

 * Registration: Agents are registered with the ParallelScheduler, receiving a reference to the shared MeTTa instance.

 * Execution: Agents run concurrently, interacting with the shared MeTTa atomspace.

 * Termination: Agents stop gracefully when the system is interrupted, leaving the state in the shared atomspace intact.

 ### Important!!!!
 ### You should structure your Agents in this way
 ### AgentScript.metta
 ### AgentScriptRunner.metta 

 - AgentScriptRunner. metta should Import the AgentScript.metta file and run the main function for example (AFImportanceDiffusionAgenT-RUN)
 - And only the AgentScriptRunner.metta should be registered int eh main.py

## Agent Structure (IMPORTANT)

To maintain code organization and reusability, agents should be structured in the following way:

*   `AgentScript.metta`: Contains the core logic and definitions for the agent's functionality.  This file defines the core rules and functions.
*   `AgentScriptRunner.metta`: Imports `AgentScript.metta` and executes the main function (e.g., `<AgentName>-RUN`). This acts as the entry point for the agent.

**Example:**

Let's say you have an agent named `MyAwesomeAgent`.

1.  `MyAwesomeAgentScript.metta`:

    ```metta
    ; Define the core logic of MyAwesomeAgent here
    (= (my-awesome-function)
      ; ...do something with $x...
    )
    ```

2.  `MyAwesomeAgentRunner.metta`:

    ```metta
    ; Import the agent's core script
    !(import! &self MyAwesomeAgentScript.metta)

    !(my-awesome-function) ; Run it!
    ``
- And do 
   ```python
    scheduler.register_agent("MyAwesomeAgentRunner", lambda: AgentObject(metta=metta, pathto MyAwesomeAgentRunner.metta"))
   ```
