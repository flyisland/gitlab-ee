---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Linux 软件包极狐GitLab 实例迁移到 Docker
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用以下两种方法之一，将现有的 Linux 软件包极狐GitLab 实例迁移到 Docker：

- **复用现有数据目录**：将现有数据目录移动到 Docker 卷路径中。使用此方法可将数据保留在原位，无需完整的备份和恢复周期。
- **备份并恢复**：在 Linux 软件包实例上创建极狐GitLab 备份，设置全新的 Docker 实例，然后恢复备份。使用此方法进行干净迁移，并在需要时支持回滚。

<a id="prerequisites"></a>

## 先决条件

- Linux 软件包实例和 Docker 镜像上的极狐GitLab 版本必须匹配。如有必要，请在迁移到 Docker 之前升级您的 Linux 软件包实例。
- 目标服务器上已[安装 Docker](installation.md)。

<a id="reuse-existing-data-directories"></a>

## 复用现有数据目录

通过复用现有数据目录，将 Linux 软件包极狐GitLab 实例迁移到 Docker。

<a id="stop-the-linux-package-instance"></a>

### 停止 Linux 软件包实例

停止所有极狐GitLab 服务：

```shell
sudo gitlab-ctl stop
```

<a id="prepare-the-volume-directories"></a>

### 准备卷目录

如何准备卷目录取决于 Docker 的运行位置：

- 如果 Docker 与 Linux 软件包实例运行在同一台服务器上，您可以直接挂载现有目录，无需复制。将 Docker Compose 文件中的卷路径设置为 Linux 软件包位置：

  ```yaml
  volumes:
    - '/etc/gitlab:/etc/gitlab'
    - '/var/log/gitlab:/var/log/gitlab'
    - '/var/opt/gitlab:/var/opt/gitlab'
  ```

- 如果您要迁移到其他服务器，或希望将 Docker 卷与 Linux 软件包路径分开，请先将目录复制到新位置。

  1. 将 `$GITLAB_HOME` 设置为目标目录：

     ```shell
     export GITLAB_HOME=/srv/gitlab
     sudo mkdir -p $GITLAB_HOME
     ```

  1. 复制（或移动）数据、日志和配置目录：

     ```shell
     sudo cp -a /var/opt/gitlab $GITLAB_HOME/data
     sudo cp -a /var/log/gitlab $GITLAB_HOME/logs
     sudo cp -a /etc/gitlab     $GITLAB_HOME/config
     ```

     要移动而非复制，请使用 `mv` 而不是 `cp -a`。

> [!warning]
> 在启动容器之前，不要将主机目录的所有权更改为 `root:root`。这样做会阻止容器启动，并阻止 `update-permissions` 脚本在之后纠正所有权。

验证代码仓库目录存在且是真实目录，而不是损坏的符号链接：

```shell
ls -la $GITLAB_HOME/data/git-data/repositories
```

如果目录缺失或是损坏的符号链接，请创建它：

```shell
sudo mkdir -p $GITLAB_HOME/data/git-data/repositories
```

<a id="align-user-and-group-identifiers"></a>

### 对齐用户和组标识符

极狐GitLab Docker 镜像包含一个名为 `update-permissions` 的内置脚本，用于设置所有极狐GitLab 目录的正确所有权。如果 Linux 软件包实例使用的 UID 与 Docker 镜像期望的不同（可能是因发行版而异的操作系统默认值，或[显式配置的值](https://gitlab.cn/docs/omnibus/settings/configuration/#specify-numeric-user-and-group-identifiers)），请在启动容器前，从挂载了卷的临时容器中运行 `update-permissions`。这会在首次启动前纠正所有权：

```shell
docker run --rm \
  -v <config_path>:/etc/gitlab \
  -v <logs_path>:/var/log/gitlab \
  -v <data_path>:/var/opt/gitlab \
  --entrypoint /bin/bash \
  gitlab/gitlab-ee:<version> \
  -c "update-permissions"
```

将 `<config_path>`、`<logs_path>` 和 `<data_path>` 替换为您在[准备卷目录](#prepare-the-volume-directories)中确定的主机路径。

<a id="start-gitlab-in-docker"></a>

### 在 Docker 中启动极狐GitLab

按照[安装说明](installation.md)创建 Docker Compose 文件或 Docker Engine 命令，以挂载您准备好的目录：

```yaml
volumes:
  - '$GITLAB_HOME/config:/etc/gitlab'
  - '$GITLAB_HOME/logs:/var/log/gitlab'
  - '$GITLAB_HOME/data:/var/opt/gitlab'
```

容器启动后，运行 reconfigure：

```shell
docker exec -it <container_name> gitlab-ctl reconfigure
```

验证安装：

```shell
docker exec -it <container_name> gitlab-rake gitlab:check
```

<a id="back-up-the-linux-package-instance-and-restore-to-the-docker-instance"></a>

## 备份 Linux 软件包实例并恢复到 Docker 实例

<a id="create-a-backup-on-the-linux-package-instance"></a>

### 在 Linux 软件包实例上创建备份

在停止 Linux 软件包实例之前，请创建备份：

```shell
sudo gitlab-backup create
```

将您的密钥文件复制到安全位置：

```shell
sudo cp /etc/gitlab/gitlab-secrets.json /your/backup/location/
```

更多信息，请参阅[备份极狐GitLab](../../administration/backup_restore/backup_gitlab.md)。

<a id="stop-the-linux-package-instance-1"></a>

### 停止 Linux 软件包实例

停止所有极狐GitLab 服务：

```shell
sudo gitlab-ctl stop
```

<a id="set-up-the-docker-instance"></a>

### 设置 Docker 实例

按照[安装说明](installation.md)设置新的 Docker 实例。将 `$GITLAB_HOME` 设置为您为卷创建的目录，例如：

```shell
export GITLAB_HOME=/srv/gitlab
```

启动容器一次以初始化卷目录，然后在恢复前停止它：

```shell
docker compose up -d
docker compose stop
```

<a id="restore-the-backup"></a>

### 恢复备份

1. 将备份归档复制到 Docker 数据卷中：

   ```shell
   sudo cp <timestamp>_gitlab_backup.tar $GITLAB_HOME/data/backups/
   ```

1. 将密钥文件复制到 Docker 配置卷中：

   ```shell
   sudo cp gitlab-secrets.json $GITLAB_HOME/config/gitlab-secrets.json
   ```

1. 启动容器并运行恢复：

   ```shell
   docker compose start
   docker exec -it <container_name> gitlab-backup restore BACKUP=<timestamp>
   ```

1. 恢复完成后，重新配置并重启：

   ```shell
   docker exec -it <container_name> gitlab-ctl reconfigure
   docker exec -it <container_name> gitlab-ctl restart
   ```

1. 验证安装：

   ```shell
   docker exec -it <container_name> gitlab-rake gitlab:check
   ```

<a id="troubleshooting"></a>

## 故障排查

将 Linux 软件包极狐GitLab 实例迁移到 Docker 时，您可能会遇到以下问题。

<a id="permission-errors-after-starting"></a>

### 启动后出现权限错误

如果容器启动但报告权限错误，请运行：

```shell
sudo docker exec <container_name> update-permissions
sudo docker restart <container_name>
```

当 Linux 软件包实例为系统账户使用的 UID 与 Docker 镜像期望的不同时，会发生此问题。为防止此问题，请按照[对齐用户和组标识符](#align-user-and-group-identifiers)中的说明，在启动前运行 `update-permissions`。

<a id="errors-when-reusing-data-from-another-instance"></a>

### 复用其他实例的数据时出错

复用其他实例的数据时，您可能会遇到以下问题。

<a id="stat-missing-operand-error-on-startup"></a>

#### 启动时出现 `stat: missing operand` 错误

当容器找不到 `git-data/repositories` 目录时，会发生此错误：

```plaintext
stat: missing operand
Expected process to exit with [0], but received '1'
Ran stat --printf='%U' $(readlink -f /var/opt/gitlab/git-data/repositories) returned 1
```

在主机上创建缺失的目录，然后重启容器：

```shell
sudo mkdir -p $GITLAB_HOME/data/git-data/repositories
sudo docker restart <container_name>
```

<a id="container-exits-immediately-and-restart-loop-blocks-docker-exec"></a>

#### 容器立即退出，重启循环阻止 `docker exec`

如果容器启动后立即退出，您将无法使用 `docker exec` 进行调查或运行 `update-permissions`。相反，请使用[对齐用户和组标识符](#align-user-and-group-identifiers)中的相同命令直接运行 `update-permissions`，该命令会启动一个挂载了卷的临时容器并纠正所有权，而无需主容器运行。
