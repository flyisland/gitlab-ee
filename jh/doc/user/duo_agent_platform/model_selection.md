---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure large language models for GitLab Duo features.
title: Agent Platform AI 模型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

每个 极狐GitLab Duo 功能都使用默认模型。极狐GitLab 可能会更新默认模型以优化性能。对于某些功能，你可以选择其他模型，所选模型会持续生效，直到你更改它。

<a id="default-models"></a>

## 默认模型

下表列出了 Agent Platform 中每个功能的默认模型。

| 功能 | 模型 |
|-------|--------------|
| 极狐GitLab Duo Agentic Chat | MiniMax-M3  |
| Code Review Flow | GLM-5.2   |
| 所有其他 agent | DeepSeek-V4-Pro  |

<a id="supported-models"></a>

## 支持的模型

下表列出了你可以在 Agent 平台中为功能选择的模型。
|  模型                |  极狐GitLab Duo Agentic Chat  |  极狐Code Review Flow and Security Review Flow  |  所有其他 agents
|----------------------|------------------------------|------------------------------------------------|--------------------|
|  DeepSeek-V4-Pro     |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  DeepSeek-V4-Flash   |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  GLM-5.1             |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  GLM-5.2             |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  Qwen3.6-plus        |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  Qwen3.7-max         |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  Qwen2.5-coder-base  |  {{< no >}}                  |  {{< no >}}                                    |  {{< no >}}        |
|  MiniMax-M3          |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  Kimi-K2.6           |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |
|  Kimi-K3             |  {{< yes >}}                 |  {{< no >}}                                    |  {{< yes >}}       |
|  MIMO-V2.5-PRO       |  {{< yes >}}                 |  {{< yes >}}                                   |  {{< yes >}}       |

**脚注**:

1. 该模型受到有限的供应商端数据保留的限制。

<a id="select-a-model-for-a-feature"></a>

## 为功能选择模型

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.1 中为顶级群组引入，使用功能标志 `ai_model_switching`。默认禁用。
- 在 极狐GitLab 18.4 中更改为测试版。
- 在 极狐GitLab 18.4 中启用。
- 在 极狐GitLab 18.4 中为 极狐GitLab Duo Agent Platform 引入了模型选择，使用功能标志 `duo_agent_platform_model_selection`。默认禁用。
- 在 极狐GitLab 18.5 中 GA。功能标志 `ai_model_switching` 已启用。
- 功能标志 `duo_agent_platform_model_selection` 在 极狐GitLab 18.6 中启用。
- 功能标志 `ai_model_switching` 在 极狐GitLab 18.7 中移除。
- 功能标志 `duo_agent_platform_model_selection` 在 极狐GitLab 18.9 中移除。

{{< /history >}}

你可以在顶级群组中为功能选择模型。你选择的模型将应用于该功能在各级子群组和项目中的使用。

前提条件：

- 你拥有该群组的所有者角色。
- 你选择模型的群组必须是顶级群组。
- 在 极狐GitLab 18.3 或更高版本中，如果你属于多个 极狐GitLab Duo 命名空间，你必须设置一个默认命名空间。

要为功能选择模型：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **配置功能**。
1. 转到 **极狐GitLab Duo Agent Platform** 部分。
1. 从下拉列表中选择一个模型。
1. 可选。要将该模型应用到该部分的所有功能，请选择 **应用到所有**。

在 IDE 中，只有当连接类型设置为 WebSocket 时，才会应用为 极狐GitLab Duo Agentic Chat 选择的模型。

要为 极狐GitLab Duo CLI 指定模型，请参见选择模型。

<a id="troubleshooting"></a>

## 故障排除

当选择非默认模型时，你可能会遇到以下问题。

<a id="model-is-not-available"></a>

### 模型不可用

如果你对 极狐GitLab Duo AI 原生功能使用默认的 极狐GitLab 模型，极狐GitLab 可能会在不通知用户的情况下更改默认模型，以保持最佳性能和可靠性。

如果你为 极狐GitLab Duo AI 原生功能选择了特定模型，但该模型不可用，则不会自动回退。使用该模型的功能将不可用。

<a id="no-default-gitlab-duo-namespace"></a>

### 没有默认的 极狐GitLab Duo 命名空间

使用选定了模型的 极狐GitLab Duo 功能时，你可能会收到一条错误信息，提示你需要设置一个默认的 极狐GitLab Duo 命名空间。

如果你属于多个 极狐GitLab Duo 命名空间，或者在本地处理一个未配置 极狐GitLab 远程仓库的项目，就会出现此问题。

要解决此问题，请设置默认的 极狐GitLab Duo 命名空间。