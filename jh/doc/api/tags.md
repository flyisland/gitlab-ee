---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for Git tags in GitLab.
title: 标签 API
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

使用此 API 管理 [Git 标签](../user/project/repository/tags/_index.md)。此 API 也返回已签名标签的 X.509 签名信息。

<a id="list-all-project-repository-tags"></a>

## 列出所有项目仓库标签

{{< history >}}

- `created_at` 响应属性在极狐GitLab 16.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/451011)。

{{< /history >}}

列出一个项目的所有仓库标签，按更新日期和时间降序排序。

> [!note]
> 如果仓库是公开的，则不需要身份验证 (`--header "PRIVATE-TOKEN: <your_access_token>"`)。

```plaintext
GET /projects/:id/repository/tags
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | 整数或字符串       | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by`   | 字符串             | 否       | 按 `name`、`updated` 或 `version` 排序返回标签。`version` 按语义版本号排序。默认为 `updated`。 |
| `page`       | 整数               | 否       | 分页的当前页码。默认为 `1`。 |
| `page_token` | 字符串             | 否       | 用于开始分页的标签名称。用于键集分页。 |
| `search`     | 字符串             | 否       | 返回与搜索条件匹配的标签列表。你可以使用 `^term` 和 `term$` 查找以 `term` 开头和结尾的标签。不支持其他正则表达式。 |
| `sort`       | 字符串             | 否       | 返回按 `asc` 或 `desc` 顺序排序的标签。默认为 `desc`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                        | 类型     | 描述 |
|--------------------------|---------|-------------|
| `commit`                 | 对象    | 与标签关联的提交信息。 |
| `commit.author_email`    | 字符串  | 提交作者的电子邮件地址。 |
| `commit.author_name`     | 字符串  | 提交作者的名称。 |
| `commit.authored_date`   | 字符串  | 创作提交的日期，采用 ISO 8601 格式。 |
| `commit.committed_date`  | 字符串  | 提交的日期，采用 ISO 8601 格式。 |
| `commit.committer_email` | 字符串  | 提交者的电子邮件地址。 |
| `commit.committer_name`  | 字符串  | 提交者的名称。 |
| `commit.created_at`      | 字符串  | 创建提交的日期，采用 ISO 8601 格式。 |
| `commit.id`              | 字符串  | 完整的提交 SHA。 |
| `commit.message`         | 字符串  | 提交信息。 |
| `commit.parent_ids`      | 数组    | 父提交 SHA 的数组。 |
| `commit.short_id`        | 字符串  | 短的提交 SHA。 |
| `commit.title`           | 字符串  | 提交的标题。 |
| `created_at`             | 字符串  | 创建标签的日期，采用 ISO 8601 格式。 |
| `message`                | 字符串  | 标签信息。 |
| `name`                   | 字符串  | 标签的名称。 |
| `protected`              | 布尔值  | 如果为 `true`，则该标签受保护。 |
| `release`                | 对象    | 与标签关联的发布信息。 |
| `release.description`    | 字符串  | 发布的描述。 |
| `release.tag_name`       | 字符串  | 发布的标签名称。 |
| `target`                 | 字符串  | 标签指向的 SHA。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/5/repository/tags"
```

示例响应：

```json
[
  {
    "commit": {
      "id": "2695effb5807a22ff3d138d593fd856244e155e7",
      "short_id": "2695effb",
      "title": "Initial commit",
      "created_at": "2017-07-26T11:08:53.000+02:00",
      "parent_ids": [
        "2a4b78934375d7f53875269ffd4f45fd83a84ebe"
      ],
      "message": "Initial commit",
      "author_name": "John Smith",
      "author_email": "john@example.com",
      "authored_date": "2012-05-28T04:42:42-07:00",
      "committer_name": "Jack Smith",
      "committer_email": "jack@example.com",
      "committed_date": "2012-05-28T04:42:42-07:00"
    },
    "release": {
      "tag_name": "1.0.0",
      "description": "Amazing release. Wow"
    },
    "name": "v1.0.0",
    "target": "2695effb5807a22ff3d138d593fd856244e155e7",
    "message": null,
    "protected": true,
    "created_at": "2017-07-26T11:08:53.000+02:00"
  }
]
```

<a id="retrieve-a-single-repository-tag"></a>

## 获取单个仓库标签

{{< history >}}

- `created_at` 响应属性在极狐GitLab 16.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/451011)。

{{< /history >}}

获取具有指定名称的仓库标签。如果仓库是公开的，此端点无需身份验证即可访问。

```plaintext
GET /projects/:id/repository/tags/:tag_name
```

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串       | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串             | 是      | 标签的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                        | 类型     | 描述 |
|--------------------------|---------|-------------|
| `commit`                 | 对象    | 与标签关联的提交信息。 |
| `commit.author_email`    | 字符串  | 提交作者的电子邮件地址。 |
| `commit.author_name`     | 字符串  | 提交作者的名称。 |
| `commit.authored_date`   | 字符串  | 创作提交的日期，采用 ISO 8601 格式。 |
| `commit.committed_date`  | 字符串  | 提交的日期，采用 ISO 8601 格式。 |
| `commit.committer_email` | 字符串  | 提交者的电子邮件地址。 |
| `commit.committer_name`  | 字符串  | 提交者的名称。 |
| `commit.created_at`      | 字符串  | 创建提交的日期，采用 ISO 8601 格式。 |
| `commit.id`              | 字符串  | 完整的提交 SHA。 |
| `commit.message`         | 字符串  | 提交信息。 |
| `commit.parent_ids`      | 数组    | 父提交 SHA 的数组。 |
| `commit.short_id`        | 字符串  | 短的提交 SHA。 |
| `commit.title`           | 字符串  | 提交的标题。 |
| `created_at`             | 字符串  | 创建标签的日期，采用 ISO 8601 格式。 |
| `message`                | 字符串  | 标签信息。 |
| `name`                   | 字符串  | 标签的名称。 |
| `protected`              | 布尔值  | 如果为 `true`，则该标签受保护。 |
| `release`                | 对象    | 与标签关联的发布信息。 |
| `target`                 | 字符串  | 标签指向的 SHA。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/tags/v1.0.0"
```

示例响应：

```json
{
  "name": "v5.0.0",
  "message": null,
  "target": "60a8ff033665e1207714d6670fcd7b65304ec02f",
  "commit": {
    "id": "60a8ff033665e1207714d6670fcd7b65304ec02f",
    "short_id": "60a8ff03",
    "title": "Initial commit",
    "created_at": "2017-07-26T11:08:53.000+02:00",
    "parent_ids": [
      "f61c062ff8bcbdb00e0a1b3317a91aed6ceee06b"
    ],
    "message": "v5.0.0\n",
    "author_name": "Arthur Verschaeve",
    "author_email": "contact@arthurverschaeve.be",
    "authored_date": "2015-02-01T21:56:31.000+01:00",
    "committer_name": "Arthur Verschaeve",
    "committer_email": "contact@arthurverschaeve.be",
    "committed_date": "2015-02-01T21:56:31.000+01:00"
  },
  "release": null,
  "protected": false,
  "created_at": "2017-07-26T11:08:53.000+02:00"
}
```

<a id="create-a-new-tag"></a>

## 创建新标签

{{< history >}}

- `created_at` 响应属性在极狐GitLab 16.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/451011)。

{{< /history >}}

在仓库中创建一个指向所提供引用（ref）的新标签。

```plaintext
POST /projects/:id/repository/tags
```

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串       | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ref`      | 字符串             | 是      | 从提交 SHA、另一个标签名称或分支名称创建标签。 |
| `tag_name` | 字符串             | 是      | 标签的名称。 |
| `message`  | 字符串             | 否       | 创建附注标签。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                        | 类型     | 描述 |
|--------------------------|---------|-------------|
| `commit`                 | 对象    | 与标签关联的提交信息。 |
| `commit.author_email`    | 字符串  | 提交作者的电子邮件地址。 |
| `commit.author_name`     | 字符串  | 提交作者的名称。 |
| `commit.authored_date`   | 字符串  | 创作提交的日期，采用 ISO 8601 格式。 |
| `commit.committed_date`  | 字符串  | 提交的日期，采用 ISO 8601 格式。 |
| `commit.committer_email` | 字符串  | 提交者的电子邮件地址。 |
| `commit.committer_name`  | 字符串  | 提交者的名称。 |
| `commit.created_at`      | 字符串  | 创建提交的日期，采用 ISO 8601 格式。 |
| `commit.id`              | 字符串  | 完整的提交 SHA。 |
| `commit.message`         | 字符串  | 提交信息。 |
| `commit.parent_ids`      | 数组    | 父提交 SHA 的数组。 |
| `commit.short_id`        | 字符串  | 短的提交 SHA。 |
| `commit.title`           | 字符串  | 提交的标题。 |
| `created_at`             | 字符串  | 创建标签的日期，采用 ISO 8601 格式。 |
| `message`                | 字符串  | 标签信息。 |
| `name`                   | 字符串  | 标签的名称。 |
| `protected`              | 布尔值  | 如果为 `true`，则该标签受保护。 |
| `release`                | 对象    | 与标签关联的发布信息。 |
| `target`                 | 字符串  | 标签指向的 SHA。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/tags?tag_name=test&ref=main"
```

示例响应：

```json
{
  "commit": {
    "id": "2695effb5807a22ff3d138d593fd856244e155e7",
    "short_id": "2695effb",
    "title": "Initial commit",
    "created_at": "2017-07-26T11:08:53.000+02:00",
    "parent_ids": [
      "2a4b78934375d7f53875269ffd4f45fd83a84ebe"
    ],
    "message": "Initial commit",
    "author_name": "John Smith",
    "author_email": "john@example.com",
    "authored_date": "2012-05-28T04:42:42-07:00",
    "committer_name": "Jack Smith",
    "committer_email": "jack@example.com",
    "committed_date": "2012-05-28T04:42:42-07:00"
  },
  "release": null,
  "name": "v1.0.0",
  "target": "2695effb5807a22ff3d138d593fd856244e155e7",
  "message": null,
  "protected": false,
  "created_at": null
}
```

创建的标签类型决定 `created_at`、`target` 和 `message` 的内容：

- 对于附注标签：
  - `created_at` 包含标签创建的时间戳。
  - `message` 包含注释。
  - `target` 包含标签对象的 ID。
- 对于轻量标签：
  - `created_at` 为 null。
  - `message` 为 null。
  - `target` 包含提交 ID。

出错时返回状态码 `405` 并附带解释性错误信息。

<a id="delete-a-tag"></a>

## 删除标签

删除指定名称的仓库标签。

```plaintext
DELETE /projects/:id/repository/tags/:tag_name
```

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串       | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串             | 是      | 标签的名称。 |

<a id="retrieve-x509-signature-of-a-tag"></a>

## 获取标签的 X.509 签名

如果标签已签名，则获取其 [X.509 签名](../user/project/repository/signed_commits/x509.md)。未签名的标签返回 `404 Not Found` 响应。

```plaintext
GET /projects/:id/repository/tags/:tag_name/signature
```

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串       | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串             | 是      | 标签的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                                     | 类型     | 描述 |
|-------------------------------------------------------|---------|-------------|
| `signature_type`                                      | 字符串   | 签名类型 (`X509`)。 |
| `verification_status`                                 | 字符串   | 签名的验证状态。 |
| `x509_certificate`                                    | 对象     | X.509 证书信息。 |
| `x509_certificate.certificate_status`                 | 字符串   | 证书的状态。 |
| `x509_certificate.email`                              | 字符串   | 证书的电子邮件地址。 |
| `x509_certificate.id`                                 | 整数     | 证书的 ID。 |
| `x509_certificate.serial_number`                      | 整数     | 证书的序列号。 |
| `x509_certificate.subject`                            | 字符串   | 证书的主题。 |
| `x509_certificate.subject_key_identifier`             | 字符串   | 证书的主题密钥标识符。 |
| `x509_certificate.x509_issuer`                        | 对象     | 证书的颁发者信息。 |
| `x509_certificate.x509_issuer.crl_url`                | 字符串   | 证书吊销列表的 URL。 |
| `x509_certificate.x509_issuer.id`                     | 整数     | 颁发者的 ID。 |
| `x509_certificate.x509_issuer.subject`                | 字符串   | 颁发者的主题。 |
| `x509_certificate.x509_issuer.subject_key_identifier` | 字符串   | 颁发者的主题密钥标识符。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository/tags/v1.1.1/signature"
```

如果标签是 X.509 签名的，示例响应：

```json
{
  "signature_type": "X509",
  "verification_status": "unverified",
  "x509_certificate": {
    "id": 1,
    "subject": "CN=gitlab@example.org,OU=Example,O=World",
    "subject_key_identifier": "BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC",
    "email": "gitlab@example.org",
    "serial_number": 278969561018901340486471282831158785578,
    "certificate_status": "good",
    "x509_issuer": {
      "id": 1,
      "subject": "CN=PKI,OU=Example,O=World",
      "subject_key_identifier": "AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB",
      "crl_url": "http://example.com/pki.crl"
    }
  }
}
```

如果标签未签名，示例响应：

```json
{
  "message": "404 GPG Signature Not Found"
}
```