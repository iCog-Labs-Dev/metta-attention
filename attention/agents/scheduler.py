import concurrent.futures
import time
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from agents.agent_base import AgentObject

class ParallelScheduler:
    def __init__(self):
        self.agent_creators = {}  # Stores agent creator functions
        self.agent_instances = {}  # Stores actual agent instances

    def register_agent(self, agent_id, agent_creator):
        """ Register an agent factory function (not instance) """
        self.agent_creators[agent_id] = agent_creator
        print(f"Registered agent: {agent_id}")

    def get_or_create_agent(self, agent_id: str) -> AgentObject:
        """ Get existing agent or create a new one if not exists """
        if agent_id not in self.agent_instances:
            if agent_id in self.agent_creators:
                self.agent_instances[agent_id] = self.agent_creators[agent_id]()
                print(f"Created new agent: {agent_id}")
            else:
                print(f"Agent {agent_id} not found.")
                return None
        
        return self.agent_instances[agent_id]

    def stimulate(self):
        """ Run all agents once in parallel while keeping state """
        if not self.agent_creators:
            print("No agents registered!")
            return

        print("\nStarting agent execution cycle...")

        with concurrent.futures.ThreadPoolExecutor() as executor:
            futures = []
            for agent_id in self.agent_creators:
                agent = self.get_or_create_agent(agent_id)  # Use persistent agent
                if agent:
                    futures.append(executor.submit(agent.run))

            # Wait for all agents to complete
            concurrent.futures.wait(futures)

        print("Agent execution cycle completed.")
