---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 配置实例允许的单次推送事件数量限制。
title: 推送事件活动限制与批量推送事件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为保持良好的系统性能并防止活动流中出现垃圾信息，请设置**推送事件活动限制**。默认情况下，极狐GitLab 将此限制设为 `3`。当您推送的更改涉及超过 3 个分支和标签时，极狐GitLab 会创建一个批量推送事件，而不是多个单独的推送事件。

例如，如果您同时推送到四个分支，活动流会显示一条
{{< icon name="commit" >}} `Pushed to 4 branches at (project name)` 事件，而不是四条单独的
推送事件。

批量推送事件的行为与标准推送事件不同：

- 活动流：显示一条批量推送记录，而不是多个单独的推送事件。
- 事件 API：返回的批量推送事件带有 `commit_count: 0` 和 `ref_count`，后者表示
  推送的引用数量。单个提交详情（`commit_from`、`commit_to`、`ref`、
  `commit_title`）均为 `null`。

如果您的集成或外部系统必须逐个处理每个推送的引用：

- 将每次推送的引用数量保持在 `push_event_activities_limit` 以下。
- 将大型推送拆分为多个较小的推送。

> [!note]
> Webhook 触发由 `push_event_hooks_limit` 设置单独控制。
> 更多信息，请参见[推送事件限制](../../user/project/integrations/webhooks.md#push-event-limits)。

先决条件：

- 管理员访问权限。

要设置不同的**推送事件活动限制**，您可以：

- 在[应用设置 API](../../api/settings.md#available-settings)中，设置
  `push_event_activities_limit`。

- 在极狐GitLab UI 中：
  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**设置** > **网络**。
  1. 展开**性能优化**。
  1. 编辑**推送事件活动限制**设置。
  1. 选择**保存更改**。

该值可以大于或等于 `0`。将此值设为 `0` 不会禁用限流。
