---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Docker 容器中运行的极狐GitLab 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在 Docker 容器中安装极狐GitLab 时，您可能会遇到以下问题。

<a id="diagnose-potential-problems"></a>

## 诊断潜在问题

在排查 Docker 容器中的极狐GitLab 实例问题时，以下命令很有用：

查看容器日志：

```shell
sudo docker logs gitlab
```

进入正在运行的容器：

```shell
sudo docker exec -it gitlab /bin/bash
```

您可以像管理 [Linux 软件包安装](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/README.md)一样，从容器内部管理极狐GitLab 容器。

<a id="500-internal-error"></a>

## 500 内部错误

更新 Docker 镜像时，您可能会遇到所有路径都显示 `500` 页面的问题。如果出现这种情况，请重启容器：

```shell
sudo docker restart gitlab
```

<a id="permission-problems"></a>

## 权限问题

从较旧的极狐GitLab Docker 镜像更新时，您可能会遇到权限问题。当之前镜像中的用户权限未被正确保留时，就会出现这种情况。有一个脚本可以修复所有文件的权限。

要修复您的容器，请执行 `update-permissions`，然后重启容器：

```shell
sudo docker exec gitlab update-permissions
sudo docker restart gitlab
```

<a id="error-executing-action-run-on-resource-ruby_block"></a>

## 在资源 `ruby_block` 上执行操作 run 时出错

此错误发生在 Windows 或 Mac 上使用 Docker Toolbox 搭配 Oracle VirtualBox，并使用 Docker 卷时：

```plaintext
Error executing action run on resource ruby_block[directory resource: /data/GitLab]
```

`/c/Users` 卷被挂载为 VirtualBox 共享文件夹，不支持所有 POSIX 文件系统特性。如果不重新挂载，就无法更改目录的所有权和权限，极狐GitLab 会失败。

请改用适用于您平台的原生 Docker 安装，而不要使用 Docker Toolbox。

如果您无法使用原生 Docker 安装（Windows 10 家庭版，或 Windows 7/8），另一种解决方案是为 Docker Toolbox Boot2docker 设置 NFS 挂载，而不是 VirtualBox 共享。

<a id="linux-acl-issues"></a>

## Linux ACL 问题

如果您在 Docker 主机上使用文件 ACL，则 `docker` 组需要对卷拥有完全访问权限，极狐GitLab 才能正常工作：

```shell
getfacl $GITLAB_HOME

# file: $GITLAB_HOME
# owner: XXXX
# group: XXXX
user::rwx
group::rwx
group:docker:rwx
mask::rwx
default:user::rwx
default:group::rwx
default:group:docker:rwx
default:mask::rwx
default:other::r-x
```

如果这些值不正确，请使用以下命令设置：

```shell
sudo setfacl -mR default:group:docker:rwx $GITLAB_HOME
```

默认组名为 `docker`。如果您更改了组名，则需要调整该命令。

<a id="devshm-mount-not-having-enough-space-in-docker-container"></a>

## Docker 容器中 `/dev/shm` 挂载空间不足

极狐GitLab 自带位于 `/-/metrics`的 Prometheus 指标端点，用于公开极狐GitLab 的健康状况和性能统计信息。所需文件会写入临时文件系统（如 `/run` 或 `/dev/shm`）。

默认情况下，Docker 为共享内存目录（挂载于 `/dev/shm`）分配 64 MB。这不足以容纳生成的所有 Prometheus 指标相关文件，并会产生如下错误日志：

```plaintext
writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
```

虽然您可以在**管理**区域中关闭 Prometheus 指标，但解决此问题的推荐方法是[安装](configuration.md#pre-configure-docker-container)时将共享内存设置为至少 256 MB。如果您使用 `docker run`，可以传入 `--shm-size 256m` 标志。如果您使用 `docker-compose.yml` 文件，可以设置 `shm_size` 键。

<a id="docker-containers-exhaust-space-due-to-the-json-file"></a>

## Docker 容器因 `json-file` 耗尽空间

Docker 使用 [`json-file` 默认日志驱动](https://docs.docker.com/config/containers/logging/configure/#configure-the-default-logging-driver)，该驱动默认不执行日志轮转。由于缺少轮转，`json-file` 驱动存储的日志文件可能会为产生大量输出的容器占用大量磁盘空间。这可能导致磁盘空间耗尽。要解决此问题，请在可用时使用 [`journald`](https://docs.docker.com/engine/logging/drivers/journald/) 作为日志驱动，或使用[其他支持原生轮转的驱动](https://docs.docker.com/config/containers/logging/configure/#supported-logging-drivers)。

<a id="buffer-overflow-error-when-starting-docker"></a>

## 启动 Docker 时出现缓冲区溢出错误

如果您收到此缓冲区溢出错误，应清除 `/var/log/gitlab`中的旧日志文件：

```plaintext
buffer overflow detected : terminated
xargs: tail: terminated by signal 6
```

删除旧日志文件有助于修复该错误，并确保实例干净启动。

<a id="errors-when-reusing-data-from-a-previous-installation"></a>

## 复用先前安装的数据时出错

复用另一个实例的数据时，您可能会遇到以下问题。

<a id="stat-missing-operand-error-on-startup"></a>

### 启动时出现 `stat: missing operand` 错误

此错误发生在从 Linux 软件包安装迁移，且主机卷中的 `git-data/repositories` 目录缺失或为损坏的符号链接时：

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

有关完整的迁移指南，请参阅
[将 Linux 软件包极狐GitLab 实例迁移到 Docker](migrate.md)。

<a id="container-exits-immediately-and-restart-loop-blocks-docker-exec"></a>

### 容器立即退出且重启循环阻止 `docker exec`

如果容器启动失败并不断重启，您将无法使用 `docker exec` 进行调查。请改为直接在镜像中启动 shell：

```shell
docker run --rm -it --entrypoint /bin/bash gitlab/gitlab-ee:<version>
```

使用此 shell 检查预期的目录结构，并将其与主机上挂载的卷进行比较。

<a id="threaderror-cant-create-thread-operation-not-permitted"></a>

## ThreadError can't create Thread Operation not permitted

```plaintext
can't create Thread: Operation not permitted
```

此错误发生在使用较新 `glibc` 版本构建的容器运行于[不支持 clone3 函数的主机](https://github.com/moby/moby/issues/42680)上时。该容器镜像包含使用较新 `glibc` 版本构建的 Ubuntu 22.04 Linux 软件包。

此问题不会出现在 [Docker 20.10.10](https://github.com/moby/moby/pull/42836) 等较新的容器运行时工具中。

要解决此问题，请将 Docker 更新到 20.10.10 或更高版本。
