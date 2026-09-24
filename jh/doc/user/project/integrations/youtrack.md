---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: YouTrack
description: 配置 YouTrack 集成，将极狐GitLab 项目关联到 YouTrack 实例，并在极狐GitLab 中引用 YouTrack 议题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

JetBrains [YouTrack](https://www.jetbrains.com/youtrack/) 是一个基于 Web 的议题跟踪和项目管理平台。

您可以在极狐GitLab 中将 YouTrack 配置为
[外部议题跟踪器](../../../integration/external-issue-tracker.md)。

要在项目中启用 YouTrack 集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **YouTrack**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 填写必填字段：
   - **项目 URL**：YouTrack 中项目的 URL。
   - **议题 URL**：在 YouTrack 项目中查看议题的 URL。
     该 URL 必须包含 `:id`。极狐GitLab 会将 `:id` 替换为议题编号。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

配置并启用 YouTrack 后，极狐GitLab 项目页面上会出现一个链接。此链接将带您进入相应的 YouTrack 项目。

您也可以在此项目中关闭 [极狐GitLab 内置议题跟踪](../issues/_index.md)。
有关关闭极狐GitLab 议题的步骤和后果的更多信息，请参阅：

- [更改项目可见性](../../public_access.md#change-project-visibility)。
- [配置项目功能和权限](../settings/_index.md#configure-project-features-and-permissions)。

<a id="reference-youtrack-issues-in-gitlab"></a>

## 在极狐GitLab 中引用 YouTrack 议题

您可以使用 `<PROJECT>-<ID>` 引用 YouTrack 中的议题（例如 `YT-101`、`Api_32-143` 或 `gl-030`），其中：

- `<PROJECT>` 以字母开头，后跟字母、数字或下划线。
- `<ID>` 是一个数字。

合并请求、提交或评论中对 `<PROJECT>-<ID>` 的引用会自动链接到 YouTrack 议题 URL。
