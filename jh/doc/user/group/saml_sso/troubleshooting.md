---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SAML 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本页面包含您在使用以下功能时可能遇到的问题的解决方案：

- [JihuLab.com 群组的 SAML SSO](_index.md)。
- 极狐GitLab 私有化部署实例级 [SAML OmniAuth Provider](../../../integration/saml.md)。

<a id="saml-debugging-tools"></a>

## SAML 调试工具

SAML 响应采用 base64 编码。要即时解码，您可以使用 **SAML-tracer** 浏览器扩展（[Firefox](https://addons.mozilla.org/en-US/firefox/addon/saml-tracer/)、[Chrome](https://chromewebstore.google.com/detail/saml-tracer/mpdajninpobndbfcldcmbpnnbhibjmch?hl=en)）。

如果您无法安装浏览器插件，可以改为[手动生成并捕获 SAML 响应](#manually-generate-a-saml-response)。

请特别注意以下内容：

- `NameID`，用于标识登录的用户。如果该用户之前登录过，
  则此值必须与 [极狐GitLab 存储的值](#verify-nameid)一致。
- 是否存在 `X509Certificate`，验证响应签名需要该证书。
- `SubjectConfirmation` 和 `Conditions`，如果配置错误可能会导致错误。

<a id="generate-a-saml-response"></a>

### 生成 SAML 响应

在尝试使用身份提供商登录时，可使用 SAML 响应预览断言列表中发送的属性名称和值。

要生成 SAML 响应：

1. 安装一个[浏览器调试工具](#saml-debugging-tools)。
1. 打开一个新的浏览器标签页。
1. 打开 SAML tracer 控制台：
   - Chrome：在页面上的上下文菜单中，选择 **Inspect**，然后在开发者控制台中选择 **SAML** 选项卡。
   - Firefox：选择浏览器工具栏上的 SAML-tracer 图标。
1. 对于 JihuLab.com 群组：
   - 转到该群组的极狐GitLab 单点登录 URL。
   - 选择 **Authorize** 或尝试登录。
1. 对于极狐GitLab 私有化部署实例：
   - 转到实例主页。
   - 选择 `SAML Login` 按钮以登录。
1. tracer 控制台中会显示一个 SAML 响应，类似于此
   [SAML 响应示例](_index.md#example-saml-response)。
1. 在 SAML tracer 中，选择 **Export** 图标，以 JSON 格式保存该响应。

<a id="manually-generate-a-saml-response"></a>

#### 手动生成 SAML 响应

无论您使用哪种浏览器，过程都大致如下：

1. 在新的浏览器中右键单击，然后选择 **Inspect** 打开 **DevTools** 窗口。
1. 选择 **Network** 选项卡。确保已选中 **Preserve log**。
1. 切换到浏览器页面，使用 SAML SSO 登录极狐GitLab。
1. 切换回 **DevTools** 窗口，并筛选 `callback` 事件。
1. 选择该 callback 事件的 **Payload** 选项卡，右键单击以复制该值。
1. 将此值粘贴到以下命令中：`echo "<value>" | base64 --decode > saml_response.xml`。
1. 在代码编辑器中打开 `saml_response.xml`。

   如果您的代码编辑器中安装了 XML“美化”工具，您应该能够自动
   格式化该响应，使其更易于阅读。

<a id="search-rails-logs-for-a-saml-sign-in"></a>

## 在 Rails 日志中搜索 SAML 登录

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以在 [`audit_json.log` 文件](../../../administration/logs/_index.md#audit_jsonlog)中找到有关 SAML 登录的详细信息。

例如，通过搜索 `system_access`，您可以找到显示用户何时使用 SAML 登录极狐GitLab 的条目：

```json
{
  "severity": "INFO",
  "time": "2024-08-13T06:05:35.721Z",
  "correlation_id": "01J555EZK136DQ8S7P32G9GEND",
  "meta.caller_id": "OmniauthCallbacksController#saml",
  "meta.remote_ip": "45.87.213.198",
  "meta.feature_category": "system_access",
  "meta.user": "bbtest",
  "meta.user_id": 16,
  "meta.client_id": "user/16",
  "author_id": 16,
  "author_name": "bbtest@agounder.onmicrosoft.com",
  "entity_id": 16,
  "entity_type": "User",
  "created_at": "2024-08-13T06:05:35.708+00:00",
  "ip_address": "45.87.213.198",
  "with": "saml",
  "target_id": 16,
  "target_type": "User",
  "target_details": "bbtest@agounder.onmicrosoft.com",
  "entity_path": "bbtest"
}
```

如果您配置了 SAML 群组链接，日志还会显示详细说明成员资格被移除的条目：

```json
{
  "severity": "INFO",
  "time": "2024-08-13T05:24:07.769Z",
  "correlation_id": "01J55330SRTKTD5CHMS96DNZEN",
  "meta.caller_id": "Auth::SamlGroupSyncWorker",
  "meta.remote_ip": "45.87.213.206",
  "meta.feature_category": "system_access",
  "meta.client_id": "ip/45.87.213.206",
  "meta.root_caller_id": "OmniauthCallbacksController#saml",
  "id": 179,
  "author_id": 6,
  "entity_id": 2,
  "entity_type": "Group",
  "details": {
    "remove": "user_access",
    "member_id": 7,
    "author_name": "BB Test",
    "author_class": "User",
    "target_id": 6,
    "target_type": "User",
    "target_details": "BB Test",
    "custom_message": "Membership destroyed",
    "ip_address": "45.87.213.198",
    "entity_path": "group1"
  }
}
```

您还可以在 `auth_json.log`中查看极狐GitLab 从 SAML 提供商处收到的用户详细信息，例如：

```json
{
  "severity": "INFO",
  "time": "2024-08-20T07:01:20.979Z",
  "correlation_id": "01J5Q9E59X4P40ZT3MCE35C2A9",
  "meta.caller_id": "OmniauthCallbacksController#saml",
  "meta.remote_ip": "xxx.xxx.xxx.xxx",
  "meta.feature_category": "system_access",
  "meta.client_id": "ip/xxx.xxx.xxx.xxx",
  "payload_type": "saml_response",
  "saml_response": {
    "issuer": [
      "https://sts.windows.net/03b8c6c5-104b-43e2-aed3-abb07df387cc/"
    ],
    "name_id": "ab260d59-0317-47f5-9afb-885c7a1257ab",
    "name_id_format": "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
    "name_id_spnamequalifier": null,
    "name_id_namequalifier": null,
    "destination": "https://dh-gitlab.agounder.com/users/auth/saml/callback",
    "audiences": [
      "https://dh-gitlab.agounder.com/16.11.6"
    ],
    "attributes": {
      "http://schemas.microsoft.com/identity/claims/tenantid": [
        "03b8c6c5-104b-43e2-aed3-abb07df387cc"
      ],
      "http://schemas.microsoft.com/identity/claims/objectidentifier": [
        "ab260d59-0317-47f5-9afb-885c7a1257ab"
      ],
      "http://schemas.microsoft.com/identity/claims/identityprovider": [
        "https://sts.windows.net/03b8c6c5-104b-43e2-aed3-abb07df387cc/"
      ],
      "http://schemas.microsoft.com/claims/authnmethodsreferences": [
        "http://schemas.microsoft.com/ws/2008/06/identity/authenticationmethod/password"
      ],
      "email": [
        "bbtest@agounder.com"
      ],
      "firstname": [
        "BB"
      ],
      "name": [
        "bbtest@agounder.onmicrosoft.com"
      ],
      "lastname": [
        "Test"
      ]
    },
    "in_response_to": "_f8863f68-b5f1-43f0-9534-e73933e6ed39",
    "allowed_clock_drift": 2.220446049250313e-16,
    "success": true,
    "status_code": "urn:oasis:names:tc:SAML:2.0:status:Success",
    "status_message": null,
    "session_index": "_b4f253e2-aa61-46a4-902b-43592fe30800",
    "assertion_encrypted": false,
    "response_id": "_392cc747-7c8b-41de-8be0-23f5590d5ded",
    "assertion_id": "_b4f253e2-aa61-46a4-902b-43592fe30800"
  }
}
```

<a id="testing-gitlab-saml"></a>

## 测试极狐GitLab SAML

您可以使用以下任一方式来排查 SAML 问题：

- 使用 Docker compose 搭建的[完整的极狐GitLab SAML 测试环境](https://gitlab.com/gitlab-com/support/toolbox/replication/-/tree/main/compose_files)。
- 如果您只需要一个 SAML 提供商，可使用[启动 Docker 容器的快速入门指南](../../../administration/troubleshooting/test_environments.md#saml)，
  其中包含即插即用的 SAML 2.0 身份提供商。
- 通过[在极狐GitLab 私有化部署实例上为群组启用 SAML](../../../integration/saml.md#configure-group-saml-sso-on-gitlab-self-managed) 搭建本地环境。

<a id="verify-configuration"></a>

## 验证配置

为方便起见，此处包含极狐GitLab 支持团队使用的一些[示例资源](example_saml_config.md)。虽然它们可能有助于您验证 SAML 应用配置，但无法保证它们能反映第三方产品的当前状态。

<a id="calculate-the-fingerprint"></a>

### 计算指纹

配置 `idp_cert_fingerprint` 时，应尽可能使用 SHA256 指纹。也支持 SHA1，但不推荐。要计算指纹，请在证书文件上运行以下命令：

```shell
openssl x509 -in <certificate.crt> -noout -fingerprint -sha256
```

将`<certificate.crt>`替换为证书文件的名称。

> [!note]
> 在极狐GitLab 17.11 及更高版本中，指纹算法会根据指纹长度
> [自动检测](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/184530)。
>
> 在极狐GitLab 17.10 及更早版本中，SHA1 是默认的指纹算法。
> 要使用 SHA256 指纹，您必须指定该算法：
>
> ```ruby
> idp_cert_fingerprint_algorithm: "http://www.w3.org/2001/04/xmlenc#sha256"
> ```

<a id="sso-certificate-updates"></a>

## SSO 证书更新

当用于您的身份提供商的证书发生变化时（例如更新或续订证书时），您也必须更新证书指纹。您可以在身份提供商的 UI 中找到证书指纹。如果您无法在身份提供商 UI 中获取证书，请按照[计算指纹](#calculate-the-fingerprint)文档中的步骤操作。

<a id="configuration-errors"></a>

## 配置错误

<a id="invalid-audience"></a>

### 无效的受众

此错误表示身份提供商不将极狐GitLab 识别为 SAML 请求的有效发送方和接收方。请确保：

- 将极狐GitLab 回调 URL 添加到身份提供商服务器批准的受众中。
- 避免 `issuer` 字符串中出现尾随空格。

<a id="key-validation-error-digest-mismatch-or-fingerprint-mismatch"></a>

### 密钥验证错误、摘要不匹配或指纹不匹配

这些错误都源自同一个地方，即 SAML 证书。SAML 请求必须使用指纹、证书或验证器进行验证。

针对此要求，请务必考虑以下事项：

- 如果您使用指纹，请确认您的 SHA256 指纹：
  1. 重新下载证书文件。
  1. [计算指纹](#calculate-the-fingerprint)。
  1. 将指纹与 `idp_cert_fingerprint`中提供的值进行比较。这两个值应相同。
- 如果设置中未提供证书，则需要提供指纹或指纹
  验证器，并且来自服务器的响应必须包含
  证书（`<ds:KeyInfo><ds:X509Data><ds:X509Certificate>`）。
- 如果设置中提供了证书，则请求不再需要
  包含证书。在这种情况下，指纹或指纹
  验证器是可选的。

如果上述场景均不适用，请求会以所提到的错误之一失败。

<a id="missing-claims-or-email-cant-be-blank-errors"></a>

### 缺少声明，或 `Email can't be blank` 错误

身份提供商服务器需要传递特定信息，以便极狐GitLab 创建账号，或将登录信息与现有账号匹配。`email` 是需要传递的最少信息。如果身份提供商服务器未提供此信息，所有 SAML 请求都会失败。

请确保提供了此信息。

可能导致此错误的另一个问题是，身份提供商发送了正确的信息，但属性与 OmniAuth `info` 哈希中的名称不匹配。在这种情况下，您必须在 SAML 配置中设置 `attribute_statements`，以[将 SAML 响应中的属性名称映射到相应的 OmniAuth `info` 哈希名称](../../../integration/saml.md#map-saml-response-attribute-names)。

<a id="saml-group-links-exist-but-no-memberships-change"></a>

### SAML 群组链接存在但成员资格未发生变化

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可能配置了 SAML 群组链接，并确认 SAML 响应携带了预期的群组，但未添加或移除任何成员资格。用户能够成功登录，登录过程和日志均未报告错误。

当极狐GitLab 无法为对用户进行身份验证的提供商解析出 `groups_attribute` 值时，就会出现此问题。一个常见原因是将 `groups_attribute` 放在了提供商的 `args` 哈希内部，而不是放在提供商级别，与 `name` 和 `label` 同级。当无法解析出任何值时，群组同步不会运行，也不会报告任何内容。

要解决此问题：

1. 将 `groups_attribute` 移到配置的提供商级别。有关示例，请参阅
   [配置 SAML 群组同步](group_sync.md#configure-saml-group-sync)。
1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 再次登录。
1. 在 `audit_json.log`中搜索包含`"meta.caller_id": "Auth::SamlGroupSyncWorker"`的条目。
   群组同步在更改成员资格时会写入这些条目。
   如果在一次本应更改成员资格的登录之后没有这些条目，则说明群组同步
   未运行。

<a id="user-sign-in-banner-error-messages"></a>

## 用户登录横幅错误消息

<a id="message-saml-authentication-failed-saml-nameid-is-missing-from-your-saml-response"></a>

### 消息：`SAML authentication failed: SAML NameID is missing from your SAML response.`

您可能会收到一条错误，内容为 `SAML authentication failed: SAML NameID is missing from your SAML response. Please contact your administrator.`

当您尝试使用群组 SSO 登录极狐GitLab，但您的 SAML 响应中未包含 `NameID` 时，就会出现此问题。

要解决此问题：

- 联系您的管理员，确保您的 IdP 账号已分配 `NameID`。
- 使用 [SAML 调试工具](#saml-debugging-tools)验证您的 SAML 响应具有有效的 `NameID`。

<a id="message-saml-authentication-failed-extern-uid-has-already-been-taken"></a>

### 消息：`SAML authentication failed: Extern uid has already been taken.`

您可能会收到一条错误，内容为 `SAML authentication failed: Extern uid has already been taken. Please contact your administrator to generate a unique external_uid (NameID).`

当您尝试使用群组 SSO 将现有极狐GitLab 账号关联到 SAML 身份，但已存在一个使用您当前 `NameID`的极狐GitLab 账号时，就会出现此问题。

要解决此问题，请告知您的管理员为您的 IdP 账号重新生成唯一的 `Extern UID`（`NameID`）。确保这个新的 `Extern UID` 符合 [极狐GitLab `NameID` 约束](_index.md#manage-user-saml-identity)。

如果您不希望将该极狐GitLab 用户用于 SAML 登录，可以[将极狐GitLab 账号与 SAML 应用解除关联](_index.md#unlink-accounts)。

<a id="message-saml-authentication-failed-user-has-already-been-taken"></a>

### 消息：`SAML authentication failed: User has already been taken`

您用于登录的用户已将 SAML 关联到其他身份，或者 `NameID` 值已更改。以下是可能的原因和解决方案：

| 原因                                                                                          | 解决方案 |
|------------------------------------------------------------------------------------------------|----------|
| 您尝试为给定的身份提供商将多个 SAML 身份关联到同一用户。 | 更改您用于登录的身份。为此，请在再次尝试登录之前，[解除先前 SAML 身份](_index.md#unlink-accounts)与此极狐GitLab 账号的关联。 |
| 每次用户请求 SSO 身份验证时 `NameID` 都会变化                           | [检查 `NameID`](#verify-nameid) 是否未设置为 `Transient` 格式，或者 `NameID` 在后续请求中是否未发生变化。 |

<a id="message-saml-authentication-failed-email-has-already-been-taken"></a>

### 消息：`SAML authentication failed: Email has already been taken`

| 原因                                                                                                                | 解决方案 |
|----------------------------------------------------------------------------------------------------------------------|----------|
| 如果存在使用相同电子邮件地址的极狐GitLab 用户账号，但该账号未与 SAML 身份关联。 | 在 JihuLab.com 上，用户需要[关联其账号](_index.md#user-access-and-management)。在极狐GitLab 私有化部署上，管理员可以配置实例，使其在用户首次登录时[自动将 SAML 身份与极狐GitLab 用户账号关联](../../../integration/saml.md#link-saml-identity-for-an-existing-user)。 |

用户账号通过以下方式之一创建：

- 用户注册
- 通过 OAuth 登录
- 通过 SAML 登录
- SCIM 预配

<a id="error-user-has-already-been-taken"></a>

### 错误：用户已被占用

同时出现以下两个错误，说明身份提供商提供的 `NameID` 大小写与该用户先前的值不完全匹配：

- `SAML authentication failed: Extern UID has already been taken`
- `User has already been taken`

可以通过将 `NameID` 配置为返回一致的值来避免此问题。为单个用户修复此问题需要更改该用户的标识符。对于 JihuLab.com，用户需要[将其 SAML 与极狐GitLab 账号解除关联](_index.md#unlink-accounts)。

<a id="message-request-to-link-saml-account-must-be-authorized"></a>

### 消息：`Request to link SAML account must be authorized`

确保尝试关联其极狐GitLab 账号的用户已作为用户添加到身份提供商的 SAML 应用中。

或者，SAML 响应可能在 `samlp:Response` 标签中缺少 `InResponseTo` 属性，而这是 [SAML gem 所期望的](https://github.com/onelogin/ruby-saml/blob/9f710c5028b069bfab4b9e2b66891e0549765af5/lib/onelogin/ruby-saml/response.rb#L307-L316)。身份提供商管理员应确保登录由服务提供商发起，而不仅仅由身份提供商发起。

<a id="message-there-is-already-a-gitlab-account-associated-with-this-email-address"></a>

### 消息：`There is already a GitLab account associated with this email address.`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

当用户尝试[手动将 SAML 关联到其现有 JihuLab.com 账号](_index.md#link-saml-to-your-existing-gitlabcom-account)时，可能会看到此消息：

```plaintext
There is already a GitLab account associated with this email address.
Sign in with your existing credentials to connect your organization's account
```

要解决此问题，用户应检查其是否使用了正确的极狐GitLab 密码登录。如果满足以下两个条件，用户首先需要[重置密码](https://jihulab.com/users/password/new)：

- 该账号由 SCIM 预配。
- 他们是首次使用用户名和密码登录。

<a id="message-saml-name-id-and-email-address-do-not-match-your-user-account"></a>

### 消息：`SAML Name ID and email address do not match your user account`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

用户可能会收到一条错误，内容为“SAML Name ID and email address do not match your user account. Contact an administrator.”
这意味着：

- SAML 发送的 NameID 值与现有 SAML 身份的 `extern_uid` 值不匹配。NameID 和 `extern_uid` 都区分大小写。有关更多信息，请参阅[管理用户 SAML 身份](_index.md#manage-user-saml-identity)。
- SAML 响应中未包含电子邮件地址，或者该电子邮件地址与用户的极狐GitLab 电子邮件地址不匹配。

变通方法是，极狐GitLab 群组所有者使用 [SAML API](../../../api/saml.md) 更新用户的 SAML `extern_uid`。`extern_uid` 值必须与 SAML 身份提供商（IdP）发送的 Name ID 值匹配。根据 IdP 配置，这可能是生成的唯一 ID、电子邮件地址或其他值。

<a id="error-certificate-element-missing-in-response-dsx509certificate"></a>

### 错误：`Certificate element missing in response (ds:x509certificate)`

此错误表明 IdP 未配置为在 SAML 响应中包含 X.509 证书：

```plaintext
Certificate element missing in response (ds:x509certificate) and not cert provided at settings
```

响应中必须包含 X.509 证书。要解决此问题，请将您的 IdP 配置为在 SAML 响应中包含 X.509 证书。

有关更多信息，请参阅[在 IdP 上为 SAML 应用进行额外配置](../../../integration/saml.md#additional-configuration-for-saml-apps-on-your-idp)的文档。

<a id="other-user-sign-in-issues"></a>

## 其他用户登录问题

<a id="verify-nameid"></a>

### 验证 `NameID`

在故障排除时，任何已通过身份验证的用户都可以使用 API 来验证极狐GitLab 已关联到其用户的 `NameID`，方法是访问 <https://jihulab.com/api/v4/user> 并查看 identities 下的 `extern_uid`。

对于极狐GitLab 私有化部署，管理员可以使用[用户 API](../../../api/users.md) 查看相同的信息。

对群组使用 SAML 时，具有适当权限角色的群组成员可以使用[成员 API](../../../api/group_members.md) 查看群组成员的群组 SAML 身份信息。

然后，可以使用 [SAML 调试工具](#saml-debugging-tools)解码消息，将其与身份提供商发送的 `NameID` 进行比较。这些值必须匹配才能识别用户。

<a id="stuck-in-a-login-loop"></a>

### 卡在登录“循环”中

确保**极狐GitLab 单点登录 URL**（对于 JihuLab.com）或实例 URL（对于极狐GitLab 私有化部署）已在身份提供商的 SAML 应用中配置为“Login URL”（或类似名称的字段）。

对于 JihuLab.com，或者，当用户需要[将 SAML 关联到其现有 JihuLab.com 账号](_index.md#link-saml-to-your-existing-gitlabcom-account)时，请提供**极狐GitLab 单点登录 URL**，并指示用户在首次登录时不要使用 SAML 应用。

<a id="users-receive-a-404"></a>

### 用户收到 404

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果用户在成功登录后收到 `404`，请检查您是否配置了 IP 限制。IP 限制设置配置在：

- 在 JihuLab.com 上，[在群组级别](../access_and_permissions.md#restrict-group-access-by-ip-address)。
- 对于极狐GitLab 私有化部署，[在实例级别](../../../administration/reporting/ip_addr_restrictions.md)。

由于群组的 SAML SSO 是付费功能，您的订阅到期可能会导致在 JihuLab.com 上使用 SAML SSO 登录时出现 `404` 错误。如果所有用户在尝试使用 SAML 登录时都收到 `404`，请确认此 SAML SSO 命名空间中使用的是[有效订阅](../../../subscriptions/manage_subscription.md#view-subscription)。

如果您在使用“验证配置”进行设置期间收到 `404`，请确保您使用了正确的 [SHA-1 生成的指纹](../../../integration/saml.md#configure-saml-on-your-idp)。

如果用户尝试首次登录，而极狐GitLab 单点登录 URL 尚未[配置](_index.md#set-up-your-identity-provider)，他们可能会看到 404。如[用户访问部分](_index.md#link-saml-to-your-existing-gitlabcom-account)所述，群组所有者需要向用户提供该 URL。

如果顶级群组[按电子邮件域限制了成员资格](../access_and_permissions.md#restrict-group-access-by-domain)，而电子邮件域不被允许的用户尝试使用 SSO 登录，该用户可能会收到 404。用户可能有多个账号，其 SAML 身份可能关联到其个人账号，而该账号的电子邮件地址与公司域不同。要检查这一点，请验证以下内容：

- 顶级群组已按电子邮件域限制成员资格。
- 在顶级群组的[审计事件](../../../administration/compliance/audit_event_reports.md)中：
  - 您可以看到该用户的 **使用 GROUP_SAML 认证登录** 操作。
  - 通过选择 **作者** 名称，确认该用户的用户名与您为 SAML SSO 配置的用户名相同。
    - 如果用户名与您为 SAML SSO 配置的用户名不同，请让该用户从其个人账号[解除 SAML 身份关联](_index.md#unlink-accounts)。

如果所有用户在登录身份提供商（IdP）后都收到 `404`：

- 验证 `assertion_consumer_service_url`：
  - 在极狐GitLab 配置中，[将其与极狐GitLab 的 HTTPS 端点匹配](../../../integration/saml.md#configure-saml-support-in-gitlab)。
  - 在您的 IdP 上设置 SAML 应用时，将其作为 `Assertion Consumer Service URL` 或等效项。
- 验证 `404` 是否与[用户在其 Azure IdP 中分配了过多群组](group_sync.md#microsoft-azure-active-directory-integration)有关。
- 验证 IdP 服务器和极狐GitLab 上的时钟是否同步到相同时间。

如果部分用户在登录 IdP 后收到 `404` 错误，请先验证如果用户被添加到群组后立即被移除，会返回哪些审计事件。或者，如果用户能够成功登录，但未显示为[顶级群组的成员](../_index.md#search-a-group)：

- 确保该用户已[添加到 SAML 身份提供商](_index.md#user-access-and-management)，并且如果配置了 [SCIM](scim_setup.md)，也已添加到 SCIM。
- 使用 [SCIM API](../../../api/scim.md) 确保该用户的 SCIM 身份的 `active` 属性为 `true`。
  如果 `active` 属性为 `false`，您可以执行以下任一操作，以尝试解决该问题：

  - 在 SCIM 身份提供商中为该用户触发同步。例如，Azure 有一个“Provision on demand”选项。
  - 在 SCIM 身份提供商中移除并重新添加该用户。
  - 让该用户尽可能[解除其账号关联](_index.md#unlink-accounts)，然后[关联其账号](_index.md#link-saml-to-your-existing-gitlabcom-account)。
  - 使用[内部 SCIM API](../../../development/internal_api/_index.md#update-a-single-scim-provisioned-user)，通过您群组的 SCIM 令牌更新该用户的 SCIM 身份。
    如果您不知道群组的 SCIM 令牌，请重置该令牌，并使用新令牌更新 SCIM 身份提供商应用。
    请求示例：

    ```plaintext
    curl --request PATCH "https://gitlab.example.com/api/scim/v2/groups/test_group/Users/f0b1d561c-21ff-4092-beab-8154b17f82f2" --header "Authorization: Bearer <SCIM_TOKEN>" --header "Content-Type: application/scim+json" --data '{ "Operations": [{"op":"Replace","path":"active","value":"true"}] }'
    ```

<a id="500-error-after-login"></a>

### 登录后出现 500 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您在从 SAML 登录页面重定向回极狐GitLab 时看到“500 错误”，这可能表明：

- 极狐GitLab 无法获取 SAML 用户的电子邮件地址。确保身份提供商使用声明名称 `email` 或 `mail` 提供包含用户
  电子邮件地址的声明。
- 您在 `gitlab.rb` 文件中为 `identity provider_cert_fingerprint` 或 `identity provider_cert` 文件设置的证书不正确。
- 您的 `gitlab.rb` 文件设置为启用 `identity provider_cert_fingerprint`，同时提供了 `identity provider_cert`，或者相反。

<a id="422-error-after-login"></a>

### 登录后出现 422 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您在从 SAML 登录页面重定向回极狐GitLab 时看到“422 错误”，可能是您在身份提供商上配置的 Assertion Consumer
Service (ACS) URL 不正确。

确保 ACS URL 指向 `https://gitlab.example.com/users/auth/saml/callback`，其中
`gitlab.example.com` 是您的极狐GitLab 实例的 URL。

如果 ACS URL 正确，但您仍然遇到错误，请查看其他故障排除部分。

<a id="422-error-with-non-allowed-email"></a>

#### 电子邮件不被允许时出现 422 错误

您可能会收到一条 422 错误，内容为“Email is not allowed. Please use your regular email address.”

此消息可能表明您必须在域允许名单或拒绝名单设置中添加或移除某个域。

先决条件：

- 管理员访问权限。

要实施此变通方法：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **新用户账户限制**。
1. 根据情况在 **允许新用户的域名** 和 **拒绝新用户的域名**中添加或移除某个域。
1. 选择 **保存更改**。

<a id="user-is-blocked-when-signing-in-through-saml"></a>

### 通过 SAML 登录时用户被阻止

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下是用户通过 SAML 登录时被阻止的最可能原因：

- 在配置中设置了 `gitlab_rails['omniauth_block_auto_created_users'] = true`，并且这是该用户首次登录。
- 配置了 [`required_groups`](../../../integration/saml.md#required-groups)，但该用户不是其中任何一个的成员。

<a id="google-workspace-troubleshooting-tips"></a>

## Google Workspace 故障排除提示

如果您在登录时看到来自 Google 的错误，Google Workspace 关于 [SAML 应用错误消息](https://support.google.com/a/answer/6301076?hl=en)的文档对调试很有帮助。请特别注意以下 403 错误：

- `app_not_configured`
- `app_not_configured_for_user`

<a id="message-the-members-email-address-is-not-linked-to-a-saml-account"></a>

## 消息：`The member's email address is not linked to a SAML account`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

当您尝试邀请用户加入已启用 [SAML SSO 强制](_index.md#sso-enforcement)的 JihuLab.com 群组（或子群组，或群组内的项目）时，会出现此错误。

如果您在尝试邀请用户加入群组后看到此消息：

1. 确保该用户已[添加到 SAML 身份提供商](_index.md#user-access-and-management)。
1. 如果该用户已有 JihuLab.com 账号，请让其[将 SAML 关联到其现有 JihuLab.com 账号](_index.md#link-saml-to-your-existing-gitlabcom-account)。否则，请让该用户通过[身份提供商的仪表板访问 JihuLab.com](_index.md#user-access-and-management) 来创建 JihuLab.com 账号，或者[手动注册](https://jihulab.com/users/sign_up)并将 SAML 关联到其新账号。
1. 确保该用户是[顶级群组的成员](../_index.md#search-a-group)。

此外，请参阅[登录后收到 404 的用户故障排除](#users-receive-a-404)。

<a id="message-the-saml-response-did-not-contain-an-email-address"></a>

## 消息：`The SAML response did not contain an email address.`

如果您看到此错误：

```plaintext
The SAML response did not contain an email address.
Either the SAML identity provider is not configured to send the attribute, or the
identity provider directory does not have an email address value for your user
```

此错误出现在以下情况：

- SAML 响应未在 **email** 或 **mail** 属性中包含用户的电子邮件地址。
- 用户尝试[将 SAML 关联](_index.md#user-access-and-management)到其账号，但尚未完成[身份验证流程](../../../security/identity_verification.md)。

确保 SAML 身份提供商配置为发送[受支持的邮件属性](../../../integration/saml.md)：

```xml
<Attribute Name="email">
  <AttributeValue>user@example.com</AttributeValue>
</Attribute>
```

默认支持以 `http://schemas.xmlsoap.org/ws/2005/05/identity/claims` 和 `http://schemas.microsoft.com/ws/2008/06/identity/claims/`等短语开头的属性名称。

```xml
<Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/emailaddress">
  <AttributeValue>user@example.com</AttributeValue>
</Attribute>
```

<a id="cannot-add-service-accounts-with-global-saml-group-memberships-lock"></a>

## 启用全局 SAML 群组成员资格锁定时无法添加服务账号

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

如果启用了[全局 SAML 群组成员资格锁定](group_sync.md#global-saml-group-memberships-lock)，则只有管理员可以通过 UI 管理群组成员和服务账号。如果群组所有者需要管理服务账号，可以改用[群组成员 API](../../../api/group_members.md)。

<a id="support-knowledge-base"></a>

## 支持知识库

如果您仍然遇到问题，请参阅[极狐GitLab 支持知识库](https://gitlab.cn/support)。
