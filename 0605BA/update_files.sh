#!/bin/bash

# Get the hostname
hostname=$(hostname)

# Get the last 6 characters of the hostname
last_six="${hostname: -6}"

# Function to download a file using curl and compare its sha256sum with the existing file
download_and_compare() {
    local url="$1"
    local local_file="$2"
    local temp_file="$local_file.temp"

    # Download the file
    curl -o "$temp_file" "$url" 2>/dev/null

    # Calculate the sha256sum of the downloaded file
    local downloaded_hash=$(sha256sum "$temp_file" | awk '{print $1}')

    # Calculate the sha256sum of the existing file (if it exists)
    local existing_hash=""
    if [ -e "$local_file" ]; then
        existing_hash=$(sha256sum "$local_file" | awk '{print $1}')
    fi

    # Compare hashes
    if [ "$downloaded_hash" != "$existing_hash" ]; then
        echo "Hashes differ for $local_file. Updating..."
        cp "$temp_file" "$local_file"
        updated=true
    else
        echo "Hashes match for $local_file. No update needed."
    fi

    # Clean up temp file
    rm "$temp_file" 2>/dev/null
}

# Set a flag to track if any files were updated
updated=false

# Download and compare global_conf.json
download_and_compare "https://raw.githubusercontent.com/flavioreck/gateways/main/$last_six/global_conf.json" "/user/basic_station/etc/global_conf.json"

# Download and compare tc.key
download_and_compare "https://raw.githubusercontent.com/flavioreck/gateways/main/$last_six/tc.key" "/user/basic_station/etc/tc.key"

# Download and compare tc.uri
download_and_compare "https://raw.githubusercontent.com/flavioreck/gateways/main/$last_six/tc.uri" "/user/basic_station/etc/tc.uri"

# If any files were updated, reboot the system
if [ "$updated" = true ]; then
    echo "At least one file was updated. Rebooting..."
    reboot
fi