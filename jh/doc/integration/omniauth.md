---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: OmniAuth
description: Configure external authentication with third-party identity providers.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

用户可以使用来自 Google、GitHub 和其他流行服务的凭据登录极狐GitLab。
[OmniAuth](https://rubygems.org/gems/omniauth/) 是极狐GitLab 用来提供此身份验证的 Rack 框架。

配置后，登录页面上会显示额外的登录选项。

<a id="supported-providers"></a>

## 支持的提供商

极狐GitLab 支持以下 OmniAuth 提供商。

| 提供商文档 | OmniAuth 提供商名称 |
| --- | --- |
| [AliCloud](alicloud.md) | `alicloud` |
| [Atlassian](../administration/auth/atlassian.md) | `atlassian_oauth2` |
| [Auth0](auth0.md) | `auth0` |
| [AWS Cognito](../administration/auth/cognito.md) | `cognito` |
| [Azure v2](azure.md) | `azure_activedirectory_v2` |
| [Bitbucket Cloud](bitbucket.md) | `bitbucket` |
| [通用 OAuth 2.0](oauth2_generic.md) | `oauth2_generic` |
| [GitHub](github.md) | `github` |
| [JihuLab.com](gitlab.md) | `gitlab` |
| [Google](google.md) | `google_oauth2` |
| [JWT](../administration/auth/jwt.md) | `jwt` |
| [Kerberos](kerberos.md) | `kerberos` |
| [OpenID Connect](../administration/auth/oidc.md) | `openid_connect` |
| [Salesforce](salesforce.md) | `salesforce` |
| [SAML](saml.md) | `saml` |
| [Shibboleth](shibboleth.md) | `shibboleth` |
| [企业微信](wecom.md) | `wecom` |

<a id="configure-common-settings"></a>

## 配置通用设置

配置 OmniAuth 提供商之前，请先配置所有提供商的通用设置。

| 选项 | 描述 |
| ------ | ----------- |
| `allow_bypass_two_factor`    | 允许用户使用指定提供商登录，无需双因素认证 (2FA)。可设置为 `true`、`false` 或提供商数组。更多信息，请参见 [绕过双因素认证](#bypass-two-factor-authentication)。 |
| `allow_single_sign_on`       | 启用 OmniAuth 登录时自动创建账户。可设置为 `true`、`false` 或提供商数组。提供商名称请参见 [支持的提供商表](#supported-providers)。当为 `false` 时，如果没有预先存在的极狐GitLab 账户，则不允许通过 OmniAuth 提供商账户登录。您必须先创建极狐GitLab 账户，然后在个人设置中将其与您的 OmniAuth 提供商账户关联。 |
| `auto_link_ldap_user`        | 为通过 OmniAuth 提供商创建的用户在极狐GitLab 中创建 LDAP 身份。要启用此设置，必须已启用 [LDAP 集成](../administration/auth/ldap/_index.md)。要求用户的 `uid` 在 LDAP 和 OmniAuth 提供商中相同。 |
| `auto_link_saml_user`        | 允许通过 SAML 提供商认证的用户在其电子邮件匹配时自动链接到现有极狐GitLab 用户。要启用此设置，必须已启用 SAML 集成。 |
| `auto_link_user`             | 允许通过 OmniAuth 提供商认证的用户在其电子邮件匹配时自动链接到现有极狐GitLab 用户。可设置为 `true`、`false` 或提供商数组。提供商名称请参见 [支持的提供商表](#supported-providers)。 |
| `auto_sign_in_with_provider` | 允许用户使用单一提供商名称自动登录。此名称必须与提供商名称匹配，如 `saml` 或 `google_oauth2`。为防止无限登录循环，用户必须在退出极狐GitLab 之前退出其身份提供商账户。存在如 [SAML](https://jihulab.com/gitlab-cn/gitlab/-/issues/14414) 等正在进行的特性增强，以实现支持 OmniAuth 提供商的联合退出。 |
| `block_auto_created_users`   | 将自动创建的用户置于 [待批准](../administration/moderate_users.md#users-pending-approval) 状态（无法登录），直到管理员批准。为 `false` 时，请确保定义您可以控制的提供商，如 SAML 或 Google。否则，互联网上的任何用户都可以在未经管理员批准的情况下登录极狐GitLab。为 `true` 时，自动创建的用户默认被阻止，必须由管理员解除阻止后才能登录。 |
| `enabled`                    | 启用或禁用在极狐GitLab 中使用 OmniAuth。为 `false` 时，OmniAuth 提供商按钮不会在用户界面中显示。 |
| `external_providers`         | 允许您定义哪些 OmniAuth 提供商为 `external`，以便通过此类提供商创建账户或登录的所有用户都无法访问内部项目。必须使用提供商的完整名称，如 Google 的 `google_oauth2`。更多信息，请参见 [创建外部提供商列表](#create-an-external-providers-list)。 |
| `providers`                  | 提供商名称可在 [支持的提供商表](#supported-providers) 中找到。 |
| `sync_profile_attributes`    | 登录时从提供商同步的配置文件属性列表。更多信息，请参见 [保持 OmniAuth 用户配置文件更新](#keep-omniauth-user-profiles-up-to-date)。 |
| `sync_profile_from_provider` | 极狐GitLab 应自动从中同步配置文件信息的提供商名称列表。条目必须与提供商名称匹配，如 `saml` 或 `google_oauth2`。更多信息，请参见 [保持 OmniAuth 用户配置文件更新](#keep-omniauth-user-profiles-up-to-date)。 |

<a id="configure-initial-settings"></a>

### 配置初始设置

要更改 OmniAuth 设置：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # 警告！
   # 这允许用户在没有预先创建用户账户的情况下登录。使用数组定义允许的提供商，例如 ["saml", "google_oauth2"]，或设置为 true/false 来允许所有提供商或无提供商。
   # 认证成功后，用户账户将自动创建。
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml', 'google_oauth2']
   gitlab_rails['omniauth_auto_link_ldap_user'] = true
   gitlab_rails['omniauth_block_auto_created_users'] = true
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`，更新 `globals.appConfig` 下的 `omniauth` 部分：

   ```yaml
   global:
     appConfig:
       omniauth:
         enabled: true
         allowSingleSignOn: ['saml', 'google_oauth2']
         autoLinkLdapUser: false
         blockAutoCreatedUsers: true
   ```

   更多细节，请参见
   [globals 文档](https://gitlab.cn/docs/charts/charts/globals/#omniauth)。
1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_allow_single_sign_on'] = ['saml', 'google_oauth2']
           gitlab_rails['omniauth_auto_link_ldap_user'] = true
           gitlab_rails['omniauth_block_auto_created_users'] = true
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   ## OmniAuth 设置
   omniauth:
     # 允许通过 Google、GitLab 等 OmniAuth 提供商登录
     # 11.4 之前的版本需要将其设置为 true
     # enabled: true

     # 警告！
     # 这允许用户在没有预先创建用户账户的情况下登录。使用数组定义允许的提供商，例如 ["saml", "google_oauth2"]，或设置为 true/false 来允许所有提供商或无提供商。
     # 认证成功后，用户账户将自动创建。
     allow_single_sign_on: ["saml", "google_oauth2"]

     auto_link_ldap_user: true

     # 锁定这些用户，直到管理员批准（默认：true）。
     block_auto_created_users: true
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

配置这些设置后，你可以配置你选择的[提供商](#supported-providers)。

<a id="per-provider-configuration"></a>

### 按提供商配置

{{< history >}}

- 在极狐GitLab 15.3 中引入。

{{< /history >}}

如果设置了 `allow_single_sign_on`，极狐GitLab 会使用 OmniAuth `auth_hash` 中返回的以下字段之一作为登录用户的极狐GitLab 用户名，选择第一个存在的字段：

- `username`。
- `nickname`。
- `email`。

你可以按提供商创建极狐GitLab 配置，通过 `args` 提供给[提供商](#supported-providers)。如果你在提供商的 `args` 中设置了 `gitlab_username_claim` 变量，可以选择另一个声明作为极狐GitLab 用户名。选择的声明必须唯一，以避免冲突。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```ruby
gitlab_rails['omniauth_providers'] = [

  # 使用名称 PROVIDER_NAME 配置提供商的通用模式

  gitlab_rails['omniauth_providers'] = {
    name: "PROVIDER_NAME"
    ...
    args: { gitlab_username_claim: 'sub' } # 对于使用您配置的提供商登录的用户，极狐GitLab 用户名将设置为从提供商接收到的 "sub"
  },

  # 以下为使用 GitHub 和 Kerberos 的示例

  gitlab_rails['omniauth_providers'] = {
    name: "github"
    ...
    args: { gitlab_username_claim: 'name' } # 对于使用 GitHub 登录的用户，极狐GitLab 用户名将设置为从 GitHub 接收到的 "name"
  },
  {
    name: "kerberos"
    ...
    args: { gitlab_username_claim: 'uid' } # 对于使用 Kerberos 登录的用户，极狐GitLab 用户名将设置为从 Kerberos 接收到的 "uid"
  },
]
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```yaml
- { name: 'PROVIDER_NAME',
  # ...
  args: { gitlab_username_claim: 'sub' }
}
- { name: 'github',
  # ...
  args: { gitlab_username_claim: 'name' }
}
- { name: 'kerberos',
  # ...
  args: { gitlab_username_claim: 'uid' }
}
```

{{< /tab >}}

{{< /tabs >}}

<a id="passwords-for-users-created-via-omniauth"></a>

### 通过 OmniAuth 创建的用户的密码

[通过集成认证创建的用户的生成密码](../user/profile/user_passwords.md) 指南提供了关于极狐GitLab 如何为通过 OmniAuth 创建的用户生成和设置密码的概述。

<a id="enable-omniauth-for-an-existing-user"></a>

## 为现有用户启用 OmniAuth

如果您是现有用户，在极狐GitLab 账户创建后，您可以激活一个 OmniAuth 提供商。例如，如果您最初使用 LDAP 登录，可以启用如 Google 这样的 OmniAuth 提供商。

1. 使用您的极狐GitLab 凭据、LDAP 或其他 OmniAuth 提供商登录极狐GitLab。
1. 在右上角，选择您的头像。
1. 选择 **编辑配置文件**。
1. 在左侧边栏中，选择 **访问** > **密码与认证**。
1. 在 **服务登录** 部分，选择 OmniAuth 提供商，例如 Google。
1. 您会被重定向到提供商。授权极狐GitLab 后，您会被重定向回极狐GitLab。

您现在可以使用所选的 OmniAuth 提供商登录极狐GitLab。

<a id="enable-or-disable-sign-in-with-an-omniauth-provider-without-disabling-import-sources"></a>

## 在不禁用导入源的情况下启用或禁用 OmniAuth 提供商登录

管理员可以为某些 OmniAuth 提供商启用或禁用登录。

> [!NOTE]
> 默认情况下，`config/gitlab.yml` 中配置的所有 OAuth 提供商登录均已启用。

要启用或禁用 OmniAuth 提供商：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **登录限制**。
1. 在 **已启用的 OAuth 认证源** 部分，选中或清除要启用或禁用的每个提供商的复选框。

<a id="disable-omniauth"></a>

## 禁用 OmniAuth

OmniAuth默认启用。但是，只有在提供商已配置并[启用](#enable-or-disable-sign-in-with-an-omniauth-provider-without-disabling-import-sources)的情况下，OmniAuth 才会工作。

如果即使单独禁用，OmniAuth 提供商仍会引起问题，您可以通过修改配置文件来禁用整个 OmniAuth 子系统。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```ruby
gitlab_rails['omniauth_enabled'] = false
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```yaml
omniauth:
  enabled: false
```

{{< /tab >}}

{{< /tabs >}}

<a id="link-existing-users-to-omniauth-users"></a>

## 将现有用户链接到 OmniAuth 用户

如果电子邮件地址匹配，您可以自动将 OmniAuth 用户与现有极狐GitLab 用户链接。

以下示例为 OpenID Connect 提供商和 Google OAuth 提供商启用了自动链接。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```ruby
gitlab_rails['omniauth_auto_link_user'] = ["openid_connect", "google_oauth2"]
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```yaml
omniauth:
  auto_link_user: ["openid_connect", "google_oauth2"]
```

{{< /tab >}}

{{< /tabs >}}

这种启用自动链接的方法适用于所有提供商，[除了 SAML](https://jihulab.com/gitlab-cn/gitlab/-/issues/338293)。要为 SAML 启用自动链接，请参阅 [SAML 设置说明](saml.md#configure-saml-support-in-gitlab)。

<a id="create-an-external-providers-list"></a>

## 创建外部提供商列表

您可以定义外部 OmniAuth 提供商列表。通过列表中的提供商创建账户或登录极狐GitLab 的用户无法访问 [内部项目](../user/public_access.md#internal-projects-and-groups)，并被标记为 [外部用户](../administration/external_users.md)。

要定义外部提供商列表，请使用提供商的完整名称，例如 Google 的 `google_oauth2`。提供商名称请参见 [支持的提供商表](#supported-providers) 中的 **OmniAuth 提供商名称** 列。

> [!NOTE]
> 如果从外部提供商列表中移除某个 OmniAuth 提供商，您必须手动更新使用该登录方式的用户，使其账户升级为完整的内部账户。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```ruby
gitlab_rails['omniauth_external_providers'] = ['saml', 'google_oauth2']
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```yaml
omniauth:
  external_providers: ['saml', 'google_oauth2']
```

{{< /tab >}}

{{< /tabs >}}

<a id="keep-omniauth-user-profiles-up-to-date"></a>

## 保持 OmniAuth 用户配置文件更新

{{< history >}}

- 在极狐GitLab 17.9 中引入了 `job_title` 和 `organization` 属性。

{{< /history >}}

> [!NOTE]
> 某些提供商需要额外配置才能同步这些属性。例如，SAML 提供商需要[映射配置文件属性](saml.md#map-profile-attributes)。

您可以从选定的 OmniAuth 提供商启用配置文件同步。您可以同步以下用户属性的任意组合：

- `name`
- `email`
- `job_title`
- `location`
- `organization`

当使用 LDAP 认证时，用户的姓名和电子邮件始终同步。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_sync_profile_from_provider'] = ['saml', 'google_oauth2']
   gitlab_rails['omniauth_sync_profile_attributes'] = ['name', 'email', 'job_title', 'location', 'organization']
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > values.yaml
   ```

1. 编辑 `values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         syncProfileFromProvider: ['saml', 'google_oauth2']
         syncProfileAttributes: ['name', 'email', 'job_title', 'location', 'organization']
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_sync_profile_from_provider'] = ['saml', 'google_oauth2']
           gitlab_rails['omniauth_sync_profile_attributes'] = ['name', 'email', 'job_title', 'location', 'organization']
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       sync_profile_from_provider: ['saml', 'google_oauth2']
       sync_profile_attributes: ['name', 'email', 'job_title', 'location', 'organization']
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="bypass-two-factor-authentication"></a>

## 绕过双因素认证

对于某些 OmniAuth 提供商，用户可以在不使用双因素认证 (2FA) 的情况下登录。

要绕过 2FA，您可以：

- 使用数组定义允许的提供商（例如 `['saml', 'google_oauth2']`）。
- 指定 `true` 以允许所有提供商，或 `false` 以不允许任何提供商。

此选项应仅针对已经具备 2FA 的提供商进行配置。默认值为 `false`。

此配置不适用于 SAML。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```ruby
gitlab_rails['omniauth_allow_bypass_two_factor'] = ['saml', 'google_oauth2']
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```yaml
omniauth:
  allow_bypass_two_factor: ['saml', 'google_oauth2']
```

{{< /tab >}}

{{< /tabs >}}

<a id="sign-in-with-a-provider-automatically"></a>

## 自动使用提供商登录

您可以在极狐GitLab 配置中添加 `auto_sign_in_with_provider` 设置，以将登录请求重定向到您的 OmniAuth 提供商进行认证。这消除了在登录前选择提供商的需要。

例如，要为 [Azure v2 集成](azure.md) 启用自动登录：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```ruby
gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'azure_activedirectory_v2'
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```yaml
omniauth:
  auto_sign_in_with_provider: azure_activedirectory_v2
```

{{< /tab >}}

{{< /tabs >}}

请记住，每次登录尝试都会被重定向到 OmniAuth 提供商，因此您无法使用本地凭据登录。确保至少有一个 OmniAuth 用户是管理员。

您也可以通过浏览到 `https://gitlab.example.com/users/sign_in?auto_sign_in=false` 来绕过自动登录。

<a id="use-a-custom-omniauth-provider-icon"></a>

## 使用自定义 OmniAuth 提供商图标

大多数受支持的提供商都包含用于渲染登录按钮的内置图标。

要使用自己的图标，请确保您的图片优化为 64 x 64 像素渲染，然后通过以下两种方式之一覆盖图标：

- **提供自定义图片路径**：

  1. 如果您将图片托管在极狐GitLab 服务器域之外，请确保您的 [内容安全策略](https://gitlab.cn/docs/omnibus/settings/configuration/#set-a-content-security-policy) 已配置为允许访问该图片文件。
  1. 根据您的极狐GitLab 安装方法，在极狐GitLab 配置文件中添加自定义 `icon` 参数。请参阅 [OpenID Connect OmniAuth 提供商](../administration/auth/oidc.md) 了解 OpenID Connect 提供商的示例。
- **直接将图片嵌入配置文件**：此示例创建了您图片的 Base64 编码版本，您可以通过 [Data URL](https://developer.mozilla.org/en-US/docs/Web/URI/Schemes/data) 提供：

  1. 使用 GNU `base64` 命令（如 `base64 -w 0 <logo.png>`）对图片文件进行编码，该命令返回单行 `<base64-data>` 字符串。
  1. 将 Base64 编码的数据添加到极狐GitLab 配置文件中的自定义 `icon` 参数：

     ```yaml
     omniauth:
       providers:
         - { name: '...'
             icon: 'data:image/png;base64,<base64-data>'
             # 为可读性而删除的其他参数
           }
     ```

<a id="change-apps-or-configuration"></a>

## 更改应用或配置

由于极狐GitLab 中的 OAuth 不支持将同一个外部认证和授权提供商设置为多个提供商，因此如果更改提供商或应用，必须同时更新极狐GitLab 配置和用户标识。
例如，您可以设置 `saml` 和 `azure_activedirectory_v2`，但不能在同一配置中添加第二个 `azure_activedirectory_v2`。

这些说明适用于极狐GitLab 存储 `extern_uid` 且该标识是用户认证唯一数据的所有认证方法。

在提供商内部更改应用时，如果用户的 `extern_uid` 未更改，则只需更新极狐GitLab 配置。

要交换配置：

1. 更改 `gitlab.rb` 文件中的提供商配置。
1. 为所有在极狐GitLab 中具有先前提供商身份的用户更新 `extern_uid`。

要查找 `extern_uid`，请查看现有用户当前的 `extern_uid`，该 ID 与您当前提供商中同一用户的相应字段匹配。

有两种方法可以更新 `extern_uid`：

- 使用 [用户 API](../api/users.md#modify-a-user)。传递提供商名称和新的 `extern_uid`。
- 使用 [Rails 控制台](../administration/operations/rails_console.md)：

  ```ruby
  Identity.where(extern_uid: 'old-id').update!(extern_uid: 'new-id')
  ```

<a id="known-issues"></a>

## 已知问题

大多数支持的 OmniAuth 提供商不支持通过 HTTP 密码认证进行 Git 操作。作为解决办法，您可以使用[个人访问令牌](../user/profile/personal_access_tokens.md)进行认证。
