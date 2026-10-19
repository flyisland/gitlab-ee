---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "使用 OAuth 2.0、访问令牌和作业令牌对极狐GitLab REST API 进行身份验证。"
title: REST API 身份验证
---

大多数 API 请求都需要身份验证，如果未提供身份验证，则仅返回公开数据。当不需要身份验证时，每个端点的文档都会说明这一点。例如，[`/projects/:id` 端点](../projects.md#retrieve-a-project)不需要身份验证。

您可以通过以下几种方式对极狐GitLab REST API 进行身份验证：

- [OAuth 2.0 令牌](#oauth-20-tokens)
- [个人访问令牌](../../user/profile/personal_access_tokens.md)
- [项目访问令牌](../../user/project/settings/project_access_tokens.md)
- [群组访问令牌](../../user/group/settings/group_access_tokens.md)
- [会话 Cookie](#session-cookie)
- [CI/CD 作业令牌](#job-tokens)（仅限特定端点）

以下版本支持项目访问令牌：

- 极狐GitLab 私有化部署：基础版、专业版和旗舰版。
- JihuLab.com：专业版和旗舰版。

如果您是管理员，您或您的应用程序可以通过以下任一方式以特定用户身份进行身份验证：

- [模拟令牌](#impersonation-tokens)
- [Sudo](#sudo)

如果身份验证信息无效或缺失，极狐GitLab 会返回一条错误消息，状态码为 `401`：

```json
{
  "message": "401 Unauthorized"
}
```

> [!note]
> 部署令牌不能与极狐GitLab 公共 API 一起使用。有关详情，请参阅
> [部署令牌](../../user/project/deploy_tokens/_index.md)。

<a id="rate-limits"></a>

## 速率限制

极狐GitLab 会对 REST API 的请求进行速率限制。经过身份验证的请求比匿名请求获得更高的配额。

在 JihuLab.com 上，配额取决于您的订阅套餐。有关更多信息，请参阅
[JihuLab.com 速率限制](../../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)。

当您超出速率限制时，极狐GitLab 会返回 `429 Too Many Requests` 响应，并附带 `Retry-After` 响应头，告知您需要等待多长时间。有关速率限制响应头的完整列表，请参阅[响应头](../../administration/settings/user_and_ip_rate_limits.md#response-headers)。

<a id="oauth-20-tokens"></a>

## OAuth 2.0 令牌

您可以使用 [OAuth 2.0 令牌](../oauth2.md)对 API 进行身份验证，方法是将令牌传入 `access_token` 参数或 `Authorization` 请求头，但不能同时传入两者。如果请求在两处都包含令牌，将返回 `400 Bad Request`。

在参数中使用 OAuth 2.0 令牌的示例：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/projects?access_token=OAUTH-TOKEN"
```

在请求头中使用 OAuth 2.0 令牌的示例：

```shell
curl --request GET \
  --header "Authorization: Bearer OAUTH-TOKEN" \
  --url "https://gitlab.example.com/api/v4/projects"
```

详细了解[极狐GitLab 作为 OAuth 2.0 提供商](../oauth2.md)。

> [!note]
> 所有 OAuth 访问令牌在创建后两小时内有效。您可以使用
> `refresh_token` 参数刷新令牌。有关如何使用刷新令牌请求新的访问令牌，请参阅 [OAuth 2.0 令牌](../oauth2.md)文档。

<a id="personal-project-and-group-access-tokens"></a>

## 个人、项目和群组访问令牌

您可以使用访问令牌对 API 进行身份验证。通过 `PRIVATE-TOKEN` 请求头（推荐）或其他方法传递令牌。

例如，使用推荐的请求头方法：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects"
```

您还可以将个人、项目或群组访问令牌与符合 OAuth 规范的请求头一起使用。例如：

```shell
curl --request GET \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects"
```

<a id="job-tokens"></a>

## 作业令牌

您可以使用作业令牌对[特定 API 端点](../../ci/jobs/ci_job_token.md#job-token-access)进行身份验证。在极狐GitLab CI/CD 作业中，该令牌可通过 `CI_JOB_TOKEN` 变量获取。

通过 `JOB-TOKEN` 请求头（推荐）或其他方法传递令牌。有关所有身份验证方法，请参阅 [CI/CD 作业令牌身份验证](../../ci/jobs/ci_job_token.md#rest-api-authentication)。

例如，使用请求头方法：

```shell
curl --request GET \
  --header "JOB-TOKEN: $CI_JOB_TOKEN" \
  --url "https://gitlab.example.com/api/v4/projects/1/releases"
```

<a id="session-cookie"></a>

## 会话 Cookie

登录极狐GitLab 主应用程序会设置一个 `_gitlab_session` Cookie。如果该 Cookie 存在，API 会使用它进行身份验证。不支持使用 API 生成新的会话 Cookie。

此身份验证方法的主要使用者是极狐GitLab 自身的 Web 前端。Web 前端可以以经过身份验证的用户身份使用 API 获取项目列表，而无需显式传递访问令牌。

<a id="impersonation-tokens"></a>

## 模拟令牌

模拟令牌是一种[个人访问令牌](../../user/profile/personal_access_tokens.md)。它们只能由管理员创建，用于以特定用户身份对 API 进行身份验证。

使用模拟令牌可以替代以下方式：

- 用户的密码或其个人访问令牌之一。
- [Sudo](#sudo) 功能。用户或管理员的密码或令牌
  可能未知，也可能随时间变化。

有关更多详情，请参阅[用户令牌 API](../user_tokens.md#create-an-impersonation-token) 文档。

模拟令牌的使用方式与常规个人访问令牌完全相同，可以传入 `private_token` 参数或 `PRIVATE-TOKEN` 请求头。

<a id="disable-impersonation"></a>

### 禁用模拟

默认情况下，模拟处于启用状态。要禁用模拟：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   gitlab_rails['impersonation_enabled'] = false
   ```

1. 保存文件，然后[重新配置](../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)
   极狐GitLab 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml` 文件：

   ```yaml
   gitlab:
     impersonation_enabled: false
   ```

1. 保存文件，然后[重启](../../administration/restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

要重新启用模拟，请移除此配置并重新配置极狐GitLab（Linux 软件包安装）或重启极狐GitLab（自行编译安装）。

<a id="sudo"></a>

## Sudo

只要您以管理员身份通过具有 `sudo` 范围的 OAuth 或个人访问令牌进行身份验证，所有 API 请求都支持以其他用户身份执行 API 请求。API 请求将以被模拟用户的权限执行。

作为[管理员](../../user/permissions.md)，通过查询字符串或请求头传递 `sudo` 参数，值为您希望以其身份执行操作的用户的 ID 或用户名（不区分大小写）。如果通过请求头传递，请求头名称必须为 `Sudo`。

如果提供的是非管理员访问令牌，极狐GitLab 会返回一条错误消息，状态码为
`403`：

```json
{
  "message": "403 Forbidden - Must be admin to use sudo"
}
```

如果提供的访问令牌没有 `sudo` 范围，则会返回一条错误消息，状态码为
`403`：

```json
{
  "error": "insufficient_scope",
  "error_description": "The request requires higher privileges than provided by the access token.",
  "scope": "sudo"
}
```

如果找不到 sudo 用户 ID 或用户名，则会返回一条错误消息，状态码为
`404`：

```json
{
  "message": "404 User with ID or username '123' Not Found"
}
```

以下是有效 API 请求的示例，以及使用 cURL 提供用户名进行 sudo 请求的示例：

```plaintext
GET /projects?private_token=<your_access_token>&sudo=username
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Sudo: username" \
  --url "https://gitlab.example.com/api/v4/projects"
```

以下是有效 API 请求的示例，以及使用 cURL 提供 ID 进行 sudo 请求的示例：

```plaintext
GET /projects?private_token=<your_access_token>&sudo=23
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Sudo: 23" \
  --url "https://gitlab.example.com/api/v4/projects"
```
