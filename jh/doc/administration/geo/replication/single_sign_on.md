---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo 与单点登录 (SSO)
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档仅讨论特定于 Geo 的 SSO 注意事项和配置。有关一般身份验证的更多信息，请参见[极狐GitLab 身份验证和授权](../../auth/_index.md)。

<a id="configuring-instance-wide-saml"></a>

## 配置实例范围 SAML

<a id="prerequisites"></a>

### 先决条件

[实例范围 SAML](../../../integration/saml.md) 必须在您的主 Geo 站点上正常工作。

您只需在主站点上配置 SAML。在辅助站点的 `gitlab.rb` 中配置 `gitlab_rails['omniauth_providers']` 无效。辅助站点根据主站点上配置的 SAML 提供程序进行身份验证。根据辅助站点的 [URL 类型](#determine-the-type-of-url-your-secondary-site-uses)，可能需要在主站点上进行[额外配置](#saml-with-separate-url-with-proxying-enabled)。

<a id="determine-the-type-of-url-your-secondary-site-uses"></a>

### 确定辅助站点使用的 URL 类型

配置实例范围 SAML 的方式取决于辅助站点的配置。确定您的辅助站点使用的是：

- [统一 URL](../secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites)，即 `external_url` 与主站点的 `external_url` 完全匹配。
- [启用了代理的独立 URL](../secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site)。在极狐GitLab 15.1 及更高版本中默认启用代理。
- [禁用了代理的独立 URL](../secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site)。

<a id="saml-with-unified-url"></a>

### 使用统一 URL 的 SAML

如果您已在主站点上正确配置 SAML，则无需额外配置即可在辅助站点上运行。

<a id="saml-with-separate-url-with-proxying-enabled"></a>

### 使用启用了代理的独立 URL 的 SAML

> [!note]
> 启用代理后，只有当您的 SAML 身份提供程序 (IdP) 允许一个应用程序配置多个回调 URL 时，才能使用 SAML 登录辅助站点。请与您的 IdP 提供商支持团队确认是否属于这种情况。

如果辅助站点使用与主站点不同的 `external_url`，则配置您的 SAML 身份提供程序 (IdP) 以允许辅助站点的 SAML 回调 URL。例如，配置 Okta：

1. [登录 Okta](https://login.okta.com/)。
1. 前往 **Okta 管理员仪表盘** > **应用程序** > **您的应用名称** > **常规**。
1. 在 **SAML 设置** 中，选择 **编辑**。
1. 在 **常规设置** 中，选择 **下一步** 以转到 **SAML 设置**。
1. 在 **SAML 设置** > **常规** 中，确保 **单点登录 URL** 是您主站点的 SAML 回调 URL。例如，`https://gitlab-primary.example.com/users/auth/saml/callback`。如果不是，请在此字段中输入主站点的 SAML 回调 URL。
1. 选择 **显示高级设置**。
1. 在 **其他可请求的 SSO URL** 中，输入辅助站点的 SAML 回调 URL。例如，`https://gitlab-secondary.example.com/users/auth/saml/callback`。您可以将 **索引** 设置为任意值。
1. 选择 **下一步**，然后选择 **完成**。

不得在主站点的 `gitlab.rb` 中的 SAML 提供程序配置 `gitlab_rails['omniauth_providers']` 中指定 `assertion_consumer_service_url`。例如：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "saml",
    label: "Okta", # optional label for login button, defaults to "Saml"
    args: {
      idp_cert_fingerprint: "B5:AD:AA:9E:3C:05:68:AD:3B:78:ED:31:99:96:96:43:9E:6D:79:96",
      idp_sso_target_url: "https://<dev-account>.okta.com/app/dev-account_gitlabprimary_1/exk7k2gft2VFpVFXa5d1/sso/saml",
      issuer: "https://<gitlab-primary>",
      name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
    }
  }
]
```

此配置会导致：

- 您的两个站点都将 `/users/auth/saml/callback` 用作其断言消费者服务 (ACS) URL。
- URL 主机将设置为相应站点的主机。

您可以通过访问每个站点的 `/users/auth/saml/metadata` 路径来检查这一点。例如，访问 `https://gitlab-primary.example.com/users/auth/saml/metadata` 可能会响应：

```xml
<md:EntityDescriptor ID="_b9e00d84-d34e-4e3d-95de-122e3c361617" entityID="https://gitlab-primary.example.com"
  xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
  xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
  <md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</md:NameIDFormat>
    <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://gitlab-primary.example.com/users/auth/saml/callback"    index="0" isDefault="true"/>
    <md:AttributeConsumingService index="1" isDefault="true">
      <md:ServiceName xml:lang="en">Required attributes</md:ServiceName>
      <md:RequestedAttribute FriendlyName="Email address" Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
      <md:RequestedAttribute FriendlyName="Full name" Name="name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
      <md:RequestedAttribute FriendlyName="Given name" Name="first_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
      <md:RequestedAttribute FriendlyName="Family name" Name="last_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
    </md:AttributeConsumingService>
  </md:SPSSODescriptor>
</md:EntityDescriptor>
```

访问 `https://gitlab-secondary.example.com/users/auth/saml/metadata` 可能会响应：

```xml
<md:EntityDescriptor ID="_bf71eb57-7490-4024-bfe2-54cec716d4bf" entityID="https://gitlab-primary.example.com"
  xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
  xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
  <md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</md:NameIDFormat>
    <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://gitlab-secondary.example.com/users/auth/saml/callback"    index="0" isDefault="true"/>
    <md:AttributeConsumingService index="1" isDefault="true">
      <md:ServiceName xml:lang="en">Required attributes</md:ServiceName>
      <md:RequestedAttribute FriendlyName="Email address" Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
      <md:RequestedAttribute FriendlyName="Full name" Name="name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
      <md:RequestedAttribute FriendlyName="Given name" Name="first_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
      <md:RequestedAttribute FriendlyName="Family name" Name="last_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
    </md:AttributeConsumingService>
  </md:SPSSODescriptor>
</md:EntityDescriptor>
```

`md:AssertionConsumerService` 字段的 `Location` 属性指向 `gitlab-secondary.example.com`。

在配置好您的 SAML IdP 允许辅助站点的 SAML 回调 URL 后，您应该能够使用 SAML 登录主站点以及辅助站点。

<a id="saml-with-separate-url-with-proxying-disabled"></a>

### 使用禁用了代理的独立 URL 的 SAML

如果您已在主站点上正确配置 SAML，则无需额外配置即可在辅助站点上运行。

<a id="openid-connect"></a>

## OpenID Connect

如果您使用 [OpenID Connect (OIDC)](../../auth/oidc.md) OmniAuth 提供程序，在大多数情况下，它应该可以正常工作：

- **统一 URL 的 OIDC**：如果您已在主站点上正确配置 OIDC，则无需额外配置即可在辅助站点上运行。
- **禁用了代理的独立 URL 的 OIDC**：如果您已在主站点上正确配置 OIDC，则无需额外配置即可在辅助站点上运行。
- **启用了代理的独立 URL 的 OIDC**：启用了代理的 Geo 独立 URL 不支持 [OpenID Connect](../../auth/oidc.md)。有关更多信息，请参见 [issue 396745](https://jihulab.com/gitlab-cn/gitlab/-/issues/396745)。

<a id="ldap"></a>

## LDAP

如果您在**主**站点上使用 LDAP，则相同的 LDAP 配置也适用于**辅助**站点，因为**辅助**站点会将与身份验证相关的请求代理到**主**站点。

为了准备灾难恢复场景，您应该在每个**辅助**站点上设置辅助 LDAP 服务器。
在这种情况下，当您提升**辅助**站点时，用户将能够使用副本 LDAP 服务进行身份验证。
否则，如果连接到**主**站点的 LDAP 服务对于提升后的**辅助**站点不可用，用户将无法在**辅助**站点上使用 HTTP 基本身份验证通过 HTTP(s) 执行 Git 操作。
但是，用户仍然可以使用 SSH 和个人访问令牌使用 Git，除非他们的帐户因为 LDAP 服务不可用时多次登录失败而被锁定。

> [!note]
> 所有**辅助**站点可以共享一个 LDAP 服务器，但额外的延迟可能会成为问题。此外，请考虑在[灾难恢复](../disaster_recovery/_index.md)场景中，如果**辅助**站点被提升为**主**站点，有哪些 LDAP 服务器可用。

查看您的 LDAP 服务文档，了解如何设置 LDAP 服务中的复制。该过程因所使用的软件或服务而异。例如，OpenLDAP 提供了此[复制文档](https://www.openldap.org/doc/admin24/replication.html)。

