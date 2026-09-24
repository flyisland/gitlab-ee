---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组级别 Kubernetes 集群（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[弃用](https://jihulab.com/groups/gitlab-cn/configure/-/epics/8)。要将集群连接到极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

与[项目级](../../project/clusters/_index.md)和[实例级](../../instance/clusters/_index.md) Kubernetes 集群类似，群组级别 Kubernetes 集群允许你将 Kubernetes 集群连接到你的群组，从而使你能够在多个项目中使用同一个集群。

查看你的群组级别 Kubernetes 集群：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **运维** > **Kubernetes**。

<a id="cluster-management-project"></a>

## 集群管理项目

将[集群管理项目](../../clusters/management_project.md)附加到你的集群，以管理安装时需要 `cluster-admin` 权限的共享资源，例如 Ingress 控制器。

<a id="rbac-compatibility"></a>

## RBAC 兼容性

对于带有 Kubernetes 集群的群组下的每个项目，极狐GitLab 在项目命名空间中创建一个具有 [`编辑` 权限](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)的受限服务账号。

<a id="cluster-precedence"></a>

## 集群优先级

如果项目的集群可用且未被禁用，极狐GitLab 会优先使用项目集群，然后再使用包含该项目的群组中的任何集群。
对于子群组，极狐GitLab 使用距离项目最近的祖先群组的集群，前提是该集群未被禁用。

<a id="multiple-kubernetes-clusters"></a>

## 多个 Kubernetes 集群

你可以将多个 Kubernetes 集群关联到你的群组，并为不同的环境（如开发、预发布和生产）维护不同的集群。
添加其他集群时，[设置环境范围](#environment-scopes)以帮助区分新集群与其他集群。

<a id="gitlab-managed-clusters"></a>

## 极狐GitLab 管理的集群

你可以选择让极狐GitLab 为你管理集群。如果极狐GitLab 管理集群，则会自动创建项目资源。有关极狐GitLab 为你创建哪些资源的详细信息，请参阅[访问控制](../../project/clusters/cluster_access.md)部分。

对于不由极狐GitLab 管理的集群，不会自动创建项目特定资源。如果你在使用 [Auto DevOps](../../../topics/autodevops/_index.md) 对不由极狐GitLab 管理的集群进行部署，则必须确保：

- 项目的部署服务账号具有部署到 [`KUBE_NAMESPACE`](../../project/clusters/deploy_to_cluster.md#deployment-variables) 的权限。
- `KUBECONFIG` 正确反映 `KUBE_NAMESPACE` 的任何更改（此过程[不是自动的](https://jihulab.com/gitlab-cn/gitlab/-/issues/31519)）。不建议直接编辑 `KUBE_NAMESPACE`。

<a id="clearing-the-cluster-cache"></a>

### 清除集群缓存

如果你选择让极狐GitLab 管理集群，极狐GitLab 会存储它为你项目创建的命名空间和服务账号的缓存版本。如果你手动在集群中修改这些资源，该缓存可能会与集群不同步，从而导致部署作业失败。

要清除缓存：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **运维** > **Kubernetes**。
1. 选择你的集群。
1. 展开 **高级设置**。
1. 选择 **清除集群缓存**。

<a id="base-domain"></a>

## 基础域名

集群级别的域名支持按照[多个 Kubernetes 集群](#multiple-kubernetes-clusters)使用多个域名。当指定域名时，会在 [Auto DevOps](../../../topics/autodevops/_index.md) 阶段自动设置为环境变量（`KUBE_INGRESS_BASE_DOMAIN`）。

该域名应将通配符 DNS 配置为指向 Ingress IP 地址。[更多详情](../../project/clusters/gitlab_managed_clusters.md#base-domain)。

<a id="environment-scopes"></a>

## 环境范围

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当向你的项目添加多个 Kubernetes 集群时，你需要使用环境范围来区分它们。环境范围将集群与[环境](../../../ci/environments/_index.md)关联起来，这与[环境特定的 CI/CD 变量](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)的工作方式类似。

在评估哪个环境与集群的环境范围匹配时，[集群优先级](#cluster-precedence)会生效。项目级别的集群优先，其次是最接近的祖先群组，然后是祖先群组的父级，依此类推。

例如，如果你的项目有以下 Kubernetes 集群：

| 集群       | 环境范围            | 位置     |
| ---------- | ------------------- | -------- |
| Project    | `*`                 | 项目     |
| Staging    | `staging/*`         | 项目     |
| Production | `production/*`      | 项目     |
| Test       | `test`              | 群组     |
| Development| `*`                 | 群组     |

并且 `.gitlab-ci.yml` 文件中设置有以下环境：

```yaml
stages:
  - test
  - deploy

test:
  stage: test
  script: sh test

deploy to staging:
  stage: deploy
  script: make deploy
  environment:
    name: staging/$CI_COMMIT_REF_NAME
    url: https://staging.example.com/

deploy to production:
  stage: deploy
  script: make deploy
  environment:
    name: production/$CI_COMMIT_REF_NAME
    url: https://example.com/
```

结果为：

- Project 集群用于 `test` 作业。
- Staging 集群用于 `deploy to staging` 作业。
- Production 集群用于 `deploy to production` 作业。

<a id="cluster-environments"></a>

## 集群环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要查看哪些 CI [环境](../../../ci/environments/_index.md)被部署到 Kubernetes 集群的统一视图，请参阅[集群环境](../../clusters/environments.md)文档。

<a id="security-of-runners"></a>

## Runner 安全

有关安全配置 Runner 的重要信息，请参阅项目级集群的 [Runner 安全性](../../project/clusters/cluster_access.md#security-of-runners)文档。

<a id="more-information"></a>

## 更多信息

有关极狐GitLab 与 Kubernetes 集成的信息，请参阅 [Kubernetes 集群](../../infrastructure/clusters/_index.md)。