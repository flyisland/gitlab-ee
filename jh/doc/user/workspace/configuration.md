---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置您的极狐GitLab 工作区，以管理您的极狐GitLab 开发环境。
title: 配置工作区
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用[工作区](_index.md)为您的极狐GitLab 项目创建和管理隔离的开发环境。每个工作区都包含自己的一组依赖项、库和工具，您可以按每个项目的具体需求进行自定义。

<a id="set-up-workspace-infrastructure"></a>

## 设置工作区基础设施

在[创建工作区](#create-a-workspace)之前，您必须设置一次基础设施。无论使用哪种云服务商，要为工作区设置基础设施，您必须：

1. 设置一个[极狐GitLab Kubernetes Agent](../clusters/agent/_index.md) 支持的 Kubernetes 集群。
   请参阅[支持的 Kubernetes 版本](../clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。
1. 确保已为 Kubernetes 集群启用自动扩缩。
1. 在 Kubernetes 集群中：
   1. 确认已定义[默认存储类](https://kubernetes.io/docs/concepts/storage/storage-classes/)，
      以便为每个工作区动态预配卷。
1. 完成[设置极狐GitLab Kubernetes Agent 教程](set_up_gitlab_agent_and_proxies.md)中的所有步骤。
1. 可选。[在工作区中构建并运行容器](#build-and-run-containers-in-a-workspace)。
1. 可选。[配置对私有容器镜像仓库的支持](#configure-support-for-private-container-registries)。
1. 可选。[为工作区配置 sudo 访问权限](#configure-sudo-access-for-a-workspace)。

如果您使用 AWS，可以使用我们的 OpenTofu 教程。有关更多信息，请参阅[在 AWS 上设置工作区基础设施教程](set_up_infrastructure.md)。

<a id="create-a-workspace"></a>

## 创建工作区

> [!warning]
> 仅从受信任的项目创建工作区。

先决条件：

- 您必须[设置工作区基础设施](#set-up-workspace-infrastructure)。
- 您必须对工作区和 Agent 项目拥有开发者、维护者或所有者角色。

{{< tabs >}}

{{< tab title="从项目" >}}

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在项目页面上，选择右上角的**代码**下拉列表，然后在**工作区**部分中，选择**新建工作区**。
1. 从**集群代理**下拉列表中，选择项目所属群组拥有的集群代理。
1. 从 **Git 引用**下拉列表中，选择极狐GitLab 用于创建工作区的分支、标签或提交哈希。
   默认情况下，这是您当前查看的分支。
1. 从 **Devfile** 下拉列表中，选择以下之一：
   - [极狐GitLab 默认 devfile](_index.md#gitlab-default-devfile)。
   - [自定义 devfile](_index.md#custom-devfile)。
1. 在**变量**中，输入要注入工作区的环境变量的键和值。
   要添加新变量，请选择**添加变量**。
1. 选择**创建工作区**。

{{< /tab >}}

{{< tab title="From a merge request" >}}

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **合并请求**。
1. 选择要为其创建工作区的合并请求。
1. 选择**代码** > **在工作区中打开**。
1. 从**集群代理**下拉列表中，选择项目所属群组拥有的集群代理。
1. 从 **Git 引用**下拉列表中，选择极狐GitLab 用于创建工作区的分支、标签或提交哈希。
   默认情况下，这是合并请求的源分支。
1. 从 **Devfile** 下拉列表中，选择以下之一：
   - [极狐GitLab 默认 devfile](_index.md#gitlab-default-devfile)。
   - [自定义 devfile](_index.md#custom-devfile)。
1. 在**变量**中，输入要注入工作区的环境变量的键和值。
   要添加新变量，请选择**添加变量**。
1. 选择**创建工作区**。

{{< /tab >}}

{{< /tabs >}}

工作区可能需要几分钟才能启动。要打开工作区，请在**预览**下选择该工作区。您还可以访问终端，并安装任何必要的依赖项。

<a id="monitor-workspace-startup-progress"></a>

### 监控工作区启动进度

启动工作区时，您可以通过查看工作区日志来监控初始化任务和 `postStart` 事件的进度。有关更多信息，请参阅[工作区日志目录](_index.md#workspace-logs-directory)。

<a id="platform-compatibility"></a>

## 平台兼容性

工作区的平台要求取决于您的开发需求。

对于基本的工作区功能，工作区可运行在任何支持
极狐GitLab Kubernetes Agent 的 `linux/amd64` Kubernetes 集群上，无论底层操作系统是什么。

要选择适合您平台要求的方法，请参阅[为工作区配置 sudo 访问权限](#configure-sudo-access-for-a-workspace)。

<a id="build-and-run-containers-in-a-workspace"></a>

## 在工作区中构建并运行容器

开发环境通常需要在运行时构建并运行容器，以管理和使用依赖项。要在工作区中构建并运行容器，请参阅[为工作区配置 sudo 访问权限](#configure-sudo-access-for-a-workspace)。

<a id="configure-support-for-private-container-registries"></a>

## 配置对私有容器镜像仓库的支持

要使用来自私有容器镜像仓库的镜像：

1. 在 Kubernetes 中创建[镜像拉取密钥](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)。
1. 将此密钥的 `name` 和 `namespace` 添加到[极狐GitLab Kubernetes Agent 配置](gitlab_agent_configuration.md)中。

有关更多信息，请参阅 [`image_pull_secrets`](settings.md#image_pull_secrets)。

<a id="configure-sudo-access-for-a-workspace"></a>

## 为工作区配置 sudo 访问权限

开发环境通常需要在运行时使用 sudo 权限来安装、配置和使用依赖项。请选择适合您平台要求的方法：

| 方法                                   | 平台要求                                                                                                                                                                                                                                                                     | 用途 |
|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------|
| [Sysbox](#with-sysbox)                   | 有关最新信息，请参阅 [Sysbox 发行版兼容性矩阵](https://github.com/nestybox/sysbox/blob/master/docs/distro-compat.md)。                                                                                                                                     | 改善容器隔离，并使容器能够运行与虚拟机相同的工作负载。 |
| [Kata Containers](#with-kata-containers) | 有关最新信息，请参阅 [Kata Containers 安装指南](https://github.com/kata-containers/kata-containers/tree/main/docs/install)。                                                                                                                                     | 轻量级虚拟机的表现与容器类似，但提供更强的工作负载隔离和安全性。 |
| [用户命名空间](#with-user-namespaces) | Kubernetes 1.33 及更高版本的用户命名空间受默认启用的 Kubernetes 功能门控控制。有关最新信息，请参阅 [Kubernetes 功能门控](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/)。 | 无需额外安装运行时。将容器用户与主机用户隔离，以提高安全性。 |

先决条件：

- 您的容器镜像必须支持[任意用户 ID](_index.md#arbitrary-user-ids)。
  即使配置了 sudo 访问权限，[devfile](_index.md#devfile)中使用的容器镜像
  也不能以用户 ID `0` 运行。

<a id="with-sysbox"></a>

### 使用 Sysbox

[Sysbox](https://github.com/nestybox/sysbox) 是一种容器运行时，可改善容器隔离，并使容器能够运行与虚拟机相同的工作负载。

要使用 Sysbox 配置 sudo 访问权限：

1. 在您的 Kubernetes 集群中，[安装 Sysbox](https://github.com/nestybox/sysbox#installation)。
1. 配置极狐GitLab Kubernetes Agent：

   - 设置默认运行时类。在 [`default_runtime_class`](settings.md#default_runtime_class)中，
     输入 Sysbox 的运行时类。例如，`sysbox-runc`。
   - 启用权限提升。
     将 [`allow_privilege_escalation`](settings.md#allow_privilege_escalation) 设置为 `true`。
   - 配置 Sysbox 所需的注解。将 [`annotations`](settings.md#annotations) 设置为
     `{"io.kubernetes.cri-o.userns-mode": "auto:size=65536"}`。

<a id="with-kata-containers"></a>

### 使用 Kata Containers

[Kata Containers](https://github.com/kata-containers/kata-containers) 是轻量级虚拟机的
标准实现，其表现与容器类似，但提供虚拟机的工作负载隔离和安全性。

要使用 Kata Containers 配置 sudo 访问权限：

1. 在您的 Kubernetes 集群中，[安装 Kata Containers](https://github.com/kata-containers/kata-containers/tree/main/docs/install)。
1. 配置极狐GitLab Kubernetes Agent：

   - 设置默认运行时类。在 [`default_runtime_class`](settings.md#default_runtime_class)中，
     输入 Kata Containers 的运行时类。例如，`kata-qemu`。
   - 启用权限提升。
     将 [`allow_privilege_escalation`](settings.md#allow_privilege_escalation) 设置为 `true`。

<a id="with-user-namespaces"></a>

### 使用用户命名空间

[用户命名空间](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)可将容器用户与主机用户隔离。

要使用用户命名空间配置 sudo 访问权限：

1. 在您的 Kubernetes 集群中，[配置用户命名空间](https://kubernetes.io/blog/2024/04/22/userns-beta/)。
1. 配置极狐GitLab Kubernetes Agent：

   - 将 [`use_kubernetes_user_namespaces`](settings.md#use_kubernetes_user_namespaces) 设置为 `true`。
   - 将 [`allow_privilege_escalation`](settings.md#allow_privilege_escalation) 设置为 `true`。

<a id="connect-to-a-workspace-with-ssh"></a>

## 使用 SSH 连接到工作区

先决条件：

- 您必须为 [devfile](_index.md#devfile)中指定的镜像启用 SSH 访问。
  有关更多信息，请参阅[更新工作区容器镜像](#update-your-workspace-container-image)。
- 您必须配置一个指向极狐GitLab 工作区代理的 TCP 负载均衡器。
  有关更多信息，请参阅[更新您的 DNS 记录](set_up_gitlab_agent_and_proxies.md#update-your-dns-records)。

要使用 SSH 客户端连接到工作区：

1. 获取 `gitlab-workspaces-proxy-ssh` 服务的外部 IP 地址：

   ```shell
   kubectl -n gitlab-workspaces get service gitlab-workspaces-proxy-ssh
   ```

1. 获取工作区的名称：

   1. 在顶部栏中，选择**搜索或跳转到**。
   1. 选择**您的工作**。
   1. 选择**工作区**。
   1. 复制您要连接的工作区的名称。

1. 运行以下命令：

   ```shell
   ssh <workspace_name>@<ssh_proxy_IP_address>
   ```

1. 在密码处，输入具有至少 `read_api` 范围的个人访问令牌。

当您通过 TCP 负载均衡器连接到 `gitlab-workspaces-proxy` 时，`gitlab-workspaces-proxy` 会检查用户名（工作区名称），并与极狐GitLab 交互以验证：

- 个人访问令牌
- 用户对工作区的访问权限

<a id="update-your-workspace-container-image"></a>

### 更新工作区容器镜像

您可以通过两种方式更新自定义工作区镜像。

如果您的工作区镜像基于[工作区基础镜像](_index.md#workspace-base-image)，则 SSH 支持已配置好并可直接使用。此方法可确保您的镜像具有所有必要的工作区配置。有关更多信息，请参阅[创建自定义工作区镜像](create_image.md)。

如果您不想使用工作区基础镜像，可以从自己的基础镜像构建。如果这样做，请在运行时镜像中手动配置 SSH 支持：

1. 在您的运行时镜像中安装 [`sshd`](https://man.openbsd.org/sshd.8)。
1. 创建一个名为 `gitlab-workspaces`的用户，以允许无需密码访问您的容器。

以下是一个 SSH 配置示例：

```dockerfile
FROM golang:1.20.5-bullseye

# Install `openssh-server` and other dependencies
RUN apt update \
    && apt upgrade -y \
    && apt install openssh-server sudo curl git wget software-properties-common apt-transport-https --yes \
    && rm -rf /var/lib/apt/lists/*

# Permit empty passwords
RUN sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth
RUN echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

# Generate a workspace host key
RUN ssh-keygen -A
RUN chmod 775 /etc/ssh/ssh_host_rsa_key && \
    chmod 775 /etc/ssh/ssh_host_ecdsa_key && \
    chmod 775 /etc/ssh/ssh_host_ed25519_key

# Create a `gitlab-workspaces` user
RUN useradd -l -u 5001 -G sudo -md /home/gitlab-workspaces -s /bin/bash gitlab-workspaces
RUN passwd -d gitlab-workspaces
ENV HOME=/home/gitlab-workspaces
WORKDIR $HOME
RUN mkdir -p /home/gitlab-workspaces && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

# Allow sign-in access to `/etc/shadow`
RUN chmod 775 /etc/shadow

USER gitlab-workspaces
```
