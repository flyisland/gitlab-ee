---
stage: AI Platform
group: AI Core Infra
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解极狐GitLab Duo 可以访问哪些信息来提供建议，以及如何从代码评审上下文中排除敏感内容。
title: 极狐GitLab Duo 上下文感知
---

有多种信息可用来帮助极狐GitLab Duo 做出决策并提供建议。

信息可在以下情况下可用：

- 始终可用。
- 根据您所在的位置（当您导航时上下文会发生变化）。
- 被显式引用时。例如，您通过 URL、ID 或文件路径提及该信息。

<a id="always-available"></a>

## 始终可用

- 极狐GitLab 文档。
- 通用编程知识、最佳实践和语言特性。
- 您正在查看或编辑的文件中的内容，包括光标前后的代码。
- 在极狐GitLab UI 中使用 Chat 时，当前页面标题和 URL。
- `/refactor`、`/fix`、`/tests` 和 `/explain` 斜杠命令可以访问代码建议中最新的 Repository X-Ray 报告。

<a id="based-on-location"></a>

## 基于位置

当您打开以下任一资源时，极狐GitLab Duo 会了解它们。

- 您已告知 Chat 的文件，方式包括：
  - 提供直接的文件路径。
  - 在您的 IDE 中，包括使用 `/include` 命令。
- 文件中选中的代码。
- 议题（仅限极狐GitLab Duo Enterprise）。
- 史诗（仅限极狐GitLab Duo Enterprise）。
- [其他工作项类型](../work_items/_index.md#work-item-types)（仅限极狐GitLab Duo Enterprise）。

> [!note]
> 在 IDE 中，符合已知格式的密钥和敏感值会在发送到极狐GitLab Duo Chat 之前被遮盖。

在 UI 中，当您处于合并请求中时，极狐GitLab Duo 还会了解：

- 合并请求本身（仅限极狐GitLab Duo Enterprise）。
- 合并请求中的提交（仅限极狐GitLab Duo Enterprise）。
- 合并请求流水线的 CI/CD 作业（仅限极狐GitLab Duo Enterprise）。

<a id="when-referenced-explicitly"></a>

### 被显式引用时

所有基于您所在位置可用的资源，在您通过其 ID 或 URL 显式引用时也同样可用。

<a id="exclude-context-from-code-review"></a>

## 从代码评审中排除上下文

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Pro 或 Enterprise

{{< /details >}}

您可以排除代码评审用作上下文的项目内容。排除上下文以保护敏感信息，例如密码和配置文件。

要指定代码评审排除的内容：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 在**极狐GitLab Duo** 下，在**极狐GitLab Duo 上下文排除项**部分中，选择**管理排除项**。
1. 指定哪些项目文件和目录从极狐GitLab Duo 上下文中排除，然后选择**保存排除项**。
1. 可选。要删除现有排除项，请为相应的排除项选择**删除**（{{< icon name="remove" >}}）。
1. 选择**保存更改**。
