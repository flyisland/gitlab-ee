---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: ServiceNow
description: "Configure ServiceNow to centralize and automate GitLab workflows."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

ServiceNow 提供多种集成，帮助您集中管理并自动化极狐GitLab 工作流。

为了简化技术栈并优化流程，您应尽可能使用极狐GitLab [部署审批](../../api/oauth2.md)。

<a id="gitlab-spoke"></a>

## 极狐GitLab spoke

通过 ServiceNow 中的极狐GitLab spoke，您可以自动执行针对极狐GitLab 项目、群组、用户、议题、合并请求、分支和代码仓的操作。

有关完整功能列表，请参阅[极狐GitLab spoke 文档（Xanadu 版本）](https://docs.servicenow.com/bundle/xanadu-integrate-applications/page/administer/integrationhub-store-spokes/concept/gitlab-spoke.html)。

您必须[将极狐GitLab 配置为 OAuth 2.0 身份验证服务提供者](../../integration/oauth_provider.md)，这包括创建一个应用程序，然后在 ServiceNow 中提供应用程序 ID 和密钥。

<a id="gitlab-scm-and-continuous-integration-for-devops"></a>

## 极狐GitLab SCM 和 DevOps 持续集成

在 ServiceNow DevOps 中，您可以集成极狐GitLab 代码仓和极狐GitLab CI/CD，以集中查看极狐GitLab 活动和变更管理流程。

您可以：

- 在 ServiceNow 中跟踪极狐GitLab 代码仓和 CI/CD 流水线中的活动信息。
- 与极狐GitLab CI/CD 流水线集成，自动创建变更工单并确定自动批准变更的条件。

有关更多信息，请参阅以下 ServiceNow 资源：

- [ServiceNow DevOps 主页](https://www.servicenow.com/products/devops.html)
- [ServiceNow DevOps 文档](https://docs.servicenow.com/bundle/tokyo-devops/page/product/enterprise-dev-ops/concept/dev-ops-bundle-landing-page.html)
- [极狐GitLab SCM 和 DevOps 持续集成](https://store.servicenow.com/sn_appstore_store.do#!/store/application/54dc4eacdbc2dcd02805320b7c96191e/)