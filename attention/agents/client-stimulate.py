import socket
import json
import time

def send_stimulus(host, port, agent_id, pattern, stimulus):
    """Sends a pattern as stimulus to the MeTTa agent's socket server."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((host, port))
            data = {"agent_id": agent_id, "pattern": pattern, "stimulus": stimulus}
            message = json.dumps(data).encode('utf-8')
            s.sendall(message)
            response = s.recv(1024).decode('utf-8') 
            print(f"Received response: {response}")
            return response 
    except Exception as e:
        print(f"Error sending stimulus: {e}")
        return None

if __name__ == "__main__":
    host = "localhost"
    port = 5000  # Ensure this matches the server port
    agent_id = "AFImportanceDiffusionAgent"  # Must match the agent ID in main.py

    # List of atom patterns to send
    patterns = [
    # Insect-related terms
    [ "ant"], 
   # ["ants"], 
   # ["aphid"],
    
    # Poison-related terms
   # ["aphids"], 
   # ["acetamiprid"], 
   ["alachlor"]
]


    stimulus_value = 500  # Example stimulus (can be modified per pattern)

    for pattern in patterns:
        print(f"Sending pattern: {pattern}")
        response = send_stimulus(host, port, agent_id, pattern, stimulus_value)
        
        if response:  # Proceed only if a response is received
            time.sleep(2)  # Wait 2 seconds before sending the next pattern
        else:
            print("No response received, stopping transmission.")
            break
