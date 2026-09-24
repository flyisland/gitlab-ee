---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 密钥误报检测
description: Automatic detection and filtering of false positives in secret detection findings.
---

{{< details >}}

- Tier: 旗舰版
- Add-on: 极狐GitLab Duo Core、专业版 或 企业版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 于 极狐GitLab 18.10 引入，作为 [测试版](../../../policy/development_stages_support.md#beta) 功能，需启用功能标志 `duo_secret_detection_false_positive`。已在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

密钥误报检测是一项可选功能。启用后，极狐GitLab Duo 会分析每个检测到的密钥，以确定其为误报的可能性。该检测支持[极狐GitLab 密钥检测](../secret_detection/_index.md) 检测到的所有密钥类型。

> [!important]
> 启用此功能后，漏洞信息（包括检测到的密钥周围的代码上下文）将被发送到大语言模型（LLM）进行分析。[密钥检测与数据脱敏](../../gitlab_duo/data_usage.md#secret-detection-and-redaction) 文档中描述的行为不适用于此功能。启用此功能前，请先审查组织的数据策略。

极狐GitLab Duo 评估包括每个误报发现的以下信息：

- 置信度评分：一个数字分数，表示该发现为误报的可能性。
- 解释：基于代码上下文和密钥特征，说明该发现可能是真阳性或误报的理由。
- 可视化指示器：在漏洞报告中显示误报评估的标记。

启用后，误报检测会在每次安全扫描后自动运行，无需手动干预。

结果基于 AI 分析，建议安全专业人员审查。该功能需要带有有效订阅的极狐GitLab Duo。

<a id="automatic-detection"></a>

# 自动检测

误报检测在以下场景中自动运行：

- 密钥检测扫描在默认分支上成功完成。
- 扫描检测到密钥。
- 项目已启用极狐GitLab Duo 功能。

分析在后台运行，处理完成后结果会出现在漏洞报告中。

<a id="manual-trigger"></a>

# 手动触发

你可以手动对现有漏洞运行误报检测：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 选择你要分析的漏洞。
1. 在右上角，选择 **检查是否为误报** 以触发误报检测。

极狐GitLab Duo 分析将运行并在漏洞详情页面显示结果。

<a id="configuration"></a>

# 配置

要使用误报检测，你必须满足以下要求：

- 一个极狐GitLab Duo 附加订阅（极狐GitLab Duo Core、专业版 或 企业版）。
- 在项目或群组中[启用极狐GitLab Duo](../../gitlab_duo/turn_on_off.md)。
- 在用户偏好设置中[设置默认的极狐GitLab Duo 命名空间](../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 极狐GitLab 18.10 或更高版本。

<a id="enable-false-positive-detection"></a>

# 启用误报检测

误报检测默认关闭，必须显式启用。启用后，漏洞信息（包括周围的代码上下文）将被发送到大语言模型进行分析。要使用此功能，你必须为群组启用基础流程，并为项目开启该功能。

<a id="allow-foundational-flow-for-a-group"></a>

# 允许群组使用基础流程

你可以允许群组中的所有项目使用基础流程。各个项目仍需要在项目设置中启用该功能。
要为群组中的所有项目允许误报检测：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 在 **允许基础流程** 下，选中 **密钥检测误报检测** 复选框。
1. 选择 **保存更改**。

<a id="turn-on-for-a-project"></a>

# 为项目开启

要为特定项目开启误报检测：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo**。
1. 打开 **开启密钥检测误报检测** 开关。
1. 选择 **保存更改**。

当你允许群组使用误报检测并在项目中启用它后，该功能将自动与你现有的密钥检测扫描器一起工作。

<a id="confidence-scores"></a>

# 置信度评分

置信度评分估计极狐GitLab Duo 评估正确的可能性：

- 有可能为误报（80-100%）：极狐GitLab Duo 高度确信该发现为误报。
- 可能为误报（60-79%）：极狐GitLab Duo 有一定把握认为该发现可能是误报，但建议手动审查。
- 大概不是误报（&lt;60%）：极狐GitLab Duo 不认为该发现是误报。强烈建议在忽略此漏洞之前进行手动审查。

<a id="dismissing-false-positives"></a>

# 忽略误报

当极狐GitLab Duo 分析将某个漏洞识别为误报时，你可以选择以下操作：

- 忽略漏洞
- 移除误报标记

<a id="dismiss-the-vulnerability"></a>

# 忽略漏洞

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 选择你要忽略的漏洞。
1. 选择 **更改状态**。
1. 从 **状态** 下拉列表中，选择 **已忽略**。
1. 从 **设置忽略原因** 下拉列表中，选择 **误报**。
1. 在 **添加评论** 输入框中，提供为何将其作为误报忽略的上下文。
1. 选择 **更改状态**。

该漏洞将被标记为已忽略，除非重新引入，否则不会出现在未来的扫描中。

<a id="remove-the-false-positive-flag"></a>

# 移除误报标记

如果你想移除误报评估并保留漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 找到带有误报标记的漏洞。
1. 将鼠标悬停在漏洞上的误报标记上。
1. 选择 **移除误报标记**。

误报标记将被移除，误报置信度评分恢复为 0。该漏洞仍保留在报告中，可在未来的扫描中重新评估。