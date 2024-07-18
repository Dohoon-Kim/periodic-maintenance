#!/bin/bash

# Create output file name
output_file="periodic_maintenance_$(hostname)_$(date +'%Y_%m').txt"

# Define function
function what() {
    echo -e ""
    echo "=============================================="
    echo "$1"
    echo "=============================================="
}

# Redirect script execution results to a file (including stderr)
{
    what "1. Check hostname and domain name"
    hostname
    #cat /etc/hosts | grep -v ::1 | grep -v 127.0.0.1

    what "2. Check IP address"
    ip addr | grep 'inet ' | grep -vE '(docker0|veth|br-[0-9]+|127.0.0.1|172.14.1)' | awk {'print $2'}

    what "3. Display CPU information"
    nproc

    what "4. Display memory size"
    free -h

    what "5. Display disk size"
    lsblk | grep 'sd'

    what "6. Display uptime"
    uptime

    what "7. Display CPU usage / system / idle"
    vmstat 1 1 | awk 'NR==3 {print $13, $14, $15}'

    what "8. Display memory used percentage"
    free -m | grep '^Mem' | awk '{printf "%.2f\n", ($3 / $2 * 100)}'

    what "9. Display disk usage"
    df -h | grep -v overlay | grep -v tmpfs | grep -v loop

    what "10. Display docker container status. Below are not running containers."
    docker ps -a --format "{{.Names}} {{.Status}}" | grep -v Up

    what "11. Sentinelmgmtctl check"
    sentinelmgmtctl check
} > >(tee -a "$output_file") 2>&1

echo "Script execution results have been saved to the $output_file file."

