---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Jira 议题管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以[直接在极狐GitLab 中管理 Jira 议题](configure.md)。
然后你可以在极狐GitLab 提交和合并请求中通过 ID 引用 Jira 议题。
Jira 议题 ID 必须为大写。

<a id="cross-reference-gitlab-activity-and-jira-issues"></a>

## 交叉引用极狐GitLab 活动与 Jira 议题

通过此集成，你可以在极狐GitLab 议题、合并请求和 Git 中工作时交叉引用 Jira 议题。
当你在极狐GitLab 议题、合并请求、评论或提交中提及 Jira 议题时：

- 极狐GitLab 会从极狐GitLab 中的提及处链接到 Jira 议题。
- 极狐GitLab 会在 Jira 议题中添加一条格式化的评论，链接回极狐GitLab 中的议题、合并请求或提交。

例如，当此提交引用了 `GIT-1` Jira 议题时：

```shell
git commit -m "GIT-1 这是一个测试提交"
```

极狐GitLab 会向该 Jira 议题添加：

- **网页链接** 部分中的一个引用。
- **活动** 部分中一条遵循以下格式的评论：

  ```plaintext
  USER 在 [PROJECT_NAME|COMMENTLINK] 的 RESOURCE_NAME 中提及了此议题：
  ENTITY_TITLE
  ```

  - `USER`：提及 Jira 议题的用户名称，并附有指向其极狐GitLab 用户资料的链接。
  - `RESOURCE_NAME`：引用了 Jira 议题的资源类型（例如，极狐GitLab 提交、议题或合并请求）。
  - `PROJECT_NAME`：极狐GitLab 项目名称。
  - `COMMENTLINK`：指向提及 Jira 议题位置的链接。
  - `ENTITY_TITLE`：极狐GitLab 提交（第一行）、议题或合并请求的标题。

每个极狐GitLab 议题、合并请求或提交在 Jira 中仅显示一个交叉引用。
例如，在极狐GitLab 合并请求上引用 Jira 议题的多条评论，
在 Jira 中只会创建一个指向该合并请求的交叉引用。

你可以[禁用议题评论](#disable-comments-on-jira-issues)。

<a id="require-associated-jira-issue-for-merge-requests-to-be-merged"></a>

### 要求合并请求关联 Jira 议题才能合并

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过此集成，你可以阻止未引用 Jira 议题的合并请求被合并。
要启用此功能：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并检查** 部分，选择 **要求关联 Jira 议题**。
1. 选择 **保存**。

启用此功能后，未引用关联 Jira 议题的合并请求将无法合并。合并请求会显示消息
**要合并，必须在标题或描述中提及 Jira 议题关键字**。

<a id="customize-jira-issue-matching-in-gitlab"></a>

## 自定义极狐GitLab 中的 Jira 议题匹配

{{< history >}}

- 在极狐GitLab 15.10 中引入。

{{< /history >}}

你可以通过定义以下内容来配置极狐GitLab 匹配 Jira 议题关键字的自定义规则：

- [一个正则表达式模式](#define-a-regex-pattern)
- [一个前缀](#define-a-prefix)

当你未配置自定义规则时，将使用
[默认行为](https://jihulab.com/gitlab-cn/gitlab/-/blob/9b062706ac6203f0fa897a9baf5c8e9be1876c74/lib/gitlab/regex.rb#L245)。

<a id="define-a-regex-pattern"></a>

### 定义正则表达式模式

{{< history >}}

- 集成名称在极狐GitLab 17.6 中更新为 **Jira 议题**。

{{< /history >}}

你可以使用正则表达式（regex）来匹配 Jira 议题关键字。
正则表达式模式必须遵循 [RE2 语法](https://github.com/google/re2/wiki/Syntax)。

要为 Jira 议题关键字定义正则表达式模式：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Jira 议题**。
1. 转到 **Jira 议题匹配** 部分。
1. 在 **Jira 议题正则表达式** 文本框中，输入正则表达式模式。
1. 选择 **保存更改**。

更多信息，请参阅
[Atlassian 文档](https://confluence.atlassian.com/adminjiraserver073/changing-the-project-key-format-861253229.html)。

<a id="define-a-prefix"></a>

### 定义前缀

{{< history >}}

- 集成名称在极狐GitLab 17.6 中更新为 **Jira 议题**。

{{< /history >}}

你可以使用前缀来匹配 Jira 议题关键字。
例如，如果你的 Jira 议题关键字是 `ALPHA-1`，并且你定义了 `JIRA#` 前缀，
极狐GitLab 会匹配 `JIRA#ALPHA-1` 而不是 `ALPHA-1`。

要为 Jira 议题关键字定义前缀：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Jira 议题**。
1. 转到 **Jira 议题匹配** 部分。
1. 在 **Jira 议题前缀** 文本框中，输入前缀。
1. 选择 **保存更改**。

<a id="close-jira-issues-in-gitlab"></a>

## 在极狐GitLab 中关闭 Jira 议题

如果你已配置极狐GitLab 转换 ID，则可以直接从极狐GitLab 关闭 Jira 议题。
在提交或合并请求中使用触发词后跟 Jira 议题 ID。
当你推送包含触发词和 Jira 议题 ID 的提交时，极狐GitLab 会：

1. 在提及的 Jira 议题中添加评论。
1. 关闭 Jira 议题。如果 Jira 议题已有解决结果，则不会进行转换。

例如，使用以下任一触发词来关闭 Jira 议题 `PROJECT-1`：

- `Resolves PROJECT-1`
- `Closes PROJECT-1`
- `Fixes PROJECT-1`

提交或合并请求必须针对你项目的[默认分支](../../user/project/repository/branches/default.md)。
你可以在[项目设置](../../user/project/repository/branches/default.md#change-the-default-branch-name-for-a-project)中更改项目的默认分支。

当你的分支名称与 Jira 议题 ID 匹配时，`Closes <JIRA-ID>` 会自动追加到你现有的合并请求模板中。
如果你不想关闭议题，请[禁用自动关闭议题](../../user/project/issues/managing_issues.md#disable-automatic-issue-closing)。

<a id="use-case-for-closing-issues"></a>

### 关闭议题的用例

考虑以下示例：

1. 用户创建了 Jira 议题 `PROJECT-7` 以请求一个新功能。
1. 你在极狐GitLab 中创建了一个合并请求来构建所请求的功能。
1. 在合并请求中，你添加了议题关闭触发词 `Closes PROJECT-7`。
1. 当合并请求被合并时：
   - 极狐GitLab 会为你关闭 Jira 议题。
   - 极狐GitLab 会向 Jira 添加一条格式化的评论，链接回解决了该议题的提交。你可以[禁用评论](#disable-comments-on-jira-issues)。

<a id="automatic-issue-transitions"></a>

## 自动议题转换

当你配置自动议题转换时，你可以将引用的 Jira 议题转换到下一个类别为 **完成** 的可用状态。要配置此设置：

1. 参考[配置极狐GitLab](configure.md) 说明。
1. 选中 **启用 Jira 转换** 复选框。
1. 选择 **移至完成** 选项。

<a id="custom-issue-transitions"></a>

## 自定义议题转换

对于高级工作流，你可以指定自定义 Jira 转换 ID：

1. 根据你的 Jira 订阅状态使用相应方法：

   - 对于 Jira Cloud 用户：通过在 **文本** 视图中编辑工作流来获取转换 ID。转换 ID 显示在 **转换** 列中。
   - 对于 Jira Server 用户：通过以下方式之一获取转换 ID：
     - 使用 API，例如请求 `https://yourcompany.atlassian.net/rest/api/2/issue/ISSUE-123/transitions`，使用处于适当“开放”状态的议题。
     - 将鼠标悬停在所需转换的链接上，并查找 URL 中的 **action** 参数。

   转换 ID 可能因工作流而异（例如，错误与故事），即使你要更改到的状态相同。
1. 参考[配置极狐GitLab](configure.md) 说明。
1. 选择 **启用 Jira 转换** 设置。
1. 选择 **自定义转换** 选项。
1. 在文本字段中输入你的转换 ID。如果你插入多个转换 ID（以 `,` 或 `;` 分隔），议题将按照你指定的顺序依次移动到每个状态。如果某个转换失败，序列将中止。

<a id="disable-comments-on-jira-issues"></a>

## 禁用 Jira 议题评论

极狐GitLab 可以交叉链接源提交或合并请求与 Jira 议题，而无需向 Jira 议题添加评论：

1. 参考[配置极狐GitLab](configure.md) 说明。
1. 清除 **启用评论** 复选框。