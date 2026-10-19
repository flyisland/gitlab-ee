---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 许可证 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在 极狐GitLab 中，有一个可用于处理各种开源许可证模板的 API 端点。有关各种许可证条款的更多信息，请参阅[此网站](https://choosealicense.com/)或许多其他在线资源。

具有访客角色的用户无法访问许可证模板。更多信息，请参阅[项目与群组可见性](../../user/public_access.md)。

<a id="list-all-license-templates"></a>

## 列出所有许可证模板

列出所有许可证模板。

```plaintext
GET /templates/licenses
```

| 属性 | 类型    | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `popular` | boolean | 否       | 如果传入，则只返回流行许可证 |

请求示例：

```shell
curl "https://gitlab.example.com/api/v4/templates/licenses?popular=1"
```

响应示例：

```json
[
  {
    "key":"apache-2.0",
    "name":"Apache License 2.0",
    "nickname":null,
    "featured":true,
    "html_url":"http://choosealicense.com/licenses/apache-2.0/",
    "source_url":"http://www.apache.org/licenses/LICENSE-2.0.html",
    "description":"A permissive license that also provides an express grant of patent rights from contributors to users.",
    "conditions":[
      "include-copyright",
      "document-changes"
    ],
    "permissions":[
      "commercial-use",
      "modifications",
      "distribution",
      "patent-use",
      "private-use"
    ],
    "limitations":[
      "trademark-use",
      "no-liability"
    ],
    "content":"                                 Apache License\n                           Version 2.0, January 2004\n [...]"
  },
  {
    "key":"gpl-3.0",
    "name":"GNU General Public License v3.0",
    "nickname":"GNU GPLv3",
    "featured":true,
    "html_url":"http://choosealicense.com/licenses/gpl-3.0/",
    "source_url":"http://www.gnu.org/licenses/gpl-3.0.txt",
    "description":"The GNU GPL is the most widely used free software license and has a strong copyleft requirement. When distributing derived works, the source code of the work must be made available under the same license.",
    "conditions":[
      "include-copyright",
      "document-changes",
      "disclose-source",
      "same-license"
    ],
    "permissions":[
      "commercial-use",
      "modifications",
      "distribution",
      "patent-use",
      "private-use"
    ],
    "limitations":[
      "no-liability"
    ],
    "content":"                    GNU GENERAL PUBLIC LICENSE\n                       Version 3, 29 June 2007\n [...]"
  },
  {
    "key":"mit",
    "name":"MIT License",
    "nickname":null,
    "featured":true,
    "html_url":"http://choosealicense.com/licenses/mit/",
    "source_url":"http://opensource.org/licenses/MIT",
    "description":"A permissive license that is short and to the point. It lets people do anything with your code with proper attribution and without warranty.",
    "conditions":[
      "include-copyright"
    ],
    "permissions":[
      "commercial-use",
      "modifications",
      "distribution",
      "private-use"
    ],
    "limitations":[
      "no-liability"
    ],
    "content":"The MIT License (MIT)\n\nCopyright (c) [year] [fullname]\n [...]"
  }
]
```

<a id="retrieve-a-single-license-template"></a>

## 获取单个许可证模板

获取单个许可证模板。您可以传递参数来替换许可证占位符。

```plaintext
GET /templates/licenses/:key
```

| 属性  | 类型   | 是否必需 | 描述 |
|------------|--------|----------|-------------|
| `key`      | string | 是      | 许可证模板的键 |
| `project`  | string | 否       | 受版权保护的项目名称 |
| `fullname` | string | 否       | 版权所有者的全名 |

> [!note]
> 如果您省略 `fullname` 参数但已认证请求，则已认证用户的名称将替换版权持有者占位符。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/templates/licenses/mit?project=My+Cool+Project"
```

响应示例：

```json
{
  "key":"mit",
  "name":"MIT License",
  "nickname":null,
  "featured":true,
  "html_url":"http://choosealicense.com/licenses/mit/",
  "source_url":"http://opensource.org/licenses/MIT",
  "description":"A permissive license that is short and to the point. It lets people do anything with your code with proper attribution and without warranty.",
  "conditions":[
    "include-copyright"
  ],
  "permissions":[
    "commercial-use",
    "modifications",
    "distribution",
    "private-use"
  ],
  "limitations":[
    "no-liability"
  ],
  "content":"The MIT License (MIT)\n\nCopyright (c) 2016 John Doe\n [...]"
}
```