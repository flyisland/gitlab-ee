---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Maven API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [Maven 软件包管理器客户端](../../user/packages/maven_repository/_index.md) 交互。

> [!warning]
> 此 API 供 [Maven 软件包管理器客户端](https://maven.apache.org/) 使用，通常不用于手动操作。

这些端点不遵循标准 API 身份验证方法。请查看 [Maven 软件包仓库文档](../../user/packages/maven_repository/_index.md) 了解支持哪些标头和令牌类型。未记录的身份验证方法可能会在未来被移除。

<a id="download-a-package-file-for-an-instance"></a>

下载实例的软件包文件

为实例下载指定的 Maven 软件包文件。

```plaintext
GET packages/maven/*path/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `path`       | string | 是 | Maven 软件包路径，格式为 `<groupId>/<artifactId>/<version>`。将 `groupId` 中的任何 `.` 替换为 `/`。 |
| `file_name`  | string | 是 | Maven 软件包文件的名称。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar" >> mypkg-1.0-SNAPSHOT.jar
```

这会将下载的文件写入当前目录下的 `mypkg-1.0-SNAPSHOT.jar`。

<a id="download-a-package-file-for-a-group-level"></a>

下载群组级别的软件包文件

为群组下载指定的 Maven 软件包文件。

```plaintext
GET groups/:id/-/packages/maven/*path/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `path`       | string | 是 | Maven 软件包路径，格式为 `<groupId>/<artifactId>/<version>`。将 `groupId` 中的任何 `.` 替换为 `/`。 |
| `file_name`  | string | 是 | Maven 软件包文件的名称。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar" >> mypkg-1.0-SNAPSHOT.jar
```

这会将下载的文件写入当前目录下的 `mypkg-1.0-SNAPSHOT.jar`。

<a id="download-a-package-file-for-a-project"></a>

下载项目的软件包文件

为项目下载指定的 Maven 软件包文件。

```plaintext
GET projects/:id/packages/maven/*path/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `path`       | string | 是 | Maven 软件包路径，格式为 `<groupId>/<artifactId>/<version>`。将 `groupId` 中的任何 `.` 替换为 `/`。 |
| `file_name`  | string | 是 | Maven 软件包文件的名称。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar"
```

将输出写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar" >> mypkg-1.0-SNAPSHOT.jar
```

这会将下载的文件写入当前目录下的 `mypkg-1.0-SNAPSHOT.jar`。

<a id="upload-a-package-file"></a>

上传软件包文件

为项目上传指定的 Maven 软件包文件。

```plaintext
PUT projects/:id/packages/maven/*path/:file_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `path`       | string | 是 | Maven 软件包路径，格式为 `<groupId>/<artifactId>/<version>`。将 `groupId` 中的任何 `.` 替换为 `/`。 |
| `file_name`  | string | 是 | Maven 软件包文件的名称。 |

```shell
curl --request PUT \
     --upload-file path/to/mypkg-1.0-SNAPSHOT.pom \
     --header "PRIVATE-TOKEN: <personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/maven/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.pom"
```

