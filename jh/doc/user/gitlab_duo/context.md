---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn what information GitLab Duo can access to provide suggestions, and how to exclude sensitive content from Code Review context.
title: 极狐GitLab Duo 上下文感知
---

不同的信息可用于帮助极狐GitLab Duo 做出决策并提供建议。

信息可以：

- 始终可用。
- 基于您的位置（当您导航时上下文会发生变化）。
- 当明确引用时。例如，您通过 URL、ID 或文件路径提及信息。

<a id="always-available"></a>

## 始终可用

- 极狐GitLab 文档。
- 通用编程知识、最佳实践和语言特性。
- 您正在查看或编辑的文件中的内容，包括光标前后的代码。
- 在极狐GitLab UI 中使用 Chat 时，当前页面的标题和 URL。
- `/refactor`、`/fix`、`/tests` 和 `/explain` 斜杠命令可以访问来自代码建议的最新仓库 X-Ray 报告。

<a id="based-on-location"></a>

## 基于位置

当您打开以下任何资源时，极狐GitLab Duo 会了解它们。

- 您通过以下方式告知 Chat 的文件：
  - 提供直接文件路径。
  - 在您的 IDE 中，包括使用 `/include` 命令。
- 文件中选定的代码。
- 议题（仅限极狐GitLab Duo 企业版）。
- 史诗（仅限极狐GitLab Duo 企业版）。
- [其他工作项类型](../work_items/_index.md#work-item-types)（仅限极狐GitLab Duo 企业版）。

> [!note]
> 在 IDE 中，匹配已知格式的密钥和敏感值在发送到极狐GitLab Duo Chat 之前会被编辑。

在 UI 中，当您处于合并请求中时，极狐GitLab Duo 还会了解：

- 合并请求本身（仅限极狐GitLab Duo 企业版）。
- 合并请求中的提交（仅限极狐GitLab Duo 企业版）。
- 合并请求流水线的 CI/CD 作业（仅限极狐GitLab Duo 企业版）。

<a id="when-referenced-explicitly"></a>

### 当明确引用时

所有基于您的位置可用的资源，当您通过其 ID 或 URL 明确引用时也可用。

<a id="exclude-context-from-code-review"></a>

## 从代码审查中排除上下文

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo 专业版或企业版

{{< /details >}}
{{< history >}}

- 在极狐GitLab 18.2 [引入](../../administration/feature_flags/_index.md)，带有一个名为 `use_duo_context_exclusion` 的功能标志。默认禁用。
- 在极狐GitLab 18.4 中更改为测试版。
- 在极狐GitLab 18.5 中默认启用。

{{< /history >}}

您可以排除代码审查用作上下文的项目内容。
排除上下文以保护敏感信息，如密码和配置文件。

要指定代码审查排除的内容：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **极狐GitLab Duo** 下的 **极狐GitLab Duo 上下文排除项** 部分，选择 **管理排除项**。
1. 指定要从极狐GitLab Duo 上下文中排除的项目文件和目录，然后选择 **保存排除项**。
1. 可选。要删除现有排除项，请为相应的排除项选择 **删除** ({{< icon name="remove" >}})。
1. 选择 **保存更改**。