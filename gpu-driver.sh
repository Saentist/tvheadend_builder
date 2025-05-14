#!/bin/bash

# Vendor IDs and example Product IDs for GPUs
NVIDIA_VID="10de"
INTEL_VID="8086"
AMD_VID="1002"

# Function to update PCI IDs database
update_pci_ids() {
    echo "Updating PCI IDs database..."
    if command -v update-pciids >/dev/null 2>&1; then
        sudo update-pciids
        echo "PCI IDs database updated successfully."
    else
        echo "update-pciids command not found. Please install the pciutils package."
        sudo apt-get install -y pciutils
        sudo update-pciids
    fi
}

# Function to check for NVIDIA GPU by VID:PID
check_nvidia_gpu_by_vid_pid() {
    echo "Checking for NVIDIA GPU by hardware VID:PID..."
    if command -v lspci >/dev/null 2>&1; then
        if lspci -nn | grep -i "$NVIDIA_VID" >/dev/null 2>&1; then
            echo "NVIDIA GPU detected (VID: $NVIDIA_VID)."
            lspci -nn | grep -i "$NVIDIA_VID"
            return 0
        fi
    fi
    echo "No NVIDIA GPU detected on this system (VID: $NVIDIA_VID)."
    return 1
}

# Function to check for Intel GPU by VID:PID
check_intel_gpu_by_vid_pid() {
    echo "Checking for Intel GPU by hardware VID:PID..."
    if command -v lspci >/dev/null 2>&1; then
        if lspci -nn | grep -i "$INTEL_VID" >/dev/null 2>&1; then
            echo "Intel GPU detected (VID: $INTEL_VID)."
            lspci -nn | grep -i "$INTEL_VID"
            return 0
        fi
    fi
    echo "No Intel GPU detected on this system (VID: $INTEL_VID)."
    return 1
}

# Function to check for AMD GPU by VID:PID
check_amd_gpu_by_vid_pid() {
    echo "Checking for AMD GPU by hardware VID:PID..."
    if command -v lspci >/dev/null 2>&1; then
        if lspci -nn | grep -i "$AMD_VID" >/dev/null 2>&1; then
            echo "AMD GPU detected (VID: $AMD_VID)."
            lspci -nn | grep -i "$AMD_VID"
            return 0
        fi
    fi
    echo "No AMD GPU detected on this system (VID: $AMD_VID)."
    return 1
}

# Function to offer NVIDIA driver installation
offer_nvidia_driver_install() {
    echo "Would you like to install NVIDIA drivers? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Installing NVIDIA drivers..."
        sudo apt-get update -y
        sudo apt-get install -y nvidia-driver-530 # Replace with the correct version for your system
    else
        echo "Skipping NVIDIA driver installation."
    fi
}

# Function to offer Intel driver installation
offer_intel_driver_install() {
    echo "Would you like to install Intel GPU drivers? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Installing Intel GPU drivers..."
        sudo apt-get update -y
        sudo apt-get install -y intel-media-va-driver-non-free # Intel VAAPI driver for hardware acceleration
    else
        echo "Skipping Intel GPU driver installation."
    fi
}

# Function to offer AMD driver installation
offer_amd_driver_install() {
    echo "Would you like to install AMD GPU drivers? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Installing AMD GPU drivers..."
        sudo apt-get update -y
        sudo apt-get install -y mesa-vulkan-drivers # AMD Vulkan drivers for Linux
    else
        echo "Skipping AMD driver installation."
    fi
}

# Main script logic
main() {
    echo "Starting hardware VID:PID-based GPU detection..."

    # Update PCI IDs database
    update_pci_ids

    # NVIDIA GPU check via VID:PID
    if check_nvidia_gpu_by_vid_pid; then
        offer_nvidia_driver_install
    fi

    # Intel GPU check via VID:PID
    if check_intel_gpu_by_vid_pid; then
        offer_intel_driver_install
    fi

    # AMD GPU check via VID:PID
    if check_amd_gpu_by_vid_pid; then
        offer_amd_driver_install
    fi

    echo "GPU hardware check completed."
}

# Execute the main function
main
