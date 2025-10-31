Instalation for automated management by moonraker.

Not completed! Shall be finalized before release.
Watch out for correct locations with different debian versions/klipper versions


1. Clone GitHub repo: `git clone https://github.com/Graylag-PD/Goose-Purge-Software.git goose_purge_software`  
2. Symlink read only files `ln -sf ~/goose_purge_software/goose_purge.cfg ~/printer_data/config/goose_purge/goose_purge.cfg`  
3. Copy R/W files `cp -f ~/goose_purge_software/goose_purge_variables.cfg ~/printer_data/config/goose_purge/goose_purge_variables.cfg`  
4. Add following lines to `moonraker,conf`:  
>[update_manager goose_purge_software]  
>type: git_repo  
>primary_branch: main  
>path: ~/goose_purge_software  
>origin: https://github.com/Graylag-PD/Goose-Purge-Software.git  
>managed_services: klipper  
5. Add `[include goose_purge/goose_purge.cfg]` to `printer.cfg`
