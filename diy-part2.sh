#!/bin/bash
set -e

# Apply source tree customizations after feeds are installed and before "make defconfig".
# Example: change the default LAN IP.
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
