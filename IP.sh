#!/bin/bash
# =======================================
# Author  : Khoka Ahmed
# GitHub  : https://github.com/weirdnehal
# Tool    : Termux IP Lookup
# Version : 3.2
# =======================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear

# Banner using figlet
if ! type figlet >/dev/null 2>&1; then
    echo -e "${YELLOW}Figlet not found. Installing...${RESET}"
    pkg install figlet -y
fi

figlet -f slant "IP Lookup"
echo -e "${CYAN}🌐 Termux IP Lookup Tool 🌐${RESET}"

# Hardcoded Author info
username="Khoka Ahmed"
github_link="https://github.com/weirdnehal"

echo -e "${GREEN} Author   : $username"
echo -e " GitHub   : $github_link"
echo -e " Version  : 3.2 ${RESET}"
echo "--------------------------------------"

# Menu
echo -e "${YELLOW}[1]${RESET} 🔍 Lookup My IP"
echo -e "${YELLOW}[2]${RESET} 🌎 Lookup Other IP"
echo -e "${YELLOW}[3]${RESET} 📜 View Lookup History"
echo -e "${YELLOW}[4]${RESET} 🚪 Exit"
echo "--------------------------------------"
read -p "Choose an option: " opt

if [ "$opt" == "1" ]; then
    ip=$(curl -s ifconfig.me)
elif [ "$opt" == "2" ]; then
    read -p "Enter IP Address: " ip
    if ! [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid IP Address!${RESET}"
        exit
    fi
elif [ "$opt" == "3" ]; then
    if [ -f history.txt ]; then
        echo -e "${CYAN}📜 Lookup History:${RESET}"
        cat history.txt
    else
        echo -e "${RED}No history found!${RESET}"
    fi
    exit
elif [ "$opt" == "4" ]; then
    echo "👋 Thanks for using this tool!"
    exit
else
    echo -e "${RED}❌ Invalid option!${RESET}"
    exit
fi

# Spinner function
spinner(){
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Fetch data
curl -s https://ipinfo.io/$ip/json > /tmp/ipdata.json &
pid=$!
spinner $pid
data=$(cat /tmp/ipdata.json)

# Save to history
echo "$(date): $ip" >> history.txt

# Display results
echo -e "${CYAN}"
echo "========= 📊 Lookup Result 📊 ========="
echo -e "${RESET}"
echo -e "${GREEN}🔹 IP Address :${RESET} $(echo $data | jq -r '.ip')"
echo -e "${GREEN}🔹 Hostname   :${RESET} $(echo $data | jq -r '.hostname')"
echo -e "${GREEN}🔹 City       :${RESET} $(echo $data | jq -r '.city')"
echo -e "${GREEN}🔹 Region     :${RESET} $(echo $data | jq -r '.region')"
echo -e "${GREEN}🔹 Country    :${RESET} $(echo $data | jq -r '.country')"
echo -e "${GREEN}🔹 Org/ISP    :${RESET} $(echo $data | jq -r '.org')"
echo -e "${GREEN}🔹 Timezone   :${RESET} $(echo $data | jq -r '.timezone')"
loc=$(echo $data | jq -r '.loc')
echo -e "${GREEN}🔹 Location   :${RESET} $loc"
echo -e "${GREEN}🔹 Google Map :${RESET} https://www.google.com/maps?q=$loc"

# Country flag (Termux-safe)
country_code=$(echo $data | jq -r '.country')
if [ -n "$country_code" ]; then
  first_char=$(printf "%d" "'${country_code:0:1}")
  second_char=$(printf "%d" "'${country_code:1:1}")
  first_unicode=$((0x1F1E6 + first_char - 65))
  second_unicode=$((0x1F1E6 + second_char - 65))
  flag=$(echo -e "\U$(printf '%X' $first_unicode)\U$(printf '%X' $second_unicode)")
  if [ -z "$flag" ]; then
      flag="$country_code"
  fi
  echo -e "${GREEN}🔹 Country Flag :${RESET} $flag"
fi

echo "--------------------------------------"
echo -e "${CYAN}✨ Created by: $username ($github_link)${RESET}"
echo "======================================"
