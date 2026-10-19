---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例 Kubernetes 集群（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[弃用](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。要将集群连接到极狐GitLab，
> 请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

与[项目](../../project/clusters/_index.md)和[群组](../../group/clusters/_index.md)的 Kubernetes 集群类似，实例 Kubernetes 集群使您能够将 Kubernetes 集群连接到极狐GitLab 实例，并在多个项目之间使用同一集群。

要查看实例的 Kubernetes 集群：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Kubernetes**。

<a id="cluster-precedence"></a>

## 集群优先级

极狐GitLab 按以下顺序尝试匹配集群：

- 项目集群。
- 群组集群。
- 实例集群。

要能被选中，集群必须已启用，并匹配[环境选择器](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

<a id="cluster-environments"></a>

## 集群环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要查看哪些 CI [环境](../../../ci/environments/_index.md)已部署到 Kubernetes 集群的整合视图，请参阅[集群环境](../../clusters/environments.md)文档。

<a id="more-information"></a>

## 更多信息

有关集成极狐GitLab 和 Kubernetes 的信息，请参阅[Kubernetes 集群](../../infrastructure/clusters/_index.md)。
