# Knulli-Tailscale
**Run Tailscale in knulli with Subnet and Accept Routes, tailscale starts at boot so you can access "share folder" or "ssh" service remotely**

*Knulli comes with pre-enabled ssh, login using (**username:root and password:linux**)*

**Create a temp folder**

    mkdir /userdata/temp
    cd /userdata/temp

**To find out your knulli architecture run this command**

    knulli-info | grep -oP 'Architecture:\s*\K.+'

or

    uname -m
   
**Download appropriate file as per your system architecture
details available in Knulli "SYSTEM SETTINGS > INFORMATION > ARCHITECTURE (example: armv7l or aarch64 or x86_64)**

arm/v7 or aarch32:

    wget https://pkgs.tailscale.com/stable/tailscale_1.98.4_arm.tgz

arm64/v8 or aarch64:

    wget https://pkgs.tailscale.com/stable/tailscale_1.98.4_arm64.tgz

amd64:

    wget https://pkgs.tailscale.com/stable/tailscale_1.98.4_amd64.tgz

x86 or x86_64:

    wget https://pkgs.tailscale.com/stable/tailscale_1.98.4_386.tgz

riscv64:

    wget https://pkgs.tailscale.com/stable/tailscale_1.98.4_riscv64.tgz

**Find out more packages at "Static binaries (other distros)"**

https://pkgs.tailscale.com/stable/#static



**Next step is to unarchieve the downloaded file, carefully choose the right file name**

    tar -xf <File Name>
example: tar -xf tailscale_1.98.4_arm64.tgz

    cd <File Name Directory>
example: cd tailscale_1.98.4_arm64

**Create a new directory "tailscale" in share/userdata folder**

    mkdir /userdata/tailscale

***Now move systemd, talscale and tailscaled to /userdata/tailscale***

    mv systemd /userdata/tailscale/systemd
    mv tailscale /userdata/tailscale/tailscale
    mv tailscaled /userdata/tailscale/tailscaled
    cd /userdata
    rm -rf temp

***Create service/script directory***

    mkdir /userdata/system/services
    touch /userdata/system/services/tailscale
    nano /userdata/system/services/tailscale

***Paste these line and change your network CIDR "example: --advertise-routes=192.168.1.0/24 or --advertise-routes=192.168.0.0/24 or --advertise-routes=xxx.xxx.xxx.0/xx" depends on what subnet you use***

    #!/bin/bash
    if test "$1" != "start"
    then
      exit 0
    fi
    /userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &/userdata/tailscale/tailscale up --advertise-routes=192.168.1.0/24 --snat-subnet-routes=false --accept-routes
    
# Important to specify correct CIDR

***My knulli ip address is 192.168.1.102 so my CIDR is 192.168.1.0/24***

# Making changes to system

***Creating tun, forwarding IP and saving knulli overlay to make the changes permanent***

  
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
    echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
    knulli-save-overlay

# Now Activate your TailScale

***Paste this line in ssh command***

    /userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &/userdata/tailscale/tailscale up

****If it does not give you a login link then run it again****

***Login to your tailscale with the given link and activate your knulli machine***

***Go to "Admin console" of tailscale and approve the newly added machine***

***After login check tailscale IP in your machine***

    ip a

***if you see tailscale ip then only proceed further, else you have made a mistake somewhere above***

**Now Activate Knulli Service/Script to start with booth**

    knulli-services list
    knulli-services enable tailscale
    reboot

**Wait for the machine to start and check your machine's IP**

    ip a

***you must have tailscale ip in the list***

**go to tailscale admin page and enable "subnet routes" by selecting your CIDR**

**now you can access your rom files, copy/paste/delete or ssh remotely if you have tailscale running in the remote computer/device using same tailscale account or by sharing your machine to your friends who has a tailscale account with every reboot**

