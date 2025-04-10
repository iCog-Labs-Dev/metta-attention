from hyperon import *
from hyperon.ext import register_atoms

'''
This is very preliminary and incomplete PoC version.
However, it is put to exts, because metta-motto depends on it.
Reagrding threading:
- Generic threading for metta can be introduced with
  parallel and sequential composition, for-comprehension, etc.
  Agents could be built on top of this functionality. However,
  this piece of code was driven by metta-motto demands.
- Two main cases for agents are:
  -- Immediate call with inputs to get outputs
  -- Asynchronous events and responses
  Supporting both cases in one implementation is more convenient,
  because both of them can be needed simultaneously in certain
  domains (e.g. metta-motto)
- Implementation can be quite different.
  -- Agents could be started explicitly
  -- They could inherint from StreamMethod
  -- Other methods could be called directly without StreamMethod wrapper
  All these nuances are to be fleshed out
'''

import threading
from queue import Queue
class StreamMethod(threading.Thread):
    def __init__(self, method, args):
        super().__init__() #daemon=True
        self._result = Queue()
        self.method = method
        self.args = args

    def run(self):
        for r in self.method(*self.args):
            self._result.put(r)

    def __iter__(self):
        return self

    def __next__(self):
        if self._result.empty() and not self.is_alive():
            raise StopIteration
        return self._result.get()


class AgentObject:

    def _try_unwrap(self, val):
        if val is None or isinstance(val, str):
            return val
        if isinstance(val, GroundedAtom):
            return str(val.get_object().content)
        return repr(val)

    def __init__(self, metta=None, path=None, atoms={}, include_paths=None, code=None):
        self._metta = metta
        if path is None and code is None:
            # purely Python agent
            return
        # The first argument is either path or code when called from MeTTa
        if isinstance(path, ExpressionAtom):# and path != E():
            code = path
        elif path is not None:
            path = self._try_unwrap(path)
            with open(path, mode='r') as f:
                code = f.read()
        # _code can remain None if the agent uses parent runner (when called from MeTTa)
        self._code = code.get_children()[1] if isinstance(code, ExpressionAtom) else \
            self._try_unwrap(code)
        self._atoms = atoms
        self._include_paths = include_paths
        self._context_space = None
        # Initialize Metta if not already initialized
        if self._metta is None:
            self._create_metta()
        else:
            self._load_code()

    def _create_metta(self):
        if self._code is None:
            return None
        self._init_metta()
        self._load_code()  # TODO: check that the result contains only units

    def _init_metta(self):
        ### =========== Creating MeTTa runner ===========
        # NOTE: each MeTTa agent uses its own space and runner,
        # which are not inherited from the caller agent. Thus,
        # the caller space is not directly accessible as a context,
        # except the case when _metta is set via get_agent_atom with parent MeTTa
        if self._metta:
            return
        if self._include_paths is not None:
            env_builder = Environment.custom_env(include_paths=self._include_paths)
            metta = MeTTa(env_builder=env_builder)
        else:
            metta = MeTTa()
        # Externally passed atoms for registrations
        for k, v in self._atoms.items():
            metta.register_atom(k, v)
        self._metta = metta

    def _load_code(self):
        if self._code:
            self._metta.run(self._code) if isinstance(self._code, str) else \
                self._metta.space().add_atom(self._code)

    def run(self):
        """Runs the agent by executing the loaded MeTTa script."""
        if self._code is None:
            print(f"Agent {self.name()} has no code to execute.")
            return

        print(f"Running agent: {self.name()} from {self._code[:50]}...")  # Show first 50 chars of code
        try:
            results = self._metta.run(self._code)
            print(f"Execution result for {self.name()}: {results}")
        except Exception as e:
            print(f"Error executing agent {self.name()}: {e}")
