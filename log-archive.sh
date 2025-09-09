#!/bin/bash

prompt_for_input()
{
    read -r -p "$1 [$2]: " input
    echo "${input:-2}"
}

while true; do
    echo "1. Specify Log Directory"
    echo "2. Specify how many days to keep logs"
    echo "3. Specify how many days to keep backup archives"
    echo "4. Run Log Archiving Process"
    echo "5. Exit"
    echo ""

    read -r -p "Choose an option [1-5]: " choice
    case $choice in
        1)
            log_dir=$(prompt_for_input "Enter the log directory" "/var/log")
            if [ ! -d "$log_dir" ]; then
                echo "Error: Log directory does not exist!"
                log_dir=""
            else
                echo "Log directory set to $log_dir"
            fi
            ;;
        2)
            days_to_keep_logs=$(prompt_for_input "How many days of logs do you want to keep?" "7")
            echo "Logs older than $days_to_keep_logs days will be archived."
            ;;
        3)
            days_to_keep_backups=$(prompt_for_input "How many days of backup archives do you want to keep?" "30")
            echo "Backup archives older than $days_to_keep_backups days will be deleted."
            ;;
        4)
            if [ -z "$log_dir" ]; then
                echo "Error: Log directory is not set. Please set it first"
            else
                archive_dir="$log_dir/archive"
                mkdir -p "$archive_dir"

                timestamp=$(date +"%Y%m%d_%H%M%S")
                archive_file="$archive_dir/logs_archive_$timestamp.tar.gz"

                find "$log_dir" -type f -mtime +$days_to_keep_logs -print0 | tar -czvf "$archive_file" --null -T -

                echo "Logs archived in $archive_file on $(date)" >> "$archive_dir/archive_log.txt"

                find "$log_dir" -type f -mtime +$days_to_keep_logs -exec rm -f {} \;

                echo "Archiving completed: $archive_file"

                find "$archive_dir" -type f -name "*.tar.gz" -mtime +$days_to_keep_backups -exec rm -f {} \;
                
                echo "Backup archives older than $days_to_keep_backups days have been deleted."

            fi
            ;;
        5)
            echo "Exiting...."
            break
            ;;
        *)
            echo "Invalid option. Please choose a number between 1 and 5."
            ;;
        
    esac
done
