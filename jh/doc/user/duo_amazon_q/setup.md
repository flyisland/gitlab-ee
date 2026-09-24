---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Set up and manage 极狐GitLab Duo with Amazon Q on a Self-Managed instance using AWS integration.
title: 设置 极狐GitLab Duo with Amazon Q
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.7 中作为[实验](../../policy/development_stages_support.md#experiment)引入，并带有一个名为 `amazon_q_integration` 的功能标志，默认禁用。
- 功能标志 `amazon_q_integration` 在极狐GitLab 17.8 中移除。
- 在极狐GitLab 17.11 中 GA。

{{< /history >}}

> [!note]
> 极狐GitLab Duo with Amazon Q 无法与其他极狐GitLab Duo 附加组件组合使用。

要获取 极狐GitLab Duo with Amazon Q 的订阅，请联系您的客户经理。

要申请试用，[请填写此表单](https://gitlab.cn/partners/technology-partners/aws/#form)。

要在私有化部署的极狐GitLab上设置 极狐GitLab Duo with Amazon Q，请完成以下步骤。

<a id="set-up-gitlab-duo-with-amazon-q"></a>

# 设置 极狐GitLab Duo with Amazon Q

要设置 极狐GitLab Duo with Amazon Q，您必须：

- [完成先决条件](#prerequisites)
- [在 Amazon Q Developer 控制台中创建配置](#create-a-profile-in-the-amazon-q-developer-console)
- [创建 IAM 身份提供者](#create-an-iam-identity-provider)
- [创建 IAM 角色](#create-an-iam-role)
- [编辑角色](#edit-the-role)
- [在极狐GitLab中输入ARN并启用Amazon Q](#enter-the-arn-in-gitlab-and-enable-amazon-q)
- [允许管理员使用客户管理密钥](#allow-administrators-to-use-customer-managed-keys)

<a id="prerequisites"></a>

### 先决条件

- 您必须拥有私有化部署的极狐GitLab：
  - 在极狐GitLab 17.11 或更高版本上运行。
  - Amazon Q 在执行请求的操作时，会使用极狐GitLab实例的 REST API 读取和写入数据，并且必须能够访问您的 HTTPS URL（[SSL 证书不得为自签名](https://gitlab.cn/docs/omnibus/settings/ssl/)）。
  - 实例必须允许来自以下 IP 地址的 Amazon Q 服务的入站网络访问，通过 TCP/TLS 在您的实例配置的端口上进行。该端口[默认为 443](../../administration/package_information/defaults.md#ports)。
    - `34.228.181.128`
    - `44.219.176.187`
    - `54.226.244.221`
  - 拥有与极狐GitLab同步的旗舰版订阅以及 极狐GitLab Duo with Amazon Q 附加组件。

<a id="create-a-profile-in-the-amazon-q-developer-console"></a>

### 在 Amazon Q Developer 控制台中创建配置

创建一个 Amazon Q Developer 配置。

1. 打开 [Amazon Q Developer 控制台](https://us-east-1.console.aws.amazon.com/amazonq/developer/home#/gitlab)。
1. 选择 **Amazon Q Developer in GitLab**。
1. 选择 **开始使用**。
1. 在 **配置名称** 中输入您区域的唯一配置名称。例如，`QDevProfile-us-east-1`。
1. 可选。在 **配置描述 - 可选** 中输入描述。
1. 选择 **创建**。

<a id="create-an-iam-identity-provider"></a>

### 创建 IAM 身份提供者

接下来，创建一个 IAM 身份提供者。

首先，您需要从 GitLab 获取一些值：

先决条件：

- 您必须是管理员。

1. 登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo with Amazon Q**。
1. 选择 **查看配置设置**。
1. 在步骤 1 下，复制提供者 URL 和受众。下一步会用到它们。

现在，创建一个 AWS 身份提供者：

1. 登录 [AWS IAM 控制台](https://console.aws.amazon.com/iam)。
1. 选择 **访问管理** > **身份提供者**。
1. 选择 **添加提供者**。
1. 在 **提供者类型** 中选择 **OpenID Connect**。
1. 在 **提供者 URL** 中输入来自极狐GitLab的值。
1. 在 **受众** 中输入来自极狐GitLab的值。
1. 选择 **添加提供者**。

<a id="create-an-iam-role"></a>

### 创建 IAM 角色

接下来，您必须创建一个信任该 IAM 身份提供者并能访问 Amazon Q 的 IAM 角色。

> [!note]
> 设置 IAM 角色后，无法更改与该角色关联的 AWS 账户。

1. 在 AWS IAM 控制台中，选择 **访问管理** > **角色** > **创建角色**。
1. 选择 **Web 身份**。
1. 在 **Web 身份** 中选择您之前输入的提供者 URL。
1. 在 **受众** 中选择您之前输入的受众值。
1. 选择 **下一步**。
1. 在 **添加权限** 页面上：
   - 要使用托管策略，在 **权限策略** 中搜索并选择 `GitLabDuoWithAmazonQPermissionsPolicy`。
   - 要创建内联策略，请跳过 **权限策略**，直接选择 **下一步**。您稍后将创建策略。
1. 选择 **下一步**。
1. 命名角色，例如 `QDeveloperAccess`。
1. 确保信任策略正确无误。它应该如下所示：

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

要创建内联策略而非使用托管策略：

1. 选择 **权限** > **添加权限** > **创建内联策略**。
1. 选择 **JSON** 并将以下内容粘贴到编辑器中：

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

1. 选择 **操作** > **优化可读性** 让 AWS 格式化并解析该 JSON。
1. 选择 **下一步**。
1. 将策略命名为 `gitlab-duo-amazon-q-policy` 并选择 **创建策略**。

<a id="edit-the-role"></a>

### 编辑角色

现在编辑角色：

1. 找到您刚刚创建的角色并选中。
1. 将会话时间更改为 12 小时。如果会话未设置为 12 小时或更长，AI Gateway 中的 `AssumeRoleWithWebIdentity` 将失败。

   1. 在 **角色搜索** 字段中，输入您的 IAM 角色名称，然后选择该角色名称。
   1. 在 **摘要** 中，选择 **编辑** 来编辑会话持续时间。
   1. 选择 **最大会话持续时间** 下拉列表，然后选择 **12 小时**。
   1. 选择 **保存更改**。

1. 复制页面上列出的 ARN。它看起来类似于以下内容：

   ```plaintext
   arn:aws:iam::123456789:role/QDeveloperAccess
   ```

<a id="enter-the-arn-in-gitlab-and-enable-amazon-q"></a>

### 在极狐GitLab中输入ARN并启用Amazon Q

现在，将 ARN 输入极狐GitLab并确定哪些群组和项目可以使用此功能。

先决条件：

- 您必须是极狐GitLab管理员。

要完成 极狐GitLab Duo with Amazon Q 的设置：

1. 登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo with Amazon Q**。
1. 选择 **查看配置设置**。
1. 在 **IAM 角色的 ARN** 下，粘贴 ARN。
1. 要确定哪些群组和项目可以使用 极狐GitLab Duo with Amazon Q，选择一个选项：
   - 要为实例启用，但允许群组和项目禁用它，请选择 **默认开启**。
     - 可选。要配置 Amazon Q 自动审查合并请求中的代码，请选择 **让 Amazon Q 自动审查合并请求中的代码**。
   - 要为实例禁用，但允许群组和项目启用它，请选择 **默认关闭**。
   - 要为实例禁用，并阻止群组或项目启用它，请选择 **始终关闭**。

1. 选择 **保存更改**。

保存时，API 应联系 AI Gateway 以在 Amazon Q 上创建 OAuth 应用程序。

要确认成功：

- 在 Amazon CloudWatch 控制台日志中，检查 `204` 状态码。有关更多信息，请参阅[什么是 Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)？
- 在极狐GitLab中，会显示一条通知，内容为 `Amazon Q 设置已保存`。
- 在极狐GitLab的左侧边栏中，选择 **应用程序**。将显示 Amazon Q OAuth 应用程序。

<a id="allow-administrators-to-use-customer-managed-keys"></a>

## 允许管理员使用客户管理密钥

如果您是管理员，可以使用 AWS Key Management Service (AWS KMS) 客户管理密钥 (CMK) 来加密客户数据。

更新角色策略以在 KMS 控制台中配置的角色上使用 CMK 时授予权限。

`kms:ViaService` 条件键将 KMS 密钥的使用限制为来自特定 AWS 服务的请求。
此外，它还用于在请求来自特定服务时拒绝使用 KMS 密钥的权限。
使用该条件键，您可以限制谁可以使用 CMK 进行加密或解密内容。

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

有关更多信息，请参阅 [AWS KMS 开发者指南中的 `kms:ViaService`](https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html#conditions-kms-via-service)。

<a id="configure-gitlab-to-use-aws-hosted-ai-gateway"></a>

## 配置极狐GitLab使用AWS托管的AI网关

您可以配置极狐GitLab使用 AWS 上托管的 AI Gateway。

1. 启动 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。例如，对于使用 Linux 软件包的安装，请运行：

   ```shell
   sudo gitlab-rails console
   ```

1. 要查看当前分配的服务 URL，请运行：

   ```ruby
   Ai::Setting.instance.ai_gateway_url
   ```

1. 要更新服务 URL，请运行：

   ```ruby
   Ai::Setting.instance.update!(ai_gateway_url: "https://cloud.jihulab.com/aws/ai")
   ```

<a id="turn-off-gitlab-duo-with-amazon-q"></a>

## 关闭 极狐GitLab Duo with Amazon Q

您可以为实例、群组或项目关闭 极狐GitLab Duo with Amazon Q。

<a id="turn-off-for-the-instance"></a>

### 为实例关闭

先决条件：

- 您必须是管理员。

要为实例关闭 极狐GitLab Duo with Amazon Q：

1. 登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo with Amazon Q**。
1. 选择 **查看配置设置**。
1. 选择 **始终关闭**。
1. 选择 **保存更改**。

<a id="turn-off-for-a-group"></a>

### 为群组关闭

先决条件：

- 您必须拥有某个群组的所有者角色。

要为群组关闭 极狐GitLab Duo with Amazon Q：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **Amazon Q**。
1. 选择一个选项：
   - 要为该群组关闭，但允许其他群组或项目启用它，请选择 **默认关闭**。
   - 要为该群组关闭，并阻止其他群组或项目启用它，请选择 **始终关闭**。
1. 选择 **保存更改**。

<a id="turn-off-for-a-project"></a>

### 为项目关闭

先决条件：

- 您必须拥有某个项目的所有者角色。

要为项目关闭 极狐GitLab Duo with Amazon Q：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **Amazon Q** 下，关闭开关。
1. 选择 **保存更改**。

<a id="troubleshooting"></a>

## 故障排除

如果您在将极狐GitLab连接到 Amazon Q 时遇到问题，请确保您的极狐GitLab安装满足[所有先决条件](#prerequisites)。

您也可能会遇到以下问题。

<a id="gitlab-instance-uuid-mismatch"></a>

### 极狐GitLab实例UUID不匹配

断开 Amazon Q 连接时，您可能会遇到 `GitLab instance UUID mismatch` 错误。此问题通常发生在以下情况下：

- 极狐GitLab实例已从备份恢复。
- 极狐GitLab实例已迁移至新基础设施。
- 极狐GitLab实例 UUID 因其他任何原因发生更改。

要确认 UUID 不匹配是根本原因，请执行以下验证步骤。

<a id="validate"></a>

#### 验证

1. 登录托管 GitLab 的 EC2 实例。
1. 访问 Rails 控制台。
1. 获取当前 UUID：`Gitlab::CurrentSettings.current_application_settings.uuid`
1. 获取 JWT 令牌：

   ```ruby
   token = CloudConnector::Tokens.get(unit_primitive: :agent_quick_actions, resource: :instance)
   JWT.decode(token, false, nil)
   ```

当步骤 3 中 `sub` 字段的 UUID 与步骤 4 中的 `gitlab_instance_uuid` 之间存在不匹配时，问题就很明显了。

要解决此问题，请完成以下步骤。

1. 移除所有有效的许可证。
1. 删除所有订阅附加组件购买项：

   打开 Rails 控制台并执行：

   ```ruby
   GitlabSubscriptions::AddOnPurchase.all.destroy_all
   ```

1. 执行实例 UUID 重置。
   在 Rails 控制台中执行：

   ```ruby
   ApplicationSetting.update!(uuid: SecureRandom.uuid)
   ```

1. 应用有效的许可证。
1. 等待一分钟左右，然后同步许可证。此操作会强制重新生成云连接器令牌。（如果不执行此步骤，则会出现标头不匹配。）
1. 使用新的 UUID 更新 IdP 和 IAM 角色。
1. 选择下一步：
   - 通过使用新的 UUID 更新现有 IdP 和 IAM 角色，继续使用现有设置并继续使用 极狐GitLab Duo with Amazon Q。
   - 注销：
     1. 从 极狐GitLab Duo with Amazon Q 注销。
     1. 如果需要，建立新的连接。

完成后，UUID 不匹配问题应得到解决，并且 极狐GitLab Duo with Amazon Q 应能使用新配置正常运行。