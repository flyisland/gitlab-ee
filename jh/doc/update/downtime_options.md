---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 考虑升级停机时间选项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级期间的停机时间选项取决于您的实例类型：

- 单节点实例：您必须进行带停机时间的升级。用户会看到
  **部署进行中** 消息或 `502` 错误。
- 多节点实例：可以选择带停机时间或不带停机时间的升级。

要跨多个次要版本升级（例如从 14.6 到 14.9），您必须将极狐GitLab 实例离线并进行带停机时间的升级。

<a id="upgrades-with-downtime"></a>

## 带停机时间的升级

在开始之前，请查看您的 [升级路径](upgrade_paths.md) 的版本特定升级说明：

- [极狐GitLab 17 升级说明](versions/gitlab_17_changes.md)
- [极狐GitLab 16 升级说明](versions/gitlab_16_changes.md)
- [极狐GitLab 15 升级说明](versions/gitlab_15_changes.md)

对于单节点实例，请参阅 [升级 Linux 软件包实例](package/_index.md)。
对于多节点实例，请参阅 [使用停机时间升级多节点实例](with_downtime.md)。

<a id="zero-downtime-upgrades"></a>

## 零停机时间升级

零停机时间升级允许您在不使环境离线的情况下升级运行中的极狐GitLab 环境。

要实现零停机时间，请按特定顺序升级极狐GitLab 节点。使用负载均衡、HA 系统和优雅重载以最大程度地减少中断。

该文档仅涵盖核心极狐GitLab 组件。对于 AWS RDS 等第三方服务的升级或管理，请参阅其文档。

要执行零停机时间升级，请参阅您的安装方法的文档：[Helm charts](https://gitlab.cn/docs/charts/installation/upgrade.html)、[GitLab Operator](https://gitlab.cn/docs/operator/gitlab_upgrades/) 或 [多节点实例](zero_downtime.md)。