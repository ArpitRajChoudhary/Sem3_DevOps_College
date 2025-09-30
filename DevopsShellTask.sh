#!/bin/bash
system_health() {
    echo "Checking system health..."
    echo "Disk Usage:" > system_report.txt
    df -h >> system_report.txt
    echo "" >> system_report.txt
    echo "CPU Info:" >> system_report.txt
    lscpu >> system_report.txt
    echo "" >> system_report.txt
    echo "Memory Usage:" >> system_report.txt
    free -m >> system_report.txt

    echo "First 10 lines of system_report.txt:"
    head -n 10 system_report.txt
}

active_processes() {
    echo "Showing active processes..."
    ps aux
    echo "Enter a keyword to filter processes:"
    read keyword
    ps aux | grep $keyword
    count=$(ps aux | grep $keyword | wc -l)
    echo "Number of processes matched: $count"
}

user_group_management() {
    if [ "$EUID" -ne 0 ]; then
        echo "You need to run this option as root (use: sudo ./system_health.sh)"
        return
    fi

    echo "Enter new username:"
    read uname
    useradd $uname
    echo "User $uname created."

    echo "Enter a new group name:"
    read gname
    groupadd $gname
    usermod -aG $gname $uname
    echo "User $uname added to group $gname"

    touch testfile.txt
    chown $uname:$gname testfile.txt
    echo "Changed ownership of testfile.txt"
}


file_organizer() {
    echo "Enter directory path:"
    read dir
    if [ -d "$dir" ]; then
        cd $dir
        mkdir -p images docs scripts
        mv *.jpg images/ 2>/dev/null
        mv *.png images/ 2>/dev/null
        mv *.txt docs/ 2>/dev/null
        mv *.md docs/ 2>/dev/null
        mv *.sh scripts/ 2>/dev/null
        echo "Files moved into folders."
        tree
    else
        echo "Directory does not exist."
    fi
}

network_diagnostics() {
    echo "Running ping..."
    ping -c 3 google.com
    echo "Running dig..."
    dig google.com
    echo "Running curl..."
    curl -I https://example.com
    echo "Saving results to network_report.txt"
    {
        ping -c 3 google.com
        dig google.com
        curl -I https://example.com
    } > network_report.txt
}

schedule_task() {
    echo "Enter script path to schedule:"
    read spath
    echo "Enter minute (0-59):"
    read minute
    echo "Enter hour (0-23):"
    read hour
    (crontab -l; echo "$minute $hour * * * $spath") | crontab -
    echo "Cron job added."
}

ssh_key_setup() {
    echo "Generating SSH key..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    echo "Public key is:"
    cat ~/.ssh/id_rsa.pub
    echo "Copy this key to remote server using:"
    echo "ssh-copy-id user@remote_host"
}


while true
do
    echo "========= MENU ========="
    echo "1. System Health Check"
    echo "2. Active Processes"
    echo "3. User & Group Management"
    echo "4. File Organizer"
    echo "5. Network Diagnostics"
    echo "6. Scheduled Task Setup"
    echo "7. SSH Key Setup"
    echo "8. Exit"
    echo "========================"
    read choice

    case $choice in
        1) system_health ;;
        2) active_processes ;;
        3) user_group_management ;;
        4) file_organizer ;;
        5) network_diagnostics ;;
        6) schedule_task ;;
        7) ssh_key_setup ;;
        8) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice, try again." ;;
    esac
done
