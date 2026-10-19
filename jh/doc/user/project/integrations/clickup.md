---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: ClickUp
description: 配置 ClickUp 集成，将极狐GitLab 项目链接到 ClickUp，并在合并请求和提交中引用 ClickUp 议题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将 [ClickUp](https://clickup.com/) 用作
[外部议题跟踪器](../../../integration/external-issue-tracker.md)。
要在项目中启用 ClickUp 集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **ClickUp**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 填写必填字段：

   - **项目 URL**：要链接到此极狐GitLab 项目的 ClickUp 项目的 URL。
   - **议题 URL**：要链接到此极狐GitLab 项目的 ClickUp 项目议题的 URL。
     URL 必须包含 `:id`。极狐GitLab 会用议题编号替换此 ID。

1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

配置并启用 ClickUp 后，极狐GitLab 项目页面上会出现一个链接。
该链接会将您引导至您的 ClickUp 项目。

例如，以下是一个名为 `gitlab-ci` 的项目的配置：

- 项目 URL：`https://app.clickup.com/1234567`
- 议题 URL：`https://app.clickup.com/t/1234567/:id`

您也可以在此项目中关闭 [极狐GitLab 内部议题跟踪](../issues/_index.md)。
有关关闭极狐GitLab 议题的步骤和后果的更多信息，请参阅：

- [更改项目可见性](../../public_access.md#change-project-visibility)。
- [配置项目功能和权限](../settings/_index.md#configure-project-features-and-permissions)。

<a id="reference-clickup-issues-in-gitlab"></a>

## 在极狐GitLab 中引用 ClickUp 议题

您可以使用以下方式引用您的 ClickUp 议题：

- `#<ID>`，其中 `<ID>` 是字母数字字符串（示例 `#8wrtcd932`）。
- `CU-<ID>`，其中 `<ID>` 是字母数字字符串（示例 `CU-8wrtcd932`）。
- `<PROJECT>-<ID>`，例如 `API_32-143`，其中：
  - `<PROJECT>` 是 ClickUp 列表自定义前缀 ID。
  - `<ID>` 是数字。
- 如果您使用 [自定义任务 ID](https://help.clickup.com/hc/en-us/sections/17044579323671-Custom-Task-IDs)，完整的自定义任务 ID 也可以使用。例如 `SOP-1234`。

在链接中，`CU-` 部分会被忽略，并链接到议题的全局 URL。当在 ClickUp 列表中使用自定义前缀时，前缀部分是链接的一部分。

如果您同时启用了内部和外部议题跟踪器，请使用 `CU-` 格式（`CU-<ID>`）。如果您使用较短的格式，并且内部议题跟踪器中存在相同 ID 的议题，则会链接到内部议题。

对于 [自定义任务 ID](https://help.clickup.com/hc/en-us/sections/17044579323671-Custom-Task-IDs)，您必须包含完整的 ID，包括您的自定义前缀。例如，`SOP-1432`。
