---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 AI 解释漏洞
---

{{< details >}}

- Tier: 旗舰版
- 附加组件: 极狐GitLab Duo Enterprise, 极狐GitLab Duo with Amazon Q
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../gitlab_duo/model_selection.md#default-models)
- Amazon Q 的 LLM：Amazon Q Developer
- 可用于[自部署模型的极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

极狐GitLab Duo 漏洞解释功能可以通过使用大语言模型，帮助您处理漏洞：

- 总结漏洞。
- 帮助开发者和安全分析师理解该漏洞、其可能被利用的方式以及如何修复。
- 提供建议的缓解措施。

极狐GitLab Duo 还可以自动分析严重级别和高危级别的 SAST 漏洞，以识别潜在的误报。更多信息，请参见 [SAST 误报检测](../vulnerabilities/false_positive_detection.md)。

先决条件：

- 项目的开发者、维护者或所有者角色。
- 必须为群组或实例启用[极狐GitLab Duo](../../gitlab_duo/turn_on_off.md)。
- 您必须是该项目的成员。
- 该漏洞必须来自 SAST 扫描器。

要解释漏洞：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **漏洞报告**。
1. 可选。要移除默认筛选条件，请选择**清除**（{{< icon name="clear" >}}）。
1. 在漏洞列表上方，选择筛选栏。
1. 在出现的下拉列表中，选择**工具**，然后选择 **SAST** 类别中的所有值。
1. 在筛选字段外选择。漏洞严重性总计和匹配的漏洞列表会更新。
1. 选择您想要解释的 SAST 漏洞。
1. 执行以下操作之一：

   - 选择漏洞描述下方显示*您也可以使用 AI，让极狐GitLab Duo Chat 解释此漏洞及建议的修复方法。*的文本。
   - 在右上角，选择 **AI 操作**，然后选择**使用 AI 解释**。
   - 打开极狐GitLab Duo Chat，输入 `/vulnerability_explain` 使用[解释漏洞](../../gitlab_duo_chat/examples.md#explain-a-vulnerability)命令。

响应会显示在页面右侧。

在 JihuLab.com 上，此功能可用。
默认情况下，它由 MiniMax-M3 模型提供支持。极狐GitLab 无法保证大语言模型生成的结果是正确的。请谨慎使用该解释。

<a id="data-shared-with-third-party-ai-apis-for-vulnerability-explanation"></a>

## 为漏洞解释与第三方 AI API 共享的数据

以下数据会与第三方 AI API 共享：

- 漏洞标题（可能包含文件名，具体取决于所使用的扫描器）。
- 漏洞标识符。
- 文件名。
