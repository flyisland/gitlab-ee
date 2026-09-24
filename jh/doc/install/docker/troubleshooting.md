---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Docker 容器中运行的极狐GitLab 故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在 Docker 容器中安装极狐GitLab 时，您可能会遇到以下问题。

<a id="diagnose-potential-problems"></a>

## 诊断潜在问题

以下命令在排查 Docker 容器中的极狐GitLab 实例时非常有用：

读取容器日志：

```shell
sudo docker logs gitlab
```

进入正在运行的容器：

```shell
sudo docker exec -it gitlab /bin/bash
```

您可以从容器内部管理极狐GitLab 容器，就像管理 [Linux 软件包安装](https://jihulab.com/gitlab-cn/omnibus-gitlab/blob/master/README.md) 一样。

<a id="500-internal-error"></a>

## 500 内部错误

在更新 Docker 镜像时，您可能会遇到所有路径都显示 `500` 页面的问题。如果发生这种情况，请重新启动容器：

```shell
sudo docker restart gitlab
```

<a id="permission-problems"></a>

## 权限问题

从旧版极狐GitLab Docker 镜像更新时，您可能会遇到权限问题。这是因为以前镜像中的用户权限没有正确保留。有一个脚本可以修复所有文件的权限。

要修复您的容器，请执行 `update-permissions`，然后重新启动容器：

```shell
sudo docker exec gitlab update-permissions
sudo docker restart gitlab
```

<a id="error-executing-action-run-on-resource-ruby_block"></a>

## 执行资源 `ruby_block` 上的操作时出错

在 Windows 或 Mac 上使用 Docker Toolbox 配合 Oracle VirtualBox 并使用 Docker 卷时，会发生此错误：

```plaintext
Error executing action run on resource ruby_block[directory resource: /data/GitLab]
```

`/c/Users` 卷作为 VirtualBox 共享文件夹挂载，不支持所有 POSIX 文件系统特性。目录的所有权和权限无法在不重新挂载的情况下更改，因此极狐GitLab 会失败。

请改用适用于您平台的本地 Docker 安装，而不是使用 Docker Toolbox。

如果您无法使用本地 Docker 安装（Windows 10 家庭版或 Windows 7/8），另一种解决方案是为 Docker Toolbox 的 Boot2docker 设置 NFS 挂载，而不是使用 VirtualBox 共享。

<a id="-dev-shm-mount-not-having-enough-space-in-docker-container"></a>

## Docker 容器中 /dev/shm 挂载空间不足

极狐GitLab 在 `/-/metrics` 提供了一个 Prometheus 指标端点，用于公开极狐GitLab 的健康和性能统计信息。生成这些统计信息所需的文件会写入临时文件系统（如 `/run` 或 `/dev/shm`）。

默认情况下，Docker 为共享内存目录（挂载在 `/dev/shm`）分配 64 MB。这不足以容纳生成的所有 Prometheus 指标相关文件，并会产生类似以下的错误日志：

```plaintext
writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/gauge_all_sidekiq_0-1.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
writing value to /dev/shm/gitlab/sidekiq/histogram_sidekiq_0-0.db failed with unmapped file
```

虽然您可以在 **管理员** 区域关闭 Prometheus 指标，但解决此问题的推荐方案是 [安装](configuration.md#pre-configure-docker-container) 时将共享内存设置为至少 256 MB。如果您使用 `docker run`，可以传递标志 `--shm-size 256m`。如果您使用 `docker-compose.yml` 文件，可以设置 `shm_size` 键。

<a id="docker-containers-exhausts-space-due-to-the-json-file"></a>

## Docker 容器因 `json-file` 耗尽空间

Docker 使用 [`json-file` 默认日志驱动](https://docs.docker.com/config/containers/logging/configure/#configure-the-default-logging-driver)，该驱动默认不执行日志轮转。由于缺乏轮转，`json-file` 驱动存储的日志文件对于生成大量输出的容器可能会消耗大量磁盘空间，这可能导致磁盘空间耗尽。为解决此问题，在可用时使用 [`journald`](https://docs.docker.com/config/containers/logging/journald/) 作为日志驱动，或使用 [其他支持本地轮转的驱动](https://docs.docker.com/config/containers/logging/configure/#supported-logging-drivers)。

<a id="buffer-overflow-error-when-starting-docker"></a>

## 启动 Docker 时出现缓冲区溢出错误

如果您收到此缓冲区溢出错误，应清除 `/var/log/gitlab` 中的旧日志文件：

```plaintext
buffer overflow detected : terminated
xargs: tail: terminated by signal 6
```

删除旧日志文件有助于修复该错误，并确保实例干净启动。

<a id="threaderror-can-t-create-thread-operation-not-permitted"></a>

## ThreadError 无法创建线程 操作不被允许

```plaintext
can't create Thread: Operation not permitted
```

该错误发生在使用较新的 `glibc` 版本构建的容器在不支持 `clone3` 函数的主机上运行时。在极狐GitLab 16.0 及更高版本中，容器镜像包含 Ubuntu 22.04 Linux 软件包，该软件包使用较新的 `glibc` 版本构建。

此问题不会出现在较新的容器运行时工具（例如 [Docker 20.10.10](https://github.com/moby/moby/pull/42836)）中。

要解决此问题，请将 Docker 更新到 20.10.10 或更高版本。