---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 可用的 CI/CD 变量
---

<a id="available-ci-cd-variables"></a>

| CI/CD 变量                                                                                   | 描述 |
|----------------------------------------------------------------------------------------------|-------------|
| `SECURE_ANALYZERS_PREFIX`                                                                    | 指定用于下载分析器的 Docker 仓库基础地址。 |
| `FUZZAPI_VERSION`                                                                            | 指定 API 模糊测试容器版本。默认为 `5`。 |
| `FUZZAPI_IMAGE_SUFFIX`                                                                       | 指定容器镜像后缀。默认为无。 |
| `FUZZAPI_API_PORT`                                                                           | 指定 API 模糊测试引擎使用的通信端口号。默认为 `5500`。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/367734) GitLab 15.5。 |
| `FUZZAPI_TARGET_URL`                                                                         | API 测试目标的基础 URL。 |
| `FUZZAPI_TARGET_CHECK_SKIP`                                                                  | 禁用等待目标变为可用。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/442699) GitLab 17.1。 |
| `FUZZAPI_TARGET_CHECK_STATUS_CODE`                                                           | 为目标可用性检查提供预期的状态码。如果未提供，任何非 500 状态码都可接受。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/442699) GitLab 17.1。 |
| [`FUZZAPI_PROFILE`](customizing_analyzer_settings.md#api-fuzzing-profiles)                   | 测试期间使用的配置配置文件。默认为 `Quick-10`。 |
| [`FUZZAPI_EXCLUDE_PATHS`](customizing_analyzer_settings.md#exclude-paths)                    | 从测试中排除 API URL 路径。 |
| [`FUZZAPI_EXCLUDE_URLS`](customizing_analyzer_settings.md#exclude-urls)                      | 从测试中排除 API URL。 |
| [`FUZZAPI_EXCLUDE_PARAMETER_ENV`](customizing_analyzer_settings.md#exclude-parameters)       | 包含排除参数的 JSON 字符串。 |
| [`FUZZAPI_EXCLUDE_PARAMETER_FILE`](customizing_analyzer_settings.md#exclude-parameters)      | 包含排除参数的 JSON 文件路径。 |
| [`FUZZAPI_OPENAPI`](enabling_the_analyzer.md#openapi-specification)                          | OpenAPI 规范文件或 URL。 |
| [`FUZZAPI_OPENAPI_RELAXED_VALIDATION`](enabling_the_analyzer.md#openapi-specification)       | 放宽文档验证。默认禁用。 |
| [`FUZZAPI_OPENAPI_ALL_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification)          | 在生成请求时使用所有支持的媒体类型而不是一种。会导致测试时间更长。默认禁用。 |
| [`FUZZAPI_OPENAPI_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification)              | 用冒号（`:`）分隔接受的测试媒体类型。默认禁用。 |
| [`FUZZAPI_HAR`](enabling_the_analyzer.md#http-archive-har)                                   | HTTP 存档（HAR）文件。 |
| [`FUZZAPI_GRAPHQL`](enabling_the_analyzer.md#graphql-schema)                                 | GraphQL 端点路径，例如 `/api/graphql`。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/352780) GitLab 15.4。 |
| [`FUZZAPI_GRAPHQL_SCHEMA`](enabling_the_analyzer.md#graphql-schema)                          | JSON 格式的 GraphQL 模式的 URL 或文件名。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/352780) GitLab 15.4。 |
| [`FUZZAPI_POSTMAN_COLLECTION`](enabling_the_analyzer.md#postman-collection)                  | Postman Collection 文件。 |
| [`FUZZAPI_POSTMAN_COLLECTION_VARIABLES`](enabling_the_analyzer.md#postman-variables)         | 提取 Postman 变量值的 JSON 文件路径。对逗号分隔（`,`）文件的支持[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/356312) GitLab 15.1。 |
| [`FUZZAPI_OVERRIDES_FILE`](customizing_analyzer_settings.md#overrides)                       | 包含覆盖项的 JSON 文件路径。 |
| [`FUZZAPI_OVERRIDES_ENV`](customizing_analyzer_settings.md#overrides)                        | 包含要覆盖的标头的 JSON 字符串。 |
| [`FUZZAPI_OVERRIDES_CMD`](customizing_analyzer_settings.md#overrides)                        | 覆盖命令。 |
| [`FUZZAPI_OVERRIDES_CMD_VERBOSE`](customizing_analyzer_settings.md#overrides)                | 当设置为任意值时，会将覆盖命令的输出显示为作业输出的一部分。 |
| `FUZZAPI_PER_REQUEST_SCRIPT`                                                                 | 每个请求脚本的完整路径和文件名。[参见演示项目示例。](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/auth-with-request-example) [引入于](https://gitlab.com/groups/gitlab-org/-/epics/13691) GitLab 17.2。 |
| `FUZZAPI_PRE_SCRIPT`                                                                         | 在扫描会话开始前运行用户命令或脚本。必须使用 `sudo` 进行安装软件包等特权操作。 |
| `FUZZAPI_POST_SCRIPT`                                                                        | 在扫描会话结束后运行用户命令或脚本。必须使用 `sudo` 进行安装软件包等特权操作。 |
| [`FUZZAPI_OVERRIDES_INTERVAL`](customizing_analyzer_settings.md#overrides)                   | 覆盖命令的运行频率（秒）。默认为 `0`（一次）。 |
| [`FUZZAPI_HTTP_USERNAME`](customizing_analyzer_settings.md#http-basic-authentication)        | HTTP 认证用户名。 |
| [`FUZZAPI_HTTP_PASSWORD`](customizing_analyzer_settings.md#http-basic-authentication)        | HTTP 认证密码。 |
| [`FUZZAPI_HTTP_PASSWORD_BASE64`](customizing_analyzer_settings.md#http-basic-authentication) | HTTP 认证密码，Base64 编码。[引入于](https://jihulab.com/gitlab-cn/security-products/analyzers/api-fuzzing-src/-/merge_requests/702) GitLab 15.4。 |
| `FUZZAPI_SUCCESS_STATUS_CODES`                                                               | 指定以逗号分隔（`,`）的 HTTP 成功状态码列表，用于判断 API 模糊测试扫描作业是否通过。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/442219) GitLab 17.1。示例：`'200, 201, 204'` |