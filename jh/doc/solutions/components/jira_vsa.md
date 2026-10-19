---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
title: Jira 到 极狐GitLab VSA 集成
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab [价值流分析 (VSA)](../../user/group/value_stream_analytics/_index.md) 为你的开发工作流提供强大的洞察力，追踪以下关键指标：

- **前置时间**：从议题创建到完成的时间
- **创建的议题**：在给定时间段内创建的新议题数量
- **已关闭的议题**：在给定时间段内已解决的议题数量

对于使用 Jira 进行议题跟踪，同时在极狐GitLab 上进行开发的团队，此集成可以实时将 Jira 议题自动复制到极狐GitLab。这样可以在不要求团队更改现有 Jira 工作流的情况下，获得准确的 VSA 指标。

该集成还会填充极狐GitLab **价值流仪表盘**（仅限旗舰版），该仪表盘提供关键 DevSecOps 指标的概览，你可以在极狐GitLab 项目或群组的 **分析** > **分析仪表盘** 下找到它。

> [!note]
> 同样存在一个用于事件复制的集成，用于生成特定的 DORA 指标（变更失败率和恢复服务时间）。如果你对事件复制感兴趣，请参考 [Jira 事件复制器](jira_dora.md)。

<a id="architecture"></a>

## 架构

我们将使用 Jira 自动化创建 2 个自动化工作流：

1. 当在 Jira 中创建议题时，在极狐GitLab 中创建议题
1. 当在 Jira 中解决议题时，关闭极狐GitLab 中的议题

<a id="issue-creation"></a>

### 议题创建

当在 Jira 中创建新议题时，自动化工作流会向极狐GitLab 议题 API 发送 POST 请求，在指定的极狐GitLab 项目中创建相应的议题。

<a id="issue-resolution"></a>

### 议题解决

当 Jira 议题转换为已解决状态（已关闭、完成、已解决）时，自动化工作流会发送 PUT 请求来关闭相应的极狐GitLab 议题。

<a id="setup"></a>

## 设置

<a id="pre-requisites"></a>

### 先决条件

本操作指南假设你具备以下条件：

- 你希望生成 VSA 分析的极狐GitLab 项目
- 你要从中复制议题的 Jira 项目
- 极狐GitLab 旗舰版或专业版许可证（用于价值流分析功能）

Jira 根据你的 Jira 许可证对自动化运行的频率施加了[限制](https://www.atlassian.com/software/jira/pricing)：

| **层次**   | **限制**                    |
|------------|------------------------------|
| 基础版       | 每月 100 次运行           |
| 标准版   | 每月 1700 次运行          |
| 专业版    | 每用户每月 1000 次运行 |
| 企业版 | 无限制运行               |

每个议题创建计为 1 次运行，每个议题解决计为 1 次运行。

<a id="gitlab-project-access-token"></a>

### 极狐GitLab 项目访问令牌

首先，我们需要创建一个极狐GitLab 项目访问令牌，并赋予相应的权限，以便通过 API 创建和更新议题。

1. 导航到你希望将 Jira 议题复制到的极狐GitLab 项目。从侧边栏中，转到 **设置** > **访问令牌**。
1. 点击 **添加新令牌**。
1. 设置以下配置：
   - **令牌名称**：`Jira VSA 集成`（或任何描述性名称）
   - **到期日期**：根据你的安全策略设置
   - **角色**：`所有者`（这是设置自定义议题 ID 所必需的）
   - **作用域**：勾选 `api`（完整的 API 访问）

**重要**：**所有者** 级别的访问令牌是必需的，因为该集成需要在极狐GitLab 中创建议题时强制设置自定义议题 ID。这确保了当 Jira 议题关闭时，自动化可以使用相同的 ID 映射识别并关闭相应的极狐GitLab 议题。如果没有所有者角色，极狐GitLab API 将不允许设置自定义议题 ID，从而破坏 Jira 议题关闭与极狐GitLab 议题关闭之间的同步。

1. 点击 **创建项目访问令牌** 并安全保存生成的令牌——稍后你在设置 Jira 自动化时会用到它。

<a id="jira-issue-creation-workflow"></a>

### Jira 议题创建工作流

为了在 Jira 议题创建时自动创建极狐GitLab 议题，我们将使用 [Jira 自动化](https://community.atlassian.com/t5/Jira-articles/Automation-for-Jira-Send-web-request-using-Jira-REST-API/ba-p/1443828)。

1. 导航到你的 Jira 项目。从侧边栏中，前往 **项目设置** > **自动化**。
1. 点击右上角的 **创建规则**。
1. 对于你的触发器，搜索并选择 **议题已创建**。点击 **保存**。
1. *可选*：添加条件以筛选应复制哪些议题。例如，你可能希望添加 **议题字段条件** 以仅复制特定类型或带有特定标签的议题。
1. 选择 **THEN：添加操作**。搜索并选择 **发送 Web 请求**。
1. 配置 Web 请求：
   - **Web 请求 URL**：`https://jihulab.com/api/v4/projects/<GITLAB_PROJECT_ID>/issues`（如果你使用私有化部署，请将 `jihulab.com` 替换为你的极狐GitLab 实例 URL，并将 `<GITLAB_PROJECT_ID>` 替换为你的极狐GitLab 项目的数字 ID，例如 `42718690`）
   - **HTTP 方法**：**POST**
   - **Web 请求正文**：**自定义数据**
1. 添加以下标头：

    | 名称 | 值 |
    | ------ | ------ |
    | Authorization | Bearer `<YOUR_GITLAB_TOKEN>` |
    | Content-Type | `application/json` |

   出于安全考虑，将 Authorization 标头设置为“隐藏”。
1. 在 **自定义数据** 字段中，输入：

   ```json
   {
     "title": "{{issue.summary}}",
     "iid": {{issue.key.replace("VSA-", "1000")}}
   }
   ```

   将 `"VSA-"` 替换为你的 Jira 项目前缀（例如，如果你的 Jira 议题编号为 `PROJ-123`，则使用 `"PROJ-"`）。`1000` 是一个基数，加上它之后可以确保与可能已通过 UI 在极狐GitLab 中直接创建的议题不冲突——你可以根据需要调整此值。
1. 点击 **保存**，为你的自动化命名一个描述性名称（例如 `Jira 到 极狐GitLab 议题创建`），然后点击 **开启**。

<a id="jira-issue-resolution-workflow"></a>

### Jira 议题解决工作流

创建第二个自动化工作流，以便在 Jira 议题解决时关闭极狐GitLab 议题：

1. 按照创建工作流的步骤 1-2 开始一个新规则。
1. 将触发器设置为 **议题已转换**：
   - 将“从状态”字段留空
   - 将“到状态”设置为已解决状态：`已关闭`、`完成`、`已解决`（根据你的 Jira 工作流进行调整）
1. 跳过条件（或根据需要添加自定义条件）。
1. 添加 **发送 Web 请求** 操作，并设置以下内容：
   - **Web 请求 URL**：`https://jihulab.com/api/v4/projects/<GITLAB_PROJECT_ID>/issues/{{issue.key.replace("<JIRA_PROJECT_PREFIX>-", "1000").urlEncode}}`（如果你使用私有化部署，请将 `jihulab.com` 替换为你的极狐GitLab 实例 URL，将 `<GITLAB_PROJECT_ID>` 替换为你的极狐GitLab 项目的数字 ID，并将 `<JIRA_PROJECT_PREFIX>` 替换为你的 Jira 项目前缀，例如 `VSA` 或 `PROJ`）
   - **HTTP 方法**：**PUT**
   - **Web 请求正文**：**自定义数据**
1. 使用与创建工作流相同的标头。
1. 在 **自定义数据** 字段中，输入：

   ```json
   {
     "state_event": "close"
   }
   ```

1. 保存并启用此自动化规则，并为其命名一个描述性名称（例如 `Jira 到 极狐GitLab 议题关闭器`）。

<a id="value-stream-analytics-configuration"></a>

## 价值流分析配置

一旦你的自动化工作流处于活跃状态，极狐GitLab 就会开始接收议题数据。以下说明如何访问你的分析：

<a id="value-streams-dashboard-automatic---ultimate-only"></a>

### 价值流仪表盘（自动 - 仅限旗舰版）

**价值流仪表盘** 会自动填充你复制议题中的指标，并且仅适用于极狐GitLab 旗舰版：

1. 在你的极狐GitLab 项目或群组中，导航到 **分析** > **分析仪表盘**
1. 点击 **价值流仪表盘**
1. 你将看到包括创建的议题、已关闭的议题、前置时间和周期时间在内的指标

<a id="value-stream-analytics-requires-setup---premium-and-ultimate"></a>

### 价值流分析（需要设置 - 专业版和旗舰版）

要获得更详细的分析和自定义价值流（适用于极狐GitLab 专业版和旗舰版）：

1. 在你的极狐GitLab 项目或群组中，导航到 **分析** > **价值流分析**
1. 点击 **新建价值流** 以创建自定义价值流
1. 根据你的开发流程配置阶段和工作流
1. 诸如前置时间和新议题数量之类的指标将自动生成，并显示在你创建的阶段旁边
1. 有关详细的设置说明，请参考 [极狐GitLab 价值流分析文档](../../user/group/value_stream_analytics/_index.md#create-a-value-stream)

<a id="multi-project-considerations"></a>

## 多项目注意事项

如果你想使用一组自动化规则从多个 Jira 项目复制议题，请考虑使用基于时间戳的方法来生成唯一的议题 ID，而不是使用项目前缀方法：

将自定义数据中的 `iid` 值替换为：

```json
"iid": {{issue.created.replace("-","").replace("T","").replace(":","").replace(".","").replace("+","")}}
```

此方法将创建时间戳（格式：`2025-02-15T09:45:32.7+0000`）转换为数值。请注意，此方法可能会导致议题 ID 非常长，并且如果同时创建两个议题，则存在很小的冲突风险。

<a id="resources"></a>

## 资源

- [极狐GitLab 价值流分析](../../user/group/value_stream_analytics/_index.md)
  - [创建价值流](../../user/group/value_stream_analytics/_index.md#create-a-value-stream)
- [极狐GitLab 价值流仪表盘](../../user/analytics/value_streams_dashboard.md)
- [极狐GitLab 议题 API](../../api/issues.md)
  - [创建新议题](../../api/issues.md#create-an-issue)
  - [编辑议题](../../api/issues.md#update-an-issue)
- [极狐GitLab 项目访问令牌](../../user/project/settings/project_access_tokens.md)
- [使用 Web 请求的 Jira 自动化](https://community.atlassian.com/t5/Jira-articles/Automation-for-Jira-Send-web-request-using-Jira-REST-API/ba-p/1443828)

