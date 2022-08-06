#!/bin/bash
# Usage: 
# source fbash.sh
# 
# DEFINE_string name --required "" "Your name"
# DEFINE_int age 1 "Your age"
# 
# fbash::init "$@"
# 
# echo "Hello, $FLAGS_name! Your age is $FLAGS_age"
# echo "Non-flag arguments: ${FBASH_ARGV[@]}"

function fbash::CHECK_EQ() {
  if  [[ "$1" == "$2" ]]; then
    return
  else
    echo "CHECK_EQ($1, $2) failed: $3"
    exit 1
  fi
}

function fbash::CHECK_LT() {
  if [[ "$1" < "$2" ]]; then
    return
  else
    echo "CHECK_LT($1, $2) failed: $3"
    exit 1
  fi
}

function fbash::CHECK_LE() {
  if [[ "$1" == "$2" ]] || [[ "$1" < "$2" ]]; then
    return
  else
    echo "CHECK_LE($1, $2) failed: $3"
    exit 1
  fi
}

function fbash::CHECK_GT() {
  if [[ "$1" > "$2" ]]; then
    return
  else
    echo "CHECK_GT($1, $2) failed: $3"
    exit 1
  fi
}

function fbash::CHECK_GE() {
  if [[ "$1" == "$2" ]] || [[ "$1" > "$2" ]]; then
    return
  else
    echo "CHECK_GE($1, $2) failed: $3"
    exit 1
  fi
}

declare -A TYPES
declare -A REQUIRED
declare -A DEFAULT_VALS
declare -A HELP_MESSAGES

TYPES["help"]="string"
REQUIRED["help"]=false
DEFAULT_VALS["help"]=""
HELP_MESSAGES["help"]="Print help information"

# The input should look like
# fbash::DEFINE_flag <type> <name> [--required] <default_value> <help_message>
function fbash::DEFINE_flag() {
  fbash::CHECK_GE $# 4 "${FUNCNAME[0]} usage: <type> <name> [--required] <default_value> <help_message>"
  fbash::CHECK_LE $# 5 "${FUNCNAME[0]} usage: <type> <name> [--required] <default_value> <help_message>"
  local required=false
  args=()
  for arg in "$@";
  do
    if [[ $arg == "--required" ]]; then
      required=true
    else
      args+=("$arg")
    fi
  done
  fbash::CHECK_GE ${#args[@]} 4 "${FUNCNAME[0]} usage: <type> <name> [--required] <default_value> <help_message>"
  local type="${args[0]}"
  local name="${args[1]}"
  local default_val="${args[2]}"
  local help_msg="${args[3]}"
  TYPES[$name]=$type
  REQUIRED[$name]=$required
  DEFAULT_VALS[$name]=$default_val
  HELP_MESSAGES[$name]=$help_msg
}

function DEFINE_string() {
  fbash::DEFINE_flag string "$1" "$2" "$3" "$4"
}

function DEFINE_int() {
  fbash::DEFINE_flag int "$1" "$2" "$3" "$4"
}

function DEFINE_bool() {
  fbash::DEFINE_flag bool "$1" "$2" "$3" "$4"
}

function LOG() {
  echo -e "[$(date +%FT%T.%3N)] $@"
}

function LOG_INFO() {
  LOG "INFO $@"
}

function LOG_WARNING() {
  LOG "WARN $@"
}

function LOG_ERROR() {
  LOG "ERROR $@"
}

function LOG_EXIT() {
  LOG "ERROR $@"
  exit 1
}

function fbash::usage() {
  echo "Flags from $(basename ${BASH_SOURCE[-1]})"
  for flag in "${!REQUIRED[@]}";
  do
    local default_val="${DEFAULT_VALS[$flag]}"
    if [[ ${TYPES[$flag]} = "string" ]]; then
      default_val="\"$default_val\""
    fi
    echo "  --$flag (${HELP_MESSAGES[$flag]}) type: ${TYPES[$flag]} default: $default_val"
  done
  exit 0
}

# Parses the flags and prints the positional arguments.
function fbash::init() {
  local args=()
  local -A flags
  while [[ $# -gt 0 ]];
  do
    case "$1" in
      --*)
        local flag=${1:2}
        if [[ -z "${TYPES[$flag]}" ]]; then
          echo "Unknown flag: $flag"
          exit 1
        fi
        if [[ "$flag" = help ]]; then
          fbash::usage
        fi
        flags[$flag]=$flag
        case "${TYPES[$flag]}" in
          bool)
            export FLAGS_$flag=true
            ;;
          int|string)
            if [[ -n "$2" ]] && [[ ${2:0:1} != '-' ]]; then
              if [[ ${TYPES[$flag]} = string ]]; then
                export FLAGS_$flag="$2"
              else
                export FLAGS_$flag=$2
              fi
              shift
            else
              echo "Missing value for flag: $flag"
            fi
            ;;
        esac
        ;;
      -*)
        echo "Invalid flag: $1"
        exit 1
        ;;
      *)
        args+=("$1")
        ;;
    esac
    shift
  done
  for flag in "${!REQUIRED[@]}";
  do
    if [[ -z "${flags[$flag]}" ]]; then
      if [[ ${REQUIRED[$flag]} = true ]]; then
        echo "Required flag not set: --$flag"
        exit 1
      else
        if [[ $flag = string ]]; then
          export FLAGS_$flag="${DEFAULT_VALS[$flag]}"
        else
          export FLAGS_$flag=${DEFAULT_VALS[$flag]}
        fi
      fi
    fi
  done
  export FBASH_ARGV="${args[@]}"
}
