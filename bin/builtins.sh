#!/usr/bin/env bash

##
# builtins.sh
#
# Modified bash builtins and oem functions
#
# Assumptions:
# - All util scripts have been symlinked to /usr/local/bin
##

source /usr/local/bin/common.sh
_set_colors

function cd() {
	local step='../'
	local level i dest

	if [[ -d "$@" || $# -eq 0 || "$@" == '-' || "$@" == '.' ]]; then
		builtin cd "$@"
	else
		if [[ -f $@ ]]; then     # if arg is a file -- go into its directory
			dest=$( dirname "$@" )
		else
			level=${@//\.*/}
			if [[ ${level} != [0-9] ]]; then
				_err_msg "Invalid cd argument \"$@\""
				return
			fi
			for (( i=0; i<${level}; i++ )); do
				dest+="${step}"
			done
		fi
		builtin cd "${dest}"
	fi
	_list_files
}

function cp() {
	command cp "$@"
	_list_files
}

function dir() {
	if [[ $1 == -y ]]; then
		shift
		...
	else
		ls "$@"
	fi
}

function ls() {
	if [[ $1 == -y ]]; then
		shift
		...
	else
		_update_ps1
		command ls -G "$@"
	fi
}

function mkdir() {
	command mkdir "$@"
	_list_files
}

function mv() {
	command mv "$@"
	_list_files
}

function touch() {
	command touch "$@"
	_list_files
}
