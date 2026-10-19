---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 Linux 软件包实例
description: 升级单节点 Linux 软件包实例。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级 Linux 软件包实例的说明取决于您的极狐GitLab 实例是单节点还是多节点。要升级多节点 Linux 软件包极狐GitLab 实例，请参阅：

- [升级多节点实例（有停机时间）](../with_downtime.md)。
- [升级多节点实例（零停机时间）](../zero_downtime.md)。

要升级单节点 Linux 软件包极狐GitLab 实例，请按照本页面的信息操作。


<a id="prerequisites"></a>

## 先决条件

在升级单节点 Linux 软件包极狐GitLab 实例之前：

- 您必须[阅读必需信息并执行必需步骤](../plan_your_upgrade.md)。
- 如有需要，升级到[受支持的操作系统](../../install/package/_index.md)。
- 升级操作系统时，如果您的 `glibc` 版本发生变化，您必须遵循
  [为 PostgreSQL 升级操作系统](../../administration/postgresql/upgrading_os.md)，以避免索引损坏。
- 确保 PostgreSQL、Redis 和 Gitaly 正在运行。

在安装较新的极狐GitLab 版本之前，会备份极狐GitLab 数据库。您可以通过在 `/etc/gitlab/skip-auto-backup` 创建一个空文件来跳过此自动数据库备份：

```shell
sudo touch /etc/gitlab/skip-auto-backup
```

尽管如此，您仍应自行维护一份完整且最新的[备份](../../administration/backup_restore/_index.md)。

<a id="upgrade-a-single-node-linux-package-instance"></a>

## 升级单节点 Linux 软件包实例

要升级单节点 Linux 软件包实例：

1. 考虑在升级期间[开启维护模式](../../administration/maintenance_mode/_index.md)。
1. 暂停[正在运行的 CI/CD 流水线和作业](../plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 将[极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 升级到与目标极狐GitLab 版本相同的版本。
1. [使用 Linux 软件包升级极狐GitLab](#upgrade-with-the-linux-package)。

升级之后：

1. 取消暂停[正在运行的 CI/CD 流水线和作业](../plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，[关闭维护模式](../../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[升级健康检查](../plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="upgrade-with-the-linux-package"></a>

## 使用 Linux 软件包升级

要升级在单节点上运行的极狐GitLab，或升级属于多节点极狐GitLab 实例的某个节点，可通过以下任一方式升级：

- [使用官方软件仓库](#upgrade-with-the-official-repositories-recommended)。
- [使用下载的软件包](#upgrade-with-a-downloaded-package)。

<a id="upgrade-with-the-official-repositories-recommended"></a>

### 使用官方软件仓库升级（推荐）

所有极狐GitLab 软件包都会发布到极狐GitLab [软件包服务器](https://packages.gitlab.cn/#browse/browse)。

| 软件仓库                                                                                       | 描述 |
|:-------------------------------------------------------------------------------------------------|:------------|
| [`gitlab-jh`](https://packages.gitlab.cn/#browse/browse)                                         | 极狐GitLab 软件包。 |
| [`gitlab/nightly-builds`](https://packages.gitlab.com/ui/browse/gitlab/nightly-builds)           | 每夜构建。 |
| [`gitlab/nightly-fips-builds`](https://packages.gitlab.com/ui/browse/gitlab/nightly-fips-builds) | 符合 FIPS 的每夜构建。 |
| [`gitlab/gitlab-fips`](https://packages.gitlab.com/ui/browse/gitlab/gitlab-fips)                 | 符合 FIPS 的构建。 |

默认情况下，Linux 发行版软件包管理器会安装软件包的最新可用版本。如果您的[升级路径](../upgrade_paths.md)需要多个停靠点，则无法直接升级到极狐GitLab 的最新主要版本。如果您的升级路径包含多个版本，则每次升级都必须指定具体的极狐GitLab 软件包版本。

如果您的升级路径没有中间步骤，则可以直接升级到最新版本。

{{< tabs >}}

{{< tab title="Ubuntu/Debian" >}}

```shell
# GitLab (specific version)
sudo apt update && sudo apt install gitlab-jh=<version>-jh.0

# GitLab (latest version)
sudo apt update && sudo apt install gitlab-jh
```

{{< /tab >}}

{{< tab title="Amazon Linux 2" >}}

```shell
# GitLab Enterprise Edition (specific version)
sudo yum install gitlab-ee-<version>-ee.0.amazon2

# GitLab Community Edition (specific version)
sudo yum install gitlab-ce-<version>-ce.0.amazon2

# GitLab Enterprise Edition (latest version)
sudo yum install gitlab-ee

# GitLab Community Edition (latest version)
sudo yum install gitlab-ce
```

{{< /tab >}}

{{< tab title="RHEL/Oracle Linux/AlmaLinux 8/9" >}}

```shell
# GitLab (specific version)
sudo dnf install gitlab-jh-<version>-jh.0.el9

# GitLab (specific version)
sudo dnf install gitlab-jh-<version>-jh.0.el8

# GitLab (latest version)
sudo dnf upgrade gitlab-jh
```

{{< /tab >}}

{{< tab title="Amazon Linux 2023" >}}

```shell
# GitLab (specific version)
sudo dnf install gitlab-jh-<version>-jh.0.amazon2023

# GitLab (latest version)
sudo dnf upgrade gitlab-jh
```

{{< /tab >}}

{{< tab title="OpenSUSE Leap 15.5" >}}

```shell
# GitLab Enterprise Edition (specific version)
sudo zypper install gitlab-ee=<version>-ee.sles15

# GitLab Community Edition (specific version)
sudo zypper install gitlab-ce=<version>-ce.sles15

# GitLab Enterprise Edition (latest version)
sudo zypper install gitlab-ee

# GitLab Community Edition (latest version)
sudo zypper install gitlab-ce
```

{{< /tab >}}

{{< tab title="SUSE Enterprise Server 12.2/12.5" >}}

```shell
# GitLab Enterprise Edition (specific version)
sudo zypper install gitlab-ee=<version>-ee.0.sles12

# GitLab Community Edition (specific version)
sudo zypper install gitlab-ce=<version>-ce.0.sles12

# GitLab Enterprise Edition (latest version)
sudo zypper install gitlab-ee

# GitLab Community Edition (latest version)
sudo zypper install gitlab-ce
```

{{< /tab >}}

{{< /tabs >}}

<a id="pre-download-a-package-from-the-official-repository"></a>

### 从官方软件仓库预下载软件包

为了减少升级期间的安装时间，或测试软件包是否可访问，您可以从官方软件仓库下载软件包，稍后再安装：

{{< tabs >}}

{{< tab title="Ubuntu/Debian" >}}

```shell
# GitLab
sudo apt-get install --download-only gitlab-jh=<version>-jh.0
sudo apt-get install /var/cache/apt/archives/gitlab-jh_<version>-jh.0_amd64.deb
```

{{< /tab >}}

{{< tab title="Amazon Linux 2" >}}

```shell
# GitLab Enterprise Edition
sudo yumdownloader gitlab-ee-<version>-ee.0.amazon2
sudo yum install ./gitlab-ee-<version>-ee.0.amazon2.x86_64.rpm

# GitLab Community Edition
sudo yumdownloader gitlab-ce-<version>-ce.0.amazon2
sudo yum install ./gitlab-ce-<version>-ce.0.amazon2.x86_64.rpm
```

{{< /tab >}}

{{< tab title="RHEL/Oracle Linux/AlmaLinux 8/9" >}}

```shell
# GitLab (el9)
sudo dnf download gitlab-jh-<version>-jh.0.el9
sudo dnf install ./gitlab-jh-<version>-jh.0.el9.x86_64.rpm

# GitLab (el8)
sudo dnf download gitlab-jh-<version>-jh.0.el8
sudo dnf install ./gitlab-jh-<version>-jh.0.el8.x86_64.rpm
```

{{< /tab >}}

{{< tab title="Amazon Linux 2023" >}}

```shell
# GitLab
sudo dnf download gitlab-jh-<version>-jh.0.amazon2023
sudo dnf install ./gitlab-jh-<version>-jh.0.amazon2023.x86_64.rpm
```

{{< /tab >}}

{{< tab title="OpenSUSE Leap 15.5" >}}

```shell
# GitLab Enterprise Edition
sudo zypper install --download-only gitlab-ee-<version>-ee.0.sles15.x86_64
sudo zypper install /var/cache/zypp/packages/gitlab_gitlab-ee/Packages/g/gitlab-ee-<version>-ee.sles15.x86_64.rpm

# GitLab Community Edition
sudo zypper install --download-only gitlab-ce-<version>-ce.0.sles15.x86_64
sudo zypper install /var/cache/zypp/packages/gitlab_gitlab-ce/Packages/g/gitlab-ce-<version>-ce.sles15.x86_64.rpm
```

{{< /tab >}}

{{< tab title="SUSE Enterprise Server 12.2/12.5" >}}

```shell
# GitLab Enterprise Edition
sudo zypper install --download-only gitlab-ee-<version>-ee.0.sles12.x86_64
sudo zypper install /var/cache/zypp/packages/gitlab_gitlab-ee/Packages/g/gitlab-ee-<version>-ee.0.sles12.x86_64.rpm

# GitLab Community Edition
sudo zypper install --download-only gitlab-ce-<version>-ce.0.sles12.x86_64
sudo zypper install /var/cache/zypp/packages/gitlab_gitlab-ce/Packages/g/gitlab-ce-<version>-ce.0.sles12.x86_64.rpm
```

{{< /tab >}}

{{< /tabs >}}

<a id="upgrade-with-a-downloaded-package"></a>

### 使用下载的软件包升级

如果您不想使用官方软件仓库，可以下载软件包并手动安装。此方法既可用于首次安装极狐GitLab，也可用于升级。

要下载并安装或升级极狐GitLab：

1. 转到您的软件包的[官方软件仓库](#upgrade-with-the-official-repositories-recommended)。
1. 通过搜索您要安装的版本来筛选列表。例如，`18.4.1`。同一版本可能存在多个软件包，
   每个受支持的发行版和架构各一个。由于某些文件
   与多个发行版相关，因此文件名旁边会有一个标签，指示其所属的发行版。
1. 找到您希望安装的软件包版本，然后从列表中选择文件名。
1. 在右上角，选择**下载**。
1. 软件包下载完成后，使用以下
   命令之一进行安装，并将 `<package_name>` 替换为您下载的
   软件包名称：

   {{< tabs >}}

   {{< tab title="Ubuntu/Debian" >}}

   ```shell
   dpkg -i <package_name>
   ```

   {{< /tab >}}

   {{< tab title="Amazon Linux 2" >}}

   ```shell
   rpm -Uvh <package_name>
   ```

   {{< /tab >}}

   {{< tab title="RHEL/Oracle Linux/AlmaLinux 8/9 and Amazon Linux 2023" >}}

   ```shell
   dnf install <package_name>
   ```

   {{< /tab >}}

   {{< tab title="SUSE and OpenSUSE" >}}

   ```shell
   zypper install <package_name>
   ```

   {{< /tab >}}

   {{< /tabs >}}
