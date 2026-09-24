---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目模板 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 检索这些端点的项目特定版本：

- [Dockerfile 模板](templates/dockerfiles.md)
- [Gitignore 模板](templates/gitignores.md)
- [极狐GitLab CI/CD 配置模板](templates/gitlab_ci_ymls.md)
- [开源许可证模板](templates/licenses.md)
- [议题和合并请求模板](../user/project/description_templates.md)

它废弃了这些端点，这些端点计划在 API 第 5 版中移除。

除了整个实例通用的模板外，还可以从这个 API 端点获取项目特定的模板。

还支持[群组文件模板](../user/group/manage.md#group-file-templates)。

<a id="list-all-templates-of-a-particular-type"></a>

## 列出特定类型的所有模板

列出项目指定类型的所有模板。

```plaintext
GET /projects/:id/templates/:type
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `type` | 字符串 | 是 | 模板的类型。接受的值：`dockerfiles`、`gitignores`、`gitlab_ci_ymls`、`licenses`、`issues` 或 `merge_requests`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|--------|-------------|
| `key` | 字符串 | 模板的唯一标识符。 |
| `name` | 字符串 | 模板的人类可读名称。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/templates/licenses"
```

示例响应（许可证）：

```json
[
  {
    "key": "epl-1.0",
    "name": "Eclipse 公共许可证 1.0"
  },
  {
    "key": "lgpl-3.0",
    "name": "GNU 宽通用公共许可证 v3.0"
  },
  {
    "key": "unlicense",
    "name": "Unlicense 许可证"
  },
  {
    "key": "agpl-3.0",
    "name": "GNU Affero 通用公共许可证 v3.0"
  },
  {
    "key": "gpl-3.0",
    "name": "GNU 通用公共许可证 v3.0"
  },
  {
    "key": "bsd-3-clause",
    "name": "BSD 3 条款“新”或“修订”许可证"
  },
  {
    "key": "lgpl-2.1",
    "name": "GNU 宽通用公共许可证 v2.1"
  },
  {
    "key": "mit",
    "name": "MIT 许可证"
  },
  {
    "key": "apache-2.0",
    "name": "Apache 许可证 2.0"
  },
  {
    "key": "bsd-2-clause",
    "name": "BSD 2 条款“简化”许可证"
  },
  {
    "key": "mpl-2.0",
    "name": "Mozilla 公共许可证 2.0"
  },
  {
    "key": "gpl-2.0",
    "name": "GNU 通用公共许可证 v2.0"
  }
]
```

<a id="retrieve-a-template-of-a-particular-type"></a>

## 检索特定类型的模板

检索项目指定类型的一个模板。

```plaintext
GET /projects/:id/templates/:type/:name
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|------------------------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 模板的键，从集合端点获取。 |
| `type` | 字符串 | 是 | 模板的类型。以下之一：`dockerfiles`、`gitignores`、`gitlab_ci_ymls`、`licenses`、`issues` 或 `merge_requests`。 |
| `fullname` | 字符串 | 否 | 用于在模板中展开占位符的版权持有者的全名。仅影响许可证。 |
| `project` | 字符串 | 否 | 用于在模板中展开占位符的项目名称。仅影响许可证。 |
| `source_template_project_id` | 整数 | 否 | 存储给定模板的项目 ID。当不同项目中有多个同名模板时很有帮助。如果多个模板同名，且未指定 `source_template_project_id`，则返回最近祖先的匹配项。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|---------------|--------|---------------------------------------------------------------|
| `conditions` | 数组 | 许可证条件数组。仅适用于许可证。 |
| `content` | 字符串 | 模板内容。 |
| `description` | 字符串 | 许可证描述。仅适用于许可证。 |
| `html_url` | 字符串 | 许可证信息页面的 URL。仅适用于许可证。 |
| `key` | 字符串 | 模板的唯一标识符。仅适用于许可证。 |
| `limitations` | 数组 | 许可证限制数组。仅适用于许可证。 |
| `name` | 字符串 | 模板的人类可读名称。 |
| `nickname` | 字符串 | 许可证的常见别名。仅适用于许可证。 |
| `permissions` | 数组 | 许可证许可数组。仅适用于许可证。 |
| `popular` | 布尔值 | 如果为 `true`，表示这是一个流行的许可证。仅适用于许可证。 |
| `source_url` | 字符串 | 许可证源 URL。仅适用于许可证。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/templates/dockerfiles/Binary"
```

示例响应（Dockerfile）：

```json
{
  "name": "Binary",
  "content": "# 这是一个模板文件，可能需要编辑后才能在你的项目中使用。\n# 此 Dockerfile 将一个已编译的二进制文件安装到一个裸系统中。\n# 你必须将编译好的二进制文件提交到版本控制（不推荐）\n# 或者先作为 CI/CD 流水线的一部分构建该二进制文件。\n\nFROM buildpack-deps:buster\n\nWORKDIR /usr/local/bin\n\n# 将 `app` 更改为你的二进制文件的名称\nAdd app .\nCMD [\"./app\"]\n"
}
```

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/templates/licenses/mit"
```

示例响应（许可证）：

```json
{
  "key": "mit",
  "name": "MIT 许可证",
  "nickname": null,
  "popular": true,
  "html_url": "http://choosealicense.com/licenses/mit/",
  "source_url": "https://opensource.org/licenses/MIT",
  "description": "一个简短且宽松的许可证，仅要求保留版权和许可声明。许可的作品、修改和衍生作品可以在不同条款下分发，无需提供源代码。",
  "conditions": [
    "包含版权说明"
  ],
  "permissions": [
    "商业用途",
    "修改",
    "分发",
    "私人使用"
  ],
  "limitations": [
    "责任",
    "保证"
  ],
  "content": "MIT 许可证\n\n版权所有 (c) 2018 [全名]\n\n特此免费授予任何获得本软件及相关文档文件（“软件”）副本的人，不受限制地处理本软件的权利，包括但不限于使用、复制、修改、合并、发布、分发、再许可和/或销售本软件副本的权利，并允许接受本软件的人这样做，但须满足以下条件：\n\n上述版权声明和本许可声明应包含在本软件的所有副本或重要部分中。\n\n本软件按“原样”提供，不提供任何形式的明示或暗示保证，包括但不限于对适销性、特定用途的适用性和非侵权的保证。在任何情况下，作者或版权持有人均不对任何索赔、损害或其他责任承担任何责任，无论是在合同、侵权或其他行为中，由软件或软件的使用或其他交易引起、产生或与之相关。\n"
}
```

