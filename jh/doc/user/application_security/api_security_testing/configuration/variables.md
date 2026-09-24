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

{{< history >}}

- 在 极狐GitLab 17.1 中，模板名称从 `DAST-API.gitlab-ci.yml` 更改为 `API-Security.gitlab-ci.yml`，变量前缀也从 `DAST_API_` 变更为 `APISEC_`。

{{< /history >}}

## 可用的 CI/CD 变量
<a id="available-cicd-variables"></a>

| CI/CD 变量 | 描述 |
|---------------------------------------------------------------------------------------------|-------------|
| `SECURE_ANALYZERS_PREFIX` | 指定用于下载分析器的 Docker 镜像仓库基础地址。 |
| `APISEC_DISABLED` | 设置为 'true' 或 '1' 以禁用 API 安全测试扫描。 |
| `APISEC_DISABLED_FOR_DEFAULT_BRANCH` | 设置为 'true' 或 '1'，仅为默认（生产）分支禁用 API 安全测试扫描。 |
| `APISEC_VERSION` | 指定 API 安全测试容器版本。默认为 `3`。 |
| `APISEC_IMAGE_SUFFIX` | 指定容器镜像后缀。默认为空。 |
| `APISEC_API_PORT` | 指定 API 安全测试引擎使用的通信端口号。默认为 `5500`。在 极狐GitLab 15.5 中引入。 |
| `APISEC_TARGET_URL` | API 测试目标的基础 URL。 |
| `APISEC_TARGET_CHECK_SKIP` | 禁用等待目标变为可用状态。在 极狐GitLab 17.1 中引入。 |
| `APISEC_TARGET_CHECK_STATUS_CODE` | 为目标可用性检查提供预期的状态码。如果未提供，任何非 500 的状态码都是可接受的。在 极狐GitLab 17.1 中引入。 |
| [`APISEC_CONFIG`](#configuration-files) | API 安全测试配置文件。默认为 `.gitlab-dast-api.yml`。 |
| [`APISEC_PROFILE`](#configuration-files) | 测试期间要使用的配置配置文件。默认为 `Quick`。 |
| [`APISEC_EXCLUDE_PATHS`](customizing_analyzer_settings.md#exclude-paths) | 从测试中排除 API URL 路径。 |
| [`APISEC_EXCLUDE_URLS`](customizing_analyzer_settings.md#exclude-urls) | 从测试中排除 API URL。 |
| [`APISEC_EXCLUDE_PARAMETER_ENV`](customizing_analyzer_settings.md#exclude-parameters) | 包含要排除的参数的 JSON 字符串。 |
| [`APISEC_EXCLUDE_PARAMETER_FILE`](customizing_analyzer_settings.md#exclude-parameters) | 包含要排除的参数的 JSON 文件路径。 |
| [`APISEC_REQUEST_HEADERS`](customizing_analyzer_settings.md#request-headers) | 在每个扫描请求中包含的请求头列表，以逗号（`,`）分隔。当在[屏蔽变量](../../../../ci/variables/_index.md#mask-a-cicd-variable)中存储密钥标头值时，请考虑使用 `APISEC_REQUEST_HEADERS_BASE64`，因为屏蔽变量有字符集限制。 |
| [`APISEC_REQUEST_HEADERS_BASE64`](customizing_analyzer_settings.md#request-headers) | 在每个扫描请求中包含的请求头列表，以逗号（`,`）分隔，并进行 Base64 编码。在 极狐GitLab 15.6 中引入。 |
| [`APISEC_OPENAPI`](enabling_the_analyzer.md#openapi-specification) | OpenAPI 规范文件或 URL。 |
| [`APISEC_OPENAPI_RELAXED_VALIDATION`](enabling_the_analyzer.md#openapi-specification) | 放宽文档验证。默认是禁用的。 |
| [`APISEC_OPENAPI_ALL_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification) | 在生成请求时使用所有支持的媒体类型，而不是仅用一种。会导致测试时间更长。默认是禁用的。 |
| [`APISEC_OPENAPI_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification) | 测试接受的媒体类型，以冒号（`:`）分隔。默认是禁用的。 |
| [`APISEC_HAR`](enabling_the_analyzer.md#http-archive-har) | HTTP 存档（HAR）文件。 |
| [`APISEC_GRAPHQL`](enabling_the_analyzer.md#graphql-schema) | GraphQL 端点的路径，例如 `/api/graphql`。在 极狐GitLab 15.4 中引入。 |
| [`APISEC_GRAPHQL_SCHEMA`](enabling_the_analyzer.md#graphql-schema) | GraphQL schema 的 URL 或文件名，格式为 JSON。在 极狐GitLab 15.4 中引入。 |
| [`APISEC_POSTMAN_COLLECTION`](enabling_the_analyzer.md#postman-collection) | Postman Collection 文件。 |
| [`APISEC_POSTMAN_COLLECTION_VARIABLES`](enabling_the_analyzer.md#postman-variables) | 用于提取 Postman 变量值的 JSON 文件路径。对逗号分隔（`,`）文件的支持在 极狐GitLab 15.1 中引入。 |
| [`APISEC_OVERRIDES_FILE`](customizing_analyzer_settings.md#overrides) | 包含覆盖项的 JSON 文件路径。 |
| [`APISEC_OVERRIDES_ENV`](customizing_analyzer_settings.md#overrides) | 包含要覆盖的请求头的 JSON 字符串。 |
| [`APISEC_OVERRIDES_CMD`](customizing_analyzer_settings.md#overrides) | 覆盖命令。 |
| [`APISEC_OVERRIDES_CMD_VERBOSE`](customizing_analyzer_settings.md#overrides) | 当设置为任何值时，它会将覆盖命令的输出记录到 `gl-api-security-scanner.log` 作业产物文件中。 |
| `APISEC_PER_REQUEST_SCRIPT` | 每个请求脚本的完整路径和文件名。[参见演示项目中的示例。](https://gitlab.com/gitlab-org/security-products/demos/api-dast/auth-with-request-example) 在 极狐GitLab 17.2 中引入。 |
| `APISEC_PRE_SCRIPT` | 在扫描会话开始前运行用户命令或脚本。对于安装软件包等特权操作，必须使用 `sudo`。 |
| `APISEC_POST_SCRIPT` | 在扫描会话结束后运行用户命令或脚本。对于安装软件包等特权操作，必须使用 `sudo`。 |
| [`APISEC_OVERRIDES_INTERVAL`](customizing_analyzer_settings.md#overrides) | 运行覆盖命令的频率（秒）。默认为 `0`（一次）。 |
| [`APISEC_HTTP_USERNAME`](customizing_analyzer_settings.md#http-basic-authentication) | 用于 HTTP 认证的用户名。 |
| [`APISEC_HTTP_PASSWORD`](customizing_analyzer_settings.md#http-basic-authentication) | 用于 HTTP 认证的密码。请考虑改用 `APISEC_HTTP_PASSWORD_BASE64`。 |
| [`APISEC_HTTP_PASSWORD_BASE64`](customizing_analyzer_settings.md#http-basic-authentication) | 用于 HTTP 认证的密码，Base64 编码。在 极狐GitLab 15.4 中引入。 |
| `APISEC_SERVICE_START_TIMEOUT` | 等待目标 API 变为可用状态的时长（秒）。默认为 300 秒。 |
| `APISEC_TIMEOUT` | 等待 API 响应的时长（秒）。默认为 30 秒。 |
| `APISEC_SUCCESS_STATUS_CODES` | 指定一个逗号分隔（`,`）的 HTTP 成功状态码列表，用于判断 API 安全测试扫描作业是否通过。在 极狐GitLab 17.1 中引入。示例：`'200, 201, 204'` |

## 配置文件
<a id="configuration-files"></a>

为了帮助您快速入门，极狐GitLab 提供了配置文件
[`gitlab-dast-api-config.yml`](https://gitlab.com/gitlab-org/security-products/analyzers/dast/-/blob/master/config/gitlab-dast-api-config.yml)。
此文件包含几个测试配置文件，它们执行不同数量的测试。每个配置文件的运行时间会随着测试数量的增加而增加。要使用配置文件，请将其作为 `.gitlab/gitlab-dast-api-config.yml` 添加到您仓库的根目录中。

### 配置文件
<a id="profiles"></a>

以下配置文件在默认配置文件中已预定义。可以通过创建自定义配置来添加、删除和修改配置文件。

#### Passive
<a id="passive"></a>

- Application Information Check
- Cleartext Authentication Check
- JSON Hijacking Check
- Sensitive Information Check
- Session Cookie Check

#### Quick
<a id="quick"></a>

- Application Information Check
- Cleartext Authentication Check
- FrameworkDebugModeCheck
- HTML Injection Check
- Insecure Http Methods Check
- JSON Hijacking Check
- JSON Injection Check
- Sensitive Information Check
- Session Cookie Check
- SQL Injection Check
- Token Check
- XML Injection Check

#### Full
<a id="full"></a>

- Application Information Check
- Cleartext AuthenticationCheck
- CORS Check
- DNS Rebinding Check
- Framework Debug Mode Check
- HTML Injection Check
- Insecure Http Methods Check
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
