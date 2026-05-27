# 固件使用说明

本文说明如何下载、校验、选择和写入本仓库自动编译出来的 OpenWrt 固件。

## 1. 下载固件

打开仓库页面，进入 `Releases`，选择最新的 Release。

Release 名称类似：

```text
Duan-OpenWrt-openwrt-25.12-运行编号
```

优先下载与你设备对应的 zip：

```text
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号.zip
Duan-OpenWrt-nanopi-r2s-openwrt-25.12-运行编号.zip
Duan-OpenWrt-phicomm-n1-openwrt-25.12-运行编号.zip
README_RELEASE_ASSETS.txt
SHA256SUMS.txt
```

如果 x86 包太大，Release 里可能不是一个 `.zip`，而是多个分卷：

```text
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号.zip.part-000
Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号.zip.part-001
```

这种情况需要先合并分卷，再解压合并后的 zip。

Linux/macOS：

```sh
cat Duan-OpenWrt-x86-64-generic-*.zip.part-* > Duan-OpenWrt-x86-64-generic.zip
```

Windows PowerShell：

```powershell
$parts = Get-ChildItem "Duan-OpenWrt-x86-64-generic-*.zip.part-*" | Sort-Object Name
$out = [IO.File]::Create("Duan-OpenWrt-x86-64-generic.zip")
foreach ($part in $parts) {
  $in = [IO.File]::OpenRead($part.FullName)
  $in.CopyTo($out)
  $in.Close()
}
$out.Close()
```

不要下载 GitHub 自动生成的 `Source code.zip` 或 `Source code.tar.gz`，那只是源码压缩包，不是固件。

## 2. 校验文件

下载后建议先校验完整性。

Windows PowerShell：

```powershell
Get-FileHash .\Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号.zip -Algorithm SHA256
```

Linux/macOS：

```sh
sha256sum Duan-OpenWrt-x86-64-generic-openwrt-25.12-运行编号.zip
```

把结果和 Release 里的 `SHA256SUMS.txt` 对照。每个设备 zip 解压后，里面还有一个设备内部的 `SHA256SUMS.txt`。

## 3. 默认登录信息

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

如果电脑没有自动获取到地址，可以临时把电脑网卡设置为：

```text
IP：10.0.0.2
掩码：255.255.255.0
网关：10.0.0.1
```

## 4. 自动扩容说明

固件默认系统分区约 4GB。刷到更大的硬盘、SSD、U 盘、TF 卡后，首次启动会尝试自动扩容：

```text
剩余空间 -> 第 3 分区 -> Btrfs -> /overlay extroot
```

举例：

```text
10GB 硬盘写入 4GB 镜像
首次启动后剩余约 6GB 会被创建为 Btrfs 第 3 分区
重启一次后，/overlay 会使用这个 Btrfs 扩容空间
```

扩容后的空间会用于：

```text
后续安装的软件包
OpenClash 数据
LuCI 配置
Docker 数据
系统日志和其他可写数据
```

注意：

- 只会在没有第 3 分区、且剩余空间大于约 512MB 时自动创建。
- 如果已经存在第 3 分区，不会自动格式化，避免误删数据。
- 首次启动后建议等待 1 到 3 分钟，然后手动重启一次。
- 重启后可以在 LuCI 的挂载点页面，或 SSH 里确认 `/overlay` 容量。

SSH 检查命令：

```sh
df -h /overlay
mount | grep overlay
block info
```

## 5. x86/64 软路由使用

x86 artifact 解压后会看到多种格式。常用选择如下：

```text
combined-efi.img.gz   推荐给 UEFI 启动的物理软路由
combined.img.gz       适合 Legacy BIOS 启动的物理软路由
vmdk                  VMware / ESXi
vdi                   VirtualBox
vhdx                  Hyper-V
iso                   测试或光盘启动场景，不建议作为长期主系统
rootfs.img.gz         高级用户手工分区时使用
```

写入物理硬盘、SSD 或 U 盘：

1. 解压设备 zip。
2. 找到 `combined-efi.img.gz` 或 `combined.img.gz`。
3. 使用 balenaEtcher、Rufus、USBImager 等工具写入目标盘。
4. 如果写盘工具不识别 `.img.gz`，先用 7-Zip 解压成 `.img` 再写入。
5. 写入会清空目标盘，务必确认磁盘没有选错。
6. 从目标盘启动软路由。
7. 进入 `http://10.0.0.1` 完成初始配置。
8. 等待首次扩容脚本执行完成后，重启一次。

如果启动后无法访问后台，优先尝试：

- 换另一个网口连接电脑。
- 给电脑手动设置 `10.0.0.2/24`。
- 接显示器和键盘查看网卡识别情况。

## 6. NanoPi R2S 使用

R2S 使用 `nanopi-r2s` 对应的 zip。

首次刷入 TF 卡：

1. 解压 `Duan-OpenWrt-nanopi-r2s-...zip`。
2. 找到文件名包含 `nanopi-r2s` 的 `.img.gz` 或 `sysupgrade.img.gz`。
3. 使用 balenaEtcher、Rufus、USBImager 写入 TF 卡。
4. 如果写盘工具不识别 `.img.gz`，先用 7-Zip 解压成 `.img` 再写入。
5. 插入 R2S 启动。
6. 电脑连接 LAN 口，访问 `http://10.0.0.1`。
7. 等待首次扩容脚本执行完成后，重启一次。

如果已经在运行 OpenWrt，也可以在 LuCI 后台使用升级：

```text
系统 -> 备份/升级 -> 刷写新的固件
```

升级前建议备份配置。跨版本或遇到异常时，建议取消保留配置后重新设置。

## 7. 斐讯 N1 使用

N1 使用 `phicomm-n1` 对应的 zip。

一般流程：

1. 解压 `Duan-OpenWrt-phicomm-n1-...zip`。
2. 找到 ophub 打包生成的 `.img.gz` 固件。
3. 使用 balenaEtcher、Rufus、USBImager 写入 U 盘。
4. 如果写盘工具不识别 `.img.gz`，先用 7-Zip 解压成 `.img` 再写入。
5. N1 从 U 盘启动 OpenWrt。
6. 电脑连接同一网络，访问 `http://10.0.0.1`。
7. 确认网络、插件和后台正常后，再考虑安装到 eMMC。

如果镜像内带有 ophub 的安装工具，可以 SSH 登录后执行：

```sh
openwrt-install-amlogic
```

安装到 eMMC 有风险，操作前建议先确认：

- U 盘启动运行正常。
- 设备型号确实是斐讯 N1。
- 已备份原系统或确认不需要原系统。
- 不要在断电风险高的时候写入 eMMC。

## 8. 常见问题

### 进入不了后台

先确认电脑是否拿到 `10.0.0.x` 地址。没有拿到就手动设置 `10.0.0.2/24`，然后访问：

```text
http://10.0.0.1
```

x86 机器如果有多个网口，可能 LAN 口不是你插的那个，换一个网口再试。

### 容量没有变大

首次启动后需要等待一会儿，再重启一次。重启后查看：

```sh
df -h /overlay
```

如果仍没有变大，可能原因是：

- 目标盘本身只有 4GB 左右。
- 已经存在第 3 分区，脚本不会自动格式化。
- 当前设备分区命名不是脚本支持的常见形式。

### Docker 数据在哪里

默认 Docker 数据目录：

```text
/mnt/data/docker
```

`/mnt/data` 会指向扩容后的 Btrfs `/overlay/data`。

### 应该选 ext4 还是 squashfs

普通用户优先使用设备推荐的完整镜像：

```text
x86: combined-efi.img.gz 或 combined.img.gz
R2S: 设备名对应的 sysupgrade/img.gz
N1:  ophub 打包出的 img.gz
```

不要单独刷 `rootfs.img.gz`，除非你明确知道自己在手工分区。
