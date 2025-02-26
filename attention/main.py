import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from agents.scheduler import ParallelScheduler
from agents.agent_base import AgentObject

def main():
    # Create scheduler
    scheduler = ParallelScheduler()

    # Register agents
    print("\nRegistering agents...")
    scheduler.register_agent("AFImportanceDiffusionAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/AFImportanceDiffusionAgent.metta"))
    scheduler.register_agent("WAImportanceDiffusionAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/WAImportanceDiffusionAgent.metta"))
    scheduler.register_agent("AFRentCollectionAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/AFRentCollectionAgent.metta"))
    scheduler.register_agent("WARentCollectionAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/WARentCollectionAgent.metta"))
    scheduler.register_agent("ForgettingAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/ForgettingAgent.metta"))
    scheduler.register_agent("HebbianCreationAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/HebbianCreationAgent.metta"))
    scheduler.register_agent("HebbianUpdatingAgent", 
        lambda: AgentObject(path="./agents/mettaAgents/HebbianUpdatingAgent.metta"))

    print("\nAgent System Ready!")

    while True:
        try:
            print("\nRunning agents in continuous mode. Press Ctrl+C to stop.")
            scheduler.run_continuously()

        except KeyboardInterrupt:
            print("\nReceived interrupt signal. Stopping system...")
            break
        except Exception as e:
            print(f"\nError: {e}")
            break

    print("System stopped. Goodbye!")

if __name__ == "__main__":
    main()
