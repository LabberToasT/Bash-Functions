import sys, getopt, subprocess
from project_validator import is_valid

def open(projectName):
    if not is_valid(projectName):
        print("Project \'" + projectName + "\' is not supported by this command.")
        return

    bashCommand = "open -a PhpStorm " + __getProjectDir() + "/" + projectName
    __runBashCommand(bashCommand)

def __runBashCommand(command):
    subprocess.Popen(command.split(), stdout=subprocess.PIPE)

def __getProjectDir():
    return '/Users/lucas.reich/PhpstormProjects'

if __name__ == "__main__":
    import os
    current_dir = os.path.basename(os.getcwd())
    open(current_dir)
