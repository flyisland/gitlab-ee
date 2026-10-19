---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>.
title: Jira 迁移选项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你有多种选项可将 Jira 项目迁移到极狐GitLab。在决定迁移策略之前，首先确定是否真的需要将 Jira 议题迁移到极狐GitLab。在许多情况下，Jira 议题数据已不再相关或可操作。通过在极狐GitLab 中全新开始，你可以专注于设置流程和工作流，以最大化使用极狐GitLab 的优势。

如果你选择迁移 Jira 议题，可以从以下几个迁移选项中选择：

- 使用极狐GitLab Jira 导入器。
- 导入 CSV 文件。
- 让极狐GitLab 专业服务为你处理迁移。
- 使用第三方服务建立单向或双向数据同步流程。
- 使用第三方脚本。
- 编写你自己的脚本。

<a id="use-gitlab-jira-importer"></a>

## 使用极狐GitLab Jira 导入器

极狐GitLab 有一个内置工具用于导入 Jira 议题数据。要使用极狐GitLab Jira 导入器：

1. [在目标项目中配置极狐GitLab Jira 议题集成](../../../integration/jira/configure.md#configure-the-integration)
1. [将 Jira 项目议题导入到极狐GitLab](jira.md)

<a id="import-a-csv-file"></a>

## 导入 CSV 文件

要将 Jira 议题数据从 CSV 文件导入到极狐GitLab 项目：

1. 导出 Jira 数据：
   1. 登录 Jira 实例并进入要迁移的项目。
   1. 将项目数据导出为 CSV 文件。
   1. 编辑 CSV 文件以匹配[极狐GitLab CSV 导入器所需的列名](../issues/csv_import.md)。
      - 仅导入 `title`、`description`、`due_date` 和 `milestone`。
      - 你可以在描述字段中添加[快速操作](../quick_actions.md)，以在导入过程中自动设置其他议题元数据。
1. 创建新的极狐GitLab 群组和项目：
   1. 登录极狐GitLab 账户并[创建群组](../../group/_index.md#create-a-group)以托管迁移的项目。
   1. 在新群组中，[创建新项目](../_index.md#create-a-blank-project)以存放迁移的 Jira 议题。
1. 将 Jira 数据导入极狐GitLab：
   1. 在新的极狐GitLab 项目中，在左侧边栏中选择 **计划** > **工作项**。
   1. 选择 **操作** ({{< icon name="ellipsis_v" >}}) > **从 Jira 导入**。
   1. 按照屏幕上的说明完成导入过程。
1. 验证迁移：
   1. 检查导入的议题，确保项目已成功迁移到极狐GitLab。
   1. 在极狐GitLab 中测试迁移后的 Jira 项目功能。
1. 调整工作流和设置：
   1. 自定义极狐GitLab [项目设置](../settings/_index.md)，例如[描述模板](../description_templates.md)、[标签](../labels.md)和[里程碑](../milestones/_index.md)，以满足团队需求。
   1. 让团队熟悉极狐GitLab 界面以及迁移引入的任何新工作流或流程。
1. 停用 Jira 实例：
   1. 对迁移满意后，可以停用 Jira 实例并完全过渡到极狐GitLab。

<a id="let-gitlab-professional-services-handle-the-migration-for-you"></a>

## 让极狐GitLab 专业服务为你处理迁移

有关高级概述，请参阅 [Jira 迁移服务](https://drive.google.com/file/d/1p0rv02OnjfSiNoeDT2u4MhviozS--Yan/view) 数据表。

要获取个性化报价，请访问[极狐GitLab 专业服务](https://gitlab.cn/services/)页面并选择 **请求服务**。

<a id="establish-a-one-way-or-two-way-data-synchronization-using-a-third-party-service"></a>

## 使用第三方服务建立单向或双向数据同步

要在 Jira 和极狐GitLab 之间建立单向或双向数据同步，可以使用以下第三方服务：

- **Unito.io**：[极狐GitLab + Jira 集成文档](https://guide.unito.io/gitlab-jira-integration)，[极狐GitLab + Jira 双向同步 Marketplace 插件](https://marketplace.atlassian.com/apps/1218054/gitlab-jira-two-way-sync?tab=overview&hosting=cloud)
- **Getint**：[极狐GitLab Jira 同步 Marketplace 插件](https://marketplace.atlassian.com/apps/1223999/gitlab-jira-sync-integration-by-getint?tab=overview&hosting=cloud)

<a id="use-a-third-party-script"></a>

## 使用第三方脚本

你可以使用可用的开源迁移脚本之一来帮助将 Jira 议题迁移到极狐GitLab。

我们的许多客户已成功使用 [`jira2gitlab`](https://github.com/swingbit/jira2gitlab)。

<a id="use-a-first-party-script"></a>

## 使用自有脚本

[极狐GitLab 专业服务](https://gitlab.cn/services/) 构建了前述 `jira2gitlab` 脚本的分支 `Jira2Lab`：

- 博客文章：[使用 Jira2Lab 大规模无缝从 Jira 迁移到极狐GitLab](https://gitlab.cn/blog/seamlessly-migrate-from-jira-to-gitlab-with-jira2lab-at-scale/)
- [仓库](https://jihulab.com/gitlab-cn/professional-services-automation/tools/migration/jira2lab)

正如 `Jira2Lab` README 中所述：

> 我们鼓励用户比较这两种工具，以最好地满足其迁移需求。

<a id="write-your-own-script"></a>

## 编写你自己的脚本

要完全控制迁移过程，你可以编写自己的自定义脚本，以完全符合需求的方式将 Jira 议题迁移到极狐GitLab。极狐GitLab 提供 API 来帮助自动化迁移：

- [REST API](../../../api/rest/_index.md)
- [GraphQL API](../../../api/graphql/_index.md)

要开始使用，请熟悉以下极狐GitLab API 端点：

- [议题](../../../api/issues.md)
- [项目](../../../api/projects.md)
- [标签](../../../api/labels.md)
- [里程碑](../../../api/milestones.md)

编写脚本时，需要将 Jira 议题字段映射到相应的极狐GitLab 等效项。以下是一些提示：

- **具有固定数量选项的自定义字段**：创建[范围标签](../labels.md#scoped-labels)集，将字段名作为范围标签键，字段值作为范围标签集值（例如，`input name::value1`、`input name::value2`）。
- **具有文本字符串或整数值的自定义字段**：将自定义字段名称和值注入议题描述中的某个部分。
- **状态**：创建[范围标签](../labels.md#scoped-labels)，将状态设置为范围标签键，状态值作为范围标签集值（例如，`status::in progress`）。
- **优先级**：创建[范围标签](../labels.md#scoped-labels)，将优先级设置为范围标签键，优先级值作为范围标签集值（例如，`priority::1`）。
- **故事点**：将此值映射到极狐GitLab 议题的 **权重** 值。
- **冲刺**：将此值映射到极狐GitLab 议题的 **迭代** 值。此值仅对尚未完成或计划在未来冲刺中的议题有意义。在导入数据之前，请在项目的父群组中创建所需的[迭代](../../group/iterations/_index.md#iteration-cadences)。

你可能还需要处理解析 Atlassian 文档格式并将其映射到极狐GitLab 风格的 Markdown。你可以通过多种不同方式实现。如需灵感，
[查看一个示例提交](https://jihulab.com/gitlab-cn/gitlab/-/commit/4292a286d3f4ab26466f8e89125a4dbd194a9f3e)。
此提交为极狐GitLab Jira 导入器添加了一个方法，用于将 Atlassian 文档格式解析为极狐GitLab 风格的 Markdown。

如果你在本地运行极狐GitLab，还可以在 Rails 控制台中手动将 Atlassian 文档格式转换为极狐GitLab 风格的 Markdown。为此，请执行：

```ruby
text = <Atlassian 文档格式的文档>
project = <wiki 所在的项目> 或 nil
Banzai.render(text, pipeline: :adf_commonmark, project: project)
```