---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：为 JihuLab.com 群组设置 SAML SSO'
---

本教程将引导您使用 Okta 或 Microsoft Entra ID 等身份提供商（IdP），为 JihuLab.com 群组设置 SAML 单点登录（SSO）。完成后，您群组中的成员即可通过该 IdP 登录极狐GitLab。

在本教程中，您将：

1. 通过 IdP 应用程序配置 SAML。
1. 在极狐GitLab 群组中配置 SAML SSO。
1. 测试 SAML 连接。
1. 关联用户账号以验证设置。

<a id="before-you-begin"></a>

## 开始之前

先决条件：

- 您必须在 JihuLab.com 上拥有某个极狐GitLab 专业版或旗舰版群组的所有者角色。
- 您必须拥有 IdP 的管理员访问权限。
- 您的 IdP 中必须至少有一个测试用户账号。
- 您应熟悉单点登录的概念。

完成时间：20-30 分钟

<a id="step-1-gather-gitlab-information"></a>

## 第 1 步：收集极狐GitLab 信息

在 IdP 中进行任何设置之前，您必须先从极狐GitLab 获取一些连接详情，这些详情会告知您的 IdP 如何与您的极狐GitLab 群组通信。

收集极狐GitLab 信息：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 记下以下值：
   - **标识符**
   - **断言消费者服务 URL**
   - **极狐GitLab 单点登录 URL**

<a id="step-2-create-an-idp-application"></a>

## 第 2 步：创建 IdP 应用程序

现在您已准备好极狐GitLab 详情，接下来在 IdP 中创建一个应用程序。该应用程序会将极狐GitLab 信息映射到 IdP，并配置用户信息如何在两个系统之间流动。

创建 IdP 应用程序：

{{< tabs >}}

{{< tab title="Okta" >}}

1. 以管理员身份登录 Okta。
1. 在管理控制台中，选择 **应用程序** > **应用程序**。
1. 选择 **创建应用集成**。
1. 在 **登录方法** 部分，选择 **SAML 2.0**。
1. 选择 **下一步**。
1. 在 **常规设置** 选项卡上，为您的应用程序输入名称。例如，`GitLab SAML`。
1. 选择 **下一步**。
1. 在 **配置 SAML** 选项卡上，使用第 1 步中的值填写各字段：
   - **单点登录 URL**：输入**断言消费者服务 URL**。
   - 选中 **将此值用于接收方 URL 和目标 URL** 复选框。
   - **受众 URI（SP 实体 ID）**：输入**标识符**。
1. 配置名称标识符：
   - **应用程序用户名（NameID）**：选择 **自定义**，然后输入 `user.getInternalProperty("id")`。
   - **名称 ID 格式**：选择 **持久**。
1. 在 **属性声明（可选）** 部分，添加以下属性：
   - **名称**：`email`
   - **值**：`user.email`
1. 向下滚动到 **应用程序登录页面** 设置：
   - **登录页面 URL**：输入**极狐GitLab 单点登录 URL**。
1. 选择 **下一步**。
1. 在 **反馈** 选项卡上，根据您的使用场景选择相应选项。
1. 选择 **完成**。

SAML 应用程序已在 Okta 中创建。

> [!note]
> 有关 SAML 属性和高级配置选项的更多信息，
> 请参阅 [SAML SSO 文档](../../user/group/saml_sso/_index.md#okta)。

{{< /tab >}}

{{< tab title="Entra ID" >}}

1. 登录 [Microsoft Entra 管理中心](https://entra.microsoft.com/)。
1. 选择 **身份** > **应用程序** > **企业应用程序**。
1. 选择 **新建应用程序**。
1. 选择 **创建自己的应用程序**。
1. 在对话框中填写各字段：
   - **名称**：为您的应用程序输入名称。本教程中，请使用 `GitLab SAML`。
   - 选择 **集成在库中找不到的任何其他应用程序（非库应用程序）**。
1. 选择 **创建**。

企业应用程序已在 Microsoft Entra ID 中创建。

1. 在您的企业应用程序中，从左侧边栏选择 **单点登录**。
1. 选择 **SAML** 作为单点登录方法。
1. 在 **基本 SAML 配置** 部分，选择 **编辑**。
1. 使用第 1 步中的值填写各字段：
   - **标识符（实体 ID）**：输入**标识符**。
   - **回复 URL（断言消费者服务 URL）**：输入**断言消费者服务 URL**。
   - **登录 URL**：输入**极狐GitLab 单点登录 URL**。
1. 选择 **保存**。
1. 在 **用户属性和声明** 部分，选择 **编辑**。
1. 选择 **添加新声明** 并填写各字段：
   - **名称**：输入 `email`。
   - **源属性**：选择 `user.mail`。
1. 选择 **保存**。
1. 编辑 **唯一用户标识符（名称 ID）** 声明：
   - 选择现有的 **唯一用户标识符** 声明。
   - **源属性**：选择 `user.objectid`。
   - **名称标识符格式**：选择 **持久**。
1. 选择 **保存**。

> [!note]
> 有关 SAML 属性和高级配置选项的更多信息，
> 请参阅 [SAML SSO 文档](../../user/group/saml_sso/_index.md#azure)。

{{< /tab >}}

{{< tab title="Google Workspace" >}}

1. 登录 [Google 管理控制台](https://admin.google.com/)。
1. 选择 **应用** > **Web 和移动应用**。
1. 选择 **添加应用** > **添加自定义 SAML 应用**。
1. 在 **应用详情** 页面中，为您的应用程序输入名称。例如，`GitLab SAML`。
1. 选择 **继续**。
1. 在 **Google 身份提供商详情** 页面上，保持此页面打开。第 3 步中需要用到这些值。
1. 选择 **继续**。
1. 在 **服务提供商详情** 页面上，使用第 1 步中的值填写各字段：
   - **ACS URL**：输入**断言消费者服务 URL**。
   - **实体 ID**：输入**标识符**。
   - **启动 URL**：输入**极狐GitLab 单点登录 URL**。
   - **名称 ID 格式**：选择 **EMAIL**。
   - **名称 ID**：选择 **基本信息** > **主邮箱**。
1. 选择 **继续**。
1. 在 **属性映射** 页面上，添加以下属性：
   - **Google 目录属性**：`Primary email`，**应用属性**：`email`
   - **Google 目录属性**：`First name`，**应用属性**：`first_name`
   - **Google 目录属性**：`Last name`，**应用属性**：`last_name`
1. 选择 **完成**。
   SAML 应用程序已在 Google Workspace 中创建。
1. 为您的用户开启该应用程序：
   - 在 **用户访问权限** 部分，选择 **为所有人开启**。
   - 选择 **保存**。

有关 SAML 属性和高级配置选项的更多信息，
请参阅 [SAML SSO 文档](../../user/group/saml_sso/_index.md#google-workspace)。

{{< /tab >}}

{{< tab title="OneLogin" >}}

1. 以管理员身份登录 OneLogin。
1. 选择 **管理** > **应用程序**。
1. 选择 **添加应用**。
1. 搜索 **SAML Test Connector (Advanced)** 并选择它。
1. 在 **显示名称** 字段中，为您的应用程序输入名称。例如，`GitLab SAML`。
1. 选择 **保存**。
1. 选择 **配置** 选项卡。
1. 使用第 1 步中的值填写各字段：
   - **受众（EntityID）**：输入**标识符**。
   - **接收方**：输入**断言消费者服务 URL**。
   - **ACS（消费者）URL 验证器**：以正则表达式的形式输入**断言消费者服务 URL**。
     例如，`https://gitlab\.com/groups/your-group/-/saml/callback`。
   - **ACS（消费者）URL**：输入**断言消费者服务 URL**。
   - **登录 URL**：输入**极狐GitLab 单点登录 URL**。
1. 选择 **保存**。
1. 选择 **参数** 选项卡。
1. 通过选择 **添加参数** 添加所需属性：
   - **字段名**：`email`，**值**：Email
1. 对于 **NameID**，在值字段中选择 **OneLogin ID**。
1. 选择 **保存**。
1. 选择 **访问** 选项卡，将用户或角色分配给该应用程序。

SAML 应用程序已在 OneLogin 中创建。

有关 SAML 属性和高级配置选项的更多信息，
请参阅 [SAML SSO 文档](../../user/group/saml_sso/_index.md#onelogin)。

{{< /tab >}}

{{< tab title="Keycloak" >}}

1. 以管理员身份登录 Keycloak。
1. 转到 **客户端** 并选择 **创建客户端**。
1. 在 **常规设置** 页面中，选择 **SAML** 作为 **客户端类型**。
1. 使用第 1 步中的值填写各字段：
   - **客户端 ID**：输入**标识符**。
   - **有效的重定向 URI**：输入**断言消费者服务 URL**。
   - **断言消费者服务 POST 绑定 URL**：输入**断言消费者服务 URL**。
   - **主页 URL**：输入**极狐GitLab 单点登录 URL**。
1. 选择 **保存**。
1. 在 **设置** 选项卡的 **SAML 功能** 部分：
   - **名称 ID 格式**：选择 `persistent`。
   - 开启 **强制名称 ID 格式** 开关。
   - 开启 **强制 POST 绑定** 开关。
   - 开启 **包含 AuthnStatement** 开关。
1. 在 **签名和加密** 部分，开启 **签署文档** 开关。
1. 在 **密钥** 选项卡上，确保所有部分均已禁用。
1. 在 **客户端范围** 选项卡上：
   - 选择极狐GitLab 的客户端范围。
   - 选择 **配置新映射器**，然后在打开的窗口中选择 **用户属性**。
   - 在 **添加映射器** 页面上，将 **名称**、**用户属性** 和 **SAML 属性名称** 字段设置为 `email`。
   - 选择 **保存**。

SAML 客户端已在 Keycloak 中创建。

> [!note]
> 有关 SAML 属性和高级配置选项的更多信息，
> 请参阅 [SAML SSO 文档](../../user/group/saml_sso/_index.md#keycloak)。

{{< /tab >}}

{{< tab title="AWS IAM Identity Center" >}}

1. 登录 AWS IAM Identity Center 控制台。
1. 选择 **应用程序**，然后选择 **添加应用程序**。
1. 选择 **我有一个要设置的应用程序**。
1. 选择 **SAML 2.0** 作为应用程序类型。
1. 选择 **下一步**。
1. 在 **配置应用程序** 页面上，为您的应用程序输入显示名称。例如，`GitLab SAML`。
1. 使用第 1 步中的值填写各字段：
   - **应用程序 ACS URL**：输入**断言消费者服务 URL**。
   - **应用程序 SAML 受众**：输入**标识符**。
   - **应用程序启动 URL**：输入**极狐GitLab 单点登录 URL**。
1. 在 **属性映射** 下，配置以下属性：
   - **主体**：`${user:email}`，**格式**：`unspecified`
   - **email**：`${user:email}`，**格式**：`unspecified`
   - **first_name**：`${user:givenName}`，**格式**：`unspecified`
   - **last_name**：`${user:familyName}`，**格式**：`unspecified`

   > [!warning]
   > 为避免现有极狐GitLab 用户出现身份验证错误，请勿将格式设置为
   > `persistent` 或 `transient`。

1. 选择 **提交**。
   SAML 应用程序已在 AWS IAM Identity Center 中创建。
1. 将用户分配给极狐GitLab 应用程序。

有关 SAML 属性和高级配置选项的更多信息，
请参阅 [SAML SSO 文档](../../user/group/saml_sso/_index.md#aws-iam-identity-center)。

> [!note]
> AWS IAM Identity Center 默认使用 IdP 发起的登录。要关联现有极狐GitLab 账号，
> 用户必须从**极狐GitLab 单点登录 URL** 或 **应用程序启动 URL** 登录。

{{< /tab >}}

{{< /tabs >}}

<a id="step-3-gather-the-connection-details"></a>

## 第 3 步：收集连接详情

现在获取极狐GitLab 向 IdP 发送身份验证请求所需的信息。

收集连接详情：

{{< tabs >}}

{{< tab title="Okta" >}}

1. 在您的 Okta SAML 应用程序中，选择 **登录** 选项卡。
1. 在右侧，选择 **查看 SAML 设置说明**。
1. 记下 **身份提供商单点登录 URL**。
1. 生成证书指纹：
   1. 在 **X.509 证书** 字段中，复制文本并保存到本地。
   1. 打开终端，转到您保存证书文件的目录。
   1. 运行以下命令生成证书指纹：

   ```shell
      # Replace `<certificate_filename>` with the actual filename of your downloaded certificate.
      # You might need to install OpenSSL or use an alternative method to generate the fingerprint.
       openssl x509 -noout -fingerprint -sha256 -in <certificate_filename>.crt
   ```

1. 复制 `SHA256 Fingerprint=` 之后的指纹值。
   指纹类似于 `A1:B2:C3:D4:E5:F6:...`。

{{< /tab >}}

{{< tab title="Entra ID" >}}

1. 在您的 Entra ID 企业应用程序中，选择 **单点登录**。
1. 在 **设置 GitLab SAML** 部分，记下 **登录 URL**。
   此部分的名称基于您企业应用程序的名称。
1. 在 **SAML 签名证书** 部分，记下 **指纹** 值。
   指纹类似于 `A1B2C3D4E5F6...`。

{{< /tab >}}

{{< tab title="Google Workspace" >}}

1. 在您的 Google Workspace SAML 应用程序中，转到应用程序详情页面。
1. 记下 **SSO URL** 值。
1. 记下为证书显示的 **SHA-256 指纹** 值。
   指纹类似于 `A1:B2:C3:D4:E5:F6:...`。

{{< /tab >}}

{{< tab title="OneLogin" >}}

1. 在您的 OneLogin SAML 应用程序中，选择 **SSO** 选项卡。
1. 记下 **SAML 2.0 端点（HTTP）** URL。
1. 在 **X.509 证书** 部分，选择 **查看详情**。
1. 记下 **SHA-256 指纹** 值。
   指纹类似于 `A1:B2:C3:D4:E5:F6:...`。

{{< /tab >}}

{{< tab title="Keycloak" >}}

1. 在您的 Keycloak SAML 客户端中，在 **操作** 下拉列表中选择 **下载适配器配置**。
1. 在 **下载适配器配置** 对话框中，从下拉列表中选择 **mod-auth-mellon**。
1. 选择 **下载**。
1. 解压下载的归档文件并打开 `idp-metadata.xml`。
1. 找到 `<md:SingleSignOnService>` 标签，记下 `Location` 属性的值。
1. 生成证书指纹：
   1. 找到 `<ds:X509Certificate>` 标签，将值复制到单独的文件中。
   1. 将该值转换为 PEM 格式。在文件开头添加 `-----BEGIN CERTIFICATE-----`，在文件末尾添加 `-----END CERTIFICATE-----`，各占一行。

{{< /tab >}}

{{< tab title="AWS IAM Identity Center" >}}

1. 在您的 AWS IAM Identity Center SAML 应用程序中，选择您创建的应用程序。
1. 在 **IAM Identity Center SAML 元数据** 部分，记下 **IAM Identity Center 登录 URL**。
1. 下载证书。
1. 生成证书指纹：
   1. 打开终端，转到您保存证书文件的目录。
   1. 运行以下命令生成证书指纹：

   ```shell
   # Replace `<certificate_filename>` with the actual filename of your downloaded certificate.
   # You might need to install OpenSSL or use an alternative method to generate the fingerprint.
   openssl x509 -noout -fingerprint -sha256 -in <certificate_filename>.pem
   ```

1. 复制 `SHA1 Fingerprint=` 之后的指纹值。
   指纹类似于 `A1:B2:C3:D4:E5:F6:...`。

> [!note]
> AWS IAM Identity Center 需要 SHA1 指纹。有关更多信息，请参阅
> [SAML SSO 文档](../../user/group/saml_sso/_index.md#aws-iam-identity-center)。

{{< /tab >}}

{{< /tabs >}}

<a id="step-4-configure-saml-sso-in-gitlab"></a>

## 第 4 步：在极狐GitLab 中配置 SAML SSO

您已具备完成连接所需的一切。返回极狐GitLab，输入连接详情，为您的群组开启 SAML 身份验证。

配置 SAML：

1. 返回您的极狐GitLab 群组。
1. 选择**设置** > **SAML SSO**。
1. 在 **配置** 部分，填写各字段：
   - **身份验证提供商单点登录URL**：输入第 3 步中的 URL。
   - **证书指纹**：输入第 3 步中的指纹。
1. 选中 **为此群组启用 SAML 身份认证** 复选框。
1. 从 **默认成员角色** 下拉列表中，选择 **最小访问权限**。
1. 选择 **保存更改**。

基本 SAML 连接现已配置完成。

> [!note]
> 您可以将默认成员角色设置为任意角色。所有新用户首次通过 SAML 登录时都会被分配该角色。
> 将默认角色设置为 [**最小访问权限**](../../user/permissions.md#users-with-minimal-access)
> 并在之后提升用户，可降低用户权限过大的风险。

<a id="step-5-test-the-saml-configuration"></a>

## 第 5 步：测试 SAML 配置

在邀请您的团队之前，请先验证连接是否正常工作。

测试 SAML 配置：

1. 在**设置** > **SAML SSO** 页面上，选择 **验证SAML配置**。
   极狐GitLab 会将您重定向到 IdP。
1. 使用您的 IdP 凭据登录。
1. 确认 IdP 将您重定向回极狐GitLab。

如果看到错误，请参阅[故障排除指南](../../user/group/saml_sso/troubleshooting.md)。

<a id="step-6-link-a-user-account-to-test-the-full-flow"></a>

## 第 6 步：关联用户账号以测试完整流程

配置看起来没问题。现在通过关联一个测试账号，从用户的角度测试整个体验，就像您的团队成员首次通过 IdP 连接到极狐GitLab 时所做的那样。

测试用户账号关联：

1. 退出极狐GitLab。
1. 在其他浏览器或无痕窗口中，登录您的测试极狐GitLab 账号。
1. 转到您在第 1 步中记下的极狐GitLab 单点登录 URL。
1. 选择 **授权**。
1. 出现提示时，使用您的 IdP 凭据登录。
1. 验证您已被重定向到极狐GitLab 群组。

恭喜！您已成功将 SAML 身份关联到极狐GitLab 账号。

<a id="step-7-optional-turn-on-sso-enforcement"></a>

## 第 7 步：可选：开启 SSO 强制

您已拥有可用的 SAML 设置。作为可选的最后一步，您可以开启 SSO 强制。SSO 强制要求所有群组成员通过 IdP 进行身份验证，这可以增强安全性。但是，它会阻止通过其他身份验证方法访问。

开启 SSO 强制：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 选择 **对该群组的 Web 活动强制执行仅 SSO 身份验证**。
1. 选择 **保存更改**。

启用强制后，所有群组成员必须先通过 IdP 登录，才能访问群组资源。

<a id="next-steps"></a>

## 后续步骤

您已成功为您的极狐GitLab 群组设置 SAML SSO！以下是一些您接下来可能想做的事情：

- [设置 SCIM 预配](../../user/group/saml_sso/scim_setup.md)以自动同步用户。
- [配置群组同步](../../user/group/saml_sso/group_sync.md)，根据您的 IdP 群组管理极狐GitLab 群组成员关系。
- 验证域名，以便为新用户[绕过用户邮箱确认](../../user/group/saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。
- 查看 [SSO 强制文档](../../user/group/saml_sso/_index.md#sso-enforcement)了解高级安全选项。

<a id="troubleshooting"></a>

## 故障排除

如果您在本教程中遇到问题，请参阅以下资源：

- [常见 SAML 错误及解决方案](../../user/group/saml_sso/troubleshooting.md)
- [如何取消关联并重新关联账号](../../user/group/saml_sso/_index.md#unlink-accounts)
- [支持资源](https://gitlab.cn/support)
