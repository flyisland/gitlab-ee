---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用合并请求标题模板，为项目中的新合并请求设置默认标题格式。
title: 合并请求标题模板
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

合并请求标题模板用于定义项目中新合并请求的默认标题。使用模板可以统一团队内的合并请求命名规范。

模板支持变量，这些变量会展开为源分支名称或首个提交信息之类的值。用户可以在创建合并请求之前编辑标题。

<a id="configure-a-merge-request-title-template"></a>

## 配置合并请求标题模板

先决条件：

- 您必须至少拥有该项目的维护者角色。

要配置合并请求标题模板：

1. 在左侧边栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 选择**设置** > **合并请求**。
1. 滚动到**合并请求标题模板**。
1. 使用静态文本和[支持的变量](#supported-variables)输入模板。
   模板长度限制为 100 个字符。
1. 选择**保存更改**。

要移除模板并恢复默认行为，请清空模板字段，然后选择**保存更改**。

<a id="supported-variables"></a>

## 支持的变量

标题模板支持以下变量：

| 变量               | 描述                                                                                                    | 输出示例 |
|------------------------|----------------------------------------------------------------------------------------------------------------|----------------|
| `%{source_branch}`     | 源分支的名称。                                                                                 | `my-feature-branch` |
| `%{target_branch}`     | 目标分支的名称。                                                                                 | `main`         |
| `%{title_from_branch}` | 转换为人类可读格式的源分支名称。连字符和下划线会替换为空格。 | `My feature branch` |
| `%{first_commit_title}` | 合并请求中首个提交的主题（第一行）。                                            | `Update README.md` |
| `%{issue_id}`           | 通过源分支名称关联的议题 IID（例如，从 `123-fix-bug`中提取的 `123`）。如果未检测到议题，则为空。 | `123` |
| `%{issue_title}`        | 通过源分支名称关联的议题标题。如果未检测到议题，则为空。                   | `Fix login bug` |

<a id="template-examples"></a>

## 模板示例

| 模板                                          | 结果 |
|---------------------------------------------------|--------|
| `%{source_branch}`                                | `my-feature-branch` |
| `%{title_from_branch}`                            | `My feature branch` |
| `%{first_commit_title}`                           | `Update README.md` |
| `Draft: %{title_from_branch}`                     | `Draft: My feature branch` |
| `[%{source_branch}] %{first_commit_title}`        | `[my-feature-branch] Update README.md` |
| `Resolve %{issue_id} "%{issue_title}"`            | `Resolve 123 "Fix login bug"` |

<a id="title-template-assignment"></a>

## 标题模板的分配

当您创建合并请求时，极狐GitLab 按以下顺序分配标题：

1. 如果您提供了标题，极狐GitLab 会使用该标题。
1. 如果配置了标题模板，极狐GitLab 会使用展开后的模板。
1. 如果未设置模板，极狐GitLab 会使用[默认标题行为](#default-title-behavior)。

<a id="default-title-behavior"></a>

## 默认标题行为

当未配置标题模板且您未提供标题时，极狐GitLab 会按顺序检查以下条件来生成标题：

1. 如果合并请求只有一个提交，则使用该提交的标题。
1. 如果合并请求有多个提交，则使用首个带多行提交信息的提交的标题。
1. 如果源分支名称以议题 IID 后跟连字符开头，例如
   `123-fix-typo`，则标题为 `Resolve "<your_issue_title>"`。
1. 否则，使用源分支名称，并将连字符和下划线替换为空格。

如果合并请求没有提交，或者您将其标记为草稿，极狐GitLab 会在标题前添加 `Draft:`。
