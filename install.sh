#!/bin/bash
#
echo "Goose Purge Macro installation script - installing"
echo "------------------------------------------------------------"
#
echo "Installing configuration files"
KLIPPER_CONF_DIR="${HOME}/printer_data/config"
# check for folder location
if [ ! -d "$KLIPPER_CONF_DIR" ]; then
    echo "New structure folder ~/printer_data not found, looking for a legacy structure..."
    
    # locations to be checked
    if [ -d $HOME/klipper_config ]; then
        KLIPPER_CONF_DIR="${HOME}/klipper_config"
    elif [ -d $HOME/printer_config ]; then
        KLIPPER_CONF_DIR="${HOME}/printer_config"
    else
        KLIPPER_CONF_DIR="${HOME}"
    fi
fi
echo "Configuration files will be copied to: $KLIPPER_CONF_DIR"
ln -sf goose_purge_core.cfg $KLIPPER_CONF_DIR/goose_purge_core.cfg
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
		cp --update=none goose_purge-dcmot.cfg $KLIPPER_CONF_DIR/goose_purge.cfg
	elif [ $purger_type -eq 2 ]; then
		cp --update=none goose_purge-stpmot.cfg $KLIPPER_CONF_DIR/goose_purge.cfg
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
        ln -sf goose_purge.py $EXTRAS_DIR/goose_purge.py
    else
        # ask for sudo if we don't have write permissions
        sudo ln -sf goose_purge.py $EXTRAS_DIR/goose_purge.py
    fi
else
    echo "Error: Klipper extras folder not found"
	echo "Installation failed"
    exit 1
fi
echo ""

# 4 add record to moonraker.cfg
echo "Configuring Moonraker update manager"
MOONRAKER_CONF="$KLIPPER_CONF_DIR/moonraker.conf"
SECTION_NAME="[update_manager goose_purge]"

if grep -qF "$SECTION_NAME" "$MOONRAKER_CONF"; then
    echo "Update manager in moonraker.conf already set"
else
    echo "Adding Update Manager configuration to moonraker.conf..."
    cat << EOF >> "$MOONRAKER_CONF"

$SECTION_NAME
type: git_repo
primary_branch: v0-dev
path: ~/goose_purge_macro
origin: https://github.com/Graylag-PD/Goose-Purge-Macro.git
managed_services: klipper
EOF
fi






echo -e "\n------------------------------------------------------------"
echo "Installation script completed."
echo "Make sure to add following line to your printer.cfg:"
echo -e "\e[1;32m[include goose_purge.cfg]\e[0m"
echo "Don't forget to restart the Klipper before you can start using this macro"
echo -e "\nIn case of doubt you can run this script again at any time,"
echo "your configuration file will never get overwritten!"
echo "------------------------------------------------------------"