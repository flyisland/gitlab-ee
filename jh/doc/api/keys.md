---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 密钥 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 检索有关 [SSH 密钥](../user/ssh.md) 的信息。关于部署密钥指纹的查询也会检索使用该密钥的项目信息。

如果您在 API 调用中使用 SHA256 指纹，则应对指纹进行 URL 编码。

<a id="retrieve-user-by-ssh-key-id"></a>

## 通过 SSH 密钥 ID 检索用户

前提条件：

- 您必须具有实例的管理员访问权限。

检索拥有指定 SSH 密钥的用户的信息。

```plaintext
GET /keys/:id
```

支持的属性：

| 属性    | 类型    | 是否必需 | 描述               |
|---------|---------|----------|--------------------|
| `id`    | integer | 是       | SSH 密钥的 ID。    |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性               | 类型    | 描述 |
|--------------------|---------|-------------|
| `created_at`       | string  | SSH 密钥的创建日期和时间，ISO 8601 格式。 |
| `expires_at`       | string  | SSH 密钥的过期日期和时间，ISO 8601 格式。 |
| `id`               | integer | SSH 密钥的 ID。 |
| `key`              | string  | SSH 密钥内容。 |
| `last_used_at`     | string  | SSH 密钥的最后使用日期和时间，ISO 8601 格式。 |
| `title`            | string  | SSH 密钥的标题。 |
| `usage_type`       | string  | SSH 密钥的使用类型（例如，`auth` 或 `auth_and_signing`）。 |
| `user`             | object  | 与 SSH 密钥关联的用户。 |
| `user.avatar_url`  | string  | 用户头像的 URL。 |
| `user.bio`         | string  | 用户的个人简介。 |
| `user.created_at`  | string  | 用户账户的创建日期和时间，ISO 8601 格式。 |
| `user.id`          | integer | 用户的 ID。 |
| `user.linkedin`    | string  | 用户的 LinkedIn 个人资料 URL。 |
| `user.location`    | string  | 用户的位置。 |
| `user.name`        | string  | 用户的姓名。 |
| `user.organization`| string  | 用户所属组织。 |
| `user.public_email`| string  | 用户的公开电子邮件地址。 |
| `user.state`       | string  | 用户的状态。 |
| `user.twitter`     | string  | 用户的 Twitter 个人资料 URL。 |
| `user.username`    | string  | 用户名。 |
| `user.web_url`     | string  | 用户个人资料的 URL。 |
| `user.website_url` | string  | 用户网站的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/keys/1"
```

响应示例：

```json
{
  "id": 1,
  "title": "Sample key 25",
  "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt1256k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
  "created_at": "2015-09-03T07:24:44.627Z",
  "expires_at": "2020-05-05T00:00:00.000Z",
  "last_used_at": "2020-04-07T00:00:00.000Z",
  "usage_type": "auth",
  "user": {
    "name": "John Smith",
    "username": "john_smith",
    "id": 25,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/cfa35b8cd2ec278026357769582fa563?s=40\u0026d=identicon",
    "web_url": "http://localhost:3000/john_smith",
    "created_at": "2015-09-03T07:24:01.670Z",
    "bio": null,
    "location": null,
    "public_email": "john@example.com",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "last_sign_in_at": "2015-09-03T07:24:01.670Z",
    "confirmed_at": "2015-09-03T07:24:01.670Z",
    "last_activity_on": "2015-09-03",
    "email": "john@example.com",
    "theme_id": 2,
    "color_scheme_id": 1,
    "projects_limit": 10,
    "current_sign_in_at": null,
    "identities": [],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": false,
    "external": false,
    "private_profile": null
  }
}
```

<a id="retrieve-user-by-ssh-key-fingerprint"></a>

## 通过 SSH 密钥指纹检索用户

前提条件：

- 您必须具有实例的管理员访问权限。

检索拥有指定 SSH 密钥的用户的信息。

```plaintext
GET /keys
```

支持的属性：

| 属性         | 类型   | 是否必需 | 描述                    |
|--------------|--------|----------|-------------------------|
| `fingerprint`| string | 是       | SSH 密钥的指纹。     |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                         | 类型    | 描述 |
|------------------------------|---------|-------------|
| `created_at`                 | string  | SSH 密钥的创建日期和时间，ISO 8601 格式。 |
| `expires_at`                 | string  | SSH 密钥的过期日期和时间，ISO 8601 格式。 |
| `id`                         | integer | SSH 密钥的 ID。 |
| `key`                        | string  | SSH 密钥内容。 |
| `last_used_at`               | string  | SSH 密钥的最后使用日期和时间，ISO 8601 格式。 |
| `title`                      | string  | SSH 密钥的标题。 |
| `usage_type`                 | string  | SSH 密钥的使用类型（例如，`auth` 或 `auth_and_signing`）。 |
| `user`                       | object  | 与 SSH 密钥关联的用户。 |
| `user.avatar_url`            | string  | 用户头像的 URL。 |
| `user.bio`                   | string  | 用户的个人简介。 |
| `user.can_create_group`      | boolean | 如果为 `true`，表示用户可以创建群组。 |
| `user.can_create_project`    | boolean | 如果为 `true`，表示用户可以创建项目。 |
| `user.color_scheme_id`       | integer | 用户的配色方案 ID。 |
| `user.confirmed_at`          | string  | 用户的确认日期和时间，ISO 8601 格式。 |
| `user.created_at`            | string  | 用户账户的创建日期和时间，ISO 8601 格式。 |
| `user.current_sign_in_at`    | string  | 用户的当前登录日期和时间，ISO 8601 格式。 |
| `user.email`                 | string  | 用户的电子邮件地址。 |
| `user.external`              | boolean | 如果为 `true`，表示用户是外部用户。 |
| `user.id`                    | integer | 用户的 ID。 |
| `user.identities`            | array   | 与用户关联的身份信息。 |
| `user.last_activity_on`      | string  | 用户的最后活动日期。 |
| `user.last_sign_in_at`       | string  | 用户的最后登录日期和时间，ISO 8601 格式。 |
| `user.linkedin`              | string  | 用户的 LinkedIn 个人资料 URL。 |
| `user.location`              | string  | 用户的位置。 |
| `user.name`                  | string  | 用户的姓名。 |
| `user.organization`          | string  | 用户所属组织。 |
| `user.private_profile`       | boolean | 如果为 `true`，表示用户的个人资料为私有。 |
| `user.projects_limit`        | integer | 用户的项目限制。 |
| `user.public_email`          | string  | 用户的公开电子邮件地址。 |
| `user.state`                 | string  | 用户账户的状态。 |
| `user.theme_id`              | integer | 用户的主题 ID。 |
| `user.twitter`               | string  | 用户的 Twitter 个人资料 URL。 |
| `user.two_factor_enabled`    | boolean | 如果为 `true`，表示为用户启用了双因素认证。 |
| `user.username`              | string  | 用户名。 |
| `user.web_url`               | string  | 用户个人资料的 URL。 |
| `user.website_url`           | string  | 用户网站的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/keys?fingerprint=ba:81:59:68:d7:6c:cd:02:02:bf:6a:9b:55:4e:af:d1"
```

响应示例：

```json
{
  "id": 1,
  "title": "Sample key 1",
  "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt1016k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
  "created_at": "2019-11-14T15:11:13.222Z",
  "expires_at": "2020-05-05T00:00:00.000Z",
  "last_used_at": "2020-04-07T00:00:00.000Z",
  "usage_type": "auth",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://0.0.0.0:3000/root",
    "created_at": "2019-11-14T15:09:34.831Z",
    "bio": null,
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "last_sign_in_at": "2019-11-16T22:41:26.663Z",
    "confirmed_at": "2019-11-14T15:09:34.575Z",
    "last_activity_on": "2019-11-20",
    "email": "admin@example.com",
    "theme_id": 1,
    "color_scheme_id": 1,
    "projects_limit": 100000,
    "current_sign_in_at": "2019-11-19T14:42:18.078Z",
    "identities": [],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": false,
    "external": false,
    "private_profile": false,
    "shared_runners_minutes_limit": null,
    "extra_shared_runners_minutes_limit": null
  }
}
```

<a id="retrieve-user-by-deploy-key-fingerprint"></a>

## 通过部署密钥指纹检索用户

检索使用指定部署密钥指纹的用户和项目信息。部署密钥会绑定到创建的所属用户。

```plaintext
GET /keys
```

支持的属性：

| 属性         | 类型   | 是否必需 | 描述                        |
|--------------|--------|----------|-----------------------------|
| `fingerprint`| string | 是       | 部署密钥的指纹。        |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                     | 类型    | 描述 |
|------------------------------------------|---------|-------------|
| `created_at`                             | string  | 部署密钥的创建日期和时间，ISO 8601 格式。 |
| `deploy_keys_projects`                    | array   | 部署密钥的项目信息。 |
| `deploy_keys_projects[].can_push`         | boolean | 如果为 `true`，表示部署密钥可以向项目推送。 |
| `deploy_keys_projects[].created_at`       | string  | 创建日期和时间，ISO 8601 格式。 |
| `deploy_keys_projects[].deploy_key_id`    | integer | 部署密钥的 ID。 |
| `deploy_keys_projects[].id`               | integer | 部署密钥项目关系的 ID。 |
| `deploy_keys_projects[].project_id`       | integer | 项目的 ID。 |
| `deploy_keys_projects[].updated_at`       | string  | 最后更新日期和时间，ISO 8601 格式。 |
| `expires_at`                             | string  | 部署密钥的过期日期和时间，ISO 8601 格式。 |
| `id`                                     | integer | 部署密钥的 ID。 |
| `key`                                    | string  | 部署密钥内容。 |
| `last_used_at`                           | string  | 部署密钥的最后使用日期和时间，ISO 8601 格式。 |
| `title`                                  | string  | 部署密钥的标题。 |
| `usage_type`                             | string  | 部署密钥的使用类型（例如，`auth` 或 `auth_and_signing`）。 |
| `user`                                   | object  | 与部署密钥关联的用户。 |
| `user.avatar_url`                        | string  | 用户头像的 URL。 |
| `user.bio`                               | string  | 用户的个人简介。 |
| `user.can_create_group`                  | boolean | 如果为 `true`，表示用户可以创建群组。 |
| `user.can_create_project`                | boolean | 如果为 `true`，表示用户可以创建项目。 |
| `user.color_scheme_id`                   | integer | 用户的配色方案 ID。 |
| `user.confirmed_at`                      | string  | 用户的确认日期和时间，ISO 8601 格式。 |
| `user.created_at`                        | string  | 用户账户的创建日期和时间，ISO 8601 格式。 |
| `user.current_sign_in_at`                | string  | 用户的当前登录日期和时间，ISO 8601 格式。 |
| `user.email`                             | string  | 用户的电子邮件地址。 |
| `user.external`                          | boolean | 如果为 `true`，表示用户是外部用户。 |
| `user.extra_shared_runners_minutes_limit`| integer | 用户的额外共享 runner 分钟数限制。 |
| `user.id`                                | integer | 用户的 ID。 |
| `user.identities`                        | array   | 与用户关联的身份信息。 |
| `user.last_activity_on`                  | string  | 用户的最后活动日期。 |
| `user.last_sign_in_at`                   | string  | 用户的最后登录日期和时间，ISO 8601 格式。 |
| `user.linkedin`                          | string  | 用户的 LinkedIn 个人资料 URL。 |
| `user.location`                          | string  | 用户的位置。 |
| `user.name`                              | string  | 用户的姓名。 |
| `user.organization`                      | string  | 用户所属组织。 |
| `user.private_profile`                   | boolean | 如果为 `true`，表示用户的个人资料为私有。 |
| `user.projects_limit`                    | integer | 用户的项目限制。 |
| `user.public_email`                      | string  | 用户的公开电子邮件地址。 |
| `user.shared_runners_minutes_limit`      | integer | 用户的共享 runner 分钟数限制。 |
| `user.state`                             | string  | 用户账户的状态。 |
| `user.theme_id`                          | integer | 用户的主题 ID。 |
| `user.twitter`                           | string  | 用户的 Twitter 个人资料 URL。 |
| `user.two_factor_enabled`                | boolean | 如果为 `true`，表示为用户启用了双因素认证。 |
| `user.username`                          | string  | 用户名。 |
| `user.web_url`                           | string  | 用户个人资料的 URL。 |
| `user.website_url`                       | string  | 用户网站的 URL。 |

使用 MD5 指纹的请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/keys?fingerprint=ba:81:59:68:d7:6c:cd:02:02:bf:6a:9b:55:4e:af:d1"
```

使用 SHA256 指纹（URL 编码后）的请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/keys?fingerprint=SHA256%3AnUhzNyftwADy8AH3wFY31tAKs7HufskYTte2aXo%2FlCg"
```

在 SHA256 示例中，`/` 表示为 `%2F`，`:` 表示为 `%3A`。

响应示例：

```json
{
  "id": 1,
  "title": "Sample key 1",
  "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt1016k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
  "created_at": "2019-11-14T15:11:13.222Z",
  "expires_at": "2020-05-05T00:00:00.000Z",
  "last_used_at": "2020-04-07T00:00:00.000Z",
  "usage_type": "auth",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://0.0.0.0:3000/root",
    "created_at": "2019-11-14T15:09:34.831Z",
    "bio": null,
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "last_sign_in_at": "2019-11-16T22:41:26.663Z",
    "confirmed_at": "2019-11-14T15:09:34.575Z",
    "last_activity_on": "2019-11-20",
    "email": "admin@example.com",
    "theme_id": 1,
    "color_scheme_id": 1,
    "projects_limit": 100000,
    "current_sign_in_at": "2019-11-19T14:42:18.078Z",
    "identities": [],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": false,
    "external": false,
    "private_profile": false,
    "shared_runners_minutes_limit": null,
    "extra_shared_runners_minutes_limit": null
  },
  "deploy_keys_projects": [
    {
      "id": 1,
      "deploy_key_id": 1,
      "project_id": 1,
      "created_at": "2020-01-09T07:32:52.453Z",
      "updated_at": "2020-01-09T07:32:52.453Z",
      "can_push": false
    }
  ]
}
```

