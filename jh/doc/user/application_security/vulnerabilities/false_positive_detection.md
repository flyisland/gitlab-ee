---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自动检测误报
description: 自动检测并过滤 SAST 发现中的误报。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当静态应用安全测试（SAST）扫描运行时，SAST 误报检测任务流会自动分析每个严重和高严重级别的 SAST 漏洞，以判断其为误报的可能性。检测适用于来自[极狐GitLab 支持的 SAST 分析器](../sast/analyzers.md)的漏洞。

任务流评估包括：

- 置信度分数：一个数值分数，表示该发现是误报的可能性。
- 解释：基于代码上下文和漏洞特征，说明该发现可能是或可能不是真实漏洞的上下文推理。
- 视觉指示器：漏洞报告中显示误报评估的徽章。

每次安全扫描后，检测会自动运行，无需手动触发。

结果基于 AI 分析，应由安全专业人员审阅。

<!-- Video published on 2026-03-20 -->

如需点击式演示，请参阅 [SAST 误报检测任务流](https://gitlab.navattic.com/sast-fp-detection-flow)。
<!-- Demo published on 2026-02-17 -->

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../../duo_agent_platform/_index.md#prerequisites)。
- 为[顶级群组](../../duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)开启 **允许内置任务流** 和 **SAST 误报检测**。
- [配置推送规则以允许服务账号](../../duo_agent_platform/troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
- 为您的项目[配置您自己的 Runner](../../duo_agent_platform/flows/execution/_index.md#configure-runners-to-execute-flows) 或开启 [极狐GitLab 托管 Runner](../../../ci/runners/hosted_runners/_index.md)。
- 在您的用户偏好中设置[默认的极狐GitLab Duo 命名空间](../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

<a id="allow-foundational-flow-for-a-group"></a>

## 为群组允许内置任务流

您可以允许群组中的所有项目使用该内置任务流。单个项目仍必须在其项目设置中启用该功能。
要为群组中的所有项目允许误报检测：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 在 **允许内置任务流** 下，选中 **SAST 误报检测** 复选框。
1. 选择 **保存更改**。

<a id="turn-on-for-a-project"></a>

## 为项目开启

先决条件：

- 项目的安全管理员、维护者或所有者角色。

要为特定项目开启误报检测：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo**。
1. 打开 **开启 SAST 误报检测** 开关。
1. 选择 **保存更改**。

当您为群组允许误报检测并为项目开启该功能时，该功能会与您现有的 SAST 扫描器自动配合工作。

<a id="automatic-detection"></a>

## 自动检测

误报检测任务流在以下情况自动运行：

- SAST 安全扫描在默认分支上成功完成。
- 扫描检测到严重或高严重级别的漏洞。
- 该项目已启用极狐GitLab Duo 功能。

分析在后台进行，处理完成后结果会显示在漏洞报告中。

<a id="run-the-sast-false-positive-detection-flow"></a>

## 运行 SAST 误报检测任务流

您可以手动触发对现有漏洞的分析：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 选择要分析的漏洞。
1. 在右上角，选择 **AI 操作**，然后选择 **检查误报**。

极狐GitLab Duo 分析将运行，结果会显示在漏洞详情页面上。

<a id="analyze-multiple-vulnerabilities"></a>

## 分析多个漏洞

{{< details >}}

- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

您可以触发任务流来分析多个漏洞是否为误报。

将分析以下严重级别：

- 严重
- 高
- 中
- 低
- 未知
- 信息

先决条件：

- 要分析多个漏洞，您必须具有以下任一角色：
  - 项目的安全管理员、维护者或所有者角色
  - 具有 `admin_vulnerability` 权限的自定义角色
- 要查看任务流的进度，您必须具有开发者角色。

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **安全** > **漏洞报告**。
1. 选中每个要分析的漏洞旁边的复选框。
   要选择页面上的所有漏洞，请选中表头中的复选框。
1. 从 **选择操作** 下拉列表中，选择 **运行 SAST 误报检测**。
1. 选择 **运行 SAST 误报检测**。

<a id="known-limitations"></a>

### 已知限制

- 进度报告仅显示符合解决条件的漏洞数量。
  如果您选择了 10 个漏洞，其中三个符合条件，则进度报告仅报告三个。
- 一个项目中每个任务流同一时间只能有一次运行处于活动状态。
  该运行属于该项目，因此由其他用户启动的运行也会阻止新的运行。
  请等待当前运行完成，然后再启动同一任务流的另一次运行。
- 您一次最多只能批量运行 1,000 个漏洞的任务流。
  此限制适用于您在漏洞报告中选择的漏洞。
  要解决超过 1,000 个漏洞，请使用 GraphQL。

<a id="confidence-scores"></a>

## 置信度分数

置信度分数用于估计极狐GitLab Duo 评估正确的可能性：

- **很可能为误报（80-100%）**：极狐GitLab Duo 高度确信该发现是误报。
- **可能为误报（60-79%）**：极狐GitLab Duo 对该发现可能是误报有合理的信心，但建议进行人工审阅。
- **很可能不是误报（<60%）**：极狐GitLab Duo 对该发现是误报没有信心。在关闭该漏洞之前，强烈建议进行人工审阅。

<a id="dismissing-false-positives"></a>

## 关闭误报

当极狐GitLab Duo 分析将漏洞识别为误报时，您有以下选项：

- 关闭该漏洞
- 移除误报标记

<a id="dismiss-the-vulnerability"></a>

### 关闭漏洞

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 选择要关闭的漏洞。
1. 在右侧边栏的 **状态** 部分，选择 **编辑**。
1. 从 **状态** 下拉列表中，在 **关闭为...** 下，选择 **误报**。
1. 在 **评论** 文本框中，提供您将其关闭为误报的原因上下文。
   评论为必填项。
1. 选择 **更改状态**。

该漏洞将被标记为已关闭，除非被重新引入，否则不会出现在未来的扫描中。

<a id="remove-the-false-positive-flag"></a>

### 移除误报标记

如果您想移除误报评估并保留该漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **漏洞报告**。
1. 找到带有误报标记的漏洞。
1. 将鼠标悬停在漏洞上的误报徽章上。
1. 选择 **移除误报标记**。

误报标记将被移除，FP 置信度分数将恢复为 0。该漏洞仍保留在报告中，并可在未来的扫描中重新评估。

<a id="providing-feedback"></a>

## 提供反馈

在 [议题 583697](https://gitlab.com/gitlab-org/gitlab/-/issues/583697) 中分享您的反馈。
