---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置服务台
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，服务台在新项目中处于启用状态。
如果未启用，您可以在项目设置中启用它。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。
- 在极狐GitLab 私有化部署上，您必须为极狐GitLab 实例[设置接收邮件](../../../administration/incoming_email.md#set-it-up)。您应该使用
  [邮件子地址](../../../administration/incoming_email.md#email-sub-addressing)，
  但也可以使用[捕获所有邮箱](../../../administration/incoming_email.md#catch-all-mailbox)。
  为此，您必须拥有管理员访问权限。
  如果没有支持邮件子地址或捕获所有邮箱的接收邮件功能，
  项目设置中将不会显示 **服务台** 部分。
- 您必须已为项目启用[议题](../settings/_index.md#configure-project-features-and-permissions)
  跟踪器。

要在您的项目中启用服务台：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 打开 **启用服务台** 开关。
1. 可选。填写字段。
   - [添加后缀](#configure-a-suffix-for-service-desk-alias-email) 到您的服务台电子邮件地址。
   - 如果 **要附加到所有服务台议题的模板** 下方的列表为空，请在您的代码仓库中创建一个
     [描述模板](../description_templates.md)。
1. 选择 **保存更改**。

服务台现已为此项目启用。
如果有人向 **用于服务台的电子邮件地址** 下方显示的地址发送电子邮件，
极狐GitLab 会创建一个包含该电子邮件内容的机密工单。

<a id="service-desk-glossary"></a>

## 服务台术语表

本术语表提供与服务台相关的术语定义。

| 术语                                             | 定义 |
|--------------------------------------------------|------------|
| [外部参与者](external_participants.md) | 没有极狐GitLab 账户、只能通过电子邮件与议题或服务台工单交互的用户。 |
| 请求者                                        | 创建服务台工单或使用 [`/convert_to_ticket` 快速操作](using_service_desk.md#create-a-service-desk-ticket-in-gitlab-ui) 添加为请求者的外部参与者。 |

<a id="improve-your-projects-security"></a>

## 提高项目的安全性

要提高您的服务台项目的安全性，您应该：

- 将服务台电子邮件地址放在您电子邮件系统的别名后面，以便日后更改。
- 在您的极狐GitLab 实例上[启用 Akismet](../../../integration/akismet.md)，为此服务添加垃圾邮件检查。
  未拦截的电子邮件垃圾邮件可能导致创建大量垃圾议题。

<a id="customize-emails-sent-to-external-participants"></a>

## 自定义发送给外部参与者的电子邮件

在以下情况下，会向外部参与者发送电子邮件：

- 请求者通过向服务台发送电子邮件来提交新工单。
- 外部参与者被添加到服务台工单。
- 在服务台工单上添加了新的公开评论。
  - 编辑评论不会触发发送新电子邮件。

您可以使用服务台电子邮件模板自定义这些电子邮件的正文。模板
可以包含 [极狐GitLab 风格 Markdown](../../markdown.md) 和 [一些 HTML 标签](../../markdown.md#inline-html)。
例如，您可以根据组织的品牌指南格式化电子邮件，使其包含页眉和页脚。您还可以包含以下占位符来显示
特定于服务台工单或您的极狐GitLab 实例的动态内容。

| 占位符            | `thank_you.md` 和 `new_participant` | `new_note.md`          | 描述 |
|------------------------|--------------------------------------|------------------------|-------------|
| `%{ISSUE_ID}`          | {{< yes >}}               | {{< yes >}} | 工单 IID。 |
| `%{ISSUE_PATH}`        | {{< yes >}}               | {{< yes >}} | 附加了工单 IID 的项目路径。 |
| `%{ISSUE_URL}`         | {{< yes >}}               | {{< yes >}} | 工单的 URL。外部参与者只有在项目为公开且工单非机密时才能查看工单（服务台工单默认是机密的）。 |
| `%{ISSUE_DESCRIPTION}` | {{< yes >}}               | {{< yes >}} | 工单描述。如果用户编辑了描述，则可能包含不打算传递给外部参与者的敏感信息。请谨慎使用此占位符，最好仅在您从不修改工单描述或您的团队了解模板设计时使用。 |
| `%{UNSUBSCRIBE_URL}`   | {{< yes >}}               | {{< yes >}} | 取消订阅 URL。了解如何[作为外部参与者取消订阅](external_participants.md#unsubscribing-from-notification-emails)以及[在来自极狐GitLab 的通知电子邮件中使用取消订阅标头](../../profile/notifications.md#using-an-email-client-or-other-software)。 |
| `%{NOTE_TEXT}`         | {{< no >}}                | {{< yes >}} | 用户添加到工单的新评论。请务必在 `new_note.md` 中包含此占位符。否则，外部参与者可能永远看不到其服务台工单上的更新。 |

<a id="thank-you-email"></a>

### 感谢邮件

当请求者通过服务台提交议题时，极狐GitLab 会发送一封**感谢邮件**。
无需额外配置，极狐GitLab 会发送默认的感谢邮件。

要创建自定义感谢邮件模板：

1. 在您代码仓库的 `.gitlab/service_desk_templates/` 目录中，创建一个名为 `thank_you.md` 的文件。
1. 使用文本、[极狐GitLab 风格 Markdown](../../markdown.md)、
   [一些选定的 HTML 标签](../../markdown.md#inline-html) 和占位符填充 Markdown 文件，以自定义对
   服务台请求者的回复。

<a id="new-participant-email"></a>

### 新参与者邮件

当[外部参与者](external_participants.md)被添加到工单时，极狐GitLab 会发送一封**新参与者邮件**，告知他们已加入对话。
无需额外配置，极狐GitLab 会发送默认的新参与者邮件。

要创建自定义新参与者邮件模板：

1. 在您代码仓库的 `.gitlab/service_desk_templates/` 目录中，创建一个名为 `new_participant.md` 的文件。
1. 使用文本、[极狐GitLab 风格 Markdown](../../markdown.md)、
   [一些选定的 HTML 标签](../../markdown.md#inline-html) 和占位符填充 Markdown 文件，以自定义对
   服务台请求者的回复。

<a id="new-note-email"></a>

### 新评论邮件

当服务台工单有新的公开评论时，极狐GitLab 会发送一封**新评论邮件**。
无需额外配置，极狐GitLab 会发送评论的内容。

为保持您的电子邮件符合品牌形象，您可以创建自定义的新评论邮件模板。操作步骤如下：

1. 在您代码仓库的 `.gitlab/service_desk_templates/` 目录中，创建一个名为 `new_note.md` 的文件。
1. 使用文本、[极狐GitLab 风格 Markdown](../../markdown.md)、
   [一些选定的 HTML 标签](../../markdown.md#inline-html) 和占位符填充 Markdown 文件，以自定义新评论
   邮件。请务必在模板中包含 `%{NOTE_TEXT}`，以确保邮件收件人能够
   阅读评论内容。

<a id="instance-wide-email-header-footer-and-additional-text"></a>

### 实例级电子邮件页眉、页脚和附加文本

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

实例管理员可以向极狐GitLab 实例添加页眉、页脚或附加文本，并将其应用于从极狐GitLab 发送的所有电子邮件。如果您使用自定义的 `thank_you.md`、`new_participant.md` 或 `new_note.md`，要包含
此内容，请将 `%{SYSTEM_HEADER}`、`%{SYSTEM_FOOTER}` 或 `%{ADDITIONAL_TEXT}` 添加到您的模板中。

有关更多信息，请参阅[系统页眉和页脚消息](../../../administration/appearance.md#add-system-header-and-footer-messages)和[自定义附加文本](../../../administration/settings/email.md#custom-additional-text)。

<a id="use-a-custom-template-for-service-desk-tickets"></a>

## 为服务台工单使用自定义模板

您可以为**每个项目**选择一个[描述模板](../description_templates.md#create-a-description-template)，
将其附加到每个新的服务台工单描述中。

您可以在不同级别设置描述模板：

- 整个[实例](../description_templates.md#set-instance-level-description-templates)。
- 特定的[群组或子群组](../description_templates.md#set-group-level-description-templates)。
- 特定的[项目](../description_templates.md#set-a-default-template-for-merge-requests-and-issues)。

模板是继承的。例如，在一个项目中，您也可以访问为实例或项目的父群组设置的模板。

先决条件：

- 您必须已[创建描述模板](../description_templates.md#create-a-description-template)。

要将自定义描述模板与服务台一起使用：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 从下拉列表 **要附加到所有服务台议题的模板** 中，搜索或选择您的模板。

<a id="support-bot-user"></a>

## 支持机器人用户

在幕后，服务台通过特殊的支持机器人用户创建工单来工作。
该用户不是[计费用户](../../../subscriptions/manage_seats.md#criteria-for-non-billable-users)，
因此不计入许可证限制。

从服务台电子邮件生成的评论会显示发送电子邮件用户的电子邮件地址。

<a id="change-the-support-bots-display-name"></a>

### 更改支持机器人的显示名称

您可以更改支持机器人用户的显示名称。从服务台工单发送的电子邮件在
`From` 标头中包含此名称。默认显示名称为 `GitLab Support Bot`。

要编辑自定义电子邮件显示名称：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 在 **电子邮件显示名称** 下方，输入新名称。
1. 选择 **保存更改**。

<a id="default-ticket-visibility"></a>

## 默认工单可见性

新工单默认是机密的，因此只有具有计划者、报告者、开发者、维护者或所有者角色的项目成员
才能查看它们。

在私有和内部项目中，您可以配置极狐GitLab，使新工单默认不机密，并且任何项目成员都可以查看。

在公开项目中，此设置不可用，因为新工单默认始终是机密的。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

要禁用此设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 清除 **新工单默认机密** 复选框。
1. 选择 **保存更改**。

<a id="reopen-tickets-when-an-external-participant-comments"></a>

## 当外部参与者评论时重新打开工单

您可以配置极狐GitLab，在外部参与者通过电子邮件在工单上添加
新评论时重新打开已关闭的工单。这还会添加一条内部评论，提及
工单的指派人，并为他们创建待办事项。

<!-- Video published on 2023-12-12 -->

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

要启用此设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 选中 **当外部参与者发表新评论时重新打开议题** 复选框。
1. 选择 **保存更改**。

<a id="custom-email-address"></a>

## 自定义电子邮件地址

{{< details >}}

- Status: 测试版

{{< /details >}}

配置自定义电子邮件地址，以显示为您的支持沟通的发件人。
通过使用用户认可的域名来维护品牌形象并增强支持请求者的信心。

<!-- Video published on 2023-09-12 -->

此功能处于[测试版](../../../policy/development_stages_support.md#beta)。
测试版功能尚未准备好用于生产环境，但在发布前不太可能发生重大变化。我们鼓励用户尝试测试版功能，并在
[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416637)中提供反馈。

<a id="prerequisites"></a>

### 先决条件

每个项目只能为服务台使用一个自定义电子邮件地址，并且该地址在整个实例中必须是唯一的。

您要使用的自定义电子邮件地址必须满足以下所有要求：

- 您可以设置电子邮件转发。
- 转发的电子邮件保留原始 `From` 标头。
- 您的服务提供商必须支持子地址。电子邮件地址由本地部分（`@` 之前的所有内容）和
  域部分组成。

  使用电子邮件子地址，您可以通过在本地部分添加 `+` 符号后跟
  任意文本来创建电子邮件地址的唯一变体。给定电子邮件地址 `support@example.com`，通过向
  `support+1@example.com` 发送电子邮件来检查是否支持子地址。此电子邮件应出现在您的邮箱中。
- 您有 SMTP 凭据（理想情况下，您应该使用应用密码）。
  用户名和密码使用高级加密标准 (AES) 以 256 位密钥存储在数据库中。
- **SMTP 主机** 必须可以从您的极狐GitLab 实例的网络（在极狐GitLab 私有化部署上）
  或公共互联网（在 JihuLab.com 上）解析。
- 您必须拥有该项目的维护者或所有者角色。
- 必须为项目配置服务台。

<a id="configure-a-custom-email-address"></a>

### 配置自定义电子邮件地址

当您想使用自己的电子邮件地址发送服务台电子邮件时，请配置并验证自定义电子邮件地址。

> [!warning]
> 设置电子邮件转发时，请使用自定义电子邮件表单中
> **用于转发电子邮件的服务台电子邮件地址** 字段中的地址
> （`incoming+...` 地址）。不要转发到服务台设置页面顶部的别名地址（`contact-project+...`）。
> 转发到别名
> 地址会导致 `Incorrect forwarding target` 验证失败。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台** 并找到 **配置自定义电子邮件地址** 部分。
1. 从 **用于转发电子邮件的服务台电子邮件地址** 字段复制电子邮件地址。
   这是您必须用作转发目标的 `incoming+...` 地址。
1. 在您的电子邮件提供商（例如 Gmail 或 Microsoft 365）中，设置从您的自定义电子邮件地址到上一步中复制的地址的电子邮件转发。
1. 返回极狐GitLab，填写其余字段。
1. 选择 **保存并测试连接**。

配置已保存，自定义电子邮件地址的验证已触发。

<a id="verification"></a>

#### 验证

1. 完成配置后，所有项目所有者和保存自定义电子邮件配置的管理员都会收到通知电子邮件。
1. 使用提供的 SMTP 凭据向自定义电子邮件地址（带有子地址部分）发送验证电子邮件。
   该电子邮件包含验证令牌。当电子邮件转发设置正确且满足所有先决条件时，
   电子邮件会转发到您的服务台地址并由极狐GitLab 摄取。极狐GitLab 检查以下条件：
   1. 极狐GitLab 可以使用 SMTP 凭据发送电子邮件。
   1. 支持子地址（使用 `+verify` 子地址部分）。
   1. 转发后保留 `From` 标头。
   1. 验证令牌正确。
   1. 在 30 分钟内收到电子邮件。

通常该过程只需几分钟。

要随时取消验证，或者如果验证失败，请选择 **重置自定义电子邮件**。
设置页面会相应更新并反映验证的当前状态。
SMTP 凭据将被删除，您可以重新开始配置。

在失败和成功时，所有项目所有者和触发验证过程的用户都会收到一封包含验证结果的通知电子邮件。
如果验证失败，该电子邮件还会包含失败原因的详细信息。

如果验证成功，自定义电子邮件地址即可使用。
您现在可以启用使用自定义电子邮件地址发送服务台电子邮件。

<a id="troubleshooting-your-configuration"></a>

#### 配置故障排查

配置自定义电子邮件时，您可能会遇到以下问题。

<a id="invalid-credentials"></a>

##### 凭据无效

您可能会收到如下错误：

```plaintext
The given credentials (username and password) were rejected by the SMTP server,
or you need to explicitly set an authentication method.
```

当 SMTP 服务器拒绝身份验证凭据时，会出现此问题。

要解决此问题：

1. 验证您的用户名和密码是否正确。
1. 如果极狐GitLab 无法自动选择受支持的身份验证方法，请执行以下操作之一：
   - 测试可用的身份验证方法：**Plain**、**Login** 和 **CRAM-MD5**。
   - 通过在极狐GitLab 服务器上运行此命令，检查您的 SMTP 服务器支持哪些身份验证方法：

     ```shell
          swaks --to user@example.com \
                --from support@example.com \
                --auth-user support@example.com \
                --server smtp@example.com:587 \
                -tls-optional \
                --auth-password your-app-password
     ```

     在输出中，找到以 `250-AUTH` 开头的行，
     然后在自定义电子邮件设置表单中选择一种受支持的身份验证方法。

1. 如果您使用 Microsoft 365 且错误仍然存在，请禁用条件访问并重复上述步骤。

<a id="incorrect-forwarding-target"></a>

##### 错误的转发目标

您可能会收到使用了错误转发目标的错误。

当验证电子邮件被转发到与自定义电子邮件配置表单中显示的项目特定服务台地址不同的电子邮件地址时，会发生此情况。

您必须使用从 `incoming_email` 生成的服务台地址。不支持转发到从 `service_desk_email` 生成的附加
服务台别名地址，因为它不支持
所有通过电子邮件回复的功能。

要对此进行故障排查：

1. 找到要转发电子邮件的正确电子邮件地址。可以：
   - 记下所有项目所有者和触发验证过程的用户收到的验证结果电子邮件中的地址。
   - 从自定义电子邮件设置表单中的 **用于转发电子邮件的服务台电子邮件地址** 输入框复制地址。
1. 将所有发送到自定义电子邮件地址的电子邮件转发到正确的目标电子邮件地址。

<a id="enable-or-disable-the-custom-email-address"></a>

### 启用或禁用自定义电子邮件地址

自定义电子邮件地址验证通过后，管理员可以启用或禁用使用自定义电子邮件地址发送服务台电子邮件。

要**启用**自定义电子邮件地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 打开 **启用自定义电子邮件** 开关。
   发送给外部参与者的服务台电子邮件将使用 SMTP 凭据发送。

要**禁用**自定义电子邮件地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 关闭 **启用自定义电子邮件** 开关。
   由于您设置了电子邮件转发，发送到您的自定义电子邮件地址的电子邮件将继续被处理并
   作为服务台工单出现在您的项目中。

   发送给外部参与者的服务台电子邮件现在将使用极狐GitLab 实例的默认外发
   电子邮件配置发送。

<a id="change-or-remove-custom-email-configuration"></a>

### 更改或移除自定义电子邮件配置

要更改自定义电子邮件配置，您必须重置并移除它，然后重新配置自定义电子邮件。

要在流程的任何步骤重置配置，请选择 **重置自定义电子邮件**。
然后，凭据将从数据库中移除。

<a id="custom-email-reply-address"></a>

### 自定义电子邮件回复地址

外部参与者可以[通过电子邮件回复](../../../administration/reply_by_email.md) 服务台工单。
极狐GitLab 使用带有 32 字符回复密钥的电子邮件回复地址，该密钥与工单对应。
配置自定义电子邮件后，极狐GitLab 会从该电子邮件生成回复地址。

<a id="use-google-workspace-with-your-own-domain"></a>

### 将 Google Workspace 与您自己的域名一起使用

当将 Google Workspace 与您自己的域名一起使用时，为服务台设置自定义电子邮件地址。

先决条件：

- 您已有一个 Google Workspace 账户。
- 您可以为您的租户创建新账户。

要使用 Google Workspace 配置自定义服务台电子邮件地址：

1. [配置 Google Workspace 账户](#configure-a-google-workspace-account)。
1. [在 Google Workspace 中配置电子邮件转发](#configure-email-forwarding-in-google-workspace)。
1. [使用 Google Workspace 账户配置自定义电子邮件地址](#configure-custom-email-address-using-a-google-workspace-account)。

<a id="configure-a-google-workspace-account"></a>

#### 配置 Google Workspace 账户

首先，您必须创建并配置一个 Google Workspace 账户。

在 Google Workspace 中：

1. 为您要使用的自定义电子邮件地址创建一个新账户（例如，`support@example.com`）。
1. 登录该账户并激活
   两步验证：`https://myaccount.google.com/u/3/signinoptions/two-step-verification`
1. 创建一个可用作 SMTP 密码的应用密码：`https://myaccount.google.com/u/3/apppasswords`
   将其存储在安全的地方，并删除字符之间的空格。

接下来，您必须[在 Google Workspace 中配置电子邮件转发](#configure-email-forwarding-in-google-workspace)。

<a id="configure-email-forwarding-in-google-workspace"></a>

#### 在 Google Workspace 中配置电子邮件转发

以下步骤需要在极狐GitLab 和 Google Workspace 之间切换。

在极狐GitLab 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**
1. 展开 **服务台**。
1. 记下 **用于转发电子邮件的服务台电子邮件地址** 下方的电子邮件地址。

在 Google Workspace 中：

1. 登录自定义电子邮件账户并打开 [**转发和 POP/IMAP**](https://mail.google.com/mail/u/0/#settings/fwdandpop) 设置。
1. 选择 **添加转发地址**。
1. 输入自定义电子邮件表单中的服务台地址。
1. 选择 **下一步**。
1. 确认您的输入并选择 **继续**。Google 会向服务台地址发送一封电子邮件，并
   要求提供确认代码。

在极狐GitLab 中：

1. 选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。
   等待从 Google 的确认电子邮件创建新议题。
1. 选择该议题并记下确认代码。
1. 可选。删除该议题。

在 Google Workspace 中：

1. 输入确认代码并选择 **验证**。
1. 选择 **转发传入邮件的副本至**，并确保从下拉列表中选择服务台地址。
1. 在页面底部，选择 **保存更改**。

接下来，[使用 Google Workspace 账户配置自定义电子邮件地址](#configure-custom-email-address-using-a-google-workspace-account)
以与服务台一起使用。

<a id="configure-custom-email-address-using-a-google-workspace-account"></a>

#### 使用 Google Workspace 账户配置自定义电子邮件地址

在极狐GitLab 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台** 并找到自定义电子邮件设置。
1. 填写字段：
   - **自定义电子邮件地址**：您的自定义电子邮件地址。
   - **SMTP 主机**：`smtp.gmail.com`。
   - **SMTP 端口**：`587`。
   - **SMTP 用户名**：预填为自定义电子邮件地址。
   - **SMTP 密码**：您之前为自定义电子邮件账户创建的应用密码。
   - **SMTP 身份验证方法**：让极狐GitLab 选择服务器支持的方法（推荐）。
1. 选择 **保存并测试连接**。
1. 在[验证过程](#verification)之后，您应该能够
   [启用自定义电子邮件地址](#enable-or-disable-the-custom-email-address)。

<a id="use-microsoft-365-exchange-online-with-your-own-domain"></a>

### 将 Microsoft 365（Exchange Online）与您自己的域名一起使用

当将 Microsoft 365（Exchange）与您自己的域名一起使用时，为服务台设置自定义电子邮件地址。

先决条件：

- 您已有一个 Microsoft 365 账户。
- 您可以为您的租户创建新账户。

要使用 Microsoft 365 配置自定义服务台电子邮件地址：

1. [配置 Microsoft 365 账户](#configure-a-microsoft-365-account)。
1. [在 Microsoft 365 中配置电子邮件转发](#configure-email-forwarding-in-microsoft-365)。
1. [使用 Microsoft 365 账户配置自定义电子邮件地址](#configure-custom-email-address-using-a-microsoft-365-account)。

<a id="configure-a-microsoft-365-account"></a>

#### 配置 Microsoft 365 账户

首先，您必须创建并配置一个 Microsoft 365 账户。
在本指南中，为自定义电子邮件邮箱使用许可用户。
您也可以尝试其他配置选项。

在 [Microsoft 365 管理中心](https://admin.microsoft.com/Adminportal/Home#/homepage) 中：

1. 为您要使用的自定义电子邮件地址创建一个新账户（例如，`support@example.com`）。
   1. 展开 **用户** 部分，然后从菜单中选择 **活跃用户**。
   1. 选择 **添加用户** 并按照屏幕上的说明操作。
1. 在 Microsoft Entra（以前称为 Active Directory）中，为该账户启用两步验证。
1. [允许用户创建应用密码](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-app-passwords)。
1. 为该账户启用 **已验证 SMTP**。
   1. 从列表中选择该账户。
   1. 在抽屉中选择 **邮件**。
   1. 在 **电子邮件应用** 下方，选择 **管理电子邮件应用**。
   1. 勾选 **已验证 SMTP** 并选择 **保存更改**。
1. 根据您的整体 Exchange Online 配置，您可能需要配置以下内容：
   1. 使用 Azure Cloud Shell 允许 SMTP 客户端身份验证：

      ```powershell
      Set-TransportConfig -SmtpClientAuthenticationDisabled $false
      ```

   1. 使用 Azure Cloud Shell 允许
      [使用 SMTP AUTH 的旧版 TLS 客户端](https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/opt-in-exchange-online-endpoint-for-legacy-tls-using-smtp-auth)：

      ```powershell
      Set-TransportConfig -AllowLegacyTLSClients $true
      ```

   1. 如果您想转发到外部收件人，请参阅此指南了解如何启用
      [外部电子邮件转发](https://learn.microsoft.com/en-gb/defender-office-365/outbound-spam-policies-external-email-forwarding)。
      您可能还想[创建出站反垃圾邮件策略](https://security.microsoft.com/antispam)
      以仅允许需要它的用户转发到外部收件人。
1. 登录该账户并激活两步验证。
   <!-- vale gitlab_base.SubstitutionWarning = NO -->
   1. 从右上角的菜单中，选择 **查看账户** 并[浏览到 **安全信息**](https://mysignins.microsoft.com/security-info)。
   <!-- vale gitlab_base.SubstitutionWarning = YES -->
   1. 选择 **添加登录方法** 并选择适合您的方法（验证器应用、电话或电子邮件）。
   1. 按照屏幕上的说明操作。
<!-- vale gitlab_base.SubstitutionWarning = NO -->
1. 在 [**安全信息**](https://mysignins.microsoft.com/security-info) 页面上，
   创建一个可用作 SMTP 密码的应用密码。
<!-- vale gitlab_base.SubstitutionWarning = YES -->
   1. 选择 **添加登录方法**，然后从下拉列表中选择 **应用密码**。
   1. 为应用密码设置一个描述性名称，例如 `GitLab SD`。
   1. 选择 **下一步**。
   1. 复制显示的密码并存储在安全的地方。
   1. 可选。确保您可以使用 [`swaks` 命令行工具](https://www.jetmore.org/john/code/swaks/) 通过 SMTP 发送电子邮件。
   1. 使用您的凭据运行以下命令，并使用应用密码作为 `auth-password`：

      ```shell
      swaks --to your-email@example.com \
            --from custom-email@example.com \
            --auth-user custom-email@example.com \
            --server smtp.office365.com:587 \
            -tls-optional \
            --auth-password <your_app_password>
      ```

接下来，您必须[在 Microsoft 365 中配置电子邮件转发](#configure-email-forwarding-in-microsoft-365)。

<a id="configure-email-forwarding-in-microsoft-365"></a>

#### 在 Microsoft 365 中配置电子邮件转发

以下步骤需要在极狐GitLab 和 Microsoft 365 管理中心之间切换。

在极狐GitLab 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**
1. 展开 **服务台**。
1. 记下 **用于转发电子邮件的服务台电子邮件地址** 下方的电子邮件地址，不包括
   子地址部分。

   如果收件人地址包含子地址（例如极狐GitLab 生成的回复地址）且转发电子邮件地址包含子地址
   （**用于转发电子邮件的服务台电子邮件地址**），则电子邮件不会被转发。

   例如，`incoming+group-project-12346426-issue-@incoming.gitlab.com` 变为 `incoming@incoming.gitlab.com`。
   这没问题，因为 Exchange Online 在转发后会在 `To` 标头中保留自定义电子邮件地址，
   极狐GitLab 可以根据自定义电子邮件地址分配正确的项目。

在 [Microsoft 365 管理中心](https://admin.microsoft.com/Adminportal/Home#/homepage) 中：

<!-- vale gitlab_base.SubstitutionWarning = NO -->
1. 展开 **用户** 部分，然后从菜单中选择 **活跃用户**。
<!-- vale gitlab_base.SubstitutionWarning = YES -->
1. 从列表中选择您要用于自定义电子邮件的账户。
1. 在抽屉中选择 **邮件**。
1. 在 **电子邮件转发** 下方，选择 **管理电子邮件转发**。
1. 勾选 **转发发送到此邮箱的所有电子邮件**。
1. 在 **转发电子邮件地址** 中输入自定义电子邮件表单中的服务台地址，不包括子地址部分。
1. 选择 **保存更改**。

接下来，[使用 Microsoft 365 账户配置自定义电子邮件地址](#configure-custom-email-address-using-a-microsoft-365-account)
以与服务台一起使用。

<a id="configure-custom-email-address-using-a-microsoft-365-account"></a>

#### 使用 Microsoft 365 账户配置自定义电子邮件地址

在极狐GitLab 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**
1. 展开 **服务台** 并找到自定义电子邮件设置。
1. 填写字段：
   - **自定义电子邮件地址**：您的自定义电子邮件地址。
   - **SMTP 主机**：`smtp.office365.com`。
   - **SMTP 端口**：`587`。
   - **SMTP 用户名**：预填为自定义电子邮件地址。
   - **SMTP 密码**：您之前为自定义电子邮件账户创建的应用密码。
   - **SMTP 身份验证方法**：Login。
1. 选择 **保存并测试连接**。
1. 在[验证过程](#verification)之后，您应该能够
   [启用自定义电子邮件地址](#enable-or-disable-the-custom-email-address)。

<a id="known-issues"></a>

### 已知问题

- 一些服务提供商不再允许 SMTP 连接。
  通常，您可以按用户启用它们并创建应用密码。

<a id="use-an-additional-service-desk-alias-email"></a>

## 使用附加的服务台别名电子邮件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为实例使用附加的服务台别名电子邮件地址。

为此，您必须在实例配置中配置
[`service_desk_email`](#configure-service-desk-alias-email)。您还可以配置一个
[自定义后缀](#configure-a-suffix-for-service-desk-alias-email)，用于替换子地址部分上默认的 `-issue-` 部分。

<a id="configure-service-desk-alias-email"></a>

### 配置服务台别名电子邮件

> [!note]
> 在 JihuLab.com 上，已使用 `contact-project+%{key}@incoming.gitlab.com` 作为电子邮件地址配置了自定义邮箱。您仍然可以在项目设置中配置
> [自定义后缀](#configure-a-suffix-for-service-desk-alias-email)。

服务台默认使用[接收邮件](../../../administration/incoming_email.md)
配置。但是，要为服务台拥有单独的电子邮件地址，
请在项目设置中使用[自定义后缀](#configure-a-suffix-for-service-desk-alias-email)配置 `service_desk_email`。

先决条件：

- `address` 必须在地址的 `user` 部分、`@` 之前包含 `+%{key}` 占位符。该占位符用于标识应创建议题的项目。
- `service_desk_email` 和 `incoming_email` 配置必须始终使用单独的邮箱，
  以确保服务台电子邮件被正确处理。

要使用 IMAP 为服务台配置自定义邮箱，请将以下代码片段完整添加到您的配置文件中：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```ruby
gitlab_rails['service_desk_email_enabled'] = true
gitlab_rails['service_desk_email_address'] = "project_contact+%{key}@gmail.com"
gitlab_rails['service_desk_email_email'] = "project_contact@gmail.com"
gitlab_rails['service_desk_email_password'] = "[REDACTED]"
gitlab_rails['service_desk_email_mailbox_name'] = "inbox"
gitlab_rails['service_desk_email_idle_timeout'] = 60
gitlab_rails['service_desk_email_log_file'] = "/var/log/gitlab/mailroom/mail_room_json.log"
gitlab_rails['service_desk_email_host'] = "imap.gmail.com"
gitlab_rails['service_desk_email_port'] = 993
gitlab_rails['service_desk_email_ssl'] = true
gitlab_rails['service_desk_email_start_tls'] = false
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```yaml
service_desk_email:
  enabled: true
  address: "project_contact+%{key}@example.com"
  user: "project_contact@example.com"
  password: "[REDACTED]"
  host: "imap.gmail.com"
  delivery_method: webhook
  secret_file: .gitlab-mailroom-secret
  port: 993
  ssl: true
  start_tls: false
  log_path: "log/mailroom.log"
  mailbox: "inbox"
  idle_timeout: 60
  expunge_deleted: true
```

{{< /tab >}}

{{< /tabs >}}

配置选项与配置
[接收邮件](../../../administration/incoming_email.md#set-it-up) 相同。

<a id="use-encrypted-credentials"></a>

#### 使用加密凭据

您可以选择使用加密文件存储接收邮件凭据，而不是将服务台电子邮件凭据以明文形式存储在配置文件中。

先决条件：

- 要使用加密凭据，您必须首先启用
  [加密配置](../../../administration/encrypted_configuration.md)。

加密文件支持的配置项为：

- `user`
- `password`

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 如果您的服务台配置最初在 `/etc/gitlab/gitlab.rb` 中如下所示：

   ```ruby
   gitlab_rails['service_desk_email_email'] = "service-desk-email@mail.example.com"
   gitlab_rails['service_desk_email_password'] = "examplepassword"
   ```

1. 编辑加密密钥：

   ```shell
   sudo gitlab-rake gitlab:service_desk_email:secret:edit EDITOR=vim
   ```

1. 输入服务台电子邮件密钥的未加密内容：

   ```yaml
   user: 'service-desk-email@mail.example.com'
   password: 'examplepassword'
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并移除 `service_desk` 设置中的 `email` 和 `password`。
1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes 密钥存储服务台电子邮件密码。有关更多信息，
请参阅 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

1. 如果您的服务台配置最初在 `docker-compose.yml` 中如下所示：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'gitlab/gitlab-ee:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['service_desk_email_email'] = "service-desk-email@mail.example.com"
           gitlab_rails['service_desk_email_password'] = "examplepassword"
   ```

1. 进入容器内部，并编辑加密密钥：

   ```shell
   sudo docker exec -t <container_name> bash
   gitlab-rake gitlab:service_desk_email:secret:edit EDITOR=editor
   ```

1. 输入服务台密钥的未加密内容：

   ```yaml
   user: 'service-desk-email@mail.example.com'
   password: 'examplepassword'
   ```

1. 编辑 `docker-compose.yml` 并移除 `service_desk` 设置中的 `email` 和 `password`。
1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 如果您的服务台配置最初在 `/home/git/gitlab/config/gitlab.yml` 中如下所示：

   ```yaml
   production:
     service_desk_email:
       user: 'service-desk-email@mail.example.com'
       password: 'examplepassword'
   ```

1. 编辑加密密钥：

   ```shell
   bundle exec rake gitlab:service_desk_email:secret:edit EDITOR=vim RAILS_ENVIRONMENT=production
   ```

1. 输入服务台密钥的未加密内容：

   ```yaml
   user: 'service-desk-email@mail.example.com'
   password: 'examplepassword'
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并移除 `service_desk_email:` 设置中的 `user` 和 `password`。
1. 保存文件并重启极狐GitLab 和 Mailroom

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="microsoft-graph"></a>

#### Microsoft Graph

可以将 `service_desk_email` 配置为使用 Microsoft
Graph API 而不是 IMAP 读取 Microsoft Exchange Online 邮箱。为 Microsoft Graph 设置 OAuth 2.0 应用程序
[与接收邮件的方式相同](../../../administration/incoming_email.md#microsoft-graph)。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换
   为您想要的值：

   ```ruby
   gitlab_rails['service_desk_email_enabled'] = true
   gitlab_rails['service_desk_email_address'] = "project_contact+%{key}@example.onmicrosoft.com"
   gitlab_rails['service_desk_email_email'] = "project_contact@example.onmicrosoft.com"
   gitlab_rails['service_desk_email_mailbox_name'] = "inbox"
   gitlab_rails['service_desk_email_log_file'] = "/var/log/gitlab/mailroom/mail_room_json.log"
   gitlab_rails['service_desk_email_inbox_method'] = 'microsoft_graph'
   gitlab_rails['service_desk_email_inbox_options'] = {
      'tenant_id': '<YOUR-TENANT-ID>',
      'client_id': '<YOUR-CLIENT-ID>',
      'client_secret': '<YOUR-CLIENT-SECRET>',
      'poll_interval': 60  # Optional
   }
   ```

   对于 Microsoft Cloud for US Government 或[其他 Azure 部署](https://learn.microsoft.com/en-us/graph/deployments)，
   请配置 `azure_ad_endpoint` 和 `graph_endpoint` 设置。例如：

   ```ruby
   gitlab_rails['service_desk_email_inbox_options'] = {
      'azure_ad_endpoint': 'https://login.microsoftonline.us',
      'graph_endpoint': 'https://graph.microsoft.us',
      'tenant_id': '<YOUR-TENANT-ID>',
      'client_id': '<YOUR-CLIENT-ID>',
      'client_secret': '<YOUR-CLIENT-SECRET>',
      'poll_interval': 60  # Optional
   }
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 创建[包含 OAuth 2.0 应用程序客户端密钥的 Kubernetes 密钥](https://gitlab.cn/docs/charts/installation/secrets/#microsoft-graph-client-secret-for-service-desk-emails)：

   ```shell
   kubectl create secret generic service-desk-email-client-secret --from-literal=secret=<YOUR-CLIENT_SECRET>
   ```

1. 创建[用于极狐GitLab 服务台电子邮件身份验证令牌的 Kubernetes 密钥](https://gitlab.cn/docs/charts/installation/secrets/#gitlab-service-desk-email-auth-token)。
   将 `<name>` 替换为极狐GitLab 安装的 [Helm 发布名称](https://helm.sh/docs/intro/using_helm/)：

   ```shell
   kubectl create secret generic <name>-service-desk-email-auth-token --from-literal=authToken=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 32 | base64)
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
     serviceDeskEmail:
       enabled: true
       address: "project_contact+%{key}@example.onmicrosoft.com"
       user: "project_contact@example.onmicrosoft.com"
       mailbox: inbox
       inboxMethod: microsoft_graph
       azureAdEndpoint: https://login.microsoftonline.com
       graphEndpoint: https://graph.microsoft.com
       tenantId: "YOUR-TENANT-ID"
       clientId: "YOUR-CLIENT-ID"
       clientSecret:
         secret: service-desk-email-client-secret
         key: secret
       deliveryMethod: webhook
       authToken:
         secret: <name>-service-desk-email-auth-token
         key: authToken
   ```

   对于 Microsoft Cloud for US Government 或[其他 Azure 部署](https://learn.microsoft.com/en-us/graph/deployments)，
   请配置 `azureAdEndpoint` 和 `graphEndpoint` 设置。这些字段区分大小写：

   ```yaml
   global:
     appConfig:
     serviceDeskEmail:
       [..]
       azureAdEndpoint: https://login.microsoftonline.us
       graphEndpoint: https://graph.microsoft.us
       [..]
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
           gitlab_rails['service_desk_email_enabled'] = true
           gitlab_rails['service_desk_email_address'] = "project_contact+%{key}@example.onmicrosoft.com"
           gitlab_rails['service_desk_email_email'] = "project_contact@example.onmicrosoft.com"
           gitlab_rails['service_desk_email_mailbox_name'] = "inbox"
           gitlab_rails['service_desk_email_log_file'] = "/var/log/gitlab/mailroom/mail_room_json.log"
           gitlab_rails['service_desk_email_inbox_method'] = 'microsoft_graph'
           gitlab_rails['service_desk_email_inbox_options'] = {
             'tenant_id': '<YOUR-TENANT-ID>',
             'client_id': '<YOUR-CLIENT-ID>',
             'client_secret': '<YOUR-CLIENT-SECRET>',
             'poll_interval': 60  # Optional
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

对于 Microsoft Cloud for US Government 或[其他 Azure 部署](https://learn.microsoft.com/en-us/graph/deployments)，
请配置 `azure_ad_endpoint` 和 `graph_endpoint` 设置：

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['service_desk_email_enabled'] = true
           gitlab_rails['service_desk_email_address'] = "project_contact+%{key}@example.onmicrosoft.com"
           gitlab_rails['service_desk_email_email'] = "project_contact@example.onmicrosoft.com"
           gitlab_rails['service_desk_email_mailbox_name'] = "inbox"
           gitlab_rails['service_desk_email_log_file'] = "/var/log/gitlab/mailroom/mail_room_json.log"
           gitlab_rails['service_desk_email_inbox_method'] = 'microsoft_graph'
           gitlab_rails['service_desk_email_inbox_options'] = {
             'azure_ad_endpoint': 'https://login.microsoftonline.us',
             'graph_endpoint': 'https://graph.microsoft.us',
             'tenant_id': '<YOUR-TENANT-ID>',
             'client_id': '<YOUR-CLIENT-ID>',
             'client_secret': '<YOUR-CLIENT-SECRET>',
             'poll_interval': 60  # Optional
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
     service_desk_email:
       enabled: true
       address: "project_contact+%{key}@example.onmicrosoft.com"
       user: "project_contact@example.onmicrosoft.com"
       mailbox: "inbox"
       delivery_method: webhook
       log_path: "log/mailroom.log"
       secret_file: .gitlab-mailroom-secret
       inbox_method: "microsoft_graph"
       inbox_options:
         tenant_id: "<YOUR-TENANT-ID>"
         client_id: "<YOUR-CLIENT-ID>"
         client_secret: "<YOUR-CLIENT-SECRET>"
         poll_interval: 60  # Optional
   ```

   对于 Microsoft Cloud for US Government 或[其他 Azure 部署](https://learn.microsoft.com/en-us/graph/deployments)，
   请配置 `azure_ad_endpoint` 和 `graph_endpoint` 设置。例如：

   ```yaml
     service_desk_email:
       enabled: true
       address: "project_contact+%{key}@example.onmicrosoft.com"
       user: "project_contact@example.onmicrosoft.com"
       mailbox: "inbox"
       delivery_method: webhook
       log_path: "log/mailroom.log"
       secret_file: .gitlab-mailroom-secret
       inbox_method: "microsoft_graph"
       inbox_options:
         azure_ad_endpoint: "https://login.microsoftonline.us"
         graph_endpoint: "https://graph.microsoft.us"
         tenant_id: "<YOUR-TENANT-ID>"
         client_id: "<YOUR-CLIENT-ID>"
         client_secret: "<YOUR-CLIENT-SECRET>"
         poll_interval: 60  # Optional
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-a-suffix-for-service-desk-alias-email"></a>

### 为服务台别名电子邮件配置后缀

您可以在项目的服务台设置中设置自定义后缀。

后缀只能包含小写字母 (`a-z`)、数字 (`0-9`) 或下划线 (`_`)。

配置后，自定义后缀会创建一个新的服务台电子邮件地址，由
`service_desk_email_address` 设置和格式为：`<project_full_path>-<custom_suffix>` 的密钥组成。

先决条件：

- 您必须已配置 [服务台别名电子邮件](#configure-service-desk-alias-email)。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **服务台**。
1. 在 **电子邮件地址后缀** 下方，输入要使用的后缀。
1. 选择 **保存更改**。

例如，假设 `mygroup/myproject` 项目的服务台设置配置了以下内容：

- 电子邮件地址后缀设置为 `support`。
- 服务台电子邮件地址配置为 `contact+%{key}@example.com`。

此项目的服务台电子邮件地址为：`contact+mygroup-myproject-support@example.com`。
[接收邮件](../../../administration/incoming_email.md) 地址仍然有效。

如果您不配置自定义后缀，则使用默认的项目标识来标识
项目。

<a id="configure-email-ingestion-in-multi-node-environments"></a>

## 在多节点环境中配置电子邮件摄取

多节点环境是指极狐GitLab 在多台服务器上运行
以实现可扩展性、容错性和性能的配置。

极狐GitLab 使用一个名为 `mail_room` 的独立进程来摄取来自
`incoming_email` 和 `service_desk_email` 邮箱的新未读电子邮件。

<a id="helm-chart-kubernetes"></a>

### Helm chart（Kubernetes）

[GitLab Helm chart](https://gitlab.cn/docs/charts/) 由多个子 chart 组成，其中之一是
[Mailroom 子 chart](https://gitlab.cn/docs/charts/charts/gitlab/mailroom/)。配置
[`incoming_email` 的通用设置](https://gitlab.cn/docs/charts/installation/command-line-options/#incoming-email-configuration)
和 [`service_desk_email` 的通用设置](https://gitlab.cn/docs/charts/installation/command-line-options/#service-desk-email-configuration)。

<a id="linux-package-omnibus"></a>

### Linux 软件包（Omnibus）

在多节点 Linux 软件包安装环境中，仅在一个节点上运行 `mail_room`。可以在单个
`rails` 节点上运行（例如，`application_role`）
或完全单独运行。

<a id="set-up-all-nodes"></a>

#### 设置所有节点

1. 在每个节点上为 `incoming_email` 和 `service_desk_email` 添加基本配置，
   以在 Web UI 和生成的电子邮件中呈现电子邮件地址。

   在 `/etc/gitlab/gitlab.rb` 中找到 `incoming_email` 或 `service_desk_email` 部分：

   {{< tabs >}}

   {{< tab title="`incoming_email`" >}}

   ```ruby
   gitlab_rails['incoming_email_enabled'] = true
   gitlab_rails['incoming_email_address'] = "incoming+%{key}@example.com"
   ```

   {{< /tab >}}

   {{< tab title="`service_desk_email`" >}}

   ```ruby
   gitlab_rails['service_desk_email_enabled'] = true
   gitlab_rails['service_desk_email_address'] = "project_contact+%{key}@example.com"
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 极狐GitLab 提供两种方法将电子邮件从 `mail_room` 传输到极狐GitLab
   应用程序。您可以为每个电子邮件设置单独配置 `delivery_method`：
   1. 推荐（默认）：`webhook` 通过 API POST 请求将电子邮件负载发送到您的极狐GitLab
      应用程序。它使用共享令牌进行身份验证。如果您选择此方法，
      请确保 `mail_room` 进程可以访问 API 端点，并在所有应用程序节点之间分发共享
      令牌。

      {{< tabs >}}

      {{< tab title="`incoming_email`" >}}

      ```ruby
      gitlab_rails['incoming_email_delivery_method'] = "webhook"

      # The URL that mail_room can contact. You can also use an internal URL or IP,
      # just make sure mail_room can access the GitLab API with that address.
      # Do not end with "/".
      gitlab_rails['incoming_email_gitlab_url'] = "https://gitlab.example.com"

      # The shared secret file that should contain a random token. Make sure it's the same on every node.
      gitlab_rails['incoming_email_secret_file'] = ".gitlab_mailroom_secret"
      ```

      {{< /tab >}}

      {{< tab title="`service_desk_email`" >}}

      ```ruby
      gitlab_rails['service_desk_email_delivery_method'] = "webhook"

      # The URL that mail_room can contact. You can also use an internal URL or IP,
      # just make sure mail_room can access the GitLab API with that address.
      # Do not end with "/".

      gitlab_rails['service_desk_email_gitlab_url'] = "https://gitlab.example.com"

      # The shared secret file that should contain a random token. Make sure it's the same on every node.
      gitlab_rails['service_desk_email_secret_file'] = ".gitlab_mailroom_secret"
      ```

      {{< /tab >}}

      {{< /tabs >}}

   1. 如果您在使用 `webhook` 设置时遇到问题，请使用 `sidekiq` 通过 Redis 将电子邮件负载直接传送到极狐GitLab Sidekiq。

      {{< tabs >}}

      {{< tab title="`incoming_email`" >}}

      ```ruby
      # It uses the Redis configuration to directly add Sidekiq jobs
      gitlab_rails['incoming_email_delivery_method'] = "sidekiq"
      ```

      {{< /tab >}}

      {{< tab title="`service_desk_email`" >}}

      ```ruby
      # It uses the Redis configuration to directly add Sidekiq jobs
      gitlab_rails['service_desk_email_delivery_method'] = "sidekiq"
      ```

      {{< /tab >}}

      {{< /tabs >}}

1. 在所有不应运行电子邮件摄取的节点上禁用 `mail_room`。例如，在 `/etc/gitlab/gitlab.rb` 中：

   ```ruby
   mailroom['enable'] = false
   ```

1. [重新配置极狐GitLab](../../../administration/restart_gitlab.md) 以使更改生效。

<a id="set-up-a-single-email-ingestion-node"></a>

#### 设置单个电子邮件摄取节点

设置所有节点并禁用 `mail_room` 进程后，在单个节点上启用 `mail_room`。
此节点定期轮询 `incoming_email` 和 `service_desk_email` 的邮箱，并将
新的未读电子邮件移动到极狐GitLab。

1. 选择一个额外处理电子邮件摄取的现有节点。
1. 为 `incoming_email` 和 `service_desk_email` 添加[完整配置和凭据](../../../administration/incoming_email.md#configuration-examples)。
1. 在此节点上启用 `mail_room`。例如，在 `/etc/gitlab/gitlab.rb` 中：

   ```ruby
   mailroom['enable'] = true
   ```

1. 在此节点上[重新配置极狐GitLab](../../../administration/restart_gitlab.md) 以使更改生效。

<a id="turn-off-service-desk-for-multiple-projects"></a>

## 为多个项目关闭服务台

要关闭命名空间中多个项目的服务台，请使用
[API](../../../api/projects.md#turn-off-service-desk-for-multiple-projects) 或在
极狐GitLab 私有化部署上使用 [Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。

为群组或命名空间中的项目关闭服务台后，以下情况适用：

- 项目成员可以重新打开服务台。
- 您之后创建的项目默认将服务台设置为启用状态。

> [!warning]
> 更改数据的命令如果运行不正确或在不适当的条件下运行，可能会造成损害。始终先在测试环境中运行命令，并准备好备份实例以供恢复。

要关闭命名空间中所有项目的服务台，请运行以下命令。
将 `my-namespace` 替换为群组或个人命名空间的完整路径。

```ruby
namespace = Namespace.find_by_full_path!('my-namespace')
scope = namespace.is_a?(Group) ? namespace.all_projects : namespace.projects

scope.where(service_desk_enabled: true).each_batch(of: 100) do |batch|
  batch.update_all(service_desk_enabled: false)
end
```

要为某些项目保持服务台启用，请排除这些项目的 ID：

```ruby
keep_ids = [42, 1337]
namespace = Namespace.find_by_full_path!('my-namespace')
scope = namespace.is_a?(Group) ? namespace.all_projects : namespace.projects

scope.where(service_desk_enabled: true).where.not(id: keep_ids).each_batch(of: 100) do |batch|
  batch.update_all(service_desk_enabled: false)
end
```
