---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 DAST 扫描问题
---

以下排查场景收集自客户支持案例。如果您遇到的问题未在此列出，或此处的信息未能解决您的问题，请创建支持工单。更多详情，请参阅[极狐GitLab 支持](https://gitlab.cn/support/)页面。

<a id="when-something-goes-wrong"></a>

## 当出现问题时

当 DAST 扫描出现问题时：

- 如果您是首次配置 DAST，请检查[配置 DAST](#setting-up-dast)。
- 如果您遇到特定的错误消息，请查阅[已知问题](#known-problems)。

否则，请尝试通过回答以下问题来找出问题所在：

- [预期结果是什么？](#what-is-the-expected-outcome)
- [人工操作能否达到预期结果？](#is-the-outcome-achievable-by-a-human)
- [是否存在导致 DAST 无法正常工作的原因？](#any-reason-why-dast-would-not-work)
- [您的应用如何工作？](#how-does-your-application-work)
- [DAST 正在做什么？](#what-is-dast-doing)

<a id="setting-up-dast"></a>

### 配置 DAST

首次配置 DAST 时，您可能会遇到以下问题。

<a id="configuration-validation-failed-required-field-url-was-not-set"></a>

#### 配置验证失败：未设置必需的 URL 字段

当您引入 DAST 模板但未定义目标 URL 时，流水线会在配置验证阶段失败，并产生以下错误：

```plaintext
ERR MAIN  configuration validation failed error="未设置必需字段 URL"
```

此错误表明 DAST 不知道该扫描哪个 URL。要解决此问题，请通过以下任一方法定义目标 URL：

- 在 `.gitlab-ci.yml` 文件中设置 `DAST_TARGET_URL` CI/CD 变量：

  ```yaml
  stages:
    - dast

  include:
    - template: Security/DAST.gitlab-ci.yml

  dast:
    variables:
      DAST_TARGET_URL: "https://example.com"
  ```

- 在项目根目录创建一个 `environment_url.txt` 文件，并在其中添加目标 URL。这种方法适用于在动态环境中测试应用程序。

<a id="runner-cannot-connect-to-target-application"></a>

#### Runner 无法连接到目标应用

当 Runner 无法访问您的目标应用时，DAST 扫描会因连接错误而失败。这通常是由于网络配置或防火墙问题造成的。

DAST 需要使用您指定的 URL 连接到您的应用：

- 如果您的 `DAST_TARGET_URL` 或 `DAST_AUTH_URL` 包含端口号，请确保 Runner 能够访问该特定端口。
- 如果 URL 中未指定端口，DAST 使用标准端口：
  - 对于 HTTP URL（例如 `http://example.com`），使用端口 `80`。
  - 对于 HTTPS URL（例如 `https://example.com`），使用端口 `443`。

连接问题的常见原因包括：

- HTTP 和 HTTPS 混合内容。您的应用可能同时使用 HTTP 和 HTTPS。例如，如果目标 URL 是 `http://example.com`，但站点却从 `https://example.com` 加载资源，请确保 Runner 能够访问两个端口。
- 自定义端口。如果您的应用运行在非标准端口上，请将其包含在 `DAST_TARGET_URL` 中，例如 `https://example.com:8443`。
- 防火墙规则。如果您的应用位于防火墙后，请配置规则以允许来自 Runner IP 地址的流量。
- 内部和外部网络。请确保 Runner 所在的网络能够访问您的应用。例如，如果您在内部网络的预发布环境上进行测试，请使用同一网络中的 Runner。

<a id="target-connection-issues"></a>

#### 目标连接问题

DAST 在开始扫描前，会检查目标 URL 是否可访问。如果无法访问目标 URL，DAST 会生成详细的错误消息以帮助诊断问题。默认情况下，DAST 每两秒重试连接一次，最长持续 60 秒。您可以使用 `DAST_TARGET_CHECK_TIMEOUT` 配置 DAST 重试连接的超时时间。

如果您遇到连接问题：

1. 验证 `DAST_TARGET_URL` 配置。
   - 检查主机名、端口或协议是否有拼写错误。
   - 确保 URL 包含协议（`http://` 或 `https://`）。
   - 验证端口号与您的应用运行的端口是否匹配。

1. 从 Runner 端测试连接。
   - 测试连接：`curl --verbose "http://your-target-url:port"`
   - 检查 DNS 解析：`nslookup your-hostname.com`
   - 验证端口是否开放：`nc -zv your-hostname.com port`

1. 确认您的应用正在运行。
   - 检查应用是否已成功启动。
   - 查看应用日志中的启动错误。
   - 确保所有依赖项（包括数据库和 API）都已就绪。

1. 检查网络和防火墙配置。
   - 确保防火墙规则允许所需端口上的流量。
   - 对于内部应用，确保 Runner 能够访问内部 DNS 服务器。

1. 如果您的应用启动或变得健康需要较长时间，请增加超时时间：

   ```yaml
      variables:
        DAST_TARGET_CHECK_TIMEOUT: "5m"  # 最长等待 5 分钟
   ```

<a id="dns-lookup-failed"></a>

#### DNS 查找失败

您可能会看到类似 `DNS lookup failed` 的错误。
这表示 DAST 无法找到您提供的主机名的服务器地址，可能的原因有：

- `DAST_TARGET_URL` 中的主机名拼写错误或不正确。
- 域名尚未注册或不存在。
- 您的网络或 Runner 环境中存在 DNS 解析问题。

<a id="connection-refused"></a>

#### 连接被拒绝

您可能会看到 `connection refused` 的错误。
这通常发生在服务器存在，但：

- 应用尚未完成启动。
- 应用运行的端口与指定的不同。
- 防火墙阻止了 Runner 与您的应用之间的连接。
- 应用崩溃或启动失败。

<a id="target-responded-with-http-5xx-error"></a>

#### 目标响应 HTTP 5xx 错误

您可能会看到目标应用返回 `HTTP 5xx` 错误。这表示应用可访问，但正在响应服务器错误，例如 `500 Internal Server Error`、`502 Bad Gateway`、`503 Service Unavailable` 或 `504 Gateway Timeout`。

以下情况可能导致服务器错误：

- 应用正在启动，尚未完全就绪。
- 应用存在配置错误。
- 必需的依赖项（如数据库和 API）不可用。

<a id="what-is-the-expected-outcome"></a>

### 预期结果是什么？

许多遇到 DAST 扫描问题的用户对其认为扫描器应该执行的操作有一个较好的高层次认知。例如，它没有扫描特定页面，或者它没有选择页面上的按钮。

尽可能将问题隔离，以缩小解决方案的搜索范围。例如，假设 DAST 未扫描某个特定页面。DAST 本应从何处找到该页面？它经过了怎样的路径到达那里？在引用页面上，是否有本应由 DAST 选择但实际上并未选择的元素？

<a id="is-the-outcome-achievable-by-a-human"></a>

### 人工操作能否达到预期结果？

如果人工无法手动遍历应用，DAST 也无法扫描该应用。

了解您期望的结果后，尝试在您的机器上使用浏览器手动复现。例如：

- 打开一个新的无痕/隐私浏览器窗口。
- 打开开发者工具，留意控制台中的错误消息。
  - 在 Chrome 中：`View -> Developer -> Developer Tools`。
  - 在 Firefox 中：`Tools -> Browser Tools -> Web Developer Tools`。
- 如果需要认证：
  - 转到 `DAST_AUTH_URL`。
  - 在 `DAST_AUTH_USERNAME_FIELD` 中输入 `DAST_AUTH_USERNAME`。
  - 在 `DAST_AUTH_PASSWORD_FIELD` 中输入 `DAST_AUTH_PASSWORD`。
  - 选择 `DAST_AUTH_SUBMIT_FIELD`。
- 点击链接并填写表单，导航至未正确扫描的页面。
- 观察应用的行为。留意是否有可能给自动化扫描器带来问题的任何情况。

<a id="any-reason-why-dast-would-not-work"></a>

### 是否存在导致 DAST 无法正常工作的原因？

以下情况会导致 DAST 无法正确扫描：

- 存在验证码。请在测试环境中为被扫描的应用关闭验证码。
- 无法访问目标应用。确保 GitLab Runner 能够使用 DAST 配置中使用的 URL 访问该应用。

<a id="how-does-your-application-work"></a>

### 您的应用如何工作？

了解应用的工作原理对于找出 DAST 扫描失败的原因至关重要。例如，以下情况可能需要额外的配置设置。

- 是否存在隐藏元素的弹出对话框？
- 加载的页面是否会在特定时间后发生显著变化？
- 应用加载是特别慢还是特别快？
- 目标应用在加载时是否不稳定？
- 应用是否基于客户端位置表现出不同的行为？
- 应用是单页应用吗？
- 应用是提交 HTML 表单，还是使用 JavaScript 和 AJAX？
- 应用是否使用 WebSocket？
- 应用是否使用特定的 Web 框架？
- 点击按钮是否在继续提交表单之前运行 JavaScript？是快还是慢？
- DAST 是否可能在元素或页面就绪之前就尝试选择或搜索元素？

<a id="what-is-dast-doing"></a>

### DAST 正在做什么？

{{< history >}}

- 简洁日志在极狐GitLab 18.3 中引入。

{{< /history >}}

作业控制台（CI/CD 作业日志）提供了 DAST 正在执行的操作的简明摘要。
如需更详细的诊断信息，您可以配置日志文件生成细粒度输出。

提供以下日志记录选项：

- [诊断日志](#diagnostic-logs)，用于了解分析器正在执行的操作。
- [Chromium DevTools 日志](#chromium-devtools-logging)，用于检查 DAST 与 Chromium 之间的通信。
- [Chromium 日志](#chromium-logs)，用于记录 Chromium 意外崩溃时的错误。

<a id="diagnostic-logs"></a>

## 诊断日志

使用分析器日志文件来诊断扫描问题。您可以对不同部分的分析器配置不同的日志级别。

<a id="log-message-format"></a>

### 日志消息格式

日志消息的格式为 `[时间] [日志级别] [日志模块] [消息] [附加属性]`。

例如，以下日志条目的级别为 `INFO`，属于 `CRAWL` 日志模块，消息为 `Crawled path`，附加属性为 `nav_id` 和 `path`。

```plaintext
2021-04-21T00:34:04.000 INF CRAWL Crawled path nav_id=0cc7fd path="LoadURL [https://my.site.com:8090]"
```

<a id="log-destination"></a>

### 日志目标

日志发送到日志文件产物。您可以使用环境变量 `DAST_LOG_FILE_CONFIG` 为每个目标配置接受不同日志。
例如：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_BROWSER_SCAN: "true"
    DAST_LOG_FILE_CONFIG: "loglevel:debug,cache:warn"           # 文件日志默认级别为 DEBUG，CACHE 模块日志级别为 WARN
```

默认情况下，文件日志是一个名为 `gl-dast-scan.log` 的作业产物。
要[配置此路径](configuration/variables.md)，请修改 `DAST_LOG_FILE_PATH` CI/CD 变量。

<a id="log-levels"></a>

### 日志级别

可配置的日志级别如下：

| 日志模块              | 组件概述                                                       | 更多信息                         |
|-------------------------|--------------------------------------------------------------------------|----------------------------------|
| `TRACE`                 | 用于特性内部具体的、通常较嘈杂的运作细节。              |                                  |
| `DEBUG`                 | 描述特性的内部运作。用于诊断目的。 |                                  |
| `INFO`                  | 描述扫描的高层流程和结果。               | 未指定时的默认级别。 |
| `WARN`                  | 描述 DAST 能够恢复并继续扫描的错误情况。 |                                  |
| `FATAL`/`ERROR`/`PANIC` | 描述退出前无法恢复的错误。                            |                                  |

<a id="log-modules"></a>

### 日志模块

`LOGLEVEL` 配置日志目标的默认日志级别。如果配置了以下任何模块，DAST 会为该模块使用其特定的日志级别，而不使用默认级别。

可配置的日志模块如下：

| 日志模块 | 组件概述                                                                                |
|------------|---------------------------------------------------------------------------------------------------|
| `ACTIV`    | 用于主动攻击。                                                                          |
| `AUTH`     | 用于创建经过认证的扫描。                                                          |
| `BPOOL`    | 为爬网而租出的浏览器集合。                                             |
| `BROWS`    | 用于查询浏览器的状态或页面。                                               |
| `CACHE`    | 用于报告缓存 HTTP 资源的命中与未命中情况。                               |
| `CHROM`    | 用于记录 Chrome DevTools 消息。                                                             |
| `CONFG`    | 用于记录分析器配置。                                                           |
| `CONTA`    | 用于从 DevTools 消息中收集部分 HTTP 请求和响应的容器。 |
| `CRAWL`    | 用于核心爬虫算法。                                                              |
| `CRWLG`    | 用于爬网图生成器。                                                               |
| `DATAB`    | 用于将数据持久化到内部数据库。                                                |
| `LEASE`    | 用于创建浏览器并将其添加到浏览器池。                                          |
| `MAIN`     | 用于爬虫主事件循环的流程。                                          |
| `NAVDB`    | 用于持久化机制来存储导航条目。                                      |
| `REGEX`    | 用于记录运行正则表达式时的性能统计。                       |
| `REPT`     | 用于生成报告。                                                                      |
| `STAT`     | 用于扫描期间的通用统计信息。                                               |
| `VLDFN`    | 用于加载和解析漏洞定义。                                           |
| `WEBGW`    | 用于记录在执行主动检查时发送到目标应用的消息。                   |
| `SCOPE`    | 用于记录与[范围管理](configuration/customize_settings.md#managing-scope)相关的消息。 |

<a id="secure_log_level"></a>

### SECURE_LOG_LEVEL

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

作为使用 `DAST_LOG_FILE_CONFIG` 配置日志模块的更简单替代方案，您可以设置 `SECURE_LOG_LEVEL`：

- 为任意[支持的日志级别](#log-levels)。
  这样做时，指定的级别会成为日志文件中所有模块的默认日志级别。
- 设置为 `debug` 或 `trace` 以启用[认证报告](configuration/authentication.md#configure-the-authentication-report)。
- 设置为 `trace` 以启用 [DevTools 日志记录](#chromium-devtools-logging)。

例如：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    SECURE_LOG_LEVEL: "trace"
    # 等同于：
    # DAST_LOG_FILE_CONFIG: "loglevel:trace"
    # DAST_LOG_DEVTOOLS_CONFIG: "Default:messageAndBody,truncate:2000"
    # DAST_AUTH_REPORT: "true"
```

`DAST_LOG_FILE_CONFIG`、`DAST_LOG_DEVTOOLS_CONFIG`、`DAST_AUTH_REPORT` 中的设置会覆盖 `SECURE_LOG_LEVEL` 中的设定。

<a id="example---log-crawled-paths"></a>

### 示例 - 记录已爬取的路径

将日志文件模块 `CRAWL` 设置为 `DEBUG`，即可将爬取阶段中发现的导航路径记录到日志文件。这对于理解 DAST 是否正确爬取您的目标应用非常有用。

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

## Chromium DevTools 日志

> [!warning]
> 记录 DevTools 消息存在安全风险。输出中可能包含用户名、密码和认证令牌等机密信息。
> 输出会上传到极狐GitLab 服务器，并可能在作业日志中可见。

基于浏览器的 DAST 扫描器使用 [Chrome DevTools 协议](https://chromedevtools.github.io/devtools-protocol/) 编排 Chromium 浏览器。
记录 DevTools 消息有助于透明了解浏览器的行为。例如，如果点击按钮无效，一条 DevTools 消息可能会显示原因是浏览器控制台日志中的 CORS 错误。
包含 DevTools 消息的日志可能非常庞大。因此，应仅在持续时间较短的作业上启用。

要记录所有 DevTools 消息，请将 `CHROM` 日志模块设置为 `trace` 并配置日志级别。以下是 DevTools 日志的示例：

```plaintext
2022-12-05T06:27:24.280 TRC CHROM event received    {"method":"Fetch.requestPaused","params":{"requestId":"interception-job-3.0","request":{"url":"http://auth-auto:8090/font-awesome.min.css","method":"GET","headers":{"Accept":"text/css,*/*;q=0.1","Referer":"http://auth-auto:8090/login.html","User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/105.0.5195.102 Safari/537.36"},"initialPriority":"VeryHigh","referrerPolicy":"strict-origin-when-cross-origin"},"frameId":"A706468B01C2FFAA2EB6ED365FF95889","resourceType":"Stylesheet","networkId":"39.3"}} method=Fetch.requestPaused
2022-12-05T06:27:24.280 TRC CHROM request sent      {"id":47,"method":"Fetch.continueRequest","params":{"requestId":"interception-job-3.0","headers":[{"name":"Accept","value":"text/css,*/*;q=0.1"},{"name":"Referer","value":"http://auth-auto:8090/login.html"},{"name":"User-Agent","value":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/105.0.5195.102 Safari/537.36"}]}} id=47 method=Fetch.continueRequest
2022-12-05T06:27:24.281 TRC CHROM response received {"id":47,"result":{}} id=47 method=Fetch.continueRequest
```

<a id="customizing-devtools-log-levels"></a>

### 自定义 DevTools 日志级别

Chrome DevTools 请求、响应和事件按域命名。DAST 允许为每个域以及每个域与消息的组合配置不同的日志记录。
环境变量 `DAST_LOG_DEVTOOLS_CONFIG` 接受以分号分隔的日志配置列表。
日志配置使用 `[domain/message]:[what-to-log][,truncate:[max-message-size]]` 结构声明。

- `domain/message` 指定记录的内容。
  - `Default` 可用作代表所有域和消息的值。
  - 可以是一个域，例如 `Browser`、`CSS`、`Page`、`Network`。
  - 可以是一个域及消息，例如 `Network.responseReceived`。
  - 如果多个配置适用，则使用最具体的配置。
- `what-to-log` 指定是否记录以及记录什么。
  - `message` 记录收到了一条消息，但不记录消息内容。
  - `messageAndBody` 记录消息及其内容，建议与 `truncate` 配合使用。
  - `suppress` 不记录消息，用于静默嘈杂的域和消息。
- `truncate` 是一个可选配置，用于限制打印的消息大小。

<a id="example---log-all-devtools-messages"></a>

### 示例 - 记录所有 DevTools 消息

用于在不确定从何处开始时记录所有内容。

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

对资源加载不正确的情况很有用。HTTP 消息事件会被记录，同时记录继续或中止请求的决定。浏览器控制台中的任何错误也会被记录。

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

默认情况下，作业控制台显示 DAST 活动的简明摘要。
要将完整的诊断日志输出到作业控制台，请同时设置 `DAST_FF_DIAGNOSTIC_JOB_OUTPUT` 和 `DAST_LOG_CONFIG` 变量：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_FF_DIAGNOSTIC_JOB_OUTPUT: "true"
    DAST_LOG_CONFIG: "crawl:debug"                               # 控制台日志默认级别为 INFO，将 AUTH 模块设为 DEBUG
```

<a id="chromium-logs"></a>

## Chromium 日志

在 Chromium 崩溃这种罕见情况下，将 Chromium 进程的 `STDOUT` 和 `STDERR` 写入日志可能会有所帮助。
将环境变量 `DAST_LOG_BROWSER_OUTPUT` 设置为 `true` 即可实现此目的。

DAST 会启动和停止多个 Chromium 进程。DAST 会将每个进程的输出发送到所有日志目标，使用日志模块 `LEASE` 和日志级别 `INFO`。

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

默认情况下，DAST 处理 HTTP 响应体不超过 10 MB 的 HTTP 请求。否则，DAST 会阻止响应，这可能导致扫描失败。此限制旨在减少扫描期间的内存消耗。

如下示例日志所示，DAST 阻止了在 `https://example.com/large.js` 找到的 JavaScript 文件，原因是其大小超过了限制：

```plaintext
2022-12-05T06:28:43.093 WRN BROWS response body exceeds allowed size allowed_size_bytes=1000000 browser_id=752944257619431212 nav_id=ae23afe2acbce2c537657a9112926f1a of=1 request_id=interception-job-2.0 response_size_bytes=9333408 step=1 url=https://example.com/large.js
2022-12-05T06:28:58.104 WRN CONTA request failed, attempting to continue scan error=net::ERR_BLOCKED_BY_RESPONSE index=0 requestID=38.2 url=https://example.com/large.js
```

可以通过配置 `DAST_PAGE_MAX_RESPONSE_SIZE_MB` 进行更改。例如：

```yaml
dast:
  variables:
    DAST_PAGE_MAX_RESPONSE_SIZE_MB: "25"
```

<a id="crawler-doesnt-reach-expected-pages"></a>

### 爬虫未到达预期页面

<a id="try-disabling-the-cache"></a>

#### 尝试禁用缓存

如果 DAST 错误地缓存了您的应用页面，可能导致 DAST 无法正确爬取您的应用。如果您发现爬虫意外找不到某些页面，请尝试设置 `DAST_USE_CACHE: "false"` 变量，看看是否有帮助。这会显著降低扫描性能，请仅在绝对必要时才禁用缓存。如果您有订阅，请[创建支持工单](https://gitlab.cn/support/)以调查缓存为何阻止了您的网站被爬取。

<a id="specifying-target-paths-directly"></a>

#### 直接指定目标路径

爬虫通常从定义的目标 URL 开始，并尝试通过与站点交互来发现更多页面。不过，有两种方法可以直接指定爬虫起始的路径：
```
- 使用 sitemap.xml：[Sitemap](https://www.sitemaps.org/protocol.html) 是一个定义明确的协议，用于指定网站中的页面。DAST 的爬虫会在 `<目标 URL>/sitemap.xml` 查找 sitemap.xml 文件，并采用所有指定的 URL 作为爬虫的起始点。不支持 [Sitemap Index](https://www.sitemaps.org/protocol.html#index) 文件。
- 使用 `DAST_TARGET_PATHS`：此配置变量允许为爬虫指定输入路径。示例：`DAST_TARGET_PATHS: /,/page/1.html,/page/2.html`。

<a id="make-sure-requests-are-not-getting-blocked"></a>

#### 确保请求未被阻止

默认情况下，DAST 仅允许对目标 URL 域名的请求。如果你的网站向目标域名以外的域名发出请求，请使用 `DAST_SCOPE_ALLOW_HOSTS` 来指定此类主机。示例："example.com" 向 "auth.example.com" 发出认证请求以续订认证令牌。由于该域名未被允许，请求被阻止，爬虫无法找到新页面。

<a id="maximum-actions-and-crawler-timeout"></a>

#### 最大行动次数和爬虫超时

爬虫对其活动量和在目标站点上花费的时间有默认限制：

1. 默认情况下，爬虫处理 10,000 次行动。一次行动可以是选择一个链接或填写一个表单。如果
   爬虫超过了此限制，你会看到调试级别日志 `not adding navigation as it exceeds max actions`。
1. 默认情况下，爬虫最多运行 24 小时。如果超过此时间限制，你会看到跟踪
   级别日志 `crawl complete, timed out`。

当爬虫达到这些限制中的任何一个时，扫描器会停止，并且无法完全覆盖目标网站。
因此，超过这些限制可能表明扫描期间存在问题以及潜在的优化机会。

如果你的应用程序有基于模板的页面，这些页面结构相似但不同页面上的数据不同，或者
你注意到 URL 模式（例如，`/products/item-123`、`/products/item-456`、`/products/item-789`），
请配置[分组 URL](configuration/customize_settings.md#grouped-urls) 以减少扫描时间，同时
保持安全覆盖。

分组 URL 非常适合具有许多产品页面的电子商务网站、基于内容的网站或搜索界面
（例如，`/search?q=term&page=1`、`/search?q=term&page=2`）。

有关管理扫描时间的更多信息，请参见[管理扫描时间](configuration/customize_settings.md#managing-scan-time)。
如果没有其他合适的策略并且你的目标站点规模很大，请增加爬虫超时时间 (`DAST_CRAWL_TIMEOUT`)
或最大行动次数 (`DAST_CRAWL_MAX_ACTIONS`)。