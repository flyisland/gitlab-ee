---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义分析器设置
---

API 模糊测试行为可通过 CI/CD 变量进行更改。

API 模糊测试配置文件必须位于代码仓库的 `.gitlab` 目录中。

> [!warning]
> 对极狐GitLab 安全扫描工具的所有自定义设置，都应在合并请求中进行测试，然后再将这些更改合并到默认分支。否则可能会产生意外结果，包括大量误报。

<a id="authentication"></a>

## 身份验证

身份验证通过将身份验证令牌作为请求头或 Cookie 提供来处理。您可以提供一个执行身份验证流程或计算令牌的脚本。

<a id="http-basic-authentication"></a>

### HTTP 基本身份验证

[HTTP 基本身份验证](https://en.wikipedia.org/wiki/Basic_access_authentication)是内置于 HTTP 协议中的一种身份验证方法，与[传输层安全 (TLS)](https://en.wikipedia.org/wiki/Transport_Layer_Security) 配合使用。

建议您为密码（例如 `TEST_API_PASSWORD`）[创建 CI/CD 变量](../../../../ci/variables/_index.md#for-a-project)，并将其设置为掩码。您可以在极狐GitLab 项目页面的**设置** > **CI/CD**中的**变量**部分创建 CI/CD 变量。由于[掩码变量的限制](../../../../ci/variables/_index.md#mask-a-cicd-variable)，您应在将密码添加为变量之前对其进行 Base64 编码。

最后，将两个 CI/CD 变量添加到您的 `.gitlab-ci.yml` 文件中：

- `FUZZAPI_HTTP_USERNAME`：用于身份验证的用户名。
- `FUZZAPI_HTTP_PASSWORD_BASE64`：用于身份验证的 Base64 编码密码。

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

如果您不想对密码进行 Base64 编码，可以提供原始密码 `FUZZAPI_HTTP_PASSWORD`，而不使用 `FUZZAPI_HTTP_PASSWORD_BASE64`。

<a id="bearer-tokens"></a>

### Bearer 令牌

Bearer 令牌用于多种不同的身份验证机制，包括 OAuth2 和 JSON Web 令牌 (JWT)。Bearer 令牌使用 `Authorization` HTTP 请求头传输。要将 Bearer 令牌与 API 模糊测试配合使用，您需要满足以下条件之一：

- 一个不会过期的令牌
- 一种生成在测试期间持续有效的令牌的方法
- 一个 API 模糊测试可以调用以生成令牌的 Python 脚本

<a id="token-doesnt-expire"></a>

#### 令牌不会过期

如果 Bearer 令牌不会过期，请使用 `FUZZAPI_OVERRIDES_ENV` 变量提供它。该变量的内容是一段 JSON 片段，提供要添加到 API 模糊测试传出 HTTP 请求中的请求头和 Cookie。

按照以下步骤使用 `FUZZAPI_OVERRIDES_ENV` 提供 Bearer 令牌：

1. [创建 CI/CD 变量](../../../../ci/variables/_index.md#for-a-project)，
   例如 `TEST_API_BEARERAUTH`，其值为
   `{"headers":{"Authorization":"Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}}`（替换为您的令牌）。您
   可以在极狐GitLab 项目页面的**设置** > **CI/CD**中的
   **变量**部分创建 CI/CD 变量。

1. 在您的 `.gitlab-ci.yml` 文件中，将 `FUZZAPI_OVERRIDES_ENV` 设置为您刚刚创建的变量：

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

1. 要验证身份验证是否正常工作，请运行 API 模糊测试并查看模糊测试日志
   以及测试 API 的应用程序日志。有关覆盖命令的更多信息，请参阅[覆盖部分](#overrides)。

<a id="token-generated-at-test-runtime"></a>

#### 在测试运行时生成令牌

如果 Bearer 令牌必须生成且在测试期间不会过期，您可以通过一个包含该令牌的文件提供给 API 模糊测试。之前阶段和作业，或 API 模糊测试作业的一部分，可以生成此文件。

API 模糊测试期望接收具有以下结构的 JSON 文件：

```json
{
  "headers" : {
    "Authorization" : "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

此文件可以由之前的阶段生成，并通过 `FUZZAPI_OVERRIDES_FILE` CI/CD 变量提供给 API 模糊测试。

在您的 `.gitlab-ci.yml` 文件中设置 `FUZZAPI_OVERRIDES_FILE`：

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

要验证身份验证是否正常工作，请运行 API 模糊测试并查看模糊测试日志以及测试 API 的应用程序日志。

<a id="token-has-short-expiration"></a>

#### 令牌有效期较短

如果 Bearer 令牌必须生成且在扫描完成之前过期，您可以提供一个程序或脚本，供 API 模糊测试器按指定间隔执行。提供的脚本在
安装了 Python 3 和 Bash 的 Alpine Linux 容器中运行。如果 Python 脚本需要
其他软件包，它必须检测到这一点并在运行时安装这些软件包。

该脚本必须创建一个包含 Bearer 令牌的 JSON 文件，格式如下：

```json
{
  "headers" : {
    "Authorization" : "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}
```

您必须提供三个 CI/CD 变量，每个变量都需正确设置：

- `FUZZAPI_OVERRIDES_FILE`：提供的命令生成的 JSON 文件。
- `FUZZAPI_OVERRIDES_CMD`：生成 JSON 文件的命令。
- `FUZZAPI_OVERRIDES_INTERVAL`：运行命令的间隔（以秒为单位）。

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

要验证身份验证是否正常工作，请运行 API 模糊测试并查看模糊测试日志以及测试 API 的应用程序日志。

<a id="api-fuzzing-profiles"></a>

## API 模糊测试配置文件

极狐GitLab 提供配置文件
[`gitlab-api-fuzzing-config.yml`](https://gitlab.com/gitlab-org/security-products/analyzers/api-fuzzing/-/blob/master/gitlab-api-fuzzing-config.yml)。
它包含多个测试配置文件，执行特定数量的测试。每个配置文件的运行时间随着测试数量的增加而增加。

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

您可以使用它来注入语义版本请求头、身份验证等。[身份验证部分](#authentication)包含为此目的使用覆盖的示例。

覆盖使用 JSON 文档，其中每种覆盖类型由 JSON 对象表示：

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

当请求正文仅包含表单数据内容时，覆盖引擎使用 `body-form`。

设置 `body-json` 覆盖的示例用法：

```json
{
  "body-json":  {
    "$.credentials.access-token": "iddqd!42.$"
  }
}
```

对象 `body-json`中的每个 JSON 属性名称都设置为一个 [JSON Path](https://goessner.net/articles/JsonPath/) 表达式。JSON Path 表达式 `$.credentials.access-token` 标识要用值 `iddqd!42.$` 覆盖的节点。当请求正文仅包含 [JSON](https://www.json.org/json-en.html) 内容时，覆盖引擎使用 `body-json`。

例如，如果正文设置为以下 JSON：

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

以下是设置 `body-xml` 覆盖的示例。第一个条目覆盖一个 XML 属性，第二个条目覆盖一个 XML 元素：

```json
{
  "body-xml" :  {
    "/credentials/@isEnabled": "true",
    "/credentials/access-token/text()" : "iddqd!42.$"
  }
}
```

对象 `body-xml`中的每个 JSON 属性名称都设置为一个
[XPath v2](https://www.w3.org/TR/xpath20/)
表达式。XPath 表达式 `/credentials/@isEnabled` 标识要覆盖的属性节点，其值为 `true`。XPath 表达式 `/credentials/access-token/text()` 标识要用值 `iddqd!42.$` 覆盖的元素节点。当请求正文仅包含 [XML](https://www.w3.org/XML/) 内容时，覆盖引擎使用 `body-xml`。

例如，如果正文设置为以下 XML：

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

您可以将此 JSON 文档作为文件或环境变量提供。您也可以提供一个命令来生成 JSON 文档。该命令可以按间隔运行，以支持会过期的值。

<a id="using-a-file"></a>

### 使用文件

要将覆盖 JSON 作为文件提供，需设置 `FUZZAPI_OVERRIDES_FILE` CI/CD 变量。该路径相对于作业的当前工作目录。

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

要将覆盖 JSON 作为 CI/CD 变量提供，请使用 `FUZZAPI_OVERRIDES_ENV` 变量。这样可以将 JSON 存储在可设置掩码和保护的变量中。

在此 `.gitlab-ci.yml` 示例中，`FUZZAPI_OVERRIDES_ENV` 变量直接设置为该 JSON：

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

在此 `.gitlab-ci.yml` 示例中，`SECRET_OVERRIDES` 变量提供该 JSON。这是一个[在 UI 中定义的群组或实例级 CI/CD 变量](../../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)：

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

如果值必须生成或在过期时重新生成，您可以提供一个程序或脚本，供
API 模糊测试器按指定间隔执行。提供的脚本在安装了 Python 3 和 Bash 的 Alpine Linux
容器中运行。

您必须将环境变量 `FUZZAPI_OVERRIDES_CMD` 设置为您想要执行的程序或脚本。提供的命令会创建如前所定义的覆盖 JSON 文件。

您可能想要安装其他脚本运行时，如 NodeJS 或 Ruby，或者您可能需要为覆盖命令安装依赖项。在这种情况下，您应将 `FUZZAPI_PRE_SCRIPT` 设置为提供这些先决条件的脚本文件路径。由 `FUZZAPI_PRE_SCRIPT` 提供的脚本在分析器启动之前执行一次。

> [!note]
> 在执行需要提升权限的操作时，请使用 `sudo` 命令。
> 例如，`sudo apk add nodejs`。

有关安装 Alpine Linux 软件包的信息，请参阅 [Alpine Linux 软件包管理](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)
页面。

您必须提供三个 CI/CD 变量，每个变量都需正确设置：

- `FUZZAPI_OVERRIDES_FILE`：由提供的命令生成的文件。
- `FUZZAPI_OVERRIDES_CMD`：负责定期生成覆盖 JSON 文件的覆盖命令。
- `FUZZAPI_OVERRIDES_INTERVAL`：运行命令的间隔（以秒为单位）。

可选：

- `FUZZAPI_PRE_SCRIPT`：在分析器启动之前安装运行时或依赖项的脚本。

> [!warning]
> 要在 Alpine Linux 中执行脚本，您必须首先使用命令 [`chmod`](https://www.gnu.org/software/coreutils/manual/html_node/chmod-invocation.html) 设置[执行权限](https://www.gnu.org/software/coreutils/manual/html_node/Setting-Permissions.html)。例如，要为所有人设置 `script.py`的执行权限，请使用命令：`sudo chmod a+x script.py`。如有需要，您可以对已设置执行权限的 `script.py` 进行版本控制。

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

默认情况下，覆盖命令的输出是隐藏的。如果覆盖命令返回非零退出代码，该命令会作为作业输出的一部分显示。您可以选择将变量 `FUZZAPI_OVERRIDES_CMD_VERBOSE` 设置为任意值，以在生成时显示覆盖命令输出。这在测试覆盖脚本时很有用，但之后应禁用它，因为它会减慢测试速度。

您还可以将脚本中的消息写入日志文件，该文件在作业完成或失败时被收集。日志文件必须在特定位置创建并遵循命名约定。

在覆盖脚本中添加一些基本日志记录很有用，以防脚本在作业的典型运行过程中意外失败。日志文件会自动作为作业的产物包含在内，允许您在作业完成后下载它。

按照我们的示例，我们在环境变量 `FUZZAPI_OVERRIDES_CMD`中提供了 `renew_token.py`。请注意脚本中的两点：

- 日志文件保存在环境变量 `CI_PROJECT_DIR` 指示的位置。
- 日志文件名应匹配 `gl-*.log`。

```python
#!/usr/bin/env python

# Example of an overrides command

# Override commands can update the overrides json file
# with new values to be used.  This is a great way to
# update an authentication token that will expire
# during testing.

import logging
import json
import os
import requests
import backoff

# [1] Store log file in directory indicated by env var CI_PROJECT_DIR
working_directory = os.environ.get( 'CI_PROJECT_DIR')
overrides_file_name = os.environ.get('FUZZAPI_OVERRIDES_FILE', 'api-fuzzing-overrides.json')
overrides_file_path = os.path.join(working_directory, overrides_file_name)

# [2] File name should match the pattern: gl-*.log
log_file_path = os.path.join(working_directory, 'gl-user-overrides.log')

# Set up logger
logging.basicConfig(filename=log_file_path, level=logging.DEBUG)

# Use `backoff` decorator to retry in case of transient errors.
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

# In our example, access token is retrieved from a given endpoint
try:

    # Performs a http request, response sample:
    # { "Token" : "abcdefghijklmn" }
    response = get_auth_response()

    # Check that the request is successful. may raise `requests.exceptions.HTTPError`
    response.raise_for_status()

    # Gets JSON data
    response_body = response.json()

# If needed specific exceptions can be caught
# requests.ConnectionError                  : A network connection error problem occurred
# requests.HTTPError                        : HTTP request returned an unsuccessful status code. [Response.raise_for_status()]
# requests.ConnectTimeout                   : The request timed out while trying to connect to the remote server
# requests.ReadTimeout                      : The server did not send any data in the allotted amount of time.
# requests.TooManyRedirects                 : The request exceeds the configured number of maximum redirections
# requests.exceptions.RequestException      : All exceptions that related to Requests
except json.JSONDecodeError as json_decode_error:
    # logs errors related decoding JSON response
    logging.error(f'Error, failed while decoding JSON response. Error message: {json_decode_error}')
    raise
except requests.exceptions.RequestException as requests_error:
    # logs  exceptions  related to `Requests`
    logging.error(f'Error, failed while performing HTTP request. Error message: {requests_error}')
    raise
except Exception as e:
    # logs any other error
    logging.error(f'Error, unknown error while retrieving access token. Error message: {e}')
    raise

# computes object that holds overrides file content.
# It uses data fetched from request
overrides_data = {
    "headers": {
        "Authorization": f"Token {response_body['Token']}"
    }
}

# log entry informing about the file override computation
logging.info("Creating overrides file: %s" % overrides_file_path)

# attempts to overwrite the file
try:
    if os.path.exists(overrides_file_path):
        os.unlink(overrides_file_path)

    # overwrites the file with our updated dictionary
    with open(overrides_file_path, "wb+") as fd:
        fd.write(json.dumps(overrides_data).encode('utf-8'))
except Exception as e:
    # logs any other error
    logging.error(f'Error, unknown error when overwriting file {overrides_file_path}. Error message: {e}')
    raise

# logs informing override has finished successfully
logging.info("Override file has been updated")

# end
```

在覆盖命令示例中，Python 脚本依赖于 `backoff` 库。为确保在执行 Python 脚本之前安装该库，将 `FUZZAPI_PRE_SCRIPT` 设置为一个安装覆盖命令依赖项的脚本。例如，以下脚本 `user-pre-scan-set-up.sh`：

```shell
#!/bin/bash

# user-pre-scan-set-up.sh
# Ensures python dependencies are installed

echo "**** install python dependencies ****"

sudo pip3 install --no-cache --upgrade --break-system-packages \
    requests \
    backoff

echo "**** python dependencies installed ****"

# end
```

您必须更新配置，将 `FUZZAPI_PRE_SCRIPT` 设置为我们的新 `user-pre-scan-set-up.sh` 脚本。例如：

```yaml
stages:
     - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_PRE_SCRIPT: user-pre-scan-set-up.sh
  FUZZAPI_OVERRIDES_FILE: api-fuzzing-overrides.json
  FUZZAPI_OVERRIDES_CMD: renew_token.py
  FUZZAPI_OVERRIDES_INTERVAL: 300
```

在前面的示例中，您可以使用脚本 `user-pre-scan-set-up.sh` 来安装新的运行时或应用程序，之后您可以在覆盖命令中使用它们。

<a id="exclude-paths"></a>

## 排除路径

在测试 API 时，排除某些路径可能很有用。例如，您可能排除对身份验证服务或旧版 API 的测试。要排除路径，请使用 `FUZZAPI_EXCLUDE_PATHS` CI/CD 变量。该变量在您的 `.gitlab-ci.yml` 文件中指定。要排除多个路径，请使用 `;` 字符分隔条目。在提供的路径中，您可以使用单字符通配符 `?` 和 `*` 作为多字符通配符。

要验证路径已被排除，请查看作业输出中的 `Tested Operations` 和 `Excluded Operations` 部分。您不应在 `Tested Operations` 下看到任何列出的已排除路径。

```plaintext
2021-05-27 21:51:08 [INF] API Fuzzing: --[ Tested Operations ]-------------------------
2021-05-27 21:51:08 [INF] API Fuzzing: 201 POST http://target:7777/api/users CREATED
2021-05-27 21:51:08 [INF] API Fuzzing: ------------------------------------------------
2021-05-27 21:51:08 [INF] API Fuzzing: --[ Excluded Operations ]-----------------------
2021-05-27 21:51:08 [INF] API Fuzzing: GET http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API Fuzzing: POST http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API Fuzzing: ------------------------------------------------
```

<a id="examples-of-excluding-paths"></a>

### 排除路径的示例

此示例排除 `/auth` 资源。这不会排除子资源（`/auth/child`）。

```yaml
variables:
  FUZZAPI_EXCLUDE_PATHS: /auth
```

要排除 `/auth` 及其子资源（`/auth/child`），请使用通配符：

```yaml
variables:
  FUZZAPI_EXCLUDE_PATHS: /auth*
```

要排除多个路径，请使用 `;` 字符分隔路径。此示例展示了如何通过排除 `/auth*` 和 `/v1/*` 来实现。

```yaml
variables:
  FUZZAPI_EXCLUDE_PATHS: /auth*;/v1/*
```

<a id="exclude-parameters"></a>

## 排除参数

在测试 API 时，您可能希望从测试中排除某个参数（查询字符串、请求头或正文元素）。这可能是必要的，因为某个参数总是导致失败、减慢测试速度，或其他原因。要排除参数，您可以使用以下变量之一：`FUZZAPI_EXCLUDE_PARAMETER_ENV` 或 `FUZZAPI_EXCLUDE_PARAMETER_FILE`。

`FUZZAPI_EXCLUDE_PARAMETER_ENV` 允许提供包含被排除参数的 JSON 字符串。如果 JSON 较短且不经常更改，这是一个不错的选择。另一个选项是变量 `FUZZAPI_EXCLUDE_PARAMETER_FILE`。该变量设置为一个文件路径，该文件可以检入代码仓库、由另一个作业作为产物创建，或使用 `FUZZAPI_PRE_SCRIPT` 在运行时从预脚本生成。

<a id="exclude-parameters-using-a-json-document"></a>

### 使用 JSON 文档排除参数

JSON 文档包含一个 JSON 对象，该对象使用特定属性来标识应排除哪个参数。您可以在扫描过程中提供以下属性来排除特定参数：

- `headers`：使用此属性排除特定请求头。该属性的值是要排除的请求头名称数组。名称不区分大小写。
- `cookies`：使用此属性的值排除特定 Cookie。该属性的值是要排除的 Cookie 名称数组。名称区分大小写。
- `query`：使用此属性从查询字符串中排除特定字段。该属性的值是要从查询字符串中排除的字段名称数组。名称区分大小写。
- `body-form`：使用此属性从使用媒体类型 `application/x-www-form-urlencoded`的请求中排除特定字段。该属性的值是要从正文中排除的字段名称数组。名称区分大小写。
- `body-json`：使用此属性从使用媒体类型 `application/json`的请求中排除特定 JSON 节点。该属性的值是一个数组，数组的每个条目是一个 [JSON Path](https://goessner.net/articles/JsonPath/) 表达式。
- `body-xml`：使用此属性从使用媒体类型 `application/xml`的请求中排除特定 XML 节点。该属性的值是一个数组，数组的每个条目是一个 [XPath v2](https://www.w3.org/TR/xpath20/) 表达式。

以下 JSON 文档是排除参数预期结构的示例。

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

要排除请求头 `Upgrade-Insecure-Requests`，请将 `header` 属性的值设置为包含该请求头名称的数组：`[ "Upgrade-Insecure-Requests" ]`。例如，JSON 文档如下所示：

```json
{
  "headers": [ "Upgrade-Insecure-Requests" ]
}
```

请求头名称不区分大小写，因此请求头名称 `UPGRADE-INSECURE-REQUESTS` 等同于 `Upgrade-Insecure-Requests`。

<a id="excluding-both-a-header-and-two-cookies"></a>

#### 同时排除一个请求头和两个 Cookie

要排除请求头 `Authorization` 以及 Cookie `PHPSESSID` 和 `csrftoken`，请将 `headers` 属性的值设置为包含请求头名称的数组 `[ "Authorization" ]`，并将 `cookies` 属性的值设置为包含 Cookie 名称的数组 `[ "PHPSESSID", "csrftoken" ]`。例如，JSON 文档如下所示：

```json
{
  "headers": [ "Authorization" ],
  "cookies": [ "PHPSESSID", "csrftoken" ]
}
```

<a id="excluding-a-body-form-parameter"></a>

#### 排除 `body-form` 参数

要排除使用 `application/x-www-form-urlencoded`的请求中的 `password` 字段，请将 `body-form` 属性的值设置为包含该字段名称的数组 `[ "password" ]`。例如，JSON 文档如下所示：

```json
{
  "body-form":  [ "password" ]
}
```

当请求使用内容类型 `application/x-www-form-urlencoded` 时，排除参数使用 `body-form`。

<a id="excluding-a-specific-json-nodes-using-json-path"></a>

#### 使用 JSON Path 排除特定 JSON 节点

要排除根对象中的 `schema` 属性，请将 `body-json` 属性的值设置为包含 JSON Path 表达式的数组 `[ "$.schema" ]`。

JSON Path 表达式使用特殊语法来标识 JSON 节点：`$` 指 JSON 文档的根，`.` 指当前对象（在我们的例子中是根对象），文本 `schema` 指属性名称。因此，JSON 路径表达式 `$.schema` 指根对象中的属性 `schema`。例如，JSON 文档如下所示：

```json
{
  "body-json": [ "$.schema" ]
}
```

当请求使用内容类型 `application/json` 时，排除参数使用 `body-json`。`body-json`中的每个条目都应为 [JSON Path 表达式](https://goessner.net/articles/JsonPath/)。在 JSON Path 中，`$`、`*`、`.` 等字符具有特殊含义。

<a id="excluding-multiple-json-nodes-using-json-path"></a>

#### 使用 JSON Path 排除多个 JSON 节点

要排除根级别 `users` 数组每个条目上的属性 `password`，请将 `body-json` 属性的值设置为包含 JSON Path 表达式的数组 `[ "$.users[*].password" ]`。

JSON Path 表达式以 `$` 开头，指根节点，并使用 `.` 指当前节点。接下来，它使用 `users` 指一个属性。字符 `[` 和 `]` 括住您要使用的数组索引。您可以使用 `*` 指定任意索引，而不是提供具体数字。在索引引用之后，`.` 字符指数组中任意给定的选定索引，后跟属性名称 `password`。

例如，JSON 文档如下所示：

```json
{
  "body-json": [ "$.users[*].password" ]
}
```

当请求使用内容类型 `application/json` 时，排除参数使用 `body-json`。`body-json`中的每个条目都应为 [JSON Path 表达式](https://goessner.net/articles/JsonPath/)。在 JSON Path 中，`$`、`*`、`.` 等字符具有特殊含义。

<a id="excluding-an-xml-attribute"></a>

#### 排除 XML 属性

要排除位于根元素 `credentials`中名为 `isEnabled`的属性，请将 `body-xml` 属性的值设置为包含 XPath 表达式的数组 `[ "/credentials/@isEnabled" ]`。

XPath 表达式 `/credentials/@isEnabled` 以 `/` 开头，表示 XML 文档的根，然后后跟单词 `credentials`，表示要匹配的元素名称。它使用 `/` 指前一个 XML 元素的节点，并使用字符 `@` 表示名称 `isEnable` 是一个属性。

例如，JSON 文档如下所示：

```json
{
  "body-xml": [
    "/credentials/@isEnabled"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml`中的每个条目都应为 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，`@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-elements-text"></a>

#### 排除 XML 元素的文本

要排除根节点 `credentials`中包含的 `username` 元素的文本，请将 `body-xml` 属性的值设置为包含 XPath 表达式的数组 `[/credentials/username/text()" ]`。

在 XPath 表达式 `/credentials/username/text()`中，第一个字符 `/` 指根 XML 节点，然后在其后表示 XML 元素的名称 `credentials`。类似地，字符 `/` 指当前元素，后跟新的 XML 元素名称 `username`。最后一部分有一个 `/` 指当前元素，并使用名为 `text()`的 XPath 函数，该函数标识当前元素的文本。

例如，JSON 文档如下所示：

```json
{
  "body-xml": [
    "/credentials/username/text()"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml`中的每个条目都应为 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，`@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-element"></a>

#### 排除 XML 元素

要排除根节点 `credentials`中包含的元素 `username`，请将 `body-xml` 属性的值设置为包含 XPath 表达式的数组 `[/credentials/username" ]`。

在 XPath 表达式 `/credentials/username`中，第一个字符 `/` 指根 XML 节点，然后在其后表示 XML 元素的名称 `credentials`。类似地，字符 `/` 指当前元素，后跟新的 XML 元素名称 `username`。

例如，JSON 文档如下所示：

```json
{
  "body-xml": [
    "/credentials/username"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml`中的每个条目都应为 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，`@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="excluding-an-xml-node-with-namespaces"></a>

#### 排除带命名空间的 XML 节点

要排除在命名空间 `s`中定义、且包含在 `credentials` 根节点中的 XML 元素 `login`，请将 `body-xml` 属性的值设置为包含 XPath 表达式的数组 `[ "/credentials/s:login" ]`。

在 XPath 表达式 `/credentials/s:login`中，第一个字符 `/` 指根 XML 节点，然后在其后表示 XML 元素的名称 `credentials`。类似地，字符 `/` 指当前元素，后跟新的 XML 元素名称 `s:login`。请注意，该名称包含字符 `:`，该字符将命名空间与节点名称分隔开。

命名空间名称应已在作为请求正文一部分的 XML 文档中定义。您可以在规范文档 HAR、OpenAPI 或 Postman Collection 文件中检查命名空间。

```json
{
  "body-xml": [
    "/credentials/s:login"
  ]
}
```

当请求使用内容类型 `application/xml` 时，排除参数使用 `body-xml`。`body-xml`中的每个条目都应为 [XPath v2 表达式](https://www.w3.org/TR/xpath20/)。在 XPath 表达式中，`@`、`/`、`:`、`[`、`]` 等字符具有特殊含义。

<a id="using-a-json-string"></a>

### 使用 JSON 字符串

要提供排除 JSON 文档，请将变量 `FUZZAPI_EXCLUDE_PARAMETER_ENV` 设置为该 JSON 字符串。在以下示例 `.gitlab-ci.yml`中，`FUZZAPI_EXCLUDE_PARAMETER_ENV` 变量设置为一个 JSON 字符串：

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

<a id="using-a-file-1"></a>

### 使用文件

要提供排除 JSON 文档，请将变量 `FUZZAPI_EXCLUDE_PARAMETER_FILE` 设置为该 JSON 文件路径。该文件路径相对于作业的当前工作目录。在以下示例 `.gitlab-ci.yml` 文件中，`FUZZAPI_EXCLUDE_PARAMETER_FILE` 变量设置为一个 JSON 文件路径：

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

`api-fuzzing-exclude-parameters.json` 是一个遵循[排除参数文档](#exclude-parameters-using-a-json-document)结构的 JSON 文档。

<a id="exclude-urls"></a>

## 排除 URL

作为按路径排除的替代方法，您可以使用 `FUZZAPI_EXCLUDE_URLS` CI/CD 变量按 URL 中的任何其他组件进行筛选。该变量可以在您的 `.gitlab-ci.yml` 文件中设置。该变量可以存储多个值，以逗号（`,`）分隔。每个值都是一个正则表达式。由于每个条目都是正则表达式，诸如 `.*` 这样的条目会排除所有 URL，因为它是一个匹配所有内容的正则表达式。

在作业输出中，您可以检查是否有任何 URL 匹配 `FUZZAPI_EXCLUDE_URLS`中提供的任何正则表达式。匹配操作列在 **Excluded Operations** 部分。列在 **Excluded Operations**中的操作不应列在 **Tested Operations** 部分。例如，以下作业输出的一部分：

```plaintext
2021-05-27 21:51:08 [INF] API Fuzzing: --[ Tested Operations ]-------------------------
2021-05-27 21:51:08 [INF] API Fuzzing: 201 POST http://target:7777/api/users CREATED
2021-05-27 21:51:08 [INF] API Fuzzing: ------------------------------------------------
2021-05-27 21:51:08 [INF] API Fuzzing: --[ Excluded Operations ]-----------------------
2021-05-27 21:51:08 [INF] API Fuzzing: GET http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API Fuzzing: POST http://target:7777/api/messages
2021-05-27 21:51:08 [INF] API Fuzzing: ------------------------------------------------
```

> [!note]
> `FUZZAPI_EXCLUDE_URLS`中的每个值都是一个正则表达式。`.`、`*` 和 `$` 等许多字符在[正则表达式](https://en.wikipedia.org/wiki/Regular_expression#Standards)中具有特殊含义。

<a id="examples-1"></a>

### 示例

<a id="excluding-a-url-and-child-resources"></a>

#### 排除一个 URL 及其子资源

以下示例排除 URL `http://target/api/auth` 及其子资源。

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

#### 排除两个 URL 并允许其子资源

要排除 URL `http://target/api/buy` 和 `http://target/api/sell`，但允许扫描其子资源，例如：`http://target/api/buy/toy` 或 `http://target/api/sell/chair`。您可以使用值 `http://target/api/buy/$,http://target/api/sell/$`。该值使用两个正则表达式，每个由 `,` 字符分隔。因此，它包含 `http://target/api/buy$` 和 `http://target/api/sell$`。在每个正则表达式中，末尾的 `$` 字符指出匹配 URL 应结束的位置。

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

要排除 URL：`http://target/api/buy` 和 `http://target/api/sell`，及其子资源。要提供多个 URL，我们使用 `,` 字符，如下所示：

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

要精确排除 `https://target/api/v1/user/create` 和 `https://target/api/v2/user/create` 或任何其他版本（`v3`、`v4` 等），我们可以使用 `https://target/api/v.*/user/create$`。在前面的正则表达式中：

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

由于许多技术栈会产生大量误报，请求头模糊测试默认处于禁用状态。启用请求头模糊测试时，您必须指定要包含在模糊测试中的请求头列表。

默认配置文件中的每个配置文件都有一个 `GeneralFuzzingCheck` 条目。此检查执行请求头模糊测试。在 `Configuration` 部分下，您必须更改 `HeaderFuzzing` 和 `Headers` 设置以启用请求头模糊测试。

此代码片段显示了禁用请求头模糊测试的 `Quick-10` 配置文件的默认配置：

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

`HeaderFuzzing` 是一个布尔值，用于打开和关闭请求头模糊测试。默认设置为 `false` 表示关闭。要打开请求头模糊测试，请将此设置更改为 `true`：

```yaml
    - Name: GeneralFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
        HeaderFuzzing: true
        Headers:
```

`Headers` 是要进行模糊测试的请求头列表。只有列出的请求头才会被模糊测试。要模糊测试您的 API 使用的请求头，请使用语法 `- Name: HeaderName` 为其添加条目。例如，要模糊测试自定义请求头 `X-Custom`，请添加 `- Name: X-Custom`：

```yaml
    - Name: GeneralFuzzingCheck
      Configuration:
        FuzzingCount: 10
        UnicodeFuzzing: true
        HeaderFuzzing: true
        Headers:
          - Name: X-Custom
```

现在您已有一个用于模糊测试请求头 `X-Custom`的配置。使用相同的表示法列出其他请求头：

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

根据需要为每个配置文件重复此配置。
