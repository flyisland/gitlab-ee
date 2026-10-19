---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab CI/CD 与 Kubernetes 集群配合使用
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用极狐GitLab CI/CD 安全地连接、部署和更新您的 Kubernetes 集群。

为此，请[在集群中安装 Agent](install/_index.md)。完成后，您将拥有一个 Kubernetes 上下文，并可以在极狐GitLab CI/CD 流水线中运行 Kubernetes API 命令。

为确保对集群的访问安全：

- 每个 Agent 都有独立的上下文（`kubecontext`）。
- 只有配置了该 Agent 的项目，以及您授权的其他项目，才能访问集群中的该 Agent。

要使用极狐GitLab CI/CD 与集群交互，Runner 必须注册到极狐GitLab。不过，这些 Runner 不必位于 Agent 所在的集群中。

先决条件：

- 确保[已启用极狐GitLab CI/CD](../../../ci/pipelines/settings.md#disable-gitlab-cicd-pipelines)。

<a id="use-gitlab-cicd-with-your-cluster"></a>

## 将极狐GitLab CI/CD 与您的集群配合使用

要使用极狐GitLab CI/CD 更新 Kubernetes 集群：

1. 确保您有一个可正常工作的 Kubernetes 集群，并且清单文件位于某个极狐GitLab 项目中。
1. 在同一个极狐GitLab 项目中，[注册并安装极狐GitLab Kubernetes Agent](install/_index.md)。
1. [更新您的 `.gitlab-ci.yml` 文件](#update-your-gitlab-ciyml-file-to-run-kubectl-commands)，以
   选择该 Agent 的 Kubernetes 上下文并运行 Kubernetes API 命令。
1. 运行您的流水线，以部署到集群或更新集群。

如果您有多个包含 Kubernetes 清单的极狐GitLab 项目：

1. 在它自己的项目中，或在您保存 Kubernetes 清单的某个
   极狐GitLab 项目中，[安装极狐GitLab Kubernetes Agent](install/_index.md)。
1. 在您的极狐GitLab 项目中[授权 Agent 访问](#authorize-agent-access)。
1. 可选。为增强安全性，[使用模拟](#restrict-project-and-group-access-by-using-impersonation)。
1. [更新您的 `.gitlab-ci.yml` 文件](#update-your-gitlab-ciyml-file-to-run-kubectl-commands)，以
   选择该 Agent 的 Kubernetes 上下文并运行 Kubernetes API 命令。
1. 运行您的流水线，以部署到集群或更新集群。

<a id="authorize-agent-access"></a>

## 授权 Agent 访问

如果您有多个包含 Kubernetes 清单的项目，则必须授权这些项目访问该 Agent。您可以为单个项目、群组或子群组授权 Agent 访问，以便所有项目都拥有访问权限。为增强安全性，您还可以[使用模拟](#restrict-project-and-group-access-by-using-impersonation)。

授权配置可能需要一到两分钟才能生效。

<a id="authorize-your-projects-to-access-the-agent"></a>

### 授权您的项目访问 Agent

要授权您保存 Kubernetes 清单的极狐GitLab 项目访问该 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，找到包含 [Agent 配置文件](install/_index.md#create-an-agent-configuration-file)（`config.yaml`）的项目。
1. 编辑 `config.yaml` 文件。在 `ci_access` 关键字下，添加 `projects` 属性。
1. 对于 `id`，添加该项目的路径。

   ```yaml
   ci_access:
     projects:
       - id: path/to/project
   ```

   - 被授权的项目必须与 Agent 的配置项目具有相同的顶级群组或用户命名空间，除非启用了
     [实例级授权](#authorize-all-projects-in-your-gitlab-instance-to-access-the-agent)应用设置。
   - 您可以将其他 Agent 安装到同一集群中，以适应其他层级结构。
   - 您最多可以授权 500 个项目。

进行这些更改后：

- 所有 CI/CD 作业现在都包含一个 `kubeconfig` 文件，其中包含每个共享 Agent 连接的上下文。
- `kubeconfig` 路径可在 `$KUBECONFIG` 环境变量中获取。
- 您可以选择上下文，以便从 CI/CD 脚本中运行 `kubectl` 命令。

<a id="authorize-projects-in-your-groups-to-access-the-agent"></a>

### 授权您群组中的项目访问 Agent

要授权某个群组或子群组中的所有极狐GitLab 项目访问该 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，找到包含 [Agent 配置文件](install/_index.md#create-an-agent-configuration-file)（`config.yaml`）的项目。
1. 编辑 `config.yaml` 文件。在 `ci_access` 关键字下，添加 `groups` 属性。
1. 对于 `id`，添加路径：

   ```yaml
   ci_access:
     groups:
       - id: path/to/group/subgroup
   ```

   - 被授权的群组必须与 Agent 的配置项目具有相同的顶级群组，除非启用了
     [实例级授权](#authorize-all-projects-in-your-gitlab-instance-to-access-the-agent)应用设置。
   - 您可以将其他 Agent 安装到同一集群中，以适应其他层级结构。
   - 被授权群组的所有子群组也可以访问同一个 Agent（无需单独指定）。
   - 您最多可以授权 500 个群组。

进行这些更改后：

- 属于该群组及其子群组的所有项目现在都被授权访问该 Agent。
- 所有 CI/CD 作业现在都包含一个 `kubeconfig` 文件，其中包含每个共享 Agent 连接的上下文。
- `kubeconfig` 路径可在 `$KUBECONFIG` 环境变量中获取。
- 您可以选择上下文，以便从 CI/CD 脚本中运行 `kubectl` 命令。

<a id="authorize-all-projects-in-your-gitlab-instance-to-access-the-agent"></a>

### 授权您极狐GitLab 实例中的所有项目访问 Agent

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员。

要允许将 Agent 配置为授权您极狐GitLab 实例中的所有项目：

{{< tabs >}}

{{< tab title="使用 UI" >}}

1. 在**管理**区域中，选择**设置** > **通用**，然后展开**极狐GitLab Kubernetes Agent** 部分。
1. 选择 **启用实例级别授权**。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="Using the API" >}}

1. [更新应用设置](../../../api/settings.md#update-application-settings) `organization_cluster_agent_authorization_enabled` 为 `true`。

{{< /tab >}}

{{< /tabs >}}

要授权该 Agent 访问所有极狐GitLab 项目：

1. 在顶部栏中，选择**搜索或跳转到**，找到包含 [Agent 配置文件](install/_index.md#create-an-agent-configuration-file)（`config.yaml`）的项目。
1. 编辑 `config.yaml` 文件。在 `ci_access` 关键字下，添加 `instance` 属性：

   ```yaml
   ci_access:
     instance: {}
   ```

对 Agent 配置文件进行这些更改后：

- 您实例中所有项目的所有 CI/CD 作业都被授权访问该 Agent。
  您可以使用 CI/CD 作业模拟配合 RBAC，按需授予或限制访问权限。
  有关更多信息，请参阅[使用模拟限制项目和群组访问](#restrict-project-and-group-access-by-using-impersonation)。
- 所有 CI/CD 作业都包含一个 `kubeconfig` 文件，其中包含每个共享 Agent 连接的上下文。
- `kubeconfig` 路径可在 `$KUBECONFIG` 环境变量中获取。
- 您可以选择上下文，以便从 CI/CD 脚本中运行 `kubectl` 命令。

<a id="update-your-gitlab-ciyml-file-to-run-kubectl-commands"></a>

## 更新您的 `.gitlab-ci.yml` 文件以运行 `kubectl` 命令

在您想要运行 Kubernetes 命令的项目中，编辑该项目的 `.gitlab-ci.yml` 文件。

在 `script` 关键字下的第一条命令中，设置您的 Agent 上下文。使用格式 `<path/to/agent/project>:<agent-name>`。例如：

```yaml
deploy:
  image: debian:13-slim
  variables:
    KUBECTL_VERSION: v1.34
    DEBIAN_FRONTEND: noninteractive
  script:
    # Follows https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
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

如果您不确定 Agent 的上下文是什么，请在您想要访问该 Agent 的 CI/CD 作业中运行 `kubectl config get-contexts`。

<a id="environments-that-use-auto-devops"></a>

### 使用 Auto DevOps 的环境

如果启用了 Auto DevOps，则必须定义 CI/CD 变量 `KUBE_CONTEXT`。
将 `KUBE_CONTEXT`的值设置为您希望 Auto DevOps 使用的 Agent 上下文：

```yaml
deploy:
  variables:
    KUBE_CONTEXT: path/to/agent/project:agent-name
```

您可以将不同的 Agent 分配给不同的 Auto DevOps 作业。例如，
Auto DevOps 可以将一个 Agent 用于 `staging` 作业，将另一个 Agent 用于 `production` 作业。
要使用多个 Agent，请为每个 Agent 定义一个[环境作用域 CI/CD 变量](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。例如：

1. 定义两个名为 `KUBE_CONTEXT`的变量。
1. 对于第一个变量：
   1. 将 `environment` 设置为 `staging`。
   1. 将值设置为您的预发布 Agent 的上下文。
1. 对于第二个变量：
   1. 将 `environment` 设置为 `production`。
   1. 将值设置为您的生产 Agent 的上下文。

<a id="environments-with-both-certificate-based-and-agent-based-connections"></a>

### 同时使用基于证书和基于 Agent 连接的环境

当您部署到同时具有[基于证书的集群](../../infrastructure/clusters/_index.md)（已弃用）和 Agent 连接的环境时：

- 基于证书的集群的上下文称为 `gitlab-deploy`。此上下文
  始终默认被选中。
- Agent 上下文包含在 `$KUBECONFIG`中。
  您可以使用 `kubectl config use-context <path/to/agent/project>:<agent-name>` 选择它们。

当存在基于证书的连接时，要使用 Agent 连接，您可以手动配置一个新的 `kubectl` 配置上下文。例如：

```yaml
deploy:
  variables:
    KUBE_CONTEXT: my-context # The name to use for the new context
    AGENT_ID: 1234 # replace with your agent's numeric ID
    K8S_PROXY_URL: https://<KAS_DOMAIN>/k8s-proxy/ # For agent server (KAS) deployed in Kubernetes cluster (for gitlab.com use kas.gitlab.com); replace with your URL
    # K8S_PROXY_URL: https://<GITLAB_DOMAIN>/-/kubernetes-agent/k8s-proxy/ # For agent server (KAS) in Omnibus
    # Include any additional variables
  before_script:
    - kubectl config set-credentials agent:$AGENT_ID --token="ci:${AGENT_ID}:${CI_JOB_TOKEN}"
    - kubectl config set-cluster gitlab --server="${K8S_PROXY_URL}"
    - kubectl config set-context "$KUBE_CONTEXT" --cluster=gitlab --user="agent:${AGENT_ID}"
    - kubectl config use-context "$KUBE_CONTEXT"
  # Include the remaining job configuration
```

<a id="environments-with-kas-that-use-self-signed-certificates"></a>

### 使用自签名证书的 KAS 环境

如果您使用带有 KAS 和自签名证书的环境，则必须将 Kubernetes 客户端配置为信任签署您证书的证书颁发机构（CA）。

要配置您的客户端，请执行以下操作之一：

- 设置一个 CI/CD 变量 `SSL_CERT_FILE`，其中包含 PEM 格式的 KAS 证书。
- 使用 `--certificate-authority=$KAS_CERTIFICATE` 配置 Kubernetes 客户端，其中 `KAS_CERTIFICATE` 是包含 KAS 的 CA 证书的 CI/CD 变量。
- 通过更新容器镜像或通过 Runner 挂载，将证书放置在作业容器中的适当位置。
- 不推荐。使用 `--insecure-skip-tls-verify=true` 配置 Kubernetes 客户端。

<a id="restrict-project-and-group-access-by-using-impersonation"></a>

## 使用模拟限制项目和群组访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，您的 CI/CD 作业会继承用于在集群中安装 Agent 的服务账号的所有权限。要限制对集群的访问，您可以使用[模拟](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation)。

要指定模拟，请在 Agent 配置文件中使用 `access_as` 属性，并使用 Kubernetes RBAC 规则来管理被模拟账号的权限。

您可以模拟：

- Agent 本身（默认）。
- 访问集群的 CI/CD 作业。
- 集群中定义的特定用户或系统账号。

授权配置可能需要一到两分钟才能生效。

<a id="impersonate-the-agent"></a>

### 模拟 Agent

默认情况下会模拟 Agent。您无需执行任何操作即可模拟它。

<a id="impersonate-the-cicd-job-that-accesses-the-cluster"></a>

### 模拟访问集群的 CI/CD 作业

要模拟访问集群的 CI/CD 作业，请在 `access_as` 键下，添加 `ci_job: {}` 键值对。

当 Agent 向实际的 Kubernetes API 发出请求时，它会按以下方式设置模拟凭据：

- `UserName` 设置为 `gitlab:ci_job:<job id>`。例如：`gitlab:ci_job:1074499489`。
- `Groups` 设置为：

  - `gitlab:ci_job`，用于标识所有来自 CI 作业的请求。
  - 项目所属群组的 ID 列表。
  - 项目 ID。
  - 此作业所属环境的 slug 和层级。

    例如：对于 `group1/group1-1/project1`中的 CI 作业，其中：

    - 群组 `group1`的 ID 为 23。
    - 群组 `group1/group1-1`的 ID 为 25。
    - 项目 `group1/group1-1/project1`的 ID 为 150。
    - 作业在 `prod` 环境中运行，该环境具有 `production` 环境层级。

  群组列表将为 `[gitlab:ci_job, gitlab:group:23, gitlab:group_env_tier:23:production, gitlab:group:25, gitlab:group_env_tier:25:production, gitlab:project:150, gitlab:project_env:150:prod, gitlab:project_env_tier:150:production]`。

- `Extra` 携带有关请求的额外信息。以下属性设置在模拟身份上：

| 属性                             | 描述                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------------- |
| `agent.gitlab.com/id`                | 包含 Agent ID。                                                       |
| `agent.gitlab.com/config_project_id` | 包含 Agent 的配置项目 ID。                               |
| `agent.gitlab.com/project_id`        | 包含 CI 项目 ID。                                                  |
| `agent.gitlab.com/ci_pipeline_id`    | 包含 CI 流水线 ID。                                                 |
| `agent.gitlab.com/ci_job_id`         | 包含 CI 作业 ID。                                                      |
| `agent.gitlab.com/username`          | 包含运行该 CI 作业的用户的用户名。                  |
| `agent.gitlab.com/environment_slug`  | 包含环境的 slug。仅在环境中运行时设置。 |
| `agent.gitlab.com/environment_tier`  | 包含环境的层级。仅在环境中运行时设置。 |

用于按 CI/CD 作业身份限制访问的示例 `config.yaml`：

```yaml
ci_access:
  projects:
    - id: path/to/project
      access_as:
        ci_job: {}
```

<a id="example-rbac-to-restrict-cicd-jobs"></a>

#### 用于限制 CI/CD 作业的 RBAC 示例

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

对于给定的连接，您可以使用静态身份进行模拟。

在 `access_as` 键下，添加 `impersonate` 键，以使用提供的身份发出请求。

可以使用以下键指定身份：

- `username`（必需）
- `uid`
- `groups`
- `extra`

有关详细信息，请参阅 [Kubernetes 官方文档](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation)。

<a id="restrict-project-and-group-access-to-specific-environments"></a>

## 将项目和群组访问限制到特定环境

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，如果您的 Agent [可供某个项目使用](#authorize-agent-access)，则该项目的所有 CI/CD 作业都可以使用该 Agent。

要将对该 Agent 的访问限制为仅具有特定环境的作业，请将 `environments` 添加到 `ci_access.projects` 或 `ci_access.groups`。例如：

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

- `project-1` 下的所有 CI/CD 作业都可以访问该 Agent。
- `project-2` 下具有 `staging` 或 `review/*` 环境的 CI/CD 作业可以访问该 Agent。
  - `*` 是通配符，因此 `review/*` 匹配 `review` 下的所有环境。
- `group-1` 下具有 `production` 环境的项目的 CI/CD 作业可以访问该 Agent。

<a id="restrict-access-to-the-agent-to-protected-branches"></a>

## 将对 Agent 的访问限制到受保护分支

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

要将对该 Agent 的访问限制为仅在[受保护分支](../../project/repository/branches/protected.md)上运行的作业：

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

默认情况下，`protected_branches_only` 设置为 `false`，并且可以从非受保护分支和受保护分支访问该 Agent。

为增强安全性，您可以将此功能与[环境限制](#restrict-project-and-group-access-to-specific-environments)结合使用。

如果某个项目有多个配置，则只使用最具体的配置。例如，以下配置授予对 `example/my-project`中非受保护分支的访问权限，即使 `example` 群组被配置为仅授予对受保护分支的访问权限：

```yaml
# .gitlab/agents/my-agent/config.yaml
ci_access:
  project:
    - id: example/my-project # Project of the group below
      protected_branches_only: false # This configuration supersedes the group configuration
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

### 授予对 `~/.kube/cache`的写入权限

`kubectl`、Helm、`kpt` 和 `kustomize` 等工具会将有关集群的信息缓存在 `~/.kube/cache`中。如果此目录不可写，该工具会在每次调用时获取信息，从而使交互变慢，并对集群造成不必要的负载。为获得最佳体验，请在您的 `.gitlab-ci.yml` 文件中使用的镜像中，确保此目录可写。

<a id="enable-tls"></a>

### 启用 TLS

如果您使用极狐GitLab 私有化部署，请确保您的实例配置了传输层安全（TLS）。

如果您尝试在没有 TLS 的情况下使用 `kubectl`，可能会收到如下错误：

```shell
$ kubectl get pods
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

<a id="unable-to-connect-to-the-server-certificate-signed-by-unknown-authority"></a>

### 无法连接到服务器：证书由未知机构签署

如果您使用带有 KAS 和自签名证书的环境，您的 `kubectl` 调用可能会返回此错误：

```plaintext
kubectl get pods
Unable to connect to the server: x509: certificate signed by unknown authority
```

出现此错误是因为该作业不信任签署 KAS 证书的证书颁发机构（CA）。

要解决此问题，请[将 `kubectl` 配置为信任该 CA](#environments-with-kas-that-use-self-signed-certificates)。

<a id="validation-errors"></a>

### 验证错误

如果您使用 `kubectl` v1.27.0 或 v1.27.1 版本，可能会收到以下错误：

```plaintext
error: error validating "file.yml": error validating data: the server responded with the status code 426 but did not return more information; if you choose to ignore these errors, turn validation off with --validate=false
```

此问题是由 `kubectl` 及其他使用共享 Kubernetes 库的工具的[一个缺陷](https://github.com/kubernetes/kubernetes/issues/117463)引起的。

要解决此问题，请使用其他版本的 `kubectl`。
