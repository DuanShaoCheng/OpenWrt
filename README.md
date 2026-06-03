# Duan OpenWrt 自动编译

这个仓库使用 GitHub Actions 自动编译自用 OpenWrt 固件。当前保留 3 个目标：x86/64 软路由、FriendlyARM NanoPi R2S、斐讯 N1。

编译完成后，固件会自动发布到 GitHub Releases。Release 里直接展示常用固件文件，不再把一个设备压成一个大 zip。x86 只发布 EROFS 的 `.img.gz` 和 `.iso`，R2S/N1 发布对应设备镜像。

刷写和首次启动步骤见：[固件使用说明](USAGE.md)。

## 当前设备

| 设备 | 用途 | 构建方式 |
| --- | --- | --- |
| `x86-64-generic` | 物理软路由、虚拟机、主路由 | OpenWrt 官方 x86/64 generic |
| `nanopi-r2s` | NanoPi R2S | OpenWrt 官方 rockchip/armv8 |
| `phicomm-n1` | 斐讯 N1 | 先编译 `armsr/armv8` rootfs，再用 ophub 打包 |

## 默认配置

| 项目 | 当前值 |
| --- | --- |
| OpenWrt 源码 | `https://github.com/openwrt/openwrt.git` |
| OpenWrt 分支 | `openwrt-25.12` |
| 作者标识 | `Duan` |
| 后台地址 | `http://10.0.0.1` |
| 登录账号 | `root` |
| 登录密码 | `root` |
| rootfs 分区 | `4096 MB` |
| 自动编译 | 每周一北京时间 `04:10` |
| Release 上传 | 开启 |
| Actions artifact | 保留 14 天 |

首次进入后台后建议立即修改密码。

每次自动编译都会重新拉取 OpenWrt 源码、更新 feeds、安装 feeds 软件包，并重新拉取 OpenClash、luci-app-cloudflarespeedtest 等第三方插件源码，然后再打包发布到 Release。下载缓存只缓存源码压缩包，不会固定 OpenWrt、feeds 或插件版本。

当前更新范围是 `openwrt-25.12` 分支内的最新代码；如果以后要切换到新的 OpenWrt 大版本，需要修改 workflow 里的 `OPENWRT_BRANCH`。

## 内置插件

基础功能：

- LuCI Web 后台、HTTPS Web UI、软件包管理页面
- 中文界面和常用中文语言包
- OpenClash
- Cloudflare Speed Test 优选 IP 页面
- WireGuard
- DDNS
- SQM QoS
- irqbalance
- banIP
- mwan3，多 WAN 服务默认禁用，需要时可手动开启

Docker 和存储：

- Docker、dockerd、docker-compose
- LuCI Dockerman 管理页面
- USB 存储、EXT4、Btrfs、F2FS、XFS
- `parted`、`btrfs-progs`、`f2fs-tools`、`xfs-*`
- 首次启动自动把系统盘剩余空间创建为 Btrfs extroot

常用工具：

- `curl`
- `htop`
- `iperf3`
- `tcpdump`
- `wget-ssl`

## 自动扩容

固件系统分区默认约 4GB。如果刷入 8GB、16GB、32GB 或更大的硬盘、SSD、U 盘、TF 卡，首次启动时会尝试自动处理剩余空间：

```text
系统盘剩余空间 -> 第 3 分区 -> Btrfs -> /overlay extroot
```

扩容成功后，后续安装的软件包、OpenClash 数据、系统配置、Docker 数据等都会使用扩容后的 `/overlay`。

注意：

- 只在没有第 3 分区、且剩余空间大于约 512MB 时执行。
- 如果已经存在第 3 分区，不会自动格式化，避免误删数据。
- 首次启动后建议等待 1 到 3 分钟，再重启一次。
- Docker 默认数据目录为 `/mnt/data/docker`。

## 输出格式

x86 只发布现代 EROFS 镜像：

| 文件特征 | 推荐用途 |
| --- | --- |
| `x86-erofs-uefi.img.gz` | UEFI 启动的物理软路由，优先推荐 |
| `x86-erofs-bios.img.gz` | Legacy BIOS 启动的物理软路由 |
| `x86-uefi.iso` | UEFI ISO，测试或临时启动 |
| `x86-bios.iso` | Legacy BIOS ISO，测试或临时启动 |

R2S 通常使用文件名包含 `nanopi-r2s` 的 `sysupgrade.img.gz` 或完整镜像。N1 使用 ophub 打包输出的 `.img.gz`。

如果某个 Release 文件超过 GitHub 单文件 2GB 限制，会自动拆成：

```text
文件名.part-000
文件名.part-001
```

下载后按 Release 里的 `README_RELEASE_ASSETS.txt` 合并即可。

## 手动运行编译

1. 打开仓库页面。
2. 进入 `Actions`。
3. 选择 `Build OpenWrt Multi Device`。
4. 点击 `Run workflow`。
5. 保持 `build_official` 和 `build_n1` 为开启，或按需要关闭某类构建。
6. 点击绿色的 `Run workflow`。

如果刚刚修改了 workflow，一定要重新点 `Run workflow` 发起新任务，不要对旧失败任务点 `Re-run failed jobs`，旧任务可能仍然使用旧版本脚本。

## 下载固件

编译成功后进入 `Releases`，选择最新 Release。名称类似：

```text
Duan-OpenWrt-openwrt-25.12-运行编号
```

Release 里会直接列出短文件名：

```text
x86-erofs-uefi.img.gz
x86-erofs-bios.img.gz
x86-uefi.iso
x86-bios.iso
r2s-squashfs-sysupgrade.img.gz
n1-s905d.img.gz
README_RELEASE_ASSETS.txt
x86-SOURCE_VERSIONS.txt
r2s-SOURCE_VERSIONS.txt
n1-SOURCE_VERSIONS.txt
SHA256SUMS.txt
```

不要下载 GitHub 自动生成的 `Source code.zip` 或 `Source code.tar.gz`，那是源码，不是固件。

## 修改配置

常改文件：

| 文件 | 作用 |
| --- | --- |
| `.github/workflows/build-openwrt-multi.yml` | 设备列表、编译分支、定时任务、Release 发布逻辑 |
| `configs/common.seed` | 所有设备共同软件包 |
| `configs/x86.seed` | x86 专用格式、驱动、Docker 等 |
| `configs/sbc.seed` | R2S、N1 这类 SBC 的额外软件包 |
| `configs/router.seed` | 后续新增普通路由器时使用 |
| `configs/amlogic-rootfs.seed` | N1 rootfs 和 ophub 打包需要的设置 |
| `diy-part1.sh` | feeds 更新前执行，适合添加第三方包源 |
| `diy-part2.sh` | `make defconfig` 前执行，适合修改源码默认配置 |
| `files/` | OpenWrt rootfs 覆盖目录，里面文件会进入固件 |

## 新增设备

官方 OpenWrt 支持的设备，在 `.github/workflows/build-openwrt-multi.yml` 的 `strategy.matrix.include` 里新增一段：

```yaml
- name: device-name
  target: ramips
  subtarget: mt7621
  profile: xiaomi_mi-router-4a-gigabit
  extra_seed: configs/router.seed
```

`target`、`subtarget`、`profile` 必须和 OpenWrt 官方源码里的设备定义一致。小闪存设备不要直接使用当前完整插件包，否则很容易因为空间不足导致编译失败。

## 常见问题

编译失败提示缺少 `python3-pyelftools`：当前 workflow 已安装 `python3-pyelftools`，如果旧任务仍失败，请从最新 `main` 重新发起一次新任务。

Release 上传失败提示 `size must be less than 2147483648`：GitHub 单个 Release 附件限制 2GB。当前 workflow 会把超大文件自动切分，重新运行最新 workflow 即可。

Release 里文件太多：当前已收窄为常用镜像短文件名；x86 只保留 EROFS 的 IMG/ISO，R2S 只保留 squashfs sysupgrade，N1 只保留 s905d 镜像。

找不到后台：电脑手动设置为 `10.0.0.2/24`，访问 `http://10.0.0.1`。x86 多网口设备可以换另一个网口再试。
