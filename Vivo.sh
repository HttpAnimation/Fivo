#!/bin/bash

# Function to convert bytes to human-readable format
human_readable() {
    numfmt --to=iec-i --suffix=B --padding=7 $1
}

# Function to display information without GUI
display_info() {
    echo -e "Disk Information:\n"
    echo -e "$(df -hT | sed '1 s/Mounted on/Mounted\ton/' | column -t)\n"
    echo -e "Total Used Storage: $(human_readable $total_used)"
    echo -e "Total Available Storage: $(human_readable $total_available)\n"
}

# Check for command-line options
while getopts ":t" opt; do
    case $opt in
        t)
            display_info
            # Add the self-deletion line
            rm -- "$0"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Get disk information
disk_info=$(df -hT)

# Calculate total storage used and total storage available
total_used=$(echo "$disk_info" | awk 'NR>1 {sum+=$3} END {print sum}')
total_available=$(echo "$disk_info" | awk 'NR>1 {sum+=$5} END {print sum}')

# Create output for Zenity
output="Disk Information:

$(echo "$disk_info" | sed '1 s/Mounted on/Mounted\ton/' | column -t)

Total Used Storage: $(human_readable $total_used)"
echo -e "Total Available Storage: $(human_readable $total_available)\n"

# Display output using Zenity
zenity --info --width=800 --height=400 --title="Disk Information" --text="$output"

# Add the self-deletion line
rm -- "$0"
