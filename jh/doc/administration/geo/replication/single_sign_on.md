---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo 与单点登录 (SSO)
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档仅讨论 Geo 特有的 SSO 注意事项和配置。有关一般身份验证的更多信息，请参见[极狐GitLab 身份验证和授权](../../auth/_index.md)。

<a id="configuring-instance-wide-saml"></a>

## 配置实例级 SAML

<a id="prerequisites"></a>

### 先决条件

[实例级 SAML](../../../integration/saml.md) 必须在您的主 Geo 站点上正常工作。

您只需在主站点上配置 SAML。在从站点的 `gitlab.rb`中配置 `gitlab_rails['omniauth_providers']` 不会产生任何效果。从站点会针对主站点上配置的 SAML 提供商进行身份验证。根据从站点的 [URL 类型](#determine-the-type-of-url-your-secondary-site-uses)，可能需要在主站点上进行[额外配置](#saml-with-separate-url-with-proxying-enabled)。

<a id="determine-the-type-of-url-your-secondary-site-uses"></a>

### 确定从站点使用的 URL 类型

配置实例级 SAML 的方式因从站点配置而异。请确定您的从站点使用的是：

- [统一 URL](../secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites)，即 `external_url` 与主站点的 `external_url` 完全一致。
- [独立 URL](../secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site) 且启用了代理。代理默认启用。
- [独立 URL](../secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site) 且禁用了代理。

<a id="saml-with-unified-url"></a>

### 使用统一 URL 的 SAML

如果您已正确地在主站点上配置了 SAML，那么它应该无需额外配置即可在从站点上正常工作。

<a id="saml-with-separate-url-with-proxying-enabled"></a>

### 使用独立 URL 且启用代理的 SAML

> [!note]
> 启用代理后，只有当您的 SAML 身份提供商 (IdP) 允许一个应用配置多个回调 URL 时，SAML 才能用于登录从站点。请咨询您的 IdP 提供商支持团队以确认是否支持。

如果从站点使用的 `external_url` 与主站点不同，请配置您的 SAML 身份提供商 (IdP) 以允许从站点的 SAML 回调 URL。例如，要配置 Okta：

1. [登录 Okta](https://login.okta.com/)。
1. 转到 **Okta 管理员仪表盘** > **应用程序** > **您的应用名称** > **常规**。
1. 在 **SAML 设置**中，选择 **编辑**。
1. 在 **常规设置**中，选择 **下一步** 以转到 **SAML 设置**。
1. 在 **SAML 设置** > **常规**中，确保 **单点登录 URL** 是您主站点的 SAML 回调 URL。例如，`https://gitlab-primary.example.com/users/auth/saml/callback`。如果不是，请在此字段中输入您主站点的 SAML 回调 URL。
1. 选择 **显示高级设置**。
1. 在 **其他可请求的 SSO URL**中，输入您从站点的 SAML 回调 URL。例如，`https://gitlab-secondary.example.com/users/auth/saml/callback`。您可以将 **索引** 设置为任意值。
1. 选择 **下一步**，然后选择 **完成**。

您不得在主站点的 `gitlab.rb`中的 `gitlab_rails['omniauth_providers']` 的 SAML 提供商配置中指定 `assertion_consumer_service_url`。例如：

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

- 您的两个站点都使用 `/users/auth/saml/callback` 作为其断言消费者服务 (ACS) URL。
- URL 主机被设置为相应站点的主机。

您可以通过访问每个站点的 `/users/auth/saml/metadata` 路径来检查这一点。例如，访问 `https://gitlab-primary.example.com/users/auth/saml/metadata` 可能会返回：

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

访问 `https://gitlab-secondary.example.com/users/auth/saml/metadata` 可能会返回：

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

在配置您的 SAML IdP 以允许从站点的 SAML 回调 URL 后，您应该能够在主站点以及从站点上使用 SAML 登录。

<a id="saml-with-separate-url-with-proxying-disabled"></a>

### 使用独立 URL 且禁用代理的 SAML

如果您已正确地在主站点上配置了 SAML，那么它应该无需额外配置即可在从站点上正常工作。

<a id="openid-connect"></a>

## OpenID Connect

> [!flag]
> 使用独立 URL 且启用代理时，OIDC 的可用性由功能标志控制。

如果您使用 [OpenID Connect (OIDC)](../../auth/oidc.md) OmniAuth 提供商，在大多数情况下，它应该可以正常工作：

- **使用统一 URL 的 OIDC**：如果您已正确地在主站点上配置了 OIDC，那么它应该无需额外配置即可在从站点上正常工作。
- **使用独立 URL 且禁用代理的 OIDC**：如果您已正确地在主站点上配置了 OIDC，那么它应该无需额外配置即可在从站点上正常工作。
- **使用独立 URL 且启用代理的 OIDC**：用户可以使用从站点的 URL 登录。
  当请求通过 Geo 从站点到达时，极狐GitLab 会发送发起登录的站点的重定向 URI，而不是配置的
  `redirect_uri`。要使用它：

  1. 在您的身份提供商中的 OIDC 客户端上，将每个站点的回调 URL
     (`https://<site-external-url>/users/auth/openid_connect/callback`) 注册为有效的重定向 URI。
  1. 在主站点上[启用功能标志](../../feature_flags/_index.md) `geo_oidc_proxied_redirect_uri`。

<a id="ldap"></a>

## LDAP

如果您在主站点上使用 LDAP，相同的 LDAP 配置也适用于从站点，因为从站点会将与身份验证相关的请求代理到主站点。

为了准备灾难恢复场景，您应该在每个从站点上设置辅助 LDAP 服务器。在这种情况下，当您提升从站点时，用户将能够使用副本 LDAP 服务进行身份验证。否则，如果连接到主站点的 LDAP 服务对提升后的从站点不可用，用户将无法在从站点上使用 HTTP 基本身份验证通过 HTTP(s) 执行 Git 操作。但是，用户仍然可以使用带 SSH 和个人访问令牌的 Git，除非在 LDAP 服务不可用时其账号因多次登录失败而被锁定。

> [!note]
> 所有从站点可以共享一个 LDAP 服务器，但额外的延迟可能会成为问题。此外，请考虑在从站点被提升为主站点的[灾难恢复](../disaster_recovery/_index.md)场景中，哪个 LDAP 服务器可用。

请查阅您的 LDAP 服务文档，了解如何在您的 LDAP 服务中设置复制。具体过程因所使用的软件或服务而异。例如，OpenLDAP 提供了此[复制文档](https://www.openldap.org/doc/admin24/replication.html)。
