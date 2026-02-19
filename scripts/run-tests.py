import subprocess
import pathlib
import sys
import os
import re

# Define ANSI escape codes for colors
RESET = "\033[0m"
BOLD = "\033[1m"
CYAN = "\033[96m"
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"


def extract_and_print(result, path: pathlib.Path, idx: int) -> bool:
    # Combine stdout and stderr for analysis
    output = result.stdout + "\n" + result.stderr
    
    # Clean up the output for display
    extracted = output.replace("[()]\n", "").strip()

    # Failure detection:
    # 1. Non-zero return code is the primary indicator.
    # 2. Pattern "is X, should Y." where X != Y.
    has_failure = result.returncode != 0

    if not has_failure:
        # Check for explicit assertion failures
        # Pattern: is <actual>, should <expected>.
        # Note: use `\.(\s|$)` to match only the sentence-ending dot, not dots in decimals.
        for match in re.finditer(r"is\s+(.+?),\s+should\s+(.+?)\.(\s|$)", output):
            actual, expected = match.group(1).strip(), match.group(2).strip()
            if actual != expected:
                has_failure = True
                break
    
    # Some environments render the failure emoji as bytes or garbled text
    if not has_failure:
        if "❌" in output or "â\x9d\x8c" in output:
            has_failure = True

    status_color = RED if has_failure else GREEN
    print(YELLOW + f"Test {idx + 1}: {path}" + RESET)
    
    # Only show the full output if it failed
    if has_failure:
        print(status_color + extracted + RESET)
    else:
        print(status_color + "test passed" + RESET)
        
    print(YELLOW + f"Exit-code: {result.returncode}" + RESET)
    print("-" * 40)

    return has_failure


# Function to print section headers
def print_header(text: str) -> None:
    print(BOLD + CYAN + f"\n=== {text} ===" + RESET)


# This script is expected to be run from the PeTTa directory.
# PeTTa's run.sh uses swipl to execute MeTTa files.
# metta-attention is expected to be a sibling directory of PeTTa.

# Resolve paths
SCRIPT_DIR = pathlib.Path(__file__).resolve().parent
METTA_ATTENTION_ROOT = SCRIPT_DIR.parent
PETTA_DIR = pathlib.Path(os.getcwd()).resolve()

# Kill any stray swipl processes to avoid jumbled output/conflicts
if sys.platform == "win32":
    os.system('taskkill /F /IM swipl.exe /T /FI "STATUS eq RUNNING" >nul 2>&1')

root: pathlib.Path = METTA_ATTENTION_ROOT

# Find all test files but exclude ForgettingAgent
all_test_files = list(root.rglob("*-test.metta"))
testMettaFiles = [f for f in all_test_files if "ForgettingAgent" not in str(f)]

total_files: int = 0
results: list = []
fails: int = 0

# Print header
print_header("Test Runner")
print(CYAN + f"PeTTa dir  : {PETTA_DIR}" + RESET)
print(CYAN + f"Tests root : {root}" + RESET)
excluded_count = len(all_test_files) - len(testMettaFiles)
print(CYAN + f"Found {len(testMettaFiles)} test file(s) (Excluded {excluded_count} ForgettingAgent tests)" + RESET)
print("-" * 40)

# Isolate environment for Janus/PeTTa
# remove Python-related env vars that might interfere with the PeTTa internal Python
env = os.environ.copy()
env.pop("PYTHONHOME", None)
env.pop("PYTHONPATH", None)

for testFile in testMettaFiles:
    total_files += 1
    # Use forward slashes for sh
    abs_test_path = testFile.resolve().as_posix()
    
    try:
        # Use a robust way to run subprocess on Windows to avoid ThreadException
        # run 'sh' which on Windows usually comes from Git Bash or similar
        process = subprocess.Popen(
            ["sh", "run.sh", abs_test_path, "-s"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=str(PETTA_DIR),
            env=env
        )
        stdout_bytes, stderr_bytes = process.communicate()
        
        # Decode manually to handle potential encoding issues
        stdout = stdout_bytes.decode('utf-8', errors='replace')
        stderr = stderr_bytes.decode('utf-8', errors='replace')
        
        # Create a dummy result object
        class Result:
            def __init__(self, rc, so, se):
                self.returncode = rc
                self.stdout = so
                self.stderr = se
                
        results.append((Result(process.returncode, stdout, stderr), testFile))
    except Exception as e:
        results.append((f"Execution Error: {str(e)}", testFile))
        fails += 1

# Output the results
for idx, (result, path) in enumerate(results):
    if isinstance(result, str):
        print(RED + f"Error found: {result}" + RESET)
        continue

    has_failure = extract_and_print(result, path, idx)
    if has_failure:
        fails += 1


# Summary
print_header("Test Summary")
print(f"{total_files} files tested.")
print(RED + f"{fails} failed." + RESET)
print(GREEN + f"{total_files - fails} succeeded." + RESET)


if fails > 0:
    print(RED + "Tests failed. Process Exiting with exit code 1" + RESET)
    sys.exit(1)
