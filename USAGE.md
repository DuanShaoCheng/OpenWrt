# 固件使用说明

本文说明如何下载、校验、选择和刷写本仓库自动编译出来的 OpenWrt 固件。

## 1. 下载位置

打开仓库页面，进入 `Releases`，选择最新的 Release。Release 名称类似：

```text
Duan-OpenWrt-openwrt-25.12-运行编号
```

Release 里会直接列出固件文件，不再按设备打成一个大 zip。常见文件名类似：

```text
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号-openwrt-x86-64-generic-squashfs-combined-efi.img.gz
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号-openwrt-x86-64-generic-squashfs-combined.img.gz
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号-openwrt-x86-64-generic-squashfs-combined-efi.vmdk
Duan-OpenWrt-nanopi-r2s-openwrt-25.12-运行编号-openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz
Duan-OpenWrt-phicomm-n1-openwrt-25.12-运行编号-ophub打包文件名.img.gz
README_RELEASE_ASSETS.txt
SHA256SUMS.txt
```

不要下载 GitHub 自动生成的 `Source code.zip` 或 `Source code.tar.gz`，那只是源码压缩包，不是可刷写固件。

## 2. 文件怎么选

x86/64 软路由：

| 文件特征 | 用途 |
| --- | --- |
| `combined-efi.img.gz` | UEFI 启动的物理软路由，优先推荐 |
| `combined.img.gz` | Legacy BIOS 启动的物理软路由 |
| `.vmdk` | VMware、ESXi |
| `.vdi` | VirtualBox |
| `.vhdx` | Hyper-V |
| `.iso` | 测试或临时启动 |
| `rootfs.img.gz` | 高级用户手工分区 |

NanoPi R2S：

- 首次写卡通常选择文件名包含 `nanopi-r2s` 的 `.img.gz`。
- 已经运行 OpenWrt 时，通常选择 `sysupgrade.img.gz` 在后台升级。

斐讯 N1：

- 选择 `phicomm-n1` 对应的 ophub `.img.gz`。
- 先从 U 盘启动确认正常，再考虑写入 eMMC。

## 3. 大文件分卷

GitHub Release 单个附件不能超过 2GB。为了避免发布失败，超过约 1.9GB 的文件会自动拆分：

```text
原文件名.part-000
原文件名.part-001
原文件名.part-002
```

下载所有分卷后，先合并再使用。合并后的文件名就是去掉 `.part-000` 这一段后的原文件名。

Linux/macOS：

```sh
cat FILENAME.part-* > FILENAME
```

Windows PowerShell：

```powershell
$parts = Get-ChildItem "FILENAME.part-*" | Sort-Object Name
$out = [IO.File]::Create("FILENAME")
foreach ($part in $parts) {
  $in = [IO.File]::OpenRead($part.FullName)
  $in.CopyTo($out)
  $in.Close()
}
$out.Close()
```

## 4. 校验文件

下载后建议校验 SHA256。Release 里的 `SHA256SUMS.txt` 是顶层校验文件。

Windows PowerShell：

```powershell
Get-FileHash .\固件文件名 -Algorithm SHA256
```

Linux/macOS：

```sh
sha256sum 固件文件名
```

如果文件是分卷，先合并，再校验合并后的完整文件。

## 5. 默认登录

刷入并启动后：

```text
后台地址：http://10.0.0.1
用户名：root
密码：root
```

首次进入后台后建议立即修改密码：

```text
系统 -> 管理权
```

如果电脑没有自动获取到地址，可以临时设置电脑网卡：

```text
IP：10.0.0.2
掩码：255.255.255.0
网关：10.0.0.1
```

## 6. x86/64 刷写

写入物理硬盘、SSD 或 U 盘：

1. 下载 `combined-efi.img.gz` 或 `combined.img.gz`。
2. UEFI 机器优先用 `combined-efi.img.gz`。
3. Legacy BIOS 机器使用 `combined.img.gz`。
4. 使用 balenaEtcher、Rufus、USBImager 等工具写入目标盘。
5. 如果写盘工具不识别 `.img.gz`，先用 7-Zip 解压成 `.img` 再写入。
6. 写入会清空目标盘，务必确认磁盘没有选错。
7. 从目标盘启动软路由。
8. 访问 `http://10.0.0.1`。
9. 首次启动后等待 1 到 3 分钟，再重启一次，让自动扩容生效。

虚拟机：

| 平台 | 推荐文件 |
| --- | --- |
| VMware、ESXi | `.vmdk` |
| VirtualBox | `.vdi` |
| Hyper-V | `.vhdx` |

如果虚拟机启动后没有网络，优先检查虚拟网卡类型和桥接/旁路由网络配置。

## 7. NanoPi R2S 刷写

首次刷入 TF 卡：

1. 下载 `nanopi-r2s` 对应的 `.img.gz`。
2. 使用 balenaEtcher、Rufus、USBImager 写入 TF 卡。
3. 如果写盘工具不识别 `.img.gz`，先用 7-Zip 解压成 `.img` 再写入。
4. 插入 R2S 启动。
5. 电脑连接 LAN 口，访问 `http://10.0.0.1`。
6. 首次启动后等待 1 到 3 分钟，再重启一次。

已经运行 OpenWrt 时，可以在后台升级：

```text
系统 -> 备份/升级 -> 刷写新的固件
```

升级前建议备份配置。跨大版本升级或遇到异常时，建议取消保留配置后重新设置。

## 8. 斐讯 N1 刷写

一般流程：

1. 下载 `phicomm-n1` 对应的 ophub `.img.gz`。
2. 使用 balenaEtcher、Rufus、USBImager 写入 U 盘。
3. 如果写盘工具不识别 `.img.gz`，先用 7-Zip 解压成 `.img` 再写入。
4. N1 从 U 盘启动 OpenWrt。
5. 电脑连接同一网络，访问 `http://10.0.0.1`。
6. 确认网络、插件和后台正常后，再考虑安装到 eMMC。

如果镜像内带有 ophub 安装工具，可以 SSH 登录后执行：

```sh
openwrt-install-amlogic
```

写入 eMMC 有风险，操作前确认：

- U 盘启动运行正常。
- 设备确实是斐讯 N1。
- 已备份原系统，或确认不需要原系统。
- 写入过程中不要断电。

## 9. 自动扩容

固件默认系统分区约 4GB。刷到更大的硬盘、SSD、U 盘或 TF 卡后，首次启动会尝试把剩余空间创建为 Btrfs 数据分区，并挂载为 `/overlay` extroot。

示例：

```text
10GB 硬盘写入 4GB 镜像
首次启动后剩余约 6GB 会被创建为 Btrfs 第 3 分区
重启一次后，/overlay 使用这个 Btrfs 扩容空间
```

扩容后的空间会用于：

- 后续安装的软件包
- OpenClash 数据
- LuCI 配置
- Docker 数据
- 系统日志和其他可写数据

检查命令：

```sh
df -h /overlay
mount | grep overlay
block info
```

注意：

- 只在没有第 3 分区、且剩余空间大于约 512MB 时自动创建。
- 如果已经存在第 3 分区，不会自动格式化。
- 首次启动后建议等待 1 到 3 分钟，再手动重启一次。
- Docker 默认数据目录为 `/mnt/data/docker`。

## 10. 常见问题

进入不了后台：

- 确认访问地址是 `http://10.0.0.1`。
- 电脑手动设置为 `10.0.0.2/24` 后再试。
- x86 多网口设备可以换另一个网口。
- 接显示器和键盘查看网卡识别情况。

容量没有变大：

- 首次启动后需要等待一会儿再重启。
- 目标盘本身可能只有 4GB 左右。
- 如果已经存在第 3 分区，脚本不会自动格式化。
- 当前设备分区命名可能不是脚本支持的常见形式。

Docker 数据在哪里：

```text
/mnt/data/docker
```

应该选 ext4 还是 squashfs：

- 普通用户优先选择 `squashfs combined` 或设备推荐的完整镜像。
- x86 UEFI 物理机优先 `combined-efi.img.gz`。
- 不要单独刷 `rootfs.img.gz`，除非明确知道如何手工分区。

OpenClash 或 Docker 数据多怎么办：

- 当前方案会把剩余空间扩展到 `/overlay`。
- 插件、配置和 Docker 数据会跟随 `/overlay` 使用扩容后的空间。
