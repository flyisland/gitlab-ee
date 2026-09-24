---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集群管理项目（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.0 中，在私有化部署上禁用。

{{< /history >}}

> [!flag]
> 此功能在私有化部署上默认不可用。要使其可用，管理员可以启用名为 `certificate_based_clusters` 的[功能标志](../../administration/feature_flags/_index.md)。

可以将一个项目指定为集群的管理项目。

> [!warning]
> 集群管理项目在 极狐GitLab 14.5 中[已弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。
> 要管理集群应用，请使用 [极狐GitLab Kubernetes Agent](agent/_index.md)
> 和[集群管理项目模板](management_project_template.md)。

管理项目可用于运行具有 Kubernetes
[`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)
权限的部署作业。

这对于以下情况很有用：

- 创建流水线以将集群范围的应用安装到集群中，详情请参见[管理项目模板](management_project_template.md)。
- 任何需要 `cluster-admin` 权限的作业。

<a id="permissions"></a>

## 权限

只有管理项目会获得 `cluster-admin` 权限。所有
其他项目继续获得[命名空间范围的 `edit` 级别权限](../project/clusters/cluster_access.md#rbac-cluster-resources)。

管理项目受以下限制：

- 对于项目级集群，管理项目必须与集群的项目位于同一
  命名空间（或后代）中。
- 对于群组级集群，管理项目必须与集群的群组位于同一
  群组（或后代）中。
- 对于实例级集群，没有此类限制。

<a id="how-to-create-and-configure-a-cluster-management-project"></a>

## 如何创建和配置集群管理项目

要使用集群管理项目来管理集群：

1. 创建一个新项目作为集群的集群管理项目。
1. [将集群与管理项目关联](#associate-the-cluster-management-project-with-the-cluster)。
1. [配置集群的流水线](#configuring-your-pipeline)。
1. [设置环境范围](#setting-the-environment-scope)。

<a id="associate-the-cluster-management-project-with-the-cluster"></a>

### 将集群管理项目与集群关联

先决条件：

- 需要管理员权限才能关联实例集群。

要将集群管理项目与集群关联：

1. 前往相应的配置页面。对于：
   - [项目级集群](../project/clusters/_index.md)，前往项目的
     **运维** > **Kubernetes 集群**页面。
   - [群组级集群](../group/clusters/_index.md)，前往群组的 **Kubernetes**
     页面。
   - [实例级集群](../instance/clusters/_index.md)：
     1. 在右上角，选择 **管理员**。
     1. 选择 **Kubernetes**。
1. 展开 **高级设置**。
1. 从 **集群管理项目** 下拉列表中，选择在上一步中创建的集群管理项目。

<a id="configuring-your-pipeline"></a>

### 配置流水线

将项目指定为集群的管理项目后，
在该项目中添加一个 `.gitlab-ci.yml` 文件。例如：

```yaml
configure cluster:
  stage: deploy
  script: kubectl get namespaces
  environment:
    name: production
```

<a id="setting-the-environment-scope"></a>

### 设置环境范围

当将多个集群关联到同一个管理项目时，可以使用
[环境范围](../project/clusters/multiple_kubernetes_clusters.md#setting-the-environment-scope)。

每个范围只能由一个集群用于一个管理项目。

例如，以下 Kubernetes 集群关联
到一个管理项目：

| 集群     | 环境范围 |
| ----------- | ----------------- |
| Development | `*`               |
| Staging     | `staging`         |
| Production  | `production`      |

在 `.gitlab-ci.yml` 文件中设置的环境会部署到
Development、Staging 和 Production 集群。

```yaml
stages:
  - deploy

configure development cluster:
  stage: deploy
  script: kubectl get namespaces
  environment:
    name: development

configure staging cluster:
  stage: deploy
  script: kubectl get namespaces
  environment:
    name: staging

configure production cluster:
  stage: deploy
  script: kubectl get namespaces
  environment:
    name: production
```