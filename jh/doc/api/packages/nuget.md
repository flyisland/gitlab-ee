---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: NuGet API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [NuGet 包管理客户端](../../user/packages/nuget_repository/_index.md) 进行交互。

> [!warning]
> 此 API 由 [NuGet 包管理客户端](https://www.nuget.org/) 使用，通常不适用于手动使用。

这些端点不遵循标准的 API 认证方法。有关支持哪些标头和令牌类型的详细信息，请参见 [NuGet 软件包仓库文档](../../user/packages/nuget_repository/_index.md)。未记录的认证方法将来可能会被移除。

<a id="retrieve-a-package-index"></a>

## 检索软件包索引

检索指定软件包的索引，包括可用版本的列表。

```plaintext
GET projects/:id/packages/nuget/download/:package_name/index
```

| 属性 | 类型 | 是否必填 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整路径。 |
| `package_name` | string | 是 | 软件包的名称。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/index"
```

示例响应：

```json
{
  "versions": [
    "1.3.0.17"
  ]
}
```

<a id="download-a-package-file"></a>

## 下载软件包文件

为项目下载指定的 NuGet 软件包文件。[元数据服务](#retrieve-package-metadata) 提供此 URL。

```plaintext
GET projects/:id/packages/nuget/download/:package_name/:package_version/:package_filename
```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整路径。 |
| `package_name` | string | 是 | 软件包的名称。 |
| `package_version` | string | 是 | 软件包的版本。 |
| `package_filename` | string | 是 | 文件的名称。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/1.3.0.17/mynugetpkg.1.3.0.17.nupkg"
```

将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/1.3.0.17/mynugetpkg.1.3.0.17.nupkg" > MyNuGetPkg.1.3.0.17.nupkg
```

这将把下载的文件 `MyNuGetPkg.1.3.0.17.nupkg` 写入当前目录。

> [!note]
> 当您使用 [群组端点](#group-level) 时，此 API 返回 `404` 状态。请使用 NuGet 包管理 CLI 通过群组端点 [安装软件包](../../user/packages/nuget_repository/_index.md#install-a-package)，以避免此错误。

<a id="upload-a-package-file"></a>

## 上传软件包文件

{{< history >}}

- 在极狐GitLab 16.2 中为 NuGet v2 feed 引入。

{{< /history >}}

为指定项目上传 NuGet 软件包文件。

- 对于 NuGet v3 feed：

  ```plaintext
  PUT projects/:id/packages/nuget
  ```

- 对于 NuGet V2 feed：

  ```plaintext
  PUT projects/:id/packages/nuget/v2
  ```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整路径。 |
| `package_name` | string | 是 | 软件包的名称。 |
| `package_version` | string | 是 | 软件包的版本。 |
| `package_filename` | string | 是 | 文件的名称。 |

- 对于 NuGet v3 feed：

  ```shell
  curl --request PUT \
      --form 'package=@path/to/mynugetpkg.1.3.0.17.nupkg' \
      --user <username>:<personal_access_token> \
      --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/"
  ```

- 对于 NuGet v2 feed：

  ```shell
  curl --request PUT \
      --form 'package=@path/to/mynugetpkg.1.3.0.17.nupkg' \
      --user <username>:<personal_access_token> \
      --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2"
  ```

<a id="upload-a-symbol-package-file"></a>

## 上传符号包文件

为项目上传指定的 NuGet 符号包文件 (`.snupkg`)。

```plaintext
PUT projects/:id/packages/nuget/symbolpackage
```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整路径。 |
| `package_name` | string | 是 | 软件包的名称。 |
| `package_version` | string | 是 | 软件包的版本。 |
| `package_filename` | string | 是 | 文件的名称。 |

```shell
curl --request PUT \
     --form 'package=@path/to/mynugetpkg.1.3.0.17.snupkg' \
     --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/symbolpackage"
```

<a id="route-prefix"></a>

## 路由前缀

对于剩余的路由，有两组相同的路由，各自在不同的范围内发出请求：

- 使用群组级前缀在群组范围内发出请求。
- 使用项目级前缀在单个项目范围内发出请求。

本文档中的示例均使用项目级前缀。

<a id="group-level"></a>

### 群组级

```plaintext
/groups/:id/-/packages/nuget
```

| 属性 | 类型 | 是否必填 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | string | 是 | 群组 ID 或完整群组路径。 |

<a id="project-level"></a>

### 项目级

```plaintext
/projects/:id/packages/nuget
```

| 属性 | 类型 | 是否必填 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整项目路径。 |

<a id="service-index"></a>

## 服务索引

<a id="v2-source-feedprotocol"></a>

### V2 源 feed/协议

检索表示 v2 NuGet 源 feed 的服务索引的 XML 文档。无需认证。

```plaintext
GET <route-prefix>/v2
```

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2"
```

示例响应：

```xml
<?xml version="1.0" encoding="utf-8"?>
<service xmlns="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom" xml:base="https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2">
  <workspace>
    <atom:title type="text">默认</atom:title>
    <collection href="Packages">
      <atom:title type="text">软件包</atom:title>
    </collection>
  </workspace>
</service>
```

<a id="v3-source-feedprotocol"></a>

### V3 源 feed/协议

{{< history >}}

- 在极狐GitLab 16.1 中变更为公开。

{{< /history >}}

检索可用 API 资源的列表。无需认证。

```plaintext
GET <route-prefix>/index
```

示例请求：

```shell
curl --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/index"
```

示例响应：

```json
{
  "version": "3.0.0",
  "resources": [
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/query",
      "@type": "SearchQueryService",
      "comment": "按关键字筛选和搜索软件包。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/query",
      "@type": "SearchQueryService/3.0.0-beta",
      "comment": "按关键字筛选和搜索软件包。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/query",
      "@type": "SearchQueryService/3.0.0-rc",
      "comment": "按关键字筛选和搜索软件包。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata",
      "@type": "RegistrationsBaseUrl",
      "comment": "获取软件包元数据。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata",
      "@type": "RegistrationsBaseUrl/3.0.0-beta",
      "comment": "获取软件包元数据。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata",
      "@type": "RegistrationsBaseUrl/3.0.0-rc",
      "comment": "获取软件包元数据。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download",
      "@type": "PackageBaseAddress/3.0.0",
      "comment": "获取软件包内容 (.nupkg)。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget",
      "@type": "PackagePublish/2.0.0",
      "comment": "推送和删除（或取消列出）软件包。"
    },
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/symbolpackage",
      "@type": "SymbolPackagePublish/4.9.0",
      "comment": "推送符号包。"
    }
  ]
}
```

响应中的 URL 与用于请求它们的路由前缀相同。如果您使用群组级路由请求它们，则返回的 URL 包含 `/groups/:id/-`。

<a id="retrieve-package-metadata"></a>

## 检索软件包元数据

检索指定软件包的元数据。

```plaintext
GET <route-prefix>/metadata/:package_name/index
```

| 属性 | 类型 | 是否必填 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `package_name` | string | 是 | 软件包的名称。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/index"
```

示例响应：

```json
{
  "count": 1,
  "items": [
    {
      "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17.json",
      "lower": "1.3.0.17",
      "upper": "1.3.0.17",
      "count": 1,
      "items": [
        {
          "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17.json",
          "packageContent": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/1.3.0.17/helloworld.1.3.0.17.nupkg",
          "catalogEntry": {
            "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17.json",
            "authors": "Author1, Author2",
            "dependencyGroups": [],
            "id": "MyNuGetPkg",
            "version": "1.3.0.17",
            "tags": "",
            "packageContent": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/1.3.0.17/helloworld.1.3.0.17.nupkg",
            "description": "软件包的描述",
            "summary": "软件包的描述",
            "published": "2023-05-08T17:23:25Z",
          }
        }
      ]
    }
  ]
}
```

<a id="retrieve-version-metadata"></a>

## 检索版本元数据

检索指定软件包版本的元数据。

```plaintext
GET <route-prefix>/metadata/:package_name/:package_version
```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `package_name` | string | 是 | 软件包的名称。 |
| `package_version` | string | 是 | 软件包的版本。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17"
```

示例响应：

```json
{
  "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17.json",
  "packageContent": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/1.3.0.17/helloworld.1.3.0.17.nupkg",
  "catalogEntry": {
    "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17.json",
    "authors": "Author1, Author2",
    "dependencyGroups": [],
    "id": "MyNuGetPkg",
    "version": "1.3.0.17",
    "tags": "",
    "packageContent": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/MyNuGetPkg/1.3.0.17/helloworld.1.3.0.17.nupkg",
    "description": "软件包的描述",
    "summary": "软件包的描述",
    "published": "2023-05-08T17:23:25Z",
  }
}
```

<a id="search-for-packages"></a>

## 搜索软件包

根据指定查询搜索仓库中的 NuGet 软件包。

```plaintext
GET <route-prefix>/query
```

| 属性 | 类型 | 是否必填 | 描述 |
| ------------ | ------- | -------- | ----------- |
| `q` | string | 是 | 搜索查询。 |
| `skip` | integer | 否 | 跳过的结果数量。 |
| `take` | integer | 否 | 返回的结果数量。 |
| `prerelease` | boolean | 否 | 包含预发布版本。如果未提供值，则默认为 `true`。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/query?q=MyNuGet"
```

示例响应：

```json
{
  "totalHits": 1,
  "data": [
    {
      "@type": "Package",
      "authors": "Author1, Author2",
      "id": "MyNuGetPkg",
      "title": "MyNuGetPkg",
      "description": "软件包的描述",
      "summary": "软件包的描述",
      "totalDownloads": 0,
      "verified": true,
      "version": "1.3.0.17",
      "versions": [
        {
          "@id": "https://gitlab.example.com/api/v4/projects/1/packages/nuget/metadata/MyNuGetPkg/1.3.0.17.json",
          "version": "1.3.0.17",
          "downloads": 0
        }
      ],
      "tags": ""
    }
  ]
}
```

<a id="delete-a-package"></a>

## 删除软件包

{{< history >}}

- 在极狐GitLab 16.5 中引入。

{{< /history >}}

删除指定的 NuGet 软件包。

```plaintext
DELETE projects/:id/packages/nuget/:package_name/:package_version
```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id` | string | 是 | 项目 ID 或完整路径。 |
| `package_name` | string | 是 | 软件包的名称。 |
| `package_version` | string | 是 | 软件包的版本。 |

```shell
curl --request DELETE \
     --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/MyNuGetPkg/1.3.0.17"
```

可能的请求响应：

| 状态 | 描述 |
| ------ | ----------- |
| `204` | 软件包已删除 |
| `401` | 未授权 |
| `403` | 禁止访问 |
| `404` | 未找到 |

<a id="download-a-debugging-symbol-file-pdb"></a>

## 下载调试符号文件 `.pdb`

{{< history >}}

- 在极狐GitLab 16.7 中引入。

{{< /history >}}

下载指定的调试符号文件 (`.pdb`)。

```plaintext
GET <route-prefix>/symbolfiles/:file_name/:signature/:file_name
```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `file_name` | string | 是 | 文件的名称。 |
| `signature` | string | 是 | 文件的签名。 |
| `Symbolchecksum` | string | 是 | 必需的标头。文件的校验和。 |

```shell
curl --header "Symbolchecksum: SHA256:<file_checksum>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/symbolfiles/:file_name/:signature/:file_name"
```

将输出写入文件：

```shell
curl --header "Symbolchecksum: SHA256:<file_checksum>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/symbolfiles/mynugetpkg.pdb/k813f89485474661234z7109cve5709eFFFFFFFF/mynugetpkg.pdb" > mynugetpkg.pdb
```

可能的请求响应：

| 状态 | 描述 |
| ------ | ----------- |
| `200` | 文件已下载 |
| `400` | 错误的请求 |
| `403` | 禁止访问 |
| `404` | 未找到 |

<a id="v2-feed-metadata-endpoints"></a>

## V2 Feed 元数据端点

{{< history >}}

- 在极狐GitLab 16.3 中引入。

{{< /history >}}

<a id="metadata-endpoint"></a>

### `$metadata` 端点

无需认证。返回 V2 feed 可用端点的元数据：

```plaintext
GET <route-prefix>/v2/$metadata
```

```shell
curl --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2/$metadata"
```

示例响应：

```xml
<edmx:Edmx xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx" Version="1.0">
  <edmx:DataServices xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" m:DataServiceVersion="2.0" m:MaxDataServiceVersion="2.0">
    <Schema xmlns="http://schemas.microsoft.com/ado/2006/04/edm" Namespace="NuGetGallery.OData">
      <EntityType Name="V2FeedPackage" m:HasStream="true">
        <Key>
          <PropertyRef Name="Id"/>
          <PropertyRef Name="Version"/>
        </Key>
        <Property Name="Id" Type="Edm.String" Nullable="false"/>
        <Property Name="Version" Type="Edm.String" Nullable="false"/>
        <Property Name="Authors" Type="Edm.String"/>
        <Property Name="Dependencies" Type="Edm.String"/>
        <Property Name="Description" Type="Edm.String"/>
        <Property Name="DownloadCount" Type="Edm.Int64" Nullable="false"/>
        <Property Name="IconUrl" Type="Edm.String"/>
        <Property Name="Published" Type="Edm.DateTime" Nullable="false"/>
        <Property Name="ProjectUrl" Type="Edm.String"/>
        <Property Name="Tags" Type="Edm.String"/>
        <Property Name="Title" Type="Edm.String"/>
        <Property Name="LicenseUrl" Type="Edm.String"/>
      </EntityType>
    </Schema>
    <Schema xmlns="http://schemas.microsoft.com/ado/2006/04/edm" Namespace="NuGetGallery">
      <EntityContainer Name="V2FeedContext" m:IsDefaultEntityContainer="true">
        <EntitySet Name="Packages" EntityType="NuGetGallery.OData.V2FeedPackage"/>
        <FunctionImport Name="FindPackagesById" ReturnType="Collection(NuGetGallery.OData.V2FeedPackage)" EntitySet="Packages">
          <Parameter Name="id" Type="Edm.String" FixedLength="false" Unicode="false"/>
        </FunctionImport>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>
```

<a id="odata-package-entry-endpoints"></a>

### OData 软件包条目端点

{{< history >}}

- 在极狐GitLab 16.4 中引入。

{{< /history >}}

| 端点 | 描述 |
| -------- | ----------- |
| `GET projects/:id/packages/nuget/v2/Packages()?$filter=(tolower(Id) eq '<package_name>')` | 返回 OData XML 文档，其中包含具有给定名称的软件包的信息。 |
| `GET projects/:id/packages/nuget/v2/FindPackagesById()?id='<package_name>'` | 返回 OData XML 文档，其中包含具有给定名称的软件包的信息。 |
| `GET projects/:id/packages/nuget/v2/Packages(Id='<package_name>',Version='<package_version>')` | 返回 OData XML 文档，其中包含具有给定名称和版本的软件包的信息。 |

```shell
curl --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2/Packages(Id='mynugetpkg',Version='1.0.0')"
```

示例响应：

```xml
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xml:base="https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2">
    <id>https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2/Packages(Id='mynugetpkg',Version='1.0.0')</id>
    <category term="V2FeedPackage" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
    <title type="text">mynugetpkg</title>
    <content type="application/zip" src="https://gitlab.example.com/api/v4/projects/1/packages/nuget/download/mynugetpkg/1.0.0/mynugetpkg.1.0.0.nupkg"/>
    <m:properties>
      <d:Version>1.0.0</d:Version>
    </m:properties>
 </entry>
```

> [!note]
> 极狐GitLab 不会收到 `Packages()` 和 `FindPackagesByID()` 端点的认证令牌，因此无法返回软件包的最新版本。当您使用 NuGet v2 feed 安装或升级软件包时，必须提供版本。

```shell
curl --url "https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2/Packages()?$filter=(tolower(Id) eq 'mynugetpkg')"
```

示例响应：

```xml
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xml:base="https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2">
    <id>https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2/Packages(Id='mynugetpkg',Version='')</id>
    <category term="V2FeedPackage" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
    <title type="text">mynugetpkg</title>
    <content type="application/zip" src="https://gitlab.example.com/api/v4/projects/1/packages/nuget/v2"/>
    <m:properties>
      <d:Version></d:Version>
    </m:properties>
 </entry>
```