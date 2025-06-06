# Agents

This readme outlines the the structure of the agents file found in the mettaAgents
direcorty.

The purpose of the files found in the mettaAgents directory is used to create agents 
describing rules of how ECAN interacts with patterns. 

The AttentionParam file is a repository of constant variables the describe how
the agents behave.

## Agents

As described above the Agents are used to make modification to the atomspace in
accordance to their ruleset which are designed to be unique to each agent and 
collabroative. 

The agents work in the atomspace of on atoms outside of it the 7 agents are as 
follows.

1. [**Hebbian Creation**](HebbianCreationAgent/)
2. **Hebbain Updating**
3. **AF Importance Diffusion**
4. **AF Rent Collection**
5. **WA Importance Diffusion**
6. **WA Rent Collection**
. [**Forgetting**](ForgettingAgent/README.md)

## File Structure

The files are structured in such a way that each agent directory holds a defination
which holds the functions responsible, a test file and a runner.

The runner is the function used when calling agents from a python file.

### Basic File strucutre

mettaAgents
|
|---<Agent>
    |
    |---tests
    |   |---<Agent>-test.metta
    |
    |---<Agent>-runnner.metta
    |
    |---<Agent>.metta

The following agents **Importance Diffusion** and **Rent Collection** are 
used different in thier file structure such that they have a ** <Agent>Base.metta **

For agents involved in Diffusion and Rent collection the file structure is as 
follows

mettaAgents 
|
|---<Agent-Base>
    |
    |---tests
    |   |---<Agent>-test.metta
    |
    |---<Base>
    |   |
    |   |---<Agent>Base.metta
    |
    |---<Agent>
        |
        |---<Agent>-runnner.metta
        |
        |---<Agent>.metta
    

