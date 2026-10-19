---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为 Kubernetes 安装 agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

连接 Kubernetes 集群到极狐GitLab，你必须在集群中安装 agent。

<a id="prerequisites"></a>

## 前提条件

在集群中安装 agent 之前，你需要：

- 一个已存在的[可以从本地终端连接的 Kubernetes 集群](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/)。如果没有集群，你可以在云提供商上创建一个，例如：
  - [Amazon Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
  - [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/what-is-aks)
  - [Digital Ocean](https://docs.digitalocean.com/products/kubernetes/getting-started/quickstart/)
  - [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster)
  - 对于大规模基础设施资源管理，应使用[基础设施即代码技术](../../../infrastructure/iac/_index.md)。
- 访问 agent 服务器：
  - 在 JihuLab.com 上，agent 服务器在 `wss://kas.gitlab.com` 可用。
  - 在私有化部署上，极狐GitLab 管理员必须设置 [agent 服务器](../../../../administration/clusters/kas.md)。然后默认在 `wss://gitlab.example.com/-/kubernetes-agent/` 可用。

<a id="bootstrap-the-agent-with-flux-support-recommended"></a>

## 使用 Flux 支持引导 agent（推荐）

你可以通过使用 [极狐GitLab CLI (`glab`)](../../../../editor_extensions/gitlab_cli/_index.md) 和 Flux 进行引导来安装 agent。

前提条件：

- 已安装以下命令行工具：
  - `glab`
  - `kubectl`
  - `flux`
- 有一个可以在 `kubectl` 和 `flux` 中使用的本地集群连接。
- 你已经使用 `flux bootstrap` 将 Flux [引导](https://fluxcd.io/flux/installation/bootstrap/gitlab/) 至集群。
  - 确保在兼容的目录中引导 Flux 和 agent。如果你使用 `--path` 选项引导了 Flux，则必须将相同的值传递给 `glab cluster agent bootstrap` 命令的 `--manifest-path` 选项。

要安装 agent，可以：

- 在目标项目的 Git 仓库目录中运行 `glab cluster agent bootstrap`：

  ```shell
  glab cluster agent bootstrap <agent-name> --manifest-path <same_path_used_in_flux_bootstrap>
  ```

- 如果必须在目标项目的 Git 仓库外运行命令，则运行 `glab -R path-with-namespace cluster agent bootstrap`：

  ```shell
  glab -R <full/path/to/project> cluster agent bootstrap <agent-name> --manifest-path <same_path_used_in_flux_bootstrap>
  ```

默认情况下，该命令：

1. 注册 agent。
1. 配置 agent。
1. 为 agent 配置一个带有仪表板的环境。
1. 创建 agent 令牌。
1. 在集群中，创建一个包含 agent 令牌的 Kubernetes secret。
1. 将 Flux Helm 资源提交到 Git 仓库。
1. 触发 Flux 协调。

关于自定义选项，请运行 `glab cluster agent bootstrap --help`。你可能至少需要使用 `--path <flux_manifests_directory>` 选项。

<a id="install-the-agent-manually"></a>

## 手动安装 agent

在集群中安装 agent 需要三个步骤：

1. 可选。[创建 agent 配置文件](#create-an-agent-configuration-file)。
1. [向极狐GitLab 注册 agent](#register-the-agent-with-gitlab)。
1. [在集群中安装 agent](#install-the-agent-in-the-cluster)。

<a id="create-an-agent-configuration-file"></a>

### 创建 agent 配置文件

对于配置设置，agent 在极狐GitLab 项目中使用一个 YAML 文件。添加 agent 配置文件是可选的。如果你：

- 使用 [极狐GitLab CI/CD 工作流](../ci_cd_workflow.md#use-gitlab-cicd-with-your-cluster) 并希望授权其他项目或群组访问该 agent。
- [允许特定项目或群组成员访问 Kubernetes](../user_access.md)。

则需要创建此文件。

要创建 agent 配置文件：

1. 为你的 agent 选择一个名称。agent 名称遵循 [RFC 1123 的 DNS 标签标准](https://www.rfc-editor.org/rfc/rfc1123)。名称必须：

   - 在项目中唯一。
   - 最多包含 63 个字符。
   - 仅包含小写字母数字字符或 `-`。
   - 以字母数字字符开头。
   - 以字母数字字符结尾。

1. 在仓库的默认分支中，创建 agent 配置文件，路径为：

   ```plaintext
   .gitlab/agents/<agent-name>/config.yaml
   ```

你可以暂时将文件留空，稍后再[进行配置](../work_with_agent.md#configure-your-agent)。

<a id="register-the-agent-with-gitlab"></a>

### 向极狐GitLab 注册 agent

<a id="option-1-agent-connects-to-gitlab"></a>

#### 选项 1：agent 连接至极狐GitLab

你可以直接从极狐GitLab UI 创建新的 agent 记录。无需创建 agent 配置文件即可注册 agent。

必须先注册 agent，然后才能在集群中安装 agent。要注册 agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。如果你有 [agent 配置文件](#create-an-agent-configuration-file)，则该文件必须在此项目中。你的集群清单文件也应在此项目中。
1. 选择 **运维** > **Kubernetes 集群**。
1. 选择 **连接集群（agent）**。
1. 在 **新 agent 名称** 字段中，输入 agent 的唯一名称。
   - 如果已存在同名的 [agent 配置文件](#create-an-agent-configuration-file)，则会使用该文件。
   - 如果不存在该名称的配置，则会使用默认配置创建新 agent。
1. 选择 **创建并注册**。
1. 极狐GitLab 会为 agent 生成访问令牌。在集群中安装 agent 需要此令牌。

   > [!warning]
   > 请安全存储 agent 访问令牌。恶意攻击者可以使用此令牌访问 agent 配置项目中的源代码，访问极狐GitLab 实例上任何公开项目的源代码，甚至在极其特定的条件下获取 Kubernetes 清单文件。

1. 复制 **推荐的安装方式** 下的命令。当你使用一行命令安装方式在集群中安装 agent 时，会需要用到该命令。

<a id="option-2-gitlab-connects-to-agent-receptive-agent"></a>

#### 选项 2：极狐GitLab 连接至 agent（被动式 agent）

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中引入。

{{< /history >}}

> [!note]
> 极狐GitLab Agent Helm Chart 发行版不完全支持 mTLS 认证。
> 应改用 JWT 方式进行认证。
> 对 mTLS 的支持在
> [issue 64](https://gitlab.com/gitlab-org/charts/gitlab-agent/-/issues/64) 中跟踪。

[被动式 agent](../_index.md#receptive-agents) 允许极狐GitLab 与无法建立到极狐GitLab 实例的网络连接、但可以被极狐GitLab 连接的 Kubernetes 集群进行集成。

1. 按照选项 1 中的步骤在集群中注册 agent。保存 agent 令牌和安装命令，但尚不安装 agent。
1. 准备认证方式。

   极狐GitLab 到 agent 的连接可以是明文 gRPC (`grpc://`) 或加密 gRPC (`grpcs://`，推荐)。
   极狐GitLab 可以使用以下方式向集群中的 agent 进行认证：
   - JWT 令牌。在 `grpc://` 和 `grpcs://` 配置中均可用。使用此方式无需生成客户端证书。
1. 使用 [cluster agents API](../../../../api/cluster_agents.md#create-a-url-configuration) 为 agent 添加 URL 配置。如果删除 URL 配置，被动式 agent 将变为普通 agent。一个被动式 agent 一次只能关联一个 URL 配置。
1. 将 agent 安装到集群中。使用注册 agent 时复制的命令，但移除 `--set config.kasAddress=...` 参数。

   JWT 令牌认证示例。注意添加的 `config.receptive.enabled=true` 和 `config.api.jwt` 设置：

   ```shell
   helm repo add gitlab https://charts.gitlab.io
   helm repo update
   helm upgrade --install my-agent gitlab/gitlab-agent \
    --namespace ns \
    --create-namespace \
    --set config.token=.... \
    --set config.receptive.enabled=true \
    --set config.api.jwtPublicKey=<public_key from the response>
   ```

极狐GitLab 可能需要长达 10 分钟才能开始尝试建立与新 agent 的连接。

<a id="install-the-agent-in-the-cluster"></a>

### 在集群中安装 agent

要将集群连接到极狐GitLab，[使用 Helm 安装已注册的 agent](#install-the-agent-with-helm)。

要安装被动式 agent，请按照 [极狐GitLab 连接至 agent（被动式 agent）](#option-2-gitlab-connects-to-agent-receptive-agent) 中的步骤操作。

> [!note]
> 要连接多个集群，必须在每个集群中配置、注册并安装 agent。确保为每个 agent 指定一个唯一的名称。

<a id="install-the-agent-with-helm"></a>

#### 使用 Helm 安装 agent

> [!warning]
> 为简化起见，默认的 Helm Chart 配置会为 agent 创建一个具有 `cluster-admin` 权限的服务账户。你不应在生产系统上使用此配置。要在生产系统上部署，请按照 [自定义 Helm 安装](#customize-the-helm-installation) 中的说明创建具有部署所需最小权限的服务账户，并在安装时指定该账户。

要在集群上使用 Helm 安装 agent：

1. [安装 Helm CLI](https://helm.sh/docs/intro/install/)。
1. 在计算机上打开终端并[连接到你的集群](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/)。
1. 运行你在[向极狐GitLab 注册 agent](#register-the-agent-with-gitlab) 时复制的命令。该命令应类似于：

   ```shell
   helm repo add gitlab https://charts.gitlab.io
   helm repo update
   helm upgrade --install test gitlab/gitlab-agent \
       --namespace gitlab-agent-test \
       --create-namespace \
       --set image.tag=<current agentk version> \
       --set config.token=<your_token> \
       --set config.kasAddress=<address_to_GitLab_KAS_instance>
   ```

1. 可选。[自定义 Helm 安装](#customize-the-helm-installation)。如果你在生产系统上安装 agent，应自定义 Helm 安装以限制服务账户的权限。相关的自定义选项如下所述。

<a id="customize-the-helm-installation"></a>

##### 自定义 Helm 安装

默认情况下，极狐GitLab 生成的 Helm 安装命令会：

- 为部署创建一个命名空间 `gitlab-agent` (`--namespace gitlab-agent`)。你可以通过省略 `--create-namespace` 标志来跳过创建命名空间。
- 为 agent 设置一个服务账户，并为其分配 `cluster-admin` 角色。你可以：
  - 通过向 `helm install` 命令添加 `--set serviceAccount.create=false` 来跳过创建服务账户。在这种情况下，你必须将 `serviceAccount.name` 设置为一个已存在的服务账户。
  - 通过向 `helm install` 命令添加 `--set rbac.useExistingRole <your role name>` 来自定义分配给服务账户的角色。在这种情况下，你应该有一个预先创建的、权限受限的角色，可供该服务账户使用。
  - 通过向 `helm install` 命令添加 `--set rbac.create=false` 来完全跳过角色分配。在这种情况下，你必须手动创建 `ClusterRoleBinding`。
- 为 agent 的访问令牌创建一个 `Secret` 资源。要使用自己携带令牌的 secret，请省略令牌 (`--set token=...`)，而改用 `--set config.secretName=<your secret name>`。
- 为 `agentk` Pod 创建一个 `Deployment` 资源。

要查看完整的可自定义项列表，请参阅 Helm chart 的 [README](https://gitlab.com/gitlab-org/charts/gitlab-agent/-/blob/main/README.md#values)。

<a id="use-the-agent-when-kas-is-behind-a-self-signed-certificate"></a>

##### 当 KAS 位于自签名证书后时使用 agent

当 [KAS](../../../../administration/clusters/kas.md) 位于自签名证书后时，你可以将 `config.kasCaCert` 的值设置为该证书。例如：

```shell
helm upgrade --install gitlab-agent gitlab/gitlab-agent \
  --set-file config.kasCaCert=my-custom-ca.pem
```

在此示例中，`my-custom-ca.pem` 是包含 KAS 使用的 CA 证书的本地文件路径。该证书会自动存储在 ConfigMap 中，并挂载到 `agentk` Pod 中。

如果 KAS 是通过 GitLab chart 安装的，且该 chart 配置为提供[自动生成的自签名通配符证书](https://gitlab.cn/docs/charts/installation/tls/#option-4-use-auto-generated-self-signed-wildcard-certificate)，你可以从 `RELEASE-wildcard-tls-ca` secret 中提取 CA 证书。

<a id="use-the-agent-behind-an-http-proxy"></a>

##### 在 HTTP 代理后使用 agent

{{< history >}}

- 在极狐GitLab 15.0 中引入，极狐GitLab agent Helm chart 支持设置环境变量。

{{< /history >}}

要使用 Helm chart 配置 HTTP 代理，你可以使用环境变量 `HTTP_PROXY`、`HTTPS_PROXY` 和 `NO_PROXY`。大小写均可。

你可以使用 `extraEnv` 值来设置这些变量，形式为包含 `name` 和 `value` 键的对象列表。例如，要仅将环境变量 `HTTPS_PROXY` 设置为 `https://example.com/proxy`，可以运行：

```shell
helm upgrade --install gitlab-agent gitlab/gitlab-agent \
  --set extraEnv[0].name=HTTPS_PROXY \
  --set extraEnv[0].value=https://example.com/proxy \
  ...
```

> [!note]
> 当设置了 `HTTP_PROXY` 或 `HTTPS_PROXY` 环境变量，且域 DNS 不可解析时，DNS 重绑定保护将被禁用。

<a id="install-multiple-agents-in-your-cluster"></a>

## 在集群中安装多个 agent

> [!note]
> 在大多数情况下，你应该每个集群运行一个 agent，并使用 agent 模拟功能(仅限专业版和旗舰版)来支持多租户。如果你必须运行多个 agent，请分享你遇到的任何问题。你可以在 [issue 454110](https://gitlab.com/gitlab-org/gitlab/-/issues/454110) 中提供反馈。

要在集群中安装第二个 agent，你可以第二次按照[之前的步骤](#register-the-agent-with-gitlab)操作。为避免集群内的资源名称冲突，你必须：

- 为 agent 使用不同的 release 名称，例如 `second-gitlab-agent`：

  ```shell
  helm upgrade --install second-gitlab-agent gitlab/gitlab-agent ...
  ```

- 或者，将 agent 安装到不同的命名空间中，例如 `different-namespace`：

  ```shell
  helm upgrade --install gitlab-agent gitlab/gitlab-agent \
    --namespace different-namespace \
    ...
  ```

由于集群中的每个 agent 都独立运行，每个启用了 Flux 模块的 agent 都会触发协调。

作为变通方法，你可以：

- 为 agent 配置 RBAC，使其仅访问所需的 Flux 资源。
- 在不使用 Flux 的 agent 上禁用该模块。

<a id="example-projects"></a>

## 示例项目

以下示例项目可以帮助你快速上手 agent。

- [独立应用和清单仓库示例](https://gitlab.com/gitlab-examples/ops/gitops-demo/hello-world-service-gitops)
- [使用 CI/CD 工作流的 Auto DevOps 设置](https://gitlab.com/gitlab-examples/ops/gitops-demo/hello-world-service)
- [使用 CI/CD 工作流的集群管理项目模板示例](https://gitlab.com/gitlab-examples/ops/gitops-demo/cluster-management)

<a id="updates-and-version-compatibility"></a>

## 更新及版本兼容性

极狐GitLab 会在 agent 列表页提醒你更新集群上安装的 agent 版本。

为获得最佳体验，集群中安装的 agent 版本应与极狐GitLab 的主版本和次版本匹配。也支持上一个和下一个次版本。例如，如果你的极狐GitLab 版本是 v14.9.4（主版本 14，次版本 9），那么 agent 版本 v14.9.0 和 v14.9.1 是理想的，但也支持任何 v14.8.x 或 v14.10.x 版本。请参阅 [Kubernetes 用极狐GitLab agent 的发布页面](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/releases)。

<a id="update-the-agent-version"></a>

### 更新 agent 版本

> [!note]
> 不要使用 `--reuse-values`，而应指定所有需要的值。
> 如果使用 `--reuse-values`，可能会错过新的默认值或使用已弃用的值。
> 要检索之前的 `--set` 参数，请使用 `helm get values <release name>`。
> 你可以通过 `helm get values gitlab-agent > agent.yaml` 将值保存到文件，并使用 `-f` 将文件传递给 Helm：
> `helm upgrade gitlab-agent gitlab/gitlab-agent -f agent.yaml`。这可以安全地替代 `--reuse-values` 的行为。

要将 agent 更新至最新版本，可以运行：

```shell
helm repo update
helm upgrade --install gitlab-agent gitlab/gitlab-agent \
  --namespace gitlab-agent
```

要设置特定版本，可以覆盖 `image.tag` 值。例如，要安装版本 `v14.9.1`，运行：

```shell
helm upgrade gitlab-agent gitlab/gitlab-agent \
  --namespace gitlab-agent \
  --set image.tag=v14.9.1
```

Helm chart 的更新独立于 Kubernetes 用 agent，有时可能会落后于 agent 的最新版本。如果你运行 `helm repo update` 且未指定镜像标签，你的 agent 将运行 chart 中指定的版本。

要使用 Kubernetes 用 agent 的最新版本，请将镜像标签设置为与最新的 agent 镜像匹配。

<a id="uninstall-the-agent"></a>

## 卸载 agent

如果你[使用 Helm 安装了 agent](#install-the-agent-with-helm)，那么也可以使用 Helm 卸载。例如，如果 release 和命名空间都叫做 `gitlab-agent`，则可以使用以下命令卸载 agent：

```shell
helm uninstall gitlab-agent \
    --namespace gitlab-agent
```

<a id="troubleshooting"></a>

## 故障排除

在安装 Kubernetes 用 agent 时，你可能会遇到以下问题。

<a id="error-failed-to-reconcile-the-gitlab-agent"></a>

### 错误：`failed to reconcile the GitLab Agent`

如果 `glab cluster agent bootstrap` 命令失败并显示消息 `failed to reconcile the GitLab Agent`，这意味着 `glab` 无法与 Flux 协调 agent。

此错误可能是因为：

- Flux 设置未指向 `glab` 放置 agent Flux 清单文件的目录。如果你使用 `--path` 选项引导了 Flux，则必须将相同的值传递给 `glab cluster agent bootstrap` 命令的 `--manifest-path` 选项。
- Flux 指向没有 `kustomization.yaml` 的项目的根目录，这会导致 Flux 遍历子目录寻找 YAML 文件。要使用 agent，必须在 `.gitlab/agents/<agent-name>/config.yaml` 处有 agent 配置文件，而该文件不是有效的 Kubernetes 清单文件。Flux 会因无法应用此文件而导致错误。要解决此问题，你应该让 Flux 指向一个子目录，而不是根目录。

