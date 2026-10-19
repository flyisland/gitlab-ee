---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 发布链接 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.1 中添加了通过[极狐GitLab CI/CD 作业令牌](../../ci/jobs/ci_job_token.md)进行身份验证的功能。

{{< /history >}}

使用此 API 与[发布](../../user/project/releases/_index.md)的链接进行交互。

极狐GitLab 支持以下协议的资产链接：

- `http`
- `https`
- `ftp`

> [!note]
> 要直接与项目发布交互，请参阅[项目发布 API](_index.md)。

<a id="list-all-release-links"></a>

## 列出所有发布链接

列出发布中所有资产链接。

```plaintext
GET /projects/:id/releases/:tag_name/assets/links
```

| 属性 | 类型 | 是否必需 | 描述 |
| ------------- | -------------- | -------- | --------------------------------------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串 | 是 | 与发布关联的标签。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1/assets/links"
```

示例响应：

```json
[
   {
      "id":2,
      "name":"awesome-v0.2.msi",
      "url":"http://192.168.10.15:3000/msi",
      "link_type":"other"
   },
   {
      "id":1,
      "name":"awesome-v0.2.dmg",
      "url":"http://192.168.10.15:3000",
      "link_type":"other"
   }
]
```

<a id="retrieve-a-release-link"></a>

## 获取一个发布链接

获取发布中指定的资产链接。

```plaintext
GET /projects/:id/releases/:tag_name/assets/links/:link_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| ------------- | -------------- | -------- | --------------------------------------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串 | 是 | 与发布关联的标签。 |
| `link_id` | 整数 | 是 | 链接的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1/assets/links/1"
```

示例响应：

```json
{
   "id":1,
   "name":"awesome-v0.2.dmg",
   "url":"http://192.168.10.15:3000",
   "link_type":"other"
}
```

<a id="create-a-release-link"></a>

## 创建发布链接

为指定发布创建资产链接。

```plaintext
POST /projects/:id/releases/:tag_name/assets/links
```

| 属性 | 类型 | 是否必需 | 描述 |
|----------------------|----------------|----------|---------------------------------------------------------------------------------------------------------------------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串 | 是 | 与发布关联的标签。 |
| `name` | 字符串 | 是 | 链接的名称。链接名称在发布内必须唯一。 |
| `url` | 字符串 | 是 | 链接的 URL。链接 URL 在发布内必须唯一。 |
| `direct_asset_path` | 字符串 | 否 | 可选路径，用于[直接资产链接](../../user/project/releases/release_fields.md#permanent-links-to-release-assets)。 |
| `link_type` | 字符串 | 否 | 链接类型：`other`、`runbook`、`image`、`package`。默认为 `other`。 |

示例请求：

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --data name="hellodarwin-amd64" \
    --data url="https://gitlab.example.com/mynamespace/hello/-/jobs/688/artifacts/raw/bin/hello-darwin-amd64" \
    --data direct_asset_path="/bin/hellodarwin-amd64" \
    "https://gitlab.example.com/api/v4/projects/20/releases/v1.7.0/assets/links"
```

示例响应：

```json
{
   "id":2,
   "name":"hellodarwin-amd64",
   "url":"https://gitlab.example.com/mynamespace/hello/-/jobs/688/artifacts/raw/bin/hello-darwin-amd64",
   "direct_asset_url":"https://gitlab.example.com/mynamespace/hello/-/releases/v1.7.0/downloads/bin/hellodarwin-amd64",
   "link_type":"other"
}
```

<a id="update-a-release-link"></a>

## 更新发布链接

更新发布中指定的资产链接。

```plaintext
PUT /projects/:id/releases/:tag_name/assets/links/:link_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| -------------------- | -------------- | -------- | ------------------------------------------------------------------------------------------------------------------------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串 | 是 | 与发布关联的标签。 |
| `link_id` | 整数 | 是 | 链接的 ID。 |
| `name` | 字符串 | 否 | 链接的名称。 |
| `url` | 字符串 | 否 | 链接的 URL。 |
| `direct_asset_path` | 字符串 | 否 | 可选路径，用于[直接资产链接](../../user/project/releases/release_fields.md#permanent-links-to-release-assets)。 |
| `link_type` | 字符串 | 否 | 链接类型：`other`、`runbook`、`image`、`package`。默认为 `other`。 |

> [!note]
> 你必须至少指定 `name` 或 `url` 中的一个。

示例请求：

```shell
curl --request PUT --data name="new name" --data link_type="runbook" \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     "https://gitlab.example.com/api/v4/projects/24/releases/v0.1/assets/links/1"
```

示例响应：

```json
{
   "id":1,
   "name":"new name",
   "url":"http://192.168.10.15:3000",
   "link_type":"runbook"
}
```

<a id="delete-a-release-link"></a>

## 删除发布链接

删除发布中指定的资产链接。

```plaintext
DELETE /projects/:id/releases/:tag_name/assets/links/:link_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| ------------- | -------------- | -------- | --------------------------------------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `tag_name` | 字符串 | 是 | 与发布关联的标签。 |
| `link_id` | 整数 | 是 | 链接的 ID。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1/assets/links/1"
```

示例响应：

```json
{
   "id":1,
   "name":"new name",
   "url":"http://192.168.10.15:3000",
   "link_type":"other"
}
```