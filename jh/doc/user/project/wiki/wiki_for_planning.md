---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Wiki 与您的规划工作流结合使用
description: 将极狐GitLab Wiki 与您的规划工作流结合使用。将文档与史诗、议题和看板关联起来。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Wiki 可与您的规划工具配合使用。它不是独立的工具。
您可以将 Wiki 页面链接到史诗、议题和看板。
借助由极狐GitLab 查询语言 (GLQL) 驱动的嵌入式视图，您的 Wiki 页面可以显示
议题和工作项的实时、自动更新视图，将文档转变为动态仪表板。
了解如何将 Wiki 与议题、史诗和看板连接起来，以创建文档与规划协同工作的顺畅工作流。

Wiki 通过以下方式为您的规划工具提供帮助：

- 丰富的文档空间：容纳无法放入议题描述中的复杂需求、设计决策和流程文档。
- 版本控制的知识：随时间跟踪规范和决策的变更。
- 实时数据视图：嵌入 GLQL 查询，直接在 Wiki 页面中显示实时的议题和工作项数据。
- 持久的上下文：在议题关闭后，保留决策背后的“原因”。
- 集中参考：为团队流程、标准和约定提供单一事实来源。
- 灵活的格式：支持表格、图表和长文内容，并完全支持 Markdown。
- 集成的访问控制：Wiki 使用极狐GitLab 中现有的角色和权限系统，因此团队成员会根据其项目角色自动获得适当的 Wiki 访问权限，无需单独的身份验证。

<a id="prerequisites"></a>

## 先决条件

要有效使用本指南，您应熟悉：

- [极狐GitLab Wiki](_index.md)
- [极狐GitLab 风格 Markdown](../../markdown.md)
- 创建和管理各种工作项，例如[议题](../issues/_index.md)和[史诗](../../group/epics/_index.md)

<a id="connect-wiki-pages-to-work-items"></a>

## 将 Wiki 页面连接到工作项

在 Wiki 文档和规划项之间创建链接，以构建互联的知识网络。

<a id="link-wiki-documentation-to-epics"></a>

### 将 Wiki 文档链接到史诗

史诗通常需要比史诗描述更长的详细规格说明。
将完整文档保存在 Wiki 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 使用您的详细需求创建一个 Wiki 页面（例如，使用 slug `product-requirements`）。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到您项目的群组。
1. 选择 **计划** > **工作项**。
1. 在筛选栏中，选择筛选条件 **类型**、运算符 **为** 和值 **史诗**。
1. 找到您想要的史诗，然后选择其标题。
1. 在史诗描述中，链接到 Wiki 页面：

   ```markdown
   ## Requirements

   See full specification: [[product-requirements]]

   Or with custom text: [[Full PRD|product-requirements]]

   Or use the full URL:
   [Full PRD](https://gitlab.example.com/group/project/-/wikis/product-requirements)
   ```

1. 在 Wiki 页面中，链接回史诗：

   ```markdown
   Related epic: &123
   ```

示例用例：

- 产品需求文档 (PRD)
- 技术设计规格说明
- 用户研究发现
- 竞品分析
- 成功指标和 KPI

<a id="reference-wiki-from-issues"></a>

### 从议题引用 Wiki

将议题链接到 Wiki 页面，以获取实现细节、标准和指南：

```markdown
## Implementation notes

Follow our [[API-design-standards]] when implementing this endpoint.

For local setup, see [[Development Setup Guide|development-environment-setup]].

Definition of Done: [[team-dod]]
```

示例用例：

- 编码标准和风格指南
- 开发环境设置
- 测试流程
- 部署手册
- 故障排查指南
- 入职文档

<a id="link-from-wiki-to-work-items"></a>

### 从 Wiki 链接到工作项

直接在 Wiki 页面中引用议题和史诗：

```markdown
## Current sprint goals

- Implement user authentication: #1234
- Fix performance regression: #1235
- Update API documentation: #1236

## Q3 roadmap

Major initiatives:
- Authentication overhaul: &10
- Performance improvements: &11
- API v2 release: &12
```

<a id="cross-project-wiki-references"></a>

### 跨项目 Wiki 引用

链接到其他项目中的 Wiki 页面：

```markdown
## Related documentation

See the backend team's API guide: [[backend/api:api-standards]]

Or use the alternative syntax: [wiki_page:backend/api:api-standards]

With custom text: [[Backend API Standards|backend/api:api-standards]]
```

<a id="create-dynamic-dashboards-with-embedded-views"></a>

## 使用嵌入式视图创建动态仪表板

使用[极狐GitLab 查询语言 (GLQL)](../../glql/_index.md) 将您的 Wiki 页面转变为实时仪表板。
嵌入式视图会在数据变更时自动更新，让您无需离开 Wiki 即可实时了解规划数据。

> [!note]
> 嵌入式视图存在性能方面的考量。大型查询可能会超时或受到速率限制。
> 如果遇到超时，请通过添加更多筛选条件或减少 `limit` 参数来缩小查询范围。

<a id="basic-embedded-view-syntax"></a>

### 基本嵌入式视图语法

要嵌入 GLQL 查询，请使用以 `glql` 作为语言标识符的代码块：

````yaml
```glql
display: table
title: Sprint 18.5 Dashboard
description: Current sprint work items
fields: title, assignee, state, health, labels, milestone, updated
limit: 20
sort: updated desc
query: project = "gitlab-org/gitlab" and milestone = "18.5" and opened = true
```
````

这将创建一个实时表格，显示当前里程碑中的所有未关闭议题，并在议题被创建、修改或关闭时自动更新。

<a id="planning-dashboard-examples"></a>

### 规划仪表板示例

直接在您的 Wiki 页面中创建全面的规划仪表板。

> [!note]
> 在本节的所有示例中，请将 `project = "group/project"` 替换为您的实际项目路径，
> 例如 `project = "gitlab-org/gitlab"` 或 `project = "my-team/my-project"`。

先决条件：

- 您必须具有查看所查询议题和工作项的权限。

冲刺概览仪表板：

````yaml
```glql
display: table
title: Sprint Overview
description: All work for the current sprint
fields: title, assignee, state, labels("priority::*") as "Priority", health, due
limit: 30
sort: due asc
query: project = "group/project" and milestone = "Current Sprint" and opened = true
```
````

关键缺陷跟踪器：

````yaml
```glql
display: table
title: Critical Bugs
description: High-priority bugs requiring immediate attention
fields: title, assignee, labels, created, updated
limit: 10
query: project = "group/project" and label = "bug" and label = "severity::1" and opened = true
```
````

团队工作量视图：

````yaml
```glql
display: list
title: Team Work In Progress
description: Active work items by team member
fields: title, assignee, milestone, due
limit: 15
sort: assignee asc
query: project = "group/project" and assignee in (alice, bob, charlie) and label = "workflow::in dev"
```
````

个人任务列表：

````yaml
```glql
display: orderedList
title: My Tasks
description: Tasks assigned to me, sorted by priority
fields: title, labels("priority::*") as "Priority", due
limit: 10
sort: due asc
query: type = Task and assignee = currentUser() and opened = true
```
````

嵌入式视图支持：

- 多种显示格式：`table`、`list` 或 `orderedList`
- 自定义字段：选择要显示的字段
- 排序：按任何字段的升序或降序排序
- 筛选：使用包含多个条件的复杂查询
- 分页：使用 **加载更多** 加载其他结果
- 动态函数：使用 `currentUser()` 实现个性化视图，使用 `today()` 实现基于日期的查询

<a id="planning-workflows-with-wiki"></a>

## 使用 Wiki 的规划工作流

<a id="sprint-planning-and-execution"></a>

### 冲刺规划与执行

在整个冲刺过程中创建互联的文档流：

<a id="pre-sprint-planning"></a>

#### 冲刺前规划

1. 需求收集：在 Wiki 中记录详细需求。
1. 创建史诗：创建引用 Wiki 规格说明的史诗。
1. 故事拆解：将议题链接到相关的 Wiki 文档。
1. 估算记录：在 Wiki 中记录估算理由。

<a id="during-sprint"></a>

#### 冲刺期间

- 每日站会：创建每日 Wiki 页面，并链接到受阻议题。
- 技术决策：记录设计决策，并链接到实现议题。
- 障碍：在 Wiki 中跟踪障碍，并引用相关议题。

<a id="post-sprint"></a>

#### 冲刺后

- 回顾会议：创建 Wiki 回顾页面，引用：
  - 已完成的议题
  - 速度指标
  - 行动项（作为新议题）
  - 经验教训

<a id="long-term-planning-documentation"></a>

### 长期规划文档

维护与您的路线图关联的战略文档：

<a id="roadmap-documentation-structure"></a>

#### 路线图文档结构

```plaintext
roadmap/
├── 2025-strategy
├── q1-okrs
├── q2-okrs
├── architecture-decisions/
│   ├── adr-001-microservices
│   ├── adr-002-authentication
└── technical-debt-registry
```

每个页面都链接到相关的史诗，并通过议题引用跟踪进度。

<a id="architecture-decision-records"></a>

#### 架构决策记录

记录具有可追溯性的技术决策。
您可以使用类似以下的模板：

```markdown
# ADR-001: Adopt microservices architecture

## Status

Accepted

## Context

[Detailed context...]

## Decision

[Decision details...]

## Consequences

[Impact analysis...]

## Implementation

- Infrastructure epic: &50
- Service extraction: #2001, #2002, #2003
- Monitoring setup: #2004
```

<a id="cross-functional-collaboration"></a>

### 跨职能协作

将 Wiki 用作跨职能团队的协作中心：

<a id="design-documentation"></a>

#### 设计文档

- 将设计规格说明链接到实现议题
- 维护包含使用示例的组件库
- 记录设计决策，并引用相关史诗

<a id="api-documentation"></a>

#### API 文档

- 生成链接到实现议题的 API 文档
- 维护包含里程碑引用的版本信息
- 包含链接到测试议题的示例代码

<a id="qa-test-plans"></a>

#### QA 测试计划

- 链接到史诗需求的测试策略
- 具有议题可追溯性的测试用例库
- 包含议题示例的缺陷模式文档

<a id="navigation-and-discovery-patterns"></a>

## 导航和发现模式

<a id="make-wiki-discoverable-from-issues-and-boards"></a>

### 使 Wiki 可从议题和看板中发现

<a id="issue-and-epic-templates"></a>

#### 议题和史诗模板

在您的模板中包含 Wiki 引用：

```markdown
## Prerequisites

- [ ] Review [[contribution-guidelines]]
- [ ] Check [[security-checklist]]
- [ ] Read relevant documentation in [[project-wiki-home]]

## Implementation

- [ ] Follow [[coding-standards]]
- [ ] Update [[api-documentation]] if needed
- [ ] Add tests per [[testing-guidelines]]
```

<a id="milestone-descriptions"></a>

#### 里程碑描述

链接到 Wiki 规划文档：

```markdown
## Milestone 18.5

Sprint dates: 2025-02-01 to 2025-02-14

- [[Sprint 18.5 Goals|sprint-18-5-goals]]
- [[Sprint 18.5 Capacity|sprint-18-5-capacity]]
- [[Known Issues|known-issues-and-workarounds]]
```

<a id="board-descriptions"></a>

#### 看板描述

引用 Wiki 工作流文档：

```markdown
This board follows our [[Kanban Workflow Guide|kanban-workflow-guide]].

For column definitions, see [[Board Column Definitions|board-column-definitions]].
```

<a id="surface-work-items-in-wiki"></a>

### 在 Wiki 中展示工作项

<a id="create-index-pages"></a>

#### 创建索引页面

构建收集相关议题的 Wiki 页面：

```markdown
# Open bugs dashboard

## Critical (P1)

- #1001 - Database connection timeout
- #1002 - Authentication bypass

## High (P2)

- #1003 - Performance degradation
- #1004 - UI rendering issue

## By component

### Authentication

- #1001, #1005, #1009

### API

- #1002, #1006, #1010
```

<a id="use-hierarchical-wiki-structure"></a>

#### 使用层级化 Wiki 结构

使用文件夹和相对链接组织 Wiki 页面：

```markdown
# Team handbook

## Processes

- [Sprint Planning](processes/sprint-planning) - How we plan sprints
- [Code Review](processes/code-review) - Review standards and SLAs
- [Incident Response](processes/incident-response) - On-call procedures

## Go up to parent page

[Back to Documentation](../documentation)
```

<a id="practical-examples"></a>

## 实际示例

<a id="example-1-feature-development-workflow"></a>

### 示例 1：功能开发工作流

使用 Wiki 集成的完整功能开发周期：

1. 产品经理：

   - 创建包含市场研究的 `feature-x-prd` Wiki 页面。
   - 创建史诗 &100，并附上链接：`[[Feature X PRD|feature-x-prd]]`。
   - 在 Wiki 中添加验收标准。

1. 工程负责人：

   - 创建 `feature-x-technical-design` Wiki 页面。
   - 将设计文档链接到史诗 &100。
   - 创建实现议题 #201-205，并附上 Wiki 引用。

1. 工程师：

   - 在合并请求描述中引用 Wiki 设计文档。
   - 使用决策变更更新 Wiki。
   - 将议题链接到 Wiki 故障排查指南。

1. QA 工程师：

   - 创建 `feature-x-test-plan` Wiki 页面。
   - 将测试议题 #301-305 链接到测试计划。
   - 在 Wiki 中记录测试结果，并引用相关议题。

1. 技术文档工程师：

   - 在 Wiki 中更新用户文档。
   - 创建文档议题 #401。
   - 将 Wiki 变更链接到功能史诗。

<a id="example-2-team-knowledge-base-with-live-dashboards"></a>

### 示例 2：带实时仪表板的团队知识库

使用嵌入式视图构建您的团队手册，以获取实时洞察：

````markdown
# Engineering team handbook

## Current sprint status

```glql
display: table
title: Sprint Progress
fields: title, assignee, state, labels("workflow::*") as "Status"
limit: 20
query: project = "team/project" and milestone = "Sprint 23" and opened = true
```

## Processes

- [[Sprint Planning Process|sprint-planning-process]] - How we plan sprints
- [[Code Review Guidelines|code-review-guidelines]] - Review standards and SLAs
- [[Incident Response|incident-response]] - On-call procedures

## Technical standards

- [[API Design Standards|API-design-standards]] - REST API conventions
- [[Database Schema Guide|database-schema-guide]] - Schema design rules
- [[Security Checklist|security-checklist]] - Security requirements

## Work management

- [Issue board](https://gitlab.example.com/group/project/-/boards/123)
- [Current milestone](https://gitlab.example.com/group/project/-/milestones/45)
- Label taxonomy: [[Label Definitions|label-definitions]]

## Onboarding

- [[New Developer Setup|new-developer-setup]] - Environment setup
- [[First Week Issues|first-week-issues]] - Good first issues: #101, #102, #103
- [[Team Contacts|team-contacts]] - Who to ask for what
````

<a id="quick-reference"></a>

## 快速参考

<a id="wiki-linking-syntax"></a>

### Wiki 链接语法

| 用途                          | 语法                                    | 示例 |
| -------------------------------- | ----------------------------------------- | ------- |
| 链接到 Wiki 页面（同一项目） | `[[page-slug]]`                           | `[[api-standards]]` |
| 使用自定义文本链接            | `[[Display Text\|page-slug]]`             | `[[our API guide\|api-standards]]` |
| 跨项目 Wiki 链接          | `[[group/project:page-slug]]`             | `[[backend/api:rest-guide]]` |
| 替代 Wiki 语法          | `[wiki_page:page-slug]`                   | `[wiki_page:home]` |
| 跨项目替代语法        | `[wiki_page:namespace/project:page-slug]` | `[wiki_page:backend/api:home]` |
| 层级链接（同级）   | `[Link text](page-slug)`                  | `[Related](related-page)` |
| 层级链接（父级）       | `[Link text](../parent-page)`             | `[Up](../main)` |
| 层级链接（子级）        | `[Link text](child-page)`                 | `[Details](details)` |
| 根链接                        | `[Link text](/page-from-root)`            | `[Home](/home)` |
| 完整 URL                         | 标准 Markdown                         | `[API Guide](https://gitlab.example.com/.../wikis/api-standards)` |

<!-- The `page-from-root` example is added as exception in `doc/.vale/gitlab_docs/InternalLinkFormat.yml` -->

<a id="referencing-work-items"></a>

### 引用工作项

| 项类型                 | 语法              | 示例 |
| ------------------------- | ------------------- | ------- |
| 议题（同一项目）      | `#123`              | `#123`  |
| 议题（不同项目） | `group/project#123` | `gitlab-org/gitlab#123` |
| 合并请求             | `!123`              | `!123`  |
| 史诗                      | `&123`              | `&123`  |
| 里程碑                 | `%"Milestone Name"` | `%"18.5"` |

<a id="creating-issues-from-wiki"></a>

### 从 Wiki 创建议题

使用 Wiki 中可转换为议题的任务列表：

```markdown
## Action items from retrospective

- [ ] Improve CI pipeline performance
- [ ] Update documentation
- [ ] Add monitoring for API endpoints
```

选中复选框，然后使用 **创建议题** 将任务转换为受跟踪的议题。

<a id="tips-for-effective-integration"></a>

## 有效集成的技巧

<a id="use-page-slugs-correctly"></a>

### 正确使用页面 slug

- Wiki 链接使用页面 slug（URL 友好版本）：`api-standards` 而不是 `API Standards`。
- 当页面不存在时，选择该链接即可创建它。
- 粘贴的 Wiki URL 会自动转换为可读文本（连字符变为空格）。

<a id="maintain-bidirectional-links"></a>

### 维护双向链接

- 从 Wiki 链接到议题时，同时更新议题以引用 Wiki 页面。
- 使用一致的命名约定，以便于发现。
- 考虑使用 Webhook 或 CI/CD 自动化链接创建。

<a id="organize-for-discovery"></a>

### 为便于发现而组织

- 创建一个索引所有规划文档的 Wiki 主页。
- 使用一致的页面命名：`sprint-2025-01`、`adr-001`、`feature-name`。
- 对于大型 Wiki，使用带文件夹的层级结构。
- 使用与您的标记分类法匹配的类别为 Wiki 页面添加标记。

<a id="keep-documentation-current"></a>

### 保持文档最新

- 在您的“完成定义”中包含文档更新。
- 在冲刺规划期间审阅 Wiki 页面。
- 将过时的页面归档到 `archive/` 文件夹。

<a id="use-templates"></a>

### 使用模板

为常见文档创建 Wiki 模板：

- 冲刺规划模板
- 回顾会议模板
- 功能规格说明模板
- 架构决策记录模板
