---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Conan v1 API
---

{{< details >}}

- Tier:基础版, 专业版, 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 对于 Conan v2 操作，请参阅 [Conan v2 API](conan_v2.md)。

使用此 API 与 [Conan v1 软件包管理器](../../user/packages/conan_1_repository/_index.md) 进行交互。这些端点适用于项目与实例。

> [!note]
> 这些端点不遵循标准的 API 认证方法。
> 请参阅每个路由以了解凭据的传递方式。未记录的认证方法可能在未来被移除。

通常，这些端点由 [Conan 1 软件包管理器客户端](https://docs.conan.io/en/latest/) 使用，不适合手动调用。

> [!warning]
> Conan 注册表不符合 FIPS 标准，在启用 FIPS 模式时会被禁用。
> 这些端点均返回 `404 Not Found`。

## 创建认证令牌

<a id="create-an-authentication-token"></a>

创建一个 JSON Web Token (JWT)，作为 Bearer 头用于其他 Conan 软件包管理器客户端请求。

```shell
"Authorization: Bearer <authenticate_token>"
```

```plaintext
GET /packages/conan/v1/users/authenticate
GET /projects/:id/packages/conan/v1/users/authenticate
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |

```shell
curl --user <username>:<your_access_token> \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/users/authenticate"
```

示例响应：

```shell
eyJhbGciOiJIUzI1NiIiheR5cCI6IkpXVCJ9.eyJhY2Nlc3NfdG9rZW4iOjMyMTQyMzAsqaVzZXJfaWQiOjQwNTkyNTQsImp0aSI6IjdlNzBiZTNjLWFlNWQtNDEyOC1hMmIyLWZiOThhZWM0MWM2OSIsImlhd3r1MTYxNjYyMzQzNSwibmJmIjoxNjE2NjIzNDMwLCJleHAiOjE2MTY2MjcwMzV9.QF0Q3ZIB2GW5zNKyMSIe0HIFOITjEsZEioR-27Rtu7E
```

## 验证 Conan 仓库的可用性

<a id="verify-availability-of-a-conan-repository"></a>

验证极狐GitLab Conan 仓库的可用性。

```plaintext
GET /packages/conan/v1/ping
GET /projects/:id/packages/conan/v1/ping
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |

```shell
curl --url "https://gitlab.example.com/api/v4/packages/conan/v1/ping"
```

示例响应：

```json
""
```

## 搜索 Conan 软件包

<a id="search-for-a-conan-package"></a>

在实例中搜索指定的 Conan 软件包。

```plaintext
GET /packages/conan/v1/conans/search
GET /projects/:id/packages/conan/v1/conans/search
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `q`       | string | 是 | 搜索查询。你可以使用 `*` 作为通配符。 |

```shell
curl --user <username>:<your_access_token> \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/search?q=Hello*"
```

示例响应：

```json
{
  "results": [
    "Hello/0.1@foo+conan_test_prod/beta",
    "Hello/0.1@foo+conan_test_prod/stable",
    "Hello/0.2@foo+conan_test_prod/beta",
    "Hello/0.3@foo+conan_test_prod/beta",
    "Hello/0.1@foo+conan-reference-test/stable",
    "HelloWorld/0.1@baz+conan-reference-test/beta"
    "hello-world/0.4@buz+conan-test/alpha"
  ]
}
```

## 验证认证凭据

<a id="verify-authentication-credentials"></a>

验证 Basic Auth 凭据或指定的 Conan JWT（由 [`/authenticate`](#创建认证令牌) 端点生成）的有效性。

```plaintext
GET /packages/conan/v1/users/check_credentials
GET /projects/:id/packages/conan/v1/users/check_credentials
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/users/check_credentials"
```

示例响应：

```shell
ok
```

## 获取配方快照

<a id="retrieve-a-recipe-snapshot"></a>

获取指定 Conan 配方的文件快照。快照是文件名及其关联的 MD5 哈希列表。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel
GET /projects/:id/packages/conan/v1/conans/:package_version/:package_username/:package_channel
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable"
```

示例响应：

```json
{
  "conan_sources.tgz": "eadf19b33f4c3c7e113faabf26e76277",
  "conanfile.py": "25e55b96a28f81a14ba8e8a8c99eeace",
  "conanmanifest.txt": "5b6fd77a2ba14303ce4cdb08c87e82ab"
}
```

## 获取软件包快照

<a id="retrieve-a-package-snapshot"></a>

获取指定 Conan 软件包和引用的文件快照。快照是文件名及其关联的 MD5 哈希列表。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference
GET /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `conan_package_reference` | string | 是 | Conan 软件包的引用哈希。Conan 会生成该值。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f"
```

示例响应：

```json
{
  "conan_package.tgz": "749b29bdf72587081ca03ec033ee59dc",
  "conaninfo.txt": "32859d737fe84e6a7ccfa4d64dc0d1f2",
  "conanmanifest.txt": "a86b398e813bd9aa111485a9054a2301"
}
```

## 获取配方清单

<a id="retrieve-a-recipe-manifest"></a>

获取指定配方的清单，包括文件列表及关联的下载 URL。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/digest
GET /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/digest
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/digest"
```

示例响应：

```json
{
  "conan_sources.tgz": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conan_sources.tgz",
  "conanfile.py": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanfile.py",
  "conanmanifest.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanmanifest.txt"
}
```

## 获取软件包清单

<a id="retrieve-a-package-manifest"></a>

获取指定软件包的清单，包括文件列表及关联的下载 URL。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference/digest
GET /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference/digest
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `conan_package_reference` | string | 是 | Conan 软件包的引用哈希。Conan 会生成该值。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/digest"
```

示例响应：

```json
{
  "conan_package.tgz": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conan_package.tgz",
  "conaninfo.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conaninfo.txt",
  "conanmanifest.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conanmanifest.txt"
}
```

## 列出所有配方下载 URL

<a id="list-all-recipe-download-urls"></a>

列出指定配方的所有文件及关联的下载 URL。返回与 [获取配方清单](#获取配方清单) 端点相同的载荷。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/download_urls
GET /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/download_urls
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/digest"
```

示例响应：

```json
{
  "conan_sources.tgz": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conan_sources.tgz",
  "conanfile.py": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanfile.py",
  "conanmanifest.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanmanifest.txt"
}
```

## 列出所有软件包下载 URL

<a id="list-all-package-download-urls"></a>

列出指定软件包的所有文件及关联的下载 URL。返回与 [获取软件包清单](#获取软件包清单) 端点相同的载荷。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference/download_urls
GET /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference/download_urls
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `conan_package_reference` | string | 是 | Conan 软件包的引用哈希。Conan 会生成该值。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/download_urls"
```

示例响应：

```json
{
  "conan_package.tgz": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conan_package.tgz",
  "conaninfo.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conaninfo.txt",
  "conanmanifest.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conanmanifest.txt"
}
```

## 列出所有配方上传 URL

<a id="list-all-recipe-upload-urls"></a>

列出指定配方文件集合的上传 URL。请求必须包含一个 JSON 对象，其中包含各个文件的名称和大小。

```plaintext
POST /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/upload_urls
POST /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/upload_urls
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |

示例请求 JSON 载荷：

载荷必须同时包含文件的名称和大小。

```json
{
  "conanfile.py": 410,
  "conanmanifest.txt": 130
}
```

```shell
curl --request POST \
     --header "Authorization: Bearer <authenticate_token>" \
     --header "Content-Type: application/json" \
     --data '{"conanfile.py":410,"conanmanifest.txt":130}' \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/upload_urls"
```

示例响应：

```json
{
  "conanfile.py": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanfile.py",
  "conanmanifest.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanmanifest.txt"
}
```

## 列出所有软件包上传 URL

<a id="list-all-package-upload-urls"></a>

列出指定软件包文件集合的上传 URL。请求必须包含一个 JSON 对象，其中包含各个文件的名称和大小。

```plaintext
POST /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference/upload_urls
POST /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/packages/:conan_package_reference/upload_urls
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `conan_package_reference` | string | 是 | Conan 软件包的引用哈希。Conan 会生成该值。 |

示例请求 JSON 载荷：

载荷必须同时包含文件的名称和大小。

```json
{
  "conan_package.tgz": 5412,
  "conanmanifest.txt": 130,
  "conaninfo.txt": 210
}
```

```shell
curl --request POST \
     --header "Authorization: Bearer <authenticate_token>" \
     --header "Content-Type: application/json" \
     --data '{"conan_package.tgz":5412,"conanmanifest.txt":130,"conaninfo.txt":210}' \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/upload_urls"
```

示例响应：

```json
{
  "conan_package.tgz": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/package/103f6067a947f366ef91fc1b7da351c588d1827f/0/conan_package.tgz",
  "conanmanifest.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/package/103f6067a947f366ef91fc1b7da351c588d1827f/0/conanmanifest.txt",
  "conaninfo.txt": "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/package/103f6067a947f366ef91fc1b7da351c588d1827f/0/conaninfo.txt"
}
```

## 获取配方文件

<a id="retrieve-a-recipe-file"></a>

从软件包仓库中获取指定的配方文件。你必须使用从 [列出所有配方下载 URL](#列出所有配方下载 URL) 端点返回的下载 URL。

```plaintext
GET /packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/export/:file_name
GET /projects/:id/packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/export/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `recipe_revision`   | string | 是 | 配方的修订版本。极狐GitLab 暂不支持 Conan 修订版本，因此始终使用默认值 `0`。 |
| `file_name`         | string | 是 | 请求文件的名称和扩展名。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanfile.py"
```

你也可以通过以下方式将输出写入文件：

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanfile.py" \
     >> conanfile.py
```

此示例会将文件写入当前目录下的 `conanfile.py`。

## 上传配方文件

<a id="upload-a-recipe-file"></a>

将指定的配方文件上传到软件包仓库。你必须使用从 [列出所有配方上传 URL](#列出所有配方上传 URL) 端点返回的上传 URL。

```plaintext
PUT /packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/export/:file_name
PUT /projects/:id/packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/export/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `recipe_revision`   | string | 是 | 配方的修订版本。极狐GitLab 暂不支持 Conan 修订版本，因此始终使用默认值 `0`。 |
| `file_name`         | string | 是 | 请求文件的名称和扩展名。 |

在请求体中提供文件内容：

```shell
curl --request PUT \
     --user <username>:<personal_access_token> \
     --upload-file path/to/conanfile.py \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/export/conanfile.py"
```

## 获取软件包文件

<a id="retrieve-a-package-file"></a>

从软件包仓库中获取指定的软件包文件。你必须使用从 [列出所有软件包下载 URL](#列出所有软件包下载 URL) 端点返回的下载 URL。

```plaintext
GET /packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/package/:conan_package_reference/:package_revision/:file_name
GET /projects/:id/packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/package/:conan_package_reference/:package_revision/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | string | 条件性 | 项目 ID 或完整项目路径。仅对项目端点必需。 |
| `package_name`      | string | 是 | 软件包名称。 |
| `package_version`   | string | 是 | 软件包版本。 |
| `package_username`  | string | 是 | 软件包的 Conan 用户名。该属性是以 `+` 分隔的项目完整路径。 |
| `package_channel`   | string | 是 | 软件包通道。 |
| `recipe_revision`   | string | 是 | 配方的修订版本。极狐GitLab 暂不支持 Conan 修订版本，因此始终使用默认值 `0`。 |
| `conan_package_reference` | string | 是 | Conan 软件包的引用哈希。Conan 会生成该值。 |
| `package_revision`  | string | 是 | 软件包的修订版本。极狐GitLab 暂不支持 Conan 修订版本，因此始终使用默认值 `0`。 |
| `file_name`         | string | 是 | 请求文件的名称和扩展名。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conaninfo.txt"
```

你也可以通过以下方式将输出写入文件：

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/packages/103f6067a947f366ef91fc1b7da351c588d1827f/0/conaninfo.txt" \
     >> conaninfo.txt
```

此示例会将文件写入当前目录下的 `conaninfo.txt`。

## 上传软件包文件

<a id="upload-a-package-file"></a>

将指定的软件包文件上传到软件包仓库。你必须使用从 [列出所有软件包上传 URL](#列出所有软件包上传 URL) 端点返回的上传 URL。

```plaintext
PUT /packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/package/:conan_package_reference/:package_revision/:file_name
PUT /projects/:id/packages/conan/v1/files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision/package/:conan_package_reference/:package_revision/:file_name
```
| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | 字符串 | 条件必需 | 项目 ID 或完整项目路径。仅项目端点需要。 |
| `package_name`      | 字符串 | 是 | 软件包名称。 |
| `package_version`   | 字符串 | 是 | 软件包版本。 |
| `package_username`  | 字符串 | 是 | 软件包的 Conan 用户名。该属性是项目的 `+` 分隔完整路径。 |
| `package_channel`   | 字符串 | 是 | 软件包通道。 |
| `recipe_revision`   | 字符串 | 是 | 配方的修订。极狐GitLab 尚不支持 Conan 修订，因此始终使用默认值 `0`。 |
| `conan_package_reference` | 字符串 | 是 | Conan 软件包的引用哈希。由 Conan 生成。 |
| `package_revision`  | 字符串 | 是 | 软件包的修订。极狐GitLab 尚不支持 Conan 修订，因此始终使用默认值 `0`。 |
| `file_name`         | 字符串 | 是 | 所请求文件的名称和扩展名。 |

在请求体中提供文件上下文：

```shell
curl --request PUT \
     --user <username>:<your_access_token> \
     --upload-file path/to/conaninfo.txt \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/files/my-package/1.0/my-group+my-project/stable/0/package/103f6067a947f366ef91fc1b7da351c588d1827f/0/conaninfo.txt"
```

<a id="delete-a-recipe-and-package"></a>

## 删除配方和软件包

从软件包仓库中删除指定的 Conan 配方及其关联的软件包文件。

```plaintext
DELETE /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel
DELETE /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | 字符串 | 条件必需 | 项目 ID 或完整项目路径。仅项目端点需要。 |
| `package_name`      | 字符串 | 是 | 软件包名称。 |
| `package_version`   | 字符串 | 是 | 软件包版本。 |
| `package_username`  | 字符串 | 是 | 软件包的 Conan 用户名。该属性是项目的 `+` 分隔完整路径。 |
| `package_channel`   | 字符串 | 是 | 软件包通道。 |

```shell
curl --request DELETE \
     --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable"
```

示例响应：

```json
{
  "id": 1,
  "project_id": 123,
  "created_at": "2020-08-19T13:17:28.655Z",
  "updated_at": "2020-08-19T13:17:28.655Z",
  "name": "my-package",
  "version": "1.0",
  "package_type": "conan",
  "creator_id": null,
  "status": "default"
}
```

<a id="retrieve-package-references-metadata"></a>

## 检索软件包引用的元数据

检索指定软件包的所有软件包引用的元数据。

```plaintext
GET /packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/search
GET /projects/:id/packages/conan/v1/conans/:package_name/:package_version/:package_username/:package_channel/search
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                | 字符串 | 条件必需 | 项目 ID 或完整项目路径。仅项目端点需要。 |
| `package_name`      | 字符串 | 是 | 软件包名称。 |
| `package_version`   | 字符串 | 是 | 软件包版本。 |
| `package_username`  | 字符串 | 是 | 软件包的 Conan 用户名。该属性是项目的 `+` 分隔完整路径。 |
| `package_channel`   | 字符串 | 是 | 软件包通道。 |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/packages/conan/v1/conans/my-package/1.0/my-group+my-project/stable/search"
```

示例响应：

```json
{
  "103f6067a947f366ef91fc1b7da351c588d1827f": {
    "settings": {
      "arch": "x86_64",
      "build_type": "Release",
      "compiler": "gcc",
      "compiler.libcxx": "libstdc++",
      "compiler.version": "9",
      "os": "Linux"
    },
    "options": {
      "shared": "False"
    },
    "requires": {
      "zlib/1.2.11": null
    },
    "recipe_hash": "75151329520e7685dcf5da49ded2fec0"
  }
}
```

响应为每个软件包引用包含以下元数据：

- `settings`：构建软件包时使用的构建设置。
- `options`：软件包选项。
- `requires`：软件包所需的依赖项。
- `recipe_hash`：配方的哈希。