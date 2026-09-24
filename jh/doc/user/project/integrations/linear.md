---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linear
description: 配置 Linear 集成，将极狐GitLab 项目链接到 Linear 工作区，并在极狐GitLab 中引用 Linear 议题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 [Linear](https://linear.app/) 作为
[外部议题跟踪器](../../../integration/external-issue-tracker.md)。
要在项目中启用 Linear 集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Linear**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 填写必填字段：

   - **工作区 URL**：要链接到此极狐GitLab 项目的 Linear 工作区项目的 URL。

1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

配置并启用 Linear 后，极狐GitLab 项目页面上会出现一个链接。
该链接会将您引导至您的 Linear 工作区。

例如，以下是一个名为 `example` 的工作区的配置：

- 工作区 URL：`https://linear.app/example`

您也可以在此项目中关闭 [极狐GitLab 内部议题跟踪](../issues/_index.md)。
有关关闭极狐GitLab 议题的步骤和后果的更多信息，请参阅：

- [更改项目可见性](../../public_access.md#change-project-visibility)。
- [配置项目功能和权限](../settings/_index.md#configure-project-features-and-permissions)。

<a id="reference-linear-issues-in-gitlab"></a>

## 在极狐GitLab 中引用 Linear 议题

您可以使用以下方式引用您的 Linear 议题：

- `<TEAM>-<ID>`，例如 `API-123`，其中：
  - `<TEAM>` 是团队标识符。
  - `<ID>` 是数字。
