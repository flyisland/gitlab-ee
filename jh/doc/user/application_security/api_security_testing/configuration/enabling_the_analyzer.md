---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 启用分析器
---

你可以通过以下方式指定要扫描的 API：

- [OpenAPI v2 或 v3 规范](#openapi-specification)
- [GraphQL Schema](#graphql-schema)
- [HTTP 存档 (HAR)](#http-archive-har)
- [Postman Collection v2.0 或 v2.1](#postman-collection)

<a id="openapi-specification"></a>

## OpenAPI 规范

[OpenAPI 规范](https://www.openapis.org/)（前身为 Swagger 规范）是一种用于 REST API 的 API 描述格式。
本节将展示如何配置 API 安全测试扫描，使用 OpenAPI 规范来提供待测试目标 API 的信息。
OpenAPI 规范以文件系统资源或 URL 形式提供。支持 JSON 和 YAML 这两种 OpenAPI 格式。

API 安全测试使用 OpenAPI 文档来生成请求体。当需要请求体时，
请求体的生成仅限以下请求体类型：

- `application/x-www-form-urlencoded`
- `multipart/form-data`
- `application/json`
- `application/xml`

## OpenAPI 和媒体类型

媒体类型（以前称为 MIME 类型）是用于标识文件格式和传输格式内容的标识符。OpenAPI 文档允许你指定某个操作可以接受不同的媒体类型，因此，一个给定的请求可以使用不同的文件内容发送数据。例如，一个用于更新用户数据的 `PUT /user` 操作，既可以接受 XML（媒体类型 `application/xml`）格式的数据，也可以接受 JSON（媒体类型 `application/json`）格式的数据。
OpenAPI 2.x 允许你全局或按操作指定可接受的媒体类型，而 OpenAPI 3.x 允许你按操作指定可接受的媒体类型。API 安全测试将检查列出的媒体类型，并尝试为每种受支持的媒体类型生成样本数据。

- 默认行为是选择一种受支持的媒体类型来使用。列表中的第一种受支持的媒体类型会被选中。此行为是可配置的。

使用不同的媒体类型（例如 `application/json` 和 `application/xml`）测试同一个操作（例如 `POST /user`）并非总是令人满意的。
例如，如果目标应用无论请求内容类型如何都执行相同的代码，那么完成测试会话将花费更长的时间，并且根据目标应用的情况，可能会报告与请求体相关的重复漏洞。

环境变量 `APISEC_OPENAPI_ALL_MEDIA_TYPES` 允许你指定在为给定操作生成请求时，是使用所有受支持的媒体类型，而不是只使用一种。当环境变量 `APISEC_OPENAPI_ALL_MEDIA_TYPES` 被设置为任何值时，API 安全测试会尝试为给定操作中所有受支持的媒体类型生成请求，而不是只生成一种。这将导致测试时间更长，因为会针对每种提供的媒体类型重复进行测试。

或者，变量 `APISEC_OPENAPI_MEDIA_TYPES` 用于提供一个要逐一进行测试的媒体类型列表。提供多种媒体类型会导致测试时间更长，因为会针对选定的每种媒体类型执行测试。当环境变量 `APISEC_OPENAPI_MEDIA_TYPES` 被设置为一个媒体类型列表时，创建请求时只会包含列出的媒体类型。

`APISEC_OPENAPI_MEDIA_TYPES` 中的多个媒体类型用冒号（`:`）分隔。例如，要将请求生成限制为媒体类型 `application/x-www-form-urlencoded` 和 `multipart/form-data`，请将环境变量 `APISEC_OPENAPI_MEDIA_TYPES` 设置为 `application/x-www-form-urlencoded:multipart/form-data`。创建请求时，仅包含此列表中受支持的媒体类型，但不受支持的媒体类型总会被跳过。一个媒体类型文本可能包含不同的部分。例如，`application/vnd.api+json; charset=UTF-8` 是由 `type "/" [tree "."] subtype ["+" suffix]* [";" parameter]` 组合而成。在生成请求时进行媒体类型过滤时，不考虑参数。

环境变量 `APISEC_OPENAPI_ALL_MEDIA_TYPES` 和 `APISEC_OPENAPI_MEDIA_TYPES` 允许你决定如何处理媒体类型。这些设置是互斥的。如果两者都启用，API 安全测试会报告错误。

### 使用 OpenAPI 规范配置 API 安全测试

要使用 OpenAPI 规范配置 API 安全测试扫描：

1.  在你的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate) [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
2.  [配置文件](variables.md#configuration-files)中定义了几个测试配置文件，分别启用了不同的检查。从 `Quick` 配置文件开始。
    使用此配置文件进行测试完成速度更快，便于更轻松地验证配置。
    通过在 `.gitlab-ci.yml` 文件中添加 `APISEC_PROFILE` CI/CD 变量来提供配置文件。
3.  以文件或 URL 的形式提供 OpenAPI 规范的位置。
    通过添加 `APISEC_OPENAPI` 变量来指定位置。
4.  目标 API 实例的基础 URL 也是必需的。请使用 `APISEC_TARGET_URL`
    变量或 `environment_url.txt` 文件提供此 URL。

    在项目根目录的 `environment_url.txt` 文件中添加 URL，非常适合在动态环境中进行测试。要针对在极狐GitLab CI/CD 流水线中动态创建的应用运行 API 安全测试，请让该应用将其 URL 持久化保存在 `environment_url.txt` 文件中。API 安全测试会自动解析该文件以查找其扫描目标。你可以在极狐GitLab 的 [Auto DevOps CI YAML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml) 中看到此示例。

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

这是 API 安全测试的最小配置。从这里你可以：

- [运行你的第一次扫描](#running-your-first-scan)。
- [添加认证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="http-archive-har"></a>

## HTTP 存档 (HAR)

[HTTP 存档格式 (HAR)](../../api_fuzzing/create_har_files.md) 是一种用于记录 HTTP 事务的存档文件格式。当与极狐GitLab API 安全测试扫描器一起使用时，HAR 文件必须包含调用待测试 Web API 的记录。API 安全测试扫描器提取所有请求，并使用它们执行测试。

你可以使用多种工具来生成 HAR 文件：

- [Insomnia Core](https://insomnia.rest/)：API 客户端
- [Chrome](https://www.google.com/chrome/)：浏览器
- [Firefox](https://www.mozilla.org/en-US/firefox/)：浏览器
- [Fiddler](https://www.telerik.com/fiddler)：Web 调试代理
- [极狐GitLab HAR Recorder](https://gitlab.com/gitlab-org/security-products/har-recorder)：命令行工具

> [!warning]
> HAR 文件可能包含敏感信息，例如身份验证令牌、API 密钥和会话 cookie。在将 HAR 文件添加到仓库之前，请先检查其内容。

### 使用 HAR 文件进行 API 安全测试扫描

要配置 API 安全测试以使用提供目标 API 测试信息的 HAR 文件：

1.  在你的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate) [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
2.  [配置文件](variables.md#configuration-files)中定义了几个测试配置文件，分别启用了不同的检查。从 `Quick` 配置文件开始。
    使用此配置文件进行测试完成速度更快，便于更轻松地验证配置。

    通过在 `.gitlab-ci.yml` 文件中添加 `APISEC_PROFILE` CI/CD 变量来提供配置文件。
3.  提供 HAR 文件的位置。你可以以文件路径或 URL 的形式提供位置。通过添加 `APISEC_HAR` 变量来指定位置。
4.  目标 API 实例的基础 URL 也是必需的。请使用 `APISEC_TARGET_URL`
    变量或 `environment_url.txt` 文件提供此 URL。

    在项目根目录的 `environment_url.txt` 文件中添加 URL，非常适合在动态环境中进行测试。要针对在极狐GitLab CI/CD 流水线中动态创建的应用运行 API 安全测试，请让该应用将其 URL 持久化保存在 `environment_url.txt` 文件中。API 安全测试会自动解析该文件以查找其扫描目标。你可以在极狐GitLab 的 [Auto DevOps CI YAML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml) 中看到此示例。

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

此示例是 API 安全测试的最小配置。从这里你可以：

- [运行你的第一次扫描](#running-your-first-scan)。
- [添加认证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="graphql-schema"></a>

## GraphQL Schema

{{< history >}}

- 在极狐GitLab 15.4 中引入对 GraphQL Schema 的支持。

{{< /history >}}

GraphQL 是一种用于 API 的查询语言，也是 REST API 的替代方案。
API 安全测试支持多种方式测试 GraphQL 端点：

- 使用 GraphQL Schema 进行测试。在极狐GitLab 15.4 中引入。
- 使用 GraphQL 查询的录制（HAR）进行测试。
- 使用包含 GraphQL 查询的 Postman Collection 进行测试。

本节介绍如何使用 GraphQL schema 进行测试。API 安全测试中的 GraphQL schema 支持能够从支持[内省](https://graphql.org/learn/introspection/)的端点查询 schema。
默认情况下，内省是启用的，以便像 GraphiQL 这样的工具能够工作。
有关如何启用内省的详细信息，请参见你的 GraphQL 框架文档。

### 使用 GraphQL 端点 URL 进行 API 安全测试扫描

API 安全测试中的 GraphQL 支持能够查询 GraphQL 端点的 schema。

> [!note]
> 为使此方法正常工作，GraphQL 端点必须支持内省查询。

要配置 API 安全测试以使用提供目标 API 测试信息的 GraphQL 端点 URL：

1.  在你的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate) [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
2.  提供 GraphQL 端点的路径，例如 `/api/graphql`。通过添加 `APISEC_GRAPHQL` 变量来指定位置。
3.  目标 API 实例的基础 URL 也是必需的。请使用 `APISEC_TARGET_URL`
    变量或 `environment_url.txt` 文件提供此 URL。

    在项目根目录的 `environment_url.txt` 文件中添加 URL，非常适合在动态环境中进行测试。更多信息，请参见[动态环境解决方案](../troubleshooting.md#dynamic-environment-solutions)。

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

此示例是 API 安全测试的最小配置。从这里你可以：

- [运行你的第一次扫描](#running-your-first-scan)。
- [添加认证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

### 使用 GraphQL Schema 文件进行 API 安全测试扫描

API 安全测试可以使用 GraphQL schema 文件来理解并测试禁用了内省的 GraphQL 端点。要使用 GraphQL schema 文件，它必须是内省 JSON 格式。可以使用第三方在线工具将 GraphQL schema 转换为内省 JSON 格式：<https://transform.tools/graphql-to-introspection-json>。

要配置 API 安全测试以使用提供目标 API 测试信息的 GraphQL schema 文件：

1.  在你的 `.gitlab-ci.yml` 文件中[包含](../../../../ci/yaml/_index.md#includetemplate) [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
2.  提供 GraphQL 端点路径，例如 `/api/graphql`。通过添加 `APISEC_GRAPHQL` 变量来指定路径。
3.  提供 GraphQL schema 文件的位置。你可以以文件路径或 URL 的形式提供位置。通过添加 `APISEC_GRAPHQL_SCHEMA` 变量来指定位置。
4.  目标 API 实例的基础 URL 也是必需的。请使用 `APISEC_TARGET_URL`
    变量或 `environment_url.txt` 文件提供此 URL。

    在项目根目录的 `environment_url.txt` 文件中添加 URL，非常适合在动态环境中进行测试。更多信息，请参见[动态环境解决方案](../troubleshooting.md#dynamic-environment-solutions)。

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

此示例是 API 安全测试的最小配置。从这里你可以：

- [运行你的第一次扫描](#running-your-first-scan)。
- [添加认证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

<a id="postman-collection"></a>

## Postman Collection

[Postman API Client](https://www.postman.com/product/api-client/) 是一个流行的工具，开发人员和测试人员用它来调用各种类型的 API。API 定义[可以导出为 Postman Collection 文件](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)，供 API 安全测试使用。导出时，请确保选择受支持的 Postman Collection 版本：v2.0 或 v2.1。

当与极狐GitLab API 安全测试扫描器一起使用时，Postman Collections 必须包含待测试 Web API 的定义以及有效数据。API 安全测试扫描器提取所有 API 定义，并使用它们执行测试。

> [!warning]
> Postman Collection 文件可能包含敏感信息，例如身份验证令牌、API 密钥和会话 cookie。在将 Postman Collection 文件添加到仓库之前，请先检查其内容。

### 使用 Postman Collection 文件进行 API 安全测试扫描

要配置 API 安全测试以使用提供目标 API 测试信息的 Postman Collection 文件：

1.  [包含](../../../../ci/yaml/_index.md#includetemplate) [`API-Security.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml)。
2.  [配置文件](variables.md#configuration-files)中定义了几个测试配置文件，分别启用了不同的检查。从 `Quick` 配置文件开始。
    使用此配置文件进行测试完成速度更快，便于更轻松地验证配置。

    通过在 `.gitlab-ci.yml` 文件中添加 `APISEC_PROFILE` CI/CD 变量来提供配置文件。
3.  以文件或 URL 的形式提供 Postman Collection 文件的位置。通过添加 `APISEC_POSTMAN_COLLECTION` 变量来指定位置。
4.  目标 API 实例的基础 URL 也是必需的。请使用 `APISEC_TARGET_URL`
    变量或 `environment_url.txt` 文件提供此 URL。

    在项目根目录的 `environment_url.txt` 文件中添加 URL，非常适合在动态环境中进行测试。要针对在极狐GitLab CI/CD 流水线中动态创建的应用运行 API 安全测试，请让该应用将其 URL 持久化保存在 `environment_url.txt` 文件中。API 安全测试会自动解析该文件以查找其扫描目标。你可以在极狐GitLab 的 [Auto DevOps CI YAML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml) 中看到此示例。

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

这是 API 安全测试的最小配置。从这里你可以：

- [运行你的第一次扫描](#running-your-first-scan)。
- [添加认证](customizing_analyzer_settings.md#authentication)。
- 了解如何[处理误报](#handling-false-positives)。

### Postman 变量

{{< history >}}

- 在极狐GitLab 15.1 中引入了对 Postman 环境文件格式的支持。
- 在极狐GitLab 15.1 中引入了对多个变量文件的支持。
- 在极狐GitLab 15.1 中引入了对 Postman 变量作用域：全局和环境的支持。

{{< /history >}}

#### Postman Client 中的变量

Postman 允许开发人员定义可在请求的不同部分使用的占位符。这些占位符称为变量，如[使用变量](https://learning.postman.com/docs/sending-requests/variables/variables/#using-variables)中所述。你可以使用变量在请求和脚本中存储和重用值。例如，你可以编辑 collection 以将变量添加到文档中：

![编辑 collection 变量选项卡视图](img/dast_api_postman_collection_edit_variable_v18_5.png)

或者，你也可以在环境中添加变量：

![编辑环境变量视图](img/dast_api_postman_environment_edit_variable_v18_5.png)

然后，你可以在 URL、标头等部分使用这些变量：

![编辑使用变量的请求视图](img/dast_api_postman_request_edit_v18_5.png)

Postman 已经从一个具有良好 UX 体验的基本客户端工具，发展成为一个更复杂的生态系统，允许使用脚本测试 API，创建触发二次请求的复杂集合，并在过程中设置变量。并非 Postman 生态系统中的每个功能都受支持。例如，不支持脚本。Postman 支持的主要重点是摄取 Postman Client 使用的 Postman Collection 定义，以及在工作区、环境和集合本身中定义的相关变量。

Postman 允许在不同的作用域中创建变量。每个作用域在 Postman 工具中具有不同级别的可见性。例如，你可以在一个 _全局环境_ 作用域中创建一个变量，该变量对每个操作定义和工作区都可见。你也可以在一个特定的 _环境_ 作用域中创建一个变量，该变量仅在选择使用该特定环境时才可见和使用。有些作用域并非总是可用的，例如在 Postman 生态系统中，你可以在 Postman Client 中创建请求，这些请求没有 _本地_ 作用域，但测试脚本有。

Postman 中的变量作用域可能是一个令人望而生畏的话题，并非每个人都熟悉它。在继续之前，请阅读 Postman 文档中的[变量作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#variable-scopes)。

如前所述，存在不同的变量作用域，每个作用域都有其用途，并可用于为你的 Postman 文档提供更大的灵活性。关于如何计算变量的值，有一个重要的说明，根据 Postman 文档：

> [!note]
> 如果在两个不同的作用域中声明了同名的变量，则使用具有最窄作用域的变量中存储的值。例如，如果存在一个名为 `username` 的全局变量和一个名为 `username` 的本地变量，则当请求运行时，将使用本地值。

以下是 Postman Client 和 API 安全测试支持的变量作用域的摘要：

- **全局环境（Global）作用域** 是一个特殊的预定义环境，在整个工作区中都可用。你也可以将 _全局环境_ 作用域称为 _全局_ 作用域。Postman Client 允许将全局环境导出为 JSON 文件，该文件可与 API 安全测试一起使用。
- **环境（Environment）作用域** 是由用户在 Postman Client 中创建的命名变量组。
  Postman Client 支持一个活动的环境与全局环境一起使用。在活动的用户创建的环境中定义的变量优先于在全局环境中定义的变量。Postman Client 允许将你的环境导出为 JSON 文件，该文件可与 API 安全测试一起使用。
- **Collection 作用域** 是在给定 collection 中声明的一组变量。Collection 变量对声明它们的 collection 以及嵌套的请求或 collection 可用。在 Collection 作用域中定义的变量优先于 _全局环境_ 作用域以及 _环境_ 作用域。
  Postman Client 可以将一个或多个 collection 导出为 JSON 文件，此 JSON 文件包含选定的 collection、请求和 collection 变量。
- **API 安全测试作用域** 是 API 安全测试添加的一个新作用域，允许用户提供额外的变量，或覆盖在其他受支持的作用域中定义的变量。Postman 不支持此作用域。_API 安全测试作用域_ 变量是使用[自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)提供的。
  - 覆盖在环境或 collection 中定义的值
  - 定义来自脚本的变量
  - 定义来自不受支持的 _数据作用域_ 的单行数据
- **数据（Data）作用域** 是一组变量，其名称和值来自 JSON 或 CSV 文件。Postman collection Runner 如 [Newman](https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/) 或 [Postman Collection Runner](https://learning.postman.com/docs/collections/running-collections/intro-to-collection-runs/) 会根据 JSON 或 CSV 文件中的条目数量多次执行 collection 中的请求。这些变量的一个良好用例是在 Postman 中使用脚本自动化测试。
  API 安全测试 **不** 支持从 CSV 或 JSON 文件读取数据。
- **本地（Local）作用域** 是在 Postman 脚本中定义的变量。API 安全测试 **不** 支持 Postman 脚本，进而也不支持在脚本中定义的变量。你仍然可以通过在一个受支持的作用域或自定义 JSON 格式中定义它们，来为脚本定义的变量提供值。

并非所有作用域都受 API 安全测试支持，并且在脚本中定义的变量也不受支持。下表按最广泛的作用域到最窄的作用域排序。

| 作用域                      | Postman | API 安全测试 | 注释                                           |
|----------------------------|:-------:|:--------------------:|:-------------------------------------------|
| 全局环境                     |   是   |         是         | 特殊的预定义环境                            |
| 环境                         |   是   |         是         | 命名环境                                    |
| Collection                   |   是   |         是         | 在你的 postman collection 中定义             |
| API 安全测试作用域            |   否   |         是         | 由 API 安全测试添加的自定义作用域               |
| 数据                         |   是   |         否          | CSV 或 JSON 格式的外部文件                   |
| 本地                         |   是   |         否          | 在脚本中定义的变量                           |
有关如何在不同作用域定义变量和导出变量的详细信息，请参见：

- [定义集合变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-collection-variables)
- [定义环境变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-environment-variables)
- [定义全局变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-global-variables)

<a id="exporting-from-postman-client"></a>

##### 从 Postman Client 导出

Postman Client 允许你导出不同文件格式，例如，你可以导出 Postman 集合或 Postman 环境。
导出的环境可以是全局环境（始终可用）或你之前创建的任何自定义环境。当你导出 Postman 集合时，它可能仅包含 _collection_ 和 _local_ 作用域变量的声明；_environment_ 作用域变量不包含在内。

要获取 _environment_ 作用域变量的声明，你必须当时导出给定的环境。每个导出的文件仅包含所选环境的变量。

有关在不同支持的作用域导出变量的更多详细信息，请参见：

- [导出集合](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)
- [导出环境](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)
- [下载全局环境](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)

<a id="api-security-testing-scope-custom-json-file-format"></a>

#### API 安全测试作用域，自定义 JSON 文件格式

自定义 JSON 文件格式是一个 JSON 对象，其中每个对象属性代表一个变量名，属性值代表变量值。你可以使用喜欢的文本编辑器创建此文件，也可以由流水线中的早期作业生成。

此示例在 API 安全测试作用域中定义两个变量 `base_url` 和 `token`：

```json
{
  "base_url": "http://127.0.0.1/",
  "token": "Token 84816165151"
}
```

<a id="using-scopes-with-api-security-testing"></a>

#### 将作用域用于 API 安全测试

以下作用域在 [极狐GitLab 15.1 及更高版本](https://jihulab.com/gitlab-cn/gitlab/-/issues/356312) 中受支持：_global_、_environment_、_collection_ 和 _GitLab API security testing_。极狐GitLab 15.0 及更早版本仅支持 _collection_ 和 _GitLab API security testing_ 作用域。

下表提供了将作用域文件/URL 映射到 API 安全测试配置变量的快速参考：

| 作用域              |  如何提供 |
| ------------------ | --------------- |
| 全局环境 | APISEC_POSTMAN_COLLECTION_VARIABLES |
| 环境        | APISEC_POSTMAN_COLLECTION_VARIABLES |
| 集合         | APISEC_POSTMAN_COLLECTION           |
| API 安全测试作用域 | APISEC_POSTMAN_COLLECTION_VARIABLES |
| 数据               | 不支持   |
| 本地              | 不支持   |

Postman Collection 文档自动包含任何 _collection_ 作用域变量。Postman Collection 通过配置变量 `APISEC_POSTMAN_COLLECTION` 提供。此变量可设置为单个 [导出的 Postman 集合](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)。

其他作用域的变量通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。该配置变量在 [极狐GitLab 15.1 及更高版本](https://jihulab.com/gitlab-cn/gitlab/-/issues/356312) 中支持以逗号（`,`）分隔的文件列表。极狐GitLab 15.0 及更早版本仅支持单个文件。提供的文件顺序不重要，因为文件提供了所需的作用域信息。

配置变量 `APISEC_POSTMAN_COLLECTION_VARIABLES` 可设置为：

- [导出的全局环境](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)
- [导出的环境](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)
- [API 安全测试自定义 JSON 格式](#api-security-testing-scope-custom-json-file-format)

<a id="undefined-postman-variables"></a>

#### 未定义的 Postman 变量

API 安全测试引擎有可能找不到 Postman 集合文件使用的所有变量引用。某些情况可能是：

- 你正在使用 _data_ 或 _local_ 作用域变量，如前所述，API 安全测试不支持这些作用域。因此，假设这些变量的值没有通过 [API 安全测试作用域](#api-security-testing-scope-custom-json-file-format) 提供，那么 _data_ 和 _local_ 作用域变量的值是未定义的。
- 变量名输入错误，名称与定义的变量不匹配。
- Postman Client 支持 API 安全测试不支持的新动态变量。

在可能的情况下，API 安全测试在处理未定义变量时遵循与 Postman Client 相同的行为。变量引用的文本保持不变，不进行文本替换。相同的行为也适用于任何不受支持的动态变量。

例如，如果 Postman Collection 中的请求定义引用了变量 `{{full_url}}` 且未找到该变量，则它会保持不变，值为 `{{full_url}}`。

<a id="dynamic-postman-variables"></a>

#### 动态 Postman 变量

除了用户可以在各种作用域级别定义的变量外，Postman 还有一组称为 _dynamic_ 变量的预定义变量。[_dynamic_ 变量](https://learning.postman.com/docs/tests-and-scripts/write-scripts/variables-list/) 已预先定义，其名称以美元符号（`$`）为前缀，例如 `$guid`。_dynamic_ 变量可以像其他变量一样使用，并且在 Postman Client 中，它们在请求/集合运行期间产生随机值。

API 安全测试和 Postman 之间的一个重要区别在于，API 安全测试对同一动态变量的每次使用都返回相同的值。这与 Postman Client 的行为不同，后者对同一动态变量的每次使用都返回随机值。换句话说，API 安全测试使用静态值作为动态变量，而 Postman 使用随机值。

扫描过程中支持的动态变量如下：

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

在此示例中，[_global_ 作用域从 Postman Client 导出](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments) 为 `global-scope.json`，并通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供给 API 安全测试。

以下是使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 的示例：

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

在此示例中，[_environment_ 作用域从 Postman Client 导出](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments) 为 `environment-scope.json`，并通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供给 API 安全测试。

以下是使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 的示例：

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

#### 示例：集合作用域

_collection_ 作用域变量包含在导出的 Postman Collection 文件中，并通过 `APISEC_POSTMAN_COLLECTION` 配置变量提供。

以下是使用 `APISEC_POSTMAN_COLLECTION` 的示例：

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

API 安全测试作用域有两个主要用途：定义 API 安全测试不支持的 _data_ 和 _local_ 作用域变量，以及更改另一个作用域中已定义变量的现有值。API 安全测试作用域通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。

以下是使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 的示例：

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

文件 `dast-api-scope.json` 使用 [自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)。这是一个键值对属性对象。键是变量名，值是变量值。例如：

```json
{
  "base_url": "http://127.0.0.1/",
  "token": "Token 84816165151"
}
```

<a id="example-multiple-scopes"></a>

#### 示例：多个作用域

在此示例中，配置了 _global_ 作用域、_environment_ 作用域和 _collection_ 作用域。第一步是导出各种作用域。

- [导出 _global_ 作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments) 为 `global-scope.json`
- [导出 _environment_ 作用域](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments) 为 `environment-scope.json`
- 导出包含 _collection_ 作用域的 Postman Collection 为 `postman-collection.json`

Postman Collection 使用 `APISEC_POSTMAN_COLLECTION` 变量提供，而其他作用域使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 提供。API 安全测试可以使用每个文件中提供的数据识别提供的文件匹配哪个作用域。

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

在使用导出作用域时，通常需要更改变量的值以用于 API 安全测试。例如，一个 _collection_ 作用域变量可能包含一个名为 `api_version` 且值为 `v2` 的变量，而你的测试需要值为 `v1`。无需修改导出的集合来更改值，可以使用 API 安全测试作用域更改其值。这是因为 _API security testing_ 作用域的优先级高于所有其他作用域。

_collection_ 作用域变量包含在导出的 Postman Collection 文件中，并通过 `APISEC_POSTMAN_COLLECTION` 配置变量提供。

API 安全测试作用域通过 `APISEC_POSTMAN_COLLECTION_VARIABLES` 配置变量提供，但首先需要创建文件。
文件 `dast-api-scope.json` 使用 [自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format)。这是一个键值对属性对象。键是变量名，值是变量值。例如：

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

在使用导出作用域时，通常需要更改变量的值以用于 API 安全测试。例如，一个 _environment_ 作用域可能包含一个名为 `api_version` 且值为 `v2` 的变量，而你的测试需要值为 `v1`。无需修改导出的文件来更改值，可以使用 API 安全测试作用域。这是因为 _API security testing_ 作用域的优先级高于所有其他作用域。

在此示例中，配置了 _global_ 作用域、_environment_ 作用域、_collection_ 作用域和 _API security testing_ 作用域。第一步是导出并创建各种作用域。

- [导出 _global_ 作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments) 为 `global-scope.json`
- [导出 _environment_ 作用域](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments) 为 `environment-scope.json`
- 导出包含 _collection_ 作用域的 Postman Collection 为 `postman-collection.json`

通过使用 [自定义 JSON 文件格式](#api-security-testing-scope-custom-json-file-format) 创建文件 `dast-api-scope.json` 来使用 API 安全测试作用域。这是一个键值对属性对象。键是变量名，值是变量值。例如：

```json
{
  "api_version": "v1"
}
```

Postman Collection 使用 `APISEC_POSTMAN_COLLECTION` 变量提供，而其他作用域使用 `APISEC_POSTMAN_COLLECTION_VARIABLES` 提供。API 安全测试可以使用每个文件中提供的数据识别提供的文件匹配哪个作用域。

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

## 运行首次扫描

正确配置后，CI/CD 流水线会包含一个 `dast` 阶段和一个 `dast_api` 作业。该作业仅在提供了无效配置时才会失败。在典型操作中，即使在测试期间识别到漏洞，作业也始终成功。

漏洞会显示在 **安全** 流水线标签页上，并带有套件名称。当针对仓库的默认分支进行测试时，API 安全测试漏洞也会显示在安全与合规的漏洞报告中。

为防止报告过多漏洞，API 安全扫描器会限制每个操作报告的漏洞数量。

<a id="viewing-api-security-testing-vulnerabilities"></a>

## 查看 API 安全测试漏洞

API 安全测试分析器会生成一个 JSON 报告，该报告会被收集并用于 [将漏洞填充到极狐GitLab 漏洞屏幕中](#view-details-of-an-api-security-testing-vulnerability)。

有关限制误报数量的配置更改，请参见 [处理误报](#handling-false-positives)。

<a id="view-details-of-an-api-security-testing-vulnerability"></a>

### 查看 API 安全测试漏洞详情

按照以下步骤查看漏洞详情：

1. 你可以在项目或合并请求中查看漏洞：

   - 在项目中，访问项目的 **安全** > **漏洞报告** 页面。此页面仅显示默认分支的所有漏洞。
   - 在合并请求中，访问合并请求的 **安全** 部分，然后选择 **展开** 按钮。API 安全测试漏洞可在标签为 **DAST 检测到 N 个潜在漏洞** 的部分中找到。选择标题以显示漏洞详情。

1. 选择漏洞标题以显示详情。下表描述了这些详情。

   | 字段               | 描述                                                                             |
   |:--------------------|:----------------------------------------------------------------------------------------|
   | 描述         | 漏洞描述，包括修改的内容。                           |
   | 项目             | 检测到漏洞的命名空间和项目。                          |
   | 方法              | 用于检测漏洞的 HTTP 方法。                                           |
   | URL                 | 检测到漏洞的 URL。                                            |
   | 请求             | 导致漏洞的 HTTP 请求。                                         |
   | 未修改响应 | 未修改请求的响应。典型的正常响应看起来像未修改响应。|
   | 实际响应     | 从测试请求接收到的响应。                                                    |
   | 证据            | 极狐GitLab 如何确定发生了漏洞。                                         |
   | 标识符         | 用于发现此漏洞的 API 安全测试检查。                         |
   | 严重性            | 漏洞的严重性。                                                          |
   | 扫描器类型        | 用于执行测试的扫描器。                                                        |

<a id="security-dashboard"></a>

### 安全仪表板

安全仪表板是获取群组、项目和流水线中所有安全漏洞概况的好地方。有关更多信息，请参见 [安全仪表板文档](../../security_dashboard/_index.md)。
<a id="interacting-with-the-vulnerabilities"></a>

### 与漏洞交互

一旦发现漏洞，你可以与之交互。阅读更多关于如何[处理漏洞](../../vulnerabilities/_index.md)的信息。

<a id="handling-false-positives"></a>

### 处理误报

可以通过以下几种方式处理误报：

- 忽略该漏洞。
- 某些检查有多种检测漏洞的方法，称为_断言_。断言也可以关闭和配置。例如，API 安全测试扫描器默认使用 HTTP 状态码来帮助识别何时是真正的问题。如果在测试期间 API 返回 500 错误，这会创建一个漏洞。但这并不总是期望的，因为一些框架经常返回 500 错误。
- 关闭产生误报的检查。这可以防止该检查生成任何漏洞。示例检查包括 SQL 注入检查和 JSON 劫持检查。

<a id="turn-off-a-check"></a>

#### 关闭一个检查

检查执行特定类型的测试，并且可以为特定的配置配置文件打开和关闭。提供的[配置文件](variables.md#configuration-files)定义了几个你可以使用的配置文件。配置文件中的配置文件定义列出了扫描期间活动的所有检查。要关闭特定检查，请将其从配置文件中的配置文件定义中移除。配置文件在配置文件的 `Profiles` 部分中定义。

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

要关闭 JSON 劫持检查，你可以移除这些行：

```yaml
          - Name: JsonHijackingCheck
```

这将得到以下 YAML：

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

断言检测由检查产生的测试中的漏洞。许多检查支持多个断言，例如日志分析、响应分析和状态码。当发现漏洞时，会提供所使用的断言。要识别默认开启哪些断言，请查看配置文件中的检查默认配置。该部分称为 `Checks`。

此示例显示 SQL 注入检查：

```yaml
- Name: SqlInjectionCheck
  Configuration:
    UserInjections: []
  Assertions:
    - Name: LogAnalysisAssertion
    - Name: ResponseAnalysisAssertion
    - Name: StatusCodeAssertion
```

在这里你可以看到默认开启了三个断言。误报的常见来源是 `StatusCodeAssertion`。要关闭它，请在 `Profiles` 部分修改其配置。此示例仅提供其他两个断言（`LogAnalysisAssertion`、`ResponseAnalysisAssertion`）。这可以防止 `SqlInjectionCheck` 使用 `StatusCodeAssertion`：

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