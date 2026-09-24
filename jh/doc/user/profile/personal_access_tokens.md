---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use personal access tokens to authenticate with the GitLab API or Git over HTTPS. Includes creation, rotation, revocation, scopes, and expiration settings.
title: 个人访问令牌
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="personal-access-tokens"></a>

# 个人访问令牌

个人访问令牌为极狐GitLab 提供认证访问。它们是 [OAuth2 令牌](../../api/oauth2.md) 的替代方案，
类似于群组访问令牌和项目访问令牌，但附加到用户而非群组或项目。

你可以使用个人访问令牌进行认证：

- 通过 [极狐GitLab API](../../api/rest/authentication.md#personal-project-and-group-access-tokens)。
- 通过 Git over HTTPS。使用时：
  - 任意非空值作为用户名。
  - 个人访问令牌作为密码。

> [!note]
> 如果启用了 [双因素认证 (2FA)](account/two_factor_authentication.md) 或 [SAML](../../integration/saml.md#password-generation-for-users-created-through-saml)，你必须使用个人访问令牌进行认证。

部分需要用户名的极狐GitLab 功能，例如
[极狐GitLab 托管 Terraform 状态后端](../infrastructure/iac/terraform_state.md#use-your-gitlab-backend-as-a-remote-data-source)
和 [容器镜像仓库](../packages/container_registry/authenticate_with_container_registry.md)，
使用带有极狐GitLab 用户名的个人访问令牌。在这些情况下，用户名是必需的，
但不会作为认证的一部分进行评估。更多信息请参见 [issue 212953](https://gitlab.com/gitlab-org/gitlab/-/issues/212953)。

在私有化部署实例上，管理员可以使用
[用户令牌 API](../../api/user_tokens.md#create-an-impersonation-token) 创建模拟令牌以特定用户身份进行认证。

<a id="view-token-usage-information"></a>

## 查看令牌使用信息

{{< history >}}

- 在极狐GitLab 16.0 及更早版本中，令牌使用信息每 24 小时更新一次。
- 令牌使用信息更新的频率在极狐GitLab 16.1 [变更](https://gitlab.com/gitlab-org/gitlab/-/issues/410168) 为从 24 小时缩短至 10 分钟。
- 查看 IP 地址功能在极狐GitLab 17.8 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/428577) [通过一个功能标志](../../administration/feature_flags/_index.md) 名为 `pat_ip`。默认在 17.9 中启用。
- 查看 IP 地址功能在极狐GitLab 17.10 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/513302)。功能标志 `pat_ip` 已移除。

{{< /history >}}

个人访问令牌页面显示有关你的访问令牌的信息。

在此页面，你可以执行以下操作：

- 创建、轮换和吊销个人访问令牌。
- 查看所有活跃和非活跃的个人访问令牌。
- 查看令牌信息，包括范围、指派的角色和过期日期。
- 查看使用信息，包括使用日期和最后五个不同连接 IP 地址。
  > [!note]
  > 当令牌执行 Git 操作或通过 [REST](../../api/rest/_index.md) 或 [GraphQL](../../api/graphql/_index.md) API 认证操作时，极狐GitLab 会定期更新令牌使用信息。令牌使用时间每 10 分钟更新一次，令牌使用 IP 地址每分钟更新一次。

要查看你的个人访问令牌：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。

选择令牌名称以打开详细信息面板。默认情况下，仅显示活跃令牌。
使用搜索栏过滤访问令牌列表。

<a id="create-a-personal-access-token"></a>

## 创建个人访问令牌

{{< history >}}

- 创建永久个人访问令牌的功能在极狐GitLab 16.0 中[已移除](https://gitlab.com/gitlab-org/gitlab/-/issues/392855)。
- 最大允许的有效期限制在极狐GitLab 17.6 中[延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901) [通过一个功能标志](../../administration/feature_flags/list.md) 名为 `buffered_token_expiration_limit`。默认禁用。
- 个人访问令牌描述在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/443819)。

{{< /history >}}

> [!flag]
> 扩展最大允许有效期限制的可用性受功能标志控制。
> 更多信息请参见历史记录。

要创建个人访问令牌：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 从 **生成令牌** 下拉列表中，选择 **旧版令牌**。
1. 在 **令牌名称** 中，输入令牌名称。
1. 可选。在 **令牌描述** 中，输入令牌描述。
1. 在 **过期日期** 中，输入令牌的过期日期。
   - 令牌在该日期的 UTC 午夜过期。
   - 如果你未输入日期，过期日期将设置为自今日起 365 天后。
   - 默认情况下，过期日期不能超过自今日起 365 天。在极狐GitLab 17.6 及更高版本中，管理员可以[修改访问令牌的最大有效期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。
1. 选择一个或多个 [个人访问令牌范围](#personal-access-token-scopes)。
1. 选择 **生成令牌**。

将显示个人访问令牌。请将个人访问令牌保存在安全的地方。离开或刷新页面后，你将无法再次查看它。

所有访问令牌都继承
为个人访问令牌配置的 [默认前缀设置](../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)。

### 预填个人访问令牌详情

你可以通过将名称、描述和范围列表附加到 URL 来预填个人访问令牌的详细信息。例如：

```plaintext
https://gitlab.example.com/-/user_settings/personal_access_tokens?name=Example+Access+token&description=My+description&scopes=api,read_user
```

> [!note]
> 个人访问令牌必须谨慎处理。有关管理个人访问令牌的指导，请参见 [令牌安全注意事项](../../security/tokens/_index.md#security-considerations)。

<a id="personal-access-token-scopes"></a>

### 个人访问令牌范围

{{< history >}}

- 个人访问令牌不再能够访问容器或软件包仓库在极狐GitLab 16.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/387721)。
- `k8s_proxy` 在极狐GitLab 16.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/422408) [通过一个功能标志](../../administration/feature_flags/_index.md) 名为 `k8s_proxy_pat`。默认启用。
- 功能标志 `k8s_proxy_pat` 在极狐GitLab 16.5 中[已移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/131518)。
- `read_service_ping` 在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/42692#note_1222832412)。
- `manage_runner` 在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/460721)。
- `self_rotate` 在极狐GitLab 17.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/178111)。默认启用。

{{< /history >}}

范围定义了使用个人访问令牌认证时可用的操作。以下是可用的范围：

> [!note]
> [细粒度个人访问令牌](../../auth/tokens/fine_grained_access_tokens.md) 使用不同的范围。

| 范围                      | 描述 |
| ------------------------- | ----------- |
| `api`                     | 授予对所有 API 的完全读写访问权限，包括所有群组和项目、[容器镜像仓库](../packages/container_registry/_index.md)、[依赖代理](../packages/dependency_proxy/_index.md) 和 [软件包仓库](../packages/package_registry/_index.md)。还通过 Git-over-HTTP 授予对镜像仓库和代码仓的完全读写访问权限。 |
| `read_api`                | 授予对 API 的只读访问权限，包括所有群组和项目、容器镜像仓库和软件包仓库。 |
| `read_registry`           | 当项目为私密且需要授权时，授予对[容器镜像仓库](../packages/container_registry/_index.md) 镜像的只读访问权限（拉取）。仅在容器镜像仓库启用时可用。 |
| `write_registry`          | 当项目为私密且需要授权时，授予对[容器镜像仓库](../packages/container_registry/_index.md) 镜像的写入访问权限（推送）。仅在容器镜像仓库启用时可用。 |
| `read_virtual_registry`   | 当项目为私密且需要授权时，通过[依赖代理](../packages/dependency_proxy/_index.md) 授予对容器镜像的只读访问权限（拉取）。仅在依赖代理启用时可用。 |
| `write_virtual_registry`  | 当项目为私密且需要授权时，通过[依赖代理](../packages/dependency_proxy/_index.md) 授予对容器镜像的读写访问权限（拉取、推送和删除）。仅在依赖代理启用时可用。 |
| `read_repository`         | 通过 Git-over-HTTP 或[代码仓文件 API](../../api/repository_files.md) 授予对私有项目代码仓的只读访问权限（拉取）。 |
| `write_repository`        | 通过 Git-over-HTTP 授予对私有项目代码仓的读写访问权限（拉取和推送）。不支持 API 认证。 |
| `create_runner`           | 授予创建 Runner 的权限。 |
| `manage_runner`           | 授予管理 Runner 的权限。 |
| `admin_mode`              | 当[管理员模式](../../administration/settings/sign_in_restrictions.md#admin-mode) 启用时，授予执行 API 操作的权限。仅适用于私有化部署实例上的管理员。 |
| `ai_features`             | 授予执行极狐GitLab Duo、代码建议 API 和极狐GitLab Duo Chat API 所需 API 操作的权限。专为与 CodeRider（极狐GitLab UI 中的代码建议）配合使用而设计。在私有化部署版本 16.5、16.6 和 16.7 上不工作。在私有化部署实例上，此范围仅在启用极狐GitLab Duo 时可用。 |
| `k8s_proxy`               | 授予使用 Kubernetes 代理执行 Kubernetes API 调用的权限。 |
| `self_rotate`             | 授予使用[个人访问令牌 API](../../api/personal_access_tokens.md#rotate-a-personal-access-token) 轮换此令牌的权限。不允许轮换其他令牌。 |
| `read_service_ping`       | 授予通过 API 以管理员身份认证时下载服务 Ping 负载的访问权限。 |
| `sudo`                    | 授予以管理员身份认证时，以系统中任何用户身份执行 API 操作的权限。 |
| `read_user`               | 通过 `/user` API 端点授予对已认证用户个人资料的只读访问权限，包括用户名、公开电子邮件和全名。还授予对 [`/users`](../../api/users.md) 下只读 API 端点的访问权限。 |

> [!warning]
> 如果你启用了[外部授权](../../administration/settings/external_authorization.md)，
> 个人访问令牌将无法访问容器或软件包仓库。要恢复访问，请关闭外部授权。

<a id="rotate-a-personal-access-token"></a>

## 轮换个人访问令牌

{{< history >}}

- 使用 UI 轮换个人访问令牌的功能在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/241523)。
- [更新 UI](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/194582) 在极狐GitLab 18.1 中。

{{< /history >}}

轮换令牌以创建一个与原始令牌具有相同权限和范围的新令牌。
原始令牌立即变为非活跃状态，极狐GitLab 将保留两个版本以供审计。

> [!warning]
> 此操作无法撤消。依赖已轮换访问令牌的工具将停止工作，直到你引用新的令牌。

要轮换个人访问令牌：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 在活跃令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **轮换** ({{< icon name="retry" >}})。
1. 在确认对话框中，选择 **轮换**。

<a id="revoke-a-personal-access-token"></a>

## 吊销个人访问令牌

{{< history >}}

- [更新 UI](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/194582) 在极狐GitLab 18.1 中。

{{< /history >}}

吊销令牌以立即使其失效并阻止进一步使用。极狐GitLab 将保留令牌以供审计目的。你无法永久删除令牌，但可以过滤令牌列表以仅显示活跃令牌。

> [!warning]
> 此操作无法撤消。依赖已吊销访问令牌的工具将停止工作，直到你添加新令牌。

要吊销个人访问令牌：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 在活跃令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **吊销** ({{< icon name="remove" >}})。
1. 在确认对话框中，选择 **吊销**。

<a id="access-token-expiration"></a>

## 访问令牌过期

个人、群组和项目访问令牌在过期日期的 UTC 午夜过期。
过期后，它们将无法再用于认证请求。

在极狐GitLab 16.0 及更高版本中，新访问令牌必须具有过期日期。如果在创建令牌时未明确设置过期日期，将应用自当前日期起 365 天的过期日期。
在极狐GitLab 旗舰版中，管理员可以为访问令牌配置
[最大允许有效期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。

根据你的极狐GitLab 版本和许可证类型，升级极狐GitLab 版本时，你现有的访问令牌可能会自动应用过期日期。更多信息，
请参见 [非过期访问令牌](../../update/deprecations.md#non-expiring-access-tokens)。

<a id="personal-access-token-expiry-emails"></a>

### 个人访问令牌过期邮件

{{< history >}}

- 60 天和 30 天过期通知在极狐GitLab 17.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/464040) [通过一个功能标志](../../administration/feature_flags/_index.md) 名为 `expiring_pats_30d_60d_notifications`。默认禁用。
- 60 天和 30 天通知在极狐GitLab 17.7 中[GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/173792)。功能标志 `expiring_pats_30d_60d_notifications` 已移除。

{{< /history >}}

极狐GitLab 每天 UTC 时间凌晨 1:00 运行一个检查，以识别即将过期的个人访问令牌。
在令牌过期前 7 天，用户会通过电子邮件收到通知。在极狐GitLab 17.6 及更高版本中，还将在令牌过期前 30 天和 60 天发送通知。

<a id="personal-access-token-expiry-calendar"></a>

### 个人访问令牌过期日历

你可以订阅一个 iCalendar 端点，其中包含每个令牌过期日期的事件。登录后，此端点可在 `/-/user_settings/personal_access_tokens.ics` 获取。

<a id="create-a-service-account-personal-access-token-with-no-expiry-date"></a>

### 创建不过期的服务账户个人访问令牌

你可以[为服务账户创建个人访问令牌](../../api/service_accounts.md#create-a-personal-access-token-for-a-group-service-account) 且不设置过期日期。与非服务账户个人访问令牌不同，这些个人访问令牌永不过期。

> [!note]
> 允许为服务账户创建不过期的个人访问令牌仅影响更改此设置后创建的令牌。不会影响现有令牌。

#### JihuLab.com

先决条件：

- 你必须对顶级群组具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 在 **个人访问令牌** 下，清除 **要求服务账户的过期日期** 复选框。

你现在可以为服务账户用户创建不过期的个人访问令牌。

#### 私有化部署

先决条件：

- 你必须是你私有化部署实例的管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 清除 **服务账户令牌过期** 复选框。

你现在可以为服务账户用户创建不过期的个人访问令牌。

<a id="disable-access-tokens"></a>

## 禁用访问令牌

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- `禁用访问令牌` 设置 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/436991) 在极狐GitLab 17.3。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以防止用户在整个极狐GitLab 实例中使用访问令牌进行认证。此设置会影响个人访问令牌、群组访问令牌、项目访问令牌和模拟令牌。此设置也适用于服务账户的个人访问令牌。

当你禁用访问令牌时，以下规则适用：

- 用户无法使用个人访问令牌登录极狐GitLab。
- 个人访问令牌页面返回 `404 Not Found` 错误。
- RSS、Atom 和日历订阅的订阅令牌停止工作。
- 使用个人访问令牌认证的 API 请求将被拒绝。

要为实例禁用访问令牌：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选中 **禁用访问令牌** 复选框。
1. 选择 **保存更改**。

你还可以在应用设置 API 中使用 [`disable_personal_access_tokens` 属性](../../api/settings.md#available-settings)。

<a id="disable-personal-access-tokens-for-enterprise-users"></a>

## 禁止企业用户使用个人访问令牌

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/369504) 在极狐GitLab 16.11 [通过一个功能标志](../../administration/feature_flags/_index.md) 名为 `enterprise_disable_personal_access_tokens`。默认禁用。
- [在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/369504) 在极狐GitLab 17.2。
- [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/369504) 在极狐GitLab 17.3。功能标志 `enterprise_disable_personal_access_tokens` 已移除。

{{< /history >}}

先决条件：

- 对用户所属群组具有所有者角色。

禁止群组的[企业用户](../enterprise_user/_index.md) 的个人访问令牌：

- 阻止企业用户创建新的个人访问令牌。即使企业用户同时也是群组管理员，此行为也适用。
- 禁用企业用户现有的个人访问令牌。

> [!warning]
> 禁止企业用户使用个人访问令牌不会禁用[服务账户](service_accounts.md) 的个人访问令牌。

要禁止企业用户的个人访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 在 **企业用户** 下，选择 **禁用个人访问令牌**。
1. 选择 **保存更改**。

当你删除或阻止企业用户账户时，其个人访问令牌将自动吊销。

<a id="create-a-personal-access-token-programmatically"></a>

## 以编程方式创建个人访问令牌

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

你可以创建预定的个人访问令牌，作为测试或自动化的一部分。

先决条件：

- 你需要足够的访问权限来为你的极狐GitLab 实例运行 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。

要以编程方式创建个人访问令牌：

1. 打开 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 运行以下命令以引用用户名、令牌和范围。

   令牌长度必须为 20 个字符。范围必须有效，并可在 [源代码](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/auth.rb) 中查看。

   例如，要创建一个属于用户名为 `automation-bot` 的用户且一年后过期的令牌：

   ```ruby
   user = User.find_by_username('automation-bot')
   token = user.personal_access_tokens.create(scopes: ['read_user', 'read_repository'], name: '自动化令牌', expires_at: 365.days.from_now)
   token.set_token('token-string-here123')
   token.save!
   ```

此代码可以通过使用 [Rails runner](../../administration/operations/rails_console.md#using-the-rails-runner) 缩短为单行 shell 命令：

```shell
sudo gitlab-rails runner "token = User.find_by_username('automation-bot').personal_access_tokens.create(scopes: ['read_user', 'read_repository'], name: '自动化令牌', expires_at: 365.days.from_now); token.set_token('token-string-here123'); token.save!"
```

<a id="revoke-a-personal-access-token-programmatically"></a>

## 以编程方式吊销个人访问令牌

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

你可以以编程方式吊销个人访问令牌，作为测试或自动化的一部分。

先决条件：

- 你需要足够的访问权限来为你的极狐GitLab 实例运行 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。

要以编程方式吊销令牌：

1. 打开 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 要吊销 `token-string-here123` 的令牌，请运行以下命令：

   ```ruby
   token = PersonalAccessToken.find_by_token('token-string-here123')
   token.revoke!
   ```
    ```ruby
   token = PersonalAccessToken.find_by_token('token-string-here123')
   token.revoke!
   ```

这段代码可以通过 [Rails runner](../../administration/operations/rails_console.md#using-the-rails-runner) 简化为一行 shell 命令：

```shell
sudo gitlab-rails runner "PersonalAccessToken.find_by_token('token-string-here123').revoke!"
```

<a id="clone-repository-using-personal-access-token"></a>

## 使用个人访问令牌克隆仓库

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

要在 SSH 被禁用时使用个人访问令牌克隆仓库，请运行以下命令：

```shell
git clone https://<username>:<personal_token>@jihulab.com/gitlab-org/gitlab.git
```

此方法会将您的个人访问令牌保存在 bash 历史记录中。为避免这种情况，请运行以下命令：

```shell
git clone https://<username>@jihulab.com/gitlab-org/gitlab.git
```

当系统要求您输入 `https://jihulab.com` 的密码时，输入您的个人访问令牌。

`clone` 命令中的 `username`：

- 可以是任意字符串。
- 不能为空字符串。

如果您设置了依赖认证的自动化流水线，请务必记住这一点。

<a id="alternatives-to-personal-access-tokens"></a>

## 个人访问令牌的替代方案

对于通过 HTTPS 访问 Git，个人访问令牌的一种替代方案是使用 OAuth 凭据助手。

对于 CI/CD 作业中的认证，请考虑：

- 使用 [CI/CD 作业令牌](../../ci/jobs/ci_job_token.md)并结合[细粒度权限](../../ci/jobs/fine_grained_permissions.md)，进行流水线认证。
- 使用具有项目特定自动化所需最小权限的[项目访问令牌](../project/settings/project_access_tokens.md)。

<a id="related-topics"></a>

## 相关主题

- [群组访问令牌](../group/settings/group_access_tokens.md)
- [项目访问令牌](../project/settings/project_access_tokens.md)
- [个人访问令牌 API](../../api/personal_access_tokens.md)
- [支持细粒度个人访问令牌的 REST API 端点](../../auth/tokens/fine_grained_access_tokens.md)