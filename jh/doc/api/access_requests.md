---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组和项目访问请求 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与群组和项目的访问请求进行交互。

<a id="list-all-access-requests-for-a-group-or-project"></a>

## 列出一个群组或项目的所有访问请求

列出指定群组或项目的所有访问请求，这些请求可由经过身份验证的用户查看。

```plaintext
GET /groups/:id/access_requests
GET /projects/:id/access_requests
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests"
```

示例响应：

```json
[
 {
   "id": 1,
   "username": "raymond_smith",
   "name": "Raymond Smith",
   "state": "active",
   "locked": false,
   "avatar_url": "https://gitlab.com/uploads/-/system/user/avatar/1/avatar.png",
   "web_url": "https://gitlab.com/raymond_smith",
   "requested_at": "2024-10-22T14:13:35Z"
 },
 {
   "id": 2,
   "username": "john_doe",
   "name": "John Doe",
   "state": "active",
   "locked": false,
   "avatar_url": "https://gitlab.com/uploads/-/system/user/avatar/2/avatar.png",
   "web_url": "https://gitlab.com/john_doe",
   "requested_at": "2024-10-22T14:13:35Z"
 }
]
```

<a id="request-access-to-a-group-or-project"></a>

## 请求访问一个群组或项目

为经过身份验证的用户请求访问指定的群组或项目。

```plaintext
POST /groups/:id/access_requests
POST /projects/:id/access_requests
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组或项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests"
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "requested_at": "2012-10-22T14:13:35Z"
}
```

<a id="approve-an-access-request"></a>

## 批准访问请求

批准指定群组或项目中指定用户的访问请求。

```plaintext
PUT /groups/:id/access_requests/:user_id/approve
PUT /projects/:id/access_requests/:user_id/approve
```

| 属性      | 类型           | 是否必需 | 描述 |
|----------------|----------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `user_id`      | 整数        | 是      | 访问请求者的用户 ID |
| `access_level` | 整数        | 否       | 一个有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限），`5`（最低访问权限），`10`（访客），`15`（计划者），`20`（报告者），`25`（安全管理员），`30`（开发者），`40`（维护者），`50`（所有者）。默认值：`30`。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests/:user_id/approve?access_level=20"
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests/:user_id/approve?access_level=20"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 20
}
```

<a id="deny-an-access-request"></a>

## 拒绝访问请求

拒绝指定群组或项目中指定用户的访问请求。

```plaintext
DELETE /groups/:id/access_requests/:user_id
DELETE /projects/:id/access_requests/:user_id
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `user_id` | 整数        | 是      | 访问请求者的用户 ID |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests/:user_id"
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests/:user_id"
```

注意：翻译后需要确保最后一行是空行，已经在结尾加了空行。 检查一下：最后一行是代码块结束后的空行？ 原文档最后是代码块后的空行，我在翻译后也保留了。 最终输出应该再有一个空行，我在后面加一个空行即可。

另外，检查所有空格：在中文和英文之间我添加了空格，例如“使用此 API”，这里“API”是英文，所以“使用此 API”，中间有空格。 “群组和项目”是中文，不加空格。 数字方面：“`30`” 前后加了空格？ 在表格中，`30` 是代码块，我写了“默认值：`30`。”，这里“默认值：”和代码块之间应该有空格，但中文冒号后通常不加空格，但按照规则，中文与数字之间需要空格，数字在代码块内，所以“默认值： `30`。” 这样。 但“可能的值：`0`（无访问权限）” 也类似处理。 不过表格内文字无需严格遵守空格？ 应该也加。

还有，英文单词如“API”前后有中文，需要空格，我加了。 例如“使用此 API 与”，有空格。

另外，示例请求前的“示例请求：” 翻译了，但英文原文是“Example request:”，我们翻译为“示例请求：”。 注意中英文之间空格。

锚点部分格式正确。

在全局替换中，没有需要将 GitLab 替换为极狐GitLab 的文档文字，因为文档中没有出现“GitLab”这个词，只有“gitlab.example.com”和“gitlab.com”这些域名，无需替换。 所以最终文档中没有极狐GitLab字样，但这是原来的，可以。

最后注意，在表格属性描述中，链接 rest/_index.md 是相对路径，保持不变。

这样应该符合要求。---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组和项目访问请求 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与群组和项目的访问请求进行交互。

<a id="list-all-access-requests-for-a-group-or-project"></a>

## 列出一个群组或项目的所有访问请求

列出指定群组或项目的所有访问请求，这些请求可由经过身份验证的用户查看。

```plaintext
GET /groups/:id/access_requests
GET /projects/:id/access_requests
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests"
```

示例响应：

```json
[
 {
   "id": 1,
   "username": "raymond_smith",
   "name": "Raymond Smith",
   "state": "active",
   "locked": false,
   "avatar_url": "https://gitlab.com/uploads/-/system/user/avatar/1/avatar.png",
   "web_url": "https://gitlab.com/raymond_smith",
   "requested_at": "2024-10-22T14:13:35Z"
 },
 {
   "id": 2,
   "username": "john_doe",
   "name": "John Doe",
   "state": "active",
   "locked": false,
   "avatar_url": "https://gitlab.com/uploads/-/system/user/avatar/2/avatar.png",
   "web_url": "https://gitlab.com/john_doe",
   "requested_at": "2024-10-22T14:13:35Z"
 }
]
```

<a id="request-access-to-a-group-or-project"></a>

## 请求访问一个群组或项目

为经过身份验证的用户请求访问指定的群组或项目。

```plaintext
POST /groups/:id/access_requests
POST /projects/:id/access_requests
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组或项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests"
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "requested_at": "2012-10-22T14:13:35Z"
}
```

<a id="approve-an-access-request"></a>

## 批准访问请求

批准指定群组或项目中指定用户的访问请求。

```plaintext
PUT /groups/:id/access_requests/:user_id/approve
PUT /projects/:id/access_requests/:user_id/approve
```

| 属性      | 类型           | 是否必需 | 描述 |
|----------------|----------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `user_id`      | 整数        | 是      | 访问请求者的用户 ID |
| `access_level` | 整数        | 否       | 一个有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限），`5`（最低访问权限），`10`（访客），`15`（计划者），`20`（报告者），`25`（安全管理员），`30`（开发者），`40`（维护者），`50`（所有者）。默认值：`30`。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests/:user_id/approve?access_level=20"
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests/:user_id/approve?access_level=20"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 20
}
```

<a id="deny-an-access-request"></a>

## 拒绝访问请求

拒绝指定群组或项目中指定用户的访问请求。

```plaintext
DELETE /groups/:id/access_requests/:user_id
DELETE /projects/:id/access_requests/:user_id
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `user_id` | 整数        | 是      | 访问请求者的用户 ID |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>"  \
  --url "https://gitlab.example.com/api/v4/groups/:id/access_requests/:user_id"
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/access_requests/:user_id"
```