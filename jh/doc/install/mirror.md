---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Mirror GitLab Linux package repositories
title: Linux 软件包仓库镜像
---

极狐GitLab 和 极狐GitLab Runner Linux 软件包可从
<https://packages.gitlab.cn> 获取。本文档说明如何
维护这些仓库的本地镜像。

<a id="mirroring-apt-repositories"></a>

## 镜像 APT 仓库

可以使用 `apt-mirror` 工具创建 `apt` 仓库的本地镜像。

1. 安装 `apt-mirror`

   ```shell
   sudo apt install apt-mirror
   ```

1. 为镜像创建目录

   ```shell
   sudo mkdir /srv/gitlab-repo-mirror
   ```

1. 将以下行添加到位于 `/etc/apt/mirror.list` 的 `apt-mirror` 配置文件中

   ```shell
   set base_path /srv/gitlab-repo-mirror
   ```

   镜像内容被写入
   `/srv/gitlab-repo-mirror/mirror/packages.gitlab.cn` 目录中。

   请查看[上游示例配置文件](https://github.com/apt-mirror/apt-mirror/blob/master/mirror.list)
   了解其他可用设置。

1. 在配置文件的末尾，以 `apt` 源文件 URL 格式指定要镜像的仓库。

   > [!note]
   > 极狐GitLab 与 极狐GitLab Runner 的仓库结构不同。
   >
   > <a id="gitlab"></a>
   >
   > ### 极狐GitLab
   >
   > 极狐GitLab 在不同操作系统发行版中使用相同的版本字符串（内容不同）。这意味着这些软件包被视为
   > [根据 Debian 仓库格式的重复软件包](https://wiki.debian.org/DebianRepository/Format#Duplicate_Packages)。
   >
   > 要解决此问题，每个操作系统发行版（如 Debian Trixie 或 Ubuntu
   > Focal）都会获得一个仅托管该发行版的专用仓库。这
   > 导致 URL 中多出一个发行版组件。
   >
   > <a id="gitlab-runner"></a>
   >
   > ### 极狐GitLab Runner
   >
   > 极狐GitLab Runner 是一个静态链接的 Go 二进制文件，在不同操作系统发行版中使用相同的软件包。
   > 它针对每个操作系统使用单个 APT 仓库，并在该仓库中托管该操作系统的所有发行版。

   {{< tabs >}}

   {{< tab title="极狐GitLab" >}}

   ```plaintext
   deb https://packages.gitlab.cn/gitlab/gitlab-jh/debian/trixie trixie main
   deb-src https://packages.gitlab.cn/gitlab/gitlab-jh/debian/trixie trixie main
   ```

   {{< /tab >}}

   {{< tab title="极狐GitLab Runner" >}}

   ```plaintext
   deb https://packages.gitlab.cn/runner/gitlab-runner/debian trixie main
   deb-src https://packages.gitlab.cn/runner/gitlab-runner/debian trixie main
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 启动镜像过程

   ```shell
   sudo apt-mirror
   ```

<a id="mirroring-rpm-repositories"></a>

## 镜像 RPM 仓库

可以使用 `reposync`（用于下载软件包）和 `createrepo`（用于生成元数据）创建 `rpm` 仓库的本地镜像。

> [!note]
> `reposync` 要求系统上已安装要镜像的仓库。请按照[安装文档](package/_index.md#supported-platforms)
> 操作要镜像的仓库。
>
> 要查找仓库 ID，请使用以下命令列出可用仓库：
>
> ```shell
> yum repolist
> ```

1. 安装 `createrepo` 和 `reposync`

   ```shell
   sudo yum install createrepo yum-utils
   ```

1. 为镜像创建目录

   ```shell
   sudo mkdir /srv/gitlab-repo-mirror
   ```

1. 运行 `reposync`。将仓库 ID 和输出目录作为参数传递。

   ```shell
   reposync --repoid=gitlab-jh --download-path=/srv/gitlab-repo-mirror
   ```

1. 使用 `createrepo` 为仓库生成元数据

   ```shell
   createrepo -o /srv/gitlab-repo-mirror /srv/gitlab-repo-mirror
   ```
