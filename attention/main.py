import sys
import os
import socket
import threading
import json
import time
import queue #Import the queue
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from hyperon import MeTTa, E, SymbolAtom, S
from agents.scheduler import ParallelScheduler
from agents.agent_base import AgentObject

class SocketHandler: #No longer a thread
    def __init__(self, client_socket, metta, scheduler): #include the queue
        self.client_socket = client_socket
        self.metta = metta
        self.scheduler = scheduler

    def process_socket(self):
        try:
            print(f"Connected to {self.client_socket.getpeername()}")
            data = self.client_socket.recv(1024).decode()
            print(f"Received data: {data}")

            try:
                request = json.loads(data)
                agent_id = request.get("agent_id")
                pattern = request.get("pattern")  # Expecting an array of atoms
                stimulus = request.get("stimulus")

                if agent_id and isinstance(pattern, list) and stimulus is not None:
                    agent = self.scheduler.get_or_create_agent(agent_id)
                    if agent:
                        # Generate MeTTa command dynamically from the pattern array
                        # pattern_str = " ".join(str(atom) for atom in pattern)  # Convert list to space-separated string
                        # pattern_str = "(" + pattern_str + ")"  # Enclose in parentheses
                        metta_command = f'!(stimulate {S(pattern[0])} {stimulus})'
                        print(f"Executing MeTTa command: {metta_command}")

                        results = agent._metta.run(metta_command)  # Execute MeTTa command
                        response = str(results) if results else "No Result"
                        self.client_socket.sendall(response.encode('utf-8'))
                    else:
                        self.client_socket.sendall(b"Agent not found")
                else:
                    self.client_socket.sendall(b"Invalid request format")
            except json.JSONDecodeError:
                self.client_socket.sendall(b"Invalid JSON format")
            except Exception as e:
                print(f"Error processing request: {e}")
                self.client_socket.sendall(str(e).encode('utf-8'))

        except Exception as e:
            print(f"Error handling client connection: {e}")
        finally:
            try:
                self.client_socket.close()
                print(f"Connection closed")
            except OSError as e:
                print(f"Error closing socket: {e}")

def load_data_into_agent(agent, data_file_path):
    """Loads data from a file into the atomspace of a specific agent."""
    try:
        with open(data_file_path, 'r') as f:
            data = f.read()
            results = agent._metta.run(data)
            response = str(results) if results else "No Result"
            print(response)
        print(f"Data loaded successfully into {agent.name()}'s atomspace from {data_file_path}")
    except FileNotFoundError:
        print(f"Error: Data file not found at {data_file_path}")
    except Exception as e:
        print(f"Error loading data from file: {e}")

def main():
    metta = MeTTa()
    base_path = os.path.dirname(os.path.abspath(__file__))
    # Data file path
    data_file = os.path.join(base_path, "data/adagram_sm_links.metta")

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('localhost', 5000))
    server_socket.listen(5) # Allow 5 pending connections

    scheduler = ParallelScheduler(metta)
    # Register agents
    print("\nRegistering agents...")

    def create_af_agent():
        agent = AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ImportanceDiffusionAgent/AFImportanceDiffusionAgent/AFImportanceDiffusionAgent-runner.metta"))
         # Load initial data into agent's atomspace
        load_data_into_agent(agent, data_file)
        return agent

    scheduler.register_agent("AFImportanceDiffusionAgent",create_af_agent)
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
    # scheduler.register_agent("ForgettingAgent",
    #     lambda: AgentObject(metta=metta, path=os.path.join(base_path, "agents/mettaAgents/ForgettingAgent/ForgettingAgent-runner.metta")))


    print("\nAgent System Ready!")

    try:
        scheduler_thread = threading.Thread(target=scheduler.run_continuously, daemon=True)
        scheduler_thread.start() # Start scheduler in another thread
        print("\nRunning agents in continuous mode. Press Ctrl+C to stop.")

        client_threads = [] #list of all threads

        while True:
            try:
                client_socket, addr = server_socket.accept()  # Accept connections in main thread
                client_handler = SocketHandler(client_socket, metta, scheduler) #Instantiate the socket
                client_threads.append(client_handler)
                thread = threading.Thread(target=client_handler.process_socket)
                thread.start()

            except OSError as e:
                print(f"Socket error: {e}")
                break


    except KeyboardInterrupt:
        print("\nReceived interrupt signal. Stopping system...")
    except Exception as e:
        print(f"\nError: {e}")
    finally:
        server_socket.close() #close the socket
        # for client_thread in client_threads:
        #     client_thread.join()

    print("System stopped. Goodbye!")

if __name__ == "__main__":
    main()
