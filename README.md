# Goose Purge Macro - BETA
## About
Goose Purge Macro (GPM) is the next generation of the control macro originally intended for the Goose Belt Purger. It has been split from the GBP repository to allow for a smooth automated updating mechanism, but also to simplify further development and improve the way software configuration is documented.  
Primary use of the GPM is still the control of the Goose Belt Purger, but it can also be used to control other compatible belt purge systems.  
  
Goose Purge Macro is currently in BETA phase. It has been tested and proven to work, but as each printer is unique, you can run into any kind of issues. If you run into any issues, make sure to let us know preferably through Discord.
If you want to taste the GPM but don't want to loose your existing GBP macro configuration, fear not, as the GPM uses different filenames and will happily coexist with the old GBP macro. You just need to make sure to have either `[include goose_belt.cfg]` or `[include goose_purge.cfg]` commented out in the `printer.cfg`.  
Once the final released version of the macro gets released, you will have an option to easily migrate from BETA with the configuration preserved.  
  
A more detailed documentation is comming, but is not available yet.  
## Changes from GBP macro v0.7.3
The main upgrade over the old version is the automated installation and updating mechanism, which makes for easy upgrade path to future releases. As part of this effort, the configuration variables have been splitted from the main macro body and now reside in an independent file. A python module has also been incorporated and although it is not used yet, it is expected to be utilised with future releases.  
The second main feature is the official support of the stepper motor based purgers.  
Finally the third bigger change is an improved support for the HappyHare MMU control module.  
  
Many other smaller tweaks have been made with relatively minor impact. Here are points where the GPM behaves differently from v0.7.3  
- Macro now processes both PURGE_LENGTH and PURGE_VOLUME parameters and adds them up if both are provided.  
- Parameters LENGTH and VOLUME are no longer supported.  
- A new parameter HAPPYHARE has been introduced to instruct the macro to interface with the HappyHare. A legacy wrapper `_goose_purge_hh` remains in place for compatibility reasons, but is now discouraged to use.  
- Macro now no longer requires Z axis homed if you don't move the Z axis during purging.  
- Default values for some variables have been changed.  

## Instalation and updating
### Automated instalation.
Follow the steps below for the smoothest experience. This should work for most of the users and does most of the hard work for you, including configuring Moonraker Update manager.  
  
SSH into your printer and run following code:
```
git clone https://github.com/Graylag-PD/Goose-Purge-Macro.git goose_purge_macro
bash ~/goose_purge_macro/install.sh
```
Afterwards add `[include goose_purge.cfg]` to printer.cfg and restart the klipper.
  
Don't forget to configure the `goose_purge.cfg` file to match your setup.  

### Automated updates
Updates are managed by Moonraker and in most cases you can just hit the update button and it will take care of everything. In rare cases where bigger changes are introduced you may be asked to run the installation script again, in which case do so. 
The installation script is designed to always preserve your configuration, so don't hesitate to run it anytime.  
  
Note, that since the update mechanism does not alter your configuration file, it may happen, that the new feature gets introduced, yet you will not see the associated variables. If that happens, simply copy the variables name from docs and paste it into your configuration file.  

### Manual instalation.
For advanced users who would like to modify any of the parameters (e.g. file locations) or for less common configurations where automated script fails  
  
SSH into your printer and run following code. This will download a fresh copy of the repository. You should skip this step in case you already cloned repo before.  
```
git clone https://github.com/Graylag-PD/Goose-Purge-Macro.git goose_purge_macro  
```
  
Now you need to copy two configuration files.  
Run following command to create a symbolic link of the macro core file. This also deletes any previously existing file of this name.  
Symbolic link means this file remains in the original folder and only gets "mirrored" into the configuration folder. This ensures it gets updated automaticaly, but also provides write protection  when opened from Mainsail or Fluidd.  
```
ln -sf ~/goose_purge_macro/goose_purge_core.cfg ~/printer_data/config/goose_purge_core.cfg  
```
  
Next run following command to copy the user configuration file. Note, that this command does not overwrite any preexisting file of the same name.  
```
cp --update=none ~/goose_purge_macro/goose_purge.cfg ~/printer_data/config/goose_purge.cfg
```
Note, that you can replace source file `goose_purge.cfg` for `goose_purge-dcmot.cfg` or `goose_purge-stpmot.cfg`. Those are prefiltered configurations depending on whether you want to use DC or stepper motor. Resulting commands would like like this:  
```
cp --update=none ~/goose_purge_macro/goose_purge-dcmot.cfg ~/printer_data/config/goose_purge.cfg
```  
or  
```
cp --update=none ~/goose_purge_macro/goose_purge-stpmot.cfg ~/printer_data/config/goose_purge.cfg
```
NOTE: On some older printers (pre 2022) you may not have your configuration files in folder `~/printer_data/config/`. If this is your case, modify those commands before using them.  
  
Next step is to symlink the python module into the extras folder. Run following command:  
```
ln -sf ~/goose_purge_macro/goose_purge.py ~/klipper/klippy/extras/goose_purge.py
```
in some cases this may fail due to insufficient user privileges. If that is your case, use this instead  
```
sudo ln -sf ~/goose_purge_macro/goose_purge.py ~/klipper/klippy/extras/goose_purge.py
```
  
In the next step you are going to configure the Moonraker Update Manager for automated updating.  
Open the `moonraker.cfg` file and add following lines:  
```
[update_manager goose_purge]
type: git_repo
primary_branch: v0-dev
path: ~/goose_purge_macro
origin: https://github.com/Graylag-PD/Goose-Purge-Macro.git
managed_services: klipper
```
  
Last step is to add `[include goose_purge.cfg]` to printer.cfg and restart the klipper

### Manual update
Following commands will delete your `goose_purge_core.cfg` and create new symlink for the freshly pulled file. The `goose_purge.cfg` will be preserved if it exists and added if not.  
Run those commands if you mess up bad and it should fix everything.
```
cd ~/goose_purge_macro
git pull
bash ~/goose_purge_macro/install.sh
```

## Usage
For the most part the usage remains the same as with the old macro, so please refer to the original GBP documentation.  
Here are notable differences:  
### On the fly variables tuning 
Because the variables have been splitted from the main macro, you must now use following command to do on the fly variables changes  
```
SET_GCODE_VARIABLE MACRO=_GOOSE_PURGE_VARIABLES VARIABLE=<variable name> VALUE=<your value>  
```
The most common variables to be tuned are
```
# for DC motors
SET_GCODE_VARIABLE MACRO=_GOOSE_PURGE_VARIABLES VARIABLE=belt_pwm VALUE=your value
SET_GCODE_VARIABLE MACRO=_GOOSE_PURGE_VARIABLES VARIABLE=rtr_dwell VALUE=your value
```
and  
```
# for stepper motors
SET_GCODE_VARIABLE MACRO=_GOOSE_PURGE_VARIABLES VARIABLE=belt_speed VALUE=your value
SET_GCODE_VARIABLE MACRO=_GOOSE_PURGE_VARIABLES VARIABLE=belt_speed_dwell VALUE=your value
SET_GCODE_VARIABLE MACRO=_GOOSE_PURGE_VARIABLES VARIABLE=rtr_dwell VALUE=your value
```

### HappyHare interfacing
Previous integration with the HappyHare was not correct in some aspects and may have been causing some hard to diagnose issues. Which is why the interfacing has been changed and the new correct way of calling the macro from the HH is with the following command  
```
GOOSE_PURGE HAPPYHARE=1
```
Note, that this will cause the macro to override the initial and final deretractions to match those expected by HH, and to ignore any PURGE_LENGTH or PURGE_VOLUME parameters, should they be included.  
The old way of calling the macro through a wrapper `_goose_purge_hh` remains in place and behaves exactly the same as it did in previous releases, however the usage of this wrapper is now discouraged in favor of the new way.  
  
You should now also change your HappyHare configuration to call the purge macro from the `purge_macro:` handle (in mmu_parameters.cfg) instead of the `variable_user_post_load_extension` variable. The only thing to keep in mind is that the `purge_macro:` handle is case sensitive, so you need to watch your capitalization.  

## FAQ
### Can I automaticaly migrate my GBP macro v0.7.3 to GPM?
Unfortunately not and you will likely have to manually transfer all you variable values. Most if not all variables have kept their name so it is pretty simple to search for corresponding variables.  

### What if I am an advanced user and I want to modify the main macro myself?
You have several options:  
#### Quick and dirty
Copy the `goose_purge_core.cfg` into the config folder. You can use following command:
```
cp -f ~/goose_purge_macro/goose_purge_core.cfg ~/printer_data/config/goose_purge_core.cfg
```
Note, that this will disable the updating mechanism. Moonraker will still pull newest files and show the macro to be updated, however your file in config folder will not be changed  

#### Advanced
Edit directly the `~/goose_purge_macro/goose_purge_core.cfg` This will probably cause Moonraker to mark it as dirty and may or may not allow you to update, however if you do update (either through Moonraker or directly by SSH (see above)), 
git should correctly merge any incomming changes into your files. Probably.

#### Methodical
Create a github fork of this repo, do any kind of changes you like and redirect the Moonraker to your new repo instead.

## Credits
The Goose Purge Macro has been made by Graylag and Dragi2k.
