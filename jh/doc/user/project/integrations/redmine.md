---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Redmine
description: 配置 Redmine 集成，将极狐GitLab 项目链接到 Redmine 议题跟踪器，并在极狐GitLab 中引用 Redmine 议题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 您必须在项目中[关闭极狐GitLab 内部议题跟踪](../../../integration/external-issue-tracker.md#disable-the-gitlab-issue-tracker)功能。
  有关关闭极狐GitLab 议题的步骤和后果的更多信息，请参阅[更改项目可见性](../../public_access.md#change-project-visibility)和
  [配置项目功能和权限](../settings/_index.md#configure-project-features-and-permissions)。

您可以使用 [Redmine](https://www.redmine.org/) 作为
[外部议题跟踪器](../../../integration/external-issue-tracker.md)。
要在项目中开启 Redmine 集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Redmine**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 填写必填字段：

   - **项目 URL**：要链接到此极狐GitLab 项目的 Redmine 项目的 URL。
   - **议题 URL**：要链接到此极狐GitLab 项目的 Redmine 项目议题的 URL。
     URL 必须包含 `:id`。极狐GitLab 会用议题编号替换此 ID。
   - **新建议题 URL**：用于在链接到此极狐GitLab 项目的 Redmine 项目中创建新议题的 URL。

     <!-- The note below was originally added in January 2018: <https://gitlab.com/gitlab-org/gitlab/-/commit/778b231f3a5dd42ebe195d4719a26bf675093350> -->

     > [!note]
     > 此 URL 未被使用，并计划在未来的版本中移除。
     > 有关更多信息，请参阅[议题 327503](https://gitlab.com/gitlab-org/gitlab/-/issues/327503)。

1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

配置并开启 Redmine 后，极狐GitLab 项目页面上会出现一个链接。
该链接将引导您进入您的 Redmine 项目。

例如，以下是一个名为 `gitlab-ci` 的项目的配置：

- 项目 URL：`https://redmine.example.com/projects/gitlab-ci`
- 议题 URL：`https://redmine.example.com/issues/:id`
- 新建议题 URL：`https://redmine.example.com/projects/gitlab-ci/issues/new`

<a id="reference-redmine-issues-in-gitlab"></a>

## 在极狐GitLab 中引用 Redmine 议题

您可以使用以下方式引用您的 Redmine 议题：

- `#<ID>`，其中 `<ID>` 是数字（例如 `#143`）。
- `<PROJECT>-<ID>`，例如 `API_32-143`，其中：
  - `<PROJECT>` 以大写字母开头，后跟大写字母、数字或下划线。
  - `<ID>` 是数字。

在链接中，`<PROJECT>` 部分会被忽略，它们始终指向 **议题 URL** 中指定的地址。

如果您同时开启了内部和外部议题跟踪器，请使用较长的格式（`<PROJECT>-<ID>`）。如果您使用较短的格式，且内部议题跟踪器中存在相同 ID 的议题，则会链接到内部议题。
