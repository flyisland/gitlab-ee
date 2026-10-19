---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Conan v2 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.11 中引入，带有名为 `conan_package_revisions_support` 的功能标志。默认禁用。
- 在极狐GitLab 18.3 中于 JihuLab.com 上启用。功能标志 `conan_package_revisions_support` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。更多信息，请参见历史记录。

使用此 API 与 [Conan v2 软件包管理器](../../user/packages/conan_2_repository/_index.md) 交互。
对于 Conan v1 操作，请参见 [Conan v1 API](conan_v1.md)。

> [!note]
> 这些端点不遵循标准的 API 身份验证方法。
> 请参见每个路由，了解有关如何传递凭证的详细信息。未文档化的身份验证方法将来可能会被移除。

通常，这些端点由 [Conan 2 软件包管理器客户端](https://docs.conan.io/2/index.html) 使用，而非用于手动调用。

> [!warning]
> Conan 软件包仓库不符合 FIPS 标准，并在启用 FIPS 模式时被禁用。
> 这些端点均返回 `404 Not Found`。

## 创建身份验证令牌

创建一个 JSON Web Token (JWT)，用作其他请求中的 Bearer 标头。

```shell
"Authorization: Bearer <authenticate_token>
```

Conan 2 软件包管理器客户端会自动使用此令牌。

```plaintext
GET /projects/:id/packages/conan/v2/users/authenticate
```

| 属性   | 类型   | 必需         | 描述                                     |
| ------ | ------ | ------------ | ---------------------------------------- |
| `id`   | string | 有条件地必需 | 项目 ID 或完整项目路径。仅项目端点必需。 |

生成一个 base64 编码的 Basic Auth 令牌：

```shell
echo -n "<用户名>:<您的访问令牌>"|base64
```

使用 base64 编码的 Basic Auth 令牌获取 JWT 令牌：

```shell
curl --request GET \
     --header 'Authorization: Basic <base64_encoded_token>' \
     --url "https://gitlab.example.com/api/v4/packages/conan/v2/users/authenticate"
```

示例响应：

```shell
eyJhbGciOiJIUzI1NiIiheR5cCI6IkpXVCJ9.eyJhY2Nlc3NfdG9rZW4iOjMyMTQyMzAsqaVzZXJfaWQiOjQwNTkyNTQsImp0aSI6IjdlNzBiZTNjLWFlNWQtNDEyOC1hMmIyLWZiOThhZWM0MWM2OSIsImlhd3r1MTYxNjYyMzQzNSwibmJmIjoxNjE2NjIzNDMwLCJleHAiOjE2MTY2MjcwMzV9.QF0Q3ZIB2GW5zNKyMSIe0HIFOITjEsZEioR-27Rtu7E
```

## 验证身份认证凭证

验证 Basic Auth 凭证或从 Conan v1 [`/authenticate`](conan_v1.md#创建身份验证令牌) 端点生成的特定 Conan JWT 的有效性。

```plaintext
GET /projects/:id/packages/conan/v2/users/check_credentials
```

| 属性   | 类型   | 必需 | 描述                     |
| ------ | ------ | ---- | ------------------------ |
| `id`   | string | 是   | 项目 ID 或完整项目路径。 |

```shell
curl --request GET \
     --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<project_id>/packages/conan/v2/users/check_credentials"
```

示例响应：

```plaintext
ok
```

## 搜索 Conan 软件包

在项目中搜索指定的 Conan 软件包。

```plaintext
GET /projects/:id/packages/conan/v2/conans/search?q=:query
```

| 属性   | 类型   | 必需 | 描述                                 |
| ------ | ------ | ---- | ------------------------------------ |
| `id`   | string | 是   | 项目 ID 或完整项目路径。             |
| `query`| string | 是   | 搜索查询。您可以使用 `*` 作为通配符。 |

```shell
curl --request GET \
     --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/search?q=Hello*"
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

## 获取最新配方修订

获取最新软件包配方的修订哈希和创建日期。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/latest
```

| 属性               | 类型   | 必需 | 描述                                                         |
| ------------------ | ------ | ---- | ------------------------------------------------------------ |
| `id`               | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`     | string | 是   | 软件包名称。                                                  |
| `package_version`  | string | 是   | 软件包版本。                                                  |
| `package_username` | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`  | string | 是   | 软件包的通道。                                                |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/latest"
```

示例响应：

```json
{
  "revision" : "75151329520e7685dcf5da49ded2fec0",
  "time" : "2024-12-17T09:16:40.334+0000"
}
```

## 列出所有配方修订

列出软件包配方的所有修订。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions
```

| 属性               | 类型   | 必需 | 描述                                                         |
| ------------------ | ------ | ---- | ------------------------------------------------------------ |
| `id`               | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`     | string | 是   | 软件包名称。                                                  |
| `package_version`  | string | 是   | 软件包版本。                                                  |
| `package_username` | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`  | string | 是   | 软件包的通道。                                                |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions"
```

示例响应：

```json
{
  "reference": "my-package/1.0@my-group+my-project/stable",
  "revisions": [
    {
      "revision": "75151329520e7685dcf5da49ded2fec0",
      "time": "2024-12-17T09:16:40.334+0000"
    },
    {
      "revision": "df28fd816be3a119de5ce4d374436b25",
      "time": "2024-12-17T09:15:30.123+0000"
    }
  ]
}
```

## 删除一个配方修订

从软件包仓库中删除指定的配方修订。如果软件包只有一个配方修订，则该软件包也会被删除。

```plaintext
DELETE /projects/:id/packages/conan/conans/:package_name/package_version/:package_username/:package_channel/revisions/:recipe_revision
```

| 属性               | 类型   | 必需 | 描述                                                         |
| ------------------ | ------ | ---- | ------------------------------------------------------------ |
| `id`               | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`     | string | 是   | 软件包名称。                                                  |
| `package_version`  | string | 是   | 软件包版本。                                                  |
| `package_username` | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`  | string | 是   | 软件包的通道。                                                |
| `recipe_revision`  | string | 是   | 要删除的配方修订的修订哈希。                                    |

```shell
curl --request DELETE \
     --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/2be19f5a69b2cb02ab576755252319b9"
```

## 列出所有配方文件

列出软件包仓库中的所有配方文件。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/files
```

| 属性               | 类型   | 必需 | 描述                                                         |
| ------------------ | ------ | ---- | ------------------------------------------------------------ |
| `id`               | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`     | string | 是   | 软件包名称。                                                  |
| `package_version`  | string | 是   | 软件包版本。                                                  |
| `package_username` | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`  | string | 是   | 软件包的通道。                                                |
| `recipe_revision`  | string | 是   | 配方的修订。不接受 `0` 值。                                     |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-username/stable/revisions/df28fd816be3a119de5ce4d374436b25/files"
```

示例响应：

```json
{
  "files": {
    "conan_sources.tgz": {},
    "conanfile.py": {},
    "conanmanifest.txt": {}
  }
}
```

## 获取一个配方文件

从软件包仓库中获取指定的配方文件。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/files/:file_name
```

| 属性               | 类型   | 必需 | 描述                                                         |
| ------------------ | ------ | ---- | ------------------------------------------------------------ |
| `id`               | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`     | string | 是   | 软件包名称。                                                  |
| `package_version`  | string | 是   | 软件包版本。                                                  |
| `package_username` | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`  | string | 是   | 软件包的通道。                                                |
| `recipe_revision`  | string | 是   | 配方的修订。不接受 `0` 值。                                     |
| `file_name`        | string | 是   | 请求文件的名称和扩展名。                                      |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-username/stable/revisions/df28fd816be3a119de5ce4d374436b25/files/conanfile.py"
```

您也可以使用以下命令将输出写入文件：

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-username/stable/revisions/df28fd816be3a119de5ce4d374436b25/files/conanfile.py" \
     >> conanfile.py
```

此示例将内容写入当前目录下的 `conanfile.py` 文件中。

## 上传一个配方文件

将指定的配方文件上传到软件包仓库。

```plaintext
PUT /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/files/:file_name
```

| 属性               | 类型   | 必需 | 描述                                                         |
| ------------------ | ------ | ---- | ------------------------------------------------------------ |
| `id`               | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`     | string | 是   | 软件包名称。                                                  |
| `package_version`  | string | 是   | 软件包版本。                                                  |
| `package_username` | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`  | string | 是   | 软件包的通道。                                                |
| `recipe_revision`  | string | 是   | 配方的修订。不接受 `0` 值。                                     |
| `file_name`        | string | 是   | 请求文件的名称和扩展名。                                      |

```shell
curl --request PUT \
     --header "Authorization: Bearer <authenticate_token>" \
     --upload-file path/to/conanfile.py \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/upload-v2-package/1.0.0/user/stable/revisions/123456789012345678901234567890ab/files/conanfile.py"
```

示例响应：

```json
{
  "id": 38,
  "package_id": 28,
  "created_at": "2025-04-07T12:35:40.841Z",
  "updated_at": "2025-04-07T12:35:40.841Z",
  "size": 24,
  "file_store": 1,
  "file_md5": "131f806af123b497209a516f46d12ffd",
  "file_sha1": "01b992b2b1976a3f4c1e5294d0cab549cd438502",
  "file_name": "conanfile.py",
  "file": {
    "url": "/94/00/9400f1b21cb527d7fa3d3eabba93557a18ebe7a2ca4e471cfe5e4c5b4ca7f767/packages/28/files/38/conanfile.py"
  },
  "file_sha256": null,
  "verification_retry_at": null,
  "verified_at": null,
  "verification_failure": null,
  "verification_retry_count": null,
  "verification_checksum": null,
  "verification_state": 0,
  "verification_started_at": null,
  "status": "default",
  "file_final_path": null,
  "project_id": 9,
  "new_file_path": null
}
```

## 列出所有软件包修订

列出特定配方修订和软件包引用的所有软件包修订。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/packages/:conan_package_reference/revisions
```

| 属性                      | 类型   | 必需 | 描述                                                         |
| ------------------------- | ------ | ---- | ------------------------------------------------------------ |
| `id`                      | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`            | string | 是   | 软件包名称。                                                  |
| `package_version`         | string | 是   | 软件包版本。                                                  |
| `package_username`        | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`         | string | 是   | 软件包的通道。                                                |
| `recipe_revision`         | string | 是   | 配方的修订。不接受 `0` 值。                                     |
| `conan_package_reference` | string | 是   | Conan 软件包的引用哈希。此值由 Conan 生成。                     |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/packages/103f6067a947f366ef91fc1b7da351c588d1827f/revisions"
```

示例响应：

```json
{
  "reference": "my-package/1.0@my-group+my-project/stable#75151329520e7685dcf5da49ded2fec0:103f6067a947f366ef91fc1b7da351c588d1827f",
  "revisions": [
    {
      "revision": "2bfb52659449d84ed11356c353bfbe86",
      "time": "2024-12-17T09:16:40.334+0000"
    },
    {
      "revision": "3bdd2d8c8e76c876ebd1ac0469a4e72c",
      "time": "2024-12-17T09:15:30.123+0000"
    }
  ]
}
```

## 获取最新软件包修订

获取特定配方修订和软件包引用的最新软件包修订的修订哈希和创建日期。

```plaintext
GET /api/v4/projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/packages/:conan_package_reference/latest
```

| 属性                      | 类型   | 必需 | 描述                                                         |
| ------------------------- | ------ | ---- | ------------------------------------------------------------ |
| `id`                      | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`            | string | 是   | 软件包名称。                                                  |
| `package_version`         | string | 是   | 软件包版本。                                                  |
| `package_username`        | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`         | string | 是   | 软件包的通道。                                                |
| `recipe_revision`         | string | 是   | 配方的修订。不接受 `0` 值。                                     |
| `conan_package_reference` | string | 是   | Conan 软件包的引用哈希。此值由 Conan 生成。                     |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/packages/103f6067a947f366ef91fc1b7da351c588d1827f/latest"
```

示例响应：

```json
{
  "revision" : "3bdd2d8c8e76c876ebd1ac0469a4e72c",
  "time" : "2024-12-17T09:16:40.334+0000"
}
```

## 删除一个软件包修订

从软件包仓库中删除指定的软件包修订。如果软件包引用只有一个软件包修订，则该软件包引用也会被删除。

```plaintext
DELETE /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/packages/:conan_package_reference/revisions/:package_revision
```

| 属性                      | 类型   | 必需 | 描述                                                         |
| ------------------------- | ------ | ---- | ------------------------------------------------------------ |
| `id`                      | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`            | string | 是   | 软件包名称。                                                  |
| `package_version`         | string | 是   | 软件包版本。                                                  |
| `package_username`        | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`         | string | 是   | 软件包的通道。                                                |
| `recipe_revision`         | string | 是   | 配方的修订。不接受 `0` 值。                                     |
| `conan_package_reference` | string | 是   | Conan 软件包的引用哈希。此值由 Conan 生成。                     |
| `package_revision`        | string | 是   | 软件包的修订。不接受 `0` 值。                                    |

```shell
curl --request DELETE \
     --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/packages/103f6067a947f366ef91fc1b7da351c588d1827f/revisions/3bdd2d8c8e76c876ebd1ac0469a4e72c"
```

## 获取一个软件包文件

从软件包仓库中获取指定的软件包文件。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/packages/:conan_package_reference/revisions/:package_revision/files/:file_name
```

| 属性                      | 类型   | 必需 | 描述                                                         |
| ------------------------- | ------ | ---- | ------------------------------------------------------------ |
| `id`                      | string | 是   | 项目 ID 或完整项目路径。                                      |
| `package_name`            | string | 是   | 软件包名称。                                                  |
| `package_version`         | string | 是   | 软件包版本。                                                  |
| `package_username`        | string | 是   | 软件包的 Conan 用户名。此属性是项目的以 `+` 分隔的完整路径。 |
| `package_channel`         | string | 是   | 软件包的通道。                                                |
| `recipe_revision`         | string | 是   | 配方的修订。不接受 `0` 值。                                     |
| `conan_package_reference` | string | 是   | Conan 软件包的引用哈希。此值由 Conan 生成。                     |
| `package_revision`        | string | 是   | 软件包的修订。不接受 `0` 值。                                    |
| `file_name`               | string | 是   | 请求文件的名称和扩展名。                                      |
```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/packages/103f6067a947f366ef91fc1b7da351c588d1827f/revisions/3bdd2d8c8e76c876ebd1ac0469a4e72c/files/conaninfo.txt"
```

你还可以通过以下方式将输出写入文件：

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/packages/103f6067a947f366ef91fc1b7da351c588d1827f/revisions/3bdd2d8c8e76c876ebd1ac0469a4e72c/files/conaninfo.txt" \
     >> conaninfo.txt
```

此示例将内容写入当前目录下的 `conaninfo.txt` 文件中。

<a id="upload-a-package-file"></a>

## 上传软件包文件

将指定的软件包文件上传到软件包仓库。

```plaintext
PUT /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/packages/:conan_package_reference/revisions/:package_revision/files/:file_name
```

| 属性                        | 类型   | 是否必需 | 描述                                                                  |
| --------------------------- | ------ | -------- | --------------------------------------------------------------------- |
| `id`                        | string | 是       | 项目 ID 或完整项目路径。                                              |
| `package_name`              | string | 是       | 软件包名称。                                                          |
| `package_version`           | string | 是       | 软件包版本。                                                          |
| `package_username`          | string | 是       | 软件包的 Conan 用户名。此属性为用 `+` 分隔的项目完整路径。            |
| `package_channel`           | string | 是       | 软件包渠道。                                                          |
| `recipe_revision`           | string | 是       | 配方的修订版本。不接受值为 `0`。                                      |
| `conan_package_reference`   | string | 是       | Conan 软件包的引用哈希。Conan 生成此值。                              |
| `package_revision`          | string | 是       | 软件包的修订版本。不接受值为 `0`。                                    |
| `file_name`                 | string | 是       | 所请求文件的名称和扩展名。                                            |

在请求体中提供文件内容：

```shell
curl --request PUT \
     --header "Authorization: Bearer <authenticate_token>" \
     --upload-file path/to/conaninfo.txt \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/packages/103f6067a947f366ef91fc1b7da351c588d1827f/revisions/3bdd2d8c8e76c876ebd1ac0469a4e72c/files/conaninfo.txt"
```

示例响应：

```json
{
  "id": 202,
  "package_id": 48,
  "created_at": "2025-03-19T10:06:53.626Z",
  "updated_at": "2025-03-19T10:06:53.626Z",
  "size": 208,
  "file_store": 1,
  "file_md5": "bf996313bbdd75944b58f8c673661d99",
  "file_sha1": "02c8adf14c94135fb95d472f96525063efe09ee8",
  "file_name": "conaninfo.txt",
  "file": {
      "url": "/94/00/9400f1b21cb527d7fa3d3eabba93557a18ebe7a2ca4e471cfe5e4c5b4ca7f767/packages/48/files/202/conaninfo.txt"
  },
  "file_sha256": null,
  "verification_retry_at": null,
  "verified_at": null,
  "verification_failure": null,
  "verification_retry_count": null,
  "verification_checksum": null,
  "verification_state": 0,
  "verification_started_at": null,
  "status": "default",
  "file_final_path": null,
  "project_id": 9,
  "new_file_path": null
}
```

<a id="retrieve-package-references-metadata"></a>

## 获取软件包引用元数据

获取指定软件包的所有软件包引用的元数据。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/search
```

| 属性                  | 类型   | 是否必需 | 描述                                                                  |
| --------------------- | ------ | -------- | --------------------------------------------------------------------- |
| `id`                  | string | 是       | 项目 ID 或完整项目路径。                                              |
| `package_name`        | string | 是       | 软件包名称。                                                          |
| `package_version`     | string | 是       | 软件包版本。                                                          |
| `package_username`    | string | 是       | 软件包的 Conan 用户名。此属性为用 `+` 分隔的项目完整路径。            |
| `package_channel`     | string | 是       | 软件包渠道。                                                          |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/search"
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

响应中包含每个软件包引用的以下元数据：

- `settings`：用于软件包的构建设置。
- `options`：软件包选项。
- `requires`：软件包所需的依赖项。
- `recipe_hash`：配方的哈希值。

<a id="retrieve-package-references-metadata-by-recipe-revision"></a>

## 通过配方修订获取软件包引用元数据

获取与指定配方修订关联的所有软件包引用的元数据。

```plaintext
GET /projects/:id/packages/conan/v2/conans/:package_name/:package_version/:package_username/:package_channel/revisions/:recipe_revision/search
```

| 属性                  | 类型   | 是否必需 | 描述                                                                  |
| --------------------- | ------ | -------- | --------------------------------------------------------------------- |
| `id`                  | string | 是       | 项目 ID 或完整项目路径。                                              |
| `package_name`        | string | 是       | 软件包名称。                                                          |
| `package_version`     | string | 是       | 软件包版本。                                                          |
| `package_username`    | string | 是       | 软件包的 Conan 用户名。此属性为用 `+` 分隔的项目完整路径。            |
| `package_channel`     | string | 是       | 软件包渠道。                                                          |
| `recipe_revision`     | string | 是       | 配方的修订版本。不接受值为 `0`。                                      |

```shell
curl --header "Authorization: Bearer <authenticate_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/packages/conan/v2/conans/my-package/1.0/my-group+my-project/stable/revisions/75151329520e7685dcf5da49ded2fec0/search"
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

响应中包含每个软件包引用的以下元数据：

- `settings`：用于软件包的构建设置。
- `options`：软件包选项。
- `requires`：软件包所需的依赖项。
- `recipe_hash`：配方的哈希值。