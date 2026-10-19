---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组级 Kubernetes 集群（基于证书）（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。要将集群连接到极狐GitLab，
> 请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

与[项目级](../../project/clusters/_index.md)和
[实例级](../../instance/clusters/_index.md) Kubernetes 集群类似，
群组级 Kubernetes 集群允许您将 Kubernetes 集群连接到
您的群组，使您能够在多个项目中使用同一个集群。

要查看您的群组级 Kubernetes 集群：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**运维** > **Kubernetes**。

<a id="cluster-management-project"></a>

## 集群管理项目

将[集群管理项目](../../clusters/management_project.md)附加到您的集群，以管理需要 `cluster-admin` 权限才能安装的共享资源，例如 Ingress 控制器。

<a id="rbac-compatibility"></a>

## RBAC 兼容性

对于群组下具有 Kubernetes 集群的每个项目，极狐GitLab 会在项目命名空间中创建一个具有 [`edit` 权限](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)的受限服务账号。

<a id="cluster-precedence"></a>

## 集群优先级

如果项目的集群可用且未禁用，极狐GitLab 会先使用项目的集群，然后再使用包含该项目的群组所属的任何集群。对于子群组，极狐GitLab 会使用距离项目最近的祖先群组的集群，前提是该集群未被禁用。

<a id="multiple-kubernetes-clusters"></a>

## 多个 Kubernetes 集群

您可以将多个 Kubernetes 集群关联到您的群组，并为不同的环境（例如开发、预发布和生产）维护不同的集群。

添加另一个集群时，请[设置环境范围](#environment-scopes)，以帮助将新集群与您的其他集群区分开来。

<a id="gitlab-managed-clusters"></a>

## 极狐GitLab 管理的集群

您可以选择允许极狐GitLab 为您管理集群。如果由极狐GitLab 管理您的集群，则会自动为您的项目创建资源。有关极狐GitLab 为您创建哪些资源的详细信息，请参阅[访问控制](../../project/clusters/cluster_access.md)部分。

对于不由极狐GitLab 管理的集群，不会自动创建项目专属资源。
如果您使用 [Auto DevOps](../../../topics/autodevops/_index.md)
在不由极狐GitLab 管理的集群上进行部署，则必须确保：

- 项目的部署服务账号具有部署到
  [`KUBE_NAMESPACE`](../../project/clusters/deploy_to_cluster.md#deployment-variables)的权限。
- `KUBECONFIG` 正确反映对 `KUBE_NAMESPACE`的任何更改
  （这[不是自动的](https://gitlab.com/gitlab-org/gitlab/-/issues/31519)）。不建议
  直接编辑 `KUBE_NAMESPACE`。

<a id="clearing-the-cluster-cache"></a>

### 清除集群缓存

如果您选择允许极狐GitLab 为您管理集群，极狐GitLab 会存储它为您的项目创建的命名空间和服务账号的缓存版本。如果您在集群中手动修改这些资源，此缓存可能会与您的集群不同步，从而导致部署作业失败。

要清除缓存：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**运维** > **Kubernetes**。
1. 选择您的集群。
1. 展开**高级设置**。
1. 选择**清除集群缓存**。

<a id="base-domain"></a>

## 基础域名

集群级别的域名允许为[多个 Kubernetes 集群](#multiple-kubernetes-clusters)支持多个域名。指定域名时，会在 [Auto DevOps](../../../topics/autodevops/_index.md) 阶段自动将其设置为环境变量
（`KUBE_INGRESS_BASE_DOMAIN`）。

该域名应配置指向 Ingress IP 地址的通配符 DNS。[更多详情](../../project/clusters/gitlab_managed_clusters.md#base-domain)。

<a id="environment-scopes"></a>

## 环境范围

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当向您的项目添加多个 Kubernetes 集群时，您需要使用环境范围来区分它们。环境范围将集群与[环境](../../../ci/environments/_index.md)关联，其工作方式类似于[特定于环境的 CI/CD 变量](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

在评估哪个环境与集群的环境范围匹配时，[集群优先级](#cluster-precedence)会生效。项目级别的集群优先，其次是最近的祖先群组，再其次是该群组的父群组，依此类推。

例如，如果您的项目具有以下 Kubernetes 集群：

| 集群    | 环境范围   | 位置     |
| ---------- | ------------------- | ----------|
| Project    | `*`                 | 项目   |
| Staging    | `staging/*`         | 项目   |
| Production | `production/*`      | 项目   |
| Test       | `test`              | 群组     |
| Development| `*`                 | 群组     |

并且在 `.gitlab-ci.yml` 文件中设置了以下环境：

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

- `test` 作业使用 Project 集群。
- `deploy to staging` 作业使用 Staging 集群。
- `deploy to production` 作业使用 Production 集群。

<a id="cluster-environments"></a>

## 集群环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要查看哪些 CI [环境](../../../ci/environments/_index.md)部署到 Kubernetes 集群的整合视图，请参阅[集群环境](../../clusters/environments.md)文档。

<a id="security-of-runners"></a>

## Runner 的安全性

有关安全配置 Runner 的重要信息，请参阅项目级集群的
[Runner 的安全性](../../project/clusters/cluster_access.md#security-of-runners)
文档。

<a id="more-information"></a>

## 更多信息

有关集成极狐GitLab 和 Kubernetes 的信息，请参阅
[Kubernetes 集群](../../infrastructure/clusters/_index.md)。
