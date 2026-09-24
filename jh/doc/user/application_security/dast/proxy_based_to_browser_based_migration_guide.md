---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从基于代理的 DAST 分析器迁移到 DAST 版本 5
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- [基于代理的 DAST 分析器](proxy_based_to_browser_based_migration_guide.md) 在极狐GitLab 16.6 中被弃用，并在 17.0 中移除。

{{< /history >}}

[DAST 版本 5](browser/_index.md) 使用基于浏览器的分析器取代了基于代理的分析器。本文档旨在指导您从基于代理的分析器迁移到 DAST 版本 5。

如果满足以下所有条件，请遵循本迁移指南：

1. 您使用极狐GitLab DAST 在 CI/CD 流水线中运行 DAST 扫描。
1. DAST CI/CD 作业通过包含 `DAST.gitlab-ci.yml` 或 `DAST.latest.gitlab-ci.yml` 任一 DAST 模板进行配置。
1. CI/CD 变量 `DAST_VERSION` 未设置，或设置为 `4` 或更低。
1. CI/CD 变量 `DAST_BROWSER_SCAN` 未设置，或设置为 `false`。

请阅读以下章节并进行推荐的更改，以迁移到 DAST 版本 5。

<a id="dast-analyzer-versions"></a>

## DAST 分析器版本

DAST 有两个主要版本：4 和 5。
从极狐GitLab 17.0 开始，DAST 模板 `DAST.gitlab-ci.yml` 和 `DAST.latest.gitlab-ci.yml` 默认使用 DAST 版本 5。
您可以继续使用 DAST 版本 4，但应仅将其作为迁移到 DAST 版本 5 期间的临时措施。有关详细信息，请参阅[继续使用基于代理的分析器](#continuing-to-use-the-proxy-based-analyzer)。

每个 DAST 主要版本默认使用不同的分析器：

- DAST 版本 4 使用基于代理的分析器。
- DAST 版本 5 使用基于浏览器的分析器。

DAST 版本 5 使用一组新的 CI/CD 变量。已为 DAST 版本 4 的变量名创建了别名。

需要进行的更改：

- 要在极狐GitLab 16.11 及更早版本中使用 DAST 版本 5 测试您的 DAST 扫描，请将 CI/CD 变量 `DAST_VERSION` 设置为 `5`。

<a id="continuing-to-use-the-proxy-based-analyzer"></a>

## 继续使用基于代理的分析器

您可以使用基于代理的 DAST 分析器直到极狐GitLab 18.0。此旧版分析器中的错误和漏洞将不会被修复。

需要进行的更改：

- 要继续使用基于代理的分析器，请将 CI/CD 变量 `DAST_VERSION` 设置为 `4`。

<a id="artifacts"></a>

## 产物

极狐GitLab 17.0 会自动将 DAST 版本 5 生成的产物发布到 DAST CI 作业。

需要进行的更改：

- 如果您已覆盖 CI 作业定义以公开文件日志、爬取图或身份验证报告，请从 CI 作业定义中移除 `artifacts`。
- CI/CD 变量 `DAST_BROWSER_FILE_LOG_PATH` 和 `DAST_FILE_LOG_PATH` 不再需要。

<a id="authentication"></a>

## 身份验证

基于代理的分析器和 DAST 版本 5 都使用基于浏览器的分析器进行身份验证。升级到 DAST 版本 5 不会改变身份验证的工作方式。

需要进行的更改：

- 重命名身份验证 CI/CD 变量，请参阅带有 `DAST_AUTH` 前缀的变量。
- 如果尚未执行，请使用 `DAST_SCOPE_EXCLUDE_URLS` 从扫描中排除注销 URL。

<a id="crawling"></a>

## 爬取

DAST 版本 5 在浏览器中爬取目标应用程序，以提供更好的爬取覆盖率。与同等的基于代理的分析器爬取相比，这可能需要更多的资源来运行。

需要进行的更改：

- 使用 `DAST_TARGET_URL` 代替 `DAST_WEBSITE`。
- 使用 `DAST_CRAWL_TIMEOUT` 代替 `DAST_SPIDER_MINS`。
- CI/CD 变量 `DAST_USE_AJAX_SPIDER`、`DAST_SPIDER_START_AT_HOST`、`DAST_ZAP_CLI_OPTIONS` 和 `DAST_ZAP_LOG_CONFIGURATION` 不再受支持。
- 如果 DAST 应处理大于 10 MB 的响应正文，请配置 `DAST_PAGE_MAX_RESPONSE_SIZE_MB`。
- 考虑为执行 DAST 作业的极狐GitLab Runner 提供更多 CPU 资源。

<a id="scope"></a>

## 范围

与基于代理的分析器相比，DAST 版本 5 对范围提供了更多控制。

需要进行的更改：

- 使用 `DAST_SCOPE_ALLOW_HOSTS` 代替 `DAST_ALLOWED_HOSTS`。
- `DAST_TARGET_URL` 的域会自动添加到 `DAST_SCOPE_ALLOW_HOSTS` 中，请考虑为目标应用程序 API 和资产端点添加域。
- 通过将域添加到 `DAST_SCOPE_EXCLUDE_HOSTS` 中，将其从扫描中移除（身份验证期间除外）。

<a id="vulnerability-checks"></a>

## 漏洞检查

<a id="changes-required"></a>

### 需要的更改

DAST 版本 5 使用极狐GitLab 构建的漏洞定义，这些定义不直接映射到基于代理的分析器定义。

需要进行的更改：

- 使用 `DAST_CHECKS_TO_RUN` 代替 `DAST_ONLY_INCLUDE_RULES`。将使用的 ID 更改为极狐GitLab DAST 漏洞检查 ID。
- 使用 `DAST_CHECKS_TO_EXCLUDE` 代替 `DAST_EXCLUDE_RULES`。将使用的 ID 更改为极狐GitLab DAST 漏洞检查 ID。
- 请参阅[漏洞检查](browser/checks/_index.md)文档，了解极狐GitLab DAST 漏洞检查的描述和 ID。
- CI/CD 变量 `DAST_AGGREGATE_VULNERABILITIES` 和 `DAST_MAX_URLS_PER_VULNERABILITY` 不再受支持。

<a id="why-migrating-produces-different-vulnerabilities"></a>

### 为什么迁移会产生不同的漏洞

基于代理的扫描和基于浏览器的 DAST 版本 5 扫描不会产生相同的结果，因为它们使用不同的漏洞检查集。

DAST 版本 5 没有与基于代理的检查等效的检查，这些检查会产生太多误报，或者因为现代浏览器不允许利用该漏洞而不值得运行，或者不再被视为相关。
DAST 版本 5 包含基于代理的分析器所没有的检查。

DAST 版本 5 扫描提供了更好的应用程序覆盖率，因此它们可能会发现更多漏洞，因为您的站点有更多部分被扫描。

<a id="coverage"></a>

### 覆盖率

还有一项基于代理的主动检查尚未在基于浏览器的 DAST 分析器中实现。剩余主动检查的迁移已在 [epic 13411](https://jihulab.com/groups/gitlab-cn/-/epics/13411) 中提出。如果您希望在最后一个检查迁移之前继续使用 DAST 版本 4，请参阅[继续使用基于代理的分析器](#continuing-to-use-the-proxy-based-analyzer)。

剩余检查：

- CWE-79：跨站脚本（XSS）

<a id="on-demand-scans"></a>

## 按需扫描

从极狐GitLab 17.0 开始，按需扫描使用 [DAST 版本 5](https://jihulab.com/groups/gitlab-cn/-/epics/11429) 运行基于浏览器的扫描。

<a id="troubleshooting"></a>

## 故障排除

请参阅 DAST 版本 5 的[故障排除](browser/troubleshooting.md)文档。

<a id="changes-to-cicd-variables"></a>

## CI/CD 变量的更改

下表概述了每个基于代理的分析器 CI/CD 变量所需的迁移操作。有关配置 DAST 版本 5 的更多信息，请参阅[配置](browser/configuration/_index.md)。

| 基于代理的分析器 CI/CD 变量 | 所需操作 | 备注 |
|:-------------------------------------|:-------------------------|:-----------------------------------------------------------------------------------------|
| `DAST_ADVERTISE_SCAN` | 重命名 | 改为 `DAST_REQUEST_ADVERTISE_SCAN` |
| `DAST_ALLOWED_HOSTS` | 重命名 | 改为 `DAST_SCOPE_ALLOW_HOSTS` |
| `DAST_API_HOST_OVERRIDE` | 移除 | 不受支持 |
| `DAST_API_SPECIFICATION` | 移除 | 不受支持 |
| `DAST_AUTH_EXCLUDE_URLS` | 重命名 | 改为 `DAST_SCOPE_EXCLUDE_URLS` |
| `DAST_AUTO_UPDATE_ADDONS` | 移除 | 不受支持 |
| `DAST_BROWSER_FILE_LOG_PATH` | 移除 | 不再需要 |
| `DAST_DEBUG` | 移除 | 不受支持 |
| `DAST_EXCLUDE_RULES` | 重命名，更新检查 ID | 改为 `DAST_CHECKS_TO_EXCLUDE` |
| `DAST_EXCLUDE_URLS` | 重命名 | 改为 `DAST_SCOPE_EXCLUDE_URLS` |
| `DAST_FILE_LOG_PATH` | 移除 | 不再需要 |
| `DAST_FULL_SCAN_ENABLED` | 重命名 | 改为 `DAST_FULL_SCAN` |
| `DAST_HTML_REPORT` | 移除 | 不受支持 |
| `DAST_INCLUDE_ALPHA_VULNERABILITIES` | 移除 | 不受支持 |
| `DAST_MARKDOWN_REPORT` | 移除 | 不受支持 |
| `DAST_MASK_HTTP_HEADERS` | 移除 | 不受支持 |
| `DAST_MAX_URLS_PER_VULNERABILITY` | 移除 | 不受支持 |
| `DAST_ONLY_INCLUDE_RULES` | 重命名，更新检查 ID | 改为 `DAST_CHECKS_TO_RUN` |
| `DAST_PATHS` | 无 | 受支持 |
| `DAST_PATHS_FILE` | 无 | 受支持 |
| `DAST_PKCS12_CERTIFICATE_BASE64` | 无 | 受支持 |
| `DAST_PKCS12_PASSWORD` | 无 | 受支持 |
| `DAST_SKIP_TARGET_CHECK` | 无 | 受支持 |
| `DAST_SPIDER_MINS` | 更改 | 改为使用持续时间的 `DAST_CRAWL_TIMEOUT`。例如，使用 `5m` 代替 `5` |
| `DAST_SPIDER_START_AT_HOST` | 移除 | 不受支持 |
| `DAST_TARGET_AVAILABILITY_TIMEOUT` | 更改 | 改为使用持续时间的 `DAST_TARGET_CHECK_TIMEOUT`。例如，使用 `60s` 代替 `60` |
| `DAST_USE_AJAX_SPIDER` | 移除 | 不受支持 |
| `DAST_XML_REPORT` | 移除 | 不受支持 |
| `DAST_WEBSITE` | 重命名 | 改为 `DAST_TARGET_URL`<br/>私有化部署：在移除 `DAST_WEBSITE` 之前，请将您的实例升级到 17.0 或更高版本。如果您使用 17.0 之前版本的极狐GitLab 中包含的 `DAST.gitlab-ci.yml` 文件，则需要此变量。 |
| `DAST_ZAP_CLI_OPTIONS` | 移除 | 不受支持 |
| `DAST_ZAP_LOG_CONFIGURATION` | 移除 | 不受支持 |
| `SECURE_ANALYZERS_PREFIX` | 无 | 受支持 |

