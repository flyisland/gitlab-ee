---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 支持助手
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

支持助手是一款专门的 Agent，可帮助您：

- 在不确定从何处入手时，诊断极狐GitLab 产品问题。
- 查找特定功能领域的故障排查文档。
- 检查问题是否为已知问题。
- 在需要升级到人工支持时，准备包含相关诊断信息的支持工单。

支持助手可帮助诊断极狐GitLab 问题。对于其他问题，支持助手会尝试为您指明正确的团队。

有关支持助手的更多信息，请参阅 [Agent 配置 YAML 文件](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/blob/main/duo_workflow_service/agent_platform/v1/flows/configs/support_assistant/1.0.0.yml)。

<a id="use-the-support-assistant"></a>

## 使用支持助手

前提条件：

- [启用内置 Agent](_index.md#turn-foundational-agents-on-or-off)。
- [启用测试版和实验性功能](../../turn_on_off.md#turn-on-beta-and-experimental-features)。

要使用支持助手：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在极狐GitLab Duo 侧边栏中，选择 **添加新会话**
   ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择 **支持助手**。

   屏幕右侧的极狐GitLab Duo 侧边栏中会打开一个 Chat 会话。
1. 用您自己的话描述您的极狐GitLab 问题，然后回答后续问题，Agent 会诊断原因。为获得最佳结果，请在请求中：

   - 先说明症状和影响。例如，“从今天早上开始构建一直失败，并阻塞了所有合并”比“CI 坏了”提供的信息更多。
   - 包含确切的错误消息（如有任何密钥，请将其隐去）和错误代码（如果有）。
   - 说明您已经尝试过的方法，这样 Agent 就不会重复建议相同的内容。
   - 尽早提及您的环境：JihuLab.com SaaS、极狐GitLab 私有化部署（以及安装类型，如 Linux 软件包或 Helm chart），或 GitLab Dedicated，以及版本。
   - 标记紧急程度。如果是生产环境中断，请明确说明，Agent 会直接准备紧急工单。
   - 每个会话只处理一个问题，以便诊断保持专注。

<a id="example-prompts"></a>

### 示例提示

- “我的流水线一直间歇性失败，且没有明确错误。我该从哪里入手？”
- “依赖扫描没有报告我的项目存在任何漏洞。”
- “使用个人访问令牌调用 API 时，我遇到了 403 错误。”
- “我们的 Geo 辅助节点远远落后于主节点。这是已知问题吗？”
- “我需要为 Gitaly 性能缓慢问题开一个支持工单。我应该包含哪些内容？”
- “对于基于 Helm 的极狐GitLab 私有化部署安装，我应该收集哪个诊断归档？”
