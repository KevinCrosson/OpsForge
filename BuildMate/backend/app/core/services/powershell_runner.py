# Run PowerShell scripts from Python
import subprocess

def run_script(script_path, args=[]):
    command = ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path] + args
    result = subprocess.run(command, capture_output=True, text=True)
    return result.stdout  # Return script output