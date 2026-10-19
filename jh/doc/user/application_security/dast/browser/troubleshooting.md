---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 DAST 扫描
---

以下故障排除场景收集自客户支持案例。如果您遇到此处未涉及的问题，或此处信息未能解决您的问题，请创建支持工单。更多详情，请参阅[极狐GitLab 支持](https://gitlab.cn/support)页面。

<a id="when-something-goes-wrong"></a>

## 出现问题时

当 DAST 扫描出现问题时：

- 如果您是首次设置 DAST，请查看[设置 DAST](#setting-up-dast)。
- 如果您遇到特定的错误消息，请查看[已知问题](#known-problems)。

否则，请尝试通过回答以下问题来找出问题所在：

- [预期结果是什么？](#what-is-the-expected-outcome)
- [人工能否实现该结果？](#is-the-outcome-achievable-by-a-human)
- [有什么原因会导致 DAST 无法工作？](#any-reason-why-dast-would-not-work)
- [您的应用程序如何工作？](#how-does-your-application-work)
- [DAST 在做什么？](#what-is-dast-doing)

<a id="setting-up-dast"></a>

### 设置 DAST

首次设置 DAST 时，您可能会遇到以下问题。

<a id="configuration-validation-failed-required-field-url-was-not-set"></a>

#### 配置验证失败：未设置必填字段 URL

当您包含 DAST 模板但未定义目标 URL 时，流水线会在配置验证期间失败，并显示以下错误：

```plaintext
ERR MAIN  configuration validation failed error="the required field URL was not set"
```

此错误表明 DAST 不知道要扫描哪个 URL。要解决此问题，请使用以下方法之一定义目标 URL：

- 在`.gitlab-ci.yml` 文件中设置 `DAST_TARGET_URL` CI/CD 变量：

  ```yaml
  stages:
    - dast

  include:
    - template: Security/DAST.gitlab-ci.yml

  dast:
    variables:
      DAST_TARGET_URL: "https://example.com"
  ```

- 在项目根目录中创建 `environment_url.txt` 文件并添加目标 URL。使用此方法可在动态环境中测试应用程序。

<a id="runner-cannot-connect-to-target-application"></a>

#### Runner 无法连接到目标应用程序

当您的 Runner 无法访问目标应用程序时，DAST 扫描会因连接错误而失败。这通常是由网络配置或防火墙问题引起的。

DAST 需要使用您指定的 URL 连接到您的应用程序：

- 如果您的 `DAST_TARGET_URL` 或 `DAST_AUTH_URL` 包含端口号，请确保您的 Runner 可以访问该特定端口。
- 如果 URL 中未指定端口，DAST 使用标准端口：
  - HTTP URL 使用端口 `80`（例如 `http://example.com`）。
  - HTTPS URL 使用端口 `443`（例如 `https://example.com`）。

连接问题的常见原因包括：

- HTTP 和 HTTPS 内容混合。您的应用程序可能同时使用 HTTP 和 HTTPS。例如，如果您的目标 URL 是 `http://example.com`，但站点从 `https://example.com` 加载资源，请确保您的 Runner 可以访问这两个端口。
- 自定义端口。如果您的应用程序运行在非标准端口上，请将其包含在 `DAST_TARGET_URL`中。例如 `https://example.com:8443`。
- 防火墙规则。如果您的应用程序位于防火墙后面，请配置规则以允许来自 Runner IP 地址的流量。
- 内部和外部网络。确保您的 Runner 位于可以访问您应用程序的网络上。例如，如果您在内部网络的预发布环境中测试，请使用同一网络上的 Runner。

<a id="target-connection-issues"></a>

#### 目标连接问题

在 DAST 开始扫描之前，它会检查目标 URL 是否可访问。如果无法访问目标 URL，DAST 会生成详细的错误消息以帮助诊断问题。默认情况下，DAST 每两秒重试一次连接，最多持续 60 秒。您可以使用 `DAST_TARGET_CHECK_TIMEOUT` 配置 DAST 何时重试连接。

如果您遇到连接问题：

1. 验证您的 `DAST_TARGET_URL` 配置。
   - 检查主机名、端口或协议中是否有拼写错误。
   - 确保 URL 包含协议（`http://`或 `https://`）。
   - 验证端口号与您的应用程序运行所在的端口一致。

1. 从 Runner 测试连接。
   - 测试连接：`curl --verbose "http://your-target-url:port"`
   - 检查 DNS 解析：`nslookup your-hostname.com`
   - 验证端口已打开：`nc -zv your-hostname.com port`

1. 验证您的应用程序正在运行。
   - 检查您的应用程序是否已成功启动。
   - 查看应用程序日志中的启动错误。
   - 确保所有依赖项（包括数据库和 API）均可用。

1. 检查网络和防火墙配置。
   - 确保防火墙规则允许所需端口上的流量。
   - 对于内部应用程序，确保 Runner 可以访问内部 DNS 服务器。

1. 如果您的应用程序启动或进入健康状态需要很长时间，请增加超时时间：

   ```yaml
      variables:
        DAST_TARGET_CHECK_TIMEOUT: "5m"  # Wait up to 5 minutes
   ```

<a id="dns-lookup-failed"></a>

#### DNS 查找失败

您可能会看到类似 `DNS lookup failed`的错误。当 DAST 无法找到您所提供主机名的服务器地址时，就会发生这种情况，原因包括：

- `DAST_TARGET_URL`中的主机名拼写错误或不正确。
- 该域名尚未注册或不存在。
- 您的网络或 Runner 环境中存在 DNS 解析问题。

<a id="connection-refused"></a>

#### 连接被拒绝

您可能会看到 `connection refused`的错误。这通常发生在服务器存在，但出现以下情况时：

- 应用程序尚未完成启动。
- 应用程序运行在与指定端口不同的端口上。
- 防火墙阻止了 Runner 与您的应用程序之间的连接。
- 应用程序崩溃或启动失败。

<a id="target-responded-with-http-5xx-error"></a>

#### 目标响应 HTTP 5xx 错误

您可能会看到目标应用程序响应 `HTTP 5xx` 错误。当应用程序可访问，但响应 `500 Internal Server Error`、`502 Bad Gateway`、`503 Service Unavailable` 或 `504 Gateway Timeout` 等服务器错误时，就会发生这种情况。

您可能会在以下情况下看到服务器错误：

- 应用程序正在启动，尚未完全就绪。
- 应用程序存在配置错误。
- 所需依赖项（如数据库和 API）不可用。

<a id="what-is-the-expected-outcome"></a>

### 预期结果是什么？

许多遇到 DAST 扫描问题的用户对扫描器应该做什么都有大致的高层次想法。例如，它没有扫描特定页面，或者它没有选择页面上的某个按钮。

请尽可能尝试隔离问题，以帮助缩小解决方案的搜索范围。例如，假设 DAST 没有扫描某个特定页面。DAST 应该从哪里找到该页面？它通过什么路径到达那里？引用页面上是否有 DAST 本应选择但没有选择的元素？

<a id="is-the-outcome-achievable-by-a-human"></a>

### 人工能否实现该结果？

如果人工无法手动遍历应用程序，DAST 就无法扫描该应用程序。

了解您期望的结果后，请尝试在您机器上使用浏览器手动复现它。例如：

- 打开一个新的无痕/隐私浏览器窗口。
- 打开开发者工具。留意控制台中的错误消息。
  - 在 Chrome 中：`View -> Developer -> Developer Tools`。
  - 在 Firefox 中：`Tools -> Browser Tools -> Web Developer Tools`。
- 如果需要身份验证：
  - 转到 `DAST_AUTH_URL`。
  - 在 `DAST_AUTH_USERNAME_FIELD`中输入 `DAST_AUTH_USERNAME`。
  - 在 `DAST_AUTH_PASSWORD_FIELD`中输入 `DAST_AUTH_PASSWORD`。
  - 选择 `DAST_AUTH_SUBMIT_FIELD`。
- 选择链接并填写表单。导航到未正确扫描的页面。
- 观察您的应用程序的行为。注意是否有任何可能给自动化扫描器带来问题的内容。

<a id="any-reason-why-dast-would-not-work"></a>

### 有什么原因会导致 DAST 无法工作？

在以下情况下，DAST 无法正确扫描：

- 存在 CAPTCHA。请在要扫描的应用程序的测试环境中将其关闭。
- 它无法访问目标应用程序。确保极狐GitLab Runner 可以使用 DAST 配置中使用的 URL 访问该应用程序。

<a id="how-does-your-application-work"></a>

### 您的应用程序如何工作？

了解您的应用程序如何工作对于弄清 DAST 扫描为何不工作至关重要。例如，以下情况可能需要额外的配置设置。

- 是否有隐藏元素的弹出对话框？
- 加载的页面是否会在特定时间段后发生剧烈变化？
- 应用程序的加载速度是特别慢还是特别快？
- 目标应用程序在加载时是否卡顿？
- 应用程序是否会根据客户端的位置而表现不同？
- 应用程序是单页应用程序吗？
- 应用程序是提交 HTML 表单，还是使用 JavaScript 和 AJAX？
- 应用程序是否使用 websocket？
- 应用程序是否使用特定的 Web 框架？
- 选择按钮是否会在继续提交表单之前运行 JavaScript？它是快还是慢？
- DAST 是否可能在元素或页面就绪之前就选择或搜索元素？

<a id="what-is-dast-doing"></a>

### DAST 在做什么？

作业控制台（CI/CD 作业日志）提供了 DAST 正在做什么的简要摘要。如需更详细的诊断信息，您可以配置日志文件以生成细粒度的输出。

以下日志记录选项可用：

- [诊断日志](#diagnostic-logs)，用于了解分析器正在做什么。
- [Chromium DevTools 日志记录](#chromium-devtools-logging)，用于检查 DAST 与 Chromium 之间的通信。
- [Chromium 日志](#chromium-logs)，用于在 Chromium 意外崩溃时记录错误。

<a id="diagnostic-logs"></a>

## 诊断日志

使用分析器日志文件来诊断扫描问题。您可以按不同级别记录分析器的不同部分。

<a id="log-message-format"></a>

### 日志消息格式

日志消息的格式为`[time] [log level] [log module] [message] [additional properties]`。

例如，以下日志条目的级别为 `INFO`，属于 `CRAWL` 日志模块，消息为 `Crawled path`，附加属性为 `nav_id` 和 `path`。

```plaintext
2021-04-21T00:34:04.000 INF CRAWL Crawled path nav_id=0cc7fd path="LoadURL [https://my.site.com:8090]"
```

<a id="log-destination"></a>

### 日志目标

日志会发送到日志文件产物。您可以使用环境变量 `DAST_LOG_FILE_CONFIG` 配置每个目标以接受不同的日志。例如：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_BROWSER_SCAN: "true"
    DAST_LOG_FILE_CONFIG: "loglevel:debug,cache:warn"           # file log defaults to DEBUG level, logs CACHE module at WARN
```

默认情况下，文件日志是一个名为 `gl-dast-scan.log`的作业产物。要[配置此路径](configuration/variables.md)，请修改 `DAST_LOG_FILE_PATH` CI/CD 变量。

<a id="log-levels"></a>

### 日志级别

可配置的日志级别如下：

| 日志模块              | 组件概述                                                       | 更多                             |
|-------------------------|--------------------------------------------------------------------------|----------------------------------|
| `TRACE`                 | 用于特定且通常较为繁杂的功能内部运作。              |                                  |
| `DEBUG`                 | 描述功能的内部运作。用于诊断目的。 |                                  |
| `INFO`                  | 描述扫描的高层次流程和结果。               | 未指定时的默认级别。 |
| `WARN`                  | 描述 DAST 恢复并继续扫描的错误情况。 |                                  |
| `FATAL`/`ERROR`/`PANIC` | 描述退出前的不可恢复错误。                            |                                  |

<a id="log-modules"></a>

### 日志模块

`LOGLEVEL` 配置日志目标的默认日志级别。如果配置了以下任何模块，DAST 会优先使用该模块的日志级别，而不是默认日志级别。

可配置用于日志记录的模块如下：

| 日志模块 | 组件概述                                                                                |
|------------|---------------------------------------------------------------------------------------------------|
| `ACTIV`    | 用于主动攻击。                                                                          |
| `AUTH`     | 用于创建经过身份验证的扫描。                                                          |
| `BPOOL`    | 为爬取而租用的一组浏览器。                                             |
| `BROWS`    | 用于查询浏览器的状态或页面。                                               |
| `CACHE`    | 用于报告缓存 HTTP 资源的缓存命中和未命中。                               |
| `CHROM`    | 用于记录 Chrome DevTools 消息。                                                             |
| `CONFG`    | 用于记录分析器配置。                                                           |
| `CONTA`    | 用于从 DevTools 消息中收集部分 HTTP 请求和响应的容器。 |
| `CRAWL`    | 用于核心爬取算法。                                                              |
| `CRWLG`    | 用于爬取图生成器。                                                               |
| `DATAB`    | 用于将数据持久化到内部数据库。                                                |
| `LEASE`    | 用于创建浏览器并将其添加到浏览器池。                                          |
| `MAIN`     | 用于爬取器主事件循环的流程。                                          |
| `NAVDB`    | 用于存储导航条目的持久化机制。                                      |
| `REGEX`    | 用于在运行正则表达式时记录性能统计信息。                       |
| `REPT`     | 用于生成报告。                                                                      |
| `STAT`     | 用于运行扫描时的一般统计信息。                                               |
| `VLDFN`    | 用于加载和解析漏洞定义。                                           |
| `WEBGW`    | 用于在运行主动检查时记录发送到目标应用程序的消息。                   |
| `SCOPE`    | 用于记录与[范围管理](configuration/customize_settings.md#managing-scope)相关的消息。 |

<a id="secure_log_level"></a>

### SECURE_LOG_LEVEL

作为使用 `DAST_LOG_FILE_CONFIG` 配置日志模块的更简单替代方案，您可以设置 `SECURE_LOG_LEVEL`：

- 设置为任何[支持的日志级别](#log-levels)。
  这样做时，指定的级别将成为日志文件中所有模块的默认日志级别。
- 设置为 `debug` 或 `trace` 以启用[认证报告](configuration/authentication.md#configure-the-authentication-report)。
- 设置为 `trace` 以启用 [DevTools 日志记录](#chromium-devtools-logging)。

例如：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    SECURE_LOG_LEVEL: "trace"
    # is equivalent to:
    # DAST_LOG_FILE_CONFIG: "loglevel:trace"
    # DAST_LOG_DEVTOOLS_CONFIG: "Default:messageAndBody,truncate:2000"
    # DAST_AUTH_REPORT: "true"
```

来自 `DAST_LOG_FILE_CONFIG`、`DAST_LOG_DEVTOOLS_CONFIG`、`DAST_AUTH_REPORT`的设置会覆盖来自 `SECURE_LOG_LEVEL`的设置。

<a id="example---log-crawled-paths"></a>

### 示例 - 记录已爬取的路径

将日志文件模块 `CRAWL` 设置为 `DEBUG`，以将扫描爬取阶段发现的导航路径记录到日志文件。这对于了解 DAST 是否正确爬取您的目标应用程序很有用。

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_LOG_FILE_CONFIG: "crawl:debug"
```

例如，以下输出显示在爬取 `https://example.com` 页面时发现了四个锚点链接。

```plaintext
2022-11-17T11:18:05.578 DBG CRAWL executing step nav_id=6ec647d8255c729160dd31cb124e6f89 path="LoadURL [https://example.com]" step=1
...
2022-11-17T11:18:11.900 DBG CRAWL found new navigations browser_id=2243909820020928961 nav_count=4 nav_id=6ec647d8255c729160dd31cb124e6f89 of=1 step=1
2022-11-17T11:18:11.901 DBG CRAWL adding navigation action="LeftClick [a href=/page1.html]" nav=bd458cc1fc2d7c6fb984464b6d968866 parent_nav=6ec647d8255c729160dd31cb124e6f89
2022-11-17T11:18:11.901 DBG CRAWL adding navigation action="LeftClick [a href=/page2.html]" nav=6dcb25f9f9ece3ee0071ac2e3166d8e6 parent_nav=6ec647d8255c729160dd31cb124e6f89
2022-11-17T11:18:11.901 DBG CRAWL adding navigation action="LeftClick [a href=/page3.html]" nav=89efbb0c6154d6c6d85a63b61a7cdc6f parent_nav=6ec647d8255c729160dd31cb124e6f89
2022-11-17T11:18:11.901 DBG CRAWL adding navigation action="LeftClick [a href=/page4.html]" nav=f29b4f4e0bdee70f5255de7fc080f04d parent_nav=6ec647d8255c729160dd31cb124e6f89
```

<a id="chromium-devtools-logging"></a>

## Chromium DevTools 日志记录

> [!warning]
> 记录 DevTools 消息存在安全风险。输出包含用户名、密码和认证令牌等密钥。
> 输出会上传到极狐GitLab 服务器，并可能在作业日志中可见。

基于浏览器的 DAST 扫描器使用 [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) 来编排 Chromium 浏览器。
记录 DevTools 消息有助于提高浏览器行为的透明度。例如，如果选择按钮不起作用，DevTools 消息可能会显示原因是浏览器控制台日志中的 CORS 错误。包含 DevTools 消息的日志可能非常大。因此，只应在持续时间较短的作业上启用它。

要记录所有 DevTools 消息，请将 `CHROM` 日志模块设置为 `trace` 并配置日志级别。以下是 DevTools 日志的示例：

```plaintext
2022-12-05T06:27:24.280 TRC CHROM event received    {"method":"Fetch.requestPaused","params":{"requestId":"interception-job-3.0","request":{"url":"http://auth-auto:8090/font-awesome.min.css","method":"GET","headers":{"Accept":"text/css,*/*;q=0.1","Referer":"http://auth-auto:8090/login.html","User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/105.0.5195.102 Safari/537.36"},"initialPriority":"VeryHigh","referrerPolicy":"strict-origin-when-cross-origin"},"frameId":"A706468B01C2FFAA2EB6ED365FF95889","resourceType":"Stylesheet","networkId":"39.3"}} method=Fetch.requestPaused
2022-12-05T06:27:24.280 TRC CHROM request sent      {"id":47,"method":"Fetch.continueRequest","params":{"requestId":"interception-job-3.0","headers":[{"name":"Accept","value":"text/css,*/*;q=0.1"},{"name":"Referer","value":"http://auth-auto:8090/login.html"},{"name":"User-Agent","value":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/105.0.5195.102 Safari/537.36"}]}} id=47 method=Fetch.continueRequest
2022-12-05T06:27:24.281 TRC CHROM response received {"id":47,"result":{}} id=47 method=Fetch.continueRequest
```

<a id="customizing-devtools-log-levels"></a>

### 自定义 DevTools 日志级别

Chrome DevTools 请求、响应和事件按域进行命名空间划分。DAST 允许每个域以及每个带消息的域具有不同的日志记录配置。环境变量 `DAST_LOG_DEVTOOLS_CONFIG` 接受以分号分隔的日志记录配置列表。日志记录配置使用结构`[domain/message]:[what-to-log][,truncate:[max-message-size]]`声明。

- `domain/message` 引用正在记录的内容。
  - `Default` 可用作表示所有域和消息的值。
  - 可以是域，例如 `Browser`、`CSS`、`Page`、`Network`。
  - 可以是带消息的域，例如 `Network.responseReceived`。
  - 如果多个配置适用，则使用最具体的配置。
- `what-to-log` 引用是否记录以及记录什么。
  - `message` 记录收到了一条消息，但不记录消息内容。
  - `messageAndBody` 记录消息及其内容。建议与 `truncate` 一起使用。
  - `suppress` 不记录该消息。用于静默繁杂的域和消息。
- `truncate` 是一个可选配置，用于限制所打印消息的大小。

<a id="example---log-all-devtools-messages"></a>

### 示例 - 记录所有 DevTools 消息

当您不确定从何处着手时，用于记录所有内容。

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_LOG_FILE_CONFIG: "chrom:trace"
    DAST_LOG_DEVTOOLS_CONFIG: "Default:messageAndBody,truncate:2000"
```

<a id="example---log-http-messages"></a>

### 示例 - 记录 HTTP 消息

当资源未正确加载时很有用。HTTP 消息事件会被记录，继续或使请求失败的决策也会被记录。浏览器控制台中的任何错误也会被记录。

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_LOG_FILE_CONFIG: "chrom:trace"
    DAST_LOG_DEVTOOLS_CONFIG: "Default:suppress;Fetch:messageAndBody,truncate:2000;Network:messageAndBody,truncate:2000;Log:messageAndBody,truncate:2000;Console:messageAndBody,truncate:2000"
```

<a id="override-the-job-console-output"></a>

### 覆盖作业控制台输出

默认情况下，作业控制台会显示 DAST 活动的简要摘要。要将完整的诊断日志输出到作业控制台，请同时设置 `DAST_FF_DIAGNOSTIC_JOB_OUTPUT` 和 `DAST_LOG_CONFIG` 变量：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_FF_DIAGNOSTIC_JOB_OUTPUT: "true"
    DAST_LOG_CONFIG: "crawl:debug"                               # console log defaults to INFO level, logs AUTH module at DEBUG
```

[议题 552171](https://gitlab.com/gitlab-org/gitlab/-/issues/552171) 提议在极狐GitLab 19.0 中移除此选项。

<a id="chromium-logs"></a>

## Chromium 日志

在 Chromium 崩溃的罕见情况下，将 Chromium 进程的 `STDOUT` 和 `STDERR` 写入日志可能会有所帮助。将环境变量 `DAST_LOG_BROWSER_OUTPUT` 设置为 `true` 即可实现此目的。

DAST 会启动和停止许多 Chromium 进程。DAST 会将每个进程的输出发送到所有日志目标，日志模块为 `LEASE`，日志级别为 `INFO`。

例如：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_LOG_BROWSER_OUTPUT: "true"
```

<a id="known-problems"></a>

## 已知问题

<a id="logs-contain-response-body-exceeds-allowed-size"></a>

### 日志包含 `response body exceeds allowed size`

默认情况下，DAST 处理 HTTP 响应正文为 10 MB 或更小的 HTTP 请求。否则，DAST 会阻止该响应，这可能导致扫描失败。此限制旨在减少扫描期间的内存消耗。

以下是一个示例日志，其中 DAST 阻止了在 `https://example.com/large.js` 找到的 JavaScript 文件，因为其大小超过了限制：

```plaintext
2022-12-05T06:28:43.093 WRN BROWS response body exceeds allowed size allowed_size_bytes=1000000 browser_id=752944257619431212 nav_id=ae23afe2acbce2c537657a9112926f1a of=1 request_id=interception-job-2.0 response_size_bytes=9333408 step=1 url=https://example.com/large.js
2022-12-05T06:28:58.104 WRN CONTA request failed, attempting to continue scan error=net::ERR_BLOCKED_BY_RESPONSE index=0 requestID=38.2 url=https://example.com/large.js
```

可以使用配置 `DAST_PAGE_MAX_RESPONSE_SIZE_MB` 更改此设置。例如，

```yaml
dast:
  variables:
    DAST_PAGE_MAX_RESPONSE_SIZE_MB: "25"
```

<a id="crawler-doesnt-reach-expected-pages"></a>

### 爬取器无法到达预期页面

<a id="try-disabling-the-cache"></a>

#### 尝试禁用缓存

如果 DAST 错误地缓存了您的应用程序页面，可能会导致 DAST 无法正确爬取您的应用程序。如果您发现某些页面意外地未被爬取器找到，请尝试设置 `DAST_USE_CACHE: "false"`变量，看看是否有帮助。这可能会显著降低扫描的性能。请确保仅在绝对必要时才禁用缓存。如果您有订阅，请[创建支持工单](https://gitlab.cn/support)以调查缓存为何阻止您的网站被爬取。

<a id="specifying-target-paths-directly"></a>

#### 直接指定目标路径

爬取器通常从定义的目标 URL 开始，并尝试通过与站点交互来查找更多页面。但是，有两种方法可以直接指定爬取器的起始路径：

- 使用 sitemap.xml：[Sitemap](https://www.sitemaps.org/protocol.html) 是一种定义明确的协议，用于指定网站中的页面。DAST 的爬取器会在`<target URL>/sitemap.xml` 查找 sitemap.xml 文件，并将所有指定的 URL 作为爬取器的起始点。不支持 [Sitemap Index](https://www.sitemaps.org/protocol.html#index) 文件。
- 使用 `DAST_TARGET_PATHS`：此配置变量允许为爬取器指定输入路径。示例：`DAST_TARGET_PATHS: /,/page/1.html,/page/2.html`。

<a id="make-sure-requests-are-not-getting-blocked"></a>

#### 确保请求未被阻止

默认情况下，DAST 仅允许对目标 URL 域的请求。如果您的网站向目标域以外的域发出请求，请使用 `DAST_SCOPE_ALLOW_HOSTS` 指定这些主机。示例："example.com" 向 "auth.example.com" 发出认证请求以续订认证令牌。由于该域不被允许，请求被阻止，爬取器无法找到新页面。

<a id="maximum-actions-and-crawler-timeout"></a>

#### 最大操作数和爬取器超时

爬取器对其在目标站点上的活动和所花费的时间有默认限制：

1. 默认情况下，爬取器处理 10,000 个操作。一个操作可以是选择链接或填写表单。如果
   爬取器超过此限制，您会看到调试级别的日志 `not adding navigation as it exceeds max actions`。
1. 默认情况下，爬取器最多运行 24 小时。如果超过此时间限制，您会看到跟踪级别的
   日志 `crawl complete, timed out`。

当爬取器达到其中任一限制时，扫描器会停止，无法完全覆盖目标网站。因此，超过这些限制可能表明扫描期间存在问题，也可能是优化的潜在机会。

如果您的应用程序具有基于模板的页面，这些页面结构相似但各页面的数据不同，或者您注意到 URL 模式（例如`/products/item-123`、`/products/item-456`、`/products/item-789`），请配置[分组 URL](configuration/customize_settings.md#grouped-urls) 以减少扫描时间，同时保持安全覆盖范围。

分组 URL 非常适合具有许多产品页面的电子商务网站、基于内容的网站或搜索界面（例如`/search?q=term&page=1`、`/search?q=term&page=2`）。

有关管理扫描时间的更多信息，请参阅[管理扫描时间](configuration/customize_settings.md#managing-scan-time)。如果没有其他合适的策略且您的目标站点非常庞大，请增加爬取器超时时间（`DAST_CRAWL_TIMEOUT`）或最大操作数（`DAST_CRAWL_MAX_ACTIONS`）。
