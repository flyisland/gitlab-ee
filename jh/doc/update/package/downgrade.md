---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 回滚到较早的极狐GitLab 版本
description: 将 Linux 软件包或 Docker 实例回滚到较早版本。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将使用 Linux 软件包或 Docker 安装的极狐GitLab 实例回滚到较早版本。

回滚时，您必须考虑之前升级时发生的[版本特定变更](../versions/_index.md)。

<a id="prerequisites"></a>

## 先决条件

由于您必须还原实例升级时所做的数据库架构变更（迁移），因此您必须拥有：

- 至少一个在您要回滚到的完全相同版本和版本类型下创建的数据库备份。
- 理想情况下，是您要回滚到的完全相同版本和版本类型的[完整备份归档](../../administration/backup_restore/_index.md)。

<a id="roll-back-a-linux-package-instance"></a>

## 回滚 Linux 软件包实例

要将 Linux 软件包实例回滚到较早的极狐GitLab 版本：

1. 停止极狐GitLab 并移除当前软件包：

   ```shell
   # If running Puma
   sudo gitlab-ctl stop puma

   # Stop sidekiq
   sudo gitlab-ctl stop sidekiq

   # If on Ubuntu: remove the current package
   sudo dpkg -r gitlab-ee

   # If on Centos: remove the current package
   sudo yum remove gitlab-ee
   ```

1. 确定您要回滚到的极狐GitLab 版本：

   ```shell
   # (Replace with gitlab-ce if you have GitLab FOSS installed)

   # Ubuntu
   sudo apt-cache madison gitlab-ee

   # CentOS:
   sudo yum --showduplicates list gitlab-ee
   ```

1. 将极狐GitLab 回滚到所需版本（例如，回滚到极狐GitLab 19.2.1）：

   ```shell
   # (Replace with gitlab-ce if you have GitLab FOSS installed)

   # Ubuntu
   sudo apt install gitlab-ee=19.2.1-ee.0

   # CentOS:
   sudo yum install gitlab-ee-19.2.1-ee.0.el8
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. [恢复极狐GitLab](../../administration/backup_restore/restore_gitlab.md#restore-for-linux-package-installations)
   以完成回滚。

<a id="roll-back-a-docker-instance"></a>

## 回滚 Docker 实例

恢复操作会用较旧的状态覆盖所有较新的极狐GitLab 数据库内容。仅在必要时才建议回滚。例如，升级后测试发现无法快速解决的问题时。

> [!warning]
> 您必须至少拥有一个使用您要降级到的完全相同版本和版本类型创建的数据库备份。
> 需要该备份来还原升级期间所做的架构变更（迁移）。

要在升级后不久回滚极狐GitLab：

1. 按照升级流程操作，[指定一个较早的版本](../../install/docker/installation.md#find-the-gitlab-version-and-edition-to-use)
   而不是您已安装的版本。
1. 恢复您在升级前[所做的数据库备份](../../install/docker/backup.md#create-a-database-backup)。

   - [按照 Docker 镜像的恢复步骤操作](../../administration/backup_restore/restore_gitlab.md#restore-for-docker-image-and-gitlab-helm-chart-installations)，包括
     停止 Puma 和 Sidekiq。只需恢复数据库，因此请将 `SKIP=artifacts,repositories,registry,uploads,builds,pages,lfs,packages,terraform_state` 添加到 `gitlab-backup restore` 命令行参数中。
