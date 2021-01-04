import os

def add_supported_project(project_name):
    if not __project_folder_has_dir(project_name):
        raise Exception("Could not find Project with name {} in Projects folder. \n Will not add it to supported projects!".format(project_name))

    __write_to_supported_projects(project_name)
    print("Added {} to list of supprted Projects.".format(project_name))
    return

def __write_to_supported_projects(project_name):
    suppored_projects = open('/Users/lucas.reich/Bash-Functions/project_functions/projects.txt', 'a')
    suppored_projects.write(project_name)
    suppored_projects.close()

    return

def __project_folder_has_dir(dir):
    projects_path = __get_projects_path()

    project_dir_src = projects_path + "/" + dir

    return os.path.exists(project_dir_src)

def __get_projects_path():
    return '/Users/lucas.reich/PhpstormProjects'
