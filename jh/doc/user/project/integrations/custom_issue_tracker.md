---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义议题跟踪器
description: 配置自定义议题跟踪器集成，将极狐GitLab 项目链接到没有内置集成的议题跟踪器。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将[外部议题跟踪器](../../../integration/external-issue-tracker.md)与极狐GitLab 集成。如果您偏好的议题跟踪器未列在[集成列表](../../../integration/external-issue-tracker.md#configure-an-external-issue-tracker)中，您可以启用自定义议题跟踪器。

启用自定义议题跟踪器后，项目左侧边栏中会显示指向该议题跟踪器的链接。

![项目左侧边栏中的自定义议题跟踪器链接。](img/custom_issue_tracker_v18_3.png)

<a id="enable-a-custom-issue-tracker"></a>

## 启用自定义议题跟踪器

要在项目中启用自定义议题跟踪器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **自定义议题跟踪器**。
1. 在 **启用集成** 下，选中 **活跃** 复选框。
1. 填写必填字段：

   - **项目 URL**：用于查看自定义议题跟踪器中所有议题的 URL。
   - **议题 URL**：用于查看自定义议题跟踪器中某个议题的 URL。该 URL 必须包含 `:id`。极狐GitLab 会将 `:id` 替换为议题编号（例如，`https://customissuetracker.com/project-name/:id` 会变为 `https://customissuetracker.com/project-name/123`）。
   - **新议题 URL**：
     <!-- The line below was originally added in January 2018: <https://gitlab.com/gitlab-org/gitlab/-/commit/778b231f3a5dd42ebe195d4719a26bf675093350> -->
     **此 URL 未被使用，且存在一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/327503)要求移除该字段**。请输入任意 URL。

1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

<a id="reference-issues-in-a-custom-issue-tracker"></a>

## 在自定义议题跟踪器中引用议题

您可以使用以下格式在自定义议题跟踪器中引用议题：

- `#<ID>`，其中 `<ID>` 是数字（例如，`#143`）。
- `<PROJECT>-<ID>`（例如，`API_32-143`），其中：
  - `<PROJECT>` 以大写字母开头，后跟大写字母、数字或下划线。
  - `<ID>` 是数字。

链接中的 `<PROJECT>` 部分会被忽略，链接始终指向 **议题 URL** 中指定的地址。

如果您同时启用了内部和外部议题跟踪器，请使用较长的格式（`<PROJECT>-<ID>`）。如果您使用较短的格式，且内部议题跟踪器中存在相同 ID 的议题，则会链接到内部议题。
