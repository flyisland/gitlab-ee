---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Autocomplete characters in Markdown fields.
title: 自动补全字符
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

自动补全字符提供了一种在 Markdown 字段中快速输入字段值的方式。当你在 Markdown 字段中开始输入一个词，并以下列字符之一开头时，极狐GitLab 会根据一组匹配值逐步进行自动补全。字符串匹配不区分大小写。

| 字符 | 自动补全对象    | 显示的相关匹配数 |
| ---- | --------------- | ---------------- |
| `~`  | 标签            | 20               |
| `%`  | 里程碑          | 5                |
| `@`  | 用户和群组      | 10               |
| `!`  | 合并请求        | 5                |
| `&`  | 史诗            | 5                |
| `$`  | 代码片段        | 5                |
| `:`  | 表情符号        | 5                |
| `/`  | 快速操作        | 100              |
| `*iteration:` | 迭代 | 5 |

当你从列表中选择一个项目时，该值会被输入到字段中。你输入的字符越多，匹配就越精确。

你可以结合[快速操作](quick_actions.md)使用自动补全字符。

<a id="user-autocomplete"></a>

## 用户自动补全

假设你的极狐GitLab 实例包含以下用户：

<!-- vale gitlab_base.Spelling = NO -->

| 用户名          | 姓名 |
| :-------------- | :--- |
| alessandra      | Rosy Grant |
| lawrence.white  | Kelsey Kerluke |
| leanna          | Rosemarie Rogahn |
| logan_gutkowski | Lee Wuckert |
| shelba          | Josefine Haley |

<!-- vale gitlab_base.Spelling = YES -->

用户自动补全优先排序其用户名或姓名以你的查询内容开头的用户。例如，输入 `@lea` 会首先显示 `leanna`，输入 `@ros` 会首先显示 `Rosemarie Rogahn` 和 `Rosy Grant`。之后，自动补全菜单中会显示任何包含你的查询内容的用户名或姓名。

你还可以在完整的姓名中搜索以找到用户。例如，要找到 `Rosy Grant`，即使她的用户名是 `alessandra`，你可以输入不带空格的全名，如 `@rosygrant`。