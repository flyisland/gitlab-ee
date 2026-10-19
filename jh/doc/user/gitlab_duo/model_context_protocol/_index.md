---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 介绍模型上下文协议及其使用方法
title: 模型上下文协议
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

模型上下文协议（MCP）是一种开放标准，用于将 AI 助手连接到现有工具和数据源。MCP 就像通用适配器。您无需为每个软件平台分别创建自定义连接，而是可以使用单一标准化协议进行系统通信。

例如，AI 助手可以通过同一协议从您的 CRM 中提取客户数据、在极狐GitLab 中查看项目状态，并查阅您 Wiki 中的文档。这种方式减少了开发人员的配置工作，并打造出更强大的 AI 助手，使其能够访问所需的上下文。

极狐GitLab 通过两种方式支持 MCP：

- [MCP 客户端](mcp_clients.md)：将极狐GitLab Duo 功能（如极狐GitLab Duo Agentic Chat）
  连接到外部 MCP 服务器，以访问其他系统的数据和工具，
  从而提供更全面的协助。

- [MCP 服务器](../../model_context_protocol/mcp_server.md)：将外部 AI 工具连接到您的极狐GitLab 实例。
  连接的工具可以安全地访问您的项目、议题、合并请求
  和其他极狐GitLab 数据。
