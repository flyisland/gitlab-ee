---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Helm API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [Helm 软件包客户端](../../user/packages/helm_repository/_index.md) 进行交互。

> [!warning]
> 此 API 供 Helm 相关的软件包客户端使用，例如 [Helm](https://helm.sh/) 和 [`helm-push`](https://github.com/chartmuseum/helm-push/#readme)，通常不用于手动操作。

这些端点不遵循标准的 API 身份验证方法。有关支持的标头和令牌类型的详细信息，请参阅 [Helm 仓库文档](../../user/packages/helm_repository/_index.md)。未记录的身份验证方法将来可能会被移除。

<a id="download-a-chart-index"></a>

## 下载 chart 索引

> [!note]
> 为确保 chart 下载 URL 的一致性，`index.yaml` 响应中的 `contextPath` 字段始终使用数字项目 ID，无论您是使用项目 ID 还是完整项目路径访问 API。

下载项目的指定 chart 索引。

```plaintext
GET projects/:id/packages/helm/:channel/index.yaml
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | 字符串 | 是      | 项目的 ID 或完整路径。 |
| `channel` | 字符串 | 是      | Helm 仓库频道。 |

```shell
curl --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/helm/stable/index.yaml"
```

将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/helm/stable/index.yaml" \
     --remote-name
```

<a id="download-a-chart"></a>

## 下载 chart

下载项目的指定 chart。

```plaintext
GET projects/:id/packages/helm/:channel/charts/:file_name.tgz
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------- | ------ | -------- | ----------- |
| `id`        | 字符串 | 是      | 项目的 ID 或完整路径。 |
| `channel`   | 字符串 | 是      | Helm 仓库频道。 |
| `file_name` | 字符串 | 是      | Chart 文件名。 |

```shell
curl --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/helm/stable/charts/mychart.tgz" \
     --remote-name
```

<a id="upload-a-chart"></a>

## 上传 chart

上传项目的指定 chart。

```plaintext
POST projects/:id/packages/helm/api/:channel/charts
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | 字符串 | 是      | 项目的 ID 或完整路径。 |
| `channel` | 字符串 | 是      | Helm 仓库频道。 |
| `chart`   | 文件   | 是      | Chart（作为 `multipart/form-data`）。 |

```shell
curl --request POST \
     --form 'chart=@mychart.tgz' \
     --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/helm/api/stable/charts"
```