---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use commit message templates to ensure commits to your GitLab project contain all necessary information and are formatted correctly.
title: 提交消息模板
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 使用提交模板为特定类型的
提交创建默认消息。这些模板鼓励提交消息遵循特定格式，
或包含特定信息。用户在合并
合并请求时可以覆盖这些模板。

提交模板的语法类似于
[审查建议](reviews/suggestions.md#configure-the-commit-message-for-applied-suggestions) 的语法。

极狐GitLab Duo 还可以帮助您生成[合并提交消息](duo_in_merge_requests.md#generate-a-merge-commit-message)，
即使您未配置模板。

<a id="configure-commit-templates"></a>

## 配置提交模板

如果默认模板不包含您需要的信息，请更改项目的提交模板。

先决条件：

- 您必须对项目具有维护者或所有者角色。

操作步骤：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 根据要创建的模板类型，滚动到
   [**合并提交消息模板**](#default-template-for-merge-commits) 或
   [**压缩提交消息模板**](#default-template-for-squash-commits)。
1. 对于所需的提交类型，输入您的默认消息。您可以使用静态
   文本和[变量](#supported-variables-in-commit-templates)。每个模板
   限制为 500 个字符，但在用数据替换模板后，最终消息可能会更长。
1. 选择 **保存更改**。

<a id="default-template-for-merge-commits"></a>

## 合并提交的默认模板

合并提交消息的默认模板是：

```plaintext
Merge branch '%{source_branch}' into '%{target_branch}'

%{title}

%{issues}

See merge request %{reference}
```

<a id="default-template-for-squash-commits"></a>

## 压缩提交的默认模板

如果您已将项目配置为[在合并时压缩提交](squash_and_merge.md)，
极狐GitLab 会使用此模板创建压缩提交消息：

```plaintext
%{title}
```

<a id="supported-variables-in-commit-templates"></a>

## 提交模板中支持的变量

{{< history >}}

- `local_reference` 变量在极狐GitLab 16.1 中引入。
- `source_project_id` 变量在极狐GitLab 16.3 中引入。
- `merge_request_author` 变量在极狐GitLab 17.1 中引入。

{{< /history >}}

提交消息模板支持以下变量：

| 变量                                | 描述                                                                                                                                                                                                                                   | 输出示例                                                                                                                                                                                   |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `%{source_branch}`                      | 要合并的分支名称。                                                                                                                                                                                                              | `my-feature-branch`                                                                                                                                                                              |
| `%{target_branch}`                      | 要应用更改的分支名称。                                                                                                                                                                                               | `main`                                                                                                                                                                                           |
| `%{title}`                              | 合并请求的标题。                                                                                                                                                                                                                   | `Fix tests and translations`                                                                                                                                                                     |
| `%{issues}`                             | 包含短语 `Closes <议题编号>` 的字符串。包含合并请求描述中提及的所有与[议题关闭模式](../issues/managing_issues.md#closing-issues-automatically)匹配的议题。如果未提及任何议题，则为空。 | `Closes #465, #190 and #400`                                                                                                                                                                     |
| `%{description}`                        | 合并请求的描述。                                                                                                                                                                                                             | `Merge request description.`<br>`Can be multiline.`                                                                                                                                              |
| `%{reference}`                          | 合并请求的引用。                                                                                                                                                                                                               | `group-name/project-name!72359`                                                                                                                                                                  |
| `%{local_reference}`                    | 合并请求的本地引用。                                                                                                                                                                                                         | `!72359`                                                                                                                                                                                         |
| `%{source_project_id}`                  | 合并请求源项目的 ID。                                                                                                                                                                                                     | `123`                                                                                                                                                                                            |
| `%{first_commit}`                       | 合并请求差异中第一个提交的完整消息。                                                                                                                                                                                       | `Update README.md`                                                                                                                                                                               |
| `%{first_multiline_commit}`             | 第一个非合并提交且消息正文超过一行的提交的完整消息。如果所有提交都不是多行的，则为合并请求标题。                                                                                   | `Update README.md`<br><br>`Improved project description in readme file.`                                                                                                                         |
| `%{first_multiline_commit_description}` | 第一个非合并提交且消息正文超过一行的提交的描述（不含第一行/标题）。                                                                                                          | `Improved project description in readme file.`                                                                                                                                                   |
| `%{url}`                                | 合并请求的完整 URL。                                                                                                                                                                                                                | `https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/1`                                                                                                                                        |
| `%{reviewed_by}`                        | 以换行分隔的合并请求审查员列表，基于使用批量评论提交审查的用户，格式为 `Reviewed-by` Git 提交尾部。                                                                                 | `Reviewed-by: Sidney Jones <sjones@example.com>` <br> `Reviewed-by: Zhang Wei <zwei@example.com>`                                                                                                |
| `%{approved_by}`                        | 以换行分隔的合并请求批准者列表，格式为 `Approved-by` Git 提交尾部。                                                                                                                                              | `Approved-by: Sidney Jones <sjones@example.com>` <br> `Approved-by: Zhang Wei <zwei@example.com>`                                                                                                |
| `%{merged_by}`                          | 合并合并请求的用户。                                                                                                                                                                                                            | `Alex Garcia <agarcia@example.com>`                                                                                                                                                              |
| `%{merge_request_author}`               | 合并请求作者的姓名和电子邮件。                                                                                                                                                                                                   | `Zane Doe <zdoe@example.com>`                                                                                                                                                                    |
| `%{co_authored_by}`                     | 以 `Co-authored-by` Git 提交尾部格式列出的提交作者姓名和电子邮件。限于合并请求中最近 100 次提交的作者。                                                                                           | `Co-authored-by: Zane Doe <zdoe@example.com>` <br> `Co-authored-by: Blake Smith <bsmith@example.com>`                                                                                            |
| `%{all_commits}`                        | 合并请求中所有提交的消息。限于最近 100 次提交。跳过超过 100 KiB 的提交正文和合并提交消息。                                                                                          | `* Feature introduced` <br><br> `This commit implements feature` <br> `Changelog:added` <br><br> `* Bug fixed` <br><br> `* Documentation improved` <br><br>`This commit introduced better docs.` |

任何仅包含空变量的行都会被删除。如果删除的行前后均为空行，则前面的空行也会被删除。

在打开的合并请求上编辑提交消息后，极狐GitLab
会自动再次更新提交消息。
要将提交消息恢复为项目模板，请重新加载页面。