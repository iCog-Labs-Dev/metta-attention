# ECAN Agents Framework in Metta

A poc for agent-based system implemented in MeTTa.

## Overview

This is a simple way of implementing a cognitive controller for the ECAN Agents. The state is preserved until the system got stopped.

## Core Components

### Base Architecture

- `AgentObject`: The foundational class that enables both MeTTa scripts and Python classes to function as agents
- `BaseListeningAgent`: An extension that adds message processing and event handling capabilities
- `ParallelScheduler`: Manages the concurrent execution of multiple agents

### Agents that are going to be implemented


1. **Importance Diffusion Agents**
   - `AFImportanceDiffusionAgent`: Implements attentional-focus importance diffusion
   - `WAImportanceDiffusionAgent`: Handles Whole Atomspace importance diffusion

2. **Rent Collection Agents**
   - `AFRentCollectionAgent`: Manages attentional-focus Rent collection.
   - `WARentCollectionAgent`: Manges Whole-atomspace Rent collection

3. **Learning and Memory Agents**
   - `HebbianCreationAgent`: Manages Hebbian Link creation between atoms.
   - `HebbianUpdatingAgent`: Manages updates to Hebbian link weights
   - `ForgettingAgent`: Handles memory decay and cleanup operations

## Key Features

- **Parallel Execution**: Agents can run concurrently using the ParallelScheduler
- **Retaining State**: State gets preserved through out the execution of the agents until it get stoped.
- **Flexible Integration**: Supports both MeTTa and Python-based agent implementations

## Usage

### Creating an Agent

Agents can be created either through MeTTa scripts or Python classes:

```metta
!(import! &self agents)
!((create-agent ./agents/tests/agent.metta) (g 3))
```

### Registering with Scheduler

```python
scheduler = ParallelScheduler()
scheduler.register_agent("agent_id", agent_creator)
```

### Running Agents

```python

# Run all agents in parallel
python3 main.py
```

### What you can enter in the command

```
stimulate or stop
```

## Architecture Details

### Agent Lifecycle

1. **Initialization**
2. **Registration**
3. **Execution**
4. **Termination**

### Message Processing (This is from the agent_base which is directly imported from the hyperon experimental repostory)


Agents use a queue-based system for message processing:
- Messages are added to the queue using the `input` method
- The `message_processor` handles incoming messages
- The `messages_processor` runs continuously while the agent is active
