---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目级 Kubernetes 集群（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在 极狐GitLab 14.5 中[已弃用](https://jihulab.com/groups/gitlab-cn/configure/-/epics/8)。要将集群连接到 极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

[项目级](../../infrastructure/clusters/connect/_index.md#cluster-levels-deprecated) Kubernetes 集群允许你将 Kubernetes 集群连接到 极狐GitLab 中的项目。

你还可以[将多个集群](multiple_kubernetes_clusters.md)连接到单个项目。

<a id="view-your-project-level-clusters"></a>

查看项目级集群

要查看项目级 Kubernetes 集群：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **运维** > **Kubernetes 集群**。

