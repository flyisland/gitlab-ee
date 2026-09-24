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

本页面包含使用以下功能时可能遇到的问题的解决方案：

- [JihuLab.com 群组的 SAML SSO](_index.md)。
- 极狐GitLab 私有化部署实例级 [SAML OmniAuth 提供程序](../../../integration/saml.md)。

## SAML 调试工具

SAML 响应是 base64 编码的。你可以使用 **SAML-tracer** 浏览器扩展（[Firefox](https://addons.mozilla.org/en-US/firefox/addon/saml-tracer/)、[Chrome](https://chromewebstore.google.com/detail/saml-tracer/mpdajninpobndbfcldcmbpnnbhibjmch?hl=en)）即时解码。

如果你无法安装浏览器插件，可以改为[手动生成并捕获 SAML 响应](#手动生成-saml-响应)。

请特别关注：

- `NameID`，用于标识登录用户。如果用户之前已登录，此值必须与[极狐GitLab 存储的值](#验证-nameid)匹配。
- 是否存在 `X509Certificate`，这是验证响应签名所必需的。
- `SubjectConfirmation` 和 `Conditions`，如果配置错误可能导致错误。

### 生成 SAML 响应

在尝试使用身份提供程序登录时，使用 SAML 响应预览断言列表中发送的属性名称和值。

生成 SAML 响应：

1. 安装一种[浏览器调试工具](#saml-调试工具)。
1. 打开一个新的浏览器标签页。
1. 打开 SAML tracer 控制台：
   - Chrome：在页面上下文菜单中，选择 **Inspect**，然后在开发者控制台中选择 **SAML** 标签页。
   - Firefox：选择浏览器工具栏上的 SAML-tracer 图标。
1. 对于 JihuLab.com 群组：
   - 前往群组的极狐GitLab 单点登录 URL。
   - 选择 **Authorize** 或尝试登录。
1. 对于极狐GitLab 私有化部署实例：
   - 前往实例首页。
   - 选择 `SAML Login` 按钮登录。
1. SAML 响应会显示在 tracer 控制台中，类似于这个[示例 SAML 响应](_index.md#示例-saml-响应)。
1. 在 SAML tracer 中，选择 **Export** 图标将响应保存为 JSON 格式。

#### 手动生成 SAML 响应

无论使用哪种浏览器，过程都类似于以下步骤：

1. 在新浏览器中右键单击，选择 **Inspect** 打开 **DevTools** 窗口。
1. 选择 **Network** 标签页。确保选中 **Preserve log**。
1. 切换到浏览器页面，使用 SAML SSO 登录极狐GitLab。
1. 切换回 **DevTools** 窗口，过滤 `callback` 事件。
1. 选择 callback 事件的 **Payload** 标签页，右键复制值。
1. 将此值粘贴到以下命令中：`echo "<value>" | base64 --decode > saml_response.xml`。
1. 在代码编辑器中打开 `saml_response.xml`。

   如果你的代码编辑器中安装了 XML "美化器"，你应该能够自动格式化响应，使其更易于阅读。

## 在 Rails 日志中搜索 SAML 登录

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以在 [`audit_json.log` 文件](../../../administration/logs/_index.md#audit_jsonlog)中找到有关 SAML 登录的详细信息。

例如，通过搜索 `system_access`，你可以找到显示用户何时使用 SAML 登录极狐GitLab 的条目：

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

如果你配置了 SAML 群组链接，日志还会显示详细说明成员资格被移除的条目：

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

你还可以在 `auth_json.log` 中查看极狐GitLab 从 SAML 提供程序收到的用户详细信息，例如：

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

## 测试极狐GitLab SAML

你可以使用以下方法之一排查 SAML 问题：

- 使用 Docker compose 的[完整极狐GitLab SAML 测试环境](https://gitlab.com/gitlab-com/support/toolbox/replication/tree/master/compose_files)。
- 如果你只需要一个 SAML 提供程序，可以使用[快速入门指南启动一个 Docker 容器](../../../administration/troubleshooting/test_environments.md#saml)，其中包含即插即用的 SAML 2.0 身份提供程序。
- 通过在[极狐GitLab 私有化部署实例上为群组启用 SAML](../../../integration/saml.md#configure-group-saml-sso-on-gitlab-self-managed)来搭建本地环境。

## 验证配置

为方便起见，这里包含了极狐GitLab 支持团队使用的一些[示例资源](example_saml_config.md)。虽然它们可能有助于验证 SAML 应用配置，但不能保证反映第三方产品的当前状态。

### 计算指纹

配置 `idp_cert_fingerprint` 时，应尽可能使用 SHA256 指纹。也支持 SHA1，但不推荐。要计算指纹，请在证书文件上运行以下命令：

```shell
openssl x509 -in <certificate.crt> -noout -fingerprint -sha256
```

将 `<certificate.crt>` 替换为证书文件名。

> [!note]
> 在极狐GitLab 17.11 及更高版本中，指纹算法会[根据指纹长度自动检测](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/184530)。
>
> 在极狐GitLab 17.10 及更早版本中，SHA1 是默认的指纹算法。
> 要使用 SHA256 指纹，你必须指定算法：
>
> ```ruby
> idp_cert_fingerprint_algorithm: "http://www.w3.org/2001/04/xmlenc#sha256"
> ```

## SSO 证书更新

当你的身份提供程序使用的证书发生变化时（例如更新或续订证书），你还必须更新证书指纹。你可以在身份提供程序的 UI 中找到证书指纹。如果无法在身份提供程序 UI 中获取证书，请按照[计算指纹](#计算指纹)文档中的步骤操作。

## 配置错误

### 无效的受众

此错误表示身份提供程序不将极狐GitLab 识别为有效的 SAML 请求发送方和接收方。请确保：

- 将极狐GitLab 回调 URL 添加到身份提供程序服务器的已批准受众中。
- 避免 `issuer` 字符串中有尾随空格。

### 密钥验证错误、摘要不匹配或指纹不匹配

这些错误都源于类似的问题，即 SAML 证书。SAML 请求必须使用指纹、证书或验证器进行验证。

为此，请务必考虑以下事项：

- 如果你使用指纹，请确认你的 SHA256 指纹：
  1. 重新下载证书文件。
  1. [计算指纹](#计算指纹)。
  1. 将指纹与 `idp_cert_fingerprint` 中提供的值进行比较。这些值应该相同。
- 如果设置中未提供证书，则需要提供指纹或指纹验证器，并且服务器的响应必须包含证书（`<ds:KeyInfo><ds:X509Data><ds:X509Certificate>`）。
- 如果设置中提供了证书，则请求中不再需要包含证书。在这种情况下，指纹或指纹验证器是可选的。

如果上述情况均不成立，请求将失败并显示上述错误之一。

### 缺少声明，或 `邮箱不能为空` 错误

身份提供程序服务器需要传递某些信息，以便极狐GitLab 创建账户或将登录信息与现有账户匹配。`email` 是需要传递的最基本信息。如果身份提供程序服务器未提供此信息，所有 SAML 请求都会失败。

请确保提供此信息。

导致此错误的另一个问题是，身份提供程序发送了正确的信息，但属性与 OmniAuth `info` 哈希中的名称不匹配。在这种情况下，你必须在 SAML 配置中设置 `attribute_statements`，以[将 SAML 响应中的属性名称映射到相应的 OmniAuth `info` 哈希名称](../../../integration/saml.md#map-saml-response-attribute-names)。

## 用户登录横幅错误消息

### 消息：`SAML 认证失败：SAML 响应中缺少 SAML NameID。`

你可能会收到错误消息：`SAML 认证失败：SAML 响应中缺少 SAML NameID。请联系你的管理员。`

当你尝试使用群组 SSO 登录极狐GitLab，但你的 SAML 响应未包含 `NameID` 时，会出现此问题。

要解决此问题：

- 联系你的管理员，确保你的 IdP 账户已分配 `NameID`。
- 使用 [SAML 调试工具](#saml-调试工具)验证你的 SAML 响应是否包含有效的 `NameID`。

### 消息：`SAML 认证失败：Extern uid 已被占用。`

你可能会收到错误消息：`SAML 认证失败：Extern uid 已被占用。请联系你的管理员生成唯一的 external_uid (NameID)。`

当你尝试使用群组 SSO 将现有极狐GitLab 账户链接到 SAML 身份，但已存在具有你当前 `NameID` 的极狐GitLab 账户时，会出现此问题。

要解决此问题，请告知你的管理员为你的 IdP 账户重新生成唯一的 `Extern UID` (`NameID`)。确保此新的 `Extern UID` 符合[极狐GitLab `NameID` 约束](_index.md#管理用户-saml-身份)。

如果你不希望将该极狐GitLab 用户用于 SAML 登录，可以[取消极狐GitLab 账户与 SAML 应用的链接](_index.md#取消链接账户)。

### 消息：`SAML 认证失败：用户已被占用`

你登录的用户已将 SAML 链接到其他身份，或者 `NameID` 值已更改。
以下是可能的原因和解决方案：

| 原因 | 解决方案 |
|------|----------|
| 你尝试为同一身份提供程序将多个 SAML 身份链接到同一用户。 | 更改你登录时使用的身份。为此，在再次尝试登录之前，[取消之前 SAML 身份的链接](_index.md#取消链接账户)。 |
| 每次用户请求 SSO 标识时，`NameID` 都会更改。 | [检查 `NameID`](#验证-nameid) 是否未设置为 `Transient` 格式，或者 `NameID` 在后续请求中是否未更改。 |

### 消息：`SAML 认证失败：邮箱已被占用`

| 原因 | 解决方案 |
|------|----------|
| 如果存在具有相同电子邮件地址的极狐GitLab 用户账户，但该账户未关联 SAML 身份。 | 在 JihuLab.com 上，用户需要[链接其账户](_index.md#用户访问和管理)。在极狐GitLab 私有化部署实例上，管理员可以配置实例，在用户首次登录时[自动将 SAML 身份与极狐GitLab 用户账户链接](../../../integration/saml.md#link-saml-identity-for-an-existing-user)。 |

用户账户通过以下方式之一创建：

- 用户注册
- 通过 OAuth 登录
- 通过 SAML 登录
- SCIM 配置

### 错误：用户已被占用

同时出现以下两个错误表明身份提供程序提供的 `NameID` 大小写与该用户之前的值不完全匹配：

- `SAML 认证失败：Extern UID 已被占用`
- `用户已被占用`

可以通过配置 `NameID` 返回一致的值来防止此问题。为单个用户解决此问题需要更改该用户的标识符。对于 JihuLab.com，用户需要[取消其 SAML 与极狐GitLab 账户的链接](_index.md#取消链接账户)。

### 消息：`链接 SAML 账户的请求必须经过授权`

确保尝试链接其极狐GitLab 账户的用户已作为用户添加到身份提供程序的 SAML 应用中。

或者，SAML 响应可能缺少 `samlp:Response` 标签中的 `InResponseTo` 属性，这是 [SAML gem 所期望的](https://github.com/onelogin/ruby-saml/blob/9f710c5028b069bfab4b9e2b66891e0549765af5/lib/onelogin/ruby-saml/response.rb#L307-L316)。身份提供程序管理员应确保登录是由服务提供程序发起的，而不仅仅是身份提供程序。

### 消息：`此电子邮件地址已关联极狐GitLab 账户。`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

当用户尝试[手动将 SAML 链接到其现有的 JihuLab.com 账户](_index.md#将-saml-链接到你现有的-jihulabcom-账户)时，可能会看到此消息：

```plaintext
此电子邮件地址已关联极狐GitLab 账户。
使用你现有的凭据登录以连接你组织的账户
```

要解决此问题，用户应检查他们是否使用了正确的极狐GitLab 密码登录。如果同时满足以下条件，用户首先需要[重置密码](https://gitlab.com/users/password/new)：

- 账户是通过 SCIM 配置的。
- 他们是首次使用用户名和密码登录。

### 消息：`SAML Name ID 和电子邮件地址与你的用户账户不匹配`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

用户可能会收到错误消息：“SAML Name ID 和电子邮件地址与你的用户账户不匹配。请联系管理员。”
这意味着：

- SAML 发送的 NameID 值与现有的 SAML 身份 `extern_uid` 值不匹配。NameID 和 `extern_uid` 都区分大小写。有关更多信息，请参阅[管理用户 SAML 身份](_index.md#管理用户-saml-身份)。
- SAML 响应未包含电子邮件地址，或者电子邮件地址与用户的极狐GitLab 电子邮件地址不匹配。

解决方法是，极狐GitLab 群组所有者使用 [SAML API](../../../api/saml.md) 更新用户的 SAML `extern_uid`。
`extern_uid` 值必须与 SAML 身份提供程序 (IdP) 发送的 Name ID 值匹配。根据 IdP 配置，这可能是生成的唯一 ID、电子邮件地址或其他值。

### 错误：`响应中缺少证书元素 (ds:x509certificate)`

此错误表明 IdP 未配置为在 SAML 响应中包含 X.509 证书：

```plaintext
响应中缺少证书元素 (ds:x509certificate)，且设置中未提供证书
```

X.509 证书必须包含在响应中。
要解决此问题，请配置你的 IdP 以在 SAML 响应中包含 X.509 证书。

有关更多信息，请参阅[在 IdP 上为 SAML 应用进行额外配置](../../../integration/saml.md#additional-configuration-for-saml-apps-on-your-idp)的文档。

## 其他用户登录问题

### 验证 `NameID`

在故障排除中，任何经过身份验证的用户都可以使用 API 来验证极狐GitLab 已链接到其用户的 `NameID`，方法是访问 <https://gitlab.com/api/v4/user> 并检查身份下的 `extern_uid`。

对于极狐GitLab 私有化部署实例，管理员可以使用[用户 API](../../../api/users.md) 查看相同的信息。

当为群组使用 SAML 时，具有相应权限的群组成员可以使用[成员 API](../../../api/group_members.md) 查看群组成员的群组 SAML 身份信息。

然后，可以通过使用 [SAML 调试工具](#saml-调试工具)解码消息，将其与身份提供程序发送的 `NameID` 进行比较。这些值必须匹配才能识别用户。

### 陷入登录“循环”

确保 **极狐GitLab 单点登录 URL**（对于 JihuLab.com）或实例 URL（对于极狐GitLab 私有化部署）已在身份提供程序的 SAML 应用中配置为“登录 URL”（或类似名称的字段）。

对于 JihuLab.com，或者当用户需要[将 SAML 链接到其现有的 JihuLab.com 账户](_index.md#将-saml-链接到你现有的-jihulabcom-账户)时，请提供 **极狐GitLab 单点登录 URL**，并指示用户不要在首次登录时使用 SAML 应用。

### 用户收到 404

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果用户在成功登录后收到 `404`，请检查你是否配置了 IP 限制。IP 限制设置配置在：

- 在 JihuLab.com 上，[在群组级别](../access_and_permissions.md#restrict-group-access-by-ip-address)。
- 对于极狐GitLab 私有化部署实例，[在实例级别](../../../administration/reporting/ip_addr_restrictions.md)。

由于群组的 SAML SSO 是一项付费功能，当你在 JihuLab.com 上使用 SAML SSO 登录时，订阅过期可能会导致 `404` 错误。
如果所有用户在尝试使用 SAML 登录时都收到 `404`，请确认[此 SAML SSO 命名空间中正在使用有效的订阅](../../../subscriptions/manage_subscription.md#view-subscription)。

如果你在设置期间使用“验证配置”时收到 `404`，请确保你使用了正确的 [SHA-1 生成的指纹](../../../integration/saml.md#configure-saml-on-your-idp)。

如果用户是首次尝试登录，并且极狐GitLab 单点登录 URL 尚未[配置](_index.md#设置你的身份提供程序)，他们可能会看到 404。
如[用户访问部分](_index.md#将-saml-链接到你现有的-jihulabcom-账户)所述，群组所有者需要向用户提供 URL。

如果顶级群组已[按电子邮件域限制成员资格](../access_and_permissions.md#restrict-group-access-by-domain)，并且具有不允许的电子邮件域的用户尝试使用 SSO 登录，该用户可能会收到 404。用户可能拥有多个账户，并且他们的 SAML 身份可能链接到其个人账户，该账户的电子邮件地址与公司域不同。要检查这一点，请验证以下内容：

- 顶级群组已按电子邮件域限制成员资格。
- 在顶级群组的[审计事件](../../../administration/compliance/audit_event_reports.md)中：
  - 你可以看到该用户的 **使用 GROUP_SAML 认证登录** 操作。
  - 通过选择 **Author** 名称，确认该用户的用户名与你为 SAML SSO 配置的用户名相同。
    - 如果用户名与你为 SAML SSO 配置的用户名不同，请要求用户[取消 SAML 身份与其个人账户的链接](_index.md#取消链接账户)。

如果所有用户在登录身份提供程序 (IdP) 后都收到 `404`：

- 验证 `assertion_consumer_service_url`：
  - 在极狐GitLab 配置中，[将其与极狐GitLab 的 HTTPS 端点匹配](../../../integration/saml.md#configure-saml-support-in-gitlab)。
  - 在 IdP 上设置 SAML 应用时，作为 `Assertion Consumer Service URL` 或等效项。
- 验证 `404` 是否与[用户在 Azure IdP 中分配了过多群组](group_sync.md#microsoft-azure-active-directory-integration)有关。
- 验证 IdP 服务器和极狐GitLab 的时钟是否同步到同一时间。

如果一部分用户在登录 IdP 后收到 `404` 错误，首先验证如果用户被添加到群组然后立即被移除，会返回哪些审计事件。或者，如果用户可以成功登录，但他们未显示为[顶级群组的成员](../_index.md#搜索群组)：

- 确保用户已[添加到 SAML 身份提供程序](_index.md#用户访问和管理)，以及 [SCIM](scim_setup.md)（如果已配置）。
- 使用 [SCIM API](../../../api/scim.md) 确保用户的 SCIM 身份的 `active` 属性为 `true`。
  如果 `active` 属性为 `false`，你可以执行以下操作之一来可能解决问题：

  - 在 SCIM 身份提供程序中触发用户同步。例如，Azure 有“按需配置”选项。
  - 在 SCIM 身份提供程序中移除并重新添加用户。
  - 如果可能，让用户[取消链接其账户](_index.md#取消链接账户)，然后[链接其账户](_index.md#将-saml-链接到你现有的-jihulabcom-账户)。
  - 使用[内部 SCIM API](../../../development/internal_api/_index.md#更新单个-scim-配置用户) 使用群组的 SCIM 令牌更新用户的 SCIM 身份。
    如果你不知道群组的 SCIM 令牌，请重置令牌并使用新令牌更新 SCIM 身份提供程序应用。
    示例请求：

（待续）
```plaintext
curl --request PATCH "https://gitlab.example.com/api/scim/v2/groups/test_group/Users/f0b1d561c-21ff-4092-beab-8154b17f82f2" --header "Authorization: Bearer <SCIM_TOKEN>" --header "Content-Type: application/scim+json" --data '{ "Operations": [{"op":"Replace","path":"active","value":"true"}] }'
```

<a id="500-error-after-login"></a>

### 登录后出现 500 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你从 SAML 登录页面重定向回极狐GitLab 时看到“500 错误”，这可能表明：

- 极狐GitLab 无法获取 SAML 用户的邮箱地址。请确保身份提供程序使用 `email` 或 `mail` 属性名称提供包含用户邮箱地址的声明。
- 你在 `gitlab.rb` 文件中为 `identity provider_cert_fingerprint` 或 `identity provider_cert` 设置的证书不正确。
- 你的 `gitlab.rb` 文件设置为启用 `identity provider_cert_fingerprint`，但同时提供了 `identity provider_cert`，或者反之。

<a id="422-error-after-login"></a>

### 登录后出现 422 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你从 SAML 登录页面重定向回极狐GitLab 时看到“422 错误”，你可能在身份提供程序上配置了错误的断言消费者服务（ACS）URL。

请确保 ACS URL 指向 `https://gitlab.example.com/users/auth/saml/callback`，其中 `gitlab.example.com` 是你的极狐GitLab 实例的 URL。

如果 ACS URL 正确，但你仍然遇到错误，请查看其他故障排除部分。

<a id="422-error-with-non-allowed-email"></a>

#### 非允许邮箱导致 422 错误

你可能会收到一个 422 错误，提示“邮箱不被允许。请使用你的常规邮箱地址。”

此消息可能表明你需要从域名允许列表或拒绝列表设置中添加或移除域名。

先决条件：

- 管理员访问权限。

要实施此解决方法：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **新用户账户限制**。
1. 根据需要在 **允许新用户的域名** 和 **拒绝新用户的域名** 中添加或移除域名。
1. 选择 **保存更改**。

<a id="user-is-blocked-when-signing-in-through-saml"></a>

### 通过 SAML 登录时用户被阻止

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下是用户通过 SAML 登录时被阻止的最可能原因：

- 在配置中，设置了 `gitlab_rails['omniauth_block_auto_created_users'] = true`，并且这是该用户首次登录。
- 配置了 [`required_groups`](../../../integration/saml.md#required-groups)，但用户不是其中任何群组的成员。

<a id="google-workspace-troubleshooting-tips"></a>

## Google Workspace 故障排除提示

Google Workspace 关于 [SAML 应用错误消息](https://support.google.com/a/answer/6301076?hl=en) 的文档对于调试 Google 登录时出现的错误很有帮助。
请特别注意以下 403 错误：

- `app_not_configured`
- `app_not_configured_for_user`

<a id="message-the-members-email-address-is-not-linked-to-a-saml-account"></a>

## 消息：`成员的邮箱地址未关联 SAML 账户`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

当你尝试邀请用户加入启用了 [SAML SSO 强制执行](_index.md#sso-enforcement) 的 JihuLab.com 群组（或子群组或群组内的项目）时，会出现此错误。

如果你在尝试邀请用户加入群组后看到此消息：

1. 确保用户已 [添加到 SAML 身份提供程序](_index.md#user-access-and-management)。
1. 如果用户已有 JihuLab.com 账户，请要求用户 [将 SAML 关联到其现有 JihuLab.com 账户](_index.md#link-saml-to-your-existing-gitlabcom-account)。否则，请要求用户通过 [从身份提供程序的控制台访问 JihuLab.com](_index.md#user-access-and-management) 或 [手动注册](https://jihulab.com/users/sign_up) 并关联 SAML 到其新账户来创建 JihuLab.com 账户。
1. 确保用户是 [顶级群组的成员](../_index.md#search-a-group)。

此外，请参阅 [排查用户登录后收到 404 错误](#users-receive-a-404)。

<a id="message-the-saml-response-did-not-contain-an-email-address"></a>

## 消息：`SAML 响应未包含邮箱地址`

如果你看到此错误：

```plaintext
SAML 响应未包含邮箱地址。
可能是 SAML 身份提供程序未配置为发送该属性，或者身份提供程序目录中没有你的用户的邮箱地址值。
```

此错误出现在以下情况：

- SAML 响应在 **email** 或 **mail** 属性中未包含用户的邮箱地址。
- 用户尝试 [关联 SAML](_index.md#user-access-and-management) 到其账户，但尚未完成 [身份验证流程](../../../security/identity_verification.md)。

确保 SAML 身份提供程序配置为发送 [支持的邮件属性](../../../integration/saml.md)：

```xml
<Attribute Name="email">
  <AttributeValue>user@example.com‹/AttributeValue>
</Attribute>
```

从极狐GitLab 16.7 开始，默认支持以 `http://schemas.xmlsoap.org/ws/2005/05/identity/claims` 和 `http://schemas.microsoft.com/ws/2008/06/identity/claims/` 等短语开头的属性名称。

```xml
<Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/emailaddress">
  <AttributeValue>user@example.com‹/AttributeValue>
</Attribute>
```

<a id="cannot-add-service-accounts-with-global-saml-group-memberships-lock"></a>

## 无法在全局 SAML 群组成员锁定下添加服务账户

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

如果启用了 [全局 SAML 群组成员锁定](group_sync.md#global-saml-group-memberships-lock)，则只有管理员才能通过 UI 管理群组成员和服务账户。如果群组所有者需要管理服务账户，他们可以改用 [群组成员 API](../../../api/group_members.md)。

<a id="support-knowledge-base"></a>

## 支持知识库

如果你仍然遇到问题，请参阅 [极狐GitLab 支持知识库](https://support.gitlab.com/hc/en-us/)。

```