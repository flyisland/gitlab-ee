---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Kubernetes 集群
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要将集群连接到极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

<a id="certificate-based-kubernetes-integration-deprecated"></a>

## 基于证书的 Kubernetes 集成（已废弃）

> [!warning]
> 在极狐GitLab 14.5 中，用于将 Kubernetes 集群连接到极狐GitLab 的基于证书的方法
> 已[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)，
> 其相关[功能](#deprecated-features)也已废弃。在极狐GitLab 私有化部署 17.0 及更高版本中，
> 此功能默认禁用。对于 JihuLab.com 用户，此功能在
> 极狐GitLab 15.9 之前对在其命名空间层级中至少启用了一个基于证书的集群的用户可用。
> 对于此前从未使用过此功能的 JihuLab.com 用户，该功能已不再可用。

与极狐GitLab 的基于证书的 Kubernetes 集成已废弃。
此集成存在以下问题：

- 存在安全问题，因为它需要极狐GitLab 直接访问 Kubernetes API。
- 配置选项不够灵活。
- 该集成不稳定。
- 用户不断报告基于此模型的功能存在问题。

因此，基于证书的集成被废弃，以专注于新模式
[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。
并行维护两种方法造成了大量困惑，并显著增加了使用、开发、维护和编写文档的复杂性。因此，两者均被废弃，转而采用新模式。基于证书的功能继续：

- 接收安全修复和关键修复。
- 与受支持的 Kubernetes 版本配合使用。

这些功能从极狐GitLab 中移除的时间尚未确定。

请关注此[史诗](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)以获取更新。

如果您需要更多时间迁移到极狐GitLab Kubernetes Agent，您可以
[启用功能标志](../../../administration/feature_flags/_index.md) `certificate_based_clusters`。有关更多信息，请参阅[废弃通知](../../../update/deprecations.md#gitlab-self-managed-certificate-based-integration-with-kubernetes)。此功能标志会重新启用基于证书的 Kubernetes 集成。

<a id="deprecated-features"></a>

## 已废弃的功能

- [通过集群证书连接现有集群](../../project/clusters/add_existing_cluster.md)
- [访问控制](../../project/clusters/cluster_access.md)
- [极狐GitLab 管理的集群](../../project/clusters/gitlab_managed_clusters.md)
- [通过基于证书的连接部署应用](../../project/clusters/deploy_to_cluster.md)
- [集群管理项目](../../clusters/management_project.md)
- [集群环境](../../clusters/environments.md)
- [在部署板上显示 Canary Ingress 部署](../../project/canary_deployments.md#show-canary-ingress-deployments-on-deploy-boards-deprecated)
- [部署板](../../project/deploy_boards.md)
- [Web 终端](../../../administration/integration/terminal.md)

<a id="cluster-levels"></a>

### 集群级别

[项目级](../../project/clusters/_index.md)、[群组级](../../group/clusters/_index.md)和[实例级](../../instance/clusters/_index.md)集群的概念在新模式中已不复存在，尽管相关功能在一定程度上仍然保留。

代理始终在单个极狐GitLab 项目中配置，您可以将集群连接公开给其他项目和群组，以便[从极狐GitLab CI/CD 访问它](../../clusters/agent/ci_cd_workflow.md)。这样做即表示您授予这些项目和群组访问同一集群的权限，这类似于群组级集群的用例。
