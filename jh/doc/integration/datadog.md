---
stage: Verify
group: CI Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Datadog
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过 Datadog 集成，您可以将极狐GitLab 项目连接到 [Datadog](https://www.datadoghq.com/)。
借助此集成，您可以同步代码仓库元数据以丰富 Datadog 遥测数据，让 Datadog 对合并请求发表评论，并将 CI/CD 流水线和作业信息发送到 Datadog。

<a id="connect-your-datadog-account"></a>

## 连接您的 Datadog 账号

拥有管理员访问权限的用户可以为整个实例或特定项目或群组配置该集成：

1. 如果您没有 Datadog API 密钥：
   1. 登录 Datadog。
   1. 转到 **集成** 部分。
   1. 在 [APIs 选项卡](https://app.datadoghq.com/account/settings#api)中生成 API 密钥。
      复制该值，后续步骤中会用到。
1. *对于特定项目或群组的集成：*在极狐GitLab 中，转到您的项目或群组。
1. *对于整个实例的集成：*
   1. 以拥有管理员访问权限的用户身份登录极狐GitLab。
   1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 滚动到**添加集成**，然后选择 **Datadog**。
1. 选择**活跃**以启用该集成。
1. 指定要向其发送数据的 [**Datadog 站点**](https://docs.datadoghq.com/getting_started/site/)。
1. 可选。要覆盖直接用于发送数据的 API URL，请提供 **API URL**。
   仅在高级场景中使用。
1. 提供您的 Datadog **API 密钥**。

<a id="configure-ci-visibility"></a>

## 配置 CI Visibility

您可以选择启用 [Datadog CI Visibility](https://www.datadoghq.com/product/ci-cd-monitoring/)，
以将 CI/CD 流水线和作业数据发送到 Datadog。使用此功能可以监控并排查作业失败和性能问题。

有关更多信息，请参阅 [Datadog CI Visibility 文档](https://docs.datadoghq.com/continuous_integration/pipelines/?tab=gitlab)。

> [!warning]
> Datadog CI Visibility 按提交者计费。使用此功能可能会影响您的 Datadog 账单。
> 有关详情，请参阅 [Datadog 定价页面](https://www.datadoghq.com/pricing/?product=ci-pipeline-visibility#products)。

此功能基于 [Webhook](../user/project/integrations/webhooks.md)，
并且只需在极狐GitLab 中进行配置：

1. 可选。选择**启用流水线作业日志收集**，以启用作业输出的日志收集。
1. 可选。如果您使用多个极狐GitLab 实例，请提供一个唯一的 **Service** 名称，
   以区分您的极狐GitLab 实例。
   <!-- vale gitlab_base.Spelling = NO -->
1. 可选。如果您使用极狐GitLab 实例组（例如预发布和生产环境），
   请提供一个 **Env** 名称。该值会附加到该集成生成的每个 span 上。
   <!-- vale gitlab_base.Spelling = YES -->
1. 可选。要为配置该集成时涉及的所有 span 定义自定义标签，
   请在 **标签**中每行输入一个标签。每行必须采用 `key:value` 格式。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

当该集成发送数据时，您可以在 Datadog 账号的 [CI Visibility](https://app.datadoghq.com/ci)
部分查看这些数据。
