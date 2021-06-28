#!/usr/bin/env bash

##
# common.sh
#
# Common functions used in my utility scripts
##

_compress() {
	local name=${1:?$(_null_var "$FUNCNAME")}
	local file=${2:?$(_null_var "$FUNCNAME")}

	tar zcf "${name}.tar.gz" "${file}"
}

_extract() {
	local file=${1:?$(_null_var "$FUNCNAME")}
	local ext=${file##*.}
	local target

	target="${PROGDIR}/caution"
	mkdir -p "${target}"
	case "${ext}" in
		"tar"|"gz"|"xz") tar -xf "${file}" -C "${target}" ;;
		"zst")           tar -I zstd -xvf archive.tar.zst ;;
		*) _err_exit "Unsupported file extension — manually extract!" ;;
	esac
	_print_status "'${file}' extracted to: ${target}\n"
}

_err_exit() {
	printf "${RED}ERROR/EXIT[$(date +'%Y-%m-%d %H:%M:%S')]: %b!\n${NC}" "$@" >&2
	exit -1
}

_get_os() {
	local os

	os=$(uname -s)
	if [[ ${os} == "Darwin" ]]; then
		echo "${os}"
	elif [[ ${os} == "Linux" ]]; then
		if grep -q "centos" /etc/os-release; then
			echo "CentOS"
		elif grep -q "ubuntu" /etc/os-release; then
			echo "Ubuntu"
		else
			_err_exit "OS '${os}' not supported"
		fi
	else
		_err_exit "OS '${os}' not supported"
	fi
}

_install_dependencies() {
	local pkgs=(
		'coreutils'
		'jq'
		'ncurses'
		'perl'
		'xclip'
		'zstd'
	)
	local os i

	os=$(_get_os)
	for i in "${pkgs[@]}"; do
		_is_installed "${os}" "${i}" || _install_pkg "${os}" "${i}"
	done
}

_install_pkg() {
	local os=$1
	local name=$2

	case "${os}" in
		"Darwin") brew install "${name}" ;;
		"CentOS") yum install -y "${name}" ;;
		"Ubuntu") apt install -y "${name}" ;;
	esac
}

_is_installed() {
	local os=$1
	local name=$2

	case "${os}" in
		"Darwin") brew list "${name}" &>/dev/null ;;
		"CentOS") rpm -q "${name}" &>/dev/null ;;
		"Ubuntu") dpkg -l "${name}" &>/dev/null ;;
	esac
}

_null_var() {
	echo "${RED}ERROR/EXIT: Variable in $1() cannot be null!${NC}"
}

_parse_args() {
	while getopts ":hd" opt; do
		case ${opt} in
			d ) set -x ;;
			h ) usage ;;
			\? ) usage "Invalid option: -$OPTARG" ;;
		esac
	done
	shift $((OPTIND-1))
}

_print_status() {
	printf "${NC}${GRN}  ***** %b${NC}" "$@"
}

_print_warn() {
	printf "${NC}${YEL}  ***** %b${NC}" "$@"
}

_set_colors() {
	local hues=( "RED" "GRN" "YEL" "BLU" "MAG" "CYN" "WHT" "ORG" "NC" "CLR" )

	if [[ $TERM != *"term"* ]]; then
		for hue in "${hues[@]}"; do
			unset "${hue}"
		done
		unset hue
	else
		CLR=$(echo -en "\033[2K")
		BOLD=$(tput bold)
		ITALIC=$(tput sitm)
		DIM=$(tput dim)
		RED=$(tput sgr0; tput setaf 1)
		GRN=$(tput sgr0; tput setaf 2)
		YEL_BLD=$(tput sgr0; tput setaf 3; tput bold)
		YEL=$(tput sgr0; tput setaf 3)
		BLU=$(tput sgr0; tput setaf 4)
		MAG=$(tput sgr0; tput setaf 5)
		CYN=$(tput sgr0; tput setaf 6)
		WHT=$(tput sgr0; tput setaf 7)
		LT_BLU=$(tput sgr0; tput setaf 12)
		ORG=$(tput sgr0; tput setaf 16)
		DK_GRAY=$(tput sgr0; tput setaf 18)
		LT_BLU=$(tput sgr0; tput setaf 12)
		NC=$(tput sgr0)
	fi
}

_usage() {
	local synopsis=$1
	local name=$2
	local args=$3
	shift; shift; shift;
	local options=( "$@" )
	local i option detail

	echo "${YEL}${ITALIC}"
	echo "  Synopsis: ${synopsis}" \
		| sed 's/[[:space:]]\+/ /g' \
		| perl -lpe 's/(.{56,}?)\s/$1\n\t   /g '
	echo "${NC}${YEL}${BOLD}"
	echo "  Usage: ${name} ${args}"
	echo ""
	echo "    Where:"
	for i in "${options[@]}"; do
		option=${i//:*}
		detail=${i#*:}
		printf "      %-16s" "${option}"
		echo "${detail}" \
			| sed 's/[[:space:]]\+/ /g' \
			| perl -lpe 's/(.{23,}?)\s/$1\n\t\t       /g '
	done
	echo "${NC}"
}
