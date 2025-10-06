import glob
import subprocess
import os
import sys
from pathlib import Path

def run_metta_files(base_dir: str, pattern: str , recursive: bool = True):
    """
    Find and run all MeTTa files in a directory that match a glob pattern.
    
    :param base_dir: Directory to search in
    :param pattern: Glob pattern for files (e.g., "*experiment*.metta")
    :param recursive: Whether to search subdirectories
    """
    # Build glob pattern
    glob_pattern = os.path.join(base_dir, "**", pattern) if recursive else os.path.join(base_dir, pattern)
    
    files = glob.glob(glob_pattern, recursive=recursive)
    
    if not files:
        print(f"No files found matching pattern {pattern} in {base_dir}")
        return
    
    for f in files:
        print(f"\n=== Running {f} ===")
        try:
            result = subprocess.run(
                ["metta", f]
            )
            print(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error running {f}:\n{e.stderr}")

def run_py_files(base_dir: str, pattern: str , recursive: bool = True):
    """
    Find and run all python files in a directory that match a glob pattern.
    
    :param base_dir: Directory to search in
    :param pattern: Glob pattern for files (e.g., "*experiment*.metta")
    :param recursive: Whether to search subdirectories
    """
    # Use the *current* interpreter (works in venvs, conda, etc.)
    python = sys.executable

    # Build glob pattern
    glob_pattern = os.path.join(base_dir, "**", pattern) if recursive else os.path.join(base_dir, pattern)
    
    files = [Path(p) for p in glob.glob(glob_pattern, recursive=recursive)]
    
    if not files:
        print(f"No files found matching pattern {pattern} in {base_dir}")
        return
    
    # Prepare env (preserve current, but ensure user site isn’t disabled)
    env = os.environ.copy()
    env.pop("PYTHONNOUSERSITE", None)

    for f in files:
        print(f"\n=== Running {f} ===")
        try:

            # Important: run with cwd set to the script’s directory
            cwd = str(f.parent)

            result = subprocess.run(
                ["python3.10", f],
                cwd=cwd,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,                
            )
            print(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error running {f}:\n{e.stderr}")

# Example usage
if __name__ == "__main__":
    # Change "experiments" to your actual directory and adjust pattern as needed
    script_path = os.path.dirname(os.path.abspath(__file__))
    # run_metta_files(base_dir=script_path, pattern="experiment.metta", recursive=True)
    run_py_files(base_dir=script_path, pattern="main.py", recursive=True)

