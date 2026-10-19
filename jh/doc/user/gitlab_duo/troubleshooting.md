---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除极狐GitLab Duo
---

使用极狐GitLab Duo 时，您可能会遇到问题。

首先请[运行健康检查](../../administration/gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo)，以确定您的实例是否满足使用极狐GitLab Duo 的要求。

有关极狐GitLab Duo 故障排除的更多信息，请参阅：

- [故障排除代码建议](../project/repository/code_suggestions/troubleshooting.md)。
- [极狐GitLab Duo Chat 故障排除](../gitlab_duo_chat/troubleshooting.md)。
- [故障排除极狐GitLab Duo 自部署版本](../../administration/gitlab_duo_self_hosted/troubleshooting.md)。

如果健康检查未能解决您的问题，请查看以下故障排除步骤。

<a id="gitlab-duo-features-do-not-work-on-self-managed"></a>

## 极狐GitLab Duo 功能在私有化部署中无法使用

除了[确保极狐GitLab Duo 功能已开启](turn_on_off.md)之外，您还可以执行以下操作：

1. 以管理员身份，为极狐GitLab Duo 运行健康检查。

   {{< tabs >}}

   {{< tab title="In 17.5 and later" >}}

   在极狐GitLab 17.5 及更高版本中，您可以使用 UI 运行健康检查并下载详细报告，以帮助识别和排查问题。

   {{< /tab >}}

   {{< tab title="In 17.4" >}}

   在极狐GitLab 17.4 中，您可以运行健康检查 Rake 任务来生成详细报告，以帮助识别和排查问题。

   ```shell
   sudo gitlab-rails 'cloud_connector:health_check(root,report.json)'
   ```

   {{< /tab >}}

   {{< tab title="在 17.3 及更早版本中" >}}

   在极狐GitLab 17.3 及更早版本中，您可以下载并运行 `health_check` 脚本，以生成详细报告，帮助识别和排查问题。

   1. 下载健康检查脚本：

      ```shell
      wget https://gitlab.com/gitlab-org/gitlab/-/snippets/3734617/raw/main/health_check.rb
      ```

   1. 使用 Rails Runner 运行该脚本：

      ```shell
      gitlab-rails runner [full_path/to/health_check.rb] --debug --username [username] --output-file [report.txt]
      ```

      ```shell
      Usage: gitlab-rails runner full_path/to/health_check.rb
             --debug                Enable debug mode
             --output-file FILE     Write a report to FILE
             --username USERNAME    Provide a username to test seat assignments
             --skip [CHECK]         Skip specific check (options: access_data, token, license, host, features, end_to_end)
      ```

   {{< /tab >}}

   {{< /tabs >}}

1. 验证极狐GitLab 实例能否访问[所需的 JihuLab.com 端点](../../administration/gitlab_duo/configure/_index.md)。
   您可以使用 `curl` 等命令行工具来验证连接性。

   ```shell
   curl --verbose "https://cloud.jihulab.com"

   curl --verbose "https://customers.jihulab.com"
   ```

   如果为极狐GitLab 实例配置了 HTTP/S 代理，请在 `curl` 命令中包含 `proxy` 参数。

   ```shell
   # https proxy for curl
   curl --verbose --proxy "http://USERNAME:PASSWORD@example.com:8080" "https://cloud.jihulab.com"
   curl --verbose --proxy "http://USERNAME:PASSWORD@example.com:8080" "https://customers.jihulab.com"
   ```

1. 可选。如果您在极狐GitLab
   应用程序与公共互联网之间使用了[代理服务器](../../administration/gitlab_duo/configure/_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)，
   请[禁用 DNS 重绑定保护](../../security/webhooks.md#enforce-dns-rebinding-attack-protection)。

1. [手动同步订阅数据](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。
   - 验证极狐GitLab 实例是否[将您的订阅数据与极狐GitLab 同步](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/)。

<a id="error-webview-didnt-initialize-in-10000ms"></a>

## 错误：`Webview didn't initialize in 10000ms`

在 VS Code Remote SSH 或 WSL 会话中使用极狐GitLab Duo Chat 时，您可能会遇到此错误。
该扩展还可能尝试错误地连接到 `127.0.0.1`地址。

当远程环境引入的延迟超过 GitLab for VS Code 扩展 6.8.0 及更高版本中
硬编码的 10 秒超时时，就会出现此问题。

要解决此问题：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，请按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，请按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **打开设置 (JSON)** 以编辑您的 `settings.json` 文件。
   或者，按 <kbd>F1</kbd>，输入 **首选项：打开设置 (JSON)**，
   然后选择它。
1. 添加此设置：

   ```json
   "gitlab.featureFlags.languageServerWebviews": false
   ```

1. 保存并重新加载 VS Code。

<a id="gitlab-duo-features-not-available-for-users"></a>

## 用户无法使用极狐GitLab Duo 功能

除了[开启极狐GitLab Duo 功能](turn_on_off.md)之外，您还可以执行以下操作：

- 如果您拥有极狐GitLab Duo Core，请验证您是否具备：
  - 专业版或旗舰版订阅。
  - [已开启 IDE 功能](turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
  > [!note]
  > GitLab Duo Non-Agentic Chat 不适用于极狐GitLab Duo Core 用户。
- 如果您拥有极狐GitLab Duo Pro 或 Enterprise：
  - 验证[是否已购买订阅附加组件](../../subscriptions/subscription-add-ons.md#purchase-gitlab-duo)。
  - 确保[已为用户分配席位](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)。
- 对于您的 IDE：
  - 验证[扩展](../project/repository/code_suggestions/set_up.md#configure-editor-extension)
    或插件是否为最新版本。
  - 运行健康检查，并测试身份验证。
