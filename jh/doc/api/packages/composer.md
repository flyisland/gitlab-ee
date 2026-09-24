---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Composer API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [Composer 软件包管理器客户端](../../user/packages/composer_repository/_index.md) 交互。

> [!warning]
> 此 API 供 [Composer 软件包管理器客户端](https://getcomposer.org/) 使用，通常不适用于手动操作。

这些端点不遵循标准 API 身份验证方式。关于支持的请求头和令牌类型，请参阅 [Composer 软件包仓库文档](../../user/packages/composer_repository/_index.md)。未记录的身份验证方式可能会在未来被移除。

<a id="retrieve-repository-url-templates"></a>

## 获取仓库 URL 模板

获取群组中用于请求单个软件包的仓库 URL 模板。

```plaintext
GET group/:id/-/packages/composer/packages
```

| 属性 | 类型   | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | string | 是      | 群组的 ID 或完整路径。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/group/1/-/packages/composer/packages"
```

示例响应：

```json
{
  "packages": [],
  "metadata-url": "/api/v4/group/1/-/packages/composer/p2/%package%.json",
  "provider-includes": {
    "p/%hash%.json": {
      "sha256": "082df4a5035f8725a12a4a3d2da5e6aaa966d06843d0a5c6d499313810427bd6"
    }
  },
  "providers-url": "/api/v4/group/1/-/packages/composer/%package%$%hash%.json"
}
```

此端点同时适用于 Composer V1 和 V2。要查看 V2 特有的响应，请包含 Composer 的 `User-Agent` 请求头。建议优先使用 Composer V2 而非 V1。

```shell
curl --user <username>:<personal_access_token> \
     --header "User-Agent: Composer/2" \
     --url "https://gitlab.example.com/api/v4/group/1/-/packages/composer/packages"
```

示例响应：

```json
{
  "packages": [],
  "metadata-url": "/api/v4/group/1/-/packages/composer/p2/%package%.json"
}
```

<a id="v1-packages-list"></a>

## V1 软件包列表

根据给定的 V1 供应方 SHA，获取群组仓库中的软件包列表。建议优先使用 Composer V2 而非 V1。

```plaintext
GET group/:id/-/packages/composer/p/:sha
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | string | 是 | 群组的 ID 或完整路径。 |
| `sha`     | string | 是 | 供应方 SHA，由 Composer 的 [基础请求](#retrieve-repository-url-templates) 提供。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/group/1/-/packages/composer/p/082df4a5035f8725a12a4a3d2da5e6aaa966d06843d0a5c6d499313810427bd6"
```

示例响应：

```json
{
  "providers": {
    "my-org/my-composer-package": {
      "sha256": "5c873497cdaa82eda35af5de24b789be92dfb6510baf117c42f03899c166b6e7"
    }
  }
}
```

<a id="retrieve-v1-package-metadata"></a>

## 获取 V1 软件包元数据

获取群组中指定软件包的版本列表和元数据。建议优先使用 Composer V2 而非 V1。

```plaintext
GET group/:id/-/packages/composer/:package_name$:sha
```

请注意 URL 中的 `$` 符号。发出请求时，你可能需要使用该符号的 URL 编码版本 `%24`。请参阅表格后的示例：

| 属性      | 类型   | 是否必需 | 描述                                                                           |
|----------------|--------|----------|---------------------------------------------------------------------------------------|
| `id`           | string | 是      | 群组的 ID 或完整路径。                                                     |
| `package_name` | string | 是      | 软件包的名称。                                                              |
| `sha`          | string | 是      | 软件包的 SHA 摘要，由 [V1 软件包列表](#v1-packages-list) 提供。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/group/1/-/packages/composer/my-org/my-composer-package%245c873497cdaa82eda35af5de24b789be92dfb6510baf117c42f03899c166b6e7"
```

示例响应：

```json
{
  "packages": {
    "my-org/my-composer-package": {
      "1.0.0": {
        "name": "my-org/my-composer-package",
        "type": "library",
        "license": "GPL-3.0-only",
        "version": "1.0.0",
        "dist": {
          "type": "zip",
          "url": "https://gitlab.example.com/api/v4/projects/1/packages/composer/archives/my-org/my-composer-package.zip?sha=673594f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "reference": "673594f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "shasum": ""
        },
        "source": {
          "type": "git",
          "url": "https://gitlab.example.com/my-org/my-composer-package.git",
          "reference": "673594f85a55fe3c0eb45df7bd2fa9d95a1601ab"
        },
        "uid": 1234567
      },
      "2.0.0": {
        "name": "my-org/my-composer-package",
        "type": "library",
        "license": "GPL-3.0-only",
        "version": "2.0.0",
        "dist": {
          "type": "zip",
          "url": "https://gitlab.example.com/api/v4/projects/1/packages/composer/archives/my-org/my-composer-package.zip?sha=445394f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "reference": "445394f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "shasum": ""
        },
        "source": {
          "type": "git",
          "url": "https://gitlab.example.com/my-org/my-composer-package.git",
          "reference": "445394f85a55fe3c0eb45df7bd2fa9d95a1601ab"
        },
        "uid": 1234567
      }
    }
  }
}
```

<a id="retrieve-v2-package-metadata"></a>

## 获取 V2 软件包元数据

获取群组中指定软件包的版本列表和元数据。

```plaintext
GET group/:id/-/packages/composer/p2/:package_name
```

| 属性      | 类型   | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `id`           | string | 是      | 群组的 ID 或完整路径。 |
| `package_name` | string | 是      | 软件包的名称。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/group/1/-/packages/composer/p2/my-org/my-composer-package"
```

示例响应：

```json
{
  "packages": {
    "my-org/my-composer-package": {
      "1.0.0": {
        "name": "my-org/my-composer-package",
        "type": "library",
        "license": "GPL-3.0-only",
        "version": "1.0.0",
        "dist": {
          "type": "zip",
          "url": "https://gitlab.example.com/api/v4/projects/1/packages/composer/archives/my-org/my-composer-package.zip?sha=673594f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "reference": "673594f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "shasum": ""
        },
        "source": {
          "type": "git",
          "url": "https://gitlab.example.com/my-org/my-composer-package.git",
          "reference": "673594f85a55fe3c0eb45df7bd2fa9d95a1601ab"
        },
        "uid": 1234567
      },
      "2.0.0": {
        "name": "my-org/my-composer-package",
        "type": "library",
        "license": "GPL-3.0-only",
        "version": "2.0.0",
        "dist": {
          "type": "zip",
          "url": "https://gitlab.example.com/api/v4/projects/1/packages/composer/archives/my-org/my-composer-package.zip?sha=445394f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "reference": "445394f85a55fe3c0eb45df7bd2fa9d95a1601ab",
          "shasum": ""
        },
        "source": {
          "type": "git",
          "url": "https://gitlab.example.com/my-org/my-composer-package.git",
          "reference": "445394f85a55fe3c0eb45df7bd2fa9d95a1601ab"
        },
        "uid": 1234567
      }
    }
  }
}
```

<a id="create-a-package"></a>

## 创建软件包

根据项目中的指定 Git 标签或分支创建 Composer 软件包。

```plaintext
POST projects/:id/packages/composer
```

| 属性 | 类型   | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | string | 是      | 群组的 ID 或完整路径。 |
| `tag`     | string | 否       | 用于定位软件包的标签名称。 |
| `branch`  | string | 否       | 用于定位软件包的分支名称。 |

```shell
curl --request POST --user <username>:<personal_access_token> \
     --data tag=v1.0.0 \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/composer"
```

示例响应：

```json
{
  "message": "201 Created"
}
```

<a id="download-a-package-archive"></a>

## 下载软件包归档

下载项目中指定的 Composer 软件包归档。此 URL 由 [v1](#retrieve-v1-package-metadata) 或 [v2 软件包元数据](#retrieve-v2-package-metadata) 响应提供。请求中必须包含 `.zip` 文件扩展名。

```plaintext
GET projects/:id/packages/composer/archives/:package_name
```

| 属性      | 类型   | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `id`           | string | 是      | 群组的 ID 或完整路径。 |
| `package_name` | string | 是      | 软件包的名称。 |
| `sha`          | string | 是      | 请求软件包版本的目标 SHA。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/composer/archives/my-org/my-composer-package.zip?sha=673594f85a55fe3c0eb45df7bd2fa9d95a1601ab"
```

将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/composer/archives/my-org/my-composer-package.zip?sha=673594f85a55fe3c0eb45df7bd2fa9d95a1601ab" >> package.zip
```

这会将下载的文件写入当前目录下的 `package.zip` 文件中。