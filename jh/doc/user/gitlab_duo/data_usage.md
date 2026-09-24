---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: AI-native features and functionality.
title: 极狐GitLab Duo 数据使用
---

极狐GitLab Duo 使用生成式 AI 帮助您提高速度并提升生产力。每个 AI 原生功能独立运行，其他功能无需依赖它即可工作。

极狐GitLab 使用合适的大语言模型（LLM）来完成特定任务。
这些 LLM 是国内 SOTA 大模型。

<a id="progressive-enhancement"></a>

## 渐进增强

极狐GitLab Duo AI 原生功能被设计为对 DevSecOps 平台上现有极狐GitLab 功能的渐进增强。这些功能被设计为可优雅降级，不应妨碍底层功能的核心功能。您应注意，每个功能均受相关[功能支持政策](../../policy/development_stages_support.md)所定义的预期功能约束。

<a id="stability-and-performance"></a>

## 稳定性与性能

极狐GitLab Duo AI 原生功能处于各种[功能支持级别](../../policy/development_stages_support.md#beta)。由于这些功能的性质，使用需求可能很高，可能导致性能下降或功能意外停机。我们已构建这些功能以优雅降级，并设有控制措施以减轻滥用或误用。极狐GitLab 可随时自行决定为任何或所有客户禁用 Beta 和实验性功能。

<a id="data-privacy"></a>

## 数据隐私

极狐GitLab Duo AI 原生功能由生成式 AI 模型提供支持。任何个人数据的处理均遵循我们的[隐私声明](https://gitlab.cn/privacy/)。您还可以访问[子处理者页面](https://gitlab.cn/privacy/subprocessors/#third-party-sub-processors)查看我们用于提供这些功能的子处理者列表。

<a id="data-retention"></a>

## 数据保留

<a id="model-sub-processors"></a>

### 模型子处理者

以下反映了极狐GitLab AI 模型[子处理者](https://gitlab.cn/privacy/subprocessors/#third-party-sub-processors)当前的保留期限：

对于极狐GitLab Duo 请求，极狐GitLab 对模型子处理者实行零数据保留政策。

这些供应商在输出提供后立即丢弃模型输入和输出数据，并且不存储输入和输出数据用于滥用监控。该政策的例外情况是，当为代码建议和极狐GitLab Duo Agentic Chat 启用提示缓存时。

所有极狐GitLab AI 模型子处理者均被限制使用模型输入和输出训练模型，并与极狐GitLab 签订数据保护协议，禁止将客户内容用于自身目的，除非履行其独立法律义务。

<a id="gitlab"></a>

### 极狐GitLab

极狐GitLab Duo Chat 和极狐GitLab Duo Agent Platform 分别保留聊天历史和工作流历史，以帮助您快速返回之前讨论的主题。您可以在极狐GitLab Duo Chat 界面中删除聊天。在 JihuLab.com 上，聊天和工作流历史可能会出于反滥用目的而保留。

除非客户通过极狐GitLab [支持工单](https://about.gitlab.com/support/portal/) 提供同意，否则极狐GitLab 不会保留输入和输出数据。

当群组或实例为极狐GitLab Duo Agent Platform 工作流启用扩展日志记录时，将保留跟踪数据。这与 AI 模型子处理者的任何零数据保留政策是分开的。

更多信息，请参见 [AI 功能日志记录](../../administration/logs/_index.md)。

<a id="training-data"></a>

## 训练数据

极狐GitLab 不训练生成式 AI 模型。

<a id="telemetry"></a>

## 遥测

极狐GitLab Duo 通过 Snowplow 收集器收集聚合或去标识化的第一方使用数据。此使用数据包括以下指标：

- 唯一用户数
- 唯一实例数
- 提示和后缀长度
- 使用的模型
- 状态码响应
- API 响应时间
- 代码建议还会收集：
  - 建议所用的语言（例如 Python）
  - 正在使用的编辑器（例如 VS Code）
  - 显示、接受、拒绝或出错的建议数量
  - 建议显示的持续时间

<a id="gitlab-model-context-protocol-server"></a>

## 极狐GitLab 模型上下文协议服务器

以下信息适用于在极狐GitLab 私有化部署实例中使用 [极狐GitLab 模型上下文协议（MCP）服务器](model_context_protocol/mcp_server.md)。

使用极狐GitLab MCP 服务器时，极狐GitLab 不会传输、存储、保留或处理任何数据。所有通信直接在 MCP 客户端和您环境中的极狐GitLab MCP 服务器之间进行。

仓库数据和元数据不会发送到极狐GitLab。

您可以控制哪些 MCP 客户端连接到您的实例。每个客户端自身的隐私和数据保留政策适用。

<a id="model-accuracy-and-quality"></a>

## 模型准确性与质量

生成式 AI 可能会产生意外结果，这些结果可能：

- 质量低下
- 不连贯
- 不完整
- 产生失败的流水线
- 不安全的代码
- 冒犯性或不当
- 信息过时

极狐GitLab 正在积极迭代所有 AI 辅助功能，以提高生成内容的质量。我们通过提示工程、评估新的 AI/ML 模型来驱动这些功能，以及通过直接内置于这些功能中的新颖启发式方法来提高质量。

<a id="secret-detection-and-redaction"></a>

## 密钥检测与编辑

{{< history >}}

- 在极狐GitLab 17.9 中引入。

{{< /history >}}

极狐GitLab Duo 在流程执行期间包含[密钥检测与编辑](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/blob/main/docs/developer/secret-redaction.md)。根据场景，极狐GitLab Duo 会自动检测并移除代码中的敏感信息，如 API 密钥、凭证和令牌，然后再使用大语言模型进行处理。

在使用极狐GitLab Duo 时，您的代码会经过预扫描安全工作流：

1. 使用 Gitleaks 扫描您的代码以查找敏感信息。
1. 任何检测到的密钥都会自动从请求中移除。

密钥扫描在以下场景中运行：

- 代码补全上下文转换（在上下文发送到 AI 之前）
- AI 上下文转换
- 工作流工具结果
- Agentic Chat 用户输入
- Git 命令日志记录
- CLI 配置日志记录

> [!note]
> 当您通过 Web 界面与极狐GitLab Duo Chat 交互时，不会进行密钥扫描。

<a id="exception-secret-false-positive-detection"></a>

### 例外：密钥误报检测

[密钥误报检测](../application_security/vulnerabilities/secret_false_positive_detection.md) 是一项可选功能，它会将有关漏洞的信息（包括检测到的密钥周围的代码上下文）发送到 LLM 进行分析。这是对[密钥检测与编辑](#secret-detection-and-redaction)行为的刻意例外。

由于此功能是可选加入的，您必须在群组和项目级别明确启用它，然后任何漏洞数据才会发送到 LLM。在启用此功能之前，请查看您组织的数据政策。

<a id="share-group-usage-data-with-gitlab"></a>

## 与极狐GitLab 共享群组使用数据

{{< history >}}

- 在极狐GitLab 18.9.1 中引入。

{{< /history >}}

为了帮助提高服务质量，您可以与极狐GitLab 共享有关极狐GitLab Duo Agent Platform 功能的使用数据。

开启数据收集后，您命名空间中所有项目和子群组的 AI 交互都会被极狐GitLab 记录。此数据仅用于服务改进和调试，不用于训练 AI 模型。

您还可以[为实例](../../administration/gitlab_duo/configure/_index.md#share-usage-data-with-gitlab)开启使用数据收集。

前提条件：

- 拥有极狐GitLab 18.9.1 或更高版本。
- 拥有顶级群组的所有者角色。
- 在 JihuLab.com 上，您的群组必须[已启用极狐GitLab Duo](turn_on_off.md#turn-gitlab-duo-on-or-off)。

要为您的群组开启数据收集：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **数据收集** 下，选中 **收集使用数据** 复选框。
1. 选择 **保存更改**。

<a id="agent-platform-usage-data"></a>

### Agent Platform 使用数据

开启数据收集后，将记录以下数据：

- 与极狐GitLab Duo 交互的完整提示和响应文本。
- 会话上下文，包括在启用设置时正在进行的会话。
- 模型元数据（模型版本、令牌计数、延迟）。
- 工具调用及其结果。
- 会话 ID，用于与用户反馈相关联。

以下信息不包含在日志中，除非用户将其包含在自己的提示中：

- 用户 ID 或用户名。
- 电子邮件地址或个人标识符。
- 项目或命名空间标识符。

极狐GitLab 不会移除用户在其提示中包含的标识符。