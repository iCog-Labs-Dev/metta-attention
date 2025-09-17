import concurrent.futures
import logging
import random
from pathlib import Path
from typing import Any, Iterator
from .agent_base import Agentrun

class ParallelScheduler:
    def __init__(self, metta: Any, paths: str, log_file:str = "af_agent.log"):
        self.agent_creators = {}  # Stores agent creator functions
        self.agent_instances = {}  # Stores actual agent instances
        self.metta = metta

        # default stimulate value
        self.stimulate_value = 200

        # Configure logging
        self.log_file = log_file

        # files to read from
        self.sent_paths = []

        # words to read from in random word experiment setup
        self.word_list = []

        self.load_imports(paths)
        logging.basicConfig(filename=self.log_file, level=logging.INFO,
                            format='%(asctime)s - %(levelname)s - %(message)s')
        logging.info("Starting ParallelScheduler")

    def run_metta_file(self, path: Path) -> None:
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

    def get_absolute_path(self, relative_path: str) -> Path:
        """ takes a string of file path and resolves it relaitve metta-atention"""

        if isinstance(relative_path, str):
            script_dir = Path(__file__).parent.parent.resolve()
            return (script_dir / relative_path).resolve()
        else:
            raise TypeError("file path must be instance of str")

    def load_imports(self, import_path: str) -> None:
        """ imports any file into the metta space """ 
        if ".metta" in import_path.split("/")[-1]:
            resolved_path = self.get_absolute_path(import_path)
            self.run_metta_file(resolved_path)
        else:
            raise ValueError(f"load_imports only accepts .metta file {import_path}")

    def load_sent_files(self, file_paths: list[str]) -> None:
        """ takes a list of files to read for ECAN stimulation """

        if isinstance(file_paths, list):
            for path in file_paths:
                if isinstance(path, str):
                    self.sent_paths.append(path)
                else:
                    raise TypeError("path to file must be str instance")
        else:
            raise TypeError("load_sent_files sentence argument must be list instance")

    def create_word_list(self) -> None:
        """ populates self.word_list by list of words to be chosen randomly """
        for file in self.sent_paths:
            with open(file, 'r') as f:
                lines = f.read()
                self.word_list.append(lines.split())

    def random_word(self, index: int) -> str:
        """ picks a random word from self.word_list instance variable """

        if isinstance(index, int):
            return random.choice(self.word_list[index])
        else:
            raise TypeError("argument to random_word must be int instance")

    def update_attention_param(self, param: str, new_value: Any) -> None:
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
                "SPREADING_FILTER",
                "STARTING_FUNDS_STI", 
                "FUNDS_STI",
                "STARTING_FUNDS_LTI",
                "FUNDS_LTI",
                "STI_FUNDS_BUFFER",
                "LTI_FUNDS_BUFFER",
                "TARGET_STI", 
                "TARGET_LTI",
                "STI_ATOM_WAGE",
                "LTI_ATOM_WAGE"
            ]

        if isinstance(param, str):
            if param in params:
                self.metta.run(f"!(updateAttentionParam {param} {new_value})")
            else:
                raise ValueError("param value not known")
        else:
            raise TypeError("function takes str as first argument")

    def start_logger(self, directory: str) -> None:
        """ makes a call to the save_param function in utilities """

        if not isinstance(directory, str):
            raise TypeError("save_params directroy path must be str instance")

        self.metta.run(f"!(start_log (attentionParam) {directory})")

    def register_agent(self, agent_id: str, agent_creator) -> None:
        """ Register an agent factory function (not instance) """
        self.agent_creators[agent_id] = agent_creator
        self.agent_instances[agent_id] =  agent_creator()
        logging.info(f"Registered agent: {agent_id}")
        print(f"Registered agent: {agent_id}")

    def get_or_create_agent(self, agent_id: str) -> Any:
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

    def log_af_state(self, agent: Agentrun, agent_id: str) -> None:
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
        
        
    def word_reader(self) -> Iterator[str]:
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

    def stimulate_data(self, word: str, value: int) -> Any:
        """ recives a word and a value and stimulates that value """

        if isinstance(word, str) and isinstance(value, int):
            result = self.metta.run(f"!(stimulate {word} {value})")
            return result

        raise TypeError("accepts str and int respectivly")

    def run_continuously(self) -> None:
        """ Run all agents continuously in parallel without stopping """
        if not self.agent_creators:
            logging.warning("No agents registered!")
            print("No agents registered!")
            return

        logging.info("Starting continuous agent execution...")
        data = self.word_reader()

        try:
            while True :  # Infinite loop
                with concurrent.futures.ThreadPoolExecutor() as executor:
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

    def run_iterativly(self, iteration:int, switch:int) -> None:

        if not isinstance(iteration, int):
            raise TypeError(f"run_iterativly expects int argument but {type(iteration)} was given")

        if not self.agent_creators:
            logging.warning("No agents registered!")
            print("No agents registered!")

        logging.info("Starting continuous agent execution...")
        
        self.create_word_list()

        try:
            for count in range(iteration, 0, -1):
                if count > switch:
                    value = self.random_word(0)
                else:
                    value = self.random_word(1)

                with concurrent.futures.ThreadPoolExecutor() as executor:
                    print(f"--- stimulateing {value} with {self.stimulate_value} ---")
                    self.stimulate_data(value, self.stimulate_value)
                    futures = []
                    for agent_id in self.agent_creators:
                        agent = self.get_or_create_agent(agent_id)  # Use persistent agent
                        if agent:
                            futures.append(executor.submit(self.log_af_state, agent, agent_id))

                    # Wait for all agents to complete before starting the next iteration
                    concurrent.futures.wait(futures)
            else:
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
