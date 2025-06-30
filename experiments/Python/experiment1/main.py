import sys
import os
from hyperon import MeTTa

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# change dir so metta working directory remain constant regardless of where it is called
os.chdir(BASE_DIR)

# add PythonController to the path
sys.path.insert(0, BASE_DIR)

from pythonController import ParallelScheduler, Agentrun

def main():

    # create Base dir to allow robust agent path defination
    base_path = os.path.join(BASE_DIR, "attention/")

    # create a metta instance
    metta = MeTTa()

    # create parallerscheduler instance with metta instance for all agents and a file with all relvent imports
    scheduler = ParallelScheduler(metta, "attention/paths.metta")

    # load any file that is to be used as knowledge base
    scheduler.load_imports("experiments/Python/experiment1/data/adagram_sm_links.metta")

    # load list of files to for ECAN to read through
    scheduler.load_sent_files(["experiments/Python/experiment1/data/insect-sent.txt", "experiments/Python/experiment1/data/poison-sent.txt"])

    # Optional: adjust parameters
    scheduler.update_attention_param("MAX_AF_SIZE", 3)


    # Register agents
    print("\nRegistering agents...")

    scheduler.register_agent("AFImportanceDiffusionAgent",
        lambda: Agentrun(metta=metta, path=os.path.join(base_path, "ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent-runner.metta")))
    scheduler.register_agent("AFRentCollectionAgent",
        lambda: Agentrun(metta=metta, path=os.path.join(base_path, "RentCollectionAgent/AFRentCollectionAgent/AFRentCollectionAgent-runner.metta")))
    scheduler.register_agent("HebbianUpdatingAgent",
        lambda: Agentrun(metta=metta, path=os.path.join(base_path, "HebbianUpdatingAgent/HebbianUpdatingAgent-runner.metta")))
    scheduler.register_agent("HebbianCreationAgent",
        lambda: Agentrun(metta=metta, path=os.path.join(base_path, "HebbianCreationAgent/HebbianCreationAgent-runner.metta")))
    # scheduler.register_agent("WAImportanceDiffusionAgent",
    #     lambda: Agentrun(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent-runner.metta")))
    # scheduler.register_agent("WARentCollectionAgent",
    #     lambda: Agentrun(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent-runner.metta")))
    # scheduler.register_agent("ForgettingAgent",
    #     lambda: Agentrun(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ForgettingAgent/ForgettingAgent-runner.metta")))


    print("\nAgent System Ready!")

    try:
        print("\nRunning agents in continuous mode. Press Ctrl+C to stop.")
        scheduler.run_continuously()
    except KeyboardInterrupt:
        print("\nReceived interrupt signal. Stopping system...")
    except Exception as e:
        print(f"\nError: {e}")

    print("System stopped. Goodbye!")

if __name__ == "__main__":
    main()
