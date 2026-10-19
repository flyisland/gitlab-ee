---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Debian 群组发行版 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- [部署在功能标志后](../../administration/feature_flags/_index.md)，默认禁用。

{{< /history >}}

使用此 API 管理 [Debian 群组发行版](../../user/packages/debian_repository/_index.md)。此 API 受功能标志控制，默认禁用。要使用此 API，你必须[启用它](#enable-the-debian-group-api)。

> [!warning]
> 此 API 正在开发中，不适用于生产环境。

<a id="enable-the-debian-group-api"></a>

## 启用 Debian 群组 API

Debian 群组仓库支持仍在开发中，受默认禁用的功能标志控制。
[有权访问极狐GitLab Rails 控制台的极狐GitLab 管理员](../../administration/feature_flags/_index.md)
可以选择启用它。要启用它，请按照
[启用 Debian 群组 API](../../user/packages/debian_repository/_index.md#enable-the-debian-group-api) 中的说明进行操作。

<a id="authenticate-to-the-debian-distributions-apis"></a>

## 向 Debian 发行版 API 进行认证

参见[向 Debian 发行版 API 进行认证](../../user/packages/debian_repository/_index.md#authenticate-to-the-debian-distributions-apis)。

<a id="list-all-debian-distributions-in-a-group"></a>

## 列出群组中的所有 Debian 发行版

列出指定群组的所有 Debian 发行版。

```plaintext
GET /groups/:id/-/debian_distributions
```

| 属性       | 类型            | 必需 | 描述 |
| ---------- | --------------- | -------- | ----------- |
| `id`       | 整数或字符串  | 是      | ID 或[群组的 URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | 字符串          | 否       | 使用特定的代号过滤。 |
| `suite`    | 字符串          | 否       | 使用特定的 suite 过滤。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/-/debian_distributions"
```

响应示例：

```json
[
  {
    "id": 1,
    "codename": "sid",
    "suite": null,
    "origin": null,
    "label": null,
    "version": null,
    "description": null,
    "valid_time_duration_seconds": null,
    "components": [
      "main"
    ],
    "architectures": [
      "all",
      "amd64"
    ]
  }
]
```

<a id="retrieve-a-debian-group-distribution"></a>

## 获取一个 Debian 群组发行版

获取群组中指定的 Debian 群组发行版。

```plaintext
GET /groups/:id/-/debian_distributions/:codename
```

| 属性       | 类型           | 必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | 整数或字符串 | 是      | ID 或[群组的 URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | 字符串         | 是      | 发行版的代号。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/-/debian_distributions/unstable"
```

响应示例：

```json
{
  "id": 1,
  "codename": "sid",
  "suite": null,
  "origin": null,
  "label": null,
  "version": null,
  "description": null,
  "valid_time_duration_seconds": null,
  "components": [
    "main"
  ],
  "architectures": [
    "all",
    "amd64"
  ]
}
```

<a id="retrieve-a-debian-group-distribution-key"></a>

## 获取 Debian 群组发行版密钥

获取群组中指定的 Debian 群组发行版密钥。

```plaintext
GET /groups/:id/-/debian_distributions/:codename/key.asc
```

| 属性       | 类型           | 必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | 整数或字符串 | 是      | ID 或[群组的 URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | 字符串         | 是      | 发行版的代号。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/-/debian_distributions/unstable/key.asc"
```

响应示例：

```plaintext
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: Alice's OpenPGP certificate
Comment: https://www.ietf.org/id/draft-bre-openpgp-samples-01.html

mDMEXEcE6RYJKwYBBAHaRw8BAQdArjWwk3FAqyiFbFBKT4TzXcVBqPTB3gmzlC/U
b7O1u120JkFsaWNlIExvdmVsYWNlIDxhbGljZUBvcGVucGdwLmV4YW1wbGU+iJAE
ExYIADgCGwMFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQTrhbtfozp14V6UTmPy
MVUMT0fjjgUCXaWfOgAKCRDyMVUMT0fjjukrAPoDnHBSogOmsHOsd9qGsiZpgRnO
dypvbm+QtXZqth9rvwD9HcDC0tC+PHAsO7OTh1S1TC9RiJsvawAfCPaQZoed8gK4
OARcRwTpEgorBgEEAZdVAQUBAQdAQv8GIa2rSTzgqbXCpDDYMiKRVitCsy203x3s
E9+eviIDAQgHiHgEGBYIACAWIQTrhbtfozp14V6UTmPyMVUMT0fjjgUCXEcE6QIb
DAAKCRDyMVUMT0fjjlnQAQDFHUs6TIcxrNTtEZFjUFm1M0PJ1Dng/cDW4xN80fsn
0QEA22Kr7VkCjeAEC08VSTeV+QFsmz55/lntWkwYWhmvOgE=
=iIGO
-----END PGP PUBLIC KEY BLOCK-----
```

<a id="create-a-debian-group-distribution"></a>

## 创建 Debian 群组发行版

为指定群组创建 Debian 群组发行版。

```plaintext
POST /groups/:id/-/debian_distributions
```

| 属性                         | 类型           | 必需 | 描述 |
| ----------------------------- | -------------- | -------- | ----------- |
| `id`                          | 整数或字符串 | 是      | ID 或[群组的 URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `codename`                    | 字符串         | 是      | Debian 发行版的代号。 |
| `suite`                       | 字符串         | 否       | 新 Debian 发行版的 suite。 |
| `origin`                      | 字符串         | 否       | 新 Debian 发行版的 origin。 |
| `label`                       | 字符串         | 否       | 新 Debian 发行版的 label。 |
| `version`                     | 字符串         | 否       | 新 Debian 发行版的 version。 |
| `description`                 | 字符串         | 否       | 新 Debian 发行版的描述。 |
| `valid_time_duration_seconds` | 整数           | 否       | 新 Debian 发行版的有效时间（秒）。 |
| `components`                  | 字符串数组     | 否       | 新 Debian 发行版的组件列表。 |
| `architectures`               | 字符串数组     | 否       | 新 Debian 发行版的架构列表。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/-/debian_distributions?codename=sid"
```

响应示例：

```json
{
  "id": 1,
  "codename": "sid",
  "suite": null,
  "origin": null,
  "label": null,
  "version": null,
  "description": null,
  "valid_time_duration_seconds": null,
  "components": [
    "main"
  ],
  "architectures": [
    "all",
    "amd64"
  ]
}
```

<a id="update-a-debian-group-distribution"></a>

## 更新 Debian 群组发行版

更新群组中指定的 Debian 群组发行版。

```plaintext
PUT /groups/:id/-/debian_distributions/:codename
```

| 属性                         | 类型           | 必需 | 描述 |
| ----------------------------- | -------------- | -------- | ----------- |
| `id`                          | 整数或字符串 | 是      | ID 或[群组的 URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `codename`                    | 字符串         | 是      | Debian 发行版的新代号。 |
| `suite`                       | 字符串         | 否       | Debian 发行版的新 suite。 |
| `origin`                      | 字符串         | 否       | Debian 发行版的新 origin。 |
| `label`                       | 字符串         | 否       | Debian 发行版的新 label。 |
| `version`                     | 字符串         | 否       | Debian 发行版的新 version。 |
| `description`                 | 字符串         | 否       | Debian 发行版的新描述。 |
| `valid_time_duration_seconds` | 整数           | 否       | Debian 发行版的新有效时间（秒）。 |
| `components`                  | 字符串数组     | 否       | Debian 发行版的新组件列表。 |
| `architectures`               | 字符串数组     | 否       | Debian 发行版的新架构列表。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/-/debian_distributions/unstable?suite=new-suite&valid_time_duration_seconds=604800"
```

响应示例：

```json
{
  "id": 1,
  "codename": "sid",
  "suite": "new-suite",
  "origin": null,
  "label": null,
  "version": null,
  "description": null,
  "valid_time_duration_seconds": 604800,
  "components": [
    "main"
  ],
  "architectures": [
    "all",
    "amd64"
  ]
}
```

<a id="delete-a-debian-group-distribution"></a>

## 删除 Debian 群组发行版

删除群组中指定的 Debian 群组发行版。

```plaintext
DELETE /groups/:id/-/debian_distributions/:codename
```

| 属性       | 类型           | 必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | 整数或字符串 | 是      | ID 或[群组的 URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | 字符串         | 是      | Debian 发行版的代号。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/-/debian_distributions/unstable"
```