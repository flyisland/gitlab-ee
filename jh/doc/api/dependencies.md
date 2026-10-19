---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 访问依赖项 API，以获取项目依赖项信息，包括受支持软件包管理器的软件包详情、版本、漏洞和许可证。
title: 依赖项 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

对此端点的每次调用都需要身份验证。要执行此调用，用户必须有权读取代码仓库。要查看响应中的漏洞，用户必须有权读取[项目安全仪表板](../user/application_security/security_dashboard/_index.md)。

<a id="list-project-dependencies"></a>

## 列出项目依赖项

列出指定项目的所有依赖项。此操作部分对应[依赖项列表](../user/application_security/dependency_list/_index.md)功能，该功能仅适用于 Gemnasium 支持的[语言和软件包管理器](../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#supported-languages-and-files)。

响应采用[分页](rest/_index.md#pagination)方式，默认返回 20 条结果。

```plaintext
GET /projects/:id/dependencies
GET /projects/:id/dependencies?package_manager=maven
GET /projects/:id/dependencies?package_manager=yarn,bundler
```

| 属性     | 类型           | 是否必需 | 描述                                                                                                                                                                 |
| ------------- | -------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                            |
| `package_manager` | string array   | 否       | 返回属于指定软件包管理器的依赖项。有效值：`bundler`、`composer`、`conan`、`go`、`gradle`、`maven`、`npm`、`nuget`、`pip`、`pipenv`、`pnpm`、`yarn`、`sbt` 或 `setuptools`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/dependencies"
```

示例响应：

```json
[
  {
    "name": "rails",
    "version": "5.0.1",
    "package_manager": "bundler",
    "dependency_file_path": "Gemfile.lock",
    "vulnerabilities": [
      {
        "name": "DDoS",
        "severity": "unknown",
        "id": 144827,
        "url": "https://gitlab.example.com/group/project/-/security/vulnerabilities/144827"
      }
    ],
    "licenses": [
      {
        "name": "MIT",
        "url": "https://opensource.org/licenses/MIT"
      }
    ]
  },
  {
    "name": "hanami",
    "version": "1.3.1",
    "package_manager": "bundler",
    "dependency_file_path": "Gemfile.lock",
    "vulnerabilities": [],
    "licenses": [
      {
        "name": "MIT",
        "url": "https://opensource.org/licenses/MIT"
      }
    ]
  },
  {
    "name": "pako",
    "version": "2.2.0",
    "package_manager": "yarn",
    "dependency_file_path": "yarn.lock",
    "vulnerabilities": [],
    "licenses": [
      {
        "name": "MIT AND Zlib",
      }
    ]
  },
]
```
