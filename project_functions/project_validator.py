#!/usr/bin/python

import sys, getopt

def is_valid(name):
    validProjects = open('/Users/lucas.reich/Bash-Functions/project_functions/projects.txt', 'r').readlines()

    for project in validProjects:
        if name != project[:-1]:
            continue

        return True

    return False

if __name__ == "__main__":
    import os
    current_dir = os.path.basename(os.getcwd())
    is_valid(current_dir)
