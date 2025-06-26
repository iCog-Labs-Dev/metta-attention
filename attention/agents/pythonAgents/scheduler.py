import concurrent.futures
import sys
import os
import logging
from pathlib import Path

from agents.pythonAgents.agent_base import Agentrun

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

class ParallelScheduler:
    def __init__(self, metta, paths, log_file="af_agent.log"):
        self.agent_creators = {}  # Stores agent creator functions
        self.agent_instances = {}  # Stores actual agent instances
        self.metta = metta

        # default stimulate value
        self.stimulate_value = 200

        # Configure logging
        self.log_file = log_file

        # files to read from
        self.sent_paths = []

        self.load_imports(paths)
        logging.basicConfig(filename=self.log_file, level=logging.INFO,
                            format='%(asctime)s - %(levelname)s - %(message)s')
        logging.info("Starting ParallelScheduler")

    def run_metta_file(self, path):
        data_file_path = path
        try:
            with open(data_file_path, 'r') as f:
                data = f.read()
                results = self.metta.run(data)
                response = str(results) if results else "No Result"
            print(f"Data loaded successfully into atomspace from {data_file_path}")
        except FileNotFoundError:
            print(f"Error: Data file not found at {data_file_path}")
        except Exception as e:
            print(f"Error loading data from file: {e}")

    def get_absolute_path(self, relative_path):
        """ takes a string of file path and resolves it relaitve metta-atention"""

        if isinstance(relative_path, str):
            script_dir = Path(__file__).parent.parent.parent.parent.resolve()
            return (script_dir / relative_path).resolve()
        else:
            raise TypeError("file path must be instance of str")

    def load_imports(self, import_path):
        """ imports any file into the metta space """ 
        if ".metta" in import_path.split("/")[-1]:
            resolved_path = self.get_absolute_path(import_path)
            self.run_metta_file(resolved_path)
        else:
            raise ValueError(f"load_imports only accepts .metta file {import_path}")

    def load_sent_files(self, file_paths):
        """ takes a list of files to read for ECAN stimulation """

        if isinstance(file_paths, list):
            for path in file_paths:
                if isinstance(path, str):
                    self.sent_paths.append(path)
                else:
                    raise TypeError("path to file must be str instance")
        else:
            raise TypeError("load_sent_files sentence argument must be list instance")

    def update_attention_param(self, param, new_value):
        """ Updates ECAN hyperparameters """

        params = [   
                "AF_SIZE",
                "MIN_AF_SIZE",
                "AFB_DECAY",
                "AFB_BOTTOM",
                "MAX_AF_SIZE",
                "AFRentFrequency",
                "FORGET_THRESHOLD",
                "HEBBIAN_MAX_ALLOCATION_PERCENTAGE",
                "LOCAL_FAR_LINK_RATIO",
                "MAX_SPREAD_PERCENTAGE",
                "DIFFUSION_TOURNAMENT_SIZE",
                "SPREAD_HEBBIAN_ONLY",
                "StartingAtomStiRent",
                "StartingAtomLtiRent",
                "TargetStiFunds",
                "TargetLtiFunds",
                "StiFundsBuffer",
                "LtiFundsBuffer",
                "TARGET_LTI_FUNDS_BUFFER",
                "RENT_TOURNAMENT_SIZE",
                "SPREADING_FILTER"
            ]

        if isinstance(param, str):
            if param in params:
                self.metta.run(f"!(updateAttentionParam {param} {new_value})")
            else:
                raise ValueError("param value not known")
        else:
            raise TypeError("function takes str as first argument")

    def save_params(self):
        """ makes a call to the save_param function in utilities """
        self.metta.run("!(let $vals (collapse (get-atoms &attentionParam)) (save_params $vals))")

    def register_agent(self, agent_id, agent_creator):
        """ Register an agent factory function (not instance) """
        self.agent_creators[agent_id] = agent_creator
        self.agent_instances[agent_id] =  agent_creator()
        logging.info(f"Registered agent: {agent_id}")
        print(f"Registered agent: {agent_id}")

    def get_or_create_agent(self, agent_id: str):
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

    def log_af_state(self, agent: Agentrun, agent_id: str):
        """Logs the attentionalFocus state of the AFImportanceDiffusionAgent."""

        try:
            logging.info(f"{agent_id} Started running")
            print(f"\n{agent_id} Started running")
            value = agent.run()
            print(value)
            logging.info(f"{agent_id} Finished running")
            print(f"{agent_id} Finished running\n")
        except Exception as e:
            logging.error(f"Error logging attentionalFocus: {e}")
            print(f"Error logging attentionalFocus: {e}")
        
        
    def word_reader(self):
        """ Generator function reads all files in the sent_path obj instance
        and yields a word until finished """
        data = self.sent_paths
    
        for concept in data:
            with open(concept, 'r') as file:
                line = file.readline()
                words = line.split()
                for word in words:
                    yield word

    def set_stimulate_value(self, value:int) -> None:
        """ Sets object variable that controls how much stimulus to apply """
        if isinstance(value, int):
            self.stimulate_value = value
        else:
            raise TypeError(f"stimulating value must be int instance")

    def get_stimulate_value(self) -> int:
        """ Retrives obects value used for stimlation """
        return self.stimulate_value

    def stimulate_data(self, word, value):
        """ recives a word and a value and stimulates that value """

        if isinstance(word, str) and isinstance(value, int):
            result = self.metta.run(f"!(stimulate {word} {value})")
            return result

        raise TypeError("accepts str and int respectivly")

    def run_continuously(self):
        """ Run all agents continuously in parallel without stopping """
        if not self.agent_creators:
            logging.warning("No agents registered!")
            print("No agents registered!")
            return

        self.save_params()
        logging.info("Starting continuous agent execution...")
        data = self.word_reader()

        try:
            with concurrent.futures.ThreadPoolExecutor() as executor:
                while True :  # Infinite loop
                    value = next(data)
                    print(f"--- stimulateing {value} with {self.stimulate_value} ---")
                    self.stimulate_data(value, self.stimulate_value)
                    futures = []
                    for agent_id in self.agent_creators:
                        agent = self.get_or_create_agent(agent_id)  # Use persistent agent
                        if agent:
                            futures.append(executor.submit(self.log_af_state, agent, agent_id))

                    # Wait for all agents to complete before starting the next iteration
                    concurrent.futures.wait(futures)
                    
        except StopIteration:
            logging.info("Finished stimulating values")
            print("Finished stimulating values")

            logging.info(f"AF in metta {self.metta.run('!(AFsnapshot (attentionalFocus))')}")
            print("AF in metta", self.metta.run("!(AFsnapshot (attentionalFocus))"))
        except KeyboardInterrupt:
           logging.info("Received interrupt signal. Stopping agents...")
           print("\nReceived interrupt signal. Stopping agents...")
        except Exception as e:
            logging.error(f"Exception in run_continuously: {e}")
            print(f"Exception in run_continuously: {e}")
