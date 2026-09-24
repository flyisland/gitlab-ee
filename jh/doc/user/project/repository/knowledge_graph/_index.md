---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create structured, queryable representations of code repositories to power AI features and enhance developer productivity with the GitLab Knowledge Graph.
title: 极狐GitLab 知识图谱
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- 状态：测试版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 中作为[实验](../../../../policy/development_stages_support.md#experiment)引入。
- 在极狐GitLab 18.4 中变更为[测试版](../../../../policy/development_stages_support.md#beta)。

{{< /history >}}

[极狐GitLab Duo Agent Platform](../../../duo_agent_platform/_index.md) 使用
[极狐GitLab 知识图谱](https://gitlab-org.gitlab.io/rust/knowledge-graph) 来提高 AI Agent 的准确性。你可以在 AI 项目中使用知识图谱框架，以在整个代码库中实现丰富的代码智能。例如，在构建检索增强生成（RAG）应用时，知识图谱可将你的代码库转化为一个实时、可嵌入的图数据库，供 AI Agent 使用。知识图谱还能创建架构可视化，提供关于系统结构和依赖关系的清晰图表。

你可以通过一行脚本安装知识图谱框架。它会解析本地仓库，并使用模型上下文协议（MCP）连接以查询你的项目。知识图谱会捕获诸如文件、目录、类、函数及其关系等实体。这些附加上下文可实现高级代码理解和 AI 功能。例如，这使得极狐GitLab Duo Agent 能够理解本地工作空间中的关系，从而更快、更精准地响应复杂问题。

知识图谱扫描你的代码以识别：

- 结构元素：构成应用骨架的文件、目录、类、函数和模块。
- 代码关系：诸如函数调用、继承层次和模块依赖等复杂连接。

知识图谱还提供了一个 CLI。有关知识图谱 CLI（`gkg`）和框架的更多信息，请参阅
[知识图谱项目文档](https://gitlab-org.gitlab.io/rust/knowledge-graph)。

