---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 考虑升级停机选项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级期间的停机选项取决于您的实例类型：

- 单节点实例：必须停机升级。用户会看到
  **部署进行中**消息或 `502` 错误。
- 多节点实例：可选择停机升级或零停机升级。

跨多个次要版本升级（例如从 14.6 升级到 14.9）时，必须将极狐GitLab 实例下线并停机升级。

<a id="upgrades-with-downtime"></a>

## 停机升级

开始之前，请查看您的[升级路径](upgrade_paths.md)对应的版本特定升级说明：

- [极狐GitLab 17 升级说明](versions/gitlab_17_changes.md)
- [极狐GitLab 16 升级说明](versions/gitlab_16_changes.md)
- [极狐GitLab 15 升级说明](versions/gitlab_15_changes.md)

对于单节点实例，请参阅[升级 Linux 软件包实例](package/_index.md)。对于多节点实例，请参阅[停机升级多节点实例](with_downtime.md)。

<a id="zero-downtime-upgrades"></a>

## 零停机升级

零停机升级让您无需将运行中的极狐GitLab 环境下线即可完成升级。

要实现零停机，请按特定顺序升级极狐GitLab 节点。使用负载均衡、高可用系统和优雅重载来尽可能减少中断。

本文档仅涵盖极狐GitLab 核心组件。对于 AWS RDS 等第三方服务的升级或管理，请参阅其文档。

要执行零停机升级，请参阅您的安装方式对应的文档：[Helm chart](https://gitlab.cn/docs/charts/installation/upgrade/)、[GitLab Operator](https://docs.gitlab.com/operator/gitlab_upgrades/) 或[多节点实例](zero_downtime.md)。
