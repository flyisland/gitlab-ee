---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于发送事件的自定义 HTTP 回调。
title: 故障排除 webhooks
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

排查并解决极狐GitLab webhooks 的常见问题。

<a id="debug-webhooks"></a>

## 调试 Webhooks

使用以下方法调试极狐GitLab webhooks 并捕获负载：

- [公共 Webhook 检查工具](#use-public-webhook-inspection-tools)
- [Webhook 请求和响应详情](webhooks.md#inspect-request-and-response-details)
- [GitLab 开发套件 (GDK)](#use-the-gitlab-development-kit-gdk)
- [私有 Webhook 接收器](#create-a-private-webhook-receiver)

有关 webhook 事件和 JSON 负载的信息，请参阅 [webhook 事件](webhook_events.md)。

<a id="use-public-webhook-inspection-tools"></a>

### 使用公共 Webhook 检查工具

使用公共工具检查和测试 webhook 负载。这些工具为 HTTP 请求提供 catch-all 端点，并以 `200 OK` 状态码响应。

> [!warning]
> 使用公共工具时请谨慎，因为您可能会将敏感数据发送到外部服务。
> 请使用测试令牌，并轮换任何无意中发送给第三方的密钥。
> 为增强隐私，请[创建私有 Webhook 接收器](#create-a-private-webhook-receiver)。

公共 Webhook 检查工具包括：

<!-- vale gitlab_base.Spelling = NO -->
- [Beeceptor](https://beeceptor.com)：创建临时 HTTPS 端点并检查传入的负载。
<!-- vale gitlab_base.Spelling = YES -->
- [Webhook.site](https://webhook.site)：查看传入的负载。
- [Webhook Tester](https://webhook-test.com)：检查和调试传入的负载。

<a id="use-the-gitlab-development-kit-gdk"></a>

### 使用 GitLab 开发套件 (GDK)

为了更安全的开发环境，请使用
[GitLab 开发套件 (GDK)](https://gitlab.com/gitlab-org/gitlab-development-kit) 在本地处理
极狐GitLab webhooks。
使用 GDK 将 webhooks 从您的本地极狐GitLab 实例发送到您机器上的 webhook 接收器。

要使用此方法，请安装并配置 GDK。

<a id="create-a-private-webhook-receiver"></a>

### 创建私有 Webhook 接收器

如果您无法将 webhook 负载发送到[公共接收器](#use-public-webhook-inspection-tools)，请创建您自己的私有 Webhook 接收器。

先决条件：

- 您的系统上已安装 Ruby。

要创建私有 Webhook 接收器：

1. 将此脚本保存为 `print_http_body.rb`：

   ```ruby
   require 'webrick'

   server = WEBrick::HTTPServer.new(:Port => ARGV.first)
   server.mount_proc '/' do |req, res|
     puts req.body
   end

   trap 'INT' do
     server.shutdown
   end
   server.start
   ```

1. 选择一个未使用的端口（例如 `8000`）并启动脚本：

   ```shell
   ruby print_http_body.rb 8000
   ```

1. 在极狐GitLab 中，使用您的接收器 URL（例如 `http://receiver.example.com:8000/`）[配置 webhook](webhooks.md#configure-webhooks)。
1. 选择 **测试**。您应该会看到类似以下的输出：

   ```plaintext
   {"before":"077a85dd266e6f3573ef7e9ef8ce3343ad659c4e","after":"95cd4a99e93bc4bbabacfa2cd10e6725b1403c60",<SNIP>}
   example.com - - [14/May/2014:07:45:26 EDT] "POST / HTTP/1.1" 200 0
   - -> /
   ```

> [!note]
> 要添加此接收器，您可能需要[允许对本地网络的请求](../../../security/webhooks.md)。

<a id="resolve-ssl-certificate-verification-errors"></a>

## 解决 SSL 证书验证错误

当启用 SSL 验证时，极狐GitLab 可能无法验证 webhook 端点的 SSL 证书，并出现以下错误：

```plaintext
unable to get local issuer certificate
```

此错误通常发生在根证书不是由 [CAcert.org](http://www.cacert.org/) 确定的受信任证书颁发机构签发时。

要解决此问题：

1. 使用 [SSL Checker](https://www.sslshopper.com/ssl-checker.html) 识别具体错误。
1. 检查是否缺少中间证书，这是验证失败的常见原因。

<a id="webhook-not-triggered"></a>

## Webhook 未触发

如果 webhook 未触发，请验证：

- Webhook 未被[自动禁用](webhooks.md#auto-disabled-webhooks)。
- 极狐GitLab 实例未处于[静默模式](../../../administration/silent_mode/_index.md)。
- [**管理员**](../../../administration/settings/push_event_activities_limit.md)区域中的 **Push 事件活动限制** 和 **Push 事件钩子限制** 设置的值大于 `0`。

<a id="error-webhook-rate-limit-exceeded"></a>

## 错误：`Webhook rate limit exceeded`

Webhook 可能因速率限制而失败。JihuLab.com 限制每个顶级命名空间每分钟的 webhook 调用总数。
有关更多信息，请参阅[速率限制](../../jihulab_com/_index.md#webhook-rate-limits)。

要确认问题是否由速率限制引起：

1. 检查您的极狐GitLab 日志中是否有消息 `Webhook rate limit exceeded`。
1. 减少触发 webhooks 的事件数量，或联系极狐GitLab 支持讨论您的速率限制需求。

<a id="custom-webhook-template-with-unquoted-placeholders-cannot-be-saved"></a>

## 包含未加引号占位符的自定义 Webhook 模板无法保存

在极狐GitLab 18.8 至 18.10 中，包含未加引号负载字段的[自定义 Webhook 模板](webhooks.md#custom-webhook-template)无法保存。此问题已在极狐GitLab 18.11 中解决。
作为变通方法，请将字段用引号括起来，或升级到极狐GitLab 18.11 或更高版本。例如，
`{"value": {{id}}}` 将变为 `{"value": "{{id}}"}`。

带引号的字段会产生字符串值而不是数值。如果这与您的 webhook 不兼容，并且您需要对其进行更改，建议升级。

<a id="duplicate-deployment-failure-alerts-after-a-rejection"></a>

## 拒绝后出现重复的部署失败告警

当对[受保护环境](../../../ci/environments/deployment_approvals.md)的部署被拒绝时，极狐GitLab 会发送一个 `status: "rejected"` webhook，随后在部署作业被丢弃时，为相同的 `deployment_id` 发送一个 `status: "failed"` webhook。`failed` 事件是现有的生命周期事件，不包含审批字段，因此，对 `status: "failed"` 发出告警的接收器可能会对有意拒绝的部署产生重复告警。

为避免重复告警：

1. 通过 `deployment_id` 关联事件，并将同一部署的 `status: "failed"` 事件视为与此前发生的 `status: "rejected"` 事件相同的事件。
1. 要区分因拒绝导致的失败与真正的失败，请监听 `status: "rejected"` 事件并存储被拒绝的部署 ID。当 `status: "failed"` 事件到达时，如果其 `deployment_id` 在该集合中，则抑制该告警。
