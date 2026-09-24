---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 可用的 CI/CD 变量
---

<!--
  此文档由脚本自动生成。
  请勿直接编辑此文件。

  要编辑介绍性文本，请修改 `tooling/dast_variables/docs/templates/default.md.haml`。
  要编辑变量信息，请修改 `lib/gitlab/security/dast_variables.rb`。

  运行 `bundle exec rake gitlab:dast_variables:compile_docs`
  或检查 `lib/tasks/gitlab/dast_variables.rake` 中的 `compile_docs` 任务。
-->

这些 CI/CD 变量特定于基于浏览器的 DAST 分析器。它们可用于根据你的需求自定义 DAST 的行为。

<a id="scanner-behavior"></a>

## 扫描器行为

这些变量控制扫描的进行方式以及结果的存储位置。

| CI/CD 变量 | 类型 | 示例 | 描述 |
| :------------- | :--- | ------- | :---------- |
| `DAST_CHECKS_TO_EXCLUDE` | string | `552.2,78.1` | 要从扫描中排除的检查标识符的逗号分隔列表。有关标识符，请参见[漏洞检查](../checks/_index.md)。 |
| `DAST_CHECKS_TO_RUN` | List of strings | `16.1,16.2,16.3` | 用于扫描的检查标识符的逗号分隔列表。有关标识符，请参见[漏洞检查](../checks/_index.md)。 |
| `DAST_CRAWL_GRAPH` | boolean | `true` | 设置为 `true` 以生成在扫描爬取阶段访问的导航路径的 SVG 图。你还必须将 `gl-dast-crawl-graph.svg` 定义为 CI 作业产物才能访问生成的图。默认为 `false`。 |
| `DAST_FULL_SCAN` | boolean | `true` | 设置为 `true` 以同时运行被动和主动检查。默认为 `false`。 |
| `DAST_LOG_BROWSER_OUTPUT` | boolean | `true` | 设置为 `true` 以记录 Chromium 的 `STDOUT` 和 `STDERR`。 |
| `DAST_LOG_CONFIG` | List of strings | `brows:debug,auth:debug` | （已弃用）要在控制台日志中使用的模块及其预期的日志级别的列表。 |
| `DAST_LOG_DEVTOOLS_CONFIG` | string | `Default:messageAndBody,truncate:2000` | 设置为记录 DAST 与 Chromium 浏览器之间的协议消息。 |
| `DAST_LOG_FILE_CONFIG` | List of strings | `brows:debug,auth:debug` | 要在文件日志中使用的模块及其预期的日志级别的列表。 |
| `DAST_LOG_FILE_PATH` | string | `/output/browserker.log` | 设置为文件日志的路径。默认为 `gl-dast-scan.log`。 |
| `SECURE_ANALYZERS_PREFIX` | URL | `registry.organization.com` | 设置从中下载分析器的 Docker 镜像仓库基础地址。 |
| `SECURE_LOG_LEVEL` | string | `debug` | 设置文件日志的默认级别。请参见 [SECURE_LOG_LEVEL](../troubleshooting.md#secure_log_level)。 |

<a id="elements-actions-and-timeouts"></a>

## 元素、操作和超时

这些变量告诉扫描器在哪里查找某些元素、要采取哪些操作以及等待操作完成多长时间。

| CI/CD 变量 | 类型 | 示例 | 描述 |
| :------------- | :--- | ------- | :---------- |
| `DAST_ACTIVE_SCAN_TIMEOUT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `3h` | 等待扫描的主动扫描阶段完成的最长时间。默认为 3h。 |
| `DAST_ACTIVE_SCAN_WORKER_COUNT` | number | `3` | 并行运行的主动检查的数量。默认为 3。 |
| `DAST_CRAWL_MAX_ACTIONS` | number | `10000` | 爬虫执行的最大操作数。示例操作包括选择链接或填写表单。默认为 `10000`。 |
| `DAST_CRAWL_MAX_DEPTH` | number | `10` | 爬虫执行的最大链式操作数。例如，`点击, 表单填写, 点击` 的深度为三。默认为 `10`。 |
| `DAST_CRAWL_TIMEOUT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `5m` | 等待扫描爬取阶段完成的最长时间。默认为 `24h`。 |
| `DAST_CRAWL_WORKER_COUNT` | number | `3` | 要使用的最大并发浏览器实例数。对于在 JihuLab.com 上的实例 Runner，我们建议最多三个。拥有更多资源的私有 Runner 可能会从更高的数量中受益，但在五到七个实例后可能收益甚微。默认值是动态的，等于可用逻辑 CPU 的数量。 |
| `DAST_PAGE_DOM_READY_TIMEOUT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `7s` | 在导航完成后等待浏览器认为页面已加载并准备好进行分析的最长时间。默认为 `6s`。 |
| `DAST_PAGE_DOM_STABLE_WAIT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `200ms` | 定义在检查页面是否稳定之前等待 DOM 更新的时间。默认为 `500ms`。 |
| `DAST_PAGE_ELEMENT_READY_TIMEOUT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `600ms` | 在确定元素准备就绪进行分析之前等待的最长时间。默认为 `300ms`。 |
| `DAST_PAGE_IS_LOADING_ELEMENT` | [selector](authentication.md#finding-an-elements-selector) | `css:#page-is-loading` | 选择器，当其在页面上不再可见时，向分析器指示页面已加载完毕且扫描可以继续。不能与 `DAST_PAGE_IS_READY_ELEMENT` 一起使用。 |
| `DAST_PAGE_IS_READY_ELEMENT` | [selector](authentication.md#finding-an-elements-selector) | `css:#page-is-ready` | 选择器，当其在页面上可见时，向分析器指示页面已加载完毕且扫描可以继续。不能与 `DAST_PAGE_IS_LOADING_ELEMENT` 一起使用。 |
| `DAST_PAGE_MAX_RESPONSE_SIZE_MB` | number | `15` | HTTP 响应体的最大大小。大于此大小的响应将被浏览器阻止。默认为 `10` MB。 |
| `DAST_PAGE_READY_AFTER_ACTION_TIMEOUT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `7s` | 等待浏览器认为页面已加载并准备好进行分析的最长时间。默认为 `7s`。 |
| `DAST_PAGE_READY_AFTER_NAVIGATION_TIMEOUT` | [Duration string](https://pkg.go.dev/time#ParseDuration) | `15s` | 等待浏览器从一个页面导航到另一个页面的最长时间。默认为 `15s`。 |
| `DAST_PASSIVE_SCAN_WORKER_COUNT` | int | `5` | 并行执行被动扫描的工作器数量。默认为可用 CPU 的数量。 |
| `DAST_PKCS12_CERTIFICATE_BASE64` | string | `ZGZkZ2p5NGd...` | 用于需要双向 TLS 的站点的 PKCS12 证书。必须编码为 base64 文本。 |
| `DAST_PKCS12_PASSWORD` | string | `password` | `DAST_PKCS12_CERTIFICATE_BASE64` 中使用的证书的密码。使用极狐GitLab UI 创建敏感[自定义 CI/CD 变量](../../../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)。 |
| `DAST_REQUEST_ADVERTISE_SCAN` | boolean | `true` | 设置为 `true` 以在每个发送的请求中添加 `Via: 极狐GitLab DAST <version>` 标头，表明该请求是作为极狐GitLab DAST 扫描的一部分发送的。默认：`false`。 |
| `DAST_REQUEST_COOKIES` | dictionary | `abtesting_group:3,region:locked` | 要添加到每个请求的 cookie 名称和值。 |
| `DAST_REQUEST_HEADERS` | String | `Cache-control:no-cache` | 设置为请求标头名称和值的逗号分隔列表。不支持以下标头：`content-length`、`cookie2`、`keep-alive`、`hosts`、`trailer`、`transfer-encoding` 以及所有带有 `proxy-` 前缀的标头。 |
| `DAST_REQUEST_USER_AGENT` | String |  | 设置以更改浏览器发送的 user-agent 字符串。默认 user-agent 是 Linux 上的 Google Chrome。 |
| `DAST_SCOPE_ALLOW_HOSTS` | List of strings | `site.com,another.com` | 此变量中包含的主机名在爬取时被视为在范围内。默认情况下，`DAST_TARGET_URL` 的主机名包含在允许的主机列表中。使用 `DAST_REQUEST_HEADERS` 设置的标头将添加到向这些主机名发出的每个请求中。 |
| `DAST_SCOPE_EXCLUDE_ELEMENTS` | [selector](authentication.md#finding-an-elements-selector) | `a[href='2.html'],css:.no-follow` | 在扫描时忽略的选择器的逗号分隔列表。 |
| `DAST_SCOPE_EXCLUDE_HOSTS` | List of strings | `site.com,another.com` | 此变量中包含的主机名被视为排除在外，连接将被强制断开。 |
| `DAST_SCOPE_IGNORE_HOSTS` | List of strings | `site.com,another.com` | 此变量中包含的主机名会被访问，但不会被攻击，也不会报告。 |
| `DAST_TARGET_CHECK_SKIP` | boolean | `true` | 设置为 `true` 以防止 DAST 在扫描前检查目标是否可用。默认：`false`。 |
| `DAST_TARGET_CHECK_TIMEOUT` | number | `60` | 等待目标可用的时间限制（以秒为单位）。默认：`60s`。 |
| `DAST_TARGET_PATHS_FILE` | string | `/builds/project/urls.txt` | 仅扫描这些路径，而不是爬取整个站点。设置为包含相对于 `DAST_TARGET_URL` 的 URL 路径列表的文件路径。该文件必须是纯文本文件，每行一个路径。设置此变量后，`DAST_CRAWL_MAX_DEPTH` 默认值为 1。要防止此情况，请设置 `DAST_OVERRIDE_MAX_DEPTH: false`。 |
| `DAST_TARGET_PATHS` | string | `/page1.html,/category1/page3.html` | 仅扫描这些路径，而不是爬取整个站点。设置为相对于 `DAST_TARGET_URL` 的 URL 路径的逗号分隔列表。设置此变量后，`DAST_CRAWL_MAX_DEPTH` 默认值为 1。要防止此情况，请设置 `DAST_OVERRIDE_MAX_DEPTH: false`。 |
| `DAST_TARGET_URL` | URL | `https://site.com` | 要扫描的网站的 URL。 |
| `DAST_USE_CACHE` | boolean | `true` | 设置为 `false` 以禁用缓存。默认：`true`。**注意**：禁用缓存可能会导致 OOM 事件或 DAST 作业超时。 |
| `DAST_CRAWL_GROUPED_URLS` | string | `https://example.com/hello/*,https://example.com/world/*/details` | （实验性）设置为至少包含一个 `*` 的通配符 URL 模式的逗号分隔列表。为了减少扫描时间，扫描器会分组并仅分析每个模式匹配的一个 URL。 |

<a id="authentication"></a>

### 身份验证

这些变量告诉扫描器如何对你的应用程序进行身份验证。

| CI/CD 变量 | 类型 | 示例 | 描述 |
| :------------- | :--- | ------- | :---------- |
| `DAST_AUTH_AFTER_LOGIN_ACTIONS` | string | `select(option=id:accept-yes),click(on=css:.continue)` | 登录后但在登录验证之前要执行的操作的逗号分隔列表。支持 `click` 和 `select` 操作。请参见[提交登录表单后执行额外操作](authentication.md#taking-additional-actions-after-submitting-the-login-form)。 |
| `DAST_AUTH_BEFORE_LOGIN_ACTIONS` | [selector](authentication.md#finding-an-elements-selector) | `css:.user,id:show-login-form` | 表示在将 DAST_AUTH_USERNAME 和 DAST_AUTH_PASSWORD 输入登录表单之前要单击的元素的逗号分隔选择器列表。 |
| `DAST_AUTH_CLEAR_INPUT_FIELDS` | boolean | `true` | 禁用在尝试手动登录之前清除用户名和密码字段。默认为 false。 |
| `DAST_AUTH_COOKIE_NAMES` | string | `sessionID,groupName` | 设置为 cookie 名称的逗号分隔列表，以指定哪些 cookie 用于身份验证。 |
| `DAST_AUTH_FIRST_SUBMIT_FIELD` | [selector](authentication.md#finding-an-elements-selector) | `css:input[type=submit]` | 描述在多页登录流程中点击以提交用户名表单的元素的选择器。 |
| `DAST_AUTH_NEGOTIATE_DELEGATION` | string | `*.example.com,example.com,*.EXAMPLE.COM,EXAMPLE.COM` | 允许哪些服务器进行集成身份验证和委派。此属性设置两个 Chromium 策略：[AuthServerAllowlist](https://chromeenterprise.google/policies/#AuthServerAllowlist) 和 [AuthNegotiateDelegateAllowlist](https://chromeenterprise.google/policies/#AuthNegotiateDelegateAllowlist)。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/502476) 极狐GitLab 17.6。 |
| `DAST_AUTH_OTP_FIELD` | [selector](authentication.md#finding-an-elements-selector) | `name:otp` | 描述用于在登录表单上输入一次性密码的元素的选择器。 |
| `DAST_AUTH_OTP_KEY` | String | `I5UXITDBMIQEIQKTKQFA====` | 生成用于对网站进行身份验证的一次性密码时使用的 Base32 编码的密钥。 |
| `DAST_AUTH_OTP_SUBMIT_FIELD` | [selector](authentication.md#finding-an-elements-selector) | `css:input[type=submit]` | 描述当 OTP 表单与用户名字段分开时，点击以提交该表单的元素的选择器。 |
| `DAST_AUTH_PASSWORD` | String | `P@55w0rd!` | 用于在网站中进行身份验证的密码。 |
| `DAST_AUTH_PASSWORD_FIELD` | [selector](authentication.md#finding-an-elements-selector) | `name:password` | 描述用于在登录表单上输入密码的元素的选择器。 |
| `DAST_AUTH_SUBMIT_FIELD` | [selector](authentication.md#finding-an-elements-selector) | `css:input[type=submit]` | 描述对于单页登录表单点击以提交登录表单，或对于多页登录表单点击以提交密码表单的元素的选择器。 |
| `DAST_AUTH_SUCCESS_IF_AT_URL` | URL | `https://www.site.com/welcome*` | 一个 URL，与浏览器中的 URL 进行比较，以确定提交登录表单后身份验证是否成功。可以使用通配符 `*` 来匹配动态 URL。 |
| `DAST_AUTH_SUCCESS_IF_ELEMENT_FOUND` | [selector](authentication.md#finding-an-elements-selector) | `css:.user-avatar` | 描述一个元素的选择器，该元素的存在用于确定提交登录表单后身份验证是否成功。 |
| `DAST_AUTH_SUCCESS_IF_NO_LOGIN_FORM` | boolean | `true` | 通过检查提交登录表单后是否不存在登录表单来验证身份验证是否成功。此成功检查默认启用。 |
| `DAST_AUTH_TYPE` | string | `basic-digest` | 要使用的身份验证类型。 |
| `DAST_AUTH_URL` | URL | `https://www.site.com/login` | 目标网站上包含登录表单的页面的 URL。DAST_AUTH_USERNAME 和 DAST_AUTH_PASSWORD 将与登录表单一起提交以创建经过身份验证的扫描。 |
| `DAST_AUTH_USERNAME` | string | `user@email.com` | 用于在网站中进行身份验证的用户名。 |
| `DAST_AUTH_USERNAME_FIELD` | [selector](authentication.md#finding-an-elements-selector) | `name:username` | 描述用于在登录表单上输入用户名的元素的选择器。 |
| `DAST_SCOPE_EXCLUDE_URLS` | URLs | `https://site.com/.*/sign-out` | 在已验证的扫描期间要跳过的 URL；逗号分隔。可以使用正则表达式语法来匹配多个 URL。例如，`.*` 匹配任意字符序列。 |
| `DAST_AUTH_REPORT` | boolean | `true` | 设置为 `true` 以生成详细说明身份验证过程中采取的步骤的报告。你还必须将 `gl-dast-debug-auth-report.html` 定义为 CI 作业产物才能访问生成的报告。该报告的内容有助于调试身份验证失败。默认为 `false`。 |