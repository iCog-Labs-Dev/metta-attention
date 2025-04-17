import concurrent.futures
import time
import sys
import os
import logging
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from agents.agent_base import AgentObject
from hyperon import E, SymbolAtom

class ParallelScheduler:
    def __init__(self, metta, log_file="af_agent.log"):
        self.agent_creators = {}  # Stores agent creator functions
        self.agent_instances = {}  # Stores actual agent instances
        self.metta = metta
        self.af_agent_id = "AFImportanceDiffusionAgent"  # Define the agent ID here

        # Configure logging
        self.log_file = log_file
        logging.basicConfig(filename=self.log_file, level=logging.INFO,
                            format='%(asctime)s - %(levelname)s - %(message)s')
        logging.info("Starting ParallelScheduler")

    def register_agent(self, agent_id, agent_creator):
        """ Register an agent factory function (not instance) """
        self.agent_creators[agent_id] = agent_creator
        logging.info(f"Registered agent: {agent_id}")
        print(f"Registered agent: {agent_id}")

    def get_or_create_agent(self, agent_id: str) -> AgentObject:
        """ Get existing agent or create a new one if not exists """
        if agent_id not in self.agent_instances:
            if agent_id in self.agent_creators:
                self.agent_instances[agent_id] = self.agent_creators[agent_id]()
                logging.info(f"Created new agent: {agent_id}")
                print(f"Created new agent: {agent_id}")
            else:
                logging.warning(f"Agent {agent_id} not found.")
                print(f"Agent {agent_id} not found.")
                return None
        
        return self.agent_instances[agent_id]

    def log_af_state(self, agent: AgentObject, agent_id: str):
        """Logs the attentionalFocus state of the AFImportanceDiffusionAgent."""
#        try:
#            # Execute MeTTa command to get attentionalFocus state
#            af_state = results[0] if results else "No attentionalFocus found"
#            logging.info(f"AFImportanceDiffusionAgent attentionalFocus: {af_state}")
#            # print(f"AFImportanceDiffusionAgent attentionalFocus: {af_state}")

        commands = {
                        "HebbianCreationAgent": "!(hello)",
                        "AFImportanceDiffusionAgent": "!(hello)",
                        "WAImportanceDiffusionAgent": "!(hello)",
                        "AFRentCollectionAgent": "!(hello)",
                        "WARentCollectionAgent": "!(hello)",
                        "HebbianUpdatingAgent": "!(hello)",
                    }
        try:
            agent.run()
            results = agent._metta.run(commands[agent_id])
            af_state = results[0] if results else "No result"
            logging.info(f"{agent_id} state {af_state}")
        except Exception as e:
            logging.error(f"Error logging attentionalFocus: {e}")
            print(f"Error logging attentionalFocus: {e}")
        
        

    def run_continuously(self):
        """ Run all agents continuously in parallel without stopping """
        if not self.agent_creators:
            logging.warning("No agents registered!")
            print("No agents registered!")
            return

        logging.info("Starting continuous agent execution...")
        print("\nStarting continuous agent execution... (Press Ctrl+C to stop)")

        try:
            with concurrent.futures.ThreadPoolExecutor() as executor:
                while True:  # Infinite loop
                    futures = []
                    for agent_id in self.agent_creators:
                        agent = self.get_or_create_agent(agent_id)  # Use persistent agent
                        if agent:
                            futures.append(executor.submit(self.log_af_state(agent, agent_id)))

                    # Wait for all agents to complete before starting the next iteration
                    concurrent.futures.wait(futures)

                    # Log attentionalFocus state for the AF agent
                    # af_agent = self.get_or_create_agent(self.af_agent_id) #get agent AF
                    # if af_agent:
                    #     self.log_af_state(af_agent)
                    # print(f"83 agent_creators {self.agent_creators}")
                    # print(f"84 agent_instances {self.agent_instances}")


        except KeyboardInterrupt:
           logging.info("Received interrupt signal. Stopping agents...")
           print("\nReceived interrupt signal. Stopping agents...")
        except Exception as e:
            logging.error(f"Exception in run_continuously: {e}")
            print(f"Exception in run_continuously: {e}")
    
