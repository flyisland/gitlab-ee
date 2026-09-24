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

要连接集群到极狐GitLab，使用 [极狐GitLab Kubernetes 代理](../../clusters/agent/_index.md)。

<a id="certificate-based-kubernetes-integration-deprecated"></a>

## 基于证书的 Kubernetes 集成（已弃用）

> [!warning]
> 在 极狐GitLab 14.5 中，基于证书的连接 Kubernetes 集群到极狐GitLab 的方法已被[弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)，其相关[功能](#已弃用的功能)也被弃用。在私有化部署极狐GitLab 17.0 及更高版本中，该功能默认禁用。对于 JihuLab.com 用户，该功能在 JihuLab.com 15.9 之前仍然可用，前提是用户在其命名空间层级中至少启用了基于证书的集群。对于之前从未使用过此功能的 JihuLab.com 用户，已不再可用。

基于证书的 Kubernetes 与极狐GitLab 集成已被弃用。该集成存在以下问题：

- 存在安全问题，因为它需要极狐GitLab 直接访问 Kubernetes API。
- 配置选项不够灵活。
- 集成不稳定。
- 用户不断报告基于此模型的功能问题。

因此，基于证书的集成被弃用，转而专注于新模型 [极狐GitLab Kubernetes 代理](../../clusters/agent/_index.md)。并行维护两种方法造成了很多困惑，并显著增加了使用、开发、维护和撰写文档的复杂性。因此，两者均被弃用，以支持新模型。基于证书的功能将继续：

- 接收安全和关键修复。
- 与受支持的 Kubernetes 版本兼容。

这些功能从极狐GitLab 中移除的时间尚未确定。关注此[史诗](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)以获取更新。

如果您需要更多时间迁移至极狐GitLab Kubernetes 代理，可以[启用名为 `certificate_based_clusters` 的功能标志](../../../administration/feature_flags/_index.md)，该标志[在极狐GitLab 15.0 中引入](../../../update/deprecations.md#gitlab-self-managed-certificate-based-integration-with-kubernetes)。此功能标志会重新启用基于证书的 Kubernetes 集成。

<a id="deprecated-features"></a>

## 已弃用的功能

- [通过集群证书连接现有集群](../../project/clusters/add_existing_cluster.md)
- [访问控制](../../project/clusters/cluster_access.md)
- [极狐GitLab 管理的集群](../../project/clusters/gitlab_managed_clusters.md)
- [通过基于证书的连接部署应用程序](../../project/clusters/deploy_to_cluster.md)
- [集群管理项目](../../clusters/management_project.md)
- [集群环境](../../clusters/environments.md)
- [在部署板上显示 Canary Ingress 部署](../../project/canary_deployments.md#show-canary-ingress-deployments-on-deploy-boards-deprecated)
- [部署板](../../project/deploy_boards.md)
- [Web 终端](../../../administration/integration/terminal.md)

<a id="cluster-levels"></a>

### 集群级别

[项目级别](../../project/clusters/_index.md)、[群组级别](../../group/clusters/_index.md) 和 [实例级别](../../instance/clusters/_index.md) 集群的概念在新模型中已不复存在，尽管功能在一定程度上得以保留。

代理始终在单个极狐GitLab 项目中配置，您可以将集群连接公开给其他项目和群组，以便[从极狐GitLab CI/CD 访问它](../../clusters/agent/ci_cd_workflow.md)。这样做，您便授予这些项目和群组对同一集群的访问权限，这类似于群组级别集群的用例。