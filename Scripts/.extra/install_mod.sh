#!/usr/bin/env bash
#|---/ /+-----------------------------------------------+---/ /|#
#|--/ /-| Script to enable early loading for nvidia drm |--/ /-|#
#|-/ /--| Prasanth Rangan                               |-/ /--|#
#|/ /---+-----------------------------------------------+/ /---|#

if [ "$(lspci -k | grep -c -A 2 -E "(VGA|3D)" | grep -i nvidia)" -gt 0 ]; then
    if [ "$(grep -c 'MODULES=' /etc/mkinitcpio.conf | grep nvidia)" -eq 0 ]; then
        sudo sed -i "/MODULES=/ s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/" /etc/mkinitcpio.conf
        sudo mkinitcpio -P
        if [ "$(grep -c 'options nvidia-drm modeset=1' /etc/modprobe.d/nvidia.conf)" -eq 0 ]; then
            echo 'options nvidia-drm modeset=1' | sudo tee -a /etc/modprobe.d/nvidia.conf
        fi
    fi
fi
