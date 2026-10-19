---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Bugzilla
description: 配置 Bugzilla 集成，将极狐GitLab 项目链接到 Bugzilla 议题跟踪器，并在极狐GitLab 中引用 Bugzilla 议题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Bugzilla](https://www.bugzilla.org/) 是一个基于 Web 的通用缺陷跟踪系统和测试工具。

您可以将 Bugzilla 配置为极狐GitLab 中的
[外部议题跟踪器](../../../integration/external-issue-tracker.md)。

要在项目中启用 Bugzilla 集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Bugzilla**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 填写必填字段：

   - **项目 URL**：Bugzilla 中项目的 URL。
     例如，对于名为 “Fire Tanuki” 的产品：
     `https://bugzilla.example.org/describecomponents.cgi?product=Fire+Tanuki`。
   - **议题 URL**：在 Bugzilla 项目中查看议题的 URL。
     该 URL 必须包含 `:id`。极狐GitLab 会将 `:id` 替换为议题编号（例如，
     `https://bugzilla.example.org/show_bug.cgi?id=:id`，它会变成
     `https://bugzilla.example.org/show_bug.cgi?id=123`）。
   - **新议题 URL**：在链接的 Bugzilla 项目中创建新议题的 URL。
     例如，对于名为 “My Cool App” 的项目：
     `https://bugzilla.example.org/enter_bug.cgi#h=dupes%7CMy+Cool+App`。

1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

配置并启用 Bugzilla 后，极狐GitLab 项目页面上会出现一个链接。此链接会将您带到相应的 Bugzilla 项目。

您也可以关闭此项目中的 [极狐GitLab 内部议题跟踪](../issues/_index.md)。
有关关闭极狐GitLab 议题的步骤和后果的更多信息，请参阅：

- [更改项目可见性](../../public_access.md#change-project-visibility)。
- [配置项目功能和权限](../settings/_index.md#configure-project-features-and-permissions)。

<a id="reference-bugzilla-issues-in-gitlab"></a>

## 在极狐GitLab 中引用 Bugzilla 议题

您可以使用以下方式引用 Bugzilla 中的议题：

- `#<ID>`，其中 `<ID>` 是数字（例如，`#143`）。
- `<PROJECT>-<ID>`（例如，`API_32-143`），其中：
  - `<PROJECT>` 以大写字母开头，后跟大写字母、数字或下划线。
  - `<ID>` 是数字。

链接中的 `<PROJECT>` 部分会被忽略，链接始终指向 **议题 URL** 中指定的地址。

如果您同时启用了内部和外部议题跟踪器，请使用较长的格式（`<PROJECT>-<ID>`）。如果您使用较短的格式，并且内部议题跟踪器中存在具有相同 ID 的议题，则会链接到内部议题。

<a id="troubleshooting"></a>

## 故障排除

要查看最近的集成 Webhook 投递情况，请检查集成 Webhook 日志。
