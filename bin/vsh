#!/usr/bin/env bash

##
# vsh
#
# Create shell script with name; automatically set file to be executable.
##

readonly ARGS=( "$@" )
readonly PROGNAME=$(basename "${BASH_SOURCE[0]}")
readonly PROGDIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")" )
readonly NAME=$1

usage() {
	local summary="Create executable shell script named 'NAME.sh'"
	local args='<NAME> [-h] [-d]'
	local options=(
		"NAME: Script name. '.sh' file extension is automatically appended."
		"-d: Enable debug mode. Warning: Extremely verbose."
		"-h: Print usage."
	)

	_usage "${summary}" "${PROGNAME}" "${args}" "${options[@]}"
	[[ -n $1 ]] && _err_exit "$@"
	exit -1
}

create_file() {
	local name=${1:?$(_null_var "$FUNCNAME")}

	install -m 755 /dev/null "${name}"
	vim "${name}"
}

check_args() {
	local name_str=$1

	if [[ -z ${name_str} ]]; then
		usage "Must pass -n <NAME> arg"
	fi
	name="${name_str}.sh"
	if [[ -f ${name} ]]; then
		_err_exit "File '${name}' already exists"
	fi
}

main() {
	local name

	source "${PROGDIR}/common.sh"
	_install_dependencies
	_set_colors
	_parse_args "${ARGS[@]}"
	check_args "${NAME}"
	create_file "${name}"
}
main
