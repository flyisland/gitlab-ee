---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 升级
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在大多数情况下，升级极狐GitLab 就像下载最新的 Docker 镜像标签一样简单。

<a id="upgrade-gitlab-using-docker-engine"></a>

## 使用 Docker Engine 升级极狐GitLab

要升级通过 [Docker Engine 安装](installation.md#install-gitlab-by-using-docker-engine) 的极狐GitLab 实例：

1. 创建一个[备份](backup.md)。至少备份[数据库](backup.md#create-a-database-backup)和极狐GitLab 密钥文件。

1. 停止运行的容器：

   ```shell
   sudo docker stop gitlab
   ```

1. 删除现有容器：

   ```shell
   sudo docker rm gitlab
   ```

1. 拉取新镜像：

   ```shell
   sudo docker pull registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
   ```

1. 确保 `GITLAB_HOME` 环境变量已[定义](installation.md#create-a-directory-for-the-volumes)：

   ```shell
   echo $GITLAB_HOME
   ```

1. 使用[之前指定的选项](installation.md#install-gitlab-by-using-docker-engine)重新创建容器：

   ```shell
   sudo docker run --detach \
   --hostname gitlab.example.com \
   --publish 443:443 --publish 80:80 --publish 22:22 \
   --name gitlab \
   --restart always \
   --volume $GITLAB_HOME/config:/etc/gitlab \
   --volume $GITLAB_HOME/logs:/var/log/gitlab \
   --volume $GITLAB_HOME/data:/var/opt/gitlab \
   --shm-size 256m \
   registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
   ```

首次运行时，极狐GitLab 会重新配置并升级自身。

在升级到不同版本时，请参考极狐GitLab 的[升级建议](../../policy/maintenance.md#upgrade-recommendations)。

<a id="upgrade-gitlab-using-docker-compose"></a>

## 使用 Docker Compose 升级极狐GitLab

要升级通过 [Docker Compose 安装](installation.md#install-gitlab-by-using-docker-compose) 的极狐GitLab 实例：

1. 进行[备份](backup.md)。至少备份[数据库](backup.md#create-a-database-backup)和极狐GitLab 密钥文件。
1. 编辑 `docker-compose.yml` 并更改要拉取的版本。
1. 下载最新版本并升级您的极狐GitLab 实例：

   ```shell
   docker compose pull
   docker compose up -d
   ```

<a id="downgrade-gitlab"></a>

## 降级极狐GitLab

恢复会将所有较新的极狐GitLab 数据库内容覆盖为较旧的状态。仅在必要时建议降级。例如，如果升级后测试发现问题且无法快速解决。

{{< alert type="warning" >}}

您必须至少有一个数据库备份，该备份与您要降级到的版本和版本完全相同。备份是恢复升级期间进行的架构更改（迁移）所必需的。

{{< /alert >}}

在升级后不久降级极狐GitLab：

1. 按照升级程序[指定的较早版本](installation.md#find-the-gitlab-version-and-edition-to-use)进行操作。

1. 恢复您在升级前创建的[数据库备份](backup.md#create-a-database-backup)。

   - [按照 Docker 镜像的恢复步骤](../../administration/backup_restore/restore_gitlab.md#restore-for-docker-image-and-gitlab-helm-chart-installations)，包括停止 Puma 和 Sidekiq。只需恢复数据库，因此在 `gitlab-backup restore` 命令行参数中添加 `SKIP=artifacts,repositories,registry,uploads,builds,pages,lfs,packages,terraform_state`。
