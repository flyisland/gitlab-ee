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

[基于证书的 Kubernetes 与极狐GitLab 集成](../_index.md)
已在极狐GitLab 14.5 中[弃用](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
要连接集群，请使用[极狐GitLab Kubernetes Agent](../../../clusters/agent/_index.md)。

<a id="cluster-levels-deprecated"></a>

## 集群级别（已废弃）

> [!warning]
> [集群级别的概念](../_index.md#cluster-levels)
> 已在极狐GitLab 14.5 中废弃。

根据集群的用途选择集群级别：

| 级别                                                  | 用途 |
|--------------------------------------------------------|---------|
| [项目级别](../../../project/clusters/_index.md)   | 将集群用于单个项目。 |
| [群组级别](../../../group/clusters/_index.md)       | 在群组内的多个项目之间使用同一个集群。 |
| [实例级别](../../../instance/clusters/_index.md) | 在实例内的群组和项目之间使用同一个集群。 |

<a id="view-your-clusters"></a>

### 查看集群

要查看连接到您的项目、群组或实例的 Kubernetes 集群，请根据集群级别打开集群页面。

**项目级集群**：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。

**群组级集群**：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。

**实例级集群**：

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Kubernetes**。

<a id="security-implications-for-clusters-connected-with-certificates"></a>

## 使用证书连接的集群的安全影响

> [!warning]
> 整个集群的安全性基于一个信任[开发者](../../../permissions.md)的模型，
> 因此**只应允许受信任的用户控制您的集群**。

使用集群证书连接集群会授予成功构建和部署容器化应用所需的大量功能访问权限。请记住，集群上运行的所有应用都使用相同的凭据。
