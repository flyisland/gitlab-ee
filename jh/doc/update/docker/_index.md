---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 Docker 实例
description: Upgrade a single-node Docker-based instance.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级基于 Docker 的实例到更高版本的极狐GitLab。

<a id="prerequisites"></a>

## 先决条件

在升级 Docker 实例之前，您必须先[阅读所需信息并执行所需步骤](../plan_your_upgrade.md)。

<a id="upgrade-a-docker-based-instance"></a>

## 升级基于 Docker 的实例

要升级基于 Docker 的实例：

1. 考虑在升级期间[开启维护模式](../../administration/maintenance_mode/_index.md)。
1. [暂停运行中的 CI/CD 流水线和作业](../plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. [升级极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 到与目标极狐GitLab 版本相同的版本。
1. 通过以下任一方式升级极狐GitLab 本身：
   - [使用 Docker Engine](#upgrade-with-docker-engine)。
   - [使用 Docker Compose](#upgrade-with-docker-compose)。

升级后：

1. [恢复运行中的 CI/CD 流水线和作业](../plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，[关闭维护模式](../../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[升级健康检查](../plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="upgrade-with-docker-engine"></a>

### 使用 Docker Engine 升级

要升级[使用 Docker Engine 安装](../../install/docker/installation.md#install-gitlab-by-using-docker-engine)的极狐GitLab 实例：

1. 创建[备份](../../install/docker/backup.md)。至少备份[数据库](../../install/docker/backup.md#create-a-database-backup)和极狐GitLab secrets 文件。
1. 停止正在运行的容器：

   ```shell
   sudo docker stop gitlab
   ```

1. 移除现有容器：

   ```shell
   sudo docker rm gitlab
   ```

1. 拉取新镜像：

   {{< tabs >}}

   {{< tab title="极狐GitLab 企业版" >}}

   ```shell
   sudo docker pull registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
   ```

   {{< /tab >}}

   {{< tab title="极狐GitLab 基础版" >}}

   ```shell
   sudo docker pull registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 确保 `GITLAB_HOME` 环境变量已[定义](../../install/docker/installation.md#create-a-directory-for-the-volumes)：

   ```shell
   echo $GITLAB_HOME
   ```

1. 使用[先前指定的](../../install/docker/installation.md#install-gitlab-by-using-docker-engine)选项重新创建容器：

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

首次运行时，极狐GitLab 会自行重新配置和升级。

<a id="upgrade-with-docker-compose"></a>

### 使用 Docker Compose 升级

要升级[使用 Docker Compose 安装](../../install/docker/installation.md#install-gitlab-by-using-docker-compose)的极狐GitLab 实例：

1. 创建[备份](../../install/docker/backup.md)。至少备份[数据库](../../install/docker/backup.md#create-a-database-backup)和极狐GitLab secrets 文件。
1. 编辑 `docker-compose.yml` 并更改要拉取的版本。
1. 下载最新版本并升级您的极狐GitLab 实例：

   ```shell
   docker compose pull
   docker compose up -d
   ```
