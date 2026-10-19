---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: CI 专家 Agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI 专家 Agent 是一个专用 Agent，可帮助您创建、调试和优化极狐GitLab CI/CD 流水线。它结合了：

- 对极狐GitLab CI/CD 语法和配置的深入专业知识。
- 对流水线优化策略和最佳实践的了解。

当您在以下方面需要帮助时，可使用 CI 专家 Agent：

- 流水线创建：根据您的项目需求从零开始生成 `.gitlab-ci.yml` 配置。
- 语法说明：了解 CI/CD 关键字和配置选项。
- 调试：分析作业日志并排查流水线故障。
- 优化：通过缓存、并行化以及使用 `needs` 关键字让作业更早启动，来提升流水线性能。
- 正确使用 CI/CD 关键字，包括 `rules`、`artifacts`、`services` 和 `environments`。

<a id="access-the-ci-expert-agent"></a>

## 访问 CI 专家 Agent

先决条件：

- 必须[开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。

要访问 CI 专家 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在极狐GitLab Duo 侧边栏中，选择 **添加新聊天** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中选择 **CI Expert**。

   聊天对话会在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 输入您与 CI/CD 相关的问题或请求。要让请求获得最佳结果：

   - 描述您的项目类型和技术栈。
   - 分享您现有的 `.gitlab-ci.yml`（如果有）。
   - 说明您的目标。例如，更快的构建、部署到 Kubernetes，或并行运行测试。

<a id="example-prompts"></a>

### 示例提示

- “为我的 Node.js 项目创建一个包含测试和 Docker 构建的 CI/CD 流水线。”
- “如何缓存依赖项以加快构建速度？”
- “为我的 Kubernetes 流水线添加部署阶段。”
- “`cache` 和 `artifacts` 有什么区别？”
- “帮我为测试套件设置并行测试。”
- “如何使用 `needs` 让作业更早启动？”
- “解释一下这个 CI/CD 配置的作用：（粘贴配置）”
- “如何设置多项目流水线？”
- “在流水线中处理密钥的最佳方式是什么？”
- “帮我优化流水线以减少构建时间。”
- “如何仅在合并请求上运行作业？”
- “为我的 Python 项目创建一个包含 pytest 和 linting 的 `.gitlab-ci.yml`。”
- “如何使用产物在作业之间传递数据？”
