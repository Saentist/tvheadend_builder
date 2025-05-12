#!/bin/bash

# Dependency groups
declare -A DEPENDENCY_GROUPS=(
    [Build_Tools]="git make gcc g++ autoconf automake pkg-config cmake libtool"
    [Multimedia_Libraries]="ffmpeg libva-dev libvdpau-dev libx264-dev libx265-dev libvpx-dev"
    [GPU_Drivers]="nvidia-smi lscpu mesa-utils vulkan-tools"
)

# Function to check if a dependency is installed
check_dependency() {
    local dependency=$1
    if command -v "$dependency" >/dev/null 2>&1; then
        echo "$dependency is already installed."
    else
        echo "$dependency is not installed."
        return 1
    fi
}

# Function to install missing dependencies
install_dependency() {
    local dependency=$1
    echo "Attempting to install $dependency..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y && sudo apt-get install -y "$dependency"
    else
        echo "Error: This script is intended for Debian/Ubuntu systems with apt-get."
        exit 1
    fi
}

# Function to display groups and let the user select one or more
select_dependency_groups() {
    echo "Available dependency groups:"
    local index=1
    local group_keys=()
    for group in "${!DEPENDENCY_GROUPS[@]}"; do
        echo "$index) $group"
        group_keys+=("$group")
        ((index++))
    done

    echo ""
    echo "Enter the numbers of the groups you want to check (e.g., 1 3), or type 'all' to check all groups:"
    read -r selection

    SELECTED_GROUPS=()
    if [ "$selection" = "all" ]; then
        SELECTED_GROUPS=("${group_keys[@]}")
    else
        for num in $selection; do
            if ((num >= 1 && num <= ${#group_keys[@]})); then
                SELECTED_GROUPS+=("${group_keys[$((num-1))]}")
            else
                echo "Invalid selection: $num. Skipping."
            fi
        done
    fi
}

# Function to check and install dependencies for selected groups
check_and_install_dependencies() {
    echo "Checking for selected dependency groups..."
    for group in "${SELECTED_GROUPS[@]}"; do
        echo "Processing group: $group"
        dependencies=(${DEPENDENCY_GROUPS[$group]})
        for dependency in "${dependencies[@]}"; do
            if ! check_dependency "$dependency"; then
                echo "Do you want to install $dependency? (y/n)"
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    install_dependency "$dependency"


