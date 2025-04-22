import concurrent.futures
import time
import sys
import os
import logging
import csv
from datetime import datetime
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
        self.csv_file = self.get_csv_file_name()
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

    def get_csv_file_name(self) -> str:
        """ creats a name and file for the current instance of the controller """

        time = datetime.now().strftime("%H:%M:%S-%d-%m-%Y")
        file_name = f"csv/results_{time}.csv"
        return file_name

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
            # results = agent._metta.run(commands[agent_id])
            # af_state = results[0] if results else "No result"
            logging.info(f"{agent_id} running")
            print(f"{agent_id} running")
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
                    
                    timestamp = datetime.now().isoformat()
                    log = []
                    if len(self.agent_creators) > 0:
                        # agent = self.get_or_create_agent("HebbianCreationAgent")
                        result = self.metta.run("!(match (attentionalFocus) $x ($x (getSTI $x)))")
                        if result[0]:
                            for expatom in result[0]:
                                print(f"result {expatom}")
                                log.append(expatom.get_children())
                        
                    data = []
                    if log:
                        for l in log :
                            data.append({"timestamp": timestamp,  "pattern": l[0], "sti": l[1]})
                    # else:
                    #     data = [{"timestamp": timestamp,  "pattern": "-", "sti": "0"}]

                    with open(self.csv_file, 'a', newline='') as f:
                        writer = csv.DictWriter(f, fieldnames=["timestamp", "pattern", "sti"])

                        if f.tell() == 0:
                            writer.writeheader()
                        
                        if len(data) > 1:
                            for d in data:
                                writer.writerow(d)
                        # else:
                        #     writer.writerow(data[0])
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
