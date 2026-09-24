---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Kubernetes 集群中使用极狐GitLab CI/CD
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 中，Agent 连接共享限制从 100 [变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/149844)为 500。

{{< /history >}}

你可以使用极狐GitLab CI/CD 安全地连接、部署和更新你的 Kubernetes 集群。

为此，请[在集群中安装 Agent](install/_index.md)。完成后，你将拥有一个 Kubernetes 上下文，并可以在极狐GitLab CI/CD 流水线中运行 Kubernetes API 命令。

为确保对集群的访问安全：

- 每个 Agent 都有一个独立的上下文（`kubecontext`）。
- 只有配置了 Agent 的项目以及你授权的任何其他项目，才能访问集群中的 Agent。

要使用极狐GitLab CI/CD 与你的集群交互，Runner 必须已在极狐GitLab 中注册。但是，这些 Runner 不必位于 Agent 所在的集群中。

先决条件：

- 确保[已启用极狐GitLab CI/CD](../../../ci/pipelines/settings.md#disable-gitlab-cicd-pipelines)。

<a id="use-gitlab-cicd-with-your-cluster"></a>

## 使用极狐GitLab CI/CD 与你的集群

要使用极狐GitLab CI/CD 更新 Kubernetes 集群：

1. 确保你有一个可正常运行的 Kubernetes 集群，并且清单文件位于一个极狐GitLab 项目中。
1. 在同一个极狐GitLab 项目中，[注册并安装极狐GitLab Kubernetes Agent](install/_index.md)。
1. [更新你的 `.gitlab-ci.yml` 文件](#update-your-gitlab-ciyml-file-to-run-kubectl-commands)以选择 Agent 的 Kubernetes 上下文并运行 Kubernetes API 命令。
1. 运行你的流水线以部署到或更新集群。

如果你有多个包含 Kubernetes 清单的极狐GitLab 项目：

1. 在它自己的项目中，或在某个包含 Kubernetes 清单的极狐GitLab 项目中[安装极狐GitLab Kubernetes Agent](install/_index.md)。
1. 在你的极狐GitLab 项目中[授权 Agent 访问](#authorize-agent-access)。
1. 可选。为了增加安全性，[使用身份模拟](#restrict-project-and-group-access-by-using-impersonation)。
1. [更新你的 `.gitlab-ci.yml` 文件](#update-your-gitlab-ciyml-file-to-run-kubectl-commands)以选择 Agent 的 Kubernetes 上下文并运行 Kubernetes API 命令。
1. 运行你的流水线以部署到或更新集群。

<a id="authorize-agent-access"></a>

## 授权 Agent 访问

如果你有多个包含 Kubernetes 清单的项目，你必须授权这些项目访问 Agent。你可以为单个项目、群组或子群组授权 Agent 访问，以便所有项目都有访问权限。为了增加安全性，你还可以[使用身份模拟](#restrict-project-and-group-access-by-using-impersonation)。

授权配置可能需要一到两分钟才能传播生效。

<a id="authorize-your-projects-to-access-the-agent"></a>

### 授权你的项目访问 Agent

{{< history >}}

- 在极狐GitLab 15.6 中[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/346566)以移除层级限制。
- 在极狐GitLab 15.7 中[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/356831)以允许授权用户命名空间中的项目。
- 在极狐GitLab 18.1 中[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/377932)以允许授权属于不同顶级群组的群组。

{{< /history >}}

要授权包含 Kubernetes 清单的极狐GitLab 项目访问 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到包含 [Agent 配置文件](install/_index.md#create-an-agent-configuration-file)（`config.yaml`）的项目。
1. 编辑 `config.yaml` 文件。在 `ci_access` 关键字下，添加 `projects` 属性。
1. 对于 `id`，添加项目的路径。

   ```yaml
   ci_access:
     projects:
       - id: path/to/project
   ```

   - 除非启用了[实例级授权](#authorize-all-projects-in-your-gitlab-instance-to-access-the-agent)应用程序设置，否则授权的项目必须与 Agent 的配置项目具有相同的顶级群组或用户命名空间。
   - 你可以在同一集群中安装额外的 Agent 以适应其他层级结构。
   - 你最多可以授权 500 个项目。

完成这些更改后：

- 所有 CI/CD 作业现在都包含一个 `kubeconfig` 文件，其中包含每个共享 Agent 连接的上下文。
- `kubeconfig` 路径在 `$KUBECONFIG` 环境变量中可用。
- 你可以选择上下文，从你的 CI/CD 脚本运行 `kubectl` 命令。

<a id="authorize-projects-in-your-groups-to-access-the-agent"></a>

### 授权你的群组中的项目访问 Agent

{{< history >}}

- 在极狐GitLab 15.6 中[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/346566)以移除层级限制。
- 在极狐GitLab 18.1 中[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/377932)以允许授权属于不同顶级群组的群组。

{{< /history >}}

要授权群组或子群组中的所有极狐GitLab 项目访问 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到包含 [Agent 配置文件](install/_index.md#create-an-agent-configuration-file)（`config.yaml`）的项目。
1. 编辑 `config.yaml` 文件。在 `ci_access` 关键字下，添加 `groups` 属性。
1. 对于 `id`，添加路径：

   ```yaml
   ci_access:
     groups:
       - id: path/to/group/subgroup
   ```

   - 除非启用了[实例级授权](#authorize-all-projects-in-your-gitlab-instance-to-access-the-agent)应用程序设置，否则授权的群组必须与 Agent 的配置项目具有相同的顶级群组。
   - 你可以在同一集群中安装额外的 Agent 以适应其他层级结构。
   - 授权群组的所有子群组也自动拥有对同一 Agent 的访问权限（无需单独指定）。
   - 你最多可以授权 500 个群组。

完成这些更改后：

- 属于该群组及其子群组的所有项目现在都已授权访问 Agent。
- 所有 CI/CD 作业现在都包含一个 `kubeconfig` 文件，其中包含每个共享 Agent 连接的上下文。
- `kubeconfig` 路径在 `$KUBECONFIG` 环境变量中可用。
- 你可以选择上下文，从你的 CI/CD 脚本运行 `kubectl` 命令。

<a id="authorize-all-projects-in-your-gitlab-instance-to-access-the-agent"></a>

### 授权你的极狐GitLab 实例中的所有项目访问 Agent

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.11 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/357516)。

{{< /history >}}

先决条件：

- 你必须是管理员。

要允许 Agent 配置为授权你的极狐GitLab 实例中的所有项目：

{{< tabs >}}

{{< tab title="使用 UI" >}}

1. 在 **管理员** 区域，选择 **设置** > **通用**，然后展开 **极狐GitLab Kubernetes Agent** 部分。
1. 选择 **启用实例级授权**。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="使用 API" >}}

1. [更新应用程序设置](../../../api/settings.md#update-application-settings) `organization_cluster_agent_authorization_enabled` 为 `true`。

{{< /tab >}}

{{< /tabs >}}

要授权 Agent 访问所有极狐GitLab 项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到包含 [Agent 配置文件](install/_index.md#create-an-agent-configuration-file)（`config.yaml`）的项目。
1. 编辑 `config.yaml` 文件。在 `ci_access` 关键字下，添加 `instance` 属性：

   ```yaml
   ci_access:
     instance: {}
   ```

对 Agent 配置文件进行这些更改后：

- 你的实例中所有项目的所有 CI/CD 作业都已授权访问 Agent。你可以结合 CI/CD 作业身份模拟与 RBAC 来根据需要授予或限制访问权限。更多信息，请参阅[通过身份模拟限制项目和群组访问](#restrict-project-and-group-access-by-using-impersonation)。
- 所有 CI/CD 作业都包含一个 `kubeconfig` 文件，其中包含每个共享 Agent 连接的上下文。
- `kubeconfig` 路径在 `$KUBECONFIG` 环境变量中可用。
- 你可以选择上下文，从你的 CI/CD 脚本运行 `kubectl` 命令。

<a id="update-your-gitlab-ciyml-file-to-run-kubectl-commands"></a>

## 更新你的 `.gitlab-ci.yml` 文件以运行 `kubectl` 命令

在你要运行 Kubernetes 命令的项目中，编辑项目的 `.gitlab-ci.yml` 文件。

在 `script` 关键字下的第一个命令中，设置你的 Agent 上下文。使用格式 `<path/to/agent/project>:<agent-name>`。例如：

```yaml
deploy:
  image: debian:13-slim
  variables:
    KUBECTL_VERSION: v1.34
    DEBIAN_FRONTEND: noninteractive
  script:
    # 遵循 https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
    - apt-get update
    - apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg
    - curl --fail --silent --show-error --location "https://pkgs.k8s.io/core:/stable:/${KUBECTL_VERSION}/deb/Release.key" | gpg --dearmor --output /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    - chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    - echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBECTL_VERSION}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
    - chmod 644 /etc/apt/sources.list.d/kubernetes.list
    - apt-get update
    - apt-get install -y --no-install-recommends kubectl
    - kubectl config get-contexts
    - kubectl config use-context path/to/agent/project:agent-name
    - kubectl get pods
```

如果你不确定你的 Agent 上下文是什么，请在你想要访问 Agent 的 CI/CD 作业中运行 `kubectl config get-contexts`。

<a id="environments-that-use-auto-devops"></a>

### 使用 Auto DevOps 的环境

如果启用了 Auto DevOps，你必须定义 CI/CD 变量 `KUBE_CONTEXT`。将 `KUBE_CONTEXT` 的值设置为你希望 Auto DevOps 使用的 Agent 的上下文：

```yaml
deploy:
  variables:
    KUBE_CONTEXT: path/to/agent/project:agent-name
```

你可以为不同的 Auto DevOps 作业分配不同的 Agent。例如，Auto DevOps 可以为 `staging` 作业使用一个 Agent，为 `production` 作业使用另一个 Agent。要使用多个 Agent，请为每个 Agent 定义一个[环境范围的 CI/CD 变量](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。例如：

1. 定义两个名为 `KUBE_CONTEXT` 的变量。
1. 对于第一个变量：
   1. 将 `environment` 设置为 `staging`。
   1. 将值设置为你的 staging Agent 的上下文。
1. 对于第二个变量：
   1. 将 `environment` 设置为 `production`。
   1. 将值设置为你的 production Agent 的上下文。

<a id="environments-with-both-certificate-based-and-agent-based-connections"></a>

### 同时具有基于证书和基于 Agent 连接的环境

当你部署到同时具有[基于证书的集群](../../infrastructure/clusters/_index.md)（已弃用）和 Agent 连接的环境时：

- 基于证书的集群的上下文称为 `gitlab-deploy`。默认情况下始终选择此上下文。
- Agent 上下文包含在 `$KUBECONFIG` 中。你可以通过使用 `kubectl config use-context <path/to/agent/project>:<agent-name>` 来选择它们。

要在存在基于证书的连接时使用 Agent 连接，你可以手动配置一个新的 `kubectl` 配置上下文。例如：

```yaml
deploy:
  variables:
    KUBE_CONTEXT: my-context # 用于新上下文的名称
    AGENT_ID: 1234 # 替换为你的 Agent 的数字 ID
    K8S_PROXY_URL: https://<KAS_DOMAIN>/k8s-proxy/ # 对于部署在 Kubernetes 集群中的 Agent 服务器（KAS）（对于 gitlab.com 使用 kas.gitlab.com）；替换为你的 URL
    # K8S_PROXY_URL: https://<GITLAB_DOMAIN>/-/kubernetes-agent/k8s-proxy/ # 对于 Omnibus 中的 Agent 服务器（KAS）
    # 包含任何其他变量
  before_script:
    - kubectl config set-credentials agent:$AGENT_ID --token="ci:${AGENT_ID}:${CI_JOB_TOKEN}"
    - kubectl config set-cluster gitlab --server="${K8S_PROXY_URL}"
    - kubectl config set-context "$KUBE_CONTEXT" --cluster=gitlab --user="agent:${AGENT_ID}"
    - kubectl config use-context "$KUBE_CONTEXT"
  # 包含剩余的作业配置
```

<a id="environments-with-kas-that-use-self-signed-certificates"></a>

### 使用自签名证书的 KAS 环境

如果你使用带有 KAS 和自签名证书的环境，你必须配置你的 Kubernetes 客户端以信任签署证书的证书颁发机构（CA）。

要配置你的客户端，请执行以下操作之一：

- 设置一个 CI/CD 变量 `SSL_CERT_FILE`，其中包含 PEM 格式的 KAS 证书。
- 使用 `--certificate-authority=$KAS_CERTIFICATE` 配置 Kubernetes 客户端，其中 `KAS_CERTIFICATE` 是一个包含 KAS 的 CA 证书的 CI/CD 变量。
- 通过更新容器镜像或通过 Runner 挂载，将证书放置在作业容器中的适当位置。
- 不推荐。使用 `--insecure-skip-tls-verify=true` 配置 Kubernetes 客户端。

<a id="restrict-project-and-group-access-by-using-impersonation"></a>

## 通过身份模拟限制项目和群组访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.5 中[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/357934)以添加对环境层级的身份模拟支持。

{{< /history >}}

默认情况下，你的 CI/CD 作业会继承用于在集群中安装 Agent 的服务账户的所有权限。要限制对集群的访问，你可以使用[身份模拟](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation)。

要指定身份模拟，请在你的 Agent 配置文件中使用 `access_as` 属性，并使用 Kubernetes RBAC 规则来管理被模拟账户的权限。

你可以模拟：

- Agent 本身（默认）。
- 访问集群的 CI/CD 作业。
- 集群中定义的特定用户或系统账户。

授权配置可能需要一到两分钟才能传播生效。

<a id="impersonate-the-agent"></a>

### 模拟 Agent

默认情况下，Agent 被模拟。你无需执行任何操作即可模拟它。

<a id="impersonate-the-cicd-job-that-accesses-the-cluster"></a>

### 模拟访问集群的 CI/CD 作业

要模拟访问集群的 CI/CD 作业，请在 `access_as` 键下添加 `ci_job: {}` 键值对。

当 Agent 向实际的 Kubernetes API 发出请求时，它会按以下方式设置身份模拟凭据：

- `UserName` 设置为 `gitlab:ci_job:<job id>`。示例：`gitlab:ci_job:1074499489`。
- `Groups` 设置为：

  - `gitlab:ci_job` 用于标识所有来自 CI 作业的请求。
  - 项目所在群组的 ID 列表。
  - 项目 ID。
  - 此作业所属环境的 slug 和层级。

    示例：对于 `group1/group1-1/project1` 中的 CI 作业，其中：

    - 群组 `group1` 的 ID 为 23。
    - 群组 `group1/group1-1` 的 ID 为 25。
    - 项目 `group1/group1-1/project1` 的 ID 为 150。
    - 作业在 `prod` 环境中运行，该环境具有 `production` 环境层级。

  群组列表将为 `[gitlab:ci_job, gitlab:group:23, gitlab:group_env_tier:23:production, gitlab:group:25, gitlab:group_env_tier:25:production, gitlab:project:150, gitlab:project_env:150:prod, gitlab:project_env_tier:150:production]`。

- `Extra` 携带有关请求的额外信息。以下属性设置在模拟身份上：

| 属性                                  | 描述                                         |
| ------------------------------------- | -------------------------------------------- |
| `agent.gitlab.com/id`                | 包含 Agent ID。                              |
| `agent.gitlab.com/config_project_id` | 包含 Agent 的配置项目 ID。                   |
| `agent.gitlab.com/project_id`        | 包含 CI 项目 ID。                            |
| `agent.gitlab.com/ci_pipeline_id`    | 包含 CI 流水线 ID。                          |
| `agent.gitlab.com/ci_job_id`         | 包含 CI 作业 ID。                            |
| `agent.gitlab.com/username`          | 包含运行 CI 作业的用户的用户名。             |
| `agent.gitlab.com/environment_slug`  | 包含环境的 slug。仅在环境中运行时设置。      |
| `agent.gitlab.com/environment_tier`  | 包含环境的层级。仅在环境中运行时设置。      |

通过 CI/CD 作业身份限制访问的 `config.yaml` 示例：

```yaml
ci_access:
  projects:
    - id: path/to/project
      access_as:
        ci_job: {}
```

<a id="example-rbac-to-restrict-cicd-jobs"></a>

#### 限制 CI/CD 作业的 RBAC 示例

以下 `RoleBinding` 资源将所有 CI/CD 作业限制为仅具有查看权限。

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ci-job-view
roleRef:
  name: view
  kind: ClusterRole
  apiGroup: rbac.authorization.k8s.io
subjects:
  - name: gitlab:ci_job
    kind: Group
```

<a id="impersonate-a-static-identity"></a>

### 模拟静态身份

对于给定的连接，你可以使用静态身份进行模拟。

在 `access_as` 键下，添加 `impersonate` 键以使用提供的身份发出请求。

可以使用以下键指定身份：

- `username`（必需）
- `uid`
- `groups`
- `extra`

有关详细信息，请参阅[官方 Kubernetes 文档](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation)。

<a id="restrict-project-and-group-access-to-specific-environments"></a>

## 限制项目和群组对特定环境的访问

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/343885)。

{{< /history >}}

默认情况下，如果你的 Agent [对某个项目可用](#authorize-agent-access)，该项目的所有 CI/CD 作业都可以使用该 Agent。

要限制 Agent 仅对具有特定环境的作业可用，请将 `environments` 添加到 `ci_access.projects` 或 `ci_access.groups`。例如：

  ```yaml
  ci_access:
    projects:
      - id: path/to/project-1
      - id: path/to/project-2
        environments:
          - staging
          - review/*
    groups:
      - id: path/to/group-1
        environments:
          - production
  ```

在此示例中：

- `project-1` 下的所有 CI/CD 作业都可以访问 Agent。
- `project-2` 下具有 `staging` 或 `review/*` 环境的 CI/CD 作业可以访问 Agent。
  - `*` 是通配符，因此 `review/*` 匹配 `review` 下的所有环境。
- `group-1` 下具有 `production` 环境的项目的 CI/CD 作业可以访问 Agent。

<a id="restrict-access-to-the-agent-to-protected-branches"></a>

## 限制对受保护分支的 Agent 访问

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/467936)，带有名为 `kubernetes_agent_protected_branches` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 17.10 中[全面可用](https://gitlab.com/gitlab-org/gitlab/-/issues/467936)。功能标志 `kubernetes_agent_protected_branches` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 有关更多信息，请参阅历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

要限制 Agent 仅对在[受保护分支](../../project/repository/branches/protected.md)上运行的作业可用：

- 将 `protected_branches_only: true` 添加到 `ci_access.projects` 或 `ci_access.groups`。
  例如：

  ```yaml
  ci_access:
    projects:
      - id: path/to/project-1
        protected_branches_only: true
    groups:
      - id: path/to/group-1
        protected_branches_only: true
        environments:
          - production
  ```

默认情况下，`protected_branches_only` 设置为 `false`，Agent 可以从不受保护和受保护的分支访问。

为了增加安全性，你可以将此功能与[环境限制](#restrict-project-and-group-access-to-specific-environments)结合使用。

如果项目有多个配置，则仅使用最具体的配置。例如，以下配置授予对 `example/my-project` 中不受保护分支的访问权限，即使 `example` 群组配置为仅授予对受保护分支的访问权限：

```yaml
# .gitlab/agents/my-agent/config.yaml
ci_access:
  project:
    - id: example/my-project # 下面群组的项目
      protected_branches_only: false # 此配置取代群组配置
      environments:
        - dev
  groups:
    - id: example
      protected_branches_only: true
      environments:
        - dev
```

有关更多详细信息，请参阅[从 CI/CD 访问 Kubernetes](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/kubernetes_ci_access.md#apiv4joballowed_agents-api)。

<a id="troubleshooting"></a>

## 故障排除

<a id="grant-write-permissions-to-kubecache"></a>

### 授予 `~/.kube/cache` 写入权限

像 `kubectl`、Helm、`kpt` 和 `kustomize` 这样的工具会将有关集群的信息缓存在 `~/.kube/cache` 中。如果此目录不可写，工具会在每次调用时获取信息，从而使交互变慢并给集群带来不必要的负载。为了获得最佳体验，请确保在 `.gitlab-ci.yml` 文件中使用的镜像中，此目录是可写的。

<a id="enable-tls"></a>

### 启用 TLS

如果你使用的是私有化部署的极狐GitLab，请确保你的实例已配置传输层安全（TLS）。

如果你尝试在没有 TLS 的情况下使用 `kubectl`，可能会收到类似以下的错误：

```shell
$ kubectl get pods
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

<a id="unable-to-connect-to-the-server-certificate-signed-by-unknown-authority"></a>

### 无法连接到服务器：证书由未知机构签署

如果你使用带有 KAS 和自签名证书的环境，你的 `kubectl` 调用可能会返回此错误：

```plaintext
kubectl get pods
Unable to connect to the server: x509: certificate signed by unknown authority
```

发生此错误是因为作业不信任签署 KAS 证书的证书颁发机构（CA）。

要解决此问题，请[配置 `kubectl` 以信任 CA](#environments-with-kas-that-use-self-signed-certificates)。

<a id="validation-errors"></a>

### 验证错误

如果你使用 `kubectl` 版本 v1.27.0 或 v.1.27.1，你可能会收到以下错误：

```plaintext
error: error validating "file.yml": error validating data: the server responded with the status code 426 but did not return more information; if you choose to ignore these errors, turn validation off with --validate=false
```

此问题是由 `kubectl` 和其他使用共享 Kubernetes 库的工具的[一个错误](https://github.com/kubernetes/kubernetes/issues/117463)引起的。

要解决此问题，请使用其他版本的 `kubectl`。

