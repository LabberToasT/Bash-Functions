#!bin/bash

function shell_script_generator() {
	local pythonCommand="from shell_script_generator import shell_script_generator; shell_script_generator($1)"

	( cd /Users/lucas.reich/Bash-Functions/project_functions && python3 -c $pythonCommand )
}
