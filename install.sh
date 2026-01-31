#!/bin/bash

echo "Goose Purge Macro installation script - installing"
cd ~
ln -sf ~/goose_purge_macro/goose_purge_core.cfg ~/printer_data/config/goose_purge_core.cfg
ln -sf ~/goose_purge_macro/goose_purge.py ~/klipper/klippy/extra/goose_purge.py
if [ -f ~/printer_data/config/goose_purge.cfg ]; then
	echo "Configuration file already exists and will not be overwritten"
	echo "If you would like to restore a default configuration, please delete or rename the goose_purge.cfg in the configuration folder and then run the installation script again"
else
	echo "Configuration file not found, default file will be copied to your configuration folder"
	echo "What purger type would you like to configure?"
	echo "	1 - Belt purge with DC motor"
	echo "	2 - Belt purge with Stepper motor"
	read -p "Purger type: " purger_type
	if [purger_type -eq 1]; then
		cp --update=none ~/goose_purge_macro/goose_purge(dcmot).cfg ~/printer_data/config/goose_purge.cfg
	elif [purger_type -eq 2]; then
		cp --update=none ~/goose_purge_macro/goose_purge(stpmot).cfg ~/printer_data/config/goose_purge.cfg
	else
		echo "Invalid selection, configuration file not copied. Copy the correct file manually or run the installation script again and select the valid value"
	fi
fi
echo "Installation script completed. In case of doubt you can run it again at any time, your configuration file will never get overwritten!"
echo "Don't forget to restart the Klipper before you can start using this macro"