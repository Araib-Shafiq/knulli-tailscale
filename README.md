# Knulli-Tailscale....

**Access you knulli machine from anywhere in the world or use it as a vpn server.**

**Run Tailscale in knulli with Subnet, Accept Routes and Exit node. Tailscale starts at boot.**

***Step 1: Login into your knulli machine via ssh.***

*Knulli comes with pre-enabled ssh, login using (**username:root and password:linux**).*

***Step 2: run this script for auto-installation.***

*This script will auto select your machine's **architecture** to download specific tailscale files and your **subnet/cidr** so you can access other machines if you route them to your knulli machine.*

***If you want only subnet to then use below script.***

    curl -L https://raw.githubusercontent.com/codecs02-marcher/knulli-tailscale/refs/heads/main/install.sh | bash

***If you want exit node and subnet to then use this script.***

    curl -L https://raw.githubusercontent.com/codecs02-marcher/knulli-tailscale/refs/heads/main/install_exit_node.sh | bash

***If you want exit node and without accept routes then use this script.***

    curl -L  https://raw.githubusercontent.com/codecs02-marcher/knulli-tailscale/refs/heads/main/install_exit_node_without_accept_routes.sh | bash

***Step 3: Login to your tailscale with the given link and activate your knulli machine.***

***Step 4: Go to "Admin console" of tailscale and approve the newly added machine.***

***After Approval check tailscale IP in your machine.***

    ip a

*you must have tailscale ip in the list*

***Refresh tailscale admin console page and you'll find **subnet**(script 1) and **exit node**(script2) waiting to be approved, approve them as per your liking.***

*You should also disable **key expiry** using tailscale admin console in **machine settings**.*

*now you can access your rom files, copy/paste/delete, ssh, route your entire network or use your knulli machine as a vpn server when you are out if you have tailscale running in the remote computer/device using same tailscale account or by sharing your machine to your friends who has a tailscale account with every reboot.*

**Whenever you feel like you want to keep tailscale logged in but don't really wanna use it for now.**

***To stop tailscale.***

    knulli-services stop tailscale

***To start tailscale.***
    
    knulli-services start tailscale
    
***To disable tailscale at boot.***
    
    knulli-services disable tailscale

***To re-enable tailscale at boot.***
    
    knulli-services enable tailscale
