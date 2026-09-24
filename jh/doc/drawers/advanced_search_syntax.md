---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 语法选项
---

<!-- 同时不要忘记更新 `doc/user/search/advanced_search.md` 中的表格。 -->

| 语法              | 描述      | 示例 |
|---------------------|------------------|---------|
| `"`                 | 精确搜索     | [`"gem sidekiq"`](https://jihulab.com/search?group_id=9970&project_id=278964&scope=blobs&search=%22gem+sidekiq%22) |
| `~`                 | 模糊搜索     | [`J~ Doe`](https://jihulab.com/search?scope=users&search=j%7E+doe) |
| `\|`                | 或               | [`display \| banner`](https://jihulab.com/search?group_id=9970&project_id=278964&scope=blobs&search=display+%7C+banner) |
| `+`                 | 且              | [`display +banner`](https://jihulab.com/search?group_id=9970&project_id=278964&repository_ref=&scope=blobs&search=display+%2Bbanner&snippets=) |
| `-`                 | 排除          | [`display -banner`](https://jihulab.com/search?group_id=9970&project_id=278964&scope=blobs&search=display+-banner) |
| `*`                 | 部分          | [`bug error 50*`](https://jihulab.com/search?group_id=9970&project_id=278964&repository_ref=&scope=blobs&search=bug+error+50%2A&snippets=) |
| ` \ `               | 转义           | [`\*md`](https://jihulab.com/search?snippets=&scope=blobs&repository_ref=&search=%5C*md&group_id=9970&project_id=278964) |
| `#`                 | 议题 ID         | [`#23456`](https://jihulab.com/search?snippets=&scope=issues&repository_ref=&search=%2323456&group_id=9970&project_id=278964) |
| `!`                 | 合并请求 ID | [`!23456`](https://jihulab.com/search?snippets=&scope=merge_requests&repository_ref=&search=%2123456&group_id=9970&project_id=278964) |

<a id="code-search"></a>

## 代码搜索

| 语法       | 描述                                     | 示例 |
|--------------|-------------------------------------------------|---------|
| `filename:`  | 文件名                                        | [`filename:*spec.rb`](https://jihulab.com/search?snippets=&scope=blobs&repository_ref=&search=filename%3A*spec.rb&group_id=9970&project_id=278964) |
| `path:`      | 代码仓位置（完全匹配或部分匹配）   | [`path:spec/workers/`](https://jihulab.com/search?group_id=9970&project_id=278964&repository_ref=&scope=blobs&search=path%3Aspec%2Fworkers&snippets=) |
| `extension:` | 不带 `.` 的文件扩展名（仅精确匹配） | [`extension:js`](https://jihulab.com/search?group_id=9970&project_id=278964&repository_ref=&scope=blobs&search=extension%3Ajs&snippets=) |
| `blob:`      | Git 对象 ID（仅精确匹配）              | [`blob:998707*`](https://jihulab.com/search?snippets=false&scope=blobs&repository_ref=&search=blob%3A998707*&group_id=9970) |

<a id="examples"></a>

## 示例

| 查询                                              | 描述 |
|----------------------------------------------------|-------------|
| [`rails -filename:gemfile.lock`](https://jihulab.com/search?group_id=9970&project_id=278964&repository_ref=&scope=blobs&search=rails+-filename%3Agemfile.lock&snippets=) | 返回所有文件中除了 `gemfile.lock` 文件外的 `rails`。 |
| [`RSpec.describe Resolvers -*builder`](https://jihulab.com/search?group_id=9970&project_id=278964&scope=blobs&search=RSpec.describe+Resolvers+-*builder) | 返回不以 `builder` 开头的 `RSpec.describe Resolvers`。 |
| [`bug \| (display +banner)`](https://jihulab.com/search?snippets=&scope=issues&repository_ref=&search=bug+%7C+%28display+%2Bbanner%29&group_id=9970&project_id=278964) | 返回 `bug` 或同时包含 `display` 和 `banner` 的结果。 |
| [`helper -extension:yml -extension:js`](https://jihulab.com/search?group_id=9970&project_id=278964&repository_ref=&scope=blobs&search=helper+-extension%3Ayml+-extension%3Ajs&snippets=) | 返回所有文件中，除了扩展名为 `.yml` 或 `.js` 的文件外的 `helper`。 |
| [`helper path:lib/git`](https://jihulab.com/search?group_id=9970&project_id=278964&scope=blobs&search=helper+path%3Alib%2Fgit) | 返回所有路径为 `lib/git*` 的文件中的 `helper`（例如 `spec/lib/gitlab`）。 |