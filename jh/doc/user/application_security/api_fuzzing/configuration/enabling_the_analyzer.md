---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 启用分析器
---

先决条件：

- 以下一种 Web API 类型：
  - REST API
  - SOAP
  - GraphQL
  - 表单体、JSON 或 XML
- 以下一种用于提供待测试 API 的资产：
  - OpenAPI v2 或 v3 API 定义
  - 待测试 API 请求的 HTTP 存档 (HAR)
  - Postman Collection v2.0 或 v2.1

  > [!warning]
  > **切勿** 对生产服务器运行模糊测试。它不仅能够执行 API 的任何功能，还可能触发 API 中的缺陷。这包括修改和删除数据等操作。仅在测试服务器上运行模糊测试。

要启用 Web API 模糊测试，请使用 Web API 模糊测试配置表单。

- 有关手动配置说明，请根据 API 类型查看相应部分：
  - [OpenAPI 规范](#openapi-specification)
  - [GraphQL 模式](#graphql-schema)
  - [HTTP 存档 (HAR)](#http-archive-har)
  - [Postman Collection](#postman-collection)
- 否则，请参阅 [Web API 模糊测试配置表单](#web-api-fuzzing-configuration-form)。

API 模糊测试配置文件必须位于您仓库的 `.gitlab` 目录中。

<a id="web-api-fuzzing-configuration-form"></a>

## Web API 模糊测试配置表单

API 模糊测试配置表单可帮助您创建或修改项目的 API 模糊测试配置。该表单允许您为最常见的 API 模糊测试选项选择值，并构建一个 YAML 片段，您可以将其粘贴到极狐GitLab CI/CD 配置中。

<a id="configure-web-api-fuzzing-in-the-ui"></a>

### 在 UI 中配置 Web API 模糊测试

要生成 API 模糊测试配置片段：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **API 模糊测试** 行中，选择 **启用 API 模糊测试**。
1. 填写字段。有关详细信息，请参阅 [可用的 CI/CD 变量](variables.md)。
1. 选择 **生成代码片段**。
   将打开一个对话框，其中包含与您在表单中选择的选项对应的 YAML 片段。
1. 执行以下操作之一：
   1. 要将片段复制到剪贴板，请选择 **仅复制代码**。
   1. 要将片段添加到项目的 `.gitlab-ci.yml` 文件中，请选择
      **复制代码并打开 `.gitlab-ci.yml` 文件**。流水线编辑器将打开。
      1. 将片段粘贴到 `.gitlab-ci.yml` 文件中。
      1. 选择 **语法检查** 标签以确认编辑后的 `.gitlab-ci.yml` 文件有效。
      1. 选择 **编辑** 标签，然后选择 **提交变更**。

当片段被提交到 `.gitlab-ci.yml` 文件时，流水线将包含一个 API 模糊测试作业。

<a id="openapi-specification"></a>

## OpenAPI 规范

[OpenAPI 规范](https://www.openapis.org/)（以前称为 Swagger 规范）是 REST API 的 API 描述格式。
本节介绍如何使用 OpenAPI 规范配置 API 模糊测试，以提供有关要测试的目标 API 的信息。
OpenAPI 规范以文件系统资源或 URL 的形式提供。支持 JSON 和 YAML 两种 OpenAPI 格式。

API 模糊测试使用 OpenAPI 文档生成请求体。当需要请求体时，请求体生成仅限于以下请求体类型：

- `application/x-www-form-urlencoded`
- `multipart/form-data`
- `application/json`
- `application/xml`

## OpenAPI 和媒体类型

媒体类型（以前称为 MIME 类型）是用于标识文件格式和传输格式内容的标识符。OpenAPI 文档允许您指定某个操作可以接受不同的媒体类型，因此给定的请求可以使用不同的文件内容发送数据。例如，一个用于更新用户数据的 `PUT /user` 操作可以接受 XML（媒体类型 `application/xml`）或 JSON（媒体类型 `application/json`）格式的数据。
OpenAPI 2.x 允许您全局或按操作指定接受的媒体类型，而 OpenAPI 3.x 允许您按操作指定接受的媒体类型。API 模糊测试会检查列出的媒体类型，并尝试为每种支持的媒体类型生成示例数据。

- 默认行为是选择一种支持的媒体类型来使用。从列表中选择第一种支持的媒体类型。此行为是可配置的。

使用不同的媒体类型（例如，`application/json` 和 `application/xml`）测试同一个操作（例如，`POST /user`）并不总是可取的。
例如，如果目标应用程序无论请求内容类型如何都执行相同的代码，那么完成测试会话所需的时间会更长，并且根据目标应用程序的不同，它可能会报告与请求体相关的重复漏洞。

环境变量 `FUZZAPI_OPENAPI_ALL_MEDIA_TYPES` 允许您指定在为给定操作生成请求时是否使用所有支持的媒体类型，而不是只使用一种。当环境变量 `FUZZAPI_OPENAPI_ALL_MEDIA_TYPES` 设置为任何值时，API 模糊测试会尝试为给定操作中所有受支持的媒体类型生成请求，而不是仅使用一种。这会导致测试时间更长，因为会针对每种提供的媒体类型重复测试。

或者，可以使用变量 `FUZZAPI_OPENAPI_MEDIA_TYPES` 提供一个媒体类型列表，并分别测试每种类型。提供多种媒体类型会导致测试时间更长，因为会针对每种选定的媒体类型执行测试。当环境变量 `FUZZAPI_OPENAPI_MEDIA_TYPES` 设置为媒体类型列表时，在创建请求时仅包含列出的媒体类型。

`FUZZAPI_OPENAPI_MEDIA_TYPES` 中的多个媒体类型必须用冒号 (`:`) 分隔。例如，要将请求生成限制为媒体类型 `application/x-www-form-urlencoded` 和 `multipart/form-data`，请将环境变量 `FUZZAPI_OPENAPI_MEDIA_TYPES` 设置为 `application/x-www-form-urlencoded:multipart/form-data`。在创建请求时，仅包含此列表中受支持的媒体类型，但始终会跳过不受支持的媒体类型。媒体类型文本可能包含不同的部分。例如，`application/vnd.api+json; charset=UTF-8` 是 `type "/" [tree "."] subtype ["+" suffix]* [";" parameter]` 的组合。在生成请求时过滤媒体类型时，不考虑参数。

环境变量 `FUZZAPI_OPENAPI_ALL_MEDIA_TYPES` 和 `FUZZAPI_OPENAPI_MEDIA_TYPES` 允许您决定如何处理媒体类型。这些设置是互斥的。如果两者都启用，API 模糊测试会报告错误。

<a id="configure-web-api-fuzzing-with-an-openapi-specification"></a>

### 使用 OpenAPI 规范配置 Web API 模糊测试

要使用 OpenAPI 规范在极狐GitLab 中配置 API 模糊测试：

1. 将 `fuzz` 阶段添加到您的 `.gitlab-ci.yml` 文件中。
1. [引入](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Fuzzing.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml)
   到您的 `.gitlab-ci.yml` 文件中。
1. 通过在您的 `.gitlab-ci.yml` 文件中添加 `FUZZAPI_PROFILE` CI/CD 变量来提供配置。
   该配置指定运行多少次测试。将 `Quick-10` 替换为您选择的配置。有关更多详细信息，请参阅 [API 模糊测试配置](customizing_analyzer_settings.md#api-fuzzing-profiles)。

   ```yaml
   variables:
     FUZZAPI_PROFILE: Quick-10
   ```

1. 提供 OpenAPI 规范的位置。您可以将规范作为文件
   或 URL 提供。通过添加 `FUZZAPI_OPENAPI` 变量来指定位置。
1. 提供目标 API 实例的基本 URL。使用 `FUZZAPI_TARGET_URL` 变量或
   `environment_url.txt` 文件。

   将 URL 添加到项目根目录下的 `environment_url.txt` 文件中非常适合在
   动态环境中进行测试。要针对在极狐GitLab CI/CD 流水线中动态创建的应用程序运行 API 模糊测试，请让应用程序将其 URL 保存到 `environment_url.txt` 文件中。
   API 模糊测试会自动解析该文件以找到其扫描目标。您可以查看
   [Auto DevOps CI YAML](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml) 中的一个示例。

使用 OpenAPI 规范的 `.gitlab-ci.yml` 文件示例：

   ```yaml
   stages:
     - fuzz

   include:
     - template: Security/API-Fuzzing.gitlab-ci.yml

   variables:
     FUZZAPI_PROFILE: Quick-10
     FUZZAPI_OPENAPI: test-api-specification.json
     FUZZAPI_TARGET_URL: http://test-deployment/
   ```

这是 API 模糊测试的最小配置。在此基础上，您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份认证](customizing_analyzer_settings.md#authentication)。
- 了解如何 [处理误报](#handling-false-positives)。

有关 API 模糊测试配置选项的详细信息，请参阅 [可用的 CI/CD 变量](variables.md)。

<a id="http-archive-har"></a>

## HTTP 存档 (HAR)

[HTTP 存档格式 (HAR)](http://www.softwareishard.com/blog/har-12-spec/)
是一种用于记录 HTTP 事务的存档文件格式。当与极狐GitLab API 模糊测试器一起使用时，HAR 必须包含要测试的 Web API 的调用记录。API 模糊测试器会提取所有请求并
使用它们来执行测试。

有关更多详细信息，包括如何创建 HAR 文件，请参阅 [HTTP 存档格式](../create_har_files.md)。

> [!warning]
> HAR 文件可能包含敏感信息，例如身份认证令牌、API 密钥和会话
> cookie。在将 HAR 文件添加到仓库之前，您应该检查其内容。

<a id="configure-web-api-fuzzing-with-a-har-file"></a>

### 使用 HAR 文件配置 Web API 模糊测试

要配置 API 模糊测试以使用 HAR 文件：

1. 将 `fuzz` 阶段添加到您的 `.gitlab-ci.yml` 文件中。
1. [引入](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Fuzzing.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml)
   到您的 `.gitlab-ci.yml` 文件中。
1. 通过在您的 `.gitlab-ci.yml` 文件中添加 `FUZZAPI_PROFILE` CI/CD 变量来提供配置。
   该配置指定运行多少次测试。将 `Quick-10` 替换为您选择的配置。有关更多详细信息，请参阅 [API 模糊测试配置](customizing_analyzer_settings.md#api-fuzzing-profiles)。

   ```yaml
   variables:
     FUZZAPI_PROFILE: Quick-10
   ```

1. 提供 HAR 规范的位置。您可以将规范作为文件
   或 URL 提供。通过添加 `FUZZAPI_HAR` 变量来指定位置。
1. 还需要目标 API 实例的基本 URL。使用 `FUZZAPI_TARGET_URL`
   变量或 `environment_url.txt` 文件提供。

   将 URL 添加到项目根目录下的 `environment_url.txt` 文件中非常适合在
   动态环境中进行测试。要针对在极狐GitLab CI/CD 流水线中动态创建的应用程序运行 API 模糊测试，请让应用程序将其域名保存到 `environment_url.txt` 文件中。API 模糊测试会自动解析该文件以找到其扫描目标。您可以查看 [极狐GitLab Auto DevOps CI YAML 中的示例](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml)。

使用 HAR 文件的 `.gitlab-ci.yml` 文件示例：

   ```yaml
   stages:
     - fuzz

   include:
     - template: Security/API-Fuzzing.gitlab-ci.yml

   variables:
     FUZZAPI_PROFILE: Quick-10
     FUZZAPI_HAR: test-api-recording.har
     FUZZAPI_TARGET_URL: http://test-deployment/
   ```

这是 API 模糊测试的最小配置。在此基础上，您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份认证](customizing_analyzer_settings.md#authentication)。
- 了解如何 [处理误报](#handling-false-positives)。

有关 API 模糊测试配置选项的详细信息，请参阅 [可用的 CI/CD 变量](variables.md)。

<a id="graphql-schema"></a>

## GraphQL 模式

{{< history >}}

- 在极狐GitLab 15.4 中引入。

{{< /history >}}

GraphQL 是一种用于 API 的查询语言，是 REST API 的替代方案。
API 模糊测试支持以多种方式测试 GraphQL 端点：

- 使用 GraphQL 模式进行测试。在极狐GitLab 15.4 中引入。
- 使用 GraphQL 查询的录制 (HAR) 进行测试。
- 使用包含 GraphQL 查询的 Postman Collection 进行测试。

本节介绍了如何使用 GraphQL 模式进行测试。API 模糊测试中的 GraphQL 模式支持能够从支持 introspection 的端点查询模式。
默认情况下，introspection是启用的，以允许像 GraphiQL 这样的工具工作。

<a id="api-fuzzing-scanning-with-a-graphql-endpoint-url"></a>

### 使用 GraphQL 端点 URL 进行 API 模糊测试扫描

API 模糊测试中的 GraphQL 支持能够查询 GraphQL 端点以获取模式。

> [!note]
> 要使此方法正常工作，GraphQL 端点必须支持 introspection 查询。

要配置 API 模糊测试以使用提供有关要测试的目标 API 信息的 GraphQL 端点 URL：

1. [引入](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Fuzzing.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml) 到您的 `.gitlab-ci.yml` 文件中。
1. 提供 GraphQL 端点路径，例如 `/api/graphql`。通过添加 `FUZZAPI_GRAPHQL` 变量来指定路径。
1. 还需要目标 API 实例的基本 URL。使用 `FUZZAPI_TARGET_URL`
   变量或 `environment_url.txt` 文件提供。

   将 URL 添加到项目根目录下的 `environment_url.txt` 文件中非常适合在
   动态环境中进行测试。有关更多信息，请参阅 [动态环境解决方案](../troubleshooting.md#dynamic-environment-solutions)。

使用 GraphQL 端点 URL 的完整配置示例：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

apifuzzer_fuzz:
  variables:
    FUZZAPI_GRAPHQL: /api/graphql
    FUZZAPI_TARGET_URL: http://test-deployment/
```

这是 API 模糊测试的最小配置。在此基础上，您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份认证](customizing_analyzer_settings.md#authentication)。
- 了解如何 [处理误报](#handling-false-positives)。

<a id="api-fuzzing-with-a-graphql-schema-file"></a>

### 使用 GraphQL 模式文件进行 API 模糊测试

API 模糊测试可以使用 GraphQL 模式文件来理解和测试已禁用 introspection 的 GraphQL 端点。要使用 GraphQL 模式文件，它必须是 introspection JSON 格式。可以使用在线第三方工具将 GraphQL 模式转换为 introspection JSON 格式：<https://transform.tools/graphql-to-introspection-json>。

要配置 API 模糊测试以使用提供有关要测试的目标 API 信息的 GraphQL 模式文件：

1. [引入](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Fuzzing.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml) 到您的 `.gitlab-ci.yml` 文件中。
1. 提供 GraphQL 端点路径，例如 `/api/graphql`。通过添加 `FUZZAPI_GRAPHQL` 变量来指定路径。
1. 提供 GraphQL 模式文件的位置。您可以将位置指定为文件路径
   或 URL。通过添加 `FUZZAPI_GRAPHQL_SCHEMA` 变量来指定位置。
1. 还需要目标 API 实例的基本 URL。使用 `FUZZAPI_TARGET_URL`
   变量或 `environment_url.txt` 文件提供。

   将 URL 添加到项目根目录下的 `environment_url.txt` 文件中非常适合在
   动态环境中进行测试。有关更多信息，请参阅 [动态环境解决方案](../troubleshooting.md#dynamic-environment-solutions)。

使用 GraphQL 模式文件的完整配置示例：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

apifuzzer_fuzz:
  variables:
    FUZZAPI_GRAPHQL: /api/graphql
    FUZZAPI_GRAPHQL_SCHEMA: test-api-graphql.schema
    FUZZAPI_TARGET_URL: http://test-deployment/
```

使用 GraphQL 模式文件 URL 的完整配置示例：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

apifuzzer_fuzz:
  variables:
    FUZZAPI_GRAPHQL: /api/graphql
    FUZZAPI_GRAPHQL_SCHEMA: http://file-store/files/test-api-graphql.schema
    FUZZAPI_TARGET_URL: http://test-deployment/
```

这是 API 模糊测试的最小配置。在此基础上，您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份认证](customizing_analyzer_settings.md#authentication)。
- 了解如何 [处理误报](#handling-false-positives)。

<a id="postman-collection"></a>

## Postman Collection

[Postman API 客户端](https://www.postman.com/product/api-client/) 是一个流行的工具，
开发人员和测试人员使用它来调用各种类型的 API。API 定义
[可以导出为 Postman Collection 文件](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)
用于 API 模糊测试。导出时，请确保选择受支持的 Postman Collection 版本：v2.0 或 v2.1。

当与极狐GitLab API 模糊测试器一起使用时，Postman Collection 必须包含要测试的 Web API 的定义以及有效数据。API 模糊测试器会提取所有 API 定义并使用它们来执行测试。

> [!warning]
> Postman Collection 文件可能包含敏感信息，例如身份认证令牌、API 密钥和会话 cookie。在将 Postman Collection 文件添加到仓库之前，您应该检查其内容。

<a id="configure-web-api-fuzzing-with-a-postman-collection-file"></a>

### 使用 Postman Collection 文件配置 Web API 模糊测试

要配置 API 模糊测试以使用 Postman Collection 文件：

1. 将 `fuzz` 阶段添加到您的 `.gitlab-ci.yml` 文件中。
1. [引入](../../../../ci/yaml/_index.md#includetemplate)
   [`API-Fuzzing.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml)
   到您的 `.gitlab-ci.yml` 文件中。
1. 通过在您的 `.gitlab-ci.yml` 文件中添加 `FUZZAPI_PROFILE` CI/CD 变量来提供配置。
   该配置指定运行多少次测试。将 `Quick-10` 替换为您选择的配置。有关更多详细信息，请参阅 [API 模糊测试配置](customizing_analyzer_settings.md#api-fuzzing-profiles)。

   ```yaml
   variables:
     FUZZAPI_PROFILE: Quick-10
   ```

1. 提供 Postman Collection 规范的位置。您可以将规范作为文件或 URL 提供。通过添加 `FUZZAPI_POSTMAN_COLLECTION` 变量指定位置。
1. 提供目标 API 实例的基本 URL。使用 `FUZZAPI_TARGET_URL` 变量或 `environment_url.txt` 文件。

   将 URL 添加到项目根目录下的 `environment_url.txt` 文件中非常适合在动态环境中进行测试。要针对在极狐GitLab CI/CD 流水线中动态创建的应用程序运行 API 模糊测试，请让应用程序将其域名保存到 `environment_url.txt` 文件中。API 模糊测试会自动解析该文件以找到其扫描目标。您可以查看 [极狐GitLab Auto DevOps CI YAML 中的示例](https://jihulab.com/gitlab-cn/gitlab-cn/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml)。

使用 Postman Collection 文件的 `.gitlab-ci.yml` 文件示例：

   ```yaml
   stages:
     - fuzz

   include:
     - template: Security/API-Fuzzing.gitlab-ci.yml

   variables:
     FUZZAPI_PROFILE: Quick-10
     FUZZAPI_POSTMAN_COLLECTION: postman-collection_serviceA.json
     FUZZAPI_TARGET_URL: http://test-deployment/
   ```

这是 API 模糊测试的最小配置。在此基础上，您可以：

- [运行您的第一次扫描](#running-your-first-scan)。
- [添加身份认证](customizing_analyzer_settings.md#authentication)。
- 了解如何 [处理误报](#handling-false-positives)。

有关 API 模糊测试配置选项的详细信息，请参阅 [可用的 CI/CD 变量](variables.md)。

<a id="postman-variables"></a>

### Postman 变量

{{< history >}}

- 在极狐GitLab 15.1 中引入。
- 在极狐GitLab 15.1 中引入。
- 在极狐GitLab 15.1 中引入。

{{< /history >}}

#### Postman 客户端中的变量

Postman 允许开发者定义可在请求的不同部分使用的占位符。这些占位符称为变量，如 [使用变量](https://learning.postman.com/docs/sending-requests/variables/variables/) 中所述。
您可以使用变量在请求和脚本中存储和重用值。例如，您可以编辑集合以向文档添加变量：

![编辑集合变量选项卡视图](img/api_fuzzing_postman_collection_edit_variable_v18_5.png)

或者，您可以在环境中添加变量：

![编辑环境变量视图](img/api_fuzzing_postman_environment_edit_variable_v18_5.png)

然后，您可以在 URL、标头等部分中使用这些变量：

![使用变量编辑请求视图](img/api_fuzzing_postman_request_edit_v18_5.png)

Postman 已经从一个具有良好用户体验的基本客户端工具发展成为一个更复杂的生态系统，它允许使用脚本测试 API、创建触发二级请求的复杂集合，并在此过程中设置变量。并非 Postman 生态系统中的每个功能都受支持。例如，脚本不受支持。Postman 支持的主要重点是摄取 Postman 客户端使用的 Postman Collection 定义，以及在工作区、环境和集合本身中定义的相关变量。

Postman 允许在不同的作用域中创建变量。每个作用域在 Postman 工具中具有不同的可见性级别。例如，您可以在全局环境作用域中创建一个变量，该变量对每个操作定义和工作区都可见。您还可以在特定环境作用域中创建一个变量，该变量仅在选择使用该特定环境时可见和使用。某些作用域并不总是可用，例如在 Postman 生态系统中，您可以在 Postman 客户端中创建请求，这些请求没有局部作用域，但测试脚本有。

Postman 中的变量作用域可能是一个令人生畏的话题，并不是每个人都熟悉它。在继续之前，请阅读 Postman 文档中的 [变量作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#variable-scopes)。

如前所述，有不同的变量作用域，每个作用域都有其用途，并可用于为您的 Postman 文档提供更大的灵活性。关于变量值如何计算，有一个重要的说明，根据 Postman 文档：

> [!note]
> 如果在两个不同的作用域中声明了同名变量，则使用具有最窄作用域的变量中存储的值。例如，如果有一个名为 `username` 的全局变量和一个名为 `username` 的局部变量，则在请求运行时使用局部值。

以下是 Postman 客户端和 API 模糊测试支持的变量作用域的摘要：
- **全局环境（global）作用域** 是一个在整个工作区中都可用的特殊预定义环境。全局环境作用域也可称为全局作用域。Postman 客户端支持将全局环境导出为 JSON 文件，该文件可用于 API 模糊测试。
- **环境作用域** 是用户在 Postman 客户端中创建的一组具名变量。
  Postman 客户端支持单个活跃环境以及全局环境。活跃的用户创建环境中定义的变量优先于全局环境中定义的变量。Postman 客户端允许将你的环境导出为 JSON 文件，该文件可用于 API 模糊测试。
- **集合作用域** 是在给定集合中声明的一组变量。集合变量可用于声明它们的集合以及嵌套的请求或集合。在集合作用域中定义的变量优先于全局环境作用域和环境作用域。
  Postman 客户端可以将一个或多个集合导出为 JSON 文件，该 JSON 文件包含选定的集合、请求和集合变量。
- **API 模糊测试作用域** 是 API 模糊测试新增的作用域，允许用户提供额外变量，或覆盖其他受支持作用域中定义的变量。此作用域不受 Postman 支持。API 模糊测试作用域变量通过[自定义 JSON 文件格式](#api-fuzzing-scope-custom-json-file-format)提供。
  - 覆盖环境或集合中定义的值
  - 从脚本定义变量
  - 从不支持的 _数据作用域_ 中定义单行数据
- **数据作用域** 是一组变量，其名称和值来自 JSON 或 CSV 文件。Postman 集合 Runner 如 [Newman](https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/) 或 [Postman Collection Runner](https://learning.postman.com/docs/collections/running-collections/intro-to-collection-runs/) 会根据 JSON 或 CSV 文件的条目数多次执行集合中的请求。这些变量的一个良好用例是使用 Postman 中的脚本自动化测试。
  API 模糊测试 **不** 支持从 CSV 或 JSON 文件读取数据。
- **局部作用域** 是在 Postman 脚本中定义的变量。API 模糊测试 **不** 支持 Postman 脚本，因此也不支持在脚本中定义的变量。你仍然可以通过在其他受支持的作用域或自定义 JSON 格式中定义这些变量来为脚本定义的变量提供值。

并非所有作用域都受 API 模糊测试支持，并且脚本中定义的变量也不受支持。下表按从最广泛到最狭窄的作用域排序。

| 作用域              | Postman   | API 模糊测试 | 备注 |
| ------------------ |:---------:|:-----------:| :-------|
| 全局环境 | 是       | 是         | 特殊的预定义环境 |
| 环境        | 是       | 是         | 具名环境 |
| 集合         | 是       | 是         | 在你的 Postman 集合中定义 |
| API 模糊测试作用域  | 否        | 是         | API 模糊测试添加的自定义作用域 |
| 数据               | 是       | 否          | CSV 或 JSON 格式的外部文件 |
| 局部              | 是       | 否          | 脚本中定义的变量 |

有关如何在不同作用域中定义和导出变量的更多详细信息，请参阅：

- [定义集合变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-collection-variables)
- [定义环境变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-environment-variables)
- [定义全局变量](https://learning.postman.com/docs/sending-requests/variables/variables/#defining-global-variables)

#### 从 Postman 客户端导出

Postman 客户端允许你导出不同的文件格式，例如，你可以导出 Postman 集合或 Postman 环境。
导出的环境可以是全局环境（始终可用），也可以是你之前创建的任何自定义环境。当你导出 Postman 集合时，它可能仅包含集合和局部作用域变量的声明；环境作用域变量不包含在内。

要获取环境作用域变量的声明，你必须同时导出一个给定的环境。每个导出文件仅包含来自所选环境的变量。

有关在受支持的不同作用域中导出变量的更多详细信息，请参阅：

- [导出集合](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)
- [导出环境](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)
- [下载全局环境](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)

#### API 模糊测试作用域，自定义 JSON 文件格式

自定义 JSON 文件格式是一个 JSON 对象，其中每个对象属性代表一个变量名，属性值代表变量值。此文件可以使用你喜欢的文本编辑器创建，也可以由流水线中的早期作业生成。

此示例在 API 模糊测试作用域中定义了两个变量 `base_url` 和 `token`：

```json
{
  "base_url": "http://127.0.0.1/",
  "token": "Token 84816165151"
}
```

#### 在 API 模糊测试中使用作用域

全局、环境、集合和极狐GitLab API 模糊测试作用域在[极狐GitLab 15.1 及更高版本](https://jihulab.com/gitlab-cn/gitlab/-/issues/356312)中受支持。极狐GitLab 15.0 及更早版本仅支持集合和极狐GitLab API 模糊测试作用域。

下表提供了将作用域文件/URL 映射到 API 模糊测试配置变量的快速参考：

| 作用域              |  如何提供 |
| ------------------ | --------------- |
| 全局环境 | FUZZAPI_POSTMAN_COLLECTION_VARIABLES |
| 环境        | FUZZAPI_POSTMAN_COLLECTION_VARIABLES |
| 集合         | FUZZAPI_POSTMAN_COLLECTION           |
| API 模糊测试作用域  | FUZZAPI_POSTMAN_COLLECTION_VARIABLES |
| 数据               | 不支持   |
| 局部              | 不支持   |

Postman 集合文档会自动包含任何集合作用域变量。Postman 集合通过配置变量 `FUZZAPI_POSTMAN_COLLECTION` 提供。此变量可以设置为单个[导出的 Postman 集合](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-collections)。

其他作用域的变量通过 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。此配置变量在[极狐GitLab 15.1 及更高版本](https://jihulab.com/gitlab-cn/gitlab/-/issues/356312)中支持逗号（`,`）分隔的文件列表。极狐GitLab 15.0 及更早版本仅支持单个文件。提供文件的顺序不重要，因为文件提供了所需的作用域信息。

配置变量 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 可以设置为：

- [导出的全局环境](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)
- [导出的环境](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)
- [API 模糊测试自定义 JSON 格式](#api-fuzzing-scope-custom-json-file-format)

#### 未定义的 Postman 变量

API 模糊测试引擎可能找不到你的 Postman 集合文件使用的所有变量引用。一些情况可能为：

- 你正在使用数据或局部作用域变量，如前所述，API 模糊测试不支持这些作用域。因此，假设未通过 [API 模糊测试作用域](#api-fuzzing-scope-custom-json-file-format) 提供这些变量的值，那么数据和局部作用域变量的值将是未定义的。
- 变量名输入错误，名称与定义的变量不匹配。
- Postman 客户端支持新的 API 模糊测试不支持的动态变量。

在可能的情况下，API 模糊测试在处理未定义变量时遵循与 Postman 客户端相同的行为。变量引用的文本保持不变，没有文本替换。同样的行为也适用于任何不支持的动态变量。

例如，如果 Postman 集合中的请求定义引用了变量 `{{full_url}}` 但未找到该变量，则将其保留为值 `{{full_url}}`。

#### Postman 动态变量

除了用户可以在各种作用域级别定义的变量之外，Postman 还有一组称为动态变量的预定义变量。[动态变量](https://learning.postman.com/docs/tests-and-scripts/write-scripts/variables-list/)已定义，其名称以美元符号（`$`）为前缀，例如 `$guid`。动态变量可以像其他变量一样使用，在 Postman 客户端中，它们在请求/集合运行期间产生随机值。

API 模糊测试与 Postman 的一个重要区别是，API 模糊测试在每次使用相同动态变量时返回相同的值。这与每次使用相同动态变量时返回随机值的 Postman 客户端行为不同。换句话说，API 模糊测试对动态变量使用静态值，而 Postman 使用随机值。

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

#### 示例：全局作用域

在此示例中，[全局作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)从 Postman 客户端导出为 `global-scope.json`，并通过 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 配置变量提供给 API 模糊测试。

以下是一个使用 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 的示例：

```yaml
stages:
     - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick-10
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: global-scope.json
  FUZZAPI_TARGET_URL: http://test-deployment/
```

#### 示例：环境作用域

在此示例中，[环境作用域](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)从 Postman 客户端导出为 `environment-scope.json`，并通过 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 配置变量提供给 API 模糊测试。

以下是一个使用 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 的示例：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: environment-scope.json
  FUZZAPI_TARGET_URL: http://test-deployment/
```

#### 示例：集合作用域

集合作用域变量包含在导出的 Postman 集合文件中，并通过 `FUZZAPI_POSTMAN_COLLECTION` 配置变量提供。

以下是一个使用 `FUZZAPI_POSTMAN_COLLECTION` 的示例：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: variable-collection-dictionary.json
```

#### 示例：API 模糊测试作用域

API 模糊测试作用域主要用于两个目的：定义 API 模糊测试不支持的 _数据_ 和 _局部_ 作用域变量，以及更改其他作用域中定义的现有变量的值。API 模糊测试作用域通过 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 配置变量提供。

以下是一个使用 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 的示例：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: api-fuzzing-scope.json
  FUZZAPI_TARGET_URL: http://test-deployment/
```

文件 `api-fuzzing-scope.json` 使用 API 模糊测试的[自定义 JSON 文件格式](#api-fuzzing-scope-custom-json-file-format)。此 JSON 是一个具有键值对属性的对象。键是变量名，值是变量值。例如：

```json
{
  "base_url": "http://127.0.0.1/",
  "token": "Token 84816165151"
}
```

#### 示例：多个作用域

在此示例中，配置了全局作用域、环境作用域和集合作用域。第一步是导出各种作用域。

- [导出全局作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)为 `global-scope.json`
- [导出环境作用域](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)为 `environment-scope.json`
- 导出包含 _集合_ 作用域的 Postman 集合为 `postman-collection.json`

Postman 集合使用 `FUZZAPI_POSTMAN_COLLECTION` 变量提供，而其他作用域使用 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 提供。API 模糊测试可以使用每个文件中提供的数据识别所提供文件匹配的作用域。

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: global-scope.json,environment-scope.json
  FUZZAPI_TARGET_URL: http://test-deployment/
```

#### 示例：更改变量的值

使用导出的作用域时，通常需要更改变量的值以用于 API 模糊测试。例如，_集合_ 作用域变量可能包含名为 `api_version` 且值为 `v2` 的变量，而你的测试需要值为 `v1`。无需修改导出的集合来更改值，可以使用 API 模糊测试作用域来更改其值。这是因为 API 模糊测试作用域优先于所有其他作用域。

集合作用域变量包含在导出的 Postman 集合文件中，并通过 `FUZZAPI_POSTMAN_COLLECTION` 配置变量提供。

API 模糊测试作用域通过 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 配置变量提供，但首先你必须创建该文件。
文件 `api-fuzzing-scope.json` 使用 API 模糊测试的[自定义 JSON 文件格式](#api-fuzzing-scope-custom-json-file-format)。此 JSON 是一个具有键值对属性的对象。键是变量名，值是变量值。例如：

```json
{
  "api_version": "v1"
}
```

CI 定义：

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: api-fuzzing-scope.json
  FUZZAPI_TARGET_URL: http://test-deployment/
```

#### 示例：使用多个作用域更改变量的值

使用导出的作用域时，通常需要更改变量的值以用于 API 模糊测试。例如，环境作用域可能包含名为 `api_version` 且值为 `v2` 的变量，而你的测试需要值为 `v1`。无需修改导出的文件来更改值，可以使用 API 模糊测试作用域。这是因为 API 模糊测试作用域优先于所有其他作用域。

在此示例中，配置了全局作用域、环境作用域、集合作用域和 API 模糊测试作用域。第一步是导出和创建各种作用域。

- [导出全局作用域](https://learning.postman.com/docs/sending-requests/variables/variables/#downloading-global-environments)为 `global-scope.json`
- [导出环境作用域](https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data/#export-environments)为 `environment-scope.json`
- 导出包含集合作用域的 Postman 集合为 `postman-collection.json`

通过创建文件 `api-fuzzing-scope.json` 使用 API 模糊测试作用域，该文件使用 API 模糊测试的[自定义 JSON 文件格式](#api-fuzzing-scope-custom-json-file-format)。此 JSON 是一个具有键值对属性的对象。键是变量名，值是变量值。例如：

```json
{
  "api_version": "v1"
}
```

Postman 集合使用 `FUZZAPI_POSTMAN_COLLECTION` 变量提供，而其他作用域使用 `FUZZAPI_POSTMAN_COLLECTION_VARIABLES` 提供。API 模糊测试可以使用每个文件中提供的数据识别所提供文件匹配的作用域。

```yaml
stages:
  - fuzz

include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_POSTMAN_COLLECTION: postman-collection.json
  FUZZAPI_POSTMAN_COLLECTION_VARIABLES: global-scope.json,environment-scope.json,api-fuzzing-scope.json
  FUZZAPI_TARGET_URL: http://test-deployment/
```

## 运行你的首次扫描

当配置正确时，CI/CD 流水线包含一个 `fuzz` 阶段以及一个 `apifuzzer_fuzz` 或 `apifuzzer_fuzz_dnd` 作业。该作业仅在提供无效配置时才会失败。在典型操作期间，即使模糊测试期间发现故障，该作业也始终成功。
故障会显示在**安全**流水线标签页上，并附有套件名称。当针对仓库的默认分支进行测试时，模糊测试故障也会显示在安全与合规的漏洞报告中。

为了防止报告过多的故障，API 模糊测试扫描器会限制其报告的故障数量。

<a id="viewing-fuzzing-faults"></a>

## 查看模糊测试故障

API 模糊测试分析器会生成一个 JSON 报告，该报告被收集并用于[将故障填充到极狐GitLab 漏洞界面中](#view-details-of-an-api-fuzzing-vulnerability)。模糊测试故障会显示为严重程度为“未知”的漏洞。

API 模糊测试发现的故障需要人工调查，并且不与特定的漏洞类型关联。它们需要调查以确定是否是安全问题，以及是否应该修复。有关您可以进行配置更改以限制报告的误报数量的信息，请参见[处理误报](#handling-false-positives)。

<a id="view-details-of-an-api-fuzzing-vulnerability"></a>

### 查看 API 模糊测试漏洞的详细信息

API 模糊测试检测到的故障发生在实时 Web 应用中，需要人工调查以确定它们是否为漏洞。模糊测试故障被归类为严重程度为“未知”的漏洞。为了方便调查模糊测试故障，系统会提供有关发送和接收的 HTTP 消息的详细信息，以及所做修改的描述。

按照以下步骤查看模糊测试故障的详细信息：

1. 您可以在项目或合并请求中查看故障：

   - 在项目中，转到项目的**安全 > 漏洞报告**页面。此页面仅显示默认分支的所有漏洞。
   - 在合并请求中，转到合并请求的**安全**部分，然后选择**展开**按钮。API 模糊测试故障位于标记为 **API 模糊测试检测到 N 个潜在漏洞**的部分中。选择标题以显示故障详细信息。

1. 选择故障的标题以显示其详细信息。下表描述了这些详细信息。

   | 字段               | 描述                                                                             |
   |:--------------------|:----------------------------------------------------------------------------------------|
   | 描述         | 故障描述，包括进行了哪些修改。                                   |
   | 项目             | 检测到漏洞的命名空间和项目。                          |
   | 方法              | 用于检测漏洞的 HTTP 方法。                                           |
   | URL                 | 检测到漏洞的 URL。                                            |
   | 请求             | 导致故障的 HTTP 请求。                                                 |
   | 未修改的响应 | 来自未修改请求的响应。一个典型的正常响应类似于未修改的响应。 |
   | 实际响应     | 从模糊测试请求收到的响应。                                                  |
   | 证据            | 极狐GitLab 如何确定发生了故障。                                                 |
   | 标识符         | 用于发现此故障的模糊测试检查。                                              |
   | 严重程度            | 发现的严重程度始终为“未知”。                                              |
   | 扫描器类型        | 用于执行测试的扫描器。                                                        |

<a id="security-dashboard"></a>

### 安全仪表盘

模糊测试故障会显示为严重程度为“未知”的漏洞。安全仪表盘是概览您的群组、项目和流水线中所有安全漏洞的好地方。有关更多信息，请参见[安全仪表盘文档](../../security_dashboard/_index.md)。

<a id="interacting-with-the-vulnerabilities"></a>

### 与漏洞交互

模糊测试故障会显示为严重程度为“未知”的漏洞。发现故障后，您可以与其进行交互。阅读更多关于如何处理[漏洞](../../vulnerabilities/_index.md)的信息。

<a id="handling-false-positives"></a>

## 处理误报

可以通过两种方式处理误报：

- 关闭产生误报的检查。这可以防止该检查产生任何故障。示例检查包括 `JSONFuzzingCheck` 和 `FormBodyFuzzingCheck`。
- 模糊测试检查有几种检测何时识别到故障的方法，称为“断言”。断言也可以被关闭和配置。例如，API 模糊测试器默认使用 HTTP 状态码来帮助识别何时出现真正的问题。如果在测试期间 API 返回 500 错误，这会产生一个故障。但这并非总是期望的，因为有些框架经常返回 500 错误。

<a id="turn-off-a-check"></a>

### 关闭检查

检查执行特定类型的测试，并且可以为特定配置场景打开或关闭。默认配置文件定义了几个您可以使用的场景。配置文件中的场景定义列出了在扫描期间处于活动状态的所有检查。要关闭特定检查，请将其从配置文件中的场景定义中删除。场景在配置文件的 `Profiles` 部分中定义。

示例场景定义：

```yaml
Profiles:
  - Name: Quick-10
    DefaultProfile: Quick
    Routes:
      - Route: *Route0
        Checks:
          - Name: FormBodyFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
          - Name: GeneralFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
          - Name: JsonFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
          - Name: XmlFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
```

要关闭 `GeneralFuzzingCheck`，您可以删除这些行：

```yaml
- Name: GeneralFuzzingCheck
  Configuration:
    FuzzingCount: 10
    UnicodeFuzzing: true
```

这会得到以下 YAML：

```yaml
- Name: Quick-10
  DefaultProfile: Quick
  Routes:
    - Route: *Route0
      Checks:
        - Name: FormBodyFuzzingCheck
          Configuration:
            FuzzingCount: 10
            UnicodeFuzzing: true
        - Name: JsonFuzzingCheck
          Configuration:
            FuzzingCount: 10
            UnicodeFuzzing: true
        - Name: XmlFuzzingCheck
          Configuration:
            FuzzingCount: 10
            UnicodeFuzzing: true
```

<a id="turn-off-an-assertion-for-a-check"></a>

### 关闭检查的断言

断言检测由检查产生的测试中的故障。许多检查支持多种断言，例如日志分析、响应分析和状态码。发现故障时，会提供所使用的断言。要识别默认开启的断言，请参见配置文件中 `Checks` 部分下检查的默认配置。

此示例显示了 `FormBodyFuzzingCheck`：

```yaml
Checks:
  - Name: FormBodyFuzzingCheck
    Configuration:
      FuzzingCount: 30
      UnicodeFuzzing: true
    Assertions:
      - Name: LogAnalysisAssertion
      - Name: ResponseAnalysisAssertion
      - Name: StatusCodeAssertion
```

在这里您可以看到默认开启了三个断言。误报的一个常见来源是 `StatusCodeAssertion`。要将其关闭，请在 `Profiles` 部分修改其配置。此示例只提供了另外两个断言 (`LogAnalysisAssertion`， `ResponseAnalysisAssertion`)。这可以防止 `FormBodyFuzzingCheck` 使用 `StatusCodeAssertion`：

```yaml
Profiles:
  - Name: Quick-10
    DefaultProfile: Quick
    Routes:
      - Route: *Route0
        Checks:
          - Name: FormBodyFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
            Assertions:
              - Name: LogAnalysisAssertion
              - Name: ResponseAnalysisAssertion
          - Name: GeneralFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
          - Name: JsonFuzzingCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
          - Name: XmlInjectionCheck
            Configuration:
              FuzzingCount: 10
              UnicodeFuzzing: true
```