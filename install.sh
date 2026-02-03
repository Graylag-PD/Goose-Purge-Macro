#!/bin/bash
#
echo "Goose Purge Macro installation script - installing"
echo "------------------------------------------------------------"
#

# -----------------------------
# Argument parsing
# -----------------------------
usage() {
    echo "Usage: $0 [-c|--config-dir <path>]"
    echo ""
    echo "Options:"
    echo "  -c, --config-dir   Path to Klipper configuration directory"
    echo "  -h, --help         Show this help message"
    exit 0
}

KLIPPER_CONF_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config-dir)
            if [ -z "$2" ]; then
                echo "Error: --config-dir requires a path argument"
                exit 1
            fi
            KLIPPER_CONF_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# -----------------------------
# Detect Klipper config directory
# -----------------------------
if [ -n "$KLIPPER_CONF_DIR" ]; then
    echo "Using KLIPPER_CONF_DIR from argument: $KLIPPER_CONF_DIR"
    if [ ! -d "$KLIPPER_CONF_DIR" ]; then
        echo "Error: Provided KLIPPER_CONF_DIR does not exist"
        exit 1
    fi
else
    KLIPPER_CONF_DIR="${HOME}/printer_data/config"

    if [ ! -d "$KLIPPER_CONF_DIR" ]; then
        echo "New structure folder ~/printer_data not found, looking for a legacy structure..."

        if [ -d "$HOME/klipper_config" ]; then
            KLIPPER_CONF_DIR="${HOME}/klipper_config"
        elif [ -d "$HOME/printer_config" ]; then
            KLIPPER_CONF_DIR="${HOME}/printer_config"
        else
            KLIPPER_CONF_DIR="${HOME}"
        fi
    fi
fi

echo "Configuration files will be copied to: $KLIPPER_CONF_DIR"
ln -sf $REPO_DIR/goose_purge_core.cfg $KLIPPER_CONF_DIR/goose_purge_core.cfg
echo ""

# 2 copy the configuration file
# no need to repeate the search for the correct folder
if [ -f $KLIPPER_CONF_DIR/goose_purge.cfg ]; then
	echo "User configuration file already exists and will not be overwritten"
	echo "If you would like to restore a default configuration, please delete or rename the goose_purge.cfg in the configuration folder and then run the installation script again"
else
	echo "User configuration file not found, default file will be copied to your configuration folder"
	echo "What purger type would you like to configure?"
	echo "	1 - Belt purge with DC motor"
	echo "	2 - Belt purge with Stepper motor"
	read -p "Purger type: " purger_type
	if [ $purger_type -eq 1 ]; then
		cp $REPO_DIR/goose_purge-dcmot.cfg $KLIPPER_CONF_DIR/goose_purge.cfg
	elif [ $purger_type -eq 2 ]; then
		cp $REPO_DIR/goose_purge-stpmot.cfg $KLIPPER_CONF_DIR/goose_purge.cfg
	else
		echo "Invalid selection, configuration file not copied. Copy the correct file manually or run the installation script again and select the valid value"
		echo ""
	fi
fi
echo ""

# 3 copy the python module
echo "Installing klipper module"
EXTRAS_DIR="${HOME}/klipper/klippy/extras"
# check for existence and write permissions
if [ -d $EXTRAS_DIR ]; then
    if [ -w $EXTRAS_DIR ]; then
        ln -sf $REPO_DIR/goose_purge.py $EXTRAS_DIR/goose_purge.py
    else
        # ask for sudo if we don't have write permissions
        sudo ln -sf $REPO_DIR/goose_purge.py $EXTRAS_DIR/goose_purge.py
    fi
else
    echo "Error: Klipper extras folder not found"
	echo "Installation failed"
    exit 1
fi
echo ""

# 4 add record to moonraker.cfg
echo "Configuring Moonraker update manager"

MOONRAKER_CONF_DIR="${HOME}/printer_data/config"
MOONRAKER_CONF="$MOONRAKER_CONF_DIR/moonraker.conf"
SECTION_NAME="[update_manager goose_purge]"

if [ ! -f "$MOONRAKER_CONF" ]; then
    echo "Warning: moonraker.conf not found at $MOONRAKER_CONF"
    echo "Skipping Moonraker update manager configuration"
else
    if grep -qF "$SECTION_NAME" "$MOONRAKER_CONF"; then
        echo "Update manager in moonraker.conf already set"
    else
        echo "Adding Update Manager configuration to moonraker.conf..."
        cat << EOF >> "$MOONRAKER_CONF"

$SECTION_NAME
type: git_repo
primary_branch: beta
path: ~/goose_purge_macro
origin: https://github.com/Graylag-PD/Goose-Purge-Macro.git
managed_services: klipper
EOF
    fi
fi





echo -e "\n------------------------------------------------------------"
echo "Installation script completed."
echo "Make sure to add following line to your printer.cfg:"
echo -e "\e[1;32m[include goose_purge.cfg]\e[0m"
echo "Don't forget to restart the Klipper before you can start using this macro"
echo -e "\nIn case of doubt you can run this script again at any time,"
echo "your configuration file will never get overwritten!"
echo "------------------------------------------------------------"
