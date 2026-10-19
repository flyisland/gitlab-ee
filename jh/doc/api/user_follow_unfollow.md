---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户关注与取消关注 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 执行用户账户的关注操作。更多信息，请参见[关注用户](../user/profile/_index.md#follow-users)。

<a id="follow-a-user"></a>

## 关注用户

关注指定的用户账户。

```plaintext
POST /users/:id/follow
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户账户 ID |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/users/3/follow"
```

响应示例：

```json
{
  "id": 1,
  "username": "john_smith",
  "name": "John Smith",
  "state": "active",
  "locked": false,
  "avatar_url": "http://localhost:3000/uploads/user/avatar/1/cd8.jpeg",
  "web_url": "http://localhost:3000/john_smith"
}
```

<a id="unfollow-a-user"></a>

## 取消关注用户

取消关注指定的用户账户。

```plaintext
POST /users/:id/unfollow
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户账户 ID |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/users/3/unfollow"
```

<a id="list-all-accounts-that-follow-a-user"></a>

## 列出关注某个用户的所有账户

列出所有关注指定用户的用户账户。

```plaintext
GET /users/:id/followers
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户账户 ID |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/users/3/followers"
```

响应示例：

```json
[
  {
    "id": 2,
    "name": "Lennie Donnelly",
    "username": "evette.kilback",
    "state": "active",
    "locked": false,
    "avatar_url": "https://www.gravatar.com/avatar/7955171a55ac4997ed81e5976287890a?s=80&d=identicon",
    "web_url": "http://127.0.0.1:3000/evette.kilback"
  },
  {
    "id": 4,
    "name": "Serena Bradtke",
    "username": "cammy",
    "state": "active",
    "locked": false,
    "avatar_url": "https://www.gravatar.com/avatar/a2daad869a7b60d3090b7b9bef4baf57?s=80&d=identicon",
    "web_url": "http://127.0.0.1:3000/cammy"
  }
]
```

<a id="list-all-accounts-followed-by-a-user"></a>

## 列出某个用户关注的所有账户

列出指定用户关注的所有用户账户。

```plaintext
GET /users/:id/following
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户账户 ID |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/users/3/following"
```