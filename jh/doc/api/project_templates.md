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

使用此 API 可获取以下端点针对特定项目的版本：

- [Dockerfile 模板](templates/dockerfiles.md)
- [Gitignore 模板](templates/gitignores.md)
- [极狐GitLab CI/CD 配置模板](templates/gitlab_ci_ymls.md)
- [开源许可证模板](templates/licenses.md)
- [议题和合并请求模板](../user/project/description_templates.md)

此 API 弃用了这些端点，这些端点计划在 API 版本 5 中移除。

除了整个实例通用的模板外，此 API 端点还提供项目特定的模板。

此外还支持[群组文件模板](../user/group/manage.md#group-file-templates)。

<a id="list-all-templates-of-a-particular-type"></a>

## 列出特定类型的所有模板

列出某个项目指定类型的所有模板。

```plaintext
GET /projects/:id/templates/:type
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `type`    | string            | 是      | 模板的类型。接受的值为：`dockerfiles`、`gitignores`、`gitlab_ci_ymls`、`licenses`、`issues` 或 `merge_requests`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `key`     | string | 模板的唯一标识符。 |
| `name`    | string | 模板的易读名称。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/templates/licenses"
```

示例响应（许可证）：

```json
[
  {
    "key": "epl-1.0",
    "name": "Eclipse Public License 1.0"
  },
  {
    "key": "lgpl-3.0",
    "name": "GNU Lesser General Public License v3.0"
  },
  {
    "key": "unlicense",
    "name": "The Unlicense"
  },
  {
    "key": "agpl-3.0",
    "name": "GNU Affero General Public License v3.0"
  },
  {
    "key": "gpl-3.0",
    "name": "GNU General Public License v3.0"
  },
  {
    "key": "bsd-3-clause",
    "name": "BSD 3-clause \"New\" or \"Revised\" License"
  },
  {
    "key": "lgpl-2.1",
    "name": "GNU Lesser General Public License v2.1"
  },
  {
    "key": "mit",
    "name": "MIT License"
  },
  {
    "key": "apache-2.0",
    "name": "Apache License 2.0"
  },
  {
    "key": "bsd-2-clause",
    "name": "BSD 2-clause \"Simplified\" License"
  },
  {
    "key": "mpl-2.0",
    "name": "Mozilla Public License 2.0"
  },
  {
    "key": "gpl-2.0",
    "name": "GNU General Public License v2.0"
  }
]
```

<a id="retrieve-a-template-of-a-particular-type"></a>

## 获取特定类型的模板

获取某个项目指定类型的模板。

```plaintext
GET /projects/:id/templates/:type/:name
```

支持的属性：

| 属性                    | 类型              | 是否必需 | 描述 |
|------------------------------|-------------------|----------|-------------|
| `id`                         | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                       | string            | 是      | 模板的键，从集合端点获取。 |
| `type`                       | string            | 是      | 模板的类型。以下之一：`dockerfiles`、`gitignores`、`gitlab_ci_ymls`、`licenses`、`issues` 或 `merge_requests`。 |
| `fullname`                   | string            | 否       | 展开模板中的占位符时使用的版权持有者全名。仅影响许可证。 |
| `project`                    | string            | 否       | 展开模板中的占位符时使用的项目名称。仅影响许可证。 |
| `source_template_project_id` | integer           | 否       | 存储给定模板的项目 ID。当来自不同项目的多个模板具有相同名称时很有用。如果多个模板具有相同名称，且未指定 `source_template_project_id`，则返回来自最近祖先的匹配项。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性     | 类型     | 描述                                                   |
|---------------|----------|---------------------------------------------------------------|
| `conditions`  | array    | 许可证条件数组。仅适用于许可证。    |
| `content`     | string   | 模板内容。                                             |
| `description` | string   | 许可证的描述。仅适用于许可证。     |
| `html_url`    | string   | 许可证信息页面的 URL。仅适用于许可证。 |
| `key`         | string   | 模板的唯一标识符。仅适用于许可证。 |
| `limitations` | array    | 许可证限制数组。仅适用于许可证。   |
| `name`        | string   | 模板的易读名称。                          |
| `nickname`    | string   | 许可证的常用别名。仅适用于许可证。 |
| `permissions` | array    | 许可证权限数组。仅适用于许可证。   |
| `popular`     | boolean  | 如果为 `true`，表示这是常用许可证。仅适用于许可证。 |
| `source_url`  | string   | 许可证来源的 URL。仅适用于许可证。      |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/templates/dockerfiles/Binary"
```

示例响应（Dockerfile）：

```json
{
  "name": "Binary",
  "content": "# This file is a template, and might need editing before it works on your project.\n# This Dockerfile installs a compiled binary into a bare system.\n# You must either commit your compiled binary into source control (not recommended)\n# or build the binary first as part of a CI/CD pipeline.\n\nFROM buildpack-deps:buster\n\nWORKDIR /usr/local/bin\n\n# Change `app` to whatever your binary is called\nAdd app .\nCMD [\"./app\"]\n"
}
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/templates/licenses/mit"
```

示例响应（许可证）：

```json
{
  "key": "mit",
  "name": "MIT License",
  "nickname": null,
  "popular": true,
  "html_url": "http://choosealicense.com/licenses/mit/",
  "source_url": "https://opensource.org/licenses/MIT",
  "description": "A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.",
  "conditions": [
    "include-copyright"
  ],
  "permissions": [
    "commercial-use",
    "modifications",
    "distribution",
    "private-use"
  ],
  "limitations": [
    "liability",
    "warranty"
  ],
  "content": "MIT License\n\nCopyright (c) 2018 [fullname]\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE.\n"
}
```
