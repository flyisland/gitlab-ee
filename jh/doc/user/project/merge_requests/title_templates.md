---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use merge request title templates to set a default title format for new merge requests in your project.
title: 合并请求标题模板
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.11 中引入，带有一个名为 `mr_default_title_template` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。此功能处于[测试版](../../../policy/development_stages_support.md#beta)。

{{< /history >}}

{{< alert type="flag" >}}

此功能的可用性由功能标志控制。
更多信息，请参阅历史。
此功能仅供测试，尚未准备好在生产环境中使用。

{{< /alert >}}

合并请求标题模板定义了项目中新合并请求的默认标题。
使用模板可以统一团队中合并请求的命名约定。

模板支持变量，这些变量会展开为值，例如源分支名称或首次提交消息。
用户可以在创建合并请求之前编辑标题。

<a id="configure-a-merge-request-title-template"></a>

## 配置合并请求标题模板

前置条件：

- 你必须至少具有项目的维护者角色。

要配置合并请求标题模板：

1. 在左侧边栏，选择**搜索或跳转到**并找到你的项目。
1. 选择**设置** > **合并请求**。
1. 滚动到**合并请求标题模板**。
1. 输入使用静态文本和[支持的变量](#supported-variables)的模板。
   模板限制为 100 个字符。
1. 选择**保存更改**。

要删除模板并恢复默认行为，请清空模板字段并选择**保存更改**。

<a id="supported-variables"></a>

## 支持的变量

标题模板支持以下变量：

| 变量                   | 描述                                                                                                     | 输出示例         |
|------------------------|----------------------------------------------------------------------------------------------------------|------------------|
| `%{source_branch}`     | 源分支的名称。                                                                                           | `my-feature-branch` |
| `%{target_branch}`     | 目标分支的名称。                                                                                         | `main`           |
| `%{title_from_branch}` | 源分支名称转换为人类可读的格式。连字符和下划线被替换为空格。                                             | `My feature branch` |
| `%{first_commit_title}` | 合并请求中第一个提交的标题（第一行）。                                                                   | `Update README.md` |
| `%{issue_id}`           | 通过源分支名称链接的议题的 IID（例如 `123` 来自 `123-fix-bug`）。如果未检测到议题，则为空。              | `123`            |
| `%{issue_title}`        | 通过源分支名称链接的议题的标题。如果未检测到议题，则为空。                                               | `Fix login bug`  |

<a id="template-examples"></a>

## 模板示例

| 模板                                       | 结果                                 |
|--------------------------------------------|--------------------------------------|
| `%{source_branch}`                         | `my-feature-branch`                  |
| `%{title_from_branch}`                     | `My feature branch`                  |
| `%{first_commit_title}`                    | `Update README.md`                   |
| `Draft: %{title_from_branch}`              | `Draft: My feature branch`           |
| `[%{source_branch}] %{first_commit_title}` | `[my-feature-branch] Update README.md` |
| `Resolve %{issue_id} "%{issue_title}"`     | `Resolve 123 "Fix login bug"`        |

<a id="title-template-assignment"></a>

## 标题模板分配

当你创建合并请求时，极狐GitLab 按以下顺序分配标题：

1. 如果你提供了标题，极狐GitLab 将使用它。
1. 如果配置了标题模板，极狐GitLab 将使用展开后的模板。
1. 如果未设置模板，极狐GitLab 将使用[默认标题行为](#default-title-behavior)。

<a id="default-title-behavior"></a>

## 默认标题行为

当没有配置标题模板且你未提供标题时，极狐GitLab 将按以下顺序检查这些条件来生成标题：

1. 如果合并请求只有一个提交，则使用提交标题。
1. 如果合并请求有多个提交，则使用带有多行提交消息的第一个提交的标题。
1. 如果源分支名称以议题 IID 开头，后跟连字符，例如 `123-fix-typo`，则标题为 `Resolve "<your_issue_title>"`。
1. 否则，为源分支名称，并将连字符和下划线替换为空格。

如果合并请求没有提交，或者你将其标记为草稿，极狐GitLab 会在标题前面加上 `Draft:`。

<a id="related-topics"></a>

## 相关主题

- [提交消息模板](commit_templates.md)
- [创建合并请求](creating_merge_requests.md)