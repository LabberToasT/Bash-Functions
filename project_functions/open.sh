#!bin/bash

function open() {
	local pythonCommand="from open import open; open('$1')"

	print $pythonCommand

	( cd /Users/lucas.reich/Bash-Functions/project_functions && python3 -c $pythonCommand )
}
