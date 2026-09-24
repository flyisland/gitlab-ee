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

{{< history >}}

- 引入于 极狐GitLab 16.4，通过名为 `ssh_certificates_rest_endpoints` 的功能标志，默认禁用。
- 于 极狐GitLab 16.9 在 JihuLab.com 上启用。
- 于 极狐GitLab 17.7 GA。功能标志 `ssh_certificates_rest_endpoints` 已移除。

{{< /history >}}

使用此 API 管理[群组的 SSH 证书](../user/group/ssh_certificates.md)。
只有顶级群组可以存储 SSH 证书。

前提条件：

- 您必须是顶级群组的所有者。

<a id="list-all-group-ssh-certificates"></a>

## 列出所有群组 SSH 证书

列出指定群组的所有 SSH 证书。

```plaintext
GET /groups/:id/ssh_certificates
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| ---------- | ------ | -------- |----------------------|
| `id` | integer | 是 | 群组的 ID。 |

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果会分页。
阅读更多关于[分页](rest/_index.md#pagination)的信息。

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
    "key": "ssh-rsa AAAAB3NzaC1ea2dAAAADAQABAAAAgQDGbLkF44ScxRQi2FfA7VsHgGqptguSbmW26jkJhEiRZpGS4/+UzaaSqc8Psw2OhSsKc5QwfrB/ANpO4LhOjDzhf2FuD8ACkv3R7XtaJ+rN6PlyzoBfLAiSyzxhEoMFDBprTgaiZKgg2yQ9dRH55w3f6XMZ4hnaUae53nQgfQLxFw== example@gitlab.com",
    "created_at": "2023-09-08T12:39:00.172Z"
  },
  {
    "id":12346,
    "title":"SSH Title 2",
    "key": "ssh-rsa AAAAB3NzaC1ac2EAAAADAQABAAAAgQDTl/hHfu1F/KlR+QfgM2wUmyxcN5YeiaWluEGIrfXUeJuI+bK6xjpE3+2afHDYtE9VQkeL32KRjefX2d72Jeoa68ewt87Vn8CcGkUTOTpHNzeL8pHMKFs3m7ArSBxNg5vTdgAsq5dbDGNtat7b2WCHTNvtWoON1Jetne30uW2EwQ== example@gitlab.com",
    "created_at": "2023-09-08T12:39:00.244Z"
  }
]
```

<a id="add-a-group-ssh-certificate"></a>

## 添加群组 SSH 证书

为指定群组添加一个 SSH 证书。

```plaintext
POST /groups/:id/ssh_certificates
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------------| -------- |---------------------------------------|
| `id` | integer | 是 | 群组的 ID。 |
| `key` | string | 是 | SSH 证书的公钥。 |
| `title` | string | 是 | SSH 证书的标题。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/ssh_certificates?title=newtitle&key=ssh-rsa+REDACTED+example%40gitlab.com"
```

示例响应：

```json
{
  "id": 54321,
  "title": "newtitle",
  "key": "ssh-rsa ssh-rsa AAAAB3NzaC1ea2dAAAADAQABAAAAgQDGbLkF44ScxRQi2FfA7VsHgGqptguSbmW26jkJhEiRZpGS4/+UzaaSqc8Psw2OhSsKc5QwfrB/ANpO4LhOjDzhf2FuD8ACkv3R7XtaJ+rN6PlyzoBfLAiSyzxhEoMFDBprTgaiZKgg2yQ9dRH55w3f6XMZ4hnaUae53nQgfQLxFw== example@gitlab.com",
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

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|---------| -------- |-------------------------------|
| `id` | integer | 是 | 群组的 ID |
| `id` | integer | 是 | SSH 证书的 ID |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/ssh_certificates/12345"
```

