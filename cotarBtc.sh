#!/usr/bin/env bash
#
# cotarBtc.sh - Get information about the Bitcoin value through "Mercado Bitcoin" API
#
# Website:       https://4fasters.com.br
# Author:        Mateus Gabriel Müller
# Maintenance:   Mateus Gabriel Müller
#
# ------------------------------------------------------------------------ #
#  This script receives two parameters:
#    * update time (seconds) - This is how much time the script will wait to make a new request to the API
#    * number of requests - This is how many requests the script will make to the API
#
# Examples:
#      $ ./cotarBtc.sh 5 10 - 10 requests every 5 seconds
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 18/08/2018, Mateus Müller:
#       - Initial version with query to the API
#   v1.1 19/08/2018
#       - Added -v, -h and the looping
#   v1.2 07/09/2018
#       - Added sed expression the cut data from the API
#   v2.0 07/09/2018
#       - Redesign of the code
#       - The request to the API was moved to the end of the code to be more performatic
#       - Added parameter expansion
#       - Changed variable and function names to PT-BR
# ------------------------------------------------------------------------ #
# Tested on:
#   bash 4.4.19
# ------------------------------------------------------------------------ #

# -------------------------------BASIC VARIABLES----------------------------------------- #
# Colors for printf
GREEN='\033[1;32m'
NO_COLOR='\033[0m'
YELLOW='\033[1;33m'

# Message -h
USE_MESSAGE="
Use: $(basename "$0") UPDATE_TIME_SECONDS NUMBER_OF_REQUESTS

OPTIONS:
    -v, --version - Script version
    -h, --help - Help page
"
VERSION="v2.0"
# ------------------------------------------------------------------------ #

# -------------------------------TESTS----------------------------------------- #
# Lynx installed?
[ ! -x "$(which lynx)" ] && printf "${YELLOW}We need to install ${GREEN}Lynx${YELLOW}, please, type your password:${NO_COLOR}\n" && sudo apt install lynx 1> /dev/null 2>&1 -y
# ------------------------------------------------------------------------ #

# -------------------------------ADVANCED VARIABLES----------------------------------------- #
API_MERCADO_BITCOIN="https://www.mercadobitcoin.net/api/BTC/ticker/"
INFORMATIONS_DESCRIPTION=(
  "Highest unit price of the last 24 hours: "
  "Lowest unit price of the last 24 hours: "
  "Quantity traded in the last 24 hours: "
  "Unit price of the last negotiation: "
  "Highest bid offer price in the last 24 hours: "
  "Lowest offer price for the last 24 hours: "
  "Date: "
)
UPDATE_TIME=${1:-1}
NUMBER_OF_REQUESTS=${2:-10}
# ------------------------------------------------------------------------ #

# -------------------------------FUNCTIONS----------------------------------------- #
formatDate () {
  date -d "@${1}" +%d/%m/%Y # Format to dd/mm/yyyy
}

getData () {
  # The number 6 below means the Date must be formated to dd/mm/yyyy
  [ $1 -eq 6 ] && echo -e "${GREEN}${INFORMATIONS_DESCRIPTION[$1]}${YELLOW}$(formatDate ${ARRAY_JSON_MERCADO_BITCOIN[$1]})\n--" && return
  echo -e "${GREEN}${INFORMATIONS_DESCRIPTION[$1]}${YELLOW}${ARRAY_JSON_MERCADO_BITCOIN[$1]}"
}

listData () {
local counter=0
local counter_2=0

while [[ $counter -lt $NUMBER_OF_REQUESTS ]]; do
  while [[ $counter_2 -lt ${#ARRAY_JSON_MERCADO_BITCOIN[@]} ]]; do # While less than length
    getData $counter_2
    counter_2=$(($counter_2+1))
  done
  sleep $UPDATE_TIME
  counter=$(($counter+1))
  counter_2=0
done
}
# ------------------------------------------------------------------------ #

# -------------------------------EXECUTION----------------------------------------- #
if test -n "$1"; then
  case "$1" in
    -v|--version) printf "Version $VERSION\n" && exit 0 ;;
    -h|--help)    printf "$USE_MESSAGE\n"  && exit 0 ;;
  esac
fi

read -r -a ARRAY_JSON_MERCADO_BITCOIN <<< "$(lynx -source $API_MERCADO_BITCOIN | sed 's/[^0-9 .]//g')" # Create an array with the returned values

listData
# ------------------------------------------------------------------------ #
