---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API that exposes token information.
title: 令牌信息 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- 状态：实验性

{{< /details >}}

使用此 API 可以检索任意令牌的详细信息并将其撤销。与其他公开令牌信息的 API 不同，此 API 允许你在不知道令牌具体类型的情况下检索详细信息或撤销令牌。

<a id="token-prefixes"></a>

## 令牌前缀

发出请求时，`personal`、`project` 或 `group access` 令牌必须以 `glpat` 或当前的[自定义前缀](../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)开头。如果令牌以以前的自定义前缀开头，操作将失败。对支持以前自定义前缀的兴趣在 issue 165663 中跟踪。

前提条件：

- 你必须具有实例的管理员访问权限。

<a id="retrieve-token-information"></a>

## 检索令牌信息

{{< history >}}

- 在极狐GitLab 17.5 中引入 [使用功能标志](../../administration/feature_flags/_index.md) 名为 `admin_agnostic_token_finder`。默认禁用。
- 在极狐GitLab 17.8 中 GA。功能标志 `admin_agnostic_token_finder` 已移除。
- 在极狐GitLab 17.6 中添加了 Feed 令牌。
- 在极狐GitLab 17.7 中添加了 OAuth 应用密钥。
- 在极狐GitLab 17.7 中添加了集群代理令牌。
- 在极狐GitLab 17.7 中添加了 Runner 认证令牌。
- 在极狐GitLab 17.7 中添加了流水线触发令牌。
- 在极狐GitLab 17.9 中添加了 CI/CD 作业令牌。
- 在极狐GitLab 17.9 中添加了功能标志客户端令牌。
- 在极狐GitLab 17.9 中添加了极狐GitLab 会话 Cookie。
- 在极狐GitLab 17.9 中添加了传入邮件令牌。

{{< /history >}}

检索指定令牌的详细信息。此端点支持以下令牌：

- [个人访问令牌](../../user/profile/personal_access_tokens.md)
- [模拟令牌](../rest/authentication.md#impersonation-tokens)
- [部署令牌](../../user/project/deploy_tokens/_index.md)
- [Feed 令牌](../../security/tokens/_index.md#feed-token)
- [OAuth 应用密钥](../../integration/oauth_provider.md)
- [集群代理令牌](../../security/tokens/_index.md#gitlab-cluster-agent-tokens)
- [Runner 认证令牌](../../security/tokens/_index.md#runner-authentication-tokens)
- [流水线触发令牌](../../ci/triggers/_index.md#create-a-pipeline-trigger-token)
- [CI/CD 作业令牌](../../security/tokens/_index.md#cicd-job-tokens)
- [功能标志客户端令牌](../../operations/feature_flags.md#get-access-credentials)
- [极狐GitLab 会话 Cookie](../../user/profile/active_sessions.md)
- [传入邮件令牌](../../security/tokens/_index.md#incoming-email-token)

```plaintext
POST /api/v4/admin/token
```

支持的属性：

| 属性       | 类型    | 是否必需 | 描述                |
|--------------|---------|----------|----------------------------|
| `token`      | string  | 是       | 要标识的现有令牌。`Personal`、`project` 或 `group access` 令牌必须以 `glpat` 或当前的[自定义前缀](../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)开头。 |

如果成功，返回 [`200`](../rest/troubleshooting.md#status-codes) 以及令牌的相关信息。

可以返回以下状态码：

- `200 OK`：令牌的相关信息。
- `401 Unauthorized`：用户未授权。
- `403 Forbidden`：用户不是管理员。
- `404 Not Found`：未找到令牌。
- `422 Unprocessable`：令牌类型不受支持。

请求示例：

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/admin/token" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header 'Content-Type: application/json' \
  --data '{"token": "glpat-<example-token>"}'
```

响应示例：

```json
{
 "id": 1,
 "user_id": 70,
 "name": "project-access-token",
 "revoked": false,
 "expires_at": "2024-10-04",
 "created_at": "2024-09-04T07:19:18.652Z",
 "updated_at": "2024-09-04T07:19:18.652Z",
 "scopes": [
  "api",
  "read_api"
 ],
 "impersonation": false,
 "expire_notification_delivered": false,
 "last_used_at": null,
 "after_expiry_notification_delivered": false,
 "previous_personal_access_token_id": null,
 "advanced_scopes": null,
 "organization_id": 1
}
```

<a id="revoke-a-token"></a>

## 撤销令牌

{{< history >}}

- 在极狐GitLab 17.9 中添加了集群代理令牌。
- 在极狐GitLab 17.9 中添加了 Runner 认证令牌。
- 在极狐GitLab 17.9 中添加了 OAuth 应用密钥。
- 在极狐GitLab 17.9 中添加了传入邮件令牌。
- 在极狐GitLab 17.9 中添加了功能标志客户端令牌。
- 在极狐GitLab 17.10 中添加了流水线触发令牌 [使用功能标志](../../administration/feature_flags/_index.md) 名为 `token_api_expire_pipeline_triggers`。默认禁用。
- 在极狐GitLab 17.11 中添加了极狐GitLab 会话。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

根据令牌类型撤销、重置或删除指定的令牌。此端点支持以下令牌类型：

| 令牌类型                                                                                      | 支持的操作   |
|----------------------------------------------------------------------------------------------|--------------------|
| [个人访问令牌](../../user/profile/personal_access_tokens.md)                       | 撤销             |
| [模拟令牌](../../user/profile/personal_access_tokens.md)                         | 撤销             |
| [项目访问令牌](../../security/tokens/_index.md#project-access-tokens)               | 撤销             |
| [群组访问令牌](../../security/tokens/_index.md#group-access-tokens)                   | 撤销             |
| [部署令牌](../../user/project/deploy_tokens/_index.md)                                   | 撤销             |
| [集群代理令牌](../../security/tokens/_index.md#gitlab-cluster-agent-tokens)          | 撤销             |
| [流水线触发令牌](../../ci/triggers/_index.md#create-a-pipeline-trigger-token)       | 撤销             |
| [Feed 令牌](../../security/tokens/_index.md#feed-token)                                    | 重置              |
| [Runner 认证令牌](../../security/tokens/_index.md#runner-authentication-tokens) | 重置              |
| [OAuth 应用密钥](../../integration/oauth_provider.md)                             | 重置              |
| [传入邮件令牌](../../security/tokens/_index.md#incoming-email-token)                | 重置              |
| [功能标志客户端令牌](../../operations/feature_flags.md#get-access-credentials)      | 重置              |
| [极狐GitLab 会话 Cookie](../../user/profile/active_sessions.md)                              | 删除             |

```plaintext
DELETE /api/v4/admin/token
```

支持的属性：

| 属性       | 类型    | 是否必需 | 描述              |
|--------------|---------|----------|--------------------------|
| `token`      | string  | 是       | 要撤销的现有令牌。`Personal`、`project` 或 `group access` 令牌必须以 `glpat` 或当前的[自定义前缀](../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)开头。 |

如果成功，返回 [`204`](../rest/troubleshooting.md#status-codes) 且无内容。

可以返回以下状态码：

- `204 No content`：令牌已被撤销。
- `401 Unauthorized`：用户未授权。
- `403 Forbidden`：用户不是管理员。
- `404 Not Found`：未找到令牌。
- `422 Unprocessable`：令牌类型不受支持。

请求示例：

```shell
curl --request DELETE \
  --url "https://gitlab.example.com/api/v4/admin/token" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header 'Content-Type: application/json' \
  --data '{"token": "glpat-<example-token>"}'
```

