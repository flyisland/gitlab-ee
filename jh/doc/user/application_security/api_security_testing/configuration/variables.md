---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 可用的 CI/CD 变量和配置文件
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="available-cicd-variables"></a>

## 可用的 CI/CD 变量

| CI/CD 变量                                                                              | 描述 |
|---------------------------------------------------------------------------------------------|-------------|
| `SECURE_ANALYZERS_PREFIX`                                                                   | 指定从中下载分析器的 Docker 镜像仓库基础地址。 |
| `APISEC_DISABLED`                                                                           | 设置为 'true' 或 '1' 可禁用 API 安全测试扫描。 |
| `APISEC_DISABLED_FOR_DEFAULT_BRANCH`                                                        | 设置为 'true' 或 '1' 可仅对默认（生产）分支禁用 API 安全测试扫描。 |
| `APISEC_VERSION`                                                                            | 指定 API 安全测试容器版本。默认为 `3`。 |
| `APISEC_IMAGE_SUFFIX`                                                                       | 指定容器镜像后缀。默认为无。 |
| `APISEC_API_PORT`                                                                           | 指定 API 安全测试引擎使用的通信端口号。默认为 `5500`。 |
| `APISEC_TARGET_URL`                                                                         | API 测试目标的基础 URL。 |
| `APISEC_TARGET_CHECK_SKIP`                                                                  | 禁用等待目标变为可用。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/442699)。 |
| `APISEC_TARGET_CHECK_STATUS_CODE`                                                           | 提供目标可用性检查的预期状态码。如果未提供，则任何非 500 状态码均可接受。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/442699)。 |
| [`APISEC_CONFIG`](#configuration-files)                                                     | API 安全测试配置文件。默认为 `.gitlab-dast-api.yml`。 |
| [`APISEC_PROFILE`](#configuration-files)                                                    | 测试期间使用的配置配置文件。默认为 `Quick`。 |
| [`APISEC_EXCLUDE_PATHS`](customizing_analyzer_settings.md#exclude-paths)                    | 从测试中排除 API URL 路径。 |
| [`APISEC_EXCLUDE_URLS`](customizing_analyzer_settings.md#exclude-urls)                      | 从测试中排除 API URL。 |
| [`APISEC_EXCLUDE_PARAMETER_ENV`](customizing_analyzer_settings.md#exclude-parameters)       | 包含被排除参数的 JSON 字符串。 |
| [`APISEC_EXCLUDE_PARAMETER_FILE`](customizing_analyzer_settings.md#exclude-parameters)      | 包含被排除参数的 JSON 文件路径。 |
| [`APISEC_REQUEST_HEADERS`](customizing_analyzer_settings.md#request-headers)                | 以逗号 (`,`) 分隔的请求头列表，用于包含在每个扫描请求中。在[掩码变量](../../../../ci/variables/_index.md#mask-a-cicd-variable)中存储密钥请求头值时，请考虑使用 `APISEC_REQUEST_HEADERS_BASE64`，因为掩码变量有字符集限制。 |
| [`APISEC_REQUEST_HEADERS_BASE64`](customizing_analyzer_settings.md#request-headers)         | 以逗号 (`,`) 分隔的请求头列表，用于包含在每个扫描请求中，采用 Base64 编码。 |
| [`APISEC_OPENAPI`](enabling_the_analyzer.md#openapi-specification)                          | OpenAPI 规范文件或 URL。 |
| [`APISEC_OPENAPI_RELAXED_VALIDATION`](enabling_the_analyzer.md#openapi-specification)       | 放宽文档验证。默认禁用。 |
| [`APISEC_OPENAPI_ALL_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification)          | 生成请求时使用所有受支持的媒体类型，而不是仅使用一种。会导致测试持续时间更长。默认禁用。 |
| [`APISEC_OPENAPI_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification)              | 以冒号 (`:`) 分隔的、可接受用于测试的媒体类型。默认禁用。 |
| [`APISEC_HAR`](enabling_the_analyzer.md#http-archive-har)                                   | HTTP Archive (HAR) 文件。 |
| [`APISEC_GRAPHQL`](enabling_the_analyzer.md#graphql-schema)                                 | GraphQL 端点路径，例如 `/api/graphql`。 |
| [`APISEC_GRAPHQL_SCHEMA`](enabling_the_analyzer.md#graphql-schema)                          | JSON 格式的 GraphQL schema 的 URL 或文件名。 |
| [`APISEC_POSTMAN_COLLECTION`](enabling_the_analyzer.md#postman-collection)                  | Postman Collection 文件。 |
| [`APISEC_POSTMAN_COLLECTION_VARIABLES`](enabling_the_analyzer.md#postman-variables)         | 用于提取 Postman 变量值的 JSON 文件路径，或以逗号 (`,`) 分隔的文件列表。 |
| [`APISEC_OVERRIDES_FILE`](customizing_analyzer_settings.md#overrides)                       | 包含覆盖项的 JSON 文件路径。 |
| [`APISEC_OVERRIDES_ENV`](customizing_analyzer_settings.md#overrides)                        | 包含要覆盖的请求头的 JSON 字符串。 |
| [`APISEC_OVERRIDES_CMD`](customizing_analyzer_settings.md#overrides)                        | 覆盖命令。 |
| [`APISEC_OVERRIDES_CMD_VERBOSE`](customizing_analyzer_settings.md#overrides)                | 设置为任意值时，会将覆盖命令的输出记录到 `gl-api-security-scanner.log` 作业产物文件中。 |
| `APISEC_PER_REQUEST_SCRIPT`                                                                 | 每个请求脚本的完整路径和文件名。[有关示例，请参见演示项目。](https://gitlab.com/gitlab-org/security-products/demos/api-dast/auth-with-request-example)在极狐GitLab 17.2 中[引入](https://gitlab.com/groups/gitlab-org/-/work_items/13691)。 |
| `APISEC_PRE_SCRIPT`                                                                         | 在扫描会话开始前运行用户命令或脚本。对于安装软件包等特权操作，必须使用 `sudo`。 |
| `APISEC_POST_SCRIPT`                                                                        | 在扫描会话结束后运行用户命令或脚本。对于安装软件包等特权操作，必须使用 `sudo`。 |
| [`APISEC_OVERRIDES_INTERVAL`](customizing_analyzer_settings.md#overrides)                   | 运行覆盖命令的频率（以秒为单位）。默认为 `0`（一次）。 |
| [`APISEC_HTTP_USERNAME`](customizing_analyzer_settings.md#http-basic-authentication)        | HTTP 认证的用户名。 |
| [`APISEC_HTTP_PASSWORD`](customizing_analyzer_settings.md#http-basic-authentication)        | HTTP 认证的密码。请考虑改用 `APISEC_HTTP_PASSWORD_BASE64`。 |
| [`APISEC_HTTP_PASSWORD_BASE64`](customizing_analyzer_settings.md#http-basic-authentication) | HTTP 认证的密码，采用 base64 编码。 |
| `APISEC_SERVICE_START_TIMEOUT`                                                              | 等待目标 API 变为可用的时长（以秒为单位）。默认为 300 秒。 |
| `APISEC_TIMEOUT`                                                                            | 等待 API 响应的时长（以秒为单位）。默认为 30 秒。 |
| `APISEC_SUCCESS_STATUS_CODES`                                                               | 指定以逗号 (`,`) 分隔的 HTTP 成功状态码列表，用于确定 API 安全测试扫描作业是否通过。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/442219)。示例：`'200, 201, 204'` |

<a id="configuration-files"></a>

## 配置文件

为帮助您快速上手，极狐GitLab 提供了配置文件
[`gitlab-dast-api-config.yml`](https://gitlab.com/gitlab-org/security-products/analyzers/dast/-/blob/master/config/gitlab-dast-api-config.yml)。
该文件包含多个测试配置文件，可执行不同数量的测试。每个配置文件的运行时间会随着测试数量的增加而增加。要使用配置文件，请将其添加到代码仓库的根目录，命名为 `.gitlab/gitlab-dast-api-config.yml`。

<a id="profiles"></a>

### 配置文件

以下配置文件已在默认配置文件中预定义。您可以通过创建自定义配置来添加、删除和修改配置文件。

<a id="passive"></a>

#### Passive

- Application Information Check
- Cleartext Authentication Check
- JSON Hijacking Check
- Sensitive Information Check
- Session Cookie Check

<a id="quick"></a>

#### Quick

- Application Information Check
- Cleartext Authentication Check
- Framework Debug Mode Check
- HTML Injection Check
- Insecure HTTP Methods Check
- JSON Hijacking Check
- JSON Injection Check
- Sensitive Information Check
- Session Cookie Check
- SQL Injection Check
- Token Check
- XML Injection Check

<a id="full"></a>

#### Full

- Application Information Check
- Cleartext Authentication Check
- CORS Check
- DNS Rebinding Check
- Framework Debug Mode Check
- HTML Injection Check
- Insecure HTTP Methods Check
- JSON Hijacking Check
- JSON Injection Check
- Open Redirect Check
- Sensitive File Check
- Sensitive Information Check
- Session Cookie Check
- SQL Injection Check
- TLS Configuration Check
- Token Check
- XML Injection Check
