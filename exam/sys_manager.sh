#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

add_users() {
    file=$1
    created=0
    exists=0
    
    while read user; do
        if id "$user"; then
            echo -e "${GREEN}User $user exists${NC}"
            exists=$((exists + 1))
        else
            sudo useradd -m "$user"
            echo "Created $user"
            created=$((created + 1))
        fi
    done < "$file"
    
    echo -e "${RED}Created: $created, Existed: $exists${NC}"
}

setup_projects() {
    user=$1
    count=$2
    
    mkdir -p "/home/$user/projects"
    
    for i in $(seq 1 $count); do
        mkdir -p "/home/$user/projects/project$i"
        echo "Project: project$i" > "/home/$user/projects/project$i/README.txt"
        echo "Date: $(date)" >> "/home/$user/projects/project$i/README.txt"
        echo "User: $user" >> "/home/$user/projects/project$i/README.txt"
        chmod 755 "/home/$user/projects/project$i"
        chmod 640 "/home/$user/projects/project$i/README.txt"
    done
    
    chown -R "$user:$user" "/home/$user/projects"
    echo -e "${RED}Created $count projects for $user${NC}"
}

sys_report() {
    file=$1
    
    echo "System Report - $(date)" > "$file"
    echo "" >> "$file"
    
    echo "Disk Usage:" >> "$file"
    df -h >> "$file"
    echo "" >> "$file"
    
    echo "Memory:" >> "$file"
    free -h >> "$file"
    echo "" >> "$file"
    
    echo "CPU:" >> "$file"
    lscpu | head -3 >> "$file"
    echo "" >> "$file"
    
    echo "Top Memory:" >> "$file"
    ps aux --sort=-%mem | head -5 >> "$file"
    echo "" >> "$file"
    
    echo "Top CPU:" >> "$file"
    ps aux --sort=-%cpu | head -5 >> "$file"
    
    echo -e "${RED}Report saved to $file${NC}"
}

process_manage() {
    user=$1
    action=$2
    
    if [ "$action" = "list_zombies" ]; then
        ps -eo pid,state,user | grep "$user" | grep "Z"
    elif [ "$action" = "list_stopped" ]; then
        ps -eo pid,state,user | grep "$user" | grep "T"
    elif [ "$action" = "kill_zombies" ]; then
        echo -e "${RED}Cannot kill zombies directly${NC}"
    elif [ "$action" = "kill_stopped" ]; then
        pids=$(ps -eo pid,state,user | grep "$user" | grep "T" | awk '{print $1}')
        if [ -n "$pids" ]; then
            echo "$pids" | xargs kill -9
            echo -e "${RED}Killed stopped processes${NC}"
        fi
    fi
}

perm_owner() {
    user=$1
    path=$2
    perm=$3
    owner=$4
    group=$5
    
    if [ -z "$path" ] || [ -z "$perm" ] || [ -z "$owner" ] || [ -z "$group" ]; then
        echo -e "${RED}Error: Missing parameters${NC}"
        return 1
    fi
    
    if [ ! -e "$path" ]; then
        echo -e "${RED}Error: Path $path does not exist${NC}"
        return 1
    fi
    
    if ! id "$owner" &>/dev/null; then
        echo -e "${RED}Error: Owner $owner does not exist${NC}"
        return 1
    fi
    
    if chown -R "$owner:$group" "$path" 2>/dev/null && chmod -R "$perm" "$path" 2>/dev/null; then
        echo -e "${GREEN}Changed permissions and ownership${NC}"
        ls -la "$path"
    else
        echo -e "${RED}Error: Failed to change permissions/ownership${NC}"
        return 1
    fi
}

show_help() {
    echo -e "${RED}Usage: $0 <mode> <args>${NC}"
    echo ""
    echo -e "${BLUE}add_users <file>${NC}"
    echo -e "${YELLOW}setup_projects <user> <count>${NC}"
    echo -e "${BLUE}sys_report <file>${NC}"
    echo -e "${YELLOW}process_manage <user> <action>${NC}"
    echo -e "${BLUE}perm_owner <user> <path> <perm> <owner> <group>${NC}"
    echo -e "${GREEN}help${NC}"
}

case "$1" in
    add_users) add_users "$2" ;;
    setup_projects) setup_projects "$2" "$3" ;;
    sys_report) sys_report "$2" ;;
    process_manage) process_manage "$2" "$3" ;;
    perm_owner) perm_owner "$2" "$3" "$4" "$5" "$6" ;;
    help) show_help ;;
    *) echo -e "${RED}Invalid mode${NC}"; show_help ;;
esac
