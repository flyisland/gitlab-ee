---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Debian 项目发行版 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- [在功能标志后部署](../../administration/feature_flags/_index.md)，默认禁用。

{{< /history >}}

使用此 API 管理 [Debian 项目发行版](../../user/packages/debian_repository/_index.md)。此 API 位于一个默认禁用的功能标志后。要使用此 API，必须[启用 Debian API](#启用-debian-api)。

> [!warning]
> 此 API 正在开发中，不适用于生产环境。

<a id="enable-the-debian-api"></a>

启用 Debian API

Debian API 由默认禁用的功能标志控制。
[对极狐GitLab Rails 控制台有访问权限的极狐GitLab 管理员](../../administration/feature_flags/_index.md)
可以选择启用它。要启用它，请按照
[启用 Debian API](../../user/packages/debian_repository/_index.md#enable-the-debian-api) 中的说明操作。

<a id="authenticate-to-the-debian-distributions-apis"></a>

对 Debian 发行版 API 进行身份验证

请参阅 [对 Debian 发行版 API 进行身份验证](../../user/packages/debian_repository/_index.md#authenticate-to-the-debian-distributions-apis)。

<a id="list-all-debian-distributions-in-a-project"></a>

列出项目中的所有 Debian 发行版

列出指定项目的所有 Debian 发行版。

```plaintext
GET /projects/:id/debian_distributions
```

| 属性 | 类型 | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id` | integer or string | 是 | 项目 ID 或 [URL 编码的项目路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | string | 否 | 使用特定的 `codename` 进行过滤。 |
| `suite` | string | 否 | 使用特定的 `suite` 进行过滤。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/debian_distributions"
```

示例响应：

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

<a id="retrieve-a-debian-project-distribution"></a>

获取一个 Debian 项目发行版

获取项目的指定 Debian 项目发行版。

```plaintext
GET /projects/:id/debian_distributions/:codename
```

| 属性 | 类型 | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id` | integer or string | 是 | 项目 ID 或 [URL 编码的项目路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | string | 是 | 发行版的 `codename`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/debian_distributions/unstable"
```

示例响应：

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

<a id="retrieve-a-debian-project-distribution-key"></a>

获取一个 Debian 项目发行版的密钥

获取项目的指定 Debian 项目发行版密钥。

```plaintext
GET /projects/:id/debian_distributions/:codename/key.asc
```

| 属性 | 类型 | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id` | integer or string | 是 | 项目 ID 或 [URL 编码的项目路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | string | 是 | 发行版的 `codename`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/debian_distributions/unstable/key.asc"
```

示例响应：

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

<a id="create-a-debian-project-distribution"></a>

创建一个 Debian 项目发行版

为指定的项目创建一个 Debian 项目发行版。

```plaintext
POST /projects/:id/debian_distributions
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ----------- |
| `id` | integer or string | 是 | 项目 ID 或 [URL 编码的项目路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | string | 是 | Debian 发行版的 codename。 |
| `suite` | string | 否 | 新 Debian 发行版的 suite。 |
| `origin` | string | 否 | 新 Debian 发行版的 origin。 |
| `label` | string | 否 | 新 Debian 发行版的 label。 |
| `version` | string | 否 | 新 Debian 发行版的 version。 |
| `description` | string | 否 | 新 Debian 发行版的 description。 |
| `valid_time_duration_seconds` | integer | 否 | 新 Debian 发行版的有效时间时长（以秒为单位）。 |
| `components` | string array | 否 | 新 Debian 发行版的 components 列表。 |
| `architectures` | string array | 否 | 新 Debian 发行版的 architectures 列表。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/debian_distributions?codename=sid"
```

示例响应：

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

<a id="update-a-debian-project-distribution"></a>

更新一个 Debian 项目发行版

为项目更新一个指定的 Debian 项目发行版。

```plaintext
PUT /projects/:id/debian_distributions/:codename
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ----------- |
| `id` | integer or string | 是 | 项目 ID 或 [URL 编码的项目路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | string | 是 | Debian 发行版的 codename。 |
| `suite` | string | 否 | Debian 发行版的新 suite。 |
| `origin` | string | 否 | Debian 发行版的新 origin。 |
| `label` | string | 否 | Debian 发行版的新 label。 |
| `version` | string | 否 | Debian 发行版的新 version。 |
| `description` | string | 否 | Debian 发行版的新 description。 |
| `valid_time_duration_seconds` | integer | 否 | Debian 发行版的新有效时间时长（以秒为单位）。 |
| `components` | string array | 否 | Debian 发行版的新 components 列表。 |
| `architectures` | string array | 否 | Debian 发行版的新 architectures 列表。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/debian_distributions/unstable?suite=new-suite&valid_time_duration_seconds=604800"
```

示例响应：

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

<a id="delete-a-debian-project-distribution"></a>

删除一个 Debian 项目发行版

为项目删除一个指定的 Debian 项目发行版。

```plaintext
DELETE /projects/:id/debian_distributions/:codename
```

| 属性 | 类型 | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id` | integer or string | 是 | 项目 ID 或 [URL 编码的项目路径](../rest/_index.md#namespaced-paths)。 |
| `codename` | string | 是 | Debian 发行版的 codename。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/debian_distributions/unstable"
```

