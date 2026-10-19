---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 语法选项
---

<!-- 请记住同时更新 `doc/user/search/exact_code_search.md` 中的表格。 -->

| 查询                | 精确匹配模式                                                                | 正则表达式模式                                                         |
|----------------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `"foo"`              | `"foo"`                                                                         | `foo`                                                                           |
| `foo file:^doc/`     | 在以 `/doc` 开头的目录中的 `foo`                                     | 在以 `/doc` 开头的目录中的 `foo`                                     |
| `"class foo"`        | `"class foo"`                                                                   | `class foo`                                                                     |
| `class foo`          | `class foo`                                                                     | `class` 和 `foo`                                                               |
| `foo or bar`         | `foo or bar`                                                                    | `foo` 或 `bar`                                                                  |
| `class Foo`          | `class Foo`（区分大小写）                                                    | `class`（不区分大小写）和 `Foo`（区分大小写）                           |
| `class Foo case:yes` | `class Foo`（区分大小写）                                                    | `class` 和 `Foo`（两者都区分大小写）                                         |
| `foo -bar`           | `foo -bar`                                                                      | `foo` 但不包含 `bar`                                                             |
| `foo file:js`        | 文件名中包含 `js` 的文件中的 `foo`                                     | 文件名中包含 `js` 的文件中的 `foo`                                     |
| `foo -file:test`     | 文件名中不包含 `test` 的文件中的 `foo`                            | 文件名中不包含 `test` 的文件中的 `foo`                            |
| `foo lang:ruby`      | Ruby 源代码中的 `foo`                                                       | Ruby 源代码中的 `foo`                                                       |
| `foo file:\.js$`     | 文件名以 `.js` 结尾的文件中的 `foo`                                   | 文件名以 `.js` 结尾的文件中的 `foo`                                   |
| `foo.*bar`           | `foo.*bar`（字面量）                                                            | `foo.*bar`（正则表达式）                                                 |
| `sym:foo`            | 类、方法和变量名等符号中的 `foo`                         | 类、方法和变量名等符号中的 `foo`                         |
| `test repo:(?i)foo`  | 项目名称中包含 `foo` 的项目中的 `test`（不区分大小写） | 项目名称中包含 `foo` 的项目中的 `test`（不区分大小写） |
