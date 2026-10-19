---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "故障排除极狐GitLab REST API。包括状态码、错误响应、垃圾信息检测和反向代理问题。"
title: 故障排除 REST API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 REST API 时，您可能会遇到问题。

要进行故障排除，请参阅 REST API 状态码。包含 HTTP 响应头和退出代码也可能有所帮助。

<a id="status-codes"></a>

## 状态码

极狐GitLab REST API 会根据上下文和操作，在每个响应中返回一个状态码。请求返回的状态码在故障排除时可能很有用。

下表概述了 API 的一般行为。

| 请求类型            | 描述 |
|:------------------------|:------------|
| `GET`                   | 访问一个或多个资源，并将结果以 JSON 形式返回。 |
| `POST`                  | 如果资源创建成功，则返回 `201 Created`，并将新创建的资源以 JSON 形式返回。 |
| `GET` / `PUT` / `PATCH` | 如果资源访问或修改成功，则返回 `200 OK`。（修改后的）结果以 JSON 形式返回。 |
| `DELETE`                | 如果资源删除成功，则返回 `204 No Content`；如果资源已计划删除，则返回 `202 Accepted`。 |

下表显示了 API 请求可能返回的代码。

| 返回值             | 描述 |
|:--------------------------|:------------|
| `200 OK`                  | `GET`、`PUT`、`PATCH` 或 `DELETE` 请求成功，资源本身以 JSON 形式返回。 |
| `201 Created`             | `POST` 请求成功，资源以 JSON 形式返回。 |
| `202 Accepted`            | `GET`、`PUT` 或 `DELETE` 请求成功，资源已计划进行处理。 |
| `204 No Content`          | 服务器已成功完成请求，响应负载正文中没有其他内容可发送。 |
| `301 Moved Permanently`   | 资源已永久移动到 `Location` 响应头指定的 URL。 |
| `304 Not Modified`        | 自上次请求以来，资源未被修改。 |
| `400 Bad Request`         | API 请求缺少必需属性。例如，未提供议题的标题。 |
| `401 Unauthorized`        | 用户未通过身份验证。需要有效的[用户令牌](authentication.md)。 |
| `403 Forbidden`           | 不允许该请求。例如，不允许该用户删除项目。 |
| `404 Not Found`           | 无法访问资源。例如，找不到资源的 ID，或用户无权访问该资源。 |
| `405 Method Not Allowed`  | 不支持该请求。 |
| `409 Conflict`            | 已存在冲突的资源。 |
| `412 Precondition Failed` | 请求被拒绝。如果在尝试删除资源时提供了 `If-Unmodified-Since` 请求头，而该资源在此期间已被修改，就可能发生这种情况。 |
| `422 Unprocessable`       | 无法处理该实体。 |
| `429 Too Many Requests`   | 用户超出了[应用程序速率限制](../../administration/instance_limits.md#rate-limits)。请等待 `Retry-After` 响应头中给出的时长后再重试。对于 JihuLab.com，请参阅 [JihuLab.com 速率限制](../../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)。 |
| `500 Server Error`        | 处理请求时，服务器上出现了问题。 |
| `503 Service Unavailable` | 由于服务器暂时过载，服务器无法处理该请求。 |

<a id="status-code-400"></a>

### 状态码 400

使用 API 时，您可能会遇到验证错误，此时 API 会返回 HTTP `400` 错误。

此类错误出现在以下情况：

- API 请求缺少必需属性（例如，未提供议题的标题）。
- 某个属性未通过验证（例如，用户个人简介过长）。

当缺少某个属性时，您会收到类似以下内容：

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
{
    "message":"400 (Bad request) \"title\" not given"
}
```

当发生验证错误时，错误消息会有所不同。它们包含验证错误的所有详细信息：

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
{
    "message": {
        "bio": [
            "is too long (maximum is 255 characters)"
        ]
    }
}
```

这使错误消息更易于机器读取。其格式可描述如下：

```json
{
    "message": {
        "<property-name>": [
            "<error-message>",
            "<error-message>",
            ...
        ],
        "<embed-entity>": {
            "<property-name>": [
                "<error-message>",
                "<error-message>",
                ...
            ],
        }
    }
}
```

<a id="include-http-response-headers"></a>

## 包含 HTTP 响应头

HTTP 响应头可在故障排除时提供额外信息。

要在响应中包含 HTTP 响应头，请使用 `--include` 选项：

```shell
curl --request GET \
  --include \
  --url "https://gitlab.example.com/api/v4/projects"
HTTP/2 200
...
```

<a id="include-http-exit-code"></a>

## 包含 HTTP 退出代码

API 响应中的 HTTP 退出代码可在故障排除时提供额外信息。

要包含 HTTP 退出代码，请使用 `--fail` 选项：

```shell
curl --request GET \
  --fail \
  --url "https://gitlab.example.com/api/v4/does-not-exist"
curl: (22) The requested URL returned error: 404
```

<a id="requests-detected-as-spam"></a>

## 被检测为垃圾信息的请求

REST API 请求可能会被检测为垃圾信息。如果某个请求被检测为垃圾信息，并且：

- 未配置 CAPTCHA 服务，则会返回错误响应。例如：

  ```json
  {"message":{"error":"Your snippet has been recognized as spam and has been discarded."}}
  ```

- 已配置 CAPTCHA 服务，您会收到包含以下内容的响应：
  - `needs_captcha_response` 设置为 `true`。
  - 设置了 `spam_log_id` 和 `captcha_site_key` 字段。

  例如：

  ```json
  {"needs_captcha_response":true,"spam_log_id":42,"captcha_site_key":"REDACTED","message":{"error":"Your snippet has been recognized as spam. Please, change the content or solve the reCAPTCHA to proceed."}}
  ```

  - 使用 `captcha_site_key` 通过相应的 CAPTCHA API 获取 CAPTCHA 响应值。
    仅支持 [Google reCAPTCHA v2](https://developers.google.com/recaptcha/docs/display)。
  - 设置 `X-GitLab-Captcha-Response` 和 `X-GitLab-Spam-Log-Id` 请求头后重新提交请求。

    ```shell
    export CAPTCHA_RESPONSE="<CAPTCHA response obtained from CAPTCHA service>"
    export SPAM_LOG_ID="<spam_log_id obtained from initial REST response>"

    curl --request POST \
      --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
      --header "X-GitLab-Captcha-Response: $CAPTCHA_RESPONSE" \
      --header "X-GitLab-Spam-Log-Id: $SPAM_LOG_ID" \
      --url "https://gitlab.example.com/api/v4/snippets?title=Title&file_name=FileName&content=Content&visibility=public"
    ```

<a id="error-404-not-found-when-using-a-reverse-proxy"></a>

## 错误：使用反向代理时出现 `404 Not Found`

如果您的极狐GitLab 实例使用反向代理，在使用极狐GitLab [编辑器扩展](../../editor_extensions/_index.md)、GitLab CLI 或使用 URL 编码参数的 API 调用时，您可能会看到 `404 Not Found` 错误。

当您的反向代理在将参数传递给极狐GitLab 之前解码 `/`、`?` 和 `@` 等字符时，就会出现此问题。

要解决此问题，请编辑反向代理的配置：

- 在 `VirtualHost` 部分中，添加 `AllowEncodedSlashes NoDecode`。
- 在 `Location` 部分中，编辑 `ProxyPass` 并添加 `nocanon` 标志。

例如：

{{< tabs >}}

{{< tab title="Apache configuration" >}}

```plaintext
<VirtualHost *:443>
  ServerName git.example.com

  SSLEngine on
  SSLCertificateFile     /etc/letsencrypt/live/git.example.com/fullchain.pem
  SSLCertificateKeyFile  /etc/letsencrypt/live/git.example.com/privkey.pem
  SSLVerifyClient None

  ProxyRequests     Off
  ProxyPreserveHost On
  AllowEncodedSlashes NoDecode

  <Location />
     ProxyPass http://127.0.0.1:8080/ nocanon
     ProxyPassReverse http://127.0.0.1:8080/
     Order deny,allow
     Allow from all
  </Location>
</VirtualHost>
```

{{< /tab >}}

{{< tab title="NGINX configuration" >}}

```plaintext
server {
  listen       80;
  server_name  gitlab.example.com;
  location / {
     proxy_pass    http://ip:port;
     proxy_set_header        X-Forwarded-Proto $scheme;
     proxy_set_header        Host              $http_host;
     proxy_set_header        X-Real-IP         $remote_addr;
     proxy_set_header        X-Forwarded-For   $proxy_add_x_forwarded_for;
     proxy_read_timeout    300;
     proxy_connect_timeout 300;
  }
}
```

{{< /tab >}}

{{< /tabs >}}

有关更多信息，请参阅[议题 18775](https://gitlab.com/gitlab-org/gitlab/-/issues/18775)。

<a id="support-knowledge-base"></a>

## 支持知识库

如果您仍然遇到问题，请参阅[极狐GitLab 支持知识库](https://gitlab.cn/support)。
