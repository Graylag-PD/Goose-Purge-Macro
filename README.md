# Automated instalation with an update management by moonraker.

SSH into your printer and run following code
```
git clone https://github.com/Graylag-PD/Goose-Purge-Macro.git goose_purge_macro
bash ~/goose_purge_macro/install.sh
```

Afterwards add `[include goose_purge/goose_purge.cfg]` to printer.cfg and restart the klipper

# Manual instalation.
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
  
Last step is to add `[include goose_purge/goose_purge.cfg]` to printer.cfg and restart the klipper

# Manual update
Following commands will delete your `goose_purge_core.cfg` and create new symlink for the freshly pulled file. The `goose_purge.cfg` will be preserved if exists and added if not.  
Run those commands if you mess up bad and it should fix everything.
```
cd ~/goose_purge_macro
git pull
bash ~/goose_purge_macro/install.sh
```

# What if I am an advanced user and I want to modify the main macro myself?
You have several options:  
## Quick and dirty
Copy the `goose_purge.cfg` into the config folder. You can use following command:
```
cp -f ~/goose_purge_macro/goose_purge_core.cfg ~/printer_data/config/goose_purge_core.cfg
```
Note, that this will disable the updating mechanism. Moonraker will still pull newest files and show the macro to be updated, however your file in config folder will not be changed  

## Advanced
Edit directly the `~/goose_purge_macro/goose_purge_core.cfg` This will probably cause Moonraker to mark it as dirty and may or may not allow you to update, however if you do update (either through Moonraker or directly by SSH (see above)), 
git should correctly merge any incomming changes into your files. Probably.

## Methodical
Create a github fork of this repo, do any kind of changes you like and redirect the Moonraker to your new repo instead.
