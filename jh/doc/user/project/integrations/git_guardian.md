---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Integrate GitLab with GitGuardian to get alerts for policy violations and security issues before they can be exploited.
title: GitGuardian
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于极狐GitLab 16.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/435706)，带有名为 `git_guardian_integration` 的[功能标志](../../../administration/feature_flags/_index.md)。默认启用。在 JihuLab.com 上禁用。
- 于极狐GitLab 17.7 [在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/438695#note_2226917025)。
- 于极狐GitLab 17.8 [GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/176391)。功能标志 `git_guardian_integration` 已移除。

{{< /history >}}

[GitGuardian](https://www.gitguardian.com/) 是一项网络安全服务，可检测源代码仓库中的敏感数据，例如 API 密钥和密码。
它会扫描 Git 仓库，对策略违规发出警报，并帮助组织在黑客利用之前修复安全问题。

你可以配置极狐GitLab 根据 GitGuardian 策略拒绝提交。

要设置 GitGuardian 集成：

1. [创建 GitGuardian API 令牌](#create-a-gitguardian-api-token)。
1. [为你的项目设置 GitGuardian 集成](#set-up-the-gitguardian-integration-for-your-project)。

<a id="create-a-gitguardian-api-token"></a>

## 创建 GitGuardian API 令牌

先决条件：

- 你必须拥有 GitGuardian 账户。

创建 API 令牌：

1. 登录你的 GitGuardian 账户。
1. 在侧边栏中，进入 **API** 部分。
1. 在 API 部分侧边栏中，进入 **Personal access tokens** 页面。
1. 选择 **Create token**。令牌创建对话框将打开。
1. 提供你的令牌信息：
   - 为你的 API 令牌指定一个有意义的名称，以标识其用途。
     例如，`GitLab integration token`。
   - 选择合适的过期时间。
   - 选中 **scan scope** 复选框。
     这是集成所需的唯一范围。
1. 选择 **Create token**。
1. 生成令牌后，将其复制到剪贴板。
   此令牌是敏感信息，请妥善保管。

现在，你已成功创建可用于集成的 GitGuardian API 令牌。

<a id="set-up-the-gitguardian-integration-for-your-project"></a>

## 为你的项目设置 GitGuardian 集成

先决条件：

- 你必须拥有项目的维护者或所有者角色。

创建并复制 API 令牌后，配置极狐GitLab 以拒绝提交：

为你的项目启用集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **GitGuardian**。
1. 在 **启用集成** 中，选中 **活跃** 复选框。
1. 在 **API 令牌** 中，[粘贴来自 GitGuardian 的令牌值](#create-a-gitguardian-api-token)。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

极狐GitLab 现在可以根据 GitGuardian 策略拒绝提交了。

<a id="skip-secret-detection"></a>

## 跳过密钥检测

{{< history >}}

- 于极狐GitLab 17.0 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/152064)。

{{< /history >}}

如果需要，你可以跳过 GitGuardian 密钥检测。跳过推送中所有提交的密钥检测的选项与[原生密钥检测](../../application_security/secret_detection/secret_push_protection/_index.md#skip-secret-push-protection)的选项相同。请执行以下任一操作：

- 将 `[skip secret push protection]` 添加到一条提交信息中。
- 使用 `secret_push_protection.skip_all` [推送选项](../../../topics/git/commit.md#push-options-for-gitguardian-integration)。

<a id="known-issues"></a>

## 已知问题

- 推送可能延迟或超时。使用 GitGuardian 集成时：
  - 推送会发送到第三方。
  - 极狐GitLab 无法控制与 GitGuardian 的连接或 GitGuardian 的处理过程。
- 由于 [GitGuardian API 限制](https://api.gitguardian.com/docs#operation/multiple_scan)，集成会忽略超过 1 MB 的文件。这些文件不会被扫描。
- 如果推送的文件的名称超过 256 个字符，则推送会失败。
- 有关更多信息，请参阅 [GitGuardian API 文档](https://api.gitguardian.com/docs#operation/multiple_scan)。

下面的故障排除步骤展示了如何缓解其中一些问题。

<a id="troubleshooting"></a>

## 故障排除

在使用 GitGuardian 集成时，你可能会遇到以下问题。

<a id="500-http-errors"></a>

### `500` HTTP 错误

你可能会收到 HTTP `500` 错误。

此问题在包含大量已更改文件的提交请求超时时发生。

如果你在提交中更改超过 50 个文件时发生此问题：

1. 将你的更改拆分成较小的提交。
1. 逐个推送较小的提交。

<a id="error-filename-ensure-this-value-has-at-most-256-characters"></a>

### 错误：`Filename: ensure this value has at most 256 characters`

你可能会收到 HTTP `400` 错误，指出 `Filename: ensure this value has at most 256 characters`。

此问题发生在你在该提交中推送的某些已更改文件的文件名（而非路径）超过 256 个字符时。

解决方法是在可能的情况下缩短文件名。
例如，如果文件名是由框架自动生成的，因此无法缩短，请禁用集成并尝试再次推送。
如果需要，之后不要忘记重新启用集成。