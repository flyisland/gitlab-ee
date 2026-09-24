---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure your 极狐GitLab workspaces to manage your 极狐GitLab development environments.
title: 配置工作空间
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 功能标志 `remote_development_feature_flag` 在 极狐GitLab 16.0 的 JihuLab.com 和私有化部署上启用。
- 于 极狐GitLab 16.7 GA。功能标志 `remote_development_feature_flag` 已移除。

{{< /history >}}

您可以使用[工作空间](_index.md)为您的 极狐GitLab 项目创建和管理隔离的开发环境。每个工作空间都包含其自身的依赖项、库和工具集，您可以根据每个项目的特定需求进行自定义。

<a id="set-up-workspace-infrastructure"></a>

## 设置工作空间基础设施

在[创建工作空间](#create-a-workspace)之前，您只需设置一次基础设施。无论使用何种云提供商，要设置工作空间基础设施，您必须：

1. 设置一个受[极狐GitLab Kubernetes Agent](../clusters/agent/_index.md)支持的 Kubernetes 集群。请参阅[支持的 Kubernetes 版本](../clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。
1. 确保 Kubernetes 集群的自动扩缩容已启用。
1. 在 Kubernetes 集群中：
   1. 确认已定义[默认存储类](https://kubernetes.io/docs/concepts/storage/storage-classes/)，以便可以为每个工作空间动态配置持久卷。
1. 完成[设置极狐GitLab Kubernetes Agent 教程](set_up_gitlab_agent_and_proxies.md)中的所有步骤。
1. 可选。[在工作空间中构建和运行容器](#build-and-run-containers-in-a-workspace)。
1. 可选。[配置对私有容器镜像仓库的支持](#configure-support-for-private-container-registries)。
1. 可选。[配置工作空间的 sudo 访问](#configure-sudo-access-for-a-workspace)。

如果您使用 AWS，可以使用我们的 OpenTofu 教程。有关更多信息，请参见[在 AWS 上设置工作空间基础设施教程](set_up_infrastructure.md)。

<a id="create-a-workspace"></a>

## 创建工作空间

{{< history >}}

- **自动终止前时间** 于 极狐GitLab 16.0 引入。
- **对私有项目的支持** 于 极狐GitLab 16.4 引入。
- **Git 引用** 和 **Devfile 位置** 于 极狐GitLab 16.10 引入。
- **自动终止前时间** 于 极狐GitLab 16.10 重命名为 **工作空间将在以下时间后自动终止**。
- **变量** 于 极狐GitLab 17.1 引入。
- **工作空间将在以下时间后自动终止** 于 极狐GitLab 17.6 移除。
- **可以从合并请求页面创建工作空间** 于 极狐GitLab 18.0 引入。

{{< /history >}}

> [!warning]
> 请仅从受信任的项目创建工作空间。

先决条件：

- 您必须[设置工作空间基础设施](#set-up-workspace-infrastructure)。
- 您必须对工作空间和 Agent 项目具有 开发者、维护者 或 所有者 角色。

{{< tabs >}}

{{< tab title="从项目中" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **代码** > **新工作空间**。
1. 从 **集群 Agent** 下拉列表中，选择项目所属群组拥有的集群 Agent。
1. 从 **Git 引用** 下拉列表中，选择极狐GitLab 用于创建工作空间的分支、标签或提交哈希。默认为您正在查看的分支。
1. 从 **Devfile** 下拉列表中，选择以下一项：
   - [极狐GitLab 默认 devfile](_index.md#gitlab-default-devfile)。
   - [自定义 devfile](_index.md#custom-devfile)。
1. 在 **变量** 中，输入您希望注入工作空间的环境变量的键和值。要添加新变量，请选择 **添加变量**。
1. 选择 **创建工作空间**。

{{< /tab >}}

{{< tab title="从合并请求中" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求**。
1. 选择您要为其创建工作空间的合并请求。
1. 选择 **代码** > **在工作空间中打开**。
1. 从 **集群 Agent** 下拉列表中，选择项目所属群组拥有的集群 Agent。
1. 从 **Git 引用** 下拉列表中，选择极狐GitLab 用于创建工作空间的分支、标签或提交哈希。默认为合并请求的源分支。
1. 从 **Devfile** 下拉列表中，选择以下一项：
   - [极狐GitLab 默认 devfile](_index.md#gitlab-default-devfile)。
   - [自定义 devfile](_index.md#custom-devfile)。
1. 在 **变量** 中，输入您希望注入工作空间的环境变量的键和值。要添加新变量，请选择 **添加变量**。
1. 选择 **创建工作空间**。

{{< /tab >}}

{{< /tabs >}}

工作空间可能需要几分钟才能启动。要打开工作空间，请在 **预览** 下选择该工作空间。您还可以访问终端并安装任何所需的依赖项。

<a id="monitor-workspace-startup-progress"></a>

### 监控工作空间启动进度

当您启动工作空间时，可以通过检查工作空间日志来监控初始化任务和 `postStart` 事件的进度。有关更多信息，请参见[工作空间日志目录](_index.md#workspace-logs-directory)。

<a id="platform-compatibility"></a>

## 平台兼容性

工作空间的平台要求取决于您的开发需求。

对于基本的工作空间功能，工作空间可以在任何支持极狐GitLab Kubernetes Agent 的 `linux/amd64` Kubernetes 集群上运行，无论底层操作系统如何。

要选择适合您平台需求的方法，请参见[配置工作空间的 sudo 访问](#configure-sudo-access-for-a-workspace)。

<a id="build-and-run-containers-in-a-workspace"></a>

## 在工作空间中构建并运行容器

{{< history >}}

- 于 极狐GitLab 17.4 引入。

{{< /history >}}

开发环境通常需要在运行时构建和运行容器以管理和使用依赖项。要在工作空间中构建和运行容器，请参见[配置工作空间的 sudo 访问](#configure-sudo-access-for-a-workspace)。

<a id="configure-support-for-private-container-registries"></a>

## 配置对私有容器镜像仓库的支持

{{< history >}}

- 于 极狐GitLab 17.6 引入。

{{< /history >}}

要从私有容器镜像仓库中使用镜像：

1. 在 Kubernetes 中创建一个[镜像拉取密钥](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)。
1. 将此密钥的 `name` 和 `namespace` 添加到[极狐GitLab Kubernetes Agent 配置](gitlab_agent_configuration.md)中。

有关更多信息，请参见[`image_pull_secrets`](settings.md#image_pull_secrets)。

<a id="configure-sudo-access-for-a-workspace"></a>

## 配置工作空间的 sudo 访问

{{< history >}}

- 于 极狐GitLab 17.4 引入。

{{< /history >}}

开发环境通常需要 sudo 权限才能在运行时安装、配置和使用依赖项。选择适合您平台需求的方法：

| 方法                                   | 平台要求                                                                                                                         | 用途 |
|----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|------|
| [Sysbox](#with-sysbox)                 | 有关最新信息，请参见 [Sysbox 发行版兼容性矩阵](https://github.com/nestybox/sysbox/blob/master/docs/distro-compat.md)。             | 改善容器隔离性，并使容器能够运行与虚拟机相同的工作负载。 |
| [Kata Containers](#with-kata-containers) | 有关最新信息，请参见 [Kata Containers 安装指南](https://github.com/kata-containers/kata-containers/tree/main/docs/install)。      | 轻量级虚拟机性能类似容器，但提供了增强的工作负载隔离和安全性。 |
| [用户命名空间](#with-user-namespaces)   | Kubernetes 1.33 或更高版本默认启用了用户命名空间功能门控。有关最新信息，请参见 [Kubernetes 功能门控](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/)。 | 无需额外安装运行时。将容器用户与主机用户隔离，提高安全性。 |

先决条件：

- 您的容器镜像必须支持[任意用户 ID](_index.md#arbitrary-user-ids)。即使配置了 sudo 访问，在 [devfile](_index.md#devfile) 中使用的容器镜像也不能以用户 ID `0` 运行。

<a id="with-sysbox"></a>

### 使用 Sysbox

[Sysbox](https://github.com/nestybox/sysbox) 是一种容器运行时，可改善容器隔离性，并使容器能够运行与虚拟机相同的工作负载。

要使用 Sysbox 配置 sudo 访问：

1. 在您的 Kubernetes 集群中[安装 Sysbox](https://github.com/nestybox/sysbox#installation)。
1. 配置极狐GitLab Kubernetes Agent：
   - 设置默认运行时类。在 [`default_runtime_class`](settings.md#default_runtime_class) 中，输入 Sysbox 的运行时类。例如，`sysbox-runc`。
   - 启用特权升级。将 [`allow_privilege_escalation`](settings.md#allow_privilege_escalation) 设置为 `true`。
   - 配置 Sysbox 所需的注解。将 [`annotations`](settings.md#annotations) 设置为 `{"io.kubernetes.cri-o.userns-mode": "auto:size=65536"}`。

<a id="with-kata-containers"></a>

### 使用 Kata Containers

[Kata Containers](https://github.com/kata-containers/kata-containers) 是轻量级虚拟机的标准实现，其性能类似容器，但提供了虚拟机的隔离性和安全性。

要使用 Kata Containers 配置 sudo 访问：

1. 在您的 Kubernetes 集群中[安装 Kata Containers](https://github.com/kata-containers/kata-containers/tree/main/docs/install)。
1. 配置极狐GitLab Kubernetes Agent：
   - 设置默认运行时类。在 [`default_runtime_class`](settings.md#default_runtime_class) 中，输入 Kata Containers 的运行时类。例如，`kata-qemu`。
   - 启用特权升级。将 [`allow_privilege_escalation`](settings.md#allow_privilege_escalation) 设置为 `true`。

<a id="with-user-namespaces"></a>

### 使用用户命名空间

[用户命名空间](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/) 将容器用户与主机用户隔离。

要使用用户命名空间配置 sudo 访问：

1. 在您的 Kubernetes 集群中[配置用户命名空间](https://kubernetes.io/blog/2024/04/22/userns-beta/)。
1. 配置极狐GitLab Kubernetes Agent：
   - 将 [`use_kubernetes_user_namespaces`](settings.md#use_kubernetes_user_namespaces) 设置为 `true`。
   - 将 [`allow_privilege_escalation`](settings.md#allow_privilege_escalation) 设置为 `true`。

<a id="connect-to-a-workspace-with-ssh"></a>

## 通过 SSH 连接到工作空间

{{< history >}}

- 于 极狐GitLab 16.3 引入。

{{< /history >}}

先决条件：

- 您必须为 [devfile](_index.md#devfile) 中指定的镜像启用 SSH 访问。有关更多信息，请参见[更新工作空间容器镜像](#update-your-workspace-container-image)。
- 您必须配置一个指向极狐GitLab 工作空间代理的 TCP 负载均衡器。有关更多信息，请参见[更新您的 DNS 记录](set_up_gitlab_agent_and_proxies.md#update-your-dns-records)。

1. 获取 `gitlab-workspaces-proxy-ssh` 服务的外部 IP 地址：

   ```shell
   kubectl -n gitlab-workspaces get service gitlab-workspaces-proxy-ssh
   ```

1. 获取工作空间名称：
   1. 在顶部栏中，选择 **搜索或跳转到**。
   1. 选择 **您的工作**。
   1. 选择 **工作空间**。
   1. 复制您要连接到的工作空间的名称。
1. 运行以下命令：

   ```shell
   ssh <workspace_name>@<ssh_proxy_IP_address>
   ```

1. 对于密码，请输入至少具有 `read_api` 权限的个人访问令牌。

当您通过 TCP 负载均衡器连接到 `gitlab-workspaces-proxy` 时，`gitlab-workspaces-proxy` 会检查用户名（工作空间名称）并与极狐GitLab 交互以验证：
- 个人访问令牌
- 用户对工作空间的访问权限

<a id="update-your-workspace-container-image"></a>

### 更新工作空间容器镜像

您可以通过两种方式更新自定义工作空间镜像。

如果您的工作空间镜像基于[工作空间基础镜像](_index.md#workspace-base-image)，则 SSH 支持已配置并立即可用。这种方法可确保您的镜像包含所有必要的工作空间配置。
有关更多信息，请参见[创建自定义工作空间镜像](create_image.md)。

如果您不希望使用工作空间基础镜像，则可以从自己的基础镜像构建。如果这样做，请在您的运行时镜像中手动配置 SSH 支持：

1. 在您的运行时镜像中安装 [`sshd`](https://man.openbsd.org/sshd.8)。
1. 创建一个名为 `gitlab-workspaces` 的用户，以允许无密码访问您的容器。

以下是一个 SSH 配置示例：

```dockerfile
FROM golang:1.20.5-bullseye

# 安装 `openssh-server` 和其他依赖
RUN apt update \
    && apt upgrade -y \
    && apt install openssh-server sudo curl git wget software-properties-common apt-transport-https --yes \
    && rm -rf /var/lib/apt/lists/*

# 允许空密码
RUN sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth
RUN echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

# 生成工作空间主机密钥
RUN ssh-keygen -A
RUN chmod 775 /etc/ssh/ssh_host_rsa_key && \
    chmod 775 /etc/ssh/ssh_host_ecdsa_key && \
    chmod 775 /etc/ssh/ssh_host_ed25519_key

# 创建一个 `gitlab-workspaces` 用户
RUN useradd -l -u 5001 -G sudo -md /home/gitlab-workspaces -s /bin/bash gitlab-workspaces
RUN passwd -d gitlab-workspaces
ENV HOME=/home/gitlab-workspaces
WORKDIR $HOME
RUN mkdir -p /home/gitlab-workspaces && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

# 允许无密码登录访问 `/etc/shadow`
RUN chmod 775 /etc/shadow

USER gitlab-workspaces
```

