import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from hyperon import MeTTa
from agents.scheduler import ParallelScheduler
from agents.agent_base import AgentObject

def main():
    metta = MeTTa()

    scheduler = ParallelScheduler(metta)

    # Register agents
    print("\nRegistering agents...")

    # scheduler.register_agent("AFImportanceDiffusionAgent", 
    #     lambda: AgentObject(metta=metta, path="./attention/agents/mettaAgents/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent.metta"))
    

    scheduler.register_agent("AFRentCollectionAgent", 
        lambda: AgentObject(metta=metta, path="./metta-attention/attention/agents/mettaAgents/AFRentCollectionAgent/AFRentCollectionAgentRunner.metta"))
    scheduler.register_agent("WARentCollectionAgent", 
        lambda: AgentObject(metta=metta, path="./metta-attention/attention/agents/mettaAgents/WARentCollectionAgent/WARentCollectionAgentRunner.metta"))
    scheduler.register_agent("ForgettingAgent", 
        lambda: AgentObject(metta=metta, path="./metta-attention/attention/agents/mettaAgents/ForgettingAgent/ForgettingAgenst-runner.metta"))
   


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