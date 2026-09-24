---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Debian API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在[功能标志](../../administration/feature_flags/_index.md)后部署，默认禁用。

{{< /history >}}

> [!warning]
> 此 API 由 Debian 相关软件包客户端使用，例如 [dput](https://manpages.debian.org/stable/dput-ng/dput.1.en.html)
> 和 [apt-get](https://manpages.debian.org/stable/apt/apt-get.8.en.html)，
> 通常不适合手动使用。此 API 正在开发中，由于功能有限，尚未准备好用于生产环境。

使用此 API 与 [Debian 软件包管理器客户端](../../user/packages/debian_repository/_index.md) 进行交互。

> [!note]
> 这些端点不遵循标准 API 认证方法。
> 有关所支持的标头和令牌类型的详细信息，请参见 [Debian 软件包仓库文档](../../user/packages/debian_repository/_index.md)。
> 未记录的认证方法将来可能会被移除。

<a id="enable-the-debian-api"></a>

## 启用 Debian API

Debian API 默认在功能标志后禁用。
[有权访问极狐GitLab Rails 控制台的极狐GitLab 管理员](../../administration/feature_flags/_index.md)
可以选择启用它。要启用它，请按照
[启用 Debian API](../../user/packages/debian_repository/_index.md#enable-the-debian-api) 中的说明操作。

<a id="enable-the-debian-group-api"></a>

## 启用 Debian 群组 API

Debian 群组 API 默认在功能标志后禁用。
[有权访问极狐GitLab Rails 控制台的极狐GitLab 管理员](../../administration/feature_flags/_index.md)
可以选择启用它。要启用它，请按照
[启用 Debian 群组 API](../../user/packages/debian_repository/_index.md#enable-the-debian-group-api) 中的说明操作。

<a id="authenticate-to-the-debian-package-repositories"></a>

### 向 Debian 软件包仓库进行身份验证

请参阅 [向 Debian 软件包仓库进行身份验证](../../user/packages/debian_repository/_index.md#authenticate-to-the-debian-package-repositories)。

<a id="upload-a-package-file"></a>

## 上传软件包文件

为指定项目上传 Debian 软件包文件。

```plaintext
PUT projects/:id/packages/debian/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整路径。 |
| `file_name` | string | 是 | Debian 软件包文件的名称。 |
| `distribution` | string | 否 | 发行版代号或套件。与 `component` 一起使用，以上传至明确的发行版和组件。 |
| `component` | string | 否 | 软件包文件组件。与 `distribution` 一起使用，以上传至明确的发行版和组件。 |

```shell
curl --request PUT \
     --user "<username>:<personal_access_token>" \
     --upload-file path/to/mypkg.deb \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/mypkg.deb"
```

使用明确的发行版和组件上传：

```shell
curl --request PUT \
  --user "<username>:<personal_access_token>" \
  --upload-file  /path/to/myother.deb \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/myother.deb?distribution=sid&component=main"
```

<a id="download-a-package"></a>

## 下载软件包

下载指定项目的软件包文件。

```plaintext
GET projects/:id/packages/debian/pool/:distribution/:letter/:package_name/:package_version/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `letter` | string | 是 | Debian 分类（首字母或 lib-首字母）。 |
| `package_name` | string | 是 | 源码软件包名称。 |
| `package_version` | string | 是 | 源码软件包版本。 |
| `file_name` | string | 是 | 文件名。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/pool/my-distro/a/my-pkg/1.0.0/example_1.0.0~alpha2_amd64.deb"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/pool/my-distro/a/my-pkg/1.0.0/example_1.0.0~alpha2_amd64.deb" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="route-prefix"></a>

## 路由前缀

以下描述的其余端点是两组相同的路由，每组在不同的范围内发起请求：

- 使用项目级前缀在单个项目范围内发起请求。
- 使用群组级前缀在单个群组范围内发起请求。

本文档中的示例均使用项目级前缀。

<a id="project-level"></a>

### 项目级

```plaintext
/projects/:id/packages/debian
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整项目路径。 |

<a id="group-level"></a>

### 群组级

```plaintext
/groups/:id/-/packages/debian
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整群组路径。 |

<a id="download-a-distribution-release-file"></a>

## 下载发行版 Release 文件

下载指定的 Debian 发行版 Release 文件。

```plaintext
GET <route-prefix>/dists/*distribution/Release
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/Release"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/Release" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-signed-distribution-release-file"></a>

## 下载已签名的发行版 Release 文件

下载指定的已签名 Debian 发行版 Release 文件。

```plaintext
GET <route-prefix>/dists/*distribution/InRelease
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/InRelease"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/InRelease" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-release-file-signature"></a>

## 下载发布文件签名

下载指定的 Debian 发布文件签名。

```plaintext
GET <route-prefix>/dists/*distribution/Release.gpg
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/Release.gpg"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/Release.gpg" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-packages-index"></a>

## 下载软件包索引

下载指定的软件包索引。

```plaintext
GET <route-prefix>/dists/*distribution/:component/binary-:architecture/Packages
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `component` | string | 是 | 发行版组件名称。 |
| `architecture` | string | 是 | 发行版架构类型。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/binary-amd64/Packages"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/binary-amd64/Packages" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-packages-index-by-hash"></a>

## 按哈希下载软件包索引

按哈希下载指定的软件包索引。

```plaintext
GET <route-prefix>/dists/*distribution/:component/binary-:architecture/by-hash/SHA256/:file_sha256

```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `component` | string | 是 | 发行版组件名称。 |
| `architecture` | string | 是 | 发行版架构类型。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/binary-amd64/by-hash/SHA256/66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/binary-amd64/by-hash/SHA256/66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-debian-installer-packages-index"></a>

## 下载 Debian 安装程序软件包索引

下载指定的 Debian 安装程序软件包索引。

```plaintext
GET <route-prefix>/dists/*distribution/:component/debian-installer/binary-:architecture/Packages
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `component` | string | 是 | 发行版组件名称。 |
| `architecture` | string | 是 | 发行版架构类型。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/debian-installer/binary-amd64/Packages"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/debian-installer/binary-amd64/Packages" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-debian-installer-packages-index-by-hash"></a>

## 按哈希下载 Debian 安装程序软件包索引

按哈希下载指定的 Debian 安装程序软件包索引。

```plaintext
GET <route-prefix>/dists/*distribution/:component/debian-installer/binary-:architecture/by-hash/SHA256/:file_sha256
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `component` | string | 是 | 发行版组件名称。 |
| `architecture` | string | 是 | 发行版架构类型。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/debian-installer/binary-amd64/by-hash/SHA256/66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/debian-installer/binary-amd64/by-hash/SHA256/66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-source-packages-index"></a>

## 下载源码软件包索引

下载指定的源码软件包索引。

```plaintext
GET <route-prefix>/dists/*distribution/:component/source/Sources
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `component` | string | 是 | 发行版组件名称。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/source/Sources"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/source/Sources" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。

<a id="download-a-source-packages-index-by-hash"></a>

## 按哈希下载源码软件包索引

按哈希下载指定的源码软件包索引。

```plaintext
GET <route-prefix>/dists/*distribution/:component/source/by-hash/SHA256/:file_sha256
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `distribution` | string | 是 | Debian 发行版的代号或套件。 |
| `component` | string | 是 | 发行版组件名称。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/source/by-hash/SHA256/66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/debian/dists/my-distro/main/source/by-hash/SHA256/66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18" \
     --remote-name
```

这会将下载的文件使用远程文件名写入当前目录。