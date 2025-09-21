from hyperon.exts.agents import AgentObject
from typing import Optional, Any
from hyperon import metta
class Agentrun(AgentObject):

    def __init__(
        self,
        metta_instance: Optional[metta] = None,
        path: Optional[str] = None,
        atoms: Optional[dict] = {},
        include_paths: Optional[list[str]] = None,
        code: Optional[str] = None
    ) -> None:
        """
        Initialize the Agentrun instance.
        
        Args:
            path: Path to the MeTTa script file
            atoms: Dictionary of atoms to register
            include_paths: Additional paths to include
            code: Direct code to execute (alternative to path)
        """
        # Call the parent class's __init__ with all parameters
        super().__init__(path=path, atoms=atoms, include_paths=include_paths, code=code)
        self._metta=metta_instance
        if self._metta is None:
            self._create_metta()
        else:
            self._load_code()

    def run(self) -> Any:
        """Runs the agent by executing the loaded MeTTa script."""
        if self._code is None:
            print(f"Agent {self.name()} has no code to execute.")
            return

        # print(f"Running agent: {self.name()} from {self._code[:50]}...")  # Show first 50 chars of code
        try:
            results = self._metta.run(self._code)
            return results
        except Exception as e:
            print(f"Error executing agent {self.name()}: {e}")
