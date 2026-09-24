---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查极狐GitLab Duo 问题
---

在使用极狐GitLab Duo 时，您可能会遇到一些问题。

首先，[运行健康检查](../../administration/gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo) 以确定您的实例是否满足使用极狐GitLab Duo 的要求。

有关排查极狐GitLab Duo 问题的更多信息，请参阅：

- [排查代码建议](../project/repository/code_suggestions/troubleshooting.md)。
- [排查极狐GitLab Duo Chat](../gitlab_duo_chat/troubleshooting.md)。
- [排查极狐GitLab Duo 私有化部署](../../administration/gitlab_duo_self_hosted/troubleshooting.md)。

如果健康检查未能解决您的问题，请查看以下排查步骤。

<a id="gitlab-duo-features-do-not-work-on-self-managed"></a>

## 极狐GitLab Duo 功能在私有化部署实例上无法使用

除了[确保已启用极狐GitLab Duo 功能](turn_on_off.md) 外，您还可以执行以下操作：

1. 以管理员身份，运行极狐GitLab Duo 的健康检查。

   {{< tabs >}}

   {{< tab title="17.5 及更高版本" >}}

   在 GitLab 17.5 及更高版本中，您可以使用 UI 运行健康检查并下载详细报告，以帮助识别和排查问题。

   {{< /tab >}}

   {{< tab title="17.4 版本" >}}

   在 GitLab 17.4 中，您可以运行健康检查 Rake 任务来生成详细报告，以帮助识别和排查问题。

   ```shell
   sudo gitlab-rails 'cloud_connector:health_check(root,report.json)'
   ```

   {{< /tab >}}

   {{< tab title="17.3 及更早版本" >}}

   在 GitLab 17.3 及更早版本中，您可以下载并运行 `health_check` 脚本来生成详细报告，以帮助识别和排查问题。

   1. 下载健康检查脚本：

      ```shell
      wget https://jihulab.com/gitlab-cn/gitlab/-/snippets/3734617/raw/main/health_check.rb
      ```

   1. 使用 Rails Runner 运行脚本：

      ```shell
      gitlab-rails runner [full_path/to/health_check.rb] --debug --username [username] --output-file [report.txt]
      ```

      ```shell
      用法：gitlab-rails runner full_path/to/health_check.rb
             --debug                启用调试模式
             --output-file FILE     将报告写入 FILE
             --username USERNAME    提供用户名测试席位分配
             --skip [CHECK]         跳过特定检查（选项：access_data, token, license, host, features, end_to_end）
      ```

   {{< /tab >}}

   {{< /tabs >}}

1. 验证极狐GitLab 实例是否能够访问[所需的 JihuLab.com 端点](../../administration/gitlab_duo/configure/gitlab_self_managed.md)。您可以使用命令行工具（如 `curl`）来验证连接性。

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

1. （可选）如果您在极狐GitLab 应用程序和公共互联网之间使用了[代理服务器](../../administration/gitlab_duo/configure/_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)，请[禁用 DNS 重新绑定保护](../../security/webhooks.md#enforce-dns-rebinding-attack-protection)。

1. [手动同步订阅数据](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。
   - 验证极狐GitLab 实例[与极狐GitLab 同步订阅数据](https://gitlab.cn/pricing/licensing-faq/cloud-licensing/)。

<a id="gitlab-duo-features-not-available-for-users"></a>

## 用户无法使用极狐GitLab Duo 功能

除了[启用极狐GitLab Duo 功能](turn_on_off.md) 外，您还可以执行以下操作：

- 如果您拥有 GitLab Duo Core，请确认您拥有：
  - 专业版或旗舰版订阅。
  - [已启用 IDE 功能](turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 如果您拥有 GitLab Duo Pro 或 Enterprise：
  - 确认[已购买订阅附加组件](../../subscriptions/subscription-add-ons.md#purchase-gitlab-duo)。
  - 确保[已为用户分配席位](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)。

