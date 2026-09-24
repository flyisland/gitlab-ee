---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 AI 解释漏洞
---

{{< details >}}

- Tier: 旗舰版
- Add-on: GitLab Duo Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../gitlab_duo/model_selection.md#default-models)
- 可访问 [自部署模型的极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 引入于 GitLab 16.0，作为 JihuLab.com 上的 [实验](../../../policy/development_stages_support.md#experiment)。
- 在 GitLab 16.2 中提升为 [Beta](../../../policy/development_stages_support.md#beta) 状态。
- 在 GitLab 17.2 中正式发布（GA）。
- 在 GitLab 17.6 及之后版本，改为需要 GitLab Duo 附加功能。

{{< /history >}}

极狐GitLab Duo 漏洞解释可以通过使用大语言模型帮助你处理漏洞：

- 总结漏洞。
- 帮助开发者及安全分析师理解漏洞、其可能被利用的方式以及如何修复。
- 提供建议的缓解措施。

极狐GitLab Duo 还可以自动分析严重及高危 SAST 漏洞，以识别潜在的误报。更多信息，请参见 [SAST 误报检测](../vulnerabilities/false_positive_detection.md)。

前提条件：

- 项目的开发者、维护者或所有者角色。
- [极狐GitLab Duo](../../gitlab_duo/turn_on_off.md) 必须为群组或实例启用。
- 你必须是该项目的成员。
- 漏洞必须来自 SAST 扫描器。

要解释漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 可选。要清除默认过滤器，选择 **清除** ({{< icon name="clear" >}})。
1. 在漏洞列表上方，选择过滤栏。
1. 在出现的下拉列表中，选择 **工具**，然后选择 **SAST** 类别中的所有值。
1. 选择过滤字段外部。漏洞严重性总数和匹配漏洞列表将更新。
1. 选择你要解释的 SAST 漏洞。
1. 执行以下操作之一：

   - 选择漏洞描述下方显示的文字：_你也可以通过询问极狐GitLab Duo Chat 来使用 AI 解释此漏洞并提供建议的修复方案。_
   - 在右上方，从 **通过合并请求解决** 下拉列表中，选择 **解释漏洞**，然后再次选择 **解释漏洞**。
   - 打开极狐GitLab Duo Chat 并使用 [解释漏洞](../../gitlab_duo_chat/examples.md#explain-a-vulnerability) 命令，输入 `/vulnerability_explain`。

响应将显示在页面右侧。

在 JihuLab.com 上，此功能可用。默认情况下，它由国内 SOTA 大模型提供支持。极狐GitLab 无法保证大语言模型产生的结果是正确的。请谨慎使用解释。

<a id="data-shared-with-third-party-ai-apis-for-vulnerability-explanation"></a>

## 用于漏洞解释的与第三方 AI API 共享的数据

以下数据与第三方 AI API 共享：

- 漏洞标题（可能包含文件名，取决于使用的扫描器）。
- 漏洞标识符。
- 文件名。