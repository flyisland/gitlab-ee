---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群证书部署到 Kubernetes 集群（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[弃用](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
> 要将您的集群连接到极狐GitLab，请使用 [极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。
> 要使用 Agent 进行部署，请使用 [CI/CD 工作流](../../clusters/agent/ci_cd_workflow.md)。

Kubernetes 集群可以作为部署作业的目标。如果

- 集群已与极狐GitLab 集成，您的作业将可以使用特殊的
  [部署变量](#deployment-variables)，并且无需配置。您可以立即使用诸如 `kubectl` 或 `helm` 等工具从作业中与集群交互。
- 您未使用极狐GitLab 集群集成，您仍然可以部署到您的集群。但是，您必须先使用 [CI/CD 变量](../../../ci/variables/_index.md#for-a-project) 自行配置 Kubernetes 工具，然后才能从作业中与集群交互。

<a id="deployment-variables"></a>

## 部署变量

部署变量需要一个名为 [`gitlab-deploy-token`](../deploy_tokens/_index.md#gitlab-deploy-token) 的有效 [部署令牌](../deploy_tokens/_index.md)，并且在您的部署作业脚本中包含以下命令，以便 Kubernetes 访问镜像仓库：

- 使用 Kubernetes 1.18+：

  ```shell
  kubectl create secret docker-registry gitlab-registry --docker-server="$CI_REGISTRY" --docker-username="$CI_DEPLOY_USER" --docker-password="$CI_DEPLOY_PASSWORD" --docker-email="$GITLAB_USER_EMAIL" -o yaml --dry-run=client | kubectl apply -f -
  ```

- 使用 Kubernetes <1.18：

  ```shell
  kubectl create secret docker-registry gitlab-registry --docker-server="$CI_REGISTRY" --docker-username="$CI_DEPLOY_USER" --docker-password="$CI_DEPLOY_PASSWORD" --docker-email="$GITLAB_USER_EMAIL" -o yaml --dry-run | kubectl apply -f -
  ```

Kubernetes 集群集成在极狐GitLab CI/CD 构建环境中向部署作业公开以下
[部署变量](../../../ci/variables/predefined_variables.md#deployment-variables)。部署作业已
[定义目标环境](../../../ci/environments/_index.md)。

| 部署变量        | 描述 |
|----------------------------|-------------|
| `KUBE_URL`                 | 等于 API URL。 |
| `KUBE_TOKEN`               | [环境服务账号](cluster_access.md)的 Kubernetes 令牌。 |
| `KUBE_NAMESPACE`           | 与项目的部署服务账号关联的命名空间。格式为 `<project_name>-<project_id>-<environment>`。对于极狐GitLab 管理的集群，极狐GitLab 会在集群中自动创建匹配的命名空间。如果您的集群是在极狐GitLab 12.2 之前创建的，则默认的 `KUBE_NAMESPACE` 设置为 `<project_name>-<project_id>`。 |
| `KUBE_CA_PEM_FILE`         | 包含 PEM 数据的文件路径。仅在指定了自定义 CA 捆绑包时存在。 |
| `KUBE_CA_PEM`              | （已弃用）原始 PEM 数据。仅在指定了自定义 CA 捆绑包时存在。 |
| `KUBECONFIG`               | 包含此部署的 `kubeconfig` 的文件路径。如果指定了 CA 捆绑包，则会嵌入其中。此配置还嵌入了 `KUBE_TOKEN` 中定义的相同令牌，因此您可能只需要此变量。此变量名也会被 `kubectl` 自动识别，因此如果您使用 `kubectl`，则无需显式引用它。 |
| `KUBE_INGRESS_BASE_DOMAIN` | 此变量可用于为每个集群设置域名。有关更多信息，请参阅 [集群域名](gitlab_managed_clusters.md#base-domain)。 |

<a id="custom-namespace"></a>

## 自定义命名空间

Kubernetes 集成向部署作业提供一个带有自动生成命名空间的 `KUBECONFIG`。它默认使用项目环境特定的命名空间，格式为 `<prefix>-<environment>`，其中 `<prefix>` 的格式为
`<project_name>-<project_id>`。有关更多信息，请参阅 [部署变量](#deployment-variables)。

您可以通过以下几种方式自定义部署命名空间：

- 您可以选择**按 [环境](../../../ci/environments/_index.md) 的命名空间**或**按项目的命名空间**。按环境的命名空间是默认且推荐的设置，因为它可以防止生产和非生产环境之间的资源混合。
- 使用项目级集群时，您还可以自定义命名空间前缀。使用按环境的命名空间时，部署命名空间为 `<prefix>-<environment>`，否则仅为 `<prefix>`。
- 对于**非托管**集群，自动生成的命名空间设置在 `KUBECONFIG` 中，但用户负责确保其存在。您可以使用
  [`environment:kubernetes:namespace`](../../../ci/environments/configure_kubernetes_deployments.md)
  在 `.gitlab-ci.yml` 中完全自定义此值。

当您自定义命名空间时，现有环境将保持与其当前命名空间的链接，直到您 [清除集群缓存](gitlab_managed_clusters.md#clearing-the-cluster-cache)。

<a id="protecting-credentials"></a>

### 保护凭据

默认情况下，任何可以创建部署作业的人都可以访问环境部署作业中的任何 CI/CD 变量。这包括 `KUBECONFIG`，它可以访问集群中关联服务账号可用的任何密钥。为确保您的生产凭据安全，请考虑使用
[受保护环境](../../../ci/environments/protected_environments.md)，
并结合以下任一方式：

- 极狐GitLab 管理的集群和按环境的命名空间。
- 每个受保护环境对应一个环境范围的集群。同一个集群可以使用多个受限服务账号多次添加。

<a id="web-terminals-for-kubernetes-clusters"></a>

## Kubernetes 集群的 Web 终端

Kubernetes 集成向您的 [环境](../../../ci/environments/_index.md) 添加 [Web 终端](../../../ci/environments/_index.md#web-terminals-deprecated) 支持。这基于 Docker 和 Kubernetes 中的 `exec` 功能，因此您可以在现有容器中获得新的 shell 会话。要使用此集成，您应使用此页面上的部署变量部署到 Kubernetes，确保所有部署、副本集和 Pod 都带有以下注解：

- `app.gitlab.com/env: $CI_ENVIRONMENT_SLUG`
- `app.gitlab.com/app: $CI_PROJECT_PATH_SLUG`

`$CI_ENVIRONMENT_SLUG` 和 `$CI_PROJECT_PATH_SLUG` 是 CI/CD 变量的值。

您必须是项目所有者或具有 `maintainer` 权限才能使用终端。支持仅限于环境第一个 Pod 中的第一个容器。

<a id="troubleshooting"></a>

## 故障排查

在部署作业开始之前，极狐GitLab 会专门为部署作业创建以下内容：

- 一个命名空间。
- 一个服务账号。

但是，有时极狐GitLab 无法创建它们。在这种情况下，您的作业可能会失败并显示以下消息：

```plaintext
This job failed because the necessary resources were not successfully created.
```

要查找创建命名空间和服务账号时出现此错误的原因，请检查 [日志](../../../administration/logs/_index.md#kuberneteslog-deprecated)。

失败原因包括：

- 您提供给极狐GitLab 的令牌没有极狐GitLab 所需的 [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 权限。
- 缺少 `KUBECONFIG` 或 `KUBE_TOKEN` 部署变量。要传递给您的作业，它们必须具有匹配的
  [`environment:name`](../../../ci/environments/_index.md)。如果您的作业未设置
  `environment:name`，则 Kubernetes 凭据不会传递给它。

> [!note]
> 从极狐GitLab 12.0 或更早版本升级的项目级集群，其配置方式可能会导致此错误。如果您想自行管理命名空间和服务账号，请确保清除
> [极狐GitLab 管理的集群](gitlab_managed_clusters.md) 选项。
