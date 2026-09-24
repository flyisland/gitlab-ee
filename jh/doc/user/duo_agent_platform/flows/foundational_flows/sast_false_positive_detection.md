---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SAST 误报检测流
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.7 中作为[测试版](../../../../policy/development_stages_support.md#beta)功能[引入](https://gitlab.com/groups/gitlab-org/-/epics/18977)，[使用功能标志](../../../../administration/feature_flags/_index.md) `enable_vulnerability_fp_detection` 和 `ai_experiment_sast_fp_detection`。默认禁用。
- 在极狐GitLab 18.10 中[GA](https://gitlab.com/groups/gitlab-org/-/work_items/19789)。

{{< /history >}}

SAST 误报检测流会自动分析严重和高危的 SAST 漏洞，以识别潜在的误报。此过程通过标记可能不是实际安全风险的漏洞，来减少漏洞报告中的干扰。

当 SAST 安全扫描运行时，极狐GitLab Duo 会自动分析每个漏洞，以确定其为误报的可能性。检测适用于来自[极狐GitLab 支持的 SAST 分析器](../../../application_security/sast/analyzers.md)的漏洞。

极狐GitLab Duo 的评估包括：

- 置信度分数：一个数字分数，表明该发现为误报的可能性。
- 解释：关于该发现为何可能是或可能不是实际漏洞的上下文推理。
- 可视化指示器：在漏洞报告中，显示评估结果的标记。

结果基于 AI 分析，应由安全专业人员审查。此功能需要具有有效订阅的极狐GitLab Duo。

如需点击演示，请参见[SAST 误报检测流](https://gitlab.navattic.com/sast-fp-detection-flow)。

> [!note]
> 你不能通过提及其服务账号、将其指派为负责人或向其请求审查来触发此流程。该流程会在安全扫描完成后自动运行。你也可以从漏洞报告中通过点击**检查是否为误报**按钮手动运行它。

<!-- Demo published on 2026-02-17 -->

<a id="run-sast-false-positive-detection"></a>

## 运行 SAST 误报检测

在以下情况下，该流程会自动运行：

- SAST 安全扫描在默认分支上成功完成。
- 扫描检测到严重或高危急的漏洞。
- 为项目或群组启用了极狐GitLab Duo 功能。

你也可以手动触发对现有漏洞的分析：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的项目。
1. 在左侧边栏中，选择**安全** > **漏洞报告**。
1. 选择你想要分析的漏洞。
1. 在右上角，选择**检查是否为误报**。