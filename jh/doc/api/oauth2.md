---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Third-party authorization to GitLab.
title: OAuth 2.0 身份提供者 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 允许第三方服务通过 [OAuth 2.0](https://oauth.net/2/) 协议为用户访问极狐GitLab 资源。
有关更多信息，请参阅[将极狐GitLab 配置为 OAuth 2.0 身份验证提供者](../integration/oauth_provider.md)。

此功能基于 [doorkeeper Ruby gem](https://github.com/doorkeeper-gem/doorkeeper)。

<a id="cross-origin-resource-sharing"></a>

## 跨域资源共享

{{< history >}}

- 在极狐GitLab 15.1 引入了 CORS 预检请求支持。

{{< /history >}}

许多 `/oauth` 端点支持跨域资源共享 (CORS)。从极狐GitLab 15.1 开始，以下端点也支持 [CORS 预检请求](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)：

- `/oauth/revoke`
- `/oauth/token`
- `/oauth/userinfo`

预检请求只能使用某些标头：

- [简单请求](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#simple_requests) 中列出的标头。
- `Authorization` 标头。

例如，`X-Requested-With` 标头无法用于预检请求。

<a id="supported-oauth-20-flows"></a>

## 支持的 OAuth 2.0 流程

极狐GitLab 支持以下授权流程：

- **带有用于代码交换的证明密钥的授权码 (PKCE)**：
  最安全。没有 PKCE，您必须在移动客户端中包含客户端密钥，建议用于客户端和服务器应用程序。
- **授权码**：安全且常见的流程。推荐用于安全服务器端应用程序的选项。
- **设备授权授予**（极狐GitLab 17.1 及更高版本）面向无法使用浏览器访问的设备的安全流程。需要辅助设备完成授权流程。

[OAuth 2.1](https://oauth.net/2.1/) 的草案规范专门省略了隐式授予和资源所有者密码凭据流程。

请参阅 [OAuth RFC](https://www.rfc-editor.org/rfc/rfc6749) 以了解所有这些流程的工作原理，并为您的用例选择合适的流程。

授权码（带或不带 PKCE）流程要求首先通过用户帐户中的 `/user_settings/applications` 页面注册 `application`。
在注册过程中，通过启用适当的范围，您可以限制 `application` 可以访问的资源范围。创建后，您将获得 `application` 凭证：_应用程序 ID_ 和 _客户端密钥_。_客户端密钥_ **必须保密**。当您的应用程序架构允许时，保持 _应用程序 ID_ 机密也是有利的。

有关极狐GitLab 中范围的列表，请参阅[提供程序文档](../integration/oauth_provider.md#view-all-authorized-applications)。

<a id="prevent-csrf-attacks"></a>

### 防止 CSRF 攻击

为了[保护基于重定向的流程](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics-13#section-3.1)，OAuth 规范建议使用“一次性 CSRF 令牌，这些令牌携带在 state 参数中，并与用户代理安全绑定”，每个请求到 `/oauth/authorize` 端点。这可以防止 [CSRF 攻击](https://wiki.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF))。

<a id="use-https-in-production"></a>

### 在生产中使用 HTTPS

对于生产环境，请为您的 `redirect_uri` 使用 HTTPS。
对于开发环境，极狐GitLab 允许不安全的 HTTP 重定向 URI。

由于 OAuth 2.0 的安全性完全基于传输层，因此您不应使用未受保护的 URI。有关更多信息，请参阅 [OAuth 2.0 RFC](https://www.rfc-editor.org/rfc/rfc6749#section-3.1.2.1) 和 [OAuth 2.0 威胁模型 RFC](https://www.rfc-editor.org/rfc/rfc6819#section-4.4.2.1)。

在以下部分中，您可以找到有关如何使用每种流程获取授权的详细说明。

<a id="authorization-code-with-proof-key-for-code-exchange-pkce"></a>

### 带有用于代码交换的证明密钥的授权码 (PKCE)

{{< history >}}

- OAuth 应用程序的群组 SAML SSO 支持在极狐GitLab 18.2 引入，功能标志 名为 `ff_oauth_redirect_to_sso_login`。默认禁用。
- OAuth 应用程序的群组 SAML SSO 支持在极狐GitLab 18.3 于 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 18.5 GA。功能标志 `ff_oauth_redirect_to_sso_login` 移除。

{{< /history >}}

[PKCE RFC](https://www.rfc-editor.org/rfc/rfc7636#section-1.1) 包含了从授权请求到访问令牌的详细流程描述。以下步骤描述了我们对该流程的实现。

带有 PKCE 的授权码流程（简称 PKCE）使得在公共客户端上安全地执行 OAuth 客户端凭据交换以获取访问令牌成为可能，而完全不需要访问 _客户端密钥_。这使得 PKCE 流程对于单页 JavaScript 应用程序或其他客户端应用程序非常有利，在这些应用程序中，技术上不可能对用户保密。

在开始流程之前，生成 `STATE`、`CODE_VERIFIER` 和 `CODE_CHALLENGE`。

- `STATE` 是一个无法预测的值，客户端使用它在请求和回调之间保持状态。它还应作为 CSRF 令牌。
- `CODE_VERIFIER` 是一个随机字符串，长度在 43 到 128 个字符之间，使用字符 `A-Z`、`a-z`、`0-9`、`-`、`.`、`_` 和 `~`。
- `CODE_CHALLENGE` 是 `CODE_VERIFIER` 的 SHA256 哈希值的 URL 安全 base64 编码字符串：
  - SHA256 哈希在编码前必须为二进制格式。
  - 在 Ruby 中，您可以使用 `Base64.urlsafe_encode64(Digest::SHA256.digest(CODE_VERIFIER), padding: false)` 进行设置。
  - 作为参考，一个 `CODE_VERIFIER` 字符串 `ks02i3jdikdo2k0dkfodf3m39rjfjsdk0wk349rj3jrhf` 在使用上述 Ruby 片段进行哈希和编码后，会生成一个 `CODE_CHALLENGE` 字符串 `2i0WFA-0AerkjQm4X4oDEhqA17QIAKNjXpagHBXmO_U`。

1. 请求授权码。为此，您应将用户重定向到 `/oauth/authorize` 页面，并包含以下查询参数：

   ```plaintext
   https://gitlab.example.com/oauth/authorize?client_id=APP_ID&redirect_uri=REDIRECT_URI&response_type=code&state=STATE&scope=REQUESTED_SCOPES&code_challenge=CODE_CHALLENGE&code_challenge_method=S256&root_namespace_id=ROOT_NAMESPACE_ID
   ```

   此页面要求用户根据 `REQUESTED_SCOPES` 中指定的范围批准应用程序访问其帐户的请求。然后，用户将被重定向回指定的 `REDIRECT_URI`。[范围参数](../integration/oauth_provider.md#view-all-authorized-applications) 是与用户关联的范围的空格分隔列表。例如，`scope=read_user+profile` 请求 `read_user` 和 `profile` 范围。
   `root_namespace_id` 是与项目关联的根命名空间 ID。当关联的群组配置了 [SAML SSO](../user/group/saml_sso/_index.md) 时，应使用此可选参数。
   重定向包含授权 `code`，例如：

   ```plaintext
   https://example.com/oauth/redirect?code=1234567890&state=STATE
   ```

1. 使用从上一步请求返回的授权 `code`（在以下示例中表示为 `RETURNED_CODE`），您可以请求 `access_token`，可以使用任何 HTTP 客户端。以下示例使用 Ruby 的 `rest-client`：

   ```ruby
   parameters = 'client_id=APP_ID&code=RETURNED_CODE&grant_type=authorization_code&redirect_uri=REDIRECT_URI&code_verifier=CODE_VERIFIER'
   RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   示例响应：

   ```json
   {
    "access_token": "de6780bc506a0446309bd9362820ba8aed28aa506c71eedbe1c5c4f9dd350e54",
    "token_type": "bearer",
    "expires_in": 7200,
    "refresh_token": "8257e65c97202ed1726cf9571600918f3bffb2544b26e00a61df9897668c33a1",
    "created_at": 1607635748
   }
   ```

1. 要获取新的 `access_token`，请使用 `refresh_token` 参数。刷新令牌即使在 `access_token` 本身过期后也可以使用。此请求：
   - 使现有的 `access_token` 和 `refresh_token` 失效。
   - 在响应中发送新的令牌。

   ```ruby
     parameters = 'client_id=APP_ID&refresh_token=REFRESH_TOKEN&grant_type=refresh_token&redirect_uri=REDIRECT_URI'
     RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   示例响应：

   ```json
   {
     "access_token": "c97d1fe52119f38c7f67f0a14db68d60caa35ddc86fd12401718b649dcfa9c68",
     "token_type": "bearer",
     "expires_in": 7200,
     "refresh_token": "803c1fd487fec35562c205dac93e9d8e08f9d3652a24079d704df3039df1158f",
     "created_at": 1628711391
   }
   ```

> [!note]
> `redirect_uri` 必须与原始授权请求中使用的 `redirect_uri` 匹配。

您现在可以使用访问令牌向 API 发出请求。

<a id="authorization-code-flow"></a>

### 授权码流程

{{< history >}}

- OAuth 应用程序的群组 SAML SSO 支持在极狐GitLab 18.2 引入，功能标志 名为 `ff_oauth_redirect_to_sso_login`。默认禁用。
- OAuth 应用程序的群组 SAML SSO 支持在极狐GitLab 18.3 于 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 18.5 GA。功能标志 `ff_oauth_redirect_to_sso_login` 移除。

{{< /history >}}

> [!note]
> 查看 [RFC 规范](https://www.rfc-editor.org/rfc/rfc6749#section-4.1) 以获取详细的流程描述。

授权码流程本质上与[带有用于代码交换的证明密钥的授权码流程](#authorization-code-with-proof-key-for-code-exchange-pkce)相同。

在开始流程之前，生成 `STATE`。它是一个无法预测的值，客户端使用它在请求和回调之间保持状态。它还应作为 CSRF 令牌。

1. 请求授权码。为此，您应将用户重定向到 `/oauth/authorize` 页面，并包含以下查询参数：

   ```plaintext
   https://gitlab.example.com/oauth/authorize?client_id=APP_ID&redirect_uri=REDIRECT_URI&response_type=code&state=STATE&scope=REQUESTED_SCOPES&root_namespace_id=ROOT_NAMESPACE_ID
   ```

   此页面要求用户根据 `REQUESTED_SCOPES` 中指定的范围批准应用程序访问其帐户的请求。然后，用户将被重定向回指定的 `REDIRECT_URI`。[范围参数](../integration/oauth_provider.md#view-all-authorized-applications) 是与用户关联的范围的空格分隔列表。例如，`scope=read_user+profile` 请求 `read_user` 和 `profile` 范围。
   `root_namespace_id` 是与项目关联的根命名空间 ID。当关联的群组配置了 [SAML SSO](../user/group/saml_sso/_index.md) 时，应使用此可选参数。
   重定向包含授权 `code`，例如：

   ```plaintext
   https://example.com/oauth/redirect?code=1234567890&state=STATE
   ```

1. 使用从上一步请求返回的授权 `code`（在以下示例中表示为 `RETURNED_CODE`），您可以请求 `access_token`，可以使用任何 HTTP 客户端。以下示例使用 Ruby 的 `rest-client`：

   ```ruby
   parameters = 'client_id=APP_ID&client_secret=APP_SECRET&code=RETURNED_CODE&grant_type=authorization_code&redirect_uri=REDIRECT_URI'
   RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   示例响应：

   ```json
   {
    "access_token": "de6780bc506a0446309bd9362820ba8aed28aa506c71eedbe1c5c4f9dd350e54",
    "token_type": "bearer",
    "expires_in": 7200,
    "refresh_token": "8257e65c97202ed1726cf9571600918f3bffb2544b26e00a61df9897668c33a1",
    "created_at": 1607635748
   }
   ```

1. 要获取新的 `access_token`，请使用 `refresh_token` 参数。刷新令牌即使在 `access_token` 本身过期后也可以使用。此请求：
   - 使现有的 `access_token` 和 `refresh_token` 失效。
   - 在响应中发送新的令牌。

   ```ruby
     parameters = 'client_id=APP_ID&client_secret=APP_SECRET&refresh_token=REFRESH_TOKEN&grant_type=refresh_token&redirect_uri=REDIRECT_URI'
     RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   示例响应：

   ```json
   {
     "access_token": "c97d1fe52119f38c7f67f0a14db68d60caa35ddc86fd12401718b649dcfa9c68",
     "token_type": "bearer",
     "expires_in": 7200,
     "refresh_token": "803c1fd487fec35562c205dac93e9d8e08f9d3652a24079d704df3039df1158f",
     "created_at": 1628711391
   }
   ```

> [!note]
> `redirect_uri` 必须与原始授权请求中使用的 `redirect_uri` 匹配。

您现在可以使用返回的访问令牌向 API 发出请求。

<a id="device-authorization-grant-flow"></a>

### 设备授权授予流程

{{< history >}}

- 在极狐GitLab 17.2 引入，功能标志 名为 `oauth2_device_grant_flow`。
- 在 17.3 默认启用。
- 在极狐GitLab 17.9 GA。功能标志 `oauth2_device_grant_flow` 移除。

{{< /history >}}

> [!note]
> 查看 [RFC 规范](https://datatracker.ietf.org/doc/html/rfc8628#section-3.1) 以获取详细的设备授权授予流程描述，从设备授权请求到浏览器登录的令牌响应。

设备授权授予流程使得可以从输入受限的设备（无法进行浏览器交互）安全地验证您的极狐GitLab 身份。

这使得设备授权授予流程非常适合尝试从无头服务器或其他没有或只有有限 UI 的设备使用极狐GitLab 服务的用户。

1. 要请求设备授权，从输入有限的设备客户端向 `https://gitlab.example.com/oauth/authorize_device` 发送请求。例如：

   ```ruby
     parameters = 'client_id=UID&scope=read'
     RestClient.post 'https://gitlab.example.com/oauth/authorize_device', parameters
   ```

   请求成功后，将向用户返回包含 `verification_uri` 的响应。例如：

   ```json
   {
       "device_code": "GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS",
       "user_code": "0A44L90H",
       "verification_uri": "https://gitlab.example.com/oauth/device",
       "verification_uri_complete": "https://gitlab.example.com/oauth/device?user_code=0A44L90H",
       "expires_in": 300,
       "interval": 5
   }
   ```

1. 设备客户端向请求用户显示响应中的 `user_code` 和 `verification_uri`。然后，该用户在具有浏览器访问权限的辅助设备上：
   1. 转到提供的 URI。
   1. 输入用户代码。
   1. 按照提示完成身份验证。

1. 在显示 `verification_uri` 和 `user_code` 后，设备客户端立即开始使用初始响应中返回的关联 `device_code` 轮询令牌端点：

   ```ruby
   parameters = 'grant_type=urn:ietf:params:oauth:grant-type:device_code
   &device_code=GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS
   &client_id=1406020730'
   RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

1. 设备客户端从令牌端点接收响应。如果授权成功，则返回成功响应；否则，返回错误响应。
   潜在的错误响应分为以下两类：

   - 那些由 OAuth 授权框架访问令牌错误响应定义的错误。
   - 那些特定于此处描述的备授权授予流程的错误。

   这些特定于设备流程的错误响应在以下内容中描述。
   有关每个潜在响应的更多信息，请参阅相关的 [设备授权授予 RFC 规范](https://datatracker.ietf.org/doc/html/rfc8628#section-3.5) 和 [授权令牌 RFC 规范](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2)。

   示例响应：

   ```json
   {
     "error": "authorization_pending",
     "error_description": "..."
   }
   ```

   收到此响应后，设备客户端继续轮询。

   如果轮询间隔太短，将返回减慢错误响应。例如：

    ```json
    {
      "error": "slow_down",
      "error_description": "..."
    }
    ```

   收到此响应后，设备客户端降低其轮询速率并以新速率继续轮询。

   如果设备代码在身份验证完成之前过期，将返回过期令牌错误响应。例如：

   ```json
   {
     "error": "expired_token",
     "error_description": "..."
   }
   ```

   此时，设备客户端应停止并启动新的设备授权请求。

   如果授权请求被拒绝，将返回访问被拒绝错误响应。例如：

   ```json
   {
     "error": "access_denied",
     "error_description": "..."
   }
   ```

   身份验证请求已被拒绝。用户应验证其凭据或联系其系统管理员。

1. 用户成功验证后，将返回成功响应：

   ```json
   {
       "access_token": "TOKEN",
       "token_type": "Bearer",
       "expires_in": 7200,
       "scope": "read",
       "created_at": 1593096829
   }
   ```

此时，设备身份验证流程完成。返回的 `access_token` 可以提供给极狐GitLab，以在访问极狐GitLab 资源时验证用户身份，例如通过 HTTPS 克隆或访问 API。

可以在 <https://jihulab.com/johnwparent/git-auth-over-https> 找到一个实现客户端设备流程的示例应用程序。

<a id="access-gitlab-api-with-access-token"></a>

## 使用 `访问令牌` 访问极狐GitLab API

`access_token` 允许您代表用户向 API 发出请求。
您可以将令牌作为 GET 参数传递：

```plaintext
GET https://gitlab.example.com/api/v4/user?access_token=OAUTH-TOKEN
```

或者，您可以将令牌放入 Authorization 标头：

```shell
curl --header "Authorization: Bearer OAUTH-TOKEN" "https://gitlab.example.com/api/v4/user"
```

<a id="access-git-over-https-with-access-token"></a>

## 使用 `访问令牌` 通过 HTTPS 访问 Git

具有[范围](../integration/oauth_provider.md#view-all-authorized-applications) `read_repository` 或 `write_repository` 的令牌可以通过 HTTPS 访问 Git。使用令牌作为密码。
您可以将用户名设置为任何字符串值。您应该使用 `oauth2`：

```plaintext
https://oauth2:<your_access_token>@gitlab.example.com/project_path/project_name.git
```

或者，您可以使用 [Git 凭据助手](../user/profile/account/two_factor_authentication.md#oauth-credential-helpers) 通过 OAuth 向极狐GitLab 进行身份验证。这将自动处理 OAuth 令牌刷新。

<a id="retrieve-the-token-information"></a>

## 获取令牌信息

要验证令牌的详细信息，请使用 Doorkeeper gem 提供的 `token/info` 端点。有关更多信息，请参阅 [`/oauth/token/info`](https://github.com/doorkeeper-gem/doorkeeper/wiki/API-endpoint-descriptions-and-examples#get----oauthtokeninfo)。

您必须提供访问令牌，方式如下：

- 作为参数：

  ```plaintext
  GET https://gitlab.example.com/oauth/token/info?access_token=<OAUTH-TOKEN>
  ```

- 在 Authorization 标头中：

  ```shell
  curl --header "Authorization: Bearer <OAUTH-TOKEN>" "https://gitlab.example.com/oauth/token/info"
  ```

以下是一个示例响应：

```json
{
    "resource_owner_id": 1,
    "scope": ["api"],
    "expires_in": null,
    "application": {"uid": "1cb242f495280beb4291e64bee2a17f330902e499882fe8e1e2aa875519cab33"},
    "created_at": 1575890427
}
```

<a id="deprecated-fields"></a>

### 已弃用的字段

响应中包含字段 `scopes` 和 `expires_in_seconds`，但现已弃用。`scopes` 字段是 `scope` 的别名，`expires_in_seconds` 字段是 `expires_in` 的别名。有关更多信息，请参阅 [Doorkeeper API 更改](https://github.com/doorkeeper-gem/doorkeeper/wiki/Migration-from-old-versions#api-changes-5)。

<a id="revoke-a-token"></a>

## 撤销令牌

要撤销令牌，请使用 `revoke` 端点。API 返回 200 响应码和一个空的 JSON 哈希以表示成功。

```ruby
parameters = 'client_id=APP_ID&client_secret=APP_SECRET&token=TOKEN'
RestClient.post 'https://gitlab.example.com/oauth/revoke', parameters
```

<a id="oauth-20-tokens-and-gitlab-registries"></a>

## OAuth 2.0 令牌和极狐GitLab 注册表

标准 OAuth 2.0 令牌对极狐GitLab 注册表支持不同程度的访问，因为它们：

- 不允许用户向以下服务进行身份验证：
  - 极狐GitLab [容器镜像仓库](../user/packages/container_registry/authenticate_with_container_registry.md)。
  - 极狐GitLab [软件包仓库](../user/packages/package_registry/_index.md) 中列出的软件包。
  - [虚拟注册表](../user/packages/virtual_registry/_index.md)。
- 允许用户通过 [容器镜像仓库 API](container_registry.md) 获取、列出和删除注册表。
- 允许用户通过 [Maven 虚拟注册表 API](maven_virtual_registries.md) 获取、列出和删除注册表对象。