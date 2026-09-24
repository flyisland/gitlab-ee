---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 Linux 软件包实例
description: Upgrade a single-node Linux package-based instance.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级 Linux 软件包实例的说明取决于你拥有的是单节点还是多节点极狐GitLab 实例。要升级多节点 Linux 软件包极狐GitLab 实例，请参见：

- [升级带停机时间的多节点实例](../with_downtime.md)。
- [升级零停机时间的多节点实例](../zero_downtime.md)。

要升级单节点 Linux 软件包极狐GitLab 实例，请按照本页信息操作。

> [!note]
> 如果你托管了产品文档，你也可以[将其升级到更高版本](../../administration/docs_self_host.md#upgrade-the-product-documentation-to-a-later-version)。

<a id="prerequisites"></a>

## 前提条件

在升级单节点 Linux 软件包极狐GitLab 实例之前：

- 你必须[阅读所需信息并执行所需步骤](../plan_your_upgrade.md)。
- 如有必要，升级到[支持的操作系统](../../install/package/_index.md)。
- 升级操作系统时，如果你的 `glibc` 版本发生变化，你必须遵循[为 PostgreSQL 升级操作系统](../../administration/postgresql/upgrading_os.md)以避免索引损坏。
- 确保 PostgreSQL、Redis 和 Gitaly 正在运行。

在安装较新的极狐GitLab 版本之前，极狐GitLab 数据库会进行备份。你可以通过在 `/etc/gitlab/skip-auto-backup` 创建一个空文件来跳过此自动数据库备份：

```shell
sudo touch /etc/gitlab/skip-auto-backup
```

尽管如此，你应该自行维护完整的[备份](../../administration/backup_restore/_index.md)。

<a id="upgrade-a-single-node-linux-package-instance"></a>

## 升级单节点 Linux 软件包实例

要升级单节点 Linux 软件包实例：

1. 考虑在升级期间[开启维护模式](../../administration/maintenance_mode/_index.md)。
1. 暂停[正在运行的 CI/CD 流水线和作业](../plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. [将极狐GitLab Runner 升级](https://gitlab.cn/docs/runner/install/)到与目标极狐GitLab 版本相同的版本。
1. [使用 Linux 软件包升级极狐GitLab](#upgrade-with-the-linux-package)。

升级后：

1. 恢复[正在运行的 CI/CD 流水线和作业](../plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，[关闭维护模式](../../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[升级健康检查](../plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="upgrade-with-the-linux-package"></a>

## 使用 Linux 软件包升级

要升级在单节点上运行的极狐GitLab，或升级属于多节点极狐GitLab 实例的节点，可以通过以下任一方式升级：

- [使用官方仓库（推荐）](#upgrade-with-the-official-repositories-recommended)。
- [使用下载的软件包](#upgrade-with-a-downloaded-package)。

<a id="upgrade-with-the-official-repositories-recommended"></a>

### 使用官方仓库升级（推荐）

所有极狐GitLab 软件包都发布在极狐GitLab [软件包服务器](https://packages.gitlab.cn/ui/browse/gitlab)上。

| 仓库                                                                                             | 描述 |
|:-------------------------------------------------------------------------------------------------|:------------|
| [`gitlab/gitlab-jh`](https://packages.gitlab.cn/ui/browse/gitlab/gitlab-jh)                     | 精简版软件包，仅包含基础版功能。 |
| [`gitlab/gitlab-jh`](https://packages.gitlab.cn/ui/browse/gitlab/gitlab-jh)                     | 完整的极狐GitLab 软件包，包含所有基础版和企业版功能。 |
| [`gitlab/nightly-builds`](https://packages.gitlab.cn/ui/browse/gitlab/nightly-builds)           | 每日构建。 |
| [`gitlab/nightly-fips-builds`](https://packages.gitlab.cn/ui/browse/gitlab/nightly-fips-builds) | 每日 FIPS 合规构建。 |
| [`gitlab/gitlab-fips`](https://packages.gitlab.cn/ui/browse/gitlab/gitlab-fips)                 | FIPS 合规构建。 |

默认情况下，Linux 发行版的软件包管理器会安装软件包的最新可用版本。如果你的[升级路径](../upgrade_paths.md)需要多次停留，则无法直接升级到极狐GitLab 的最新主版本。如果你的升级路径包含多个版本，则必须在每次升级时指定特定的极狐GitLab 软件包版本。

如果你的升级路径没有中间步骤，则可以直接升级到最新版本。

{{< tabs >}}

{{< tab title="Ubuntu/Debian" >}}

```shell
# 极狐GitLab 企业版（特定版本）
sudo apt update && sudo apt install gitlab-ee=<version>-jh.0

# 极狐GitLab 基础版（特定版本）
sudo apt update && sudo apt install gitlab-ce=<version>-jh.0

# 极狐GitLab 企业版（最新版本）
sudo apt update && sudo apt install gitlab-ee

# 极狐GitLab 基础版（最新版本）
sudo apt update && sudo apt install gitlab-ce
```

{{< /tab >}}

{{< tab title="Amazon Linux 2" >}}

```shell
# 极狐GitLab 企业版（特定版本）
sudo yum install gitlab-ee-<version>-jh.0.amazon2

# 极狐GitLab 基础版（特定版本）
sudo yum install gitlab-ce-<version>-jh.0.amazon2

# 极狐GitLab 企业版（最新版本）
sudo yum install gitlab-ee

# 极狐GitLab 基础版（最新版本）
sudo yum install gitlab-ce
```

{{< /tab >}}

{{< tab title="RHEL/Oracle Linux/AlmaLinux 8/9" >}}

```shell
# 极狐GitLab 企业版（特定版本）
sudo dnf install gitlab-ee-<version>-jh.0.el9

# 极狐GitLab 企业版（特定版本）
sudo dnf install gitlab-ee-<version>-jh.0.el8

# 极狐GitLab 基础版（特定版本）
sudo dnf install gitlab-ce-<version>-jh.0.el9

# 极狐GitLab 基础版（特定版本）
sudo dnf install gitlab-ce-<version>-jh.0.el8

# 极狐GitLab 企业版（最新版本）
sudo dnf upgrade gitlab-ee

# 极狐GitLab 基础版（最新版本）
sudo dnf upgrade gitlab-ce
```

{{< /tab >}}

{{< tab title="Amazon Linux 2023" >}}

```shell
# 极狐GitLab 企业版（特定版本）
sudo dnf install gitlab-ee-<version>-jh.0.amazon2023

# 极狐GitLab 基础版（特定版本）
sudo dnf install gitlab-ce-<version>-jh.0.amazon2023

# 极狐GitLab 企业版（最新版本）
sudo dnf upgrade gitlab-ee

# 极狐GitLab 基础版（最新版本）
sudo dnf upgrade gitlab-ce
```

{{< /tab >}}

{{< tab title="OpenSUSE Leap 15.5" >}}

```shell
# 极狐GitLab 企业版（特定版本）
sudo zypper install gitlab-ee=<version>-ee.sles15

# 极狐GitLab 基础版（特定版本）
sudo zypper install gitlab-ce=<version>-ce.sles15

# 极狐GitLab 企业版（最新版本）
sudo zypper install gitlab-ee

# 极狐GitLab 基础版（最新版本）
sudo zypper install gitlab-ce
```

{{< /tab >}}

{{< tab title="SUSE Enterprise Server 12.2/12.5" >}}

```shell
# 极狐GitLab 企业版（特定版本）
sudo zypper install gitlab-ee=<version>-jh.0.sles12

# 极狐GitLab 基础版（特定版本）
sudo zypper install gitlab-ce=<version>-jh.0.sles12

# 极狐GitLab 企业版（最新版本）
sudo zypper install gitlab-ee

# 极狐GitLab 基础版（最新版本）
sudo zypper install gitlab-ce
```

{{< /tab >}}

{{< /tabs >}}

<a id="upgrade-with-a-downloaded-package"></a>

### 使用下载的软件包升级

如果你不想使用官方仓库，可以下载软件包并手动安装。此方法可用于首次安装极狐GitLab 或升级它。

要下载并安装或升级极狐GitLab：

1. 转到你的软件包的[官方仓库](#upgrade-with-the-official-repositories-recommended)。
1. 通过搜索你要安装的版本来筛选列表。例如，`18.4.1`。单个版本可能存在多个软件包，每个软件包对应一个受支持的发行版和架构。由于某些文件适用于多个发行版，因此文件名旁边有一个标签指示发行版。
1. 找到你要安装的软件包版本，并从列表中选择文件名。
1. 在右上角，选择 **下载**。
1. 软件包下载后，使用以下命令之一进行安装，并将 `<package_name>` 替换为你下载的软件包名称：

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
