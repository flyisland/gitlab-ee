---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "Authenticate with the GitLab REST API by using OAuth 2.0, access, and job tokens."
title: REST API 认证
---

大多数 API 请求都需要认证，如果未提供认证信息，则仅返回公开数据。当不需要认证时，每个端点的文档会明确说明。例如，[`/projects/:id` 端点](../projects.md#retrieve-a-project)不需要认证。

你可以通过以下几种方式对极狐GitLab REST API 进行认证：

- [OAuth 2.0 令牌](#oauth-20-tokens)
- [个人访问令牌](../../user/profile/personal_access_tokens.md)
- [项目访问令牌](../../user/project/settings/project_access_tokens.md)
- [群组访问令牌](../../user/group/settings/group_access_tokens.md)
- [会话 cookie](#session-cookie)
- [CI/CD 作业令牌](#job-tokens)（仅限特定端点）

项目访问令牌支持：

- 私有化部署：基础版、专业版和旗舰版。
- JihuLab.com：专业版和旗舰版。

如果你是管理员，你或你的应用程序可以通过以下任一方式以特定用户身份进行认证：

- [模拟令牌](#impersonation-tokens)
- [Sudo](#sudo)

如果认证信息无效或缺失，极狐GitLab 会返回状态码为 `401` 的错误信息：

```json
{
  "message": "401 Unauthorized"
}
```

> [!note]
> 部署令牌不能用于极狐GitLab 公共 API。详情请参阅[部署令牌](../../user/project/deploy_tokens/_index.md)。

<a id="oauth-20-tokens"></a>

## OAuth 2.0 令牌

你可以使用 [OAuth 2.0 令牌](../oauth2.md)来认证 API，通过在 `access_token` 参数或 `Authorization` 标头中传递令牌。

在参数中使用 OAuth 2.0 令牌的示例：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/projects?access_token=OAUTH-TOKEN"
```

在标头中使用 OAuth 2.0 令牌的示例：

```shell
curl --request GET \
  --header "Authorization: Bearer OAUTH-TOKEN" \
  --url "https://gitlab.example.com/api/v4/projects"
```

详细了解[极狐GitLab 作为 OAuth 2.0 提供商](../oauth2.md)。

> [!note]
> 所有 OAuth 访问令牌在创建后两小时内有效。你可以使用 `refresh_token` 参数来刷新令牌。有关如何使用刷新令牌请求新的访问令牌，请参阅 [OAuth 2.0 令牌](../oauth2.md)文档。

<a id="personal-project-and-group-access-tokens"></a>

## 个人、项目和群组访问令牌

你可以使用访问令牌来认证 API。使用 `PRIVATE-TOKEN` 标头（推荐）或其他方法传递令牌。

例如，使用推荐的标头方法：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects"
```

你也可以将个人、项目或群组访问令牌与符合 OAuth 规范的标头一起使用。例如：

```shell
curl --request GET \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects"
```

<a id="job-tokens"></a>

## 作业令牌

你可以使用作业令牌来认证[特定 API 端点](../../ci/jobs/ci_job_token.md#job-token-access)。在极狐GitLab CI/CD 作业中，该令牌以 `CI_JOB_TOKEN` 变量的形式提供。

使用 `JOB-TOKEN` 标头（推荐）或其他方法传递令牌。有关所有认证方法，请参阅 [CI/CD 作业令牌认证](../../ci/jobs/ci_job_token.md#rest-api-authentication)。

例如，使用标头方法：

```shell
curl --request GET \
  --header "JOB-TOKEN: $CI_JOB_TOKEN" \
  --url "https://gitlab.example.com/api/v4/projects/1/releases"
```

<a id="session-cookie"></a>

## 会话 cookie

登录极狐GitLab 主应用程序会设置一个 `_gitlab_session` cookie。如果该 cookie 存在，API 会使用它进行认证。不支持使用 API 生成新的会话 cookie。

此认证方法的主要用户是极狐GitLab 自身的 Web 前端。Web 前端可以以认证用户身份使用 API 来获取项目列表，而无需显式传递访问令牌。

<a id="impersonation-tokens"></a>

## 模拟令牌

模拟令牌是一种[个人访问令牌](../../user/profile/personal_access_tokens.md)。它们只能由管理员创建，用于以特定用户身份认证 API。

使用模拟令牌作为以下方式的替代方案：

- 用户的密码或其个人访问令牌之一。
- [Sudo](#sudo) 功能。用户或管理员的密码或令牌可能未知，或可能随时间变化。

更多详情，请参阅[用户令牌 API](../user_tokens.md#create-an-impersonation-token) 文档。

模拟令牌的使用方式与普通个人访问令牌完全相同，可以通过 `private_token` 参数或 `PRIVATE-TOKEN` 标头传递。

<a id="disable-impersonation"></a>

### 禁用模拟

默认情况下，模拟处于启用状态。要禁用模拟：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   gitlab_rails['impersonation_enabled'] = false
   ```

1. 保存文件，然后[重新配置](../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml` 文件：

   ```yaml
   gitlab:
     impersonation_enabled: false
   ```

1. 保存文件，然后[重启](../../administration/restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

要重新启用模拟，请移除此配置并重新配置极狐GitLab（Linux 软件包安装）或重启极狐GitLab（自行编译安装）。

<a id="sudo"></a>

## Sudo

所有 API 请求都支持以其他用户身份执行 API 请求，前提是你以管理员身份认证，并拥有具有 `sudo` 范围的 OAuth 或个人访问令牌。API 请求将以被模拟用户的权限执行。

作为[管理员](../../user/permissions.md)，你可以通过查询字符串或标头传递 `sudo` 参数，提供你要以该身份执行操作的用户的 ID 或用户名（不区分大小写）。如果以标头方式传递，标头名称必须为 `Sudo`。

如果提供了非管理员访问令牌，极狐GitLab 会返回状态码为 `403` 的错误信息：

```json
{
  "message": "403 Forbidden - Must be admin to use sudo"
}
```

如果提供的访问令牌没有 `sudo` 范围，则会返回状态码为 `403` 的错误信息：

```json
{
  "error": "insufficient_scope",
  "error_description": "The request requires higher privileges than provided by the access token.",
  "scope": "sudo"
}
```

如果找不到 sudo 用户 ID 或用户名，则会返回状态码为 `404` 的错误信息：

```json
{
  "message": "404 User with ID or username '123' Not Found"
}
```

有效的 API 请求示例和使用 cURL 执行 sudo 请求（提供用户名）的示例：

```plaintext
GET /projects?private_token=<your_access_token>&sudo=username
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Sudo: username" \
  --url "https://gitlab.example.com/api/v4/projects"
```

有效的 API 请求示例和使用 cURL 执行 sudo 请求（提供 ID）的示例：

```plaintext
GET /projects?private_token=<your_access_token>&sudo=23
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Sudo: 23" \
  --url "https://gitlab.example.com/api/v4/projects"
```
