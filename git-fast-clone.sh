#!/bin/bash

# Add Multiple Repository Server Script
# usage: git-multi-remote.sh -u username -r repository

# Get the script directory to find the config file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Connection to the url address
declare -A URL
URL=(
  [CON]=""
  [AND]=""
)

# Comment out the repository servers you do not have with the '#' character
declare -A REMOTES     # Explicitly declare key value array
REMOTES=(
  [hub]=github.com
)
# Reserve booleans to check if remotes have been already added
declare -A STATUS

# Use the remote.conf file to setup configuration
declare -A CONFIG
CONFIG=(
  [SSL]=false
  [DIR]=""
  [REPO]=""
  [USER]=""
)

# Set the main origin remote
ORIGIN="${REMOTES[hub]}"


USAGE="[-u <user>] [-r <repo>] [--ssl]"
LONG_USAGE="Clone from a repository faster.
Config: Use 'remote.conf' to configure variables.
        Keep in mind using argument options 
        will override the configuration variables.

Note: The argument order does not matter.
Options:
    -u <user> Username of the repository
   --user <user>
    -r <repo> Name of the git repository
   --repo <repo>
    -d <directory> Desired directory name to place the git location
   --dir <directory>
   --git      Use git connection
   --ssl      Use https connection (default is git)

"

directory_as_repository() {
  IFS='/'
   # Read pwd into an array as tokens separated by IFS
  read -ra FULLPATH <<< "$PWD"
  # Reset to default value after usage
  IFS=' '

  # Get the last index to get the current directory
  last=$(("${#FULLPATH[@]}"-1))
  repo="${FULLPATH[$last]}"

  echo "fast-clone: using '$repo' as default repository"
  set_repository $repo
}

# Check if desired directory exists
check_dir() {
  # inverse of -n is -z
  if [[ -n "${CONFIG[DIR]}" && ! -d "${CONFIG[DIR]}" ]]; then
    echo "fast-clone: cloning repository '${CONFIG[REPO]} .'
"
  elif [[ -z "${CONFIG[DIR]}" && ! -d "${CONFIG[REPO]}" ]]; then
    echo "fast-clone: cloning repository '${CONFIG[REPO]} ..'
"
  else
    git rev-parse --git-dir 2> /dev/null
    echo "fatal: directory already exists"
    exit 0
  fi
}

# Functions need to be set before getting called
check_ssl() {
  if [ "${CONFIG[SSL]}" = true ]; then
    URL[CON]="https://"
    URL[AND]="/"
  else
    URL[CON]="git@"
    URL[AND]=":"
  fi
}

check_variables() {
  if [ -z "${CONFIG[USER]}" ]; then
    echo "fatal: username is empty"
    exit 0
  fi

  if [ -z "${CONFIG[REPO]}" ]; then
    directory_as_repository
  fi
}

clone_repo() {
  clone="git clone ${URL[CON]}$ORIGIN${URL[AND]}${CONFIG[USER]}/${CONFIG[REPO]}.git ${CONFIG[DIR]}"
  echo "$clone"
  $clone
}

init_config() {
  # while IFS= read -r line;
  while read line
  do
    if echo $line | grep -F = &>/dev/null; then
      # Skip comments lines using regular experssion with wildcards in double brackets
      if [[ $line =~ ^# ]]; then continue; fi

      # Get the main configuration variable
      conf=$(echo "$line" | cut -d '=' -f 1)
      # Identify the identifier and key
      var=$(echo "$conf" | cut -d '.' -f 1)
      key=$(echo "$conf" | cut -d '.' -f 2-)
      # Fetch the value
      val=$(echo "$line" | cut -d '=' -f 2-)

      # echo "$var [ ${key^^} ] = $val"

      # Skip unassigned variables
      if [ -z $val ]; then continue; fi

      # Assign the configurations
      case "$var" in
        REMOTES)
          REMOTES[$key]=$val
          STATUS[$key]=true
          ;;

        CONFIG)
          if [ $key = "ssl" ]; then
            CONFIG[${key^^}]=$val
          else
            CONFIG[${key^^}]=$(echo "$val")
          fi
          ;;
      esac
    fi
  done < "$DIR/config.conf"
}

main() {
  # Loop to fetch all the commands
  while case "$#" in 0) break ;; esac
  do
    # echo "Looping: $1"
    # echo "value: $2"
    case "$1" in
      -h|--h|--help)
        show_help
        ;;

      -d|--d|--dir)
        shift
        set_directory "$1"
        ;;

      -r|--r|--repo)
        shift
        set_repository "$1"
        ;;

      -u|--u|--user)
        shift
        set_username "$1"
        ;;

      -g|-git|--git)
        CONFIG[SSL]=false
        ;;

      -s|-ssl|--ssl)
        CONFIG[SSL]=true
        ;;

      -*)
        break
        ;;

      *)
        break
        ;;
    esac
    # get the next variable
    shift
  done
}

show_help() {
  echo "usage: $(basename "$0") $USAGE"
  echo ""
  echo "$LONG_USAGE"
  exit 0
}

set_directory() {
  CONFIG[DIR]="$1"
}

set_repository() {
  CONFIG[REPO]="$1"
}

set_username() {
  CONFIG[USER]="$1"
}

#################################
#     MAIN CODE STARTS HERE     #
#################################

# Load the configuration
init_config

# Options passed in the arguments will override the configuration
main "$@"

# Make sure to check the connection first
check_variables

check_ssl

check_dir

# After checking all the requirements start the git clone process
clone_repo

exit 0