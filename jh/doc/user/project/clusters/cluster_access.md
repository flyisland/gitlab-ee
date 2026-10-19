---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群证书的访问控制（RBAC 或 ABAC）（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
> 要将集群连接到极狐GitLab，请改用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

在极狐GitLab 中创建集群时，系统会询问您要创建以下哪种集群：

- [基于角色的访问控制（RBAC）](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
  集群，这是极狐GitLab 的默认选项，也是推荐选项。
- [基于属性的访问控制（ABAC）](https://kubernetes.io/docs/reference/access-authn-authz/abac/)集群。

极狐GitLab 创建集群时，会在 `default` 命名空间中创建一个具有 `cluster-admin` 权限的 `gitlab` 服务账号，以管理新建的集群。

Helm 还会为每个已安装的应用创建额外的服务账号和其他资源。详情请查阅各应用的 Helm Chart 文档。

如果您要[添加现有 Kubernetes 集群](add_existing_cluster.md)，请确保该账号的令牌具有集群的管理员权限。

极狐GitLab 创建的资源因集群类型而异。

<a id="important-notes"></a>

## 重要说明

关于访问控制，请注意以下事项：

- 仅当您的集群[由极狐GitLab 管理](gitlab_managed_clusters.md)时，才会创建特定于环境的资源。
- 如果您的集群是在极狐GitLab 12.2 之前创建的，则所有项目环境共用一个命名空间。

<a id="rbac-cluster-resources"></a>

## RBAC 集群资源

极狐GitLab 会为 RBAC 集群创建以下资源。

| 名称                  | 类型                 | 详情                                                                                                    | 创建时机           |
|:----------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------|:-----------------------|
| `gitlab`              | `ServiceAccount`     | `default` 命名空间                                                                                        | 创建新集群时 |
| `gitlab-admin`        | `ClusterRoleBinding` | [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 角色    | 创建新集群时 |
| `gitlab-token`        | `Secret`             | `gitlab` 服务账号的令牌                                                                          | 创建新集群时 |
| 环境命名空间 | `Namespace`          | 包含所有特定于环境的资源                                                                | 部署到集群时 |
| 环境命名空间 | `ServiceAccount`     | 使用环境的命名空间                                                                              | 部署到集群时 |
| 环境命名空间 | `Secret`             | 环境服务账号的令牌                                                                       | 部署到集群时 |
| 环境命名空间 | `RoleBinding`        | [`admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 角色            | 部署到集群时 |

<a id="abac-cluster-resources"></a>

## ABAC 集群资源

极狐GitLab 会为 ABAC 集群创建以下资源。

| 名称                  | 类型                 | 详情                              | 创建时机               |
|:----------------------|:---------------------|:-------------------------------------|:---------------------------|
| `gitlab`              | `ServiceAccount`     | `default` 命名空间                         | 创建新集群时 |
| `gitlab-token`        | `Secret`             | `gitlab` 服务账号的令牌           | 创建新集群时 |
| 环境命名空间 | `Namespace`          | 包含所有特定于环境的资源 | 部署到集群时 |
| 环境命名空间 | `ServiceAccount`     | 使用环境的命名空间               | 部署到集群时 |
| 环境命名空间 | `Secret`             | 环境服务账号的令牌        | 部署到集群时 |

<a id="security-of-runners"></a>

## Runner 的安全性

Runner 默认启用[特权模式](https://gitlab.cn/docs/runner/executors/docker/#the-privileged-mode)，这允许它们执行特殊命令并以 Docker in Docker 方式运行。
运行部分 [Auto DevOps](../../../topics/autodevops/_index.md)
作业需要此功能。这意味着容器以特权模式运行，因此您应了解一些重要细节。

特权标志会为运行中的容器授予所有能力，进而使其几乎可以执行宿主机能执行的所有操作。请注意，对任意镜像执行 `docker run` 操作存在固有的安全风险，因为这些镜像实际上拥有 root 访问权限。

如果您不想使用特权模式下的 Runner，可以：

- 使用 JihuLab.com 上的实例 Runner。它们没有此安全问题。
- 设置您自己的使用 [`docker+machine`](https://gitlab.cn/docs/runner/executors/docker_machine/)的 Runner。
