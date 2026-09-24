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

Datadog 集成允许你将 极狐GitLab 项目连接到 [Datadog](https://www.datadoghq.com/)，同步仓库元数据以丰富你的 Datadog 遥测数据，让 Datadog 在合并请求上评论，并将 CI/CD 流水线和作业信息发送到 Datadog。

## 连接你的 Datadog 账户

<a id="connect-your-datadog-account"></a>

具有 **管理员** 角色的用户可以为整个实例或为特定项目或群组配置集成：

1. 如果你没有 Datadog API 密钥：
   1. 登录 Datadog。
   1. 转到 **集成** 部分。
   1. 在 [API 选项卡](https://app.datadoghq.com/account/settings#api)中生成一个 API 密钥。复制此值，因为在后面的步骤中需要它。
1. *对于特定项目或群组的集成：* 在 极狐GitLab 中，转到你的项目或群组。
1. *对于整个实例的集成：*
   1. 以具有管理员访问权限的用户身份登录 极狐GitLab。
   1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 滚动到 **添加集成**，然后选择 **Datadog**。
1. 选择 **激活** 以启用集成。
1. 指定要发送数据到的 [**Datadog 站点**](https://docs.datadoghq.com/getting_started/site/)。
1. 可选。要覆盖用于直接发送数据的 API URL，请提供一个 **API URL**。仅在高级场景中使用。
1. 提供你的 Datadog **API 密钥**。

## 配置 CI 可见性

<a id="configure-ci-visibility"></a>

你可以选择性地启用 [Datadog CI Visibility](https://www.datadoghq.com/product/ci-cd-monitoring/) 以将 CI/CD 流水线和作业数据发送到 Datadog。使用此功能来监控和排除作业失败和性能问题。

有关更多信息，请参见 [Datadog CI Visibility 文档](https://docs.datadoghq.com/continuous_integration/pipelines/?tab=gitlab)。

> [!warning]
> Datadog CI Visibility 按提交者计费。使用此功能可能会影响你的 Datadog 账单。有关详细信息，请参见 [Datadog 定价页面](https://www.datadoghq.com/pricing/?product=ci-pipeline-visibility#products)。

此功能基于 [Webhooks](../user/project/integrations/webhooks.md)，并且只需要在 极狐GitLab 中配置：

1. 可选。选择 **启用流水线作业日志收集** 以为作业的输出启用日志收集。（[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/346339)于 极狐GitLab 15.3。）
1. 可选。如果你使用多个 极狐GitLab 实例，请提供一个唯一的 **服务** 名称以区分你的 极狐GitLab 实例。
   <!-- vale gitlab_base.Spelling = NO -->
1. 可选。如果你使用 极狐GitLab 实例组（例如预发布环境和生产环境），请提供一个 **Env** 名称。此值会附加到集成生成的每个跨度上。
   <!-- vale gitlab_base.Spelling = YES -->
1. 可选。要为正配置集成的所有跨度定义任何自定义标签，请在 **标签** 中每行输入一个标签。每行必须采用 `key:value` 格式。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

当集成发送数据时，你可以在 Datadog 账户的 [CI Visibility](https://app.datadoghq.com/ci) 部分查看它。