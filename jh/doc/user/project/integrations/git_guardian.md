---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将极狐GitLab 与 GitGuardian 集成，以便在策略违规和安全问题被利用之前收到相关告警。
title: GitGuardian
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[GitGuardian](https://www.gitguardian.com/) 是一项密钥检测服务，可在源代码仓库中发现硬编码的凭据，例如 API 密钥、密码和令牌。启用此集成后，极狐GitLab 会将每次推送发送到 GitGuardian 进行扫描。
如果 GitGuardian 检测到密钥，极狐GitLab 会阻止该推送。

您可以配置极狐GitLab，使其根据 GitGuardian 策略拒绝提交。

要设置 GitGuardian 集成：

1. [创建 GitGuardian API 令牌](#create-a-gitguardian-api-token)。
1. [为您的项目设置 GitGuardian 集成](#set-up-the-gitguardian-integration-for-your-project)。

<a id="create-a-gitguardian-api-token"></a>

## 创建 GitGuardian API 令牌

先决条件：

- 您必须拥有 GitGuardian 账号。

要创建 API 令牌：

1. 登录您的 GitGuardian 账号。
1. 在边栏中转到 **API** 部分。
1. 在 API 部分的边栏中，转到**个人访问令牌**页面。
1. 选择**创建令牌**。系统会打开令牌创建对话框。
1. 提供您的令牌信息：
   - 为您的 API 令牌指定一个有意义的名称，以标识其用途。
     例如，`GitLab integration token`。
   - 选择合适的有效期。
   - 选中**扫描范围**复选框。
     这是该集成唯一需要的选项。
1. 选择**创建令牌**。
1. 生成令牌后，将其复制到剪贴板。
   此令牌属于敏感信息，请妥善保管。

现在，您已成功创建了一个可用于该集成的 GitGuardian API 令牌。

<a id="set-up-the-gitguardian-integration-for-your-project"></a>

## 为您的项目设置 GitGuardian 集成

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

创建并复制 API 令牌后，配置极狐GitLab 以拒绝提交：

要为您的项目启用该集成：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **GitGuardian**。
1. 在**启用集成**中，选中**活跃**复选框。
1. 可选。在 **API 端点**文本框中，输入您的 GitGuardian 实例的基础 URL：
   - 对于自部署的 GitGuardian，输入您的实例 URL（例如，`https://gitguardian.example.com`）。

   如果留空，极狐GitLab 将使用默认的美国 SaaS 端点（`https://api.gitguardian.com`）。

1. 在 **API 令牌**中，[粘贴来自 GitGuardian 的令牌值](#create-a-gitguardian-api-token)。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

极狐GitLab 现在已准备好根据 GitGuardian 策略拒绝提交。

<a id="skip-secret-detection"></a>

## 跳过密钥检测

如有需要，您可以跳过 GitGuardian 密钥检测。跳过推送中所有提交的密钥检测的选项与[原生密钥检测](../../application_security/secret_detection/secret_push_protection/_index.md#skip-secret-push-protection)的选项相同。您可以：

- 在其中一个提交消息中添加 `[skip secret push protection]`。
- 使用 `secret_push_protection.skip_all` [推送选项](../../../topics/git/commit.md#push-options-for-gitguardian-integration)。

<a id="known-issues"></a>

## 已知问题

- 推送可能会延迟或超时。使用 GitGuardian 集成时：
  - 推送会发送到第三方。
  - 极狐GitLab 无法控制与 GitGuardian 的连接或 GitGuardian 的处理过程。
- 由于 [GitGuardian API 限制](https://api.gitguardian.com/docs#operation/multiple_scan)，该集成会忽略超过 1 MB 的文件。这些文件不会被扫描。
- 如果推送的文件名超过 256 个字符，推送会失败。
- 更多信息，请参见 [GitGuardian API 文档](https://api.gitguardian.com/docs#operation/multiple_scan)。

下面的故障排除步骤展示了如何缓解其中一些问题。

<a id="troubleshooting"></a>

## 故障排除

使用 GitGuardian 集成时，您可能会遇到以下问题。

<a id="500-http-errors"></a>

### `500` HTTP 错误

您可能会收到 HTTP `500` 错误。

当包含大量变更文件的提交请求超时时，会出现此问题。

如果此问题在您于一次提交中更改超过 50 个文件时出现：

1. 将您的更改拆分为更小的提交。
1. 逐个推送这些更小的提交。

<a id="error-filename-ensure-this-value-has-at-most-256-characters"></a>

### 错误：`Filename: ensure this value has at most 256 characters`

您可能会收到 HTTP `400` 错误，提示 `Filename: ensure this value has at most 256 characters`。

当您在该提交中推送的部分变更文件的文件名（而非路径）超过 256 个字符时，会出现此问题。

变通方法是尽可能缩短文件名。例如，如果文件名是由框架自动生成的，无法缩短，请禁用该集成并重试推送。之后如有需要，别忘了重新启用该集成。
