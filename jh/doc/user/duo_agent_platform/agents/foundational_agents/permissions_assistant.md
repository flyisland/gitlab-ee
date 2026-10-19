---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 权限助手
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

权限助手是一个极狐GitLab Duo Agent，可帮助您在创建个人访问令牌时选择正确的
[细粒度权限](../../../../auth/tokens/fine_grained_access_tokens.md)。

描述您需要令牌执行的操作，权限助手会在创建表单上选择相应的权限。您可以提出后续问题或优化请求，
直到所选权限符合您的需求。

<a id="prerequisites"></a>

## 先决条件

- 满足 [极狐GitLab Duo Agent Platform 的先决条件](../../_index.md#prerequisites)。
- 已[启用内置 Agent](_index.md#turn-foundational-agents-on-or-off)。
- 已启用细粒度个人访问令牌。此功能由
  `granular_personal_access_tokens` 功能标志控制，该标志默认启用。

<a id="use-the-permissions-assistant"></a>

## 使用权限助手

权限助手在极狐GitLab UI 的细粒度个人访问令牌创建页面中可用。

要使用权限助手：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 从 **生成令牌** 下拉列表中，选择 **细粒度令牌**。
1. 选择 **使用 Duo 添加权限**。

   此时会打开一个 Duo Chat 面板，并预先选中权限助手。
1. 描述您需要令牌执行的操作，或选择其中一个建议提示。

   权限助手会在表单上选择相应的权限。
1. 检查所选权限，并在需要时优化您的请求。
1. 填写剩余的令牌字段，然后选择 **生成令牌**。

<a id="tips-for-best-results"></a>

### 获得最佳结果的提示

- 具体描述您的使用场景。例如，“我需要在单个项目中读取议题并创建合并请求”比“我需要 API 访问权限”效果更好。
- 如果初始选择过于宽泛或过于狭窄，请要求调整。
- 如果您不确定如何描述需求，可以使用建议提示作为起点。
- 建议会应用于相关的访问级别（群组和项目、用户或全局），因此当您的请求跨越多个部分时，同一权限可以在多个部分中添加。

<a id="example-prompts"></a>

## 示例提示

- “我想通过 API 读取和写入代码仓库。”
- “我需要管理 CI/CD 流水线并读取作业日志。”
- “我想自动化议题和合并请求管理。”
- “我需要项目和群组的只读访问权限。”
- “我想读取所有代码片段，而不仅仅是自己的。”
