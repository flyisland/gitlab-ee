---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 第三方对极狐GitLab 的授权。
title: OAuth 2.0 身份提供商 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API，可通过 [OAuth 2.0](https://oauth.net/2/) 协议允许第三方服务以用户身份访问极狐GitLab 资源。更多信息，请参见[将极狐GitLab 配置为 OAuth 2.0 认证身份提供商](../integration/oauth_provider.md)。

此功能基于 [doorkeeper Ruby gem](https://github.com/doorkeeper-gem/doorkeeper)。

<a id="cross-origin-resource-sharing"></a>

## 跨域资源共享

许多 `/oauth` 端点支持跨域资源共享（CORS）。以下端点还支持 [CORS 预检请求](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)：

- `/oauth/revoke`
- `/oauth/token`
- `/oauth/userinfo`

预检请求只能使用特定请求头：

- [简单请求](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS#simple_requests)中列出的请求头。
- `Authorization` 请求头。

例如，`X-Requested-With` 请求头不能用于预检请求。

<a id="supported-oauth-20-flows"></a>

## 支持的 OAuth 2.0 流程

极狐GitLab 支持以下授权流程：

- **带[代码交换证明密钥（PKCE）](https://www.rfc-editor.org/rfc/rfc7636/)的授权码**：
  最安全。如果不使用 PKCE，您就必须在移动客户端中包含客户端密钥。
  建议客户端和服务器应用都使用此流程。
- **授权码**：安全且常用的流程。推荐用于安全的
  服务器端应用。
- **设备授权授予**（极狐GitLab 17.1 及更高版本）：面向无法访问浏览器的设备的安全流程。需要借助辅助设备来完成授权流程。

[OAuth 2.1](https://oauth.net/2.1/)的草案规范明确省略了隐式授予和资源所有者密码凭据流程。

请参阅 [OAuth RFC](https://www.rfc-editor.org/info/rfc6749/)，了解
所有这些流程的工作方式，并为您的用例选择合适的流程。

授权码（无论是否使用 PKCE）流程要求先通过用户账号中的 `/user_settings/applications` 页面注册 `application`。注册期间，通过启用适当的范围，您可以限制 `application` 可以访问的资源范围。创建后，您将获得 `application` 凭据：

- 应用程序 ID
- 客户端密钥

> [!warning]
> 客户端密钥必须妥善保管。在应用程序架构允许的情况下，
> 您也应将应用程序 ID 保密。

有关极狐GitLab 中的范围列表，请参见[提供商文档](../integration/oauth_provider.md#view-all-authorized-applications)。

<a id="prevent-csrf-attacks"></a>

### 防止 CSRF 攻击

为了[保护基于重定向的流程](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics-13#section-3.1)，OAuth 规范建议在每次请求 `/oauth/authorize` 端点时使用“通过 state 参数传递的一次性 CSRF 令牌，并安全地绑定到用户代理”。这可以防止
[CSRF 攻击](https://wiki.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF))。

<a id="use-https-in-production"></a>

### 在生产环境中使用 HTTPS

在生产环境中，请为您的 `redirect_uri` 使用 HTTPS。在开发环境中，极狐GitLab 允许不安全的 HTTP 重定向 URI。

由于 OAuth 2.0 的安全性完全基于传输层，您不应使用未受保护的
URI。更多信息，请参见 [OAuth 2.0 RFC](https://www.rfc-editor.org/info/rfc6749/#section-3.1.2.1)
和 [OAuth 2.0 威胁模型 RFC](https://www.rfc-editor.org/rfc/rfc6819#section-4.4.2.1)。

以下各节详细介绍了如何通过每种流程获取授权。

<a id="authorization-code-with-proof-key-for-code-exchange-pkce"></a>

### 带代码交换证明密钥（PKCE）的授权码

[PKCE RFC](https://www.rfc-editor.org/info/rfc7636/#section-1.1) 包含
从授权请求到访问令牌的详细流程说明。以下步骤描述了我们的流程实现。

带 PKCE 的授权码流程（简称 PKCE）使得在公共客户端上安全地执行用客户端凭据交换访问令牌的 OAuth 交换成为可能，而完全无需访问*客户端密钥*。这使得 PKCE 流程非常适合单页 JavaScript 应用或其他客户端应用，因为在这些应用中，对用户保密在技术上是不可能的。

在开始流程之前，请生成 `STATE`、`CODE_VERIFIER` 和 `CODE_CHALLENGE`。

- `STATE` 是客户端用于在请求和回调之间维护
  状态的不可预测值。它还应被用作 CSRF 令牌。
- `CODE_VERIFIER` 是长度介于 43 到 128 个字符之间的随机字符串，
  使用字符 `A-Z`、`a-z`、`0-9`、`-`、`.`、`_` 和 `~`。
- `CODE_CHALLENGE` 是 `CODE_VERIFIER`的 SHA256 哈希的
  URL 安全 base64 编码字符串：
  - SHA256 哈希在编码前必须为二进制格式。
  - 在 Ruby 中，您可以使用 `Base64.urlsafe_encode64(Digest::SHA256.digest(CODE_VERIFIER), padding: false)` 来实现。
  - 作为参考，`CODE_VERIFIER` 字符串 `ks02i3jdikdo2k0dkfodf3m39rjfjsdk0wk349rj3jrhf` 在使用前面的 Ruby 代码片段
    进行哈希和编码后，会生成 `CODE_CHALLENGE` 字符串
    `2i0WFA-0AerkjQm4X4oDEhqA17QIAKNjXpagHBXmO_U`。

1. 请求授权码。为此，您应将用户重定向到
   `/oauth/authorize` 页面，并附带以下查询参数：

   ```plaintext
   https://gitlab.example.com/oauth/authorize?client_id=APP_ID&redirect_uri=REDIRECT_URI&response_type=code&state=STATE&scope=REQUESTED_SCOPES&code_challenge=CODE_CHALLENGE&code_challenge_method=S256&root_namespace_id=ROOT_NAMESPACE_ID
   ```

   此页面要求用户根据 `REQUESTED_SCOPES`中指定的范围，批准应用访问其
   账号的请求。随后用户会被
   重定向回指定的 `REDIRECT_URI`。[范围参数](../integration/oauth_provider.md#view-all-authorized-applications)
   是与用户关联的以空格分隔的范围列表。
   例如，`scope=read_user+profile` 请求 `read_user` 和 `profile` 范围。
   `root_namespace_id` 是与项目关联的根命名空间 ID。当为关联群组配置了
   [SAML SSO](../user/group/saml_sso/_index.md) 时，应使用此可选参数。
   重定向中包含授权 `code`，例如：

   ```plaintext
   https://example.com/oauth/redirect?code=1234567890&state=STATE
   ```

1. 使用上一个请求返回的授权 `code`（在以下示例中记为
   `RETURNED_CODE`），您可以使用任意 HTTP 客户端请求 `access_token`。
   以下示例使用 Ruby 的 `rest-client`：

   ```ruby
   parameters = 'client_id=APP_ID&code=RETURNED_CODE&grant_type=authorization_code&redirect_uri=REDIRECT_URI&code_verifier=CODE_VERIFIER'
   RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   响应示例：

   ```json
   {
    "access_token": "de6780bc506a0446309bd9362820ba8aed28aa506c71eedbe1c5c4f9dd350e54",
    "token_type": "bearer",
    "expires_in": 7200,
    "refresh_token": "8257e65c97202ed1726cf9571600918f3bffb2544b26e00a61df9897668c33a1",
    "created_at": 1607635748
   }
   ```

1. 要获取新的 `access_token`，请使用 `refresh_token` 参数。刷新令牌即使在
   `access_token` 本身过期后仍可使用。此请求会：
   - 使现有的 `access_token` 和 `refresh_token` 失效。
   - 在响应中发送新令牌。

   ```ruby
     parameters = 'client_id=APP_ID&refresh_token=REFRESH_TOKEN&grant_type=refresh_token&redirect_uri=REDIRECT_URI'
     RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   响应示例：

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
> `redirect_uri` 必须与原始
> 授权请求中使用的 `redirect_uri` 匹配。

现在您可以使用访问令牌向 API 发起请求。

<a id="authorization-code-flow"></a>

### 授权码流程

> [!note]
> 请查看 [RFC 规范](https://www.rfc-editor.org/info/rfc6749/#section-4.1)以了解
> 详细的流程说明。

授权码流程与[带 PKCE 的授权码流程](#authorization-code-with-proof-key-for-code-exchange-pkce)基本相同，

在开始流程之前，请生成 `STATE`。它是客户端用于在请求和回调之间维护状态的不可预测值。它还应被用作 CSRF 令牌。

1. 请求授权码。为此，您应将用户重定向到
   `/oauth/authorize` 页面，并附带以下查询参数：

   ```plaintext
   https://gitlab.example.com/oauth/authorize?client_id=APP_ID&redirect_uri=REDIRECT_URI&response_type=code&state=STATE&scope=REQUESTED_SCOPES&root_namespace_id=ROOT_NAMESPACE_ID
   ```

   此页面要求用户根据 `REQUESTED_SCOPES`中指定的范围，批准应用访问其
   账号的请求。随后用户会被
   重定向回指定的 `REDIRECT_URI`。[范围参数](../integration/oauth_provider.md#view-all-authorized-applications)
   是与用户关联的以空格分隔的范围列表。
   例如，`scope=read_user+profile` 请求 `read_user` 和 `profile` 范围。
   `root_namespace_id` 是与项目关联的根命名空间 ID。当为关联群组配置了
   [SAML SSO](../user/group/saml_sso/_index.md) 时，应使用此可选参数。
   重定向中包含授权 `code`，例如：

   ```plaintext
   https://example.com/oauth/redirect?code=1234567890&state=STATE
   ```

1. 使用上一个请求返回的授权 `code`（在以下示例中显示为
   `RETURNED_CODE`），您可以使用任意 HTTP 客户端请求 `access_token`。
   以下示例使用 Ruby 的 `rest-client`：

   ```ruby
   parameters = 'client_id=APP_ID&client_secret=APP_SECRET&code=RETURNED_CODE&grant_type=authorization_code&redirect_uri=REDIRECT_URI'
   RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   您可以如所示将 `client_id` 和 `client_secret` 作为请求参数发送，或放在
   `Authorization: Basic` 请求头中发送，但不能同时使用两者。同时在这两处包含密钥的请求
   会返回 `400 Bad Request`。

   响应示例：

   ```json
   {
    "access_token": "de6780bc506a0446309bd9362820ba8aed28aa506c71eedbe1c5c4f9dd350e54",
    "token_type": "bearer",
    "expires_in": 7200,
    "refresh_token": "8257e65c97202ed1726cf9571600918f3bffb2544b26e00a61df9897668c33a1",
    "created_at": 1607635748
   }
   ```

1. 要获取新的 `access_token`，请使用 `refresh_token` 参数。刷新令牌即使在
   `access_token` 本身过期后仍可使用。此请求会：
   - 使现有的 `access_token` 和 `refresh_token` 失效。
   - 在响应中发送新令牌。

   ```ruby
     parameters = 'client_id=APP_ID&client_secret=APP_SECRET&refresh_token=REFRESH_TOKEN&grant_type=refresh_token&redirect_uri=REDIRECT_URI'
     RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

   响应示例：

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
> `redirect_uri` 必须与原始
> 授权请求中使用的 `redirect_uri` 匹配。

现在您可以使用返回的访问令牌向 API 发起请求。

<a id="device-authorization-grant-flow"></a>

### 设备授权授予流程

> [!note]
> 请查看 [RFC 规范](https://datatracker.ietf.org/doc/html/rfc8628#section-3.1)，了解设备授权授予流程的详细
> 说明，从设备授权请求到浏览器登录返回的令牌响应。

设备授权授予流程使得在无法进行浏览器交互的输入受限设备上安全地验证您的极狐GitLab 身份成为可能。

这使得设备授权授予流程非常适合尝试从无界面服务器或其他没有 UI 或 UI 受限的设备使用极狐GitLab 服务的用户。

1. 要请求设备授权，需从输入受限
   设备客户端向 `https://gitlab.example.com/oauth/authorize_device` 发送请求。例如：

   ```ruby
     parameters = 'client_id=UID&scope=read'
     RestClient.post 'https://gitlab.example.com/oauth/authorize_device', parameters
   ```

   请求成功后，会向用户返回包含 `verification_uri`的响应。例如：

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

1. 设备客户端向请求用户显示响应中的 `user_code` 和 `verification_uri`。
   随后该用户在具有浏览器访问权限的辅助设备上：
   1. 访问提供的 URI。
   1. 输入用户代码。
   1. 按提示完成身份验证。

1. 在显示 `verification_uri` 和 `user_code` 后，设备客户端
   立即开始使用初始响应中返回的关联 `device_code` 轮询令牌端点：

   ```ruby
   parameters = 'grant_type=urn:ietf:params:oauth:grant-type:device_code
   &device_code=GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS
   &client_id=1406020730'
   RestClient.post 'https://gitlab.example.com/oauth/token', parameters
   ```

1. 设备客户端从令牌端点收到响应。如果授权成功，
   则返回成功响应，否则返回错误响应。
   可能的错误响应分为以下任一类：

   - OAuth 授权框架访问令牌错误响应所定义的错误。
   - 此处描述的特定于设备授权授予流程的错误。

   特定于设备流程的这些错误响应在以下内容中描述。
   有关每种可能响应的更多信息，请参见相关的[设备授权授予 RFC 规范](https://datatracker.ietf.org/doc/html/rfc8628#section-3.5)和
   [授权令牌 RFC 规范](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2)。

   响应示例：

   ```json
   {
     "error": "authorization_pending",
     "error_description": "..."
   }
   ```

   收到此响应后，设备客户端继续轮询。

   如果轮询间隔太短，会返回减速错误响应。例如：

    ```json
    {
      "error": "slow_down",
      "error_description": "..."
    }
    ```

   收到此响应后，设备客户端会降低轮询速率，并以新速率继续轮询。

   如果设备代码在身份验证完成之前过期，会返回令牌过期错误
   响应。例如：

   ```json
   {
     "error": "expired_token",
     "error_description": "..."
   }
   ```

   此时，设备客户端应停止并发起新的设备授权请求。

   如果授权请求被拒绝，会返回访问被拒绝错误响应。例如：

   ```json
   {
     "error": "access_denied",
     "error_description": "..."
   }
   ```

   身份验证请求已被拒绝。用户应验证其凭据或联系其系统管理员

1. 用户成功通过身份验证后，会返回成功响应：

   ```json
   {
       "access_token": "TOKEN",
       "token_type": "Bearer",
       "expires_in": 7200,
       "scope": "read",
       "created_at": 1593096829
   }
   ```

此时，设备身份验证流程完成。返回的 `access_token` 可提供给极狐GitLab，以便在访问极狐GitLab 资源时验证用户身份，例如通过 HTTPS 克隆或访问 API 时。

实现客户端设备流程的示例应用可在以下位置找到：<https://gitlab.com/johnwparent/git-auth-over-https>。

<a id="access-gitlab-api-with-access-token"></a>

## 使用 `access token` 访问极狐GitLab API

`access token` 允许您以用户身份向 API 发起请求。您可以将令牌作为 GET 参数传递，也可以放在 `Authorization` 请求头中传递，但不能同时使用两者。同时在这两处包含令牌的请求会返回 `400 Bad Request`。

作为 GET 参数：

```plaintext
GET https://gitlab.example.com/api/v4/user?access_token=<OAUTH-TOKEN>
```

在 `Authorization` 请求头中：

```shell
curl --request GET \
  --header "Authorization: Bearer <OAUTH-TOKEN>" \
  --url "https://gitlab.example.com/api/v4/user"
```

<a id="access-git-over-https-with-access-token"></a>

## 使用 `access token` 通过 HTTPS 访问 Git

具有 [范围](../integration/oauth_provider.md#view-all-authorized-applications)
`read_repository` 或 `write_repository`的令牌可以通过 HTTPS 访问 Git。请将该令牌用作密码。您可以将用户名设置为任意字符串值。您应使用 `oauth2`：

```plaintext
https://oauth2:<your_access_token>@gitlab.example.com/project_path/project_name.git
```

或者，您可以使用 [Git 凭据助手](../user/profile/account/two_factor_authentication.md#oauth-credential-helpers)通过 OAuth 向极狐GitLab 进行身份验证。这会自动处理 OAuth 令牌刷新。

<a id="retrieve-the-token-information"></a>

## 获取令牌信息

要验证令牌的详细信息，请使用 Doorkeeper gem 提供的 `token/info` 端点。更多信息，请参见
[`/oauth/token/info`](https://github.com/doorkeeper-gem/doorkeeper/wiki/API-endpoint-descriptions-and-examples#get----oauthtokeninfo)。

您必须提供访问令牌，方式如下：

- 作为参数：

  ```plaintext
  GET https://gitlab.example.com/oauth/token/info?access_token=<OAUTH-TOKEN>
  ```

- 在 Authorization 请求头中：

  ```shell
  curl --request GET \
    --header "Authorization: Bearer <OAUTH-TOKEN>" \
    --url "https://gitlab.example.com/oauth/token/info"
  ```

以下是一个响应示例：

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

响应中包含 `scopes` 和 `expires_in_seconds` 字段，但它们现已弃用。`scopes` 字段是 `scope`的别名，`expires_in_seconds` 字段是 `expires_in`的别名。更多信息，请参见 [Doorkeeper API 变更](https://github.com/doorkeeper-gem/doorkeeper/wiki/Migration-from-old-versions#api-changes-5)。

<a id="revoke-a-token"></a>

## 撤销令牌

要撤销令牌，请使用 `revoke` 端点。该 API 会返回 200 响应码和空的 JSON 哈希以表示成功。

```ruby
parameters = 'client_id=APP_ID&client_secret=APP_SECRET&token=TOKEN'
RestClient.post 'https://gitlab.example.com/oauth/revoke', parameters
```

<a id="oauth-20-tokens-and-gitlab-registries"></a>

## OAuth 2.0 令牌与极狐GitLab 的容器镜像仓库、软件包仓库和虚拟仓库

标准 OAuth 2.0 令牌对极狐GitLab 的容器镜像仓库、软件包仓库和虚拟仓库
支持不同程度的访问，因为它们：

- 不允许用户通过身份验证访问以下服务：
  - 极狐GitLab [容器镜像仓库](../user/packages/container_registry/authenticate_with_container_registry.md)。
  - 极狐GitLab [软件包仓库](../user/packages/package_registry/_index.md)中列出的软件包。
  - [虚拟仓库](../user/packages/virtual_registry/_index.md)。
- 允许用户通过[容器镜像仓库 API](container_registry.md) 获取、列出和删除容器仓库。
- 允许用户通过 [Maven 虚拟仓库 API](maven_virtual_registries.md) 获取、列出和删除 Maven 虚拟仓库对象。
