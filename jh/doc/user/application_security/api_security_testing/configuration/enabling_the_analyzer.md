---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 启用分析器
---

您可以通过以下方式指定要扫描的 API：

- [OpenAPI v2 或 v3 规范](#openapi-specification)
- [GraphQL Schema](#graphql-schema)
- [HTTP Archive (HAR)](#http-archive-har)
- [Postman Collection v2.0 或 v2.1](#postman-collection)

<a id="openapi-specification"></a>

## OpenAPI 规范

[OpenAPI 规范](https://www.openapis.org/)（前身为 Swagger 规范）是一种用于 REST API 的 API 描述格式。
本节介绍如何使用 OpenAPI 规范配置 API 安全测试扫描，以提供有关待测试目标 API 的信息。
OpenAPI 规范以文件系统资源或 URL 的形式提供。同时支持 JSON 和 YAML 两种 OpenAPI 格式。

API 安全测试使用 OpenAPI 文档生成请求体。当需要请求体时，请求体的生成仅限于以下类型：

- `application/x-www-form-urlencoded`
- `multipart/form-data`
- `application/json`
- `application/xml`

<a id="openapi-and-media-types"></a>

## OpenAPI 与媒体类型

媒体类型（以前称为 MIME 类型）是用于标识所传输文件格式和格式内容的标识符。OpenAPI 文档允许您指定某个操作可以接受不同的媒体类型，因此某个请求可以使用不同的文件内容发送数据。例如，用于更新用户数据的 `PUT /user` 操作可以接受 XML（媒体类型 `application/xml`）或 JSON（媒体类型 `application/json`）格式的数据。OpenAPI 2.x 允许您全局或按操作指定接受的媒体类型，而 OpenAPI 3.x 允许您按操作指定接受的媒体类型。API 安全测试会检查列出的媒体类型，并尝试为每种受支持的媒体类型生成示例数据。

- 默认行为是选择其中一种受支持的媒体类型来使用。会从列表中选择第一个受支持的媒体类型。此行为可配置。

使用不同的媒体类型（例如 `application/json` 和 `application/xml`）测试同一个操作（例如 `POST /user`）并不总是可取的。例如，如果目标应用无论请求内容类型如何都执行相同的代码，那么完成测试会话将花费更长时间，并且根据目标应用的不同，可能会报告与请求体相关的重复漏洞。

环境变量 `APISEC_OPENAPI_ALL_MEDIA_TYPES` 允许您指定在为给定操作生成请求时，是使用所有受支持的媒体类型还是仅使用一种。当环境变量 `APISEC_OPENAPI_ALL_MEDIA_TYPES` 被设置为任意值时，API 安全测试会尝试为给定操作中的所有受支持的媒体类型生成请求，而不是仅使用一种。这将导致测试时间更长，因为会针对每种提供的媒体类型重复测试。

或者，可以使用变量 `APISEC_OPENAPI_MEDIA_TYPES` 来提供将逐一测试的媒体类型列表。提供多种媒体类型会导致测试时间更长，因为会针对每种选定的媒体类型执行测试。当环境变量 `APISEC_OPENAPI_MEDIA_TYPES` 被设置为媒体类型列表时，创建请求时只会包含列出的媒体类型。

`APISEC_OPENAPI_MEDIA_TYPES`中的多个媒体类型用冒号（`:`）分隔。例如，要将请求生成限制为媒体类型 `application/x-www-form-urlencoded` 和 `multipart/form-data`，请将环境变量 `APISEC_OPENAPI_MEDIA_TYPES` 设置为 `application/x-www-form-urlencoded:multipart/form-data`。创建请求时只会包含此列表中受支持的媒体类型，而不受支持的媒体类型始终会被跳过。媒体类型文本可能包含不同的部分。例如，`application/vnd.api+json; charset=UTF-8` 是 `type "/" [tree "."] subtype ["+" suffix]* [";" parameter]` 的组合。在请求生成时执行媒体类型过滤时，不会考虑参数。

环境变量 `APISEC_OPENAPI_ALL_MEDIA_TYPES` 和 `APISEC_OPENAPI_MEDIA_TYPES` 允许您决定如何处理媒体类型。这些设置互斥。如果两者都启用，API 安全测试会报告错误。

<a id="configure-api-security-testing-with-an-openapi-specification"></a>

### 使用 OpenAPI 规范配置 API 安全测试

要使用 OpenAPI 规范配置 API 安全测试扫描：

1. 在您的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
1. [配置文件](variables.md#configuration-files)中定义了多个测试配置文件，启用了不同的检查。从 `Quick` 配置文件开始。
   使用此配置文件进行测试可以更快完成，从而更容易验证配置。
   通过将 `APISEC_PROFILE` CI/CD 变量添加到您的 `.gitlab-ci.yml` 文件来提供该配置文件。
1. 以文件或 URL 的形式提供 OpenAPI 规范的位置。
   通过添加 `APISEC_OPENAPI` 变量来指定位置。
1. 还需要目标 API 实例的基础 URL。使用 `APISEC_TARGET_URL`
   变量或 `environment_url.txt` 文件来提供。

   在项目根目录的 `environment_url.txt` 文件中添加 URL 非常适合在
   动态环境中进行测试。要对极狐GitLab CI/CD
   流水线期间动态创建的应用运行 API 安全测试，请让应用将其 URL 持久化到 `environment_url.txt` 文件中。API 安全测试
   会自动解析该文件以找到其扫描目标。您可以在 GitLab
   [Auto DevOps CI YAML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml)中看到相关示例。

使用 OpenAPI 规范的完整配置示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
```

这是 API 安全测试的最小配置。从这里您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份验证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="http-archive-har"></a>

## HTTP Archive (HAR)

[HTTP Archive 格式 (HAR)](../../api_fuzzing/create_har_files.md) 是一种用于
记录 HTTP 事务的归档文件格式。与极狐GitLab API 安全测试扫描器一起使用时，HAR 文件必须包含调用待测试 Web API 的记录。API 安全测试扫描器会提取所有请求并使用它们来执行测试。

您可以使用各种工具生成 HAR 文件：

- [Insomnia Core](https://insomnia.rest/)：API 客户端
- [Chrome](https://www.google.com/chrome/)：浏览器
- [Firefox](https://www.mozilla.org/en-US/firefox/)：浏览器
- [Fiddler](https://www.telerik.com/fiddler)：Web 调试代理
- [GitLab HAR Recorder](https://gitlab.com/gitlab-org/security-products/har-recorder)：命令行

> [!warning]
> HAR 文件可能包含敏感信息，例如身份验证令牌、API 密钥和会话
> cookie。在将 HAR 文件内容添加到代码仓库之前，请先检查其内容。

<a id="api-security-testing-scanning-with-a-har-file"></a>

### 使用 HAR 文件进行 API 安全测试扫描

要配置 API 安全测试以使用提供待测试目标 API 信息的 HAR 文件：

1. 在您的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
1. [配置文件](variables.md#configuration-files)中定义了多个测试配置文件，启用了不同的检查。从 `Quick` 配置文件开始。
   使用此配置文件进行测试可以更快完成，从而更容易验证配置。

   通过将 `APISEC_PROFILE` CI/CD 变量添加到您的 `.gitlab-ci.yml` 文件来提供该配置文件。
1. 提供 HAR 文件的位置。您可以以文件路径
   或 URL 的形式提供位置。通过添加 `APISEC_HAR` 变量来指定位置。
1. 还需要目标 API 实例的基础 URL。使用 `APISEC_TARGET_URL`
   变量或 `environment_url.txt` 文件来提供。

   在项目根目录的 `environment_url.txt` 文件中添加 URL 非常适合在
   动态环境中进行测试。要对极狐GitLab CI/CD
   流水线期间动态创建的应用运行 API 安全测试，请让应用将其 URL 持久化到 `environment_url.txt` 文件中。API 安全测试
   会自动解析该文件以找到其扫描目标。您可以在 GitLab
   [Auto DevOps CI YAML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml)中看到相关示例。

使用 HAR 文件的完整配置示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_HAR: test-api-recording.har
  APISEC_TARGET_URL: http://test-deployment/
```

此示例是 API 安全测试的最小配置。从这里您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份验证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="graphql-schema"></a>

## GraphQL Schema

GraphQL 是一种用于 API 的查询语言，也是 REST API 的替代方案。API 安全测试支持以多种方式测试 GraphQL 端点：

- 使用 GraphQL Schema 进行测试。
- 使用 GraphQL 查询的记录（HAR）进行测试。
- 使用包含 GraphQL 查询的 Postman Collection 进行测试。

本节介绍如何使用 GraphQL schema 进行测试。API 安全测试中的 GraphQL schema 支持
能够从支持[内省](https://graphql.org/learn/introspection/)的端点查询 schema。默认情况下启用内省，以允许 GraphiQL 等工具正常工作。有关如何启用内省的详细信息，请参阅您的 GraphQL 框架文档。

<a id="api-security-testing-scanning-with-a-graphql-endpoint-url"></a>

### 使用 GraphQL 端点 URL 进行 API 安全测试扫描

API 安全测试中的 GraphQL 支持能够查询 GraphQL 端点以获取 schema。

> [!note]
> 要使此方法正常工作，GraphQL 端点必须支持内省查询。

要配置 API 安全测试以使用提供待测试目标 API 信息的 GraphQL 端点 URL：

1. 在您的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
1. 提供 GraphQL 端点的路径，例如 `/api/graphql`。通过添加 `APISEC_GRAPHQL` 变量来指定位置。
1. 还需要目标 API 实例的基础 URL。使用 `APISEC_TARGET_URL`
   变量或 `environment_url.txt` 文件来提供。

   在项目根目录的 `environment_url.txt` 文件中添加 URL 非常适合在
   动态环境中进行测试。有关更多信息，请参阅[动态环境解决方案](../troubleshooting.md#dynamic-environment-solutions)。

使用 GraphQL 端点路径的完整配置示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

api_security:
  variables:
    APISEC_GRAPHQL: /api/graphql
    APISEC_TARGET_URL: http://test-deployment/
```

此示例是 API 安全测试的最小配置。从这里您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份验证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="api-security-testing-scanning-with-a-graphql-schema-file"></a>

### 使用 GraphQL Schema 文件进行 API 安全测试扫描

API 安全测试可以使用 GraphQL schema 文件来理解和测试已禁用内省的 GraphQL 端点。要使用 GraphQL schema 文件，它必须采用内省 JSON 格式。可以使用在线第三方工具将 GraphQL schema 转换为内省 JSON 格式：<https://transform.tools/graphql-to-introspection-json>。

要配置 API 安全测试以使用提供待测试目标 API 信息的 GraphQL schema 文件：

1. 在您的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
1. 提供 GraphQL 端点路径，例如 `/api/graphql`。通过添加 `APISEC_GRAPHQL` 变量来指定路径。
1. 提供 GraphQL schema 文件的位置。您可以以文件路径
   或 URL 的形式提供位置。通过添加 `APISEC_GRAPHQL_SCHEMA` 变量来指定位置。
1. 还需要目标 API 实例的基础 URL。使用 `APISEC_TARGET_URL`
   变量或 `environment_url.txt` 文件来提供。

   在项目根目录的 `environment_url.txt` 文件中添加 URL 非常适合在
   动态环境中进行测试。有关更多信息，请参阅[动态环境解决方案](../troubleshooting.md#dynamic-environment-solutions)。

使用 GraphQL schema 文件的完整配置示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

api_security:
  variables:
    APISEC_GRAPHQL: /api/graphql
    APISEC_GRAPHQL_SCHEMA: test-api-graphql.schema
    APISEC_TARGET_URL: http://test-deployment/
```

使用 GraphQL schema 文件 URL 的完整配置示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

api_security:
  variables:
    APISEC_GRAPHQL: /api/graphql
    APISEC_GRAPHQL_SCHEMA: http://file-store/files/test-api-graphql.schema
    APISEC_TARGET_URL: http://test-deployment/
```

此示例是 API 安全测试的最小配置。从这里您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份验证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="postman-collection"></a>

## Postman Collection

[Postman API Client](https://www.postman.com/product/api-client/) 是一款流行的工具，
开发人员和测试人员使用它来调用各种类型的 API。API 定义
[可以导出为 Postman Collection 文件](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)
以用于 API 安全测试。导出时，请确保选择受支持的 Postman Collection
版本：v2.0 或 v2.1。

与极狐GitLab API 安全测试扫描器一起使用时，Postman Collection 必须包含待测试 Web API 的定义
以及有效数据。API 安全测试扫描器会提取所有 API 定义并使用它们来执行测试。

> [!warning]
> Postman Collection 文件可能包含敏感信息，例如身份验证令牌、API 密钥
> 和会话 cookie。在将 Postman Collection 文件内容添加到代码仓库之前，请先检查其内容。

<a id="api-security-testing-scanning-with-a-postman-collection-file"></a>

### 使用 Postman Collection 文件进行 API 安全测试扫描

要配置 API 安全测试以使用提供待测试目标
API 信息的 Postman Collection 文件：

1. [包含](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
1. [配置文件](variables.md#configuration-files)中定义了多个测试配置文件，启用了不同的检查。从 `Quick` 配置文件开始。
   使用此配置文件进行测试可以更快完成，从而更容易验证配置。

   通过将 `APISEC_PROFILE` CI/CD 变量添加到您的 `.gitlab-ci.yml` 文件来提供该配置文件。
1. 以文件或 URL 的形式提供 Postman Collection 文件的位置。通过添加 `APISEC_POSTMAN_COLLECTION` 变量来指定位置。
1. 还需要目标 API 实例的基础 URL。使用 `APISEC_TARGET_URL`
   变量或 `environment_url.txt` 文件来提供。

   在项目根目录的 `environment_url.txt` 文件中添加 URL 非常适合在
   动态环境中进行测试。要对极狐GitLab CI/CD
   流水线期间动态创建的应用运行 API 安全测试，请让应用将其 URL 持久化到 `environment_url.txt` 文件中。API 安全测试
   会自动解析该文件以找到其扫描目标。您可以在 GitLab
   [Auto DevOps CI YAML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml)中看到相关示例。

使用 Postman collection 的完整配置示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection_serviceA.json
  APISEC_TARGET_URL: http://test-deployment/
```

这是 API 安全测试的最小配置。从这里您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份验证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="postman-variables"></a>

### Postman 变量

<a id="variables-in-postman-client"></a>

#### Postman Client 中的变量

Postman 允许开发人员定义可在请求的不同部分使用的占位符。这些占位符称为变量，如[使用变量](https://learning.postman.com/docs/sending-requests/variables/variables/#using-variables)中所述。您可以使用变量在请求和脚本中存储和重用值。例如，您可以编辑 collection 以向文档添加变量：

![编辑 collection 变量选项卡视图](img/dast_api_postman_collection_edit_variable_v18_5.png)

或者，您也可以在环境中添加变量：

![编辑环境变量视图](img/dast_api_postman_environment_edit_variable_v18_5.png)

然后，您可以在 URL、请求头等部分中使用这些变量：

![使用变量编辑请求视图](img/dast_api_postman_request_edit_v18_5.png)

Postman 已经从一个具有良好 UX 体验的基础客户端工具发展成为一个更复杂的生态系统，允许使用脚本测试 API、创建触发二次请求的复杂 collection，并在此过程中设置变量。并非 Postman 生态系统中的每个功能都受支持。例如，不支持脚本。Postman 支持的主要重点是摄取 Postman Client 使用的 Postman Collection 定义，以及在工作区、环境和 collection 本身中定义的相关变量。

Postman 允许在不同的作用域中创建变量。每个作用域在 Postman 工具中具有不同的可见性级别。例如，您可以在*全局环境*作用域中创建一个变量，该变量对每个操作定义和工作区都可见。您也可以在特定的*环境*作用域中创建一个变量，该变量仅在选择使用该特定环境时才可见和使用。某些作用域并非始终可用，例如，在 Postman 生态系统中，您可以在 Postman Client 中创建请求。这些请求没有*本地*作用域，但测试脚本有。

Postman 中的变量作用域可能是一个令人生畏的话题，并非每个人都熟悉它。在继续之前，请阅读 Postman 文档中的[变量作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#variable-scopes)。

如前所述，存在不同的变量作用域，每个作用域都有其用途，可用于为您的 Postman 文档提供更大的灵活性。关于如何计算变量值，有一个重要说明，根据 Postman 文档：

> [!note]
> 如果在两个不同的作用域中声明了同名变量，则使用作用域最窄的变量中存储的值。例如，如果存在名为 `username`的全局变量和名为 `username`的本地变量，则请求运行时使用本地值。

以下是 Postman Client 和 API 安全测试支持的变量作用域摘要：

- **全局环境（Global）作用域**是一个特殊的预定义环境，在整个工作区中都可用。您也可以将*全局环境*作用域称为*全局*作用域。Postman Client 允许将全局环境导出为 JSON 文件，该文件可用于 API 安全测试。
- **环境作用域**是用户在 Postman Client 中创建的一组命名变量。
  Postman Client 支持一个活动环境以及全局环境。在活动用户创建的环境中定义的变量优先于在全局环境中定义的变量。Postman Client 允许将您的环境导出为 JSON 文件，该文件可用于 API 安全测试。
- **Collection 作用域**是在给定 collection 中声明的一组变量。collection 变量可用于声明它们的 collection 以及嵌套的请求或 collection。在 collection 作用域中定义的变量优先于*全局环境*作用域和*环境*作用域。
  Postman Client 可以将一个或多个 collection 导出为 JSON 文件，此 JSON 文件包含选定的 collection、请求和 collection 变量。
- **API 安全测试作用域**是 API 安全测试添加的一个新作用域，允许用户提供额外变量，或覆盖其他受支持作用域中定义的变量。Postman 不支持此作用域。*API 安全测试作用域*变量使用[自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)提供。
  - 覆盖在环境或 collection 中定义的值
  - 从脚本定义变量
  - 从不支持的*数据作用域*定义单行数据
- **数据作用域**是一组变量，其名称和值来自 JSON 或 CSV 文件。像 [Newman](https://learning.postman.com/docs/reference/newman-cli/command-line-integration-with-newman) 或 [Postman Collection Runner](https://learning.postman.com/docs/tests-and-scripts/running-collections/intro-to-collection-runs/) 这样的 Postman collection 运行器会按照 JSON 或 CSV 文件中的条目数量执行 collection 中的请求。这些变量的一个很好的用例是使用 Postman 中的脚本自动化测试。
  API 安全测试不支持从 CSV 或 JSON 文件读取数据。
- **本地作用域**是在 Postman 脚本中定义的变量。API 安全测试不支持 Postman 脚本，因此也不支持脚本中定义的变量。您仍然可以通过在受支持的作用域之一或自定义 JSON 格式中定义它们来为脚本定义的变量提供值。

并非所有作用域都受 API 安全测试支持，并且不支持脚本中定义的变量。下表按从最宽作用域到最窄作用域排序。

| 作用域                      | Postman | API 安全测试 | 备注                                    |
|----------------------------|:-------:|:--------------------:|:-------------------------------------------|
| 全局环境         |   是   |         是          | 特殊的预定义环境            |
| 环境                |   是   |         是          | 命名环境                         |
| Collection                 |   是   |         是          | 在您的 postman collection 中定义         |
| API 安全测试作用域 |   否   |         是          | API 安全测试添加的自定义作用域 |
| 数据                       |   是   |          否          | CSV 或 JSON 格式的外部文件       |
| 本地                      |   是   |          否          | 在脚本中定义的变量               |

有关如何在不同作用域中定义变量和导出变量的更多详细信息，请参阅：

- [定义 collection 变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-collection-variables)
- [定义环境变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-environment-variables)
- [定义全局变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-global-variables)

<a id="exporting-from-postman-client"></a>

##### 从 Postman Client 导出

Postman Client 允许您导出不同的文件格式，例如，您可以导出 Postman collection 或 Postman 环境。
导出的环境可以是全局环境（始终可用），也可以是您之前创建的任何自定义环境。当您导出 Postman Collection 时，它可能只包含 _collection_ 和*本地*作用域变量的声明；*环境*作用域变量不包含在内。

要获取*环境*作用域变量的声明，您必须当时导出给定的环境。每个导出的文件只包含来自所选环境的变量。

有关在不同受支持作用域中导出变量的更多详细信息，请参阅：

- [导出 collection](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)
- [导出环境](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)
- [下载全局环境](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)

<a id="api-security-testing-scope-custom-json-file-format"></a>

#### API 安全测试作用域，自定义 JSON 文件格式

自定义 JSON 文件格式是一个 JSON 对象，其中每个对象属性代表一个变量名，属性值代表变量值。此文件可以使用您喜欢的文本编辑器创建，也可以由您的流水线中的先前作业生成。

此示例在 API 安全测试作用域中定义了两个变量 `base_url` 和 `token`：

```json
{
  "base_url": "http://127.0.0.1/",
  "token": "Token 84816165151"
}
```

<a id="using-scopes-with-api-security-testing"></a>

#### 将作用域与 API 安全测试一起使用

支持以下作用域：*全局*、*环境*、_collection_ 和*极狐GitLab API 安全测试*。

下表提供了将作用域文件/URL 映射到 API 安全测试配置变量的快速参考：

| 作用域              |  如何提供 |
| ------------------ | --------------- |
| 全局环境 | APISEC_POSTMAN_COLLECTION_VARIABLES |
| 环境        | APISEC_POSTMAN_COLLECTION_VARIABLES |
| Collection         | APISEC_POSTMAN_COLLECTION           |
| API 安全测试作用域 | APISEC_POSTMAN_COLLECTION_VARIABLES |
| 数据               | 不支持   |
| 本地              | 不支持   |

Postman Collection 文档会自动包含任何 _collection_ 作用域变量。Postman Collection 通过配置变量 `APISEC_POSTMAN_COLLECTION` 提供。此变量可以设置为单个[导出的 Postman collection](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)。

来自其他作用域的变量通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。该配置变量支持逗号（`,`）分隔的文件列表。提供文件的顺序不重要，因为文件提供了所需的作用域信息。

配置变量 `APISEC_POSTMAN_COLLECTION_VARIABLES` 可以设置为：

- [导出的全局环境](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)
- [导出的环境](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)
- [API 安全测试自定义 JSON 格式](#api-security-testing-scope-custom-json-file-format)

<a id="undefined-postman-variables"></a>

#### 未定义的 Postman 变量

API 安全测试引擎有可能找不到您的 Postman collection 文件正在使用的所有变量引用。一些情况可能是：

- 您正在使用*数据*或*本地*作用域变量，如前所述，API 安全测试不支持这些作用域。因此，假设这些变量的值没有通过 [API 安全测试作用域](#api-security-testing-scope-custom-json-file-format)提供，那么*数据*和*本地*作用域变量的值是未定义的。
- 变量名输入错误，名称与定义的变量不匹配。
- Postman Client 支持 API 安全测试不支持的新动态变量。

在可能的情况下，API 安全测试在处理未定义变量时遵循与 Postman Client 相同的行为。变量引用的文本保持不变，并且没有文本替换。相同的行为也适用于任何不受支持的动态变量。

例如，如果 Postman Collection 中的请求定义引用了变量 `{{full_url}}` 并且未找到该变量，则它保持不变，值为 `{{full_url}}`。

<a id="dynamic-postman-variables"></a>

#### 动态 Postman 变量

除了用户可以在各种作用域级别定义的变量之外，Postman 还有一组称为*动态*变量的预定义变量。[*动态*变量](https://learning.postman.com/docs/tests-and-scripts/write-scripts/variables-list/)已经定义，其名称以美元符号（`$`）为前缀，例如 `$guid`。*动态*变量可以像任何其他变量一样使用，并且在 Postman Client 中，它们在请求/collection 运行期间产生随机值。

API 安全测试与 Postman 之间的一个重要区别是，API 安全测试对同一动态变量的每次使用都返回相同的值。这与 Postman Client 的行为不同，后者在每次使用同一动态变量时返回随机值。换句话说，API 安全测试对动态变量使用静态值，而 Postman 使用随机值。

扫描过程中受支持的动态变量有：

| 变量    | 值       |
| ----------- | ----------- |
| `$guid` | `611c2e81-2ccb-42d8-9ddc-2d0bfa65c1b4` |
| `$isoTimestamp` | `2020-06-09T21:10:36.177Z` |
| `$randomAbbreviation` | `PCI` |
| `$randomAbstractImage` | `http://no-a-valid-host/640/480/abstract` |
| `$randomAdjective` | `auxiliary` |
| `$randomAlphaNumeric` | `a` |
| `$randomAnimalsImage` | `http://no-a-valid-host/640/480/animals` |
| `$randomAvatarImage` | `https://no-a-valid-host/path/to/some/image.jpg` |
| `$randomBankAccount` | `09454073` |
| `$randomBankAccountBic` | `EZIAUGJ1` |
| `$randomBankAccountIban` | `MU20ZPUN3039684000618086155TKZ` |
| `$randomBankAccountName` | `Home Loan Account` |
| `$randomBitcoin` | `3VB8JGT7Y4Z63U68KGGKDXMLLH5` |
| `$randomBoolean` | `true` |
| `$randomBs` | `killer leverage schemas` |
| `$randomBsAdjective` | `viral` |
| `$randomBsBuzz` | `repurpose` |
| `$randomBsNoun` | `markets` |
| `$randomBusinessImage` | `http://no-a-valid-host/640/480/business` |
| `$randomCatchPhrase` | `Future-proofed heuristic open architecture` |
| `$randomCatchPhraseAdjective` | `Business-focused` |
| `$randomCatchPhraseDescriptor` | `bandwidth-monitored` |
| `$randomCatchPhraseNoun` | `superstructure` |
| `$randomCatsImage` | `http://no-a-valid-host/640/480/cats` |
| `$randomCity` | `Spinkahaven` |
| `$randomCityImage` | `http://no-a-valid-host/640/480/city` |
| `$randomColor` | `fuchsia` |
| `$randomCommonFileExt` | `wav` |
| `$randomCommonFileName` | `well_modulated.mpg4` |
| `$randomCommonFileType` | `audio` |
| `$randomCompanyName` | `Grady LLC` |
| `$randomCompanySuffix` | `Inc` |
| `$randomCountry` | `Kazakhstan` |
| `$randomCountryCode` | `MD` |
| `$randomCreditCardMask` | `3622` |
| `$randomCurrencyCode` | `ZMK` |
| `$randomCurrencyName` | `Pound Sterling` |
| `$randomCurrencySymbol` | `£` |
| `$randomDatabaseCollation` | `utf8_general_ci` |
| `$randomDatabaseColumn` | `updatedAt` |
| `$randomDatabaseEngine` | `Memory` |
| `$randomDatabaseType` | `text` |
| `$randomDateFuture` | `Tue Mar 17 2020 13:11:50 GMT+0530 (India Standard Time)` |
| `$randomDatePast` | `Sat Mar 02 2019 09:09:26 GMT+0530 (India Standard Time)` |
| `$randomDateRecent` | `Tue Jul 09 2019 23:12:37 GMT+0530 (India Standard Time)` |
| `$randomDepartment` | `Electronics` |
| `$randomDirectoryPath` | `/usr/local/bin` |
| `$randomDomainName` | `trevor.info` |
| `$randomDomainSuffix` | `org` |
| `$randomDomainWord` | `jaden` |
| `$randomEmail` | `Iva.Kovacek61@no-a-valid-host.com` |
| `$randomExampleEmail` | `non-a-valid-user@example.net` |
| `$randomFashionImage` | `http://no-a-valid-host/640/480/fashion` |
| `$randomFileExt` | `war` |
| `$randomFileName` | `neural_sri_lanka_rupee_gloves.gdoc` |
| `$randomFilePath` | `/home/programming_chicken.cpio` |
| `$randomFileType` | `application` |
| `$randomFirstName` | `Chandler` |
| `$randomFoodImage` | `http://no-a-valid-host/640/480/food` |
| `$randomFullName` | `Connie Runolfsdottir` |
| `$randomHexColor` | `#47594a` |
| `$randomImageDataUri` | `data:image/svg+xml;charset=UTF-8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20version%3D%221.1%22%20baseProfile%3D%22full%22%20width%3D%22undefined%22%20height%3D%22undefined%22%3E%20%3Crect%20width%3D%22100%25%22%20height%3D%22100%25%22%20fill%3D%22grey%22%2F%3E%20%20%3Ctext%20x%3D%220%22%20y%3D%2220%22%20font-size%3D%2220%22%20text-anchor%3D%22start%22%20fill%3D%22white%22%3Eundefinedxundefined%3C%2Ftext%3E%20%3C%2Fsvg%3E` |
| `$randomImageUrl` | `http://no-a-valid-host/640/480` |
| `$randomIngverb` | `navigating` |
| `$randomInt` | `494` |
| `$randomIP` | `241.102.234.100` |
| `$randomIPV6` | `dbe2:7ae6:119b:c161:1560:6dda:3a9b:90a9` |
| `$randomJobArea` | `Mobility` |
| `$randomJobDescriptor` | `Senior` |
| `$randomJobTitle` | `International Creative Liaison` |
| `$randomJobType` | `Supervisor` |
| `$randomLastName` | `Schneider` |
| `$randomLatitude` | `55.2099` |
| `$randomLocale` | `ny` |
| `$randomLongitude` | `40.6609` |
| `$randomLoremLines` | `Ducimus in ut mollitia.\nA itaque non.\nHarum temporibus nihil voluptas.\nIste in sed et nesciunt in quaerat sed.` |
| `$randomLoremParagraph` | `Ab aliquid odio iste quo voluptas voluptatem dignissimos velit. Recusandae facilis qui commodi ea magnam enim nostrum quia quis. Nihil est suscipit assumenda ut voluptatem sed. Esse ab voluptas odit qui molestiae. Rem est nesciunt est quis ipsam expedita consequuntur.` |
| `$randomLoremParagraphs` | `Voluptatem rem magnam aliquam ab id aut quaerat. Placeat provident possimus voluptatibus dicta velit non aut quasi. Mollitia et aliquam expedita sunt dolores nam consequuntur. Nam dolorum delectus ipsam repudiandae et ipsam ut voluptatum totam. Nobis labore labore recusandae ipsam quo.` |
| `$randomLoremSentence` | `Molestias consequuntur nisi non quod.` |
| `$randomLoremSentences` | `Et sint voluptas similique iure amet perspiciatis vero sequi atque. Ut porro sit et hic. Neque aspernatur vitae fugiat ut dolore et veritatis. Ab iusto ex delectus animi. Voluptates nisi iusto. Impedit quod quae voluptate qui.` |
| `$randomLoremSlug` | `eos-aperiam-accusamus, beatae-id-molestiae, qui-est-repellat` |
| `$randomLoremText` | `Quisquam asperiores exercitationem ut ipsum. Aut eius nesciunt. Et reiciendis aut alias eaque. Nihil amet laboriosam pariatur eligendi. Sunt ullam ut sint natus ducimus. Voluptas harum aspernatur soluta rem nam.` |
| `$randomLoremWord` | `est` |
| `$randomLoremWords` | `vel repellat nobis` |
| `$randomMACAddress` | `33:d4:68:5f:b4:c7` |
| `$randomMimeType` | `audio/vnd.vmx.cvsd` |
| `$randomMonth` | `February` |
| `$randomNamePrefix` | `Dr.` |
| `$randomNameSuffix` | `MD` |
| `$randomNatureImage` | `http://no-a-valid-host/640/480/nature` |
| `$randomNightlifeImage` | `http://no-a-valid-host/640/480/nightlife` |
| `$randomNoun` | `bus` |
| `$randomPassword` | `t9iXe7COoDKv8k3` |
| `$randomPeopleImage` | `http://no-a-valid-host/640/480/people` |
| `$randomPhoneNumber` | `700-008-5275` |
| `$randomPhoneNumberExt` | `27-199-983-3864` |
| `$randomPhrase` | `You can't program the monitor without navigating the mobile XML program!` |
| `$randomPrice` | `531.55` |
| `$randomProduct` | `Pizza` |
| `$randomProductAdjective` | `Unbranded` |
| `$randomProductMaterial` | `Steel` |
| `$randomProductName` | `Handmade Concrete Tuna` |
| `$randomProtocol` | `https` |
| `$randomSemver` | `7.0.5` |
| `$randomSportsImage` | `http://no-a-valid-host/640/480/sports` |
| `$randomStreetAddress` | `5742 Harvey Streets` |
| `$randomStreetName` | `Kuhic Island` |
| `$randomTransactionType` | `payment` |
| `$randomTransportImage` | `http://no-a-valid-host/640/480/transport` |
| `$randomUrl` | `https://no-a-valid-host.net` |
| `$randomUserAgent` | `Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.9.8; rv:15.6) Gecko/20100101 Firefox/15.6.6` |
| `$randomUserName` | `Jarrell.Gutkowski` |
| `$randomUUID` | `6929bb52-3ab2-448a-9796-d6480ecad36b` |
| `$randomVerb` | `navigate` |
| `$randomWeekday` | `Thursday` |
| `$randomWord` | `withdrawal` |
| `$randomWords` | `Samoa Synergistic sticky copying Grocery` |
| `$timestamp` | `1562757107` |

<a id="example-global-scope"></a>

#### 示例：全局作用域

在此示例中，[从 Postman Client 导出*全局*作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)为 `global-scope.json`，并通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供给 API 安全测试。

以下是使用 `APISEC_POSTMAN_COLLECTION_VARIABLES`的示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_POSTMAN_COLLECTION_VARIABLES: global-scope.json
  APISEC_TARGET_URL: http://test-deployment/
```

<a id="example-environment-scope"></a>

#### 示例：环境作用域

在此示例中，[从 Postman Client 导出*环境*作用域](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)为 `environment-scope.json`，并通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供给 API 安全测试。

以下是使用 `APISEC_POSTMAN_COLLECTION_VARIABLES`的示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_POSTMAN_COLLECTION_VARIABLES: environment-scope.json
  APISEC_TARGET_URL: http://test-deployment/
```

<a id="example-collection-scope"></a>

#### 示例：Collection 作用域

_collection_ 作用域变量包含在导出的 Postman Collection 文件中，并通过 `APISEC_POSTMAN_COLLECTION` 配置变量提供。

以下是使用 `APISEC_POSTMAN_COLLECTION`的示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_TARGET_URL: http://test-deployment/
```

<a id="example-api-security-testing-scope"></a>

#### 示例：API 安全测试作用域

API 安全测试作用域有两个主要用途：定义 API 安全测试不支持的*数据*和*本地*作用域变量，以及更改在另一个作用域中定义的现有变量的值。API 安全测试作用域通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。

以下是使用 `APISEC_POSTMAN_COLLECTION_VARIABLES`的示例：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_POSTMAN_COLLECTION_VARIABLES: dast-api-scope.json
  APISEC_TARGET_URL: http://test-deployment/
```

文件 `dast-api-scope.json` 使用[自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)。此 JSON 是一个对象，其属性为键值对。键是变量名，值是变量的值。例如：

```json
{
  "base_url": "http://127.0.0.1/",
  "token": "Token 84816165151"
}
```

<a id="example-multiple-scopes"></a>

#### 示例：多个作用域

在此示例中，配置了*全局*作用域、*环境*作用域和 _collection_ 作用域。第一步是导出各个作用域。

- [将*全局*作用域导出](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)为 `global-scope.json`
- [将*环境*作用域导出](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)为 `environment-scope.json`
- 将包含 _collection_ 作用域的 Postman Collection 导出为 `postman-collection.json`

Postman Collection 使用 `APISEC_POSTMAN_COLLECTION` 变量提供，而其他作用域使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 提供。API 安全测试可以使用每个文件中提供的数据来识别所提供文件匹配的作用域。

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_POSTMAN_COLLECTION_VARIABLES: global-scope.json,environment-scope.json
  APISEC_TARGET_URL: http://test-deployment/
```

<a id="example-changing-a-variables-value"></a>

#### 示例：更改变量值

使用导出的作用域时，通常需要更改变量的值以用于 API 安全测试。例如，一个 _collection_ 作用域变量可能包含名为 `api_version`的变量，其值为 `v2`，而您的测试需要 `v1`的值。无需修改导出的 collection 来更改值，可以使用 API 安全测试作用域来更改其值。这是可行的，因为 *API 安全测试*作用域优先于所有其他作用域。

_collection_ 作用域变量包含在导出的 Postman Collection 文件中，并通过 `APISEC_POSTMAN_COLLECTION` 配置变量提供。

API 安全测试作用域通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。但首先，创建文件。文件 `dast-api-scope.json` 使用[自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)。此 JSON 是一个对象，其属性为键值对。键是变量名，值是变量的值。例如：

```json
{
  "api_version": "v1"
}
```

CI 定义：

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_POSTMAN_COLLECTION_VARIABLES: dast-api-scope.json
  APISEC_TARGET_URL: http://test-deployment/
```

<a id="example-changing-a-variables-value-with-multiple-scopes"></a>

#### 示例：使用多个作用域更改变量值

使用导出的作用域时，通常需要更改变量的值以用于 API 安全测试。例如，一个*环境*作用域可能包含名为 `api_version`的变量，其值为 `v2`，而您的测试需要 `v1`的值。无需修改导出的文件来更改值，可以使用 API 安全测试作用域。这是可行的，因为 *API 安全测试*作用域优先于所有其他作用域。

在此示例中，配置了*全局*作用域、*环境*作用域、_collection_ 作用域和 *API 安全测试*作用域。第一步是导出和创建各个作用域。

- [将*全局*作用域导出](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)为 `global-scope.json`
- [将*环境*作用域导出](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)为 `environment-scope.json`
- 将包含 _collection_ 作用域的 Postman Collection 导出为 `postman-collection.json`

API 安全测试作用域通过使用[自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)创建文件 `dast-api-scope.json` 来使用。此 JSON 是一个对象，其属性为键值对。键是变量名，值是变量的值。例如：

```json
{
  "api_version": "v1"
}
```

Postman Collection 使用 `APISEC_POSTMAN_COLLECTION` 变量提供，而其他作用域使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 提供。API 安全测试可以使用每个文件中提供的数据来识别所提供文件匹配的作用域。

```yaml
stages:
  - dast

include:
  - template: Security/API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_POSTMAN_COLLECTION: postman-collection.json
  APISEC_POSTMAN_COLLECTION_VARIABLES: global-scope.json,environment-scope.json,dast-api-scope.json
  APISEC_TARGET_URL: http://test-deployment/
```

<a id="running-your-first-scan"></a>

## 运行您的第一次扫描

配置正确后，CI/CD 流水线会包含一个 `dast` 阶段和一个 `dast_api` 作业。仅当提供了无效配置时，作业才会失败。在典型操作期间，即使测试期间发现了漏洞，作业也始终成功。

漏洞会显示在**安全**流水线选项卡上，并带有套件名称。当针对代码仓库的默认分支进行测试时，API 安全测试漏洞也会显示在安全与合规的漏洞报告中。

为防止报告过多的漏洞，API 安全测试扫描器会限制每个操作报告的漏洞数量。

<a id="viewing-api-security-testing-vulnerabilities"></a>

## 查看 API 安全测试漏洞

API 安全测试分析器会生成一份 JSON 报告，该报告会被收集并用于[将漏洞填充到极狐GitLab 漏洞界面中](#view-details-of-an-api-security-testing-vulnerability)。

有关您可以进行的配置更改以限制报告的误报数量的信息，请参阅[处理误报](#handling-false-positives)。

<a id="view-details-of-an-api-security-testing-vulnerability"></a>

### 查看 API 安全测试漏洞的详细信息

按照以下步骤查看漏洞的详细信息：

1. 您可以在项目中或合并请求中查看漏洞：

   - 在项目中，转到项目的**安全** > **漏洞报告**
     页面。此页面仅显示来自默认分支的所有漏洞。
   - 在合并请求中，转到合并请求的**安全**部分，然后选择**展开**
     按钮。API 安全测试漏洞显示在标记为
     **DAST 检测到 N 个潜在漏洞**的部分中。选择标题以显示漏洞
     详细信息。

1. 选择漏洞标题以显示详细信息。下表描述了这些详细信息。

   | 字段               | 描述                                                                             |
   |:--------------------|:----------------------------------------------------------------------------------------|
   | 描述         | 漏洞的描述，包括修改了什么。                           |
   | 项目             | 检测到漏洞的命名空间和项目。                          |
   | 方法              | 用于检测漏洞的 HTTP 方法。                                           |
   | URL                 | 检测到漏洞的 URL。                                            |
   | 请求             | 导致漏洞的 HTTP 请求。                                         |
   | 未修改的响应 | 来自未修改请求的响应。典型的工作响应看起来像未修改的响应。 |
   | 实际响应     | 从测试请求收到的响应。                                                    |
   | 证据            | 极狐GitLab 如何确定发生了漏洞。                                         |
   | 标识符         | 用于发现此漏洞的 API 安全测试检查。                         |
   | 严重性            | 漏洞的严重性。                                                          |
   | 扫描器类型        | 用于执行测试的扫描器。                                                        |

<a id="security-dashboard"></a>

### 安全仪表板

安全仪表板是概览您的群组、项目和流水线中所有安全漏洞的好地方。有关更多信息，请参阅[安全仪表板文档](../../security_dashboard/_index.md)。

<a id="interacting-with-the-vulnerabilities"></a>

### 与漏洞交互

发现漏洞后，您可以与其交互。阅读更多关于如何[处理漏洞](../../vulnerabilities/_index.md)的信息。

<a id="handling-false-positives"></a>

### 处理误报

可以通过多种方式处理误报：

- 忽略该漏洞。
- 某些检查有多种方法来确定何时识别出漏洞，称为*断言*。
  断言也可以关闭和配置。例如，API 安全测试扫描器默认使用 HTTP
  状态码来帮助识别何时是真正的问题。如果 API 在测试期间返回 500 错误，
  这会产生一个漏洞。这并不总是可取的，因为某些框架经常返回 500 错误。
- 关闭产生误报的检查。这可以防止该检查生成任何
  漏洞。示例检查包括 SQL 注入检查和 JSON 劫持检查。

<a id="turn-off-a-check"></a>

#### 关闭检查

检查执行特定类型的测试，并且可以针对特定配置配置文件打开和关闭。提供的[配置文件](variables.md#configuration-files)定义了您可以使用的多个配置文件。配置文件中的配置文件定义列出了扫描期间活动的所有检查。要关闭特定检查，请将其从配置文件中的配置文件定义中删除。配置文件在配置文件的 `Profiles` 部分中定义。

示例配置文件定义：

```yaml
Profiles:
  - Name: Quick
    DefaultProfile: Empty
    Routes:
      - Route: *Route0
        Checks:
          - Name: ApplicationInformationCheck
          - Name: CleartextAuthenticationCheck
          - Name: FrameworkDebugModeCheck
          - Name: HtmlInjectionCheck
          - Name: InsecureHttpMethodsCheck
          - Name: JsonHijackingCheck
          - Name: JsonInjectionCheck
          - Name: SensitiveInformationCheck
          - Name: SessionCookieCheck
          - Name: SqlInjectionCheck
          - Name: TokenCheck
          - Name: XmlInjectionCheck
```

要关闭 JSON 劫持检查，您可以删除以下行：

```yaml
          - Name: JsonHijackingCheck
```

这将产生以下 YAML：

```yaml
- Name: Quick
  DefaultProfile: Empty
  Routes:
    - Route: *Route0
      Checks:
        - Name: ApplicationInformationCheck
        - Name: CleartextAuthenticationCheck
        - Name: FrameworkDebugModeCheck
        - Name: HtmlInjectionCheck
        - Name: InsecureHttpMethodsCheck
        - Name: JsonInjectionCheck
        - Name: SensitiveInformationCheck
        - Name: SessionCookieCheck
        - Name: SqlInjectionCheck
        - Name: TokenCheck
        - Name: XmlInjectionCheck
```

<a id="turn-off-an-assertion-for-a-check"></a>

#### 关闭检查的断言

断言检测由检查产生的测试中的漏洞。许多检查支持多种断言，例如日志分析、响应分析和状态码。当发现漏洞时，会提供所使用的断言。要确定默认情况下哪些断言是开启的，请参阅配置文件中的检查默认配置。该部分称为 `Checks`。

此示例显示了 SQL 注入检查：

```yaml
- Name: SqlInjectionCheck
  Configuration:
    UserInjections: []
  Assertions:
    - Name: LogAnalysisAssertion
    - Name: ResponseAnalysisAssertion
    - Name: StatusCodeAssertion
```

在这里您可以看到默认情况下开启了三个断言。误报的常见来源是 `StatusCodeAssertion`。要将其关闭，请在 `Profiles` 部分中修改其配置。此示例仅提供其他两个断言（`LogAnalysisAssertion`、`ResponseAnalysisAssertion`）。这可以防止 `SqlInjectionCheck` 使用 `StatusCodeAssertion`：

```yaml
Profiles:
  - Name: Quick
    DefaultProfile: Empty
    Routes:
      - Route: *Route0
        Checks:
          - Name: ApplicationInformationCheck
          - Name: CleartextAuthenticationCheck
          - Name: FrameworkDebugModeCheck
          - Name: HtmlInjectionCheck
          - Name: InsecureHttpMethodsCheck
          - Name: JsonHijackingCheck
          - Name: JsonInjectionCheck
          - Name: SensitiveInformationCheck
          - Name: SessionCookieCheck
          - Name: SqlInjectionCheck
            Assertions:
              - Name: LogAnalysisAssertion
              - Name: ResponseAnalysisAssertion
          - Name: TokenCheck
          - Name: XmlInjectionCheck
```
