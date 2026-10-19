---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: .gitignore API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 检索 .gitignore 模板。更多信息，请参见 [`.gitignore` 的 Git 文档](https://git-scm.com/docs/gitignore)。

具有访客角色的用户无法访问 `.gitignore` 模板。更多信息，请参见[项目和群组可见性](../../user/public_access.md)。

<a id="list-all-.gitignore-templates"></a>

## 列出所有 `.gitignore` 模板

列出所有 `.gitignore` 模板。

```plaintext
GET /templates/gitignores
```

如果成功，将返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `key`     | 字符串 | `.gitignore` 模板的键标识符。 |
| `name`    | 字符串 | `.gitignore` 模板的显示名称。 |

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/templates/gitignores"
```

示例响应：

```json
[
  {
    "key": "Actionscript",
    "name": "Actionscript"
  },
  {
    "key": "Ada",
    "name": "Ada"
  },
  {
    "key": "Agda",
    "name": "Agda"
  },
  {
    "key": "Android",
    "name": "Android"
  },
  {
    "key": "AppEngine",
    "name": "AppEngine"
  },
  {
    "key": "AppceleratorTitanium",
    "name": "AppceleratorTitanium"
  },
  {
    "key": "ArchLinuxPackages",
    "name": "ArchLinuxPackages"
  },
  {
    "key": "Autotools",
    "name": "Autotools"
  },
  {
    "key": "C",
    "name": "C"
  },
  {
    "key": "C++",
    "name": "C++"
  },
  {
    "key": "CFWheels",
    "name": "CFWheels"
  },
  {
    "key": "CMake",
    "name": "CMake"
  },
  {
    "key": "CUDA",
    "name": "CUDA"
  },
  {
    "key": "CakePHP",
    "name": "CakePHP"
  },
  {
    "key": "ChefCookbook",
    "name": "ChefCookbook"
  },
  {
    "key": "Clojure",
    "name": "Clojure"
  },
  {
    "key": "CodeIgniter",
    "name": "CodeIgniter"
  },
  {
    "key": "CommonLisp",
    "name": "CommonLisp"
  },
  {
    "key": "Composer",
    "name": "Composer"
  },
  {
    "key": "Concrete5",
    "name": "Concrete5"
  }
]
```

<a id="retrieve-a-single-.gitignore-template"></a>

## 获取单个 `.gitignore` 模板

获取单个 `.gitignore` 模板。

```plaintext
GET /templates/gitignores/:key
```

支持的属性：

| 属性 | 类型   | 是否必需 | 描述 |
|-----------|--------|----------|-------------|
| `key`     | 字符串 | 是      | `.gitignore` 模板的键。 |

如果成功，将返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `content` | 字符串 | `.gitignore` 模板的内容。 |
| `name`    | 字符串 | `.gitignore` 模板的显示名称。 |

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/templates/gitignores/Ruby"
```

示例响应：

```json
{
  "name": "Ruby",
  "content": "*.gem\n*.rbc\n/.config\n/coverage/\n/InstalledFiles\n/pkg/\n/spec/reports/\n/spec/examples.txt\n/test/tmp/\n/test/version_tmp/\n/tmp/\n\n# Used by dotenv library to load environment variables.\n# .env\n\n## Specific to RubyMotion:\n.dat*\n.repl_history\nbuild/\n*.bridgesupport\nbuild-iPhoneOS/\nbuild-iPhoneSimulator/\n\n## Specific to RubyMotion (use of CocoaPods):\n#\n# We recommend against adding the Pods directory to your .gitignore. However\n# you should judge for yourself, the pros and cons are mentioned at:\n# https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control\n#\n# vendor/Pods/\n\n## Documentation cache and generated files:\n/.yardoc/\n/_yardoc/\n/doc/\n/rdoc/\n\n## Environment normalization:\n/.bundle/\n/vendor/bundle\n/lib/bundler/man/\n\n# for a library or gem, you might want to ignore these files since the code is\n# intended to run in multiple environments; otherwise, check them in:\n# Gemfile.lock\n# .ruby-version\n# .ruby-gemset\n\n# unless supporting rvm < 1.11.0 or doing something fancy, ignore this:\n.rvmrc\n"
}
```