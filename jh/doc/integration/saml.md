---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 私有化部署的 SAML SSO
description: Configure enterprise authentication with SAML integration for single sign-on access.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 对于 JihuLab.com，请参见 [JihuLab.com 群组的 SAML SSO](../user/group/saml_sso/_index.md)。

本页面介绍了如何为极狐GitLab 私有化部署设置实例范围的 SAML 单点登录 (SSO)。

你可以将极狐GitLab 配置为 SAML 服务提供商 (SP)。这样极狐GitLab 就能从 SAML 身份提供商 (IdP)（例如 Okta）消费断言来对用户进行身份验证。

有关以下内容的更多信息：

- OmniAuth 提供者设置，请参见 [OmniAuth 文档](omniauth.md)。
- 常用术语，请参见 [词汇表](../auth/auth_glossary.md)。

<a id="configure-saml-support-in-gitlab"></a>

## 在极狐GitLab 中配置 SAML 支持

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 确保极狐GitLab 已[配置 HTTPS](https://gitlab.cn/docs/omnibus/settings/ssl/)。
1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `saml` 添加为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户创建。
1. 要允许用户使用 SAML 注册而无需先手动创建账户，请编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
   gitlab_rails['omniauth_block_auto_created_users'] = false
   ```

1. 可选。如果首次 SAML 登录的用户电子邮件地址与现有极狐GitLab 用户匹配，你可以自动将其链接。为此，请在 `/etc/gitlab/gitlab.rb` 中添加以下设置：

   ```ruby
   gitlab_rails['omniauth_auto_link_saml_user'] = true
   ```

   只有极狐GitLab 账户的主电子邮件地址会与 SAML 响应中的电子邮件进行匹配。

   或者，用户也可以通过[为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user) 来手动将其 SAML 身份链接到现有极狐GitLab 账户。
1. 配置以下属性，使你的 SAML 用户无法更改它们：

   - [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
   - 与 `omniauth_auto_link_saml_user` 一起使用时使用的 `Email`。

   如果用户可以更改这些属性，他们就能以其他授权用户的身份登录。
   请参见你的 SAML IdP 文档，了解如何使这些属性不可更改。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加提供者配置：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "saml", # 必须为小写。
       label: "提供者名称", # 登录按钮的可选标签，默认为 "Saml"
       args: {
         assertion_consumer_service_url: "https://gitlab.example.com/users/auth/saml/callback",
         idp_cert_fingerprint: "2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6",
         idp_sso_target_url: "https://login.example.com/idp",
         issuer: "https://gitlab.example.com",
         name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
       }
     }
   ]
   ```

   | 参数                             | 描述 |
   | -------------------------------- | ----------- |
   | `assertion_consumer_service_url` | 极狐GitLab HTTPS 端点（将 `/users/auth/saml/callback` 附加到你的极狐GitLab 安装的 HTTPS URL 之后）。 |
   | `idp_cert_fingerprint`           | 你的 IdP 值。要从证书生成 SHA256 指纹，请参见[计算指纹](../user/group/saml_sso/troubleshooting.md#calculate-the-fingerprint)。 |
   | `idp_sso_target_url`             | 你的 IdP 值。 |
   | `issuer`                         | 更改为一个唯一名称，用于向 IdP 标识该应用程序。 |
   | `name_identifier_format`         | 你的 IdP 值。 |

   有关这些值的更多信息，请参见 [OmniAuth SAML 文档](https://github.com/omniauth/omniauth-saml)。有关其他配置设置的更多信息，请参见[在 IdP 上配置 SAML](#configure-saml-on-your-idp)。
1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 确保极狐GitLab 已[配置 HTTPS](https://gitlab.cn/docs/charts/installation/tls/)。
1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `saml` 添加为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户创建。
1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 要允许用户使用 SAML 注册而无需先手动创建账户，请编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         enabled: true
         allowSingleSignOn: ['saml']
         blockAutoCreatedUsers: false
   ```

1. 可选。如果 SAML 用户的电子邮件地址与现有极狐GitLab 用户匹配，你可以通过编辑 `gitlab_values.yaml` 添加以下设置来自动链接它们：

   ```yaml
   global:
     appConfig:
       omniauth:
         autoLinkSamlUser: true
   ```

   或者，用户也可以通过[为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user) 来手动将其 SAML 身份链接到现有极狐GitLab 账户。
1. 配置以下属性，使你的 SAML 用户无法更改它们：

   - [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
   - 与 `omniauth_auto_link_saml_user` 一起使用时使用的 `Email`。

   如果用户可以更改这些属性，他们就能以其他授权用户的身份登录。
   请参见你的 SAML IdP 文档，了解如何使这些属性不可更改。
1. 将以下内容放入名为 `saml.yaml` 的文件中，用作 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: '提供者名称' # 登录按钮的可选标签，默认为 "Saml"
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

   | 参数                             | 描述 |
   | -------------------------------- | ----------- |
   | `assertion_consumer_service_url` | 极狐GitLab HTTPS 端点（将 `/users/auth/saml/callback` 附加到你的极狐GitLab 安装的 HTTPS URL 之后）。 |
   | `idp_cert_fingerprint`           | 你的 IdP 值。要从证书生成 SHA256 指纹，请参见[计算指纹](../user/group/saml_sso/troubleshooting.md#calculate-the-fingerprint)。 |
   | `idp_sso_target_url`             | 你的 IdP 值。 |
   | `issuer`                         | 更改为一个唯一名称，用于向 IdP 标识该应用程序。 |
   | `name_identifier_format`         | 你的 IdP 值。 |

   有关这些值的更多信息，请参见 [OmniAuth SAML 文档](https://github.com/omniauth/omniauth-saml)。有关其他配置设置的更多信息，请参见[在 IdP 上配置 SAML](#configure-saml-on-your-idp)。
1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 编辑 `gitlab_values.yaml` 并添加提供者配置：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 确保极狐GitLab 已[配置 HTTPS](https://gitlab.cn/docs/omnibus/settings/ssl/)。
1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `saml` 添加为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户创建。
1. 要允许用户使用 SAML 注册而无需先手动创建账户，请编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
           gitlab_rails['omniauth_block_auto_created_users'] = false
   ```

1. 可选。如果 SAML 用户的电子邮件地址与现有极狐GitLab 用户匹配，你可以通过编辑 `docker-compose.yml` 添加以下设置来自动链接它们：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_auto_link_saml_user'] = true
   ```

   或者，用户也可以通过[为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user) 来手动将其 SAML 身份链接到现有极狐GitLab 账户。
1. 配置以下属性，使你的 SAML 用户无法更改它们：

   - [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
   - 与 `omniauth_auto_link_saml_user` 一起使用时使用的 `Email`。

   如果用户可以更改这些属性，他们就能以其他授权用户的身份登录。
   请参见你的 SAML IdP 文档，了解如何使这些属性不可更改。
1. 编辑 `docker-compose.yml` 并添加提供者配置：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_providers'] = [
             {
               name: "saml",
               label: "提供者名称", # 登录按钮的可选标签，默认为 "Saml"
               args: {
                 assertion_consumer_service_url: "https://gitlab.example.com/users/auth/saml/callback",
                 idp_cert_fingerprint: "2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6",
                 idp_sso_target_url: "https://login.example.com/idp",
                 issuer: "https://gitlab.example.com",
                 name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
               }
             }
           ]
   ```

   | 参数                             | 描述 |
   | -------------------------------- | ----------- |
   | `assertion_consumer_service_url` | 极狐GitLab HTTPS 端点（将 `/users/auth/saml/callback` 附加到你的极狐GitLab 安装的 HTTPS URL 之后）。 |
   | `idp_cert_fingerprint`           | 你的 IdP 值。要从证书生成 SHA256 指纹，请参见[计算指纹](../user/group/saml_sso/troubleshooting.md#calculate-the-fingerprint)。 |
   | `idp_sso_target_url`             | 你的 IdP 值。 |
   | `issuer`                         | 更改为一个唯一名称，用于向 IdP 标识该应用程序。 |
   | `name_identifier_format`         | 你的 IdP 值。 |

   有关这些值的更多信息，请参见 [OmniAuth SAML 文档](https://github.com/omniauth/omniauth-saml)。有关其他配置设置的更多信息，请参见[在 IdP 上配置 SAML](#configure-saml-on-your-idp)。
1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 确保极狐GitLab 已[配置 HTTPS](../install/self_compiled/_index.md#using-https)。
1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `saml` 添加为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户创建。
1. 要允许用户使用 SAML 注册而无需先手动创建账户，请编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       enabled: true
       allow_single_sign_on: ["saml"]
       block_auto_created_users: false
   ```

1. 可选。如果 SAML 用户的电子邮件地址与现有极狐GitLab 用户匹配，你可以通过编辑 `/home/git/gitlab/config/gitlab.yml` 添加以下设置来自动链接它们：

   ```yaml
   production: &base
     omniauth:
       auto_link_saml_user: true
   ```

   或者，用户也可以通过[为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user) 来手动将其 SAML 身份链接到现有极狐GitLab 账户。
1. 配置以下属性，使你的 SAML 用户无法更改它们：

   - [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
   - 与 `omniauth_auto_link_saml_user` 一起使用时使用的 `Email`。

   如果用户可以更改这些属性，他们就能以其他授权用户的身份登录。
   请参见你的 SAML IdP 文档，了解如何使这些属性不可更改。
1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加提供者配置：

   ```yaml
   omniauth:
     providers:
       - {
         name: 'saml',
         label: '提供者名称', # 登录按钮的可选标签，默认为 "Saml"
         args: {
           assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
           idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
           idp_sso_target_url: 'https://login.example.com/idp',
           issuer: 'https://gitlab.example.com',
           name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
         }
       }
   ```

   | 参数                             | 描述 |
   | -------------------------------- | ----------- |
   | `assertion_consumer_service_url` | 极狐GitLab HTTPS 端点（将 `/users/auth/saml/callback` 附加到你的极狐GitLab 安装的 HTTPS URL 之后）。 |
   | `idp_cert_fingerprint`           | 你的 IdP 值。要从证书生成 SHA256 指纹，请参见[计算指纹](../user/group/saml_sso/troubleshooting.md#calculate-the-fingerprint)。 |
   | `idp_sso_target_url`             | 你的 IdP 值。 |
   | `issuer`                         | 更改为一个唯一名称，用于向 IdP 标识该应用程序。 |
   | `name_identifier_format`         | 你的 IdP 值。 |

   有关这些值的更多信息，请参见 [OmniAuth SAML 文档](https://github.com/omniauth/omniauth-saml)。有关其他配置设置的更多信息，请参见[在 IdP 上配置 SAML](#configure-saml-on-your-idp)。
1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="register-gitlab-in-your-saml-idp"></a>

### 在 SAML IdP 中注册极狐GitLab

1. 在你的 SAML IdP 中注册极狐GitLab SP，使用 `issuer` 中指定的应用程序名称。
1. 要向 IdP 提供配置信息，请为应用程序构建一个元数据 URL。要为极狐GitLab 构建元数据 URL，请将 `users/auth/saml/metadata` 附加到极狐GitLab 安装的 HTTPS URL 之后。例如：

   ```plaintext
   https://gitlab.example.com/users/auth/saml/metadata
   ```

   至少 IdP **必须** 提供一个声明，其中包含用户的电子邮件地址，使用 `email` 或 `mail`。有关其他可用声明的更多信息，请参见[配置断言](#configure-assertions)。
1. 在登录页面上，常规登录表单下方现在应该有一个 SAML 图标。选择该图标开始身份验证流程。如果身份验证成功，你将返回极狐GitLab 并登录。

<a id="configure-saml-on-your-idp"></a>

### 在 IdP 上配置 SAML

要在你的 IdP 上配置 SAML 应用程序，至少需要以下信息：

- 断言消费者服务 URL。
- 颁发者。
- [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
- [电子邮件地址声明](#configure-assertions)。

有关示例配置，请参见[设置标识提供商](#set-up-identity-providers)。

你的 IdP 可能需要其他配置。有关更多信息，请参见[针对 IdP 上 SAML 应用的附加配置](#additional-configuration-for-saml-apps-on-your-idp)。

<a id="configure-gitlab-to-use-multiple-saml-idps"></a>

### 将极狐GitLab 配置为使用多个 SAML IdP

你可以将极狐GitLab 配置为使用多个 SAML IdP，前提是：

- 每个提供者都有一个与 `args` 中名称集匹配的唯一名称集。
- 使用提供者的名称：
  - 在基于提供者名称的属性 OmniAuth 配置中。例如 `allowBypassTwoFactor`、`allowSingleSignOn` 和 `syncProfileFromProvider`。
  - 用于作为附加身份与每个现有用户关联。
- `assertion_consumer_service_url` 与提供者名称匹配。
- `strategy_class` 被显式设置，因为它无法从提供者名称推断出来。

> [!note]
> 配置多个 SAML IdP 时，为确保 SAML 群组链接正常工作，你必须将所有 SAML IdP 配置为在 SAML 响应中包含群组属性。有关更多信息，请参见 [SAML 群组链接](../user/group/saml_sso/group_sync.md)。

要设置多个 SAML IdP：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: 'saml', # 必须与以下名称配置参数匹配
       label: '提供者 1' # 在 UI 中区分两个按钮和提供者
       args: {
               name: 'saml', # 这是必需的，并且必须与提供者名称匹配
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback', # URL 必须与提供者名称匹配
               strategy_class: 'OmniAuth::Strategies::SAML',
               # 包含与单个提供者类似的所有必需参数
             },
     },
     {
       name: 'saml_2', # 必须与以下名称配置参数匹配
       label: '提供者 2' # 在 UI 中区分两个按钮和提供者
       args: {
               name: 'saml_2', # 这是必需的，并且必须与提供者名称匹配
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml_2/callback', # URL 必须与提供者名称匹配
               strategy_class: 'OmniAuth::Strategies::SAML',
               # 包含与单个提供者类似的所有必需参数
             },
     }
   ]
   ```

   要允许用户使用 SAML 从任一提供者注册而无需手动创建账户，请将以下值添加到配置中：

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml', 'saml_2']
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 将以下内容放入名为 `saml.yaml` 的文件中，用作第一个 SAML 提供者的 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml' # 至少有一个提供者必须命名为 'saml'
   label: '提供者 1' # 在 UI 中区分两个按钮和提供者
   args:
     name: 'saml' # 这是必需的，并且必须与提供者名称匹配
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback' # URL 必须与提供者名称匹配
     strategy_class: 'OmniAuth::Strategies::SAML' # 必需
     # 包含与单个提供者类似的所有必需参数
   ```

1. 将以下内容放入名为 `saml_2.yaml` 的文件中，用作第二个 SAML 提供者的 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml_2'
   label: '提供者 2' # 在 UI 中区分两个按钮和提供者
   args:
     name: 'saml_2' # 这是必需的，并且必须与提供者名称匹配
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml_2/callback' # URL 必须与提供者名称匹配
     strategy_class: 'OmniAuth::Strategies::SAML' # 必需
     # 包含与单个提供者类似的所有必需参数
   ```

1. 可选。按照相同的步骤设置其他 SAML 提供者。
1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml \
      --from-file=saml=saml.yaml \
      --from-file=saml_2=saml_2.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
             key: saml
           - secret: gitlab-saml
             key: saml_2
   ```

   要允许用户使用 SAML 从任一提供者注册而无需手动创建账户，请将以下值添加到配置中：

   ```yaml
   global:
     appConfig:
       omniauth:
         allowSingleSignOn: ['saml', 'saml_2']
   ```

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
           gitlab_rails['omniauth_allow_single_sign_on'] = ['saml', 'saml1']
           gitlab_rails['omniauth_providers'] = [
             {
               name: 'saml', # 必须与以下名称配置参数匹配
               label: '提供者 1' # 在 UI 中区分两个按钮和提供者
               args: {
                       name: 'saml', # 这是必需的，并且必须与提供者名称匹配
                       assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback', # URL 必须与提供者名称匹配
                       strategy_class: 'OmniAuth::Strategies::SAML',
                       # 包含与单个提供者类似的所有必需参数
                     },
             },
             {
               name: 'saml_2', # 必须与以下名称配置参数匹配
               label: '提供者 2' # 在 UI 中区分两个按钮和提供者
               args: {
                       name: 'saml_2', # 这是必需的，并且必须与提供者名称匹配
                       assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml_2/callback', # URL 必须与提供者名称匹配
                       strategy_class: 'OmniAuth::Strategies::SAML',
                       # 包含与单个提供者类似的所有必需参数
                     },
             }
           ]
   ```

   要允许用户使用 SAML 从任一提供者注册而无需手动创建账户，请将以下值添加到配置中：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_allow_single_sign_on'] = ['saml', 'saml_2']
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
       providers:
         - {
           name: 'saml', # 这必须与以下 name 配置参数匹配
           label: 'Provider 1' # 在 UI 中区分两个按钮和提供者
           args: {
             name: 'saml', # 这是必填项，必须与提供者名称匹配
             assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback', # URL 必须与提供者名称匹配
             strategy_class: 'OmniAuth::Strategies::SAML',
             # 包含所有必需参数，类似于单个提供者
           },
         }
         - {
           name: 'saml_2', # 这必须与以下 name 配置参数匹配
           label: 'Provider 2' # 在 UI 中区分两个按钮和提供者
           args: {
             name: 'saml_2', # 这是必填项，必须与提供者名称匹配
             strategy_class: 'OmniAuth::Strategies::SAML',
             assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml_2/callback', # URL 必须与提供者名称匹配
             # 包含所有必需参数，类似于单个提供者
           },
         }
   ```

   要允许您的用户使用 SAML 注册而无需从任一提供者手动创建账户，请将以下值添加到您的配置中：

   ```yaml
   production: &base
     omniauth:
       allow_single_sign_on: ["saml", "saml_2"]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="set-up-identity-providers"></a>

## 设置身份提供者

极狐GitLab 对 SAML 的支持意味着您可以通过各种 IdP 登录极狐GitLab。

极狐GitLab 提供以下有关设置 Okta 和 Google Workspace IdP 的内容，仅供参考。如果您对配置这些 IdP 有任何疑问，请联系您的提供者的支持。

<a id="set-up-okta"></a>

### 设置 Okta

1. 在 Okta 管理员部分，选择 **应用程序**。
1. 在应用程序屏幕上，选择 **创建应用集成**，然后在下一个屏幕上选择 **SAML 2.0**。
1. 可选。从[极狐GitLab 新闻资料](https://gitlab.cn/press/press-kit/)选择并添加一个 logo。您必须裁剪并调整 logo 大小。
1. 完成 SAML 常规配置。输入：
   - `"单点登录 URL"`：使用断言消费者服务 URL。
   - `"受众 URI"`：使用颁发者。
   - [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
   - [断言](#configure-assertions)。
1. 在反馈部分，输入您是客户，并且正在创建一个内部使用的应用程序。
1. 在新应用程序的配置文件顶部，选择 **SAML 2.0 配置说明**。
1. 记下 **身份提供者单点登录 URL**。在极狐GitLab 配置文件中，将此 URL 用于 `idp_sso_target_url`。
1. 在退出 Okta 之前，确保添加您的用户和群组（如果有）。

<a id="set-up-google-workspace"></a>

### 设置 Google Workspace

先决条件：

- 确保您有权访问 [Google Workspace 超级管理员帐户](https://support.google.com/a/answer/2405986#super_admin)。

要设置 Google Workspace：

1. 使用以下信息，并按照[在 Google Workspace 中设置您自己的自定义 SAML 应用程序](https://support.google.com/a/answer/6087519?hl=en)中的说明进行操作。

   |                  | 典型值                                             | 描述                                                                                           |
   |:-----------------|:---------------------------------------------------|:----------------------------------------------------------------------------------------------|
   | SAML 应用名称     | GitLab                                             | 其他名称也可以。                                                                               |
   | ACS URL          | `https://<GITLAB_DOMAIN>/users/auth/saml/callback` | 断言消费者服务 URL。                                                                           |
   | `GITLAB_DOMAIN`  | `gitlab.example.com`                               | 您的极狐GitLab 实例域名。                                                                      |
   | 实体 ID          | `https://gitlab.example.com`                       | 一个对于您的 SAML 应用程序唯一的值。将其设置为极狐GitLab 配置中的 `issuer`。                      |
   | 名称 ID 格式     | `EMAIL`                                            | 必需值。也称为 `name_identifier_format`。                                                      |
   | 名称 ID          | 主电子邮件地址                                     | 您的电子邮件地址。确保有人能收到发送到该地址的内容。                                            |
   | 名               | `first_name`                                       | 名。与极狐GitLab 通信的必需值。                                                                |
   | 姓               | `last_name`                                        | 姓。与极狐GitLab 通信的必需值。                                                                |

1. 设置以下 SAML 属性映射：

   | Google Directory 属性              | 应用属性 |
   |-----------------------------------|----------|
   | 基本信息 > 电子邮件                | `email`  |
   | 基本信息 > 名                      | `first_name` |
   | 基本信息 > 姓                      | `last_name` |

   在[配置极狐GitLab 中的 SAML 支持](#configure-saml-support-in-gitlab)时，您可能会用到其中一些信息。

配置 Google Workspace SAML 应用程序时，记录以下信息：

|                    | 值          | 描述 |
| ------------------ | ------------ | ----------- |
| SSO URL            | 视情况而定   | Google 身份提供者详细信息。设置为极狐GitLab 的 `idp_sso_target_url` 设置。 |
| 证书               | 可下载       | Google SAML 证书。 |
| SHA256 指纹        | 视情况而定   | 下载证书时可用。要从证书生成 SHA256 指纹，请参见[计算指纹](../user/group/saml_sso/troubleshooting.md#calculate-the-fingerprint)。 |

Google Workspace 管理员还提供 IdP 元数据、实体 ID 和 SHA-256 指纹。但是，极狐GitLab 不需要这些信息来连接到 Google Workspace SAML 应用程序。

<a id="set-up-microsoft-entra-id"></a>

### 设置 Microsoft Entra ID

1. 登录 [Microsoft Entra 管理中心](https://entra.microsoft.com/)。
1. [创建非库应用程序](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/overview-application-gallery#create-your-own-application)。
1. [为该应用程序配置 SSO](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/add-application-portal-setup-sso)。

   您的 `gitlab.rb` 文件中的以下设置对应于 Microsoft Entra ID 字段：

   | `gitlab.rb` 设置                   | Microsoft Entra ID 字段                         |
   | ------------------------------------| ---------------------------------------------- |
   | `issuer`                           | **标识符（实体 ID）**                           |
   | `assertion_consumer_service_url`   | **回复 URL（断言消费者服务 URL）**               |
   | `idp_sso_target_url`               | **登录 URL**                                    |
   | `idp_cert_fingerprint`             | **指纹**                                        |

1. 设置以下属性：
   - **唯一用户标识符（名称 ID）** 设置为 `user.objectID`。
     - **名称标识符格式** 设置为 `persistent`。有关更多信息，请参见如何[管理用户 SAML 身份](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
   - **其他声明** 设置为[支持的属性](#configure-assertions)。

有关更多信息，请参见[示例配置页面](../user/group/saml_sso/example_saml_config.md#azure-active-directory)。

<a id="set-up-other-idps"></a>

### 设置其他 IdP

一些 IdP 提供了有关如何在 SAML 配置中将其用作 IdP 的文档。例如：

- [Active Directory 联合身份验证服务 (ADFS)](https://learn.microsoft.com/en-us/previous-versions/windows-server/it-pro/windows-server-2012/identity/ad-fs/operations/Create-a-Relying-Party-Trust)
- [Auth0](https://auth0.com/docs/authenticate/single-sign-on/outbound-single-sign-on/configure-auth0-saml-identity-provider)

如果您对在 SAML 配置中配置 IdP 有任何疑问，请联系您的提供商的支持。

<a id="configure-assertions"></a>

### 配置断言

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- Microsoft Azure/Entra ID 属性支持在极狐GitLab 16.7 中引入。

{{< /history >}}

> [!note]
> 这些属性区分大小写。

| 字段           | 支持的默认键                                                                                                                                                         |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 电子邮件（必需）| `email`, `mail`, `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress`, `http://schemas.microsoft.com/ws/2008/06/identity/claims/emailaddress`, `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/email`, `http://schemas.microsoft.com/ws/2008/06/identity/claims/email`, `urn:oid:0.9.2342.19200300.100.1.3`                  |
| 全名           | `name`, `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name`, `http://schemas.microsoft.com/ws/2008/06/identity/claims/name`, `urn:oid:2.16.840.1.113730.3.1.241`, `urn:oid:2.5.4.3`                                           |
| 名             | `first_name`, `firstname`, `firstName`, `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname`, `http://schemas.microsoft.com/ws/2008/06/identity/claims/givenname`, `urn:oid:2.5.4.42` |
| 姓             | `last_name`, `lastname`, `lastName`, `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname`, `http://schemas.microsoft.com/ws/2008/06/identity/claims/surname`, `urn:oid:2.5.4.4`   |

当极狐GitLab 从 SAML SSO 提供者收到 SAML 响应时，极狐GitLab 会在属性 `name` 字段中查找以下值：

- `"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"`
- `"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"`
- `"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"`
- `firstname`
- `lastname`
- `email`

您必须在属性 `Name` 字段中正确包含这些值，以便极狐GitLab 能够解析 SAML 响应。例如，极狐GitLab 可以解析以下 SAML 响应片段：

- 这是可接受的，因为 `Name` 属性设置为上表中的必需值之一。

  ```xml
           <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname">
               <AttributeValue>Alvin</AttributeValue>
           </Attribute>
           <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname">
               <AttributeValue>Test</AttributeValue>
           </Attribute>
           <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress">
               <AttributeValue>alvintest@example.com</AttributeValue>
           </Attribute>
  ```

- 这是可接受的，因为 `Name` 属性与上表中的值之一匹配。

  ```xml
           <Attribute Name="firstname">
               <AttributeValue>Alvin</AttributeValue>
           </Attribute>
           <Attribute Name="lastname">
               <AttributeValue>Test</AttributeValue>
           </Attribute>
           <Attribute Name="email">
               <AttributeValue>alvintest@example.com</AttributeValue>
           </Attribute>
  ```

但是，极狐GitLab 无法解析以下 SAML 响应片段：

- 这将不被接受，因为 `Name` 属性中的值不是上表中支持的值之一。

  ```xml
           <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/firstname">
               <AttributeValue>Alvin</AttributeValue>
           </Attribute>
           <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/lastname">
               <AttributeValue>Test</AttributeValue>
           </Attribute>
           <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mail">
               <AttributeValue>alvintest@example.com</AttributeValue>
           </Attribute>
  ```

- 这将失败，因为即使 `FriendlyName` 具有支持的值，但 `Name` 属性没有。

  ```xml
           <Attribute FriendlyName="firstname" Name="urn:oid:2.5.4.42">
               <AttributeValue>Alvin</AttributeValue>
           </Attribute>
           <Attribute FriendlyName="lastname" Name="urn:oid:2.5.4.4">
               <AttributeValue>Test</AttributeValue>
           </Attribute>
           <Attribute FriendlyName="email" Name="urn:oid:0.9.2342.19200300.100.1.3">
               <AttributeValue>alvintest@example.com</AttributeValue>
           </Attribute>
  ```

有关以下内容，请参见[`attribute_statements`](#map-saml-response-attribute-names)：

- 自定义断言配置示例。
- 如何配置自定义用户名属性。

有关支持的断言的完整列表，请参见 [OmniAuth SAML gem](https://github.com/omniauth/omniauth-saml/blob/master/lib/omniauth/strategies/saml.rb)。

## 根据 SAML 群组成员资格配置用户

您可以：

- 要求用户是特定群组的成员。
- 根据群组成员资格为用户分配[外部](../administration/external_users.md)、管理员或[审计员](../administration/auditor_users.md)角色。

极狐GitLab 在每次 SAML 登录时检查这些群组，并根据需要更新用户属性。
此功能**不允许**您自动将用户添加到极狐GitLab
[群组](../user/group/_index.md)中。

对这些群组的支持取决于：

- 您的[订阅](https://gitlab.cn/pricing/)。
- 是否已安装[极狐GitLab企业版（EE）](https://gitlab.cn/install/)。

| 群组                          | 版本               | 仅限极狐GitLab企业版（EE）？ |
|------------------------------|--------------------|--------------------------------------|
| [必需](#required-groups)       | 基础版，专业版，旗舰版 | 是                                  |
| [外部](#external-groups)       | 基础版，专业版，旗舰版 | 否                                   |
| [管理员](#administrator-groups) | 基础版，专业版，旗舰版 | 是                                  |
| [审计员](#auditor-groups)      | 专业版，旗舰版       | 是                                  |

先决条件：

- 您必须告诉极狐GitLab 在哪里查找群组信息。为此，请确保您的 IdP 服务器在常规 SAML 响应中发送一个特定的 `AttributeStatement`。例如：

  ```xml
  <saml:AttributeStatement>
    <saml:Attribute Name="Groups">
      <saml:AttributeValue xsi:type="xs:string">Developers</saml:AttributeValue>
      <saml:AttributeValue xsi:type="xs:string">Freelancers</saml:AttributeValue>
      <saml:AttributeValue xsi:type="xs:string">Admins</saml:AttributeValue>
      <saml:AttributeValue xsi:type="xs:string">Auditors</saml:AttributeValue>
    </saml:Attribute>
  </saml:AttributeStatement>
  ```

  该属性的名称必须包含用户所属的群组。
  要告诉极狐GitLab 在哪里找到这些群组，请在您的 SAML 设置中添加一个 `groups_attribute:` 元素。此属性区分大小写。

<a id="required-groups"></a>

### 必需群组

您的 IdP 在 SAML 响应中将群组信息传递给极狐GitLab。要使用此响应，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 SAML 响应中查找群组的位置。
- 使用群组设置获取有关群组或用户的信息。

使用 `required_groups` 设置配置极狐GitLab，以识别登录需要哪个群组成员资格。

如果您未设置 `required_groups` 或将该设置留空，则任何具有适当身份验证的人都可以使用该服务。

如果 `groups_attribute` 中指定的属性不正确或缺失，则所有用户都将被阻止。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       groups_attribute: 'Groups',
       required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 将以下内容放入名为 `saml.yaml` 的文件中，用作 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   groups_attribute: 'Groups'
   required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: 'Our SAML Provider',
                groups_attribute: 'Groups',
                required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                }
              }
           ]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             groups_attribute: 'Groups',
             required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="external-groups"></a>

### 外部群组

您的 IdP 在 SAML 响应中将群组信息传递给极狐GitLab。要使用此响应，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 SAML 响应中查找群组的位置。
- 使用群组设置获取有关群组或用户的信息。

SAML 可以根据 `external_groups` 设置自动将用户识别为[外部用户](../administration/external_users.md)。

> [!note]
> 如果 `groups_attribute` 中指定的属性不正确或缺失，则用户将以标准用户身份访问。

示例配置：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [

     { name: 'saml',
       label: 'Our SAML Provider',
       groups_attribute: 'Groups',
       external_groups: ['Freelancers'],
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               # 或者
               # idp_cert: '-----BEGIN CERTIFICATE-----\n ... \n-----END CERTIFICATE-----',

               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 将以下内容放入名为 `saml.yaml` 的文件中，用作 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   groups_attribute: 'Groups'
   external_groups: ['Freelancers']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     # 或者
     # idp_cert: '-----BEGIN CERTIFICATE-----\n ... \n-----END CERTIFICATE-----',
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
             { name: 'saml',
               label: 'Our SAML Provider',
               groups_attribute: 'Groups',
               external_groups: ['Freelancers'],
               args: {
                       assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                       idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                       idp_sso_target_url: 'https://login.example.com/idp',
                       issuer: 'https://gitlab.example.com',
                       name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
               }
             }
           ]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：
    ```yaml
   production: &base
     omniauth:
       providers:
          - { name: 'saml',
              label: 'Our SAML Provider',
              groups_attribute: 'Groups',
              external_groups: ['Freelancers'],
              args: {
                      assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                      idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                      idp_sso_target_url: 'https://login.example.com/idp',
                      issuer: 'https://gitlab.example.com',
                      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
              }
            }
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="administrator-groups"></a>

### 管理员群组

您的 IdP 通过 SAML 响应将群组信息传递给极狐GitLab。要使用此响应，请配置极狐GitLab 来识别：

- 使用 `groups_attribute` 设置，在 SAML 响应中查找群组的位置。
- 使用群组设置，获取群组或用户信息。

使用 `admin_groups` 设置来配置极狐GitLab，以识别哪些群组会授予用户管理员权限。

如果 `groups_attribute` 中指定的属性不正确或缺失，用户将失去其管理员权限。

配置示例：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1.   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       groups_attribute: 'Groups',
       admin_groups: ['Admins'],
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               # 或者
               # idp_cert: '-----BEGIN CERTIFICATE-----\n ... \n-----END CERTIFICATE-----',

               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
       }
     }
   ]
   ```

1.   保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1.   将以下内容放入一个名为 `saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   groups_attribute: 'Groups'
   admin_groups: ['Admins']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

1.   创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1.   导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1.   编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

1.   保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1.   编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: 'Our SAML Provider',
                groups_attribute: 'Groups',
                admin_groups: ['Admins'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                }
              }
           ]
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

1.   编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             groups_attribute: 'Groups',
             admin_groups: ['Admins'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
             }
           }
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="auditor-groups"></a>

### 审计员群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您的 IdP 通过 SAML 响应将群组信息传递给极狐GitLab。要使用此响应，请配置极狐GitLab 来识别：

- 使用 `groups_attribute` 设置，在 SAML 响应中查找群组的位置。
- 使用群组设置，获取群组或用户信息。

使用 `auditor_groups` 设置来配置极狐GitLab，以识别哪些群组包含具有[审计员权限](../administration/auditor_users.md)的用户。

如果 `groups_attribute` 中指定的属性不正确或缺失，用户将失去其审计员权限。

配置示例：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1.   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       groups_attribute: 'Groups',
       auditor_groups: ['Auditors'],
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
       }
     }
   ]
   ```

1.   保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1.   将以下内容放入一个名为 `saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   groups_attribute: 'Groups'
   auditor_groups: ['Auditors']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

1.   创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1.   导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1.   编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

1.   保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1.   编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: 'Our SAML Provider',
                groups_attribute: 'Groups',
                auditor_groups: ['Auditors'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                }
              }
           ]
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

1.   编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             groups_attribute: 'Groups',
             auditor_groups: ['Auditors'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
             }
           }
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="automatically-manage-saml-group-sync"></a>

## 自动管理 SAML 群组同步

有关自动管理极狐GitLab 群组成员资格的信息，请参阅 [SAML 群组同步](../user/group/saml_sso/group_sync.md)。

<a id="customize-saml-session-timeout"></a>

### 自定义 SAML 会话超时时间

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/262074)，[带有一个功能标志](../administration/feature_flags/_index.md)，名为 `saml_timeout_supplied_by_idp_override`。
- 在极狐GitLab 18.3 中[启用](https://gitlab.com/gitlab-org/gitlab/-/work_items/553931)。

{{< /history >}}

默认情况下，极狐GitLab 在 24 小时后结束 SAML 会话。您可以使用 SAML2 AuthnStatement 中的 `SessionNotOnOrAfter` 属性自定义此持续时间。该属性包含一个 ISO 8601 时间戳值，指示何时结束用户会话。当指定此值时，它会覆盖默认的 24 小时 SAML 会话超时时间。

如果实例配置了自定义的[会话持续时间](../administration/settings/account_and_limit_settings.md#session-duration)，且该时间早于 `SessionNotOnOrAfter` 时间戳，那么用户在其极狐GitLab 用户会话结束时必须重新认证。

<a id="bypass-two-factor-authentication"></a>

## 绕过双重认证

{{< history >}}

- 绕过双重认证强制[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/122109)于极狐GitLab 16.1，[带有一个功能标志](../administration/feature_flags/_index.md)，名为 `by_pass_two_factor_current_session`。
- 在极狐GitLab 17.8 中[启用](https://gitlab.com/gitlab-org/gitlab/-/issues/416535)。

{{< /history >}}

如需将 SAML 认证方法配置为在每次会话基础上计作双重认证 (2FA)，请将该方法注册到 `upstream_two_factor_authn_contexts` 列表中。

1.   确保您的 IdP 返回了 `AuthnContext`。例如：

   ```xml
   <saml:AuthnStatement>
       <saml:AuthnContext>
           <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:MediumStrongCertificateProtectedTransport</saml:AuthnContextClassRef>
       </saml:AuthnContext>
   </saml:AuthnStatement>
   ```

1.   编辑您的安装配置，将 SAML 认证方法注册到 `upstream_two_factor_authn_contexts` 列表中。您必须输入来自 SAML 响应的 `AuthnContext`。

   {{< tabs >}}

   {{< tab title="Linux 软件包 (Omnibus)" >}}

   1.   编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      gitlab_rails['omniauth_providers'] = [
        { name: 'saml',
          label: 'Our SAML Provider',
          args: {
                  assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                  idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                  idp_sso_target_url: 'https://login.example.com/idp',
                  issuer: 'https://gitlab.example.com',
                  name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                  upstream_two_factor_authn_contexts:
                    %w(
                      urn:oasis:names:tc:SAML:2.0:ac:classes:CertificateProtectedTransport
                      urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorOTPSMS
                      urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorIGTOKEN
                    ),
          }
        }
      ]
      ```

   1.   保存文件并重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   {{< /tab >}}

   {{< tab title="Helm chart (Kubernetes)" >}}

   1.   将以下内容放入一个名为 `saml.yaml` 的文件中，用作
      [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

      ```yaml
      name: 'saml'
      label: 'Our SAML Provider'
      args:
        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
        idp_sso_target_url: 'https://login.example.com/idp'
        issuer: 'https://gitlab.example.com'
        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
        upstream_two_factor_authn_contexts:
          - 'urn:oasis:names:tc:SAML:2.0:ac:classes:CertificateProtectedTransport'
          - 'urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorOTPSMS'
          - 'urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorIGTOKEN'
      ```

   1.   创建 Kubernetes Secret：

      ```shell
      kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
      ```

   1.   导出 Helm 值：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1.   编辑 `gitlab_values.yaml`：

      ```yaml
      global:
        appConfig:
          omniauth:
            providers:
              - secret: gitlab-saml
      ```

   1.   保存文件并应用新值：

      ```shell
      helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
      ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   1.   编辑 `docker-compose.yml`：

      ```yaml
      version: "3.6"
      services:
        gitlab:
          environment:
            GITLAB_OMNIBUS_CONFIG: |
              gitlab_rails['omniauth_providers'] = [
                 { name: 'saml',
                   label: 'Our SAML Provider',
                   args: {
                           assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                           idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                           idp_sso_target_url: 'https://login.example.com/idp',
                           issuer: 'https://gitlab.example.com',
                           name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                           upstream_two_factor_authn_contexts:
                             %w(
                               urn:oasis:names:tc:SAML:2.0:ac:classes:CertificateProtectedTransport
                               urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorOTPSMS
                               urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorIGTOKEN
                             )
                   }
                 }
              ]
      ```

   1.   保存文件并重启极狐GitLab：

      ```shell
      docker compose up -d
      ```

   {{< /tab >}}

   {{< tab title="自行编译 (源码)" >}}

   1.   编辑 `/home/git/gitlab/config/gitlab.yml`：

      ```yaml
      production: &base
        omniauth:
          providers:
            - { name: 'saml',
                label: 'Our SAML Provider',
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                        upstream_two_factor_authn_contexts:
                          [
                            'urn:oasis:names:tc:SAML:2.0:ac:classes:CertificateProtectedTransport',
                            'urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorOTPSMS',
                            'urn:oasis:names:tc:SAML:2.0:ac:classes:SecondFactorIGTOKEN'
                          ]
                }
              }
      ```

   1.   保存文件并重启极狐GitLab：

      ```shell
      # 对于使用 systemd 的系统
      sudo systemctl restart gitlab.target

      # 对于使用 SysV init 的系统
      sudo service gitlab restart
      ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="validate-response-signatures"></a>

## 验证响应签名

IdP 必须对 SAML 响应进行签名，以确保断言未被篡改。

当需要特定的群组成员资格时，这可以防止用户冒充和权限提升。

<a id="using-idp_cert_fingerprint"></a>

### 使用 `idp_cert_fingerprint`

您可以使用 `idp_cert_fingerprint` 配置响应签名验证。配置示例：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1.   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
       }
     }
   ]
   ```

1.   保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1.   将以下内容放入一个名为 `saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

1.   创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1.   导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1.   编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

1.   保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1.   编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: 'Our SAML Provider',
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                }
              }
           ]
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

1.   编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
             }
           }
   ```

1.   保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="using-idp_cert"></a>

### 使用 `idp_cert`

您也可以直接使用 `idp_cert` 配置极狐GitLab。配置示例：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1.   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert: '-----BEGIN CERTIFICATE-----
                 <redacted>
                 -----END CERTIFICATE-----',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
       }
     }
   ]
   ```

1.   保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1.   将以下内容放入一个名为 `saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert: |
       -----BEGIN CERTIFICATE-----
       <redacted>
       -----END CERTIFICATE-----
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
   ```

1.   创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1.   导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1.   编辑 `gitlab_values.yaml`：

   ```yaml
```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: '我们的 SAML 提供程序',
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert: '-----BEGIN CERTIFICATE-----
                          <redacted>
                          -----END CERTIFICATE-----',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                }
              }
           ]
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
       providers:
         - { name: 'saml',
             label: '我们的 SAML 提供程序',
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert: '-----BEGIN CERTIFICATE-----
                       <redacted>
                       -----END CERTIFICATE-----',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

如果你错误配置了响应签名验证，可能会看到如下错误信息：

- 密钥验证错误。
- 摘要不匹配。
- 指纹不匹配。

关于解决这些错误的更多信息，请参见 [SAML 故障排查指南](../user/group/saml_sso/troubleshooting.md)。

## 自定义 SAML 设置

### 将用户重定向到 SAML 服务器进行身份验证

你可以在极狐GitLab 配置中添加 `auto_sign_in_with_provider` 设置，以便自动重定向到你的 SAML 服务器进行身份验证。这消除了在实际登录前需要选择某个元素的步骤。

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'saml'
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         autoSignInWithProvider: 'saml'
   ```

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
           gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'saml'
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
       auto_sign_in_with_provider: 'saml'
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

每次登录尝试都会重定向到 SAML 服务器，因此你无法使用本地凭据登录。确保至少有一个 SAML 用户拥有管理员访问权限。

> [!note]
> 要绕过自动登录设置，请在登录 URL 后添加 `?auto_sign_in=false`，例如：`https://gitlab.example.com/users/sign_in?auto_sign_in=false`。

### 映射 SAML 响应属性名称

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以使用 `attribute_statements` 将 SAML 响应中的属性名称映射到 OmniAuth [`info` hash](https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema#schema-10-and-later) 中的条目。

> [!note]
> 仅使用此设置来映射属于 OmniAuth `info` hash 架构的属性。

例如，如果你的 `SAMLResponse` 包含一个名为 `EmailAddress` 的属性，请指定 `{ email: ['EmailAddress'] }` 将该属性映射到 `info` hash 中相应的键。也支持以 URI 命名的属性，例如 `{ email: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] }`。

使用此设置告诉极狐GitLab 在哪里查找创建账户所需的某些属性。例如，如果你的 IdP 将用户电子邮件地址作为 `EmailAddress` 而不是 `email` 发送，请在配置中进行设置以使极狐GitLab 知晓：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: '我们的 SAML 提供程序',
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
               attribute_statements: { email: ['EmailAddress'] }
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 将以下内容放入名为 `saml.yaml` 的文件中，用作 [Kubernetes 密钥](https://docs.gitlab.com/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: '我们的 SAML 提供程序'
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
     attribute_statements:
       email: ['EmailAddress']
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: '我们的 SAML 提供程序',
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        attribute_statements: { email: ['EmailAddress'] }
                }
              }
           ]
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
       providers:
         - { name: 'saml',
             label: '我们的 SAML 提供程序',
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                     attribute_statements: { email: ['EmailAddress'] }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

#### 设置用户名

默认情况下，SAML 响应中电子邮件地址的本地部分用于生成用户的极狐GitLab 用户名。

在 `attribute_statements` 中配置 [`username` 或 `nickname`](omniauth.md#per-provider-configuration) 来指定一个或多个包含用户期望用户名的属性：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: '我们的 SAML 提供程序',
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
               attribute_statements: { nickname: ['username'] }
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 将以下内容放入名为 `saml.yaml` 的文件中，用作 [Kubernetes 密钥](https://docs.gitlab.com/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: '我们的 SAML 提供程序'
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
     attribute_statements:
       nickname: ['username']
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: '我们的 SAML 提供程序',
                groups_attribute: 'Groups',
                required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        attribute_statements: { nickname: ['username'] }
                }
              }
           ]
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
       providers:
         - { name: 'saml',
             label: '我们的 SAML 提供程序',
             groups_attribute: 'Groups',
             required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                     attribute_statements: { nickname: ['username'] }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

这也会将你的 SAML 响应中的 `username` 属性设置为极狐GitLab 中的用户名。

#### 映射个人资料属性

{{< history >}}

- 在极狐GitLab 17.8 中引入了 `job_title` 和 `organization` 属性。

{{< /history >}}

要从 SAML 提供程序同步个人资料信息，你必须配置 `attribute_statements` 来映射这些属性。

支持的个人资料属性有：

- `job_title`
- `organization`

这些属性没有默认映射，除非明确配置，否则不会同步。

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

1. [配置 OmniAuth 以同步所需的属性](omniauth.md#keep-omniauth-user-profiles-up-to-date)。
1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: '我们的 SAML 提供程序',
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
               attribute_statements: {
                 organization: ['organization'],
                 job_title: ['job_title']
               }
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. [配置 OmniAuth 以同步所需的属性](omniauth.md#keep-omniauth-user-profiles-up-to-date)。
1. 将以下 YAML 内容保存在名为 `saml.yaml` 的文件中，用作 [Kubernetes 密钥](https://docs.gitlab.com/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: '我们的 SAML 提供程序'
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
     attribute_statements:
       organization: ['organization']
       job_title: ['job_title']
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. [配置 OmniAuth 以同步所需的属性](omniauth.md#keep-omniauth-user-profiles-up-to-date)。
1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: '我们的 SAML 提供程序',
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        attribute_statements: {
                          organization: ['organization'],
                          job_title: ['job_title']
                        }
                }
              }
           ]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. [配置 OmniAuth 以同步所需的属性](omniauth.md#keep-omniauth-user-profiles-up-to-date)。
1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: '我们的 SAML 提供程序',
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                     attribute_statements: {
                       organization: ['organization'],
                       job_title: ['job_title']
                     }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

### 允许时钟偏差

IdP 的时钟可能会比你的系统时钟稍快一些。
为了允许少量的时钟偏差，请在设置中使用 `allowed_clock_drift`。
你必须以秒为单位输入该参数的值，包括小数部分。
给定的值会加到验证响应的当前时间上。

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: '我们的 SAML 提供程序',
       groups_attribute: 'Groups',
       required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
               allowed_clock_drift: 1  # 1 秒时钟偏差
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 将以下内容放入名为 `saml.yaml` 的文件中，用作 [Kubernetes 密钥](https://docs.gitlab.com/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: '我们的 SAML 提供程序'
   groups_attribute: 'Groups'
   required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
     allowed_clock_drift: 1  # 1 秒时钟偏差
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: '我们的 SAML 提供程序',
                groups_attribute: 'Groups',
                required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        allowed_clock_drift: 1  # 1 秒时钟偏差
                }
              }
           ]
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
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             groups_attribute: 'Groups',
             required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                     allowed_clock_drift: 1  # 允许 1 秒钟的时钟偏差
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="designate-a-unique-attribute-for-the-uid-optional"></a>

### 为 `uid` 指定唯一属性（可选）

默认情况下，用户 `uid` 被设置为 SAML 响应中的 `NameID` 属性。要指定
一个不同的属性作为 `uid`，你可以设置 `uid_attribute`。

在将 `uid` 设置为唯一属性之前，请确保你已配置
以下属性，以使你的 SAML 用户无法更改它们：

- [`NameID`](../user/group/saml_sso/_index.md#manage-user-saml-identity)。
- 当与 `omniauth_auto_link_saml_user` 一起使用时，`Email`。

如果用户可以更改这些属性，他们就可以以其他授权用户的身份登录。
有关如何使这些属性不可更改的信息，请参阅你的 SAML IdP 文档。
在以下示例中，SAML 响应中 `uid` 属性的值被设置为 `uid_attribute`。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
               uid_attribute: 'uid'
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 将以下内容放入一个名为 `saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   groups_attribute: 'Groups'
   required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
     uid_attribute: 'uid'
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: 'Our SAML Provider',
                groups_attribute: 'Groups',
                required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        uid_attribute: 'uid'
                }
              }
           ]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             groups_attribute: 'Groups',
             required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                     uid_attribute: 'uid'
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="assertion-encryption-optional"></a>

## 断言加密（可选）

对 SAML 断言进行加密是可选的，但建议执行。这增加了一层额外的保护，
以防止未加密的数据被恶意行为者记录或拦截。

> [!note]
> 此集成对断言加密和请求签名使用相同的 `certificate` 和 `private_key` 设置。

要加密你的 SAML 断言，请在极狐GitLab SAML 设置中定义私钥和公钥证书。
你的 IdP 使用公钥证书加密断言，极狐GitLab 使用私钥解密断言。

定义密钥和证书时，将密钥文件中的所有换行符替换为 `\n`。
这会使密钥文件成为一个没有换行符的长字符串。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: 'saml',
       label: 'Our SAML Provider',
       groups_attribute: 'Groups',
       required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
       args: {
               assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
               idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
               idp_sso_target_url: 'https://login.example.com/idp',
               issuer: 'https://gitlab.example.com',
               name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
               certificate:|
               -----BEGIN CERTIFICATE-----
               <redacted>
               -----END CERTIFICATE-----,
               private_key:|
               -----BEGIN PRIVATE KEY-----
               <redacted>
               -----END PRIVATE KEY-----
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 将以下内容放入一个名为 `saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'saml'
   label: 'Our SAML Provider'
   groups_attribute: 'Groups'
   required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors']
   args:
     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
     idp_sso_target_url: 'https://login.example.com/idp'
     issuer: 'https://gitlab.example.com'
     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
     certificate:|
     -----BEGIN CERTIFICATE-----
     <redacted>
     ----END CERTIFICATE-----,
     private_key:|
     -----BEGIN PRIVATE KEY-----
     <redacted>
     -----END PRIVATE KEY-----
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       omniauth:
         providers:
           - secret: gitlab-saml
   ```

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
           gitlab_rails['omniauth_providers'] = [
              { name: 'saml',
                label: 'Our SAML Provider',
                groups_attribute: 'Groups',
                required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        certificate:|
                        -----BEGIN CERTIFICATE-----
                        <redacted>
                        -----END CERTIFICATE-----,
                        private_key:|
                        -----BEGIN PRIVATE KEY-----
                        <redacted>
                        -----END PRIVATE KEY-----
                }
              }
           ]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'saml',
             label: 'Our SAML Provider',
             groups_attribute: 'Groups',
             required_groups: ['Developers', 'Freelancers', 'Admins', 'Auditors'],
             args: {
                     assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                     idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                     idp_sso_target_url: 'https://login.example.com/idp',
                     issuer: 'https://gitlab.example.com',
                     name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                     certificate: '-----BEGIN CERTIFICATE-----\n<redacted>\n-----END CERTIFICATE-----',
                     private_key: '-----BEGIN PRIVATE KEY-----\n<redacted>\n-----END PRIVATE KEY-----'
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="sign-saml-authentication-requests-optional"></a>

## 签名 SAML 认证请求（可选）

你可以配置极狐GitLab 对 SAML 认证请求进行签名。此配置
是可选的，因为极狐GitLab SAML 请求使用 SAML 重定向绑定。

要实施签名：

1. 为你的极狐GitLab 实例创建一个用于 SAML 的私钥和公钥证书对。
1. 在配置的 `security` 部分配置签名设置。
   例如：

   {{< tabs >}}

   {{< tab title="Linux package (Omnibus)" >}}

   1. 编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      gitlab_rails['omniauth_providers'] = [
        { name: 'saml',
          label: 'Our SAML Provider',
          args: {
                  assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                  idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                  idp_sso_target_url: 'https://login.example.com/idp',
                  issuer: 'https://gitlab.example.com',
                  name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                  certificate: '-----BEGIN CERTIFICATE-----\n<redacted>\n-----END CERTIFICATE-----',
                  private_key: '-----BEGIN PRIVATE KEY-----\n<redacted>\n-----END PRIVATE KEY-----',
                  security: {
                    authn_requests_signed: true,  # 启用 AuthNRequest 签名
                    want_assertions_signed: true,  # 启用对签名断言的要求
                    want_assertions_encrypted: false,  # 启用对加密断言的要求
                    metadata_signed: false,  # 启用元数据签名
                    signature_method: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
                    digest_method: 'http://www.w3.org/2001/04/xmlenc#sha256',
                  }
          }
        }
      ]
      ```

   1. 保存文件并重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   {{< /tab >}}

   {{< tab title="Helm chart (Kubernetes)" >}}

   1. 将以下内容放入一个名为 `saml.yaml` 的文件中，用作
      [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

      ```yaml
      name: 'saml'
      label: 'Our SAML Provider'
      args:
        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6'
        idp_sso_target_url: 'https://login.example.com/idp'
        issuer: 'https://gitlab.example.com'
        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
        certificate: '-----BEGIN CERTIFICATE-----\n<redacted>\n-----END CERTIFICATE-----'
        private_key: '-----BEGIN PRIVATE KEY-----\n<redacted>\n-----END PRIVATE KEY-----'
        security:
          authn_requests_signed: true  # 启用 AuthNRequest 签名
          want_assertions_signed: true  # 启用对签名断言的要求
          want_assertions_encrypted: false  # 启用对加密断言的要求
          metadata_signed: false  # 启用元数据签名
          signature_method: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'
          digest_method: 'http://www.w3.org/2001/04/xmlenc#sha256'
      ```

   1. 创建 Kubernetes Secret：

      ```shell
      kubectl create secret generic -n <namespace> gitlab-saml --from-file=provider=saml.yaml
      ```

   1. 导出 Helm 值：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1. 编辑 `gitlab_values.yaml`：

      ```yaml
      global:
        appConfig:
          omniauth:
            providers:
              - secret: gitlab-saml
      ```

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
              gitlab_rails['omniauth_providers'] = [
                 { name: 'saml',
                   label: 'Our SAML Provider',
                   args: {
                           assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                           idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                           idp_sso_target_url: 'https://login.example.com/idp',
                           issuer: 'https://gitlab.example.com',
                           name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                           certificate: '-----BEGIN CERTIFICATE-----\n<redacted>\n-----END CERTIFICATE-----',
                           private_key: '-----BEGIN PRIVATE KEY-----\n<redacted>\n-----END PRIVATE KEY-----',
                           security: {
                             authn_requests_signed: true,  # 启用 AuthNRequest 签名
                             want_assertions_signed: true,  # 启用对签名断言的要求
                             want_assertions_encrypted: false,  # 启用对加密断言的要求
                             metadata_signed: false,  # 启用元数据签名
                             signature_method: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
                             digest_method: 'http://www.w3.org/2001/04/xmlenc#sha256',
                           }
                   }
                 }
              ]
      ```

   1. 保存文件并重启极狐GitLab：

      ```shell
      docker compose up -d
      ```

   {{< /tab >}}

   {{< tab title="Self-compiled (source)" >}}

   1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

      ```yaml
      production: &base
        omniauth:
          providers:
            - { name: 'saml',
                label: 'Our SAML Provider',
                args: {
                        assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
                        idp_cert_fingerprint: '2f:cb:19:57:68:c3:9e:9a:94:ce:c2:c2:e3:2c:59:c0:aa:d7:a3:36:5c:10:89:2e:81:16:b5:d8:3d:40:96:b6',
                        idp_sso_target_url: 'https://login.example.com/idp',
                        issuer: 'https://gitlab.example.com',
                        name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
                        certificate: '-----BEGIN CERTIFICATE-----\n<redacted>\n-----END CERTIFICATE-----',
                        private_key: '-----BEGIN PRIVATE KEY-----\n<redacted>\n-----END PRIVATE KEY-----',
                        security: {
                          authn_requests_signed: true,  # 启用 AuthNRequest 签名
                          want_assertions_signed: true,  # 启用对签名断言的要求
                          want_assertions_encrypted: false,  # 启用对加密断言的要求
                          metadata_signed: false,  # 启用元数据签名
                          signature_method: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
                          digest_method: 'http://www.w3.org/2001/04/xmlenc#sha256',
                        }
                }
              }
      ```

   1. 保存文件并重启极狐GitLab：

      ```shell
      # 对于使用 systemd 的系统
      sudo systemctl restart gitlab.target

      # 对于使用 SysV init 的系统
      sudo service gitlab restart
      ```

   {{< /tab >}}

   {{< /tabs >}}

然后极狐GitLab 会：

- 使用提供的私钥对请求进行签名。
- 在元数据中包含已配置的公钥 x500 证书，以便你的 IdP 验证收到的请求的签名。

有关此选项的更多信息，请参见
[Ruby SAML gem 文档](https://github.com/SAML-Toolkits/ruby-saml/tree/v1.7.0)。

Ruby SAML gem 被
[OmniAuth SAML gem](https://github.com/omniauth/omniauth-saml) 用来实现
SAML 认证的客户端。

> [!note]
> SAML 重定向绑定不同于 SAML POST 绑定。在 POST 绑定中，
> 需要签名以防止中间人篡改请求。

<a id="password-generation-for-users-created-through-saml"></a>

## 为通过 SAML 创建的用户生成密码

极狐GitLab [为通过 SAML 创建的用户生成并设置密码](../user/profile/user_passwords.md)。

通过 SSO 或 SAML 认证的用户不得使用密码通过 HTTPS 进行 Git 操作。
这些用户可以改为：

- 设置一个[个人](../user/profile/personal_access_tokens.md)、[项目](../user/project/settings/project_access_tokens.md)或[群组](../user/group/settings/group_access_tokens.md)访问令牌。
- 使用 [OAuth 凭证助手](../user/profile/account/two_factor_authentication.md#oauth-credential-helpers)。

<a id="link-saml-identity-for-an-existing-user"></a>

## 为现有用户链接 SAML 身份

管理员可以配置极狐GitLab 以自动将 SAML 用户与现有的极狐GitLab 用户链接。
有关更多信息，请参见[在极狐GitLab 中配置 SAML 支持](#configure-saml-support-in-gitlab)。

用户可以手动将其 SAML 身份链接到现有的极狐GitLab 帐户。有关更多信息，
请参见[为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user)。

<a id="configure-group-saml-sso-on-gitlab-self-managed"></a>

## 在私有化部署的极狐GitLab 上配置群组 SAML SSO

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你必须在私有化部署的极狐GitLab 实例上允许通过多个 SAML IdP 进行访问，请使用群组 SAML SSO。

要配置群组 SAML SSO：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 确保极狐GitLab 已[配置 HTTPS](https://gitlab.cn/docs/omnibus/settings/ssl/)。
1. 编辑 `/etc/gitlab/gitlab.rb` 以启用 OmniAuth 和 `group_saml` 提供程序：

   ```ruby
   gitlab_rails['omniauth_enabled'] = true
   gitlab_rails['omniauth_providers'] = [{ name: 'group_saml' }]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 确保极狐GitLab 已[配置 HTTPS](https://gitlab.cn/docs/charts/installation/tls/)。
1. 将以下内容放入一个名为 `group_saml.yaml` 的文件中，用作
   [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

   ```yaml
   name: 'group_saml'
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-group-saml --from-file=provider=group_saml.yaml
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml` 以启用 OmniAuth 和 `group_saml` 提供程序：

   ```yaml
   global:
     appConfig:
       omniauth:
         enabled: true
         providers:
           - secret: gitlab-group-saml
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 确保极狐GitLab 已[配置 HTTPS](https://gitlab.cn/docs/omnibus/settings/ssl/)。
1. 编辑 `docker-compose.yml` 以启用 OmniAuth 和 `group_saml` 提供程序：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['omniauth_enabled'] = true
           gitlab_rails['omniauth_providers'] = [{ name: 'group_saml' }]
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 确保极狐GitLab 已[配置 HTTPS](../install/self_compiled/_index.md#using-https)。
1. 编辑 `/home/git/gitlab/config/gitlab.yml` 以启用 OmniAuth 和 `group_saml` 提供程序：

   ```yaml
   production: &base
     omniauth:
       enabled: true
       providers:
         - { name: 'group_saml' }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}
作为多租户解决方案，极狐GitLab 私有化部署上的群组 SAML 相较于推荐的[实例级 SAML](saml.md) 有所限制。使用实例级 SAML 可以利用以下优势：

- [LDAP 兼容性](../administration/auth/ldap/_index.md)
- [LDAP 群组同步](../user/group/access_and_permissions.md#manage-group-memberships-with-ldap)
- [必需群组](#required-groups)
- [管理员群组](#administrator-groups)
- [审计员群组](#auditor-groups)

<a id="additional-configuration-for-saml-apps-on-your-idp"></a>

## 针对 IdP 上 SAML 应用的额外配置

在 IdP 上配置 SAML 应用时，您的 IdP 可能需要额外的配置，例如以下内容：

| 字段 | 值 | 备注 |
|-------|-------|-------|
| SAML 配置文件 | Web 浏览器 SSO 配置文件 | 极狐GitLab 使用 SAML 通过用户的浏览器登录。不会直接向 IdP 发送请求。 |
| SAML 请求绑定 | HTTP 重定向 | 极狐GitLab（SP） 通过 base64 编码的 `SAMLRequest` HTTP 参数将用户重定向到您的 IdP。 |
| SAML 响应绑定 | HTTP POST | 指定 IdP 如何发送 SAML 令牌。包含 `SAMLResponse`，用户的浏览器会将其提交回极狐GitLab。 |
| 签名 SAML 响应 | 必需 | 防止篡改。 |
| 响应中的 X.509 证书 | 必需 | 对响应进行签名，并根据提供的指纹检查响应。 |
| 指纹算法 | SHA-1 | 极狐GitLab 使用证书的 SHA-1 哈希来签名 SAML 响应。 |
| 签名算法 | SHA-1/SHA-256/SHA-384/SHA-512 | 决定响应的签名方式。也称为摘要方法，这可以在 SAML 响应中指定。 |
| 加密 SAML 断言 | 可选 | 在您的身份提供者、用户浏览器和极狐GitLab 之间使用 TLS。 |
| 签名 SAML 断言 | 可选 | 验证 SAML 断言的完整性。启用时，对整个响应进行签名。 |
| 检查 SAML 请求签名 | 可选 | 检查 SAML 响应上的签名。 |
| 默认 RelayState | 可选 | 指定用户在 IdP 通过 SAML 成功登录后应到达的基础 URL 的子路径。 |
| NameID 格式 | 持久化 | 参见 [NameID 格式详情](../user/group/saml_sso/_index.md#manage-user-saml-identity)。 |
| 额外 URL | 可选 | 可能包括一些提供者在其他字段中的颁发者、标识符或断言消费者服务 URL。 |

有关配置示例，请参阅[特定提供者说明](#set-up-identity-providers)。

<a id="configure-saml-with-geo"></a>

## 配置 SAML 与 Geo 一起使用

要配置 Geo 与 SAML，请参阅[配置实例级 SAML](../administration/geo/replication/single_sign_on.md#configuring-instance-wide-saml)。

更多信息，请参阅[Geo 与单点登录 (SSO)](../administration/geo/replication/single_sign_on.md)。

<a id="troubleshooting"></a>

## 故障排查

请参阅我们的[SAML 故障排查指南](../user/group/saml_sso/troubleshooting.md)。