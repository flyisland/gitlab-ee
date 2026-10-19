---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 AWS 集成，在私有化部署实例上设置和管理极狐GitLab Duo with Amazon Q。
title: 设置极狐GitLab Duo with Amazon Q
---

{{< details >}}

- Tier: 旗舰版
- Add-on: 极狐GitLab Duo with Amazon Q
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 极狐GitLab Duo with Amazon Q 不能与其他极狐GitLab Duo 附加组件组合使用。

如需获取极狐GitLab Duo with Amazon Q 订阅，请联系您的客户经理。

如需申请试用，请[填写此表单](https://about.gitlab.com/partners/technology-partners/aws/#form)。

要在极狐GitLab 私有化部署上设置极狐GitLab Duo with Amazon Q，请完成以下步骤。

<a id="set-up-gitlab-duo-with-amazon-q"></a>

## 设置极狐GitLab Duo with Amazon Q

要设置极狐GitLab Duo with Amazon Q，您必须：

- [完成先决条件](#prerequisites)
- [在 Amazon Q Developer 控制台中创建配置文件](#create-a-profile-in-the-amazon-q-developer-console)
- [创建身份提供商](#create-an-iam-identity-provider)
- [创建 IAM 角色](#create-an-iam-role)
- [编辑角色](#edit-the-role)
- [在极狐GitLab 中输入 ARN 并启用 Amazon Q](#enter-the-arn-in-gitlab-and-enable-amazon-q)
- [允许管理员使用客户托管密钥](#allow-administrators-to-use-customer-managed-keys)

<a id="prerequisites"></a>

### 先决条件

- 您必须拥有极狐GitLab 私有化部署：
  - 版本为极狐GitLab 17.11 或更高版本。
  - Amazon Q 在执行请求的操作时使用极狐GitLab 实例的 REST API 读写数据，并且必须能够访问您的 HTTPS URL（[SSL 证书不能是自签名证书](https://gitlab.cn/docs/omnibus/settings/ssl/)）。
  - 实例必须允许来自以下 IP 地址的 Amazon Q 服务的入站网络访问，使用您实例所配置端口上的 TCP/TLS。该端口[默认为 443](../../administration/package_information/defaults.md#ports)。
    - `34.228.181.128`
    - `44.219.176.187`
    - `54.226.244.221`
  - 拥有与极狐GitLab 同步的旗舰版订阅，以及
    极狐GitLab Duo with Amazon Q 附加组件。

<a id="create-a-profile-in-the-amazon-q-developer-console"></a>

### 在 Amazon Q Developer 控制台中创建配置文件

创建 Amazon Q Developer 配置文件。

1. 打开 [Amazon Q Developer 控制台](https://us-east-1.console.aws.amazon.com/amazonq/developer/home#/gitlab)。
1. 选择 **Amazon Q Developer in GitLab**。
1. 选择 **开始使用**。
1. 在 **配置文件名称**中，为您所在的区域输入唯一的配置文件名称。例如，`QDevProfile-us-east-1`。
1. 可选。在 **配置文件描述（可选）**中，输入描述。
1. 选择 **创建**。

<a id="create-an-iam-identity-provider"></a>

### 创建 IAM 身份提供商

创建 IAM 身份提供商。首先，从极狐GitLab 中获取一些值。

先决条件：

- 您必须是管理员。

1. 登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **极狐GitLab Duo with Amazon Q**。
1. 选择 **查看配置设置**。
1. 在步骤 1 下，复制提供商 URL 和受众。下一步中您将需要它们。

现在，创建 AWS 身份提供商：

1. 登录 [AWS IAM 控制台](https://console.aws.amazon.com/iam)。
1. 选择 **访问管理** > **身份提供商**。
1. 选择 **添加提供商**。
1. 在 **提供商类型**中，选择 **OpenID Connect**。
1. 在 **提供商 URL**中，输入从极狐GitLab 获取的值。
1. 在 **受众**中，输入从极狐GitLab 获取的值。
1. 选择 **添加提供商**。

<a id="create-an-iam-role"></a>

### 创建 IAM 角色

接下来，您必须创建一个信任该 IAM 身份提供商且能够访问 Amazon Q 的 IAM 角色。

> [!note]
> 设置 IAM 角色后，您无法更改与该角色关联的 AWS 账户。

1. 在 AWS IAM 控制台中，选择 **访问管理** > **角色** > **创建角色**。
1. 选择 **Web 身份**。
1. 在 **Web 身份**中，选择您之前输入的提供商 URL。
1. 在 **受众**中，选择您之前输入的受众值。
1. 选择 **下一步**。
1. 在 **添加权限** 页面上：
   - 要使用托管策略，请在 **权限策略**中搜索并
     选择 `GitLabDuoWithAmazonQPermissionsPolicy`。
   - 要创建内联策略，请选择 **下一步** 跳过 **权限策略**。
     稍后您将创建策略。
1. 选择 **下一步**。
1. 为角色命名，例如 `QDeveloperAccess`。
1. 确保信任策略正确。它应如下所示：

   ```json
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {
                "Federated": "arn:aws:iam::<AWS_Account_ID>:oidc-provider/auth.token.gitlab.com/cc/oidc/<Instance_ID>"
            },
            "Condition": {
                "StringEquals": {
                    "auth.token.gitlab.com/cc/oidc/<Instance_ID>:aud": "gitlab-cc-<Instance_ID>"
                },

            }
         }
      ]
   }
   ```

1. 选择 **创建角色**。

<a id="create-an-inline-policy-optional"></a>

### 创建内联策略（可选）

要创建内联策略，而不是使用托管策略：

1. 选择 **权限** > **添加权限** > **创建内联策略**。
1. 选择 **JSON**，并将以下内容粘贴到编辑器中：

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "GitLabDuoUsagePermissions",
         "Effect": "Allow",
         "Action": [
           "q:SendEvent",
           "q:CreateAuthGrant",
           "q:UpdateAuthGrant",
           "q:GenerateCodeRecommendations",
           "q:SendMessage",
           "q:ListPlugins",
           "q:VerifyOAuthAppConnection"
         ],
         "Resource": "*"
       },
       {
         "Sid": "GitLabDuoManagementPermissions",
         "Effect": "Allow",
         "Action": [
           "q:CreateOAuthAppConnection",
           "q:DeleteOAuthAppConnection"
         ],
         "Resource": "*"
       },
       {
         "Sid": "GitLabDuoPluginPermissions",
         "Effect": "Allow",
         "Action": [
           "q:CreatePlugin",
           "q:DeletePlugin",
           "q:GetPlugin"
         ],
         "Resource": "arn:aws:qdeveloper:*:*:plugin/GitLabDuoWithAmazonQ/*"
       }
     ]
   }
   ```

1. 选择 **操作** > **优化可读性**，让 AWS 格式化并解析该 JSON。
1. 选择 **下一步**。
1. 将策略命名为 `gitlab-duo-amazon-q-policy`，然后选择 **创建策略**。

<a id="edit-the-role"></a>

### 编辑角色

现在编辑该角色：

1. 找到您刚刚创建的角色并选择它。
1. 将会话时间更改为 12 小时。如果会话未设置为 12 小时或更长时间，`AssumeRoleWithWebIdentity` 将在 AI 网关中失败。

   1. 在 **角色搜索** 字段中，输入您的 IAM 角色名称，然后选择该角色名称。
   1. 在 **摘要**中，选择 **编辑** 以编辑会话持续时间。
   1. 选择 **最长会话持续时间** 下拉列表，然后选择 **12 小时**。
   1. 选择 **保存更改**。

1. 复制页面上列出的 ARN。它看起来类似于此：

   ```plaintext
   arn:aws:iam::123456789:role/QDeveloperAccess
   ```

<a id="enter-the-arn-in-gitlab-and-enable-amazon-q"></a>

### 在极狐GitLab 中输入 ARN 并启用 Amazon Q

现在，将 ARN 输入到极狐GitLab 中，并确定哪些群组和项目可以访问该功能。

先决条件：

- 您必须是极狐GitLab 管理员。

要完成极狐GitLab Duo with Amazon Q 的设置：

1. 登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **极狐GitLab Duo with Amazon Q**。
1. 选择 **查看配置设置**。
1. 在 **IAM 角色的 ARN** 下，粘贴 ARN。
1. 要确定哪些群组和项目可以使用极狐GitLab Duo with Amazon Q，请选择一个选项：
   - 要为实例开启该功能，但允许群组和项目将其关闭，请选择 **默认开启**。
     - 可选。要配置 Amazon Q 自动评审合并请求中的代码，请选择 **让 Amazon Q 自动审查合并请求中的代码**。
   - 要为实例关闭该功能，但允许群组和项目将其开启，请选择 **默认关闭**。
   - 要为实例关闭该功能，并阻止群组或项目将其开启，请选择 **始终关闭**。

1. 选择 **保存更改**。

保存时，API 应联系 AI 网关，以在 Amazon Q 上创建 OAuth 应用程序。

要确认操作成功：

- 在 Amazon CloudWatch 控制台日志中，检查是否有 `204` 状态码。有关更多信息，请参阅
  [什么是 Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)？
- 在极狐GitLab 中，会显示一条内容为 `Amazon Q settings have been saved`的通知。
- 在极狐GitLab 中，在左侧边栏中，选择 **应用程序**。将显示 Amazon Q OAuth 应用程序。

<a id="allow-administrators-to-use-customer-managed-keys"></a>

## 允许管理员使用客户托管密钥

如果您是管理员，可以使用 AWS Key Management Service (AWS KMS)
客户托管密钥 (CMK) 来加密客户数据。

当您在 KMS 控制台中为已配置的角色创建密钥策略时，请更新角色策略以授予使用 CMK 的权限。

`kms:ViaService` 条件键将 KMS 密钥的使用限制为来自指定 AWS 服务的请求。此外，它还用于在请求来自特定服务时拒绝使用 KMS 密钥的权限。借助该条件键，您可以限制谁可以使用 CMK 加密或解密内容。

```json
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "Sid0",
         "Effect": "Allow",
         "Principal": {
            "AWS": "arn:aws:iam::<awsAccountId>:role/<rolename>"
         },
         "Action": [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:GenerateDataKey",
            "kms:GenerateDataKeyWithoutPlaintext",
            "kms:ReEncryptFrom",
            "kms:ReEncryptTo"
         ],
         "Resource": "*",
         "Condition": {
            "StringEquals": {
                "kms:ViaService": [
                    "q.<region>.amazonaws.com"
                ]
            }
        }
      }
   ]
}
```

有关更多信息，请参阅 [AWS KMS 开发人员指南中的 `kms:ViaService`](https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html#conditions-kms-via-service)。

<a id="configure-gitlab-to-use-aws-hosted-ai-gateway"></a>

## 配置极狐GitLab 以使用 AWS 托管的 AI 网关

您可以配置极狐GitLab 以使用 AWS 上托管的 AI 网关。

> [!warning]
> 更改数据的命令如果未正确运行或未在正确的条件下运行，可能会造成损害。
> 请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

1. 启动 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。例如，对于使用 Linux 软件包的安装，请运行：

   ```shell
   sudo gitlab-rails console
   ```

1. 要查看当前分配的服务 URL，请运行：

   ```ruby
   ApplicationSetting.current.ai_gateway_url
   ```

1. 要更新服务 URL，请运行：

   ```ruby
   ApplicationSetting.current.update!(ai_gateway_url: "https://cloud.gitlab.com/aws/ai")
   ```

<a id="turn-off-gitlab-duo-with-amazon-q"></a>

## 关闭极狐GitLab Duo with Amazon Q

您可以为实例、群组或项目关闭极狐GitLab Duo with Amazon Q。

<a id="turn-off-for-the-instance"></a>

### 为实例关闭

先决条件：

- 您必须是管理员。

要为实例关闭极狐GitLab Duo with Amazon Q：

1. 登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **极狐GitLab Duo with Amazon Q**。
1. 选择 **查看配置设置**。
1. 选择 **始终关闭**。
1. 选择 **保存更改**。

<a id="turn-off-for-a-group"></a>

### 为群组关闭

先决条件：

- 您必须拥有群组的所有者角色。

要为群组关闭极狐GitLab Duo with Amazon Q：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **Amazon Q**。
1. 选择一个选项：
   - 要为该群组关闭该功能，但允许其他群组或项目将其开启，请选择 **默认关闭**。
   - 要为该群组关闭该功能，并阻止其他群组或项目将其开启，请选择 **始终关闭**。
1. 选择 **保存更改**。

<a id="turn-off-for-a-project"></a>

### 为项目关闭

先决条件：

- 您必须拥有项目的所有者角色。

要为项目关闭极狐GitLab Duo with Amazon Q：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **Amazon Q** 下，关闭开关。
1. 选择 **保存更改**。

<a id="troubleshooting"></a>

## 故障排除

如果您在将极狐GitLab 连接到 Amazon Q 时遇到问题，请确保您的极狐GitLab 安装满足[所有先决条件](#prerequisites)。

您还可能遇到以下问题。

<a id="gitlab-instance-uuid-mismatch"></a>

### 极狐GitLab 实例 UUID 不匹配

当您断开 Amazon Q 连接时，可能会遇到 `GitLab instance UUID mismatch` 错误，或者在运行健康检查时遇到 `Cannot obtain OIDC token` 错误。例如：

```plaintext
Authentication with the AI gateway services failed: AI Gateway returned code 500: {"detail":"Cannot obtain OIDC token"}
Amazon Q connectivity check failed: Cannot obtain OIDC token
```

这些错误通常在以下情况下发生：

- 极狐GitLab 实例已从备份中恢复。
- 极狐GitLab 实例已迁移到新的基础设施。
- 极狐GitLab 实例 UUID 因任何其他原因发生了更改。

要确认 UUID 不匹配是根本原因，请继续执行以下验证步骤。

<a id="validate"></a>

#### 验证

1. 登录托管极狐GitLab 的 EC2 实例。
1. 访问 Rails 控制台。
1. 获取当前 UUID：`Gitlab::CurrentSettings.current_application_settings.uuid`
1. 获取 JWT 令牌：

   ```ruby
   token = CloudConnector::Tokens.get(unit_primitive: :agent_quick_actions, resource: :instance)
   JWT.decode(token, false, nil)
   ```

当步骤 3 中的 `sub` 字段与步骤 4 中的 `gitlab_instance_uuid` 之间存在 UUID 不匹配时，问题就会显现。

要解决此问题，请完成以下步骤。

1. 移除所有有效许可证。
1. 删除所有订阅附加组件购买记录：

   打开 Rails 控制台并执行：

   ```ruby
   GitlabSubscriptions::AddOnPurchase.all.destroy_all
   ```

1. 执行实例 UUID 重置。
   在 Rails 控制台中，执行：

   ```ruby
   ApplicationSetting.update!(uuid: SecureRandom.uuid)
   ```

1. 应用有效许可证。
1. 等待大约一分钟并同步许可证。此操作会强制重新生成云连接器令牌。（如果不执行此步骤，会出现请求头不匹配。）
1. 使用新的 UUID 更新 IdP 和 IAM 角色。
1. 选择下一步操作：
   - 使用新的 UUID 更新现有的 IdP 和 IAM 角色，继续使用现有设置，并继续使用极狐GitLab Duo with Amazon Q。
   - 退出：
     1. 从极狐GitLab Duo with Amazon Q 退出。
     1. 如有需要，设置新的连接。

完成后，UUID 不匹配问题应已解决，极狐GitLab Duo with Amazon Q 应能使用新配置正常运行。
