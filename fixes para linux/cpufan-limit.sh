#!/bin/bash

# Function to set fan speed
function set_fan_speed() {
    # Insert your commands here to set the fan speed
    # Use 'fancontrol' or any other preferred method
    # Make sure the commands are appropriate for your hardware configuration.
    # For example: 'fancontrol --pwm 1,128'
    echo "Setting fan speed to $1"
}

# Function to get CPU temperature in Celsius using coretemp
function get_cpu_temperature() {
    # Use 'sensors' command with 'coretemp' label to get CPU temperature
    cpu_temp=$(sensors coretemp-isa-0000 | grep 'Core 0' | awk '{print $3}' | cut -c2-3)
    echo "$cpu_temp"
}

# Fan speed configuration
MIN_FREQ=1.0    # Minimum frequency in GHz to decrease fan speed
MAX_FREQ=3.0    # Maximum frequency in GHz to maintain low fan speed
MIN_SPEED=30    # Minimum fan speed (adjust as needed)
MAX_SPEED=80   # Maximum fan speed (adjust as needed)
NORMAL_TEMP=45  # Normal CPU temperature in Celsius
MAX_TEMP=60     # Maximum allowed CPU temperature in Celsius

# Infinite loop to monitor and adjust fan speed
while true; do
    cpu_temp=$(get_cpu_temperature)

    if (( $(echo "$cpu_temp > $MAX_TEMP" | bc -l) )); then
        # If temperature is higher than the maximum allowed, set fan speed to maximum
        set_fan_speed "$MAX_SPEED"
    elif (( $(echo "$cpu_temp > $NORMAL_TEMP" | bc -l) )); then
        # If temperature is between normal and maximum allowed, adjust fan speed
        # to gradually increase the fan speed
        diff_temp=$((cpu_temp - NORMAL_TEMP))
        temp_range=$((MAX_TEMP - NORMAL_TEMP))
        speed=$((MIN_SPEED + diff_temp * (MAX_SPEED - MIN_SPEED) / temp_range))
        set_fan_speed "$speed"
    else
        # If temperature is normal, set the calculated fan speed for the frequency
        set_fan_speed "$MIN_SPEED"
    fi

    sleep 10  # Wait for 10 seconds before checking temperature again
done
