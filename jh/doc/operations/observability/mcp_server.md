---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 使用模型上下文协议服务器，从 AI 助手查询极狐GitLab 可观测性数据。
ignore_in_report: true
title: 可观测性 MCP 服务器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

极狐GitLab 可观测性提供 [模型上下文协议（MCP）](https://modelcontextprotocol.io)
服务器，您可以使用自然语言从 AI 助手和 Agent 查询可观测性数据。

连接后，支持 MCP 的客户端可以询问有关遥测数据的问题，并获得基于您自身数据的答案。支持的客户端包括 Cursor、Claude（Claude Code 和 Claude Desktop）、VS Code 和 Codex。例如：

- 哪个服务在过去一小时内错误率最高？
- 显示结账服务的错误日志。
- 支付服务今天的 p99 延迟是多少？
- 列出正在上报数据的服务。

MCP 服务器可以查询极狐GitLab 可观测性实例中的指标、追踪、日志、告警、仪表板和服务。

<a id="prerequisites"></a>

## 前提条件

- 您的群组或个人项目必须已启用可观测性。
  有关设置说明，请参阅
  [在 JihuLab.com 上设置可观测性](setup_gitlab_com.md)。
- 对于群组，您必须具有开发者、维护者或所有者角色。对于
  个人项目，您必须具有所有者角色。
- 您需要一个支持远程 HTTP 服务器的 MCP 客户端。

<a id="get-your-api-key"></a>

## 获取您的 API 密钥

MCP 服务器本身没有常驻凭据。每个用户使用自己的极狐GitLab 可观测性 API 密钥进行身份验证，其 MCP 客户端会在每个请求中发送该密钥。访问权限范围限定为该密钥允许查看的内容。

要创建 API 密钥：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或个人项目。
1. 在左侧边栏中，选择 **可观测性** > **API 密钥**。
1. 创建密钥并复制。

> [!warning]
> 请安全存储您的 API 密钥。不要将其提交到版本控制。如果可用，请使用 MCP
> 客户端的密钥管理或环境变量支持。

<a id="get-your-mcp-endpoint"></a>

## 获取您的 MCP 端点

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或个人项目。
1. 在左侧边栏中，选择 **可观测性** > **设置**。
1. 在 **MCP 服务器** 部分，复制 **MCP 端点**。

您的 MCP 端点遵循以下模式：

```plaintext
https://<namespace_id>.mcp.gitlab-o11y.com/mcp
```

将 `<namespace_id>` 替换为您启用可观测性的命名空间 ID。命名空间 ID 是您的群组 ID，或者如果您在个人项目上启用了可观测性，则为您的个人命名空间 ID。

<a id="connect-a-client"></a>

## 连接客户端

1. 使用您复制的端点，将 MCP 服务器作为新的远程 HTTP MCP 服务器添加到您的客户端。
1. 当您的客户端提示进行身份验证时，提供您创建的 API 密钥。您的客户端会将其作为 `SIGNOZ-API-KEY` 请求头发送。
1. 在您的客户端中验证连接。例如，列出可用的 MCP 工具，然后开始询问有关可观测性数据的问题。

<a id="available-tools"></a>

## 可用工具

MCP 服务器提供用于读取和探索可观测性数据的工具，包括：

- 指标：列出和查询
- 日志：搜索和聚合
- 追踪：搜索和检查单个追踪和跨度
- 服务：列出和查看主要操作
- 告警：列出和检查告警规则
- 仪表板：列出和检查仪表板和已保存视图

您的 AI 助手会选择适当的工具来回答您的问题，并返回从您实例数据中获取的结果。
