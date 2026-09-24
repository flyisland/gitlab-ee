---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 开始将 Kubernetes 集群连接到极狐GitLab
---

本页面将指导你在单个项目中设置基本的 Kubernetes 集成。如果你是极狐GitLab Kubernetes 代理、拉取式部署或 Flux 的新手，则应从这里开始。

完成之后，你将能够：

- 使用实时 Kubernetes 仪表盘查看 Kubernetes 集群的状态。
- 使用 Flux 将更新部署到集群。
- 使用极狐GitLab CI/CD 将更新部署到集群。

<a id="before-you-begin"></a>

## 开始之前

在完成本教程之前，请确保具备以下条件：

- 一个可以通过 `kubectl` 本地访问的 Kubernetes 集群。
  要查看极狐GitLab 支持的 Kubernetes 版本，请参见[极狐GitLab 功能支持的 Kubernetes 版本](_index.md#supported-kubernetes-versions-for-gitlab-features)。

  你可以通过运行以下命令来检查一切是否配置正确：

  ```shell
  kubectl cluster-info
  ```

<a id="install-and-configure-flux"></a>

## 安装与配置 Flux

[Flux](https://fluxcd.io/flux/) 是推荐的 GitOps 部署工具（也称为拉取式部署）。Flux 是一个成熟的 CNCF 项目。

要安装 Flux：

- 完成 Flux 文档中[安装 Flux CLI](https://fluxcd.io/flux/installation/#install-the-flux-cli) 的步骤。

运行以下命令检查 Flux CLI 是否正确安装：

```shell
flux -v
```

<a id="create-a-personal-access-token"></a>

### 创建个人访问令牌

要通过 Flux CLI 进行认证，创建一个具有 `api` 作用域的个人访问令牌：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 输入令牌的名称和可选的过期日期。
1. 选择 `api` 作用域。
1. 选择 **创建个人访问令牌**。

你还可以使用具有 `api` 作用域和 `维护者` 角色的[项目](../../project/settings/project_access_tokens.md)或[群组访问令牌](../../group/settings/group_access_tokens.md)。

<a id="bootstrap-flux"></a>

### 初始化 Flux

在本节中，你将使用 [`flux bootstrap`](https://fluxcd.io/flux/installation/bootstrap/gitlab/) 命令将 Flux 初始化到一个空的极狐GitLab 仓库中。

要初始化 Flux 安装：

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

`bootstrap` 的参数说明如下：

| 参数         | 描述 |
|--------------|-------------|
| `hostname`   | 你的极狐GitLab 实例的主机名。 |
| `owner`      | 包含 Flux 仓库的极狐GitLab 群组。 |
| `repository` | 包含 Flux 仓库的极狐GitLab 项目。 |
| `branch`     | 更改提交到的 Git 分支。 |
| `path`       | Flux 配置存储的文件夹路径。 |

引导脚本会执行以下操作：

1. 创建一个部署令牌并将其保存为 Kubernetes `secret`。
1. 如果 `--repository` 参数指定的项目不存在，则创建一个空的极狐GitLab 项目。
1. 在 `--path` 参数指定的文件夹中为你的项目生成 Flux 定义文件。
1. 将定义文件提交到 `--branch` 参数指定的分支。
1. 将定义文件应用到你的集群。

运行脚本后，Flux 将准备好管理自身以及你添加到极狐GitLab 项目和路径中的任何其他资源。

本教程的其余部分假设你的路径是 `clusters/testing`，你的项目位于 `my-group/optional-subgroup/my-repository` 下。

<a id="set-up-the-agent-connection"></a>

## 设置代理连接

要连接集群，你需要安装 Kubernetes 的极狐GitLab 代理。你可以通过使用 GitLab CLI（`glab`）初始化代理来完成此操作。

1. [安装 GitLab CLI](https://jihulab.com/gitlab-cn/cli/#installation)。

   要检查 GitLab CLI 是否可用，请运行：

   ```shell
   glab version
   ```

1. [对 `glab` 进行认证](https://jihulab.com/gitlab-cn/cli/#installation) 到你的极狐GitLab 实例。
1. 在初始化 Flux 的仓库中，运行 `glab cluster agent bootstrap` 命令：

   ```shell
   glab cluster agent bootstrap --manifest-path clusters/testing testing
   ```

默认情况下，该命令会：

1. 以 `testing` 为名称注册代理。
1. 配置代理。
1. 配置一个名为 `testing` 的环境，并为代理设置仪表盘。
1. 创建代理令牌。
1. 在集群中，创建一个包含代理令牌的 Kubernetes secret。
1. 将 Flux Helm 资源提交到 Git 仓库。
1. 触发 Flux 协调。

有关配置代理的更多信息，请参见[安装 Kubernetes 代理](install/_index.md)。

<a id="check-out-the-dashboard-for-kubernetes"></a>

## 查看 Kubernetes 仪表盘

`glab cluster agent bootstrap` 在极狐GitLab 中创建了一个环境，并[配置了仪表盘](../../../ci/environments/kubernetes_dashboard.md)。

要查看仪表盘：

1. 在顶栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **运维** > **环境**。
1. 选择你的环境，例如 `flux-system/gitlab-agent`。
1. 选择 **Kubernetes 概览** 标签页。

<a id="secure-the-deployment"></a>

## 保护部署

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

到目前为止，你已经使用 `.gitlab/agents/testing/config.yaml` 文件部署了一个代理。此配置使用为代理部署配置的服务账户来启用用户访问。用户访问用于 Kubernetes 仪表盘和本地访问。

为了确保部署安全，你应将此设置更改为模拟极狐GitLab 用户。在这种情况下，你可以通过常规的 Kubernetes 基于角色的访问控制（RBAC）来管理对集群资源的访问。

要启用用户模拟：

1. 在你的 `.gitlab/agents/testing/config.yaml` 文件中，将 `user_access.access_as.agent: {}` 替换为 `user_access.access_as.user: {}`。
1. 前往已配置的 Kubernetes 仪表盘。如果访问受限，仪表盘会显示错误消息。
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

1. 等待几秒钟，让 Flux 应用添加的清单，然后再次检查 Kubernetes 仪表盘。由于部署了集群角色绑定，为所有极狐GitLab 用户授予了读取权限，仪表盘应恢复正常。

有关用户访问的更多信息，请参见[授予用户 Kubernetes 访问权限](user_access.md)。

<a id="keep-everything-up-to-date"></a>

## 保持所有内容为最新

安装后，你可能需要升级 Flux 和 `agentk`。

为此：

- 重新运行 `flux bootstrap gitlab` 和 `glab cluster agent bootstrap` 命令。

<a id="next-steps"></a>

## 后续步骤

你可以从注册代理并存储 Flux 清单的项目直接部署到集群。该代理设计为支持多租户，你可以通过配置的代理和 Flux 安装将配置扩展到其他项目和群组。

建议完成后续教程[开始部署到 Kubernetes](getting_started_deployments.md)。要了解更多关于在极狐GitLab 中使用 Kubernetes 的信息，请参见：

- 使用代理进行[操作容器扫描](vulnerabilities.md)
- 为工程师提供[远程工作区](../../workspace/_index.md)