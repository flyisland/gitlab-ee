---
stage: AI-powered
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: CI 专家代理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中作为 [测试版](../../../../policy/development_stages_support.md#beta) 引入，[使用功能标志](../../../../administration/feature_flags/_index.md) 名为 `foundational_pipeline_authoring_agent`。默认禁用。
- 功能标志在极狐GitLab 19.0 中移除。

{{< /history >}}

<a id="ci-expert-agent"></a>

CI 专家代理是一个专用代理，可帮助你创建、调试和优化极狐GitLab CI/CD 流水线。它结合了：

- 极狐GitLab CI/CD 语法和配置的深厚专业知识。
- 流水线优化策略和最佳实践知识。

在需要以下帮助时，请使用 CI 专家代理：

- 流水线创建：根据你的项目需求从头生成 `.gitlab-ci.yml` 配置。
- 组件建议：根据你的项目类型获取 CI/CD 组件推荐。例如，Node.js、Python、Go、Ruby 或 Docker 项目。
- 语法解释：理解 CI/CD 关键字和配置选项。
- 调试：分析作业日志并排查流水线故障。
- 优化：通过缓存、并行化以及使用 `needs` 关键字让作业更早启动，来提升流水线性能。
- 正确使用 CI/CD 关键字，包括 `rules`、`artifacts`、`services` 和 `environments`。

## 访问 CI 专家代理

先决条件：

- 必须[开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。

要访问 CI 专家代理：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到你的项目。
1. 在极狐GitLab Duo 侧边栏中，选择 **新会话**
   （{{< icon name="pencil-square" >}}）。
1. 从下拉列表中，选择 **CI 专家**。

   一个聊天对话会在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 输入你的 CI/CD 相关问题或请求。为获得最佳结果：

   - 描述你的项目类型和技术栈。
   - 如果你已有 `.gitlab-ci.yml`，请分享出来。
   - 指定你的目标。例如，更快的构建、部署到 Kubernetes 或并行运行测试。

### 示例提示

- “为我的 Node.js 项目创建一个包含测试和 Docker 构建的 CI/CD 流水线。”
- “为什么我的流水线失败了？错误信息如下：（粘贴错误信息）”
- “如何缓存依赖项以加快构建速度？”
- “为我的流水线添加一个部署到 Kubernetes 的阶段。”
- “`cache` 和 `artifacts` 有什么区别？”
- “帮我为我的测试套件设置并行测试。”
- “如何使用 `needs` 让作业更早启动？”
- “解释一下这个 CI/CD 配置的作用：（粘贴配置）”
- “如何设置多项目流水线？”
- “在流水线中处理密钥的最佳方式是什么？”
- “帮我优化流水线以减少构建时间。”
- “如何仅在合并请求时运行作业？”
- “为我的 Python 项目创建一个包含 pytest 和 linting 的 `.gitlab-ci.yml`。”
- “如何使用产物在作业之间传递数据？”
- “为我的项目设置 Auto DevOps。”