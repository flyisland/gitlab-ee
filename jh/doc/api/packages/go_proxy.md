---
stage: Package
group: 软件包仓库
info: 要确定与此页面关联的 Stage/Group 的技术文档作者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Go 代理 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与 [Go 软件包管理器客户端](../../user/packages/go_proxy/_index.md) 进行交互。
此 API 受功能标志控制，该功能标志默认处于禁用状态。有权访问
GitLab Rails 控制台的极狐GitLab 管理员可以为您的极狐GitLab 实例 [启用](../../administration/feature_flags/_index.md)
此 API。

> [!warning]
> 此 API 由 [`go` 命令](https://go.dev/ref/mod#go-get) 使用
> 一般不用于手动调用。

这些端点不遵循标准的 API 认证方法。
有关支持哪些标头和令牌类型的详细信息，请参阅 [Go 代理软件包文档](../../user/packages/go_proxy/_index.md)。
未记录的认证方法将来可能会被移除。

<a id="list"></a>

## 列表

获取给定 Go 模块的所有标记版本：

```plaintext
GET projects/:id/packages/go/:module_name/@v/list
```

| 属性      | 类型   | 必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `id`           | string | 是      | 项目的 ID 或完整路径。 |
| `module_name`  | string | 是      | Go 模块的名称。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/list"
```

示例输出：

```shell
"v1.0.0\nv1.0.1\nv1.3.8\n2.0.0\n2.1.0\n3.0.0"
```

<a id="version-metadata"></a>

## 版本元数据

获取给定 Go 模块的所有标记版本：

```plaintext
GET projects/:id/packages/go/:module_name/@v/:module_version.info
```

| 属性         | 类型   | 必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id`              | string | 是      | 项目的 ID 或完整路径。 |
| `module_name`     | string | 是      | Go 模块的名称。 |
| `module_version`  | string | 是      | Go 模块的版本。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.info"
```

示例输出：

```json
{
  "Version": "v1.0.0",
  "Time": "1617822312 -0600"
}
```

<a id="download-module-file"></a>

## 下载模块文件

获取 `.mod` 模块文件：

```plaintext
GET projects/:id/packages/go/:module_name/@v/:module_version.mod
```

| 属性         | 类型   | 必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id`              | string | 是      | 项目的 ID 或完整路径。 |
| `module_name`     | string | 是      | Go 模块的名称。 |
| `module_version`  | string | 是      | Go 模块的版本。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.mod"
```

写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.mod" >> foo.mod
```

这会将内容写入当前目录的 `foo.mod` 文件中。

<a id="download-module-source"></a>

## 下载模块源码

获取模块源码的 `.zip` 文件：

```plaintext
GET projects/:id/packages/go/:module_name/@v/:module_version.zip
```

| 属性         | 类型   | 必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id`              | string | 是      | 项目的 ID 或完整路径。 |
| `module_name`     | string | 是      | Go 模块的名称。 |
| `module_version`  | string | 是      | Go 模块的版本。 |

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.zip"
```

写入文件：

```shell
curl --header "PRIVATE-TOKEN: <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/go/my-go-module/@v/1.0.0.zip" >> foo.zip
```

这会将内容写入当前目录的 `foo.zip` 文件中。