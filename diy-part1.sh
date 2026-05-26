#!/bin/bash
set -e

# Add or replace feeds before "./scripts/feeds update -a".
# Example:
# echo "src-git custom https://github.com/yourname/openwrt-packages.git" >> feeds.conf.default

if [ ! -d package/openclash ]; then
  git clone --depth 1 https://github.com/vernesong/OpenClash.git package/openclash
fi
