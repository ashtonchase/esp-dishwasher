#!/bin/bash

# ESPHome Dishwasher Controller - Deployment Script
#
# This script helps users build and deploy the dishwasher controller

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if ESPHome is installed
check_esphome() {
    if ! command -v esphome &> /dev/null; then
        print_error "ESPHome is not installed!"
        print_info "Please install ESPHome:"
        print_info "pip install esphome"
        exit 1
    fi
    print_status "ESPHome found: $(esphome version)"
}

# Check if secrets file exists
check_secrets() {
    if [ ! -f "secrets.yaml" ]; then
        print_error "secrets.yaml not found!"
        print_info "Copy secrets.yaml.example to secrets.yaml and configure your credentials"
        cp secrets.yaml.example secrets.yaml
        print_warning "Please edit secrets.yaml with your WiFi and API credentials"
        exit 1
    fi
    print_status "secrets.yaml found"
}

# Validate configuration
validate_config() {
    print_status "Validating ESPHome configuration..."
    if esphome config dishwasher.yaml; then
        print_status "Configuration is valid!"
    else
        print_error "Configuration validation failed!"
        exit 1
    fi
}

# Build firmware
build_firmware() {
    print_status "Building firmware..."
    if esphome compile dishwasher.yaml; then
        print_status "Build successful!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Upload to device
upload_firmware() {
    local device=$1
    print_status "Uploading firmware to device: $device"
    if esphome upload dishwasher.yaml --device "$device"; then
        print_status "Upload successful!"
        print_status "Your dishwasher controller is ready!"
    else
        print_error "Upload failed!"
        print_info "Make sure your device is connected and in programming mode"
        exit 1
    fi
}

# Main menu
show_menu() {
    echo ""
    print_info "=== ESPHome Dishwasher Controller Deployment ==="
    echo "1. Validate configuration only"
    echo "2. Build firmware only"
    echo "3. Upload via USB"
    echo "4. Upload via WiFi (requires device IP)"
    echo "5. Clean build cache"
    echo "6. Exit"
    echo ""
    read -p "Choose an option [1-6]: " choice
}

# Clean build cache
clean_build() {
    print_status "Cleaning build cache..."
    esphome clean dishwasher.yaml
    print_status "Build cache cleared!"
}

# Show device info
show_info() {
    print_info "=== Device Information ==="
    print_info "Device Name: dishwasher"
    print_info "Platform: ESP32"
    print_info "I2C Address: 0x27 (PCF8574)"
    print_info "WiFi: Static IP 192.168.2.197"
    print_info "Status LED: GPIO23"
    print_info "Button: GPIO0"
}

# Main execution
main() {
    show_info
    check_esphome
    check_secrets

    while true; do
        show_menu
        case $choice in
            1)
                validate_config
                ;;
            2)
                validate_config
                build_firmware
                ;;
            3)
                validate_config
                build_firmware
                upload_firmware "/dev/ttyUSB0"
                ;;
            4)
                validate_config
                build_firmware
                read -p "Enter device IP address: " device_ip
                upload_firmware "$device_ip"
                ;;
            5)
                clean_build
                ;;
            6)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option! Please choose 1-6."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Help function
show_help() {
    print_info "=== ESPHome Dishwasher Controller Help ==="
    echo ""
    print_info "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  validate    - Validate configuration only"
    echo "  build       - Build firmware only"
    echo "  upload-usb  - Upload via USB"
    echo "  upload-wifi  - Upload via WiFi (requires IP)"
    echo "  clean       - Clean build cache"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 validate      # Validate configuration"
    echo "  $0 upload-usb    # Upload via USB"
    echo "  $0 upload-wifi    # Upload via WiFi to 192.168.2.197"
}

# Command line argument handling
if [ $# -eq 1 ]; then
    case $1 in
        "validate")
            check_esphome
            check_secrets
            validate_config
            ;;
        "build")
            check_esphome
            check_secrets
            validate_config
            build_firmware
            ;;
        "upload-usb")
            check_esphome
            check_secrets
            validate_config
            build_firmware
            upload_firmware "/dev/ttyUSB0"
            ;;
        "upload-wifi")
            check_esphome
            check_secrets
            validate_config
            build_firmware
            upload_firmware "192.168.2.197"
            ;;
        "clean")
            clean_build
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    exit 0
fi

# Run interactive menu if no arguments
main