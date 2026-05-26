# OpenWrt GitHub Actions 自动编译

这个仓库用于每天自动编译多设备 OpenWrt 固件。官方支持的设备直接从 OpenWrt 源码编译；斐讯 N1 使用 `ophub/amlogic-s9xxx-openwrt` 基于 `armsr/armv8` rootfs 二次打包。

## 默认设置

- OpenWrt 分支：`openwrt-25.12`
- 自动编译时间：每天北京时间 04:10
- 固件产物：GitHub Actions artifact，保留 14 天
- 默认包含：LuCI、HTTPS Web UI、中文语言包、软件包管理页面
- SBC/x86 额外包含：USB/EXT4/诊断工具

## 默认编译设备

### x86 / SBC

- x86/64 generic
- FriendlyARM NanoPi R2S / R3S / R4S / R5S / R6S
- Raspberry Pi 4 / 5

### 常见路由器

- Newifi D2
- Xiaomi Mi Router 4A Gigabit
- Xiaomi Redmi Router AC2100
- TP-Link Archer C6 v3
- GL.iNet GL-MT3000 / GL-MT6000
- Redmi AX6000
- Cudy WR3000 v1
- CMCC RAX3000M
- Xiaomi AX3600
- Redmi AX6
- GL.iNet GL-AX1800 / GL-AXT1800 / GL-A1300
- Netgear R7800

### Amlogic 盒子

- Phicomm N1，板型代码：`s905d`

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

编译完成后，进入 GitHub Actions 对应运行记录，在页面底部 `Artifacts` 下载：

```text
OpenWrt-x86-64-generic-...
OpenWrt-nanopi-r4s-...
OpenWrt-phicomm-n1-...
```

不同设备的刷机方式不同，刷写前务必确认文件名里的设备型号和自己的硬件完全一致。
