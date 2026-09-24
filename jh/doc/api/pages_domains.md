---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Pages 域名 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[极狐GitLab Pages 域名](../user/project/pages/custom_domains_ssl_tls_certification/_index.md)。

必须启用极狐GitLab Pages 功能才能使用这些端点。了解更多关于[管理](../administration/pages/_index.md)和[使用](../user/project/pages/_index.md)此功能的信息。

<a id="list-all-pages-domains"></a>

## 列出所有 Pages 域名

列出实例上的所有 Pages 域名。

前提条件：

- 你必须拥有实例的管理员访问权限。

```plaintext
GET /pages/domains
```

支持的属性：

| 属性     | 类型   | 是否必需 | 描述                                       |
| -------- | ------ | -------- | ------------------------------------------ |
| `domain` | 字符串 | 否       | 用于筛选的极狐GitLab Pages 站点域名。 |

若成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                              | 类型     | 描述                                         |
| --------------------------------- | -------- | -------------------------------------------- |
| `domain`                          | 字符串   | 极狐GitLab Pages 站点的自定义域名。             |
| `url`                             | 字符串   | Pages 站点的完整 URL，包括协议。              |
| `project_id`                      | 整数     | 与该 Pages 域名关联的极狐GitLab 项目 ID。     |
| `verified`                        | 布尔值   | 指示域名是否已验证。                         |
| `verification_code`               | 字符串   | 用于验证域名所有权的唯一记录。               |
| `enabled_until`                   | 日期     | 域名启用的截止日期。随着域名重新验证，该值会定期更新。 |
| `auto_ssl_enabled`                | 布尔值   | 指示是否为此域名启用了 SSL 证书自动生成功能。   |
| `certificate_expiration`          | 对象     | SSL 证书过期信息。                           |
| `certificate_expiration.expired`  | 布尔值   | 指示 SSL 证书是否已过期。                     |
| `certificate_expiration.expiration` | 日期    | SSL 证书的过期日期和时间。                   |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/pages/domains"
```

示例响应：

```json
[
  {
    "domain": "ssl.domain.example",
    "url": "https://ssl.domain.example",
    "project_id": 1337,
    "verified": true,
    "verification_code": "1234567890abcdef",
    "enabled_until": "2020-04-12T14:32:00.000Z",
    "auto_ssl_enabled": false,
    "certificate": {
      "expired": false,
      "expiration": "2020-04-12T14:32:00.000Z"
    }
  }
]
```

<a id="list-all-pages-domains-in-a-project"></a>

## 列出项目中的所有 Pages 域名

列出指定项目中的所有 Pages 域名。用户必须拥有查看 Pages 域名的权限。

```plaintext
GET /projects/:id/pages/domains
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述                              |
| ---- | -------------- | -------- | ---------------------------------- |
| `id` | 整数或字符串   | 是       | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |

若成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型     | 描述                                         |
| ------------------------------ | -------- | -------------------------------------------- |
| `domain`                       | 字符串   | 极狐GitLab Pages 站点的自定义域名。             |
| `url`                          | 字符串   | Pages 站点的完整 URL，包括协议。              |
| `verified`                     | 布尔值   | 指示域名是否已验证。                         |
| `verification_code`            | 字符串   | 用于验证域名所有权的唯一记录。               |
| `enabled_until`                | 日期     | 域名启用的截止日期。随着域名重新验证，该值会定期更新。 |
| `auto_ssl_enabled`             | 布尔值   | 指示是否为此域名启用了 SSL 证书自动生成功能。   |
| `certificate`                  | 对象     | SSL 证书信息。                               |
| `certificate.subject`          | 字符串   | SSL 证书的主题，通常包含域名信息。            |
| `certificate.expired`          | 日期     | 指示 SSL 证书是否已过期（true）或仍然有效（false）。 |
| `certificate.certificate`      | 字符串   | PEM 格式的完整 SSL 证书。                     |
| `certificate.certificate_text` | 日期     | SSL 证书的人类可读文本表示，包括颁发者、有效期、主题和其他证书信息。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains"
```

示例响应：

```json
[
  {
    "domain": "www.domain.example",
    "url": "http://www.domain.example",
    "verified": true,
    "verification_code": "1234567890abcdef",
    "enabled_until": "2020-04-12T14:32:00.000Z",
    "auto_ssl_enabled": false,
  },
  {
    "domain": "ssl.domain.example",
    "url": "https://ssl.domain.example",
    "verified": true,
    "verification_code": "1234567890abcdef",
    "enabled_until": "2020-04-12T14:32:00.000Z",
    "auto_ssl_enabled": false,
    "certificate": {
      "subject": "/O=Example, Inc./OU=Example Origin CA/CN=Example Origin Certificate",
      "expired": false,
      "certificate": "-----BEGIN CERTIFICATE-----\n … \n-----END CERTIFICATE-----",
      "certificate_text": "Certificate:\n … \n"
    }
  }
]
```

<a id="retrieve-a-pages-domain"></a>

## 获取 Pages 域名

从指定项目中获取一个 Pages 域名。用户必须拥有查看 Pages 域名的权限。

```plaintext
GET /projects/:id/pages/domains/:domain
```

支持的属性：

| 属性     | 类型           | 是否必需 | 描述                              |
| -------- | -------------- | -------- | ---------------------------------- |
| `id`     | 整数或字符串   | 是       | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `domain` | 字符串         | 是       | 用户指定的自定义域名              |

若成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型     | 描述                                         |
| ------------------------------ | -------- | -------------------------------------------- |
| `domain`                       | 字符串   | 极狐GitLab Pages 站点的自定义域名。             |
| `url`                          | 字符串   | Pages 站点的完整 URL，包括协议。              |
| `verified`                     | 布尔值   | 指示域名是否已验证。                         |
| `verification_code`            | 字符串   | 用于验证域名所有权的唯一记录。               |
| `enabled_until`                | 日期     | 域名启用的截止日期。随着域名重新验证，该值会定期更新。 |
| `auto_ssl_enabled`             | 布尔值   | 指示是否为此域名启用了 SSL 证书自动生成功能。   |
| `certificate`                  | 对象     | SSL 证书信息。                               |
| `certificate.subject`          | 字符串   | SSL 证书的主题，通常包含域名信息。            |
| `certificate.expired`          | 日期     | 指示 SSL 证书是否已过期（true）或仍然有效（false）。 |
| `certificate.certificate`      | 字符串   | PEM 格式的完整 SSL 证书。                     |
| `certificate.certificate_text` | 日期     | SSL 证书的人类可读文本表示，包括颁发者、有效期、主题和其他证书信息。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains/ssl.domain.example"
```

示例响应：

```json
{
  "domain": "ssl.domain.example",
  "url": "https://ssl.domain.example",
  "verified": true,
  "verification_code": "1234567890abcdef",
  "enabled_until": "2020-04-12T14:32:00.000Z",
  "auto_ssl_enabled": false,
  "certificate": {
    "subject": "/O=Example, Inc./OU=Example Origin CA/CN=Example Origin Certificate",
    "expired": false,
    "certificate": "-----BEGIN CERTIFICATE-----\n … \n-----END CERTIFICATE-----",
    "certificate_text": "Certificate:\n … \n"
  }
}
```

<a id="create-new-pages-domain"></a>

## 创建新的 Pages 域名

在指定项目中创建一个 Pages 域名。用户必须拥有创建 Pages 域名的权限。

```plaintext
POST /projects/:id/pages/domains
```

支持的属性：

| 属性               | 类型           | 是否必需 | 描述                              |
| ------------------ | -------------- | -------- | ---------------------------------- |
| `id`               | 整数或字符串   | 是       | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `domain`           | 字符串         | 是       | 用户指定的自定义域名              |
| `auto_ssl_enabled` | 布尔值        | 否       | 为自定义域名启用 SSL 证书自动生成功能。 |
| `certificate`      | 文件/字符串    | 否       | PEM 格式的证书，中间证书按从特定到最不特定的顺序排列。 |
| `key`              | 文件/字符串    | 否       | PEM 格式的证书密钥。             |

若成功，返回 [`201`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型     | 描述                                         |
| ------------------------------ | -------- | -------------------------------------------- |
| `domain`                       | 字符串   | 极狐GitLab Pages 站点的自定义域名。             |
| `url`                          | 字符串   | Pages 站点的完整 URL，包括协议。              |
| `verified`                     | 布尔值   | 指示域名是否已验证。                         |
| `verification_code`            | 字符串   | 用于验证域名所有权的唯一记录。               |
| `enabled_until`                | 日期     | 域名启用的截止日期。随着域名重新验证，该值会定期更新。 |
| `auto_ssl_enabled`             | 布尔值   | 指示是否为此域名启用了 SSL 证书自动生成功能。   |
| `certificate`                  | 对象     | SSL 证书信息。                               |
| `certificate.subject`          | 字符串   | SSL 证书的主题，通常包含域名信息。            |
| `certificate.expired`          | 日期     | 指示 SSL 证书是否已过期（true）或仍然有效（false）。 |
| `certificate.certificate`      | 字符串   | PEM 格式的完整 SSL 证书。                     |
| `certificate.certificate_text` | 日期     | SSL 证书的人类可读文本表示，包括颁发者、有效期、主题和其他证书信息。 |

示例请求：

使用 `.pem` 文件创建新的 Pages 域名（带证书）：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains" \
  --form "domain=ssl.domain.example" \
  --form "certificate=@/path/to/cert.pem" \
  --form "key=@/path/to/key.pem"
```

使用包含证书的变量创建新的 Pages 域名：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains" \
  --form "domain=ssl.domain.example" \
  --form "certificate=$CERT_PEM" \
  --form "key=$KEY_PEM"
```

示例响应：

```json
{
  "domain": "ssl.domain.example",
  "url": "https://ssl.domain.example",
  "auto_ssl_enabled": true,
  "certificate": {
    "subject": "/O=Example, Inc./OU=Example Origin CA/CN=Example Origin Certificate",
    "expired": false,
    "certificate": "-----BEGIN CERTIFICATE-----\n … \n-----END CERTIFICATE-----",
    "certificate_text": "Certificate:\n … \n"
  }
}
```

<a id="update-pages-domain"></a>

## 更新 Pages 域名

更新项目中指定的 Pages 域名。用户必须拥有修改现有 Pages 域名的权限。

```plaintext
PUT /projects/:id/pages/domains/:domain
```

支持的属性：

| 属性               | 类型           | 是否必需 | 描述                              |
| ------------------ | -------------- | -------- | ---------------------------------- |
| `id`               | 整数或字符串   | 是       | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `domain`           | 字符串         | 是       | 用户指定的自定义域名              |
| `auto_ssl_enabled` | 布尔值        | 否       | 为自定义域名启用 SSL 证书自动生成功能。 |
| `certificate`      | 文件/字符串    | 否       | PEM 格式的证书，中间证书按从特定到最不特定的顺序排列。 |
| `key`              | 文件/字符串    | 否       | PEM 格式的证书密钥。             |

若成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型     | 描述                                         |
| ------------------------------ | -------- | -------------------------------------------- |
| `domain`                       | 字符串   | 极狐GitLab Pages 站点的自定义域名。             |
| `url`                          | 字符串   | Pages 站点的完整 URL，包括协议。              |
| `verified`                     | 布尔值   | 指示域名是否已验证。                         |
| `verification_code`            | 字符串   | 用于验证域名所有权的唯一记录。               |
| `enabled_until`                | 日期     | 域名启用的截止日期。随着域名重新验证，该值会定期更新。 |
| `auto_ssl_enabled`             | 布尔值   | 指示是否为此域名启用了 SSL 证书自动生成功能。   |
| `certificate`                  | 对象     | SSL 证书信息。                               |
| `certificate.subject`          | 字符串   | SSL 证书的主题，通常包含域名信息。            |
| `certificate.expired`          | 日期     | 指示 SSL 证书是否已过期（true）或仍然有效（false）。 |
| `certificate.certificate`      | 字符串   | PEM 格式的完整 SSL 证书。                     |
| `certificate.certificate_text` | 日期     | SSL 证书的人类可读文本表示，包括颁发者、有效期、主题和其他证书信息。 |

<a id="adding-certificate"></a>

### 添加证书

使用 `.pem` 文件为 Pages 域名添加证书：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains/ssl.domain.example" \
  --form "certificate=@/path/to/cert.pem" \
  --form "key=@/path/to/key.pem"
```

使用包含证书的变量为 Pages 域名添加证书：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains/ssl.domain.example" \
  --form "certificate=$CERT_PEM" \
  --form "key=$KEY_PEM"
```

示例响应：

```json
{
  "domain": "ssl.domain.example",
  "url": "https://ssl.domain.example",
  "auto_ssl_enabled": false,
  "certificate": {
    "subject": "/O=Example, Inc./OU=Example Origin CA/CN=Example Origin Certificate",
    "expired": false,
    "certificate": "-----BEGIN CERTIFICATE-----\n … \n-----END CERTIFICATE-----",
    "certificate_text": "Certificate:\n … \n"
  }
}
```

<a id="removing-certificate"></a>

### 移除证书

要移除附加到 Pages 域名的 SSL 证书，请运行：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains/ssl.domain.example" \
  --form "certificate=" \
  --form "key="
```

示例响应：

```json
{
  "domain": "ssl.domain.example",
  "url": "https://ssl.domain.example",
  "auto_ssl_enabled": false
}
```

<a id="verify-pages-domain"></a>

## 验证 Pages 域名

{{< history >}}

- 于极狐GitLab 17.7 引入。

{{< /history >}}

验证项目中指定的 Pages 域名。用户必须拥有更新 Pages 域名的权限。

```plaintext
PUT /projects/:id/pages/domains/:domain/verify
```

支持的属性：

| 属性     | 类型           | 是否必需 | 描述                              |
| -------- | -------------- | -------- | ---------------------------------- |
| `id`     | 整数或字符串   | 是       | 项目 ID 或 URL 编码的项目路径     |
| `domain` | 字符串         | 是       | 要验证的自定义域名                |

若成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型     | 描述                                         |
| ------------------------------ | -------- | -------------------------------------------- |
| `domain`                       | 字符串   | 极狐GitLab Pages 站点的自定义域名。             |
| `url`                          | 字符串   | Pages 站点的完整 URL，包括协议。              |
| `verified`                     | 布尔值   | 指示域名是否已验证。                         |
| `verification_code`            | 字符串   | 用于验证域名所有权的唯一记录。               |
| `enabled_until`                | 日期     | 域名启用的截止日期。随着域名重新验证，该值会定期更新。 |
| `auto_ssl_enabled`             | 布尔值   | 指示是否为此域名启用了 SSL 证书自动生成功能。   |
| `certificate`                  | 对象     | SSL 证书信息。                               |
| `certificate.subject`          | 字符串   | SSL 证书的主题，通常包含域名信息。            |
| `certificate.expired`          | 日期     | 指示 SSL 证书是否已过期（true）或仍然有效（false）。 |
| `certificate.certificate`      | 字符串   | PEM 格式的完整 SSL 证书。                     |
| `certificate.certificate_text` | 日期     | SSL 证书的人类可读文本表示，包括颁发者、有效期、主题和其他证书信息。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains/ssl.domain.example/verify"
```

示例响应：

```json
{
  "domain": "ssl.domain.example",
  "url": "https://ssl.domain.example",
  "auto_ssl_enabled": false,
  "verified": true,
  "verification_code": "1234567890abcdef",
  "enabled_until": "2020-04-12T14:32:00.000Z"
}
```

<a id="delete-pages-domain"></a>

## 删除 Pages 域名

删除项目中指定的 Pages 域名。

```plaintext
DELETE /projects/:id/pages/domains/:domain
```

支持的属性：

| 属性     | 类型           | 是否必需 | 描述                              |
| -------- | -------------- | -------- | ---------------------------------- |
| `id`     | 整数或字符串   | 是       | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `domain` | 字符串         | 是       | 用户指定的自定义域名              |

若成功，预期会返回一个内容为空的 `204 No Content` HTTP 响应。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/pages/domains/ssl.domain.example"
```