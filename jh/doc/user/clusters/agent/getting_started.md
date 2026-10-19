---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 开始将 Kubernetes 集群连接到极狐GitLab
---

本页面将指导您在单个项目中设置基本的 Kubernetes 集成。如果您是初次接触极狐GitLab Kubernetes Agent、基于拉取的部署或 Flux，建议从这里开始。

完成本教程后，您将能够：

- 通过实时 Kubernetes 仪表板查看 Kubernetes 集群的状态。
- 使用 Flux 向集群部署更新。
- 使用极狐GitLab CI/CD 向集群部署更新。

<a id="before-you-begin"></a>

## 开始之前

在完成本教程之前，请确保您具备以下条件：

- 一个可以通过 `kubectl` 在本地访问的 Kubernetes 集群。
  要了解极狐GitLab 支持哪些 Kubernetes 版本，请参阅[极狐GitLab 功能支持的 Kubernetes 版本](_index.md#supported-kubernetes-versions-for-gitlab-features)。

  您可以运行以下命令来检查一切是否已正确配置：

  ```shell
  kubectl cluster-info
  ```

<a id="install-and-configure-flux"></a>

## 安装并配置 Flux

[Flux](https://fluxcd.io/flux/) 是 GitOps 部署（也称为基于拉取的部署）的推荐工具。Flux 是一个成熟的 CNCF 项目。

要安装 Flux：

- 完成 Flux 文档中的[安装 Flux CLI](https://fluxcd.io/flux/installation/#install-the-flux-cli) 步骤。

运行以下命令检查 Flux CLI 是否已正确安装：

```shell
flux -v
```

<a id="create-a-personal-access-token"></a>

### 创建个人访问令牌

要使用 Flux CLI 进行身份验证，请创建一个具有 `api` 作用域的个人访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 输入令牌的名称和可选的到期日期。
1. 选择 `api` 作用域。
1. 选择**创建个人访问令牌**。

您也可以使用具有 `api` 作用域和 `maintainer` 角色的[项目访问令牌](../../project/settings/project_access_tokens.md)或[群组访问令牌](../../group/settings/group_access_tokens.md)。

<a id="bootstrap-flux"></a>

### 引导 Flux

在本节中，您将使用 [`flux bootstrap`](https://fluxcd.io/flux/installation/bootstrap/gitlab/) 命令将 Flux 引导到空的极狐GitLab 代码仓库中。

要引导 Flux 安装：

- 运行 `flux bootstrap gitlab` 命令。例如：

  ```shell
  flux bootstrap gitlab \
  --hostname=gitlab.example.org \
  --owner=my-group/optional-subgroup \
  --repository=my-repository \
  --branch=main \
  --path=clusters/testing \
  --deploy-token-auth
  ```

`bootstrap`的参数如下：

| 参数     | 描述 |
|--------------|-------------|
| `hostname`   | 极狐GitLab 实例的主机名。 |
| `owner`      | 包含 Flux 代码仓库的极狐GitLab 群组。 |
| `repository` | 包含 Flux 代码仓库的极狐GitLab 项目。 |
| `branch`     | 提交更改所到的 Git 分支。 |
| `path`       | 存储 Flux 配置的文件夹的文件路径。 |

引导脚本会执行以下操作：

1. 创建一个部署令牌，并将其保存为 Kubernetes `secret`。
1. 如果 `--repository` 参数指定的项目不存在，则创建一个空的极狐GitLab 项目。
1. 在 `--path` 参数指定的文件夹中为您的项目生成 Flux 定义文件。
1. 将定义文件提交到 `--branch` 参数指定的分支。
1. 将定义文件应用到您的集群。

运行脚本后，Flux 将准备好管理自身以及您添加到极狐GitLab 项目和路径中的任何其他资源。

本教程的其余部分假设您的路径为 `clusters/testing`，并且您的项目位于 `my-group/optional-subgroup/my-repository` 下。

<a id="set-up-the-agent-connection"></a>

## 设置代理连接

要连接您的集群，您需要安装极狐GitLab Kubernetes Agent。
您可以通过使用 GitLab CLI（`glab`）引导代理来完成此操作。

1. [安装 GitLab CLI](https://jihulab.com/gitlab-cn/cli#installation)。

   要检查 GitLab CLI 是否可用，请运行

   ```shell
   glab version
   ```

1. [对 `glab` 进行身份验证](https://jihulab.com/gitlab-cn/cli#installation)，以连接到您的极狐GitLab 实例。
1. 在您引导 Flux 的代码仓库中，运行 `glab cluster agent bootstrap` 命令：

   ```shell
   glab cluster agent bootstrap --manifest-path clusters/testing testing
   ```

默认情况下，该命令会：

1. 以 `testing` 作为名称注册代理。
1. 配置代理。
1. 配置一个名为 `testing`的环境，并为该代理配置仪表板。
1. 创建代理令牌。
1. 在集群中创建一个包含代理令牌的 Kubernetes 密钥。
1. 将 Flux Helm 资源提交到 Git 代码仓库。
1. 触发 Flux 协调。

有关配置代理的更多信息，请参阅[安装极狐GitLab Kubernetes Agent](install/_index.md)。

<a id="check-out-the-dashboard-for-kubernetes"></a>

## 查看 Kubernetes 仪表板

`glab cluster agent bootstrap` 在极狐GitLab 中创建了一个环境，并[配置了仪表板](../../../ci/environments/kubernetes_dashboard.md)。

要查看您的仪表板：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**运维** > **环境**。
1. 选择您的环境。例如，`flux-system/gitlab-agent`。
1. 选择 **Kubernetes 概览**标签页。

<a id="secure-the-deployment"></a>

## 保护部署安全

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

到目前为止，您已使用 `.gitlab/agents/testing/config.yaml` 文件部署了一个代理。此配置使用为代理部署配置的服务账号启用用户访问。用户访问由 Kubernetes 仪表板以及本地访问使用。

为确保部署安全，您应将此设置更改为模拟极狐GitLab 用户。在这种情况下，您可以通过常规的 Kubernetes 基于角色的访问控制（RBAC）来管理对集群资源的访问。

要启用用户模拟：

1. 在您的 `.gitlab/agents/testing/config.yaml` 文件中，将 `user_access.access_as.agent: {}` 替换为 `user_access.access_as.user: {}`。
1. 转到已配置的 Kubernetes 仪表板。如果访问受到限制，仪表板会显示错误消息。
1. 将以下代码添加到 `clusters/testing/gitlab-user-read.yaml`：

   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
      name: gitlab-user-view
   roleRef:
      name: view
      kind: ClusterRole
      apiGroup: rbac.authorization.k8s.io
   subjects:
      - name: gitlab:user
        kind: Group
   ```

1. 等待几秒钟，让 Flux 应用添加的清单，然后再次检查 Kubernetes 仪表板。由于部署的集群角色绑定授予所有极狐GitLab 用户读取访问权限，仪表板应恢复正常。

有关用户访问的更多信息，请参阅[授予用户 Kubernetes 访问权限](user_access.md)。

<a id="keep-everything-up-to-date"></a>

## 保持一切为最新状态

安装后，您可能需要升级 Flux 和 `agentk`。

为此：

- 重新运行 `flux bootstrap gitlab` 和 `glab cluster agent bootstrap` 命令。

<a id="next-steps"></a>

## 后续步骤

您可以从注册代理并存储 Flux 清单的项目直接部署到您的集群。该代理旨在支持多租户，您可以使用已配置的代理和 Flux 安装将配置扩展到其他项目和群组。

建议您完成后续教程[开始部署到 Kubernetes](getting_started_deployments.md)。要了解有关将 Kubernetes 与极狐GitLab 结合使用的更多信息，请参阅：

- [将极狐GitLab 集成与 Kubernetes 结合使用的最佳实践](enterprise_considerations.md)
- 使用代理进行[运维容器扫描](vulnerabilities.md)
- 为您的工程师提供[远程工作区](../../workspace/_index.md)
