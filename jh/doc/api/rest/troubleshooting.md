---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "Troubleshooting the GitLab REST API. Includes status codes, error responses, spam detection, and reverse proxy issues."
title: 排查 REST API 问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在使用 REST API 时，你可能会遇到问题。

要进行排查，请参考 REST API 状态码。包含 HTTP 响应头和退出码也可能会有所帮助。

<a id="status-codes"></a>

## 状态码

极狐GitLab REST API 根据上下文和操作返回一个状态码。请求返回的状态码在排查问题时非常有用。

下表概述了 API 功能通常如何运行。

| 请求类型            | 描述 |
|:------------------------|:------------|
| `GET`                   | 访问一个或多个资源并以 JSON 格式返回结果。 |
| `POST`                  | 如果资源成功创建，返回 `201 Created` 并以 JSON 格式返回新创建的资源。 |
| `GET` / `PUT` / `PATCH` | 如果资源成功访问或修改，返回 `200 OK`。(修改后的) 结果以 JSON 格式返回。 |
| `DELETE`                | 如果资源成功删除，返回 `204 No Content`，或者如果资源计划删除，返回 `202 Accepted`。 |

下表显示了 API 请求可能返回的返回码。

| 返回值             | 描述 |
|:--------------------------|:------------|
| `200 OK`                  | `GET`、`PUT`、`PATCH` 或 `DELETE` 请求成功，并且资源本身以 JSON 格式返回。 |
| `201 Created`             | `POST` 请求成功，并且资源以 JSON 格式返回。 |
| `202 Accepted`            | `GET`、`PUT` 或 `DELETE` 请求成功，并且资源已安排处理。 |
| `204 No Content`          | 服务器已成功完成请求，并且没有额外的内容在响应体中发送。 |
| `301 Moved Permanently`   | 资源已永久移动到 `Location` 头给出的 URL。 |
| `304 Not Modified`        | 资源自上次请求以来未被修改。 |
| `400 Bad Request`         | API 请求缺少必需属性。例如，未提供议题的标题。 |
| `401 Unauthorized`        | 用户未经身份验证。需要有效的[用户令牌](authentication.md)。 |
| `403 Forbidden`           | 请求不被允许。例如，用户不被允许删除项目。 |
| `404 Not Found`           | 无法访问资源。例如，未找到资源的 ID，或用户无权访问该资源。 |
| `405 Method Not Allowed`  | 请求不被支持。 |
| `409 Conflict`            | 冲突的资源已存在。 |
| `412 Precondition Failed` | 请求被拒绝。如果在尝试删除资源时提供了 `If-Unmodified-Since` 头，而资源在此期间被修改，则可能发生这种情况。 |
| `422 Unprocessable`       | 实体无法处理。 |
| `429 Too Many Requests`   | 用户超过了[应用程序速率限制](../../administration/instance_limits.md#rate-limits)。 |
| `500 Server Error`        | 在处理请求时，服务器上出现了问题。 |
| `503 Service Unavailable` | 服务器无法处理请求，因为服务器暂时过载。 |

<a id="status-code-400"></a>

### 状态码 400

当使用 API 时，你可能会遇到验证错误，此时 API 会返回 HTTP `400` 错误。

此类错误出现在以下情况：

- API 请求缺少必需属性（例如，未提供议题的标题）。
- 属性未通过验证（例如，用户个人简介太长）。

当缺少属性时，你会收到类似以下响应：

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
{
    "message":"400 (Bad request) \"title\" not given"
}
```

当发生验证错误时，错误消息不同。它们包含所有验证错误的详细信息：

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

这使得错误消息更易于机器读取。格式可以描述如下：

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

HTTP 响应头可以在排查问题时提供额外信息。

要在响应中包含 HTTP 响应头，请使用 `--include` 选项：

```shell
curl --request GET \
  --include \
  --url "https://gitlab.example.com/api/v4/projects"
HTTP/2 200
...
```

<a id="include-http-exit-code"></a>

## 包含 HTTP 退出码

API 响应中的 HTTP 退出码可以在排查问题时提供额外信息。

要包含 HTTP 退出码，请添加 `--fail` 选项：

```shell
curl --request GET \
  --fail \
  --url "https://gitlab.example.com/api/v4/does-not-exist"
curl: (22) The requested URL returned error: 404
```

<a id="requests-detected-as-spam"></a>

## 被检测为垃圾信息的请求

REST API 请求可能被检测为垃圾信息。如果请求被检测为垃圾信息并且：

- 未配置 CAPTCHA 服务，则返回错误响应。例如：

  ```json
  {"message":{"error":"Your snippet has been recognized as spam and has been discarded."}}
  ```

- 如果配置了 CAPTCHA 服务，你会收到一个响应，其中：
  - `needs_captcha_response` 设置为 `true`。
  - `spam_log_id` 和 `captcha_site_key` 字段已设置。

  例如：

  ```json
  {"needs_captcha_response":true,"spam_log_id":42,"captcha_site_key":"REDACTED","message":{"error":"Your snippet has been recognized as spam. Please, change the content or solve the reCAPTCHA to proceed."}}
  ```

  - 使用 `captcha_site_key` 通过适当的 CAPTCHA API 获取 CAPTCHA 响应值。仅支持 [Google reCAPTCHA v2](https://developers.google.com/recaptcha/docs/display)。
  - 将请求与已设置的 `X-GitLab-Captcha-Response` 和 `X-GitLab-Spam-Log-Id` 头一起重新提交。

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

## 使用反向代理时出现 `404 Not Found` 错误

如果您的极狐GitLab 实例使用了反向代理，您在使用极狐GitLab [编辑器扩展](../../editor_extensions/_index.md)、GitLab CLI 或使用 URL 编码参数的 API 调用时可能会看到 `404 Not Found` 错误。

当您的反向代理在将参数传递给极狐GitLab 之前解码诸如 `/`、`?` 和 `@` 之类的字符时，会出现此问题。

要解决此问题，请编辑反向代理的配置：

- 在 `VirtualHost` 节中，添加 `AllowEncodedSlashes NoDecode`。
- 在 `Location` 节中，编辑 `ProxyPass` 并添加 `nocanon` 标志。

例如：

{{< tabs >}}

{{< tab title="Apache 配置" >}}

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

{{< tab title="NGINX 配置" >}}

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

<a id="support-knowledge-base"></a>

## 支持知识库

如果您仍然遇到问题，请参见[极狐GitLab 支持知识库](https://support.jihulab.com/hc/en-us/)。

