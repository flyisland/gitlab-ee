---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义分析器设置
---

<a id="authentication"></a>

## 认证

认证通过将认证令牌作为请求头或 Cookie 提供来处理。你可以提供一个执行认证流程或计算令牌的脚本。

<a id="http-basic-authentication"></a>

### HTTP 基本认证

[HTTP 基本认证](https://en.wikipedia.org/wiki/Basic_access_authentication) 是一种内置于 HTTP 协议中的认证方法，通常与 [传输层安全 (TLS)](https://en.wikipedia.org/wiki/Transport_Layer_Security) 结合使用。

为密码创建一个 [CI/CD 变量](../../../../ci/variables/_index.md#for-a-project)（例如 `TEST_API_PASSWORD`），并将其设置为隐藏。你可以从极狐GitLab 项目页面 **设置** > **CI/CD** 中的 **变量** 部分创建 CI/CD 变量。由于 [隐藏变量的限制](../../../../ci/variables/_index.md#mask-a-cicd-variable)，在将其添加为变量之前，你应该对密码进行 Base64 编码。

最后，在你的 `.gitlab-ci.yml` 文件中添加两个 CI/CD 变量：

- `APISEC_HTTP_USERNAME`：用于认证的用户名。
- `APISEC_HTTP_PASSWORD_BASE64`：用于认证的 Base64 编码密码。

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_HAR: test-api-recording.har
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_HTTP_USERNAME: testuser
  APISEC_HTTP_PASSWORD_BASE64: $TEST_API_PASSWORD
```

<a id="raw-password"></a>

#### 原始密码

如果你不想对密码进行 Base64 编码（或者你使用的是极狐GitLab 15.3 或更早版本），你可以提供原始密码 `APISEC_HTTP_PASSWORD`，而不是使用 `APISEC_HTTP_PASSWORD_BASE64`。

<a id="bearer-tokens"></a>

### Bearer 令牌

Bearer 令牌被多种不同的认证机制使用，包括 OAuth2 和 JSON Web 令牌 (JWT)。Bearer 令牌通过 `Authorization` HTTP 请求头传输。要在 API 安全测试中使用 Bearer 令牌，你需要满足以下条件之一：

- 一个不会过期的令牌。
- 一种生成持续整个测试时长的令牌的方法。
- 一个 API 安全测试可以调用来生成令牌的 Python 脚本。

<a id="token-doesnt-expire"></a>

#### 令牌不会过期

如果 Bearer 令牌不会过期，使用 `APISEC_OVERRIDES_ENV` 变量来提供它。该变量的内容是一个 JSON 片段，用于为 API 安全测试的传出 HTTP 请求添加请求头和 Cookie。

按照以下步骤使用 `APISEC_OVERRIDES_ENV` 提供 Bearer 令牌：

1. [创建一个 CI/CD 变量](../../../../ci/variables/_index.md#for-a-project)，例如 `TEST_API_BEARERAUTH`，其值为 `{"headers":{"Authorization":"Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}}`（替换为你的令牌）。你可以从极狐GitLab 项目页面 **设置** > **CI/CD** 中的 **变量** 部分创建 CI/CD 变量。由于 `TEST_API_BEARERAUTH` 的格式，无法隐藏该变量。要隐藏令牌的值，你可以创建第二个包含令牌值的变量，并将 `TEST_API_BEARERAUTH` 定义为 `{"headers":{"Authorization":"Bearer $MASKED_VARIABLE"}}`。
1. 在你的 `.gitlab-ci.yml` 文件中，将 `APISEC_OVERRIDES_ENV` 设置为你刚刚创建的变量：

   ```yaml
   stages:
     - dast

   include:
     - template: API-Security.gitlab-ci.yml

   variables:
     APISEC_PROFILE: Quick
     APISEC_OPENAPI: test-api-specification.json
     APISEC_TARGET_URL: http://test-deployment/
     APISEC_OVERRIDES_ENV: $TEST_API_BEARERAUTH
   ```

1. 要验证认证是否正常工作，运行 API 安全测试并查看作业日志以及测试 API 的应用程序日志。

<a id="token-generated-at-test-runtime"></a>

#### 测试运行时生成令牌

如果 Bearer 令牌必须生成并且在测试期间不会过期，你可以为 API 安全测试提供一个包含令牌的文件。一个前置阶段和作业，或者 API 安全测试作业的一部分，可以生成此文件。

API 安全测试期望接收一个具有以下结构的 JSON 文件：

```json
{
  "headers" : {
    "Authorization" : "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

此文件可以由前置阶段生成，并通过 `APISEC_OVERRIDES_FILE` CI/CD 变量提供给 API 安全测试。

在你的 `.gitlab-ci.yml` 文件中设置 `APISEC_OVERRIDES_FILE`：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OVERRIDES_FILE: dast-api-overrides.json
```

要验证认证是否正常工作，运行 API 安全测试并查看作业日志以及测试 API 的应用程序日志。

<a id="token-has-short-expiration"></a>

#### 令牌有效期短

如果 Bearer 令牌必须生成并且在扫描完成前过期，你可以提供一个程序或脚本，让 API 安全测试扫描器按指定的时间间隔执行。提供的脚本在一个安装了 Python 3 和 Bash 的 Alpine Linux 容器中运行。如果 Python 脚本需要额外的软件包，它必须在运行时检测并安装这些软件包。

该脚本必须创建一个包含 Bearer 令牌的 JSON 文件，格式如下：

```json
{
  "headers" : {
    "Authorization" : "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

你必须提供三个 CI/CD 变量，每个变量都需要正确设置才能正常工作：

- `APISEC_OVERRIDES_FILE`：提供的命令生成的 JSON 文件。
- `APISEC_OVERRIDES_CMD`：生成 JSON 文件的命令。
- `APISEC_OVERRIDES_INTERVAL`：运行命令的间隔（以秒为单位）。

例如：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OVERRIDES_FILE: dast-api-overrides.json
  APISEC_OVERRIDES_CMD: renew_token.py
  APISEC_OVERRIDES_INTERVAL: 300
```

要验证认证是否正常工作，运行 API 安全测试并查看作业日志以及测试 API 的应用程序日志。有关覆盖命令的更多信息，请参阅 [覆盖部分](#overrides)。

<a id="overrides"></a>

## 覆盖

API 安全测试提供了一种方法来添加或覆盖请求中的特定项，例如：

- 请求头
- Cookie
- 查询字符串
- 表单数据
- JSON 节点
- XML 节点

你可以使用此功能来注入语义版本请求头、认证等。[认证部分](#authentication) 包含了为此目的使用覆盖的示例。

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

`body-json` 对象中的每个 JSON 属性名都被设置为一个 [JSON Path](https://goessner.net/articles/JsonPath/) 表达式。JSON Path 表达式 `$.credentials.access-token` 标识了要用值 `iddqd!42.$` 覆盖的节点。当请求体仅包含 [JSON](https://www.json.org/json-en.html) 内容时，覆盖引擎使用 `body-json`。

例如，如果请求体设置为以下 JSON：

```json
{
    "credentials" : {
        "username" :"john.doe",
        "access-token" : "non-valid-password"
    }
}
```

它将被更改为：

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

`body-xml` 对象中的每个 JSON 属性名都被设置为一个 [XPath v2](https://www.w3.org/TR/xpath20/) 表达式。XPath 表达式 `/credentials/@isEnabled` 标识了要用值 `true` 覆盖的属性节点。XPath 表达式 `/credentials/access-token/text()` 标识了要用值 `iddqd!42.$` 覆盖的元素节点。当请求体仅包含 [XML](https://www.w3.org/XML/) 内容时，覆盖引擎使用 `body-xml`。

例如，如果请求体设置为以下 XML：

```xml
<credentials isEnabled="false">
  <username>john.doe</username>
  <access-token>non-valid-password</access-token>
</credentials>
```

它将被更改为：

```xml
<credentials isEnabled="true">
  <username>john.doe</username>
  <access-token>iddqd!42.$</access-token>
</credentials>
```

你可以将此 JSON 文档作为文件或环境变量提供。你也可以提供一个命令来生成 JSON 文档。该命令可以按间隔运行以支持会过期的值。

<a id="using-a-file"></a>

### 使用文件

要将覆盖 JSON 作为文件提供，需要设置 `APISEC_OVERRIDES_FILE` CI/CD 变量。路径相对于作业的当前工作目录。

以下是一个 `.gitlab-ci.yml` 示例：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OVERRIDES_FILE: dast-api-overrides.json
```

<a id="using-a-cicd-variable"></a>

### 使用 CI/CD 变量

要将覆盖 JSON 作为 CI/CD 变量提供，使用 `APISEC_OVERRIDES_ENV` 变量。这允许你将 JSON 作为可以隐藏和保护的变量放置。

在此 `.gitlab-ci.yml` 示例中，`APISEC_OVERRIDES_ENV` 变量直接设置为 JSON：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OVERRIDES_ENV: '{"headers":{"X-API-Version":"2"}}'
```

在此 `.gitlab-ci.yml` 示例中，`SECRET_OVERRIDES` 变量提供了 JSON。这是一个 [在 UI 中定义的群组或实例 CI/CD 变量](../../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OVERRIDES_ENV: $SECRET_OVERRIDES
```

<a id="using-a-command"></a>

### 使用命令

如果值必须生成或在过期时重新生成，你可以提供一个程序或脚本，让 API 安全测试扫描器按指定的时间间隔执行。提供的命令在一个安装了 Python 3 和 Bash 的 Alpine Linux 容器中运行。

你必须将环境变量 `APISEC_OVERRIDES_CMD` 设置为你想要执行的程序或脚本。提供的命令会创建前面定义的覆盖 JSON 文件。

你可能想要安装其他脚本运行时，如 NodeJS 或 Ruby，或者你可能需要为覆盖命令安装依赖项。在这种情况下，你应该将 `APISEC_PRE_SCRIPT` 设置为提供这些先决条件的脚本的文件路径。由 `APISEC_PRE_SCRIPT` 提供的脚本会在分析器启动前执行一次。

> [!note]
> 当执行需要提升权限的操作时，请使用 `sudo` 命令。例如，`sudo apk add nodejs`。

有关安装 Alpine Linux 软件包的信息，请参阅 [Alpine Linux 软件包管理](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management) 页面。

你必须提供三个 CI/CD 变量，每个变量都需要正确设置才能正常工作：

- `APISEC_OVERRIDES_FILE`：由提供的命令生成的文件。
- `APISEC_OVERRIDES_CMD`：负责定期生成覆盖 JSON 文件的覆盖命令。
- `APISEC_OVERRIDES_INTERVAL`：运行命令的间隔（以秒为单位）。

可选：

- `APISEC_PRE_SCRIPT`：在扫描开始前安装运行时或依赖项的脚本。

> [!warning]
> 要在 Alpine Linux 中执行脚本，你必须首先使用 [`chmod`](https://www.gnu.org/software/coreutils/manual/html_node/chmod-invocation.html) 命令来设置 [执行权限](https://www.gnu.org/software/coreutils/manual/html_node/Setting-Permissions.html)。例如，要为所有人设置 `script.py` 的执行权限，使用命令：`sudo chmod a+x script.py`。如果需要，你可以对已经设置好执行权限的 `script.py` 进行版本控制。

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OVERRIDES_FILE: dast-api-overrides.json
  APISEC_OVERRIDES_CMD: renew_token.py
  APISEC_OVERRIDES_INTERVAL: 300
```

<a id="debugging-overrides"></a>

### 调试覆盖

默认情况下，覆盖命令的输出是隐藏的。你可以选择将变量 `APISEC_OVERRIDES_CMD_VERBOSE` 设置为任意值，以将覆盖命令输出记录到 `gl-api-security-scanner.log` 作业产物文件中。这在测试覆盖脚本时很有用，但之后应禁用它，因为它会减慢测试速度。

也可以从脚本向日志文件写入消息，该日志文件在作业完成或失败时被收集。日志文件必须创建在特定位置并遵循命名约定。

在覆盖脚本中添加一些基本的日志记录是很有用的，以防脚本在作业的标准运行期间意外失败。日志文件会自动作为作业的产物包含在内，允许你在作业完成后下载它。

该示例在环境变量 `APISEC_OVERRIDES_CMD` 中提供了 `renew_token.py`。请注意脚本中的两点：

- 日志文件保存在环境变量 `CI_PROJECT_DIR` 指示的位置。
- 日志文件名应匹配 `gl-*.log`。

```python
#!/usr/bin/env python

# 覆盖命令示例

# 覆盖命令可以更新覆盖 JSON 文件
# 以使用新的值。这是更新
# 将在测试期间过期的认证令牌的
# 好方法。

import logging
import json
import os
import requests
import backoff

# [1] 将日志文件存储在环境变量 CI_PROJECT_DIR 指示的目录中
working_directory = os.environ.get( 'CI_PROJECT_DIR')
overrides_file_name = os.environ.get('APISEC_OVERRIDES_FILE', 'dast-api-overrides.json')
overrides_file_path = os.path.join(working_directory, overrides_file_name)

# [2] 文件名应匹配模式：gl-*.log
log_file_path = os.path.join(working_directory, 'gl-user-overrides.log')

# 设置日志记录器
logging.basicConfig(filename=log_file_path, level=logging.DEBUG)

# 使用 `backoff` 装饰器在发生瞬时错误时重试。
@backoff.on_exception(backoff.expo,
                      (requests.exceptions.Timeout,
                       requests.exceptions.ConnectionError),
                       max_time=30)
def get_auth_response():
    authorization_url = 'https://authorization.service/api/get_api_token'
    return requests.get(
        f'{authorization_url}',
        auth=(os.environ.get('AUTH_USER'), os.environ.get('AUTH_PWD'))
    )

# 在此示例中，访问令牌是从给定端点检索的
try:

    # 执行 HTTP 请求，响应示例：
    # { "Token" : "abcdefghijklmn" }
    response = get_auth_response()

    # 检查请求是否成功。可能引发 `requests.exceptions.HTTPError`
    response.raise_for_status()

    # 获取 JSON 数据
    response_body = response.json()

# 如果需要，可以捕获特定的异常
# requests.ConnectionError                  : 发生网络连接错误问题
# requests.HTTPError                        : HTTP 请求返回了不成功的状态码。[Response.raise_for_status()]
# requests.ConnectTimeout                   : 尝试连接到远程服务器时请求超时
# requests.ReadTimeout                      : 服务器在分配的时间内未发送任何数据。
# requests.TooManyRedirects                 : 请求超过了配置的最大重定向次数
# requests.exceptions.RequestException      : 与 Requests 相关的所有异常
except json.JSONDecodeError as json_decode_error:
    # 记录与解码 JSON 响应相关的错误
    logging.error(f'错误，解码 JSON 响应失败。错误信息：{json_decode_error}')
    raise
except requests.exceptions.RequestException as requests_error:
    # 记录与 `Requests` 相关的异常
    logging.error(f'错误，执行 HTTP 请求失败。错误信息：{requests_error}')
    raise
except Exception as e:
    # 记录任何其他错误
    logging.error(f'错误，检索访问令牌时发生未知错误。错误信息：{e}')
    raise

# 计算包含覆盖文件内容的对象。
# 它使用从请求中获取的数据
overrides_data = {
    "headers": {
        "Authorization": f"Token {response_body['Token']}"
    }
}

# 记录有关文件覆盖计算的日志条目
logging.info("正在创建覆盖文件：%s" % overrides_file_path)

# 尝试覆盖文件
try:
    if os.path.exists(overrides_file_path):
        os.unlink(overrides_file_path)

    # 用更新后的字典覆盖文件
    with open(overrides_file_path, "wb+") as fd:
        fd.write(json.dumps(overrides_data).encode('utf-8'))
except Exception as e:
    # 记录任何其他错误
    logging.error(f'错误，覆盖文件 {overrides_file_path} 时发生未知错误。错误信息：{e}')
    raise

# 记录覆盖已成功完成
logging.info("覆盖文件已更新")

# 结束
```

在覆盖命令示例中，Python 脚本依赖于 `backoff` 库。为了确保在执行 Python 脚本之前安装该库，将 `APISEC_PRE_SCRIPT` 设置为一个安装覆盖命令依赖项的脚本。例如，以下脚本 `user-pre-scan-set-up.sh`

```shell
#!/bin/bash

# user-pre-scan-set-up.sh
# 确保 Python 依赖项已安装

echo "**** 安装 Python 依赖项 ****"

sudo pip3 install --no-cache --upgrade --break-system-packages \
    backoff

echo "**** Python 依赖项已安装 ****"

# 结束
```

你必须更新配置，将 `APISEC_PRE_SCRIPT` 设置为新的 `user-pre-scan-set-up.sh` 脚本。例如：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_PRE_SCRIPT: ./user-pre-scan-set-up.sh
  APISEC_OVERRIDES_FILE: dast-api-overrides.json
  APISEC_OVERRIDES_CMD: renew_token.py
  APISEC_OVERRIDES_INTERVAL: 300
```

在前面的示例中，你可以使用脚本 `user-pre-scan-set-up.sh` 来安装新的运行时或应用程序。然后在覆盖命令中使用这些运行时或应用程序。

<a id="request-headers"></a>

## 请求头

请求头功能允许你在扫描会话期间为请求头指定固定值。例如，你可以使用配置变量 `APISEC_REQUEST_HEADERS` 在 `Cache-Control` 请求头中设置一个固定值。如果你需要设置的请求头包含敏感值（如 `Authorization` 请求头），请结合使用 [隐藏变量](../../../../ci/variables/_index.md#mask-a-cicd-variable) 功能和 [变量 `APISEC_REQUEST_HEADERS_BASE64`](#base64)。

如果 `Authorization` 请求头或任何其他请求头需要在扫描进行时更新，请考虑使用 [覆盖](#overrides) 功能。

变量 `APISEC_REQUEST_HEADERS` 允许你指定一个以逗号（`,`）分隔的请求头列表。这些请求头会包含在扫描器执行的每个请求中。列表中的每个请求头条目由一个名称后跟一个冒号（`:`）然后是其值组成。键或值之前的空格会被忽略。例如，要声明一个名为 `Cache-Control`、值为 `max-age=604800` 的请求头，请求头条目为 `Cache-Control: max-age=604800`。要使用两个请求头 `Cache-Control: max-age=604800` 和 `Age: 100`，请将 `APISEC_REQUEST_HEADERS` 变量设置为 `Cache-Control: max-age=604800, Age: 100`。

将不同的请求头提供给变量 `APISEC_REQUEST_HEADERS` 的顺序不会影响结果。将 `APISEC_REQUEST_HEADERS` 设置为 `Cache-Control: max-age=604800, Age: 100` 与将其设置为 `Age: 100, Cache-Control: max-age=604800` 产生的结果相同。

<a id="base64"></a>

### Base64

`APISEC_REQUEST_HEADERS_BASE64` 变量接受与 `APISEC_REQUEST_HEADERS` 相同的请求头列表，唯一的区别是变量的整个值必须进行 Base64 编码。例如，要将 `APISEC_REQUEST_HEADERS_BASE64` 变量设置为 `Authorization: QmVhcmVyIFRPS0VO, Cache-control: bm8tY2FjaGU=`，请确保你将列表转换为其 Base64 等效值：`QXV0aG9yaXphdGlvbjogUW1WaGNtVnlJRlJQUzBWTywgQ2FjaGUtY29udHJvbDogYm04dFkyRmphR1U9`，并且必须使用 Base64 编码后的值。这在将密钥请求头值存储在具有字符集限制的 [隐藏变量](../../../../ci/variables/_index.md#mask-a-cicd-variable) 中时非常有用。

> [!warning]
> Base64 用于支持 [隐藏变量](../../../../ci/variables/_index.md#mask-a-cicd-variable) 功能。Base64 编码本身并不是一种安全措施，因为敏感值可以被解码。

<a id="example-adding-a-list-of-headers-on-each-request-using-plain-text"></a>

### 示例：使用纯文本在每个请求上添加请求头列表

在以下 `.gitlab-ci.yml` 示例中，`APISEC_REQUEST_HEADERS` 配置变量被设置为提供两个请求头值，如 [请求头](#request-headers) 中所述。

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_REQUEST_HEADERS: 'Cache-control: no-cache, Save-Data: on'
```

<a id="example-using-a-masked-cicd-variable"></a>

### 示例：使用隐藏的 CI/CD 变量

以下 `.gitlab-ci.yml` 示例假设 [隐藏变量](../../../../ci/variables/_index.md#mask-a-cicd-variable) `SECRET_REQUEST_HEADERS_BASE64` 被定义为一个 [在 UI 中定义的群组或实例 CI/CD 变量](../../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)。`SECRET_REQUEST_HEADERS_BASE64` 的值设置为 `WC1BQ01FLVNlY3JldDogc31jcnt0ISwgWC1BQ01FLVRva2VuOiA3MDVkMTZmNWUzZmI=`，这是 `X-ACME-Secret: s3cr3t!, X-ACME-Token: 705d16f5e3fb` 的 Base64 编码文本版本。然后，可以按如下方式使用：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_REQUEST_HEADERS_BASE64: $SECRET_REQUEST_HEADERS_BASE64
```

当将密钥请求头值存储在具有字符集限制的 [隐藏变量](../../../../ci/variables/_index.md#mask-a-cicd-variable) 中时，请考虑使用 `APISEC_REQUEST_HEADERS_BASE64`。

<a id="exclude-paths"></a>

## 排除路径

在测试 API 时，排除某些路径可能会很有用。例如，你可能想排除对认证服务或旧版本 API 的测试。要排除路径，请使用 `APISEC_EXCLUDE_PATHS` CI/CD 变量。此变量在你的 `.gitlab-ci.yml` 文件中指定。要排除多个路径，请使用 `;` 字符分隔条目。在提供的路径中，你可以使用单字符通配符 `?` 和多字符通配符 `*`。

要验证路径是否被排除，请查看作业输出中的 `已测试操作` 和 `已排除操作` 部分。你不应在 `已测试操作` 下看到任何被排除的路径。


```plaintext
2021-05-27 21:51:08 [INF] API SECURITY: --[ 已测试操作 ]-------------------------
2021-05-27 21:51:08 [INF] API SECURITY: 201 POST http://target:7777/api/users CREATED
2021-05-27 21:51:08 [INF] API SECURITY: ------------------------------------------------
2021-05-27 21:51:08 [INF] API SECURITY: --[ 已排除操作 ]-----------------------
2021-05-27 21:51:08 [INF] API SECURITY: GET http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API SECURITY: POST http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API SECURITY: ------------------------------------------------
```

<a id="examples"></a>

### 示例

此示例排除了 `/auth` 资源。这不会排除子资源（`/auth/child`）。

```yaml
variables:
  APISEC_EXCLUDE_PATHS: /auth
```

要排除 `/auth` 及子资源（`/auth/child`），请使用通配符。

```yaml
variables:
  APISEC_EXCLUDE_PATHS: /auth*
```

要排除多个路径，请使用 `;` 字符。以下示例排除了 `/auth*` 和 `/v1/*`。

```yaml
variables:
  APISEC_EXCLUDE_PATHS: /auth*;/v1/*
```

要排除路径中的一个或多个嵌套级别，请使用 `**`。以下示例测试了 `/api/v1/` 和 `/api/v2/` API 端点，使用数据查询请求 `planet`、`moon`、`star` 和 `satellite` 对象的 `mass`、`brightness` 和 `coordinates` 数据。可能被扫描的示例路径包括：

- `/api/v2/planet/coordinates`
- `/api/v1/star/mass`
- `/api/v2/satellite/brightness`

此示例仅测试 `brightness` 端点：

```yaml
variables:
  APISEC_EXCLUDE_PATHS: /api/**/mass;/api/**/coordinates
```

<a id="exclude-parameters"></a>

### 排除参数

在测试 API 时，你可能希望排除某个参数（查询字符串、标头或正文元素）以避免测试。这可能是因为该参数总是导致失败、减慢测试速度或其他原因。要排除参数，你可以设置以下变量之一：`APISEC_EXCLUDE_PARAMETER_ENV` 或 `APISEC_EXCLUDE_PARAMETER_FILE`。

`APISEC_EXCLUDE_PARAMETER_ENV` 允许提供包含排除参数的 JSON 字符串。如果 JSON 较短且不经常更改，这是一个不错的选择。另一个选项是变量 `APISEC_EXCLUDE_PARAMETER_FILE`。此变量设置为一个文件路径，该文件可以检入到代码仓库中，由另一个作业作为产物创建，或在运行时使用 `APISEC_PRE_SCRIPT` 通过预脚本生成。

<a id="exclude-parameters-using-a-json-document"></a>

#### 使用 JSON 文档排除参数

JSON 文档包含一个 JSON 对象，此对象使用特定属性来标识应排除的参数。
你可以提供以下属性来在扫描过程中排除特定参数：

- `headers`：使用此属性排除特定的标头。该属性的值是一个要排除的标头名称数组。名称不区分大小写。
- `cookies`：使用此属性排除特定的 Cookie。该属性的值是一个要排除的 Cookie 名称数组。名称区分大小写。
- `query`：使用此属性排除查询字符串中的特定字段。该属性的值是一个要从查询字符串中排除的字段名称数组。名称区分大小写。
- `body-form`：使用此属性从使用媒体类型 `application/x-www-form-urlencoded` 的请求中排除特定字段。该属性的值是一个要从正文中排除的字段名称数组。名称区分大小写。
- `body-json`：使用此属性从使用媒体类型 `application/json` 的请求中排除特定的 JSON 节点。该属性的值是一个数组，数组的每个条目都是一个 [JSON Path](https://goessner.net/articles/JsonPath/) 表达式。
- `body-xml`：使用此属性从使用媒体类型 `application/xml` 的请求中排除特定的 XML 节点。该属性的值是一个数组，数组的每个条目都是一个 [XPath v2](https://www.w3.org/TR/xpath20/) 表达式。

因此，以下 JSON 文档是排除参数的预期结构示例。

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

<a id="examples-1"></a>

#### 示例

<a id="excluding-a-single-header"></a>

##### 排除单个标头

要排除标头 `Upgrade-Insecure-Requests`，请将 `header` 属性的值设置为包含该标头名称的数组：`[ "Upgrade-Insecure-Requests" ]`。例如，JSON 文档如下所示：

```json
{
  "headers": [ "Upgrade-Insecure-Requests" ]
}
```

标头名称不区分大小写，因此标头名称 `UPGRADE-INSECURE-REQUESTS` 等同于 `Upgrade-Insecure-Requests`。

<a id="excluding-both-a-header-and-two-cookies"></a>

##### 排除标头和两个 Cookie

要排除标头 `Authorization` 以及 Cookie `PHPSESSID` 和 `csrftoken`，请将 `headers` 属性的值设置为包含标头名称 `[ "Authorization" ]` 的数组，并将 `cookies` 属性的值设置为包含 Cookie 名称 `[ "PHPSESSID", "csrftoken" ]` 的数组。例如，JSON 文档如下所示：

```json
{
  "headers": [ "Authorization" ],
  "cookies": [ "PHPSESSID", "csrftoken" ]
}
```

<a id="excluding-a-body-form-parameter"></a>

##### 排除 `body-form` 参数

要在使用 `application/x-www-form-urlencoded` 的请求中排除 `password` 字段，请将 `body-form` 属性的值设置为包含字段名称 `[ "password" ]` 的数组。例如，JSON 文档如下所示：

```json
{
  "body-form":  [ "password" ]
}
```

当请求使用内容类型 `application/x-www-form-urlencoded` 时，排除参数使用 `body-form`。

<a id="excluding-a-specific-json-nodes-using-json-path"></a>

##### 使用 JSON Path 排除特定的 JSON 节点

要排除根对象中的 `schema` 属性，请将 `body-json` 属性的值设置为包含 JSON Path 表达式 `[ "$.schema" ]` 的数组。

JSON Path 表达式使用特殊语法来标识 JSON 节点：`$` 指代 JSON 文档的根，`.` 指代当前对象（本例中为根对象），文本 `schema` 指代属性名称。因此，JSON Path 表达式 `$.schema` 指代根对象中的属性 `schema`。
例如，JSON 文档如下所示：

```json
{
  "body-json": [ "$.schema" ]
}
```

当请求使用内容类型 `application/json` 时，排除参数使用 `body-json`。`body-json` 中的每个条目都应是 [JSON Path 表达式](https://goessner.net/articles/JsonPath/)。在 JSON Path 中，诸如 `$`、`*`、`.` 等字符具有特殊含义。

<a id="excluding-multiple-json-nodes-using-json-path"></a>

##### 使用 JSON Path 排除多个 JSON 节点

要在根级别的 `users` 数组的每个条目中排除属性 `password`，请将 `body-json` 属性的值设置为包含 JSON Path 表达式 `[ "$.users[*].password" ]` 的数组。

JSON Path 表达式以 `$` 开头指代根节点，使用 `.` 指代当前节点。然后，它使用 `users` 指代属性，并使用 `[` 和 `]` 括起要使用的数组索引，但不提供数字索引，而是使用 `*` 指定任何索引。在索引引用之后，字符 `.` 指代数组中任何给定选定的索引，后跟属性名 `password`。

例如，JSON 文档如下所示：

```json
{
  "body-json": [ "$.users[*].password" ]
}
```

当请求使用内容类型 `application/json` 时，排除参数使用 `body-json`。`body-json` 中的每个条目都应是 [JSON Path 表达式](https://goessner.net/articles/JsonPath/)。在 JSON Path 中，诸如 `$`、`*`、`.` 等字符具有特殊含义。

<a id="excluding-a-xml-attribute"></a>

##### 排除 XML 属性

要排除位于根元素 `credentials` 中名为 `isEnabled` 的属性，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[ "/credentials/@isEnabled" ]` 的数组。

XPath 表达式 `/credentials/@isEnabled` 以 `/` 开头指示 XML 文档的根，后跟 `credentials` 指示要匹配的元素名称。它使用 `/` 指代前一个 XML 元素的节点，并使用字符 `@` 指示名称 `isEnable` 是一个属性。

例如，JSON 文档如下所示：

```json
{
  "body-xml": [
    "/credentials/@isEnabled"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml` 中的每个条目都应是 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-a-xml-texts-element"></a>

##### 排除 XML 文本元素

要排除根节点 `credentials` 中包含的 `username` 元素的文本，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[/credentials/username/text()" ]` 的数组。

在 XPath 表达式 `/credentials/username/text()` 中，第一个字符 `/` 指代根 XML 节点，然后指示 XML 元素名称 `credentials`。类似地，字符 `/` 指代当前元素，后跟新的 XML 元素名称 `username`。最后一部分有一个 `/` 指代当前元素，并使用一个称为 `text()` 的 XPath 函数来标识当前元素的文本。

例如，JSON 文档如下所示：

```json
{
  "body-xml": [
    "/credentials/username/text()"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml` 中的每个条目都应是 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-element"></a>

##### 排除 XML 元素

要排除根节点 `credentials` 中包含的 `username` 元素，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[/credentials/username" ]` 的数组。

在 XPath 表达式 `/credentials/username` 中，第一个字符 `/` 指代根 XML 节点，然后指示 XML 元素名称 `credentials`。类似地，字符 `/` 指代当前元素，后跟新的 XML 元素名称 `username`。

例如，JSON 文档如下所示：

```json
{
  "body-xml": [
    "/credentials/username"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml` 中的每个条目都应是 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-node-with-namespaces"></a>

##### 排除带命名空间的 XML 节点

要排除在命名空间 `s` 中定义并包含在根节点 `credentials` 中的 XML 元素 `login`，请将 `body-xml` 属性的值设置为包含 XPath 表达式 `[ "/credentials/s:login" ]` 的数组。

在 XPath 表达式 `/credentials/s:login` 中，第一个字符 `/` 指代根 XML 节点，然后指示 XML 元素名称 `credentials`。类似地，字符 `/` 指代当前元素，后跟新的 XML 元素名称 `s:login`。请注意，名称包含字符 `:`，此字符将命名空间与节点名称分隔开。

命名空间名称应该已在 XML 文档（作为正文请求的一部分）中定义。你可以在规范文档 HAR、OpenAPI 或 Postman Collection 文件中检查命名空间。

```json
{
  "body-xml": [
    "/credentials/s:login"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml` 中的每个条目都应是 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 中，诸如 `@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="using-a-json-string"></a>

#### 使用 JSON 字符串

要提供排除 JSON 文档，请将变量 `APISEC_EXCLUDE_PARAMETER_ENV` 设置为 JSON 字符串。在以下 `.gitlab-ci.yml` 示例中，`APISEC_EXCLUDE_PARAMETER_ENV` 变量被设置为一个 JSON 字符串：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_EXCLUDE_PARAMETER_ENV: '{ "headers": [ "Upgrade-Insecure-Requests" ] }'
```

<a id="using-a-file"></a>

#### 使用文件

要提供排除 JSON 文档，请将变量 `APISEC_EXCLUDE_PARAMETER_FILE` 设置为 JSON 文件路径。该文件路径相对于作业的当前工作目录。在以下 `.gitlab-ci.yml` 内容示例中，`APISEC_EXCLUDE_PARAMETER_FILE` 变量被设置为一个 JSON 文件路径：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_OPENAPI: test-api-specification.json
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_EXCLUDE_PARAMETER_FILE: dast-api-exclude-parameters.json
```

`dast-api-exclude-parameters.json` 是一个遵循 [排除参数文档](#exclude-parameters-using-a-json-document) 结构的 JSON 文档。

<a id="exclude-urls"></a>

### 排除 URL

作为按路径排除的替代方案，你可以使用 `APISEC_EXCLUDE_URLS` CI/CD 变量按 URL 中的任何其他组件进行过滤。此变量可以在你的 `.gitlab-ci.yml` 文件中设置。该变量可以存储多个值，以逗号 (`,`) 分隔。每个值都是一个正则表达式。由于每个条目都是正则表达式，像 `.*` 这样的条目会排除所有 URL，因为它是一个匹配所有内容的正则表达式。

在你的作业输出中，你可以检查是否有任何 URL 与 `APISEC_EXCLUDE_URLS` 中提供的任何正则表达式匹配。匹配的操作列在 **已排除操作** 部分。**已排除操作** 中列出的操作不应列在 **已测试操作** 部分。例如，以下作业输出的一部分：

```plaintext
2021-05-27 21:51:08 [INF] API SECURITY: --[ 已测试操作 ]-------------------------
2021-05-27 21:51:08 [INF] API SECURITY: 201 POST http://target:7777/api/users CREATED
2021-05-27 21:51:08 [INF] API SECURITY: ------------------------------------------------
2021-05-27 21:51:08 [INF] API SECURITY: --[ 已排除操作 ]-----------------------
2021-05-27 21:51:08 [INF] API SECURITY: GET http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API SECURITY: POST http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API SECURITY: ------------------------------------------------
```

> [!note]
> `APISEC_EXCLUDE_URLS` 中的每个值都是正则表达式。诸如 `.`、`*` 和 `$` 等字符在[正则表达式](https://en.wikipedia.org/wiki/Regular_expression#Standards)中具有特殊含义。

<a id="examples-2"></a>

#### 示例

<a id="excluding-a-url-and-child-resources"></a>

##### 排除一个 URL 及其子资源

以下示例排除了 URL `http://target/api/auth` 及其子资源。

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: http://target/
  APISEC_OPENAPI: test-api-specification.json
  APISEC_EXCLUDE_URLS: http://target/api/auth
```

<a id="excluding-two-urls-and-allow-their-child-resources"></a>

##### 排除两个 URL 并允许其子资源

要排除 URL `http://target/api/buy` 和 `http://target/api/sell`，但允许扫描其子资源，例如 `http://target/api/buy/toy` 或 `http://target/api/sell/chair`。你可以使用值 `http://target/api/buy/$,http://target/api/sell/$`。此值使用了两个正则表达式，每个表达式由 `,` 字符分隔。因此，它包含 `http://target/api/buy$` 和 `http://target/api/sell$`。在每个正则表达式中，结尾的 `$` 字符指示匹配的 URL 应在何处结束。

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: http://target/
  APISEC_OPENAPI: test-api-specification.json
  APISEC_EXCLUDE_URLS: http://target/api/buy/$,http://target/api/sell/$
```

<a id="excluding-two-urls-and-their-child-resources"></a>

##### 排除两个 URL 及其子资源

要排除 URL `http://target/api/buy` 和 `http://target/api/sell` 及其子资源。要提供多个 URL，请使用 `,` 字符，如下所示：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: http://target/
  APISEC_OPENAPI: test-api-specification.json
  APISEC_EXCLUDE_URLS: http://target/api/buy,http://target/api/sell
```

<a id="excluding-url-using-regular-expressions"></a>

##### 使用正则表达式排除 URL

要精确排除 `https://target/api/v1/user/create` 和 `https://target/api/v2/user/create` 或任何其他版本（`v3`、`v4` 等），请使用 `https://target/api/v.*/user/create$`。在正则表达式中，`.` 表示任何字符，`*` 表示零次或多次。`$` 表示 URL 应在此处结束。

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: http://target/
  APISEC_OPENAPI: test-api-specification.json
  APISEC_EXCLUDE_URLS: https://target/api/v.*/user/create$
```