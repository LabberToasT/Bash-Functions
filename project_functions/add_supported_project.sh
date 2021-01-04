#!bin/bash

function add_supported_project() {
	local pythonCommand="from add_supported_project import add_supported_project; add_supported_project($1)"

	( cd /Users/lucas.reich/Bash-Functions/project_functions && python3 -c $pythonCommand )
}
