#!/usr/bin/env bash

# Script for managing firewall security rules based on project policies

ip_list_file='hosts.list'
commands=()

hosts_array=( $(cat ${ip_list_file}) )

function isRoot() {
  if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root!"
    exit 1
  fi
}

function rules_create() {
  if [ ${#hosts_array[*]} -gt 0 ]
  then
    commands+=( "ufw reset" )
#    commands+=( "ufw allow from 192.168.2.3" )
    for i in ${!hosts_array[*]}
    do
      commands+=( "ufw allow from "${hosts_array[$i]} )
    done
    commands+=( "ufw enable" )
  fi
}

function rules_view() {
  echo "List of firewall security rules to be applied:"
  echo ""
  if [ ${#commands[*]} -gt 0 ]
  then
    for k in ${!commands[*]}
	do
      echo "  "${commands[$k]}
    done
  fi
  echo ""
  echo "Access will be allowed to "${#hosts_array[*]}" hosts"
  until [[ ${action} =~ ^[yYnN]$ ]]; do
    read -rp "Do you agree with it? [Y/N]: " -e action
  done
  case $action in
      [Yy]* ) echo "Rules apply!"; rules_apply;;
      [Nn]* ) exit 1;;
  esac
}

function rules_apply() {
#  echo "Rules applied!"
  if [ ${#commands[*]} -gt 0 ]
  then
    for k in ${!commands[*]}
	do
      ${commands[$k]}
    done
  fi
}

# Display help
function help() {
  echo "Usage: srm [OPTION]
Script for managing firewall security rules

Mandatory arguments to long options are mandatory for short options too.
      c, -c, --confirm  display a list of rules before adding
      h, -h, --help     display this help and exit"
}

isRoot
rules_create

if [ $# -gt 0 ]
then
  while [ $# -gt 0 ]
  do
    case $1 in
      c | -c | --confirm) rules_view;;
      h | -h | --help) help;;
      *) help;;
    esac
    shift
  done
else
  echo "Rules apply!"
  rules_apply
fi
exit 1