---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 回滚到更早的极狐GitLab 版本
description: 回滚 Linux 软件包或 Docker 实例到更早版本。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将使用 Linux 软件包或 Docker 安装的极狐GitLab 实例回滚到更早的版本。

回滚时，您必须考虑之前升级时发生的[特定于版本的变更](../versions/_index.md)。

<a id="prerequisites"></a>

## 先决条件

由于必须还原实例升级时所做的数据库架构更改（迁移），您必须拥有：

- 至少一个在与回滚目标完全相同的版本和版本类型下创建的数据库备份。
- 理想情况下，一个与回滚目标完全相同的版本和版本类型的[完整备份存档](../../administration/backup_restore/_index.md)。

<a id="roll-back-a-linux-package-instance"></a>

## 回滚 Linux 软件包实例

要将 Linux 软件包实例回滚到更早的极狐GitLab 版本：

1. 停止极狐GitLab 并删除当前软件包：

   ```shell
   # 如果正在运行 Puma
   sudo gitlab-ctl stop puma

   # 停止 sidekiq
   sudo gitlab-ctl stop sidekiq

   # 如果使用 Ubuntu：删除当前软件包
   sudo dpkg -r gitlab-ee

   # 如果使用 CentOS：删除当前软件包
   sudo yum remove gitlab-ee
   ```

1. 确定要回滚到的极狐GitLab 版本：

   ```shell
   # (如果您安装了极狐GitLab 基础版，请替换为 gitlab-ce)

   # Ubuntu
   sudo apt-cache madison gitlab-ee

   # CentOS:
   sudo yum --showduplicates list gitlab-ee
   ```

1. 将极狐GitLab 回滚到所需版本（例如，回滚到极狐GitLab 15.0.5）：

   ```shell
   # (如果您安装了极狐GitLab 基础版，请替换为 gitlab-ce)

   # Ubuntu
   sudo apt install gitlab-ee=15.0.5-jh.0

   # CentOS:
   sudo yum install gitlab-ee-15.0.5-jh.0.el8
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. [恢复极狐GitLab](../../administration/backup_restore/restore_gitlab.md#restore-for-linux-package-installations)
   以完成回滚。

<a id="roll-back-a-docker-instance"></a>

## 回滚 Docker 实例

恢复操作会用旧状态覆盖所有较新的极狐GitLab 数据库内容。
仅在必要时才建议回滚。例如，升级后测试发现无法快速解决的问题。

> [!warning]
> 您必须至少有一个使用与降级目标完全相同的版本和版本类型创建的数据库备份。
> 需要此备份来还原升级期间所做的架构更改（迁移）。

要在升级后不久回滚极狐GitLab：

1. 按照升级步骤，[指定一个比已安装版本更早的版本](../../install/docker/installation.md#find-the-gitlab-version-and-edition-to-use)。
1. 恢复升级前创建的[数据库备份](../../install/docker/backup.md#create-a-database-backup)。

   - [遵循 Docker 镜像和极狐GitLab Helm Chart 安装的恢复步骤](../../administration/backup_restore/restore_gitlab.md#restore-for-docker-image-and-gitlab-helm-chart-installations)，包括停止 Puma 和 Sidekiq。只需要恢复数据库，因此将 `SKIP=产物,仓库,镜像仓库,上传,构建,页面,LFS,软件包,terraform_state` 添加到 `gitlab-backup restore` 命令行参数中。

