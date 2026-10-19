---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全分析师 Agent
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

安全分析师 Agent 是一款专用的 AI 助手，可帮助您在极狐GitLab 中完成漏洞管理和安全分析工作流。它结合了安全领域的专业知识与对极狐GitLab 安全功能、漏洞报告、安全仪表板和合规工具的深入了解，帮助您高效地排查、评估和修复安全发现。

当您需要以下方面的帮助时，可以使用安全分析师 Agent：

- 漏洞排查：分析并确定不同扫描类型的安全发现的优先级。
- 风险评估：评估漏洞的严重性、可利用性和业务影响。
- 误报识别：区分真实威胁与无害的发现。
- 合规管理：了解监管要求和修复时限。
- 安全报告：生成安全态势和修复进度的摘要。
- 修复规划：制定可执行的计划来处理安全漏洞。
- 安全工作流自动化：简化重复性的安全评估任务。

安全分析师 Agent 了解极狐GitLab 特有的安全实现，包括漏洞状态、严重性级别和安全扫描器输出。它可以解读 EPSS 分数、CVE 数据和可达性分析，以提供结合上下文的安全指导。

<a id="use-the-security-analyst-agent"></a>

## 使用安全分析师 Agent

您可以在极狐GitLab UI、VS Code 和 JetBrains IDE 中使用安全分析师 Agent。

<a id="in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中

先决条件：

- 使用已启用安全扫描的极狐GitLab 项目。
- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。

要在极狐GitLab UI 中使用安全分析师 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在极狐GitLab Duo 边栏中，选择**添加新会话**（{{< icon name="pencil-square" >}}）。
1. 从下拉列表中，选择**安全分析师**。

   聊天对话会在屏幕右侧的极狐GitLab Duo 边栏中打开。
1. 输入您的安全相关问题或请求。为从请求中获得最佳结果：

   - 提供有关您的安全需求和风险承受能力的背景信息。
   - 说明您关注的是哪些类型的漏洞或扫描结果。
   - 在请求分析时，包含相关的项目或组件详细信息。
   - 如果安全分析师 Agent 的建议与您的安全策略不一致，请要求其澄清。
   - 在讨论特定发现时，使用具体的漏洞 ID 或 URL。

<a id="in-vs-code"></a>

### 在 VS Code 中

先决条件：

- 使用已启用安全扫描的极狐GitLab 项目。
- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 安装并配置 [GitLab for VS Code](../../../../editor_extensions/visual_studio_code/setup.md)
  6.57.3 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

要在 VS Code 中使用安全分析师 Agent：

1. 在 VS Code 的左侧边栏中，选择**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
1. 选择**聊天**标签页。
1. 从**新会话**（{{< icon name="duo-chat-new" >}}）下拉列表中，选择**安全分析师**。
1. 输入您的安全相关问题或请求。为从请求中获得最佳结果：

   - 提供有关您的安全需求和风险承受能力的背景信息。
   - 说明您关注的是哪些类型的漏洞或扫描结果。
   - 在请求分析时，包含相关的项目或组件详细信息。
   - 如果安全分析师 Agent 的建议与您的安全策略不一致，请要求其澄清。
   - 在讨论特定发现时，使用具体的漏洞 ID 或 URL。

<a id="in-jetbrains-ides"></a>

### 在 JetBrains IDE 中

先决条件：

- 使用已启用安全扫描的极狐GitLab 项目。
- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 安装并配置 [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../../../editor_extensions/jetbrains_ide/setup.md)
  3.11.1 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

首先，启用极狐GitLab Duo Agent Platform：

1. 在您的 JetBrains IDE 中，转到**设置** > **工具** > **极狐GitLab Duo**。
1. 在**极狐GitLab Duo Agent Platform** 下，选中**启用极狐GitLab Duo Agent Platform** 复选框。
1. 如果系统提示，请重启您的 IDE。

然后，要使用安全分析师 Agent：

1. 在您的 JetBrains IDE 中，在右侧工具窗口栏上，选择**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
1. 选择**聊天**标签页。
1. 从**新会话**（{{< icon name="duo-chat-new" >}}）下拉列表中，选择**安全分析师**。
1. 输入您的安全相关问题或请求。为从请求中获得最佳结果：

   - 提供有关您的安全需求和风险承受能力的背景信息。
   - 说明您关注的是哪些类型的漏洞或扫描结果。
   - 在请求分析时，包含相关的项目或组件详细信息。
   - 如果安全分析师 Agent 的建议与您的安全策略不一致，请要求其澄清。
   - 在讨论特定发现时，使用具体的漏洞 ID 或 URL。

<a id="example-prompts"></a>

## 示例提示

- 漏洞分析：
  - “显示我项目中的所有严重漏洞。”
  - “列出 EPSS 分数高于 0.7 且可达的漏洞。”
  - “根据可利用性，我应该优先处理哪些 SAST 发现？”
  - “分析（组件名称）中漏洞的安全影响。”
  - “比较此版本与上一版本之间的漏洞趋势。”
- 风险评估：
  - “这些容器扫描发现的业务风险是什么？”
  - “帮我评估此依赖项漏洞是否影响我们的用例。”
  - “评估跨越信任边界的漏洞的严重性。”
  - “哪些漏洞对生产环境构成最高风险？”
- 排查和管理：
  - “忽略所有被标记为误报且代码不可达的依赖项扫描漏洞。”
  - “确认所有具有已知漏洞利用的容器扫描漏洞。”
  - “将所有跨越信任边界的漏洞的严重性更新为高。”
  - “显示过去一周内被忽略的漏洞及其原因。”
  - “将漏洞状态恢复为已检测，以便重新评估。”
- 议题管理：
  - “为所有已确认的高严重性 SAST 漏洞创建议题，并将它们指派给最近的提交者。”
  - “将漏洞（漏洞 ID）链接到议题（议题 ID），以便跟踪修复进度。”
  - “为关键基础设施漏洞生成修复任务。”
  - “创建一个安全史诗，以跟踪所有与身份验证相关的漏洞。”
- 报告和合规：
  - “生成我们当前安全态势的高层摘要。”
  - “起草一份显示修复进度的合规报告。”
  - “为安全评审委员会总结安全发现。”
  - “创建一个处理所有高严重性发现的时间表。”
- 修复指导：
  - “为这些 SQL 注入漏洞建议修复方法。”
  - “针对此容器基础镜像漏洞，推荐的修复方案是什么？”
  - “帮我确定下一个冲刺中安全补丁的优先级。”
  - “提供有关安全编码实践的指导，以预防这些问题。”
