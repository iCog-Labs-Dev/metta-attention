import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from hyperon import MeTTa
from agents.scheduler import ParallelScheduler
from agents.agent_base import AgentObject

def main():
    metta = MeTTa()

    scheduler = ParallelScheduler(metta)
    base_path = os.path.dirname(os.path.abspath(__file__))
    # Register agents
    print("\nRegistering agents...")

    
    scheduler.register_agent("AFImportanceDiffusionAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent-runner.metta")))
    scheduler.register_agent("WAImportanceDiffusionAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent-runner.metta")))
    scheduler.register_agent("AFRentCollectionAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent-runner.metta")))
    scheduler.register_agent("WARentCollectionAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent-runner.metta")))
    scheduler.register_agent("HebbianUpdatingAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/HebbianUpdatingAgent/HebbianUpdatingAgent-runner.metta")))
    scheduler.register_agent("HebbianCreationAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/HebbianCreationAgent/HebbianCreationAgent-runner.metta")))
    scheduler.register_agent("ForgettingAgent", 
        lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ForgettingAgent/ForgettingAgent-runner.metta")))
    

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
