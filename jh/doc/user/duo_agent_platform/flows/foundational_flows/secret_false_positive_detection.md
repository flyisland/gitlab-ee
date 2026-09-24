---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 密钥误报检测
---

{{< details >}}

- Tier: 旗舰版
- Add-on: 极狐GitLab Duo Core, Pro, or Enterprise
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 该功能在极狐GitLab 18.10 中作为[测试版](../../../../policy/development_stages_support.md#beta)功能引入，由名为 `duo_secret_detection_false_positive` 的[功能标志](../../../../administration/feature_flags/_index.md)控制（参见史诗 [epic 17885]）。已在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

密钥误报检测会自动分析密钥检测结果，识别潜在的误报。消除那些很可能不是实际安全风险的密钥，可减少漏洞报告中的噪音。

当密钥检测扫描运行时，极狐GitLab Duo 会自动分析每条结果，判断其是否为误报。该检测适用于[极狐GitLab 密钥检测](../../../application_security/secret_detection/_index.md)发现的所有密钥类型。

极狐GitLab Duo 的评估会包含每条误报检测结果的以下信息：

- 置信度评分：一个数值评分，指示该发现为误报的可能性。
- 解释：说明该发现可能是真阳性或不是真阳性的原因。
- 可视化指示器：漏洞报告中显示评估结果的徽章。

结果基于 AI 分析，应由安全专业人员审查。此功能需要已激活订阅的极狐GitLab Duo。

> [!note]
> 你无法通过提及、指派或向其服务账户请求审查来触发此流程。该流程会在安全扫描完成后自动运行。你也可以通过点击漏洞报告中的 **检查误报** 按钮手动运行。

<a id="running-secret-false-positive-detection"></a>

## 运行密钥误报检测

该流程在以下情况下自动运行：

- 密钥检测扫描在默认分支上成功完成。
- 扫描检测到密钥。
- 项目或群组已启用极狐GitLab Duo 功能。

你也可以为现有漏洞手动触发分析：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 选择你要分析的漏洞。
1. 在右上角，选择 **检查误报**。

<a id="related-links"></a>

## 相关链接

- [密钥检测误报检测](../../../application_security/vulnerabilities/secret_false_positive_detection.md)。
- [漏洞报告](../../../application_security/vulnerability_report/_index.md)。
- [密钥检测](../../../application_security/secret_detection/_index.md)。

