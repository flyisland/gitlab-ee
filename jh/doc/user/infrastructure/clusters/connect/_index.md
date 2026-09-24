---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将集群连接到极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

基于证书的 [Kubernetes 与极狐GitLab 集成](../_index.md) 在 极狐GitLab 14.5 中已 [弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。要连接你的集群，请使用 [极狐GitLab Kubernetes 代理](../../../clusters/agent/_index.md)。

<a id="cluster-levels-deprecated"></a>

## 集群级别（已弃用）

{{< history >}}

- [已弃用] 于 极狐GitLab 14.5。

{{< /history >}}

> [!warning]
> [集群级别的概念](../_index.md#cluster-levels) 在 极狐GitLab 14.5 中已弃用。

根据用途选择集群级别：

| 级别                                                  | 用途 |
|--------------------------------------------------------|---------|
| [项目级别](../../../project/clusters/_index.md)   | 为单个项目使用你的集群。 |
| [群组级别](../../../group/clusters/_index.md)       | 在你群组内的多个项目中使用同一个集群。 |
| [实例级别](../../../instance/clusters/_index.md) | 在你实例内的群组和项目中使用同一个集群。 |

<a id="view-your-clusters"></a>

### 查看你的集群

要查看连接到你的项目、群组或实例的 Kubernetes 集群，请根据集群级别打开相应页面。

**项目级集群**：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。

**群组级集群**：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。

**实例级集群**：

前提条件：

- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Kubernetes**。

<a id="security-implications-for-clusters-connected-with-certificates"></a>

## 使用证书连接的集群的安全隐患

{{< history >}}

- 通过集群证书将集群连接到 极狐GitLab 在 极狐GitLab 14.5 中已 [弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

{{< /history >}}

> [!warning]
> 整个集群安全基于一个信任 [开发者](../../../permissions.md) 的模型，因此 **只应允许受信任的用户控制你的集群**。

使用集群证书连接集群会授予一套广泛的功能，以便成功构建和部署容器化应用。请记住，同一凭证会被用于集群上运行的所有应用。
