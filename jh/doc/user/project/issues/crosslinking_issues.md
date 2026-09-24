---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 议题交叉链接
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

交叉链接在极狐GitLab 中创建议题之间的关系。
交叉链接：

- 连接相关议题，以便更好地跟踪和查看。
- 将议题与其相关的提交和合并请求链接起来。
- 通过提交信息、分支名称和描述创建引用。
- 跨项目和群组工作。
- 在每个议题的 **链接项** 部分显示关系。

你可以通过以下方式创建交叉链接：

- [提交信息](#from-commit-messages)
- [链接的议题](#from-linked-issues)
- [合并请求](#from-merge-requests)
- [分支名称](#from-branch-names)

<a id="from-commit-messages"></a>

## 从提交信息

每次在提交信息中提及议题时，你都在创建开发工作流两个阶段之间的关系：议题本身以及与该议题相关的第一个提交。

如果议题和你提交的代码在同一个项目中，请在提交信息中添加 `#xxx`，其中 `xxx` 是议题编号。

```shell
git commit -m "this is my commit message. Ref #xxx"
```

提交信息通常不能以 `#` 字符开头，因此你也可以使用替代的 `GL-xxx` 表示法：

```shell
git commit -m "GL-xxx: this is my commit message"
```

如果它们在不同的项目中但位于同一群组内，请在提交信息中添加 `projectname#xxx`。

```shell
git commit -m "this is my commit message. Ref projectname#xxx"
```

如果它们不在同一群组中，你可以添加议题的完整 URL（`https://jihulab.com/<username>/<projectname>/-/issues/<xxx>`）。

> [!note]
> 出于性能考虑，极狐GitLab 仅处理提交信息中的前 1,000 个完整 URL 进行自动链接。超出此限制的其他 URL 不会被转换为链接。

```shell
git commit -m "this is my commit message. Related to https://jihulab.com/<username>/<projectname>/-/issues/<xxx>"
```

当然，你可以将 `jihulab.com` 替换为你自己的极狐GitLab 实例的 URL。

将你的第一个提交链接到你的议题对于使用 [极狐GitLab 价值流分析](https://about.gitlab.com/solutions/value-stream-management/) 跟踪你的流程至关重要。
它度量了规划该议题实施所花费的时间，即从创建议题到进行第一次提交之间的时间。

<a id="from-linked-issues"></a>

## 从链接的议题

在合并请求和其他议题中提及已链接的议题，有助于你的团队成员和协作者了解存在关于同一主题的已开启议题。

在议题 `#222` 中提及议题 `#111` 时，议题 `#111` 也会在其 **动态** 提要中显示一条通知。也就是说，你只需提及一次关系，它就会在两个议题中都显示。在 [合并请求](#from-merge-requests) 中提及议题也同样有效。

当议题的动态提要被过滤为 **仅显示历史记录** 或 **显示所有动态** 时，交叉链接将显示为 `(用户名) 提及于议题 #(编号) (时间前)`。

<a id="from-merge-requests"></a>

## 从合并请求

在合并请求评论中提及议题的方式与 [链接的议题](#from-linked-issues) 完全相同。

当你在合并请求描述中提及议题时，它会 [将议题和合并请求链接在一起](#from-linked-issues)。此外，你还可以 [设置议题在合并请求合并时自动关闭](managing_issues.md#closing-issues-automatically)。

当议题的动态提要被过滤为 **仅显示历史记录** 或 **显示所有动态** 时，交叉链接将显示为 `(用户名) 提及于合并请求 !(编号) (时间前)`。

<a id="from-branch-names"></a>

## 从分支名称

当你在与议题相同的项目中创建分支，并且分支名称以议题编号开头，后跟一个连字符时，你创建的议题和 MR 会被链接起来。
更多信息，请参阅
[使用议题编号作为分支名称前缀](../repository/branches/_index.md#prefix-branch-names-with-a-number)。