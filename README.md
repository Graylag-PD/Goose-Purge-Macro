# Instalation for automated management by moonraker.

```
git clone https://github.com/Graylag-PD/Goose-Purge-Macro.git goose_purge_macro
ln -sf ~/goose_purge_macro/goose_purge.cfg ~/printer_data/config/goose_purge.cfg
cp --update=none ~/goose_purge_macro/goose_purge_config.cfg ~/printer_data/config/goose_purge_config.cfg
```

Add following lines to moonraker.conf:
```
[update_manager goose_purge_macro]
type: git_repo
primary_branch: main
path: ~/goose_purge_macro
origin: https://github.com/Graylag-PD/Goose-Purge-Macro.git
managed_services: klipper
```

Add `[include goose_purge/goose_purge.cfg]` to printer.cfg

# Manual update
Following commands will delete your `goose_purge.cfg` and create new symlink for the freshly pulled file. The `goose_purge_config.cfg` will be preserved if exists and added if not.  
Run those commands if you mess up bad and it should fix everything.
```
cd ~/goose_purge_macro
git pull
ln -sf ~/goose_purge_macro/goose_purge.cfg ~/printer_data/config/goose_purge.cfg
cp --update=none ~/goose_purge_macro/goose_purge_config.cfg ~/printer_data/config/goose_purge_config.cfg
```

# What if I am an advanced user and I want to modify the main macro myself?
You have several options:  
## Quick and dirty
Copy the `goose_purge.cfg` into the config folder. You can use following command:
```
sudo cp -f ~/goose_purge_macro/goose_purge.cfg ~/printer_data/config/goose_purge/goose_purge.cfg
```
Note, that this will disable the updating mechanism. Moonraker will still pull newest files and show the macro to be updated, however your file in config folder will not be changed  

## Advanced
Edit directly the `~/goose_purge_macro/goose_purge.cfg` This will probably cause Moonraker to mark it as dirty and may or may not allow you to update, however if you do update (either through Moonraker or directly by SSH (see above)), 
git should correctly merge any incomming changes into your files. Probably.

## Methodical
Create a github fork of this repo, do any kind of changes you like and redirect the Moonraker to your new repo instead.
