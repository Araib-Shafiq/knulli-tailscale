#!/bin/bash

case "$1" in
    start)
        # This will Start Tailscale on boot
        knulli-services start tailscale

        # Restart logic: Loop to check time
        (
            while true; do
                current_day=$(date +%u)  # Get current day (1=Monday, 2=Tuesday, ..., 7=Sunday)
                current_time=$(date +%H:%M)  # Get current time HH:MM

                if [[ "$current_day" -eq 2 && "$current_time" == "05:30" ]]; then
                    echo "Scheduled restart at $current_time on Tuesday"
                    /sbin/reboot
                fi

                sleep 60  # Check every minute
            done
        ) &
        ;;
    stop)
        ;;
esac
