---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义分析器设置
---

API 模糊测试行为可以通过 CI/CD 变量进行更改。

API 模糊测试配置文件必须位于仓库的 `.gitlab` 目录中。

> [!warning]
> 所有对极狐GitLab 安全扫描工具的自定义操作，在合并到默认分支之前，都应在合并请求中进行测试。否则可能会导致意外结果，包括大量误报。

<a id="authentication"></a>

## 认证

认证是通过将认证令牌作为请求头或 Cookie 提供来处理的。你可以提供一个脚本来执行认证流程或计算令牌。

<a id="http-basic-authentication"></a>

### HTTP 基本认证

HTTP 基本认证是内置于 HTTP 协议中的一种认证方法，通常与传输层安全（TLS）结合使用。

我们建议你为密码创建一个 CI/CD 变量（例如 `TEST_API_PASSWORD`），并将其设置为隐藏。你可以从极狐GitLab 项目页面的 **设置** > **CI/CD** 中的 **变量** 部分创建 CI/CD 变量。由于隐藏变量的限制，你应该在将密码添加为变量之前对其进行 Base64 编码。

最后，在你的 `.gitlab-ci.yml` 文件中添加两个 CI/CD 变量：

- `FUZZAPI_HTTP_USERNAME`：用于认证的用户名。
- `FUZZAPI_HTTP_PASSWORD_BASE64`：用于认证的 Base64 编码密码。

```yaml
stages:
    - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick-10
  FUZZAPI_HAR: test-api-recording.har
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_HTTP_USERNAME: testuser
  FUZZAPI_HTTP_PASSWORD_BASE64: $TEST_API_PASSWORD
```

<a id="raw-password"></a>

### 原始密码

如果你不想对密码进行 Base64 编码（或者你使用的是极狐GitLab 15.3 或更早版本），你可以提供原始密码 `FUZZAPI_HTTP_PASSWORD`，而不是使用 `FUZZAPI_HTTP_PASSWORD_BASE64`。

<a id="bearer-tokens"></a>

### 持有者令牌

持有者令牌被多种不同的认证机制使用，包括 OAuth2 和 JSON Web 令牌（JWT）。持有者令牌通过 `Authorization` HTTP 请求头进行传输。要在 API 模糊测试中使用持有者令牌，你需要以下之一：

- 一个不会过期的令牌
- 一种生成持续测试期间有效的令牌的方法
- 一个 API 模糊测试可以调用来生成令牌的 Python 脚本

<a id="token-doesnt-expire"></a>

#### 令牌不会过期

如果持有者令牌不会过期，使用 `FUZZAPI_OVERRIDES_ENV` 变量来提供它。该变量的内容是一个 JSON 片段，用于提供要添加到 API 模糊测试发出的 HTTP 请求中的请求头和 Cookie。

按照以下步骤使用 `FUZZAPI_OVERRIDES_ENV` 提供持有者令牌：

1. 创建一个 CI/CD 变量，例如 `TEST_API_BEARERAUTH`，其值为 `{"headers":{"Authorization":"Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}}`（替换为你的令牌）。你可以从极狐GitLab 项目页面的 **设置** > **CI/CD** 中的 **变量** 部分创建 CI/CD 变量。

1. 在你的 `.gitlab-ci.yml` 文件中，将 `FUZZAPI_OVERRIDES_ENV` 设置为你刚创建的变量：

   ```yaml
   stages:
     - fuzz

   include:
     - template: API-Fuzzing.gitlab-ci.yml

   variables:
     FUZZAPI_PROFILE: Quick-10
     FUZZAPI_OPENAPI: test-api-specification.json
     FUZZAPI_TARGET_URL: http://test-deployment/
     FUZZAPI_OVERRIDES_ENV: $TEST_API_BEARERAUTH
   ```

1. 要验证认证是否正常工作，运行 API 模糊测试并查看模糊测试日志和测试 API 的应用程序日志。有关覆盖命令的更多信息，请参见[覆盖部分](#overrides)。

<a id="token-generated-at-test-runtime"></a>

#### 测试运行时生成的令牌

如果持有者令牌必须生成且在测试期间不会过期，你可以通过一个包含令牌的文件提供给 API 模糊测试。一个前置阶段和作业，或者 API 模糊测试作业的一部分，可以生成此文件。

API 模糊测试期望接收一个具有以下结构的 JSON 文件：

```json
{
  "headers" : {
    "Authorization" : "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

此文件可以由前置阶段生成，并通过 `FUZZAPI_OVERRIDES_FILE` CI/CD 变量提供给 API 模糊测试。

在你的 `.gitlab-ci.yml` 文件中设置 `FUZZAPI_OVERRIDES_FILE`：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OVERRIDES_FILE: api-fuzzing-overrides.json
```

要验证认证是否正常工作，运行 API 模糊测试并查看模糊测试日志和测试 API 的应用程序日志。

<a id="token-has-short-expiration"></a>

#### 令牌过期时间短

如果持有者令牌必须生成且在扫描完成前就会过期，你可以提供一个程序或脚本，让 API 模糊测试器按指定的时间间隔执行。提供的脚本在安装了 Python 3 和 Bash 的 Alpine Linux 容器中运行。如果 Python 脚本需要额外的软件包，它必须检测到并在运行时安装这些软件包。

该脚本必须创建一个特定格式的 JSON 文件，其中包含持有者令牌：

```json
{
  "headers" : {
    "Authorization" : "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

你必须提供三个 CI/CD 变量，每个变量都需正确设置：

- `FUZZAPI_OVERRIDES_FILE`：提供的命令生成的 JSON 文件。
- `FUZZAPI_OVERRIDES_CMD`：生成 JSON 文件的命令。
- `FUZZAPI_OVERRIDES_INTERVAL`：运行命令的时间间隔（以秒为单位）。

例如：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick-10
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OVERRIDES_FILE: api-fuzzing-overrides.json
  FUZZAPI_OVERRIDES_CMD: renew_token.py
  FUZZAPI_OVERRIDES_INTERVAL: 300
```

要验证认证是否正常工作，运行 API 模糊测试并查看模糊测试日志和测试 API 的应用程序日志。

<a id="api-fuzzing-profiles"></a>

## API 模糊测试配置文件

极狐GitLab 提供了配置文件 `gitlab-api-fuzzing-config.yml`。它包含几个测试配置文件，每个配置文件执行特定数量的测试。随着测试数量的增加，每个配置文件的运行时间也会增加。

| 配置文件   | 模糊测试（每个参数） |
|:----------|:---------------------------|
| Quick-10  | 10 |
| Medium-20 | 20 |
| Medium-50 | 50 |
| Long-100  | 100 |

<a id="overrides"></a>

## 覆盖

API 模糊测试提供了一种在请求中添加或覆盖特定项的方法，例如：

- 请求头
- Cookie
- 查询字符串
- 表单数据
- JSON 节点
- XML 节点

你可以使用此功能来注入语义版本请求头、认证信息等。[认证部分](#authentication)包含了为此目的使用覆盖的示例。

覆盖使用一个 JSON 文档，其中每种覆盖类型由一个 JSON 对象表示：

```json
{
  "headers": {
    "header1": "value",
    "header2": "value"
  },
  "cookies": {
    "cookie1": "value",
    "cookie2": "value"
  },
  "query":      {
    "query-string1": "value",
    "query-string2": "value"
  },
  "body-form":  {
    "form-param1": "value",
    "form-param2": "value"
  },
  "body-json":  {
    "json-path1": "value",
    "json-path2": "value"
  },
  "body-xml" :  {
    "xpath1":    "value",
    "xpath2":    "value"
  }
}
```

设置单个请求头的示例：

```json
{
  "headers": {
    "Authorization": "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

同时设置请求头和 Cookie 的示例：

```json
{
  "headers": {
    "Authorization": "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  },
  "cookies": {
    "flags": "677"
  }
}
```

设置 `body-form` 覆盖的示例用法：

```json
{
  "body-form":  {
    "username": "john.doe"
  }
}
```

当请求体仅包含表单数据内容时，覆盖引擎使用 `body-form`。

设置 `body-json` 覆盖的示例用法：

```json
{
  "body-json":  {
    "$.credentials.access-token": "iddqd!42.$"
  }
}
```

`body-json` 对象中的每个 JSON 属性名称都被设置为一个 JSON Path 表达式。JSON Path 表达式 `$.credentials.access-token` 标识了要用值 `iddqd!42.$` 覆盖的节点。当请求体仅包含 JSON 内容时，覆盖引擎使用 `body-json`。

例如，如果请求体设置为以下 JSON：

```json
{
    "credentials" : {
        "username" :"john.doe",
        "access-token" : "non-valid-password"
    }
}
```

它会被更改为：

```json
{
    "credentials" : {
        "username" :"john.doe",
        "access-token" : "iddqd!42.$"
    }
}
```

以下是一个设置 `body-xml` 覆盖的示例。第一个条目覆盖一个 XML 属性，第二个条目覆盖一个 XML 元素：

```json
{
  "body-xml" :  {
    "/credentials/@isEnabled": "true",
    "/credentials/access-token/text()" : "iddqd!42.$"
  }
}
```

`body-xml` 对象中的每个 JSON 属性名称都被设置为一个 XPath v2 表达式。XPath 表达式 `/credentials/@isEnabled` 标识了要用值 `true` 覆盖的属性节点。XPath 表达式 `/credentials/access-token/text()` 标识了要用值 `iddqd!42.$` 覆盖的元素节点。当请求体仅包含 XML 内容时，覆盖引擎使用 `body-xml`。

例如，如果请求体设置为以下 XML：

```xml
<credentials isEnabled="false">
  <username>john.doe</username>
  <access-token>non-valid-password</access-token>
</credentials>
```

它会被更改为：

```xml
<credentials isEnabled="true">
  <username>john.doe</username>
  <access-token>iddqd!42.$</access-token>
</credentials>
```

你可以将此 JSON 文档作为文件或环境变量提供。你也可以提供一个命令来生成 JSON 文档。该命令可以按间隔运行，以支持会过期的值。

<a id="using-a-file"></a>

### 使用文件

要将覆盖 JSON 作为文件提供，需要设置 `FUZZAPI_OVERRIDES_FILE` CI/CD 变量。该路径相对于作业的当前工作目录。

以下是一个 `.gitlab-ci.yml` 示例：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OVERRIDES_FILE: api-fuzzing-overrides.json
```

<a id="using-a-cicd-variable"></a>

### 使用 CI/CD 变量

要将覆盖 JSON 作为 CI/CD 变量提供，使用 `FUZZAPI_OVERRIDES_ENV` 变量。这允许你将 JSON 作为可隐藏和保护的变量放置。

在此 `.gitlab-ci.yml` 示例中，`FUZZAPI_OVERRIDES_ENV` 变量直接设置为 JSON：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OVERRIDES_ENV: '{"headers":{"X-API-Version":"2"}}'
```

在此 `.gitlab-ci.yml` 示例中，`SECRET_OVERRIDES` 变量提供了 JSON。这是一个在 UI 中定义的群组或实例级别的 CI/CD 变量：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OVERRIDES_ENV: $SECRET_OVERRIDES
```

<a id="using-a-command"></a>

### 使用命令

如果值必须生成或在过期时重新生成，你可以提供一个程序或脚本，让 API 模糊测试器按指定的时间间隔执行。提供的脚本在安装了 Python 3 和 Bash 的 Alpine Linux 容器中运行。

你必须将环境变量 `FUZZAPI_OVERRIDES_CMD` 设置为你想要执行的程序或脚本。提供的命令会按照前面定义的方式创建覆盖 JSON 文件。

你可能想要安装其他脚本运行时，如 NodeJS 或 Ruby，或者你可能需要为覆盖命令安装依赖项。在这种情况下，你应该将 `FUZZAPI_PRE_SCRIPT` 设置为提供这些先决条件的脚本的文件路径。由 `FUZZAPI_PRE_SCRIPT` 提供的脚本会在分析器启动之前执行一次。

> [!note]
> 当执行需要提升权限的操作时，请使用 `sudo` 命令。
> 例如，`sudo apk add nodejs`。

有关安装 Alpine Linux 软件包的信息，请参见 Alpine Linux 软件包管理页面。

你必须提供三个 CI/CD 变量，每个变量都需正确设置：

- `FUZZAPI_OVERRIDES_FILE`：由提供的命令生成的文件。
- `FUZZAPI_OVERRIDES_CMD`：负责定期生成覆盖 JSON 文件的覆盖命令。
- `FUZZAPI_OVERRIDES_INTERVAL`：运行命令的时间间隔（以秒为单位）。

可选：

- `FUZZAPI_PRE_SCRIPT`：在分析器启动之前安装运行时或依赖项的脚本。

> [!warning]
> 要在 Alpine Linux 中执行脚本，你必须首先使用 `chmod` 命令设置执行权限。例如，要为所有人设置 `script.py` 的执行权限，使用命令：`sudo chmod a+x script.py`。如果需要，你可以对已设置执行权限的 `script.py` 进行版本控制。

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OVERRIDES_FILE: api-fuzzing-overrides.json
  FUZZAPI_OVERRIDES_CMD: renew_token.py
  FUZZAPI_OVERRIDES_INTERVAL: 300
```

<a id="debugging-overrides"></a>

### 调试覆盖

默认情况下，覆盖命令的输出是隐藏的。如果覆盖命令返回非零退出代码，该命令会作为作业输出的一部分显示。可选地，你可以将变量 `FUZZAPI_OVERRIDES_CMD_VERBOSE` 设置为任意值，以在生成时显示覆盖命令的输出。
```json
{
  "headers": [
    "header1",
    "header2"
  ],
  "cookies": [
    "cookie1",
    "cookie2"
  ],
  "query": [
    "query-string1",
    "query-string2"
  ],
  "body-form": [
    "form-param1",
    "form-param2"
  ],
  "body-json": [
    "json-path-expression-1",
    "json-path-expression-2"
  ],
  "body-xml" : [
    "xpath-expression-1",
    "xpath-expression-2"
  ]
}
```

<a id="examples"></a>

### 示例

<a id="excluding-a-single-header"></a>

#### 排除单个请求头

要排除 `Upgrade-Insecure-Requests` 请求头，请将 `header` 属性的值设置为一个包含该请求头名称的数组：`[ "Upgrade-Insecure-Requests" ]`。对应的 JSON 文档示例如下：

```json
{
  "headers": [ "Upgrade-Insecure-Requests" ]
}
```

请求头名称不区分大小写，因此 `UPGRADE-INSECURE-REQUESTS` 与 `Upgrade-Insecure-Requests` 等效。

<a id="excluding-both-a-header-and-two-cookies"></a>

#### 同时排除一个请求头和两个 Cookie

要排除 `Authorization` 请求头以及 `PHPSESSID` 和 `csrftoken` 这两个 Cookie，请将 `headers` 属性的值设置为包含 `[ "Authorization" ]` 的数组，并将 `cookies` 属性的值设置为包含 `[ "PHPSESSID", "csrftoken" ]` 的数组。对应的 JSON 文档示例如下：

```json
{
  "headers": [ "Authorization" ],
  "cookies": [ "PHPSESSID", "csrftoken" ]
}
```

<a id="excluding-a-body-form-parameter"></a>

#### 排除 `body-form` 参数

要排除使用 `application/x-www-form-urlencoded` 请求中的 `password` 字段，请将 `body-form` 属性的值设置为包含字段名称的数组：`[ "password" ]`。对应的 JSON 文档示例如下：

```json
{
  "body-form":  [ "password" ]
}
```

当请求使用 `application/x-www-form-urlencoded` 内容类型时，排除参数会使用 `body-form`。

<a id="excluding-a-specific-json-nodes-using-json-path"></a>

#### 使用 JSON Path 排除特定的 JSON 节点

要排除根对象中的 `schema` 属性，请将 `body-json` 属性的值设置为包含 JSON Path 表达式 `[ "$.schema" ]` 的数组。

JSON Path 表达式使用特殊语法来标识 JSON 节点：`$` 表示 JSON 文档的根，`.` 表示当前对象（此处为根对象），而文本 `schema` 表示属性名称。因此，JSON path 表达式 `$.schema` 表示根对象中名为 `schema` 的属性。对应的 JSON 文档示例如下：

```json
{
  "body-json": [ "$.schema" ]
}
```

当请求使用 `application/json` 内容类型时，排除参数会使用 `body-json`。`body-json` 中的每个条目都应是一个 [JSON Path 表达式](https://goessner.net/articles/JsonPath/)。在 JSON Path 中，诸如 `$`、`*`、`.` 等字符具有特殊含义。

<a id="excluding-multiple-json-nodes-using-json-path"></a>

#### 使用 JSON Path 排除多个 JSON 节点

要排除根级别 `users` 数组中每个条目下的 `password` 属性，请将 `body-json` 属性的值设置为包含 JSON Path 表达式 `[ "$.users[*].password" ]` 的数组。

JSON Path 表达式以 `$` 开头表示根节点，并使用 `.` 表示当前节点。接着，它使用 `users` 来指代一个属性。字符 `[` 和 `]` 包裹着你想使用的数组索引。你可以使用 `*` 来指定任意索引，而不必提供具体数字。在索引引用之后，`.` 字符表示数组中任意选中的索引，其后跟着属性名称 `password`。

对应的 JSON 文档示例如下：

```json
{
  "body-json": [ "$.users[*].password" ]
}
```

当请求使用 `application/json` 内容类型时，排除参数会使用 `body-json`。`body-json` 中的每个条目都应是一个 [JSON Path 表达式](https://goessner.net/articles/JsonPath/)。在 JSON Path 中，诸如 `$`、`*`、`.` 等字符具有特殊含义。

<a id="excluding-an-xml-attribute"></a>

#### 排除 XML 属性

要排除根元素 `credentials` 中名为 `isEnabled` 的属性，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[ "/credentials/@isEnabled" ]` 的数组。

XPath 表达式 `/credentials/@isEnabled` 以 `/` 开头表示 XML 文档的根，紧接着是单词 `credentials`，表示要匹配的元素名称。它使用 `/` 来指向前一个 XML 元素的节点，并使用 `@` 字符表示 `isEnabled` 是一个属性。

对应的 JSON 文档示例如下：

```json
{
  "body-xml": [
    "/credentials/@isEnabled"
  ]
}
```

当请求使用 `application/xml` 内容类型时，排除参数会使用 `body-xml`。`body-xml` 中的每个条目都应是一个 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-elements-text"></a>

#### 排除 XML 元素的文本

要排除根节点 `credentials` 下 `username` 元素的文本，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[ "/credentials/username/text()" ]` 的数组。

在 XPath 表达式 `/credentials/username/text()` 中，第一个字符 `/` 指向根 XML 节点，之后是指定 XML 元素名称 `credentials`。同样，字符 `/` 指向当前元素，后面跟着新的 XML 元素名称 `username`。最后部分有一个 `/` 指向当前元素，并使用名为 `text()` 的 XPath 函数来标识当前元素的文本。

对应的 JSON 文档示例如下：

```json
{
  "body-xml": [
    "/credentials/username/text()"
  ]
}
```

当请求使用 `application/xml` 内容类型时，排除参数会使用 `body-xml`。`body-xml` 中的每个条目都应是一个 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-element"></a>

#### 排除 XML 元素

要排除根节点 `credentials` 下的 `username` 元素，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[ "/credentials/username" ]` 的数组。

在 XPath 表达式 `/credentials/username` 中，第一个字符 `/` 指向根 XML 节点，之后是指定 XML 元素名称 `credentials`。同样，字符 `/` 指向当前元素，后面跟着新的 XML 元素名称 `username`。

对应的 JSON 文档示例如下：

```json
{
  "body-xml": [
    "/credentials/username"
  ]
}
```

当请求使用 `application/xml` 内容类型时，排除参数会使用 `body-xml`。`body-xml` 中的每个条目都应是一个 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-node-with-namespaces"></a>

#### 排除带命名空间的 XML 节点

要排除命名空间 `s` 中定义且位于根节点 `credentials` 下的 XML 元素 `login`，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[ "/credentials/s:login" ]` 的数组。

在 XPath 表达式 `/credentials/s:login` 中，第一个字符 `/` 指向根 XML 节点，之后是指定 XML 元素名称 `credentials`。同样，字符 `/` 指向当前元素，后面跟着新的 XML 元素名称 `s:login`。请注意，名称中包含字符 `:`，该字符将命名空间与节点名称分隔开。

命名空间名称应在作为请求体一部分的 XML 文档中定义。你可以在 HAR、OpenAPI 或 Postman Collection 文件的规范文档中检查命名空间。

```json
{
  "body-xml": [
    "/credentials/s:login"
  ]
}
```

当请求使用 `application/xml` 内容类型时，排除参数会使用 `body-xml`。`body-xml` 中的每个条目都应是一个 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="using-a-json-string"></a>

### 使用 JSON 字符串

要提供排除 JSON 文档，请将变量 `FUZZAPI_EXCLUDE_PARAMETER_ENV` 设置为该 JSON 字符串。在以下 `.gitlab-ci.yml` 示例中，`FUZZAPI_EXCLUDE_PARAMETER_ENV` 变量被设置为一个 JSON 字符串：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_EXCLUDE_PARAMETER_ENV: '{ "headers": [ "Upgrade-Insecure-Requests" ] }'
```

<a id="using-a-file"></a>

### 使用文件

要提供排除 JSON 文档，请将变量 `FUZZAPI_EXCLUDE_PARAMETER_FILE` 设置为该 JSON 文件路径。文件路径相对于作业的当前工作目录。在以下 `.gitlab-ci.yml` 文件示例中，`FUZZAPI_EXCLUDE_PARAMETER_FILE` 变量被设置为一个 JSON 文件路径：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_EXCLUDE_PARAMETER_FILE: api-fuzzing-exclude-parameters.json
```

`api-fuzzing-exclude-parameters.json` 是一个 JSON 文档，其结构遵循 [排除参数文档](#exclude-parameters-using-a-json-document) 的结构。

<a id="exclude-urls"></a>

## 排除 URL

作为按路径排除的替代方案，你可以通过使用 `FUZZAPI_EXCLUDE_URLS` CI/CD 变量来按 URL 中的任何其他组成部分进行过滤。该变量可以在你的 `.gitlab-ci.yml` 文件中设置。该变量可以存储多个值，以逗号 (`,`) 分隔。每个值都是一个正则表达式。由于每个条目都是一个正则表达式，因此像 `.*` 这样的条目会排除所有 URL，因为它是一个匹配所有内容的正则表达式。

在作业输出中，你可以检查是否有任何 URL 匹配了 `FUZZAPI_EXCLUDE_URLS` 中提供的正则表达式。匹配的操作会列在 **已排除操作** 部分。已列在 **已排除操作** 中的操作不应再出现在 **已测试操作** 部分。例如，以下作业输出片段：

```plaintext
2021-05-27 21:51:08 [INF] API 模糊测试: --[ 已测试操作 ]-------------------------
2021-05-27 21:51:08 [INF] API 模糊测试: 201 POST http://target:7777/api/users CREATED
2021-05-27 21:51:08 [INF] API 模糊测试: ------------------------------------------------
2021-05-27 21:51:08 [INF] API 模糊测试: --[ 已排除操作 ]-----------------------
2021-05-27 21:51:08 [INF] API 模糊测试: GET http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API 模糊测试: POST http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API 模糊测试: ------------------------------------------------
```

> [!note]
> `FUZZAPI_EXCLUDE_URLS` 中的每个值都是一个正则表达式。诸如 `.`、`*` 和 `$` 等字符在 [正则表达式](https://en.wikipedia.org/wiki/Regular_expression#Standards) 中具有特殊含义。

<a id="examples"></a>

### 示例

<a id="excluding-a-url-and-child-resources"></a>

#### 排除一个 URL 及其子资源

以下示例排除了 URL `http://target/api/auth` 及其子资源。

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: http://target/
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_EXCLUDE_URLS: http://target/api/auth
```

<a id="excluding-two-urls-and-allow-their-child-resources"></a>

#### 排除两个 URL 但允许扫描其子资源

要排除 `http://target/api/buy` 和 `http://target/api/sell` URL，但仍允许扫描它们的子资源，例如：`http://target/api/buy/toy` 或 `http://target/api/sell/chair`。你可以使用值 `http://target/api/buy/$,http://target/api/sell/$`。此值使用了两个正则表达式，每个之间用 `,` 分隔。因此，它包含 `http://target/api/buy$` 和 `http://target/api/sell$`。在每个正则表达式中，末尾的 `$` 字符标识了匹配 URL 应在何处结束。

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: http://target/
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_EXCLUDE_URLS: http://target/api/buy/$,http://target/api/sell/$
```

<a id="excluding-two-urls-and-their-child-resources"></a>

#### 排除两个 URL 及其子资源

要排除 URL：`http://target/api/buy` 和 `http://target/api/sell` 以及它们的子资源。我们使用 `,` 字符来提供多个 URL，如下所示：

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: http://target/
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_EXCLUDE_URLS: http://target/api/buy,http://target/api/sell
```

<a id="excluding-url-using-regular-expressions"></a>

#### 使用正则表达式排除 URL

要精确排除 `https://target/api/v1/user/create` 和 `https://target/api/v2/user/create` 或任何其他版本（`v3`、`v4` 等），我们可以使用 `https://target/api/v.*/user/create$`。在上述正则表达式中：

- `.` 表示任意字符。
- `*` 表示零次或多次。
- `$` 表示 URL 应在此结束。

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: http://target/
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_EXCLUDE_URLS: https://target/api/v.*/user/create$
```

<a id="header-fuzzing"></a>

## 请求头模糊测试

请求头模糊测试默认处于禁用状态，这是因为许多技术栈会产生大量误报。当启用请求头模糊测试时，你必须指定要包含在模糊测试中的请求头列表。

默认配置文件中的每个配置项都包含一个 `GeneralFuzzingCheck` 条目。此检查执行请求头模糊测试。在 `Configuration` 部分下，你必须更改 `HeaderFuzzing` 和 `Headers` 设置以启用请求头模糊测试。

以下片段显示了 `Quick-10` 配置的默认设置，其中请求头模糊测试处于禁用状态：

```yaml
- Name: Quick-10
  DefaultProfile: Empty
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
        HeaderFuzzing: false
        Headers:
    - Name: JsonFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
    - Name: XmlFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
```

`HeaderFuzzing` 是一个布尔值，用于打开或关闭请求头模糊测试。默认设置为 `false`（关闭）。要开启请求头模糊测试，请将此设置更改为 `true`：

```yaml
    - Name: GeneralFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
        HeaderFuzzing: true
        Headers:
```

`Headers` 是要进行模糊测试的请求头列表。只有列出的请求头才会被测试。要对你 API 中使用的某个请求头进行模糊测试，请使用语法 `- Name: HeaderName` 为其添加一个条目。例如，要对自定义请求头 `X-Custom` 进行模糊测试，请添加 `- Name: X-Custom`：

```yaml
    - Name: GeneralFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
        HeaderFuzzing: true
        Headers:
          - Name: X-Custom
```

现在，你已拥有一个对 `X-Custom` 请求头进行模糊测试的配置。使用相同的表示法可列出其他请求头：

```yaml
    - Name: GeneralFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
        HeaderFuzzing: true
        Headers:
          - Name: X-Custom
          - Name: X-AnotherHeader
```

请根据需要对每个配置重复此配置。

```