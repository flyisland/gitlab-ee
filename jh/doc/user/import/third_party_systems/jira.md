---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>.
title: 从 Jira 迁移
description: 从 Jira 迁移的选项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您使用 Jira，您可以选择：

- 在极狐GitLab 中全新开始，而不从 Jira 迁移。然后，您可以专注于设置流程和工作流，以充分利用极狐GitLab 的优势。
- 使用以下几种选项之一，从 Jira 迁移到极狐GitLab。

| 迁移选项             | 描述 |
|:-----------------------------|:------------|
| GitLab 专业服务 | 让 [GitLab 专业服务](https://about.gitlab.com/services/) 为您执行迁移。 |
| `Jira2Lab`                   | 使用 [`Jira2Lab`](https://about.gitlab.com/blog/seamlessly-migrate-from-jira-to-gitlab-with-jira2lab-at-scale/)，这是 GitLab 专业服务从 `jira2gitlab` 派生的项目。 |
| 第三方脚本           | 例如，使用 [`jira2gitlab`](https://github.com/swingbit/jira2gitlab) 进行迁移。 |
| Jira 导入器                | [使用 Jira 导入器](#use-the-jira-importer)，该导入器内置于极狐GitLab。 |
| CSV 文件导入              | [使用 CSV 文件](#use-a-csv-file) 将数据从 Jira 移动到极狐GitLab。 |
| 您自己的脚本              | [编写您自己的脚本](#write-your-own-script)，使用极狐GitLab REST 或 GraphQL API。 |
| 第三方服务          | 使用保持极狐GitLab 和 Jira 同步的第三方服务，例如 [Unito](https://marketplace.atlassian.com/apps/1218054/gitlab-2-way-integration-for-jira) 和 [Getint](https://marketplace.atlassian.com/apps/1223999/gitlab-integration-for-jira-two-way-sync-forge) 提供的服务。 |

<a id="use-the-jira-importer"></a>

## 使用 Jira 导入器

使用 Jira 导入器，您可以将 Jira 议题导入到极狐GitLab。可以将来自多个 Jira 项目的议题导入到一个极狐GitLab 项目中。极狐GitLab 直接导入议题的标题、描述和标记。您还可以在准备导入时将 Jira 用户映射到极狐GitLab 项目成员。

未正式映射到极狐GitLab 议题字段的其他 Jira 议题元数据会作为纯文本导入到极狐GitLab 议题的描述中。

Jira 议题中的文本不会被解析为极狐GitLab 风格 Markdown，这可能导致文本格式损坏。
有关更多信息，请参阅 [议题 379104](https://gitlab.com/gitlab-org/gitlab/-/issues/379104)。

[史诗 2738](https://gitlab.com/groups/gitlab-org/-/epics/2738) 提议为极狐GitLab Jira 导入器增加议题指派人、评论和其他改进。

<a id="prerequisites"></a>

### 先决条件

- 对 Jira 议题具有读取权限，并且对要导入到的极狐GitLab 项目具有维护者或所有者角色。
- 配置极狐GitLab [Jira 议题集成](../../../integration/jira/_index.md)。

<a id="import-jira-issues"></a>

### 导入 Jira 议题

导入 Jira 议题作为异步后台作业执行，可能会因以下原因导致延迟：

- 导入队列负载。
- 系统负载。
- 其他因素。

导入大型项目可能需要几分钟，具体取决于导入的大小。

要将 Jira 议题导入到极狐GitLab 项目：

1. 在 {{< icon name="work-items" >}} **工作项** 页面上，选择 **操作** ({{< icon name="ellipsis_v" >}}) > **从 Jira 导入**。
1. 选择 **导入自** 下拉列表，然后选择您希望从中导入议题的 Jira 项目。

   在 **Jira-极狐GitLab 用户映射模板** 部分，表格显示您的 Jira 用户映射到哪些极狐GitLab 用户。
   当表单出现时，下拉列表默认选择执行导入的用户。

1. 要更改任何映射，请选择 **极狐GitLab 用户名** 列中的下拉列表，然后选择您想要映射到每个 Jira 用户的用户。

   下拉列表可能不会显示所有用户，因此请使用搜索栏在此极狐GitLab 项目中查找特定用户。

1. 选择 **继续**。系统会向您显示导入已开始的确认信息。

   在导入于后台运行时，您可以转到 **工作项** 页面查看列表中出现的新议题（类型为议题的工作项）。

1. 要检查导入状态，请再次转到 Jira 导入页面。

<a id="use-a-csv-file"></a>

## 使用 CSV 文件

要将 Jira 议题数据从 CSV 文件导入到您的极狐GitLab 项目：

1. 导出您的 Jira 数据：
   1. 登录您的 Jira 实例，然后转到要迁移的项目。
   1. 将项目数据导出为 CSV 文件。
   1. 编辑您的 CSV 文件，使其与 [极狐GitLab CSV 导入器所需的列名](../../project/issues/csv_import.md) 匹配。
      - 仅导入 `title`、`description`、`due_date` 和 `milestone`。
      - 您可以在描述字段中添加 [快速操作](../../project/quick_actions.md)，以在导入过程中自动设置其他议题元数据。
1. 创建新的极狐GitLab 群组和项目：
   1. 登录您的极狐GitLab 账户并 [创建群组](../../group/_index.md#create-a-group) 来托管您迁移的项目。
   1. 在新群组中，[创建新项目](../../project/_index.md#create-a-blank-project) 来保存迁移的 Jira 议题。
1. 将 Jira 数据导入极狐GitLab：
   1. 在您的新极狐GitLab 项目中，在左侧边栏中，选择 **计划** > **工作项**。
   1. 选择 **操作** ({{< icon name="ellipsis_v" >}}) > **从 Jira 导入**。
   1. 按照屏幕上的说明完成导入过程。
1. 验证迁移：
   1. 检查导入的议题，确保项目成功迁移到极狐GitLab。
   1. 在极狐GitLab 中测试您迁移的 Jira 项目的功能。
1. 调整您的工作流和设置：
   1. 自定义您的极狐GitLab [项目设置](../../project/settings/_index.md)，例如：
      - [描述模板](../../project/description_templates.md)。
      - [标记](../../project/labels.md)。
      - [里程碑](../../project/milestones/_index.md)。
   1. 让您的团队熟悉极狐GitLab 界面以及迁移引入的任何新工作流或流程。
1. 当您对迁移感到满意时，您可以停用您的 Jira 实例并完全过渡到极狐GitLab。

<a id="write-your-own-script"></a>

## 编写您自己的脚本

为了完全控制迁移过程，您可以编写自己的自定义脚本，以完全符合您需求的方式将 Jira 议题迁移到极狐GitLab。极狐GitLab 提供了 API 来帮助自动化您的迁移：

- [REST API](../../../api/rest/_index.md)
- [GraphQL API](../../../api/graphql/_index.md)

要开始使用，请熟悉以下极狐GitLab API 端点：

- [议题](../../../api/issues.md)
- [项目](../../../api/projects.md)
- [标记](../../../api/labels.md)
- [里程碑](../../../api/milestones.md)

编写脚本时，您需要将 Jira 议题字段映射到对应的极狐GitLab 等效字段。

| Jira 议题字段 | 可能的极狐GitLab 等效字段 |
|:----|:-------|
| 具有固定选项数的自定义字段 | 创建一组 [范围标记](../../project/labels.md#scoped-labels)，以字段名作为范围标记键，字段值作为范围标记集值。例如，`input name::value1`、`input name::value2`。 |
| 具有文本字符串或整数值的自定义字段 | 将自定义字段名称和值注入到议题描述中的某个部分。 |
| 状态 | 使用 [状态](../../work_items/status.md)。 |
| 优先级 | 创建 [范围标记](../../project/labels.md#scoped-labels)，以优先级作为范围标记键，优先级值作为范围标记集值。例如，`priority::1`。 |
| 故事点 | 将此值映射到极狐GitLab 议题的 **权重** 值。 |
| 冲刺 | 将此值映射到极狐GitLab 议题的 **迭代** 值。此值仅对尚未完成或计划在将来冲刺中处理的议题有意义。在导入数据之前，请在您项目的父群组中创建所需的 [迭代](../../group/iterations/_index.md#iteration-cadences)。 |

您可能还需要处理解析 Atlassian 文档格式并将其映射为极狐GitLab 风格 Markdown。
您可以通过多种不同的方式处理此问题。如需灵感，
[查看一个示例提交](https://gitlab.com/gitlab-org/gitlab/-/commit/4292a286d3f4ab26466f8e89125a4dbd194a9f3e)。
此提交为 Jira 导入器添加了一个将 Atlassian 文档格式解析为极狐GitLab 风格 Markdown 的方法。

如果您在本地运行极狐GitLab，您也可以在 Rails 控制台中手动将 Atlassian 文档格式转换为极狐GitLab 风格 Markdown。为此，请执行：

```ruby
text = <document in Atlassian Document Format>
project = <project that wiki is in> or nil
Banzai.render(text, pipeline: :adf_commonmark, project: project)
```
