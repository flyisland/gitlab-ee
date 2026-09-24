---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure large language models for GitLab Duo features.
title: 极狐GitLab Duo AI 模型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core, Pro or Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

每个 极狐GitLab Duo 功能都使用默认模型。极狐GitLab 可能会更新默认模型以优化性能。您可以为功能选择不同的模型，该选择会一直持续，直到您更改它。

<a id="default-models"></a>

默认模型

下表列出了每个 极狐GitLab Duo 功能的默认模型。

| 功能 | 模型 |
|---------|---------------|
| **代码建议** | |
| 代码生成 | 国内 SOTA 模型 |
| 代码补全 | 国内 SOTA 模型 |
| **极狐GitLab Duo Chat** | |
| 通用聊天 | 国内 SOTA 模型 |
| 代码解释 | 国内 SOTA 模型 |
| 测试生成 | 国内 SOTA 模型 |
| 重构代码 | 国内 SOTA 模型 |
| 修复代码 | 国内 SOTA 模型 |
| 根因分析 | 国内 SOTA 模型 |
| **极狐GitLab Duo 合并请求功能** | |
| 合并提交信息生成 | 国内 SOTA 模型 |
| 合并请求摘要 | 国内 SOTA 模型 |
| 代码审查摘要 | 国内 SOTA 模型 |
| 代码审查 | 国内 SOTA 模型 |
| **其他极狐GitLab Duo 功能** | |
| 漏洞解释 | 国内 SOTA 模型 |
| 漏洞修复 | 国内 SOTA 模型 |
| 讨论摘要 | 国内 SOTA 模型 |
| 极狐GitLab Duo for CLI | 国内 SOTA 模型 |

<a id="supported-models"></a>

支持的模型

下表列出了您可以为每个功能选择的模型。

<a id="code-suggestions"></a>

代码建议

| 模型 | 代码生成 | 代码补全 |
|------------|-----------------|-----------------|
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< no >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< no >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< no >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< no >}} |

<a id="gitlab-duo-non-agentic-chat"></a>

极狐GitLab Duo 非 Agentic 聊天

| 模型 | 通用聊天 | 代码解释 | 测试生成 | 重构代码 | 修复代码 | 根因分析 |
|------------|--------------|------------------|-----------------|---------------|----------|---------------------|
| 国内 SOTA 模型 | {{< yes >}} | {{< no >}} | | | {{< no >}} | |
| 国内 SOTA 模型 | {{< no >}} | | | {{< no >}} | | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |  |

<a id="gitlab-duo-for-merge-requests"></a>

极狐GitLab Duo 合并请求功能

| 模型 | 合并提交信息生成 | 合并请求摘要 | 代码审查摘要 | 代码审查 |
|------------|--------------------------------|------------------------|---------------------|-------------|
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |

<a id="other-gitlab-duo-features"></a>

其他极狐GitLab Duo 功能

| 模型 | 漏洞解释 | 漏洞修复 | 极狐GitLab Duo for CLI | 讨论摘要 |
|------------|----------------------------|--------------------------|-------------------|---------------------|
| 国内 SOTA 模型 | {{< yes >}} | {{< no >}} | {{< yes >}} | {{< no >}} |
| 国内 SOTA 模型 | {{< no >}} | | {{< yes >}} | {{< no >}} |
| 国内 SOTA 模型 |  | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} |  | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 国内 SOTA 模型 | {{< yes >}} |  |  | {{< yes >}} |

<a id="select-a-model-for-a-feature"></a>

为功能选择模型

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.1 中为顶级群组引入，带有一个 [功能标志](../../administration/feature_flags/_index.md) 名为 `ai_model_switching`。默认禁用。
- 在极狐GitLab 18.4 中更改为测试版。
- 在极狐GitLab 18.4 中启用。
- 在极狐GitLab 18.5 中 GA。功能标志 `ai_model_switching` 启用。
- 功能标志 `ai_model_switching` 在极狐GitLab 18.7 中移除。

{{< /history >}}

您可以在顶级群组中为功能选择模型。您选择的模型将应用于该功能的所有子群组和项目。

先决条件：

- 您拥有该群组的所有者角色。
- 您为其选择模型的群组是顶级群组。
- 在极狐GitLab 18.3 或更高版本中，如果您属于多个极狐GitLab Duo 命名空间，您必须 [设置默认命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

要为功能选择模型：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **配置功能**。
1. 对于您要配置的功能，从下拉列表中选择一个模型。
1. 可选。要将模型应用于该部分中的所有功能，请选择 **应用到所有**。

<a id="troubleshooting"></a>

故障排除

当选择默认模型以外的模型时，您可能会遇到以下问题。

<a id="model-is-not-available"></a>

模型不可用

如果您为 极狐GitLab Duo AI 原生功能使用默认极狐GitLab 模型，极狐GitLab 可能会在不通知用户的情况下更改默认模型，以保持最佳性能和可靠性。

如果您为 极狐GitLab Duo AI 原生功能选择了特定模型，而该模型不可用，则没有自动回退。使用此模型的功能将不可用。

<a id="no-default-gitlab-duo-namespace"></a>

没有默认的极狐GitLab Duo 命名空间

当使用带有选定模型的 极狐GitLab Duo 功能时，您可能会收到一个错误，指示您需要设置默认的极狐GitLab Duo 命名空间。

当您属于多个极狐GitLab Duo 命名空间，或者在本地处理一个没有配置极狐GitLab 远程的项目时，会出现此问题。

要解决此问题，请 [设置默认的极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。