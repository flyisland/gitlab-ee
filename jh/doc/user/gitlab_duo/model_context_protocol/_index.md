---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Describes Model Context Protocol and how to use it
title: 模型上下文协议
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

模型上下文协议 (MCP) 是一个开放标准，可将 AI 助手连接到现有的工具和数据源。MCP 作为一个通用适配器工作。无需为每个软件平台创建单独的自定义连接，你可以使用一个标准化的协议进行系统通信。

例如，一个 AI 助手可以通过相同的协议从你的 CRM 中拉取客户数据，检查极狐GitLab 中的项目状态，并参考你 wiki 中的文档。这种方法减少了开发者的配置工作，并创建了更强大的 AI 助手，使其能够访问所需的上下文。

极狐GitLab 通过两种方式支持 MCP：

- [MCP 客户端](mcp_clients.md)：将 极狐GitLab Duo 功能（如 极狐GitLab Duo Agentic Chat）连接到外部 MCP 服务器，以访问来自其他系统的数据和工具，从而提供更全面的帮助。
- [MCP 服务器](mcp_server.md)：将外部 AI 工具连接到你的极狐GitLab 实例。连接的工具可以安全地访问你的项目、议题、合并请求和其他极狐GitLab 数据。

