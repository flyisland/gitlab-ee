---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群证书的访问控制（RBAC 或 ABAC）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在 极狐GitLab 14.5 中弃用。
> 要连接集群到极狐GitLab，请改为使用[极狐GitLab Kubernetes agent](../../clusters/agent/_index.md)。

在极狐GitLab中创建集群时，您会被询问是否要创建以下任一类型的集群：

- [基于角色的访问控制（RBAC）](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) 集群，这是极狐GitLab的默认和推荐选项。
- [基于属性的访问控制（ABAC）](https://kubernetes.io/docs/reference/access-authn-authz/abac/) 集群。

当极狐GitLab创建集群时，会在 `default` 命名空间中创建一个拥有 `cluster-admin` 权限的 `gitlab` 服务账号，用于管理新创建的集群。

Helm 还会为每个安装的应用程序创建额外的服务账号和其他资源。有关详细信息，请参阅每个应用程序的 Helm chart 文档。

如果您正在[添加现有 Kubernetes 集群](add_existing_cluster.md)，请确保该账号的令牌具有集群的管理员权限。

极狐GitLab 创建的资源因集群类型而异。

<a id="important-notes"></a>

## 重要说明

关于访问控制，请注意以下事项：

- 特定于环境的资源仅在集群[由极狐GitLab管理](gitlab_managed_clusters.md)时才会创建。
- 如果集群是在极狐GitLab 12.2 之前创建的，则会为所有项目环境使用单个命名空间。

<a id="rbac-cluster-resources"></a>

## RBAC 集群资源

极狐GitLab 会为 RBAC 集群创建以下资源。

| 名称                | 类型                 | 详细信息                                                                                                    | 创建时机               |
|:--------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------|:-----------------------|
| `gitlab`            | `ServiceAccount`     | `default` 命名空间                                                                                         | 新建集群时             |
| `gitlab-admin`      | `ClusterRoleBinding` | [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 角色    | 新建集群时             |
| `gitlab-token`      | `Secret`             | `gitlab` 服务账号的令牌                                                                                    | 新建集群时             |
| 环境命名空间        | `Namespace`          | 包含所有特定于环境的资源                                                                                   | 部署到集群时           |
| 环境命名空间        | `ServiceAccount`     | 使用环境的命名空间                                                                                         | 部署到集群时           |
| 环境命名空间        | `Secret`             | 环境服务账号的令牌                                                                                         | 部署到集群时           |
| 环境命名空间        | `RoleBinding`        | [`admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 角色            | 部署到集群时           |

<a id="abac-cluster-resources"></a>

## ABAC 集群资源

极狐GitLab 会为 ABAC 集群创建以下资源。

| 名称                | 类型                 | 详细信息                               | 创建时机               |
|:--------------------|:---------------------|:---------------------------------------|:-----------------------|
| `gitlab`            | `ServiceAccount`     | `default` 命名空间                     | 新建集群时             |
| `gitlab-token`      | `Secret`             | `gitlab` 服务账号的令牌                | 新建集群时             |
| 环境命名空间        | `Namespace`          | 包含所有特定于环境的资源               | 部署到集群时           |
| 环境命名空间        | `ServiceAccount`     | 使用环境的命名空间                     | 部署到集群时           |
| 环境命名空间        | `Secret`             | 环境服务账号的令牌                     | 部署到集群时           |

<a id="security-of-runners"></a>

## Runner 的安全

Runner 默认启用了[特权模式](https://gitlab.cn/docs/runner/executors/docker/#the-privileged-mode)，允许它们执行特殊命令并运行 Docker in Docker。运行某些 [Auto DevOps](../../../topics/autodevops/_index.md) 作业需要此功能。这意味着容器以特权模式运行，因此您应该注意一些重要细节。

特权标志赋予运行中的容器所有能力，进而使它几乎可以执行主机能够执行的任何操作。请注意在任意镜像上执行 `docker run` 操作所固有的安全风险，因为这些操作实际上具有 root 访问权限。

如果您不想在特权模式下使用 Runner，可以选择以下方法之一：

- 在 JihuLab.com 上使用实例 Runner。它们不存在此安全问题。
- 设置您自己的使用 [`docker+machine`](https://gitlab.cn/docs/runner/executors/docker_machine/) 的 Runner。

