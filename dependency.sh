#!/bin/bash

# Dependency groups
declare -A DEPENDENCY_GROUPS=(
    [Build_Tools]="git make gcc g++ autoconf automake pkg-config cmake libtool"
    [Multimedia_Libraries]="ffmpeg libva-dev libvdpau-dev libx264-dev libx265-dev libvpx-dev"
    [GPU_Drivers]="nvidia-smi lscpu mesa-utils vulkan-tools"
)

LOG_FILE="dependency_install.log"
DRY_RUN=false

# Ensure the script is run with root privileges
check_root_permissions() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root. Use sudo."
        exit 1
    fi
}

# Trap for handling script interruption
trap "echo 'Script interrupted. Exiting...'; exit 1" SIGINT SIGTERM

# Logging setup
setup_logging() {
    exec > >(tee -a "$LOG_FILE") 2>&1
}

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
install_dependencies() {
    local dependencies=("$@")
    echo "Attempting to install: ${dependencies[*]}..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y
        sudo apt-get install -y "${dependencies[@]}"
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
            if [[ "$num" =~ ^[0-9]+$ ]] && ((num >= 1 && num <= ${#group_keys[@]})); then
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
    missing_dependencies=()
    for group in "${SELECTED_GROUPS[@]}"; do
        echo "Processing group: $group"
        dependencies=(${DEPENDENCY_GROUPS[$group]})
        for dependency in "${dependencies[@]}"; do
            if ! check_dependency "$dependency"; then
                missing_dependencies+=("$dependency")
            fi
        done
    done

    if [ "${#missing_dependencies[@]}" -eq 0 ]; then
        echo "All dependencies are already installed."
    else
        echo "Missing dependencies: ${missing_dependencies[*]}"
        if [ "$DRY_RUN" = true ]; then
            echo "Dry run mode: Skipping installation."
        else
            echo "Do you want to install the missing dependencies? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                install_dependencies "${missing_dependencies[@]}"
            else
                echo "Skipping installation."
            fi
        fi
    fi
}

# Main script execution
main() {
    check_root_permissions
    setup_logging
    select_dependency_groups
    check_and_install_dependencies
}

main
