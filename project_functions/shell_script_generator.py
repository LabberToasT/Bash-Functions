import os

if __name__ == '__main__':
    raise Exception('Cannot be run as standalone script');

def shell_script_generator(scriptName):
    name_of_script = __resolve_script_name(scriptName)
    location_of_script = __resolve_script_location(scriptName)
    function_argument_count = __does_function_require_arguments(scriptName)

    # create function with name of script
    function = __build_generic_shell_function()
    function = function.format(
        nameOfScript=name_of_script,
        locationOfScript=location_of_script,
        python_function=__build_python_command(name_of_script, function_argument_count)
    )

    shellScriptName = location_of_script + "/" + name_of_script + ".sh"
    __write_shell_function(function, shellScriptName)
    __register_function(location_of_script, name_of_script)

    print("Generated shell function")
    pass

def __register_function(file_src, file_name):
    if __does_dir_contain_config_file(file_src) == False:
        print('Could not find config file in directory.\n Please register the function manually for the shell usage.')
        return

    content = 'eval "source $PROJECTS_ROOT_PATH/project_functions/{file_name}.sh"\n'
    content = content.format(file_name=file_name)

    __write_to_config_file(file_src, content)

def __write_to_config_file(dir, content):
    config_file = open(dir + "/config.sh", 'a')
    config_file.write(content)
    config_file.close()


def __does_dir_contain_config_file(dir):
    config_file_src = dir + "/config.sh"

    return os.path.exists(config_file_src)

def __write_shell_function(file_content, file_name):
    file = open(file_name, 'w+')
    file.write(file_content)
    file.close()

def __build_generic_shell_function():
    shell_function = '#!bin/bash\n\n'
    shell_function += 'function {nameOfScript}() {{\n'
    shell_function += '\tlocal pythonCommand="{python_function}"\n\n'
    shell_function += '\t( cd {locationOfScript} && python3 -c $pythonCommand )\n'
    shell_function += '}}\n'

    return shell_function

def __build_python_command(script_name, function_argument_count):
    base_python_function = 'from {function_name} import {function_name}; {function_name}({function_arguments})'

    test = []
    for i in range(1, function_argument_count + 1):
        test.append('${}'.format(i))

    function_arguments = ','.join(test)

    return base_python_function.format(
        function_name=script_name,
        function_arguments=function_arguments
    )

def __does_function_require_arguments(script):
    script_dir = __resolve_script_location(script)
    script_name = __resolve_script_name(script)

    python_command = 'from {script_name} import {script_name}; from inspect import signature; print(len(signature({script_name}).parameters))'
    python_command = python_command.format(script_name=script_name)

    base_cmd_command = 'cd {dir} && python3 -c "{python_command}"'

    output = __execute_shell_command_with_output(base_cmd_command.format(dir=script_dir, python_command=python_command))
    return int(output)

def __execute_shell_command_with_output(command):
    stream = os.popen(command)
    return stream.read()

def __resolve_script_name(script):
    return os.path.basename(script)

def __resolve_script_location(script):
    return os.path.dirname(os.path.abspath(script))
