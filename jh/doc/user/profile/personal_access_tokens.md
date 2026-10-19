---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用个人访问令牌通过极狐GitLab API 或 Git over HTTPS 进行身份验证。包括创建、轮换、撤销、作用域和过期设置。
title: 个人访问令牌
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

个人访问令牌提供对极狐GitLab 的经过身份验证的访问。它们是 [OAuth2 令牌](../../api/oauth2.md)的替代方案，与群组访问令牌和项目访问令牌类似，但归属于用户，而不是群组或项目。

您可以使用个人访问令牌进行身份验证：

- 使用[极狐GitLab API](../../api/rest/authentication.md#personal-project-and-group-access-tokens)。
- 使用 Git over HTTPS。请使用：
  - 任意非空值作为用户名。
  - 个人访问令牌作为密码。

> [!note]
> 如果启用了
> [双重身份验证 (2FA)](account/two_factor_authentication.md) 或
> [SAML](../../integration/saml.md#password-generation-for-users-created-through-saml)，则必须使用个人访问令牌进行身份验证。

某些需要用户名的极狐GitLab 功能，例如
[极狐GitLab 管理的 Terraform 状态后端](../infrastructure/iac/terraform_state.md#use-your-gitlab-backend-as-a-remote-data-source)
和[容器镜像仓库](../packages/container_registry/authenticate_with_container_registry.md)，会使用带有极狐GitLab 用户名的个人访问令牌。在这些情况下，用户名是必需的，但不作为身份验证的一部分进行评估。有关更多信息，请参阅[议题 212953](https://gitlab.com/gitlab-org/gitlab/-/issues/212953)。

在极狐GitLab 私有化部署实例上，管理员可以使用[用户令牌 API](../../api/user_tokens.md#create-an-impersonation-token) 创建模拟令牌，以特定用户的身份进行身份验证。

<a id="create-a-personal-access-token"></a>

## 创建个人访问令牌

> [!flag]
> 扩展的最大允许有效期限制的可用性由功能标志控制。

创建个人访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 从**生成令牌**下拉列表中，选择**旧版令牌**。
1. 在**令牌名称**中，输入令牌的名称。
1. 可选。在**令牌描述**中，输入令牌的描述。
1. 在**过期日期**中，输入令牌的到期日期。
   - 令牌将在该日期 UTC 午夜过期。
   - 如果您不输入日期，过期日期将设置为从今天起 365 天。
   - 默认情况下，过期日期不能超过从今天起 365 天。在极狐GitLab 17.6 及更高版本中，
     管理员可以[修改访问令牌的最长有效期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。
1. 选择一个或多个[个人访问令牌作用域](../../security/tokens/access_token_scopes.md)。
1. 选择**生成令牌**。

将显示个人访问令牌。请将个人访问令牌保存在安全的地方。离开或刷新页面后，您将无法再次查看它。

所有访问令牌都继承为个人访问令牌配置的[默认前缀设置](../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)。

<a id="prefill-personal-access-token-details"></a>

### 预填个人访问令牌详细信息

您可以通过将名称、描述和作用域列表附加到 URL 来预填个人访问令牌的详细信息。例如：

```plaintext
https://gitlab.example.com/-/user_settings/personal_access_tokens?name=Example+Access+token&description=My+description&scopes=api,read_user
```

> [!note]
> 必须谨慎对待个人访问令牌。有关管理个人访问令牌的指导，请参阅[令牌安全注意事项](../../security/tokens/_index.md#security-considerations)。

<a id="authenticate-with-an-access-token"></a>

## 使用访问令牌进行身份验证

使用访问令牌通过极狐GitLab REST API、Git over HTTPS 以及与极狐GitLab 集成的
第三方工具进行身份验证。

<a id="use-rest-api"></a>

### 使用 REST API

在 `PRIVATE-TOKEN` 请求头中传递您的令牌：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects"
```

有关完整详细信息，请参阅
[REST API 身份验证](../../api/rest/authentication.md#personal-project-and-group-access-tokens)。

<a id="use-git-over-https"></a>

### 使用 Git over HTTPS

当 Git 提示输入凭据时，将您的令牌用作密码：

- 用户名：任意非空字符串（极狐GitLab 不会验证此值）。
- 密码：您的个人访问令牌。

例如：

```shell
git clone https://oauth2:<your_access_token>@gitlab.example.com/gitlab-org/gitlab.git
```

<a id="use-third-party-tools-and-ide-extensions"></a>

### 使用第三方工具和 IDE 扩展

与极狐GitLab 集成的工具，例如 IDE 扩展、CI/CD 工具和自动化脚本，都接受个人访问令牌进行身份验证。每个工具的文档都描述了其所需的作用域以及如何输入您的令牌：

- [GitLab CLI (`glab`)](https://gitlab.cn/docs/cli/#authenticate-with-gitlab)
- [GitLab for VS Code 扩展](../../editor_extensions/visual_studio_code/setup.md#authenticate-with-gitlab)
- [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../editor_extensions/jetbrains_ide/setup.md#authenticate-with-gitlab)
- [GitLab for Visual Studio extension](../../editor_extensions/visual_studio/setup.md#authenticate-with-gitlab)
- [GitLab for Eclipse](../../editor_extensions/eclipse/setup.md#authenticate-with-gitlab)
- [GitLab plugin for Neovim](../../editor_extensions/neovim/setup.md#authenticate-with-gitlab)

对于 CI/CD 流水线，建议改用 [CI/CD 作业令牌](../../ci/jobs/ci_job_token.md)。

有关个人访问令牌的安全指导，请参阅[令牌安全注意事项](../../security/tokens/_index.md#security-considerations)。

<a id="view-token-usage-information"></a>

## 查看令牌使用信息

个人访问令牌页面显示有关您的访问令牌的信息。

在此页面上，您可以执行以下操作：

- 创建、轮换和撤销个人访问令牌。
- 查看所有活动和未活动的个人访问令牌。
- 查看令牌信息，包括作用域、分配的角色和过期日期。
- 查看使用信息，包括使用日期和最近五个不同的连接 IP 地址。
  > [!note]
  > 当令牌执行 Git 操作或通过 [REST](../../api/rest/_index.md) 或
  > [GraphQL](../../api/graphql/_index.md) API 进行身份验证操作时，极狐GitLab 会定期更新令牌使用信息。
  > 令牌使用时间每 10 分钟更新一次。
  > 令牌使用 IP 地址每分钟更新一次。

查看您的个人访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。

选择令牌的名称以打开详细信息面板。默认情况下，仅显示活动令牌。使用搜索栏筛选访问令牌列表。

<a id="rotate-a-personal-access-token"></a>

## 轮换个人访问令牌

轮换令牌以创建一个与原始令牌具有相同权限和作用域的新令牌。原始令牌会立即变为未活动状态，极狐GitLab 会保留两个版本以供审计之用。

> [!warning]
> 此操作无法撤销。依赖已轮换访问令牌的工具将停止工作，直到
> 您引用您的新令牌。

轮换个人访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 在活动令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择**轮换** ({{< icon name="retry" >}})。
1. 在确认对话框中，选择**轮换**。

<a id="revoke-a-personal-access-token"></a>

## 撤销个人访问令牌

撤销令牌以立即使其失效并防止进一步使用。极狐GitLab 会保留该令牌以供审计之用。您无法永久删除令牌，但可以筛选令牌列表以仅显示活动令牌。

> [!warning]
> 此操作无法撤销。依赖已撤销访问令牌的工具将停止工作，直到
> 您添加新令牌。

撤销个人访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 在活动令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择**撤销** ({{< icon name="remove" >}})。
1. 在确认对话框中，选择**撤销**。

<a id="access-token-expiration"></a>

## 访问令牌过期

个人、群组和项目访问令牌将在到期日期的 UTC 午夜过期。过期后，它们将无法再用于对请求进行身份验证。

新的访问令牌必须具有过期日期。如果在创建令牌时未明确设置过期日期，则会应用从当前日期起 365 天的过期日期。在极狐GitLab 旗舰版中，管理员可以为访问令牌配置[最大允许有效期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。

根据您的极狐GitLab 版本和交付方式，您现有的访问令牌在升级极狐GitLab 版本时可能会自动应用过期日期。有关更多信息，请参阅[永不过期的访问令牌](../../update/deprecations.md#non-expiring-access-tokens)。

<a id="personal-access-token-expiry-emails"></a>

### 个人访问令牌过期电子邮件

极狐GitLab 每天 UTC 凌晨 1:00 运行一次检查，以识别即将过期的个人访问令牌。用户会在令牌过期前七天收到电子邮件通知。在极狐GitLab 17.6 及更高版本中，还会在令牌过期前 30 天和 60 天发送通知。

<a id="personal-access-token-expiry-calendar"></a>

### 个人访问令牌过期日历

您可以订阅一个 iCalendar 端点，其中包含每个令牌到期日期的事件。登录后，此端点位于 `/-/user_settings/personal_access_tokens.ics`。

<a id="create-a-service-account-personal-access-token-with-no-expiry-date"></a>

### 创建无过期日期的服务账号个人访问令牌

您可以[为服务账号创建无过期日期的个人访问令牌](../../api/service_accounts.md#create-a-personal-access-token-for-a-group-service-account)。与非服务账号个人访问令牌不同，这些个人访问令牌永不过期。

> [!note]
> 允许为服务账号创建无过期日期的个人访问令牌仅影响您更改此设置后创建的令牌。它不会影响现有令牌。

<a id="gitlabcom"></a>

#### JihuLab.com

先决条件：

- 您必须具有顶级群组的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在**个人访问令牌**下，清除**要求服务账号设置过期日期**复选框。

现在，您可以为服务账号用户创建无过期日期的个人访问令牌。

<a id="gitlab-self-managed"></a>

#### 极狐GitLab 私有化部署

先决条件：

- 您必须是极狐GitLab 私有化部署实例的管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**账号和限制**。
1. 清除**服务账号令牌过期**复选框。

现在，您可以为服务账号用户创建无过期日期的个人访问令牌。

<a id="clone-repository-using-personal-access-token"></a>

## 使用个人访问令牌克隆代码仓库

要在 SSH 被禁用时克隆代码仓库，请通过运行以下命令使用个人访问令牌进行克隆：

```shell
git clone https://<username>:<personal_token>@gitlab.com/gitlab-org/gitlab.git
```

此方法会将您的个人访问令牌保存在 bash 历史记录中。为避免这种情况，请运行以下命令：

```shell
git clone https://<username>@gitlab.com/gitlab-org/gitlab.git
```

当系统提示您输入 `https://gitlab.com`的密码时，请输入您的个人访问令牌。

`clone` 命令中的 `username`：

- 可以是任意字符串值。
- 不能是空字符串。

如果您设置了依赖身份验证的自动化流水线，请记住这一点。

<a id="disable-access-tokens"></a>

## 禁用访问令牌

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 管理员访问权限。

您可以阻止用户在整个极狐GitLab 实例中使用访问令牌进行身份验证。此设置会影响个人访问令牌、群组访问令牌、项目访问令牌和模拟令牌。此设置也适用于服务账号的个人访问令牌。

当您禁用访问令牌时，以下规则适用：

- 用户无法使用个人访问令牌登录极狐GitLab。
- 个人访问令牌页面会返回 `404 Not Found` 错误。
- 用于 RSS、Atom 和日历 feed 的 feed 令牌将停止工作。
- 使用个人访问令牌进行身份验证的 API 请求会被拒绝。

为实例禁用访问令牌：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**账号和限制**。
1. 选中**禁用访问令牌**复选框。
1. 选择**保存更改**。

您还可以在应用程序设置 API 中使用 [`disable_personal_access_tokens` 属性](../../api/settings.md#available-settings)。

<a id="disable-personal-access-tokens-for-enterprise-users"></a>

## 为企业用户禁用个人访问令牌

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

先决条件：

- 企业用户所属群组的所有者角色。

禁用群组的[企业用户](../enterprise_user/_index.md)的个人访问令牌：

- 阻止企业用户创建新的个人访问令牌。即使企业用户同时也是群组的管理员，
  此行为也适用。
- 禁用企业用户现有的个人访问令牌。

> [!warning]
> 为企业用户禁用个人访问令牌不会禁用[服务账号](service_accounts.md)的个人访问令牌。

禁用企业用户的个人访问令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在**企业用户**下，选择**禁用个人访问令牌**。
1. 选择**保存更改**。

当您删除或封锁企业用户账号时，其个人访问令牌会自动撤销。

<a id="create-a-personal-access-token-programmatically"></a>

## 以编程方式创建个人访问令牌

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以在测试或自动化中创建预定的个人访问令牌。

先决条件：

- 您需要足够的访问权限来为您的极狐GitLab 实例运行
  [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。

以编程方式创建个人访问令牌：

1. 打开 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 运行以下命令以引用用户名、令牌和作用域。

   令牌必须为 20 个字符长。作用域必须有效，并且可以在
   [源代码中](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/auth.rb)查看。

   例如，要创建一个属于用户名为 `automation-bot`的用户且一年后过期的令牌：

   ```ruby
   user = User.find_by_username('automation-bot')
   token = user.personal_access_tokens.create(scopes: ['read_user', 'read_repository'], name: 'Automation token', expires_at: 365.days.from_now)
   token.set_token('token-string-here123')
   token.save!
   ```

通过使用
[Rails runner](../../administration/operations/rails_console.md#using-the-rails-runner)，此代码可以缩短为单行 shell 命令：

```shell
sudo gitlab-rails runner "token = User.find_by_username('automation-bot').personal_access_tokens.create(scopes: ['read_user', 'read_repository'], name: 'Automation token', expires_at: 365.days.from_now); token.set_token('token-string-here123'); token.save!"
```

<a id="revoke-a-personal-access-token-programmatically"></a>

## 以编程方式撤销个人访问令牌

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以在测试或自动化中以编程方式撤销个人访问令牌。

先决条件：

- 您需要足够的访问权限来为您的极狐GitLab 实例运行 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。

以编程方式撤销令牌：

1. 打开 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 要撤销 `token-string-here123`的令牌，请运行以下命令：

   ```ruby
   token = PersonalAccessToken.find_by_token('token-string-here123')
   token.revoke!
   ```

通过使用
[Rails runner](../../administration/operations/rails_console.md#using-the-rails-runner)，此代码可以缩短为单行 shell 命令：

```shell
sudo gitlab-rails runner "PersonalAccessToken.find_by_token('token-string-here123').revoke!"
```

<a id="use-dpop-with-personal-access-tokens"></a>

## 将 DPoP 与个人访问令牌一起使用

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

持有证明 (DPoP) 可增强个人访问令牌的安全性，并最大限度地减少意外令牌泄露的影响。当您在账户上启用此功能时，所有包含 PAT 的 REST 和 GraphQL API 请求还必须提供已签名的 DPoP 请求头。创建已签名的 DPoP 请求头需要您相应的私有 SSH 密钥。

> [!note]
> 如果您启用此功能，所有没有有效 DPoP 请求头的 API 请求都会返回 `DpopValidationError` 错误。
>
> 对于包含访问令牌的 Git over HTTPS 操作，不需要 DPoP 请求头。

先决条件：

- 您必须向您的账户[添加至少一个公共 SSH 密钥](../ssh.md#add-an-ssh-key-to-your-gitlab-account)，
  其**用途类型**为**签名**或**身份验证和签名**。
  - 您的 SSH 密钥类型必须为 RSA。
- 您必须已为您的极狐GitLab 账户安装并配置了 [GitLab CLI](../../editor_extensions/gitlab_cli/_index.md)。

要求对所有 REST 和 GraphQL API 调用使用 DPoP：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 转到**使用持有证明（DPoP）** 部分，然后选择**启用 DPoP**。
1. 选择**保存更改**。
1. 要使用 [GitLab CLI](../../editor_extensions/gitlab_cli/_index.md) 生成 DPoP 请求头，
   请在终端中运行此命令。将 `<your_access_token>` 替换为您的访问令牌，将 `~/.ssh/id_rsa`
   替换为您的私钥位置：

   ```shell
    glab auth dpop-gen --pat "<your_access_token>" --private-key ~/.ssh/id_rsa
   ```

您在 CLI 中生成的 DPoP 请求头可用于：

- 与 REST API 一起使用：

  ```shell
  curl --header "PRIVATE-TOKEN: <your_access_token>" \
    --header "DPoP: <dpop-from-glab>" \
    "https://gitlab.example.com/api/v4/projects"
  ```

- 与 GraphQL 一起使用：

  ```shell
   curl --request POST \
   --header "Content-Type: application/json" \
   --header "PRIVATE-TOKEN: <your_access_token>" \
   --header "DPoP: <dpop-from-glab>" \
   --data '{
   "query": "query { currentUser { id } }"
   }' \
   "https://gitlab.example.com/api/graphql"
  ```

要了解有关 DPoP 的更多信息，请参阅蓝图[发送方约束个人访问令牌](https://gitlab.com/gitlab-com/gl-security/product-security/appsec/security-feature-blueprints/-/tree/main/sender_constraining_access_tokens)。

<a id="alternatives-to-personal-access-tokens"></a>

## 个人访问令牌的替代方案

对于 Git over HTTPS，个人访问令牌的替代方案是使用 OAuth 凭据助手。

对于 CI/CD 作业中的身份验证，请考虑：

- 用于流水线身份验证的、具有[精细权限](../../ci/jobs/fine_grained_permissions.md)的 [CI/CD 作业令牌](../../ci/jobs/ci_job_token.md)
- 用于项目特定自动化的、具有最低所需权限的[项目访问令牌](../project/settings/project_access_tokens.md)
