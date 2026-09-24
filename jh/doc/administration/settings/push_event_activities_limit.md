---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 配置实例所允许的单次推送事件数量限制。
title: 推送事件活动限制与批量推送事件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为了保持良好的系统性能并防止活动动态中出现垃圾信息，可以设置 **推送事件活动限制**。
默认情况下，极狐GitLab 将此限制设置为 `3`。当您推送的变更影响到超过 3 个分支和标签时，
极狐GitLab 会创建一个批量推送事件，而非单独的推送事件。

例如，如果您同时推送到四个分支，活动动态中会显示一条
{{< icon name="commit" >}} `推送至 4 个分支于 (项目名称)` 事件，而不是四条独立的
推送事件。

批量推送事件与标准推送事件的行为不同：

- 活动动态：显示一条批量推送条目，而非单独的推送事件。
- 事件 API：返回批量推送事件，其中 `commit_count: 0` 以及 `ref_count` 表示
  推送的引用数量。单个提交详情（`commit_from`、`commit_to`、`ref`、
  `commit_title`）均为 `null`。

如果您的集成或外部系统必须单独处理每一个推送的引用：

- 请将每次推送的引用数量保持在 `push_event_activities_limit` 以下。
- 或将大型推送拆分成多个较小的推送。

> [!note]
> Webhook 触发由 `push_event_hooks_limit` 设置单独控制。
> 更多信息，请参见 [推送事件限制](../../user/project/integrations/webhooks.md#push-event-limits)。

先决条件：

- 管理员访问权限。

要设置不同的 **推送事件活动限制**，可以通过以下两种方式之一：

- 在[应用设置 API](../../api/settings.md#可用设置) 中设置
  `push_event_activities_limit`。

- 在极狐GitLab UI 中：
  1. 在右上角，选择 **管理员**。
  1. 在左侧边栏中，选择 **设置** > **网络**。
  1. 展开 **性能优化**。
  1. 编辑 **推送事件活动限制** 设置。
  1. 选择 **保存更改**。

该值可以大于或等于 `0`。将此值设置为 `0` 并不会禁用节流。