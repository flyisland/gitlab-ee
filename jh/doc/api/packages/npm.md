---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: npm API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [npm 包管理器客户端](../../user/packages/npm_registry/_index.md) 交互。

> [!warning]
> 此 API 供 [npm 包管理器客户端](https://docs.npmjs.com/) 使用，
> 不适用于手动调用。

这些端点不遵循标准的 API 认证方法。
请参阅 [npm 软件包仓库文档](../../user/packages/npm_registry/_index.md)，
了解支持哪些头部和令牌类型。将来可能会移除未记录的认证方法。

<a id="download-a-package"></a>

## 下载软件包

下载指定项目的指定 npm 软件包。此 URL 由 [元数据端点](#检索软件包元数据) 提供。

```plaintext
GET projects/:id/packages/npm/:package_name/-/:file_name
```

| 属性         | 类型   | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id`              | string | 是      | 项目 ID 或完整项目路径。 |
| `package_name`    | string | 是      | 软件包的名称。 |
| `file_name`       | string | 是      | 软件包文件的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/@myscope/my-pkg/-/@my-scope/my-pkg-0.0.1.tgz"
```

将输出写入文件：

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/@myscope/my-pkg/-/@my-scope/my-pkg-0.0.1.tgz" >> @myscope/my-pkg-0.0.1.tgz
```

这会将下载的文件写入当前目录的 `@myscope/my-pkg-0.0.1.tgz`。

<a id="upload-a-package-file"></a>

## 上传软件包文件

为指定项目上传软件包。

```plaintext
PUT projects/:id/packages/npm/:package_name
```

| 属性      | 类型   | 是否必需 | 描述                         |
|----------------|--------|----------|-------------------------------------|
| `id`           | string | 是      | 项目 ID 或完整项目路径。 |
| `package_name` | string | 是      | 软件包的名称。            |
| `versions`     | string | 是      | 软件包版本信息。        |

```shell
curl --request PUT
     --header "Content-Type: application/json"
     --data @./path/to/metadata/file.json
     --header "Authorization: Bearer <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/@myscope%2fmy-pkg"
```

元数据文件内容由 npm 生成，但类似以下内容：

```json
{
    "_attachments": {
        "@myscope/my-pkg-1.3.7.tgz": {
            "content_type": "application/octet-stream",
            "data": "H4sIAAAAAAAAE+1TQUvDMBjdeb/iI4edZEldV2dPwhARPIjiyXlI26zN1iYhSeeK7L+bNJtednMg4l4OKe+9PF7DF0XzNS0ZVmEfr4wUgxODEJLEMRzjPRJyCYPJNCFRlCTE+dzH1PvJqYscQ2ss1a7KT3PCv8DX/kfwMQRAgjYMpYBuIoIzKtwy6MILG6YNl8Jr0XgyvgpswUyuubJ75TGMDuSaUcsKyDooa1C6De6G8t7GRcG2br4CGxKME3wDR1hmrLexvJKwQLdaS52CkOAFMIrlfMlZsUAwGgHbcgsRcid3fdqade9SFz7u9a1naGsrqX3gHbcPNINDyydWcmN1By+W19x2oU7NcyZMfwn3z/PAqTaruanmUix5+V3UXVKq9yEoRZW1yqQYl9zWNBvnssFUcbyJsdJyxXJrcHQdz8gsTg6PzGChGty3H+6Gvz0BZ5xxxn/FJ1EDRNIACAAA",
            "length": 354
        }
    },
    "_id": "@myscope/my-pkg",
    "description": "Package created by me",
    "dist-tags": {
        "latest": "1.3.7"
    },
    "name": "@myscope/my-pkg",
    "readme": "ERROR: No README data found!",
    "versions": {
        "1.3.7": {
            "_id": "@myscope/my-pkg@1.3.7",
            "_nodeVersion": "12.18.4",
            "_npmVersion": "6.14.6",
            "author": {
                "name": "GitLab package registry Utility"
            },
            "description": "Package created by me",
            "dist": {
                "integrity": "sha512-loy16p+Dtw2S43lBmD3Nye+t+Vwv7Tbhv143UN2mwcjaHJyBfGZdNCTXnma3gJCUSE/AR4FPGWEyCOOTJ+ev9g==",
                "shasum": "4a9dbd94ca6093feda03d909f3d7e6bd89d9d4bf",
                "tarball": "https://gitlab.example.com/api/v4/projects/1/packages/npm/@myscope/my-pkg/-/@myscope/my-pkg-1.3.7.tgz"
            },
            "keywords": [],
            "license": "ISC",
            "main": "index.js",
            "name": "@myscope/my-pkg",
            "publishConfig": {
                "@myscope:registry": "https://gitlab.example.com/api/v4/projects/1/packages/npm"
            },
            "readme": "ERROR: No README data found!",
            "scripts": {
                "test": "echo \"Error: no test specified\" && exit 1"
            },
            "version": "1.3.7"
        }
    }
}
```

<a id="route-prefix"></a>

## 路由前缀

对于其余路由，有两组相同的路由，每组都可在不同范围内发起请求：

- 使用实例级前缀可在整个实例范围内发起请求。
- 使用项目级前缀可在单个项目范围内发起请求。
- 使用群组级前缀可在群组范围内发起请求。

本文档中的示例均使用项目级前缀。

<a id="instance-level"></a>

### 实例级

```plaintext
/packages/npm
```

<a id="project-level"></a>

### 项目级

```plaintext
/projects/:id/packages/npm
```

| 属性 | 类型   | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | string | 是      | 项目 ID 或完整项目路径。 |

<a id="group-level"></a>

### 群组级

{{< history >}}

- 在极狐GitLab 16.0 中引入，[功能标志](../../administration/feature_flags/_index.md) 名为 `npm_group_level_endpoints`。默认禁用。
- 在极狐GitLab 16.1 中 GA，功能标志 `npm_group_level_endpoints` 已移除。

{{< /history >}}

```plaintext
/groups/:id/-/packages/npm
```

| 属性 | 类型   | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | string | 是      | 群组 ID 或完整群组路径。 |

<a id="retrieve-package-metadata"></a>

## 检索软件包元数据

获取指定软件包的元数据。

```plaintext
GET <route-prefix>/:package_name
```

| 属性      | 类型   | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `package_name` | string | 是      | 软件包的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/@myscope/my-pkg"
```

响应示例：

```json
{
  "name": "@myscope/my-pkg",
  "versions": {
    "0.0.2": {
      "name": "@myscope/my-pkg",
      "version": "0.0.1",
      "dist": {
        "shasum": "93abb605b1110c0e3cca0a5b805e5cb01ac4ca9b",
        "tarball": "https://gitlab.example.com/api/v4/projects/1/packages/npm/@myscope/my-pkg/-/@myscope/my-pkg-0.0.1.tgz"
      }
    }
  },
  "dist-tags": {
    "latest": "0.0.1"
  }
}
```

响应中的 URL 与请求时所使用的路由前缀一致。如果你使用实例级路由请求，则返回的 URL 中会包含 `/api/v4/packages/npm`。

<a id="dist-tags"></a>

## Dist 标签

<a id="list-all-dist-tags"></a>

### 列出所有 dist 标签

列出指定软件包的所有 dist 标签。

```plaintext
GET <route-prefix>/-/package/:package_name/dist-tags
```

| 属性      | 类型   | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `package_name` | string | 是      | 软件包的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/-/package/@myscope/my-pkg/dist-tags"
```

响应示例：

```json
{
  "latest": "2.1.1",
  "stable": "1.0.0"
}
```

响应中的 URL 与请求时所使用的路由前缀一致。如果你使用实例级路由请求，则返回的 URL 中会包含 `/api/v4/packages/npm`。

<a id="create-or-update-a-dist-tag"></a>

### 创建或更新 dist 标签

为软件包创建或更新指定的 dist 标签。

```plaintext
PUT <route-prefix>/-/package/:package_name/dist-tags/:tag
```

| 属性      | 类型   | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `package_name` | string | 是      | 软件包的名称。 |
| `tag`          | string | 是      | 要创建或更新的标签。 |
| `version`      | string | 是      | 要标记的版本。 |

```shell
curl --request PUT --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/-/package/@myscope/my-pkg/dist-tags/stable"
```

此端点成功响应 `204 No Content`。

<a id="delete-a-dist-tag"></a>

### 删除 dist 标签

删除软件包的指定 dist 标签。

```plaintext
DELETE <route-prefix>/-/package/:package_name/dist-tags/:tag
```

| 属性      | 类型   | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `package_name` | string | 是      | 软件包的名称。 |
| `tag`          | string | 是      | 要删除的标签。 |

```shell
curl --request DELETE --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/npm/-/package/@myscope/my-pkg/dist-tags/stable"
```

此端点成功响应 `204 No Content`。