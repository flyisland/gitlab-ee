---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 SSH 证书 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用此 API 管理[群组的 SSH 证书](../user/group/ssh_certificates.md)。只有顶级群组可以存储 SSH 证书。

先决条件：

- 您必须是顶级群组的所有者。

<a id="list-all-group-ssh-certificates"></a>

## 列出所有群组 SSH 证书

列出指定群组的所有 SSH 证书。

```plaintext
GET /groups/:id/ssh_certificates
```

参数：

| 属性  | 类型   | 是否必需 | 描述          |
| ---------- | ------ | -------- |----------------------|
| `id`      | integer | 是       | 群组的 ID。 |

默认情况下，`GET` 请求每次返回 20 条结果，因为 API 结果已分页。阅读更多关于[分页](rest/_index.md#pagination)的内容。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/groups/90/ssh_certificates"
```

示例响应：

```json
[
  {
    "id": 12345,
    "title": "SSH Title 1",
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKW2o6syFnRbO6D++jJHc3Eqj1k+XspAgCvLq8lXlDUj ca@example.com",
    "fingerprint": "SHA256:1CrrRznEotAVn+wfXVzYlDCaVcGoTvHIup4eNWBPK2k",
    "created_at": "2023-09-08T12:39:00.172Z"
  },
  {
    "id":12346,
    "title":"SSH Title 2",
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJfRGzblvgogdxwPnwsH+h4U5eo+xOzGru08CCaezaL ca@example.com",
    "fingerprint": "SHA256:/P+kBF3hlgEYGohCvKCLQXewtPcI+4B4phcctFeExG8",
    "created_at": "2023-09-08T12:39:00.244Z"
  }
]
```

<a id="add-a-group-ssh-certificate"></a>

## 添加群组 SSH 证书

为指定群组添加群组 SSH 证书。

```plaintext
POST /groups/:id/ssh_certificates
```

参数：

| 属性 | 类型       | 是否必需 | 描述                           |
|-----------|------------| -------- |---------------------------------------|
| `id`      | integer    | 是       | 群组的 ID。                  |
| `key`     | string     | 是       | SSH 证书的公钥。|
| `title`   | string     | 是       | SSH 证书的标题。     |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data-urlencode "title=newtitle" \
  --data-urlencode "key=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKW2o6syFnRbO6D++jJHc3Eqj1k+XspAgCvLq8lXlDUj ca@example.com" \
  --url "https://gitlab.example.com/api/v4/groups/5/ssh_certificates"
```

示例响应：

```json
{
  "id": 54321,
  "title": "newtitle",
  "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKW2o6syFnRbO6D++jJHc3Eqj1k+XspAgCvLq8lXlDUj ca@example.com",
  "fingerprint": "SHA256:1CrrRznEotAVn+wfXVzYlDCaVcGoTvHIup4eNWBPK2k",
  "created_at": "2023-09-08T12:39:00.172Z"
}
```

<a id="delete-a-group-ssh-certificate"></a>

## 删除群组 SSH 证书

删除指定的群组 SSH 证书。

```plaintext
DELETE /groups/:id/ssh_certificates/:id
```

参数：

| 属性 | 类型    | 是否必需 | 描述                   |
|-----------|---------| -------- |-------------------------------|
| `id`      | integer | 是       | 群组的 ID           |
| `id`      | integer | 是       | SSH 证书的 ID |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/ssh_certificates/12345"
```
