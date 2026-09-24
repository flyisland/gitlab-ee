---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 开发者流程
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 中作为 [测试版](../../../../policy/development_stages_support.md) 引入，[带有一个功能标志](../../../../administration/feature_flags/_index.md) 名为 `duo_workflow_in_ci`。默认禁用，但可以为实例或用户启用。
- 在极狐GitLab 18.6 中，从 `Issue to MR` 重命名为 `Developer Flow`，带有一个功能标志名为 `duo_developer_button`。默认禁用，但可以为实例或用户启用。功能标志 `duo_workflow` 也必须启用，但默认启用。
- 在极狐GitLab 18.8 中 GA。
- 功能标志 `duo_workflow_in_ci`、`duo_developer_button` 和 `duo_workflow` 在极狐GitLab 18.9 中移除。
- 在极狐GitLab 18.10 中，于 JihuLab.com 上基础版中可用，使用极狐GitLab Credits。
- 提及触发器在极狐GitLab 18.11 中引入。

{{< /history >}}

开发者流程可帮助您更高效地跨议题和合并请求工作。
您可以使用开发者流程来：

- 从议题创建草稿合并请求。
- 根据审查反馈迭代现有合并请求。
- 研究实施方案并将结果发布到讨论中。
- 将大型合并请求拆分为更小、更集中的合并请求。
- 解决合并冲突。

<a id="prerequisites"></a>

## 先决条件

要使用开发者流程，您必须：

- 在项目中拥有开发者、维护者或所有者角色。
- 满足 [其他先决条件](../../_index.md#prerequisites)。
- [确保极狐GitLab Duo 服务账号可以创建提交和分支](../../troubleshooting.md#session-is-stuck-in-created-state)。
- 确保顶层群组的 **允许内置任务流** 和 **开发者** 已 [开启](_index.md#turn-foundational-flows-on-or-off)。

<a id="set-up-your-project"></a>

## 设置您的项目

为了帮助开发者流程产生更好的结果，您应该为项目配置以下可选设置：

- 添加 `AGENTS.md` 文件：记录您的项目约定，例如测试命令、
  代码检查规则、提交格式和编码模式。开发者流程在您的仓库中工作时会使用此文件
  作为上下文。
  更多信息，请参见 [AGENTS.md 自定义文件](../../customize/agents_md.md)。
- 配置执行环境：如果您的项目需要特定的工具链
  （例如 Go、Python 或 Node.js），请使用 `agent-config.yml` 文件配置代理环境。
  有了正确配置的环境，开发者流程可以在提交前运行测试并验证
  自己的更改。
  更多信息，请参见 [配置流程执行](../execution.md)。

<a id="use-the-flow"></a>

## 使用流程

先决条件：

- 事件类型 **提及** 和 **指派** 已在开发者流程的触发器中 [配置](../../triggers/_index.md)。

<a id="mention-duo-developer-in-a-discussion"></a>

### 在讨论中提及 Duo Developer

要将您的评论转化为开发者流程的可操作任务，请在讨论中使用 `@duo-developer-<namespace>` 提及它。将 `<namespace>` 替换为您的极狐GitLab 命名空间路径（例如 `gitlab-org`）。

根据议题或合并请求的内容以及您提供的上下文量，流程可以执行以下任务：

- 代码更改
- 创建合并请求和议题
- 研究实施方案并报告或相应更新

例如：

```plaintext
@duo-developer-<namespace> 研究为 /users 端点实现分页的方法，
然后使用最有前景的方法创建一个草稿合并请求。
```

开发者流程会回复一个指向其会话的链接。

或者，要监控进度，在左侧边栏选择 **AI** > **会话**。

<a id="generate-a-merge-request-from-an-issue"></a>

### 从议题生成合并请求

要从议题创建合并请求：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **计划** > **工作项**，然后按 **类型** = **议题** 过滤。
1. 选择您要为其创建合并请求的议题。
1. 要从议题创建合并请求，可以：
   - 将 Duo Developer 服务账号分配给该议题：
     1. 在右侧边栏的 **指派人** 部分，选择 **编辑**。
     1. 输入 `duo developer` 并从搜索结果中选择它。
   - 在议题标题下方，选择 **使用极狐GitLab Duo 生成合并请求**。
1. 可选。要监控流程的进度，在左侧边栏选择 **AI** > **会话**。
1. 会话完成后，从议题的 **动态** 部分中的链接审查合并请求。

<a id="best-practices"></a>

## 最佳实践

<a id="provide-clear-context"></a>

### 提供清晰的上下文

开发者流程只知道您告诉它的内容或议题、合并请求或讨论线程上下文中可用的内容。
适用于人类协作者的相同实践也适用于此：

- 编写清晰的问题描述，并附上相关文件或讨论的链接。
- 包含定义“完成”标准的验收标准。
- 如果您知道确切的文件路径，请指定它们。
- 包含现有模式的代码示例以保持一致性。

<a id="be-explicit-when-mentioning-duo-developer-in-discussions"></a>

### 在讨论中提及时要明确

当您在讨论中提及 Duo Developer 时，请明确告诉它您希望它做什么。例如：

- "创建一个草稿合并请求，为 `/api/users` 端点实现分页。"
- "处理此合并请求的审查反馈。"
- "将日志更改拆分为一个单独的合并请求。"
- "研究将此服务迁移到 gRPC 的方法，并在此处发布您的发现。"
- "此合并请求存在合并冲突。请解决它们。"

如果没有明确的指示，流程会选择自己的方法，这可能与您的预期不符。

<a id="keep-tasks-focused"></a>

### 保持任务聚焦

将复杂的任务分解为更小、更集中且面向行动的请求。
大型、开放式的任务更有可能达到迭代限制。

<a id="examples"></a>

## 示例

<a id="issue-for-generating-a-merge-request"></a>

### 用于生成合并请求的议题

此示例展示了一个精心编写的议题，开发者流程可以使用它来生成合并请求。

```plaintext
## 描述
用户端点目前一次性返回所有用户，
随着用户基数的增长，这将导致性能问题。
为 `/api/users` 端点实现基于游标的分页，
以高效处理大型数据集。

## 实施计划
为 GET /users API 端点添加分页。
在 /users API 响应中包含分页元数据（per_page、page）。
添加每页大小限制的查询参数（默认 5，最大 20）。

#### 要修改的文件
- `src/api/users.py` - 添加分页参数和逻辑。
- `src/models/user.py` - 添加分页查询方法。
- `tests/api/test_users_api.py` - 添加分页测试。

## 验收标准
- 接受 page 和 per_page 查询参数（默认：page=5，per_page=10）。
- 将 per_page 限制为最多 20 个用户。
- 在 data 数组中保持用户对象的现有响应格式。
```

<a id="iterate-on-merge-request-review-feedback"></a>

### 根据合并请求审查反馈进行迭代

在审查合并请求后，您可以提及开发者流程来处理您的反馈。例如，在特定行的审查评论中：

```plaintext
@duo-developer-<namespace> 将此验证逻辑移至 `app/services/base_service.rb` 中的 `BaseService` 类，
而不是在此处重复。
```

您也可以提交完整的审查，然后提及开发者流程来处理所有打开的讨论串：

```plaintext
@duo-developer-<namespace> 请处理此合并请求的审查反馈。
```

<a id="split-a-merge-request"></a>

### 拆分合并请求

如果合并请求变得太大，您可以要求开发者流程将其部分内容提取到单独的合并请求中：

```plaintext
@duo-developer-<namespace> 此合并请求中的日志更改超出范围。
将它们拆分为一个单独的合并请求。
```

<a id="research-an-implementation-approach"></a>

### 研究实施方案

您可以要求开发者流程在做出任何更改之前调查问题并报告：

```plaintext
@duo-developer-<namespace> 研究 `PUT /api/users` 端点是否也需要
像我们为 `POST /api/users` 端点添加的速率限制。
在此处发布您的发现。
```