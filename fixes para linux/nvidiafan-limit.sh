#!/bin/bash

# Function to set fan speed
function set_fan_speed() {
    # Insert your commands here to set the fan speed
    # Use 'nvidia-settings' or any other preferred method
    # Make sure the commands are appropriate for your hardware configuration.
    # For example: 'nvidia-settings -a [gpu:0]/GPUFanControlState=1 -a [fan:0]/GPUTargetFanSpeed=$1'
    echo "Setting fan speed to $1%"
}

# Function to get GPU temperature in Celsius using nvidia-smi
function get_gpu_temperature() {
    # Use 'nvidia-smi' command to get GPU temperature
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    echo "$gpu_temp"
}

# Enable GPU fan control
sudo nvidia-settings -a "[gpu:0]/GPUFanControlState=1"

# Fan speed configuration
MIN_TEMP_OFF=45   # Minimum temperature in Celsius to set fan speed to 0%
MAX_TEMP_OFF=50   # Maximum temperature in Celsius to set fan speed to 0%
MIN_TEMP_ON=51    # Minimum temperature in Celsius to set fan speed to 41%
MAX_TEMP_ON=70    # Maximum temperature in Celsius to set fan speed to 70%
MIN_SPEED=15      # Minimum fan speed (15%)
MAX_SPEED=70      # Maximum fan speed (70%)

# Calculate the range and speed difference
temp_range=$((MAX_TEMP_ON - MIN_TEMP_ON))
speed_diff=$((MAX_SPEED - MIN_SPEED))

# Infinite loop to monitor and adjust fan speed
while true; do
    gpu_temp=$(get_gpu_temperature)

    # Check if GPU fan control is enabled
    fan_control_state=$(nvidia-settings -q [gpu:0]/GPUFanControlState -t)
    if [ "$fan_control_state" = "1" ]; then
        if (( gpu_temp >= MAX_TEMP_ON )); then
            # If temperature is higher than or equal to the maximum allowed, set fan speed to 70%
            set_fan_speed "$MAX_SPEED"
        elif (( gpu_temp >= MIN_TEMP_ON )); then
            # If temperature is between the minimum and maximum allowed, adjust fan speed
            diff_temp=$((gpu_temp - MIN_TEMP_ON))
            speed=$((MIN_SPEED + diff_temp * speed_diff / temp_range))
            set_fan_speed "$speed"
        elif (( gpu_temp >= MIN_TEMP_OFF )); then
            # If temperature is between the minimum and maximum for turning off, set fan speed to 0%
            set_fan_speed "0"
        else
            # If temperature is below the minimum for turning off, set fan speed to 15%
            set_fan_speed "$MIN_SPEED"
        fi
    fi

    sleep 10  # Wait for 10 seconds before checking temperature again
done
