# OpenWrt GitHub Actions 自动编译

这个仓库用于每天自动编译 OpenWrt 固件。当前先保留 3 个目标：x86/64、NanoPi R2S、斐讯 N1。官方支持的设备直接从 OpenWrt 源码编译；斐讯 N1 使用 `ophub/amlogic-s9xxx-openwrt` 基于 `armsr/armv8` rootfs 二次打包。

刷写和首次启动步骤见：[固件使用说明](USAGE.md)。

## 默认设置

- 作者标识：`Duan`
- OpenWrt 分支：`openwrt-25.12`
- 自动编译时间：每天北京时间 04:10
- 固件产物：编译完成后自动发布到 GitHub Releases，同时保留 GitHub Actions artifact 14 天
- rootfs 分区：默认 4GB，适合 OpenClash + Docker + 主路由插件
- x86 输出格式：erofs、ext4、squashfs、gzip、EFI/GRUB、ISO、VDI、VMDK、VHDX
- 可写层扩容：首次启动时自动把系统盘剩余空间创建为 Btrfs 第 3 分区，并配置为 `/overlay` extroot
- 数据目录：`/mnt/data` 会指向扩容后的 Btrfs 空间，Docker 默认目录为 `/mnt/data/docker`
- 默认后台地址：`10.0.0.1`
- 默认登录：用户 `root`，密码 `root`，首次进入后台后建议立即修改
- 默认包含：LuCI、HTTPS Web UI、中文语言包、软件包管理页面
- 当前额外包含：OpenClash、Docker、Dockerman、WireGuard、DDNS、SQM、irqbalance、banIP、mwan3、USB/EXT4、Btrfs/F2FS/XFS、自动 Btrfs extroot 扩容、诊断工具

## 当前编译设备

- x86/64 generic
- FriendlyARM NanoPi R2S
- Phicomm N1，板型代码：`s905d`

## 当前包含插件

- 中文 LuCI：`luci-i18n-base-zh-cn`、`luci-i18n-firewall-zh-cn`、`luci-i18n-opkg-zh-cn`
- OpenClash：`luci-app-openclash`
- WireGuard：`luci-app-wireguard`、`luci-i18n-wireguard-zh-cn`、`kmod-wireguard`、`wireguard-tools`
- DDNS：`luci-app-ddns`、`luci-i18n-ddns-zh-cn`、`ddns-scripts`、`ddns-scripts-cloudflare`、`ddns-scripts-services`
- SQM QoS：`sqm-scripts`、`luci-app-sqm`、`luci-i18n-sqm-zh-cn`
- 多核中断均衡：`irqbalance`、`luci-app-irqbalance`
- 安全拦截：`banip`、`luci-app-banip`、`luci-i18n-banip-zh-cn`
- 多 WAN：`mwan3`、`luci-app-mwan3`、`luci-i18n-mwan3-zh-cn`，默认禁用服务
- Docker：`docker`、`dockerd`、`docker-compose`
- Docker 管理页面：`luci-app-dockerman`、`luci-i18n-dockerman-zh-cn`
- 更新文件系统：`kmod-fs-btrfs`、`btrfs-progs`、`parted`、`kmod-fs-f2fs`、`f2fs-tools`、`kmod-fs-xfs`、`xfs-mkfs`、`xfs-fsck`、`xfs-growfs`、`xfs-admin`
- 自动扩容：如果刷入设备容量大于 4GB 系统镜像，首次启动会尝试把剩余空间创建为第 3 分区，格式化为 Btrfs，复制当前 `/overlay`，并配置为 extroot；重启一次后，后续安装插件、OpenClash 数据、配置和 Docker 数据都会使用扩容后的空间
- 诊断工具：`curl`、`htop`、`iperf3`、`tcpdump`、`wget-ssl`

## 上传到 GitHub

1. 打开新建好的 GitHub 仓库。
2. 点击 `uploading an existing file`。
3. 上传本目录里的所有文件，必须包含隐藏目录 `.github`。
4. 提交后打开 `Actions` 页面。
5. 选择 `Build OpenWrt Multi Device`。
6. 点击 `Run workflow`，可以选择是否编译官方设备和 N1。

## 修改设备列表

编辑：

```text
.github/workflows/build-openwrt-multi.yml
```

在 `strategy.matrix.include` 里新增或删除设备。每个官方设备需要这几个字段：

```yaml
- name: device-name
  target: ramips
  subtarget: mt7621
  profile: xiaomi_mi-router-4a-gigabit
  extra_seed: configs/router.seed
```

## 修改软件包

- 所有设备通用软件包：`configs/common.seed`
- 普通路由器额外软件包：`configs/router.seed`
- SBC 额外软件包：`configs/sbc.seed`
- x86 额外软件包：`configs/x86.seed`
- N1 rootfs 额外设置：`configs/amlogic-rootfs.seed`

小闪存路由器容易因为软件包过多导致镜像超出分区大小。如果某个设备编译失败，先减少 `configs/common.seed` 或 `configs/router.seed` 里的包。

## 自定义脚本

- `diy-part1.sh`：在更新 feeds 前执行，用来添加第三方 feeds。
- `diy-part2.sh`：在 `make defconfig` 前执行，用来修改源码、默认 IP、主机名等。
- `files/`：OpenWrt rootfs 覆盖目录，里面的文件会进入固件。

## 下载固件

编译完成后，优先进入仓库右侧或顶部的 `Releases` 下载。每次运行会创建一个类似下面的 Release：

```text
Duan-OpenWrt-openwrt-25.12-运行编号
```

Release 里会包含每个设备对应的 zip 资产：

```text
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号
Duan-OpenWrt-nanopi-r2s-openwrt-25.12-运行编号
Duan-OpenWrt-phicomm-n1-openwrt-25.12-运行编号
SHA256SUMS.txt
```

每个设备 zip 内会包含：

- `BUILD_INFO.txt`：作者、设备、默认地址、默认登录、分区大小和构建时间
- `SHA256SUMS.txt`：顶层校验文件，方便刷写前核对固件是否完整
- 设备对应的固件文件，具体格式由 OpenWrt 目标自动生成

不同设备的刷机方式不同，刷写前务必确认文件名里的设备型号和自己的硬件完全一致。

更详细的写盘、升级、首次启动和自动扩容说明见：[固件使用说明](USAGE.md)。
