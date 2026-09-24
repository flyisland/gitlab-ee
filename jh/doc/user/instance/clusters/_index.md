---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例 Kubernetes 集群（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此功能在 GitLab 14.5 中 [已弃用]。要将集群连接到极狐GitLab，请使用 [用于 Kubernetes 的极狐GitLab 代理](../../clusters/agent/_index.md)。

与用于[项目](../../project/clusters/_index.md)和[群组](../../group/clusters/_index.md)的 Kubernetes 集群类似，实例 Kubernetes 集群允许你将一个 Kubernetes 集群连接到极狐GitLab 实例，并在多个项目中使用同一个集群。

要查看你的实例的 Kubernetes 集群：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **Kubernetes**。

<a id="cluster-precedence"></a>

## 集群优先级

极狐GitLab 按以下顺序尝试匹配集群：

- 项目集群。
- 群组集群。
- 实例集群。

要被选中，集群必须已启用并且匹配[环境选择器](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

<a id="cluster-environments"></a>

## 集群环境

{{< details >}}

- Tier: 专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

有关哪些 CI [环境](../../../ci/environments/_index.md)部署到 Kubernetes 集群的综合视图，请参阅[集群环境文档](../../clusters/environments.md)。

<a id="more-information"></a>

## 更多信息

有关集成极狐GitLab 和 Kubernetes 的信息，请参阅[Kubernetes 集群](../../infrastructure/clusters/_index.md)。