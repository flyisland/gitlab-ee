---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 内置 Agent
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

内置 Agent 是专门的 AI 助手，通过领域专属的专业知识和上下文感知能力扩展极狐GitLab Duo Chat 的功能。

与通用型极狐GitLab Duo Agent 不同，内置 Agent 理解其专业领域的独特工作流、框架和最佳实践。每个 Agent 都将极狐GitLab 功能的深入知识与角色专属的推理能力相结合，提供与从业者实际工作方式相符的针对性帮助。

内置 Agent 由极狐GitLab 构建和维护，并显示极狐GitLab 维护徽章 ({{< icon name="tanuki-verified" >}})。

<a id="prerequisites"></a>

## 先决条件

- 满足 [极狐GitLab Duo Agent Platform 的先决条件](../../_index.md#prerequisites)。
- 已[启用内置 Agent](#turn-foundational-agents-on-or-off)。

<a id="available-foundational-agents"></a>

## 可用的内置 Agent

以下内置 Agent 可在极狐GitLab UI、VS Code 和 JetBrains IDE 中使用。各 Agent 的适用版本因 Agent 而异。有关详细信息，请参阅每个 Agent 的页面。

| Agent | 描述 |
|-------|-------------|
| [CI 专家](ci_expert_agent.md) | 创建、调试和优化极狐GitLab CI/CD 流水线。 |
| [数据分析师](data_analyst.md) | 分析和可视化平台数据。 |
| [任务流创建器](flow_creator.md) | 从 Chat 为 AI 目录创建自定义任务流。 |
| [入门 Agent](onboarding_guide.md) | 采用极狐GitLab DevSecOps 平台，从首次导入代码仓库到安全和合规成熟度。 |
| [权限助手](permissions_assistant.md) | 为细粒度个人访问令牌选择正确的权限。 |
| [计划者](planner.md) | 获取产品管理和规划工作流方面的帮助。 |
| [安全分析师](security_analyst_agent.md) | 获取安全分析和漏洞管理方面的帮助。 |
| [支持助手](support_assistant.md) | 诊断和解决极狐GitLab 产品问题。 |

<a id="duplicate-an-agent"></a>

## 复制 Agent

要更改内置 Agent，请创建它的副本。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

要复制 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** > **探索**。
1. 选择 **AI 目录**，然后选择 **Agents** 选项卡。
1. 选择要复制的 Agent。
1. 在右上角，选择 **操作** ({{< icon name="ellipsis_v" >}}) > **复制**。
1. 在 **可见性与访问权限** 下：
   1. 从 **受管方** 下拉列表中，为 Agent 选择一个项目。
   1. 对于 **可见性**，选择 **私有** 或 **公开**。
1. 可选。编辑您要更改的任何字段。
1. 选择 **创建 Agent**。

将创建一个自定义 Agent。要使用它，您必须[启用它](../custom.md#enable-an-agent)。

<a id="turn-foundational-agents-on-or-off"></a>

## 启用或禁用内置 Agent

默认情况下，内置 Agent 处于启用状态。您可以为顶级群组（命名空间）或实例启用或禁用它们。

如果您默认禁用内置 Agent：

- 使用默认配置的内置 Agent（包括新发布的 Agent）将被禁用。
- 您仍然可以使用默认的极狐GitLab Duo Agent。

{{< tabs >}}

{{< tab title="For GitLab.com" >}}

先决条件：

- 您必须拥有该群组的所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **内置 Agent** 下，对于 **默认可用性**，选择以下选项之一：
   - **开启**
   - **关闭**
1. 在 **可用性设置** 下，对于每个 Agent，选择以下选项之一：
   - **开启**
   - **关闭**
   - **使用默认值（开启）** 或 **使用默认值（关闭）**
1. 选择 **保存更改**。

这些设置适用于：

- 将顶级群组作为[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)的用户。
- 没有默认命名空间，且访问属于顶级群组的命名空间的用户。

如果您为顶级群组禁用内置 Agent，则将该群组作为默认极狐GitLab Duo 命名空间的用户将无法在任何命名空间中访问内置 Agent。

{{< /tab >}}

{{< tab title="For an instance" >}}

先决条件：

- 您必须是管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **内置 Agent** 下，对于 **默认可用性**，选择以下选项之一：
   - **开启**
   - **关闭**
1. 在 **可用性设置** 下，对于每个 Agent，选择以下选项之一：
   - **开启**
   - **关闭**
   - **使用默认值（开启）** 或 **使用默认值（关闭）**
1. 选择 **保存更改**。

{{< /tab >}}

{{< /tabs >}}
