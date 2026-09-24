---
stage: none
group: none
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>"
toc: false
title: 按版本弃用和移除
---

以下极狐GitLab 功能已弃用，不再推荐使用。

- 每个弃用功能将在未来版本中移除。
- 部分功能移除时会导致重大变更。
- 在 JihuLab.com 上，弃用功能可能在发布前的任意时间被移除。
- 要查看已移除功能的文档，请参阅[极狐GitLab 文档存档](https://gitlab.cn/docs/archives/)。
- 对于 GraphQL API 弃用，您应[验证您的 API 调用在未使用弃用项时仍能正常工作](../api/graphql/_index.md#verify-against-the-future-breaking-change-schema)。

要对这些弃用信息进行高级搜索和过滤，请尝试[由我们客户成功团队构建的工具](https://gitlab-com.gitlab.io/cs-tools/gitlab-cs-tools/what-is-new-since/?tab=deprecations)。

[REST API 弃用](../api/rest/deprecations.md) 已在单独文档中介绍。

{{< icon name="rss" >}} **要接收即将到来的重大变更通知**，请将此 URL 添加到您的 RSS 阅读器：`https://gitlab.cn/breaking-changes.xml`

<!-- vale off -->
<!--
DO NOT EDIT THIS PAGE DIRECTLY

This page is automatically generated from the template located at
`data/deprecations/templates/_deprecation_template.md.erb`, using
the YAML files in `/data/deprecations` by the Rake task
located at `lib/tasks/gitlab/docs/compile_deprecations.rake`,

For deprecation authors (usually Product Managers and Engineering Managers):

- To add a deprecation, use the example.yml file in `/data/deprecations/templates` as a template.
- For more information about authoring deprecations, check the deprecation item guidance:
  <https://handbook.gitlab.com/handbook/marketing/blog/release-posts/#update-the-deprecations-doc>

For deprecation reviewers (Technical Writers only):

- To update the deprecation doc, run: `bin/rake gitlab:docs:compile_deprecations`
- To verify the deprecations doc is up to date, run: `bin/rake gitlab:docs:check_deprecations`
- For more information about updating the deprecation doc, see the deprecation doc update guidance:
  <https://handbook.gitlab.com/handbook/marketing/blog/release-posts/#update-the-deprecations-doc>
-->

<a id="gitlab-20.0"></a>

## 极狐GitLab 20.0

<a id="compliance-pipelines"></a>

### 合规流水线

- 在极狐GitLab 17.3 中宣布
- 在极狐GitLab 20.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

目前，有两种方式可以确保在项目流水线中运行合规性或安全性相关作业：

- [合规流水线](https://gitlab.cn/docs/user/compliance/compliance_pipelines/)。
- [安全策略](https://gitlab.cn/docs/user/application_security/policies/)。

为了提供单一位置来确保所需作业在所有项目流水线中运行，我们已在极狐GitLab 17.3 中弃用合规流水线，并将在极狐GitLab 20.0 中移除该功能。

客户应尽快从合规流水线迁移至新的[流水线执行策略类型](https://gitlab.cn/docs/user/application_security/policies/pipeline_execution_policies/)。

更多信息，请参阅相关：

- [迁移指南](https://gitlab.cn/docs/user/compliance/compliance_pipelines/#pipeline-execution-policies-migration)。
- [博客文章](https://gitlab.cn/blog/why-gitlab-is-deprecating-compliance-pipelines-in-favor-of-security-policies/)。

<a id="design-management-deprecated"></a>

### 设计管理弃用

- 在极狐GitLab 18.6 中宣布
- 在极狐GitLab 20.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 20.0 中，极狐GitLab 将开始弃用设计管理。设计管理允许用户将线框和模型等设计资产上传到极狐GitLab 议题中以供协作。我们是在仔细考虑现有使用情况和预估客户影响后做出此决定。设计管理所需的持续维护超过了当前使用量，我们正将精力集中在更符合现代设计师工作流的解决方案上。在极狐GitLab 20.0 及更高版本中，用户将无法再上传新设计。现有设计将以只读模式保留至极狐GitLab 21.0，让用户有时间根据需要保存设计。极狐GitLab 正在探索能更好地与设计师已使用的工具集成的替代方案。

<a id="enforce-keyset-pagination-on-audit-event-api"></a>

### 在审计事件 API 上强制执行键集分页

- 在极狐GitLab 17.8 中宣布
- 在极狐GitLab 20.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

实例、群组和项目的审计事件 API 目前支持可选的键集分页。在极狐GitLab 20.0 中，我们将对这些 API 强制执行键集分页。

<a id="legacy-group-level-audit-event-streaming-destination-graphql-apis"></a>

### 旧版群组级审计事件流目标 GraphQL API

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 20.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

以下用于审计事件流目标的群组级 GraphQL API 已弃用，并将在极狐GitLab 20.0 中移除。

已弃用的变更：

- `externalAuditEventDestinationCreate` — 使用 `groupAuditEventStreamingDestinationsCreate` 替代。
- `externalAuditEventDestinationDestroy` — 使用 `groupAuditEventStreamingDestinationsDelete` 替代。
- `externalAuditEventDestinationUpdate` — 使用 `groupAuditEventStreamingDestinationsUpdate` 替代。
- `googleCloudLoggingConfigurationCreate` — 使用 `groupAuditEventStreamingDestinationsCreate` 并带 `gcpLogging` 类别替代。
- `googleCloudLoggingConfigurationDestroy` — 使用 `groupAuditEventStreamingDestinationsDelete` 替代。
- `googleCloudLoggingConfigurationUpdate` — 使用 `groupAuditEventStreamingDestinationsUpdate` 替代。
- `auditEventsAmazonS3ConfigurationCreate` — 使用 `groupAuditEventStreamingDestinationsCreate` 并带 `amazonS3` 类别替代。
- `auditEventsAmazonS3ConfigurationDelete` — 使用 `groupAuditEventStreamingDestinationsDelete` 替代。
- `auditEventsAmazonS3ConfigurationUpdate` — 使用 `groupAuditEventStreamingDestinationsUpdate` 替代。
- `auditEventsStreamingHeadersCreate` — 通过使用 `groupAuditEventStreamingDestinationsUpdate` 配置流目标来配置头部信息。
- `auditEventsStreamingHeadersDestroy` — 通过使用 `groupAuditEventStreamingDestinationsUpdate` 配置流目标来配置头部信息。
- `auditEventsStreamingHeadersUpdate` — 通过使用 `groupAuditEventStreamingDestinationsUpdate` 配置流目标来配置头部信息。
- `auditEventsStreamingDestinationEventsAdd` — 使用 `auditEventsGroupDestinationEventsAdd` 替代。
- `auditEventsStreamingDestinationEventsRemove` — 使用 `auditEventsGroupDestinationEventsRemove` 替代。
- `auditEventsStreamingHttpNamespaceFiltersAdd` — 使用 `auditEventsGroupDestinationNamespaceFilterCreate` 替代。
- `auditEventsStreamingHttpNamespaceFiltersDelete` — 使用 `auditEventsGroupDestinationNamespaceFilterDelete` 替代。

已弃用的群组字段：

- `Group.externalAuditEventDestinations` — 使用 `Group.externalAuditEventStreamingDestinations` 替代。
- `Group.googleCloudLoggingConfigurations` — 使用 `Group.externalAuditEventStreamingDestinations` 并带 `gcpLogging` 类别替代。
- `Group.amazonS3Configurations` — 使用 `Group.externalAuditEventStreamingDestinations` 并带 `amazonS3` 类别替代。

新的统一流目标 API 通过一组端点支持所有目标类别（HTTP、Google Cloud Logging、Amazon S3），并带有 `category` 参数。

<a id="legacy-instance-level-audit-event-streaming-destination-graphql-apis"></a>

### 旧版实例级审计事件流目标 GraphQL API

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 20.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

以下用于审计事件流目标的实例级 GraphQL API 已弃用，并将在极狐GitLab 20.0 中移除。

已弃用的变更：

- `instanceExternalAuditEventDestinationCreate` — 使用 `instanceAuditEventStreamingDestinationsCreate` 替代。
- `instanceExternalAuditEventDestinationDestroy` — 使用 `instanceAuditEventStreamingDestinationsDelete` 替代。
- `instanceExternalAuditEventDestinationUpdate` — 使用 `instanceAuditEventStreamingDestinationsUpdate` 替代。
- `instanceGoogleCloudLoggingConfigurationCreate` — 使用 `instanceAuditEventStreamingDestinationsCreate` 并带 `gcpLogging` 类别替代。
- `instanceGoogleCloudLoggingConfigurationDestroy` — 使用 `instanceAuditEventStreamingDestinationsDelete` 替代。
- `instanceGoogleCloudLoggingConfigurationUpdate` — 使用 `instanceAuditEventStreamingDestinationsUpdate` 替代。
- `auditEventsInstanceAmazonS3ConfigurationCreate` — 使用 `instanceAuditEventStreamingDestinationsCreate` 并带 `amazonS3` 类别替代。
- `auditEventsInstanceAmazonS3ConfigurationDelete` — 使用 `instanceAuditEventStreamingDestinationsDelete` 替代。
- `auditEventsInstanceAmazonS3ConfigurationUpdate` — 使用 `instanceAuditEventStreamingDestinationsUpdate` 替代。
- `auditEventsStreamingInstanceHeadersCreate` — 通过使用 `instanceAuditEventStreamingDestinationsUpdate` 配置流目标来配置头部信息。
- `auditEventsStreamingInstanceHeadersDestroy` — 通过使用 `instanceAuditEventStreamingDestinationsUpdate` 配置流目标来配置头部信息。
- `auditEventsStreamingInstanceHeadersUpdate` — 通过使用 `instanceAuditEventStreamingDestinationsUpdate` 配置流目标来配置头部信息。
- `auditEventsStreamingDestinationInstanceEventsAdd` — 使用 `auditEventsInstanceDestinationEventsAdd` 替代。
- `auditEventsStreamingDestinationInstanceEventsRemove` — 使用 `auditEventsInstanceDestinationEventsRemove` 替代。

已弃用的查询字段：

- `instanceExternalAuditEventDestinations` — 使用 `auditEventsInstanceStreamingDestinations` 替代。
- `instanceGoogleCloudLoggingConfigurations` — 使用 `auditEventsInstanceStreamingDestinations` 并带 `gcpLogging` 类别替代。
- `auditEventsInstanceAmazonS3Configurations` — 使用 `auditEventsInstanceStreamingDestinations` 并带 `amazonS3` 类别替代。

新的统一流目标 API 通过一组端点支持所有目标类别（HTTP、Google Cloud Logging、Amazon S3），并带有 `category` 参数。

<a id="support-for-nginx-ingress,-haproxy,-and-traefik-charts"></a>

### 对 NGINX Ingress、HAProxy 和 Traefik Chart 的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 20.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab Helm Chart 捆绑了多个 Ingress 控制器，作为默认使用 Kubernetes Gateway API 的 Envoy Gateway 的替代方案。

这些捆绑的 Ingress 控制器，即 NGINX Ingress、HAProxy 和 Traefik，将从极狐GitLab Helm Chart 和 GitLab Operator 中移除。
极狐GitLab Helm Chart 和 GitLab Operator 仍支持使用 Ingress，但需要部署外部 Ingress 控制器。

我们建议迁移到捆绑的 Envoy Gateway 和 Gateway API。
或者，您可以部署并配置[外部 Ingress 控制器和类别](https://gitlab.cn/docs/charts/charts/globals/#configure-ingress-settings)。

<a id="gitlab-19.3"></a>

## 极狐GitLab 19.3

<a id="the-glab-duo-ask-command"></a>

### `glab duo ask` 命令

- 在极狐GitLab 19.0 中宣布
- 在极狐GitLab 19.3 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab CLI 中的 `glab duo ask` 命令在极狐GitLab 19.0 中弃用，并将在极狐GitLab 19.3 中移除。该命令通过自然语言描述生成 Git 命令。

请使用 [`glab duo cli`](https://gitlab.cn/docs/cli/duo/cli/) 在 CLI 中获得 AI 驱动的帮助。

<a id="gitlab-19.1"></a>

## 极狐GitLab 19.1

<a id="elasticsearch-7.x-no-longer-supported-for-advanced-search"></a>

### Elasticsearch 7.x 不再支持高级搜索

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 19.1 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

[Elasticsearch 7.x 的维护周期](https://www.elastic.co/support/eol)已于 2026-01-15 结束。
对于极狐GitLab 私有化部署，管理员必须升级其 Elasticsearch 实例以继续使用高级搜索。

<a id="linux-package-support-for-amazon-linux-2"></a>

### Linux 包对 Amazon Linux 2 的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.1 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 19.1 中，我们将移除 Amazon Linux 2 (AL2) 的 Linux 包构建。

Amazon Linux 2 将于 2026 年 6 月结束生命周期，之后将不再接收安全更新。
根据我们的 [Linux 包支持平台策略](https://gitlab.cn/docs/install/package/#supported-platforms)，我们会在厂商停止支持操作系统后至少提前六个月宣布，随后移除包构建。

如果您当前在 Amazon Linux 2 上运行极狐GitLab，您必须在升级到极狐GitLab 19.1 之前迁移到 Amazon Linux 2023 (AL2023) 或其他[支持的操作系统](https://gitlab.cn/docs/install/package/#supported-platforms)。
Amazon 提供了[迁移文档](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.migration-al.generic.from-al2.html)帮助您从 AL2 迁移到 AL2023。

<a id="gitlab-19.0"></a>

## 极狐GitLab 19.0

<a id="azure-storage-driver-for-the-container-registry"></a>

### 容器镜像仓库的 Azure 存储驱动

- 在极狐GitLab 17.10 中宣布
- 在极狐GitLab 19.0 中移除

容器镜像仓库的旧版 Azure 存储驱动在极狐GitLab 17.10 中弃用，并将在极狐GitLab 19.0 中移除。
如果您将 Azure 对象存储用于容器镜像仓库，并希望提前使用新驱动，需要更新配置以使用新的 `azure_v2` 驱动。在极狐GitLab 19.0 中，已弃用的 Azure 驱动将成为 `azure_v2` 驱动的别名，无需手动操作。

`azure_v2` 存储驱动相比旧版提供了更高的可靠性、更好的性能，并使用了更易维护的代码库。
这些改进有助于防止随着镜像仓库使用量增长而出现性能问题。

要迁移到 `azure_v2` 驱动：

1. 更新镜像仓库配置文件，使用 `azure_v2` 驱动代替旧版 `azure` 驱动。
1. 根据新驱动需求调整配置设置。
1. 在部署到生产环境之前，先在非生产环境中测试新配置。

有关更新存储驱动配置的更多信息，请参阅[使用对象存储](https://gitlab.cn/docs/administration/packages/container_registry/#use-object-storage)。

<a id="container-registry-aws-s3-signature-version-2-support"></a>

### 容器镜像仓库 AWS S3 签名版本 2 支持

- 在极狐GitLab 17.8 中宣布
- 在极狐GitLab 19.0 中移除

容器镜像仓库中使用 Amazon S3 签名版本 2 验证请求的支持在极狐GitLab 17.8 中弃用，并计划在极狐GitLab 19.0 中移除。

基于 AWS SDK v2 的新 S3v2 存储驱动（从极狐GitLab 17.10 Beta 版起可用，19.0 成为默认）仅支持签名版本 4。
一旦 S3v2 驱动成为默认，任何签名版本 2 的配置设置（如 `v4auth: false`）将被透明地忽略。

您可以在升级到 S3v2 成为默认驱动的极狐GitLab 版本之前迁移到签名版本 4。
此变更需要更新您的 S3 存储桶配置设置，并确保您的极狐GitLab 容器镜像仓库设置与签名版本 4 兼容。

要迁移：

1. 检查[极狐GitLab 容器镜像仓库设置中的 S3 存储后端配置](https://gitlab.cn/docs/administration/packages/container_registry/#use-object-storage)。
1. 如果 `v4auth` 设置为 `false`，请移除该选项。
1. 验证您现有的凭据是否适用于 v4 认证。

如果进行这些更改后遇到任何问题，请尝试重新生成您的 AWS 凭据。

<a id="enforce-page-limit-for-unauthenticated-projects-api-requests"></a>

### 对未认证的项目 API 请求强制执行页面限制

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

为了维护平台稳定性并确保所有客户获得最佳性能，我们将对未认证的项目 API 请求强制执行最大偏移限制。此偏移限制仅适用于 JihuLab.com。在极狐GitLab 私有化部署中，该偏移限制将通过功能标志默认禁用。

**变更内容**

所有对项目列表 REST API 的未认证请求将强制执行最大偏移限制 50,000。例如，当每页获取 20 条结果时，`page` 参数限制为 2,500 页。

需要访问更多数据的工作流必须改用基于键集的分页参数。

**重要性**

此限制通过有效管理资源使用，确保 JihuLab.com 的服务质量和性能保持一致。

<a id="linux-package-support-for-suse-distributions"></a>

### Linux 包对 SUSE 发行版的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

我们将在极狐GitLab 19.0 中终止对 SUSE 发行版的支持。这影响：

- openSUSE Leap 15.6
- SUSE Linux Enterprise Server 12.5
- SUSE Linux Enterprise Server 15.6

openSUSE Leap 15.6 即将结束生命周期。虽然 SUSE Linux Enterprise Server 通过长期服务仍受 SUSE 支持，但极狐GitLab 客户中对其的采用率太低，无法使持续支持具有商业可行性。

使用 Linux 包且位于这些发行版的客户将无法将极狐GitLab 升级至 `18.11.x` 之后的版本。

对于使用上述发行版的客户，我们建议在现有发行版上迁移到[极狐GitLab 的 Docker 部署](https://gitlab.cn/docs/install/docker/installation/)。
这样可以避免为了继续接收极狐GitLab 升级而迁移到不同的 Linux 发行版。

**更新**：由于 [SLES 12.5 上 RPM 包尺寸限制](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9716)，[Mattermost](https://gitlab.cn/docs/update/deprecations/#mattermost-bundled-with-linux-package) 和 [Spamcheck](https://gitlab.cn/docs/update/deprecations/#spamcheck-support-in-the-linux-package-and-gitlab-helm-chart) 已在极狐GitLab 18.11 中从 SLES 12.5 包中移除，早于它们在极狐GitLab 19.0 中所有发行版的计划移除时间。

<a id="linux-package-support-for-ubuntu-20.04"></a>

### Linux 包对 Ubuntu 20.04 的支持

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 19.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

Ubuntu 20.04 的标准支持已于 [2025 年 5 月结束](https://wiki.ubuntu.com/Releases)。

根据我们的 [Linux 包支持平台策略](https://gitlab.cn/docs/install/package/#supported-platforms)，我们会在厂商停止支持操作系统后停止提供包构建。

从极狐GitLab 19.0 起，我们将不再为 Ubuntu 20.04 发行版提供 Linux 包安装的包。
极狐GitLab 18.11 将是最后一个提供 Ubuntu 20.04 Linux 包的极狐GitLab 版本。

如果您当前在 Ubuntu 20.04 上运行极狐GitLab，您必须在升级到极狐GitLab 19.0 之前升级到 Ubuntu 22.04 或其他[支持的操作系统](https://gitlab.cn/docs/install/package/#supported-platforms)。
Canonical 提供了[升级指南](https://documentation.ubuntu.com/server/how-to/software/upgrade-your-release/)帮助您迁移。

<a id="mattermost-bundled-with-linux-package"></a>

### 与 Linux 包捆绑的 Mattermost

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 19.0 中，我们计划从 Linux 包中移除捆绑的 Mattermost。

Mattermost 于 2015 年首次与极狐GitLab 捆绑，作为开源团队消息传递解决方案，并包含了极狐GitLab SSO 以支持集成。此后，Mattermost 已显著成熟了其自身的打包和部署选项，极狐GitLab 客户中对捆绑 Mattermost 的采用率一直相对较低。

随着 Mattermost v11 的发布，[Mattermost 已在其免费产品中弃用了极狐GitLab SSO](https://forum.mattermost.com/t/mattermost-v11-changes-in-free-offerings/25126)。
鉴于这一变化、Mattermost 独立部署选项的成熟度以及我们客户群的低采用率，我们将从 Linux 包中移除 Mattermost。

如果您当前使用与极狐GitLab 捆绑的 Mattermost，请参阅 Mattermost 文档中的[从极狐GitLab Omnibus 迁移到独立 Mattermost](https://docs.mattermost.com/administration-guide/onboard/migrate-gitlab-omnibus.html)，了解迁移说明和可用的 Mattermost 版本。

<a id="resource-owner-password-credentials-grant-is-deprecated"></a>

### 资源所有者密码凭据授予已弃用

- 在极狐GitLab 18.0 中宣布
- 在极狐GitLab 19.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

使用资源所有者密码凭据 (ROPC) 授予作为 OAuth 流的方式已弃用，支持将在极狐GitLab 19.0 中完全移除。我们已添加一项设置，管理员可以在其实例中启用或禁用以仅使用客户端凭据的此授予类型。这让希望退出的用户能够在 19.0 之前选择不使用无客户端凭据的 ROPC。ROPC 将在 19.0 中完全移除，且之后即使使用客户端凭据也无法使用。

出于安全原因，极狐GitLab 自 2025 年 4 月 8 日起已[在 JihuLab.com 上要求对 ROPC 进行客户端认证](https://gitlab.cn/blog/improving-oauth-ropc-security-on-gitlab-com/)。完全移除 ROPC 支持使安全性符合 OAuth RFC 2.1 版本。

<a id="s3-storage-driver-(aws-sdk-v1)-for-the-container-registry"></a>

### 容器镜像仓库的 S3 存储驱动（AWS SDK v1）

- 在极狐GitLab 17.10 中宣布
- 在极狐GitLab 19.0 中移除

容器镜像仓库中使用 AWS SDK v1 的 S3 存储驱动已弃用，并将在极狐GitLab 19.0 中移除。
如果您将 S3 对象存储用于容器镜像仓库，并希望提前使用新驱动，必须更新配置以使用新的 `s3_v2` 驱动。在极狐GitLab 19.0 中，已弃用的 s3 驱动将成为 `s3_v2` 驱动的别名，无需手动操作。

`s3_v2` 存储驱动基于 AWS SDK v2，提供了更好的性能、更高的安全性以及来自 AWS 的持续支持。
它将于 2025 年 5 月推出，以取代已弃用的 [AWS SDK v1](https://aws.amazon.com/blogs/developer/announcing-end-of-support-for-aws-sdk-for-go-v1-on-july-31-2025/)，后者将于 2025 年 7 月 31 日终止支持。

`s3_v2` 驱动不再支持签名算法 v2。
如果配置中设置了 `v4auth: false` 选项，`s3_v2` 驱动将透明地忽略它，并使用更安全的 V4 算法。
要迁移到 `s3_v2` 驱动：
1. 更新您的 registry 配置文件，使用 `s3_v2` 配置替代 `s3`。
1. 如果尚未进行，请将身份验证从 Signature Version 2 迁移到 Signature Version 4，因为 AWS SDK v2 仅支持 Signature Version 4。
1. 在部署到生产环境之前，先在非生产环境中测试配置。

有关更新存储驱动配置的更多信息，请参见[使用对象存储](https://gitlab.cn/docs/administration/packages/container_registry/#use-object-storage)。

### Slack 斜杠命令

- 于极狐GitLab 18.7 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

[Slack 斜杠命令集成](https://gitlab.cn/docs/user/project/integrations/slack_slash_commands/)已被弃用，取而代之的是[极狐GitLab for Slack 应用](https://gitlab.cn/docs/user/project/integrations/gitlab_slack_application/)，后者提供了更安全的集成方法，并具有相同的能力。

从极狐GitLab 19.0 开始，用户将无法再配置或使用 Slack 斜杠命令集成。此集成仅适用于极狐GitLab 私有化部署实例。如果您使用的是 JihuLab.com，则无需执行任何操作。

如果您使用的是极狐GitLab 私有化部署，要了解是否受到影响，请查看[议题 569345](https://jihulab.com/gitlab-cn/gitlab/-/work_items/569345#am-i-impacted)。

### Linux 软件包和极狐GitLab Helm Chart 中的 Spamcheck 支持

- 于极狐GitLab 18.9 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 19.0 中，我们将从 Linux 软件包和极狐GitLab Helm Chart 中移除 [Spamcheck](https://gitlab.cn/docs/administration/reporting/spamcheck/)。

Spamcheck 是一项用于对抗面向公众的极狐GitLab 实例上的垃圾信息的服务。就其性质而言，此功能主要与大型公共实例相关，这在我们的客户群中属于边缘案例。

鉴于采用率低且存在独立部署选项，我们将从 Linux 软件包和极狐GitLab Helm Chart 中移除 Spamcheck。不使用 Spamcheck 的客户不会受到此变更的影响。此移除将减少软件包大小和依赖项占用空间（从而提高安全性），惠及大多数客户。

如果您当前使用捆绑的 Spamcheck，可以使用 [Docker](https://jihulab.com/gitlab-cn/gl-security/security-engineering/security-automation/spam/spamcheck) 单独部署它。

无需数据迁移。配置指南可在链接的文档中找到。

### 对 NGINX Ingress 的支持

- 于极狐GitLab 18.9 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab Helm Chart 当前捆绑 NGINX Ingress 作为默认网络组件。随着 NGINX Ingress 于 2026 年 3 月达到生命周期终止，我们正在过渡到使用 Envoy Gateway 的 Gateway API。

从极狐GitLab 19.0 开始，Gateway API 和捆绑的 Envoy Gateway 将成为默认配置。如果迁移到 Envoy Gateway 对您的部署不可行，您可以显式重新启用捆绑的 NGINX Ingress，该组件在计划于极狐GitLab 20.0 移除之前仍然可用。

此变更不影响 Linux 软件包中的 NGINX，也不影响使用外部管理的 Ingress 或 Gateway API 控制器的极狐GitLab Helm Chart 和极狐GitLab Operator 实例。

我们将为我们的分支 NGINX Ingress Chart 和构建提供尽力而为的安全维护，直至完全移除。为确保平稳过渡，我们建议您规划迁移到提供的 Gateway API 解决方案或外部管理的 Ingress 控制器。

### 对 PostgreSQL 16 的支持

- 于极狐GitLab 18.9 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab 遵循 [PostgreSQL 年度升级节奏](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)。

对 PostgreSQL 16 的支持计划于极狐GitLab 19.0 移除。在极狐GitLab 19.0 中，PostgreSQL 17 成为最低要求的 PostgreSQL 版本。

PostgreSQL 17 从极狐GitLab 18.9 起可用，您可以在极狐GitLab 19.0 移除 PostgreSQL 16 之前的任何时间进行升级。

如果您运行的是使用 Linux 软件包安装的单个 PostgreSQL 实例，18.11 版本可能会尝试自动升级。请确保有足够的磁盘空间来容纳升级。

有关更多信息，请参见[升级打包的 PostgreSQL 服务器](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

### 对 Redis 6 的支持

- 于极狐GitLab 18.10 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 19.0 中，我们计划移除对 Redis 6 的支持，作为我们维护安全且可支持的基础设施栈的承诺的一部分。

在升级到极狐GitLab 19.0 之前，您必须运行以下之一：

- Redis 7.2。
- Valkey 7.2，从极狐GitLab 18.9 起以测试版提供，并计划于极狐GitLab 19.0 GA。

Linux 软件包中包含的捆绑 Redis 自极狐GitLab 16.2 起已使用 Redis 7，不受影响。仅使用外部 Redis 6 部署的极狐GitLab 私有化部署实例必须迁移。

请参阅以下资源以迁移外部 Redis 6 部署：

- **AWS ElastiCache**：将您的 Redis 6 实例升级到 Redis 7.2 或 Valkey 7.2。有关可用的升级路径，请参见 [AWS ElastiCache 文档](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/supported-engine-versions.html)。
- **GCP Memorystore**：将您的 Redis 6 实例升级到 Redis 7.2 或 Valkey 7.2。有关可用的升级路径，请参见 [GCP Memorystore 文档](https://cloud.google.com/memorystore/docs/redis/supported-versions)。
- **Azure Cache for Redis**：Azure 上当前不提供托管的 Redis 7.2 或 Valkey 7.2 选项。您可以在 Azure VM 或 AKS 上自托管 Redis 7.2 或 Valkey 7.2。您也可以使用极狐GitLab Linux 软件包安装方法，该方法将支持 Valkey 7.2，并计划于极狐GitLab 19.0 GA。
- **自托管**：将您的 Redis 6 实例升级到 Redis 7.2 或 Valkey 7.2。

有关更多信息，请参见[要求文档](https://gitlab.cn/docs/install/requirements/)。

### 极狐GitLab Helm Chart 中对捆绑的 PostgreSQL、Redis 和 MinIO 的支持

- 于极狐GitLab 18.9 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab Helm Chart 捆绑了 Bitnami PostgreSQL、Bitnami Redis 以及官方 MinIO Chart 的一个分支，以简化极狐GitLab 的设置。由于许可、项目维护和公共镜像可用性方面的多项变更，这些组件将从极狐GitLab Helm Chart 和极狐GitLab Operator 中移除，且无替代品。

这些 Chart 当前默认启用，但明确记录为不建议用于生产环境。它们的唯一目的是实现快速设置概念验证和测试环境。

如果您正在运行带有捆绑的 PostgreSQL、Redis 或 MinIO 的实例，请查看[迁移指南](https://gitlab.cn/docs/charts/installation/migration/bundled_chart_migration/)。

Linux 软件包提供的 Redis 和 PostgreSQL 不受此变更影响。

### `ci_job_token_scope_enabled` 项目 API 属性已弃用

- 于极狐GitLab 16.4 宣布
- 于极狐GitLab 19.0 移除

[限制从此项目访问](https://gitlab.cn/docs/update/deprecations/#cicd-job-token---limit-access-from-your-project-setting-removal) CI/CD 作业令牌项目设置已在 18.0 中移除。[项目 API](https://gitlab.cn/docs/api/projects/) 中相关的 `ci_job_token_scope_enabled` 属性现已弃用，并始终返回 `false`，因此将在 19.0 中移除。要控制作业令牌访问，请使用 [CI/CD 作业令牌项目设置](https://gitlab.cn/docs/ci/jobs/ci_job_token/#control-job-token-access-to-your-project)。

### `heroku/builder:22` 镜像已弃用

- 于极狐GitLab 17.4 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

Auto DevOps Build 项目中的云原生构建包（CNB）构建器镜像已更新为 `heroku/builder:24`。虽然我们预计这些变更在大多数情况下不会造成破坏，但对于某些 Auto DevOps 用户，尤其是 Auto Build 用户，这可能是重大变更。为了更好地了解对您工作负载的影响，请查看以下内容：

- [Heroku-24 堆栈发布说明](https://devcenter.heroku.com/articles/heroku-24-stack#what-s-new)
- [Heroku-24 堆栈升级说明](https://devcenter.heroku.com/articles/heroku-24-stack#upgrade-notes)
- [Heroku 堆栈软件包](https://devcenter.heroku.com/articles/stack-packages)

如果您的流水线使用了由 [Auto DevOps 的 Auto Build 阶段](https://gitlab.cn/docs/topics/autodevops/stages/#auto-build)提供的 [`auto-build-image`](https://jihulab.com/gitlab-cn/cluster-integration/auto-build-image)，这些变更会影响您。

要在极狐GitLab 19.0 之后继续使用 `heroku/builder:22`，请将 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 设置为 `heroku/builder:22`。

### 探索项目页面中的热门标签页已弃用

- 于极狐GitLab 18.8 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

**探索** > **项目**中的**热门**标签页及其关联的 GraphQL 参数在极狐GitLab 18.8 中已弃用，并将在极狐GitLab 19.0 中移除。在极狐GitLab 19.0 发布前的一个月内，JihuLab.com 上的**热门**标签页将重定向到按星标降序排列的**活跃**标签页。

**正在移除的内容**

- **探索** > **项目**页面上的**热门**标签页
- 以下 GraphQL 类型中的 trending 参数：
  - `Query.adminProjects`
  - `Query.projects`
  - `Organization.projects`

**我们进行此变更的原因**

热门算法仅考虑公开项目，这使得它对于主要使用内部或私有可见性的极狐GitLab 私有化部署实例无效。该算法的局限性和缺乏搜索能力已导致私有化部署用户明确要求移除。我们不再投入大量改进，而是将资源集中在增强现有的发现机制上。

**所需操作**

UI 用户：**热门**标签页将在下一个重大变更窗口期间无法访问，然后在 19.0 中完全移除。我们建议使用**活跃**标签页查看最近更新或星标最多的项目。

### 在 Bitbucket Cloud 导入极狐GitLab API 中使用应用密码

- 于极狐GitLab 18.9 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

Atlassian 已弃用 Bitbucket Cloud 的应用密码（用户名和密码身份验证），并[宣布](https://www.atlassian.com/blog/bitbucket/bitbucket-cloud-transitions-to-api-tokens-enhancing-security-with-app-password-deprecation)此身份验证方法将于 2026 年 6 月 9 日停止工作。

从极狐GitLab 19.0 开始，如果您想通过极狐GitLab API 从 Bitbucket Cloud 导入仓库，必须改用[用户 API 令牌](https://support.atlassian.com/organization-administration/docs/understand-user-api-tokens/)。

通过极狐GitLab UI 从 Bitbucket Server 或 Bitbucket Cloud 导入仓库的用户不受影响。

### `ciJobTokenScopeAddProject` GraphQL 变更已弃用

- 于极狐GitLab 17.5 宣布
- 于极狐GitLab 19.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

随着极狐GitLab 18.0 中 [CI/CD 作业令牌默认行为变更](https://gitlab.cn/docs/update/deprecations/#default-cicd-job-token-ci_job_token-scope-changed)的到来，我们也将弃用相关的 `ciJobTokenScopeAddProject` GraphQL 变更，转而使用 `ciJobTokenScopeAddGroupOrProject`。

## 极狐GitLab 18.8

### 静态合规违规报告

- 于极狐GitLab 18.2 宣布
- 于极狐GitLab 18.8 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

现有的静态合规违规报告在极狐GitLab 18.2 中已弃用，并将在极狐GitLab 18.8 中移除。

要替换静态合规违规报告：

- 在极狐GitLab 17.11 中，我们发布了[自定义合规框架](https://gitlab.cn/docs/user/compliance/compliance_frameworks/)。
- 在极狐GitLab 18.2 中，我们发布了新的[动态合规违规报告](https://gitlab.cn/docs/user/compliance/compliance_center/compliance_violations_report/)。

这些功能提供了与静态违规报告相同的所有功能，但您可以配置所需的违规项。

在极狐GitLab 18.8 中，我们将使用合规框架的动态报告替换静态合规违规报告，以实现更准确的需求和控制报告。

## 极狐GitLab 18.6

### 早期 Mistral 模型弃用，针对极狐GitLab Duo 自部署版

- 于极狐GitLab 18.3 宣布
- 于极狐GitLab 18.6 终止支持
- 于极狐GitLab 18.6 移除

在极狐GitLab 18.6 中，极狐GitLab 将移除对 Mistral 7B-it、Mixtral 8x7B 和 Mixtral 8x22B 模型的支持，这些模型用于极狐GitLab Duo 自部署版。极狐GitLab Duo 企业版客户可以继续在极狐GitLab Duo 自部署版中使用这些模型，但将不再获得针对这些模型配置的技术支持。极狐GitLab Duo 自部署版将继续支持 Mistral Small 24B Instruct 2506，该模型已[验证为与所有 GA 的极狐GitLab Duo 自部署版功能完全兼容](https://gitlab.cn/docs/administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements/)。

### 与 Omnibus Linux 软件包捆绑的 Prometheus 2.x

- 于极狐GitLab 18.3 宣布
- 于极狐GitLab 18.6 移除

与 Linux 软件包捆绑的 Prometheus 2.x 已弃用，并将在极狐GitLab 18.6 中更新到最新的 Prometheus 3.x 版本。

Prometheus 3 包含一些潜在的破坏性变更，例如新的日志格式和更严格的标头验证。有关更多信息，请参见 [Prometheus 迁移指南](https://prometheus.io/docs/prometheus/3.0/migration)。

此变更不影响极狐GitLab Helm Chart 安装。

### 用合规状态仪表板替换合规标准遵守情况仪表板

- 于极狐GitLab 17.11 宣布
- 于极狐GitLab 18.6 移除

在极狐GitLab 17.11 中，我们发布了：

- [自定义合规框架](https://gitlab.cn/docs/user/compliance/compliance_frameworks/)。
- [合规状态报告](https://gitlab.cn/docs/user/compliance/compliance_center/compliance_status_report/)。

这些功能提供了与合规标准遵守情况仪表板相同的所有功能，但您可以配置所需的遵守情况。

在极狐GitLab 18.6 中，我们将用合规状态仪表板替换合规标准遵守情况仪表板，以实现更准确的需求和控制报告。

### 禁用精确代码搜索的用户设置

- 于极狐GitLab 18.3 宣布
- 于极狐GitLab 18.6 移除

禁用精确代码搜索的用户设置现已弃用。在 JihuLab.com 上，您无法再在个人资料偏好设置中禁用精确代码搜索。

精确代码搜索提供了更好的用户体验，并与现有搜索 API 兼容。此用户设置计划于极狐GitLab 18.6 移除，以确保所有用户都能受益于改进的搜索功能。

## 极狐GitLab 18.5

### 高级搜索中对 OpenSearch 1.x 的支持

- 于极狐GitLab 18.2 宣布
- 于极狐GitLab 18.5 移除

[OpenSearch 1.x 的维护窗口](https://opensearch.org/releases/#maintenance-policy)已结束。对于极狐GitLab 私有化部署，管理员必须升级其 OpenSearch 实例才能使用高级搜索。

## 极狐GitLab 18.4

### 极狐GitLab Chart 中的 Bitnami PostgreSQL 和 Redis 镜像

- 于极狐GitLab 18.4 宣布
- 于极狐GitLab 18.4 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab Helm Chart 默认配置依赖 Bitnami Chart 和容器镜像来提供 PostgreSQL 和 Redis。Bitnami 将于 2025 年 9 月 29 日从其免费目录中停用这些镜像。从 2025 年 8 月 28 日开始，间歇性中断会暂时使镜像不可用。

极狐GitLab Chart 捆绑 Bitnami 的 PostgreSQL 和 Redis 仅用于演示和测试目的。它们不属于任何[受支持的极狐GitLab 参考架构](https://gitlab.cn/docs/administration/reference_architectures/)。如果您使用的是参考架构，或者使用其他供应商的软件包或镜像部署了外部 PostgreSQL 和 Redis，则**不受**此变更影响。

作为临时解决方案，极狐GitLab 已将 Chart 配置迁移到 Bitnami 旧版仓库。但是，未打补丁的极狐GitLab Chart 环境（极狐GitLab 17.11、极狐GitLab 18.0.5、极狐GitLab 18.1.4 和极狐GitLab 18.2.1 或更早版本）将继续从已弃用的 Bitnami 仓库拉取镜像，这将在 9 月 29 日之后导致部署失败，并可能在间歇性中断阶段导致部署失败。

如果您正在运行受影响的极狐GitLab Chart 配置，必须执行以下操作之一：

- 迁移到受支持的极狐GitLab 参考架构。
- 升级到已打补丁的 Chart 版本。
- 在 Chart 值中配置旧版仓库。有关示例，请参见[合并请求 4421](https://jihulab.com/gitlab-cn/charts/gitlab/-/merge_requests/4421)。

展望未来，[我们将评估替代方案](https://jihulab.com/gitlab-cn/charts/gitlab/-/issues/6089)，以替换或可能从极狐GitLab Chart 中完全移除 Bitnami 组件。有关更多信息，请参见[官方 Bitnami 公告](https://github.com/bitnami/charts/issues/35164)。

## 极狐GitLab 18.3

### cert-manager Helm Chart 更新

- 于极狐GitLab 18.0 宣布
- 于极狐GitLab 18.3 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

为了启用较新 cert-manager Chart 的模式验证，极狐GitLab Helm Chart 的 `certmanager.install` 值已弃用，取而代之的是 `installCertmanager`。模式定义不接受我们在极狐GitLab Chart 的 `certmanager` 部分中添加的额外属性。

在极狐GitLab 18.3（极狐GitLab Chart 9.3）中，我们将移除已弃用的值并更新捆绑的 cert-manager。

如果您之前使用过 `certmanager.install` 设置：

1. 将 `certmanager.install` 的值转移到 `installCertmanager`。
1. 完全移除 `certmanager.install` 设置。

另请查看 cert-manager 发布说明：

- [发布说明 1.12 - 1.16](https://cert-manager.io/docs/releases/upgrading/upgrading-1.12)
- [发布说明 1.17](https://cert-manager.io/docs/releases/upgrading/upgrading-1.16-1.17)

## 极狐GitLab 18.1

### 流水线作业限制扩展到 Commits API

- 于极狐GitLab 17.7 宣布
- 于极狐GitLab 18.1 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

从极狐GitLab 18.0 开始，[活跃流水线中的最大作业数](https://gitlab.cn/docs/administration/instance_limits/#number-of-jobs-in-active-pipelines)也将适用于使用 [Commits API](https://gitlab.cn/docs/api/commits/#set-the-pipeline-status-of-a-commit) 创建作业时。请检查您的集成，确保其保持在配置的作业限制内。

## 极狐GitLab 18.0

### API Discovery 将默认使用分支流水线

- 于极狐GitLab 17.9 宣布
- 于极狐GitLab 18.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 18.0 中，我们将更新 API Discovery 的 CI/CD 模板（`API-Discovery.gitlab-ci.yml`）的默认行为。

在极狐GitLab 18.0 之前，此模板配置作业默认在打开 MR 时在[合并请求（MR）流水线](https://gitlab.cn/docs/ci/pipelines/merge_request_pipelines/)中运行。从极狐GitLab 18.0 开始，我们将使此模板的行为与其他 AST 扫描器的[稳定模板版本](https://gitlab.cn/docs/user/application_security/detect/roll_out_security_scanning/#template-editions)的行为保持一致：

- 默认情况下，模板将在分支流水线中运行扫描作业。
- 您将能够设置 CI/CD 变量 `AST_ENABLE_MR_PIPELINES: true`，以便在打开 MR 时改用 MR 流水线。

### 应用安全测试分析器主版本更新

- 于极狐GitLab 17.9 宣布
- 于极狐GitLab 18.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在极狐GitLab 18.0 中，我们将更新所有应用安全测试分析器容器镜像的主版本。

如果您未使用默认包含的模板，或者已固定分析器版本，则必须更新 CI/CD 作业定义，以移除固定版本或更新到最新的主版本。

极狐GitLab 17.0 至 17.11 的用户将继续收到分析器更新，直到极狐GitLab 18.0 发布，此后所有新修复的错误和发布的功能将仅在新主版本的分析器中发布。但是，我们不会从容器镜像仓库中移除任何已发布的容器镜像。

根据我们的维护政策，我们不会将错误和功能向后移植到已弃用的版本。根据需要，安全补丁将在最新的 3 个次要版本内进行向后移植。

具体来说，以下分析器在极狐GitLab 18.0 发布后将不再更新：

- 极狐GitLab Advanced SAST：版本 1
- 容器扫描：版本 7
- Gemnasium：版本 5
- DAST：版本 5
- DAST API：版本 4
- Fuzz API：版本 4
- IaC 扫描：版本 5
- 流水线密钥检测：版本 6
- 静态应用安全测试（SAST）：[所有分析器](https://gitlab.cn/docs/user/application_security/sast/analyzers/)的版本 5
  - `kics`
  - `kubesec`
  - `pmd-apex`
  - `semgrep`
  - `sobelow`
  - `spotbugs`

<a id="behavior-change-for-upcoming-and-started-milestone-filters"></a>

### 即将开始和已开始的里程碑过滤器行为变更
- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

“即将开始”和“已开始”特殊过滤器的行为计划在即将发布的极狐GitLab 主要版本 18.0 中更改。这两个过滤器的新行为在议题 429728 中进行了概述。

此更改不会影响极狐GitLab REST API，它将继续使用现有的里程碑过滤逻辑。极狐GitLab GraphQL API 将更新以遵循新的过滤逻辑。

### CI/CD 作业令牌 - **授权群组和项目** 允许列表强制执行

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

通过极狐GitLab 15.9 中引入的[**授权群组和项目**设置](https://gitlab.cn/docs/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)（在极狐GitLab 16.3 中从 **限制访问 _此_ 项目** 重命名），你可以控制对项目的 CI/CD 作业令牌访问。当设置为 **仅此项目及允许列表中的任何群组和项目** 时，只有添加到允许列表中的群组或项目才能使用作业令牌访问你的项目。

对于在极狐GitLab 15.9 之前创建的项目，允许列表默认处于禁用状态（选择了[**所有群组和项目**](https://gitlab.cn/docs/ci/jobs/ci_job_token/#allow-any-project-to-access-your-project)访问设置），允许来自任何项目的作业令牌访问。现在，所有新项目中默认启用允许列表。在旧项目中，它可能仍然处于禁用状态，或者你可能已手动选择 **所有群组和项目** 选项以使访问不受限制。

从极狐GitLab 17.6 开始，私有化部署实例的管理员可以选择为所有项目[强制执行此更安全的设置](https://gitlab.cn/docs/administration/settings/continuous_integration/#job-token-permissions)。此设置可防止项目维护者选择 **所有群组和项目**。此更改可确保项目之间更高级别的安全性。

在极狐GitLab 18.0 中，此实例设置将在 JihuLab.com 和私有化部署上默认启用。私有化部署管理员可以在升级到极狐GitLab 18.0 后禁用该设置以恢复升级前的行为。对于私有化部署，极狐GitLab 18.0 中不会更改任何项目设置，但实例设置的状态会影响实例上的所有项目。

为了准备此更改，使用作业令牌进行跨项目身份验证的项目维护者应填充其项目的 **授权群组和项目** 允许列表。然后，他们应将设置更改为 **仅此项目及允许列表中的任何群组和项目**。

为了帮助识别需要通过 CI/CD 作业令牌进行身份验证来访问你的项目的项目，在极狐GitLab 17.6 中，我们还引入了一种方法来[跟踪作业令牌身份验证](https://gitlab.cn/releases/2024/11/21/gitlab-17-6-released/#track-cicd-job-token-authentications)到你的项目。你可以使用该数据来填充你的 CI/CD 作业令牌允许列表。

从极狐GitLab 17.10 到 18.6，你可以使用[迁移工具](https://archives.docs.gitlab.com/18.6/ci/jobs/ci_job_token/#auto-populate-a-projects-allowlist)从作业令牌身份验证日志自动填充 CI/CD 作业令牌允许列表。我们鼓励你使用此迁移工具在[极狐GitLab 18.0 中普遍强制执行允许列表](https://gitlab.cn/docs/update/deprecations/?removal_milestone=18.0#cicd-job-token-authorized-groups-and-projects-allowlist-enforcement)之前填充并使用允许列表。在极狐GitLab 18.0 中，将按照先前宣布的在 JihuLab.com 上自动填充和强制执行允许列表。

此迁移工具在极狐GitLab 18.7 中已被移除。

### CI/CD 作业令牌 - **限制从你的项目访问** 设置移除

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

在极狐GitLab 14.4 中，我们引入了一项设置，用于[限制 _从_ 你的项目的 CI/CD 作业令牌 (`CI_JOB_TOKEN`) 访问](https://gitlab.cn/docs/ci/jobs/ci_job_token/#limit-your-projects-job-token-access)，以使其更加安全。此设置称为 **限制 CI_JOB_TOKEN 访问**。在极狐GitLab 16.3 中，为了清晰起见，我们将此设置重命名为 **限制 _从_ 此项目访问**。

在极狐GitLab 15.9 中，我们引入了一个名为[**授权群组和项目**](https://gitlab.cn/docs/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)的替代设置。此设置通过使用允许列表来控制对你的项目的作业令牌访问。这个新设置比原始设置有重大改进。第一个迭代在极狐GitLab 16.0 中被弃用，并计划在极狐GitLab 18.0 中移除。

默认情况下，所有新项目都禁用 **限制 _从_ 此项目访问** 设置。在极狐GitLab 16.0 及更高版本中，在任何项目中禁用此设置后，你无法重新启用它。相反，请使用 **授权群组和项目** 设置来控制对你的项目的作业令牌访问。

### DAST `dast_crawl_extract_element_timeout` 和 `dast_crawl_search_element_timeout` 变量已弃用

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除
- 要讨论此更改或了解更多信息，请参阅弃用议题。

DAST 变量 `DAST_CRAWL_EXTRACT_ELEMENT_TIMEOUT` 和 `DAST_CRAWL_SEARCH_ELEMENT_TIMEOUT` 已弃用，并将在极狐GitLab 18.0 中移除。当初引入这些变量时，它们为特定的浏览器交互提供了细粒度的超时控制。现在，这些交互由通用超时值控制，这使得这些变量变得多余。此外，由于底层实现问题，自 DAST 基于浏览器的分析器引入以来，这些变量一直未起作用。移除这两个变量将简化 DAST 配置，并为用户提供更好的入门体验。

### DAST `dast_devtools_api_timeout` 将具有较低的默认值

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

`DAST_DEVTOOLS_API_TIMEOUT` 环境变量确定 DAST 扫描等待浏览器响应的时间。在极狐GitLab 18.0 之前，该变量具有 45 秒的静态值。在极狐GitLab 18.0 之后，`DAST_DEVTOOLS_API_TIMEOUT` 环境变量将具有一个动态值，该值根据其他超时配置计算得出。在大多数情况下，45 秒的值高于许多扫描器功能的超时值。动态计算的值通过增加其适用情况的数量，使 `DAST_DEVTOOLS_API_TIMEOUT` 变量更有用。

为了减少潜在的中断，我们将根据以下时间表逐步调整默认超时值：

| 超时值 | 里程碑             |
|:------|:------------------|
| 45    | 17.11 及更早版本   |
| 30    | 18.0              |
| 20    | 18.1              |
| 10    | 18.2              |
| 5     | 18.3              |

### 依赖代理令牌范围强制执行

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

容器镜像的依赖代理接受使用个人访问令牌或群组访问令牌的 `docker login` 和 `docker pull` 请求，而无需验证其范围。

在极狐GitLab 18.0 中，依赖代理将要求身份验证同时具有 `read_registry` 和 `write_registry` 范围。在此更改之后，使用没有这些范围的令牌的身份验证尝试将被拒绝。

这是一个重大更改。在升级之前，请创建具有[所需范围](https://gitlab.cn/docs/user/packages/dependency_proxy/#authenticate-with-the-dependency-proxy-for-container-images)的新访问令牌，并使用这些新令牌更新你的工作流变量和脚本。

要评估此更改如何影响你的私有化部署实例，你可以在极狐GitLab 17.10 及更高版本中监控身份验证日志中的警告消息。在你的 `auth_json.log` 文件中，查找包含 `Dependency proxy missing authentication abilities` 的条目。如果你使用极狐GitLab Helm charts，则日志将位于 `component: "gitlab"` 和 `subcomponent: "auth_json"` 中。这些条目显示使用没有所需范围的令牌的身份验证尝试，这些尝试在升级到极狐GitLab 18.0 后将失败。

### 弃用 Terraform CI/CD 模板

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

Terraform CI/CD 模板已弃用，并将在极狐GitLab 18.0 中移除。这会影响以下模板：

- `Terraform.gitlab-ci.yml`
- `Terraform.latest.gitlab-ci.yml`
- `Terraform/Base.gitlab-ci.yml`
- `Terraform/Base.latest.gitlab-ci.yml`

在极狐GitLab 16.9 中，向模板添加了一个新作业，以通知用户弃用。可以通过在受影响的流水线中用占位作业覆盖 `deprecated-and-will-be-removed-in-18.0` 作业来关闭警告。

极狐GitLab 将无法将作业镜像中的 `terraform` 二进制文件更新为任何根据 BSL 许可的版本。

要继续使用 Terraform，请克隆模板和 [Terraform 镜像](https://jihulab.com/gitlab-cn/terraform-images)，并根据需要进行维护。极狐GitLab 提供了[详细说明](https://jihulab.com/gitlab-cn/terraform-images)，用于迁移到自定义构建的镜像。

作为替代方案，我们建议在 JihuLab.com 上使用新的 OpenTofu CI/CD 组件，或在私有化部署上使用新的 OpenTofu CI/CD 模板。CI/CD 组件在私有化部署上尚不可用，但议题 #415638 提议添加此功能。如果 CI/CD 组件在私有化部署上可用，则 OpenTofu CI/CD 模板将被移除。

请参阅有关[新 OpenTofu CI/CD 组件](https://jihulab.com/components/opentofu)的更多信息。

### 弃用许可证元数据格式 V1

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

许可证元数据格式 V1 数据集已弃用，并将在极狐GitLab 18.0 中移除。建议启用了 `package_metadata_synchronization` 功能标志的用户升级到极狐GitLab 16.3 或更高版本，并移除功能标志配置。

### 弃用 `NamespaceProjectSortEnum` GraphQL API 中的 `STORAGE` 枚举

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

极狐GitLab GraphQL API 的 `NamespaceProjectSortEnum` 中的 `STORAGE` 枚举将在极狐GitLab 18.0 中移除。

为了准备此更改，我们建议审查并更新与 `NamespaceProjectSortEnum` 交互的 GraphQL 查询。将对 `STORAGE` 字段的任何引用替换为 `EXCESS_REPO_STORAGE_SIZE_DESC`。

### 弃用 `ProjectMonthlyUsageType` GraphQL API 中的 `name` 字段

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

极狐GitLab GraphQL API 的 `ProjectMonthlyUsageType` 中的 `name` 字段将在极狐GitLab 18.0 中移除。

为了准备此更改，我们建议审查并更新与 `ProjectMonthlyUsageType` 交互的 GraphQL 查询。将对 `name` 字段的任何引用替换为 `project.name`。

### 对极狐GitLab NGINX chart 控制器镜像 v1.3.1 的回退支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

> [!note]
> 此更改仅影响你使用 [极狐GitLab NGINX chart](https://gitlab.cn/docs/charts/charts/nginx/) 且设置了自己的 NGINX RBAC 规则的情况。
>
> 如果你使用自己的[外部 NGINX chart](https://gitlab.cn/docs/charts/advanced/external-nginx/)，或者使用极狐GitLab NGINX chart 且未更改任何 NGINX RBAC 规则，则此弃用不适用于你。

在极狐GitLab 17.6（Helm chart 8.6）中，极狐GitLab chart 将默认 NGINX 控制器镜像从版本 1.3.1 更新到 1.11.2。此新版本需要新的 RBAC 规则，这些规则已添加到我们的极狐GitLab NGINX chart 中，因此你最终需要创建这些规则。此更改也已向后移植到：

- 极狐GitLab 17.5.1（Helm chart 8.5.1）
- 极狐GitLab 17.4.3（Helm chart 8.4.3）
- 极狐GitLab 17.3.6（Helm chart 8.3.6）

> [!note]
> Helm chart 8.3 至 8.7 的最新补丁版本包含 NGINX 控制器版本 1.11.2。后续 chart 版本包含版本 1.11.5，因为它包含各种安全修复。极狐GitLab 18.0 将默认使用控制器版本 1.11.5。

如果你管理自己的 NGINX RBAC 规则，这意味着你已将 `nginx-ingress.rbac.create` 设置为 `false`。在这种情况下，从极狐GitLab 17.3（Helm chart 8.3）直到极狐GitLab 17.11（Helm chart 8.11），存在一个回退机制，可检测到该更改并使用旧的控制器镜像，这意味着你无需进行任何 RBAC 规则更改。

从极狐GitLab 18.0（Helm chart 9.0）开始，此回退机制将被移除，因此将使用新的控制器镜像，并且必须存在新的 RBAC 规则。

如果你想在极狐GitLab 18.0 中强制执行之前利用新的 NGINX 控制器镜像：

1. 将新的 RBAC 规则添加到你的集群查看示例。
1. 将 `nginx-ingress.controller.image.disableFallback` 设置为 `true`。

有关更多信息，请参阅 [charts 发布页面](https://gitlab.cn/docs/charts/releases/8_0/#upgrade-to-86x-851-843-836)。

### Gitaly 速率限制

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除
- 要讨论此更改或了解更多信息，请参阅弃用议题。

由于 Git 操作和仓库延迟的高度可变性，Gitaly [基于 RPC 的速率限制](https://gitlab.cn/docs/administration/gitaly/monitoring/#monitor-gitaly-rate-limiting)无效。配置适当的速率限制具有挑战性，并且通常很快就会过时，因为有害操作很少会产生足够的每秒请求数来凸显出来。

Gitaly 已经支持[并发限制](https://gitlab.cn/docs/administration/gitaly/concurrency_limiting/)和一个[自适应限制附加组件](https://gitlab.cn/docs/administration/gitaly/concurrency_limiting/#adaptive-concurrency-limiting)，这些已在生产中证明运行良好。

由于 Gitaly 不直接暴露于外部网络，并且外部保护层（如负载均衡器）提供了更好的保护，因此速率限制效果较差。

因此，我们将弃用速率限制，转而采用更可靠的并发限制。Gitaly 基于 RPC 的速率限制将在极狐GitLab 18.0 中移除。

### 旧版 Web IDE 已弃用

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

基于 Vue 的旧版极狐GitLab Web IDE 实现将从极狐GitLab 中移除。此更改是在我们成功过渡到基于极狐GitLab VSCode Fork 的 Web IDE 之后进行的，该 Web IDE 自极狐GitLab 15.11 以来一直是默认的 Web IDE 体验。

此移除会影响仍在使用旧版 Web IDE 实现的用户。

为了准备此移除，请在你的极狐GitLab 实例上启用 `vscode_web_ide` 功能标志（如果之前已禁用）。

### 限制每个策略允许的扫描执行策略操作数量


<a id="reject-container-image-pull-policies-not-in-allowed_pull_policies"></a>

### 拒绝不在 `allowed_pull_policies` 中的容器镜像拉取策略

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/516107)。

所有配置的拉取策略都应出现在 Runner 的 `config.toml` 文件中指定的 [`allowed_pull_policies` 配置](https://gitlab.cn/docs/runner/executors/docker/#allow-docker-pull-policies)中。如果不在其中，作业将失败并显示 `incompatible pull policy` 错误。

在当前的实现中，当定义了多个拉取策略时，只要至少有一个拉取策略与 `allowed-pull-policies` 中的匹配，作业就会通过，即使其他策略未包含在内。

在极狐GitLab 18.0 中，只有当所有拉取策略都不匹配 `allowed-pull-policies` 时，作业才会失败。但是，与当前行为不同，作业将仅使用 `allowed-pull-policies` 中列出的拉取策略。这一区别可能导致当前通过的作业在极狐GitLab 18.0 中失败。

<a id="remove-duoproassigneduserscount-graphql-field"></a>

### 移除 `duoProAssignedUsersCount` GraphQL 字段

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/498671)。

在 18.0 中，我们将移除 `duoProAssignedUsersCount` GraphQL 字段。如果用户正在使用此字段与 [`aiMetrics` API](https://gitlab.cn/docs/api/graphql/reference/#aimetrics)，可能会遇到问题，他们可以改用 `duoAssignedUsersCount`。此移除是[修复以同时统计极狐GitLab Duo Pro 和 Duo 席位分配用户](https://jihulab.com/gitlab-cn/gitlab/-/issues/485510)的一部分。

<a id="rename-setprereceivesecretdetection-graphql-mutation-to-setsecretpushprotection"></a>

### 将 `setPreReceiveSecretDetection` GraphQL 变更重命名为 `setSecretPushProtection`

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/514414)。

`setPreReceiveSecretDetection` GraphQL 变更已重命名为 `setSecretPushProtection`。我们还将重命名变更响应中的一些字段，以反映功能名称从 `pre_receive_secret_detection` 到 `secret_push_protection` 的更改。

我们已添加新的变更名称，但将不再按原计划在极狐GitLab 18.0 中移除旧变更名称。

我们仍将更新数据库以[移除](https://jihulab.com/gitlab-cn/gitlab/-/issues/512996)旧的 `pre_receive_secret_detection_enabled` 数据库列，但你可以使用任一变更名称。两者都将反映新的 `secret_push_protection_enabled` 数据库列的值。

<a id="rename-options-to-skip-gitguardian-secret-detection"></a>

### 重命名跳过 GitGuardian 密钥检测的选项

- 在极狐GitLab 17.3 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/470119)。

跳过 GitGuardian 密钥检测的选项 `[skip secret detection]` 和 `secret_detection.skip_all` 已被弃用。你应改用 `[skip secret push protection]` 和 `secret_push_protection.skip_all`。

虽然我们建议使用新的措辞，但我们不再会在极狐GitLab 18.0 中移除旧选项。

<a id="replace-add_on_purchase-graphql-field-with-add_on_purchases"></a>

### 将 `add_on_purchase` GraphQL 字段替换为 `add_on_purchases`

- 在极狐GitLab 17.4 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/476858)。

`add_on_purchase` GraphQL 字段将在极狐GitLab 17.4 中弃用，并在极狐GitLab 18.0 中移除。请改用 `add_on_purchases` 字段。

<a id="replace-namespace-add_on_purchase-graphql-field-with-add_on_purchases"></a>

### 将命名空间 `add_on_purchase` GraphQL 字段替换为 `add_on_purchases`

- 在极狐GitLab 17.5 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/489850)。

命名空间 GraphQL 字段 `add_on_purchase` 将在极狐GitLab 17.5 中弃用，并在极狐GitLab 18.0 中移除。请改用根 `add_on_purchases` 字段。

<a id="support-for-suse-linux-enterprise-server-15-sp2"></a>

### 对 SUSE Linux Enterprise Server 15 SP2 的支持

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8888)。

SUSE Linux Enterprise Server (SLES) 15 SP2 的长期服务和支持 (LTSS) 已于 2024 年 12 月结束。

因此，我们将不再支持 SLES SP2 发行版的 Linux 软件包安装。你应升级到 SLES 15 SP6 以获得持续支持。

<a id="the-direction-graphql-argument-for-cijobtokenscoperemoveproject-is-deprecated"></a>

### `ciJobTokenScopeRemoveProject` 的 `direction` GraphQL 参数已弃用

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/383084)。

`ciJobTokenScopeRemoveProject` 变更的 `direction` GraphQL 参数已弃用。继[默认 CI/CD 作业令牌范围更改](https://gitlab.cn/docs/update/deprecations/#default-cicd-job-token-ci_job_token-scope-changed)于极狐GitLab 15.9 中宣布之后，`direction` 参数将在极狐GitLab 17.0 中默认为 `INBOUND`，且 `OUTBOUND` 将不再有效。我们将在极狐GitLab 18.0 中移除 `direction` 参数。

如果你使用 `OUTBOUND` 和 `direction` 参数来控制项目令牌访问的方向，则使用作业令牌的流水线可能面临认证失败的风险。为确保流水线继续按预期运行，你需要显式地[将其他项目添加到项目的允许列表中](https://gitlab.cn/docs/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)。

<a id="toggle-notes-confidentiality-on-apis"></a>

### 在 API 上切换评论机密性

- 在极狐GitLab 14.10 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/350670)。

通过 REST 和 GraphQL API 切换评论机密性的功能正在弃用。不再支持通过任何方式更新评论的机密属性。我们进行此更改是为了简化体验并防止私人信息被无意中暴露。

<a id="git_data_dirs-for-configuring-gitaly-storages"></a>

### 用于配置 Gitaly 存储的 `git_data_dirs`

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 18.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8786)。

[自 16.0 起](https://gitlab.cn/docs/update/versions/gitlab_16_changes/#gitaly-configuration-structure-change)，对 Linux 软件包实例使用 `git_data_dirs` 配置 Gitaly 存储的支持已被弃用，并将在 18.0 中移除。

有关迁移说明，请参阅[从 `git_data_dirs` 迁移](https://gitlab.cn/docs/omnibus/settings/configuration/#migrating-from-git_data_dirs)。

<a id="gitlab-17-11"></a>

## 极狐GitLab 17.11

<a id="oauth-ropc-grant-without-client-credentials-is-deprecated"></a>

### 不带客户端凭证的 OAuth ROPC 授权已弃用

- 在极狐GitLab 17.11 中宣布
- 在极狐GitLab 17.11 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/535298)。

自 2025 年 4 月 8 日起，JihuLab.com 要求对 OAuth 资源所有者密码凭证 (ROPC) OAuth 授权进行客户端认证。ROPC 在 RFC 版本 2.1 中被 OAuth 工作组省略。在此日期之后，没有客户端凭证的现有 ROPC 集成将遭遇服务中断。如果你遇到中断，请在截止日期前更新你的集成以包含客户端凭证。更多信息可[在我们的博客上](https://gitlab.cn/blog/2025/04/01/improving-oauth-ropc-security-on-gitlab-com/)找到。

<a id="gitlab-17-9"></a>

## 极狐GitLab 17.9

<a id="support-for-opensuse-leap-15-5"></a>

### 对 openSUSE Leap 15.5 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.9 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8778)。

[openSUSE Leap 的长期服务和支持 (LTSS) 于 2024 年 12 月结束](https://en.opensuse.org/Lifetime#openSUSE_Leap)。

因此，我们将不再支持 openSUSE Leap 15.5 发行版的 Linux 软件包安装。用户应升级到 openSUSE Leap 15.6 以获得持续支持。

<a id="gitlab-17-8"></a>

## 极狐GitLab 17.8

<a id="support-for-centos-7"></a>

### 对 CentOS 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8714)。

[CentOS 7 的长期服务和支持 (LTSS) 于 2024 年 6 月结束](https://www.redhat.com/en/topics/linux/centos-linux-eol)。

因此，我们将不再支持 CentOS 7 发行版的 Linux 软件包安装。用户应升级到其他操作系统以获得持续支持。

<a id="support-for-oracle-linux-7"></a>

### 对 Oracle Linux 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8746)。

[Oracle Linux 7 的长期服务和支持 (LTSS) 于 2024 年 12 月结束](https://wiki.debian.org/LTS)。

因此，我们将不再支持 Oracle Linux 7 发行版的 Linux 软件包安装。用户应升级到 Oracle Linux 8 以获得持续支持。

<a id="support-for-raspberry-pi-os-buster"></a>

### 对 Raspberry Pi OS Buster 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8734)。

Raspberry Pi OS Buster（以前称为 Raspbian Buster）的长期服务和支持 (LTSS) 已于 2024 年 6 月结束。

因此，我们将不再支持 PiOS Buster 发行版的 Linux 软件包安装。用户应升级到 PiOS Bullseye 以获得持续支持。

<a id="support-for-red-hat-enterprise-linux-7"></a>

### 对 Red Hat Enterprise Linux 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8714)。

Red Hat Enterprise Linux (RHEL) 7 已于 [2024 年 6 月结束维护支持](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux/rhel-7-end-of-maintenance)。

因此，我们将不再为 RHEL 7 及 RHEL 7 兼容的操作系统发布 Linux 软件包。用户应升级到 RHEL 8 以获得持续支持。

<a id="support-for-scientific-linux-7"></a>

### 对 Scientific Linux 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8745)。

[Scientific Linux 7 的长期服务和支持 (LTSS) 于 2024 年 6 月结束](https://scientificlinux.org/downloads/sl-versions/sl7/)。

因此，我们将不再支持 Scientific Linux 发行版的 Linux 软件包安装。用户应升级到其他 RHEL 兼容的操作系统。

<a id="gitlab-17-7"></a>

## 极狐GitLab 17.7

<a id="error-handling-for-repository-tree-rest-api-endpoint-returns-404"></a>

### `/repository/tree` REST API 端点的错误处理返回 `404`

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 17.7 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/420865)。

在极狐GitLab 17.7 中，当请求的路径未找到时，列出仓库树 API 端点 `/projects/:id/repository/tree` 的错误处理行为已更新。该端点现在返回状态码 `404 Not Found`。以前，状态码是 `200 OK`。

此更改已在极狐GitLab 16.5 中于 JihuLab.com 上启用，并将在极狐GitLab 17.7 中提供给私有化部署实例。

如果你的实现依赖于对缺失路径接收 `200` 状态码和空数组，则必须更新错误处理以处理新的 `404` 响应。

<a id="tls-1-0-and-1-1-no-longer-supported"></a>

### 不再支持 TLS 1.0 和 1.1

- 在极狐GitLab 17.4 中宣布
- 在极狐GitLab 17.7 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/164512)。

[OpenSSL 版本 1.1.1 的长期支持 (LTS) 于 2023 年 9 月结束](https://endoflife.date/openssl)。因此，OpenSSL 3 将成为极狐GitLab 17.7 中的默认版本。极狐GitLab 捆绑了 OpenSSL 3，因此你无需对操作系统进行任何更改。

随着升级到 OpenSSL 3：

- 极狐GitLab 要求所有传出和传入的 TLS 连接使用 TLS 1.2 或更高版本。
- TLS/SSL 证书必须具有至少 112 位的安全性。禁止使用短于 2048 位的 RSA、DSA 和 DH 密钥，以及短于 224 位的 ECC 密钥。

更多详情，请参阅[极狐GitLab 17.5 变更](https://gitlab.cn/docs/update/versions/gitlab_17_changes/#1750)。

<a id="gitlab-17-6"></a>

## 极狐GitLab 17.6

<a id="support-for-debian-10"></a>

### 对 Debian 10 的支持

- 在极狐GitLab 17.3 中宣布
- 在极狐GitLab 17.6 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8607)。

[Debian 10 的长期服务和支持 (LTSS) 于 2024 年 6 月结束](https://wiki.debian.org/LTS)。

因此，我们将不再支持 Debian 10 发行版的 Linux 软件包安装。用户应升级到 Debian 11 或 Debian 12 以获得持续支持。

<a id="gitlab-17-4"></a>

## 极狐GitLab 17.4

<a id="removed-needs-tab-from-the-pipeline-view"></a>

### 从流水线视图中移除了需求选项卡

- 在极狐GitLab 17.1 中宣布
- 在极狐GitLab 17.4 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/336560)。

我们将从流水线视图中移除需求选项卡，因为它重复了在常规流水线视图中使用 **作业依赖项** 分组选项所显示的信息。未来我们将继续改进主流水线图中的视图。

<a id="gitlab-17-3"></a>

## 极狐GitLab 17.3

<a id="fips-compliant-secure-analyzers-will-change-from-ubi-minimal-to-ubi-micro"></a>

### 符合 FIPS 的安全分析器将从 UBI Minimal 更改为 UBI Micro

- 在极狐GitLab 17.2 中宣布
- 在极狐GitLab 17.3 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/471869)。

我们正在更新一些用于扫描代码安全漏洞的分析器的基础镜像。我们只更改那些已经基于 Red Hat 通用基础镜像 (UBI) 的分析器镜像，因此此更改仅影响你专门为安全扫描启用了 [FIPS 模式](https://gitlab.cn/docs/development/fips_compliance/)的情况。极狐GitLab 安全扫描使用的默认镜像不受影响，因为它们不基于 UBI。

在极狐GitLab 17.3 中，我们将把基于 UBI 的分析器的基础镜像从 UBI Minimal 更改为 [UBI Micro](https://www.redhat.com/en/blog/introduction-ubi-micro)，后者包含更少的不必要软件包，并省略了包管理器。更新后的镜像将更小，并且受操作系统提供的软件包中漏洞的影响更少。

极狐GitLab 支持团队的[支持声明](https://gitlab.cn/support/statement-of-support/#ci-cd-templates)排除了未记录的定制，包括那些依赖于分析器镜像特定内容的定制。例如，在 `before_script` 中安装额外的软件包是不受支持的修改。尽管如此，如果你依赖此类定制，请参阅[此变更的弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/471869#action-required)以了解如何应对此变更或提供有关你当前定制的反馈。

<a id="gitlab-17-0"></a>

## 极狐GitLab 17.0

<a id="agent-for-kubernetes-option-ca-cert-file-renamed"></a>

### Kubernetes 代理选项 `ca-cert-file` 已重命名

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/437728)。

在极狐GitLab Kubernetes 代理 (agentk) 中，`--ca-cert-file` 命令行选项和相应的 `config.caCert` Helm chart 值已分别重命名为 `--kas-ca-cert-file` 和 `config.kasCaCert`。

旧的 `--ca-cert-file` 和 `config.caCert` 选项已弃用，并将在极狐GitLab 17.0 中移除。

<a id="auto-devops-support-for-herokuish-is-deprecated"></a>

### 对 Herokuish 的 Auto DevOps 支持已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/211643)。

对 Herokuish 的 Auto DevOps 支持已弃用，取而代之的是 [Cloud Native Buildpacks](https://gitlab.cn/docs/topics/autodevops/stages/#auto-build-using-cloud-native-buildpacks)。你应[将构建从 Herokuish 迁移到 Cloud Native Buildpacks](https://gitlab.cn/docs/topics/autodevops/stages/#moving-from-herokuish-to-cloud-native-buildpacks)。从极狐GitLab 14.0 开始，Auto Build 默认使用 Cloud Native Buildpacks。

由于 Cloud Native Buildpacks 不支持自动测试，Auto DevOps 的 Auto Test 功能也被弃用。

<a id="autogenerated-markdown-anchor-links-with-dash-characters"></a>

### 带连字符 (`-`) 的自动生成 Markdown 锚点链接

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/440733)。

极狐GitLab 会自动为所有标题创建锚点链接，以便你可以链接到 Markdown 文档或 Wiki 页面中的特定位置。但在某些边缘情况下，自动生成的锚点包含的连字符 (`-`) 数量少于许多用户的预期。例如，对于标题 `## Step - 1`，大多数其他 Markdown 工具和检查器会期望 `#step---1`。但极狐GitLab 生成的锚点是 `#step-1`，将连续的连字符压缩为一个。

在极狐GitLab 17.0 中，我们将通过不再去除连续的连字符，使自动生成的锚点与行业标准保持一致。如果你有 Markdown 文档并链接到在 17.0 中可能包含多个连字符的标题，则应更新标题以避免此边缘情况。使用上面的示例，你可以将 `## Step - 1` 更改为 `## Step 1`，以确保页面内链接继续有效。

<a id="cirunner-projects-default-sort-is-changing-to-id_desc"></a>

### CiRunner.projects 默认排序更改为 `id_desc`

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/372117)。

`CiRunner.projects` 字段的默认排序顺序值将从 `id_asc` 更改为 `id_desc`。如果你依赖返回项目的顺序为 `id_asc`，请更改脚本以明确指定排序。

<a id="compliance-framework-in-general-settings"></a>

### 通用设置中的合规框架

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/422783)。

我们已将合规框架管理移至[合规中心](https://gitlab.cn/docs/user/compliance/compliance_center/)的框架和项目报告中。

因此，在极狐GitLab 17.0 中，我们将从群组和项目的 **通用** 设置页面中移除合规框架的管理。

<a id="container-registry-support-for-the-swift-and-oss-storage-drivers"></a>

### 容器镜像仓库对 Swift 和 OSS 存储驱动的支持

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/container-registry/-/issues/1141)。

容器镜像仓库使用存储驱动与各种对象存储平台配合工作。虽然每个驱动的代码相对独立，但维护这些驱动的负担很高。每个驱动的实现都是独特的，对驱动进行更改需要对该特定驱动有高度的领域专业知识。

为了降低维护成本，我们弃用了对 OSS（对象存储服务）和 OpenStack Swift 的支持。这两者都已从上游 Docker Distribution 中移除。这有助于使容器镜像仓库与极狐GitLab 在[对象存储支持](https://gitlab.cn/docs/administration/object_storage/#supported-object-storage-providers)方面的更广泛产品保持一致。

OSS 具有 [S3 兼容模式](https://www.alibabacloud.com/help/en/oss/developer-reference/compatibility-with-amazon-s3)，因此如果你无法迁移到受支持的驱动，可以考虑使用该模式。Swift 也与 S3 存储驱动所需的 [S3 API 操作兼容](https://docs.openstack.org/swift/latest/s3_compat.html)。

<a id="dast-zap-advanced-configuration-variables-deprecation"></a>

### DAST ZAP 高级配置变量弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/383467)。

随着新的基于浏览器的 DAST 分析器在极狐GitLab 15.7 中 GA，我们正努力使其在未来某个时候成为默认的 DAST 分析器。为此，以下遗留的 DAST 变量被弃用，并计划在极狐GitLab 17.0 中移除：`DAST_ZAP_CLI_OPTIONS` 和 `DAST_ZAP_LOG_CONFIGURATION`。这些变量允许对基于 OWASP ZAP 的遗留 DAST 分析器进行高级配置。新的基于浏览器的分析器将不包含相同的功能，因为这些是特定于 ZAP 工作方式的。

这三个变量将在极狐GitLab 17.0 中移除。

<a id="dependency-scanning-incorrect-sbom-metadata-properties"></a>

### 依赖项扫描中不正确的 SBOM 元数据属性

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/438779)。

极狐GitLab 17.0 移除了对 CycloneDX SBOM 报告中以下元数据属性的支持：

- `gitlab:dependency_scanning:input_file`
- `gitlab:dependency_scanning:package_manager`

这些属性是在极狐GitLab 15.7 中添加到依赖项扫描生成的 SBOM 中的。但是，这些属性不正确，并且不符合[极狐GitLab CycloneDX 属性分类法](https://gitlab.cn/docs/development/sec/cyclonedx_property_taxonomy/)。为解决此问题，极狐GitLab 15.11 中添加了以下正确的属性：

- `gitlab:dependency_scanning:input_file:path`
- `gitlab:dependency_scanning:package_manager:name`

不正确的属性被保留以实现向后兼容。它们现在已被弃用，并将在 17.0 中移除。

<a id="dependency-scanning-support-for-sbt-1-0-x"></a>

### 对 sbt 1.0.X 的依赖项扫描支持

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/415835)。

支持非常旧的 sbt 版本阻碍了我们改进对此包管理器的额外用例支持，而不会增加维护成本。

sbt 1.1.0 版本于 6 年前发布，建议用户从 1.0.x 升级，因为依赖项扫描将不再有效。

<a id="deprecate-graphql-fields-related-to-the-temporary-storage-increase"></a>

### 弃用与临时存储增加相关的 GraphQL 字段

- 在极狐GitLab 16.7 中宣布
- 在极狐GitLab 17.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/385720)。

GraphQL 字段 `isTemporaryStorageIncreaseEnabled` 和 `temporaryStorageIncreaseEndsOn` 已被弃用。这些 GraphQL 字段与临时存储增加项目相关。该项目已被取消，且这些字段未被使用。

<a id="deprecate-grype-scanner-for-container-scanning"></a>

### 弃用用于容器扫描的 Grype 扫描器

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/439164)。

在极狐GitLab 16.9 中，对极狐GitLab 容器扫描分析器中 Grype 扫描器的支持已被弃用。

从极狐GitLab 17.0 起，Grype 分析器将不再维护，除非根据我们的[支持声明](https://gitlab.cn/support/statement-of-support/#version-support)进行有限的修复。

建议用户使用 `CS_ANALYZER_IMAGE` 的默认设置，该设置使用 Trivy 扫描器。
### Deprecate License Scanning CI templates

<a id="deprecate-license-scanning-ci-templates"></a>

### 弃用许可证扫描 CI 模板

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

极狐GitLab 17.0 移除了许可证扫描 CI 模板：

- [`Jobs/License-Scanning.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/6d9956863d3cd066edc50a29767c2cd4a939c6fd/lib/gitlab/ci/templates/Jobs/License-Scanning.gitlab-ci.yml)
- [`Jobs/License-Scanning.latest.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/6d9956863d3cd066edc50a29767c2cd4a939c6fd/lib/gitlab/ci/templates/Jobs/License-Scanning.latest.gitlab-ci.yml)
- [`Security/License-Scanning.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/6d9956863d3cd066edc50a29767c2cd4a939c6fd/lib/gitlab/ci/templates/Security/License-Scanning.gitlab-ci.yml)

包含上述任何模板的 CI 配置将在极狐GitLab 17.0 中停止工作。

建议用户改用 [CycloneDX 文件的许可证扫描](https://gitlab.cn/docs/user/compliance/license_scanning_of_cyclonedx_files/)。

### Deprecate Python 3.9 in dependency scanning and license scanning

<a id="deprecate-python-3-9-in-dependency-scanning-and-license-scanning"></a>

### 弃用依赖扫描和许可证扫描中的 Python 3.9

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

从极狐GitLab 16.9 起，依赖扫描和许可证扫描对 Python 3.9 的支持已弃用。在极狐GitLab 17.0 中，Python 3.10 将成为依赖扫描 CI/CD 作业的默认版本。

从极狐GitLab 17.0 起，依赖扫描和许可证扫描功能将不再支持那些需要 Python 3.9 但没有[兼容锁定文件](https://gitlab.cn/docs/user/application_security/dependency_scanning/#obtaining-dependency-information-by-parsing-lockfiles)的项目。

### Deprecate Windows CMD in GitLab Runner

<a id="deprecate-windows-cmd-in-gitlab-runner"></a>

### 弃用极狐GitLab Runner 中的 Windows CMD

- 在极狐GitLab 16.1 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

在极狐GitLab 11.11 中，Windows Batch 执行器（CMD shell）在极狐GitLab Runner 中被弃用，推荐使用 PowerShell。此后，CMD shell 在极狐GitLab Runner 中一直得到支持。然而，这给工程团队和在 Windows 上使用 Runner 的客户带来了额外的复杂性。我们计划在 17.0 中从极狐GitLab Runner 中完全移除对 Windows CMD 的支持。客户应计划在使用 shell 执行器在 Windows 上运行 runner 时使用 PowerShell。客户可以在移除议题中提供反馈或提问。

### Deprecate `CiRunner` GraphQL fields duplicated in `CiRunnerManager`

<a id="deprecate-cirunner-graphql-fields-duplicated-in-cirunnermanager"></a>

### 弃用 `CiRunnerManager` 中重复的 `CiRunner` GraphQL 字段

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

这些字段（`architectureName`、`ipAddress`、`platformName`、`revision`、`version`）现已在 [GraphQL `CiRunner`](https://gitlab.cn/docs/api/graphql/reference/#cirunner) 类型中弃用，因为它们与在一个 runner 配置中分组的 runner 管理器的引入重复。

### Deprecate `fmt` job in Terraform Module CI/CD template

<a id="deprecate-fmt-job-in-terraform-module-cicd-template"></a>

### 弃用 Terraform 模块 CI/CD 模板中的 `fmt` 作业

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

Terraform 模块 CI/CD 模板中的 `fmt` 作业已弃用，并将在极狐GitLab 17.0 中移除。这会影响以下模板：

- `Terraform-Module.gitlab-ci.yml`
- `Terraform/Module-Base.gitlab-ci.yml`

你可以使用以下方式手动将 Terraform `fmt` 作业重新添加到你的流水线中：

```yaml
fmt:
  image: hashicorp/terraform
  script: terraform fmt -chdir "$TF_ROOT" -check -diff -recursive
```

你也可以使用 [OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)中的 `fmt` 模板。

### Deprecate `message` field from Vulnerability Management features

<a id="deprecate-message-field-from-vulnerability-management-features"></a>

### 弃用漏洞管理功能中的 `message` 字段

- 在极狐GitLab 16.1 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

此 MR 弃用了 `VulnerabilityCreate` GraphQL 变更中的 `message` 字段，以及漏洞导出中的 `AdditionalInfo` 列。`message` 字段在极狐GitLab 16.0 中已从安全报告模式中移除，并且不再在其他地方使用。

### Deprecate `terminationGracePeriodSeconds` in the GitLab Runner Kubernetes executor

<a id="deprecate-terminationgraceperiodseconds-in-the-gitlab-runner-kubernetes-executor"></a>

### 弃用极狐GitLab Runner Kubernetes 执行器中的 `terminationGracePeriodSeconds`

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中支持终止
- 在极狐GitLab 17.0 中移除
- 要讨论此变更或了解更多信息，请参阅弃用议题。

极狐GitLab Runner Kubernetes 执行器设置 `terminationGracePeriodSeconds` 已弃用，并将在极狐GitLab 17.0 中移除。要在 Kubernetes 上管理极狐GitLab Runner 工作 Pod 的清理和终止，客户应改为配置 `cleanupGracePeriodSeconds` 和 `podTerminationGracePeriodSeconds`。有关如何使用 `cleanupGracePeriodSeconds` 和 `podTerminationGracePeriodSeconds` 的信息，请参阅[极狐GitLab Runner 执行器文档](https://gitlab.cn/docs/runner/executors/kubernetes/#other-configtoml-settings)。

### Deprecate `version` field in feature flag API

<a id="deprecate-version-field-in-feature-flag-api"></a>

### 弃用功能标志 API 中的 `version` 字段

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

[功能标志 REST API](https://gitlab.cn/docs/api/feature_flags/) 中的 `version` 字段已弃用，并将在极狐GitLab 17.0 中移除。

`version` 字段被移除后，将无法再创建旧版功能标志。

### Deprecate change vulnerability status from the Developer role

<a id="deprecate-change-vulnerability-status-from-the-developer-role"></a>

### 弃用开发者角色更改漏洞状态的权限

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

开发者更改漏洞状态的能力现已弃用。我们计划在即将发布的极狐GitLab 17.0 中做出重大变更，从开发者角色中移除这项能力。希望继续将此权限授予开发者的用户可以为他们的开发者[创建自定义角色](https://gitlab.cn/docs/user/permissions/#custom-roles)，并添加 `admin_vulnerability` 权限以授予他们此访问权限。

### Deprecate custom role creation for group owners on GitLab Self-Managed

<a id="deprecate-custom-role-creation-for-group-owners-on-gitlab-self-managed"></a>

### 弃用极狐GitLab 私有化部署中群组所有者的自定义角色创建功能

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

在极狐GitLab 私有化部署 17.0 中，群组所有者的自定义角色创建功能将被移除。此功能将移至实例级别，仅供管理员使用。群组所有者将能够在群组级别分配自定义角色。

JihuLab.com 上的群组所有者可以继续管理自定义角色并在群组级别分配。

如果在极狐GitLab 私有化部署上使用 API 管理自定义角色，则已添加一个新的实例端点，并且需要该端点才能继续执行 API 操作。

- 列出实例上的所有成员角色 - `GET /api/v4/member_roles`
- 向实例添加成员角色 - `POST /api/v4/member_roles`
- 从实例中移除成员角色 - `DELETE /api/v4/member_roles/:id`

### Deprecate field `hasSolutions` from GraphQL VulnerabilityType

<a id="deprecate-field-hassolutions-from-graphql-vulnerabilitytype"></a>

### 弃用 GraphQL VulnerabilityType 中的 `hasSolutions` 字段

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

GraphQL 字段 `Vulnerability.hasSolutions` 已弃用，并将在极狐GitLab 17.0 中移除。请改用 `Vulnerability.hasRemediations`。

### Deprecate legacy shell escaping and quoting runner shell executor

<a id="deprecate-legacy-shell-escaping-and-quoting-runner-shell-executor"></a>

### 弃用旧版 shell 转义和引用的 runner shell 执行器

- 在极狐GitLab 15.11 中宣布
- 在极狐GitLab 17.0 中移除
- 要讨论此变更或了解更多信息，请参阅弃用议题。

runner 用于处理变量扩展的旧版转义序列机制实现了一种次优的 Ansi-C 引用方式。这种方法意味着 runner 会扩展双引号中包含的参数。从 15.11 开始，我们弃用了 runner shell 执行器中的旧版转义和引用方法。

### Deprecated parameters related to custom text in the sign-in page

<a id="deprecated-parameters-related-to-custom-text-in-the-sign-in-page"></a>

### 弃用登录页面中与自定义文本相关的参数

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

[设置 API](https://gitlab.cn/docs/api/settings/) 中的参数 `sign_in_text` 和 `help_text` 已弃用。要向登录和新用户账户页面添加自定义文本，请使用[外观 API](https://gitlab.cn/docs/api/appearance/) 中的 `description` 字段。

### Deprecating Windows Server 2019 in favor of 2022

<a id="deprecating-windows-server-2019-in-favor-of-2022"></a>

### 弃用 Windows Server 2019，推荐 2022

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

我们最近宣布为在 Windows 上运行的 JihuLab.com runners（测试版）发布 Windows Server 2022。因此，我们在极狐GitLab 17.0 中弃用了 Windows 2019。

有关如何迁移到使用 Windows 2022 的更多信息，请参阅 [Windows 2022 对 GitLab.com runner 的支持现已可用](https://about.gitlab.com/blog/windows-2022-support-for-gitlab-saas-runners/)。（注意：链接保留，但可能需替换为 gitlab.cn 域名？但规则中 about.gitlab.com 替换为 gitlab.cn，所以替换为 https://gitlab.cn/blog/windows-2022-support-for-gitlab-saas-runners/）

### DingTalk OmniAuth provider

<a id="dingtalk-omniauth-provider"></a>

### DingTalk OmniAuth 提供程序

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

为极狐GitLab 提供 DingTalk OmniAuth 提供程序的 `omniauth-dingtalk` gem 将在我们的下一个主要版本极狐GitLab 17.0 中移除。这个 gem 用量非常少，更适合极狐版本使用。

### Duplicate storages in Gitaly configuration

<a id="duplicate-storages-in-gitaly-configuration"></a>

### Gitaly 配置中的重复存储

- 在极狐GitLab 16.10 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

配置多个指向相同存储路径的 Gitaly 存储的支持已弃用，并将在极狐GitLab 17.0 中移除。在极狐GitLab 17.0 及更高版本中，此类配置将导致错误。

我们移除此类配置的支持，因为它可能导致后台仓库维护问题，并且与未来的 Gitaly 存储实现不兼容。

实例管理员必须更新 `gitlab.rb` 配置文件中 `gitaly['configuration']` 部分的 `storage` 条目，以确保每个存储都配置了唯一的路径。

### File type variable expansion fixed in downstream pipelines

<a id="file-type-variable-expansion-fixed-in-downstream-pipelines"></a>

### 下游流水线中文件类型变量的展开修复

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

之前，如果你尝试在另一个 CI/CD 变量中引用[文件类型 CI/CD 变量](https://gitlab.cn/docs/ci/variables/#use-file-type-cicd-variables)，该 CI/CD 变量会展开以包含文件的内容。此行为不正确，因为它不符合典型的 shell 变量展开规则。CI/CD 变量引用应该只展开为文件的路径，而不是文件的内容本身。此问题已在极狐GitLab 15.7 中[针对大多数用例进行了修复](https://jihulab.com/gitlab-cn/gitlab/-/issues/29407)。不幸的是，将 CI/CD 变量传递到下游流水线是一个尚未修复的边缘情况，但现在将在极狐GitLab 17.0 中修复。

通过此变更，在 `.gitlab-ci.yml` 文件中配置的变量可以引用文件变量并传递到下游流水线，文件变量也将被传递到下游流水线。下游流水线会将变量引用展开为文件路径，而不是文件内容。

此重大变更可能会破坏依赖在下游流水线中展开文件变量的用户工作流。

### Geo: Legacy replication details routes for designs and projects deprecated

<a id="geo-legacy-replication-details-routes-for-designs-and-projects-deprecated"></a>

### Geo：弃用设计和项目的旧版复制详情路由

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

作为将旧版数据类型迁移到 [Geo 自助服务框架](https://gitlab.cn/docs/development/geo/framework/)的一部分，以下复制详情路由已弃用：

- 设计 `/admin/geo/replication/designs` 替换为 `/admin/geo/sites/<Geo 节点/站点 ID>/replication/design_management_repositories`
- 项目 `/admin/geo/replication/projects` 替换为 `/admin/geo/sites/<Geo 节点/站点 ID>/replication/projects`

从极狐GitLab 16.4 到 17.0，对旧版路由的查找将自动重定向到新路由。我们将在 17.0 中移除这些重定向。请更新可能使用旧版路由的任何书签或脚本。

### GitLab Helm chart values `gitlab.kas.privateApi.tls.*` are deprecated

<a id="gitlab-helm-chart-values-gitlab-kas-privateapi-tls-are-deprecated"></a>

### 极狐GitLab Helm Chart 值 `gitlab.kas.privateApi.tls.*` 已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

我们引入了 `global.kas.tls.*` Helm 值，以便于 KAS 与您的 Helm Chart 组件之间进行 TLS 通信。旧值 `gitlab.kas.privateApi.tls.enabled` 和 `gitlab.kas.privateApi.tls.secretName` 已弃用，并计划在极狐GitLab 17.0 中移除。

由于新值提供了一种简化、全面的方法来为 KAS 启用 TLS，因此您应该使用 `global.kas.tls.*` 而不是 `gitlab.kas.privateApi.tls.*`。有关更多信息，请参阅：

- 引入 `global.kas.tls.*` 值的[合并请求](https://jihulab.com/gitlab-cn/charts/gitlab/-/merge_requests/2888)。
- [已弃用的 `gitlab.kas.privateApi.tls.*` 文档](https://gitlab.cn/docs/charts/charts/gitlab/kas/#enable-tls-communication-through-the-gitlabkasprivateapi-attributes-deprecated)。
- [新的 `global.kas.tls.*` 文档](https://gitlab.cn/docs/charts/charts/globals/#tls-settings-1)。

### GitLab Runner provenance metadata SLSA v0.2 statement

<a id="gitlab-runner-provenance-metadata-slsa-v0-2-statement"></a>

### 极狐GitLab Runner 来源元数据 SLSA v0.2 声明

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

Runner 生成来源元数据，目前默认生成符合 SLSA v0.2 的声明。由于 SLSA v1.0 已发布且现在受到极狐GitLab 支持，v0.2 声明现已弃用，并计划在极狐GitLab 17.0 中移除。SLSA v1.0 声明计划在极狐GitLab 17.0 中成为新的默认声明格式。

### GraphQL API access through unsupported methods

<a id="graphql-api-access-through-unsupported-methods"></a>

### 通过不受支持的方法访问 GraphQL API

- 在极狐GitLab 17.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

从极狐GitLab 17.0 开始，我们将对 GraphQL 的访问限制为仅通过[已记录在案的受支持令牌类型](https://gitlab.cn/docs/api/graphql/#token-authentication)。

对于已经使用已记录在案且受支持的令牌类型的客户，没有重大变更。

### GraphQL `networkPolicies` resource deprecated

<a id="graphql-networkpolicies-resource-deprecated"></a>

### GraphQL `networkPolicies` 资源已弃用

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

`networkPolicies` [GraphQL 资源](https://gitlab.cn/docs/api/graphql/reference/#projectnetworkpolicies)已弃用，并将在极狐GitLab 17.0 中移除。自极狐GitLab 15.0 起，此字段未返回任何数据。

### GraphQL field `confidential` changed to `internal` on notes

<a id="graphql-field-confidential-changed-to-internal-on-notes"></a>

### 便笺上的 GraphQL 字段 `confidential` 更改为 `internal`

- 在极狐GitLab 15.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

`Note` 的 `confidential` 字段将被弃用并重命名为 `internal`。

### GraphQL field `registrySizeEstimated` has been deprecated

<a id="graphql-field-registrysizeestimated-has-been-deprecated"></a>

### GraphQL 字段 `registrySizeEstimated` 已弃用

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

为清晰起见，GraphQL 字段 `registrySizeEstimated` 已重命名为 `containerRegistrySizeIsEstimated`，以与其对应项匹配。`registrySizeEstimated` 在极狐GitLab 16.2 中已弃用，并将在极狐GitLab 17.0 中移除。请改用极狐GitLab 16.2 中引入的 `containerRegistrySizeIsEstimated`。

### GraphQL field `totalWeight` is deprecated

<a id="graphql-field-totalweight-is-deprecated"></a>

### GraphQL 字段 `totalWeight` 已弃用

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

你可以使用 GraphQL 查询议题看板中议题的总权重。但是，`totalWeight` 字段限制为最大值 2147483647。因此，`totalWeight` 已弃用，并将在极狐GitLab 17.0 中移除。

请改用极狐GitLab 16.2 中引入的 `totalIssueWeight`。

### GraphQL type, `RunnerMembershipFilter` renamed to `CiRunnerMembershipFilter`

<a id="graphql-type-runnermembershipfilter-renamed-to-cirunnermembershipfilter"></a>

### GraphQL 类型 `RunnerMembershipFilter` 重命名为 `CiRunnerMembershipFilter`

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

GraphQL 类型 `RunnerMembershipFilter` 已重命名为 `CiRunnerMembershipFilter`。在极狐GitLab 17.0 中，`RunnerMembershipFilter` 类型的别名将被移除。

### GraphQL: The `DISABLED_WITH_OVERRIDE` value for the `SharedRunnersSetting` enum is deprecated

<a id="graphql-the-disabled-with-override-value-for-the-sharedrunnerssetting-enum-is-deprecated"></a>

### GraphQL：`SharedRunnersSetting` 枚举的 `DISABLED_WITH_OVERRIDE` 值已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

在极狐GitLab 17.0 中，`SharedRunnersSetting` GraphQL 枚举类型的 `DISABLED_WITH_OVERRIDE` 值将被移除。请改用 `DISABLED_AND_OVERRIDABLE`。

### GraphQL: deprecate support for `canDestroy` and `canDelete`

<a id="graphql-deprecate-support-for-candestroy-and-candelete"></a>

### GraphQL：弃用对 `canDestroy` 和 `canDelete` 的支持

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

软件包仓库用户界面依赖于极狐GitLab GraphQL API。为了使每个人都易于贡献，确保前端在所有极狐GitLab 产品领域中的编码方式一致至关重要。然而，在极狐GitLab 16.6 之前，软件包仓库 UI 处理权限的方式与产品的其他领域不同。

在 16.6 中，我们在 `Types::PermissionTypes::Package` 类型下添加了一个新的 `UserPermissions` 字段，以使软件包仓库与极狐GitLab 的其余部分保持一致。这个新字段取代了 `Package`、`PackageBase` 和 `PackageDetailsType` 类型下的 `canDestroy` 字段。它还取代了 `ContainerRepository`、`ContainerRepositoryDetails` 和 `ContainerRepositoryTag` 的字段 `canDelete`。在极狐GitLab 17.0 中，`canDestroy` 和 `canDelete` 字段将被移除。

这是一项重大变更，将在 17.0 中完成。

### HashiCorp Vault integration will no longer use the `CI_JOB_JWT` CI/CD job token by default

<a id="hashicorp-vault-integration-will-no-longer-use-the-ci-job-jwt-cicd-job-token-by-default"></a>

### HashiCorp Vault 集成将默认不再使用 `CI_JOB_JWT` CI/CD 作业令牌

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

作为我们使用 JWT 和 OIDC 提高 CI 工作流安全性的一部分，原生的 HashiCorp 集成也在极狐GitLab 16.0 中进行了更新。任何使用 [`secrets:vault`](https://gitlab.cn/docs/ci/yaml/#secretsvault) 关键字从 Vault 检索密钥的项目都需要[配置为使用 ID 令牌](https://gitlab.cn/docs/ci/secrets/id_token_authentication/#configure-automatic-id-token-authentication)。ID 令牌在 15.7 中引入。

要为此变更做好准备，请使用新的 [`id_tokens`](https://gitlab.cn/docs/ci/yaml/#id_tokens) 关键字并配置 `aud` 声明。确保绑定的受众以 `https://` 为前缀。

在极狐GitLab 15.9 到 15.11 中，你可以[启用 **限制 JSON Web 令牌 (JWT) 访问**](https://gitlab.cn/docs/ci/secrets/id_token_authentication/#enable-automatic-id-token-authentication) 设置，该设置可防止旧令牌暴露给任何作业，并为 `secrets:vault` 关键字启用 [ID 令牌身份验证](https://gitlab.cn/docs/ci/secrets/id_token_authentication/#configure-automatic-id-token-authentication)。

在极狐GitLab 16.0 及更高版本中：

- 此设置将被移除。
- 使用 `id_tokens` 关键字的 CI/CD 作业可以将 ID 令牌与 `secrets:vault` 一起使用，并且不会提供任何 `CI_JOB_JWT*` 令牌。
- 不使用 `id_tokens` 关键字的作业将继续拥有 `CI_JOB_JWT*` 令牌，直到极狐GitLab 17.0。

### Heroku image upgrade in Auto DevOps build

<a id="heroku-image-upgrade-in-auto-devops-build"></a>

### Auto DevOps 构建中的 Heroku 镜像升级

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

在极狐GitLab 17.0 中，`auto-build-image` 项目将从 `heroku/builder:20` 镜像升级到 `heroku/builder:22`。

要测试新镜像的行为，请将 CI/CD 变量 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 设置为 `heroku/builder:22`。

要在极狐GitLab 17.0 之后继续使用 `heroku/builder:20`，请将 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 设置为 `heroku/builder:20`。

### Internal container registry API tag deletion endpoint

<a id="internal-container-registry-api-tag-deletion-endpoint"></a>

### 内部容器镜像仓库 API 标签删除端点

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅弃用议题。

Docker Registry HTTP API V2 规范，后来被 [OCI 分发规范](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)取代，没有包含标签删除操作，因此必须使用一种不安全且缓慢的变通方法（涉及删除清单而非标签）来实现相同目的。

标签删除是一项重要功能，因此我们在极狐GitLab 容器镜像仓库中添加了标签删除操作，扩展了 V2 API，超出了 Docker 和 OCI 分发规范的范围。
<a id="since-then-the-oci-distribution-spec-has-had-some-updates-and-it-now-has-a-tag-delete-operation-using-the-delete-v2namemanifeststag-endpoint"></a>

### 自此以来，OCI 分发规范已有更新，现已支持标签删除操作

自此以来，OCI 分发规范已有更新，现在提供了标签删除操作，使用 [`DELETE /v2/<name>/manifests/<tag>` 端点](https://github.com/opencontainers/distribution-spec/blob/main/spec.md#deleting-tags)。

这导致容器镜像仓库中存在两个功能完全相同的端点。`DELETE /v2/<name>/tags/reference/<tag>` 是极狐GitLab 自定义的标签删除端点，而 `DELETE /v2/<name>/manifests/<tag>` 则是极狐GitLab 16.4 中引入的符合 OCI 规范的标签删除端点。

极狐GitLab 16.4 中已弃用对自定义标签删除端点的支持，并将在极狐GitLab 17.0 中移除。

此端点由**内部**容器镜像仓库应用 API 使用，而非公开的[极狐GitLab 容器镜像仓库 API](https://gitlab.cn/docs/api/container_registry/)。大多数容器镜像仓库用户无需采取任何操作。随着我们过渡到新的符合 OCI 规范的端点，所有与标签删除相关的极狐GitLab UI 和 API 功能都将保持不变。

如果你确实访问内部容器镜像仓库 API 并使用原有的标签删除端点，则必须更新至新端点。

<a id="jwt---jwks-instance-endpoint-is-deprecated"></a>

### JWT `/-/jwks` 实例端点已弃用

- 在极狐GitLab 16.7 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/221031)。

随着极狐GitLab 17.0 中[旧版本 JSON 网络令牌的弃用](https://gitlab.cn/docs/update/deprecations/?removal_milestone=17.0#old-versions-of-json-web-tokens-are-deprecated)，关联的 `/-/jwks` 端点（它是 `/oauth/discovery/keys` 的别名）已不再需要，并将被移除。
如果你在认证配置中指定了 `jwks_url`，请将配置更新为 `oauth/discovery/keys`，并移除端点中所有对 `/-/jwks` 的使用。
如果你已经在认证配置中使用 `oauth_discovery_keys` 且端点为 `/-/jwks` 别名，请从端点中移除 `/-/jwks`。例如，将 `https://gitlab.example.com/-/jwks` 更改为 `https://gitlab.example.com`。

<a id="legacy-geo-prometheus-metrics"></a>

### 旧版 Geo Prometheus 指标

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/430192)。

随着项目迁移至 [Geo 自助服务框架](https://gitlab.cn/docs/development/geo/framework/)，我们已弃用了部分 [Prometheus](https://gitlab.cn/docs/administration/monitoring/prometheus/) 指标。
以下 Geo 相关的 Prometheus 指标已弃用，并将在 17.0 中移除。
下表列出了已弃用的指标及其对应的替代指标。替代指标在极狐GitLab 16.3.0 及更高版本中可用。

| 弃用的指标                             | 替代指标                                      |
| ---------------------------------------- | ---------------------------------------------- |
| `geo_repositories_synced`                | `geo_project_repositories_synced`              |
| `geo_repositories_failed`                | `geo_project_repositories_failed`              |
| `geo_repositories_checksummed`           | `geo_project_repositories_checksummed`         |
| `geo_repositories_checksum_failed`       | `geo_project_repositories_checksum_failed`     |
| `geo_repositories_verified`              | `geo_project_repositories_verified`            |
| `geo_repositories_verification_failed`   | `geo_project_repositories_verification_failed` |
| `geo_repositories_checksum_mismatch`     |  无可用替代                                |
| `geo_repositories_retrying_verification` |  无可用替代                                |

<a id="license-list-is-deprecated"></a>

### 许可证列表已弃用

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/436100)。

目前，你可以在极狐GitLab 的许可证列表中查看项目所使用的所有许可证以及使用这些许可证的组件。从 16.8 版本开始，许可证列表已弃用，并计划作为重大变更在 17.0 中移除。你现在可以在依赖项列表中查看项目或群组所使用的所有许可证，并可按许可证进行筛选。

<a id="license-scanning-support-for-sbt-10x"></a>

### 对 sbt 1.0.X 的许可证扫描支持

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/437591)。

极狐GitLab 17.0 移除了对 sbt 1.0.x 的许可证扫描支持。

建议用户从 sbt 1.0.x 升级。

<a id="linux-packages-for-ubuntu-1804"></a>

### 适用于 Ubuntu 18.04 的 Linux 软件包

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8082)。

Ubuntu 18.04 的标准支持已于 [2023 年 6 月结束](https://wiki.ubuntu.com/Releases)。

从极狐GitLab 17.0 开始，我们将不再为 Ubuntu 18.04 提供 Linux 软件包。

为准备极狐GitLab 17.0 及更高版本，请执行以下操作：

1. 将运行极狐GitLab 实例的服务器从 Ubuntu 18.04 迁移到 Ubuntu 20.04 或 Ubuntu 22.04。
1. 使用适用于当前 Ubuntu 版本的 Linux 软件包升级你的极狐GitLab 实例。

<a id="list-repository-directories-rake-task"></a>

### 列出仓库目录的 Rake 任务

- 在极狐GitLab 16.7 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/384361)。

`gitlab-rake gitlab:list_repos` Rake 任务无法正常工作，并将在极狐GitLab 17.0 中移除。
如果你正在迁移极狐GitLab，请改用
[备份与恢复](https://gitlab.cn/docs/administration/operations/moving_repositories/#recommended-approach-in-all-cases)。

<a id="maintainer-role-providing-the-ability-to-change-package-settings-using-graphql-api"></a>

### 维护者角色能够通过 GraphQL API 更改软件包设置

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/370471)。

在极狐GitLab 15.8 中，具备维护者角色的用户通过 GraphQL API 更改群组**软件包和镜像仓库**设置的功能已弃用，并将在极狐GitLab 17.0 中移除。这些设置包括：

- [允许或禁止上传重复软件包](https://gitlab.cn/docs/user/packages/maven_repository/#do-not-allow-duplicate-maven-packages)。
- [软件包请求转发](https://gitlab.cn/docs/user/packages/maven_repository/#request-forwarding-to-maven-central)。
- [为依赖项代理启用生命周期规则](https://gitlab.cn/docs/user/packages/dependency_proxy/reduce_dependency_proxy_storage/)。

在极狐GitLab 17.0 及更高版本中，你必须具备群组的所有者角色，才能通过极狐GitLab UI 或 GraphQL API 更改群组的**软件包和镜像仓库**设置。

<a id="maven-versions-below-388-support-in-dependency-scanning-and-license-scanning"></a>

### 依赖项扫描和许可证扫描对 Maven 版本低于 3.8.8 的支持

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/438772)。

极狐GitLab 17.0 放弃了对 Maven 版本低于 3.8.8 的依赖项扫描和许可证扫描支持。

建议用户升级到 3.8.8 或更高版本。

<a id="min-concurrency-and-max-concurrency-in-sidekiq-options"></a>

### Sidekiq 选项中的最小并发和最大并发

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/439687)。

对于 Linux 软件包（Omnibus）安装，[`sidekiq['min_concurrency']` 和 `sidekiq['max_concurrency']`](https://gitlab.cn/docs/administration/sidekiq/extra_sidekiq_processes/#manage-thread-counts-explicitly) 设置在极狐GitLab 16.9 中已弃用，并将在极狐GitLab 17.0 中移除。

你可以在极狐GitLab 16.9 及更高版本中使用 `sidekiq['concurrency']` 在每个进程中显式设置线程数。

上述变更仅适用于 Linux 软件包（Omnibus）安装。

对于极狐GitLab Helm Chart 安装，在极狐GitLab 16.10 中，将 `SIDEKIQ_CONCURRENCY_MIN` 和/或 `SIDEKIQ_CONCURRENCY_MAX` 作为 `extraEnv` 传递给 `sidekiq` 子 Chart 的方式已弃用，并将在极狐GitLab 17.0 中移除。

你可以使用 `concurrency` 选项在每个进程中显式设置线程数。

<a id="offset-pagination-for-users-rest-api-endpoint-is-deprecated"></a>

### `/users` REST API 端点的偏移分页已弃用

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/426547)。

极狐GitLab 16.5 中弃用了 `/users` REST API 的偏移分页，并将在极狐GitLab 17.0 中移除。请改用[键集分页](https://gitlab.cn/docs/api/rest/#keyset-based-pagination)。

<a id="old-versions-of-json-web-tokens-are-deprecated"></a>

### 旧版本 JSON 网络令牌已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/366798)。

支持 OIDC 的 [ID 令牌](https://gitlab.cn/docs/ci/secrets/id_token_authentication/) 已在极狐GitLab 15.7 中引入。这些令牌比旧的 JSON 网络令牌（JWT）更具可配置性，符合 OIDC 标准，并且仅在显式配置了 ID 令牌的 CI/CD 作业中可用。
ID 令牌比旧的 `CI_JOB_JWT*` JSON 网络令牌更安全，后者会在每个作业中暴露，因此这些旧的 JSON 网络令牌已被弃用：

- `CI_JOB_JWT`
- `CI_JOB_JWT_V1`
- `CI_JOB_JWT_V2`

为准备此变更，请将你的流水线配置为使用 [ID 令牌](https://gitlab.cn/docs/ci/yaml/#id_tokens) 替代这些已弃用的令牌。为了符合 OIDC 标准，`iss` 声明现在使用完全限定域名，例如 `https://example.com`，此前通过 `CI_JOB_JWT_V2` 令牌引入。

在极狐GitLab 15.9 至 15.11 中，你可以 [启用 **限制 JSON 网络令牌（JWT）访问**](https://gitlab.cn/docs/ci/secrets/id_token_authentication/#enable-automatic-id-token-authentication) 设置，以防止旧令牌暴露给任何作业，并为 `secrets:vault` 关键字启用 [ID 令牌自动认证](https://gitlab.cn/docs/ci/secrets/id_token_authentication/#configure-automatic-id-token-authentication)。

在极狐GitLab 16.0 及更高版本中：

- 此设置将被移除。
- 使用 `id_tokens` 关键字的 CI/CD 作业可以配合 `secrets:vault` 使用 ID 令牌，并且不会拥有任何可用的 `CI_JOB_JWT*` 令牌。
- 未使用 `id_tokens` 关键字的作业将继续拥有可用的 `CI_JOB_JWT*` 令牌，直至极狐GitLab 17.0。

在极狐GitLab 17.0 中，已弃用的令牌将被完全移除，并将在 CI/CD 作业中不再可用。

<a id="omniauth-facebook-is-deprecated"></a>

### OmniAuth Facebook 已弃用

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/416000)。

OmniAuth Facebook 支持将在极狐GitLab 17.0 中被移除。其最后一个 gem 版本于 2021 年发布，目前处于无人维护状态。当前使用率低于 0.1%。如果你使用 OmniAuth Facebook，请在支持移除之前切换到[受支持的提供商](https://gitlab.cn/docs/integration/omniauth/#supported-providers)。

<a id="package-pipelines-in-api-payload-is-paginated"></a>

### API 负载中的软件包流水线已分页

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/289956)。

对 `/api/v4/projects/:id/packages` 的 API 请求会返回分页的软件包结果。每个软件包在此响应中列出其所有关联的流水线。这存在性能问题，因为一个软件包可能关联数百甚至数千条流水线。

在里程碑 17.0 中，我们将从 API 响应中移除 `pipelines` 属性。

<a id="postgresql-13-no-longer-supported"></a>

### 不再支持 PostgreSQL 13

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用史诗](https://jihulab.com/groups/gitlab-org/-/epics/9065)。

极狐GitLab 遵循 [PostgreSQL 年度升级周期](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)。

对 PostgreSQL 13 的支持计划在极狐GitLab 17.0 中移除。
在极狐GitLab 17.0 中，PostgreSQL 14 将成为最低要求的 PostgreSQL 版本。

PostgreSQL 13 将在整个极狐GitLab 16 发布周期中受到支持。
对于希望在极狐GitLab 17.0 之前升级的实例，PostgreSQL 14 也将得到支持。
如果你运行的是通过 Omnibus Linux 软件包安装的单个 PostgreSQL 实例，在 16.11 版本时可能会尝试自动升级。
请确保你有足够的磁盘空间来容纳升级。有关更多信息，请参见 [Omnibus 数据库文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="proxy-based-dast-deprecated"></a>

### 基于代理的 DAST 已弃用

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/430966)。

从极狐GitLab 17.0 开始，将不再支持基于代理的 DAST。请迁移到基于浏览器的 DAST，以继续通过动态分析发现项目的安全结果。基于代理的 DAST 之上构建的孵化功能 **攻防模拟** 也包含在此次弃用中，并将从 17.0 起不再受支持。

<a id="queue-selector-for-running-sidekiq-is-deprecated"></a>

### 用于运行 Sidekiq 的队列选择器已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中结束支持
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390787)。

使用[队列选择器](https://gitlab.cn/docs/administration/sidekiq/processing_specific_job_classes/#queue-selectors)（即多个进程监听一组队列）以及[否定设置](https://gitlab.cn/docs/administration/sidekiq/processing_specific_job_classes/#negate-settings)来运行 Sidekiq 的方式已弃用，并将在 17.0 中完全移除。

你可以从队列选择器迁移至[在所有进程中监听所有队列](https://gitlab.cn/docs/administration/sidekiq/extra_sidekiq_processes/#start-multiple-processes)。例如，如果 Sidekiq 当前以 4 个进程运行（在 `/etc/gitlab/gitlab.rb` 中的 `sidekiq['queue_groups']` 中由 4 个元素表示），并启用了队列选择器（`sidekiq['queue_selector'] = true`），你可以更改 Sidekiq 以让所有 4 个进程监听所有队列，例如 `sidekiq['queue_groups'] = ['*'] * 4`。我们的[参考架构](https://gitlab.cn/docs/administration/reference_architectures/5k_users/#configure-sidekiq)中也推荐了此方法。请注意，Sidekiq 可以有效地运行与机器 CPU 数量相同的进程。

虽然上述方法对大多数实例是推荐做法，Sidekiq 也可以使用[路由规则](https://gitlab.cn/docs/administration/sidekiq/processing_specific_job_classes/#routing-rules)来运行，JihuLab.com 上也使用了这种方式。你可以遵循[从队列选择器迁移到路由规则的指南](https://gitlab.cn/docs/administration/sidekiq/processing_specific_job_classes/#migrating-from-queue-selectors-to-routing-rules)。在进行迁移时，你需要格外小心以避免完全丢失作业。

<a id="removal-of-tags-from-small-gitlabcom-runners-on-linux"></a>

### 移除 Linux 上小型 JihuLab.com Runner 的标签

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/30829)。

由于历史原因，小型 Linux JihuLab.com Runner 上附加了许多标签，因为它们曾被用作标签。我们希望精简标签，仅使用 `saas-linux-small-amd64`，并在所有 JihuLab.com Runner 上保持一致。

我们正在弃用以下标签：`docker`、`east-c`、`gce`、`git-annex`、`linux`、`mongo`、`mysql`、`postgres`、`ruby`、`shared`。

有关更多信息，请参见[移除我们 Linux 上小型 SaaS Runner 的标签](https://gitlab.cn/blog/removing-tags-from-small-saas-runner-on-linux/)。

<a id="required-pipeline-configuration-is-deprecated"></a>

### 强制流水线配置已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/389467)。

强制流水线配置将在极狐GitLab 17.0 中被移除。这会影响旗舰版本下的私有化部署用户。

你应该用以下任一项替代强制流水线配置：

- [范围限定合规框架的安全策略](https://gitlab.cn/docs/user/application_security/policies/scan_execution_policies/#security-policy-scopes)，该功能仍处于实验阶段。
- [合规流水线](https://gitlab.cn/docs/user/group/compliance_pipelines/)，该功能现已可用。

我们推荐这些替代方案，因为它们提供了更大的灵活性，允许将强制流水线分配给特定的合规框架标签。

合规流水线将在未来被弃用并迁移至安全策略。有关更多信息，请参见
[迁移与弃用史诗](https://jihulab.com/groups/gitlab-org/-/epics/11275)。

<a id="sast-analyzer-coverage-changing-in-gitlab-170"></a>

### SAST 分析器覆盖范围在极狐GitLab 17.0 中变更

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/412060)。

我们正在减少极狐GitLab SAST 中默认使用的受支持[分析器](https://gitlab.cn/docs/user/application_security/sast/analyzers/)的数量。这是我们长期战略的一部分，旨在为不同的编程语言提供更快、更一致的用户体验。

在极狐GitLab 17.0 中，我们将：

1. 从 [SAST CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)中移除一组语言特定分析器，并用[基于 Semgrep 的分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep)中的[极狐GitLab 支持的检测规则](https://gitlab.cn/docs/user/application_security/sast/rules/)来覆盖它们。以下分析器现已弃用，并将在极狐GitLab 17.0 中结束支持：
   1. [Brakeman](https://jihulab.com/gitlab-cn/security-products/analyzers/brakeman)（Ruby、Ruby on Rails）
   1. [Flawfinder](https://jihulab.com/gitlab-cn/security-products/analyzers/flawfinder)（C、C++）
   1. [MobSF](https://jihulab.com/gitlab-cn/security-products/analyzers/mobsf)（Android、iOS）
   1. [NodeJS Scan](https://jihulab.com/gitlab-cn/security-products/analyzers/nodejs-scan)（Node.js）
   1. [PHPCS Security Audit](https://jihulab.com/gitlab-cn/security-products/analyzers/phpcs-security-audit)（PHP）
1. 更改 [SAST CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)，停止对 Kotlin 和 Scala 代码运行[基于 SpotBugs 的分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs)。这些语言将改为使用[基于 Semgrep 的分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep)中的[极狐GitLab 支持的检测规则](https://gitlab.cn/docs/user/application_security/sast/rules/)进行扫描。

立即生效，已弃用的分析器将仅接收安全更新；其他常规改进或更新将不予保证。
在这些分析器于极狐GitLab 17.0 中结束支持后，将不再提供任何更新。
但是，我们不会删除之前为这些分析器发布的容器镜像，也不会移除通过自定义 CI/CD 流水线任务定义来运行它们的能力。

漏洞管理系统将更新大部分现有结果，使其与新检测规则匹配。
未迁移到新分析器的结果将被[自动解决](https://gitlab.cn/docs/user/application_security/sast/#automatic-vulnerability-resolution)。
有关更多详细信息，请参见[漏洞转换文档](https://gitlab.cn/docs/user/application_security/sast/analyzers/#vulnerability-translation)。

如果你对已移除的分析器应用了自定义配置，或者你当前在流水线中禁用了基于 Semgrep 的分析器，则必须按照[此变更的弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/412060#action-required)中详述的操作采取行动。

<a id="scan-execution-policies-using-_excluded_analyzers-variable-override-project-variables"></a>

### 使用 `_EXCLUDED_ANALYZERS` 变量的扫描执行策略将覆盖项目变量

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/424513)。

在交付和验证[以最高优先级强制执行 SEP 变量](https://jihulab.com/gitlab-cn/gitlab/-/issues/424028)之后，我们发现了意外行为，允许用户在流水线配置中设置 `_EXCLUDED_PATHS`，并阻止他们在策略和流水线配置中设置 `_EXCLUDED_ANALYZERS`。

为确保正确执行扫描执行变量，当使用极狐GitLab 扫描动作为扫描执行策略指定 `_EXCLUDED_ANALYZERS` 或 `_EXCLUDED_PATHS` 变量时，该变量将覆盖为此排除分析器定义的任何项目变量。

用户可以在 17.0 之前启用功能标志来强制实施此行为。在 17.0 中，如果定义了带有这些变量的扫描执行策略，使用 `_EXCLUDED_ANALYZERS`/`_EXCLUDED_PATHS` 变量的项目将被默认覆盖。

<a id="secure-analyzers-major-version-update"></a>

### Secure 分析器主版本更新

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/438123)。

Secure 阶段将在极狐GitLab 17.0 发布时同步提升其分析器的主版本。

如果你未使用默认的包含模板，或已固定分析器版本，则必须更新你的 CI/CD 任务定义，以移除固定版本或更新至最新的主版本。

极狐GitLab 16.0-16.11 的用户将在极狐GitLab 17.0 发布前正常接收分析器更新，此后所有新修复的错误和发布的功能将仅在新主版本的分析器中发布。

根据我们的维护政策，我们不会向后移植错误和功能到已弃用的版本。如有需要，安全补丁将向后移植到最近的 3 个次要版本中。

具体来说，以下分析器正在被弃用，并在极狐GitLab 17.0 发布后将不再更新：

- 容器扫描：版本 6
- 依赖项扫描：版本 4
- DAST：版本 4
- DAST API：版本 3
- Fuzz API：版本 3
- IaC 扫描：版本 4
- 密钥检测：版本 5
- 静态应用安全测试（SAST）：[所有分析器](https://gitlab.cn/docs/user/application_security/sast/analyzers/)的版本 4
  - `brakeman`
  - `flawfinder`
  - `kubesec`
  - `mobsf`
  - `nodejs-scan`
  - `phpcs-security-audit`
  - `pmd-apex`
  - `semgrep`
  - `sobelow`
  - `spotbugs`

<a id="security-policy-field-match_on_inclusion-is-deprecated"></a>

### 安全策略字段 `match_on_inclusion` 已弃用
- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/424513)。

在[支持扫描结果策略的附加过滤器](https://jihulab.com/gitlab-cn/gitlab/-/epics/6826#note_1341377224)中，我们将 `newly_detected` 字段拆分为两个选项：`new_needs_triage` 和 `new_dismissed`。通过在安全策略 YAML 中包含这两个选项，你将获得与原始 `newly_detected` 字段相同的结果。但是，你现在可以仅使用 `new_needs_triage` 来缩小过滤器范围，以忽略已忽略的发现。
根据[史诗 10203](https://jihulab.com/gitlab-cn/gitlab/-/epics/10203#note_1545826313) 中的讨论，我们已将 `match_on_inclusion` 字段的名称更改为 `match_on_inclusion_license`，以便在 YAML 定义中更清晰。

<a id="security-policy-field-newly_detected-is-deprecated"></a>

### 安全策略字段 `newly_detected` 已弃用

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/422414)。

在[支持扫描结果策略的附加过滤器](https://jihulab.com/gitlab-cn/gitlab/-/epics/6826#note_1341377224)中，我们将 `newly_detected` 字段拆分为两个选项：`new_needs_triage` 和 `new_dismissed`。通过在安全策略 YAML 中包含这两个选项，你将获得与原始 `newly_detected` 字段相同的结果。但是，你现在可以仅使用 `new_needs_triage` 来缩小过滤器范围，以忽略已忽略的发现。

<a id="support-for-self-hosted-sentry-versions-2141-and-earlier"></a>

### 对自托管 Sentry 版本 21.4.1 及更早版本的支持

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/435791)。

对自托管 Sentry 版本 21.4.1 及更早版本的支持已弃用，并将在极狐GitLab 17.0 中移除。

如果你的自托管 Sentry 版本为 21.4.1 或更早版本，则在升级到极狐GitLab 17.0 或更高版本后，你可能无法从极狐GitLab 实例收集错误。
要继续将错误从极狐GitLab 实例发送到 Sentry 实例，请将 Sentry 升级到版本 21.5.0 或更高版本。有关更多信息，
请参阅 [Sentry 文档](https://develop.sentry.dev/self-hosted/releases/)。

> [!note]
> 弃用的支持是针对
> [极狐GitLab 实例错误跟踪功能](https://gitlab.cn/docs/omnibus/settings/configuration/#error-reporting-and-logging-with-sentry)
> 供管理员使用。弃用的支持与
> [极狐GitLab 错误跟踪](https://gitlab.cn/docs/operations/error_tracking/#sentry-error-tracking)无关，后者用于
> 开发者自己部署的应用程序。

<a id="support-for-setting-custom-schema-for-backup-is-deprecated"></a>

### 支持为备份设置自定义 schema 已弃用

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/435210)。

你可以配置极狐GitLab 为备份使用自定义 schema，方法是在 Linux 软件包安装的 `/etc/gitlab/gitlab.rb` 中设置
`gitlab_rails['backup_pg_schema'] = '<schema_name>'`，
或通过编辑 `config/gitlab.yml` 用于自行编译的安装。

虽然该配置设置可用，但它没有效果，也未达到预期目的。
此配置设置将在极狐GitLab 17.0 中移除。

<a id="the-github-importer-rake-task"></a>

### GitHub 导入器 Rake 任务

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/428225)。

在极狐GitLab 16.6 中，GitHub 导入器 Rake 任务已弃用。该 Rake 任务缺少 API 支持的多个功能，且未积极维护。

在极狐GitLab 17.0 中，该 Rake 任务将被移除。

取而代之，GitHub 仓库可以通过使用 [API](https://gitlab.cn/docs/api/import/#import-repository-from-github) 或 [UI](https://gitlab.cn/docs/user/project/import/github/) 导入。

<a id="the-visual-reviews-tool-is-deprecated"></a>

### Visual Reviews 工具已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/387751)。

由于客户使用有限且功能有限，用于 Review Apps 的 Visual Reviews 功能已弃用并将被移除。没有计划替代方案，用户应在极狐GitLab 17.0 之前停止使用 Visual Reviews。

<a id="the-gitlab-runner-exec-command-is-deprecated"></a>

### `gitlab-runner exec` 命令已弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/385235)。

`gitlab-runner exec` 命令已弃用，并将在极狐GitLab Runner 16.0 中完全移除。`gitlab-runner exec` 功能最初开发是为了提供在本地系统上验证极狐GitLab CI 流水线的能力，而无需将更新提交到极狐GitLab 实例。然而，随着极狐GitLab CI 的持续演进，将所有极狐GitLab CI 功能复制到 `gitlab-runner exec` 中已不再可行。流水线语法和验证[模拟](https://gitlab.cn/docs/ci/pipeline_editor/#simulate-a-cicd-pipeline)可在极狐GitLab 流水线编辑器中使用。

<a id="the-pull-based-deployment-features-of-the-gitlab-agent-for-kubernetes-is-deprecated"></a>

### 极狐GitLab agent for Kubernetes 的基于拉取的部署功能已弃用

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/406545)。

我们正在弃用极狐GitLab agent for Kubernetes 内置的基于拉取的部署功能，转而支持 Flux 及相关集成。

极狐GitLab agent for Kubernetes **并未弃用**。此更改仅影响 agent 的基于拉取的功能。所有其他功能将保持不变，极狐GitLab 将继续支持 agent for Kubernetes。

如果你使用 agent 进行基于拉取的部署，应[迁移到 Flux](https://gitlab.cn/docs/user/clusters/agent/gitops/agent/#migrate-to-flux)。由于 Flux 是一个成熟的 CNCF GitOps 项目，我们决定在 2023 年 2 月[将 Flux 与极狐GitLab 集成](https://about.gitlab.com/blog/2023/02/08/why-did-we-choose-to-integrate-fluxcd-with-gitlab/)。

<a id="twitter-omniauth-login-option-is-deprecated-from-gitlab-self-managed"></a>

### Twitter OmniAuth 登录选项从极狐GitLab 私有化部署中弃用

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-com/Product/-/issues/11417)。

Twitter OAuth 1.0a OmniAuth 已弃用，并将在极狐GitLab 私有化部署 17.0 中移除，原因是使用率低且缺乏 gem 支持。请改用[其他受支持的 OmniAuth 提供程序](https://gitlab.cn/docs/integration/omniauth/#supported-providers)。

<a id="unified-approval-rules-are-deprecated"></a>

### 统一审批规则已弃用

- 在极狐GitLab 16.1 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/epics/9662)。

统一审批规则已弃用，取而代之的是更灵活的多审批规则。
你可能无法在没有破坏性更改的情况下将统一审批规则迁移到多审批规则。
为了帮助你手动迁移，我们引入了迁移文档。

如果你在统一审批规则被移除前未手动迁移，极狐GitLab 将自动迁移你的设置。
由于多审批规则允许更细粒度的审批规则设置，如果你将迁移留给极狐GitLab，
自动迁移可能会导致比你可能希望的更严格的规则。
如果你遇到需要比预期更多审批的问题，请检查你的迁移规则。

在极狐GitLab 15.11 中，统一审批规则的 UI 支持已被移除。
你仍然可以通过 API 访问统一审批规则。

<a id="upgrading-the-operating-system-version-of-gitlabcom-runners-on-linux"></a>

### 升级 Linux 上 JihuLab.com runners 的操作系统版本

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-org/ci-cd/shared-runners/infrastructure/-/issues/60)。

极狐GitLab 正在升级用于在 Linux 上为 JihuLab.com runners 执行作业的临时 VM 的容器优化操作系统 (COS)。
该 COS 升级包括 Docker Engine 从版本 19.03.15 升级到版本 23.0.5，这引入了一个已知的兼容性问题。

Docker-in-Docker 版本低于 20.10 或 Kaniko 镜像版本低于 v1.9.0 将无法检测到容器运行时并失败。

有关更多信息，请参阅[升级我们 SaaS runners 在 Linux 上的操作系统版本](https://about.gitlab.com/blog/updating-the-os-version-of-saas-runners-on-linux/)。

<a id="vulnerability-confidence-field"></a>

### 漏洞置信度字段

- 在极狐GitLab 15.4 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/372332)。

在极狐GitLab 15.3 中，[版本 14.x.x 的安全报告 schema 已弃用](https://gitlab.cn/docs/update/deprecations/#security-report-schemas-version-14xx)。
漏洞发现上的 `confidence` 属性仅存在于 `15-0-0` 之前的 schema 版本中，因此实际上已弃用，因为极狐GitLab 15.4 支持 schema 版本 `15-0-0`。为了保持报告与公共 API 之间的一致性，我们 GraphQL API 中任何与漏洞相关的组件上的 `confidence` 属性现已弃用，并将在 17.0 中移除。

<a id="after_script-keyword-will-run-for-canceled-jobs"></a>

### `after_script` 关键字将为已取消的作业运行

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/437789)。

[`after_script`](https://gitlab.cn/docs/ci/yaml/#after_script) CI/CD 关键字用于在作业的主 `script` 部分之后运行额外的命令。这通常用于清理作业使用的环境或其他资源。对于许多用户来说，`after_script` 命令在作业取消时不运行这一事实是出乎意料且不希望的。在 17.0 中，该关键字将更新为也在作业取消后运行命令。请确保你使用 `after_script` 关键字的 CI/CD 配置能够处理为已取消的作业运行的情况。

<a id="dependency_files-is-deprecated"></a>

### `dependency_files` 已弃用

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/396376)。

目前在极狐GitLab 中，项目的依赖项列表是使用依赖项扫描报告中的 `dependency_files` 内容生成的。然而，为了与群组依赖项列表保持一致，从极狐GitLab 17.0 开始，项目的依赖项列表将使用存储在 PostgreSQL 数据库中的 CycloneDX SBOM 报告工件。因此，依赖项扫描报告 schema 的 `dependency_files` 属性已弃用，并将在 17.0 中移除。

作为此弃用的一部分，[`dependency_path`](https://gitlab.cn/docs/user/application_security/dependency_list/#dependency-paths) 也将被弃用并在 17.0 中移除。极狐GitLab 将继续推进[使用 CycloneDX 规范的依赖项图](https://jihulab.com/gitlab-cn/gitlab/-/issues/441118)的实现，以提供类似信息。

此外，容器扫描 CI 作业[将不再生成依赖项扫描报告](https://jihulab.com/gitlab-cn/gitlab/-/issues/439782)来提供操作系统组件列表，因为这已被 CycloneDX SBOM 报告取代。容器扫描的 `CS_DISABLE_DEPENDENCY_LIST` 环境变量不再使用，也将在 17.0 中移除。

<a id="metric-filter-and-value-field-for-dora-api"></a>

### DORA API 的 `metric` 过滤器和 `value` 字段

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/393172)。

现在可以使用新的 metrics 字段同时查询多个 DORA 指标。GraphQL DORA API 的 `metric` 过滤器和 `value` 字段将在极狐GitLab 17.0 中移除。

<a id="omniauth-azure-oauth2-gem-is-deprecated"></a>

### `omniauth-azure-oauth2` gem 已弃用

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/408989)。

极狐GitLab 用户可以使用 `omniauth-azure-oauth2` gem 进行身份验证。在 17.0 中，此 gem 将被替换为 `omniauth_openid_connect` gem。新 gem 包含与旧 gem 相同的所有功能，但还具有上游维护，更有利于安全性和集中维护。

此更改要求用户在迁移时重新连接到 OAuth 2.0 提供程序。为避免中断，请在 17.0 之前的任何时间[将 `omniauth_openid_connect` 添加为新提供程序](https://gitlab.cn/docs/administration/auth/oidc/#configure-multiple-openid-connect-providers)。用户将看到一个新的登录按钮，并且必须手动重新连接其凭据。如果你在 17.0 之前未实现 `omniauth_openid_connect` gem，用户将无法再使用 Azure 登录按钮登录，而必须使用用户名和密码登录，直到管理员实现正确的 gem。

<a id="omnibus_gitconfig-configuration-item-is-deprecated"></a>

### `omnibus_gitconfig` 配置项已弃用

- 在极狐GitLab 16.10 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitaly/-/issues/5132)。

`omnibus_gitconfig['system']` 配置项已弃用。如果你使用
`omnibus_gitconfig['system']` 为 Gitaly 设置自定义 Git 配置，则必须在升级到极狐GitLab 17.0 之前，通过 Gitaly 配置下的 `gitaly[:configuration][:git][:config]` 直接配置 Git。

例如：

```ruby
  gitaly[:configuration][:git][:config] = [
    {
      key: 'fetch.fsckObjects',
      value: 'true',
    },
    # ...
  ]
```

配置键的格式必须与通过 CLI 标志 `git -c <configuration>` 传递给 `git` 的格式匹配。

如果你在将现有键转换为预期格式时遇到困难，请参阅 Linux 软件包生成的 Gitaly 配置文件中正确格式的现有键。默认情况下，配置文件位于
`/var/opt/gitlab/gitaly/config.toml`。

以下由 Gitaly 管理的配置选项应被移除。这些键不需要迁移到
Gitaly：

- `pack.threads=1`
- `receive.advertisePushOptions=true`
- `receive.fsckObjects=true`
- `repack.writeBitmaps=true`
- `transfer.hideRefs=^refs/tmp/`
- `transfer.hideRefs=^refs/keep-around/`
- `transfer.hideRefs=^refs/remotes/`
- `core.alternateRefsCommand="exit 0 #"`
- `core.fsyncObjectFiles=true`
- `fetch.writeCommitGraph=true`

<a id="postgres_exporterper_table_stats-configuration-setting"></a>

### `postgres_exporter['per_table_stats']` 配置设置

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8164)。

Linux 软件包为捆绑的 PostgreSQL 导出器提供了自定义查询，其中包括一个由 `postgres_exporter['per_table_stats']`
配置设置控制的 `per_table_stats` 查询。

PostgreSQL 导出器现在提供了一个 `stat_user_tables` 收集器，可提供相同的指标。如果你启用了 `postgres_exporter['per_table_stats']`，
请改为启用 `postgres_exporter['flags']['collector.stat_user_tables']`。

<a id="projectfingerprint-graphql-field"></a>

### `projectFingerprint` GraphQL 字段

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/343475)。

漏洞发现的 [`project_fingerprint`](https://jihulab.com/gitlab-cn/gitlab/-/epics/2791) 属性正在弃用，取而代之的是 `uuid` 属性。通过使用 UUIDv5 值来标识发现，我们可以轻松地将任何相关实体与发现关联起来。`project_fingerprint` 属性不再用于跟踪发现，并将在极狐GitLab 17.0 中移除。从 16.1 开始，`project_fingerprint` 的输出返回与 `uuid` 字段相同的值。

<a id="repository_download_operation-audit-event-type-for-public-projects"></a>

### 公共项目的 `repository_download_operation` 审计事件类型

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/383218)。

审计事件类型 `repository_download_operation` 当前会为所有项目下载（包括公共项目和私有项目）保存到数据库。对于
公共项目，此审计事件对于审计目的并非最有用，因为它可能由未认证用户触发。

从极狐GitLab 17.0 开始，`repository_download_operation` 审计事件类型将仅针对私有或内部项目触发。我们将为公共项目下载添加一个新的审计事件类型
`public_repository_download_operation`。此新审计事件类型将仅用于流式传输。

<a id="npm-package-uploads-now-occur-asynchronously"></a>

### npm 软件包上传现在异步进行

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/433009)。

极狐GitLab 软件包仓库支持 npm 和 Yarn。当你上传 npm 或 Yarn 软件包时，上传是同步的。然而，同步上传存在已知问题。例如，极狐GitLab 不支持诸如 [overrides](https://jihulab.com/gitlab-cn/gitlab/-/issues/432876) 之类的功能。

从 17.0 开始，npm 和 Yarn 软件包将异步上传。这是一个 breaking change，因为你可能有流水线期望软件包在发布后立即可用。

作为一种变通方法，你应该使用 [packages API](https://gitlab.cn/docs/api/packages/) 来检查软件包。

<a id="gitlab-169"></a>

## 极狐GitLab 16.9

<a id="deprecation-of-lfs_check-feature-flag"></a>

### `lfs_check` 功能标志的弃用

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 16.9 中移除
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/233550)。

在极狐GitLab 16.9 中，我们将移除 `lfs_check` 功能标志。此功能标志于[4 年前引入](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/60588)，用于控制是否启用 LFS 完整性检查。该功能标志默认启用，但一些客户因 LFS 完整性检查出现性能问题而明确禁用了它。

在[大幅提升 LFS 完整性检查的性能](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/61355)后，我们准备移除该功能标志。标志移除后，该功能将自动在任何当前禁用的环境中开启。

如果你的环境中此功能标志被禁用，并且你担心性能问题，请在 16.9 中移除之前启用它并监控性能。如果你在启用后发现任何性能问题，请在[此反馈议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/233550)中告知我们。

<a id="gitlab-168"></a>

## 极狐GitLab 16.8

<a id="opensuse-leap-154-packages"></a>

### openSUSE Leap 15.4 软件包

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 16.8 中移除
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8212)。

openSUSE Leap 15.4 的支持和安全更新[将于 2023 年 11 月结束](https://en.opensuse.org/Lifetime#openSUSE_Leap)。

极狐GitLab 15.4 为 openSUSE Leap 15.5 提供了软件包。极狐GitLab 15.8 及更高版本将不再为 openSUSE Leap 15.4 提供软件包。

要为极狐GitLab 15.8 及更高版本做好准备，你应该：

1. 将实例从 openSUSE Leap 15.4 迁移到 openSUSE Leap 15.5。
1. 从 openSUSE Leap 15.4 极狐GitLab 提供的软件包切换到 openSUSE Leap 15.5 极狐GitLab 提供的软件包。

<a id="gitlab-167"></a>

## 极狐GitLab 16.7

<a id="shimo-integration"></a>

### Shimo 集成

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.7 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/377824)。

**Shimo Workspace 集成**已被弃用，
并将移至极狐GitLab 代码库。

<a id="user_email_lookup_limit-api-field"></a>

### `user_email_lookup_limit` API 字段

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 16.7 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）

`user_email_lookup_limit` [API 字段](https://gitlab.cn/docs/api/settings/) 在极狐GitLab 14.9 中弃用，并在极狐GitLab 16.7 中移除。在功能移除之前，`user_email_lookup_limit` 被别名为 `search_rate_limit`，现有工作流仍可正常工作。

任何更改 `user_email_lookup_limit` 速率限制的 API 调用都必须改用 `search_rate_limit`。

<a id="gitlab-166"></a>

## 极狐GitLab 16.6

<a id="job-token-allowlist-covers-public-and-internal-projects"></a>

### 作业令牌允许列表涵盖公共和内部项目

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.6 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/420678)。

从 16.6 开始，当启用[**限制对此项目的访问**](https://gitlab.cn/docs/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)时，**公共**或**内部**项目将不再授权来自**不在**项目允许列表中的项目的作业令牌请求。

如果你有[公共或内部](https://gitlab.cn/docs/user/public_access/#change-project-visibility)项目并启用了**限制对此项目的访问**设置，则必须将任何发出作业令牌请求的项目添加到你的项目允许列表中，以继续授权。

<a id="gitlab-165"></a>

## 极狐GitLab 16.5

<a id="adding-non-ldap-synced-members-to-a-locked-ldap-group-is-deprecated"></a>

### 将非 LDAP 同步成员添加到锁定的 LDAP 群组已弃用

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.5 中移除
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/213311)。

启用 `ldap_settings_unlock_groups_by_owners` 功能标志允许将非 LDAP 同步用户添加到锁定的 LDAP 群组。此[功能](https://jihulab.com/gitlab-cn/gitlab/-/issues/1793)一直默认禁用并位于功能标志之后。我们移除此功能是为了保持与 SAML 集成的一致性，并且因为允许非同步群组成员违背了使用目录服务的“单一事实来源”原则。一旦此功能被移除，任何未与 LDAP 同步的 LDAP 群组成员将失去对该群组的访问权限。

<a id="geo-housekeeping-rake-tasks"></a>

### Geo：维护 Rake 任务

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.5 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/416384)。
作为将复制和验证迁移到
[Geo 自服务框架 (SSF)](https://gitlab.cn/docs/development/geo/framework/) 的一部分，
项目仓库的旧版复制已被
[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/130565)。
因此，依赖旧版代码的以下 Rake 任务也已被移除。这些 Rake 任务所触发的工作现在会自动定期或基于触发事件执行。

| Rake 任务 | 替代方案 |
| --------- | ----------- |
| `geo:git:housekeeping:full_repack` | [已移至 UI](https://gitlab.cn/docs/administration/housekeeping/#heuristical-housekeeping)。SSF 中无等效的 Rake 任务。 |
| `geo:git:housekeeping:gc` | 始终对新仓库执行，并在需要时执行。SSF 中无等效的 Rake 任务。 |
| `geo:git:housekeeping:incremental_repack` | 在需要时执行。SSF 中无等效的 Rake 任务。 |
| `geo:run_orphaned_project_registry_cleaner` | 由注册表[一致性 worker](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/workers/geo/secondary/registry_consistency_worker.rb) 定期执行，该 worker 会移除孤立的注册表。SSF 中无等效的 Rake 任务。 |
| `geo:verification:repository:reset` | 已移至 UI。SSF 中无等效的 Rake 任务。 |
| `geo:verification:wiki:reset` | 已移至 UI。SSF 中无等效的 Rake 任务。 |

<a id="gitlab-163"></a>

## 极狐GitLab 16.3

<a id="bundled-grafana-deprecated-and-disabled"></a>

### 捆绑的 Grafana 已弃用并禁用

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

与 Omnibus 极狐GitLab 捆绑的 Grafana 版本在 16.0 中
[已弃用并禁用](https://gitlab.cn/docs/administration/monitoring/performance/grafana_configuration/#deprecation-of-bundled-grafana)，
并将在 16.3 中移除。如果您正在使用捆绑的 Grafana，您必须迁移到以下之一：

- 另一个 Grafana 实现。有关更多信息，请参阅
  [切换到新的 Grafana 实例](https://gitlab.cn/docs/administration/monitoring/performance/grafana_configuration/#switch-to-new-grafana-instance)。
- 您选择的其他可观测性平台。

当前提供的 Grafana 版本已不再是受支持的版本。

在极狐GitLab 16.0 到 16.2 版本中，您仍然可以[重新启用捆绑的 Grafana](https://gitlab.cn/docs/administration/monitoring/performance/grafana_configuration/#temporary-workaround)。
但是，从极狐GitLab 16.3 开始，启用捆绑的 Grafana 将不再有效。

<a id="rsa-key-size-limits"></a>

### RSA 密钥大小限制

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

Go 1.20.7 及更高版本添加了一个 `maxRSAKeySize` 常量，将 RSA 密钥限制为最大 8192 位。因此，大于 8192 位的 RSA 密钥将不再适用于极狐GitLab。任何大于 8192 位的 RSA 密钥都必须重新生成为较小的尺寸。

您可能会注意到此问题，因为您的日志中包含类似 `tls: server sent certificate containing RSA key larger than 8192 bits` 的错误。要测试密钥的长度，请使用以下命令：`openssl rsa -in <your-key-file> -text -noout | grep "Key:"`。

<a id="twitter-omniauth-login-option-is-removed-from-gitlabcom"></a>

### Twitter OmniAuth 登录选项从 JihuLab.com 中移除

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

由于使用率低、缺少 gem 支持以及该功能缺乏有效的登录选项，Twitter OAuth 1.0a OmniAuth 正在被弃用，并将在极狐GitLab 16.3 中从 JihuLab.com 移除。如果您使用 Twitter 登录 JihuLab.com，您可以使用密码或其他[受支持的 OmniAuth 提供商](https://gitlab.com/users/sign_in)登录。

<a id="license-compliance-ci-template"></a>

### 许可证合规 CI 模板

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

**更新**：我们之前宣布将在极狐GitLab 16.0 中移除现有的许可证合规 CI/CD 模板。但是，由于[CycloneDX 文件的许可证扫描](https://gitlab.cn/docs/user/compliance/license_scanning_of_cyclonedx_files/)存在性能问题，我们将改为在 16.3 中进行。

极狐GitLab [许可证合规](https://gitlab.cn/docs/user/compliance
对于拥有群组开发者角色的用户，将项目导入到该群组的功能已在极狐GitLab 15.8 中弃用，并将在极狐GitLab 16.0 中移除。从极狐GitLab 16.0 开始，只有拥有群组维护者或所有者角色的用户才能将项目导入到该群组。

### PHP 和 Python 的开发依赖项报告

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/375505)。

在极狐GitLab 16.0 中，极狐GitLab 依赖扫描分析器将开始报告 Python/pipenv 和 PHP/composer 项目的开发依赖项。不希望报告这些开发依赖项的用户应在其 CI/CD 文件中设置 `DS_INCLUDE_DEV_DEPENDENCIES: false`。

### 在 Markdown 中嵌入 Grafana 面板已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/389477)。

在极狐GitLab Flavored Markdown 中添加 Grafana 面板的功能已在 15.9 中弃用，并将在 16.0 中移除。我们计划用 [GitLab Observability UI](https://jihulab.com/gitlab-cn/opstrace/opstrace-ui) 的[嵌入图表](https://jihulab.com/groups/gitlab-cn/opstrace/-/epics/33)功能来替代此功能。

### 强制验证 CI/CD 参数字符长度

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/372770)。

虽然 CI/CD [作业名称](https://gitlab.cn/docs/ci/jobs/#job-name)有严格的 255 字符限制，但其他 CI/CD 参数尚未进行验证以确保它们也保持在限制之内。

在极狐GitLab 16.0 中，将添加验证以严格限制以下内容也为 255 字符：

- `stage` 关键字。
- `ref`，即流水线的 Git 分支或标签名称。
- 外部 CI/CD 集成使用的 `description` 和 `target_url` 参数。

极狐GitLab 私有化部署用户应更新其流水线，以确保不使用超过 255 字符的参数。JihuLab.com 用户无需进行任何更改，因为这些参数在数据库中已经受到限制。

### 环境搜索查询至少需要三个字符

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/382532)。

从极狐GitLab 16.0 开始，当您使用 API 搜索环境时，必须至少使用三个字符。此更改有助于我们确保搜索操作的可扩展性。

### GraphQL ReleaseAssetLink 类型中的 external 字段

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在 [GraphQL API](https://gitlab.cn/docs/api/graphql/) 中，[`ReleaseAssetLink` 类型](https://gitlab.cn/docs/api/graphql/reference/#releaseassetlink)的 `external` 字段用于指示[发布链接](https://gitlab.cn/docs/user/project/releases/release_fields/#links)是极狐GitLab 实例的内部链接还是外部链接。
从极狐GitLab 15.9 开始，我们将所有发布链接视为外部链接，因此，此字段在极狐GitLab 15.9 中弃用，并将在极狐GitLab 16.0 中移除。
为避免工作流中断，请停止使用 `external` 字段，因为它将被移除且不会被替换。

### 发布和发布链接 API 中的 external 字段

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

在[发布 API](https://gitlab.cn/docs/api/releases/) 和[发布链接 API](https://gitlab.cn/docs/api/releases/links/) 中，`external` 字段用于指示[发布链接](https://gitlab.cn/docs/user/project/releases/release_fields/#links)是极狐GitLab 实例的内部链接还是外部链接。
从极狐GitLab 15.9 开始，我们将所有发布链接视为外部链接，因此，此字段在极狐GitLab 15.9 中弃用，并将在极狐GitLab 16.0 中移除。
为避免工作流中断，请停止使用 `external` 字段，因为它将被移除且不会被替换。

### Geo：项目仓库重新下载已弃用

- 在极狐GitLab 15.11 中宣布
- 在极狐GitLab 16.0 中移除
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/388868)。

在辅助 Geo 站点中，用于“重新下载”项目仓库的按钮已弃用。重新下载逻辑存在固有的数据一致性问题，一旦遇到就很难解决。该按钮将在极狐GitLab 16.0 中移除。

### 极狐GitLab 管理员必须具有修改受保护分支或标签的权限

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/12776)。

极狐GitLab 管理员不再能对受保护分支或标签执行操作，除非他们已被明确授予该权限。这些操作包括推送和合并到[受保护分支](https://gitlab.cn/docs/user/project/repository/branches/protected/)、取消保护分支以及创建[受保护标签](https://gitlab.cn/docs/user/project/protected_tags/)。

### 极狐GitLab 自监控项目

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/348909)。

极狐GitLab 自监控为实例管理员提供了监控其实例健康状况的工具。此功能在极狐GitLab 14.9 中弃用，并计划在 16.0 中移除。

### GitLab.com 导入器

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-com/Product/-/issues/4895)。

GitLab.com 导入器已在极狐GitLab 15.8 中弃用，并将在极狐GitLab 16.0 中移除。

GitLab.com 导入器于 2015 年引入，用于通过 UI 将项目从 GitLab.com 导入到极狐GitLab 私有化部署实例。
此功能仅在极狐GitLab 私有化部署上可用。[通过直接迁移迁移极狐GitLab 群组和项目](https://gitlab.cn/docs/user/group/import/#migrate-groups-by-direct-transfer-recommended)取代了 GitLab.com 导入器，并提供了更一致的导入功能。

有关概述，请参阅[已迁移的群组项](https://gitlab.cn/docs/user/group/import/#migrated-group-items)和[已迁移的项目项](https://gitlab.cn/docs/user/group/import/#migrated-project-items)。

### GraphQL API Runner 状态将不再返回 `paused`

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/344648)。

极狐GitLab Runner GraphQL API 端点将在极狐GitLab 16.0 中不再返回 `paused` 或 `active` 作为状态。
在未来的 REST API v5 中，极狐GitLab Runner 的端点也将不再返回 `paused` 或 `active`。

Runner 的状态将仅与 Runner 联系状态相关，例如：
`online`、`offline` 或 `not_connected`。状态 `paused` 或 `active` 将不再出现。

当检查 Runner 是否 `paused` 时，建议 API 用户改为检查布尔属性 `paused` 是否为 `true`。当检查 Runner 是否 `active` 时，检查 `paused` 是否为 `false`。

### Jira Cloud 的 Jira DVCS 连接器

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/groups/gitlab-cn/-/epics/7508)。

用于 Jira Cloud 的 [Jira DVCS 连接器](https://gitlab.cn/docs/integration/jira/dvcs/)已弃用，并将在极狐GitLab 16.0 中移除。如果您正在使用 Jira DVCS 连接器与 Jira Cloud，请迁移到 [Jira Cloud 应用的极狐GitLab](https://gitlab.cn/docs/integration/jira/connect-app/)。

Jira DVCS 连接器对于 Jira 8.13 及更早版本也已弃用。您只能在 Jira 8.14 及更高版本中使用 Jira DVCS 连接器与 Jira Server 或 Jira Data Center。

### 极狐GitLab Helm Chart 中的 KAS 指标端口

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/git
- 仅支持项目和项目 Wiki 仓库，不支持设计、群组 Wiki 或代码片段的仓库。
- 允许导入非哈希存储的项目，即使这些项目不受支持。
- 依赖已设置的 Git 配置 `gitlab.fullpath`。[史诗 8953](https://gitlab.com/groups/gitlab-org/-/epics/8953) 提议取消对此配置的支持。

除了使用 `gitlab:import:repos` Rake 任务之外，还可选择：

- 使用[导出文件](https://gitlab.cn/docs/user/project/settings/import_export/)或[直接转移](https://gitlab.cn/docs/user/group/import/#migrate-groups-by-direct-transfer-recommended)迁移项目，同时迁移仓库。
- 通过 [URL 导入仓库](https://gitlab.cn/docs/user/project/import/repo_by_url/)。
- 从[非 极狐GitLab 源导入仓库](https://gitlab.cn/docs/user/project/import/)。

<a id="redis-5-deprecated"></a>

### Redis 5 已弃用

- 在 极狐GitLab 15.3 中宣布
- 终止支持在 极狐GitLab 15.6
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

自 极狐GitLab 13.9 开始，在 Omnibus GitLab 软件包和 GitLab Helm Chart 4.9 中，Redis 版本[已更新至 Redis 6](https://gitlab.cn/releases/2021/02/22/gitlab-13-9-released/#omnibus-improvements)。
Redis 5 已于 2022 年 4 月达到生命周期终点，并将在 极狐GitLab 15.6 之后不再受支持。
如果您使用自己的 Redis 5.0 实例，应在升级至 极狐GitLab 16.0 或更高版本之前，将其升级到 Redis 6.0 或更高版本。

<a id="remove-job_age-parameter-from-post-jobsrequest-runner-endpoint"></a>

### 移除 `POST /jobs/request` Runner 端点中的 `job_age` 参数

- 在 极狐GitLab 15.2 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

在 `POST /jobs/request` API 端点返回的 `job_age` 参数，用于与 极狐GitLab Runner 通信，但从未被任何 极狐GitLab 或 Runner 功能使用。此参数将在 极狐GitLab 16.0 中被移除。

对于依赖此参数返回的自定义 Runner 开发者来说，这可能是一项重大更改。对于使用官方发布版 极狐GitLab Runner 的任何用户，包括 JihuLab.com 上的公共共享 Runner，则不属于重大更改。

<a id="sast-analyzer-coverage-changing-in-gitlab-160"></a>

### SAST 分析器覆盖范围在 极狐GitLab 16.0 中的变化

- 在 极狐GitLab 15.9 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

极狐GitLab SAST 使用多种[分析器](https://gitlab.cn/docs/user/application_security/sast/analyzers/)扫描代码中的漏洞。

我们正在减少 极狐GitLab SAST 默认支持的分析器数量。这是我们长期战略的一部分，旨在为不同的编程语言提供更快、更一致的用户体验。

从 极狐GitLab 16.0 开始，极狐GitLab SAST CI/CD 模板将不再使用基于 [Security Code Scan] 的分析器用于 .NET，并将进入终止支持状态。我们将从 [SAST CI/CD 模板] 中移除此分析器，并用 [基于 Semgrep 的分析器] 中的 极狐GitLab 支持的 C# 检测规则来替代。

立即生效，此分析器将仅接收安全更新；不保证提供其他常规改进或更新。此分析器在 极狐GitLab 16.0 中达到终止支持后，将不再提供任何更新。但是，我们不会删除先前为此分析器发布的容器镜像，也不会移除通过自定义 CI/CD 流水线作业运行它的能力。

如果您已经忽略了来自已弃用分析器的漏洞发现，替换版本会尝试保留您先前的忽略操作。系统行为取决于：

- 您过去是否排除了基于 Semgrep 的分析器运行。
- 哪个分析器首先发现了项目漏洞报告中显示的漏洞。

请参阅[漏洞转换文档](https://gitlab.cn/docs/user/application_security/sast/analyzers/#vulnerability-translation)，了解详细信息。

如果您对受影响的分析器应用了自定义，或者当前在流水线中禁用了基于 Semgrep 的分析器，则必须按照[此变更的弃用议题]中详细说明采取行动。

**更新**：我们缩小了此更改的范围。在 极狐GitLab 16.0 中，我们将不再进行以下更改：

1. 移除基于 [PHPCS Security Audit] 的分析器支持，并用 [基于 Semgrep 的分析器] 中的 极狐GitLab 管理的检测规则替代。
1. 从 [基于 SpotBugs 的分析器] 的范围中移除 Scala，并用 [基于 Semgrep 的分析器] 中的 极狐GitLab 管理的检测规则替代。

替换基于 PHPCS Security Audit 分析器的工作在[议题 364060] 中进行跟踪，而将 Scala 扫描迁移到基于 Semgrep 的分析器的工作在[议题 362958] 中进行跟踪。

<a id="secure-analyzers-major-version-update"></a>

### 安全分析器主版本更新

- 在 极狐GitLab 15.9 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

安全阶段将随着 极狐GitLab 16.0 版本一起升级其分析器的主版本。此次升级将使分析器之间有一个清晰的划分，区分为：

- 2023 年 5 月 22 日之前发布的版本
- 2023 年 5 月 22 日之后发布的版本

如果您未使用默认内置模板，或已固定分析器版本，则需要更新 CI/CD 作业定义，要么移除固定版本，要么更新到最新的主版本。
极狐GitLab 13.0-15.10 的用户将继续正常接收分析器更新，直到 极狐GitLab 16.0 发布为止，此后所有新修复的错误和发布的功能将仅在新主版本的分析器中提供。根据我们的[维护策略](https://gitlab.cn/docs/policy/maintenance/)，我们不会将错误和功能回溯到已弃用的版本。根据要求，安全补丁将在最新的 3 个次要版本内进行回溯。
具体来说，以下版本将被弃用，并在 极狐GitLab 16.0 发布后不再更新：

- API 模糊测试：版本 2
- 容器扫描：版本 5
- 覆盖率引导的模糊测试：版本 3
- 依赖项扫描：版本 3
- 动态应用程序安全测试 (DAST)：版本 3
- DAST API：版本 2
- IaC 扫描：版本 3
- 许可证扫描：版本 4
- 密钥检测：版本 4
- 静态应用程序安全测试 (SAST)：[所有分析器](https://gitlab.cn/docs/user/application_security/sast/#supported-languages-and-frameworks) 版本 3
  - `brakeman`：版本 3
  - `flawfinder`：版本 3
  - `kubesec`：版本 3
  - `mobsf`：版本 3
  - `nodejs-scan`：版本 3
  - `phpcs-security-audit`：版本 3
  - `pmd-apex`：版本 3
  - `security-code-scan`：版本 3
  - `semgrep`：版本 3
  - `sobelow`：版本 3
  - `spotbugs`：版本 3

<a id="secure-scanning-cicd-templates-will-use-new-job-rules"></a>

### 安全扫描 CI/CD 模板将使用新的作业 `rules`

- 在 极狐GitLab 15.9 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

极狐GitLab 管理的安全扫描 CI/CD 模板将在 极狐GitLab 16.0 版本中进行更新。
这些更新将包括已在最新版 CI/CD 模板中发布的改进。
我们在最新模板版本中发布这些更改，是因为它们有可能中断自定义的 CI/CD 流水线配置。

在所有更新的模板中，我们将更新 `SAST_DISABLED` 和 `DEPENDENCY_SCANNING_DISABLED` 等变量的定义，使其仅在值为 `"true"` 时禁用扫描。此前，即使值为 `"false"`，扫描也会被禁用。

以下模板将被更新：

- API 模糊测试：[`API-Fuzzing.gitlab-ci.yml`]
- 容器扫描：[`Container-Scanning.gitlab-ci.yml`]
- 覆盖率引导的模糊测试：[`Coverage-Fuzzing.gitlab-ci.yml`]
- DAST：[`DAST.gitlab-ci.yml`]
- DAST API：[`DAST-API.gitlab-ci.yml`]
- 依赖项扫描：[`Dependency-Scanning.gitlab-ci.yml`]
- IaC 扫描：[`SAST-IaC.gitlab-ci.yml`]
- SAST：[`SAST.gitlab-ci.yml`]
- 密钥检测：[`Secret-Detection.gitlab-ci.yml`]

如果您使用了上述任一模板，并且使用了 `_DISABLED` 变量但设置的值为 `"true"` 之外的值，我们建议您在 16.0 版本发布前测试您的流水线。

**更新**：我们此前宣布将更新受影响模板的 `rules`，使其默认在[合并请求流水线](https://gitlab.cn/docs/ci/pipelines/merge_request_pipelines/)中运行。
然而，由于[弃用议题中讨论的兼容性问题]，我们将不再在 极狐GitLab 16.0 中进行此项更改。我们将仍按上述说明发布对 `_DISABLED` 变量的更改。

<a id="security-report-schemas-version-14xx"></a>

### 安全报告模式版本 14.x.x

- 在 极狐GitLab 15.3 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

版本 14.x.x 的[安全报告模式]已弃用。

在 极狐GitLab 15.8 及更高版本中，使用模式版本 14.x.x 的[安全报告扫描器集成]将在流水线的 **安全** 选项卡中显示弃用警告。

在 极狐GitLab 16.0 及更高版本中，此功能将被移除。使用模式版本 14.x.x 的安全报告将在流水线的 **安全** 选项卡中导致错误。

有关更多信息，请参阅[安全报告验证](https://gitlab.cn/docs/user/application_security/#security-report-validation)。

<a id="starboard-directive-in-the-configuration-of-the-gitlab-agent-for-kubernetes"></a>

### Kubernetes 的 极狐GitLab Agent 配置中的 Starboard 指令

- 在 极狐GitLab 15.4 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

极狐GitLab 容器扫描功能不再需要安装 Starboard。因此，Kubernetes 的 极狐GitLab Agent 配置文件中 `starboard:` 指令的使用现已弃用，并计划在 极狐GitLab 16.0 中移除。请更新您的配置文件，改用 `container_scanning:` 指令。

<a id="stop-publishing-gitlab-runner-images-based-on-windows-server-2004-and-20h2"></a>

### 停止发布基于 Windows Server 2004 和 20H2 的 极狐GitLab Runner 镜像

- 在 极狐GitLab 16.0 中宣布
- 在 极狐GitLab 16.0 中移除
- 要讨论此更改或了解更多信息，请参阅弃用议题。

从 极狐GitLab 16.0 开始，基于 Windows Server 2004 和 20H2 的 极狐GitLab Runner 镜像将不再提供，因为这些操作系统已达到生命周期终点。

<a id="support-for-praefect-custom-metrics-endpoint-configuration"></a>

### 对 Praefect 自定义指标端点配置的支持

- 在 极狐GitLab 15.9 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

在 极狐GitLab 15.9 中，使用 `prometheus_exclude_database_from_default_metrics` 配置值的支持已弃用，并将在 极狐GitLab 16.0 中移除。我们移除此配置值是因为使用它会导致性能不佳。
此更改意味着以下指标将在 `/metrics` 上不再可用：

- `gitaly_praefect_unavailable_repositories`。
- `gitaly_praefect_verification_queue_depth`。
- `gitaly_praefect_replication_queue_depth`。

这可能需要更新您的指标采集目标，以同时抓取 `/db_metrics`。

<a id="support-for-periods-in-terraform-state-names-might-break-existing-states"></a>

### Terraform 状态名中对句点 (`.`) 的支持可能破坏现有状态

- 在 极狐GitLab 15.7 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

此前，包含句点的 Terraform 状态名不受支持。但是，您仍可以通过一种变通方法使用带句点的状态名。

极狐GitLab 15.7 [完全支持](https://gitlab.cn/docs/user/infrastructure/iac/troubleshooting/#state-not-found-if-the-state-name-contains-a-period)包含句点的状态名。如果您曾使用变通方法来处理这些状态名，您的作业可能会失败，或者看起来像是第一次运行 Terraform。

要解决此问题：

1. 更改对状态文件的任何引用，排除句点及其后面的所有字符。
   - 例如，如果您的状态名是 `state.name`，请将所有引用更改为 `state`。
1. 运行您的 Terraform 命令。

要使用包含句点的完整状态名，请[迁移到完整状态文件](https://gitlab.cn/docs/user/infrastructure/iac/terraform_state/#migrate-to-a-gitlab-managed-terraform-state)。

<a id="the-api-no-longer-returns-revoked-tokens-for-the-agent-for-kubernetes"></a>

### API 不再返回 Kubernetes 的 Agent 已撤销令牌

- 在 极狐GitLab 15.8 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

目前，对[集群 Agent API](https://gitlab.cn/docs/api/cluster_agents/#list-tokens-for-an-agent) 端点的 GET 请求可能返回已撤销的令牌。在 极狐GitLab 16.0 中，GET 请求将不会返回已撤销的令牌。

您应检查对这些端点的调用，确保不使用已撤销的令牌。

此更改影响以下 REST 和 GraphQL API 端点：

- REST API：
  - [列出令牌](https://gitlab.cn/docs/api/cluster_agents/#list-tokens-for-an-agent)
  - [获取单个令牌](https://gitlab.cn/docs/api/cluster_agents/#get-a-single-agent-token)
- GraphQL：
  - [`ClusterAgent.tokens`]

<a id="the-phabricator-task-importer-is-deprecated"></a>

### Phabricator 任务导入器已弃用

- 在 极狐GitLab 15.7 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

Phabricator 任务导入器正被弃用。Phabricator 本身作为一个项目，自 2021 年 6 月 1 日起已不再积极维护。我们没有观察到使用该工具进行的导入。极狐GitLab 上相关的公开议题也没有活动。

<a id="the-latest-terraform-templates-will-overwrite-current-stable-templates"></a>

### 最新的 Terraform 模板将覆盖当前的稳定模板

- 在 极狐GitLab 15.8 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

在每个主要 极狐GitLab 版本中，我们都会用当前的最新模板更新稳定的 Terraform 模板。
此更改影响[快速入门]和[基础]模板。

由于新模板附带了默认规则，此次更新可能破坏您的 Terraform 流水线。
例如，如果您的 Terraform 作业作为下游流水线触发，这些规则将不会在 极狐GitLab 16.0 中触发您的作业。

为适应这些更改，您可能需要调整 `.gitlab-ci.yml` 文件中的 [`rules`](https://gitlab.cn/docs/ci/yaml/#rules) 配置。

<a id="toggle-behavior-of-draft-quick-action-in-merge-requests"></a>

### 合并请求中 `/draft` 快速操作的开/关行为

- 在 极狐GitLab 15.4 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

为了使快速操作切换合并请求草稿状态的行为更清晰，我们正在弃用并移除 `/draft` 快速操作的切换行为。从 极狐GitLab 16.0 版本开始，`/draft` 将仅用于将合并请求设置为草稿，而新的 `/ready` 快速操作将用于移除草稿状态。

<a id="use-of-id-field-in-vulnerabilityfindingdismiss-mutation"></a>

### `vulnerabilityFindingDismiss` 变更中使用 `id` 字段

- 在 极狐GitLab 15.3 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

您可以使用 `vulnerabilityFindingDismiss` GraphQL 变更将漏洞发现的状态设置为 `Dismissed`。此前，此变更使用 `id` 字段唯一标识发现项。然而，这不适用于从流水线安全选项卡中忽略发现项。因此，使用 `id` 字段作为标识符已被弃用，转而使用 `uuid` 字段。使用 `uuid` 字段作为标识符后，您可以从流水线安全选项卡中忽略发现项。

<a id="use-of-third-party-container-registries-is-deprecated"></a>

### 第三方容器镜像仓库的使用已弃用

- 在 极狐GitLab 15.8 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

在 极狐GitLab 15.8 中，将 极狐GitLab 作为认证端点与第三方容器镜像仓库一起使用已弃用，[终止支持](https://gitlab.cn/docs/development/deprecation_guidelines/#terminology)计划在 极狐GitLab 16.0 进行。这会影响 极狐GitLab 私有化部署的用户，这些用户已将其外部镜像仓库连接到 极狐GitLab 用户界面，以查找、查看和删除容器镜像。

同时支持 极狐GitLab 容器镜像仓库和第三方容器镜像仓库对维护、代码质量和向后兼容性都带来挑战，并且阻碍了我们的效率提升。因此，我们未来将不再支持此功能。

此更改不会影响您使用流水线从外部镜像仓库拉取和推送容器镜像的能力。

自从我们在 JihuLab.com 上发布了新的[极狐GitLab 容器镜像仓库]版本以来，我们已开始实现第三方容器镜像仓库所不具备的附加功能。这些新功能使我们能够实现显著的性能改进，例如[清理策略]。我们专注于交付[新功能]，其中大部分功能将需要仅在 极狐GitLab 容器镜像仓库中可用的功能。此次弃用使我们能够通过专注于提供更健壮的集成镜像仓库体验和功能集，从长远上减少碎片化和用户困扰。

未来，我们将继续投资于开发和发布仅在 极狐GitLab 容器镜像仓库中可用的新功能。

<a id="work-items-path-with-global-id-at-the-end-of-the-path-is-deprecated"></a>

### 在路径末尾带有全局 ID 的工作项路径已弃用

- 在 极狐GitLab 15.10 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

在工作项 URL 中使用全局 ID 已弃用。将来，仅支持内部 ID (IID)。

由于 极狐GitLab 支持多种工作项类型，路径如 `https://gitlab.com/gitlab-org/gitlab/-/work_items/<global_id>` 可能显示，例如，一个[任务](https://gitlab.cn/docs/user/tasks/)或一个 [OKR](https://gitlab.cn/docs/user/okrs/)。

在 极狐GitLab 15.10 中，我们通过在该路径末尾添加查询参数 (`iid_path`) 的方式添加了对使用内部 ID (IID) 的支持，格式为：`https://gitlab.com/gitlab-org/gitlab/-/work_items/<iid>?iid_path=true`。

在 极狐GitLab 16.0 中，我们将移除在工作项路径中使用全局 ID 的能力。路径末尾的数字将被视为内部 ID (IID)，无需在末尾添加查询参数。仅支持以下格式：`https://gitlab.com/gitlab-org/gitlab/-/work_items/<iid>`。

<a id="cibuild_-predefined-variables"></a>

### `CI_BUILD_*` 预定义变量

- 在 极狐GitLab 14.8 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

以 `CI_BUILD_*` 开头的预定义 CI/CD 变量在 极狐GitLab 9.0 中已弃用，并将在 极狐GitLab 16.0 中移除。如果您仍在使用这些变量，请务必更改为功能相同的[替代预定义变量](https://gitlab.cn/docs/ci/variables/predefined_variables/)：

| 已移除变量            | 替代变量                |
| --------------------- |------------------------ |
| `CI_BUILD_BEFORE_SHA` | `CI_COMMIT_BEFORE_SHA`  |
| `CI_BUILD_ID`         | `CI_JOB_ID`             |
| `CI_BUILD_MANUAL`     | `CI_JOB_MANUAL`         |
| `CI_BUILD_NAME`       | `CI_JOB_NAME`           |
| `CI_BUILD_REF`        | `CI_COMMIT_SHA`         |
| `CI_BUILD_REF_NAME`   | `CI_COMMIT_REF_NAME`    |
| `CI_BUILD_REF_SLUG`   | `CI_COMMIT_REF_SLUG`    |
| `CI_BUILD_REPO`       | `CI_REPOSITORY_URL`     |
| `CI_BUILD_STAGE`      | `CI_JOB_STAGE`          |
| `CI_BUILD_TAG`        | `CI_COMMIT_TAG`         |
| `CI_BUILD_TOKEN`      | `CI_JOB_TOKEN`          |
| `CI_BUILD_TRIGGERED`  | `CI_PIPELINE_TRIGGERED` |

<a id="post-cilint-api-endpoint-deprecated"></a>

### `POST ci/lint` API 端点已弃用

- 在 极狐GitLab 15.7 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。

`POST ci/lint` API 端点在 15.7 中已弃用，并将在 16.0 中移除。此端点不会验证完整的 CI/CD 配置选项。请改用 [`POST /projects/:id/ci/lint`](https://gitlab.cn/docs/api/lint/#validate-a-ci-yaml-configuration-with-a-namespace)，它能正确验证 CI/CD 配置。

<a id="environment_tier-parameter-for-dora-api"></a>

### DORA API 的 `environment_tier` 参数

- 在 极狐GitLab 15.8 中宣布
- 在 极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此更改或了解更多信息，请参阅弃用议题。
为了避免混淆和重复，`environment_tier` 参数已被弃用，取而代之的是 `environment_tiers` 参数。新的 `environment_tiers` 参数允许 DORA API 同时返回多个层级的聚合数据。`environment_tier` 参数将在极狐GitLab 16.0 中移除。

<a id="name-field-for-pipelinesecurityreportfinding-graphql-type"></a>

### `PipelineSecurityReportFinding` GraphQL 类型的 `name` 字段

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 16.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/346335)。

此前，[`PipelineSecurityReportFinding` GraphQL 类型已更新](https://jihulab.com/gitlab-cn/gitlab/-/issues/335372)，新增了一个 `title` 字段。该字段是当前 `name` 字段的别名，使得语义不够明确的 `name` 字段变得冗余。`name` 字段将在极狐GitLab 16.0 中从 `PipelineSecurityReportFinding` 类型中移除。

<a id="started-iteration-state"></a>

### `started` 迭代状态

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 16.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/334018)。

[迭代 GraphQL API](https://gitlab.cn/docs/api/graphql/reference/#iterationstate) 和[迭代 REST API](https://gitlab.cn/docs/api/iterations/#list-project-iterations) 中的 `started` 迭代状态已被弃用。

GraphQL API 版本将在极狐GitLab 16.0 中移除。此状态正被 `current` 状态（已可用）取代，后者与里程碑等其他基于时间的实体的命名保持一致。

我们计划在 REST API 版本中继续支持 `started` 状态，直至下一个 v5 REST API 版本。

<a id="vulnerabilityfindingdismiss-graphql-mutation"></a>

### `vulnerabilityFindingDismiss` GraphQL 变更

- 在极狐GitLab 15.5 中宣布
- 在极狐GitLab 16.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/375645)。

`VulnerabilityFindingDismiss` GraphQL 变更正被弃用，并将在极狐GitLab 16.0 中移除。由于漏洞发现 ID 对用户不可用（该字段[在 15.3 中已弃用](https://gitlab.cn/docs/update/deprecations/#use-of-id-field-in-vulnerabilityfindingdismiss-mutation)），此变更很少被使用。用户应改用 `VulnerabilityDismiss` 来忽略漏洞报告中的漏洞，或使用 `SecurityFindingDismiss` 处理 CI 流水线安全选项卡中的安全发现。

<a id="gitlab-1511"></a>

## 极狐GitLab 15.11

<a id="opensuse-leap-153-packages"></a>

### openSUSE Leap 15.3 软件包

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 15.11 中移除
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/7371)。

openSUSE Leap 15.3 的发行版支持和安全更新[已于 2022 年 12 月结束](https://en.opensuse.org/Lifetime#Discontinued_distributions)。

从极狐GitLab 15.7 开始，我们已开始提供 openSUSE Leap 15.4 的软件包，并将在 15.11 里程碑中停止提供 openSUSE Leap 15.3 的软件包。

- 请从 openSUSE Leap 15.3 软件包切换到提供的 15.4 软件包。

<a id="gitlab-1510"></a>

## 极狐GitLab 15.10

<a id="automatic-backup-upload-using-openstack-swift-and-rackspace-apis"></a>

### 使用 OpenStack Swift 和 Rackspace API 的自动备份上传

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 15.10 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/387976)。

我们正在弃用对使用 OpenStack Swift 和 Rackspace API **将备份上传到远程存储**的支持。对这些 API 的支持依赖于不再积极维护且尚未针对 Ruby 3 进行更新的第三方库。极狐GitLab 正在 Ruby 2 生命周期结束前切换到 Ruby 3，以便及时获取安全补丁。

- 如果你正在使用 OpenStack，需要将配置更改为使用 S3 API 而非 Swift。
- 如果你正在使用 Rackspace 存储，需要切换到其他提供商，或在备份任务完成后手动上传备份文件。

<a id="gitlab-159"></a>

## 极狐GitLab 15.9

<a id="live-preview-no-longer-available-in-the-web-ide"></a>

### Web IDE 中不再提供 Live Preview

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 15.9 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/383889)。

Web IDE 的 Live Preview 功能旨在提供静态 Web 应用的客户端预览。然而，复杂的配置步骤和有限的支持项目类型限制了其实用性。随着极狐GitLab 15.7 中 Web IDE Beta 的推出，你现在可以连接到完整的服务器端运行时环境。随着 Web IDE 即将支持安装扩展，我们还将支持比 Live Preview 更高级的工作流。从极狐GitLab 15.9 起，Web IDE 中将不再提供 Live Preview。

<a id="omniauth-authentiq-gem-no-longer-available"></a>

### `omniauth-authentiq` gem 不再可用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 15.9 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/389452)。

`omniauth-authentiq` 是极狐GitLab 中包含的一个 OmniAuth 策略 gem。提供身份验证服务的公司 Authentiq 已关闭。因此，该 gem 正被移除。

<a id="gitlab-157"></a>

## 极狐GitLab 15.7

<a id="file-type-variable-expansion-in-gitlab-ciyml"></a>

### `.gitlab-ci.yml` 中的文件类型变量展开

- 在极狐GitLab 15.5 中宣布
- 在极狐GitLab 15.7 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/29407)。

此前，引用或应用别名文件变量的变量会展开 `File` 类型变量的值，例如文件内容。此行为不正确，因为它不符合典型的 shell 变量展开规则。为了泄露存储在 `File` 类型变量中的密钥或敏感信息，用户可以使用 `$echo` 命令并将该变量作为输入参数。

此重大变更加以修复，但可能会中断依赖此行为的用户工作流。通过此次变更，引用或应用别名文件变量的作业变量展开将展开为 `File` 类型变量的文件名或路径，而非其值（如文件内容）。

<a id="flowdock-integration"></a>

### Flowdock 集成

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 15.7 中移除
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/379197)。

自 2022 年 12 月 22 日起，我们将移除 Flowdock 集成，因为该服务已于 2022 年 8 月 15 日关闭。

<a id="gitlab-156"></a>

## 极狐GitLab 15.6

<a id="nfs-for-git-repository-storage"></a>

### 用于 Git 仓库存储的 NFS

- 在极狐GitLab 14.0 中宣布
- 在极狐GitLab 15.6 中移除

随着 Gitaly Cluster 的 GA（[在极狐GitLab 13.0 中引入](https://gitlab.cn/releases/2020/05/22/gitlab-13-0-released/)），我们已在极狐GitLab 14.0 中弃用了对用于 Git 仓库存储的 NFS 的开发（错误修复、性能改进等）。我们将在整个 14.x 版本中继续为用于 Git 仓库的 NFS 提供技术支持，但将于 2022 年 11 月 22 日移除对 NFS 的所有支持。此计划原定于 2022 年 5 月 22 日，但为了让 Gitaly Cluster 继续成熟，我们选择延长了弃用支持日期。请参阅我们的官方[支持声明](https://gitlab.cn/support/statement-of-support/#gitaly-and-nfs)了解更多信息。

Gitaly Cluster 为我们的客户提供了巨大的优势，例如：

- [可变复制因子](https://gitlab.cn/docs/administration/gitaly/#replication-factor)。
- [强一致性](https://gitlab.cn/docs/administration/gitaly/#strong-consistency)。
- [分布式读取能力](https://gitlab.cn/docs/administration/gitaly/#distributed-reads)。

我们鼓励当前使用 NFS 存储 Git 仓库的客户通过查阅我们的[迁移到 Gitaly Cluster 文档](https://gitlab.cn/docs/administration/gitaly/#migrate-to-gitaly-cluster)来规划迁移。

<a id="gitlab-154"></a>

## 极狐GitLab 15.4

<a id="bundled-grafana-deprecated"></a>

### 捆绑的 Grafana 已弃用

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 15.4 中移除
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/6972)。

在极狐GitLab 15.4 中，我们将把捆绑的 Grafana 替换为由极狐GitLab 维护的 Grafana 分支。

Grafana 存在一个[已识别的 CVE](https://nvd.nist.gov/vuln/detail/CVE-2022-31107)，为了缓解此安全漏洞，我们必须切换到我们自己的分支，因为我们捆绑的旧版 Grafana 不再接收长期支持。

预计这不会与之前版本的 Grafana 产生任何不兼容问题，无论是使用我们捆绑的版本还是外部 Grafana 实例。

<a id="sast-analyzer-consolidation-and-cicd-template-changes"></a>

### SAST 分析器整合和 CI/CD 模板变更

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.4 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352554)。

极狐GitLab SAST 使用多种[分析器](https://gitlab.cn/docs/user/application_security/sast/analyzers/)扫描代码中的漏洞。

作为我们提供更佳、更一致用户体验的长期战略的一部分，我们正在减少极狐GitLab SAST 中使用的分析器数量。精简分析器集合还将实现更快的迭代、更好的结果和更高的效率（在大多数情况下包括减少 CI runner 使用量）。

在极狐GitLab 15.4 中，极狐GitLab SAST 将不再使用以下分析器：

- [ESLint](https://jihulab.com/gitlab-cn/security-products/analyzers/eslint)（JavaScript、TypeScript、React）
- [Gosec](https://jihulab.com/gitlab-cn/security-products/analyzers/gosec)（Go）
- [Bandit](https://jihulab.com/gitlab-cn/security-products/analyzers/bandit)（Python）

> [!note]
> 此变更原计划在极狐GitLab 15.0 中进行，后推迟至极狐GitLab 15.4。

这些分析器将从[极狐GitLab 管理的 SAST CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)中移除，并替换为[基于 Semgrep 的分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep)。
即日起，它们将仅接收安全更新；不保证其他常规改进或更新。
这些分析器达到支持终止后，将不再提供任何更新。
我们不会删除之前为这些分析器发布的容器镜像；任何此类变更都将作为弃用、移除或重大变更公告发布。

我们还将从 [SpotBugs](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs) 分析器的范围中移除 Java，并替换为[基于 Semgrep 的分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep)。
此变更将使扫描 Java 代码更简单；不再需要编译。
此变更将反映在[极狐GitLab 管理的 SAST CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)的自动语言检测部分。请注意，基于 SpotBugs 的分析器将继续覆盖 Groovy、Kotlin 和 Scala。

如果你已忽略来自某个已弃用分析器的漏洞发现，替换分析器会尝试遵循你之前的忽略操作。系统行为取决于：

- 你过去是否排除了基于 Semgrep 的分析器运行。
- 哪个分析器首先发现了项目漏洞报告中显示的漏洞。

有关更多详细信息，请参阅[漏洞转换文档](https://gitlab.cn/docs/user/application_security/sast/analyzers/#vulnerability-translation)。

如果你对任何受影响的分析器应用了自定义设置，或者当前在流水线中禁用了 Semgrep 分析器，则必须按照[此变更的弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352554#breaking-change)中的详细说明采取行动。

<a id="gitlab-153"></a>

## 极狐GitLab 15.3

<a id="vulnerability-report-sort-by-state"></a>

### 按状态排序漏洞报告

- 在极狐GitLab 15.0 中宣布
- 在极狐GitLab 15.3 中移除
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/360516)。

在极狐GitLab 14.10 中，由于底层数据模型的重构，按 `State` 列排序漏洞报告的功能被禁用并置于功能标志之后。该功能标志一直默认关闭，因为需要进一步重构以确保按此值排序时保持性能。由于使用 `State` 列进行排序的频率非常低，该功能标志将被移除，以简化代码库并防止任何不必要的性能下降。

<a id="vulnerability-report-sort-by-tool"></a>

### 按工具排序漏洞报告

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 15.3 中移除
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/362962)。

在极狐GitLab 14.10 中，由于底层数据模型的重构，按 `Tool` 列（扫描类型）排序漏洞报告的功能被禁用并置于功能标志之后。该功能标志一直默认关闭，因为需要进一步重构以确保按此值排序时保持性能。由于使用 `Tool` 列进行排序的频率非常低，该功能标志将在极狐GitLab 15.3 中被移除，以简化代码库并防止任何不必要的性能下降。

<a id="gitlab-151"></a>

## 极狐GitLab 15.1

<a id="deprecate-support-for-debian-9"></a>

### 弃用对 Debian 9 的支持

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.1 中移除

[Debian 9 Stretch 的长期服务和支持（LTSS）于 2022 年 7 月结束](https://wiki.debian.org/LTS)。因此，我们将不再支持极狐GitLab 软件包的 Debian 9 发行版。用户可以升级到 Debian 10 或 Debian 11。

<a id="gitlab-150"></a>

## 极狐GitLab 15.0

<a id="audit-events-for-repository-push-events"></a>

### 仓库推送事件的审计事件

- 在极狐GitLab 14.3 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/337993)。

**仓库事件**的审计事件现已弃用，并将在极狐GitLab 15.0 中移除。

这些事件始终默认禁用，必须通过功能标志手动启用。启用它们可能会导致生成过多事件，从而显著降低极狐GitLab 实例的速度。因此，它们正被移除。

<a id="background-upload-for-object-storage"></a>

### 对象存储的后台上传

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/26600)。

为了降低[对象存储功能](https://gitlab.cn/docs/administration/object_storage/)的整体复杂性和维护负担，使用 `background_upload` 上传文件的支持已被弃用，并将在极狐GitLab 15.0 中完全移除。请查看[15.0 特定变更](https://gitlab.cn/docs/omnibus/update/gitlab_15_changes/)中关于[已移除的对象存储后台上传设置](https://gitlab.cn/docs/omnibus/update/gitlab_15_changes/#removed-background-uploads-settings-for-object-storage)的部分。

这会影响一小部分对象存储提供商：

- **OpenStack** 使用 OpenStack 的客户需要将配置更改为使用 S3 API 而非 Swift。
- **RackSpace** 使用基于 RackSpace 的对象存储的客户需要将数据迁移到其他提供商。

极狐GitLab 将发布额外指南，以协助受影响的客户进行迁移。

<a id="cicd-job-name-length-limit"></a>

### CI/CD 作业名称长度限制

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/342800)。

在极狐GitLab 15.0 中，我们将把 CI/CD 作业名称的字符数限制为 255 个。任何作业名称超过 255 个字符限制的流水线将在 15.0 版本发布后停止工作。

<a id="changing-an-instance-shared-runner-to-a-project-specific-runner"></a>

### 将实例（共享）runner 更改为项目（特定）runner

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/345347)。

在极狐GitLab 15.0 中，你将无法再将实例（共享）runner 更改为项目（特定）runner。

用户经常意外地将实例 runner 更改为项目 runner，并且无法将其改回。由于安全影响，极狐GitLab 不允许你将项目 runner 更改为共享 runner。原本用于一个项目的 runner 可能被设置为为整个实例运行作业。

需要为多个项目添加 runner 的管理员可以先为一个项目注册 runner，然后转到管理员视图并选择其他项目。

<a id="container-network-and-host-security"></a>

### 容器网络和主机安全

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）

与极狐GitLab 容器网络安全和容器主机安全类别相关的所有功能在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。需要此功能替代品的用户，建议评估以下可作为潜在解决方案在极狐GitLab 外部安装和管理的开源项目：
[AppArmor](https://gitlab.com/apparmor/apparmor)、
[Cilium](https://github.com/cilium/cilium)、
[Falco](https://github.com/falcosecurity/falco)、
[FluentD](https://github.com/fluent/fluentd)、
[Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)。

要将这些技术集成到极狐GitLab 中，请将所需的 Helm charts 添加到你的[集群管理项目模板](https://gitlab.cn/docs/user/clusters/management_project_template/)副本中。
通过极狐GitLab [CI/CD](https://gitlab.cn/docs/user/clusters/agent/ci_cd_workflow/) 调用命令，在生产环境中部署这些 Helm charts。

作为此变更的一部分，极狐GitLab 中的以下特定功能现已弃用，并计划在极狐GitLab 15.0 中移除：

- **安全与合规** > **威胁监控**页面。
- `Network Policy` 安全策略类型，位于**安全与合规** > **策略**页面。
- 通过极狐GitLab 管理与以下技术集成的能力：AppArmor、Cilium、Falco、FluentD 和 Pod Security Policies。
- 与上述功能相关的所有 API。

如需更多背景信息或提供关于此变更的反馈，请参考我们的公开[弃用议题](https://jihulab.com/groups/gitlab-cn/-/epics/7476)。

<a id="container-scanning-schemas-below-1400"></a>

### 低于 14.0.0 的容器扫描模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

版本低于 14.0.0 的[容器扫描报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)在极狐GitLab 15.0 中将不再受支持。未通过报告中声明的模式版本验证的报告在极狐GitLab 15.0 中也将不再受支持。

受影响的是[通过输出容器扫描安全报告作为流水线作业产物与极狐GitLab 集成的](https://gitlab.cn/docs/development/integrations/secure/#report)第三方工具。你必须确保所有输出报告遵循正确的模式，且最低版本为 14.0.0。版本较低或未能通过声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在 MR、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示[警告](https://jihulab.com/gitlab-cn/gitlab/-/issues/335789#note_672853791)。

<a id="coverage-guided-fuzzing-schemas-below-1400"></a>

### 低于 14.0.0 的覆盖率引导模糊测试模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

版本低于 14.0.0 的[覆盖率引导模糊测试报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)在极狐GitLab 15.0 中将不再受支持。未通过报告中声明的模式版本验证的报告在极狐GitLab 15.0 中也将不再受支持。

受影响的是[通过输出覆盖率引导模糊测试安全报告作为流水线作业产物与极狐GitLab 集成的](https://gitlab.cn/docs/development/integrations/secure/#report)第三方工具。你必须确保所有输出报告遵循正确的模式，且最低版本为 14.0.0。任何版本较低或未能通过声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在 MR、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示[警告](https://jihulab.com/gitlab-cn/gitlab/-/issues/335789#note_672853791)。

<a id="dast-schemas-below-1400"></a>

### 低于 14.0.0 的 DAST 模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

版本低于 14.0.0 的[DAST 报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)在极狐GitLab 15.0 中将不再受支持。未通过报告中声明的模式版本验证的报告从极狐GitLab 15.0 起也将不再受支持。

受影响的是[通过输出 DAST 安全报告作为流水线作业产物与极狐GitLab 集成的](https://gitlab.cn/docs/development/integrations/secure/#report)第三方工具。你必须确保所有输出报告遵循正确的模式，且最低版本为 14.0.0。版本较低或未能通过声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在 MR、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将导致在漏洞报告中[显示警告](https://jihulab.com/gitlab-cn/gitlab/-/issues/335789#note_672853791)。

<a id="dependency-scanning-python-39-and-36-image-deprecation"></a>

### 依赖扫描 Python 3.9 和 3.6 镜像弃用

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请查看[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/334060)。

对于使用依赖扫描的 Python 项目，我们正在弃用默认的 `gemnasium-python:2` 镜像（使用 Python 3.6）以及自定义的 `gemnasium-python:2-python-3.9` 镜像（使用 Python 3.9）。从极狐GitLab 15.0 起，新的默认镜像将针对 Python 3.9，因为它是一个[受支持的版本](https://endoflife.date/python)，而 3.6 [已不再受支持](https://endoflife.date/python)。

对于使用 Python 3.9 或 3.9 兼容项目的用户，你无需采取任何行动，依赖扫描在极狐GitLab 15.0 中应该可以正常工作。如果你希望现在测试新容器，请在你的项目中使用此容器（将在 15.0 中移除）运行测试流水线。使用 Python 3.9 镜像：

```yaml
gemnasium-python-dependency_scanning:
  image:
    name: registry.jihulab.com/gitlab-cn/security-products/analyzers/gemnasium-python:2-python-3.9
```

对于使用 Python 3.6 的用户，从极狐GitLab 15.0 起，你将无法再使用依赖扫描的默认模板。你需要切换到使用已弃用的 `gemnasium-python:2` 分析器镜像。如果你受此影响，请在[此议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/351503)中评论，以便我们在需要时延长移除时间。

对于使用 3.9 特殊例外镜像的用户，你必须改用默认值，不再覆盖你的容器。要验证你是否正在使用 3.9 特殊例外镜像，请检查你的 `.gitlab-ci.yml` 文件中是否有以下引用：

```yaml
gemnasium-python-dependency_scanning:
  image:
    name: registry.jihulab.com/gitlab-cn/security-products/analyzers/gemnasium-python:2-python-3.9
```

<a id="dependency-scanning-default-java-version-changed-to-17"></a>

### 依赖扫描默认 Java 版本更改为 17

- 在极狐GitLab 14.10 中宣布
- 在极狐GitLab 15.0 中移除（[breaking change](https://gitlab.cn/docs/update/terminology/#breaking-change)）
在极狐GitLab 15.0 中，对于依赖项扫描，扫描器所期望的默认 Java 版本将从 11 更新到 17。Java 17 是[最新的长期支持 (LTS) 版本](https://en.wikipedia.org/wiki/Java_version_history)。依赖项扫描将继续支持相同的[版本范围（8、11、13、14、15、16、17）](https://gitlab.cn/docs/user/application_security/dependency_scanning/#supported-languages-and-package-managers)，仅默认版本发生了变化。如果你的项目使用以前的默认 Java 11，请务必[将 `DS_Java_Version` 变量设置为匹配](https://gitlab.cn/docs/user/application_security/dependency_scanning/#configuring-specific-analyzers-used-by-dependency-scanning)。

<a id="dependency-scanning-schemas-below-14.0.0"></a>

### 低于 14.0.0 的依赖项扫描模式

- 于极狐GitLab 14.7 宣布
- 将于极狐GitLab 15.0 移除

[依赖项扫描报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)低于 14.0.0 的版本将在极狐GitLab 15.0 中不再受支持。截至极狐GitLab 15.0，未通过报告中声明的模式版本验证的报告也将不再受支持。

[通过输出依赖项扫描安全报告作为流水线作业产物与极狐GitLab 集成](https://gitlab.cn/docs/development/integrations/secure/#report)的第三方工具会受到影响。你必须确保所有输出报告遵循正确的最低版本为 14.0.0 的模式。版本较低或未通过声明的模式版本验证的报告将不会被处理，漏洞发现也不会在合并请求、流水线或漏洞报告中显示。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示警告。

<a id="deprecate-geo-admin-ui-routes"></a>

### 弃用 Geo 管理界面路由

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除
- 要讨论此变更或了解更多信息，请参见弃用议题。

在极狐GitLab 13.0 中，我们在 Geo 管理界面中引入了新的项目和设计复制详情路由。这些路由是 `/admin/geo/replication/projects` 和 `/admin/geo/replication/designs`。我们保留了旧路由并将它们重定向到新路由。在极狐GitLab 15.0 中，我们将移除对旧路由 `/admin/geo/projects` 和 `/admin/geo/designs` 的支持。请更新可能使用旧路由的任何书签或脚本。

<a id="deprecate-custom-geo-db-rake-tasks"></a>

### 弃用自定义 Geo:db:\* Rake 任务

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除
- 要讨论此变更或了解更多信息，请参见弃用议题。

在极狐GitLab 14.8 中，我们正在用内置任务替换 `geo:db:*` Rake 任务，这在将 Geo 跟踪数据库切换为使用 Rails 6 的多数据库支持后成为可能。以下 `geo:db:*` 任务将替换为对应的 `db:*:geo` 任务：

- `geo:db:drop` -> `db:drop:geo`
- `geo:db:create` -> `db:create:geo`
- `geo:db:setup` -> `db:setup:geo`
- `geo:db:migrate` -> `db:migrate:geo`
- `geo:db:rollback` -> `db:rollback:geo`
- `geo:db:version` -> `db:version:geo`
- `geo:db:reset` -> `db:reset:geo`
- `geo:db:seed` -> `db:seed:geo`
- `geo:schema:load:geo` -> `db:schema:load:geo`
- `geo:db:schema:dump` -> `db:schema:dump:geo`
- `geo:db:migrate:up` -> `db:migrate:up:geo`
- `geo:db:migrate:down` -> `db:migrate:down:geo`
- `geo:db:migrate:redo` -> `db:migrate:redo:geo`
- `geo:db:migrate:status` -> `db:migrate:status:geo`
- `geo:db:test:prepare` -> `db:test:prepare:geo`
- `geo:db:test:load` -> `db:test:load:geo`
- `geo:db:test:purge` -> `db:test:purge:geo`

<a id="deprecate-feature-flag-push_rules_supersede_code_owners"></a>

### 弃用功能标志 PUSH_RULES_SUPERSEDE_CODE_OWNERS

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

功能标志 `PUSH_RULES_SUPERSEDE_CODE_OWNERS` 将在极狐GitLab 15.0 中移除。移除后，推送规则将取代代码所有者。即使需要代码所有者批准，明确允许特定用户推送代码的推送规则也会覆盖代码所有者设置。

<a id="elasticsearch-6.8"></a>

### Elasticsearch 6.8

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

Elasticsearch 6.8 在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。使用 Elasticsearch 6.8 的客户需要在升级到极狐GitLab 15.0 之前将 Elasticsearch 版本升级到 7.x。我们建议使用最新版本的 Elasticsearch 7，以获得所有 Elasticsearch 改进。

Elasticsearch 6.8 还与 Amazon OpenSearch 不兼容，我们计划在极狐GitLab 15.0 中支持 Amazon OpenSearch。

<a id="enforced-validation-of-security-report-schemas"></a>

### 安全报告模式的强制验证

- 于极狐GitLab 14.7 宣布
- 将于极狐GitLab 15.0 移除
- 要讨论此变更或了解更多信息，请参见弃用议题。

[安全报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)低于 14.0.0 的版本将在极狐GitLab 15.0 中不再受支持。截至极狐GitLab 15.0，未通过报告中声明的模式版本验证的报告也将不再受支持。

[通过输出安全报告作为流水线作业产物与极狐GitLab 集成](https://gitlab.cn/docs/development/integrations/secure/#report)的安全工具会受到影响。你必须确保所有输出报告遵循正确的最低版本为 14.0.0 的模式。版本较低或未通过声明的模式版本验证的报告将不会被处理，漏洞发现也不会在合并请求、流水线或漏洞报告中显示。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示警告。

<a id="external-status-check-api-breaking-changes"></a>

### 外部状态检查 API 的重大变更

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

[外部状态检查 API](https://gitlab.cn/docs/api/status_checks/) 最初实现为支持默认通过请求，以将状态检查标记为通过。默认通过请求现已弃用。具体弃用的包括：

- 不包含 `status` 字段的请求。
- `status` 字段设置为 `approved` 的请求。

从极狐GitLab 15.0 开始，仅当 `status` 字段存在且设置为 `passed` 时，状态检查才会更新为通过状态。以下请求：

- 不包含 `status` 字段将被拒绝，并返回 `422` 错误。有关更多信息，请参见相关议题。
- 包含除 `passed` 之外的任何值都将导致状态检查失败。有关更多信息，请参见相关议题。

为了与此变更保持一致，列出外部状态检查的 API 调用也将返回 `passed` 值，而不是 `approved`，用于表示已通过的状态检查。

<a id="gitlab-pages-running-as-daemon"></a>

### 以守护进程方式运行的极狐GitLab Pages

- 于极狐GitLab 14.9 宣布
- 将于极狐GitLab 15.0 移除

在 15.0 中，将移除对极狐GitLab Pages 守护进程模式的支持。

<a id="gitlab-serverless"></a>

### 极狐GitLab Serverless

- 于极狐GitLab 14.3 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

极狐GitLab Serverless 是一组支持基于 Knative 的无服务器开发的功能，具有自动部署和监控能力。

我们决定移除极狐GitLab Serverless 功能，因为它们从未真正引起用户的共鸣。此外，鉴于 Kubernetes 和 Knative 的持续发展，我们当前的实现甚至无法在最新版本上运行。

<a id="godep-support-in-license-compliance"></a>

### 许可证合规中的 Godep 支持

- 于极狐GitLab 14.7 宣布
- 将于极狐GitLab 15.0 移除
- 要讨论此变更或了解更多信息，请参见弃用议题。

Go 的 Godep 依赖管理器已于 2020 年被 Go 弃用，并由 Go modules 取代。为了降低维护成本，我们从 14.7 开始弃用对 Godep 项目的许可证合规支持，并将在极狐GitLab 15.0 中移除。

<a id="graphql-id-and-globalid-compatibility"></a>

### GraphQL ID 和 GlobalID 兼容性

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

我们正在移除一个为向后兼容而添加的非标准 GraphQL 处理器扩展。此扩展修改了 GraphQL 查询的验证，允许在通常会被拒绝的参数中使用 `ID` 类型。某些参数最初具有 `ID` 类型，后来被更改为特定类型的 `ID`。如果你存在以下情况，此变更可能会是重大变更：

- 使用 GraphQL。
- 在查询签名中对任何参数使用 `ID` 类型。

某些字段参数仍具有 `ID` 类型，这些通常用于 IID 值或命名空间路径。例如 `Query.project(fullPath: ID!)`。

有关受影响和不受影响的字段参数列表，请参见弃用议题。

你可以通过使用从极狐GitLab 服务器获取的 schema 数据在本地验证查询来测试此变更是否对你有影响。你可以使用相应极狐GitLab 实例的 GraphQL 探索工具来执行此操作。例如：`https://jihulab.com/-/graphql-explorer`。

例如，以下查询说明了此重大变更：

```graphql
# 使用已弃用的 Query.issue(id:) 类型的查询
# 警告：这在极狐GitLab 15.0 之后将无法工作
query($id: ID!) {
  deprecated: issue(id: $id) {
    title, description
  }
}
```

上述查询在极狐GitLab 15.0 发布后将无法工作，因为 `Query.issue(id:)` 的类型实际上是 `IssueID!`。

相反，你应该使用以下两种形式之一：

```graphql
# 这将继续工作
query($id: IssueID!) {
  a: issue(id: $id) {
    title, description
  }
  b: issue(id: "gid://gitlab/Issue/12345") {
    title, description
  }
}
```

此查询目前可以工作，并且在极狐GitLab 15.0 之后将继续工作。您应该将第一种形式（在签名中使用 `ID` 作为命名类型）的任何查询转换为其他两种形式之一（在签名中使用正确的适当类型，或使用内联参数表达式）。

<a id="graphql-permissions-change-for-package-settings"></a>

### 软件包设置的 GraphQL 权限变更

- 于极狐GitLab 14.9 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab 软件包阶段提供软件包仓库、容器镜像仓库和依赖代理，帮助你使用极狐GitLab 管理所有依赖项。这些产品类别中的每一个都有多种可以使用 API 进行调整的设置。

GraphQL 的权限模型正在更新。15.0 之后，具有访客、报告者和开发者角色的用户将无法再更新这些设置：

- [软件包仓库设置](https://gitlab.cn/docs/api/graphql/reference/#packagesettings)
- [容器镜像仓库清理策略](https://gitlab.cn/docs/api/graphql/reference/#containerexpirationpolicy)
- [依赖代理生存时间策略](https://gitlab.cn/docs/api/graphql/reference/#dependencyproxyimagettlgrouppolicy)
- [为群组启用依赖代理](https://gitlab.cn/docs/api/graphql/reference/#dependencyproxysetting)

<a id="known-host-required-for-gitlab-runner-ssh-executor"></a>

### 极狐GitLab Runner SSH 执行器需要已知主机

- 于极狐GitLab 14.5 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

在极狐GitLab 14.3 中，我们在极狐GitLab Runner `config.toml` 文件中添加了一个配置设置。此设置 [`[runners.ssh.disable_strict_host_key_checking]`](https://gitlab.cn/docs/runner/executors/ssh/#security) 控制是否对 SSH 执行器使用严格主机密钥检查。

在极狐GitLab 15.0 及更高版本中，此配置选项的默认值将从 `true` 更改为 `false`。这意味着在使用极狐GitLab Runner SSH 执行器时将强制进行严格主机密钥检查。

<a id="legacy-approval-status-names-from-license-compliance-api"></a>

### 来自许可证合规 API 的旧审批状态名称

- 于极狐GitLab 14.6 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

我们在 `managed_licenses` API 中弃用了许可证策略审批状态的旧名称（`blacklisted`、`approved`），但它们仍用于我们的 API 查询和响应中。它们将在 15.0 中移除。

如果你正在使用我们的许可证合规 API，应停止使用 `approved` 和 `blacklisted` 查询参数，现在应使用 `allowed` 和 `denied`。在 15.0 中，响应也将停止使用 `approved` 和 `blacklisted`，因此你需要调整所有自定义工具以使用新旧值，确保它们在 15.0 版本中不会中断。

<a id="legacy-database-configuration"></a>

### 旧数据库配置

- 于极狐GitLab 14.3 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

位于 `database.yml` 中的[极狐GitLab 数据库](https://gitlab.cn/docs/omnibus/settings/database/)配置语法正在发生变化，旧格式已弃用。旧格式支持使用单个 PostgreSQL 适配器，而新格式将支持多个数据库。`main:` 数据库需要被定义为第一个配置项。

此弃用主要影响从源代码编译极狐GitLab 的用户，因为 Omnibus 会自动处理此配置。

<a id="logging-in-gitlab"></a>

### 极狐GitLab 中的日志记录

- 于极狐GitLab 14.7 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

极狐GitLab 中的日志记录功能允许用户安装 ELK 技术栈（Elasticsearch、Logstash 和 Kibana）来聚合和管理应用日志。用户可以在极狐GitLab 中搜索相关日志。然而，自从弃用基于证书的 Kubernetes 集集群成和极狐GitLab 托管应用以来，我们不再有推荐的极狐GitLab 内部日志记录解决方案。有关更多信息，你可以关注集成 Opstrace 与极狐GitLab 的议题。

<a id="move-custom_hooks_dir-setting-from-gitlab-shell-to-gitaly"></a>

### 将 `custom_hooks_dir` 设置从极狐GitLab Shell 移至 Gitaly

- 于极狐GitLab 14.9 宣布
- 将于极狐GitLab 15.0 移除

[`custom_hooks_dir`](https://gitlab.cn/docs/administration/server_hooks/#create-a-global-server-hook-for-all-repositories) 设置现在在 Gitaly 中配置，并将在极狐GitLab 15.0 中从极狐GitLab Shell 移除。

<a id="oauth-implicit-grant"></a>

### OAuth 隐式授权

- 于极狐GitLab 14.0 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

OAuth 隐式授权流程将在我们的下一个主要版本极狐GitLab 15.0 中移除。任何使用 OAuth 隐式授权的应用程序应切换到其他[支持的 OAuth 流程](https://gitlab.cn/docs/api/oauth2/)。

<a id="oauth-tokens-without-expiration"></a>

### 无过期的 OAuth 令牌

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

默认情况下，所有新应用程序的访问令牌在 2 小时后过期。在极狐GitLab 14.2 及更早版本中，OAuth 访问令牌没有过期时间。在极狐GitLab 15.0 中，对于任何尚未有过期时间的现有令牌，系统将自动生成一个过期时间。

你应该在极狐GitLab 15.0 发布之前[选择加入](https://gitlab.cn/docs/integration/oauth_provider/#access-token-expiration)令牌过期功能：

1. 编辑应用程序。
1. 选择 **使访问令牌过期** 以启用它们。令牌必须被撤销，否则它们不会过期。

<a id="omniauth-kerberos-gem"></a>

### OmniAuth Kerberos gem

- 于极狐GitLab 14.3 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

`omniauth-kerberos` gem 将在我们的下一个主要版本极狐GitLab 15.0 中移除。

此 gem 一直没有得到维护，并且使用量非常少。因此，我们计划移除对此身份验证方法的支持，并建议改用 Kerberos [SPNEGO](https://en.wikipedia.org/wiki/SPNEGO) 集成。你可以按照[升级说明](https://gitlab.cn/docs/integration/kerberos/#upgrading-from-password-based-to-ticket-based-kerberos-sign-ins)从 `omniauth-kerberos` 集成升级到受支持的集成。

请注意，我们并未弃用 Kerberos SPNEGO 集成，仅弃用旧的基于密码的 Kerberos 集成。

<a id="optional-enforcement-of-pat-expiration"></a>

### PAT 过期的可选强制执行

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

从安全角度来看，禁用 PAT 过期强制执行的功能是不寻常的。我们担心这种不寻常的功能可能会给用户带来意外行为。安全功能中的意外行为本质上是危险的，因此我们决定移除此功能。

<a id="optional-enforcement-of-ssh-expiration"></a>

### SSH 过期的可选强制执行

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

从安全角度来看，禁用 SSH 过期强制执行的功能是不寻常的。我们担心这种不寻常的功能可能会给用户带来意外行为。安全功能中的意外行为本质上是危险的，因此我们决定移除此功能。

<a id="out-of-the-box-sast-support-for-java-8"></a>

### 对 Java 8 的开箱即用 SAST 支持

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

[极狐GitLab SAST SpotBugs 分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs) 扫描 [Java、Scala、Groovy 和 Kotlin 代码](https://gitlab.cn/docs/user/application_security/sast/#supported-languages-and-frameworks) 以查找安全漏洞。出于技术原因，分析器在扫描之前必须先编译代码。除非你使用[预编译策略](https://gitlab.cn/docs/user/application_security/sast/#pre-compilation)，分析器会尝试自动编译你项目的代码。

在 15.0 之前的极狐GitLab 版本中，分析器镜像包含 Java 8 和 Java 11 运行时以便于编译。

在极狐GitLab 15.0 中，我们将：

- 从分析器镜像中移除 Java 8，以减小镜像大小。
- 将 Java 17 添加到分析器镜像中，以便更容易使用 Java 17 进行编译。

如果你依赖分析器环境中存在的 Java 8，则必须按照此变更的弃用议题中的详细说明采取行动。

<a id="outdated-indices-of-advanced-search-migrations"></a>

### 高级搜索迁移的过期索引

- 于极狐GitLab 14.10 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

由于高级搜索迁移通常需要在较长时间内支持多个代码路径，因此在安全可行时清理这些路径非常重要。我们使用极狐GitLab 主要版本升级作为安全时机，移除对尚未完全迁移的索引的向后兼容性。有关详细信息，请参见[升级文档](https://gitlab.cn/docs/update/#upgrading-to-a-new-major-version)。

<a id="pseudonymizer"></a>

### 假名化功能

- 于极狐GitLab 14.7 宣布
- 将于极狐GitLab 15.0 移除
- 要讨论此变更或了解更多信息，请参见弃用议题。

假名化功能通常未被使用，可能在大数据库中导致生产问题，并且可能干扰对象存储开发。此功能现已弃用，并将在极狐GitLab 15.0 中移除。

<a id="querying-usage-trends-via-the-instancestatisticsmeasurements-graphql-node"></a>

### 通过 `instanceStatisticsMeasurements` GraphQL 节点查询使用趋势

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

`instanceStatisticsMeasurements` GraphQL 节点已在 13.10 中重命名为 `usageTrendsMeasurements`，旧字段名称已被标记为弃用。要修复现有的 GraphQL 查询，请将 `instanceStatisticsMeasurements` 替换为 `usageTrendsMeasurements`。

<a id="request-profiling"></a>

### 请求性能分析

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

[请求性能分析](https://gitlab.cn/docs/administration/monitoring/performance/) 在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。

我们正在努力整合我们的性能分析工具，并使其更易于访问。我们评估了此功能的使用情况，发现它并未被广泛使用。它还依赖于一些不再积极维护的第三方 gem，这些 gem 未针对最新版本的 Ruby 进行更新，或者在分析高负载页面时经常崩溃。

有关更多信息，请查看弃用议题的摘要部分。

<a id="required-pipeline-configurations-in-premium-tier"></a>

### 专业版层级的必需流水线配置

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

对于专业版客户，[必需的流水线配置](https://gitlab.cn/docs/administration/settings/continuous_integration/#required-pipeline-configuration-deprecated) 功能在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。此功能对于极狐GitLab 旗舰版客户未弃用。

将此功能移至极狐GitLab 旗舰版层级的这一变更旨在帮助我们使功能更好地符合我们的定价理念，因为我们发现对此功能的需求主要来自高管人员。

此变更还将帮助极狐GitLab 在层级策略上保持一致，与其他相关的旗舰版功能如[安全策略](https://gitlab.cn/docs/user/application_security/policies/)和[合规框架流水线](https://gitlab.cn/docs/user/project/settings/#compliance-pipeline-configuration)保持一致。

<a id="retire-js-dependency-scanning-tool"></a>

### Retire-JS 依赖项扫描工具

- 于极狐GitLab 14.8 宣布
- 将于极狐GitLab 15.0 移除（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

从 14.8 开始，retire.js 作业在依赖项扫描中被弃用。在弃用期间，它将继续包含在我们的 CI/CD 模板中。我们将在 2022 年 5 月 22 日的极狐GitLab 15.0 中从依赖项扫描中移除 retire.js。JavaScript 扫描功能不会受到影响，因为它仍由 Gemnasium 覆盖。
<a id="sast-schemas-below-14-0-0"></a>

### 14.0.0 以下的 SAST 模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[SAST 报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)
低于 14.0.0 的版本将在极狐GitLab 15.0 中不再受支持。未通过报告中声明的模式版本验证的报告在极狐GitLab 15.0 中也将不再受支持。

输出 SAST 安全报告作为流水线作业产物的[与极狐GitLab 集成的第三方工具](https://gitlab.cn/docs/development/integrations/secure/#report)会受到影响。你必须确保所有输出报告都遵循正确的模式，且版本至少为 14.0.0。版本较低或未能通过声明的模式版本验证的报告将不会被处理，漏洞发现也不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示
[警告](https://jihulab.com/gitlab-cn/gitlab/-/issues/335789#note_672853791)。

<a id="sast-support-for-net-2-1"></a>

### 对 .NET 2.1 的 SAST 支持

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352553)。

极狐GitLab SAST Security Code Scan 分析器扫描 .NET 代码以查找安全漏洞。
出于技术原因，分析器必须先构建代码才能进行扫描。

在 15.0 之前的极狐GitLab 版本中，默认的分析器镜像（版本 2）包含对以下内容的支持：

- .NET 2.1
- .NET 3.0 和 .NET Core 3.0
- .NET Core 3.1
- .NET 5.0

在极狐GitLab 15.0 中，我们将此分析器的默认主要版本从版本 2 变更为版本 3。此变更：

- 为漏洞添加了[严重性值](https://jihulab.com/gitlab-cn/gitlab/-/issues/350408)以及[其他新功能和改进](https://jihulab.com/gitlab-cn/security-products/analyzers/security-code-scan/-/blob/master/CHANGELOG.md)。
- 移除了 .NET 2.1 支持。
- 添加了对 .NET 6.0、Visual Studio 2019 和 Visual Studio 2022 的支持。

版本 3 在[极狐GitLab 14.6 中宣布](https://gitlab.cn/releases/2021/12/22/gitlab-14-6-released/#sast-support-for-net-6)，并作为可选的升级提供。

如果你依赖于分析器镜像中默认存在的 .NET 2.1 支持，则必须按照[此变更的弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352553#breaking-change)中详细说明的方式采取行动。

<a id="secret-detection-configuration-variables-deprecated"></a>

### 已弃用的密钥检测配置变量

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352565)。

为了使[自定义极狐GitLab 密钥检测](https://gitlab.cn/docs/user/application_security/secret_detection/#customizing-settings)更简单、更可靠，我们弃用了一些以前你可以在 CI/CD 配置中设置的变量。

以下变量当前允许你自定义历史扫描的选项，但与[极狐GitLab 管理的 CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/Secret-Detection.gitlab-ci.yml)交互不佳，现已弃用：

- `SECRET_DETECTION_COMMIT_FROM`
- `SECRET_DETECTION_COMMIT_TO`
- `SECRET_DETECTION_COMMITS`
- `SECRET_DETECTION_COMMITS_FILE`

`SECRET_DETECTION_ENTROPY_LEVEL` 先前允许你配置只考虑代码库中字符串熵值的规则，现已弃用。
这种仅基于熵值的规则类型产生了不可接受数量的错误结果（误报），不再受支持。

在极狐GitLab 15.0 中，我们将更新密钥检测[分析器](https://gitlab.cn/docs/user/application_security/terminology/#analyzer)以忽略这些已弃用的选项。
你仍然可以通过设置 [`SECRET_DETECTION_HISTORIC_SCAN` CI/CD 变量](https://gitlab.cn/docs/user/application_security/secret_detection/#available-cicd-variables)来配置对提交历史的历史扫描。

有关更多详细信息，请参见[此变更的弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352565)。

<a id="secret-detection-schemas-below-14-0-0"></a>

### 14.0.0 以下的密钥检测模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[密钥检测报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/releases)
低于 14.0.0 的版本将在极狐GitLab 15.0 中不再受支持。未通过报告中声明的模式版本验证的报告在极狐GitLab 15.0 中也将不再受支持。

输出密钥检测安全报告作为流水线作业产物的[与极狐GitLab 集成的第三方工具](https://gitlab.cn/docs/development/integrations/secure/#report)会受到影响。你必须确保所有输出报告都遵循正确的模式，且版本至少为 14.0.0。版本较低或未能通过声明的模式版本验证的报告将不会被处理，漏洞发现也不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示
[警告](https://jihulab.com/gitlab-cn/gitlab/-/issues/335789#note_672853791)。

<a id="secure-and-protect-analyzer-images-published-in-new-location"></a>

### 在新位置发布的 Secure 和 Protect 分析器镜像

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352564)。

极狐GitLab 使用各种[分析器](https://gitlab.cn/docs/user/application_security/terminology/#analyzer)来[扫描安全漏洞](https://gitlab.cn/docs/user/application_security/)。
每个分析器都作为一个容器镜像分发。

从极狐GitLab 14.8 开始，新版本的极狐GitLab Secure 和 Protect 分析器将发布到 `registry.gitlab.com/security-products` 下的新镜像仓库位置。

我们将更新[极狐GitLab 管理的 CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/lib/gitlab/ci/templates/Security)的默认值以反映此变更：

- 对于除容器扫描之外的所有分析器，我们将把变量 `SECURE_ANALYZERS_PREFIX` 更新为新的镜像仓库位置。
- 对于容器扫描，默认镜像地址已更新。容器扫描没有 `SECURE_ANALYZERS_PREFIX` 变量。

在未来的版本中，我们将停止向 `registry.gitlab.com/gitlab-org/security-products/analyzers` 发布镜像。
一旦发生这种情况，如果你手动拉取镜像并将其推送到单独的镜像仓库，则必须采取行动。这通常是[离线部署](https://gitlab.cn/docs/user/application_security/offline_deployments/)的情况。
否则，你将不会收到进一步的更新。

更多详细信息请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/352564)。

<a id="secure-and-protect-analyzer-major-version-update"></a>

### Secure 和 Protect 分析器主要版本更新

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/350936)。

Secure 和 Protect 阶段将在极狐GitLab 15.0 发布时同步提升其分析器的主要版本。此次主要版本提升将为分析器提供明确的区分，区分：

- 在 2022 年 5 月 22 日之前发布的版本，其生成的报告不受严格的模式验证约束。
- 在 2022 年 5 月 22 日之后发布的版本，其生成的报告将受到严格的模式验证约束。

如果你没有使用默认的包含模板，或者已固定了分析器版本，则需要更新 CI/CD 作业定义，要么移除固定的版本，要么更新到最新的主要版本。
在极狐GitLab 15.0 发布之前，极狐GitLab 12.0-14.10 的用户将继续正常接收分析器更新。在此之后，所有在新主要版本中修复的错误和新发布的功能都不会在已弃用版本中提供，因为按照我们的[维护政策](https://gitlab.cn/docs/policy/maintenance/)，我们不会向后移植错误和新功能。所需的安全补丁将在最新的 3 个次要版本中进行向后移植。
具体来说，以下内容正在被弃用，并且在极狐GitLab 15.0 发布后将不再更新：

- API 安全：版本 1
- 容器扫描：版本 4
- 覆盖率引导的模糊测试：版本 2
- 依赖项扫描：版本 2
- 动态应用安全测试 (DAST)：版本 2
- 基础设施即代码 (IaC) 扫描：版本 1
- 许可证扫描：版本 3
- 密钥检测：版本 3
- 静态应用安全测试 (SAST)：[所有分析器](https://gitlab.cn/docs/user/application_security/sast/#supported-languages-and-frameworks)的版本 2，但目前为版本 3 的 `gosec` 除外
  - `bandit`：版本 2
  - `brakeman`：版本 2
  - `eslint`：版本 2
  - `flawfinder`：版本 2
  - `gosec`：版本 3
  - `kubesec`：版本 2
  - `mobsf`：版本 2
  - `nodejs-scan`：版本 2
  - `phpcs-security-audit`：版本 2
  - `pmd-apex`：版本 2
  - `security-code-scan`：版本 2
  - `semgrep`：版本 2
  - `sobelow`：版本 2
  - `spotbugs`：版本 2

<a id="sidekiq-metrics-and-health-checks-configuration"></a>

### Sidekiq 指标和健康检查配置

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/347509)。

使用单个进程和端口导出 Sidekiq 指标和健康检查的方式已被弃用。
支持将在 15.0 中移除。

我们已经更新了 Sidekiq，使其[从两个独立的进程导出指标和健康检查](https://jihulab.com/groups/gitlab-cn/-/epics/6409)
以提高稳定性和可用性，并防止边缘情况下的数据丢失。
由于这是两个独立的服务器，因此在 15.0 中需要进行配置更改，以显式设置指标和健康检查的独立端口。
新引入的 `sidekiq['health_checks_*']` 设置应始终在 `gitlab.rb` 中设置。
有关更多信息，请查看[配置 Sidekiq](https://gitlab.cn/docs/administration/sidekiq/) 的文档。

这些更改还需要在 Prometheus 中更新以抓取新端点，或在 k8s 健康检查中更新以指向新的健康检查端口，才能正常工作，否则指标或健康检查将消失。

在弃用期间，这些设置是可选的，
极狐GitLab 将 Sidekiq 健康检查端口默认设置为与 `sidekiq_exporter` 相同的端口，
并且只运行一个服务器（不改变当前行为）。
只有当两者都设置并提供了不同的端口时，才会启动一个单独的指标服务器来提供 Sidekiq 指标，类似于 Sidekiq 在 15.0 中的行为方式。

<a id="static-site-editor"></a>

### 静态站点编辑器

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/347137)。

从极狐GitLab 15.0 开始，静态站点编辑器将不再可用。整个极狐GitLab 中 Markdown 编辑体验的改进将提供类似的优势，但覆盖范围更广。对静态站点编辑器的传入请求将被重定向到 [Web IDE](https://gitlab.cn/docs/user/project/web_ide/)。

静态站点编辑器的当前用户可以查看[文档](https://gitlab.cn/docs/user/project/web_ide/)以获取更多信息，包括如何从现有项目中移除配置文件。

<a id="support-for-sles-12-sp2"></a>

### 对 SLES 12 SP2 的支持

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))

SUSE Linux Enterprise Server (SLES) 12 SP2 的长期服务和支持 (LTSS) 已于 [2021 年 3 月 31 日结束](https://www.suse.com/lifecycle/)。SP2 上的 CA 证书包含已过期的 DST 根证书，并且不会获得新的 CA 证书包更新。我们已经实施了一些[变通方法](https://jihulab.com/gitlab-cn/gitlab-omnibus-builder/-/merge_requests/191)，但我们无法继续使构建正常运行。

<a id="support-for-grpc-aware-proxy-deployed-between-gitaly-and-rest-of-gitlab"></a>

### 对部署在 Gitaly 与极狐GitLab 其余部分之间的 gRPC 感知代理的支持

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))

尽管不推荐也没有记录，但过去可以在 Gitaly
与极狐GitLab 的其余部分之间部署 gRPC 感知代理。例如，NGINX 和 Envoy。部署 gRPC 感知代理的能力已被
[弃用](https://jihulab.com/gitlab-cn/gitlab/-/issues/352517)。如果你目前为 Gitaly 连接使用了 gRPC 感知代理，则应将代理配置更改为使用 TCP 或 TLS 代理（OSI 第 4 层）代替。

Gitaly Cluster 在极狐GitLab 13.12 中已与 gRPC 感知代理不兼容。现在，所有极狐GitLab 实例都将与
gRPC 感知代理不兼容，即使没有 Gitaly Cluster 也是如此。

通过通过自定义协议（而非 gRPC）发送部分内部 RPC 流量，我们
提高了吞吐量并减少了 Go 垃圾回收延迟。有关更多信息，请参见
[相关史诗](https://jihulab.com/groups/gitlab-com/gl-infra/-/epics/463)。

<a id="test-coverage-project-cicd-setting"></a>

### 测试覆盖率项目 CI/CD 设置

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))

为了简化设置测试覆盖率模式，在极狐GitLab 15.0 中，
[用于测试覆盖率解析的项目设置](https://gitlab.cn/docs/ci/pipelines/settings/#add-test-coverage-results-using-project-settings-removed)
将被移除。

相反，应使用项目的 `.gitlab-ci.yml`，通过 `coverage` 关键词提供一个正则表达式，以在合并请求中设置测试覆盖率结果。

<a id="tracing-in-gitlab"></a>

### 极狐GitLab 中的追踪

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/346540)。

极狐GitLab 中的追踪是与 Jaeger 的集成，Jaeger 是一个开源的端到端分布式追踪系统。极狐GitLab 用户可以转到其 Jaeger 实例，以深入了解已部署应用程序的性能，跟踪处理给定请求的每个函数或微服务。极狐GitLab 中的追踪在极狐GitLab 14.7 中被弃用，并计划在 15.0 中移除。要跟踪可能的替代方案的工作进展，请参见 [Opstrace 与极狐GitLab 集成](https://jihulab.com/groups/gitlab-cn/-/epics/6976) 的议题。

<a id="update-to-the-container-registry-group-level-api"></a>

### 容器镜像仓库组级别 API 的更新

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/336912)。

在 15.0 版本中，对 `tags` 和 `tags_count` 参数的支持将从[从组获取镜像仓库](https://gitlab.cn/docs/api/container_registry/#within-a-group)的容器镜像仓库 API 中移除。

`GET /groups/:id/registry/repositories` 端点将保留，但不会返回任何关于标签的信息。要获取标签信息，你可以使用现有的 `GET /registry/repositories/:id` 端点，该端点将继续如现在一样支持 `tags` 和 `tag_count` 选项。后者必须针对每个镜像仓库调用一次。

<a id="value-stream-analytics-filtering-calculation-change"></a>

### 价值流分析过滤计算变更

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/343210)。

我们正在改变价值流分析中日期过滤器的工作方式。日期过滤器将不再按议题或合并请求的创建时间过滤，而是按给定阶段的结束事件时间过滤。这将导致此变更推出后出现完全不同的数字。

如果你监控价值流分析指标并依赖日期过滤器，为避免数据丢失，你必须在此变更之前保存数据。

<a id="vulnerability-check"></a>

### 漏洞检查

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))

漏洞检查功能在极狐GitLab 14.8 中被弃用，并计划在极狐GitLab 15.0 中移除。我们鼓励你迁移到新的安全审批功能。你可以通过导航到 **安全与合规** > **策略** 并创建新的扫描结果策略来完成此操作。

新的安全审批功能与漏洞检查类似。例如，两者都可以要求对包含安全漏洞的合并请求进行审批。但是，安全审批在以下几个方面改进了以前的体验：

- 用户可以选择允许谁编辑安全审批规则。独立的安全或合规团队因此可以以防止开发项目维护者修改规则的方式来管理规则。
- 可以创建多个规则并将其串联起来，以允许对每种扫描器类型的不同严重性阈值进行过滤。
- 可以对安全审批规则的任何所需更改强制执行两步审批流程。
- 一组安全策略可以应用于多个开发项目，以便于维护单一的、集中化的规则集。

<a id="versions-on-base-packagetype"></a>

### `PackageType` 基类上的 `Versions`

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/327453)。

作为[创建软件包仓库 GraphQL API](https://jihulab.com/groups/gitlab-cn/-/epics/6318) 工作的一部分，软件包组弃用了基本 `PackageType` 类型的 `Version` 类型，并将其移至 [`PackageDetailsType`](https://gitlab.cn/docs/api/graphql/reference/#packagedetailstype)。

在 15.0 版本中，我们将从 `PackageType` 中完全移除 `Version`。

<a id="apifuzzingciconfigurationcreate-graphql-mutation"></a>

### `apiFuzzingCiConfigurationCreate` GraphQL 变更

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/333233)。

API 模糊测试配置片段现在在客户端生成，不再需要
API 请求。因此，我们弃用了 `apiFuzzingCiConfigurationCreate` 变更，
该变更在极狐GitLab 中不再使用。

<a id="artifactsreportscobertura-keyword"></a>

### `artifacts:reports:cobertura` 关键词

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/348980)。

目前，极狐GitLab 中的测试覆盖率可视化仅支持 Cobertura 报告。从 15.0 开始，
`artifacts:reports:cobertura` 关键词将被
[`artifacts:reports:coverage_report`](https://jihulab.com/gitlab-cn/gitlab/-/issues/344533) 取代。在 15.0 中，Cobertura 将是
唯一支持的报告文件，但这是极狐GitLab 支持其他报告类型的第一步。

<a id="defaultmergecommitmessagewithdescription-graphql-api-field"></a>

### `defaultMergeCommitMessageWithDescription` GraphQL API 字段

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/345451)。

GraphQL API 字段 `defaultMergeCommitMessageWithDescription` 已被弃用，并将在极狐GitLab 15.0 中移除。对于设置了提交消息模板的项目，它将忽略该模板。

<a id="dependency_proxy_for_private_groups-feature-flag"></a>

### `dependency_proxy_for_private_groups` 功能标志

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/276777)。

我们添加了一个功能标志，因为 [极狐GitLab-#11582](https://jihulab.com/gitlab-cn/gitlab/-/issues/11582) 改变了公共群组使用依赖代理的方式。在此变更之前，你可以在不进行认证的情况下使用依赖代理。此变更要求认证才能使用依赖代理。

在 15.0 版本中，我们将完全移除该功能标志。今后，你在使用依赖代理时必须进行认证。

<a id="htpasswd-authentication-for-the-container-registry"></a>

### 容器镜像仓库的 `htpasswd` 认证

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))

容器镜像仓库支持通过 `htpasswd` 进行[认证](https://gitlab.cn/gitlab-org/container-registry/-/blob/master/docs/configuration.md#auth)。它依赖于一个 [Apache `htpasswd` 文件](https://httpd.apache.org/docs/2.4/programs/htpasswd.html)，密码使用 `bcrypt` 哈希。

由于在极狐GitLab（产品）的上下文中未使用它，`htpasswd` 认证将在极狐GitLab 14.9 中弃用，并在极狐GitLab 15.0 中移除。

<a id="pipelines-field-from-the-version-field"></a>

### `version` 字段的 `pipelines` 字段

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/342882)。

在 GraphQL 中，你可以在 [`PackageDetailsType`](https://gitlab.cn/docs/api/graphql/reference/#packagedetailstype) 中使用两个 `pipelines` 字段来获取软件包版本的流水线：

- `versions` 字段的 `pipelines` 字段。这将返回与所有软件包版本关联的所有流水线，这可能会在内存中拉取无限制数量的对象并造成性能问题。
- 特定 `version` 的 `pipelines` 字段。这仅返回与该单一软件包版本关联的流水线。

为了缓解潜在的性能问题，我们将在 15.0 版本中移除 `versions` 字段的 `pipelines` 字段。尽管你将不再能获取一个软件包所有版本的所有流水线，但你可以通过该版本保留的 `pipelines` 字段获取单个版本的流水线。

<a id="projectfingerprint-in-pipelinesecurityreportfinding-graphql"></a>

### `PipelineSecurityReportFinding` GraphQL 中的 `projectFingerprint`

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))

[`PipelineSecurityReportFinding`](https://gitlab.cn/docs/api/graphql/reference/#pipelinesecurityreportfinding)
GraphQL 对象中的 `projectFingerprint` 字段正在被弃用。该字段包含用于确定唯一性的安全发现“指纹”。
计算指纹的方法已经改变，从而产生了不同的值。今后，新值将在 UUID 字段中公开。之前在 `projectFingerprint` 字段中可用的数据最终将被完全移除。

<a id="promote-db-command-from-gitlab-ctl"></a>

### `gitlab-ctl` 中的 `promote-db` 命令

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除 ([重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change))
- 要讨论此变更或了解更多信息，请参见[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/345207)。

在极狐GitLab 14.5 中，我们引入了命令 `gitlab-ctl promote`，用于在故障转移期间将任何 Geo 辅助节点提升为主节点。此命令替代了 `gitlab-ctl promote-db`，后者用于在多节点 Geo 辅助站点中提升数据库节点。`gitlab-ctl promote-db` 将继续按原样运行，并在极狐GitLab 15.0 之前保持可用。我们建议 Geo 客户开始在其预发布环境中测试新的 `gitlab-ctl promote` 命令，并将新命令纳入其故障转移流程。
<a id="promote-to-primary-node-command-from-gitlab-ctl"></a>

### `gitlab-ctl` 中的 `promote-to-primary-node` 命令

- 宣布于 极狐GitLab 14.5
- 移除于 极狐GitLab 15.0（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

在 极狐GitLab 14.5 中，我们引入了 `gitlab-ctl promote` 命令，用于在故障转移期间将任何 Geo 辅助节点提升为主节点。此命令取代了仅适用于单节点 Geo 站点的 `gitlab-ctl promote-to-primary-node`。`gitlab-ctl promote-to-primary-node` 将继续按原样运行，并一直可用到 极狐GitLab 15.0。我们建议 Geo 客户开始在其预发布环境中测试新的 `gitlab-ctl promote` 命令，并将新命令纳入其故障转移流程。

<a id="type-and-types-keyword-in-cicd-configuration"></a>

### CI/CD 配置中的 `type` 和 `types` 关键字

- 宣布于 极狐GitLab 14.6
- 移除于 极狐GitLab 15.0（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

`type` 和 `types` CI/CD 关键字将在 极狐GitLab 15.0 中移除。使用这些关键字的流水线将停止工作，因此您必须切换到具有相同行为的 `stage` 和 `stages`。

<a id="bundler-audit-dependency-scanning-tool"></a>

### bundler-audit 依赖扫描工具

- 宣布于 极狐GitLab 14.6
- 移除于 极狐GitLab 15.0（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参见弃用议题。

从 14.6 开始，bundler-audit 在依赖扫描中被弃用。在弃用期间，它将继续存在于我们的 CI/CD 模板中。我们将在 2022 年 5 月 22 日的 15.0 版本中从依赖扫描中移除 bundler-audit。移除后，Ruby 扫描功能不会受到影响，因为它仍由 Gemnasium 覆盖。

如果您已使用 DS_EXCLUDED_ANALYZERS 明确排除了 bundler-audit，则需要在 15.0 中进行清理（移除引用）。如果您自定义了流水线的依赖扫描配置，例如编辑了 `bundler-audit-dependency_scanning` 作业，则需要在 15.0 移除之前切换到 gemnasium-dependency_scanning，以防止流水线失败。如果您没有使用 DS_EXCLUDED_ANALYZERS 引用 bundler-audit，或专门为 bundler-audit 自定义了模板，则无需采取任何操作。

<a id="gitlab-1410"></a>

## 极狐GitLab 14.10

<a id="permissions-change-for-downloading-composer-dependencies"></a>

### 下载 Composer 依赖项的权限变更

- 宣布于 极狐GitLab 14.9
- 移除于 极狐GitLab 14.10（[重大变更](https://gitlab.cn/docs/update/terminology/#breaking-change)）

极狐GitLab Composer 仓库可用于推送、搜索、获取元数据以及下载 PHP 依赖项。
- 在极狐GitLab 17.7 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/502382)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

极狐GitLab 信奉默认安全的实践。为践行这一理念，我们正在对 CI/CD 变量的使用做出一些更改，以支持最小权限原则。
目前，具有开发者或更高角色的用户默认情况下能够使用[流水线变量](https://gitlab.cn/docs/ci/variables/#use-pipeline-variables)，而无需任何验证或主动选择。

你可以立即开始将最低角色提升至建议的[仅所有者或无人](https://gitlab.cn/docs/ci/variables/#restrict-pipeline-variables)，以获得更默认安全的流水线变量体验。
从 17.7 开始，对于 JihuLab.com 上新命名空间中的所有新项目，默认设置为 `不允许任何人使用`。

### OpenTofu CI/CD 模板

<a id="opentofu-cicd-template"></a>

- 在极狐GitLab 17.1 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/components/opentofu/-/issues/43#note_1913822299)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

我们在 16.8 中引入了 OpenTofu CI/CD 模板，因为当时 CI/CD 组件尚不可用于私有化部署的极狐GitLab。
随着[私有化部署极狐GitLab 的 CI/CD 组件](https://gitlab.cn/docs/ci/components/#use-a-gitlabcom-component-in-a-self-managed-instance)的推出，
我们移除了冗余的 OpenTofu CI/CD 模板，转而使用 CI/CD 组件。

有关从 CI/CD 模板迁移到组件的信息，请参阅 [OpenTofu 组件文档](https://gitlab.com/components/opentofu#usage-on-self-managed)。

### 流水线执行策略 `inject_ci` 策略被 `inject_policy` 取代

<a id="pipeline-execution-policies-inject_ci-strategy-replaced-by-inject_policy"></a>

- 在极狐GitLab 17.11 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/573447)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

随着流水线执行策略中[自定义阶段](https://jihulab.com/gitlab-cn/gitlab/-/issues/475152)的引入（在极狐GitLab 17.9 中可用），我们引入了配置选项 `inject_policy` 来替代已弃用的 `inject_ci`。

这一新策略允许为使用 `inject_ci` 策略的现有流水线执行策略用户平稳地铺开自定义阶段功能。

为准备即将到来的移除，请将所有使用 `inject_ci` 的流水线执行策略更新为使用 `inject_policy`。

### 通用用户、项目及群组 API 端点的速率限制

<a id="rate-limits-for-common-user-project-and-group-api-endpoints"></a>

- 在极狐GitLab 17.4 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/480914)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

默认情况下，将为常用的[用户](https://gitlab.cn/docs/administration/settings/user_and_ip_rate_limits/)、
[项目](https://gitlab.cn/docs/administration/settings/rate_limit_on_projects_api/)和[群组](https://gitlab.cn/docs/administration/settings/rate_limit_on_groups_api/)端点启用速率限制。
默认启用这些速率限制有助于提高整体系统稳定性，并减少大量 API 使用对更广泛的用户体验产生负面影响的可能性。超出速率限制的请求将返回 [HTTP 429](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429) 错误代码和[额外的速率限制标头](https://gitlab.cn/docs/administration/settings/user_and_ip_rate_limits/#response-headers)。

基于我们在 JihuLab.com 上观察到的请求速率，默认的速率限制值有意设置得比较高，以避免干扰大多数使用场景。实例管理员可以在管理区域根据需要设置更高或更低的限制，就像已设置的其他速率限制一样。

### 移除 `ContainerRepository` GraphQL API 中的 `migrationState` 字段

<a id="removal-of-migrationstate-field-in-containerrepository-graphql-api"></a>

- 在极狐GitLab 17.6 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/459869)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

极狐GitLab GraphQL API 的 `ContainerRepositoryType` 中的 `migrationState` 字段已被弃用。此弃用是我们简化和改进 API 工作的一部分。

为准备此变更，我们建议审查并更新与 `ContainerRepositoryType` 交互的 GraphQL 查询。移除对 `migrationState` 字段的任何引用，并相应地调整应用程序逻辑。

### 从 GraphQL 移除 `previousStageJobsOrNeeds`

<a id="remove-previousstagejobsorneeds-from-graphql"></a>

- 在极狐GitLab 17.0 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/424417)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

GraphQL 中的 `previousStageJobsOrNeeds` 字段将被移除，因为它已被 `previousStageJobs` 和 `needs` 字段取代。

### 在 PipelineSchedulePermissions 中用 `admin_pipeline_schedule` 替换 GraphQL 字段 `take_ownership_pipeline_schedule`

<a id="replace-graphql-field-take_ownership_pipeline_schedule-with-admin_pipeline_schedule-in-pipelineschedulepermissions"></a>

- 在极狐GitLab 15.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/391941)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

GraphQL 字段 `take_ownership_pipeline_schedule` 将被弃用。要确定用户是否可以接管流水线调度，请改用 `admin_pipeline_schedule` 字段。

### 解决 Yarn 项目依赖项扫描的漏洞

<a id="resolve-a-vulnerability-for-dependency-scanning-on-yarn-projects"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/501308)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

由 Gemnasium 分析器为依赖项扫描提供的[解决漏洞](https://gitlab.cn/docs/user/application_security/vulnerabilities/#resolve-a-vulnerability)功能（针对 Yarn 项目）已在极狐GitLab 17.9 中弃用。

虽然在使用 Gemnasium 分析器时此功能将继续有效，但在迁移到新的依赖项扫描分析器后将不再可用。详情请参阅[迁移指南](https://gitlab.cn/docs/user/application_security/dependency_scanning/migration_guide_to_sbom_based_scans/)。

作为[自动修复愿景](https://jihulab.com/gitlab-cn/gitlab/-/epics/7186)的一部分，计划推出替代功能，但尚未设定交付时间表。

### 公共 API 中与订阅相关的 API 端点已被弃用

<a id="subscription-related-api-endpoints-in-the-public-api-are-deprecated"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/515371#note_2319368251)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

以下公共 REST API 端点将被移除：

- `PUT /api/v4/user/:id/credit_card_validation`
- `POST /api/v4/namespaces/:namespace_id/minutes`
- `PATCH /api/v4/namespaces/:previous_namespace_id/minutes/move/:target_namespace_id`
- `GET /api/v4/namespaces/:namespace_id/subscription_add_on_purchase/:id`
- `PUT /api/v4/namespaces/:namespace_id/subscription_add_on_purchase/:id`
- `POST /api/v4/namespaces/:namespace_id/subscription_add_on_purchase/:id`
- `POST /api/v4/namespaces/:id/gitlab_subscription`
- `PUT /api/v4/namespaces/:id/gitlab_subscription`
- `PUT /api/v4/namespaces/:id`

这些端点曾被订阅门户用于管理 JihuLab.com 上的订阅信息。它们的使用已由采用 JWT 认证的内部端点替代，以支持即将推出的单元架构。移除公共 API 中的这些端点是为了避免它们被意外再次使用，并随着功能渐行渐远而减轻维护负担。

此变更不应给你带来任何影响，因为这些是内部使用的端点。

### `agentk` 容器仓库迁移至 Cloud Native GitLab

<a id="the-agentk-container-registry-is-moving-to-cloud-native-gitlab"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/issues/630)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

我们正在将 `agentk` 容器仓库从
[其项目特定的仓库](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/container_registry/1223205)
迁移到
[Cloud Native GitLab (CNG) 仓库](https://jihulab.com/gitlab-cn/build/CNG/container_registry/8241772)。
从极狐GitLab 18.0 起，在 CNG 中构建的 `agentk` 镜像将镜像到项目特定的仓库中。
新镜像与旧镜像等效，但新镜像仅支持 `amd64` 和 `arm64` 架构。它不支持 32 位的 `arm` 架构。
从极狐GitLab 19.0 起，项目特定的仓库将不再接收 `agentk` 更新。如果你将 `agentk` 容器镜像到本地仓库，应将镜像源切换为
[CNG 仓库](https://jihulab.com/gitlab-cn/build/CNG/container_registry/8241772)。

如果你使用官方 [极狐GitLab Agent Helm Chart](https://gitlab.com/gitlab-org/charts/gitlab-agent/)，
在极狐GitLab 18.0 中，新的 `agentk` 镜像将无缝地从新位置开始部署。

### 将 CI/CD 作业令牌更新为 JWT 标准

<a id="updating-cicd-job-tokens-to-jwt-standard"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/509578)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

在极狐GitLab 19.0 中，CI/CD 作业令牌将从字符串令牌格式切换为 JWT 令牌格式。此更改将影响所有项目中的现有和新 CI/CD 作业令牌。如果你遇到问题，仍可以在极狐GitLab 20.0 版本之前[为你的 CI/CD 令牌使用旧格式](https://gitlab.cn/docs/ci/jobs/ci_job_token#use-legacy-format-for-cicd-tokens)。

已知问题：

1. 极狐GitLab Runner 的 AWS Fargate 驱动器 0.5.0 及更早版本与 JWT 标准不兼容。作业将因 `文件名过长` 错误而失败。[AWS Fargate 自定义执行器驱动器](https://gitlab.cn/docs/runner/configuration/runner_autoscale_aws_fargate/)的用户必须升级到 0.5.1 或更高版本。有关迁移说明，请参阅[文档](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/tree/master/docs)。
1. 更长的 JWT 标准破坏了某些 CI/CD 配置文件中使用的 `echo $CI_JOB_TOKEN | base64` 命令。你可以改用 `echo $CI_JOB_TOKEN | base64 -w0` 命令。

### Gitaly 中的 `bin_path` 和 `use_bundled_binaries` 配置选项

<a id="bin_path-and-use_bundled_binaries-configuration-options-in-gitaly"></a>

- 在极狐GitLab 18.2 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/9181)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

在 Gitaly 中使用 `bin_path` 和 `use_bundled_binaries` 配置选项的支持已被弃用，并将在极狐GitLab 19.0 中移除。

由 Gitaly 提供的 Git 二进制文件将是执行 Git 的唯一受支持方式。

### 基于 `kpt` 的 `agentk` 已被弃用

<a id="kpt-based-agentk-is-deprecated"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/issues/656)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

我们将移除对基于 `kpt` 安装 Kubernetes 代理的支持。建议你使用以下受支持的安装方法之一安装代理：

- Helm（推荐）
- 极狐GitLab CLI
- Flux

要从 `kpt` 迁移到 Helm，请按照[代理安装文档](https://gitlab.cn/docs/user/clusters/agent/install/)的指引覆盖你通过 `kpt` 部署的 `agentk` 实例。

### `mergeTrainIndex` 和 `mergeTrainsCount` GraphQL 字段已被弃用

<a id="mergetrainindex-and-mergetrainscount-graphql-fields-deprecated"></a>

- 在极狐GitLab 17.5 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/473759)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

`MergeRequest` 中的 GraphQL 字段 `mergeTrainIndex` 和 `mergeTrainsCount` 已被弃用。要确定合并请求在合并队列上的位置，请改用 `MergeTrainCar` 中的 `index` 字段。要获取合并队列中 MR 的数量，请改用 `MergeTrains::TrainType` 中 `cars` 的 `count`。

### `scanResultPolicies` GraphQL 字段已被弃用

<a id="scanresultpolicies-graphql-field-is-deprecated"></a>

- 在极狐GitLab 17.8 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/439199)。

> [!note]
> 此变更已从其原始里程碑中移除，并正在重新评估。

在 16.10 中，扫描结果策略被重命名为合并请求批准策略，以更准确地反映该策略类型在范围和能力上的变化。因此，我们更新了 GraphQL 端点。请使用 `approvalPolicies` 代替 `scanResultPolicies`。

## 已取消的变更

以下变更已被取消。

### 容器扫描默认严重性阈值设置为 `medium`

<a id="container-scanning-default-severity-threshold-set-to-medium"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/515358)。

> [!note]
> 此变更已取消。

容器扫描安全功能会产生大量安全发现，工程团队通常难以管理这一数量。通过将严重性阈值更改为 `medium`，我们为用户提供了一个更合理的默认值，任何严重性低于 `medium` 的发现都不会被报告。从极狐GitLab 18.0 开始，`CS_SEVERITY_THRESHOLD` 环境变量的默认值从 `unknown` 变为 `medium`。因此，`low` 和 `unknown` 严重性级别的安全发现默认将不再被报告。相应地，之前已在默认分支上报告的具有这些严重性的任何漏洞，将在下一次执行容器扫描时被标记为不再检测到。要持续显示这些发现，你必须将 `CS_SEVERITY_THRESHOLD` 变量配置为所需级别。

### 弃用许可证扫描 CI/CD 工件报告类型

<a id="deprecate-license-scanning-cicd-artifact-report-type"></a>

- 在极狐GitLab 16.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/439301)。

> [!note]
> 此变更已取消。

CI/CD [工件报告](https://gitlab.cn/docs/ci/yaml/artifacts_reports/)类型在极狐GitLab 16.9 中弃用，并将在极狐GitLab 18.0 中移除。在极狐GitLab 18.0 中使用此关键字的 CI/CD 配置将停止工作。

由于在极狐GitLab 16.3 中移除了旧版许可证扫描 CI/CD 作业，该工件报告类型已不再使用。你应该转而使用[对 CycloneDX 文件的许可证扫描](https://gitlab.cn/docs/user/compliance/license_scanning_of_cyclonedx_files/)。

### 终止支持的 SAST 作业将从 CI/CD 模板中移除

<a id="end-of-support-sast-jobs-will-be-removed-from-the-cicd-template"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/519133)。

> [!note]
> 此变更已取消。

在极狐GitLab 18.0 中，我们将更新 SAST CI/CD 模板，以移除在之前版本中已达到终止支持的分析器作业。以下作业将从 `SAST.gitlab-ci.yml` 和 `SAST.latest.gitlab-ci.yml` 中移除：

- `bandit-sast`，在 [15.4 中达到终止支持](#sast-analyzer-consolidation-and-cicd-template-changes)
- `brakeman-sast`，在 [17.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-170)
- `eslint-sast`，在 [15.4 中达到终止支持](#sast-analyzer-consolidation-and-cicd-template-changes)
- `flawfinder-sast`，在 [17.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-170)
- `gosec-sast`，在 [15.4 中达到终止支持](#sast-analyzer-consolidation-and-cicd-template-changes)
- `mobsf-android-sast`，在 [17.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-170)
- `mobsf-ios-sast`，在 [17.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-170)
- `nodejs-scan-sast`，在 [17.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-170)
- `phpcs-security-audit-sast`，在 [17.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-170)
- `security-code-scan-sast`，在 [16.0 中达到终止支持](#sast-analyzer-coverage-changing-in-gitlab-160)

在每个分析器达到终止支持时，我们更新了其作业 `rules` 使其默认不运行，并停止发布更新。但是，你可能已自定义模板以继续使用这些作业，或依赖于它们存在于你的流水线中。如果你有任何依赖于上述作业的自定义配置，请在升级到 18.0 之前执行[所需的操作](https://jihulab.com/gitlab-cn/gitlab/-/issues/519133#actions-required)，以避免中断你的 CI/CD 流水线。

### 禁用公开访问安全容器仓库

<a id="public-use-of-secure-container-registries-is-deprecated"></a>

- 在极狐GitLab 17.4 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/470641)。

> [!note]
> 此变更已取消。

在极狐GitLab 18.0 中，`registry.gitlab.com/gitlab-org/security-products/` 下的容器仓库将不再可访问。[自极狐GitLab 14.8 起](https://gitlab.cn/docs/update/deprecations/#secure-and-protect-analyzer-images-published-in-new-location)，正确的位置是 `registry.gitlab.com/security-products`（请注意地址中没有 `gitlab-org`）。

此变更提高了极狐GitLab [漏洞扫描器](https://gitlab.cn/docs/user/application_security/#vulnerability-scanner-maintenance)发布过程的安全性。

建议用户使用 `registry.gitlab.com/security-products/` 下的等效仓库，这是极狐GitLab 安全扫描器镜像的规范位置。相关的极狐GitLab CI 模板已使用此位置，因此使用未修改模板的用户无需进行任何更改。

离线部署应查阅[特定扫描器说明](https://gitlab.cn/docs/user/application_security/offline_deployments/#specific-scanner-instructions)，以确保使用正确的位置镜像所需的扫描器镜像。

### SAST 作业不再使用全局缓存设置

<a id="sast-jobs-no-longer-use-global-cache-settings"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/512564)。

> [!note]
> 此变更已取消。

在极狐GitLab 18.0 中，我们将更新 SAST 和 IaC 扫描，以默认显式[禁用 CI/CD 作业缓存的使用](https://gitlab.cn/docs/ci/caching/#disable-cache-for-specific-jobs)。

此变更影响以下 CI/CD 模板：

- SAST：`SAST.gitlab-ci.yml`。
- IaC 扫描：`SAST-IaC.gitlab-ci.yml`。

我们已更新 `latest` 模板 `SAST.latest.gitlab-ci.yml` 和 `SAST-IaC.latest.gitlab-ci.yml`。有关这些模板版本的更多详细信息，请参阅[稳定版与最新版 SAST 模板](https://gitlab.cn/docs/user/application_security/sast/#stable-vs-latest-sast-templates)。

在大多数项目中，缓存目录不在扫描范围内，因此获取缓存可能导致超时或误报结果。

如果你在扫描项目时需要用到缓存，可以通过在项目的 CI 配置中[覆盖](https://gitlab.cn/docs/user/application_security/sast/#overriding-sast-jobs) [`cache`](https://gitlab.cn/docs/ci/yaml/#cache) 属性来恢复之前的行为。

### 密钥检测分析器默认不再以 root 用户运行

<a id="secret-detection-analyzer-doesnt-run-as-root-user-by-default"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/476160)。

> [!note]
> 此变更已取消。

密钥检测分析器的此项计划变更已取消。你仍然可以默认使用 root 用户。

### 支持将项目构建作为 SpotBugs 扫描的一部分

<a id="support-for-project-build-as-part-of-spotbugs-scans"></a>

- 在极狐GitLab 17.9 中宣布
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/513409)。

> [!note]
> 此变更已取消。

SpotBugs [SAST 分析器](https://gitlab.cn/docs/user/application_security/sast/#supported-languages-and-frameworks) 可以在要扫描的工件不存在时执行构建。虽然对于简单项目这通常有效，但在更复杂的构建中可能会失败。

从极狐GitLab 18.0 起，要解决 SpotBugs 分析器构建失败问题，你应该：

1. [预编译](https://gitlab.cn/docs/user/application_security/sast/#pre-compilation) 项目。
1. 将你要扫描的工件传递给分析器。

这并非功能上的变更，因此为清晰起见，我们将此公告标记为“已取消”。

> [!disclaimer]