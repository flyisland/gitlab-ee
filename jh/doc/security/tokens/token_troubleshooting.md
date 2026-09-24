---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 令牌故障排除
---

使用极狐GitLab 令牌时，您可能会遇到以下问题。

<a id="token-appears-active-but-requests-fail"></a>

## 令牌显示为活跃但请求失败

列为活跃的令牌仍可能返回 `401 Unauthorized`、`403 Forbidden` 或
`404 Not Found` 响应。活跃状态仅表示令牌存在且未过期或未被撤销。此状态并不表示令牌可以发出特定请求。如果令牌已过期或被撤销，请参阅[令牌过期后请求失败](#requests-fail-after-a-token-expires)。

令牌的权限取决于其范围和角色。请求也可能因令牌之外的原因而失败：请求的来源、请求目标的资源，以及管理员是否已关闭访问令牌。这些因素都无法从令牌本身看出。个人、项目和群组访问令牌都使用相同的 `glpat-` 前缀。因此，两个看起来相同的令牌可能表现不同。

活跃令牌可能因以下任何原因而失败：

| 原因 | 解决方法 |
|-------|------------|
| 令牌缺少请求所需的范围。 | 创建具有必要[访问令牌范围](access_token_scopes.md)的令牌。轮换会保留原始范围，无法添加缺失的范围。 |
| 群组或项目访问令牌没有所需的角色。 | 创建具有更高角色的令牌。令牌的权限受其角色和范围的限制。 |
| 令牌已过期。 | 访问令牌在其过期日期的[UTC 午夜](#requests-fail-after-a-token-expires)过期。创建一个令牌，然后更新所有使用旧令牌的位置。 |
| 令牌已被撤销，或已被轮换且原始值仍在使用。 | 轮换会使原始令牌立即失效。使用轮换创建的令牌，或创建一个令牌。在极狐GitLab 私有化部署上，管理员可以[恢复意外撤销的个人访问令牌](#restore-a-personal-access-token)。 |
| 令牌类型无法访问该资源。 | 使用可以访问该资源的令牌类型。个人访问令牌可访问其用户可用的群组和项目。群组访问令牌可访问其群组中的子群组和项目。项目访问令牌只能访问其自己的项目。 |
| [IP 地址限制](../../user/group/access_and_permissions.md#restrict-group-access-by-ip-address)阻止了请求。 | 这些限制适用于群组和项目访问令牌，被阻止的请求会返回 `404 Not Found`。从允许的地址发送请求，或请求具有顶级群组所有者角色的用户将地址添加到允许范围内。 |
| 已启用[外部授权](../../administration/settings/external_authorization.md)。 | 个人和项目访问令牌无法访问容器镜像仓库或软件包仓库。要恢复对仓库的访问，请关闭外部授权。 |
| 管理员已为实例[关闭访问令牌](../../user/profile/personal_access_tokens.md#disable-access-tokens)。 | 请管理员或具有所有者角色的用户重新开启访问令牌。 |

要确定适用哪种原因，请将失败令牌的详细信息与可正常工作的令牌进行比较：

- [个人访问令牌](../../user/profile/personal_access_tokens.md#view-token-usage-information)
- [群组访问令牌](../../user/group/settings/group_access_tokens.md#view-your-access-tokens)
- [项目访问令牌](../../user/project/settings/project_access_tokens.md#view-your-access-tokens)

详细信息包括每个令牌的范围、过期日期和使用信息。群组和项目访问令牌还会显示分配的角色。

如果您发出请求后令牌的使用信息未更新，则请求可能未到达极狐GitLab。极狐GitLab 每 10 分钟更新一次使用时间，每 1 分钟更新一次使用 IP 地址。如果超过这些时间间隔后极狐GitLab 仍未记录使用情况，则您的请求未到达极狐GitLab。

<a id="token-does-not-work-in-an-editor-extension-or-command-line-tool"></a>

## 令牌在编辑器扩展或命令行工具中不起作用

在极狐GitLab UI 或 API 中通过身份验证的令牌，在编辑器扩展或命令行工具中仍可能失败。不同工具的范围要求不同。

有效令牌可能因以下原因在工具中失败：

| 原因 | 解决方法 |
|-------|------------|
| 令牌需要不同的范围。 | 将[工具所需的范围](../../user/profile/personal_access_tokens.md#use-third-party-tools-and-ide-extensions)与添加到令牌的[范围](access_token_scopes.md)进行比较。创建具有所需范围的令牌。轮换会保留原始范围，无法添加缺失的范围。 |
| 工具未使用正确的令牌。 | 检查工具使用哪个令牌进行身份验证，然后更新或删除不正确的令牌。仅当未为该实例配置令牌时，GitLab for VS Code 扩展才会使用 `GITLAB_WORKFLOW_TOKEN` [环境变量](../../editor_extensions/visual_studio_code/setup.md#store-tokens-in-environment-variables)中的令牌。此变量在您删除 VS Code 存储后仍然存在。要覆盖它，请在扩展中为该实例配置一个令牌。 |
| 工具无法连接到极狐GitLab。 | 如果令牌具有所需范围且工具正在使用它，请验证工具是否可以通过您的网络访问极狐GitLab。对于 GitLab for VS Code 扩展，请参阅[身份验证故障排除](../../editor_extensions/visual_studio_code/troubleshooting.md#authentication)。 |

<a id="requests-fail-after-a-token-expires"></a>

## 令牌过期后请求失败

如果现有访问令牌正在使用中并达到 `expires_at` 值，则令牌过期并且：

- 不能再用于身份验证。
- 在 UI 中不可见。

使用此令牌发出的请求会返回 `401 Unauthorized` 响应。同一 IP 地址在短时间内发出过多未授权请求，会导致 JihuLab.com 返回 `403 Forbidden` 响应。

有关身份验证请求限制的更多信息，请参阅 [Git 和容器镜像仓库失败身份验证禁令](../../user/jihulab_com/_index.md#git-and-container-registry-failed-authentication-ban)。

<a id="identify-expired-access-tokens-from-logs"></a>

### 从日志中识别过期的访问令牌

先决条件：

您必须：

- 是管理员。
- 有权访问 [`api_json.log`](../../administration/logs/_index.md#api_jsonlog) 文件。

要识别哪些 `401 Unauthorized` 请求因访问令牌过期而失败，请使用 `api_json.log` 文件中的以下字段：

| 字段名称                        | 描述 |
|-----------------------------------|-------------|
| `meta.auth_fail_reason`           | 请求被拒绝的原因。可能的值：`token_expired`、`token_revoked`、`insufficient_scope` 和 `impersonation_disabled`。 |
| `meta.auth_fail_token_id`         | 描述尝试使用的令牌类型和 ID 的字符串。 |
| `meta.auth_fail_requested_scopes` | 请求所需的 OAuth 范围，以空格分隔。 |
| `meta.auth_fail_token_type`       | 使用的令牌类型。可能的值：`PersonalAccessToken`、`CiJobToken` 和 `unknown`。 |
| `meta.auth_fail_auth_header_type` | 令牌在请求中的传递方式。可能的值：`private_token_header`、`private_token_param`、`bearer` 和 `other`。 |

当用户尝试使用过期的令牌时，`meta.auth_fail_reason` 为 `token_expired`。以下显示了日志条目的摘录：

```json
{
  "status": 401,
  "method": "GET",
  "path": "/api/v4/user",
  ...
  "meta.auth_fail_reason": "token_expired",
  "meta.auth_fail_token_id": "PersonalAccessToken/12",
}
```

> [!note]
> 在某些情况下，`meta.auth_fail_*` 字段可能出现在非 401 响应上。已知情况包括：
>
> - 对公共项目的 Git HTTP 请求，Rack::Attack 记录了令牌失败，但项目的公共可见性允许请求成功。
> - Unleash 功能标志端点，它通过 `HTTP_UNLEASH_INSTANCEID` 而非令牌进行授权。
> - Workhorse 预授权（`/authorize`）端点，它们在令牌探测后执行自己的授权。

`meta.auth_fail_token_id` 表示使用了 ID 为 12 的访问令牌。在极狐GitLab 18.9 及更高版本中，`meta.user` 也会填充与用于失败请求的令牌关联的任何用户名。

要查找有关此令牌的更多信息，请使用[个人访问令牌 API](../../api/personal_access_tokens.md#retrieve-a-personal-access-token)。您也可以使用 API [轮换令牌](../../api/personal_access_tokens.md#rotate-a-personal-access-token)。

<a id="replace-expired-access-tokens"></a>

### 替换过期的访问令牌

要替换令牌：

1. 检查此令牌之前可能使用过的位置，并将其从可能仍在使用该令牌的任何自动化中移除。
   - 对于个人访问令牌，使用 [API](../../api/personal_access_tokens.md#list-all-personal-access-tokens) 列出最近过期的令牌。例如，访问 `https://jihulab.com/api/v4/personal_access_tokens`，并找到具有特定 `expires_at` 日期的令牌。
   - 对于项目访问令牌，使用[项目访问令牌 API](../../api/project_access_tokens.md#list-all-project-access-tokens) 列出最近过期的令牌。
   - 对于群组访问令牌，使用[群组访问令牌 API](../../api/group_access_tokens.md#list-all-group-access-tokens) 列出最近过期的令牌。
1. 创建新的访问令牌：
   - 对于个人访问令牌，[使用 UI](../../user/profile/personal_access_tokens.md#create-a-personal-access-token) 或 [用户令牌 API](../../api/user_tokens.md#create-a-personal-access-token)。
   - 对于项目访问令牌，[使用 UI](../../user/project/settings/project_access_tokens.md#create-a-project-access-token) 或 [项目访问令牌 API](../../api/project_access_tokens.md#create-a-project-access-token)。
   - 对于群组访问令牌，[使用 UI](../../user/group/settings/group_access_tokens.md#create-a-group-access-token) 或 [群组访问令牌 API](../../api/group_access_tokens.md#create-a-group-access-token)。
1. 用新访问令牌替换旧访问令牌。此过程因令牌的使用方式而异，例如配置为密钥或嵌入在应用程序中。使用新令牌的请求不再返回 `401` 响应。

<a id="restore-a-personal-access-token"></a>

## 恢复个人访问令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 私有化部署实例上，管理员可以恢复意外撤销的个人访问令牌。JihuLab.com 上不提供恢复功能。

> [!warning]
> 运行以下命令会直接更改数据，如果命令运行不正确或在错误的条件下运行，可能会造成损害。请先在测试环境中运行这些命令，并准备好实例的备份以便恢复。

1. 打开 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 恢复令牌：

   ```ruby
   token = PersonalAccessToken.find_by_token('<token_string>')
   token.update!(revoked:false)
   ```

   例如，要恢复 `token-string-here123` 的令牌：

   ```ruby
   token = PersonalAccessToken.find_by_token('token-string-here123')
   token.update!(revoked:false)
   ```

<a id="tokens-expire-unexpectedly-after-an-upgrade"></a>

## 升级后令牌意外过期

没有过期日期的访问令牌无限期有效，如果令牌泄露，这会带来安全风险。

根据您的极狐GitLab 版本和交付方式，升级时可能会自动为现有访问令牌应用过期日期。有关更多信息，请参阅[无过期日期的访问令牌](../../update/deprecations.md#non-expiring-access-tokens)。如果您不知道这些日期已更改，身份验证可能会在没有警告的情况下失败。

在极狐GitLab 17.3 及更高版本中，极狐GitLab 不会自动为现有令牌设置过期日期。管理员也可以[关闭新访问令牌的过期日期强制执行](../../administration/settings/account_and_limit_settings.md#require-expiration-dates-for-new-access-tokens)。

要分析、延长或移除令牌过期日期，请使用[访问令牌 Rake 任务](../../administration/raketasks/tokens/_index.md)。
