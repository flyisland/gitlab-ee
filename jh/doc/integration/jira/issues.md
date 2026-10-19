---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 从极狐GitLab 提交、议题和合并请求中引用和链接 Jira 议题，并要求在合并前关联议题。
title: Jira 议题管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以[直接在极狐GitLab 中管理 Jira 议题](configure.md)。然后，您可以在极狐GitLab 提交和合并请求中通过 ID 引用 Jira 议题。Jira 议题 ID 必须使用大写字母。

<a id="cross-reference-gitlab-activity-and-jira-issues"></a>

## 交叉引用极狐GitLab 活动和 Jira 议题

通过此集成，您可以在极狐GitLab 议题、合并请求和 Git 中工作时交叉引用 Jira 议题。当您在极狐GitLab 议题、合并请求、评论或提交中提及 Jira 议题时：

- 极狐GitLab 会从极狐GitLab 中的提及处链接到该 Jira 议题。
- 极狐GitLab 会向该 Jira 议题添加一条格式化评论，链接回极狐GitLab 中的议题、合并请求或提交。

例如，当此提交引用 `GIT-1` Jira 议题时：

```shell
git commit -m "GIT-1 this is a test commit"
```

极狐GitLab 会向该 Jira 议题添加：

- **网页链接** 部分中的引用。
- **活动** 部分中一条遵循以下格式的评论：

  ```plaintext
  USER mentioned this issue in RESOURCE_NAME of [PROJECT_NAME|COMMENTLINK]:
  ENTITY_TITLE
  ```

  - `USER`：提及该 Jira 议题的用户的名称，并附有其极狐GitLab 用户个人资料的链接。
  - `RESOURCE_NAME`：引用该 Jira 议题的资源类型（例如极狐GitLab 提交、议题或合并请求）。
  - `PROJECT_NAME`：极狐GitLab 项目名称。
  - `COMMENTLINK`：指向提及该 Jira 议题位置的链接。
  - `ENTITY_TITLE`：极狐GitLab 提交（第一行）、议题或合并请求的标题。

每个极狐GitLab 议题、合并请求或提交在 Jira 中只会出现一个交叉引用。例如，极狐GitLab 合并请求上引用某个 Jira 议题的多条评论，在 Jira 中只会创建一条指回该合并请求的交叉引用。

您可以[禁用议题上的评论](#disable-comments-on-jira-issues)。

<a id="require-associated-jira-issue-for-merge-requests-to-be-merged"></a>

### 要求合并请求关联 Jira 议题才能合并

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过此集成，如果合并请求未引用 Jira 议题，您可以阻止其被合并。要开启此功能：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并检查**部分，选择**要求关联来自 Jira 的议题**。
1. 选择**保存**。

开启此功能后，未引用关联 Jira 议题的合并请求将无法合并。该合并请求会显示消息**要合并，必须在标题或描述中提及 Jira 议题键**。

<a id="customize-jira-issue-matching-in-gitlab"></a>

## 自定义极狐GitLab 中的 Jira 议题匹配

您可以通过定义以下内容，配置极狐GitLab 匹配 Jira 议题键的自定义规则：

- [正则表达式模式](#define-a-regex-pattern)
- [前缀](#define-a-prefix)

当您未配置自定义规则时，将使用[默认行为](https://gitlab.com/gitlab-org/gitlab/-/blob/9b062706ac6203f0fa897a9baf5c8e9be1876c74/lib/gitlab/regex.rb#L245)。

<a id="define-a-regex-pattern"></a>

### 定义正则表达式模式

您可以使用正则表达式（regex）来匹配 Jira 议题键。该正则表达式模式必须遵循 [RE2 语法](https://github.com/google/re2/wiki/Syntax)。

要为 Jira 议题键定义正则表达式模式：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Jira 议题**。
1. 转到 **Jira 议题匹配**部分。
1. 在 **Jira 议题正则表达式**文本框中，输入正则表达式模式。
1. 选择**保存更改**。

有关更多信息，请参阅
[Atlassian 文档](https://confluence.atlassian.com/adminjiraserver073/changing-the-project-key-format-861253229.html)。

<a id="define-a-prefix"></a>

### 定义前缀

您可以使用前缀来匹配 Jira 议题键。例如，如果您的 Jira 议题键是 `ALPHA-1`，并且您定义了 `JIRA#` 前缀，极狐GitLab 会匹配 `JIRA#ALPHA-1`，而不是 `ALPHA-1`。

要为 Jira 议题键定义前缀：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Jira 议题**。
1. 转到 **Jira 议题匹配**部分。
1. 在 **Jira 议题前缀**文本框中，输入前缀。
1. 选择**保存更改**。

<a id="close-jira-issues-in-gitlab"></a>

## 在极狐GitLab 中关闭 Jira 议题

如果您已配置极狐GitLab 转换 ID，您可以直接从极狐GitLab 关闭 Jira 议题。在提交或合并请求中使用触发词后跟 Jira 议题 ID。当您推送包含触发词和 Jira 议题 ID 的提交时，极狐GitLab 会：

1. 在提及的 Jira 议题中发表评论。
1. 关闭该 Jira 议题。如果该 Jira 议题有解决方案，则不会进行转换。

例如，使用以下任一触发词来关闭 Jira 议题 `PROJECT-1`：

- `Resolves PROJECT-1`
- `Closes PROJECT-1`
- `Fixes PROJECT-1`

提交或合并请求必须针对您项目的[默认分支](../../user/project/repository/branches/default.md)。您可以在[项目设置](../../user/project/repository/branches/default.md#change-the-default-branch-name-for-a-project)中更改项目的默认分支。

当您的分支名称与 Jira 议题 ID 匹配时，`Closes <JIRA-ID>` 会自动追加到您现有的合并请求模板中。如果您不想关闭该议题，请[禁用自动关闭议题](../../user/project/issues/managing_issues.md#disable-automatic-issue-closing)。

<a id="use-case-for-closing-issues"></a>

### 关闭议题的用例

请考虑以下示例：

1. 用户创建 Jira 议题 `PROJECT-7` 以请求新功能。
1. 您在极狐GitLab 中创建一个合并请求来构建所请求的功能。
1. 在该合并请求中，您添加议题关闭触发词 `Closes PROJECT-7`。
1. 当该合并请求被合并时：
   - 极狐GitLab 会为您关闭该 Jira 议题。
   - 极狐GitLab 会向 Jira 添加一条格式化评论，链接回解决该议题的提交。
     您可以[禁用评论](#disable-comments-on-jira-issues)。

<a id="automatic-issue-transitions"></a>

## 自动议题转换

当您配置自动议题转换时，您可以将引用的 Jira 议题转换为下一个类别为 **完成** 的可用状态。要配置此设置：

1. 参阅[配置极狐GitLab](configure.md) 说明。
1. 选中**启用 Jira 转换**复选框。
1. 选择**移至完成**。

<a id="custom-issue-transitions"></a>

## 自定义议题转换

对于高级工作流，您可以指定自定义 Jira 转换 ID：

1. 根据您的 Jira 订阅状态使用相应方法：

   - 对于 Jira Cloud 用户：通过在 **文本** 视图中编辑工作流来获取转换 ID。转换 ID 会显示在 **转换** 列中。
   - 对于 Jira Server 用户：通过以下任一方式获取转换 ID：
     - 使用 API，发送类似 `https://yourcompany.atlassian.net/rest/api/2/issue/ISSUE-123/transitions`的请求，
       并使用处于相应“打开”状态的议题。
     - 将鼠标悬停在所需转换的链接上，并在 URL 中查找
       **action** 参数。

   即使您要更改到的状态相同，转换 ID 也可能因工作流而异（例如，bug 而非 story）。

1. 参阅[配置极狐GitLab](configure.md) 说明。
1. 选择**启用 Jira 转换**设置。
1. 选择**自定义转换**。
1. 在文本字段中输入您的转换 ID。如果您插入多个转换 ID
   （以 `,` 或 `;` 分隔），议题会按您指定的顺序依次移动到每个状态。如果某个转换失败，该序列将中止。

<a id="disable-comments-on-jira-issues"></a>

## 禁用 Jira 议题上的评论

极狐GitLab 可以将源提交或合并请求与 Jira 议题交叉链接，而无需向该 Jira 议题添加评论：

1. 参阅[配置极狐GitLab](configure.md) 说明。
1. 清除**启用评论**复选框。
