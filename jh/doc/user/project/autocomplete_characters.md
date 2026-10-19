---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Markdown 字段中的自动补全字符。
title: 自动补全字符
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

自动补全字符提供了一种在 Markdown 字段中快速输入字段值的方式。当您在 Markdown 字段中开始输入以以下某个字符开头的单词时，极狐GitLab 会根据一组匹配值逐步自动补全。字符串匹配不区分大小写。

| 字符 | 自动补全 | 显示的匹配项数量 |
| --------- | ---------------- | ---------------------- |
| `~`       | 标记           | 20                     |
| `%`       | 里程碑       | 5                      |
| `@`       | 用户和群组 | 10                     |
| `#`       | 议题           | 5                      |
| `!`       | 合并请求   | 5                      |
| `&`       | 史诗           | 5                      |
| `$`       | 代码片段           | 5                      |
| `:`       | 表情符号            | 5                      |
| `/`       | 快速操作    | 100                    |
| `*iteration:` | 迭代 | 5 |

当您从列表中选择某一项时，该值会输入到字段中。您输入的字符越多，匹配结果就越精确。

您可以将自动补全字符与[快速操作](quick_actions.md)结合使用。

<a id="user-autocomplete"></a>

## 用户自动补全

假设您的极狐GitLab 实例包含以下用户：

<!-- vale gitlab_base.Spelling = NO -->

| 用户名        | 姓名 |
| :-------------- | :--- |
| alessandra      | Rosy Grant |
| lawrence.white  | Kelsey Kerluke |
| leanna          | Rosemarie Rogahn |
| logan_gutkowski | Lee Wuckert |
| shelba          | Josefine Haley |

<!-- vale gitlab_base.Spelling = YES -->

用户自动补全会优先按用户名或姓名以您的查询内容开头的用户进行排序。例如，输入 `@lea` 会首先显示 `leanna`，输入 `@ros` 会首先显示 `Rosemarie Rogahn` 和 `Rosy Grant`。随后，自动补全菜单中会显示其他包含您查询内容的用户名或姓名。

您也可以搜索全名来查找用户。要查找 `Rosy Grant`，即使其用户名是 `alessandra`，您也可以输入不带空格的全名，例如 `@rosygrant`。
