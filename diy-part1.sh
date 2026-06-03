#!/bin/bash
set -e

# Add or replace feeds before "./scripts/feeds update -a".
# Example:
# echo "src-git custom https://github.com/yourname/openwrt-packages.git" >> feeds.conf.default

if [ ! -d package/openclash ]; then
  git clone --depth 1 https://github.com/vernesong/OpenClash.git package/openclash
fi

if [ ! -d package/luci-app-cloudflarespeedtest ]; then
  git clone --depth 1 https://github.com/stevenjoezhang/luci-app-cloudflarespeedtest.git package/luci-app-cloudflarespeedtest
fi

if [ ! -d package/luci-theme-argon ]; then
  git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
fi

if [ ! -d package/luci-app-argon-config ]; then
  git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
fi
