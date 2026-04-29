# POPPER

- Talks with Guacamole MariaDB and enrolls all containers into login. 

--- 

## Rundown
- `popper.py` is run in either a VENV or just by installing the pip packages on the system
- `.env` file needs to be filled out (This insecure but is just meant to run once)
- For the VM's (QEMU) to be added to guacamole two things needs to be true
    - The VMID should be abloe 1000
    - There should be a "run" tag on the VM
- For VM's (QEMU again)
    - `Qemu guest` and `spice-vdagent` additions need to be installed and also enabled in them VM configuration (This is used for just getting the IP of the machine)
    - See [This Doc](https://github.com/BiscottiMuncher/Skills2026/blob/main/docs/KALI.pdf)
    - Some VNC needs to be installed on the guest, Tiger or Tight both work (Port needs to be changed in the popper script based on the VNC chosen)
    - VNC username and password need to be put into the description of the VM "username:password"
- For Guacemole
    - This [doc](https://github.com/BiscottiMuncher/Skills2026/blob/main/docs/GUAC.pdf) and more importantly this [script](https://github.com/BiscottiMuncher/Skills2026/blob/main/guac/guac-install.sh) will set up guacamole corretly with MariaDB on the right port.

--- 

### Notes
- Built for clustered environments, unsure if it will work on a non clustered node/database :/
- Login credentials for ssh user is stored in Promxox container description (Sooo safe I know)
- MariaDB needs an access user with write permissions for guacamole_db database 

### Wishes
- Way to write users correctly and attach them to groups through script 

