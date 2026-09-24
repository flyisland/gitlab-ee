---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 DAST 版本 4 基于浏览器的分析器迁移至 DAST 版本 5
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- [DAST 基于代理的分析器](proxy_based_to_browser_based_migration_guide.md) 在 极狐GitLab 16.6 中已弃用，并于 17.0 中移除。

{{< /history >}}

[DAST 版本 5](browser/_index.md) 替换 DAST 版本 4。本文档作为从 DAST 版本 4 基于浏览器的分析器迁移到 DAST 版本 5 的指南。

如果满足以下所有条件，请遵循本迁移指南：

1. 你使用 极狐GitLab DAST 在 CI/CD 流水线中运行 DAST 扫描。
1. DAST CI/CD 作业是通过包含 DAST 模板 `DAST.gitlab-ci.yml` 或 `DAST.latest.gitlab-ci.yml` 来配置的。
1. CI/CD 变量 `DAST_VERSION` 未设置或设置为 `4` 或更小。
1. CI/CD 变量 `DAST_BROWSER_SCAN` 设置为 `true`。

通过阅读以下部分并进行推荐的更改，迁移到 DAST 版本 5。

<a id="dast-analyzer-versions"></a>

## DAST 分析器版本

DAST 有两个主要版本：4 和 5。
自 极狐GitLab 17.0 起，DAST 模板 `DAST.gitlab-ci.yml` 和 `DAST.latest.gitlab-ci.yml` 默认使用 DAST 版本 5。
你可以继续使用 DAST 版本 4，但应该仅作为迁移到 DAST 版本 5 期间的临时措施。详情请参见[继续使用版本 4](#continuing-to-use-version-4)。

每个 DAST 主版本运行不同的分析器：

- DAST 版本 4 可以运行基于代理或基于浏览器的分析器，并且默认使用基于代理的分析器。
- DAST 版本 5 仅运行基于浏览器的分析器。

DAST 版本 5 使用一组新的 CI/CD 变量。已为 DAST 版本 4 的变量名创建了别名。

对于 极狐GitLab 16.11 及更早版本的更改：

- 要测试 DAST 版本 5，请将 CI/CD 变量 `DAST_VERSION` 设置为 5。
- 为避免作业失败，请勿删除或重命名 `DAST_WEBSITE`。`DAST.gitlab-ci.yml` 模板版本 16.11 及更早版本[仍使用 `DAST_WEBSITE`](https://jihulab.com/gitlab-cn/gitlab/-/blob/v16.11.5-ee/lib/gitlab/ci/templates/Security/DAST.gitlab-ci.yml?ref_type=tags#L39) 变量。

对于 极狐GitLab 17.0 及更高版本的更改：

- 升级到 极狐GitLab 17.0 后，将 `DAST_WEBSITE` 重命名为 `DAST_TARGET_URL`。
- 当开始使用将 `DAST_VERSION` 设置为 5 的新模板时，请确保 CI/CD 变量 `DAST_VERSION` 未设置。

<a id="continuing-to-use-version-4"></a>

## 继续使用版本 4

你可以使用 DAST 版本 4 基于代理的分析器直至 极狐GitLab 18.0。此遗留分析器中的错误和漏洞将不会被修复。

需进行的更改：

- 要继续使用 DAST 版本 4，请将 CI/CD 变量 `DAST_VERSION` 设置为 4。

<a id="artifacts"></a>

## 产物

极狐GitLab 17.0 会自动将 DAST 版本 5 生成的产物发布到 DAST CI 作业。

需进行的更改：

- 如果你已覆盖 CI 作业定义以公开文件日志、爬网图或认证报告，请从 CI 作业定义中删除 `artifacts`。
- 不再需要 CI/CD 变量 `DAST_BROWSER_FILE_LOG_PATH` 和 `DAST_FILE_LOG_PATH`。

<a id="vulnerability-check-coverage"></a>

## 漏洞检查覆盖

基于浏览器的 DAST 版本 4 针对未包含在基于浏览器的分析器中的主动检查使用了基于代理的分析器检查。基于浏览器的 DAST 版本 5 不包括基于代理的分析器，因此在迁移到版本 5 时检查覆盖范围存在差距。

浏览器分析器未覆盖的一个基于代理的主动检查。其余主动检查的迁移计划在[史诗 13411](https://gitlab.com/groups/gitlab-org/-/epics/13411) 中提议。如果你希望在最后一个检查迁移之前继续使用 DAST 版本 4，请参见[继续使用版本 4](#continuing-to-use-version-4)。

剩余检查：

- CWE-79：跨站脚本 (XSS)

在史诗 [BBD 剩余主动检查](https://gitlab.com/groups/gitlab-org/-/epics/13411) 中追踪剩余检查的进展。

<a id="changes-to-cicd-variables"></a>

## CI/CD 变量更改

下表概述了每个基于浏览器的分析器 DAST 版本 4 CI/CD 变量所需的迁移操作。有关配置基于浏览器的分析器的更多信息，请参阅[配置](browser/configuration/_index.md)。

| DAST 版本 4 CI/CD 变量                       | 所需操作             | 说明                                                                                                                      |
|:--------------------------------------------|:---------------------|:--------------------------------------------------------------------------------------------------------------------------|
| `DAST_ADVERTISE_SCAN`                       | 重命名               | 改为 `DAST_REQUEST_ADVERTISE_SCAN`                                                                                         |
| `DAST_AFTER_LOGIN_ACTIONS`                  | 重命名               | 改为 `DAST_AUTH_AFTER_LOGIN_ACTIONS`                                                                                       |
| `DAST_AUTH_COOKIES`                         | 重命名               | 改为 `DAST_AUTH_COOKIE_NAMES`                                                                                              |
| `DAST_AUTH_DISABLE_CLEAR_FIELDS`            | 重命名               | 改为 `DAST_AUTH_CLEAR_INPUT_FIELDS`                                                                                        |
| `DAST_AUTH_REPORT`                          | 无需操作             |                                                                                                                           |
| `DAST_AUTH_TYPE`                            | 无需操作             |                                                                                                                           |
| `DAST_AUTH_URL`                             | 无需操作             |                                                                                                                           |
| `DAST_AUTH_VERIFICATION_LOGIN_FORM`         | 重命名               | 改为 `DAST_AUTH_SUCCESS_IF_NO_LOGIN_FORM`                                                                                  |
| `DAST_AUTH_VERIFICATION_SELECTOR`           | 重命名               | 改为 `DAST_AUTH_SUCCESS_IF_ELEMENT_FOUND`                                                                                  |
| `DAST_AUTH_VERIFICATION_URL`                | 重命名               | 改为 `DAST_AUTH_SUCCESS_IF_AT_URL`                                                                                         |
| `DAST_BROWSER_PATH_TO_LOGIN_FORM`           | 重命名               | 改为 `DAST_AUTH_BEFORE_LOGIN_ACTIONS`                                                                                      |
| `DAST_BROWSER_ACTION_STABILITY_TIMEOUT`     | 替换                 | 用 `DAST_PAGE_DOM_READY_TIMEOUT` 替换                                                                                      |
| `DAST_BROWSER_ACTION_TIMEOUT`               | 删除                 | 不支持                                                                                                                    |
| `DAST_BROWSER_ALLOWED_HOSTS`                | 重命名               | 改为 `DAST_SCOPE_ALLOW_HOSTS`                                                                                              |
| `DAST_BROWSER_CACHE`                        | 重命名               | 改为 `DAST_USE_CACHE`                                                                                                      |
| `DAST_BROWSER_COOKIES`                      | 重命名               | 改为 `DAST_REQUEST_COOKIES`                                                                                                |
| `DAST_BROWSER_CRAWL_GRAPH`                  | 重命名               | 改为 `DAST_CRAWL_GRAPH`                                                                                                    |
| `DAST_BROWSER_CRAWL_TIMEOUT`                | 重命名               | 改为 `DAST_CRAWL_TIMEOUT`                                                                                                  |
| `DAST_BROWSER_DEVTOOLS_LOG`                 | 重命名               | 改为 `DAST_LOG_DEVTOOLS_CONFIG`                                                                                            |
| `DAST_BROWSER_DOM_READY_AFTER_TIMEOUT`      | 重命名               | 改为 `DAST_PAGE_DOM_STABLE_WAIT`                                                                                           |
| `DAST_BROWSER_ELEMENT_TIMEOUT`              | 重命名               | 改为 `DAST_PAGE_ELEMENT_READY_TIMEOUT`                                                                                     |
| `DAST_BROWSER_EXCLUDED_ELEMENTS`            | 重命名               | 改为 `DAST_SCOPE_EXCLUDE_ELEMENTS`                                                                                         |
| `DAST_BROWSER_EXCLUDED_HOSTS`               | 重命名               | 改为 `DAST_SCOPE_EXCLUDE_HOSTS`                                                                                            |
| `DAST_BROWSER_EXTRACT_ELEMENT_TIMEOUT`      | 重命名               | 改为 `DAST_CRAWL_EXTRACT_ELEMENT_TIMEOUT`                                                                                  |
| `DAST_BROWSER_FILE_LOG`                     | 重命名               | 改为 `DAST_LOG_FILE_CONFIG`                                                                                                |
| `DAST_BROWSER_FILE_LOG_PATH`                | 删除                 | 不再需要                                                                                                                  |
| `DAST_BROWSER_IGNORED_HOSTS`                | 重命名               | 改为 `DAST_SCOPE_IGNORE_HOSTS`                                                                                             |
| `DAST_BROWSER_INCLUDE_ONLY_RULES`           | 重命名               | 改为 `DAST_CHECKS_TO_RUN`                                                                                                  |
| `DAST_BROWSER_LOG`                          | 重命名               | 改为 `DAST_LOG_CONFIG`                                                                                                     |
| `DAST_BROWSER_LOG_CHROMIUM_OUTPUT`          | 重命名               | 改为 `DAST_LOG_BROWSER_OUTPUT`                                                                                             |
| `DAST_BROWSER_MAX_ACTIONS`                  | 重命名               | 改为 `DAST_CRAWL_MAX_ACTIONS`                                                                                              |
| `DAST_BROWSER_MAX_DEPTH`                    | 重命名               | 改为 `DAST_CRAWL_MAX_DEPTH`                                                                                               |
| `DAST_BROWSER_MAX_RESPONSE_SIZE_MB`         | 重命名               | 改为 `DAST_PAGE_MAX_RESPONSE_SIZE_MB`                                                                                      |
| `DAST_BROWSER_NAVIGATION_STABILITY_TIMEOUT` | 重命名               | 改为 `DAST_PAGE_DOM_READY_TIMEOUT`                                                                                         |
| `DAST_BROWSER_NAVIGATION_TIMEOUT`           | 重命名               | 改为 `DAST_PAGE_READY_AFTER_NAVIGATION_TIMEOUT`                                                                            |
| `DAST_BROWSER_NUMBER_OF_BROWSERS`           | 重命名               | 改为 `DAST_CRAWL_WORKER_COUNT`                                                                                             |
| `DAST_BROWSER_PAGE_LOADING_SELECTOR`        | 重命名               | 改为 `DAST_PAGE_IS_LOADING_ELEMENT`                                                                                        |
| `DAST_BROWSER_PAGE_READY_SELECTOR`          | 重命名               | 改为 `DAST_PAGE_IS_READY_ELEMENT`                                                                                          |
| `DAST_BROWSER_PASSIVE_CHECK_WORKERS`        | 重命名               | 改为 `DAST_PASSIVE_SCAN_WORKER_COUNT`                                                                                      |
| `DAST_BROWSER_SCAN`                         | 删除                 | 不再需要                                                                                                                  |
| `DAST_BROWSER_SEARCH_ELEMENT_TIMEOUT`       | 重命名               | 改为 `DAST_CRAWL_SEARCH_ELEMENT_TIMEOUT`                                                                                   |
| `DAST_BROWSER_STABILITY_TIMEOUT`            | 重命名               | 改为 `DAST_PAGE_READY_AFTER_ACTION_TIMEOUT`                                                                                |
| `DAST_EXCLUDE_RULES`                        | 重命名               | 改为 `DAST_CHECKS_TO_EXCLUDE`                                                                                              |
| `DAST_EXCLUDE_URLS`                         | 重命名               | 改为 `DAST_SCOPE_EXCLUDE_URLS`                                                                                             |
| `DAST_FF_ENABLE_BAS`                        | 删除                 | 不支持                                                                                                                    |
| `DAST_FILE_LOG_PATH`                        | 删除                 | 不再需要                                                                                                                  |
| `DAST_FIRST_SUBMIT_FIELD`                   | 重命名               | 改为 `DAST_AUTH_FIRST_SUBMIT_FIELD`                                                                                        |
| `DAST_FULL_SCAN_ENABLED`                    | 重命名               | 改为 `DAST_FULL_SCAN`                                                                                                      |
| `DAST_PASSWORD`                             | 重命名               | 改为 `DAST_AUTH_PASSWORD`                                                                                                  |
| `DAST_PASSWORD_FIELD`                       | 重命名               | 改为 `DAST_AUTH_PASSWORD_FIELD`                                                                                            |
| `DAST_PATHS`                                | 重命名               | 改为 `DAST_TARGET_PATHS`                                                                                                   |
| `DAST_PATHS_FILE`                           | 重命名               | 改为 `DAST_TARGET_PATHS_FROM_FILE`                                                                                         |
| `DAST_PKCS12_CERTIFICATE_BASE64`            | 无需操作             |                                                                                                                           |
| `DAST_PKCS12_PASSWORD`                      | 无需操作             |                                                                                                                           |
| `DAST_REQUEST_HEADERS`                      | 无需操作             |                                                                                                                           |
| `DAST_SKIP_TARGET_CHECK`                    | 重命名               | 改为 `DAST_TARGET_CHECK_SKIP`                                                                                              |
| `DAST_SUBMIT_FIELD`                         | 重命名               | 改为 `DAST_AUTH_SUBMIT_FIELD`                                                                                              |
| `DAST_TARGET_AVAILABILITY_TIMEOUT`          | 重命名               | 改为 `DAST_TARGET_CHECK_TIMEOUT`                                                                                           |
| `DAST_USERNAME`                             | 重命名               | 改为 `DAST_AUTH_USERNAME`                                                                                                  |
| `DAST_USERNAME_FIELD`                       | 重命名               | 改为 `DAST_AUTH_USERNAME_FIELD`                                                                                            |
| `DAST_WEBSITE`                              | 重命名               | 改为 `DAST_TARGET_URL`<br/>私有化部署：在删除 `DAST_WEBSITE` 之前，将您的实例升级到 17.0 或更高版本。如果您使用 极狐GitLab 17.0 之前版本中包含的 `DAST.gitlab-ci.yml` 文件，则需要此变量。 |