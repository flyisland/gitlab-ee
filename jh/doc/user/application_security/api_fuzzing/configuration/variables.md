---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 可用的 CI/CD 变量
---

| CI/CD 变量                                                                               | 描述 |
|----------------------------------------------------------------------------------------------|-------------|
| `SECURE_ANALYZERS_PREFIX`                                                                    | 指定用于下载分析器的 Docker 镜像仓库基础地址。 |
| `FUZZAPI_VERSION`                                                                            | 指定 API 模糊测试容器版本。默认为 `5`。 |
| `FUZZAPI_IMAGE_SUFFIX`                                                                       | 指定容器镜像后缀。默认无。 |
| `FUZZAPI_API_PORT`                                                                           | 指定 API 模糊测试引擎使用的通信端口号。默认为 `5500`。 |
| `FUZZAPI_TARGET_URL`                                                                         | API 测试目标的基础 URL。 |
| `FUZZAPI_TARGET_CHECK_SKIP`                                                                  | 禁用等待目标变为可用。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/442699)。 |
| `FUZZAPI_TARGET_CHECK_STATUS_CODE`                                                           | 提供目标可用性检查的预期状态码。如果未提供，则任何非 500 状态码均可接受。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/442699)。 |
| [`FUZZAPI_PROFILE`](customizing_analyzer_settings.md#api-fuzzing-profiles)                   | 测试期间使用的配置配置文件。默认为 `Quick-10`。 |
| [`FUZZAPI_EXCLUDE_PATHS`](customizing_analyzer_settings.md#exclude-paths)                    | 从测试中排除 API URL 路径。 |
| [`FUZZAPI_EXCLUDE_URLS`](customizing_analyzer_settings.md#exclude-urls)                      | 从测试中排除 API URL。 |
| [`FUZZAPI_EXCLUDE_PARAMETER_ENV`](customizing_analyzer_settings.md#exclude-parameters)       | 包含排除参数的 JSON 字符串。 |
| [`FUZZAPI_EXCLUDE_PARAMETER_FILE`](customizing_analyzer_settings.md#exclude-parameters)      | 包含排除参数的 JSON 文件路径。 |
| [`FUZZAPI_OPENAPI`](enabling_the_analyzer.md#openapi-specification)                          | OpenAPI 规范文件或 URL。 |
| [`FUZZAPI_OPENAPI_RELAXED_VALIDATION`](enabling_the_analyzer.md#openapi-specification)       | 放宽文档验证。默认禁用。 |
| [`FUZZAPI_OPENAPI_ALL_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification)          | 生成请求时使用所有受支持的媒体类型，而不是仅使用一种。会导致测试持续时间更长。默认禁用。 |
| [`FUZZAPI_OPENAPI_MEDIA_TYPES`](enabling_the_analyzer.md#openapi-specification)              | 以冒号（`:`）分隔的、可接受用于测试的媒体类型。默认禁用。 |
| [`FUZZAPI_HAR`](enabling_the_analyzer.md#http-archive-har)                                   | HTTP 归档（HAR）文件。 |
| [`FUZZAPI_GRAPHQL`](enabling_the_analyzer.md#graphql-schema)                                 | GraphQL 端点路径，例如 `/api/graphql`。 |
| [`FUZZAPI_GRAPHQL_SCHEMA`](enabling_the_analyzer.md#graphql-schema)                          | JSON 格式的 GraphQL 模式的 URL 或文件名。 |
| [`FUZZAPI_POSTMAN_COLLECTION`](enabling_the_analyzer.md#postman-collection)                  | Postman Collection 文件。 |
| [`FUZZAPI_POSTMAN_COLLECTION_VARIABLES`](enabling_the_analyzer.md#postman-variables)         | 用于提取 Postman 变量值的 JSON 文件路径，或以逗号（`,`）分隔的文件列表。 |
| [`FUZZAPI_OVERRIDES_FILE`](customizing_analyzer_settings.md#overrides)                       | 包含覆盖项的 JSON 文件路径。 |
| [`FUZZAPI_OVERRIDES_ENV`](customizing_analyzer_settings.md#overrides)                        | 包含要覆盖的请求头的 JSON 字符串。 |
| [`FUZZAPI_OVERRIDES_CMD`](customizing_analyzer_settings.md#overrides)                        | 覆盖命令。 |
| [`FUZZAPI_OVERRIDES_CMD_VERBOSE`](customizing_analyzer_settings.md#overrides)                | 设置为任意值时，会将覆盖命令的输出作为作业输出的一部分显示。 |
| `FUZZAPI_PER_REQUEST_SCRIPT`                                                                 | 每个请求脚本的完整路径和文件名。[有关示例，请参见演示项目。](https://gitlab.com/gitlab-org/security-products/demos/api-dast/auth-with-request-example)在极狐GitLab 17.2 中[引入](https://gitlab.com/groups/gitlab-org/-/work_items/13691)。 |
| `FUZZAPI_PRE_SCRIPT`                                                                         | 在扫描会话开始前运行用户命令或脚本。安装软件包等特权操作必须使用 `sudo`。 |
| `FUZZAPI_POST_SCRIPT`                                                                        | 在扫描会话结束后运行用户命令或脚本。安装软件包等特权操作必须使用 `sudo`。 |
| [`FUZZAPI_OVERRIDES_INTERVAL`](customizing_analyzer_settings.md#overrides)                   | 运行覆盖命令的频率（以秒为单位）。默认为 `0`（一次）。 |
| [`FUZZAPI_HTTP_USERNAME`](customizing_analyzer_settings.md#http-basic-authentication)        | HTTP 认证的用户名。 |
| [`FUZZAPI_HTTP_PASSWORD`](customizing_analyzer_settings.md#http-basic-authentication)        | HTTP 认证的密码。 |
| [`FUZZAPI_HTTP_PASSWORD_BASE64`](customizing_analyzer_settings.md#http-basic-authentication) | HTTP 认证的密码，Base64 编码。 |
| `FUZZAPI_SUCCESS_STATUS_CODES`                                                               | 指定以逗号（`,`）分隔的 HTTP 成功状态码列表，用于确定 API 模糊测试扫描作业是否通过。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/442219)。示例：`'200, 201, 204'` |
