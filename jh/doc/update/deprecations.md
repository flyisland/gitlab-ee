---
stage: none
group: none
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>"
toc: false
title: 按版本弃用和移除
---

以下极狐GitLab 功能已弃用，不再推荐使用。

- 每个已弃用的功能都将在未来版本中移除。
- 部分功能在移除时会导致破坏性变更。
- 在 JihuLab.com 上，已弃用的功能可能会在版本发布前的当月内随时移除。
- 要查看已移除功能的文档，请参阅[极狐GitLab 文档存档](https://gitlab.cn/docs/jh/archives/)。
- 对于 GraphQL API 弃用，您应[验证您的 API 调用在不使用已弃用项的情况下仍可正常工作](../api/graphql/_index.md#verify-against-the-future-breaking-change-schema)。

如需对此弃用信息进行高级搜索和筛选，请尝试
[由 GitLab 客户成功团队构建的工具](https://gitlab-com.gitlab.io/cs-tools/gitlab-cs-tools/what-is-new-since/?tab=deprecations)。

[REST API 弃用](../api/rest/deprecations.md)单独记录。

{{< icon name="rss" >}} **如需接收即将发生的破坏性变更通知**，
请将此 URL 添加到您的 RSS 阅读器：`https://docs.gitlab.com/releases/breaking-changes.xml`

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

<a id="gitlab-200"></a>

## 极狐GitLab 20.0

<a id="compliance-pipelines"></a>

### 合规流水线

- 在极狐GitLab 17.3 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/11275)。

目前，有两种方法可确保在项目流水线中运行合规或安全相关作业：

- [合规流水线](https://gitlab.cn/docs/jh/user/compliance/compliance_pipelines/)。
- [安全策略](https://gitlab.cn/docs/jh/user/application_security/policies/)。

为了提供单一位置来确保在项目的所有流水线中运行必需作业，我们已在极狐GitLab 17.3 中弃用合规流水线，并将在极狐GitLab 20.0 中移除该功能。

客户应尽快从合规流水线迁移到新的
[流水线执行策略类型](https://gitlab.cn/docs/jh/user/application_security/policies/pipeline_execution_policies/)。

如需了解更多信息，请参阅相关：

- [迁移指南](https://gitlab.cn/docs/jh/user/compliance/compliance_pipelines/#pipeline-execution-policies-migration)。
- [博客文章](https://about.gitlab.com/blog/why-gitlab-is-deprecating-compliance-pipelines-in-favor-of-security-policies/)。

<a id="dependency-proxy-for-packages-is-deprecated"></a>

### 软件包依赖代理已弃用

- 在极狐GitLab 19.1 中宣布
- 在极狐GitLab 20.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/601255)。

软件包依赖代理已弃用，并将在未来版本中移除。此功能已被 **Maven 虚拟仓库**取代，后者提供更优的性能、更好的上游代理和缓存能力，并与极狐GitLab 的软件包管理工作流更深度集成。

**所需操作：**将您的软件包管理器配置从软件包依赖代理端点迁移到 Maven 虚拟仓库。请参阅 [Maven 虚拟仓库文档](https://gitlab.cn/docs/jh/user/packages/virtual_registry/maven/)了解设置说明。

<a id="deprecate-previousstagejobs-from-graphql"></a>

### 从 GraphQL 弃用 `previousStageJobs`

- 在极狐GitLab 19.2 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/603950)。

GraphQL `CiJob` 类型中的 `previousStageJobs` 字段已弃用，并将在极狐GitLab 20.0 中移除。无需服务器端替代方案，因为极狐GitLab UI 不再需要 `previousStageJobs` 来计算依赖关系。

<a id="design-management-deprecated"></a>

### 设计管理已弃用

- 在极狐GitLab 18.6 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/work_items/20375)。

在极狐GitLab 20.0 中，极狐GitLab 将开始弃用设计管理。设计管理允许用户将线框图、模型图等设计资产上传到极狐GitLab 议题中以进行协作。我们在仔细考虑现有使用情况和预估的客户影响后做出了此决定。相对于当前使用量，设计管理的持续维护成本过高，我们正将精力集中在更符合现代设计师工作流的解决方案上。在极狐GitLab 20.0 及更高版本中，用户将无法再上传新设计。现有设计将保持只读模式，直到极狐GitLab 21.0，以便用户根据需要保存设计。GitLab 正在探索能更好地与设计师已使用的工具集成的替代方案。

<a id="enforce-keyset-pagination-on-audit-event-api"></a>

### 在审计事件 API 上强制执行键集分页

- 在极狐GitLab 17.8 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/382338)。

实例、群组和项目的审计事件 API 目前支持可选的键集分页。在极狐GitLab 20.0 中，我们将对这些 API 强制执行键集分页。

<a id="gitlab-helm-chart-value-gitlabkasingressgrpcenabled"></a>

### GitLab Helm chart 值 `gitlab.kas.ingress.grpc.enabled`

- 在极狐GitLab 19.5 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/work_items/6663)。

在 GitLab Helm chart 中，KAS gRPC Ingress 现在由 `global.kas.ingress.grpc.enabled` 控制，该值还决定向极狐GitLab Kubernetes Agent 通告的地址使用原生 gRPC（`grpcs://`）还是 WebSocket（`wss://`）。

`kas` chart 的本地值 `gitlab.kas.ingress.grpc.enabled` 已弃用，并将在 chart 11.0（极狐GitLab 20.0）中移除。它仍然控制是否渲染 gRPC Ingress，但其他 chart 在推导通告地址时无法看到它，因此 Ingress 和地址可能会不一致。

如果您设置了 `gitlab.kas.ingress.grpc.enabled`，请在升级到 chart 11.0 之前将该值移至 `global.kas.ingress.grpc.enabled`。两者均不设置则保持默认值。对于 NGINX Ingress 提供程序，会渲染 gRPC Ingress，并且当 chart 将 gRPC 路由到 KAS 时，代理会指向 `grpcs://`。

<a id="go-module-proxy-experimental-is-deprecated"></a>

### Go 模块代理（实验性）已弃用

- 在极狐GitLab 19.1 中宣布
- 在极狐GitLab 20.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/592132)。

极狐GitLab 软件包仓库中的实验性 Go 模块代理已弃用，并将在极狐GitLab 20.0 中移除。此功能从未超越实验状态。

它将被 **Go 虚拟仓库**取代，后者将为通过极狐GitLab 解析 Go 模块提供更完整、更可靠的体验。

**所需操作：**如果您将极狐GitLab 用作 Go 模块代理，请计划在 Go 虚拟仓库可用后迁移到该仓库。在此期间，您可以通过更新 `GOPROXY` 环境变量来配置替代代理（例如 `proxy.golang.org` 或自托管解决方案）。

<a id="legacy-retrywhen-failure-reasons-stuck_or_timeout_failure-and-job_execution_timeout-are-deprecated"></a>

### 旧版 `retry:when` 失败原因 `stuck_or_timeout_failure` 和 `job_execution_timeout` 已弃用

- 在极狐GitLab 19.1 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/602133)。

在极狐GitLab 19.0 中，通用的 `stuck_or_timeout_failure` 和 `job_execution_timeout` 作业失败原因被拆分为一组更具体的原因（例如 `stuck_pending_no_matching_runners`、`no_updates_running` 和 `server_timeout_running`）。新构建不再记录旧原因。

这些旧原因仍然是 [`retry:when`](https://gitlab.cn/docs/jh/ci/yaml/#retrywhen) 在 `.gitlab-ci.yml`中的有效值。为避免静默破坏现有配置，当您在 `retry:when` 下列出 `stuck_or_timeout_failure` 或 `job_execution_timeout` 时，极狐GitLab 会将它们视为别名，匹配取代它们的完整特定原因集。使用这些值时，极狐GitLab 还会在 CI lint 输出和流水线编辑器中显示非阻塞警告。

这两个值均已弃用，并计划在极狐GitLab 20.0 中移除。

**所需操作：**更新 `retry:when` 以改用具体的失败原因：

- 将 `stuck_or_timeout_failure` 替换为 `stuck_pending_with_matching_runners`、`stuck_pending_no_matching_runners`、`no_updates_running` 和 `no_updates_canceling`中的相关子集。
- 将 `job_execution_timeout` 替换为 `server_timeout_running` 和/或 `server_timeout_canceling`。

<a id="legacy-group-level-audit-event-streaming-destination-graphql-apis"></a>

### 旧版群组级审计事件流目标 GraphQL API

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/work_items/12339)。

以下用于审计事件流目标的群组级 GraphQL API 已弃用，并将在极狐GitLab 20.0 中移除。

已弃用的 mutation：

- `externalAuditEventDestinationCreate` - 请改用 `groupAuditEventStreamingDestinationsCreate`。
- `externalAuditEventDestinationDestroy` - 请改用 `groupAuditEventStreamingDestinationsDelete`。
- `externalAuditEventDestinationUpdate` - 请改用 `groupAuditEventStreamingDestinationsUpdate`。
- `googleCloudLoggingConfigurationCreate` - 请改用带 `gcpLogging` 类别的 `groupAuditEventStreamingDestinationsCreate`。
- `googleCloudLoggingConfigurationDestroy` - 请改用 `groupAuditEventStreamingDestinationsDelete`。
- `googleCloudLoggingConfigurationUpdate` - 请改用 `groupAuditEventStreamingDestinationsUpdate`。
- `auditEventsAmazonS3ConfigurationCreate` - 请改用带 `amazonS3` 类别的 `groupAuditEventStreamingDestinationsCreate`。
- `auditEventsAmazonS3ConfigurationDelete` - 请改用 `groupAuditEventStreamingDestinationsDelete`。
- `auditEventsAmazonS3ConfigurationUpdate` - 请改用 `groupAuditEventStreamingDestinationsUpdate`。
- `auditEventsStreamingHeadersCreate` - 请使用流目标配置，通过 `groupAuditEventStreamingDestinationsUpdate` 配置请求头。
- `auditEventsStreamingHeadersDestroy` - 请使用流目标配置，通过 `groupAuditEventStreamingDestinationsUpdate` 配置请求头。
- `auditEventsStreamingHeadersUpdate` - 请使用流目标配置，通过 `groupAuditEventStreamingDestinationsUpdate` 配置请求头。
- `auditEventsStreamingDestinationEventsAdd` - 请改用 `auditEventsGroupDestinationEventsAdd`。
- `auditEventsStreamingDestinationEventsRemove` - 请改用 `auditEventsGroupDestinationEventsRemove`。
- `auditEventsStreamingHttpNamespaceFiltersAdd` - 请改用 `auditEventsGroupDestinationNamespaceFilterCreate`。
- `auditEventsStreamingHttpNamespaceFiltersDelete` - 请改用 `auditEventsGroupDestinationNamespaceFilterDelete`。

已弃用的群组字段：

- `Group.externalAuditEventDestinations` - 请改用 `Group.externalAuditEventStreamingDestinations`。
- `Group.googleCloudLoggingConfigurations` - 请改用带 `gcpLogging` 类别的 `Group.externalAuditEventStreamingDestinations`。
- `Group.amazonS3Configurations` - 请改用带 `amazonS3` 类别的 `Group.externalAuditEventStreamingDestinations`。

新的统一流目标 API 通过一组带 `category` 参数的端点支持所有目标类别（HTTP、Google Cloud Logging、Amazon S3）。

<a id="legacy-instance-level-audit-event-streaming-destination-graphql-apis"></a>

### 旧版实例级审计事件流目标 GraphQL API

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/work_items/12339)。

以下用于审计事件流目标的实例级 GraphQL API 已弃用，并将在极狐GitLab 20.0 中移除。

已弃用的 mutation：

- `instanceExternalAuditEventDestinationCreate` - 请改用 `instanceAuditEventStreamingDestinationsCreate`。
- `instanceExternalAuditEventDestinationDestroy` - 请改用 `instanceAuditEventStreamingDestinationsDelete`。
- `instanceExternalAuditEventDestinationUpdate` - 请改用 `instanceAuditEventStreamingDestinationsUpdate`。
- `instanceGoogleCloudLoggingConfigurationCreate` - 请改用带 `gcpLogging` 类别的 `instanceAuditEventStreamingDestinationsCreate`。
- `instanceGoogleCloudLoggingConfigurationDestroy` - 请改用 `instanceAuditEventStreamingDestinationsDelete`。
- `instanceGoogleCloudLoggingConfigurationUpdate` - 请改用 `instanceAuditEventStreamingDestinationsUpdate`。
- `auditEventsInstanceAmazonS3ConfigurationCreate` - 请改用带 `amazonS3` 类别的 `instanceAuditEventStreamingDestinationsCreate`。
- `auditEventsInstanceAmazonS3ConfigurationDelete` - 请改用 `instanceAuditEventStreamingDestinationsDelete`。
- `auditEventsInstanceAmazonS3ConfigurationUpdate` - 请改用 `instanceAuditEventStreamingDestinationsUpdate`。
- `auditEventsStreamingInstanceHeadersCreate` - 请使用流目标配置，通过 `instanceAuditEventStreamingDestinationsUpdate` 配置请求头。
- `auditEventsStreamingInstanceHeadersDestroy` - 请使用流目标配置，通过 `instanceAuditEventStreamingDestinationsUpdate` 配置请求头。
- `auditEventsStreamingInstanceHeadersUpdate` - 请使用流目标配置，通过 `instanceAuditEventStreamingDestinationsUpdate` 配置请求头。
- `auditEventsStreamingDestinationInstanceEventsAdd` - 请改用 `auditEventsInstanceDestinationEventsAdd`。
- `auditEventsStreamingDestinationInstanceEventsRemove` - 请改用 `auditEventsInstanceDestinationEventsRemove`。

已弃用的查询字段：

- `instanceExternalAuditEventDestinations` - 请改用 `auditEventsInstanceStreamingDestinations`。
- `instanceGoogleCloudLoggingConfigurations` - 请改用带 `gcpLogging` 类别的 `auditEventsInstanceStreamingDestinations`。
- `auditEventsInstanceAmazonS3Configurations` - 请改用带 `amazonS3` 类别的 `auditEventsInstanceStreamingDestinations`。

新的统一流目标 API 通过一组带 `category` 参数的端点支持所有目标类别（HTTP、Google Cloud Logging、Amazon S3）。

<a id="support-for-nginx-ingress-haproxy-and-traefik-charts"></a>

### 对 NGINX Ingress、HAProxy 和 Traefik chart 的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590799)。

GitLab Helm chart 捆绑了多个 Ingress 控制器，作为使用 Kubernetes Gateway API 的默认 Envoy Gateway 的替代方案。

这些捆绑的 Ingress 控制器，即 NGINX Ingress、HAProxy 和 Traefik，将从 GitLab Helm chart 和 GitLab Operator 中移除。GitLab Helm chart 和 GitLab Operator 仍将支持使用 Ingress，但必须部署外部 Ingress 控制器才能实现。

我们建议迁移到捆绑的 Envoy Gateway 和 Gateway API。或者，您可以部署并配置
[外部 Ingress 控制器和类](https://gitlab.cn/docs/charts/charts/globals/#configure-ingress-settings)。

<a id="--master-option-for-gitlab-ctl-patroni-failover-and-switchover"></a>

### `gitlab-ctl patroni failover` 和 `switchover`的 `--master` 选项

- 在极狐GitLab 19.4 中宣布
- 在极狐GitLab 20.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9467)。

`gitlab-ctl patroni failover` 和 `gitlab-ctl patroni switchover` 命令的 `--master` 选项已弃用，并将在极狐GitLab 20.0 中移除。自极狐GitLab 19.4 起，这两个命令都接受 `--leader`，这与 `patronictl` 使用的选项名称一致。

要迁移，请在调用这些命令的脚本和 runbooks 中将 `--master` 替换为 `--leader`。该选项接受相同的值：当前主节点的名称。在移除之前，`--master` 保持其行为并打印弃用警告。

<a id="gitlab-195"></a>

## 极狐GitLab 19.5

<a id="bitbucket-cloud-issue-and-wiki-import"></a>

### Bitbucket Cloud 议题和 Wiki 导入

- 在极狐GitLab 19.1 中宣布
- 在极狐GitLab 19.5 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/601061)。

Atlassian 将于 2026 年 8 月 20 日[停用 Bitbucket Cloud 议题和 Wiki](https://community.atlassian.com/forums/Bitbucket-articles/Announcing-sunset-of-Bitbucket-Issues-and-Wikis/ba-p/3193882)。该日期之后，底层 API 端点将被移除，极狐GitLab 将无法再从 Bitbucket Cloud 导入议题或 Wiki。

在极狐GitLab 19.3 中，Bitbucket Cloud 导入器计划妥善处理 API 移除，并跳过议题和 Wiki。在极狐GitLab 19.5 中，计划移除议题和 Wiki 的导入代码。

需要 Bitbucket 议题数据的用户应在 2026 年 8 月 20 日截止日期之前完成导入，或在从 Bitbucket 导出后使用
[CSV 导入](https://gitlab.cn/docs/jh/user/project/issues/csv_import/)。对于 Wiki，请在截止日期之前将 Bitbucket Wiki 代码仓库克隆到本地。

<a id="gitlab-193"></a>

## 极狐GitLab 19.3

<a id="rest-api-returns-400-for-non-numeric-ids-on-integer-path-parameters"></a>

### REST API 对整数路径参数上的非数字 ID 返回 400

- 在极狐GitLab 19.3 中宣布
- 在极狐GitLab 19.3 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/605824)。

多个 REST API 端点此前在整数类型的路径参数上接受非数字或多值输入，而未预先验证。这些请求没有返回明确的错误，而是返回不一致的响应（`401 Unauthorized`、`404 Not Found`，或在罕见的潜在错误情况下返回 `200 OK`）。现在它们会验证参数类型并返回 `400 Bad Request`。

要迁移，请在每个请求中发送单个数字 ID。合法客户端已经这样做，因此格式正确的请求无需采取任何操作。

<a id="gitlab-192"></a>

## 极狐GitLab 19.2

<a id="advanced-search-is-required-for-self-managed-ultimate-tier"></a>

### 私有化部署旗舰版必须使用高级搜索

- 在极狐GitLab 18.11 中宣布
- 在极狐GitLab 19.2 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/582417)。

我们现在***要求***私有化部署旗舰版客户使用
[高级搜索](https://gitlab.cn/docs/jh/integration/advanced_search/elasticsearch/)
来完整访问整套旗舰版功能。没有高级搜索，极狐GitLab 不会中断，但除非启用高级搜索，否则并非所有旗舰版功能都可用。

我们此前***建议***启用高级搜索，作为提高某些功能查询性能的一种方式。我们现在已经确定，构建需要高级搜索的完整功能对于满足我们所要求的交付速度和质量至关重要。

不使用高级搜索不会破坏或降低任何现有功能。这只是一项前瞻性变更：新功能在没有高级搜索的情况下可能不受支持。旗舰版 GA 功能现在可能对完整或部分功能有高级搜索的硬性要求。

启用高级搜索的指导可
[在我们的文档中找到](https://gitlab.cn/docs/jh/user/search/advanced_search/)。

<a id="gitlab-191"></a>

## 极狐GitLab 19.1

<a id="elasticsearch-7x-no-longer-supported-for-advanced-search"></a>

### 高级搜索不再支持 Elasticsearch 7.x

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 19.1 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/583544)。

[Elasticsearch 7.x 的维护期](https://www.elastic.co/support/eol)已于 2026 年 1 月 15 日结束。对于极狐GitLab 私有化部署，管理员必须升级其 Elasticsearch 实例才能使用高级搜索。

<a id="linux-package-support-for-amazon-linux-2"></a>

### 对 Amazon Linux 2 的 Linux 软件包支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.1 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590802)。

在极狐GitLab 19.1 中，我们将移除 Linux 软件包的 Amazon Linux 2 (AL2) 软件包构建。

Amazon Linux 2 将于 2026 年 6 月达到生命周期终点，此后将不再接收安全更新。根据我们的 [Linux 软件包支持的平台政策](https://gitlab.cn/docs/jh/install/package/#supported-platforms)，一旦供应商停止支持某个操作系统，我们就会停止该操作系统的软件包构建，并至少提前六个月公告。

如果您当前在 Amazon Linux 2 上运行极狐GitLab，则必须在升级到极狐GitLab 19.1 之前迁移到 Amazon Linux 2023 (AL2023) 或其他
[受支持的操作系统](https://gitlab.cn/docs/jh/install/package/#supported-platforms)。Amazon 提供了[迁移文档](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.migration-al.generic.from-al2.html)帮助您从 AL2 迁移到 AL2023。

<a id="gitlab-190"></a>

## 极狐GitLab 19.0

<a id="azure-storage-driver-for-the-container-registry"></a>

### 容器镜像仓库的 Azure 存储驱动

- 在极狐GitLab 17.10 中宣布
- 在极狐GitLab 19.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523096)。

容器镜像仓库的旧版 Azure 存储驱动在极狐GitLab 17.10 中已弃用，并将在极狐GitLab 19.0 中移除。如果您为容器镜像仓库使用 Azure 对象存储，并希望更早使用新驱动，则需要更新配置以使用新的 `azure_v2` 驱动。在极狐GitLab 19.0 中，已弃用的 Azure 驱动将成为 `azure_v2` 驱动的别名，无需手动操作。

与旧版驱动相比，`azure_v2` 存储驱动提供了更高的可靠性、更好的性能，并使用了更易于维护的代码库。这些改进有助于防止随着镜像仓库使用规模扩大而出现性能问题。

要迁移到 `azure_v2` 驱动：

1. 更新您的镜像仓库配置文件，使用 `azure_v2` 驱动而不是旧版 `azure` 驱动。
1. 根据新驱动的需要调整您的配置设置。
1. 在部署到生产环境之前，在非生产环境中测试新配置。

有关更新存储驱动配置的更多信息，请参阅[使用对象存储](https://gitlab.cn/docs/jh/administration/packages/container_registry/#use-object-storage)。

<a id="container-registry-aws-s3-signature-version-2-support"></a>

### 容器镜像仓库 AWS S3 Signature Version 2 支持

- 在极狐GitLab 17.8 中宣布
- 在极狐GitLab 19.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/container-registry/-/issues/1449)。

容器镜像仓库中使用 Amazon S3 Signature Version 2 对请求进行身份验证的支持在极狐GitLab 17.8 中已弃用，并计划在极狐GitLab 19.0 中移除。

基于 AWS SDK v2 的新 S3v2 存储驱动（从极狐GitLab 17.10 起以测试版提供，在 19.0 中成为默认驱动）仅支持 Signature Version 4。一旦 S3v2 驱动成为默认驱动，任何 Signature Version 2 配置设置（例如 `v4auth: false`）都将被透明地忽略。

您可以在升级到 S3v2 成为默认驱动的极狐GitLab 版本之前迁移到 Signature Version 4。此变更需要更新您的 S3 存储桶配置设置，并确保您的极狐GitLab 容器镜像仓库设置与 Signature Version 4 兼容。

要迁移：

1. 检查[极狐GitLab 容器镜像仓库设置中的 S3 存储后端配置](https://gitlab.cn/docs/jh/administration/packages/container_registry/#use-object-storage)。
1. 如果 `v4auth` 设置为 `false`，请移除该选项。
1. 验证您现有的凭据是否适用于 v4 身份验证。

如果在进行这些更改后遇到任何问题，请尝试重新生成您的 AWS 凭据。

<a id="enforce-page-limit-for-unauthenticated-projects-api-requests"></a>

### 对未经身份验证的 Projects API 请求强制执行页面限制

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/585176)。

为保持平台稳定性并确保所有客户获得最佳性能，我们将对未经身份验证的 Projects API 请求强制执行最大偏移量限制。偏移量限制仅适用于 JihuLab.com。在极狐GitLab 私有化部署上，偏移量限制受功能标志控制，默认禁用。

**变更内容**

将对 Projects List REST API 的所有未经身份验证的请求强制执行 50,000 的最大偏移量限制。例如，当每页检索 20 条结果时，`page` 参数将被限制为 2,500 页。

需要访问更多数据的工作流必须使用基于键集的分页参数。

**为什么重要**

此限制通过有效管理资源利用率，确保 JihuLab.com 上一致的服务质量和性能。

<a id="linux-package-support-for-suse-distributions"></a>

### 对 SUSE 发行版的 Linux 软件包支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590801)。

我们将在极狐GitLab 19.0 中终止对 SUSE 发行版的支持。这会影响：

- openSUSE Leap 15.6
- SUSE Linux Enterprise Server 12.5
- SUSE Linux Enterprise Server 15.6

openSUSE Leap 15.6 即将到达生命周期终点。虽然 SUSE 通过长期服务继续支持 SUSE Linux Enterprise Server，但极狐GitLab 客户中的采用率过低，无法使持续支持在商业上可行。

使用 Linux 软件包的 SUSE 发行版客户将无法将极狐GitLab 升级到 `18.11.x` 之后的版本。

对于使用这些发行版之一的客户，我们建议在现有发行版上迁移到
[极狐GitLab 的 Docker 部署](https://gitlab.cn/docs/jh/install/docker/installation/)。这样可以避免为了继续接收极狐GitLab 升级而迁移到不同的 Linux 发行版。

**更新**：由于 [SLES 12.5 上的 RPM 软件包大小限制](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9716)，
[Mattermost](https://gitlab.cn/docs/jh/update/deprecations/#mattermost-bundled-with-linux-package) 和
[Spamcheck](https://gitlab.cn/docs/jh/update/deprecations/#spamcheck-support-in-the-linux-package-and-gitlab-helm-chart)
已在极狐GitLab 18.11 中从 SLES 12.5 软件包中移除，早于它们在极狐GitLab 19.0 中从所有发行版中移除的计划。

<a id="linux-package-support-for-ubuntu-2004"></a>

### 对 Ubuntu 20.04 的 Linux 软件包支持

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8915)。

Ubuntu 20.04 的 Ubuntu 标准支持[已于 2025 年 5 月结束](https://wiki.ubuntu.com/Releases)。

根据我们的 [Linux 软件包支持的平台政策](https://gitlab.cn/docs/jh/install/package/#supported-platforms)，一旦供应商停止支持某个操作系统，我们就会停止该操作系统的软件包构建。

从极狐GitLab 19.0 起，我们将不再为 Linux 软件包安装提供 Ubuntu 20.04 发行版的软件包。极狐GitLab 18.11 将是最后一个为 Ubuntu 20.04 提供 Linux 软件包的极狐GitLab 版本。

如果您当前在 Ubuntu 20.04 上运行极狐GitLab，则必须在升级到极狐GitLab 19.0 之前升级到 Ubuntu 22.04 或其他
[受支持的操作系统](https://gitlab.cn/docs/jh/install/package/#supported-platforms)。Canonical 提供了[升级指南](https://documentation.ubuntu.com/server/how-to/software/upgrade-your-release/)帮助您迁移。

<a id="mattermost-bundled-with-linux-package"></a>

### Linux 软件包捆绑的 Mattermost

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590798)。

在极狐GitLab 19.0 中，我们计划从 Linux 软件包中移除捆绑的 Mattermost。

Mattermost 于 2015 年首次与 GitLab 捆绑，作为开源团队消息解决方案，并包含 GitLab SSO 以支持集成。此后，Mattermost 自身的打包和部署选项已显著成熟，而 GitLab 客户中捆绑 Mattermost 的采用率仍然相对较低。

随着 Mattermost v11 的发布，[Mattermost 已在其免费产品中弃用 GitLab SSO](https://forum.mattermost.com/t/mattermost-v11-changes-in-free-offerings/25126)。鉴于这一变化、Mattermost 独立部署选项的成熟度以及我们客户群中的低采用率，我们将从 Linux 软件包中移除 Mattermost。

如果您当前使用与极狐GitLab 捆绑的 Mattermost，请参阅 Mattermost 文档中的
[从 GitLab Omnibus 迁移到 Mattermost Standalone](https://docs.mattermost.com/administration-guide/onboard/migrate-gitlab-omnibus.html)
了解迁移说明和可用的 Mattermost 版本。

<a id="resource-owner-password-credentials-grant-is-deprecated"></a>

### 资源所有者密码凭据授权已弃用

- 在极狐GitLab 18.0 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/457353)。

使用资源所有者密码凭据 (ROPC) 授权作为 OAuth 流程已弃用，支持将在极狐GitLab 19.0 中完全移除。我们添加了一个设置，管理员可以在其实例中启用或禁用该设置，以仅将此授权类型与客户端凭据一起使用。这允许希望选择不使用不带客户端凭据的 ROPC 的用户在 19.0 之前这样做。ROPC 将在 19.0 中完全移除，此后即使使用客户端凭据也无法使用。

出于安全原因，GitLab 自 2025 年 4 月 8 日起[在 GitLab.com 上要求对 ROPC 进行客户端身份验证](https://about.gitlab.com/blog/improving-oauth-ropc-security-on-gitlab-com/)。完全移除 ROPC 支持可使安全性与 OAuth RFC 2.1 版本保持一致。

<a id="s3-storage-driver-aws-sdk-v1-for-the-container-registry"></a>

### 容器镜像仓库的 S3 存储驱动（AWS SDK v1）

- 在极狐GitLab 17.10 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523095)。

使用 AWS SDK v1 的容器镜像仓库 S3 存储驱动已弃用，并将在极狐GitLab 19.0 中移除。如果您为容器镜像仓库使用 S3 对象存储，并希望更早使用新驱动，则必须更新配置以使用新的 `s3_v2` 驱动。在极狐GitLab 19.0 中，已弃用的 s3 驱动将成为 `s3_v2` 驱动的别名，无需手动操作。

`s3_v2` 存储驱动基于 AWS SDK v2，提供更高的性能、更好的安全性以及 AWS 的持续支持。它将于 2025 年 5 月起提供，以取代已弃用的 [AWS SDK v1](https://aws.amazon.com/blogs/developer/announcing-end-of-support-for-aws-sdk-for-go-v1-on-july-31-2025/)，后者将于 2025 年 7 月 31 日终止支持。

`s3_v2` 驱动不再支持 Signature Signing Algorithm v2。如果配置中设置了 `v4auth: false` 选项，`s3_v2` 驱动将透明地忽略它，并使用更安全的 V4 算法。要迁移到 `s3_v2` 驱动：

1. 更新您的镜像仓库配置文件，使用 `s3_v2` 配置而不是 `s3`。
1. 如果您尚未从 Signature Version 2 迁移到 Signature Version 4 进行身份验证，请立即迁移，因为 AWS SDK v2 仅支持 Signature Version 4。
1. 在部署到生产环境之前，在非生产环境中测试配置。

在 AWS S3 上，驱动变更还可能改变客户端用于下载镜像仓库 blob 的预签名 URL 中的主机名。AWS SDK v2 会解析您所配置区域的 S3 端点，因此预签名 URL 可能使用区域主机名，例如 `s3.us-east-1.amazonaws.com`，而不是全局主机名 `s3.amazonaws.com`。如果您的网络限制出站流量，请在升级前更新您的代理或防火墙允许名单以包含区域主机名。否则，镜像拉取会失败并返回 `403 Forbidden` 响应。

有关更新存储驱动配置的更多信息，请参阅[使用对象存储](https://gitlab.cn/docs/jh/administration/packages/container_registry/#use-object-storage)。

<a id="slack-slash-commands"></a>

### Slack 斜杠命令

- 在极狐GitLab 18.7 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/569345)。

Slack 斜杠命令集成已弃用，取而代之的是 [GitLab for Slack 应用](https://gitlab.cn/docs/jh/user/project/integrations/gitlab_slack_application/)，后者提供了更安全的集成方法和相同的功能。

从极狐GitLab 19.0 起，用户将无法再配置或使用 Slack 斜杠命令集成。此集成仅在极狐GitLab 私有化部署实例上可用。如果您在 JihuLab.com 上，则无需执行任何操作。

如果您在极狐GitLab 私有化部署上，要了解您是否受到影响，请参阅
[议题 569345](https://gitlab.com/gitlab-org/gitlab/-/work_items/569345#am-i-impacted)。

<a id="spamcheck-support-in-the-linux-package-and-gitlab-helm-chart"></a>

### Linux 软件包和 GitLab Helm chart 中的 Spamcheck 支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590796)。

在极狐GitLab 19.0 中，我们将从 Linux 软件包和 GitLab Helm chart 中移除 [Spamcheck](https://gitlab.cn/docs/jh/administration/reporting/spamcheck/)。

Spamcheck 是一项用于在面向公众的极狐GitLab 实例上打击垃圾信息的服务。就其性质而言，此功能主要与大型公共实例相关，而这在我们的客户群中属于边缘情况。

鉴于采用率低且存在独立部署选项，我们将从 Linux 软件包和 GitLab Helm chart 中移除 Spamcheck。不使用 Spamcheck 的客户不会受到此变更的影响。此移除将减少大多数客户的软件包大小和依赖占用（从而提高安全性）。

如果您当前使用捆绑的 Spamcheck，可以使用
[Docker](https://gitlab.com/gitlab-org/gl-security/security-engineering/security-automation/spam/spamcheck) 单独部署它。

无需数据迁移。配置指导可在链接的文档中找到。

<a id="support-for-nginx-ingress"></a>

### 对 NGINX Ingress 的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590800)。

GitLab Helm chart 目前捆绑 NGINX Ingress 作为默认网络组件。随着 NGINX Ingress 于 2026 年 3 月到达生命周期终点，我们正在过渡到使用 Envoy Gateway 的 Gateway API。

从极狐GitLab 19.0 开始，Gateway API 和捆绑的 Envoy Gateway 成为默认配置。如果迁移到 Envoy Gateway 对您的部署不可行，您可以显式重新启用捆绑的 NGINX Ingress，该组件在极狐GitLab 20.0 中计划移除之前仍然可用。

此变更不影响 Linux 软件包中的 NGINX，也不影响使用外部管理的 Ingress 或 Gateway API 控制器的 GitLab Helm chart 和 GitLab Operator 实例。

在完全移除之前，GitLab 将尽力为其 forked NGINX Ingress chart 和构建提供安全维护。为确保平稳过渡，我们建议您规划迁移到所提供的 Gateway API 解决方案或外部管理的 Ingress 控制器。有关分步说明，请参阅
[Envoy Gateway 迁移指南](https://gitlab.cn/docs/charts/installation/migration/envoy_gateway_migration/)。

<a id="support-for-postgresql-16"></a>

### 对 PostgreSQL 16 的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/589774)。

极狐GitLab 遵循
[PostgreSQL 的年度升级节奏](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)。

对 PostgreSQL 16 的支持计划在极狐GitLab 19.0 中移除。在极狐GitLab 19.0 中，PostgreSQL 17 成为最低要求的 PostgreSQL 版本。

PostgreSQL 17 自极狐GitLab 18.9 起可用，您可以在极狐GitLab 19.0 中移除 PostgreSQL 16 之前的任何时间升级。

如果您运行的是使用 Linux 软件包安装的单个 PostgreSQL 实例，18.11 可能会尝试自动升级。请确保您有足够的磁盘空间来容纳升级。

有关更多信息，请参阅[升级打包的 PostgreSQL 服务器](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="support-for-redis-6"></a>

### 对 Redis 6 的支持

- 在极狐GitLab 18.10 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/585839)。

在极狐GitLab 19.0 中，我们计划移除对 Redis 6 的支持，作为我们维护安全且可支持的基础设施栈承诺的一部分。

在升级到极狐GitLab 19.0 之前，请迁移到 Redis 7.0 或更高版本，或 Valkey 7.2。推荐使用 Redis 7.2 或 Valkey 7.2。Redis 7.0 在上游已达到生命周期终点 (EOL)，但在某些情况下由供应商积极维护，例如 Amazon ElastiCache for Redis 7.1，它基于 Redis 7.0 构建。

Linux 软件包中包含的捆绑 Redis 自极狐GitLab 16.2 起已使用 Redis 7，不受影响。只有使用外部 Redis 6 部署的极狐GitLab 私有化部署实例必须迁移。

有关迁移外部 Redis 6 部署，请参阅以下资源：

- **AWS ElastiCache**：AWS 上不提供 ElastiCache for Redis 7.2。请迁移到
  [Amazon ElastiCache for Valkey 7.2](https://aws.amazon.com/elasticache/what-is-valkey/)，这是推荐方案。
  ElastiCache for Redis 7.1 基于 Redis 7.0 构建，已知可以正常工作。
  有关可用的升级路径，请参阅 [AWS ElastiCache 文档](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/engine-versions.html)。
- **GCP Memorystore**：将您的 Redis 6 实例升级到 Redis 7.2 或 Valkey 7.2。有关可用的升级路径，请参阅
  [GCP Memorystore 文档](https://docs.cloud.google.com/memorystore/docs/redis/supported-versions)。
- **Azure Cache for Redis**：Azure 上目前不提供托管的 Redis 7.2 或 Valkey 7.2 选项。您可以在 Azure VM 或 AKS 上自托管 Redis 7.2 或 Valkey 7.2。您也可以使用极狐GitLab Linux 软件包安装方法，该方法支持 Valkey 7.2。
- **自托管**：将您的 Redis 6 实例升级到 Redis 7.2 或 Valkey 7.2。

有关更多信息，请参阅[要求文档](https://gitlab.cn/docs/jh/install/requirements/)。

<a id="support-for-bundled-postgresql-redis-and-minio-in-gitlab-helm-chart"></a>

### 对 GitLab Helm chart 中捆绑的 PostgreSQL、Redis 和 MinIO 的支持

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590797)。

GitLab Helm chart 捆绑了 Bitnami PostgreSQL、Bitnami Redis 以及官方 MinIO chart 的一个 fork，以简化极狐GitLab 的设置。由于许可、项目维护和公共镜像可用性方面的多项变化，这些组件将从 GitLab Helm chart 和 GitLab Operator 中移除，且没有替代品。

这些 chart 目前默认启用，但已明确记录为不建议用于生产环境。它们的唯一目的是支持快速设置概念验证和测试环境。

如果您正在运行带有捆绑 PostgreSQL、Redis 或 MinIO 的实例，请
查看[迁移指南](https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/)。

Linux 软件包提供的 Redis 和 PostgreSQL 不受此变更影响。

<a id="the-ci_job_token_scope_enabled-projects-api-attribute-is-deprecated"></a>

### `ci_job_token_scope_enabled` projects API 属性已弃用

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 19.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/423091)。

[限制从此项目访问](https://gitlab.cn/docs/jh/update/deprecations/#cicd-job-token---limit-access-from-your-project-setting-removal)
CI/CD 作业令牌项目设置已在 18.0 中移除。[projects API](https://gitlab.cn/docs/jh/api/projects/)中相关的 `ci_job_token_scope_enabled` 属性现已弃用，并且始终返回 `false`，因此将在 19.0 中移除。要控制作业令牌访问，请使用 [CI/CD 作业令牌项目设置](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#control-job-token-access-to-your-project)。

<a id="the-herokubuilder22-image-is-deprecated"></a>

### `heroku/builder:22` 镜像已弃用

- 在极狐GitLab 17.4 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/cluster-integration/auto-build-image/-/issues/79)。

Auto DevOps Build 项目中的云原生 buildpack (CNB) 构建器镜像已更新为 `heroku/builder:24`。虽然我们预计这些变更在大多数情况下不会造成干扰，但对于某些 Auto DevOps 用户，尤其是 Auto Build 用户，这可能是破坏性变更。为了更好地了解对您工作负载的影响，请查看以下内容：

- [Heroku-24 stack 发布说明](https://devcenter.heroku.com/articles/heroku-24-stack#what-s-new)
- [Heroku-24 stack 升级说明](https://devcenter.heroku.com/articles/heroku-24-stack#upgrade-notes)
- [Heroku stack 软件包](https://devcenter.heroku.com/articles/stack-packages)

如果您的流水线使用 [Auto DevOps 的 Auto Build 阶段](https://gitlab.cn/docs/jh/topics/autodevops/stages/#auto-build)提供的 [`auto-build-image`](https://gitlab.com/gitlab-org/cluster-integration/auto-build-image)，这些变更会影响您。

要在极狐GitLab 19.0 之后继续使用 `heroku/builder:22`，请将 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 设置为 `heroku/builder:22`。

<a id="trending-tab-in-explore-projects-page-is-deprecated"></a>

### 探索项目页面中的热门选项卡已弃用

- 在极狐GitLab 18.8 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/work_items/18493)。

**探索** > **项目**中的**热门**选项卡及其关联的 GraphQL 参数在极狐GitLab 18.8 中已弃用，并将在极狐GitLab 19.0 中移除。在极狐GitLab 19.0 发布前的一个月内，**热门**选项卡将在 JihuLab.com 上重定向到按星标降序排序的**活跃**选项卡。

**移除内容**

- **探索** > **项目**页面上的**热门**选项卡
- 以下 GraphQL 类型中的 trending 参数：
  - `Query.adminProjects`
  - `Query.projects`
  - `Organization.projects`

**我们进行此变更的原因**

热门算法仅考虑公开项目，这使得它对于主要使用内部或私有可见性的极狐GitLab 私有化部署实例无效。该算法的局限性和缺乏搜索能力已导致私有化部署用户明确提出移除请求。与其投入大量改进，我们正将资源集中在增强现有的发现机制上。

**所需操作**

UI 用户：在 19.0 中完全移除之前的下一个破坏性变更窗口期间，**热门**选项卡将无法访问。我们建议使用**活跃**选项卡查看最近更新或星标最多的项目。

<a id="using-app-passwords-with-bitbucket-cloud-import-gitlab-api"></a>

### 在 Bitbucket Cloud 导入极狐GitLab API 中使用应用密码

- 在极狐GitLab 18.9 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/588961)。

Atlassian 已弃用 Bitbucket Cloud 的应用密码（用户名和密码身份验证），并
[宣布](https://www.atlassian.com/blog/bitbucket/bitbucket-cloud-transitions-to-api-tokens-enhancing-security-with-app-password-deprecation)
此身份验证方法将于 2026 年 6 月 9 日停止工作。

从极狐GitLab 19.0 起，如果您想通过极狐GitLab API 从 Bitbucket Cloud 导入代码仓库，则必须改用
[用户 API 令牌](https://support.atlassian.com/organization-administration/docs/understand-user-api-tokens/)。

从 Bitbucket Server 或通过极狐GitLab UI 从 Bitbucket Cloud 导入代码仓库的用户不受影响。

<a id="cijobtokenscopeaddproject-graphql-mutation-is-deprecated"></a>

### `ciJobTokenScopeAddProject` GraphQL mutation 已弃用

- 在极狐GitLab 17.5 中宣布
- 在极狐GitLab 19.0 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/474175)。

随着极狐GitLab 18.0 中 [CI/CD 作业令牌即将发生的默认行为变更](https://gitlab.cn/docs/jh/update/deprecations/#default-cicd-job-token-ci_job_token-scope-changed)，我们也将弃用相关的 `ciJobTokenScopeAddProject` GraphQL mutation，取而代之的是 `ciJobTokenScopeAddGroupOrProject`。

<a id="gitlab-188"></a>

## 极狐GitLab 18.8

<a id="static-compliance-violations-report"></a>

### 静态合规违规报告

- 在极狐GitLab 18.2 中宣布
- 在极狐GitLab 18.8 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/12774)。

现有的静态合规违规报告在极狐GitLab 18.2 中已弃用，并将在极狐GitLab 18.8 中移除。

要替代静态合规违规报告：

- 在极狐GitLab 17.11 中，我们发布了[自定义合规框架](https://gitlab.cn/docs/jh/user/compliance/compliance_frameworks/)。
- 在极狐GitLab 18.2 中，我们发布了新的[动态合规违规报告](https://gitlab.cn/docs/jh/user/compliance/compliance_center/compliance_violations_report/)。

这些功能提供了与静态违规报告相同的所有功能，但您可以配置所需的违规项。

在极狐GitLab 18.8 中，我们将使用合规框架将静态合规违规报告替换为动态报告，以便更准确地报告要求和控制项。

<a id="gitlab-186"></a>

## 极狐GitLab 18.6

<a id="early-mistral-models-deprecated-for-gitlab-duo-self-hosted"></a>

### 早期 Mistral 模型已针对极狐GitLab Duo 自部署版本弃用

- 在极狐GitLab 18.3 中宣布
- 在极狐GitLab 18.6 中终止支持
- 在极狐GitLab 18.6 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/557156)。

在极狐GitLab 18.6 中，极狐GitLab 将移除对 Mistral 7B-it、Mixtral 8x7B 和 Mixtral 8x22B 模型的支持，这些模型用于极狐GitLab Duo 自部署版本。极狐GitLab Duo Enterprise 客户可以继续将这些模型与极狐GitLab Duo 自部署版本一起使用，但对于使用这些模型的配置将不再获得技术支持。极狐GitLab Duo 自部署版本将继续支持 Mistral Small 24B Instruct 2506，该模型已[验证与所有正式发布的极狐GitLab Duo 自部署版本功能完全兼容](https://gitlab.cn/docs/jh/administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements/)。

<a id="prometheus-2x-bundled-with-the-omnibus-linux-package"></a>

### Omnibus Linux 软件包捆绑的 Prometheus 2.x

- 在极狐GitLab 18.3 中宣布
- 在极狐GitLab 18.6 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/9196)。

Linux 软件包捆绑的 Prometheus 2.x 已弃用，并将在极狐GitLab 18.6 中更新到最新的 Prometheus 3.x 版本。

Prometheus 3 包含一些潜在的破坏性变更，例如新的日志格式和更严格的请求头验证。有关更多信息，请参阅 [Prometheus 迁移指南](https://prometheus.io/docs/prometheus/latest/migration/)。

此变更不影响 GitLab Helm chart 安装。

<a id="replace-compliance-standards-adherence-dashboard-with-compliance-status-dashboard"></a>

### 用合规状态仪表板替换合规标准遵守情况仪表板

- 在极狐GitLab 17.11 中宣布
- 在极狐GitLab 18.6 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/470834)。

在极狐GitLab 17.11 中，我们发布了：

- [自定义合规框架](https://gitlab.cn/docs/jh/user/compliance/compliance_frameworks/)。
- [合规状态报告](https://gitlab.cn/docs/jh/user/compliance/compliance_center/compliance_status_report/)。

这些功能提供了与合规标准遵守情况仪表板相同的所有功能，但您可以配置所需的遵守情况。

在极狐GitLab 18.6 中，我们将用合规状态仪表板替换合规标准遵守情况仪表板，以便更准确地报告要求和控制项。

<a id="user-setting-to-disable-exact-code-search"></a>

### 禁用精确代码搜索的用户设置

- 在极狐GitLab 18.3 中宣布
- 在极狐GitLab 18.6 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/554933)。

禁用精确代码搜索的用户设置现已弃用。在 JihuLab.com 上，您无法再在个人资料偏好设置中禁用精确代码搜索。

精确代码搜索提供更好的用户体验，并与现有搜索 API 兼容。此用户设置计划在极狐GitLab 18.6 中移除，以确保所有用户都能受益于改进的搜索功能。

<a id="gitlab-185"></a>

## 极狐GitLab 18.5

<a id="support-for-opensearch-1x-in-advanced-search"></a>

### 高级搜索中对 OpenSearch 1.x 的支持

- 在极狐GitLab 18.2 中宣布
- 在极狐GitLab 18.5 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/554530)。

[OpenSearch 1.x 的维护窗口](https://opensearch.org/releases/#maintenance-policy)已结束。对于极狐GitLab 私有化部署，管理员必须升级其 OpenSearch 实例才能使用高级搜索。

<a id="gitlab-184"></a>

## 极狐GitLab 18.4

<a id="bitnami-postgresql-and-redis-images-in-gitlab-chart"></a>

### GitLab chart 中的 Bitnami PostgreSQL 和 Redis 镜像

- 在极狐GitLab 18.4 中宣布
- 在极狐GitLab 18.4 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/6089)。

GitLab Helm chart 默认配置依赖 Bitnami chart 和容器镜像来提供 PostgreSQL 和 Redis。Bitnami 将于 2025 年 9 月 29 日从其免费目录中停止提供这些镜像。从 2025 年 8 月 28 日开始，已开始通过暂时下架镜像进行临时服务中断演练。

GitLab chart 捆绑 Bitnami 的 PostgreSQL 和 Redis 仅用于演示和测试目的。它们不属于任何[受支持的极狐GitLab 参考架构](https://gitlab.cn/docs/jh/administration/reference_architectures/)。如果您使用参考架构，或使用其他供应商的软件包或镜像部署了外部 PostgreSQL 和 Redis，则**不受**此变更影响。

作为临时解决方案，极狐GitLab 已将 chart 配置迁移到 Bitnami 旧版仓库。但是，未打补丁的 GitLab chart 环境（极狐GitLab 17.11、极狐GitLab 18.0.5、极狐GitLab 18.1.4 和极狐GitLab 18.2.1 或更早版本）将继续从已弃用的 Bitnami 仓库拉取镜像，这将在 9 月 29 日之后导致部署失败，并可能在临时中断服务阶段导致部署失败。

如果您正在运行受影响的 GitLab chart 配置，则必须执行以下操作之一：

- 迁移到受支持的极狐GitLab 参考架构。
- 升级到已打补丁的 chart 版本。
- 在 chart 值中配置旧版仓库。有关示例，请参阅
  [合并请求 4421](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/4421)。

展望未来，[我们将评估替代方案](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/6089)，以完全替换或可能从 GitLab chart 中移除 Bitnami 组件。有关更多信息，请参阅
[Bitnami 官方公告](https://github.com/bitnami/charts/issues/35164)。

<a id="gitlab-183"></a>

## 极狐GitLab 18.3

<a id="cert-manager-helm-chart-update"></a>

### cert-manager Helm chart 更新

- 在极狐GitLab 18.0 中宣布
- 在极狐GitLab 18.3 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5928)。

为启用较新 cert-manager chart 的 schema 验证，GitLab Helm chart 的 `certmanager.install` 值已弃用，取而代之的是 `installCertmanager`。schema 定义不接受我们在 GitLab chart 的 `certmanager` 部分中添加的额外属性。

在极狐GitLab 18.3（GitLab chart 9.3）中，我们将移除已弃用的值并更新捆绑的 cert-manager。

如果您之前使用过 `certmanager.install` 设置：

1. 将 `certmanager.install`的值转移到 `installCertmanager`。
1. 完全移除 `certmanager.install` 设置。

另请查看 cert-manager 发布说明：

- [发布说明 1.12 - 1.16](https://cert-manager.io/docs/releases/upgrading/upgrading-1.12)
- [发布说明 1.17](https://cert-manager.io/docs/releases/upgrading/upgrading-1.16-1.17)

<a id="gitlab-181"></a>

## 极狐GitLab 18.1

<a id="pipeline-job-limits-extended-to-the-commits-api"></a>

### 流水线作业限制扩展到 Commits API

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.1 中移除（[破坏性变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/436361)。

从极狐GitLab 18.0 开始，[活跃流水线中的最大作业数](https://gitlab.cn/docs/jh/administration/instance_limits/#number-of-jobs-in-active-pipelines)也将适用于使用 [Commits API](https://gitlab.cn/docs/jh/api/commits/#set-the-pipeline-status-of-a-commit) 创建作业的情况。请检查您的集成，确保其保持在配置的作业限制范围内。

<a id="gitlab-180"></a>

## 极狐GitLab 18.0

<a id="api-discovery-will-use-branch-pipelines-by-default"></a>

### API Discovery 将默认使用分支流水线

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/515487)。

在极狐GitLab 18.0 中，我们将更新 API Discovery 的 CI/CD 模板（`API-Discovery.gitlab-ci.yml`）的默认行为。

在极狐GitLab 18.0 之前，当存在合并请求时，此模板默认将作业配置为在[合并请求流水线](https://gitlab.cn/docs/jh/ci/pipelines/merge_request_pipelines/)中运行。
从极狐GitLab 18.0 开始，我们将使此模板的行为与其他 AST 扫描器的[稳定模板版本](https://gitlab.cn/docs/jh/user/application_security/detect/roll_out_security_scanning/#template-editions)的行为保持一致：

- 默认情况下，该模板将在分支流水线中运行扫描作业。
- 当存在合并请求时，您可以通过设置 CI/CD 变量 `AST_ENABLE_MR_PIPELINES: true` 来改用合并请求流水线。此新变量的实现跟踪记录在[议题 410880](https://gitlab.com/gitlab-org/gitlab/-/issues/410880)中。

<a id="application-security-testing-analyzers-major-version-update"></a>

### 应用安全测试分析器主版本更新

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513417)。

在极狐GitLab 18.0 中，我们将更新所有应用安全测试分析器容器镜像的主版本。

如果您未使用默认内置模板，或已固定分析器版本，则必须更新 CI/CD 作业定义，以移除固定版本或更新到最新主版本。

极狐GitLab 17.0 至 17.11 的用户将继续收到分析器更新，直至极狐GitLab 18.0 发布；此后，所有新修复的错误和发布的功能将仅在分析器的新主版本中发布。但是，我们不会从容器镜像仓库中移除任何已发布的容器镜像。

根据我们的维护政策，我们不会将错误和功能向后移植到已弃用的版本。如有必要，安全补丁将在最新的 3 个次要版本内向后移植。

具体来说，以下分析器在极狐GitLab 18.0 发布后将不再更新：

- 极狐GitLab 高级 SAST：版本 1
- 容器扫描：版本 7
- Gemnasium：版本 5
- DAST：版本 5
- DAST API：版本 4
- Fuzz API：版本 4
- IaC 扫描：版本 5
- 流水线密钥检测：版本 6
- 静态应用安全测试（SAST）：[所有分析器](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/)的版本 5
  - `kics`
  - `kubesec`
  - `pmd-apex`
  - `semgrep`
  - `sobelow`
  - `spotbugs`

<a id="behavior-change-for-upcoming-and-started-milestone-filters"></a>

### “即将开始”和“已开始”里程碑筛选器的行为变更

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501294)。

“即将开始”和“已开始”特殊筛选器的行为计划在即将发布的极狐GitLab 主版本 18.0 中变更。这两个筛选器的新行为概述见
[议题 429728](https://gitlab.com/gitlab-org/gitlab/-/issues/429728#proposed-issue-filter-logic-for-upcoming-and-started-milestones)。

此变更不影响极狐GitLab REST API，其将继续使用现有的里程碑筛选逻辑。
极狐GitLab GraphQL API 将更新以遵循新的筛选逻辑。

<a id="cicd-job-token---authorized-groups-and-projects-allowlist-enforcement"></a>

### CI/CD 作业令牌 - **已授权群组和项目**允许名单强制执行

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383084)。

通过极狐GitLab 15.9 中引入的[**已授权群组和项目**设置](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)（在极狐GitLab 16.3 中由**限制访问*此*项目**更名而来），您可以控制 CI/CD 作业令牌对项目的访问。
当设置为**仅此项目以及允许名单中的任何群组和项目**时，只有添加到允许名单中的群组或项目才能使用作业令牌访问您的项目。

对于在极狐GitLab 15.9 之前创建的项目，允许名单默认处于禁用状态
（选择了[**所有群组和项目**](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#allow-any-project-to-access-your-project)
访问设置），允许来自任何项目的作业令牌访问。现在，所有新项目中默认启用允许名单。在较旧的项目中，它可能仍处于禁用状态，或者您可能已手动选择**所有群组和项目**选项以使访问不受限制。

从极狐GitLab 17.6 开始，极狐GitLab 私有化部署实例的管理员可以选择
[为所有项目强制执行此更安全的设置](https://gitlab.cn/docs/jh/administration/settings/continuous_integration/#job-token-permissions)。
此设置可防止项目维护者选择**所有群组和项目**。此变更可确保项目之间具有更高的安全性。

在极狐GitLab 18.0 中，此实例设置将在 JihuLab.com 和极狐GitLab 私有化部署上默认启用。极狐GitLab 私有化部署管理员可以在升级到极狐GitLab 18.0 后禁用该设置，以恢复升级前的行为。在极狐GitLab 18.0 中，极狐GitLab 私有化部署的项目设置不会发生任何变更，但实例设置的状态会影响实例上的所有项目。

为准备此变更，使用作业令牌进行跨项目身份验证的项目维护者应填充其项目的**已授权群组和项目**允许名单。然后，他们应将设置更改为**仅此项目以及允许名单中的任何群组和项目**。

为帮助识别需要通过 CI/CD 作业令牌进行身份验证来访问您项目的项目，在极狐GitLab 17.6 中，我们还引入了一种方法来[跟踪作业令牌身份验证](https://about.gitlab.com/releases/2024/11/21/gitlab-17-6-released/#track-cicd-job-token-authentications)访问您的项目的情况。您可以使用该数据来填充您的 CI/CD 作业令牌允许名单。

从极狐GitLab 17.10 到 18.6，您可以使用[迁移工具](https://archives.docs.gitlab.com/18.6/ci/jobs/ci_job_token/#auto-populate-a-projects-allowlist)从作业令牌身份验证日志自动填充 CI/CD 作业令牌允许名单。我们鼓励您使用此迁移工具在[极狐GitLab 18.0 中普遍强制执行允许名单](https://gitlab.cn/docs/jh/update/deprecations/?removal_milestone=18.0#cicd-job-token-authorized-groups-and-projects-allowlist-enforcement)之前填充并使用允许名单。在极狐GitLab 18.0 中，允许名单的自动填充和强制执行将如先前宣布的那样在 JihuLab.com 上进行。

此迁移工具[已移除](https://gitlab.com/gitlab-org/gitlab/-/work_items/498305)，于极狐GitLab 18.7 中。

<a id="cicd-job-token---limit-access-from-your-project-setting-removal"></a>

### CI/CD 作业令牌 - **限制来自您项目的访问**设置移除

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/395708)。

在极狐GitLab 14.4 中，我们引入了一项设置来[限制*来自*您项目的 CI/CD 作业令牌（`CI_JOB_TOKEN`）的访问](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#limit-your-projects-job-token-access)，以使其更加安全。
此设置称为**限制 CI_JOB_TOKEN 访问**。在极狐GitLab 16.3 中，为清晰起见，我们将此设置更名为**限制*来自*此项目的访问**。

在极狐GitLab 15.9 中，我们引入了一项名为
[**已授权群组和项目**](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)的替代设置。
此设置通过使用允许名单来控制*对*您项目的作业令牌访问。这项新设置是对原始设置的重大改进。第一版已在极狐GitLab 16.0 中弃用，并计划在极狐GitLab 18.0 中移除。

**限制*来自*此项目的访问**设置默认对所有新项目禁用。在极狐GitLab 16.0 及更高版本中，在任何项目中禁用此设置后，您都无法重新启用它。请改用**已授权群组和项目**设置来控制对您项目的作业令牌访问。

<a id="dast-dast_crawl_extract_element_timeout-and-dast_crawl_search_element_timeout-variables"></a>

### DAST `dast_crawl_extract_element_timeout` 和 `dast_crawl_search_element_timeout` 变量

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/517250)。

DAST 变量 `DAST_CRAWL_EXTRACT_ELEMENT_TIMEOUT` 和 `DAST_CRAWL_SEARCH_ELEMENT_TIMEOUT` 已弃用，并将在极狐GitLab 18.0 中移除。引入这些变量时，它们为特定的浏览器交互提供了细粒度的超时控制。现在，这些交互由统一的超时值管理，因此这些变量已无必要。此外，由于底层实现问题，自 DAST 基于浏览器的分析器推出以来，这些变量一直未生效。移除这两个变量将简化 DAST 配置，并为用户提供更好的入门体验。

<a id="dast-dast_devtools_api_timeout-will-have-a-lower-default-value"></a>

### DAST `dast_devtools_api_timeout` 将具有更低的默认值

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/517254)。

`DAST_DEVTOOLS_API_TIMEOUT` 环境变量决定 DAST 扫描等待浏览器响应的时长。在极狐GitLab 18.0 之前，该变量具有 45 秒的静态值。在极狐GitLab 18.0 之后，`DAST_DEVTOOLS_API_TIMEOUT` 环境变量具有动态值，该值根据其他超时配置计算得出。
在大多数情况下，45 秒的值高于许多扫描器功能的超时值。动态计算的值通过增加其适用场景的数量，使 `DAST_DEVTOOLS_API_TIMEOUT` 变量更加有用。

为减少潜在的中断，我们将根据以下时间表逐步调整默认超时值：

| 超时值 | 里程碑         |
|:--------------|:------------------|
| 45            | 17.11 及更早版本 |
| 30            | 18.0              |
| 20            | 18.1              |
| 10            | 18.2              |
| 5             | 18.3              |

<a id="dependency-proxy-token-scope-enforcement"></a>

### 依赖代理令牌范围强制执行

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/426887)。

用于容器的依赖代理接受使用个人访问令牌或群组访问令牌的 `docker login` 和 `docker pull` 请求，而无需验证其范围。

在极狐GitLab 18.0 中，依赖代理将要求同时具备 `read_registry` 和 `write_registry` 范围才能进行身份验证。此变更后，使用不具备这些范围的令牌进行身份验证的尝试将被拒绝。

这是一项重大变更。在升级之前，请使用[所需范围](https://gitlab.cn/docs/jh/user/packages/dependency_proxy/#authenticate-with-the-dependency-proxy-for-container-images)创建新的访问令牌，并使用这些新令牌更新您的工作流变量和脚本。

为评估此变更对您的极狐GitLab 私有化部署实例的影响，您可以在极狐GitLab 17.10 及更高版本中监控身份验证日志中的警告消息。在您的 `auth_json.log` 文件中，查找包含 `Dependency proxy missing authentication abilities`的条目。如果您使用的是 GitLab Helm charts，则日志将位于 `component: "gitlab"`和 `subcomponent: "auth_json"`中。这些条目显示了使用不具备所需范围的令牌进行身份验证的尝试，这些尝试在升级到极狐GitLab 18.0 后将失败。

<a id="deprecate-terraform-cicd-templates"></a>

### 弃用 Terraform CI/CD 模板

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438010)。

Terraform CI/CD 模板已弃用，并将在极狐GitLab 18.0 中移除。
这会影响以下模板：

- `Terraform.gitlab-ci.yml`
- `Terraform.latest.gitlab-ci.yml`
- `Terraform/Base.gitlab-ci.yml`
- `Terraform/Base.latest.gitlab-ci.yml`

在极狐GitLab 16.9 中，模板中新增了一个作业，用于告知用户弃用信息。可以通过在受影响的流水线中使用占位作业覆盖 `deprecated-and-will-be-removed-in-18.0` 作业来关闭该警告。

极狐GitLab 无法将作业镜像中的 `terraform` 二进制文件更新到任何根据 BSL 许可的版本。

要继续使用 Terraform，请克隆模板和 [Terraform 镜像](https://gitlab.com/gitlab-org/terraform-images)，
并根据需要进行维护。
GitLab 提供了[详细说明](https://gitlab.com/gitlab-org/terraform-images)，用于迁移到自定义构建的镜像。

作为替代方案，我们建议在 JihuLab.com 上使用新的 OpenTofu CI/CD 组件，
或在极狐GitLab 私有化部署上使用新的 OpenTofu CI/CD 模板。
CI/CD 组件在极狐GitLab 私有化部署上尚不可用，
但[议题 #415638](https://gitlab.com/gitlab-org/gitlab/-/issues/415638)
提议添加此功能。如果 CI/CD 组件在极狐GitLab 私有化部署上可用，
OpenTofu CI/CD 模板将被移除。

查看更多关于[新 OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)的信息。

<a id="deprecate-license-metadata-format-v1"></a>

### 弃用许可证元数据格式 V1

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438477)。

许可证元数据格式 V1 数据集已弃用，并将在极狐GitLab 18.0 中移除。

建议启用了 `package_metadata_synchronization` 功能标志的用户升级到极狐GitLab 16.3 或更高版本，并移除功能标志配置。

<a id="deprecation-of-storage-enum-in-namespaceprojectsortenum-graphql-api"></a>

### 弃用 GraphQL API 中 `NamespaceProjectSortEnum`的 `STORAGE` 枚举

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/396284)。

极狐GitLab GraphQL API 中 `NamespaceProjectSortEnum`的 `STORAGE` 枚举将在极狐GitLab 18.0 中移除。

为准备此变更，我们建议您检查并更新与 `NamespaceProjectSortEnum` 交互的 GraphQL 查询。将对 `STORAGE` 字段的任何引用替换为 `EXCESS_REPO_STORAGE_SIZE_DESC`。

<a id="deprecation-of-name-field-in-projectmonthlyusagetype-graphql-api"></a>

### 弃用 GraphQL API 中 `ProjectMonthlyUsageType`的 `name` 字段

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/381894)。

极狐GitLab GraphQL API 中 `ProjectMonthlyUsageType`的 `name` 字段将在极狐GitLab 18.0 中移除。

为准备此变更，我们建议您检查并更新与 `ProjectMonthlyUsageType` 交互的 GraphQL 查询。将对 `name` 字段的任何引用替换为 `project.name`。

<a id="fallback-support-for-gitlab-nginx-chart-controller-image-v131"></a>

### GitLab NGINX chart 控制器镜像 v1.3.1 的回退支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5794)。

> [!note]
> 此变更仅在您使用 [GitLab NGINX chart](https://gitlab.cn/docs/charts/charts/nginx/)，
> 并且已设置自己的 NGINX RBAC 规则时才会影响您。
>
> 如果您使用自己的[外部 NGINX chart](https://gitlab.cn/docs/charts/advanced/external-nginx/)，
> 或者您使用 GitLab NGINX chart 但未更改任何 NGINX RBAC 规则，则此弃用不适用于您。

在极狐GitLab 17.6（Helm Chart 8.6）中，GitLab chart 将默认 NGINX
控制器镜像从版本 1.3.1 更新到 1.11.2。此新版本需要新的 RBAC 规则，这些规则已添加到我们的 GitLab NGINX chart 中，因此您最终需要创建这些规则。此变更也已向后移植到：

- 极狐GitLab 17.5.1（Helm Chart 8.5.1）
- 极狐GitLab 17.4.3（Helm Chart 8.4.3）
- 极狐GitLab 17.3.6（Helm Chart 8.3.6）

> [!note]
> Helm Chart 8.3 至 8.7 的最新补丁版本包含 NGINX 控制器版本 1.11.2。
> 更高版本的 Chart 包含版本 1.11.5，因为它包含各种
> 安全修复。极狐GitLab 18.0 将默认使用控制器版本 1.11.5。

如果您管理自己的 NGINX RBAC 规则，这意味着您已将
`nginx-ingress.rbac.create` 设置为 `false`。在这种情况下，从极狐GitLab 17.3（Helm
Chart 8.3）到极狐GitLab 17.11（Helm Chart 8.11），存在一个回退
机制，用于检测该变更并使用旧的控制器镜像，
这意味着您无需进行任何 RBAC 规则更改。

从极狐GitLab 18.0（Helm Chart 9.0）开始，此回退机制将被
移除，因此将使用新的控制器镜像，并且新的 RBAC 规则必须存在。

如果您想在极狐GitLab 18.0 强制执行之前利用新的 NGINX 控制器镜像：

1. 将新的 RBAC 规则添加到您的集群中[参见示例](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3901/diffs?commit_id=93a3cbdb5ad83db95e12fa6c2145df0800493d8b)。
1. 将 `nginx-ingress.controller.image.disableFallback` 设置为 `true`。

有关更多信息，请参阅 [Charts 发布页面](https://gitlab.cn/docs/charts/releases/8_0/#upgrade-to-86x-851-843-836)。

<a id="gitaly-rate-limiting"></a>

### Gitaly 速率限制

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitaly/-/issues/5011)。

由于 Git 操作和代码仓库延迟的高度可变性，Gitaly
[基于 RPC 的速率限制](https://gitlab.cn/docs/jh/administration/gitaly/monitoring/#monitor-gitaly-rate-limiting)
效果不佳。配置适当的速率限制具有挑战性，并且通常会很快过时，因为有害操作很少产生足够的每秒请求数来凸显出来。

Gitaly 已支持[并发限制](https://gitlab.cn/docs/jh/administration/gitaly/concurrency_limiting/)和
[自适应限制附加组件](https://gitlab.cn/docs/jh/administration/gitaly/concurrency_limiting/#adaptive-concurrency-limiting)，
这些已在生产环境中证明运行良好。

由于 Gitaly 不直接暴露于外部网络，并且负载均衡器等外部保护层提供了更好的防护，因此速率限制的效果较差。

因此，我们将弃用速率限制，转而采用更可靠的并发限制。Gitaly 基于 RPC 的速率限制将在极狐GitLab 18.0 中移除。

<a id="legacy-web-ide-is-deprecated"></a>

### 旧版 Web IDE 已弃用

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513938)。

基于 Vue 的旧版极狐GitLab Web IDE 实现将从极狐GitLab 中移除。
此变更是在我们成功过渡到基于 GitLab VSCode Fork 的 Web IDE 之后进行的，后者自极狐GitLab 15.11 起一直是默认的 Web IDE 体验。

此移除会影响仍在使用旧版 Web IDE 实现的用户。

为准备此移除，请在您的极狐GitLab 实例上启用 `vscode_web_ide` 功能标志（如果之前已在极狐GitLab 实例中禁用）。

<a id="limit-number-of-scan-execution-policy-actions-allowed-per-policy"></a>

### 限制每个策略允许的扫描执行策略操作数量

- 在极狐GitLab 17.5 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/510897)。

已为每个策略允许的最大扫描执行策略操作数量添加了新的限制。此变更在 17.4 中引入，受 `scan_execution_policy_action_limit` 和 `scan_execution_policy_action_limit_group` 功能标志控制。启用后，仅处理扫描执行策略的前 10 个操作。

通过添加限制，我们可以确保安全策略的性能和可扩展性。

如果需要更多操作，请将现有策略限制为不超过 10 个操作。然后，创建具有额外操作的新扫描执行策略，每个安全策略项目最多 5 个扫描执行策略。

对于极狐GitLab 私有化部署管理员，您可以使用 `scan_execution_policies_action_limit` 应用设置配置自定义限制。

<a id="limited-scan-actions-in-a-scan-execution-policy"></a>

### 扫描执行策略中受限的 `scan` 操作

- 在极狐GitLab 17.5 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/472213)。

在 JihuLab.com 上，从极狐GitLab 18.0 开始，[扫描执行策略](https://gitlab.cn/docs/jh/user/application_security/policies/scan_execution_policies/)限制为每个策略 10 个 `scan` 操作。您无法创建超过限制的新策略，也无法更新超过限制的现有策略。对于任何超过限制的现有策略，仅运行该策略的前 10 个 `scan` 操作。

在极狐GitLab 私有化部署实例上，您可以使用 `scan_execution_policies_action_limit` 应用设置配置自定义限制。这些实例的限制默认为零个操作。我们建议配置 10 个操作的限制。

<a id="major-update-of-the-prometheus-subchart"></a>

### Prometheus 子 Chart 的主版本更新

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5927)。

随着极狐GitLab 18.0 和 GitLab chart 9.0 的发布，Prometheus 子 Chart 将从 15.3 更新到 27.3。
伴随此更新，Prometheus 3 将默认提供。

执行升级需要手动步骤。如果您启用了 Alertmanager、Node Exporter 或
Pushgateway，您还需要更新 Helm 值。

请参阅[迁移指南](https://gitlab.cn/docs/charts/releases/9_0/#prometheus-upgrade)
了解更多信息。

<a id="new-data-retention-limits-for-vulnerabilities-on-gitlabcom"></a>

### JihuLab.com 上漏洞的新数据保留限制

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/16629)。

在极狐GitLab 18.0 中，我们为 JihuLab.com 旗舰版客户引入了新的数据保留限制，以提高系统性能和可靠性。数据保留限制会影响漏洞数据的存储时长。超过 12 个月未更新的漏洞将自动移至冷存储归档。这些归档：

- 仍可通过极狐GitLab UI 访问和下载。
- 保留 3 年。
- 3 年后永久删除。

<a id="postgresql-14-and-15-no-longer-supported"></a>

### 不再支持 PostgreSQL 14 和 15

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521663)。

极狐GitLab 遵循 [PostgreSQL 的年度升级节奏](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)。

对 PostgreSQL 14 和 15 的支持计划在极狐GitLab 18.0 中移除。
在极狐GitLab 18.0 中，PostgreSQL 16 成为所需的最低 PostgreSQL 版本。

PostgreSQL 14 和 15 将在整个极狐GitLab 17 发布周期内得到支持。对于希望在极狐GitLab 18.0 之前升级的实例，也将支持 PostgreSQL 16。

如果您运行的是使用 Omnibus Linux 软件包安装的单个 PostgreSQL 实例，则可能会在 17.11 中尝试自动升级。
请确保您有足够的磁盘空间来容纳升级。有关更多信息，请参阅 [Omnibus 数据库文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="project-page-in-group-settings-is-deprecated"></a>

### 群组设置中的项目页面已弃用

- 在极狐GitLab 17.0 中宣布
- 在极狐GitLab 17.9 中支持结束
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443347)。

群组所有者可以在群组设置中访问一个项目页面，该页面列出了群组包含的项目，并提供创建、编辑或删除项目的选项，以及指向每个项目成员页面的链接。所有这些功能都可以在群组概览页面和各个项目的成员页面上使用。由于群组设置中项目页面的使用率较低且可访问性有限，此页面将被弃用。此变更仅影响用户界面。底层 API 将保持可用，因此仍可使用[项目 API](https://gitlab.cn/docs/jh/api/projects/) 执行项目创建、编辑和删除。在 17.9 中，我们将实现从此页面到群组概览页面的重定向。项目页面将在 18.0 中从群组设置中完全移除。

<a id="rest-api-endpoint-pre_receive_secret_detection_enabled-is-deprecated"></a>

### REST API 端点 `pre_receive_secret_detection_enabled` 已弃用

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/514413)。

REST API 端点 `pre_receive_secret_detection_enabled` 已弃用，取而代之的是 `secret_push_protection_enabled`。我们正在重命名一些 API 字段，以反映功能名称从 `pre_receive_secret_detection` 到 `secret_push_protection`的变更。

我们已添加新的 API 字段名称，但将不再如最初宣布的那样在极狐GitLab 18.0 中移除旧字段名称。

我们仍将更新数据库以[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/512996)旧的 `pre_receive_secret_detection_enabled` 数据库列，但您可以使用任一 API 字段名称。两者都将反映新的 `secret_push_protection_enabled` 数据库列的值。

<a id="raspberry-pi-32-bit-packages-are-deprecated"></a>

### Raspberry Pi 32 位软件包已弃用

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/519113)。

从极狐GitLab 18.0 版本开始，我们将不再为 Raspberry Pi 提供 32 位软件包。
您应使用 64 位 Raspberry Pi OS 并[安装 `arm64` Debian 软件包](https://gitlab.cn/install#debian)。
有关在 32 位操作系统上备份数据并将其恢复到 64 位操作系统的信息，请参阅
[升级 PostgreSQL 的操作系统](https://gitlab.cn/docs/jh/administration/postgresql/upgrading_os/)。

<a id="reject-container-image-pull-policies-not-in-allowed_pull_policies"></a>

### 拒绝不在 `allowed_pull_policies`中的容器镜像拉取策略

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/516107)。

所有配置的拉取策略都应存在于 Runner 的 `config.toml` 文件中指定的
[`allowed_pull_policies` 配置](https://gitlab.cn/docs/runner/executors/docker/#allow-docker-pull-policies)
中。如果不存在，作业应失败并显示 `incompatible pull policy` 错误。

在当前实现中，当定义了多个拉取策略时，只要至少有一个拉取策略与 `allowed-pull-policies`中的策略匹配，作业就会通过，即使其他策略未包含在内。

在极狐GitLab 18.0 中，仅当所有拉取策略都不匹配 `allowed-pull-policies`中的策略时，作业才会失败。但是，与当前行为不同，作业将仅使用 `allowed-pull-policies`中列出的拉取策略。这种区别可能导致当前通过的作业在极狐GitLab 18.0 中失败。

<a id="remove-duoproassigneduserscount-graphql-field"></a>

### 移除 duoProAssignedUsersCount GraphQL 字段

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/498671)。

在 18.0 中，我们将移除 `duoProAssignedUsersCount` GraphQL 字段。如果用户将此字段与 [`aiMetrics` API](https://gitlab.cn/docs/jh/api/graphql/reference/#aimetrics) 一起使用，可能会遇到问题，他们可以改用 `duoAssignedUsersCount`。此移除是[修复以同时统计极狐GitLab Duo Pro 和 Duo 席位已分配用户](https://gitlab.com/gitlab-org/gitlab/-/issues/485510)的一部分。

<a id="rename-setprereceivesecretdetection-graphql-mutation-to-setsecretpushprotection"></a>

### 将 `setPreReceiveSecretDetection` GraphQL 变更重命名为 `setSecretPushProtection`

- 在极狐GitLab 17.7 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/514414)。

`setPreReceiveSecretDetection` GraphQL 变更已重命名为 `setSecretPushProtection`。我们还在重命名该变更响应中的一些字段，以反映功能名称从 `pre_receive_secret_detection` 到 `secret_push_protection`的变更。

我们已添加新的变更名称，但将不再如最初宣布的那样在极狐GitLab 18.0 中移除旧变更名称。

我们仍将更新数据库以[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/512996)旧的 `pre_receive_secret_detection_enabled` 数据库列，但您可以使用任一变更名称。两者都将反映新的 `secret_push_protection_enabled` 数据库列的值。

<a id="rename-options-to-skip-gitguardian-secret-detection"></a>

### 重命名跳过 GitGuardian 密钥检测的选项

- 在极狐GitLab 17.3 中宣布
- 在极狐GitLab 18.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/470119)。

跳过 GitGuardian 密钥检测的选项`[skip secret detection]`和 `secret_detection.skip_all` 已弃用。您应改用`[skip secret push protection]`和 `secret_push_protection.skip_all`。

虽然我们建议使用新的措辞，但我们将不再在极狐GitLab 18.0 中移除旧选项。

<a id="replace-add_on_purchase-graphql-field-with-add_on_purchases"></a>

### 将 `add_on_purchase` GraphQL 字段替换为 `add_on_purchases`

- 在极狐GitLab 17.4 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/476858)。

GraphQL 字段 `add_on_purchase` 将在极狐GitLab 17.4 中弃用，并在极狐GitLab 18.0 中移除。请改用 `add_on_purchases` 字段。

<a id="replace-namespace-add_on_purchase-graphql-field-with-add_on_purchases"></a>

### 将命名空间 `add_on_purchase` GraphQL 字段替换为 `add_on_purchases`

- 在极狐GitLab 17.5 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/489850)。

命名空间 GraphQL 字段 `add_on_purchase` 将在极狐GitLab 17.5 中弃用，并在极狐GitLab 18.0 中移除。请改用根 `add_on_purchases` 字段。

<a id="support-for-suse-linux-enterprise-server-15-sp2"></a>

### 对 SUSE Linux Enterprise Server 15 SP2 的支持

- 在极狐GitLab 17.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8888)。

SUSE Linux Enterprise Server (SLES) 15 SP2 的长期服务和支持 (LTSS) 已于 2024 年 12 月结束。

因此，我们将不再支持用于 Linux 软件包安装的 SLES SP2 发行版。您应升级到 SLES 15 SP6 以获得持续支持。

<a id="the-direction-graphql-argument-for-cijobtokenscoperemoveproject-is-deprecated"></a>

### `ciJobTokenScopeRemoveProject`的 `direction` GraphQL 参数已弃用

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383084)。

`ciJobTokenScopeRemoveProject` 变更的 `direction` GraphQL 参数已弃用。根据极狐GitLab 15.9 中宣布的[默认 CI/CD 作业令牌范围变更](https://gitlab.cn/docs/jh/update/deprecations/#default-cicd-job-token-ci_job_token-scope-changed)，`direction` 参数将默认为 `INBOUND`，而 `OUTBOUND` 在极狐GitLab 17.0 中将不再有效。我们将在极狐GitLab 18.0 中移除 `direction` 参数。

如果您使用 `OUTBOUND` 和 `direction` 参数来控制项目令牌访问的方向，那么使用作业令牌的流水线将面临身份验证失败的风险。为确保流水线继续按预期运行，您需要明确[将其他项目添加到您项目的允许名单中](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)。

<a id="toggle-notes-confidentiality-on-apis"></a>

### 在 API 上切换评论机密性

- 在极狐GitLab 14.10 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/350670)。

通过 REST 和 GraphQL API 切换评论机密性的功能正在弃用。不再支持通过任何方式更新评论的机密属性。我们进行此变更是为了简化体验并防止私人信息被无意泄露。

<a id="git_data_dirs-for-configuring-gitaly-storages"></a>

### 用于配置 Gitaly 存储的 `git_data_dirs`

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 18.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8786)。

使用 `git_data_dirs` 为 Linux 软件包实例配置 Gitaly 存储的支持已
[自 16.0 起](https://gitlab.cn/docs/jh/update/versions/gitlab_16_changes/#gitaly-configuration-structure-change)弃用，并将在 18.0 中移除。

有关迁移说明，请参阅
[从 `git_data_dirs` 迁移](https://gitlab.cn/docs/omnibus/settings/configuration/#migrating-from-git_data_dirs)。

<a id="gitlab-1711"></a>

## 极狐GitLab 17.11

<a id="oauth-ropc-grant-without-client-credentials-is-deprecated"></a>

### 不带客户端凭据的 OAuth ROPC 授权已弃用

- 在极狐GitLab 17.11 中宣布
- 在极狐GitLab 17.11 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/535298)。

自 2025 年 4 月 8 日起，GitLab.com 要求对 OAuth 资源所有者密码凭据 (ROPC) OAuth 授权进行客户端身份验证。ROPC 在 RFC 2.1 版本中被 OAuth 工作组省略。在此日期之后，不带客户端凭据的现有 ROPC 集成将遇到服务中断。如果您遇到中断，请在截止日期之前更新您的集成以包含客户端凭据。更多信息可在[GitLab 的博客](https://about.gitlab.com/blog/improving-oauth-ropc-security-on-gitlab-com/)上找到。

<a id="gitlab-179"></a>

## 极狐GitLab 17.9

<a id="support-for-opensuse-leap-155"></a>

### 对 openSUSE Leap 15.5 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.9 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8778)。

[openSUSE Leap 的长期服务和支持 (LTSS) 于 2024 年 12 月结束](https://en.opensuse.org/Lifetime#openSUSE_Leap)。

因此，我们将不再支持用于 Linux 软件包安装的 openSUSE Leap 15.5 发行版。用户应升级到
openSUSE Leap 15.6 以获得持续支持。

<a id="gitlab-178"></a>

## 极狐GitLab 17.8

<a id="support-for-centos-7"></a>

### 对 CentOS 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8714)。

[CentOS 7 的长期服务和支持 (LTSS) 于 2024 年 6 月结束](https://www.redhat.com/en/topics/linux/centos-linux-eol)。

因此，我们将不再支持用于 Linux 软件包安装的 CentOS 7 发行版。用户应升级到其他操作系统以获得持续支持。

<a id="support-for-oracle-linux-7"></a>

### 对 Oracle Linux 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8746)。

[Oracle Linux 7 的长期服务和支持 (LTSS) 于 2024 年 12 月结束](https://wiki.debian.org/LTS)。

因此，我们将不再支持用于 Linux 软件包安装的 Oracle Linux 7 发行版。用户应升级到
Oracle Linux 8 以获得持续支持。

<a id="support-for-raspberry-pi-os-buster"></a>

### 对 Raspberry Pi OS Buster 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8734)。

Raspberry Pi OS Buster（以前称为 Raspbian Buster）的长期服务和支持 (LTSS) 已于 2024 年 6 月结束。

因此，我们将不再支持用于 Linux 软件包安装的 PiOS Buster 发行版。用户应升级到
PiOS Bullseye 以获得持续支持。

<a id="support-for-red-hat-enterprise-linux-7"></a>

### 对 Red Hat Enterprise Linux 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8714)。

Red Hat Enterprise Linux (RHEL) 7 已于 [2024 年 6 月结束维护支持](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux/rhel-7-end-of-maintenance)。

因此，我们将不再为 RHEL 7 和 RHEL 7 兼容操作系统发布 Linux 软件包。用户应升级到 RHEL 8 以获得持续支持。

<a id="support-for-scientific-linux-7"></a>

### 对 Scientific Linux 7 的支持

- 在极狐GitLab 17.6 中宣布
- 在极狐GitLab 17.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8745)。

[Scientific Linux 7 的长期服务和支持 (LTSS) 于 2024 年 6 月结束](https://scientificlinux.org/downloads/sl-versions/sl7/)。

因此，我们将不再支持用于 Linux 软件包安装的 Scientific Linux 发行版。用户应升级到其他与 RHEL 兼容的操作系统。

<a id="gitlab-177"></a>

## 极狐GitLab 17.7

<a id="error-handling-for-repositorytree-rest-api-endpoint-returns-404"></a>

### `/repository/tree` REST API 端点的错误处理返回 `404`

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 17.7 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420865)。

在极狐GitLab 17.7 中，当请求的路径未找到时，列出代码仓库树 API 端点`/projects/:id/repository/tree`的错误处理行为已更新。该端点现在返回状态码 `404 Not Found`。此前，状态码为 `200 OK`。

此变更已在极狐GitLab 16.5 中于 JihuLab.com 上启用，并将在极狐GitLab 17.7 中适用于私有化部署实例。

如果您的实现依赖于在路径缺失时收到带有空数组的 `200` 状态码，则必须更新错误处理以处理新的 `404` 响应。

<a id="tls-10-and-11-no-longer-supported"></a>

### 不再支持 TLS 1.0 和 1.1

- 在极狐GitLab 17.4 中宣布
- 在极狐GitLab 17.7 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/164512)。

[OpenSSL 1.1.1 版本的长期支持 (LTS) 于 2023 年 9 月结束](https://endoflife.date/openssl)。因此，OpenSSL 3 将成为极狐GitLab 17.7 中的默认版本。极狐GitLab 捆绑了 OpenSSL 3，因此您无需对操作系统进行任何更改。

升级到 OpenSSL 3 后：

- 极狐GitLab 要求所有传出和传入的 TLS 连接使用 TLS 1.2 或更高版本。
- TLS/SSL 证书必须至少具有 112 位安全性。禁止使用短于 2048 位的 RSA、DSA 和 DH 密钥，以及短于 224 位的 ECC 密钥。

有关更多详细信息，请参阅[极狐GitLab 17.5 变更](https://gitlab.cn/docs/jh/update/versions/gitlab_17_changes/#1750)。

<a id="gitlab-176"></a>

## 极狐GitLab 17.6

<a id="support-for-debian-10"></a>

### 对 Debian 10 的支持

- 在极狐GitLab 17.3 中宣布
- 在极狐GitLab 17.6 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8607)。

[Debian 10 的长期服务和支持 (LTSS) 于 2024 年 6 月结束](https://wiki.debian.org/LTS)。

因此，我们将不再支持用于 Linux 软件包安装的 Debian 10 发行版。用户应升级到
Debian 11 或 Debian 12 以获得持续支持。

<a id="gitlab-174"></a>

## 极狐GitLab 17.4

<a id="removed-needs-tab-from-the-pipeline-view"></a>

### 从流水线视图中移除 Needs 选项卡

- 在极狐GitLab 17.1 中宣布
- 在极狐GitLab 17.4 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/336560)。

我们将从流水线视图中移除 Needs 选项卡，因为它与使用**作业依赖项**分组选项的常规流水线视图中显示的信息重复。未来我们将继续改进主流水线图中的视图。

<a id="gitlab-173"></a>

## 极狐GitLab 17.3

<a id="fips-compliant-secure-analyzers-will-change-from-ubi-minimal-to-ubi-micro"></a>

### 符合 FIPS 的 Secure 分析器将从 UBI Minimal 更改为 UBI Micro

- 在极狐GitLab 17.2 中宣布
- 在极狐GitLab 17.3 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/471869)。

我们正在更新用于扫描代码安全漏洞的部分分析器的基础镜像。
我们仅更改已基于 Red Hat Universal Base Image (UBI) 的分析器镜像，因此此变更仅在您已为安全扫描专门启用 [FIPS 模式](https://gitlab.cn/docs/jh/development/fips_compliance/)时才会影响您。
极狐GitLab 安全扫描使用的默认镜像不受影响，因为它们不基于 UBI。

在极狐GitLab 17.3 中，我们将把基于 UBI 的分析器的基础镜像从 UBI Minimal 更改为 [UBI Micro](https://www.redhat.com/en/blog/introduction-ubi-micro)，后者包含更少的不必要软件包，并且不包含软件包管理器。
更新后的镜像将更小，并且受操作系统提供的软件包中漏洞的影响也更少。

极狐GitLab 支持团队的[支持声明](https://gitlab.cn/support)排除了未记录的自定义，包括那些依赖于分析器镜像特定内容的自定义。例如，在 `before_script`中安装其他软件包是不受支持的修改。
尽管如此，如果您依赖此类自定义，请参阅[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/471869#action-required)，了解如何应对此变更或就您当前的自定义提供反馈。

<a id="gitlab-170"></a>

## 极狐GitLab 17.0

<a id="agent-for-kubernetes-option-ca-cert-file-renamed"></a>

### Kubernetes Agent 选项 `ca-cert-file` 已重命名

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437728)。

在极狐GitLab Kubernetes Agent (agentk) 中，`--ca-cert-file` 命令行选项
和相应的 `config.caCert` Helm Chart 值已分别重命名为
`--kas-ca-cert-file` 和 `config.kasCaCert`。

旧的`--ca-cert-file` 和 `config.caCert` 选项已弃用，并将在极狐GitLab 17.0 中移除。

<a id="auto-devops-support-for-herokuish-is-deprecated"></a>

### 对 Herokuish 的 Auto DevOps 支持已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/211643)。

对 Herokuish 的 Auto DevOps 支持已弃用，取而代之的是 [Cloud Native Buildpacks](https://gitlab.cn/docs/jh/topics/autodevops/stages/#auto-build-using-cloud-native-buildpacks)。您应[将构建从 Herokuish 迁移到 Cloud Native Buildpacks](https://gitlab.cn/docs/jh/topics/autodevops/stages/#moving-from-herokuish-to-cloud-native-buildpacks)。从极狐GitLab 14.0 开始，Auto Build 默认使用 Cloud Native Buildpacks。

由于 Cloud Native Buildpacks 不支持自动测试，Auto DevOps 的 Auto Test 功能也已弃用。

<a id="autogenerated-markdown-anchor-links-with-dash---characters"></a>

### 带连字符（`-`）的自动生成 Markdown 锚点链接

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440733)。

极狐GitLab 会自动为所有标题创建锚点链接，以便您可以链接到 Markdown 文档或 Wiki 页面中的特定位置。但在某些边缘情况下，自动生成的锚点所带的连字符（`-`）数量比许多用户预期的要少。例如，对于标题`## Step - 1`，大多数其他 Markdown 工具和 linter 会期望`#step---1`。但极狐GitLab 生成的锚点是`#step-1`，连续的连字符被压缩为一个。

在极狐GitLab 17.0 中，我们将不再去除连续的连字符，从而使自动生成的锚点符合行业标准。如果您的 Markdown 文档链接到在 17.0 中可能包含多个连字符的标题，您应更新标题以避免此边缘情况。以上面的示例为例，您可以将`## Step - 1` 更改为`## Step 1`，以确保页内链接继续有效。

<a id="cirunnerprojects-default-sort-is-changing-to-id_desc"></a>

### CiRunner.projects 默认排序将更改为 `id_desc`

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/372117)。

`CiRunner.projects` 字段的默认排序顺序值将从 `id_asc` 更改为 `id_desc`。
如果您依赖返回项目的顺序为 `id_asc`，请更改脚本以明确指定该选择。

<a id="compliance-framework-in-general-settings"></a>

### 常规设置中的合规框架

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422783)。

我们已将合规框架管理移至
[合规中心](https://gitlab.cn/docs/jh/user/compliance/compliance_center/)的框架和项目报告中。

因此，在极狐GitLab 17.0 中，我们将从群组和项目的**常规**设置页面中移除合规框架的管理功能。

<a id="container-registry-support-for-the-swift-and-oss-storage-drivers"></a>

### 容器镜像仓库对 Swift 和 OSS 存储驱动的支持

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/container-registry/-/issues/1141)。

容器镜像仓库使用存储驱动来与各种对象存储平台配合使用。虽然每个驱动的代码相对独立，但这些驱动的维护负担很高。每个驱动的实现都是独一无二的，对驱动进行更改需要具备该特定驱动的高水平领域专业知识。

为了降低维护成本，我们将弃用对 OSS（对象存储服务）和 OpenStack Swift 的支持。两者都已从上游 Docker Distribution 中移除。这有助于使容器镜像仓库在[对象存储支持](https://gitlab.cn/docs/jh/administration/object_storage/#supported-object-storage-providers)方面与更广泛的极狐GitLab 产品保持一致。

OSS 具有 [S3 兼容模式](https://www.alibabacloud.com/help/en/oss/developer-reference/compatibility-with-amazon-s3)，因此如果您无法迁移到受支持的驱动，请考虑使用该模式。Swift [与 S3 API 操作兼容](https://docs.openstack.org/swift/latest/s3_compat.html)，这也是 S3 存储驱动所必需的。

<a id="dast-zap-advanced-configuration-variables-deprecation"></a>

### DAST ZAP 高级配置变量弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383467)。

随着新的基于浏览器的 DAST 分析器在极狐GitLab 15.7 中正式发布，我们正致力于在未来某个时候使其成为默认的 DAST 分析器。为此，以下旧版 DAST 变量正在弃用，并计划在极狐GitLab 17.0 中移除：`DAST_ZAP_CLI_OPTIONS` 和 `DAST_ZAP_LOG_CONFIGURATION`。这些变量允许对基于 OWASP ZAP 的旧版 DAST 分析器进行高级配置。新的基于浏览器的分析器将不包含相同的功能，因为这些功能特定于 ZAP 的工作方式。

这三个变量将在极狐GitLab 17.0 中移除。

<a id="dependency-scanning-incorrect-sbom-metadata-properties"></a>

### 依赖扫描不正确的 SBOM 元数据属性

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438779)。

极狐GitLab 17.0 移除了对 CycloneDX SBOM 报告中以下元数据属性的支持：

- `gitlab:dependency_scanning:input_file`
- `gitlab:dependency_scanning:package_manager`

这些属性是在极狐GitLab 15.7 中添加到依赖扫描生成的 SBOM 中的。但是，这些属性不正确，并且不符合[极狐GitLab CycloneDX 属性分类法](https://gitlab.cn/docs/jh/development/sec/cyclonedx_property_taxonomy/)。
以下正确的属性已在极狐GitLab 15.11 中添加以解决此问题：

- `gitlab:dependency_scanning:input_file:path`
- `gitlab:dependency_scanning:package_manager:name`

不正确的属性被保留以保持向后兼容性。它们现已弃用，并将在 17.0 中移除。

<a id="dependency-scanning-support-for-sbt-10x"></a>

### 对 sbt 1.0.X 的依赖扫描支持

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415835)。

支持非常旧版本的 sbt 阻碍了我们改进对该软件包管理器其他用例的支持，同时不增加维护成本。

sbt 1.1.0 版本发布于 6 年前，建议用户从 1.0.x 升级，因为依赖扫描将不再有效。

<a id="deprecate-graphql-fields-related-to-the-temporary-storage-increase"></a>

### 弃用与临时存储增加相关的 GraphQL 字段

- 在极狐GitLab 16.7 中宣布
- 在极狐GitLab 17.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385720)。

GraphQL 字段 `isTemporaryStorageIncreaseEnabled` 和 `temporaryStorageIncreaseEndsOn` 已弃用。这些 GraphQL 字段与临时存储增加项目相关。该项目已取消，这些字段未被使用。

<a id="deprecate-grype-scanner-for-container-scanning"></a>

### 弃用用于容器扫描的 Grype 扫描器

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439164)。

极狐GitLab 容器扫描分析器中对 Grype 扫描器的支持已在
极狐GitLab 16.9 中弃用。

从极狐GitLab 17.0 开始，Grype 分析器将不再维护，除非我们的[支持声明](https://gitlab.cn/support)中说明的有限修复。

建议用户使用 `CS_ANALYZER_IMAGE`的默认设置，该设置使用 Trivy 扫描器。

Grype 分析器镜像的当前主版本将继续更新最新的漏洞数据库和操作系统软件包，直至极狐GitLab 19.0，届时该分析器将停止工作。

要在 19.0 之后继续使用 Grype，请参阅[安全扫描器集成文档](https://gitlab.cn/docs/jh/development/integrations/secure/)
了解如何创建您自己的极狐GitLab 集成。

<a id="deprecate-license-scanning-ci-templates"></a>

### 弃用许可证扫描 CI 模板

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439157)。

极狐GitLab 17.0 移除了许可证扫描 CI 模板：

- [`Jobs/License-Scanning.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/6d9956863d3cd066edc50a29767c2cd4a939c6fd/lib/gitlab/ci/templates/Jobs/License-Scanning.gitlab-ci.yml)
- [`Jobs/License-Scanning.latest.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/6d9956863d3cd066edc50a29767c2cd4a939c6fd/lib/gitlab/ci/templates/Jobs/License-Scanning.latest.gitlab-ci.yml)
- [`Security/License-Scanning.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/6d9956863d3cd066edc50a29767c2cd4a939c6fd/lib/gitlab/ci/templates/Security/License-Scanning.gitlab-ci.yml)

包含上述任何模板的 CI 配置将在极狐GitLab 17.0 中停止工作。

建议用户改用 [CycloneDX 文件的许可证扫描](https://gitlab.cn/docs/jh/user/compliance/license_scanning_of_cyclonedx_files/)。

<a id="deprecate-python-39-in-dependency-scanning-and-license-scanning"></a>

### 弃用依赖扫描和许可证扫描中的 Python 3.9

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/441201)。

从极狐GitLab 16.9 开始，依赖扫描和许可证扫描对 Python 3.9 的支持已弃用。在极狐GitLab 17.0 中，Python 3.10 是依赖扫描 CI/CD 作业的默认版本。

从极狐GitLab 17.0 开始，依赖扫描和许可证扫描功能将不再支持需要 Python 3.9 且没有
[兼容 lockfile](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/#obtaining-dependency-information-by-parsing-lockfiles)的项目。

<a id="deprecate-windows-cmd-in-gitlab-runner"></a>

### 弃用极狐GitLab Runner 中的 Windows CMD

- 在极狐GitLab 16.1 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414864)。

在极狐GitLab 11.11 中，Windows Batch 执行器中的 CMD shell 已在极狐GitLab Runner 中弃用，取而代之的是 PowerShell。从那时起，CMD shell 在极狐GitLab Runner 中一直得到支持。然而，这给工程团队和在 Windows 上使用 Runner 的客户带来了额外的复杂性。我们计划在 17.0 中从极狐GitLab Runner 完全移除对 Windows CMD 的支持。客户应计划在 Windows 上使用 shell 执行器时使用 PowerShell。客户可以在移除议题[议题 29479](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29479)中提供反馈或提问。

<a id="deprecate-cirunner-graphql-fields-duplicated-in-cirunnermanager"></a>

### 弃用 `CiRunnerManager`中重复的 `CiRunner` GraphQL 字段

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415185)。

这些字段（`architectureName`、`ipAddress`、`platformName`、`revision`、`version`）现已从 [GraphQL `CiRunner`](https://gitlab.cn/docs/jh/api/graphql/reference/#cirunner) 类型中弃用，因为它们与在 Runner 配置中分组的 Runner 管理器的引入重复。

<a id="deprecate-fmt-job-in-terraform-module-cicd-template"></a>

### 弃用 Terraform Module CI/CD 模板中的 `fmt` 作业

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440249)。

Terraform Module CI/CD 模板中的 `fmt` 作业已弃用，并将在极狐GitLab 17.0 中移除。
这会影响以下模板：

- `Terraform-Module.gitlab-ci.yml`
- `Terraform/Module-Base.gitlab-ci.yml`

您可以使用以下方式手动将 Terraform `fmt` 作业添加回您的流水线：

```yaml
fmt:
  image: hashicorp/terraform
  script: terraform fmt -chdir "$TF_ROOT" -check -diff -recursive
```

您也可以使用 [OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)中的 `fmt` 模板。

<a id="deprecate-message-field-from-vulnerability-management-features"></a>

### 弃用漏洞管理功能中的 `message` 字段

- 在极狐GitLab 16.1 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/411573)。

此合并请求弃用了 `VulnerabilityCreate` GraphQL 变更中的 `message` 字段，以及漏洞导出的 `AdditionalInfo` 列中的该字段。message 字段已在极狐GitLab 16.0 中从安全报告模式中移除，并且不再在其他地方使用。

<a id="deprecate-terminationgraceperiodseconds-in-the-gitlab-runner-kubernetes-executor"></a>

### 弃用极狐GitLab Runner Kubernetes 执行器中的 `terminationGracePeriodSeconds`

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中支持结束
- 在极狐GitLab 17.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28165)。

极狐GitLab Runner Kubernetes 执行器设置 `terminationGracePeriodSeconds` 已弃用，并将在极狐GitLab 17.0 中移除。为管理 Kubernetes 上极狐GitLab Runner 工作进程 Pod 的清理和终止，客户应改为配置 `cleanupGracePeriodSeconds` 和 `podTerminationGracePeriodSeconds`。有关如何使用 `cleanupGracePeriodSeconds` 和 `podTerminationGracePeriodSeconds`的信息，请参阅[极狐GitLab Runner 执行器文档](https://gitlab.cn/docs/runner/executors/kubernetes/#other-configtoml-settings)。

<a id="deprecate-version-field-in-feature-flag-api"></a>

### 弃用功能标志 API 中的 `version` 字段

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437986)。

[功能标志 REST API](https://gitlab.cn/docs/jh/api/feature_flags/)中的 `version` 字段已弃用，并将在极狐GitLab 17.0 中移除。

移除 `version` 字段后，将无法再创建旧版功能标志。

<a id="deprecate-change-vulnerability-status-from-the-developer-role"></a>

### 弃用开发者角色更改漏洞状态的能力

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424133)。

开发者更改漏洞状态的能力现已弃用。我们计划在即将发布的极狐GitLab 17.0 版本中进行重大变更，从开发者角色中移除此能力。希望继续向开发者授予此权限的用户可以为其开发者[创建自定义角色](https://gitlab.cn/docs/jh/user/permissions/#custom-roles)，并添加 `admin_vulnerability` 权限以授予此访问权限。

<a id="deprecate-custom-role-creation-for-group-owners-on-gitlab-self-managed"></a>

### 弃用极狐GitLab 私有化部署中群组所有者的自定义角色创建功能

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439284)。

在极狐GitLab 私有化部署 17.0 中，群组所有者的自定义角色创建功能将被移除。此功能将移至实例级别，仅限管理员使用。群组所有者仍可在群组级别分配自定义角色。

JihuLab.com 上的群组所有者可以继续管理自定义角色并在群组级别进行分配。

如果在极狐GitLab 私有化部署上使用 API 管理自定义角色，则已添加新的实例端点，并且必须使用该端点才能继续执行 API 操作。

- 列出实例上的所有成员角色 - `GET /api/v4/member_roles`
- 向实例添加成员角色 - `POST /api/v4/member_roles`
- 从实例中移除成员角色 - `DELETE /api/v4/member_roles/:id`

<a id="deprecate-field-hassolutions-from-graphql-vulnerabilitytype"></a>

### 弃用 GraphQL VulnerabilityType 中的 `hasSolutions` 字段

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414895)。

GraphQL 字段 `Vulnerability.hasSolutions` 已弃用，并将在极狐GitLab 17.0 中移除。请改用 `Vulnerability.hasRemediations`。

<a id="deprecate-legacy-shell-escaping-and-quoting-runner-shell-executor"></a>

### 弃用旧版 shell 转义和引号处理 runner shell 执行器

- 在极狐GitLab 15.11 中宣布
- 在极狐GitLab 17.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/406679)。

Runner 用于处理变量展开的旧版转义序列机制实现了次优的 Ansi-C 引号处理。此方法意味着 Runner 会展开双引号中包含的参数。从 15.11 开始，我们弃用 runner shell 执行器中的旧版转义和引号处理方法。

<a id="deprecated-parameters-related-to-custom-text-in-the-sign-in-page"></a>

### 弃用登录页面中与自定义文本相关的参数

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/124461)。

[设置 API](https://gitlab.cn/docs/jh/api/settings/)中的参数 `sign_in_text` 和 `help_text` 已弃用。要向登录页面和新用户账号页面添加自定义文本，请使用[外观 API](https://gitlab.cn/docs/jh/api/appearance/)中的 `description` 字段。

<a id="deprecating-windows-server-2019-in-favor-of-2022"></a>

### 弃用 Windows Server 2019，改用 2022

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438554)。

我们最近宣布为 Windows 上的 GitLab.com Runner 发布 Windows Server 2022（测试版）。随之，我们将在极狐GitLab 17.0 中弃用 Windows 2019。

有关如何迁移到使用 Windows 2022 的更多信息，请参阅 [GitLab.com Runner 现已支持 Windows 2022](https://about.gitlab.com/blog/windows-2022-support-for-gitlab-saas-runners/)。

<a id="dingtalk-omniauth-provider"></a>

### DingTalk OmniAuth 提供商

- 在 GitLab 15.10 中宣布
- 在 GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390855)。

为 GitLab 提供 DingTalk OmniAuth 提供商的 `omniauth-dingtalk` gem 将在上游下一个主版本 GitLab 17.0 中移除。此 gem 在上游使用量非常少，更适合 JiHu 版本。

<a id="duplicate-storages-in-gitaly-configuration"></a>

### Gitaly 配置中的重复存储

- 在极狐GitLab 16.10 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitaly/-/issues/5598)。

配置多个指向相同存储路径的 Gitaly 存储的支持已弃用，并将在极狐GitLab 17.0 中移除。在极狐GitLab 17.0 及更高版本中，此类配置将导致错误。

我们正在移除此类配置的支持，因为它可能导致后台代码仓库维护出现问题，并且与未来的 Gitaly 存储实现不兼容。

实例管理员必须更新 `gitlab.rb` 配置文件中 `gitaly['configuration']` 部分的 `storage` 条目，以确保每个存储都配置了唯一的路径。

<a id="file-type-variable-expansion-fixed-in-downstream-pipelines"></a>

### 修复下游流水线中的文件类型变量展开

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419445)。

此前，如果您尝试在另一个 CI/CD 变量中引用[文件类型 CI/CD 变量](https://gitlab.cn/docs/jh/ci/variables/#use-file-type-cicd-variables)，该 CI/CD 变量会展开为包含文件内容。此行为是不正确的，因为它不符合典型的 shell 变量展开规则。CI/CD 变量引用应仅展开为文件路径，而不是文件本身的内容。此问题[已在极狐GitLab 15.7 中针对大多数用例修复](https://gitlab.com/gitlab-org/gitlab/-/issues/29407)。遗憾的是，将 CI/CD 变量传递给下游流水线是一个尚未修复的边缘情况，但现在将在极狐GitLab 17.0 中修复。

通过此变更，在 `.gitlab-ci.yml` 文件中配置的变量可以引用文件变量并传递给下游流水线，文件变量也将传递给下游流水线。下游流水线会将变量引用展开为文件路径，而不是文件内容。

此重大变更可能会中断依赖在下游流水线中展开文件变量的用户工作流。

<a id="geo-legacy-replication-details-routes-for-designs-and-projects-deprecated"></a>

### Geo：弃用设计和项目的旧版复制详情路由

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424002)。

作为将旧版数据类型迁移到 [Geo 自助服务框架](https://gitlab.cn/docs/jh/development/geo/framework/)的一部分，以下复制详情路由已弃用：

- 设计 `/admin/geo/replication/designs` 替换为 `/admin/geo/sites/<Geo Node/Site ID>/replication/design_management_repositories`
- 项目 `/admin/geo/replication/projects` 替换为 `/admin/geo/sites/<Geo Node/Site ID>/replication/projects`

从极狐GitLab 16.4 到 17.0，对旧版路由的查找将自动重定向到新路由。我们将在 17.0 中移除重定向。请更新任何可能使用旧版路由的书签或脚本。

<a id="gitlab-helm-chart-values-gitlabkasprivateapitls-are-deprecated"></a>

### GitLab Helm chart 值 `gitlab.kas.privateApi.tls.*` 已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/4097)。

我们引入了 `global.kas.tls.*` Helm 值，以促进 KAS 与您的 Helm chart 组件之间的 TLS 通信。旧值 `gitlab.kas.privateApi.tls.enabled` 和 `gitlab.kas.privateApi.tls.secretName` 已弃用，并计划在极狐GitLab 17.0 中移除。

由于新值提供了一种简化、全面的方法来为 KAS 启用 TLS，您应该使用 `global.kas.tls.*` 而不是 `gitlab.kas.privateApi.tls.*`。有关 `gitlab.kas.privateApi.tls.*` 的更多信息，请参阅：

- 引入 `global.kas.tls.*` 值的[合并请求](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/2888)。
- [已弃用的 `gitlab.kas.privateApi.tls.*` 文档](https://gitlab.cn/docs/charts/charts/gitlab/kas/#enable-tls-communication-through-the-gitlabkasprivateapi-attributes-deprecated)。
- [新的 `global.kas.tls.*` 文档](https://gitlab.cn/docs/charts/charts/globals/#tls-settings-1)。

<a id="gitlab-runner-provenance-metadata-slsa-v02-statement"></a>

### 极狐GitLab Runner 来源元数据 SLSA v0.2 声明

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36869)。

Runner 会生成来源元数据，目前默认生成符合 SLSA v0.2 的声明。由于 SLSA v1.0 已发布且现已获得极狐GitLab 支持，v0.2 声明现已弃用，并计划在极狐GitLab 17.0 中移除。SLSA v1.0 声明计划在极狐GitLab 17.0 中成为新的默认声明格式。

<a id="graphql-api-access-through-unsupported-methods"></a>

### 通过不受支持的方法访问 GraphQL API

- 在极狐GitLab 17.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442520)。

从极狐GitLab 17.0 开始，我们将限制对 GraphQL 的访问，仅允许通过[已记录的受支持令牌类型](https://gitlab.cn/docs/jh/api/graphql/#token-authentication)进行访问。

对于已经使用已记录且受支持的令牌类型的客户，不会有任何重大变更。

<a id="graphql-networkpolicies-resource-deprecated"></a>

### GraphQL `networkPolicies` 资源已弃用

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421440)。

`networkPolicies` [GraphQL 资源](https://gitlab.cn/docs/jh/api/graphql/reference/#projectnetworkpolicies)已弃用，并将在极狐GitLab 17.0 中移除。自极狐GitLab 15.0 起，此字段未返回任何数据。

<a id="graphql-field-confidential-changed-to-internal-on-notes"></a>

### GraphQL 字段 `confidential` 在评论上更改为 `internal`

- 在极狐GitLab 15.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/371485)。

`Note`的 `confidential` 字段将弃用并重命名为 `internal`。

<a id="graphql-field-registrysizeestimated-has-been-deprecated"></a>

### GraphQL 字段 `registrySizeEstimated` 已弃用

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416509)。

为清晰起见，GraphQL 字段 `registrySizeEstimated` 已重命名为 `containerRegistrySizeIsEstimated`，以与其对应字段匹配。
`registrySizeEstimated` 在极狐GitLab 16.2 中弃用，并将在极狐GitLab 17.0 中移除。
请改用极狐GitLab 16.2 中引入的 `containerRegistrySizeIsEstimated`。

<a id="graphql-field-totalweight-is-deprecated"></a>

### GraphQL 字段 `totalWeight` 已弃用

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416219)。

您可以使用 GraphQL 查询议题看板中议题的总权重。但是，`totalWeight` 字段限制为最大值 2147483647。因此，`totalWeight` 已弃用，并将在极狐GitLab 17.0 中移除。

请改用极狐GitLab 16.2 中引入的 `totalIssueWeight`。

<a id="graphql-type-runnermembershipfilter-renamed-to-cirunnermembershipfilter"></a>

### GraphQL 类型 `RunnerMembershipFilter` 重命名为 `CiRunnerMembershipFilter`

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/409333)。

GraphQL 类型 `RunnerMembershipFilter` 已重命名为 `CiRunnerMembershipFilter`。在极狐GitLab 17.0 中，`RunnerMembershipFilter` 类型的别名将被移除。

<a id="graphql-the-disabled_with_override-value-for-the-sharedrunnerssetting-enum-is-deprecated"></a>

### GraphQL：`SharedRunnersSetting` 枚举的 `DISABLED_WITH_OVERRIDE` 值已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385636)。

在极狐GitLab 17.0 中，`SharedRunnersSetting` GraphQL 枚举类型的 `DISABLED_WITH_OVERRIDE` 值将被移除。请改用 `DISABLED_AND_OVERRIDABLE`。

<a id="graphql-deprecate-support-for-candestroy-and-candelete"></a>

### GraphQL：弃用对 `canDestroy` 和 `canDelete`的支持

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390754)。

软件包仓库用户界面依赖于极狐GitLab GraphQL API。为了让每个人都能轻松做出贡献，前端在所有极狐GitLab 产品领域中保持一致的编码方式非常重要。然而，在极狐GitLab 16.6 之前，软件包仓库 UI 处理权限的方式与产品其他领域不同。

在 16.6 中，我们在 `Types::PermissionTypes::Package` 类型下添加了一个新的 `UserPermissions` 字段，以使软件包仓库与极狐GitLab 的其余部分保持一致。此新字段替换了 `Package`、`PackageBase` 和 `PackageDetailsType` 类型下的 `canDestroy` 字段。它还替换了 `ContainerRepository`、`ContainerRepositoryDetails` 和 `ContainerRepositoryTag`的 `canDelete` 字段。在极狐GitLab 17.0 中，`canDestroy` 和 `canDelete` 字段将被移除。

这是一项重大变更，将在 17.0 中完成。

<a id="hashicorp-vault-integration-will-no-longer-use-the-ci_job_jwt-cicd-job-token-by-default"></a>

### HashiCorp Vault 集成默认将不再使用 `CI_JOB_JWT` CI/CD 作业令牌

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/366798)。

作为我们使用 JWT 和 OIDC 提高 CI 工作流安全性努力的一部分，原生 HashiCorp 集成也将在极狐GitLab 16.0 中更新。任何使用 [`secrets:vault`](https://gitlab.cn/docs/jh/ci/yaml/#secretsvault) 关键字从 Vault 检索密钥的项目都需要[配置为使用 ID 令牌](https://gitlab.cn/docs/jh/ci/secrets/id_token_authentication/#configure-automatic-id-token-authentication)。ID 令牌在 15.7 中引入。

为准备此变更，请使用新的 [`id_tokens`](https://gitlab.cn/docs/jh/ci/yaml/#id_tokens) 关键字并配置 `aud` 声明。确保绑定的受众以 `https://` 为前缀。

在极狐GitLab 15.9 到 15.11 中，您可以[启用**限制 JSON Web 令牌 (JWT) 访问**](https://gitlab.cn/docs/jh/ci/secrets/id_token_authentication/#enable-automatic-id-token-authentication)设置，该设置可防止旧令牌暴露给任何作业，并为 [`secrets:vault` 关键字启用 ID 令牌身份验证](https://gitlab.cn/docs/jh/ci/secrets/id_token_authentication/#configure-automatic-id-token-authentication)。

在极狐GitLab 16.0 及更高版本中：

- 此设置将被移除。
- 使用 `id_tokens` 关键字的 CI/CD 作业可以将 ID 令牌与 `secrets:vault` 一起使用，并且不会有任何 `CI_JOB_JWT*` 令牌可用。
- 不使用 `id_tokens` 关键字的作业将继续拥有 `CI_JOB_JWT*` 令牌，直到极狐GitLab 17.0。

<a id="heroku-image-upgrade-in-auto-devops-build"></a>

### Auto DevOps 构建中的 Heroku 镜像升级

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437937)。

在极狐GitLab 17.0 中，`auto-build-image` 项目将从 `heroku/builder:20` 镜像升级到 `heroku/builder:22`。

要测试新镜像的行为，请将 CI/CD 变量 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 设置为 `heroku/builder:22`。

要在极狐GitLab 17.0 之后继续使用 `heroku/builder:20`，请将 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 设置为 `heroku/builder:20`。

<a id="internal-container-registry-api-tag-deletion-endpoint"></a>

### 内部容器镜像仓库 API 标签删除端点

- 在极狐GitLab 16.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/container-registry/-/issues/1094)。

Docker Registry HTTP API V2 规范（后来被 [OCI Distribution Spec](https://github.com/opencontainers/distribution-spec/blob/main/spec.md) 取代）不包含标签删除操作，必须使用一种不安全且缓慢的变通方法（涉及删除清单，而不是标签）来达到相同的目的。

标签删除是一项重要功能，因此我们向极狐GitLab 容器镜像仓库添加了标签删除操作，将 V2 API 扩展到 Docker 和 OCI 分发规范范围之外。

此后，OCI Distribution Spec 进行了一些更新，现在它使用 [`DELETE /v2/<name>/manifests/<tag>` 端点](https://github.com/opencontainers/distribution-spec/blob/main/spec.md#deleting-tags)提供了标签删除操作。

这使得容器镜像仓库拥有两个提供完全相同功能的端点。`DELETE /v2/<name>/tags/reference/<tag>` 是自定义的极狐GitLab 标签删除端点，`DELETE /v2/<name>/manifests/<tag>` 是极狐GitLab 16.4 中引入的符合 OCI 标准的标签删除端点。

对自定义极狐GitLab 标签删除端点的支持在极狐GitLab 16.4 中弃用，并将在极狐GitLab 17.0 中移除。

此端点由**内部**容器镜像仓库应用程序 API 使用，而不是公共的[极狐GitLab 容器镜像仓库 API](https://gitlab.cn/docs/jh/api/container_registry/)。大多数容器镜像仓库用户无需采取任何行动。在我们过渡到新的符合 OCI 标准的端点时，所有与标签删除相关的极狐GitLab UI 和 API 功能都将保持不变。

如果您确实访问内部容器镜像仓库 API 并使用原始标签删除端点，则必须更新到新端点。

<a id="jwt--jwks-instance-endpoint-is-deprecated"></a>

### JWT `/-/jwks` 实例端点已弃用

- 在极狐GitLab 16.7 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/221031)。

随着极狐GitLab 17.0 中[旧版 JSON Web 令牌版本的弃用](https://gitlab.cn/docs/jh/update/deprecations/?removal_milestone=17.0#old-versions-of-json-web-tokens-are-deprecated)，关联的 `/-/jwks` 端点（它是 `/oauth/discovery/keys`的别名）不再必要，将被移除。
如果您一直在身份验证配置中指定 `jwks_url`，请将配置更新为 `oauth/discovery/keys`，并移除端点中所有对 `/-/jwks`的使用。如果您已经在身份验证配置中使用 `oauth_discovery_keys`，并在端点中使用 `/-/jwks` 别名，请从端点中移除 `/-/jwks`。例如，将 `https://gitlab.example.com/-/jwks` 更改为 `https://gitlab.example.com`。

<a id="legacy-geo-prometheus-metrics"></a>

### 旧版 Geo Prometheus 指标

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430192)。

在将项目迁移到 [Geo 自助服务框架](https://gitlab.cn/docs/jh/development/geo/framework/)之后，我们弃用了许多 [Prometheus](https://gitlab.cn/docs/jh/administration/monitoring/prometheus/) 指标。
以下与 Geo 相关的 Prometheus 指标已弃用，并将在 17.0 中移除。下表列出了已弃用的指标及其各自的替代指标。替代指标在极狐GitLab 16.3.0 及更高版本中可用。

| 已弃用的指标                        | 替代指标                            |
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
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/436100)。

目前在极狐GitLab 中，您可以在许可证列表上查看项目使用的所有许可证以及使用这些许可证的组件。从 16.8 开始，许可证列表已弃用，并计划在 17.0 中作为重大变更移除。您现在可以在依赖项列表上访问项目或群组正在使用的所有许可证，包括按许可证筛选的能力。

<a id="license-scanning-support-for-sbt-10x"></a>

### 对 sbt 1.0.X 的许可证扫描支持

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437591)。

极狐GitLab 17.0 移除了对 sbt 1.0.x 的许可证扫描支持。

建议用户从 sbt 1.0.x 升级。

<a id="linux-packages-for-ubuntu-1804"></a>

### Ubuntu 18.04 的 Linux 软件包

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8082)。

Ubuntu 18.04 的标准支持[已于 2023 年 6 月结束](https://wiki.ubuntu.com/Releases)。

从极狐GitLab 17.0 开始，我们将不再为 Ubuntu 18.04 提供 Linux 软件包。

为极狐GitLab 17.0 及更高版本做好准备：

1. 将运行极狐GitLab 实例的服务器从 Ubuntu 18.04 迁移到 Ubuntu 20.04 或 Ubuntu 22.04。
1. 使用适用于您现在所用 Ubuntu 版本的 Linux 软件包升级您的极狐GitLab 实例。

<a id="list-repository-directories-rake-task"></a>

### 列出代码仓库目录的 Rake 任务

- 在极狐GitLab 16.7 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384361)。

`gitlab-rake gitlab:list_repos` Rake 任务无法正常工作，并将在极狐GitLab 17.0 中移除。
如果您正在迁移极狐GitLab，请改用[备份和恢复](https://gitlab.cn/docs/jh/administration/operations/moving_repositories/#recommended-approach-in-all-cases)。

<a id="maintainer-role-providing-the-ability-to-change-package-settings-using-graphql-api"></a>

### 维护者角色通过 GraphQL API 更改软件包设置的能力

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/370471)。

具有维护者角色的用户通过 GraphQL API 更改群组的**软件包和镜像仓库**设置的能力在极狐GitLab 15.8 中弃用，并将在极狐GitLab 17.0 中移除。这些设置包括：

- [允许或阻止重复软件包上传](https://gitlab.cn/docs/jh/user/packages/maven_repository/#do-not-allow-duplicate-maven-packages)。
- [软件包请求转发](https://gitlab.cn/docs/jh/user/packages/maven_repository/#request-forwarding-to-maven-central)。
- [为依赖代理启用生命周期规则](https://gitlab.cn/docs/jh/user/packages/dependency_proxy/reduce_dependency_proxy_storage/)。

在极狐GitLab 17.0 及更高版本中，您必须拥有群组的所有者角色，才能使用极狐GitLab UI 或 GraphQL API 更改群组的**软件包和镜像仓库**设置。

<a id="maven-versions-below-388-support-in-dependency-scanning-and-license-scanning"></a>

### 依赖扫描和许可证扫描中对 3.8.8 以下 Maven 版本的支持

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438772)。

极狐GitLab 17.0 放弃了对 3.8.8 以下 Maven 版本的依赖扫描和许可证扫描支持。

建议用户升级到 3.8.8 或更高版本。

<a id="min-concurrency-and-max-concurrency-in-sidekiq-options"></a>

### Sidekiq 选项中的最小并发和最大并发

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439687)。

对于 Linux 软件包（Omnibus）安装，[`sidekiq['min_concurrency']` 和 `sidekiq['max_concurrency']`](https://gitlab.cn/docs/jh/administration/sidekiq/extra_sidekiq_processes/#manage-thread-counts-explicitly) 设置在极狐GitLab 16.9 中弃用，并将在极狐GitLab 17.0 中移除。

您可以在极狐GitLab 16.9 及更高版本中使用 `sidekiq['concurrency']` 在每个进程中显式设置线程数。

上述变更仅适用于 Linux 软件包（Omnibus）安装。

对于 GitLab Helm chart 安装，将 `SIDEKIQ_CONCURRENCY_MIN` 和/或 `SIDEKIQ_CONCURRENCY_MAX` 作为 `extraEnv` 传递给 `sidekiq` 子 chart 的做法在极狐GitLab 16.10 中弃用，并将在极狐GitLab 17.0 中移除。

您可以使用 `concurrency` 选项在每个进程中显式设置线程数。

<a id="offset-pagination-for-users-rest-api-endpoint-is-deprecated"></a>

### `/users` REST API 端点的偏移分页已弃用

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/426547)。

`/users` REST API 的偏移分页在极狐GitLab 16.5 中弃用，并将在极狐GitLab 17.0 中移除。请改用[键集分页](https://gitlab.cn/docs/jh/api/rest/#keyset-based-pagination)。

<a id="old-versions-of-json-web-tokens-are-deprecated"></a>

### 旧版 JSON Web 令牌已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/366798)。

支持 OIDC 的 [ID 令牌](https://gitlab.cn/docs/jh/ci/secrets/id_token_authentication/)在极狐GitLab 15.7 中引入。这些令牌比旧的 JSON Web 令牌 (JWT) 更具可配置性，符合 OIDC 标准，并且仅在显式配置了 ID 令牌的 CI/CD 作业中可用。
ID 令牌比暴露在每个作业中的旧 `CI_JOB_JWT*` JSON Web 令牌更安全，因此这些旧 JSON Web 令牌已弃用：

- `CI_JOB_JWT`
- `CI_JOB_JWT_V1`
- `CI_JOB_JWT_V2`

为准备此变更，请将您的流水线配置为使用 [ID 令牌](https://gitlab.cn/docs/jh/ci/yaml/#id_tokens)而不是已弃用的令牌。为符合 OIDC 标准，`iss` 声明现在使用完全限定域名，例如 `https://example.com`，此前随 `CI_JOB_JWT_V2` 令牌引入。

在极狐GitLab 15.9 到 15.11 中，您可以[启用**限制 JSON Web 令牌 (JWT) 访问**](https://gitlab.cn/docs/jh/ci/secrets/id_token_authentication/#enable-automatic-id-token-authentication)设置，该设置可防止旧令牌暴露给任何作业，并为 [`secrets:vault` 关键字启用 ID 令牌身份验证](https://gitlab.cn/docs/jh/ci/secrets/id_token_authentication/#configure-automatic-id-token-authentication)。

在极狐GitLab 16.0 及更高版本中：

- 此设置将被移除。
- 使用 `id_tokens` 关键字的 CI/CD 作业可以将 ID 令牌与 `secrets:vault` 一起使用，并且不会有任何 `CI_JOB_JWT*` 令牌可用。
- 不使用 `id_tokens` 关键字的作业将继续拥有 `CI_JOB_JWT*` 令牌，直到极狐GitLab 17.0。

在极狐GitLab 17.0 中，已弃用的令牌将被完全移除，并且不再在 CI/CD 作业中可用。

<a id="omniauth-facebook-is-deprecated"></a>

### OmniAuth Facebook 已弃用

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416000)。

OmniAuth Facebook 支持将在极狐GitLab 17.0 中移除。最后一次 gem 发布是在 2021 年，目前无人维护。当前使用率低于 0.1%。如果您使用 OmniAuth Facebook，请在支持移除之前切换到[受支持的提供商](https://gitlab.cn/docs/jh/integration/omniauth/#supported-providers)。

<a id="package-pipelines-in-api-payload-is-paginated"></a>

### API 负载中的软件包流水线已分页

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/289956)。

对 `/api/v4/projects/:id/packages`的 API 请求会返回软件包的分页结果。每个软件包在此响应中列出其所有流水线。这是一个性能问题，因为一个软件包可能有数百或数千个关联的流水线。

在里程碑 17.0 中，我们将从 API 响应中移除 `pipelines` 属性。

<a id="postgresql-13-no-longer-supported"></a>

### 不再支持 PostgreSQL 13

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/9065)。

极狐GitLab 遵循 [PostgreSQL 的年度升级节奏](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)。

对 PostgreSQL 13 的支持计划在极狐GitLab 17.0 中移除。
在极狐GitLab 17.0 中，PostgreSQL 14 成为最低要求的 PostgreSQL 版本。

PostgreSQL 13 将在整个极狐GitLab 16 发布周期内受支持。
对于希望在极狐GitLab 17.0 之前升级的实例，PostgreSQL 14 也将受支持。如果您运行的是使用 Omnibus Linux 软件包安装的单个 PostgreSQL 实例，则可能会在 16.11 中尝试自动升级。
请确保您有足够的磁盘空间来容纳升级。有关更多信息，请参阅 [Omnibus 数据库文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="proxy-based-dast-deprecated"></a>

### 基于代理的 DAST 已弃用

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430966)。

从极狐GitLab 17.0 开始，将不再支持基于代理的 DAST。请迁移到基于浏览器的 DAST，以继续通过动态分析来分析您的项目中的安全发现。**入侵和攻击模拟**是一项基于代理的 DAST 构建的孵化功能，也包含在此弃用中，并且在 17.0 之后将不再受支持。

<a id="queue-selector-for-running-sidekiq-is-deprecated"></a>

### 用于运行 Sidekiq 的队列选择器已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中停止支持
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390787)。

使用[队列选择器](https://gitlab.cn/docs/jh/administration/sidekiq/processing_specific_job_classes/#queue-selectors)（让多个进程监听一组队列）和[否定设置](https://gitlab.cn/docs/jh/administration/sidekiq/processing_specific_job_classes/#negate-settings)运行 Sidekiq 的做法已弃用，并将在 17.0 中完全移除。

您可以从队列选择器迁移到[在所有进程中监听所有队列](https://gitlab.cn/docs/jh/administration/sidekiq/extra_sidekiq_processes/#start-multiple-processes)。例如，如果 Sidekiq 当前使用 4 个进程运行（由 `/etc/gitlab/gitlab.rb`中 `sidekiq['queue_groups']` 的 4 个元素表示），并使用队列选择器（`sidekiq['queue_selector'] = true`），您可以将 Sidekiq 更改为在所有 4 个进程中监听所有队列，例如 `sidekiq['queue_groups'] = ['*'] * 4`。我们的[参考架构](https://gitlab.cn/docs/jh/administration/reference_architectures/5k_users/#configure-sidekiq)中也推荐了这种方法。请注意，Sidekiq 实际上可以运行与机器中 CPU 数量一样多的进程。

虽然上述方法推荐用于大多数实例，但 Sidekiq 也可以使用[路由规则](https://gitlab.cn/docs/jh/administration/sidekiq/processing_specific_job_classes/#routing-rules)运行，GitLab.com 上也在使用这种方法。您可以遵循[从队列选择器迁移到路由规则的指南](https://gitlab.cn/docs/jh/administration/sidekiq/processing_specific_job_classes/#migrating-from-queue-selectors-to-routing-rules)。在迁移过程中需要小心，以避免完全丢失作业。

<a id="removal-of-tags-from-small-gitlabcom-runners-on-linux"></a>

### 从 Linux 上的小型 GitLab.com Runner 移除标签

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30829)。

由于历史原因，小型 Linux GitLab.com Runner 附加了许多标签，因为它们被用作标记。我们希望简化标签，只使用 `saas-linux-small-amd64`，并在所有 GitLab.com Runner 中保持一致。

我们正在弃用以下标签：`docker`、`east-c`、`gce`、`git-annex`、`linux`、`mongo`、`mysql`、`postgres`、`ruby`、`shared`。

有关更多信息，请参阅[从 Linux 上的小型 SaaS Runner 移除标签](https://about.gitlab.com/blog/removing-tags-from-small-saas-runner-on-linux/)。

<a id="required-pipeline-configuration-is-deprecated"></a>

### 必需的流水线配置已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389467)。

必需的流水线配置将在极狐GitLab 17.0 中移除。这会影响极狐GitLab 私有化部署旗舰版上的用户。

您应该用以下任一方式替换必需的流水线配置：

- [限定于合规框架的安全策略](https://gitlab.cn/docs/jh/user/application_security/policies/scan_execution_policies/#security-policy-scopes)，目前为实验性功能。
- [合规流水线](https://gitlab.cn/docs/jh/user/group/compliance_pipelines/)，现已可用。

我们推荐这些替代解决方案，因为它们提供了更大的灵活性，允许将必需的流水线分配给特定的合规框架标记。

合规流水线将在未来弃用并迁移到安全策略。有关更多信息，请参阅[迁移和弃用史诗](https://gitlab.com/groups/gitlab-org/-/epics/11275)。

<a id="sast-analyzer-coverage-changing-in-gitlab-170"></a>

### SAST 分析器覆盖范围在极狐GitLab 17.0 中发生变化

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412060)。

我们正在减少极狐GitLab SAST 默认使用的受支持[分析器](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/)数量。
这是我们长期战略的一部分，旨在为不同编程语言提供更快、更一致的用户体验。

在极狐GitLab 17.0 中，我们将：

1. 从 [SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)中移除一组特定语言的分析器，并用[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)中的[GitLab 支持的检测规则](https://gitlab.cn/docs/jh/user/application_security/sast/rules/)替换其覆盖范围。以下分析器现已弃用，并将在极狐GitLab 17.0 中停止支持：
   1. [Brakeman](https://gitlab.com/gitlab-org/security-products/analyzers/brakeman)（Ruby、Ruby on Rails）
   1. [Flawfinder](https://gitlab.com/gitlab-org/security-products/analyzers/flawfinder)（C、C++）
   1. [MobSF](https://gitlab.com/gitlab-org/security-products/analyzers/mobsf)（Android、iOS）
   1. [NodeJS Scan](https://gitlab.com/gitlab-org/security-products/analyzers/nodejs-scan)（Node.js）
   1. [PHPCS Security Audit](https://gitlab.com/gitlab-org/security-products/analyzers/phpcs-security-audit)（PHP）
1. 更改 [SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)，停止为 Kotlin 和 Scala 代码运行[基于 SpotBugs 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs)。这些语言将改用[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)中的[GitLab 支持的检测规则](https://gitlab.cn/docs/jh/user/application_security/sast/rules/)进行扫描。

立即生效，已弃用的分析器将仅接收安全更新；不保证其他常规改进或更新。在这些分析器于极狐GitLab 17.0 中停止支持后，将不再提供进一步更新。但是，我们不会删除之前为这些分析器发布的容器镜像，也不会移除通过自定义 CI/CD 流水线作业定义运行它们的能力。

漏洞管理系统将更新大多数现有发现，使其与新检测规则匹配。
未迁移到新分析器的发现将被[自动解决](https://gitlab.cn/docs/jh/user/application_security/sast/#automatic-vulnerability-resolution)。
有关更多详细信息，请参阅[漏洞转换文档](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/#vulnerability-translation)。

如果您对已移除的分析器应用了自定义设置，或者您当前在流水线中禁用了基于 Semgrep 的分析器，则必须按照[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412060#action-required)中的详细说明采取行动。

<a id="scan-execution-policies-using-_excluded_analyzers-variable-override-project-variables"></a>

### 使用 `_EXCLUDED_ANALYZERS` 变量的扫描执行策略会覆盖项目变量

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424513)。

在交付并验证[以最高优先级强制执行 SEP 变量](https://gitlab.com/gitlab-org/gitlab/-/issues/424028)之后，我们发现了一个意外行为：允许用户在流水线配置中设置 `_EXCLUDED_PATHS`，并阻止他们在策略和流水线配置中设置 `_EXCLUDED_ANALYZERS`。

为确保正确强制执行扫描执行变量，当使用极狐GitLab 扫描操作为扫描执行策略指定 `_EXCLUDED_ANALYZERS` 或 `_EXCLUDED_PATHS` 变量时，该变量现在将覆盖为排除的分析器定义的任何项目变量。

用户可以在 17.0 之前启用功能标志来强制执行此行为。在 17.0 中，对于使用了 `_EXCLUDED_ANALYZERS`/`_EXCLUDED_PATHS` 变量且定义了带有该变量的扫描执行策略的项目，默认情况下将被覆盖。

<a id="secure-analyzers-major-version-update"></a>

### Secure 分析器主要版本更新

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438123)。

Secure 阶段将随极狐GitLab 17.0 版本同步提升其分析器的主要版本。

如果您未使用默认包含的模板，或者已固定分析器版本，则必须更新 CI/CD 作业定义，以移除固定的版本或更新到最新的主要版本。

极狐GitLab 16.0-16.11 的用户将继续正常接收分析器更新，直到极狐GitLab 17.0 发布，此后所有新修复的错误和发布的功能将仅在分析器的新主要版本中发布。

根据我们的维护策略，我们不会将错误和功能向后移植到已弃用的版本。如有需要，安全补丁将在最新的 3 个次要版本内向后移植。

具体来说，以下分析器正在弃用，并且在极狐GitLab 17.0 发布后将不再更新：

- 容器扫描：版本 6
- 依赖扫描：版本 4
- DAST：版本 4
- DAST API：版本 3
- Fuzz API：版本 3
- IaC 扫描：版本 4
- 密钥检测：版本 5
- 静态应用安全测试 (SAST)：[所有分析器](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/)的版本 4
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
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424513)。

在[支持扫描结果策略的附加筛选器](https://gitlab.com/groups/gitlab-org/-/epics/6826#note_1341377224)中，我们将 `newly_detected` 字段拆分为两个选项：`new_needs_triage` 和 `new_dismissed`。通过在安全策略 YAML 中包含这两个选项，您将获得与原始 `newly_detected` 字段相同的结果。但是，您现在可以仅使用 `new_needs_triage` 来缩小筛选范围，以忽略已忽略的发现。
根据[史诗 10203](https://gitlab.com/groups/gitlab-org/-/epics/10203#note_1545826313)中的讨论，我们将 `match_on_inclusion` 字段的名称更改为 `match_on_inclusion_license`，以使 YAML 定义更清晰。

<a id="security-policy-field-newly_detected-is-deprecated"></a>

### 安全策略字段 `newly_detected` 已弃用

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422414)。

在[支持扫描结果策略的附加筛选器](https://gitlab.com/groups/gitlab-org/-/epics/6826#note_1341377224)中，我们将 `newly_detected` 字段拆分为两个选项：`new_needs_triage` 和 `new_dismissed`。通过在安全策略 YAML 中包含这两个选项，您将获得与原始 `newly_detected` 字段相同的结果。但是，您现在可以仅使用 `new_needs_triage` 来缩小筛选范围，以忽略已忽略的发现。

<a id="support-for-self-hosted-sentry-versions-2141-and-earlier"></a>

### 对自托管 Sentry 21.4.1 及更早版本的支持

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435791)。

对自托管 Sentry 21.4.1 及更早版本的支持已弃用，并将在极狐GitLab 17.0 中移除。

如果您的自托管 Sentry 版本为 21.4.1 或更早版本，则在升级到极狐GitLab 17.0 或更高版本后，您可能无法从极狐GitLab 实例收集错误。
要继续将错误从极狐GitLab 实例发送到您的 Sentry 实例，请将 Sentry 升级到 21.5.0 或更高版本。有关更多信息，请参阅 [Sentry 文档](https://develop.sentry.dev/self-hosted/releases/)。

> [!note]
> 已弃用的支持适用于面向管理员的
> [极狐GitLab 实例错误跟踪功能](https://gitlab.cn/docs/omnibus/settings/configuration/#error-reporting-and-logging-with-sentry)。
> 已弃用的支持与面向开发者自己部署的应用程序的
> [极狐GitLab 错误跟踪](https://gitlab.cn/docs/jh/operations/error_tracking/#sentry-error-tracking)无关。

<a id="support-for-setting-custom-schema-for-backup-is-deprecated"></a>

### 为备份设置自定义 schema 的支持已弃用

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435210)。

您可以通过在 Linux 软件包安装的 `/etc/gitlab/gitlab.rb`中设置 `gitlab_rails['backup_pg_schema'] = '<schema_name>'`，或者通过编辑自编译安装的 `config/gitlab.yml`，将极狐GitLab 配置为使用自定义 schema 进行备份。

虽然该配置设置可用，但它没有任何效果，也没有达到其预期目的。此配置设置将在极狐GitLab 17.0 中移除。

<a id="the-github-importer-rake-task"></a>

### GitHub 导入器 Rake 任务

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428225)。

在极狐GitLab 16.6 中，GitHub 导入器 Rake 任务已弃用。该 Rake 任务缺少 API 支持的多个功能，并且未得到积极维护。

在极狐GitLab 17.0 中，该 Rake 任务将被移除。

相反，可以使用 [API](https://gitlab.cn/docs/jh/api/import/#import-repository-from-github) 或 [UI](https://gitlab.cn/docs/jh/user/project/import/github/) 导入 GitHub 代码仓库。

<a id="the-visual-reviews-tool-is-deprecated"></a>

### Visual Reviews 工具已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387751)。

由于客户使用量和功能有限，用于 Review Apps 的 Visual Reviews 功能已弃用并将被移除。没有计划替代方案，用户应在极狐GitLab 17.0 之前停止使用 Visual Reviews。

<a id="the-gitlab-runner-exec-command-is-deprecated"></a>

### `gitlab-runner exec` 命令已弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385235)。

`gitlab-runner exec` 命令已弃用，并将在 16.0 中从极狐GitLab Runner 完全移除。`gitlab-runner exec` 功能最初是为了提供在本地系统上验证极狐GitLab CI 流水线的能力，而无需将更新提交到极狐GitLab 实例。然而，随着极狐GitLab CI 的持续发展，将所有极狐GitLab CI 功能复制到 `gitlab-runner exec`中已不再可行。流水线语法和验证[模拟](https://gitlab.cn/docs/jh/ci/pipeline_editor/#simulate-a-cicd-pipeline)可在极狐GitLab 流水线编辑器中使用。

<a id="the-pull-based-deployment-features-of-the-gitlab-agent-for-kubernetes-is-deprecated"></a>

### 极狐GitLab Kubernetes Agent 的基于拉取的部署功能已弃用

- 在极狐GitLab 16.2 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/406545)。

我们正在弃用极狐GitLab Kubernetes Agent 的内置基于拉取的部署功能，转而支持 Flux 及相关集成。

极狐GitLab Kubernetes Agent **并未弃用**。此变更仅影响 Agent 的基于拉取的功能。所有其他功能将保持不变，极狐GitLab 将继续支持极狐GitLab Kubernetes Agent。

如果您使用 Agent 进行基于拉取的部署，则应[迁移到 Flux](https://gitlab.cn/docs/jh/user/clusters/agent/gitops/agent/#migrate-to-flux)。由于 Flux 是一个成熟的 CNCF GitOps 项目，我们决定[在 2023 年 2 月将 Flux 与极狐GitLab 集成](https://about.gitlab.com/blog/why-did-we-choose-to-integrate-fluxcd-with-gitlab/)。

<a id="twitter-omniauth-login-option-is-deprecated-from-gitlab-self-managed"></a>

### Twitter OmniAuth 登录选项从极狐GitLab 私有化部署中弃用

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-com/Product/-/issues/11417)。

由于使用率低且缺乏 gem 支持，Twitter OAuth 1.0a OmniAuth 已弃用，并将在极狐GitLab 17.0 中为极狐GitLab 私有化部署移除。请改用[其他受支持的 OmniAuth 提供商](https://gitlab.cn/docs/jh/integration/omniauth/#supported-providers)。

<a id="unified-approval-rules-are-deprecated"></a>

### 统一审批规则已弃用

- 在极狐GitLab 16.1 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/9662)。

统一审批规则已弃用，取而代之的是多重审批规则，后者提供了更大的灵活性。您可能无法在不产生重大变更的情况下将统一审批规则迁移到多重审批规则。为帮助您手动迁移，我们引入了迁移文档。

如果您在统一审批规则被移除之前未手动迁移，极狐GitLab 将自动迁移您的设置。由于多重审批规则允许对审批规则进行更精细的设置，如果您将迁移交给极狐GitLab，自动迁移最终可能会产生比您预期更严格的规则。如果您遇到需要比预期更多审批的问题，请检查您的迁移规则。

在极狐GitLab 15.11 中，统一审批规则的 UI 支持已移除。您仍然可以通过 API 访问统一审批规则。

<a id="upgrading-the-operating-system-version-of-gitlabcom-runners-on-linux"></a>

### 升级 Linux 上 GitLab.com Runner 的操作系统版本

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/ci-cd/shared-runners/infrastructure/-/issues/60)。

GitLab 正在升级用于为 Linux 上的 GitLab.com Runner 执行作业的临时虚拟机的容器优化操作系统 (COS)。该 COS 升级包括将 Docker Engine 从版本 19.03.15 升级到版本 23.0.5，这引入了一个已知的兼容性问题。

20.10 版本之前的 Docker-in-Docker 或早于 v1.9.0 的 Kaniko 镜像将无法检测到容器运行时并失败。

有关更多信息，请参阅[升级 Linux 上 SaaS Runner 的操作系统版本](https://about.gitlab.com/blog/updating-the-os-version-of-saas-runners-on-linux/)。

<a id="vulnerability-confidence-field"></a>

### 漏洞置信度字段

- 在极狐GitLab 15.4 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/372332)。

在极狐GitLab 15.3 中，[版本 15 以下的安全报告 schema 已弃用](https://gitlab.cn/docs/jh/update/deprecations/#security-report-schemas-version-14xx)。
漏洞发现上的 `confidence` 属性仅存在于 `15-0-0` 之前的 schema 版本中，因此实际上已弃用，因为极狐GitLab 15.4 支持 schema 版本 `15-0-0`。为了保持报告与我们的公共 API 之间的一致性，我们的 GraphQL API 中任何与漏洞相关的组件上的 `confidence` 属性现已弃用，并将在 17.0 中移除。

<a id="after_script-keyword-will-run-for-canceled-jobs"></a>

### `after_script` 关键字将为已取消的作业运行

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437789)。

[`after_script`](https://gitlab.cn/docs/jh/ci/yaml/#after_script) CI/CD 关键字用于在作业的主要 `script` 部分之后运行附加命令。这通常用于清理作业使用的环境或其他资源。对于许多用户来说，如果作业被取消，`after_script` 命令不会运行这一事实是出乎意料且不受欢迎的。在 17.0 中，该关键字将更新为在作业取消后也运行命令。请确保使用 `after_script` 关键字的 CI/CD 配置也能够处理为已取消的作业运行的情况。

<a id="dependency_files-is-deprecated"></a>

### `dependency_files` 已弃用

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/396376)。

目前在极狐GitLab 中，项目的依赖项列表是使用依赖扫描报告中 `dependency_files`的内容生成的。但是，为了与群组依赖项列表保持一致，从极狐GitLab 17.0 开始，项目的依赖项列表将使用存储在 PostgreSQL 数据库中的 CycloneDX SBOM 报告产物。因此，依赖扫描报告 schema 的 `dependency_files` 属性已弃用，并将在 17.0 中移除。

作为此弃用的一部分，[`dependency_path`](https://gitlab.cn/docs/jh/user/application_security/dependency_list/#dependency-paths) 也将在 17.0 中弃用并移除。极狐GitLab 将继续推进[使用 CycloneDX 规范实现依赖关系图](https://gitlab.com/gitlab-org/gitlab/-/issues/441118)，以提供类似的信息。

此外，容器扫描 CI 作业[将不再生成依赖扫描报告](https://gitlab.com/gitlab-org/gitlab/-/issues/439782)来提供操作系统组件列表，因为这已被 CycloneDX SBOM 报告取代。容器扫描的 `CS_DISABLE_DEPENDENCY_LIST` 环境变量不再使用，也将在 17.0 中移除。

<a id="metric-filter-and-value-field-for-dora-api"></a>

### DORA API 的 `metric` 筛选器和 `value` 字段

- 在极狐GitLab 16.8 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393172)。

现在可以使用新的 metrics 字段同时查询多个 DORA 指标。GraphQL DORA API 的 `metric` 筛选器和 `value` 字段将在极狐GitLab 17.0 中移除。

<a id="omniauth-azure-oauth2-gem-is-deprecated"></a>

### `omniauth-azure-oauth2` gem 已弃用

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408989)。

极狐GitLab 用户可以使用 `omniauth-azure-oauth2` gem 进行极狐GitLab 身份验证。在 17.0 中，此 gem 将被 `omniauth_openid_connect` gem 取代。新 gem 包含与旧 gem 相同的所有功能，但还具有上游维护，并且在安全性和集中维护方面更优。

此变更要求用户在迁移时重新连接到 OAuth 2.0 提供商。为避免中断，请在 17.0 之前的任何时间[将 `omniauth_openid_connect` 添加为新提供商](https://gitlab.cn/docs/jh/administration/auth/oidc/#configure-multiple-openid-connect-providers)。用户将看到一个新的登录按钮，并且必须手动重新连接其凭据。如果您未在 17.0 之前实现 `omniauth_openid_connect` gem，用户将无法再使用 Azure 登录按钮登录，并且必须使用其用户名和密码登录，直到管理员实现正确的 gem。

<a id="omnibus_gitconfig-configuration-item-is-deprecated"></a>

### `omnibus_gitconfig` 配置项已弃用

- 在极狐GitLab 16.10 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitaly/-/issues/5132)。

`omnibus_gitconfig['system']` 配置项已弃用。如果您使用
`omnibus_gitconfig['system']` 为 Gitaly 设置自定义 Git 配置，则必须在升级到极狐GitLab 17.0 之前，通过 `gitaly[:configuration][:git][:config]` 下的 Gitaly 配置直接配置 Git。

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

配置键的格式必须与通过 CLI 标志 `git -c <configuration>` 传递给 `git`的内容一致。

如果您在将现有键转换为预期格式时遇到问题，请参阅 Linux 软件包生成的 Gitaly 配置文件中格式正确的现有键。默认情况下，该配置文件位于
`/var/opt/gitlab/gitaly/config.toml`。

以下由 Gitaly 管理的配置选项应被移除。这些键无需迁移到
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
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8164)。

Linux 软件包为内置的 PostgreSQL exporter 提供了自定义查询，其中包括由 `postgres_exporter['per_table_stats']`
配置设置控制的 `per_table_stats` 查询。

PostgreSQL exporter 现在提供了 `stat_user_tables` 收集器，可提供相同的指标。如果您已启用 `postgres_exporter['per_table_stats']`，请改为启用 `postgres_exporter['flags']['collector.stat_user_tables']`。

<a id="projectfingerprint-graphql-field"></a>

### `projectFingerprint` GraphQL 字段

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/343475)。

漏洞发现的 [`project_fingerprint`](https://gitlab.com/groups/gitlab-org/-/epics/2791) 属性正在弃用，取而代之的是 `uuid` 属性。通过使用 UUIDv5 值来标识发现，我们可以轻松地将任何相关实体与发现关联起来。`project_fingerprint` 属性不再用于跟踪发现，并将在极狐GitLab 17.0 中移除。从 16.1 开始，`project_fingerprint`的输出返回与 `uuid` 字段相同的值。

<a id="repository_download_operation-audit-event-type-for-public-projects"></a>

### 公共项目的 `repository_download_operation` 审计事件类型

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383218)。

审计事件类型 `repository_download_operation` 目前会为所有项目下载（包括公共项目和私有项目）保存到数据库。对于公共项目，此审计事件对于审计目的来说并不是最有用的，因为它可以由未认证用户触发。

从极狐GitLab 17.0 开始，`repository_download_operation` 审计事件类型将仅对私有或内部项目触发。我们将为公共项目下载添加一个名为
`public_repository_download_operation`的新审计事件类型。此新审计事件类型将仅用于流式传输。

<a id="npm-package-uploads-now-occur-asynchronously"></a>

### npm 软件包上传现在异步进行

- 在极狐GitLab 16.9 中宣布
- 在极狐GitLab 17.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433009)。

极狐GitLab 软件包仓库支持 npm 和 Yarn。当您上传 npm 或 Yarn 软件包时，上传是同步的。但是，同步上传存在已知问题。例如，极狐GitLab 不支持诸如 [overrides](https://gitlab.com/gitlab-org/gitlab/-/issues/432876) 之类的功能。

从 17.0 开始，npm 和 Yarn 软件包将异步上传。这是一项重大变更，因为您可能有期望软件包一经发布即可用的流水线。

作为变通方法，您应使用[软件包 API](https://gitlab.cn/docs/jh/api/packages/) 来检查软件包。

<a id="gitlab-169"></a>

## 极狐GitLab 16.9

<a id="deprecation-of-lfs_check-feature-flag"></a>

### `lfs_check` 功能标志的弃用

- 在极狐GitLab 16.6 中宣布
- 在极狐GitLab 16.9 中移除
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/233550)。

在极狐GitLab 16.9 中，我们将移除 `lfs_check` 功能标志。此功能标志[于 4 年前引入](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/60588)，用于控制是否启用 LFS 完整性检查。该功能标志默认启用，但一些客户遇到了 LFS 完整性检查的性能问题，并明确禁用了它。

在[大幅提升了 LFS 完整性检查的性能](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/61355)之后，我们已准备好移除该功能标志。移除该标志后，该功能将在当前已禁用的任何环境中自动开启。

如果您的环境禁用了此功能标志，并且您担心性能问题，请在 16.9 中移除它之前启用它并监控性能。如果在启用后遇到任何性能问题，请在[此反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/233550)中告知我们。

<a id="gitlab-168"></a>

## 极狐GitLab 16.8

<a id="opensuse-leap-154-packages"></a>

### openSUSE Leap 15.4 软件包

- 在极狐GitLab 16.5 中宣布
- 在极狐GitLab 16.8 中移除
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8212)。

openSUSE Leap 15.4 的支持和安全更新将于 [2023 年 11 月结束](https://en.opensuse.org/Lifetime#openSUSE_Leap)。

极狐GitLab 15.4 为 openSUSE Leap 15.5 提供了软件包。极狐GitLab 15.8 及更高版本将不再为 openSUSE Leap 15.4 提供软件包。

要为极狐GitLab 15.8 及更高版本做好准备，您应该：

1. 将实例从 openSUSE Leap 15.4 迁移到 openSUSE Leap 15.5。
1. 从 openSUSE Leap 15.4 的极狐GitLab 提供的软件包切换到 openSUSE Leap 15.5 的极狐GitLab 提供的软件包。

<a id="gitlab-167"></a>

## 极狐GitLab 16.7

<a id="shimo-integration"></a>

### Shimo 集成

- 在 GitLab 15.7 中宣布
- 在 GitLab 16.7 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/377824)。

上游的 **Shimo Workspace 集成**已弃用，
并将移至极狐GitLab 代码库。

<a id="user_email_lookup_limit-api-field"></a>

### `user_email_lookup_limit` API 字段

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 16.7 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

`user_email_lookup_limit` [API 字段](https://gitlab.cn/docs/jh/api/settings/)在极狐GitLab 14.9 中弃用，并在极狐GitLab 16.7 中移除。在该功能移除之前，`user_email_lookup_limit` 是 `search_rate_limit`的别名，现有工作流仍然有效。

任何用于更改 `user_email_lookup_limit` 速率限制的 API 调用都必须改用 `search_rate_limit`。

<a id="gitlab-166"></a>

## 极狐GitLab 16.6

<a id="job-token-allowlist-covers-public-and-internal-projects"></a>

### 作业令牌允许名单涵盖公共和内部项目

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.6 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420678)。

从 16.6 开始，当启用[**限制对此项目的访问**](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#add-a-group-or-project-to-the-job-token-allowlist)时，**公共**或**内部**项目将不再授权来自不在项目允许名单上的项目的作业令牌请求。

如果您的[公共或内部](https://gitlab.cn/docs/jh/user/public_access/#change-project-visibility)项目启用了**限制对此项目的访问**设置，则必须将任何发出作业令牌请求的项目添加到您项目的允许名单中，以继续获得授权。

<a id="gitlab-165"></a>

## 极狐GitLab 16.5

<a id="adding-non-ldap-synced-members-to-a-locked-ldap-group-is-deprecated"></a>

### 向锁定的 LDAP 群组添加非 LDAP 同步成员已弃用

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.5 中移除
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/213311)。

启用 `ldap_settings_unlock_groups_by_owners` 功能标志允许将非 LDAP 同步用户添加到锁定的 LDAP 群组。此[功能](https://gitlab.com/gitlab-org/gitlab/-/issues/1793)一直默认禁用，并受功能标志控制。我们正在移除此功能，以保持与 SAML 集成的一致性，并且因为允许非同步群组成员违背了使用目录服务的“单一事实来源”原则。移除此功能后，任何未与 LDAP 同步的 LDAP 群组成员都将失去对该群组的访问权限。

<a id="geo-housekeeping-rake-tasks"></a>

### Geo：Housekeeping Rake 任务

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.5 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416384)。

作为将复制和验证迁移到
[Geo 自助服务框架（SSF）](https://gitlab.cn/docs/jh/development/geo/framework/)的一部分，
项目代码仓库的传统复制已被
[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/130565)。
因此，以下依赖传统代码的 Rake 任务也已被移除。这些 Rake 任务所调用的工作现在会定期或基于触发事件自动执行。

| Rake 任务 | 替代方案 |
| --------- | ----------- |
| `geo:git:housekeeping:full_repack` | [已移至 UI](https://gitlab.cn/docs/jh/administration/housekeeping/#heuristical-housekeeping)。SSF 中没有等效的 Rake 任务。 |
| `geo:git:housekeeping:gc` | 对于新代码仓库始终执行，之后在需要时执行。SSF 中没有等效的 Rake 任务。 |
| `geo:git:housekeeping:incremental_repack` | 在需要时执行。SSF 中没有等效的 Rake 任务。 |
| `geo:run_orphaned_project_registry_cleaner` | 由注册表[一致性工作进程](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/workers/geo/secondary/registry_consistency_worker.rb)定期执行，该工作进程会移除孤立的注册表。SSF 中没有等效的 Rake 任务。 |
| `geo:verification:repository:reset` | 已移至 UI。SSF 中没有等效的 Rake 任务。 |
| `geo:verification:wiki:reset` | 已移至 UI。SSF 中没有等效的 Rake 任务。 |

<a id="gitlab-163"></a>

## 极狐GitLab 16.3

<a id="bundled-grafana-deprecated-and-disabled"></a>

### 内置 Grafana 已弃用并禁用

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7772)。

Omnibus GitLab 内置的 Grafana 版本已在 16.0 中
[弃用并禁用](https://gitlab.cn/docs/jh/administration/monitoring/performance/grafana_configuration/#deprecation-of-bundled-grafana)，
并将在 16.3 中移除。如果您正在使用内置的 Grafana，则必须迁移到以下任一方案：

- 另一个 Grafana 实现。有关更多信息，请参见
  [切换到新的 Grafana 实例](https://gitlab.cn/docs/jh/administration/monitoring/performance/grafana_configuration/#switch-to-new-grafana-instance)。
- 您选择的其他可观测性平台。

当前提供的 Grafana 版本已不再受支持。

在极狐GitLab 16.0 至 16.2 版本中，您仍然可以[重新启用内置的 Grafana](https://gitlab.cn/docs/jh/administration/monitoring/performance/grafana_configuration/#temporary-workaround)。
但是，从极狐GitLab 16.3 开始，启用内置的 Grafana 将不再有效。

<a id="rsa-key-size-limits"></a>

### RSA 密钥大小限制

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/11186)。

Go 1.20.7 及更高版本添加了一个 `maxRSAKeySize` 常量，将 RSA 密钥限制为最大 8192 位。因此，大于 8192 位的 RSA 密钥将不再适用于极狐GitLab。任何大于 8192 位的 RSA 密钥都必须以更小的大小重新生成。

您可能会注意到此问题，因为您的日志中包含类似 `tls: server sent certificate containing RSA key larger than 8192 bits`的错误。要测试密钥的长度，请使用以下命令：`openssl rsa -in <your-key-file> -text -noout | grep "Key:"`。

<a id="twitter-omniauth-login-option-is-removed-from-gitlabcom"></a>

### Twitter OmniAuth 登录选项已从 JihuLab.com 移除

- 在极狐GitLab 16.3 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-com/Product/-/issues/11417)。

由于使用率低、缺乏 gem 支持以及此功能缺少可用的登录选项，Twitter OAuth 1.0a OmniAuth 正在弃用，并将在极狐GitLab 16.3 中从 JihuLab.com 移除。如果您使用 Twitter 登录 JihuLab.com，则可以使用密码或其他[受支持的 OmniAuth 提供商](https://jihulab.com/users/sign_in)登录。

<a id="license-compliance-ci-template"></a>

### 许可证合规 CI 模板

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.3 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387561)。

**更新**：我们之前宣布将在极狐GitLab 16.0 中移除现有的许可证合规 CI/CD 模板。但是，由于 [CycloneDX 文件的许可证扫描](https://gitlab.cn/docs/jh/user/compliance/license_scanning_of_cyclonedx_files/)存在性能问题，我们将在 16.3 中执行此操作。

极狐GitLab [许可证合规](https://gitlab.cn/docs/jh/user/compliance/license_approval_policies/) CI/CD 模板现已弃用，并计划在极狐GitLab 16.3 版本中移除。

要继续使用极狐GitLab 进行许可证合规，请从您的 CI/CD 流水线中移除许可证合规模板，并添加依赖扫描模板。依赖扫描模板现在能够收集所需的许可证信息，因此不再需要运行单独的许可证合规作业。

在移除许可证合规 CI/CD 模板之前，请确认实例已升级到支持新许可证扫描方法的版本。

要快速大规模地开始使用依赖扫描器，您可以在群组级别设置扫描执行策略，以对群组中的所有项目强制执行基于 SBOM 的许可证扫描。然后，您可以从 CI/CD 配置中移除 `Jobs/License-Scanning.gitlab-ci.yml` 模板的引入。

如果您希望继续使用传统的许可证合规功能，可以通过将 `LICENSE_MANAGEMENT_VERSION CI` 变量设置为 `4` 来实现。此变量可以在项目、群组或实例级别设置。此配置更改将允许您继续使用现有版本的许可证合规，而无需采用新方法。

此传统分析器中的错误和漏洞将不再修复。

| CI 流水线引入 | 极狐GitLab <= 15.8 | 15.9 <= 极狐GitLab < 16.3 | 极狐GitLab >= 16.3 |
| ------------- | ------------- | ------------- | ------------- |
| 同时引入 DS 和 LS 模板 | 使用来自 LS 作业的许可证数据 | 使用来自 LS 作业的许可证数据 | 使用来自 DS 作业的许可证数据 |
| 引入 DS 模板但未引入 LS 模板 | 无许可证数据 | 使用来自 DS 作业的许可证数据 | 使用来自 DS 作业的许可证数据 |
| 引入 LS 模板但未引入 DS 模板 | 使用来自 LS 作业的许可证数据 | 使用来自 LS 作业的许可证数据 | 无许可证数据 |

<a id="gitlab-161"></a>

## 极狐GitLab 16.1

<a id="gitlab-runner-images-based-on-alpine-312-313-314"></a>

### 基于 Alpine 3.12、3.13、3.14 的极狐GitLab Runner 镜像

- 在极狐GitLab 15.11 中宣布
- 在极狐GitLab 16.1 中停止支持
- 在极狐GitLab 16.1 中移除
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29639)。

我们将停止发布基于以下已停止维护的 Alpine 版本的 runner 镜像：

- Alpine 3.12
- Alpine 3.13
- Alpine 3.14（于 2023-05-23 停止维护）

<a id="gitlab-160"></a>

## 极狐GitLab 16.0

<a id="auto-devops-no-longer-provisions-a-postgresql-database-by-default"></a>

### Auto DevOps 默认不再预配 PostgreSQL 数据库

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/343988)。

目前，Auto DevOps 默认预配集群内 PostgreSQL 数据库。
在极狐GitLab 16.0 中，数据库将仅为选择加入的用户预配。此变更支持需要更强大数据库管理的生产部署。

如果您希望 Auto DevOps 预配集群内数据库，请将 `POSTGRES_ENABLED` CI/CD 变量设置为 `true`。

<a id="azure-storage-driver-defaults-to-the-correct-root-prefix"></a>

### Azure 存储驱动默认使用正确的根前缀

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/container-registry/-/issues/854)。

容器镜像仓库的 Azure 存储驱动将 `//` 作为默认根目录写入。此默认根目录在 Azure UI 的某些位置显示为 `/<no-name>/`。我们一直保持此传统行为，以支持使用此存储驱动的旧部署。但是，当从其他存储驱动迁移到 Azure 时，此行为会隐藏您的所有数据，直到您通过设置 `trimlegacyrootprefix: true` 将存储驱动配置为构建不带额外前导斜杠的根路径。

存储驱动的新默认配置将设置 `trimlegacyrootprefix: true`，并且 `/` 将成为默认根目录。您可以在当前配置中添加 `trimlegacyrootprefix: false` 以避免任何中断。

此重大变更将在极狐GitLab 16.0 中发生。

<a id="bundled-grafana-helm-chart-is-deprecated"></a>

### 内置 Grafana Helm Chart 已弃用

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/4353)。

GitLab Helm Chart 内置的 Grafana Helm chart 已弃用，并将在 GitLab Helm Chart 7.0 版本（与极狐GitLab 16.0 一起发布）中移除。

内置的 Grafana Helm chart 是一项可选服务，可以开启以提供连接到 GitLab Helm Chart 的 Prometheus 指标的 Grafana UI。

GitLab Helm Chart 当前提供的 Grafana 版本已不再是受支持的 Grafana 版本。
如果您正在使用内置的 Grafana，则应切换到 [Grafana Labs 提供的更新 chart 版本](https://artifacthub.io/packages/helm/grafana/grafana)
或来自可信提供商的 Grafana Operator。

在您的新 Grafana 实例中，您可以[将极狐GitLab 提供的 Prometheus 配置为数据源](https://gitlab.cn/docs/jh/administration/monitoring/performance/grafana_configuration/#configure-grafana)
并[将 Grafana 连接到极狐GitLab UI](https://gitlab.cn/docs/jh/administration/monitoring/performance/grafana_configuration/#integrate-with-gitlab-ui)。

<a id="cas-omniauth-provider"></a>

### CAS OmniAuth 提供商

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369127)。

为极狐GitLab 提供 CAS OmniAuth 提供商的 `omniauth-cas3` gem 将在我们的下一个主要版本极狐GitLab 16.0 中移除。此 gem 的使用量非常少，而且缺乏上游维护，这阻碍了极狐GitLab
[升级到 OmniAuth 2.0](https://gitlab.com/gitlab-org/gitlab/-/issues/30073)。

<a id="cicd-jobs-will-fail-when-no-secret-is-returned-from-hashicorp-vault"></a>

### 当 HashiCorp Vault 未返回密钥时，CI/CD 作业将失败

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/353080)。

使用原生 HashiCorp Vault 集成时，如果 Vault 未返回密钥，CI/CD 作业将失败。在极狐GitLab 16.0 之前，请确保您的配置始终返回密钥，或更新您的流水线以处理此变更。

<a id="changing-mobsf-based-sast-analyzer-behavior-in-multi-module-android-projects"></a>

### 更改多模块 Android 项目中基于 MobSF 的 SAST 分析器行为

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408396)。

**更新**：我们之前宣布了基于 MobSF 的极狐GitLab SAST 分析器扫描多模块 Android 项目方式的变更。我们已取消该变更，无需采取任何行动。

我们没有更改要扫描的单个模块，而是[改进了多模块支持](https://gitlab.com/gitlab-org/security-products/analyzers/mobsf/-/merge_requests/73)。

<a id="changing-merge-request-approvals-with-the-approvals-api-endpoint"></a>

### 使用 `/approvals` API 端点更改合并请求审批

- 在极狐GitLab 14.0 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。

要更改合并请求所需的审批，您不应再使用 `/approvals` API 端点，该端点已在极狐GitLab 14.0 中弃用。

请改用 [`/approval_rules` 端点](https://gitlab.cn/docs/jh/api/merge_request_approvals/#merge-request-level-mr-approvals)来[创建](https://gitlab.cn/docs/jh/api/merge_request_approvals/#create-merge-request-level-rule)或[更新](https://gitlab.cn/docs/jh/api/merge_request_approvals/#update-merge-request-level-rule) 合并请求的审批规则。

<a id="conan-project-level-search-endpoint-returns-project-specific-results"></a>

### Conan 项目级搜索端点返回项目特定结果

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384455)。

您可以将极狐GitLab Conan 软件包仓库与[项目级](https://gitlab.cn/docs/jh/user/packages/conan_repository/#add-a-remote-for-your-project)或[实例级](https://gitlab.cn/docs/jh/user/packages/conan_repository/#add-a-remote-for-your-instance)端点一起使用。每个级别都支持 Conan 搜索命令。但是，项目级的搜索端点也会返回目标项目之外的软件包。

此非预期功能在极狐GitLab 15.8 中弃用，并将在极狐GitLab 16.0 中移除。项目级的搜索端点将仅返回目标项目的软件包。

<a id="configuration-fields-in-gitlab-runner-helm-chart"></a>

### 极狐GitLab Runner Helm Chart 中的配置字段

- 在极狐GitLab 15.6 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/379064)。

从极狐GitLab 13.6 开始，用户可以在极狐GitLab Runner Helm chart 中[指定任何 runner 配置](https://gitlab.cn/docs/runner/install/kubernetes/)。当我们实现此功能时，我们弃用了 GitLab Helm Chart 配置中特定于极狐GitLab Runner 的值。弃用的值将在极狐GitLab 16.0 中移除。

<a id="configuring-redis-config-file-paths-using-environment-variables-is-deprecated"></a>

### 使用环境变量配置 Redis 配置文件路径已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388255)。

您不能再使用诸如 `GITLAB_REDIS_CACHE_CONFIG_FILE` 或
`GITLAB_REDIS_QUEUES_CONFIG_FILE` 之类的环境变量来指定 Redis 配置文件位置。请改用默认的
配置文件位置，例如 `config/redis.cache.yml` 或
`config/redis.queues.yml`。

<a id="container-registry-pull-through-cache"></a>

### 容器镜像仓库拉取直通缓存

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/container-registry/-/issues/842)。

容器镜像仓库[拉取直通缓存](https://docs.docker.com/docker-hub/image-library/mirror/)在极狐GitLab 15.8 中弃用，并将在极狐GitLab 16.0 中移除。拉取直通缓存是上游 [Docker Distribution 项目](https://github.com/distribution/distribution)的一部分。但是，我们将移除拉取直通缓存，转而使用极狐GitLab 依赖代理，它允许您代理和缓存来自 Docker Hub 的容器镜像。移除拉取直通缓存也使我们能够在不牺牲功能的情况下移除上游客户端代码。

<a id="container-scanning-variables-that-reference-docker"></a>

### 引用 Docker 的容器扫描变量

- 在极狐GitLab 15.4 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/371840)。

所有变量名以 `DOCKER_` 为前缀的容器扫描变量均已弃用。这包括 `DOCKER_IMAGE`、`DOCKER_PASSWORD`、`DOCKER_USER` 和 `DOCKERFILE_PATH` 变量。对这些变量的支持将在极狐GitLab 16.0 版本中移除。请使用[新的变量名](https://gitlab.cn/docs/jh/user/application_security/container_scanning/#available-cicd-variables) `CS_IMAGE`、`CS_REGISTRY_PASSWORD`、`CS_REGISTRY_USER` 和 `CS_DOCKERFILE_PATH` 来替代已弃用的名称。

<a id="cookie-authorization-in-the-gitlab-for-jira-cloud-app"></a>

### GitLab for Jira Cloud 应用中的 Cookie 授权

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387299)。

GitLab for Jira Cloud 应用中的 Cookie 身份验证现已弃用，取而代之的是 OAuth 身份验证。
在极狐GitLab 私有化部署上，您必须[设置 OAuth 身份验证](https://gitlab.cn/docs/jh/integration/jira/connect-app/#set-up-oauth-authentication-for-self-managed-instances)
才能继续使用 GitLab for Jira Cloud 应用。如果没有 OAuth，您将无法管理关联的命名空间。

<a id="dast-api-scans-using-dast-template-is-deprecated"></a>

### 使用 DAST 模板进行 DAST API 扫描已弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384198)。

随着迁移到新的 DAST API 分析器和用于 DAST API 扫描的 `DAST-API.gitlab-ci.yml` 模板，我们将移除使用 DAST 分析器扫描 API 的能力。从极狐GitLab 15.7 开始，使用 `DAST.gitlab-ci.yml` 或 `DAST-latest.gitlab-ci.yml` 模板进行 API 扫描已弃用，并且在极狐GitLab 16.0 中将不再有效。请使用 `DAST-API.gitlab-ci.yml` 模板，并参阅 [DAST API 分析器](https://gitlab.cn/docs/jh/user/application_security/dast_api/#configure-dast-api-with-an-openapi-specification)文档了解配置详情。

<a id="dast-api-variables"></a>

### DAST API 变量

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383467)。

随着在极狐GitLab 15.6 中切换到新的 DAST API 分析器，两个传统的 DAST API 变量正在弃用。变量 `DAST_API_HOST_OVERRIDE` 和 `DAST_API_SPECIFICATION` 将不再用于 DAST API 扫描。

`DAST_API_HOST_OVERRIDE` 已弃用，取而代之的是使用 `DAST_API_TARGET_URL` 自动覆盖 OpenAPI 规范中的主机。

`DAST_API_SPECIFICATION` 已弃用，取而代之的是 `DAST_API_OPENAPI`。要继续使用 OpenAPI 规范来指导测试，用户必须将 `DAST_API_SPECIFICATION` 变量替换为 `DAST_API_OPENAPI` 变量。值可以保持不变，但变量名必须替换。

这两个变量将在极狐GitLab 16.0 中移除。

<a id="dast-report-variables-deprecation"></a>

### DAST 报告变量弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384340)。

随着新的基于浏览器的 DAST 分析器在极狐GitLab 15.7 中正式发布，我们正努力使其在未来某个时候成为默认的 DAST 分析器。为此，以下传统 DAST 变量正在弃用，并计划在极狐GitLab 16.0 中移除：`DAST_HTML_REPORT`、`DAST_XML_REPORT` 和 `DAST_MARKDOWN_REPORT`。这些报告依赖于传统的 DAST 分析器，我们不打算在新的基于浏览器的分析器中实现它们。从极狐GitLab 16.0 开始，将不再生成这些报告产物。

这三个变量将在极狐GitLab 16.0 中移除。

<a id="dependency-scanning-support-for-java-13-14-15-and-16"></a>

### 对 Java 13、14、15 和 16 的依赖扫描支持

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387560)。

极狐GitLab 已弃用对 Java 13、14、15 和 16 版本的依赖扫描支持，并计划在即将发布的极狐GitLab 16.0 版本中移除该支持。这与 [Oracle 支持政策](https://www.oracle.com/java/technologies/java-se-support-roadmap.html)一致，因为 Oracle 对这些版本的首要支持和扩展支持已经结束。这也使极狐GitLab 能够将依赖扫描的 Java 支持重点放在 LTS 版本上。

<a id="deployment-api-returns-error-when-updated_at-and-updated_at-are-not-used-together"></a>

### 当 `updated_at` 和 `updated_at` 未一起使用时，部署 API 返回错误

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/328500)。

当 `updated_at` 过滤和 `updated_at` 排序未一起使用时，部署 API 现在将返回错误。一些用户使用 `updated_at` 过滤来获取“最新”部署，而没有使用 `updated_at` 排序，这可能会产生错误的结果。您应该将它们一起使用，或者迁移到使用 `finished_at` 过滤和 `finished_at` 排序，这将以一致的方式为您提供“最新部署”。

<a id="deprecate-legacy-gitaly-configuration-methods"></a>

### 弃用传统 Gitaly 配置方法

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352609)。

使用环境变量 `GIT_CONFIG_SYSTEM` 和 `GIT_CONFIG_GLOBAL` 配置 Gitaly 已[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/352609)。
这些变量正被标准的 [`config.toml` Gitaly 配置](https://gitlab.cn/docs/jh/administration/gitaly/)所取代。

使用 `GIT_CONFIG_SYSTEM` 和 `GIT_CONFIG_GLOBAL` 配置 Gitaly 的极狐GitLab 实例应切换到使用
`config.toml` 进行配置。

<a id="deprecated-consul-http-metrics"></a>

### 弃用的 Consul http 指标

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7278)。

从极狐GitLab 16.0 开始，Linux 软件包中提供的 Consul 将不再提供较旧的已弃用 Consul 指标。

在极狐GitLab 14.0 中，[Consul 已更新到 1.9.6](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/5344)，
该版本弃用了 `consul.http` 路径下的一些遥测指标。在极狐GitLab 16.0 中，`consul.http` 路径将被移除。

如果您的监控使用了 Consul 指标，请更新它们以使用 `consul.api.http` 而不是 `consul.http`。
有关更多信息，请参见 [Consul 1.9.0 的弃用说明](https://github.com/hashicorp/consul/releases/tag/v1.9.0)。

<a id="deprecation-and-planned-removal-for-ci_pre_clone_script-variable-on-gitlabcom"></a>

### JihuLab.com 上 `CI_PRE_CLONE_SCRIPT` 变量的弃用和计划移除

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391896)。

JihuLab.com Runner 支持的 [`CI_PRE_CLONE_SCRIPT` 变量](https://gitlab.cn/docs/jh/ci/runners/saas/linux_saas_runner/#pre-clone-script)从极狐GitLab 15.9 起弃用，并将在 16.0 中移除。`CI_PRE_CLONE_SCRIPT` 变量使您能够在 runner 执行 Git init 和 get fetch 之前，在 CI/CD 作业中运行命令。有关此功能如何工作的更多信息，请参见[预克隆脚本](https://gitlab.cn/docs/jh/ci/runners/saas/linux_saas_runner/#pre-clone-script)。作为替代方案，您可以使用 [`pre_get_sources_script`](https://gitlab.cn/docs/jh/ci/yaml/#hookspre_get_sources_script)。

<a id="developer-role-providing-the-ability-to-import-projects-to-a-group"></a>

### 开发者角色提供向群组导入项目的能力

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387891)。

在极狐GitLab 15.8 中，拥有群组开发者角色的用户向该群组导入项目的能力已弃用，并将在极狐GitLab 16.0 中移除。从极狐GitLab 16.0 开始，只有拥有群组维护者或所有者角色的用户才能向该群组导入项目。

<a id="development-dependencies-reported-for-php-and-python"></a>

### 报告 PHP 和 Python 的开发依赖

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/375505)。

在极狐GitLab 16.0 中，极狐GitLab 依赖扫描分析器将开始报告 Python/pipenv 和 PHP/composer 项目的开发依赖。不希望报告这些开发依赖的用户应在其 CI/CD 文件中设置 `DS_INCLUDE_DEV_DEPENDENCIES: false`。

<a id="embedding-grafana-panels-in-markdown-is-deprecated"></a>

### 在 Markdown 中嵌入 Grafana 面板已弃用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389477)。

在极狐GitLab 风格 Markdown 中添加 Grafana 面板的能力在 15.9 中弃用，并将在 16.0 中移除。
我们打算用 [GitLab 可观测性 UI](https://gitlab.com/gitlab-org/opstrace/opstrace-ui)的[嵌入图表](https://gitlab.com/groups/gitlab-org/opstrace/-/epics/33)能力来取代此功能。

<a id="enforced-validation-of-cicd-parameter-character-lengths"></a>

### 强制执行 CI/CD 参数字符长度验证

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/372770)。

虽然 CI/CD [作业名称](https://gitlab.cn/docs/jh/ci/jobs/#job-name)有严格的 255 个字符限制，但其他 CI/CD 参数还没有验证来确保它们也保持在限制之内。

在极狐GitLab 16.0 中，将添加验证，以严格将以下内容也限制为 255 个字符：

- `stage` 关键字。
- `ref`，即流水线的 Git 分支或标签名称。
- 外部 CI/CD 集成使用的 `description` 和 `target_url` 参数。

极狐GitLab 私有化部署上的用户应更新其流水线，以确保他们不使用超过 255 个字符的参数。JihuLab.com 上的用户无需进行任何更改，因为这些参数在数据库中已经受限。

<a id="environment-search-query-requires-at-least-three-characters"></a>

### 环境搜索查询至少需要三个字符

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/382532)。

从极狐GitLab 16.0 开始，当您使用 API 搜索环境时，必须至少使用三个字符。此变更有助于我们确保搜索操作的可扩展性。

<a id="external-field-in-graphql-releaseassetlink-type"></a>

### GraphQL ReleaseAssetLink 类型中的 external 字段

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

在 [GraphQL API](https://gitlab.cn/docs/jh/api/graphql/)中，[`ReleaseAssetLink` 类型](https://gitlab.cn/docs/jh/api/graphql/reference/#releaseassetlink)的 `external` 字段用于指示[发布链接](https://gitlab.cn/docs/jh/user/project/releases/release_fields/#links)是极狐GitLab 实例的内部链接还是外部链接。
从极狐GitLab 15.9 开始，我们将所有发布链接都视为外部链接，因此，此字段在极狐GitLab 15.9 中弃用，并将在极狐GitLab 16.0 中移除。为避免对您的工作流造成任何中断，请停止使用 `external` 字段，因为它将被移除且不会被替换。

<a id="external-field-in-releases-and-release-links-apis"></a>

### Releases 和 Release Links API 中的 external 字段

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

在 [Releases API](https://gitlab.cn/docs/jh/api/releases/) 和 [Release Links API](https://gitlab.cn/docs/jh/api/releases/links/)中，`external` 字段用于指示[发布链接](https://gitlab.cn/docs/jh/user/project/releases/release_fields/#links)是极狐GitLab 实例的内部链接还是外部链接。
从极狐GitLab 15.9 开始，我们将所有发布链接都视为外部链接，因此，此字段在极狐GitLab 15.9 中弃用，并将在极狐GitLab 16.0 中移除。为避免对您的工作流造成任何中断，请停止使用 `external` 字段，因为它将被移除且不会被替换。

<a id="geo-project-repository-redownload-is-deprecated"></a>

### Geo：项目代码仓库重新下载已弃用

- 在极狐GitLab 15.11 中宣布
- 在极狐GitLab 16.0 中移除
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388868)。

在 Geo 从站点中，“重新下载”项目代码仓库的按钮已弃用。重新下载逻辑存在固有的数据一致性问题，这些问题在遇到时难以解决。该按钮将在
极狐GitLab 16.0 中移除。

<a id="gitlab-administrators-must-have-permission-to-modify-protected-branches-or-tags"></a>

### 极狐GitLab 管理员必须拥有修改受保护分支或标签的权限

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/12776)。

极狐GitLab 管理员不再能对受保护分支或标签执行操作，除非他们已被明确授予该权限。这些操作包括推送和合并到[受保护分支](https://gitlab.cn/docs/jh/user/project/repository/branches/protected/)、取消保护分支以及创建[受保护标签](https://gitlab.cn/docs/jh/user/project/protected_tags/)。

<a id="gitlab-self-monitoring-project"></a>

### 极狐GitLab 自监控项目

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/348909)。

极狐GitLab 自监控为实例管理员提供了监控其实例健康状况的工具。此功能在极狐GitLab 14.9 中弃用，并计划在 16.0 中移除。

<a id="gitlabcom-importer"></a>

### GitLab.com 导入器

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除

GitLab.com 导入器在极狐GitLab 15.8 中弃用，并将在极狐GitLab 16.0 中移除。

GitLab.com 导入器于 2015 年引入，用于通过 UI 将项目从 GitLab.com 导入到极狐GitLab 私有化部署实例。
此功能仅在极狐GitLab 私有化部署上可用。[通过直接转移迁移极狐GitLab 群组和项目](https://gitlab.cn/docs/jh/user/group/import/#migrate-groups-by-direct-transfer-recommended)
取代了 GitLab.com 导入器，并提供了更具凝聚力的导入功能。

有关概述，请参见[已迁移的群组条目](https://gitlab.cn/docs/jh/user/group/import/#migrated-group-items)和[已迁移的项目条目](https://gitlab.cn/docs/jh/user/group/import/#migrated-project-items)。

<a id="graphql-api-runner-status-will-not-return-paused"></a>

### GraphQL API Runner 状态将不再返回 `paused`

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/344648)。

极狐GitLab Runner GraphQL API 端点在极狐GitLab 16.0 中将不再返回 `paused` 或 `active` 作为状态。
在未来的 REST API v5 中，极狐GitLab Runner 的端点也将不再返回 `paused` 或 `active`。

Runner 的状态将仅与 runner 联系状态相关，例如：
`online`、`offline` 或 `not_connected`。状态 `paused` 或 `active` 将不再出现。

在检查 runner 是否 `paused` 时，建议 API 用户改为检查布尔属性
`paused` 是否为 `true`。在检查 runner 是否 `active` 时，请检查 `paused` 是否为 `false`。

<a id="jira-dvcs-connector-for-jira-cloud"></a>

### 用于 Jira Cloud 的 Jira DVCS 连接器

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/7508)。

用于 Jira Cloud 的 [Jira DVCS 连接器](https://gitlab.cn/docs/jh/integration/jira/dvcs/)已弃用，并将在极狐GitLab 16.0 中移除。如果您正在将 Jira DVCS 连接器与 Jira Cloud 一起使用，请迁移到 [GitLab for Jira Cloud 应用](https://gitlab.cn/docs/jh/integration/jira/connect-app/)。

Jira DVCS 连接器对于 Jira 8.13 及更早版本也已弃用。您只能在 Jira 8.14 及更高版本中将 Jira DVCS 连接器与 Jira Server 或 Jira Data Center 一起使用。

<a id="kas-metrics-port-in-gitlab-helm-chart"></a>

### GitLab Helm Chart 中的 KAS 指标端口

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383039)。

`gitlab.kas.metrics.port` 已弃用，取而代之的是 [GitLab Helm Chart](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/2839)的新 `gitlab.kas.observability.port` 配置字段。
此端口的用途远不止指标，因此有必要进行此更改以避免配置混淆。

<a id="legacy-gitaly-configuration-method"></a>

### 传统 Gitaly 配置方法

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393574)。

Omnibus GitLab 中的 Gitaly 配置已更新，所有与 Gitaly 相关的配置键都位于一个与标准 Gitaly 配置相匹配的单一配置结构中。因此，之前的配置结构已弃用。

单一配置结构从极狐GitLab 15.10 起可用，但仍保持向后兼容性。一旦移除，Gitaly 必须使用单一配置结构进行配置。您应尽快更新 Gitaly 的配置。

此变更提高了 Omnibus GitLab 与源码安装之间的一致性，并使我们能够为两者提供更好的文档和工具。

您应尽快使用
[升级说明](https://gitlab.cn/docs/jh/update/package/#gitaly-omnibus-gitlab-configuration-structure-change)更新到新的配置结构。

<a id="legacy-praefect-configuration-method"></a>

### 传统 Praefect 配置方法

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390291)。

以前，Praefect 配置键分散在整个配置文件中。现在，这些键位于一个与 Praefect 配置相匹配的单一配置结构中，因此之前的配置方法已弃用。

单一配置结构从极狐GitLab 15.9 起可用，但仍保持向后兼容性。一旦移除，Praefect 必须使用单一配置结构进行配置。您应尽快使用
[升级说明](https://gitlab.cn/docs/jh/update/package/#praefect-omnibus-gitlab-configuration-structure-change)更新您的 Praefect 配置。

此变更使 Omnibus GitLab 中的 Praefect 配置与 Praefect 的配置结构保持一致。以前，层次结构和配置键
不匹配。此变更提高了 Omnibus GitLab 与源码安装之间的一致性，并使我们能够为两者提供更好的文档和工具。

<a id="legacy-urls-replaced-or-removed"></a>

### 传统 URL 被替换或移除

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/214217)。

极狐GitLab 16.0 从极狐GitLab 应用程序中移除了传统 URL。

当子群组在极狐GitLab 9.0 中引入时，URL 中添加了 `/-/` 分隔符，以表示群组路径的结束。所有极狐GitLab URL 现在都使用此分隔符来标识项目、群组和实例级功能。

不使用 `/-/` 分隔符的 URL 计划在极狐GitLab 16.0 中移除。有关这些 URL 的完整列表及其替代方案，请参见[议题 28848](https://gitlab.com/gitlab-org/gitlab/-/issues/28848#release-notes)。

更新任何引用传统 URL 的脚本或书签。极狐GitLab API 不受此变更影响。

<a id="license-check-and-the-policies-tab-on-the-license-compliance-page"></a>

### License-Check 和许可证合规页面上的策略选项卡

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390417)。

**License-Check 功能**现已弃用，并计划在极狐GitLab 16.0 中移除。此外，许可证合规页面上的策略选项卡以及与 License-Check 功能相关的所有 API 均已弃用，并计划在极狐GitLab 16.0 中移除。希望继续根据检测到的许可证强制执行审批的用户，建议改为创建新的[许可证审批策略](https://gitlab.cn/docs/jh/user/compliance/license_approval_policies/)。

<a id="limit-personal-access-token-and-deploy-tokens-access-with-external-authorization"></a>

### 通过外部授权限制个人访问令牌和部署令牌的访问

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387721)。

启用外部授权后，个人访问令牌（PAT）和部署令牌必须不能再访问容器或软件包仓库。这项纵深防御安全措施将在 16.0 中部署。对于使用 PAT 和部署令牌访问这些仓库的用户，此措施会破坏这些令牌的这种用法。请禁用外部授权，以将令牌用于容器或软件包仓库。

<a id="major-bundled-helm-chart-updates-for-the-gitlab-helm-chart"></a>

### GitLab Helm Chart 的主要内置 Helm Chart 更新

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3442)。

为配合极狐GitLab 16.0，GitLab Helm Chart 将发布 7.0 主要版本。将包含以下主要内置 chart 更新：

- 在极狐GitLab 16.0 中，[PostgreSQL 12 支持正在移除，PostgreSQL 13 成为新的最低版本](#postgresql-12-deprecated)。
  - 使用生产就绪外部数据库的安装需要在升级前完成到更新 PostgreSQL 版本的迁移。
  - 使用[非生产内置 PostgreSQL 12 chart](https://gitlab.cn/docs/charts/installation/tools/#postgresql)的安装将把 chart 升级到新版本。有关更多信息，[请参见议题 4118](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/4118)
- 使用[非生产内置 Redis chart](https://gitlab.cn/docs/charts/installation/tools/#redis)的安装将把 chart 升级到更新版本。有关更多信息，[请参见议题 3375](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3375)
- 使用[内置 cert-manager chart](https://gitlab.cn/docs/charts/installation/tls/#option-1-cert-manager-and-lets-encrypt)的安装将把 chart 升级到更新版本。有关更多信息，[请参见议题 4313](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/4313)

完整的 GitLab Helm Chart 7.0 升级步骤将在[升级文档](https://gitlab.cn/docs/charts/installation/upgrade/)中提供。

<a id="managed-licenses-api"></a>

### 受管许可证 API

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390417)。

受管许可证 API 现已弃用，并计划在极狐GitLab 16.0 中移除。

<a id="maximum-number-of-active-pipelines-per-project-limit-ci_active_pipelines"></a>

### 每个项目的最大活动流水线数量限制（`ci_active_pipelines`）

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 16.0 中移除
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/368195)。

[**每个项目的最大活动流水线数量**限制](https://gitlab.cn/docs/jh/administration/settings/continuous_integration/#set-cicd-limits)从未默认启用，并将在极狐GitLab 16.0 中移除。此限制也可以在 Rails 控制台中的 [`ci_active_pipelines`](https://gitlab.cn/docs/jh/administration/instance_limits/#number-of-pipelines-running-concurrently) 下配置。请改用其他提供类似保护的建议速率限制：

- [**流水线速率限制**](https://gitlab.cn/docs/jh/administration/settings/rate_limit_on_pipelines_creation/)。
- [**当前活动流水线中的作业总数**](https://gitlab.cn/docs/jh/administration/settings/continuous_integration/#set-cicd-limits)。

<a id="monitor-performance-metrics-through-prometheus"></a>

### 通过 Prometheus 监控性能指标

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/346541)。

通过显示存储在 Prometheus 实例中的数据，极狐GitLab 允许用户查看性能指标。极狐GitLab 还在仪表板中显示这些指标的可视化效果。用户可以连接到之前配置的外部 Prometheus 实例，或将 Prometheus 设置为极狐GitLab 托管应用。
但是，由于基于证书的 Kubernetes 集群集成在极狐GitLab 中已弃用，极狐GitLab 中依赖 Prometheus 的指标功能也已弃用。这包括仪表板中的指标可视化效果。GitLab 正在努力开发基于 [Opstrace](https://about.gitlab.com/press/releases/2021-12-14-gitlab-acquires-opstrace-to-expand-its-devops-platform-with-open-source-observability-solution/)的统一用户体验。有一个[议题](https://gitlab.com/groups/gitlab-org/-/epics/6976)供您关注 Opstrace 集成的工作。

<a id="non-expiring-access-tokens"></a>

### 永不过期的访问令牌

- 在极狐GitLab 15.4 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369122)。

您现有的项目访问令牌是否会自动应用过期日期，取决于您使用的极狐GitLab 产品，以及您升级到极狐GitLab 16.0 或更高版本的时间：

- 在 JihuLab.com 上，在 16.0 里程碑期间，没有过期日期的现有项目访问令牌会自动获得一个比当前日期晚 365 天的过期日期。
- 在极狐GitLab 私有化部署上，如果您从极狐GitLab 15.11 或更早版本升级到极狐GitLab 16.0 或更高版本：
  - 在 2024 年 7 月 23 日或之前，没有过期日期的现有项目访问令牌会自动获得一个比当前日期晚 365 天的过期日期。
    此变更是一项重大变更。
  - 在 2024 年 7 月 24 日或之后，没有过期日期的现有项目访问令牌不会设置过期日期。

在极狐GitLab 私有化部署上，如果您全新安装以下极狐GitLab 版本之一，您现有的项目访问令牌不会自动应用过期日期：

- 16.0.9
- 16.1.7
- 16.2.10
- 16.3.8
- 16.4.6
- 16.5.9
- 16.6.9
- 16.7.9
- 16.8.9
- 16.9.10
- 16.10.9
- 16.11.7
- 17.0.5
- 17.1.3
- 17.2.1

没有过期日期的访问令牌无限期有效，如果访问令牌泄露，会带来安全风险。由于有过期日期的访问令牌更好，从极狐GitLab 15.3 起，我们
[填充默认过期日期](https://gitlab.com/gitlab-org/gitlab/-/issues/348660)。

在极狐GitLab 16.0 中，任何没有过期日期的[个人](https://gitlab.cn/docs/jh/user/profile/personal_access_tokens/)、
[项目](https://gitlab.cn/docs/jh/user/project/settings/project_access_tokens/)或
[群组](https://gitlab.cn/docs/jh/user/group/settings/group_access_tokens/)访问令牌
都将自动设置为一年的过期日期。

我们建议在应用默认值之前，根据您公司的安全策略为您的访问令牌设置过期日期：

- 在 JihuLab.com 上，在 16.0 里程碑期间。
- 在极狐GitLab 私有化部署上，当它们升级到 16.0 时。

<a id="non-standard-default-redis-ports-are-deprecated"></a>

### 非标准默认 Redis 端口已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388269)。

如果极狐GitLab 在没有任何 Redis 配置文件的情况下启动，极狐GitLab 会假定它可以连接到 `localhost:6380`、
`localhost:6381` 和 `localhost:6382` 上的三个 Redis 服务器。我们正在更改此行为，
使极狐GitLab 假定在 `localhost:6379` 上有一个 Redis 服务器。

希望保留三个服务器的管理员必须通过编辑 `config/redis.cache.yml`、`config/redis.queues.yml`
和 `config/redis.shared_state.yml` 文件来配置 Redis URL。

<a id="option-to-delete-projects-immediately-is-deprecated-from-deletion-protection-settings"></a>

### 从删除保护设置中弃用立即删除项目的选项

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389557)。

**管理员**区域中的群组和项目删除保护设置有一个立即删除群组和项目的选项。从 16.0 开始，此选项将不再可用，延迟删除群组和项目将成为默认行为。

该选项将不再作为群组设置出现。极狐GitLab 私有化部署上的用户仍然可以选择定义删除延迟期，而 JihuLab.com 用户有一个不可调整的默认保留期 7 天。用户仍然可以从项目设置中立即删除项目，以及从群组设置中立即删除群组。

默认立即删除群组和项目的选项已弃用，以防止用户意外执行此操作并永久丢失群组和项目。

<a id="postgresql-12-deprecated"></a>

### PostgreSQL 12 已弃用

- 在极狐GitLab 15.0 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/349185)。

对 PostgreSQL 12 的支持计划在极狐GitLab 16.0 中移除。
在极狐GitLab 16.0 中，PostgreSQL 13 成为最低要求的 PostgreSQL 版本。

PostgreSQL 12 将在整个极狐GitLab 15 发布周期内受支持。
对于希望在极狐GitLab 16.0 之前升级的实例，PostgreSQL 13 也将受支持。

在极狐GitLab 15.2 中，Geo 添加了对 PostgreSQL 13 的支持。

<a id="projects-api-field-operations_access_level-is-deprecated"></a>

### Projects API 字段 `operations_access_level` 已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参见[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385798)。

我们正在弃用 Projects API 中的 `operations_access_level` 字段。此字段已被用于控制特定功能的字段所取代：`releases_access_level`、`environments_access_level`、`feature_flags_access_level`、`infrastructure_access_level` 和 `monitor_access_level`。

<a id="rake-task-for-importing-bare-repositories"></a>

### 用于导入裸代码仓库的 Rake 任务

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除

用于导入裸代码仓库的 Rake 任务（`gitlab:import:repos`）在极狐GitLab 15.8 中已弃用，并将在极狐GitLab 16.0 中移除。

此 Rake 任务将代码仓库的目录树导入极狐GitLab 实例。这些代码仓库此前必须由极狐GitLab 管理，因为该 Rake 任务依赖特定的目录结构或特定的自定义 Git 设置（`gitlab.fullpath`）才能工作。

使用此 Rake 任务导入代码仓库存在限制。该 Rake 任务：

- 仅支持项目代码仓库和项目 Wiki 代码仓库，不支持设计、群组 Wiki 或代码片段的代码仓库。
- 允许您导入非哈希存储项目，即使这些项目不受支持。
- 依赖已设置的 Git 配置 `gitlab.fullpath`。[史诗 8953](https://gitlab.com/groups/gitlab-org/-/epics/8953) 提议移除对此设置的支持。

使用 `gitlab:import:repos` Rake 任务的替代方案包括：

- 使用[导出文件](https://gitlab.cn/docs/jh/user/project/settings/import_export/)或[直接转移](https://gitlab.cn/docs/jh/user/group/import/#migrate-groups-by-direct-transfer-recommended)迁移项目，同时也会迁移代码仓库。
- 通过 [URL 导入代码仓库](https://gitlab.cn/docs/jh/user/project/import/repo_by_url/)。
- 从[非极狐GitLab 源导入代码仓库](https://gitlab.cn/docs/jh/user/import/)。

<a id="redis-5-deprecated"></a>

### Redis 5 已弃用

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 15.6 中停止支持
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/331468)。

从极狐GitLab 13.9 开始，在 Omnibus GitLab 软件包和 GitLab Helm chart 4.9 中，Redis 版本[已更新至 Redis 6](https://about.gitlab.com/releases/2021/02/22/gitlab-13-9-released/#omnibus-improvements)。
Redis 5 已于 2022 年 4 月停止维护，并且从极狐GitLab 15.6 起将不再受支持。如果您使用的是自己的 Redis 5.0 实例，应在升级到极狐GitLab 16.0 或更高版本之前将其升级到 Redis 6.0 或更高版本。

<a id="remove-job_age-parameter-from-post-jobsrequest-runner-endpoint"></a>

### 从 Runner 端点 `POST /jobs/request`中移除 `job_age` 参数

- 在极狐GitLab 15.2 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/334253)。

`job_age` 参数由用于与极狐GitLab Runner 通信的 `POST /jobs/request` API 端点返回，但从未被任何极狐GitLab 或 Runner 功能使用。此参数将在极狐GitLab 16.0 中移除。

对于任何开发了自己的 Runner 并依赖此端点返回该参数的用户来说，这可能是一个重大变更。对于使用官方发布版本的极狐GitLab Runner 的任何人（包括 JihuLab.com 上的公共共享 Runner）来说，这不是重大变更。

<a id="sast-analyzer-coverage-changing-in-gitlab-160"></a>

### 极狐GitLab 16.0 中 SAST 分析器覆盖范围的变化

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390416)。

极狐GitLab SAST 使用各种[分析器](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/)来扫描代码中的漏洞。

我们正在减少极狐GitLab SAST 默认使用的受支持分析器的数量。这是我们长期战略的一部分，旨在为不同编程语言提供更快、更一致的用户体验。

从极狐GitLab 16.0 开始，GitLab SAST CI/CD 模板将不再使用基于 [Security Code Scan](https://gitlab.com/gitlab-org/security-products/analyzers/security-code-scan)的 .NET 分析器，该分析器将进入停止支持状态。
我们将从 [SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)中移除此分析器，并在[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)中将其替换为 GitLab 支持的 C# 检测规则。

此分析器将立即仅接收安全更新；不保证提供其他常规改进或更新。此分析器在极狐GitLab 16.0 中达到停止支持状态后，将不再提供任何更新。但是，我们不会删除此前为此分析器发布的容器镜像，也不会移除通过自定义 CI/CD 流水线作业运行它的能力。

如果您已经忽略了来自已弃用分析器的漏洞发现，替换分析器会尝试尊重您之前的忽略操作。系统行为取决于：

- 您过去是否排除了基于 Semgrep 的分析器运行。
- 哪个分析器首先发现了项目漏洞报告中显示的漏洞。

有关更多详细信息，请参阅[漏洞转换文档](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/#vulnerability-translation)。

如果您对受影响的分析器应用了自定义设置，或者您当前在流水线中禁用了基于 Semgrep 的分析器，则必须按照[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390416#breaking-change)中的详细说明采取行动。

**更新**：我们已缩小此变更的范围。我们将不再在极狐GitLab 16.0 中进行以下变更：

1. 移除基于 [PHPCS Security Audit](https://gitlab.com/gitlab-org/security-products/analyzers/phpcs-security-audit)的分析器的支持，并在[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)中将其替换为 GitLab 管理的检测规则。
1. 从[基于 SpotBugs 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs)的范围中移除 Scala，并在[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)中将其替换为 GitLab 管理的检测规则。

替换基于 PHPCS Security Audit 的分析器的工作在[议题 364060](https://gitlab.com/gitlab-org/gitlab/-/issues/364060)中跟踪，将 Scala 扫描迁移到基于 Semgrep 的分析器的工作在[议题 362958](https://gitlab.com/gitlab-org/gitlab/-/issues/362958)中跟踪。

<a id="secure-analyzers-major-version-update-1"></a>

### Secure 分析器主版本更新

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390912)。

Secure 阶段将随极狐GitLab 16.0 版本一起提升其分析器的主版本。此次提升将为分析器提供清晰的划分，区分：

- 2023 年 5 月 22 日之前发布的分析器
- 2023 年 5 月 22 日之后发布的分析器

如果您未使用默认包含的模板，或者已固定分析器版本，则需要更新 CI/CD 作业定义，以移除固定的版本或更新到最新的主版本。极狐GitLab 13.0-15.10 的用户将继续正常接收分析器更新，直到极狐GitLab 16.0 发布，此后所有新修复的错误和发布的功能将仅在分析器的新主版本中发布。根据我们的[维护政策](https://gitlab.cn/docs/jh/policy/maintenance/)，我们不会将错误和功能向后移植到已弃用的版本。如有必要，安全补丁将在最新的 3 个次要版本内向后移植。具体来说，以下内容将被弃用，并且在极狐GitLab 16.0 发布后将不再更新：

- API 模糊测试：版本 2
- 容器扫描：版本 5
- 覆盖率引导的模糊测试：版本 3
- 依赖扫描：版本 3
- 动态应用程序安全测试（DAST）：版本 3
- DAST API：版本 2
- IaC 扫描：版本 3
- 许可证扫描：版本 4
- 密钥检测：版本 4
- 静态应用程序安全测试（SAST）：[所有分析器](https://gitlab.cn/docs/jh/user/application_security/sast/#supported-languages-and-frameworks)的版本 3
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

### Secure 扫描 CI/CD 模板将使用新的作业 `rules`

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391822)。

GitLab 管理的安全扫描 CI/CD 模板将在极狐GitLab 16.0 版本中更新。更新将包括已在 CI/CD 模板最新版本中发布的改进。我们在最新模板版本中发布了这些变更，因为它们有可能破坏自定义的 CI/CD 流水线配置。

在所有更新的模板中，我们正在更新诸如 `SAST_DISABLED` 和 `DEPENDENCY_SCANNING_DISABLED` 等变量的定义，使其仅在值为 `"true"` 时禁用扫描。此前，即使值为 `"false"`，扫描也会被禁用。

以下模板将被更新：

- API 模糊测试：[`API-Fuzzing.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml)
- 容器扫描：[`Container-Scanning.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Container-Scanning.gitlab-ci.yml)
- 覆盖率引导的模糊测试：[`Coverage-Fuzzing.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/Coverage-Fuzzing.gitlab-ci.yml)
- DAST：[`DAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/DAST.gitlab-ci.yml)
- DAST API：[`DAST-API.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/DAST-API.gitlab-ci.yml)
- 依赖扫描：[`Dependency-Scanning.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml)
- IaC 扫描：[`SAST-IaC.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST-IaC.gitlab-ci.yml)
- SAST：[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)
- 密钥检测：[`Secret-Detection.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)

如果您使用上面列出的模板之一，并且使用了 `_DISABLED` 变量但设置的值不是 `"true"`，我们建议您在 16.0 版本发布之前测试您的流水线。

**更新**：我们此前宣布将更新受影响模板上的 `rules`，使其默认在[合并请求流水线](https://gitlab.cn/docs/jh/ci/pipelines/merge_request_pipelines/)中运行。
但是，由于[弃用议题中讨论的](https://gitlab.com/gitlab-org/gitlab/-/issues/388988#note_1372629948)兼容性问题，我们将不再在极狐GitLab 16.0 中进行此变更。我们仍将如上所述发布对 `_DISABLED` 变量的变更。

<a id="security-report-schemas-version-14xx"></a>

### 安全报告模式版本 14.x.x

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/366477)。

版本 14.x.x 的[安全报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas)已弃用。

在极狐GitLab 15.8 及更高版本中，使用模式版本 14.x.x 的[安全报告扫描器集成](https://gitlab.cn/docs/jh/development/integrations/secure/)将在流水线的 **安全** 选项卡中显示弃用警告。

在极狐GitLab 16.0 及更高版本中，此功能将被移除。使用模式版本 14.x.x 的安全报告将在流水线的 **安全** 选项卡中导致错误。

有关更多信息，请参阅[安全报告验证](https://gitlab.cn/docs/jh/user/application_security/#security-report-validation)。

<a id="starboard-directive-in-the-configuration-of-the-gitlab-agent-for-kubernetes"></a>

### 极狐GitLab Kubernetes Agent 配置中的 Starboard 指令

- 在极狐GitLab 15.4 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/368828)。

极狐GitLab 容器扫描功能不再需要安装 starboard。因此，在极狐GitLab Kubernetes Agent 的配置文件中使用 `starboard:` 指令现已弃用，并计划在极狐GitLab 16.0 中移除。请更新您的配置文件以使用 `container_scanning:` 指令。

<a id="stop-publishing-gitlab-runner-images-based-on-windows-server-2004-and-20h2"></a>

### 停止发布基于 Windows Server 2004 和 20H2 的极狐GitLab Runner 镜像

- 在极狐GitLab 16.0 中宣布
- 在极狐GitLab 16.0 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/31001)。

从极狐GitLab 16.0 开始，将不再提供基于 Windows Server 2004 和 20H2 的极狐GitLab Runner 镜像，因为这些操作系统已停止维护。

<a id="support-for-praefect-custom-metrics-endpoint-configuration"></a>

### 对 Praefect 自定义指标端点配置的支持

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390266)。

使用 `prometheus_exclude_database_from_default_metrics` 配置值的支持在极狐GitLab 15.9 中已弃用，并将在极狐GitLab 16.0 中移除。我们正在移除此配置值，因为使用它会导致性能不佳。此变更意味着以下指标将在 `/metrics` 上不可用：

- `gitaly_praefect_unavailable_repositories`。
- `gitaly_praefect_verification_queue_depth`。
- `gitaly_praefect_replication_queue_depth`。

这可能需要更新您的指标收集目标，以同时抓取 `/db_metrics`。

<a id="support-for-periods--in-terraform-state-names-might-break-existing-states"></a>

### 对 Terraform 状态名称中句点（`.`）的支持可能会破坏现有状态

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385564)。

此前，包含句点的 Terraform 状态名称不受支持。但是，您仍然可以通过变通方法使用带句点的状态名称。

极狐GitLab 15.7 [增加了对包含句点的状态名称的完整支持](https://gitlab.cn/docs/jh/user/infrastructure/iac/troubleshooting/#state-not-found-if-the-state-name-contains-a-period)。如果您使用了变通方法来处理这些状态名称，您的作业可能会失败，或者看起来像是您第一次运行 Terraform。

要解决此问题：

1. 更改对状态文件的任何引用，排除句点及其后的任何字符。
   - 例如，如果您的状态名称是 `state.name`，请将所有引用更改为 `state`。
1. 运行您的 Terraform 命令。

要使用包含句点的完整状态名称，请[迁移到完整状态文件](https://gitlab.cn/docs/jh/user/infrastructure/iac/terraform_state/#migrate-to-a-gitlab-managed-terraform-state)。

<a id="the-api-no-longer-returns-revoked-tokens-for-the-agent-for-kubernetes"></a>

### API 不再为极狐GitLab Kubernetes Agent 返回已撤销的令牌

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/382129)。

目前，对 [Cluster Agents API](https://gitlab.cn/docs/jh/api/cluster_agents/#list-tokens-for-an-agent) 端点的 GET 请求可能会返回已撤销的令牌。在极狐GitLab 16.0 中，GET 请求将不会返回已撤销的令牌。

您应该检查对这些端点的调用，并确保不使用已撤销的令牌。

此变更影响以下 REST 和 GraphQL API 端点：

- REST API：
  - [列出令牌](https://gitlab.cn/docs/jh/api/cluster_agents/#list-tokens-for-an-agent)
  - [获取单个令牌](https://gitlab.cn/docs/jh/api/cluster_agents/#get-a-single-agent-token)
- GraphQL：
  - [`ClusterAgent.tokens`](https://gitlab.cn/docs/jh/api/graphql/reference/#clusteragenttokens)

<a id="the-phabricator-task-importer-is-deprecated"></a>

### Phabricator 任务导入器已弃用

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

Phabricator 任务导入器正在弃用。Phabricator 项目本身自 2021 年 6 月 1 日起已不再积极维护。我们尚未观察到使用此工具的导入。GitLab 上开放的相关议题也没有任何活动。

<a id="the-latest-terraform-templates-will-overwrite-current-stable-templates"></a>

### 最新的 Terraform 模板将覆盖当前的稳定模板

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/386001)。

在每个极狐GitLab 主版本中，我们都会用当前最新的模板更新稳定的 Terraform 模板。
此变更影响[快速入门](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform.gitlab-ci.yml)和[基础模板](https://gitlab.cn/docs/jh/update/deprecations/#deprecate-terraform-cicd-templates)。

由于新模板带有默认规则，此更新可能会破坏您的 Terraform 流水线。例如，如果您的 Terraform 作业作为下游流水线触发，这些规则将不会在极狐GitLab 16.0 中触发您的作业。

为了适应这些变更，您可能需要调整 `.gitlab-ci.yml` 文件中的 [`rules`](https://gitlab.cn/docs/jh/ci/yaml/#rules)。

<a id="toggle-behavior-of-draft-quick-action-in-merge-requests"></a>

### 合并请求中 `/draft` 快速操作的切换行为

- 在极狐GitLab 15.4 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/365365)。

为了使通过快速操作切换合并请求草稿状态的行为更加清晰，我们正在弃用并移除 `/draft` 快速操作的切换行为。从极狐GitLab 16.0 版本开始，`/draft` 将仅将合并请求设置为草稿，并将使用新的 `/ready` 快速操作来移除草稿状态。

<a id="use-of-id-field-in-vulnerabilityfindingdismiss-mutation"></a>

### 在 `vulnerabilityFindingDismiss` mutation 中使用 `id` 字段

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/367166)。

您可以使用 `vulnerabilityFindingDismiss` GraphQL mutation 将漏洞发现的状态设置为 `Dismissed`。此前，此 mutation 使用 `id` 字段来唯一标识发现。但是，这不适用于从流水线安全选项卡中忽略发现。因此，使用 `id` 字段作为标识符已被弃用，取而代之的是 `uuid` 字段。使用 'uuid' 字段作为标识符允许您从流水线安全选项卡中忽略发现。

<a id="use-of-third-party-container-registries-is-deprecated"></a>

### 使用第三方容器镜像仓库已弃用

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/376216)。

在极狐GitLab 15.8 中，使用极狐GitLab 作为第三方容器镜像仓库的认证端点已弃用，[停止支持](https://gitlab.cn/docs/jh/development/deprecation_guidelines/#terminology)计划在极狐GitLab 16.0 中进行。这会影响极狐GitLab 私有化部署上已将其外部镜像仓库连接到极狐GitLab 用户界面以查找、查看和删除容器镜像的用户。

同时支持极狐GitLab 容器镜像仓库和第三方容器镜像仓库在维护、代码质量和向后兼容性方面具有挑战性，并阻碍了我们保持高效的能力。因此，我们将不再支持此功能。

此变更不会影响您使用流水线向外部镜像仓库拉取和推送容器镜像的能力。

自从我们为 JihuLab.com 发布了新的[极狐GitLab 容器镜像仓库](https://gitlab.com/groups/gitlab-org/-/epics/5523)版本以来，我们已经开始实现第三方容器镜像仓库中不可用的其他功能。这些新功能使我们能够实现显著的性能改进，例如[清理策略](https://gitlab.com/groups/gitlab-org/-/epics/8379)。我们正专注于交付[新功能](https://gitlab.com/groups/gitlab-org/-/epics/5136)，其中大部分功能将需要仅在极狐GitLab 容器镜像仓库上可用的功能。此弃用使我们能够通过专注于交付更强大的集成镜像仓库体验和功能集，从长远来看减少碎片化和用户挫败感。

展望未来，我们将继续投资于开发和发布仅在极狐GitLab 容器镜像仓库中可用的新功能。

<a id="work-items-path-with-global-id-at-the-end-of-the-path-is-deprecated"></a>

### 路径末尾带有全局 ID 的工作项路径已弃用

- 在极狐GitLab 15.10 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393836)。

在工作项 URL 中使用全局 ID 已弃用。将来，将仅支持内部 ID（IID）。

由于极狐GitLab 支持多种工作项类型，诸如 `https://gitlab.com/gitlab-org/gitlab/-/work_items/<global_id>` 的路径可以显示例如[任务](https://gitlab.cn/docs/jh/user/tasks/)或 [OKR](https://gitlab.cn/docs/jh/user/okrs/)。

在极狐GitLab 15.10 中，我们通过在该路径末尾附加一个查询参数（`iid_path`）来支持使用内部 ID（IID），格式如下：`https://gitlab.com/gitlab-org/gitlab/-/work_items/<iid>?iid_path=true`。

在极狐GitLab 16.0 中，我们将移除在工作项路径中使用全局 ID 的能力。路径末尾的数字将被视为内部 ID（IID），无需在末尾添加查询参数。将仅支持以下格式：`https://gitlab.com/gitlab-org/gitlab/-/work_items/<iid>`。

<a id="ci_build_-predefined-variables"></a>

### `CI_BUILD_*` 预定义变量

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352957)。

以 `CI_BUILD_*` 开头的预定义 CI/CD 变量在极狐GitLab 9.0 中已弃用，并将在极狐GitLab 16.0 中移除。如果您仍在使用这些变量，请务必更改为功能相同的替代[预定义变量](https://gitlab.cn/docs/jh/ci/variables/predefined_variables/)：

| 已移除的变量      | 替代变量    |
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

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/381669)。

`POST ci/lint` API 端点在 15.7 中已弃用，并将在 16.0 中移除。此端点不会验证所有 CI/CD 配置选项。请改用 [`POST /projects/:id/ci/lint`](https://gitlab.cn/docs/jh/api/lint/#validate-a-ci-yaml-configuration-with-a-namespace)，它可以正确验证 CI/CD 配置。

<a id="environment_tier-parameter-for-dora-api"></a>

### DORA API 的 `environment_tier` 参数

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/365939)。

为避免混淆和重复，`environment_tier` 参数已弃用，取而代之的是 `environment_tiers` 参数。新的 `environment_tiers` 参数允许 DORA API 同时返回多个层级的聚合数据。`environment_tier` 参数将在极狐GitLab 16.0 中移除。

<a id="name-field-for-pipelinesecurityreportfinding-graphql-type"></a>

### `PipelineSecurityReportFinding` GraphQL 类型的 `name` 字段

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/346335)。

此前，[`PipelineSecurityReportFinding` GraphQL 类型已更新](https://gitlab.com/gitlab-org/gitlab/-/issues/335372)，以包含新的 `title` 字段。此字段是当前 `name` 字段的别名，使得不太具体的 `name` 字段变得多余。`name` 字段将在极狐GitLab 16.0 中从 `PipelineSecurityReportFinding` 类型中移除。

<a id="started-iteration-state"></a>

### `started` 迭代状态

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/334018)。

[迭代 GraphQL API](https://gitlab.cn/docs/jh/api/graphql/reference/#iterationstate) 和[迭代 REST API](https://gitlab.cn/docs/jh/api/iterations/#list-project-iterations)中的 `started` 迭代状态已弃用。

GraphQL API 版本将在极狐GitLab 16.0 中移除。此状态正被 `current` 状态（已可用）取代，该状态与其他基于时间的实体（如里程碑）的命名保持一致。

我们计划在下一个 v5 REST API 版本之前继续在 REST API 版本中支持 `started` 状态。

<a id="vulnerabilityfindingdismiss-graphql-mutation"></a>

### `vulnerabilityFindingDismiss` GraphQL mutation

- 在极狐GitLab 15.5 中宣布
- 在极狐GitLab 16.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/375645)。

`VulnerabilityFindingDismiss` GraphQL mutation 正在弃用，并将在极狐GitLab 16.0 中移除。此 mutation 不常使用，因为漏洞发现 ID 对用户不可用（此字段[在 15.3 中已弃用](https://gitlab.cn/docs/jh/update/deprecations/#use-of-id-field-in-vulnerabilityfindingdismiss-mutation)）。用户应改用 `VulnerabilityDismiss` 来忽略漏洞报告中的漏洞，或使用 `SecurityFindingDismiss` 来处理 CI 流水线安全选项卡中的安全发现。

<a id="gitlab-1511"></a>

## 极狐GitLab 15.11

<a id="opensuse-leap-153-packages"></a>

### openSUSE Leap 15.3 软件包

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 15.11 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7371)。

openSUSE Leap 15.3 的发行版支持和安全更新[已于 2022 年 12 月结束](https://en.opensuse.org/Lifetime#Discontinued_distributions)。

从极狐GitLab 15.7 开始，我们开始提供 openSUSE Leap 15.4 的软件包，并将在 15.11 里程碑中停止提供 openSUSE Leap 15.3 的软件包。

- 从 openSUSE Leap 15.3 软件包切换到提供的 15.4 软件包。

<a id="gitlab-1510"></a>

## 极狐GitLab 15.10

<a id="automatic-backup-upload-using-openstack-swift-and-rackspace-apis"></a>

### 使用 OpenStack Swift 和 Rackspace API 自动上传备份

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 15.10 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387976)。

我们正在弃用使用 OpenStack Swift 和 Rackspace API **将备份上传到远程存储**的支持。对这些 API 的支持依赖于不再积极维护且尚未针对 Ruby 3 更新的第三方库。极狐GitLab 正在 Ruby 2 停止维护之前切换到 Ruby 3，以便及时获取安全补丁。

- 如果您使用 OpenStack，则需要将配置更改为使用 S3 API 而不是 Swift。
- 如果您使用 Rackspace 存储，则需要切换到其他提供商，或在备份任务完成后手动上传备份文件。

<a id="gitlab-159"></a>

## 极狐GitLab 15.9

<a id="live-preview-no-longer-available-in-the-web-ide"></a>

### Web IDE 中不再提供 Live Preview

- 在极狐GitLab 15.8 中宣布
- 在极狐GitLab 15.9 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383889)。

Web IDE 的 Live Preview 功能旨在提供静态 Web 应用程序的客户端预览。然而，复杂的配置步骤和有限的支持项目类型限制了它的实用性。随着极狐GitLab 15.7 中 Web IDE 测试版的推出，您现在可以连接到完整的服务器端运行时环境。随着即将支持在 Web IDE 中安装扩展，我们还将支持比 Live Preview 更高级的工作流。从极狐GitLab 15.9 开始，Web IDE 中不再提供 Live Preview。

<a id="omniauth-authentiq-gem-no-longer-available"></a>

### `omniauth-authentiq` gem 不再可用

- 在极狐GitLab 15.9 中宣布
- 在极狐GitLab 15.9 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389452)。

`omniauth-authentiq` 是极狐GitLab 的一部分，是一个 OmniAuth 策略 gem。提供认证服务的公司 Authentiq 已关闭。因此，该 gem 正在被移除。

<a id="gitlab-157"></a>

## 极狐GitLab 15.7

<a id="file-type-variable-expansion-in-gitlab-ciyml"></a>

### `.gitlab-ci.yml`中的文件类型变量扩展

- 在极狐GitLab 15.5 中宣布
- 在极狐GitLab 15.7 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/29407)。

此前，引用或应用别名文件变量的变量会扩展 `File` 类型变量的值。例如，文件内容。此行为是不正确的，因为它不符合典型的 shell 变量扩展规则。为了泄露存储在 `File` 类型变量中的密钥或敏感信息，用户可以运行带有该变量作为输入参数的 $echo 命令。

此重大变更修复了此问题，但可能会破坏围绕该行为进行变通的用户工作流。通过此变更，引用或应用别名文件变量的作业变量扩展将扩展为 `File` 类型变量的文件名或路径，而不是其值（例如文件内容）。

<a id="flowdock-integration"></a>

### Flowdock 集成

- 在极狐GitLab 15.7 中宣布
- 在极狐GitLab 15.7 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/379197)。

自 2022 年 12 月 22 日起，我们将移除 Flowdock 集成，因为该服务已于 2022 年 8 月 15 日关闭。

<a id="gitlab-156"></a>

## 极狐GitLab 15.6

<a id="nfs-for-git-repository-storage"></a>

### 用于 Git 代码仓库存储的 NFS

- 在极狐GitLab 14.0 中宣布
- 在极狐GitLab 15.6 中移除

随着 Gitaly 集群的正式发布（[在极狐GitLab 13.0 中引入](https://about.gitlab.com/releases/2020/05/22/gitlab-13-0-released/)），我们已在极狐GitLab 14.0 中弃用了用于 Git 代码仓库存储的 NFS 的开发（错误修复、性能改进等）。我们将在整个 14.x 期间继续为 Git 代码仓库的 NFS 提供技术支持，但我们将在 2022 年 11 月 22 日移除对 NFS 的所有支持。这最初计划于 2022 年 5 月 22 日进行，但为了让 Gitaly 集群持续成熟，我们选择延长了弃用支持日期。请参阅我们的官方[支持声明](https://gitlab.cn/support)以获取更多信息。

Gitaly 集群为我们的客户提供了巨大的好处，例如：

- [可变复制因子](https://gitlab.cn/docs/jh/administration/gitaly/#replication-factor)。
- [强一致性](https://gitlab.cn/docs/jh/administration/gitaly/#strong-consistency)。
- [分布式读取能力](https://gitlab.cn/docs/jh/administration/gitaly/#distributed-reads)。

我们鼓励目前使用 NFS 存储 Git 代码仓库的客户通过查看我们关于[迁移到 Gitaly 集群](https://gitlab.cn/docs/jh/administration/gitaly/#migrate-to-gitaly-cluster)的文档来规划他们的迁移。

<a id="gitlab-154"></a>

## 极狐GitLab 15.4

<a id="bundled-grafana-deprecated"></a>

### 内置 Grafana 已弃用

- 在极狐GitLab 15.3 中宣布
- 在极狐GitLab 15.4 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6972)。

在极狐GitLab 15.4 中，我们将把内置的 Grafana 替换为由 GitLab 维护的 Grafana fork。

[已发现 Grafana 的一个 CVE](https://nvd.nist.gov/vuln/detail/CVE-2022-31107)，为了缓解此安全漏洞，GitLab 必须切换到其自己的 fork，因为我们捆绑的旧版本 Grafana 不再获得长期支持。

预计这不会与之前版本的 Grafana 产生任何不兼容。无论是使用我们捆绑的版本，还是使用外部的 Grafana 实例。

<a id="sast-analyzer-consolidation-and-cicd-template-changes"></a>

### SAST 分析器整合和 CI/CD 模板变更

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.4 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352554)。

极狐GitLab SAST 使用各种[分析器](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/)来扫描代码中的漏洞。

作为我们长期战略的一部分，我们正在减少极狐GitLab SAST 中使用的分析器数量，以提供更好、更一致的用户体验。精简分析器集合还将实现更快的迭代、更好的结果和更高的效率（在大多数情况下包括减少 CI Runner 的使用）。

在极狐GitLab 15.4 中，极狐GitLab SAST 将不再使用以下分析器：

- [ESLint](https://gitlab.com/gitlab-org/security-products/analyzers/eslint)（JavaScript、TypeScript、React）
- [Gosec](https://gitlab.com/gitlab-org/security-products/analyzers/gosec)（Go）
- [Bandit](https://gitlab.com/gitlab-org/security-products/analyzers/bandit)（Python）

> [!note]
> 此变更最初计划在极狐GitLab 15.0 中进行，后来推迟到极狐GitLab 15.4。

这些分析器将从 [GitLab 管理的 SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)中移除，并替换为[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)。
它们将立即仅接收安全更新；不保证提供其他常规改进或更新。这些分析器达到停止支持状态后，将不再提供任何更新。我们不会删除此前为这些分析器发布的容器镜像；任何此类变更都将作为弃用、移除或重大变更公告发布。

我们还将从 [SpotBugs](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs) 分析器的范围中移除 Java，并将其替换为[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)。
此变更将使扫描 Java 代码更简单；不再需要编译。
此变更将反映在 [GitLab 管理的 SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)的自动语言检测部分中。请注意，基于 SpotBugs 的分析器将继续覆盖 Groovy、Kotlin 和 Scala。

如果您已经忽略了来自某个已弃用分析器的漏洞发现，替换分析器会尝试尊重您之前的忽略操作。系统行为取决于：

- 您过去是否排除了基于 Semgrep 的分析器运行。
- 哪个分析器首先发现了项目漏洞报告中显示的漏洞。

有关更多详细信息，请参阅[漏洞转换文档](https://gitlab.cn/docs/jh/user/application_security/sast/analyzers/#vulnerability-translation)。

如果您对任何受影响的分析器应用了自定义设置，或者您当前在流水线中禁用了 Semgrep 分析器，则必须按照[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352554#breaking-change)中的详细说明采取行动。

<a id="gitlab-153"></a>

## 极狐GitLab 15.3

<a id="vulnerability-report-sort-by-state"></a>

### 按状态排序漏洞报告

- 在极狐GitLab 15.0 中宣布
- 在极狐GitLab 15.3 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/360516)。

由于底层数据模型的重构，按 `State` 列对漏洞报告进行排序的功能在极狐GitLab 14.10 中已被禁用，并改由功能标志控制。由于需要进一步重构以确保按此值排序保持高性能，该功能标志一直默认关闭。由于使用 `State` 列进行排序的使用率非常低，因此将移除此功能标志，以简化代码库并防止任何不必要的性能下降。

<a id="vulnerability-report-sort-by-tool"></a>

### 按工具排序漏洞报告

- 在极狐GitLab 15.1 中宣布
- 在极狐GitLab 15.3 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/362962)。

由于底层数据模型的重构，按 `Tool` 列（扫描类型）对漏洞报告进行排序的功能在极狐GitLab 14.10 中已被禁用，并改由功能标志控制。由于需要进一步重构以确保按此值排序保持高性能，该功能标志一直默认关闭。由于使用 `Tool` 列进行排序的使用率非常低，因此将在极狐GitLab 15.3 中移除此功能标志，以简化代码库并防止任何不必要的性能下降。

<a id="gitlab-151"></a>

## 极狐GitLab 15.1

<a id="deprecate-support-for-debian-9"></a>

### 弃用对 Debian 9 的支持

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.1 中移除

[Debian 9 Stretch 的长期服务和支持（LTSS）于 2022 年 7 月结束](https://wiki.debian.org/LTS)。因此，我们将不再为极狐GitLab 软件包支持 Debian 9 发行版。用户可以升级到 Debian 10 或 Debian 11。

<a id="gitlab-150"></a>

## 极狐GitLab 15.0

<a id="audit-events-for-repository-push-events"></a>

### 代码仓库推送事件的审计事件

- 在极狐GitLab 14.3 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/337993)。

**代码仓库事件**的审计事件现已弃用，并将在极狐GitLab 15.0 中移除。

这些事件一直默认禁用，必须通过功能标志手动启用。启用它们可能会导致生成过多事件，从而严重拖慢极狐GitLab 实例。因此，它们正在被移除。

<a id="background-upload-for-object-storage"></a>

### 对象存储的后台上传

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/26600)。

为了降低[对象存储功能](https://gitlab.cn/docs/jh/administration/object_storage/)的整体复杂性和维护负担，使用 `background_upload` 上传文件的支持已弃用，并将在极狐GitLab 15.0 中完全移除。请查看 [15.0 特定变更](https://gitlab.cn/docs/omnibus/update/gitlab_15_changes/)中[已移除的对象存储后台上传设置](https://gitlab.cn/docs/omnibus/update/gitlab_15_changes/#removed-background-uploads-settings-for-object-storage)。

这会影响一小部分对象存储提供商：

- **OpenStack** 使用 OpenStack 的客户需要将其配置更改为使用 S3 API 而不是 Swift。
- **RackSpace** 使用基于 RackSpace 的对象存储的客户需要将数据迁移到其他提供商。

GitLab 将发布额外的指南，以协助受影响的客户进行迁移。

<a id="cicd-job-name-length-limit"></a>

### CI/CD 作业名称长度限制

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/342800)。

在极狐GitLab 15.0 中，我们将把 CI/CD 作业名称的字符数限制为 255。任何作业名称超过 255 个字符限制的流水线将在 15.0 版本发布后停止工作。

<a id="changing-an-instance-shared-runner-to-a-project-specific-runner"></a>

### 将实例（共享）Runner 更改为项目（特定）Runner

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345347)。

在极狐GitLab 15.0 中，您不能再将实例（共享）Runner 更改为项目（特定）Runner。

用户经常意外地将实例 Runner 更改为项目 Runner，并且无法将其更改回来。由于安全影响，极狐GitLab 不允许您将项目 Runner 更改为共享 Runner。为一个项目准备的 Runner 可能会被设置为整个实例运行作业。

需要为多个项目添加 Runner 的管理员可以先为一个项目注册 Runner，然后转到管理员视图并选择其他项目。

<a id="container-network-and-host-security"></a>

### 容器网络和主机安全

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

与极狐GitLab 容器网络安全和容器主机安全类别相关的所有功能在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。需要此功能替代方案的用户建议评估以下开源项目，作为可以在极狐GitLab 之外安装和管理的潜在解决方案：
[AppArmor](https://gitlab.com/apparmor/apparmor)、
[Cilium](https://github.com/cilium/cilium)、
[Falco](https://github.com/falcosecurity/falco)、
[FluentD](https://github.com/fluent/fluentd)、
[Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)。

要将这些技术集成到极狐GitLab 中，请将所需的 Helm chart 添加到您的[集群管理项目模板](https://gitlab.cn/docs/jh/user/clusters/management_project_template/)副本中。
通过极狐GitLab [CI/CD](https://gitlab.cn/docs/jh/user/clusters/agent/ci_cd_workflow/) 调用命令，在生产环境中部署这些 Helm chart。

作为此变更的一部分，极狐GitLab 中的以下特定功能现已弃用，并计划在极狐GitLab 15.0 中移除：

- **安全与合规** > **威胁监控** 页面。
- **安全与合规** > **策略** 页面上的 `Network Policy` 安全策略类型。
- 通过极狐GitLab 管理与以下技术集成的能力：AppArmor、Cilium、Falco、FluentD 和 Pod Security Policies。
- 与上述功能相关的所有 API。

有关更多背景信息，或提供有关此变更的反馈，请参考我们开放的[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/7476)。

<a id="container-scanning-schemas-below-1400"></a>

### 低于 14.0.0 的容器扫描模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[容器扫描报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)早于 14.0.0 的版本将不再在极狐GitLab 15.0 中受支持。未通过报告中声明的模式版本验证的报告也将不再在极狐GitLab 15.0 中受支持。

[通过输出容器扫描安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的第三方工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确模式。版本较低或未能根据声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示[警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="coverage-guided-fuzzing-schemas-below-1400"></a>

### 低于 14.0.0 的覆盖率引导模糊测试模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[覆盖率引导模糊测试报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)低于 14.0.0 的版本将不再在极狐GitLab 15.0 中受支持。未通过报告中声明的模式版本验证的报告也将不再在极狐GitLab 15.0 中受支持。

[通过输出覆盖率引导模糊测试安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的第三方工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确模式。任何版本较低或未能根据声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示[警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="dast-schemas-below-1400"></a>

### 低于 14.0.0 的 DAST 模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[DAST 报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)早于 14.0.0 的版本将不再在极狐GitLab 15.0 中受支持。未通过报告中声明的模式版本验证的报告也将从极狐GitLab 15.0 起不再受支持。

[通过输出 DAST 安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的第三方工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确模式。版本较低或未能根据声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将导致在漏洞报告中[显示警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="dependency-scanning-python-39-and-36-image-deprecation"></a>

### 依赖扫描 Python 3.9 和 3.6 镜像弃用

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/334060)。

对于使用依赖扫描的 Python 项目，我们正在弃用使用 Python 3.6 的默认 `gemnasium-python:2` 镜像以及使用 Python 3.9 的自定义 `gemnasium-python:2-python-3.9` 镜像。从极狐GitLab 15.0 开始，新的默认镜像将用于 Python 3.9，因为它是[受支持的版本](https://endoflife.date/python)，而 3.6 [已不再受支持](https://endoflife.date/python)。

对于使用 Python 3.9 或与 3.9 兼容的项目的用户，您无需采取任何行动，依赖扫描应该会在极狐GitLab 15.0 中开始工作。如果您希望现在测试新容器，请使用此容器（将在 15.0 中移除）在您的项目中运行测试流水线。使用 Python 3.9 镜像：

```yaml
gemnasium-python-dependency_scanning:
  image:
    name: registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python:2-python-3.9
```

对于使用 Python 3.6 的用户，从极狐GitLab 15.0 开始，您将无法再使用依赖扫描的默认模板。您需要切换到使用已弃用的 `gemnasium-python:2` 分析器镜像。如果您受此影响，请在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351503)中发表评论，以便我们在需要时延长移除时间。

对于使用 3.9 特殊例外镜像的用户，您必须改用默认值，并且不再覆盖您的容器。要验证您是否正在使用 3.9 特殊例外镜像，请检查您的 `.gitlab-ci.yml` 文件中是否有以下引用：

```yaml
gemnasium-python-dependency_scanning:
  image:
    name: registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python:2-python-3.9
```

<a id="dependency-scanning-default-java-version-changed-to-17"></a>

### 依赖扫描默认 Java 版本更改为 17

- 在极狐GitLab 14.10 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

在极狐GitLab 15.0 中，对于依赖扫描，扫描器期望的默认 Java 版本将从 11 更新到 17。Java 17 是[最新的长期支持（LTS）版本](https://en.wikipedia.org/wiki/Java_version_history)。依赖扫描继续支持相同的[版本范围（8、11、13、14、15、16、17）](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/#supported-languages-and-package-managers)，只有默认版本在变化。如果您的项目使用之前的默认版本 Java 11，请务必[设置 `DS_Java_Version` 变量以匹配](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/#configuring-specific-analyzers-used-by-dependency-scanning)。

<a id="dependency-scanning-schemas-below-1400"></a>

### 低于 14.0.0 的依赖扫描模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[依赖扫描报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)早于 14.0.0 的版本将不再在极狐GitLab 15.0 中受支持。未通过报告中声明的模式版本验证的报告也将从极狐GitLab 15.0 起不再受支持。

[通过输出依赖扫描安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的第三方工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确模式。版本较低或未能根据声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将导致在漏洞报告中[显示警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="deprecate-geo-admin-ui-routes"></a>

### 弃用 Geo 管理 UI 路由

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351345)。

在极狐GitLab 13.0 中，我们在 Geo 管理 UI 中引入了新的项目和设计复制详情路由。这些路由是 `/admin/geo/replication/projects` 和 `/admin/geo/replication/designs`。我们保留了旧路由并将其重定向到新路由。在极狐GitLab 15.0 中，我们将移除对旧路由 `/admin/geo/projects` 和 `/admin/geo/designs`的支持。请更新任何可能使用旧路由的书签或脚本。

<a id="deprecate-custom-geodb-rake-tasks"></a>

### 弃用自定义 Geo:db:* Rake 任务

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351945)。

在极狐GitLab 14.8 中，我们正在[用内置任务替换 `geo:db:*` Rake 任务](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/77269/diffs)，这些内置任务在[将 Geo 跟踪数据库切换为使用 Rails 6 的多数据库支持](https://gitlab.com/groups/gitlab-org/-/epics/6458)后成为可能。
以下 `geo:db:*` 任务将被其对应的 `db:*:geo` 任务替换：

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

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/262019)。

功能标志 `PUSH_RULES_SUPERSEDE_CODE_OWNERS` 正在极狐GitLab 15.0 中移除。移除后，推送规则将优先于代码所有者。即使需要代码所有者批准，明确允许特定用户推送代码的推送规则也会优先于代码所有者设置。

<a id="elasticsearch-68"></a>

### Elasticsearch 6.8

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/350275)。

Elasticsearch 6.8 在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。
使用 Elasticsearch 6.8 的客户需要在升级到极狐GitLab 15.0 之前将其 Elasticsearch 版本升级到 7.x。
我们建议使用最新版本的 Elasticsearch 7，以受益于所有 Elasticsearch 改进。

Elasticsearch 6.8 也与 Amazon OpenSearch 不兼容，我们[计划在极狐GitLab 15.0 中支持](https://gitlab.com/gitlab-org/gitlab/-/issues/327560)。

<a id="enforced-validation-of-security-report-schemas"></a>

### 强制验证安全报告模式

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/-/epics/6968)。

[安全报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)早于 14.0.0 的版本将不再在极狐GitLab 15.0 中受支持。未通过报告中声明的模式版本验证的报告也将不再在极狐GitLab 15.0 中受支持。

[通过输出安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的安全工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确模式。版本较低或未能根据声明的模式版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为了帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示[警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="external-status-check-api-breaking-changes"></a>

### 外部状态检查 API 重大变更

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

[外部状态检查 API](https://gitlab.cn/docs/jh/api/status_checks/) 最初是为了支持默认通过的请求以将状态检查标记为通过而实现的。默认通过的请求现已弃用。具体来说，以下内容已弃用：

- 不包含 `status` 字段的请求。
- 将 `status` 字段设置为 `approved`的请求。

从极狐GitLab 15.0 开始，仅当 `status` 字段存在且设置为 `passed` 时，状态检查才会更新为通过状态。以下请求：

- 不包含 `status` 字段的请求将被拒绝，并返回 `422` 错误。有关更多信息，请参阅[相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/338827)。
- 包含除 `passed` 以外的任何值的请求将导致状态检查失败。有关更多信息，请参阅[相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/339039)。

为了与此变更保持一致，列出外部状态检查的 API 调用也将为已通过的状态检查返回 `passed`的值，而不是 `approved`。

<a id="gitlab-pages-running-as-daemon"></a>

### GitLab Pages 以守护进程模式运行

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除

在 15.0 中，将移除对 GitLab Pages 守护进程模式的支持。

<a id="gitlab-serverless"></a>

### 极狐GitLab Serverless

- 在极狐GitLab 14.3 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/configure/-/epics/6)。

极狐GitLab Serverless 是一组功能，用于支持基于 Knative 的无服务器开发，并提供自动部署和监控。

我们决定移除极狐GitLab Serverless 功能，因为它们从未真正引起用户的共鸣。此外，鉴于 Kubernetes 和 Knative 的持续发展，我们当前的实现甚至无法与最新版本一起使用。

<a id="godep-support-in-license-compliance"></a>

### 许可证合规中的 Godep 支持

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除
- 要讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/327057)。

Go 的 Godep 依赖管理器已于 2020 年被 Go 弃用，并已被 Go modules 取代。
为了降低维护成本，我们从 14.7 开始弃用对 Godep 项目的许可证合规支持，并将在极狐GitLab 15.0 中移除。

<a id="graphql-id-and-globalid-compatibility"></a>

### GraphQL ID 与 GlobalID 兼容性

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/257883)。

我们正在移除 GraphQL 处理器中的一个非标准扩展，该扩展是为了向后兼容而添加的。此扩展修改了 GraphQL 查询的验证方式，允许在通常会被拒绝的参数上使用 `ID` 类型。一些参数原本的类型是 `ID`。这些参数已更改为特定类型的
`ID`。如果您符合以下情况，此变更可能会成为重大变更：

- 使用 GraphQL。
- 在查询签名中为任何参数使用 `ID` 类型。

一些字段参数仍然使用 `ID` 类型。这些通常用于 IID 值或命名空间路径。例如 `Query.project(fullPath: ID!)`。

如需查看受影响和未受影响的字段参数列表，
请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352832)。

您可以通过使用从极狐GitLab 服务器获取的 schema 数据在本地验证您的查询，来测试此变更是否会影响您。
您可以使用相关极狐GitLab 实例的 GraphQL explorer 工具来完成此操作。
例如：`https://gitlab.com/-/graphql-explorer`。

例如，以下查询说明了此重大变更：

```graphql
# a query using the deprecated type of Query.issue(id:)
# WARNING: This will not work after GitLab 15.0
query($id: ID!) {
  deprecated: issue(id: $id) {
    title, description
  }
}
```

上面的查询在极狐GitLab 15.0 发布后将无法使用，因为
`Query.issue(id:)`的类型实际上是 `IssueID!`。

相反，您应该使用以下两种形式之一：

```graphql
# This will continue to work
query($id: IssueID!) {
  a: issue(id: $id) {
    title, description
  }
  b: issue(id: "gid://gitlab/Issue/12345") {
    title, description
  }
}
```

此查询现在可以使用，并且在极狐GitLab 15.0 之后将继续有效。您应该将第一种形式（在签名中使用 `ID` 作为命名类型）的任何查询转换为其他两种形式之一（在签名中使用正确的适当类型，或使用内联参数表达式）。

<a id="graphql-permissions-change-for-package-settings"></a>

### 软件包设置的 GraphQL 权限变更

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

极狐GitLab 软件包阶段提供软件包仓库、容器镜像仓库和依赖代理，帮助您使用极狐GitLab 管理所有依赖项。这些产品类别中的每一个都有各种可以使用 API 调整的设置。

GraphQL 的权限模型正在更新。15.0 之后，具有访客、报告者和开发者角色的用户将无法再更新以下设置：

- [软件包仓库设置](https://gitlab.cn/docs/jh/api/graphql/reference/#packagesettings)
- [容器镜像仓库清理策略](https://gitlab.cn/docs/jh/api/graphql/reference/#containerexpirationpolicy)
- [依赖代理生存时间策略](https://gitlab.cn/docs/jh/api/graphql/reference/#dependencyproxyimagettlgrouppolicy)
- [为您的群组启用依赖代理](https://gitlab.cn/docs/jh/api/graphql/reference/#dependencyproxysetting)

<a id="known-host-required-for-gitlab-runner-ssh-executor"></a>

### 极狐GitLab Runner SSH 执行器需要已知主机

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28192)。

在[极狐GitLab 14.3](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/3074)中，我们在极狐GitLab Runner 的 `config.toml` 文件中添加了一个配置设置。此设置 [`[runners.ssh.disable_strict_host_key_checking]`](https://gitlab.cn/docs/runner/executors/ssh/#security) 控制是否对 SSH 执行器使用严格的主机密钥检查。

在极狐GitLab 15.0 及更高版本中，此配置选项的默认值将从 `true` 更改为 `false`。这意味着在使用极狐GitLab Runner SSH 执行器时将强制执行严格的主机密钥检查。

<a id="legacy-approval-status-names-from-license-compliance-api"></a>

### 许可证合规 API 中的旧审批状态名称

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/335707)。

我们在 `managed_licenses` API 中弃用了许可证策略审批状态的旧名称（`blacklisted`、`approved`），但它们仍用于我们的 API 查询和响应中。它们将在 15.0 中移除。

如果您正在使用我们的许可证合规 API，您应该停止使用 `approved` 和 `blacklisted` 查询参数，它们现在是 `allowed` 和 `denied`。在 15.0 中，响应也将停止使用 `approved` 和 `blacklisted`，因此您需要调整任何自定义工具以同时使用旧值和新值，以免在 15.0 版本中发生故障。

<a id="legacy-database-configuration"></a>

### 旧版数据库配置

- 在极狐GitLab 14.3 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/338182)。

位于 `database.yml`中的[极狐GitLab 数据库](https://gitlab.cn/docs/omnibus/settings/database/)
配置语法正在发生变化，旧格式已被弃用。旧格式支持使用单个 PostgreSQL 适配器，而新格式正在更改为支持多个数据库。`main:` 数据库需要定义为第一个配置项。

此弃用主要影响从源代码编译极狐GitLab 的用户，因为 Omnibus 将自动处理此配置。

<a id="logging-in-gitlab"></a>

### 极狐GitLab 中的日志记录

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/346485)。

极狐GitLab 中的日志记录功能允许用户安装 ELK 技术栈（Elasticsearch、Logstash 和 Kibana）来聚合和管理应用程序日志。用户可以在极狐GitLab 中搜索相关日志。但是，自从弃用与 Kubernetes 集群和极狐GitLab 托管应用的基于证书的集成以来，我们没有推荐的极狐GitLab 内日志记录解决方案。如需了解更多信息，您可以关注[将 Opstrace 与 GitLab 集成](https://gitlab.com/groups/gitlab-org/-/epics/6976)的议题。

<a id="move-custom_hooks_dir-setting-from-gitlab-shell-to-gitaly"></a>

### 将 `custom_hooks_dir` 设置从 GitLab Shell 移至 Gitaly

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除

[`custom_hooks_dir`](https://gitlab.cn/docs/jh/administration/server_hooks/#create-a-global-server-hook-for-all-repositories) 设置现在在 Gitaly 中配置，并将在极狐GitLab 15.0 中从 GitLab Shell 移除。

<a id="oauth-implicit-grant"></a>

### OAuth 隐式授权

- 在极狐GitLab 14.0 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

OAuth 隐式授权流程将在我们的下一个主要版本极狐GitLab 15.0 中移除。任何使用 OAuth 隐式授权的应用程序都应切换到其他[受支持的 OAuth 流程](https://gitlab.cn/docs/jh/api/oauth2/)。

<a id="oauth-tokens-without-expiration"></a>

### 无过期时间的 OAuth 令牌

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

默认情况下，所有新应用程序的访问令牌在 2 小时后过期。在极狐GitLab 14.2 及更早版本中，OAuth 访问令牌没有过期时间。在极狐GitLab 15.0 中，将为任何尚未有过期时间的现有令牌自动生成过期时间。

您应该在极狐GitLab 15.0 发布之前[选择启用](https://gitlab.cn/docs/jh/integration/oauth_provider/#access-token-expiration)令牌过期：

1. 编辑应用程序。
1. 选择**使访问令牌过期**以启用它们。令牌必须被撤销，否则它们不会过期。

<a id="omniauth-kerberos-gem"></a>

### OmniAuth Kerberos gem

- 在极狐GitLab 14.3 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/337384)。

`omniauth-kerberos` gem 将在我们的下一个主要版本极狐GitLab 15.0 中移除。

此 gem 一直未被维护，使用量也非常少。因此，我们计划移除对这种身份验证方法的支持，并建议改用 Kerberos [SPNEGO](https://en.wikipedia.org/wiki/SPNEGO) 集成。您可以按照[升级说明](https://gitlab.cn/docs/jh/integration/kerberos/#upgrading-from-password-based-to-ticket-based-kerberos-sign-ins)从 `omniauth-kerberos` 集成升级到受支持的集成。

请注意，我们并未弃用 Kerberos SPNEGO 集成，只是弃用了旧的基于密码的 Kerberos 集成。

<a id="optional-enforcement-of-pat-expiration"></a>

### PAT 过期时间的可选强制执行

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351962)。

从安全角度来看，禁用 PAT 过期时间强制执行的功能很不寻常。我们开始担心这种不寻常的功能可能会给用户带来意外行为。安全功能中的意外行为本身就具有危险性，因此我们决定移除此功能。

<a id="optional-enforcement-of-ssh-expiration"></a>

### SSH 过期时间的可选强制执行

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351963)。

从安全角度来看，禁用 SSH 过期时间强制执行的功能很不寻常。我们开始担心这种不寻常的功能可能会给用户带来意外行为。安全功能中的意外行为本身就具有危险性，因此我们决定移除此功能。

<a id="out-of-the-box-sast-support-for-java-8"></a>

### 对 Java 8 的开箱即用 SAST 支持

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352549)。

[GitLab SAST SpotBugs 分析器](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs)扫描 [Java、Scala、Groovy 和 Kotlin 代码](https://gitlab.cn/docs/jh/user/application_security/sast/#supported-languages-and-frameworks)以查找安全漏洞。
由于技术原因，分析器必须先编译代码才能进行扫描。
除非您使用[预编译策略](https://gitlab.cn/docs/jh/user/application_security/sast/#pre-compilation)，否则分析器会尝试自动编译您项目的代码。

在 15.0 之前的极狐GitLab 版本中，分析器镜像包含 Java 8 和 Java 11 运行时以方便编译。

在极狐GitLab 15.0 中，我们将：

- 从分析器镜像中移除 Java 8 以减小镜像大小。
- 向分析器镜像中添加 Java 17，以便更轻松地使用 Java 17 进行编译。

如果您依赖分析器环境中存在的 Java 8，则必须按照[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352549#breaking-change)中的详细说明采取行动。

<a id="outdated-indices-of-advanced-search-migrations"></a>

### 高级搜索迁移的过时索引

- 在极狐GitLab 14.10 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/359133)。

由于高级搜索迁移通常需要在很长一段时间内支持多个代码路径，因此在可以安全清理时进行清理非常重要。我们利用极狐GitLab 主要版本升级作为安全的时间点，来移除对尚未完全迁移的索引的向后兼容性。详情请参阅
[升级文档](https://gitlab.cn/docs/jh/update/package/#upgrading-to-a-new-major-version)。

<a id="pseudonymizer"></a>

### Pseudonymizer

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/219952)。

Pseudonymizer 功能通常未被使用，
可能会在大型数据库中导致生产问题，并且可能干扰对象存储开发。它现在被视为已弃用，并将在极狐GitLab 15.0 中移除。

<a id="querying-usage-trends-via-the-instancestatisticsmeasurements-graphql-node"></a>

### 通过 `instanceStatisticsMeasurements` GraphQL 节点查询使用趋势

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/332323)。

`instanceStatisticsMeasurements` GraphQL 节点已在 13.10 中重命名为 `usageTrendsMeasurements`，旧字段名已被标记为弃用。要修复现有的 GraphQL 查询，请将 `instanceStatisticsMeasurements` 替换为 `usageTrendsMeasurements`。

<a id="request-profiling"></a>

### 请求性能分析

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352488)。

[请求性能分析](https://gitlab.cn/docs/jh/administration/monitoring/performance/)在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。

我们正在努力[整合我们的性能分析工具](https://gitlab.com/groups/gitlab-org/-/epics/7327)并使其更易于访问。
我们[评估了](https://gitlab.com/gitlab-org/gitlab/-/issues/350152)此功能的使用情况，发现它并未被广泛使用。
它还依赖于一些第三方 gem，这些 gem 已不再被积极维护，尚未针对最新版本的 Ruby 进行更新，或者在分析高负载页面时经常崩溃。

如需了解更多信息，请查看[弃用议题的摘要部分](https://gitlab.com/gitlab-org/gitlab/-/issues/352488#deprecation-summary)。

<a id="required-pipeline-configurations-in-premium-tier"></a>

### 专业版中的必需流水线配置

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

[必需的流水线配置](https://gitlab.cn/docs/jh/administration/settings/continuous_integration/#required-pipeline-configuration-deprecated)功能在极狐GitLab 14.8 中针对专业版客户已弃用，并计划在极狐GitLab 15.0 中移除。此功能并未针对极狐GitLab 旗舰版客户弃用。

将此功能移至极狐GitLab 旗舰版的变更旨在帮助我们的功能更好地与我们的定价理念保持一致，因为我们看到对此功能的需求主要来自高管。

此变更还将帮助极狐GitLab 在其分层策略中与其他相关的旗舰版层功能保持一致：
[安全策略](https://gitlab.cn/docs/jh/user/application_security/policies/)和[合规框架流水线](https://gitlab.cn/docs/jh/user/project/settings/#compliance-pipeline-configuration)。

<a id="retire-js-dependency-scanning-tool"></a>

### Retire-JS 依赖扫描工具

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/350510)。

从 14.8 开始，retire.js 作业将从依赖扫描中弃用。在弃用期间，它将继续包含在我们的 CI/CD 模板中。我们将在 2022 年 5 月 22 日的极狐GitLab 15.0 中从依赖扫描中移除 retire.js。JavaScript 扫描功能不会受到影响，因为它仍由 Gemnasium 覆盖。

如果您已使用 DS_EXCLUDED_ANALYZERS 明确排除了 retire.js，则需要在 15.0 中进行清理（移除引用）。如果您已自定义流水线的与 `retire-js-dependency_scanning` 作业相关的依赖扫描配置，您将需要在 15.0 中移除之前切换到 gemnasium-dependency_scanning，以防止您的流水线失败。如果您未使用 DS_EXCLUDED_ANALYZERS 引用 retire.js，或未专门为 retire.js 自定义模板，则无需采取行动。

<a id="sast-schemas-below-1400"></a>

### 低于 14.0.0 的 SAST schema

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[SAST 报告 schema](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
版本早于 14.0.0 的将不再在极狐GitLab 15.0 中受支持。自极狐GitLab 15.0 起，未通过报告中声明的 schema 版本验证的报告也将不再受支持。

[通过输出 SAST 安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的第三方工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确 schema。版本较低或未能通过声明的 schema 版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示
[警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="sast-support-for-net-21"></a>

### 对 .NET 2.1 的 SAST 支持

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352553)。

极狐GitLab SAST Security Code Scan 分析器扫描 .NET 代码以查找安全漏洞。
由于技术原因，分析器必须先构建代码才能进行扫描。

在 15.0 之前的极狐GitLab 版本中，默认分析器镜像（版本 2）包含对以下内容的支持：

- .NET 2.1
- .NET 3.0 和 .NET Core 3.0
- .NET Core 3.1
- .NET 5.0

在极狐GitLab 15.0 中，我们将把此分析器的默认主要版本从版本 2 更改为版本 3。此变更：

- 添加[漏洞的严重性值](https://gitlab.com/gitlab-org/gitlab/-/issues/350408)以及[其他新功能和改进](https://gitlab.com/gitlab-org/security-products/analyzers/security-code-scan/-/blob/master/CHANGELOG.md)。
- 移除 .NET 2.1 支持。
- 添加对 .NET 6.0、Visual Studio 2019 和 Visual Studio 2022 的支持。

版本 3 已在[极狐GitLab 14.6 中宣布](https://about.gitlab.com/releases/2021/12/22/gitlab-14-6-released/#sast-support-for-net-6)，并作为可选升级提供。

如果您依赖分析器镜像中默认存在的 .NET 2.1 支持，则必须按照[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352553#breaking-change)中的详细说明采取行动。

<a id="secret-detection-configuration-variables-deprecated"></a>

### 密钥检测配置变量已弃用

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352565)。

为了使[自定义极狐GitLab 密钥检测](https://gitlab.cn/docs/jh/user/application_security/secret_detection/#customizing-settings)更简单、更可靠，我们正在弃用一些您以前可以在 CI/CD 配置中设置的变量。

以下变量目前允许您自定义历史扫描选项，但与 [GitLab 管理的 CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/Secret-Detection.gitlab-ci.yml)交互不佳，现已弃用：

- `SECRET_DETECTION_COMMIT_FROM`
- `SECRET_DETECTION_COMMIT_TO`
- `SECRET_DETECTION_COMMITS`
- `SECRET_DETECTION_COMMITS_FILE`

`SECRET_DETECTION_ENTROPY_LEVEL` 以前允许您配置仅考虑代码库中字符串熵级别的规则，现已弃用。
这种仅基于熵的规则产生了不可接受的错误结果（误报）数量，不再受支持。

在极狐GitLab 15.0 中，我们将更新密钥检测[分析器](https://gitlab.cn/docs/jh/user/application_security/terminology/#analyzer)以忽略这些已弃用的选项。
您仍然可以通过设置 [`SECRET_DETECTION_HISTORIC_SCAN` CI/CD 变量](https://gitlab.cn/docs/jh/user/application_security/secret_detection/#available-cicd-variables)来配置提交历史的历史扫描。

如需了解更多详情，请参阅[此变更的弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352565)。

<a id="secret-detection-schemas-below-1400"></a>

### 低于 14.0.0 的密钥检测 schema

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除

[密钥检测报告 schema](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
版本早于 14.0.0 的将不再在极狐GitLab 15.0 中受支持。自极狐GitLab 15.0 起，未通过报告中声明的 schema 版本验证的报告也将不再受支持。

[通过输出密钥检测安全报告作为流水线作业产物来与极狐GitLab 集成](https://gitlab.cn/docs/jh/development/integrations/secure/#report)的第三方工具会受到影响。您必须确保所有输出报告都符合最低版本为 14.0.0 的正确 schema。版本较低或未能通过声明的 schema 版本验证的报告将不会被处理，漏洞发现将不会显示在合并请求、流水线或漏洞报告中。

为帮助过渡，从极狐GitLab 14.10 开始，不合规的报告将在漏洞报告中显示
[警告](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)。

<a id="secure-and-protect-analyzer-images-published-in-new-location"></a>

### Secure 和 Protect 分析器镜像发布到新位置

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352564)。

极狐GitLab 使用各种[分析器](https://gitlab.cn/docs/jh/user/application_security/terminology/#analyzer)来[扫描安全漏洞](https://gitlab.cn/docs/jh/user/application_security/)。
每个分析器都作为容器镜像分发。

从极狐GitLab 14.8 开始，新版本的 GitLab Secure 和 Protect 分析器将发布到 `registry.gitlab.com/security-products` 下的新镜像仓库位置。

GitLab 将更新 [GitLab 管理的 CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates/Security)的默认值以反映此变更：

- 对于除容器扫描之外的所有分析器，我们将把变量 `SECURE_ANALYZERS_PREFIX` 更新为新的镜像仓库位置。
- 对于容器扫描，默认镜像地址已经更新。容器扫描没有 `SECURE_ANALYZERS_PREFIX` 变量。

在未来的版本中，GitLab 将停止将镜像发布到 `registry.gitlab.com/gitlab-org/security-products/analyzers`。
一旦发生这种情况，如果您手动拉取镜像并将其推送到单独的镜像仓库，则必须采取行动。这通常是[离线部署](https://gitlab.cn/docs/jh/user/application_security/offline_deployments/)的情况。
否则，您将无法收到进一步的更新。

有关更多详细信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352564)。

<a id="secure-and-protect-analyzer-major-version-update"></a>

### Secure 和 Protect 分析器主要版本更新

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/350936)。

Secure 和 Protect 阶段将随极狐GitLab 15.0 版本一起提升其分析器的主要版本。此次主要版本提升将为分析器提供清晰的划分，区分：

- 在 2022 年 5 月 22 日之前发布的分析器，其生成的报告*不受*严格的 schema 验证约束。
- 在 2022 年 5 月 22 日之后发布的分析器，其生成的报告*受*严格的 schema 验证约束。

如果您未使用默认的包含模板，或已固定分析器版本，则需要更新 CI/CD 作业定义，以移除固定的版本或更新到最新的主要版本。极狐GitLab 12.0-14.10 的用户将继续正常接收分析器更新，直到极狐GitLab 15.0 发布，之后分析器新主要版本中所有新修复的错误和新发布的功能将不会在已弃用的版本中提供，因为根据我们的[维护策略](https://gitlab.cn/docs/jh/policy/maintenance/)，我们不会向后移植错误修复和新功能。所需的安全补丁将在最新的 3 个次要版本中向后移植。具体来说，以下内容正在被弃用，并且在 15.0 极狐GitLab 版本发布后将不再更新：

- API 安全：版本 1
- 容器扫描：版本 4
- 覆盖率引导的模糊测试：版本 2
- 依赖扫描：版本 2
- 动态应用程序安全测试（DAST）：版本 2
- 基础设施即代码（IaC）扫描：版本 1
- 许可证扫描：版本 3
- 密钥检测：版本 3
- 静态应用程序安全测试（SAST）：[所有分析器](https://gitlab.cn/docs/jh/user/application_security/sast/#supported-languages-and-frameworks)的版本 2，但 `gosec` 除外，它目前是版本 3
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
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/347509)。

使用单个进程和端口导出 Sidekiq 指标和健康检查的方式已弃用。支持将在 15.0 中移除。

我们已更新 Sidekiq，使其[从两个独立的进程导出指标和健康检查](https://gitlab.com/groups/gitlab-org/-/epics/6409)，
以提高稳定性和可用性，并防止在极端情况下丢失数据。由于这是两个独立的服务器，因此在 15.0 中需要进行配置更改，以明确为指标和健康检查设置单独的端口。新引入的 `sidekiq['health_checks_*']` 设置应始终在 `gitlab.rb`中设置。
如需了解更多信息，请查看[配置 Sidekiq](https://gitlab.cn/docs/jh/administration/sidekiq/)的文档。

这些变更还需要在 Prometheus 中更新以抓取新端点，或在 k8s 健康检查中更新以指向新的健康检查端口才能正常工作，否则指标或健康检查将会消失。

在弃用期间，这些设置是可选的，极狐GitLab 将默认 Sidekiq 健康检查端口与 `sidekiq_exporter` 使用相同的端口，并且只运行一个服务器（不改变当前行为）。只有在两者都已设置且提供了不同端口的情况下，才会启动一个单独的指标服务器来提供 Sidekiq 指标，类似于 Sidekiq 在 15.0 中的行为方式。

<a id="static-site-editor"></a>

### 静态站点编辑器

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/347137)。

从极狐GitLab 15.0 开始，静态站点编辑器将不再可用。对整个极狐GitLab 的 Markdown 编辑体验的改进将带来类似的好处，但覆盖范围更广。对静态站点编辑器的传入请求将被重定向到 [Web IDE](https://gitlab.cn/docs/jh/user/project/web_ide/)。

静态站点编辑器的当前用户可以查看[文档](https://gitlab.cn/docs/jh/user/project/web_ide/)以获取更多信息，包括如何从现有项目中移除配置文件。

<a id="support-for-sles-12-sp2"></a>

### 对 SLES 12 SP2 的支持

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

SUSE Linux Enterprise Server (SLES) 12 SP2 的长期服务和支持 (LTSS) [已于 2021 年 3 月 31 日结束](https://www.suse.com/lifecycle/)。SP2 上的 CA 证书包含已过期的 DST 根证书，并且不会获得新的 CA 证书包更新。我们已经实施了一些[变通方法](https://gitlab.com/gitlab-org/gitlab-omnibus-builder/-/merge_requests/191)，但我们将无法继续使构建正常运行。

<a id="support-for-grpc-aware-proxy-deployed-between-gitaly-and-rest-of-gitlab"></a>

### 对部署在 Gitaly 与极狐GitLab 其余部分之间的 gRPC 感知代理的支持

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

尽管不推荐也没有文档说明，但可以在 Gitaly 与极狐GitLab 其余部分之间部署 gRPC 感知代理。例如，NGINX 和 Envoy。部署 gRPC 感知代理的能力
[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/352517)。如果您目前对
Gitaly 连接使用 gRPC 感知代理，则应将代理配置更改为使用 TCP 或 TLS 代理（OSI 第 4 层）。

Gitaly 集群在极狐GitLab 13.12 中已与 gRPC 感知代理不兼容。现在，所有极狐GitLab 安装都将与 gRPC 感知代理不兼容，即使没有 Gitaly 集群也是如此。

通过将我们的一些内部 RPC 流量通过自定义协议（而不是 gRPC）发送，我们提高了吞吐量并减少了 Go 垃圾回收延迟。如需了解更多信息，请参阅
[相关史诗](https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/463)。

<a id="test-coverage-project-cicd-setting"></a>

### 测试覆盖率项目 CI/CD 设置

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

为了简化测试覆盖率模式的设置，在极狐GitLab 15.0 中，
[用于测试覆盖率解析的项目设置](https://gitlab.cn/docs/jh/ci/pipelines/settings/#add-test-coverage-results-using-project-settings-removed)
正在被移除。

相反，使用项目的 `.gitlab-ci.yml`，通过 `coverage` 关键字提供正则表达式，以在合并请求中设置测试覆盖率结果。

<a id="tracing-in-gitlab"></a>

### 极狐GitLab 中的追踪

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/346540)。

极狐GitLab 中的追踪是与 Jaeger 的集成，Jaeger 是一个开源的端到端分布式追踪系统。极狐GitLab 用户可以前往其 Jaeger 实例，深入了解已部署应用程序的性能，追踪处理给定请求的每个函数或微服务。极狐GitLab 中的追踪在极狐GitLab 14.7 中已弃用，并计划在 15.0 中移除。要追踪可能的替代方案的工作，请参阅 [Opstrace 与 GitLab 集成](https://gitlab.com/groups/gitlab-org/-/epics/6976)的议题。

<a id="update-to-the-container-registry-group-level-api"></a>

### 容器镜像仓库群组级 API 的更新

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/336912)。

在里程碑 15.0 中，将从[从群组获取镜像仓库](https://gitlab.cn/docs/jh/api/container_registry/#within-a-group)的容器镜像仓库 API 中移除对 `tags` 和 `tags_count` 参数的支持。

`GET /groups/:id/registry/repositories` 端点将保留，但不会返回任何关于标签的信息。要获取关于标签的信息，您可以使用现有的 `GET /registry/repositories/:id` 端点，该端点将继续像今天一样支持 `tags` 和 `tag_count` 选项。后者必须为每个镜像仓库调用一次。

<a id="value-stream-analytics-filtering-calculation-change"></a>

### 价值流分析过滤计算变更

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/343210)。

我们正在更改价值流分析中日期过滤器的工作方式。日期过滤器将不再按议题或合并请求的创建时间进行过滤，而是按给定阶段的结束事件时间进行过滤。在此变更推出后，这将导致完全不同的数据。

如果您监控价值流分析指标并依赖日期过滤器，为避免丢失数据，您必须在此变更之前保存数据。

<a id="vulnerability-check"></a>

### 漏洞检查

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

漏洞检查功能在极狐GitLab 14.8 中已弃用，并计划在极狐GitLab 15.0 中移除。我们鼓励您迁移到新的安全审批功能。您可以通过导航到**安全与合规** > **策略**并创建新的扫描结果策略来完成此操作。

新的安全审批功能类似于漏洞检查。例如，两者都可以要求对包含安全漏洞的合并请求进行审批。但是，安全审批在几个方面改进了以前的体验：

- 用户可以选择允许谁编辑安全审批规则。独立的安全或合规团队因此可以以防止开发项目维护者修改规则的方式管理规则。
- 可以创建多个规则并将其链接在一起，以便为每种扫描器类型按不同的严重性阈值进行过滤。
- 可以对安全审批规则的任何所需更改强制执行两步审批流程。
- 可以将一组安全策略应用于多个开发项目，以便于维护单一、集中的规则集。

<a id="versions-on-base-packagetype"></a>

### 基础 `PackageType` 上的 `Versions`

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/327453)。

作为创建[软件包仓库 GraphQL API](https://gitlab.com/groups/gitlab-org/-/epics/6318) 工作的一部分，软件包组弃用了基础 `PackageType` 类型的 `Version` 类型，并将其移至 [`PackageDetailsType`](https://gitlab.cn/docs/jh/api/graphql/reference/#packagedetailstype)。

在里程碑 15.0 中，我们将从 `PackageType`中完全移除 `Version`。

<a id="apifuzzingciconfigurationcreate-graphql-mutation"></a>

### `apiFuzzingCiConfigurationCreate` GraphQL mutation

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/333233)。

API 模糊测试配置片段现在在客户端生成，不再需要 API 请求。因此，我们正在弃用 `apiFuzzingCiConfigurationCreate` mutation，该 mutation 在极狐GitLab 中已不再使用。

<a id="artifactsreportscobertura-keyword"></a>

### `artifacts:reports:cobertura` 关键字

- 在极狐GitLab 14.7 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/348980)。

目前，极狐GitLab 中的测试覆盖率可视化仅支持 Cobertura 报告。从 15.0 开始，
`artifacts:reports:cobertura` 关键字将被
[`artifacts:reports:coverage_report`](https://gitlab.com/gitlab-org/gitlab/-/issues/344533) 取代。Cobertura 将是
15.0 中唯一受支持的报告文件，但这是极狐GitLab 支持其他报告类型的第一步。

<a id="defaultmergecommitmessagewithdescription-graphql-api-field"></a>

### `defaultMergeCommitMessageWithDescription` GraphQL API 字段

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345451)。

GraphQL API 字段 `defaultMergeCommitMessageWithDescription` 已弃用，并将在极狐GitLab 15.0 中移除。对于设置了提交消息模板的项目，它将忽略该模板。

<a id="dependency_proxy_for_private_groups-feature-flag"></a>

### `dependency_proxy_for_private_groups` 功能标志

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/276777)。

我们添加了一个功能标志，因为 [GitLab-#11582](https://gitlab.com/gitlab-org/gitlab/-/issues/11582) 更改了公共群组使用依赖代理的方式。在此变更之前，您可以在不进行身份验证的情况下使用依赖代理。此变更要求进行身份验证才能使用依赖代理。

在里程碑 15.0 中，我们将完全移除此功能标志。今后，您在使用依赖代理时必须进行身份验证。

<a id="htpasswd-authentication-for-the-container-registry"></a>

### 容器镜像仓库的 `htpasswd` 身份验证

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

容器镜像仓库支持使用 `htpasswd` 进行[身份验证](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#auth)。它依赖于 [Apache `htpasswd` 文件](https://httpd.apache.org/docs/2.4/programs/htpasswd.html)，密码使用 `bcrypt` 进行哈希处理。

由于它未在极狐GitLab（产品）的上下文中使用，`htpasswd` 身份验证将在极狐GitLab 14.9 中弃用，并在极狐GitLab 15.0 中移除。

<a id="pipelines-field-from-the-version-field"></a>

### `version` 字段中的 `pipelines` 字段

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/342882)。

在 GraphQL 中，您可以在 [`PackageDetailsType`](https://gitlab.cn/docs/jh/api/graphql/reference/#packagedetailstype)中使用两个 `pipelines` 字段来获取软件包版本的流水线：

- `versions` 字段的 `pipelines` 字段。这将返回与软件包所有版本关联的所有流水线，这可能会在内存中拉取无限数量的对象并产生性能问题。
- 特定 `version`的 `pipelines` 字段。这仅返回与该单个软件包版本关联的流水线。

为了缓解可能的性能问题，我们将在里程碑 15.0 中移除 `versions` 字段的 `pipelines` 字段。尽管您将无法再获取软件包所有版本的所有流水线，但您仍然可以通过该版本剩余的 `pipelines` 字段获取单个版本的流水线。

<a id="projectfingerprint-in-pipelinesecurityreportfinding-graphql"></a>

### `PipelineSecurityReportFinding` GraphQL 中的 `projectFingerprint`

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

[`PipelineSecurityReportFinding`](https://gitlab.cn/docs/jh/api/graphql/reference/#pipelinesecurityreportfinding)
GraphQL 对象中的 `projectFingerprint` 字段正在被弃用。此字段包含用于确定唯一性的安全发现“指纹”。计算指纹的方法已更改，导致值不同。今后，新值将在 UUID 字段中公开。以前在 `projectFingerprint` 字段中可用的数据最终将被完全移除。

<a id="promote-db-command-from-gitlab-ctl"></a>

### `gitlab-ctl`中的 `promote-db` 命令

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345207)。

在极狐GitLab 14.5 中，我们引入了命令 `gitlab-ctl promote`，用于在故障转移期间将任何 Geo 从节点提升为主节点。此命令取代了 `gitlab-ctl promote-db`，后者用于在多节点 Geo 从站点中提升数据库节点。`gitlab-ctl promote-db` 将继续按原样运行，并一直可用到极狐GitLab 15.0。我们建议 Geo 客户开始在其预发环境中测试新的 `gitlab-ctl promote` 命令，并将新命令纳入其故障转移流程。

<a id="promote-to-primary-node-command-from-gitlab-ctl"></a>

### `gitlab-ctl`中的 `promote-to-primary-node` 命令

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345207)。

在极狐GitLab 14.5 中，我们引入了命令 `gitlab-ctl promote`，用于在故障转移期间将任何 Geo 从节点提升为主节点。此命令取代了 `gitlab-ctl promote-to-primary-node`，后者仅可用于单节点 Geo 站点。`gitlab-ctl promote-to-primary-node` 将继续按原样运行，并一直可用到极狐GitLab 15.0。我们建议 Geo 客户开始在其预发环境中测试新的 `gitlab-ctl promote` 命令，并将新命令纳入其故障转移流程。

<a id="type-and-types-keyword-in-cicd-configuration"></a>

### CI/CD 配置中的 `type` 和 `types` 关键字

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

`type` 和 `types` CI/CD 关键字将在极狐GitLab 15.0 中移除。使用这些关键字的流水线将停止工作，因此您必须切换到具有相同行为的 `stage` 和 `stages`。

<a id="bundler-audit-dependency-scanning-tool"></a>

### bundler-audit 依赖扫描工具

- 在极狐GitLab 14.6 中宣布
- 在极狐GitLab 15.0 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/289832)。

从 14.6 开始，bundler-audit 将从依赖扫描中弃用。在弃用期间，它将继续保留在我们的 CI/CD 模板中。我们将在 2022 年 5 月 22 日的 15.0 中从依赖扫描中移除 bundler-audit。此次移除后，Ruby 扫描功能不会受到影响，因为它仍由 Gemnasium 覆盖。

如果您已使用 DS_EXCLUDED_ANALYZERS 明确排除了 bundler-audit，则需要在 15.0 中进行清理（移除引用）。如果您已自定义流水线的依赖扫描配置，例如编辑 `bundler-audit-dependency_scanning` 作业，您将需要在 15.0 中移除之前切换到 gemnasium-dependency_scanning，以防止您的流水线失败。如果您未使用 DS_EXCLUDED_ANALYZERS 引用 bundler-audit，或未专门为 bundler-audit 自定义模板，则无需采取行动。

<a id="gitlab-1410"></a>

## 极狐GitLab 14.10

<a id="permissions-change-for-downloading-composer-dependencies"></a>

### 下载 Composer 依赖项的权限变更

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 14.10 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）

极狐GitLab Composer 软件包仓库可用于推送、搜索、获取有关 PHP 依赖项的元数据以及下载这些依赖项。除下载依赖项外，所有这些操作都需要身份验证。

无需身份验证即可下载 Composer 依赖项的方式在极狐GitLab 14.9 中已弃用，并将在极狐GitLab 15.0 中移除。从极狐GitLab 15.0 开始，您必须进行身份验证才能下载 Composer 依赖项。

<a id="gitlab-149"></a>

## 极狐GitLab 14.9

<a id="configurable-gitaly-per_repository-election-strategy"></a>

### 可配置的 Gitaly `per_repository` 选举策略

- 在极狐GitLab 14.8 中宣布
- 在极狐GitLab 14.9 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352612)。

配置 `per_repository` Gitaly 选举策略[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/352612)。
自极狐GitLab 14.0 起，`per_repository` 一直是唯一选项。

此变更是保持我们代码库整洁的定期维护的一部分。

<a id="integrated-error-tracking-disabled-by-default"></a>

### 默认禁用集成错误追踪

- 在极狐GitLab 14.9 中宣布
- 在极狐GitLab 14.9 中移除（[重大变更](https://gitlab.cn/docs/jh/update/terminology/#breaking-change)）
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/353639)。

在极狐GitLab 14.4 中，极狐GitLab 发布了一个集成错误追踪后端来取代 Sentry。此功能导致了数据库性能问题。在极狐GitLab 14.9 中，集成错误追踪已从 JihuLab.com 中移除，并在极狐GitLab 私有化部署中默认关闭。在我们探索此功能的未来发展时，请考虑通过[在项目设置中将错误追踪更改为 Sentry](https://gitlab.cn/docs/jh/operations/error_tracking/#sentry-error-tracking) 来切换到 Sentry 后端。

有关此次移除的更多背景信息，请参考[默认禁用集成错误追踪](https://gitlab.com/groups/gitlab-org/-/epics/7580)。如果您有反馈，请在[反馈：移除集成错误追踪](https://gitlab.com/gitlab-org/gitlab/-/issues/355493)中添加评论。

<a id="gitlab-148"></a>

## 极狐GitLab 14.8

<a id="opensuse-leap-152-packages"></a>

### openSUSE Leap 15.2 软件包

- 在极狐GitLab 14.5 中宣布
- 在极狐GitLab 14.8 中移除
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6427)。

openSUSE Leap 15.2 的发行版支持和安全更新[将于 2021 年 12 月结束](https://en.opensuse.org/Lifetime#openSUSE_Leap)。

从 14.5 开始，我们提供 openSUSE Leap 15.3 的软件包，并将在 14.8 里程碑中停止提供 openSUSE Leap 15.2 的软件包。

<a id="gitlab-146"></a>

## 极狐GitLab 14.6

<a id="release-cli-distributed-as-a-generic-package"></a>

### Release CLI 作为通用软件包分发

- 在极狐GitLab 14.2 中宣布
- 在极狐GitLab 14.6 中移除

[release-cli](https://gitlab.com/gitlab-org/release-cli) 将从极狐GitLab 14.2 开始作为[通用软件包](https://gitlab.com/gitlab-org/release-cli/-/packages)发布。GitLab 将继续将其作为二进制文件部署到 S3，直到极狐GitLab 14.5，并在极狐GitLab 14.6 中停止在 S3 中分发。

<a id="gitlab-145"></a>

## 极狐GitLab 14.5

<a id="rename-task-runner-pod-to-toolbox"></a>

### 将 Task Runner Pod 重命名为 Toolbox

- 在极狐GitLab 14.2 中宣布
- 在极狐GitLab 14.5 中移除

Task Runner Pod 用于在极狐GitLab 应用程序中执行定期内务处理任务，并且经常与极狐GitLab Runner 混淆。因此，[Task Runner 将重命名为 Toolbox](https://gitlab.com/groups/gitlab-org/charts/-/epics/25)。

这将导致子 chart 的重命名：`gitlab/task-runner` 重命名为 `gitlab/toolbox`。生成的 Pod 将按照 `{{ .Release.Name }}-toolbox`的格式命名，通常是 `gitlab-toolbox`。它们可以通过标签 `app=toolbox` 定位。

<a id="pending-changes"></a>

## 待定变更

以下变更已从其原定里程碑中移除，正在重新评估。

<a id="codeclimate-based-code-quality-scanning-will-be-removed"></a>

### 将移除基于 CodeClimate 的代码质量扫描

- 于极狐GitLab 17.3 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/471677)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

在极狐GitLab 19.0 中，我们将移除基于 CodeClimate 的代码质量扫描。此变更原计划在极狐GitLab 18.0 中进行，现已推迟。

取而代之，您应直接在 CI/CD 流水线中使用质量工具，并[将工具的报告作为产物提供](https://gitlab.cn/docs/jh/ci/testing/code_quality/#import-code-quality-results-from-a-cicd-job)。我们已经记录了如何直接集成许多工具，您可以按照[文档](https://gitlab.cn/docs/jh/ci/testing/code_quality/#integrate-common-tools-with-code-quality)进行集成。

我们预计通过以下方式实施此变更：

1. 修改 [`Code-Quality.gitlab-ci.yml` CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Code-Quality.gitlab-ci.yml)，使其不再执行扫描。目前，该模板运行基于 CodeClimate 的扫描。（我们计划修改模板而不是删除它，以减少对 19.0 之后仍然 `include` 该模板的任何流水线的影响。）
1. 不再将基于 CodeClimate 的扫描作为 Auto DevOps 的一部分运行。

即刻起，基于 CodeClimate 的扫描将仅获得[有限更新](https://gitlab.cn/docs/jh/update/terminology/#deprecation)。在极狐GitLab 19.0 中支持结束后，我们将不再提供进一步更新。但是，我们不会删除之前发布的容器镜像，也不会移除通过自定义 CI/CD 流水线作业定义运行它们的能力。

有关更多详细信息，请参阅[扫描代码中的质量违规](https://gitlab.cn/docs/jh/ci/testing/code_quality/#scan-code-for-quality-violations)。

<a id="container-registry-legacy-metadata-storage"></a>

### 容器镜像仓库旧版元数据存储

- 于极狐GitLab 18.5 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/571531)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

极狐GitLab 容器镜像仓库的旧版元数据存储方式已被弃用，取而代之的是容器镜像仓库元数据数据库。

GitLab.com 已在使用元数据数据库。此弃用影响当前使用旧版容器镜像仓库、将元数据信息直接存储在存储后端（无论是对象存储还是本地文件系统）中的极狐GitLab 私有化部署实例。

旧版元数据存储方式将继续以维护模式提供支持，但不会获得新功能或改进。我们强烈建议您尽快迁移到容器镜像仓库元数据数据库。

此变更仅影响容器镜像仓库存储镜像和标签元数据的方式。您选择的存储后端（对象存储或文件系统）保持不变。您可以继续将[对象存储](https://gitlab.cn/docs/jh/administration/packages/container_registry/#use-object-storage)或文件系统存储与元数据数据库一起使用。

要从旧版元数据存储迁移到元数据数据库，请遵循[容器镜像仓库元数据数据库迁移指南](https://gitlab.cn/docs/jh/administration/packages/container_registry_metadata_database/)。迁移过程包括启用元数据数据库功能并运行导入工具以传输您现有的镜像仓库数据。

元数据数据库提供更好的性能和可靠性，并支持旧版元数据存储方式所不具备的新容器镜像仓库功能。

<a id="coverage-guided-fuzz-testing-is-deprecated"></a>

### 覆盖率引导的模糊测试已弃用

- 于极狐GitLab 18.0 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/517841)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

覆盖率引导的模糊测试已弃用，从极狐GitLab 18.0 起将不再受支持。该功能将在极狐GitLab 19.0 中完全移除。

覆盖率引导的模糊测试将多个开源模糊测试工具集成到了极狐GitLab 中。如果您受到影响，可以将您的开源模糊测试工具作为独立应用集成，或迁移到其他安全功能，例如[极狐GitLab Advanced SAST](https://gitlab.cn/docs/jh/user/application_security/sast/gitlab_advanced_sast/)。

<a id="dependency-scanning-for-javascript-vendored-libraries"></a>

### JavaScript 内置库的依赖扫描

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501308)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

由 Gemnasium 分析器为依赖扫描提供的 [JavaScript 内置库依赖扫描](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/#javascript)功能已在极狐GitLab 17.9 中弃用。

虽然此功能在使用 Gemnasium 分析器时将继续工作，但在迁移到新的依赖扫描分析器后将不再可用。详情请参阅[迁移指南](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/migration_guide_to_sbom_based_scans/)。

替代功能将随[内置库依赖扫描](https://gitlab.com/groups/gitlab-org/-/epics/7186)一起开发，但尚未确定交付时间表。

<a id="dependency-scanning-upgrades-to-the-gitlab-sbom-vulnerability-scanner"></a>

### 依赖扫描升级到极狐GitLab SBOM 漏洞扫描器

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501308)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

依赖扫描功能正在升级到极狐GitLab SBOM 漏洞扫描器。作为此变更的一部分，Gemnasium 分析器（之前用于 CI/CD 流水线）已在极狐GitLab 17.9 中弃用。

它被[使用 SBOM 的依赖扫描](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/dependency_scanning_sbom/)功能和[新的依赖扫描分析器](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning)所取代，后者专注于检测依赖项及其关系（依赖图），并依赖极狐GitLab 内置的 SBOM 漏洞扫描器来识别其漏洞，该扫描器已被[持续漏洞扫描](https://gitlab.cn/docs/jh/user/application_security/continuous_vulnerability_scanning/)所使用。

从极狐GitLab 18.5 起，此新功能处于限量提供阶段。在大多数用户迁移到新的依赖扫描功能之前，极狐GitLab 将继续支持 Gemnasium 分析器。只有到那时，Gemnasium 分析器才会达到[支持结束](https://gitlab.cn/docs/jh/update/terminology/#end-of-support)状态。

由于此升级引入了重大变更和功能移除，它不会自动实施。使用 Gemnasium 分析器的现有 CI/CD 作业默认将继续运行，以防止对 CI/CD 配置造成中断。

请查看下方完整详细的变更，并参阅[迁移指南](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/migration_guide_to_sbom_based_scans/)以协助您完成过渡。

- 为防止对您的 CI/CD 配置造成中断，当您的应用使用稳定版依赖扫描 CI/CD 模板（`Dependency-Scanning.gitlab-ci.yml`）时，依赖扫描仅使用基于 Gemnasium 分析器的现有 CI/CD 作业。
- 当您的应用使用最新版依赖扫描 CI/CD 模板（`Dependency-Scanning.latest.gitlab-ci.yml`）时，依赖扫描使用基于 Gemnasium 分析器的现有 CI/CD 作业，同时新的依赖扫描分析器也会在受支持的文件类型上运行。您也可以选择为所有项目强制启用新的依赖扫描分析器。
- 随着该功能逐渐成熟，可能会考虑其他迁移路径。
- [Gemnasium 分析器](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium/)项目以及相应的容器镜像（所有标签和变体）均已弃用：`gemnasium`、`gemnasium-maven`、`gemnasium-python`。这些镜像不会从 GitLab 容器镜像仓库中移除。
- 以下与 Gemnasium 分析器关联的 CI/CD 变量也已弃用。虽然这些变量在使用 Gemnasium 分析器时将继续工作，但在迁移到新的依赖扫描分析器后将不再生效。如果某个变量也在其他上下文中使用，则弃用仅适用于依赖扫描功能（例如，`GOOS` 和 `GOARCH` 并非依赖扫描功能专用）。
  `DS_EXCLUDED_ANALYZERS`、`DS_GRADLE_RESOLUTION_POLICY`、`DS_IMAGE_SUFFIX`、`DS_JAVA_VERSION`、`DS_PIP_DEPENDENCY_PATH`、`DS_PIP_VERSION`、`DS_REMEDIATE_TIMEOUT`、`DS_REMEDIATE`、`GEMNASIUM_DB_LOCAL_PATH`、`GEMNASIUM_DB_REF_NAME`、`GEMNASIUM_DB_REMOTE_URL`、`GEMNASIUM_DB_UPDATE_DISABLED`、`GEMNASIUM_LIBRARY_SCAN_ENABLED`、`GOARCH`、`GOFLAGS`、`GOOS`、`GOPRIVATE`、`GRADLE_CLI_OPTS`、`GRADLE_PLUGIN_INIT_PATH`、`MAVEN_CLI_OPTS`、`PIP_EXTRA_INDEX_URL`、`PIP_INDEX_URL`、`PIPENV_PYPI_MIRROR`、`SBT_CLI_OPTS`。
- 以下 [CI/CD 组件](https://gitlab.com/components/dependency-scanning/#components)已弃用：Android、Rust、Swift、CocoaPods。它们被[主依赖扫描 CI/CD 组件](https://gitlab.com/components/dependency-scanning/-/tree/main/templates/main?ref_type=heads)所取代，该组件涵盖所有受支持的语言和软件包管理器。
- [解决漏洞](https://gitlab.cn/docs/jh/user/application_security/vulnerabilities/#resolve-a-vulnerability)功能**对于 Yarn 项目**已在极狐GitLab 17.9 中弃用。虽然此功能在使用 Gemnasium 分析器时将继续工作，但在迁移到新的依赖扫描分析器后将不再可用。有关更多详细信息，请参阅相应的[弃用公告](https://gitlab.cn/docs/jh/update/deprecations/#resolve-a-vulnerability-for-dependency-scanning-on-yarn-projects)。
- [JavaScript 内置库依赖扫描](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/#javascript)功能已在极狐GitLab 17.9 中弃用。虽然此功能在使用 Gemnasium 分析器时将继续工作，但在迁移到新的依赖扫描分析器后将不再可用。有关更多详细信息，请参阅相应的[弃用公告](https://gitlab.cn/docs/jh/update/deprecations/#dependency-scanning-for-javascript-vendored-libraries)。

<a id="gitlab-advanced-sast-will-be-enabled-by-default"></a>

### 极狐GitLab Advanced SAST 将默认启用

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513685)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

在极狐GitLab 19.0 中，我们将更新 [SAST CI/CD 模板](https://gitlab.cn/docs/jh/user/application_security/sast/#stable-vs-latest-sast-templates)，在拥有极狐GitLab 旗舰版的项目中默认启用[极狐GitLab Advanced SAST](https://gitlab.cn/docs/jh/user/application_security/sast/gitlab_advanced_sast/)。在此变更之前，极狐GitLab Advanced SAST 分析器仅在您将 CI/CD 变量 `GITLAB_ADVANCED_SAST_ENABLED` 设置为 `true` 时才会启用。此变更原计划在极狐GitLab 18.0 中进行，现已推迟。

Advanced SAST 通过使用跨文件、跨函数扫描和新的规则集来提供更准确的结果。Advanced SAST 接管[受支持语言](https://gitlab.cn/docs/jh/user/application_security/sast/gitlab_advanced_sast/#supported-languages)的覆盖范围，并在之前的扫描器中禁用对这些语言的扫描。自动化流程会在每个项目默认分支上的首次扫描后迁移之前扫描器的结果（如果这些结果仍能被检测到）。

由于 Advanced SAST 会更详细地扫描您的项目，因此扫描项目可能需要更长时间。如有需要，您可以通过将 CI/CD 变量 `GITLAB_ADVANCED_SAST_ENABLED` 设置为 `false` 来[禁用极狐GitLab Advanced SAST](https://gitlab.cn/docs/jh/user/application_security/sast/gitlab_advanced_sast/#disable-gitlab-advanced-sast-scanning)。您现在就可以在项目、群组或策略中设置此变量，以防止 Advanced SAST 在极狐GitLab 19.0 中默认启用。

<a id="gitlab-runner-docker-machine-executor-is-deprecated"></a>

### 极狐GitLab Runner Docker Machine 执行器已弃用

- 于极狐GitLab 17.5 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/498268)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

[极狐GitLab Runner Docker Machine 执行器](https://gitlab.cn/docs/runner/executors/docker_machine/)已弃用，并将在极狐GitLab 20.0（2027 年 5 月）中作为受支持功能从产品中完全移除。Docker Machine 的替代品——[极狐GitLab Runner 自动扩缩器](https://gitlab.cn/docs/runner/runner_autoscale/)（带有 GitLab 为 Amazon Web Services (AWS) EC2、Google Compute Engine (GCE) 和 Microsoft Azure 虚拟机 (VM) 开发的插件）已正式发布。随着此公告的发布，极狐GitLab Runner 的上游 GitLab 团队将不再接受社区对 GitLab 维护的 Docker Machine fork 的贡献，也不再解决新发现的错误。

<a id="gitlab-runner-platforms-and-setup-instructions-in-graphql-api"></a>

### GraphQL API 中的极狐GitLab Runner 平台和安装说明

- 于极狐GitLab 15.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387937)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

用于获取极狐GitLab Runner 平台和安装说明的 `runnerPlatforms` 和 `runnerSetup` 查询已弃用，并将从 GraphQL API 中移除。有关安装说明，请参阅[极狐GitLab Runner 文档](https://gitlab.cn/docs/runner/)，而不是使用这些 API 查询。

<a id="gitlab-self-managed-certificate-based-integration-with-kubernetes"></a>

### 极狐GitLab 私有化部署基于证书的 Kubernetes 集成

- 于极狐GitLab 14.5 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

基于证书的 Kubernetes 集成[将被弃用并移除](https://about.gitlab.com/blog/deprecating-the-cert-based-kubernetes-integration/)。

对于极狐GitLab 私有化部署，我们在极狐GitLab 15.0 中引入了[功能标志](https://gitlab.cn/docs/jh/administration/feature_flags/#enable-or-disable-the-feature) `certificate_based_clusters`，以便您可以保持基于证书的集成处于启用状态。但是，该功能标志默认将被禁用，因此此变更是一个**破坏性变更**。

如需更强大、更安全、更具前瞻性且更可靠的 Kubernetes 集成，请使用[极狐GitLab Kubernetes Agent](https://gitlab.cn/docs/jh/user/clusters/agent/) 将 Kubernetes 集群与极狐GitLab 连接。有关此迁移的信息，请参阅[迁移到极狐GitLab Kubernetes Agent](https://gitlab.cn/docs/jh/user/infrastructure/clusters/migrate_to_gitlab_agent/)。

在新解决方案实现功能对等之前，极狐GitLab 不会移除此功能。有关移除阻碍因素的更多信息，请参阅[议题 199](https://gitlab.com/gitlab-org/configure/general/-/issues/199)。

有关此弃用的更新和详细信息，请参阅 [epic 8](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

<a id="gitlabcom-certificate-based-integration-with-kubernetes"></a>

### JihuLab.com 基于证书的 Kubernetes 集成

- 于极狐GitLab 14.5 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

基于证书的 Kubernetes 集成将被[弃用并移除](https://about.gitlab.com/blog/deprecating-the-cert-based-kubernetes-integration/)。作为 JihuLab.com 用户，从极狐GitLab 15.0 起，您将无法再在新命名空间中使用基于证书的方法集成极狐GitLab 和您的集群。当前用户的集成将按命名空间启用。

如需更强大、更安全、更具前瞻性且更可靠的 Kubernetes 集成，我们建议您使用[极狐GitLab Kubernetes Agent](https://gitlab.cn/docs/jh/user/clusters/agent/) 将 Kubernetes 集群与极狐GitLab 连接。[我该如何迁移？](https://gitlab.cn/docs/jh/user/infrastructure/clusters/migrate_to_gitlab_agent/)

有关此弃用的更新和详细信息，请关注[此 epic](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

极狐GitLab 私有化部署客户仍然可以[通过功能标志](https://gitlab.cn/docs/jh/update/deprecations/#self-managed-certificate-based-integration-with-kubernetes)使用该功能。

<a id="graphql-deprecation-of-dependencyproxytotalsizeinbytes-field"></a>

### GraphQL 弃用 `dependencyProxyTotalSizeInBytes` 字段

- 于极狐GitLab 16.1 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414236)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

您可以使用 GraphQL 查询极狐GitLab 依赖代理使用的存储量。但是，`dependencyProxyTotalSizeInBytes` 字段限制在约 2 GB 左右，这对于依赖代理来说并不总是足够大。因此，`dependencyProxyTotalSizeInBytes` 已弃用。

请改用极狐GitLab 16.1 中引入的 `dependencyProxyTotalSizeBytes`。

<a id="group-vulnerability-report-by-owasp-top-10-2017-is-deprecated"></a>

### 按 OWASP Top 10 2017 对漏洞报告进行分组已弃用

- 于极狐GitLab 17.0 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458835)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

按 OWASP Top 10 2017 对漏洞报告进行分组已弃用，取而代之的是按 OWASP Top 10 2021 分组。未来我们将支持在漏洞报告中使用最新版本的 OWASP Top 10 进行分组。伴随此变更，我们还将弃用并移除该功能所使用的 2017 GraphQL API 枚举。更多详细信息包含在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/488433)中。

<a id="increased-default-security-for-use-of-pipeline-variables"></a>

### 提高使用流水线变量的默认安全性

- 于极狐GitLab 17.7 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502382)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

极狐GitLab 信奉默认安全的实践。为此，我们正在做出一些变更，以支持与 CI/CD 变量使用相关的最小权限原则。目前，拥有开发者或更高角色的用户默认即可使用[流水线变量](https://gitlab.cn/docs/jh/ci/variables/#use-pipeline-variables)，无需任何验证或主动选择。

您已经可以通过将最低角色提高到推荐的[仅所有者或无人](https://gitlab.cn/docs/jh/ci/variables/#restrict-pipeline-variables)，开始为流水线变量使用更安全的默认体验。从 17.7 开始，`no one allowed` 是 JihuLab.com 上新命名空间中所有新项目的默认设置。

<a id="opentofu-cicd-template"></a>

### OpenTofu CI/CD 模板

- 于极狐GitLab 17.1 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/components/opentofu/-/issues/43#note_1913822299)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

我们在 16.8 中引入了 OpenTofu CI/CD 模板，因为当时 CI/CD 组件尚不适用于极狐GitLab 私有化部署。随着[适用于极狐GitLab 私有化部署的极狐GitLab CI/CD 组件](https://gitlab.cn/docs/jh/ci/components/#use-a-gitlabcom-component-in-a-self-managed-instance)的推出，我们将移除冗余的 OpenTofu CI/CD 模板，转而使用 CI/CD 组件。

有关从 CI/CD 模板迁移到组件的信息，请参阅 [OpenTofu 组件文档](https://gitlab.com/components/opentofu#usage-on-self-managed)。

<a id="pipeline-execution-policies-inject_ci-strategy-replaced-by-inject_policy"></a>

### 流水线执行策略的 `inject_ci` 策略被 `inject_policy` 取代

- 于极狐GitLab 17.11 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/573447)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

随着流水线执行策略中[自定义阶段](https://gitlab.com/gitlab-org/gitlab/-/issues/475152)的引入（在极狐GitLab 17.9 中可用），我们引入了配置选项 `inject_policy` 来取代已弃用的 `inject_ci`。

这一新策略允许为使用 `inject_ci` 策略的现有流水线执行策略用户平稳地推出自定义阶段功能。

为准备即将到来的移除，请将所有使用 `inject_ci`的流水线执行策略更新为使用 `inject_policy`。

<a id="rate-limits-for-common-user-project-and-group-api-endpoints"></a>

### 常用用户、项目和群组 API 端点的速率限制

- 于极狐GitLab 17.4 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/480914)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

常用[用户](https://gitlab.cn/docs/jh/administration/settings/user_and_ip_rate_limits/)、[项目](https://gitlab.cn/docs/jh/administration/settings/rate_limit_on_projects_api/)和[群组](https://gitlab.cn/docs/jh/administration/settings/rate_limit_on_groups_api/)端点将默认启用速率限制。默认启用这些速率限制有助于提高整体系统稳定性，减少大量 API 使用对更广泛的用户体验产生负面影响的可能性。超过速率限制的请求将返回 [HTTP 429](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/429) 错误代码和[额外的速率限制响应头](https://gitlab.cn/docs/jh/administration/settings/user_and_ip_rate_limits/#response-headers)。

根据 GitLab 在 GitLab.com 上观察到的请求速率，默认速率限制被有意设置得相当高，以免干扰大多数使用。实例管理员可以根据需要在管理区域中设置更高或更低的限制，与已实施的其他速率限制类似。

<a id="removal-of-migrationstate-field-in-containerrepository-graphql-api"></a>

### 移除 `ContainerRepository` GraphQL API 中的 `migrationState` 字段

- 于极狐GitLab 17.6 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/459869)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

极狐GitLab GraphQL API 的 `ContainerRepositoryType`中的 `migrationState` 字段已弃用。此弃用是我们简化和改进 API 工作的一部分。

为准备此变更，我们建议您检查并更新与 `ContainerRepositoryType` 交互的 GraphQL 查询。移除对 `migrationState` 字段的任何引用，并相应调整您的应用逻辑。

<a id="remove-previousstagejobsorneeds-from-graphql"></a>

### 从 GraphQL 中移除 `previousStageJobsOrNeeds`

- 于极狐GitLab 17.0 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424417)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

GraphQL 中的 `previousStageJobsOrNeeds` 字段将被移除，因为它已被 `previousStageJobs` 和 `needs` 字段取代。

<a id="replace-graphql-field-take_ownership_pipeline_schedule-with-admin_pipeline_schedule-in-pipelineschedulepermissions"></a>

### 在 PipelineSchedulePermissions 中用 `admin_pipeline_schedule` 替换 GraphQL 字段 `take_ownership_pipeline_schedule`

- 于极狐GitLab 15.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391941)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

GraphQL 字段 `take_ownership_pipeline_schedule` 将被弃用。要确定用户是否可以接管流水线计划的所有权，请改用 `admin_pipeline_schedule` 字段。

<a id="resolve-a-vulnerability-for-dependency-scanning-on-yarn-projects"></a>

### 解决 Yarn 项目依赖扫描的漏洞

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501308)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

由 Gemnasium 分析器为依赖扫描提供的 Yarn 项目[解决漏洞](https://gitlab.cn/docs/jh/user/application_security/vulnerabilities/#resolve-a-vulnerability)功能已在极狐GitLab 17.9 中弃用。

虽然此功能在使用 Gemnasium 分析器时将继续工作，但在迁移到新的依赖扫描分析器后将不再可用。详情请参阅[迁移指南](https://gitlab.cn/docs/jh/user/application_security/dependency_scanning/migration_guide_to_sbom_based_scans/)。

替代功能已作为[自动修复愿景](https://gitlab.com/groups/gitlab-org/-/epics/7186)的一部分进行规划，但尚未确定交付时间表。

<a id="subscription-related-api-endpoints-in-the-public-api-are-deprecated"></a>

### 公共 API 中与订阅相关的 API 端点已弃用

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/515371#note_2319368251)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

公共 REST API 中的以下端点将被移除：

- `PUT /api/v4/user/:id/credit_card_validation`
- `POST /api/v4/namespaces/:namespace_id/minutes`
- `PATCH /api/v4/namespaces/:previous_namespace_id/minutes/move/:target_namespace_id`
- `GET /api/v4/namespaces/:namespace_id/subscription_add_on_purchase/:id`
- `PUT /api/v4/namespaces/:namespace_id/subscription_add_on_purchase/:id`
- `POST /api/v4/namespaces/:namespace_id/subscription_add_on_purchase/:id`
- `POST /api/v4/namespaces/:id/gitlab_subscription`
- `PUT /api/v4/namespaces/:id/gitlab_subscription`
- `PUT /api/v4/namespaces/:id`

这些端点曾被订阅门户用于管理 GitLab.com 上的订阅信息。它们的使用已被带有 JWT 身份验证的内部端点所取代，以支持即将推出的 Cells 架构。公共 API 中的这些端点正在被移除，以免它们被意外再次使用，并减少随着功能漂移而产生的维护负担。

您不应因此变更而受到任何影响，因为这些是内部使用的端点。

<a id="the-agentk-container-registry-is-moving-to-cloud-native-gitlab"></a>

### `agentk` 容器镜像仓库正在迁移到 Cloud Native GitLab

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/issues/630)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

GitLab 正在将 `agentk` 容器镜像仓库从[其项目专用镜像仓库](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/container_registry/1223205)迁移到 [Cloud Native GitLab (CNG) 镜像仓库](https://gitlab.com/gitlab-org/build/CNG/container_registry/8241772)。从极狐GitLab 18.0 起，在 CNG 中构建的 `agentk` 镜像将镜像到项目专用镜像仓库。新镜像与旧镜像等效，只是新镜像仅支持 `amd64` 和 `arm64` 架构。它不支持 32 位 `arm` 架构。从极狐GitLab 19.0 起，项目专用镜像仓库将不再接收 `agentk` 更新。如果您将 `agentk` 容器镜像到本地镜像仓库，则应将镜像源更改为 [CNG 镜像仓库](https://gitlab.com/gitlab-org/build/CNG/container_registry/8241772)。

如果您使用官方 [GitLab Agent Helm chart](https://gitlab.com/gitlab-org/charts/gitlab-agent/)，新的 `agentk` 镜像将在极狐GitLab 18.0 中无缝地从新位置开始部署。

<a id="updating-cicd-job-tokens-to-jwt-standard"></a>

### 将 CI/CD 作业令牌更新为 JWT 标准

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/509578)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

在极狐GitLab 19.0 中，CI/CD 作业令牌将从字符串令牌格式切换为 JWT 令牌格式。此变更会影响所有项目中的新 CI/CD 作业令牌和现有 CI/CD 作业令牌。如果您遇到问题，在极狐GitLab 20.0 版本发布之前，您仍然可以[为 CI/CD 令牌使用旧版格式](https://gitlab.cn/docs/jh/ci/jobs/ci_job_token/#use-legacy-format-for-cicd-tokens)。

已知问题：

1. 极狐GitLab Runner 的 AWS Fargate Drive 0.5.0 及更早版本与 JWT 标准不兼容。作业将失败并出现 `file name too long` 错误。[AWS Fargate 自定义执行器驱动](https://gitlab.cn/docs/runner/configuration/runner_autoscale_aws_fargate/)的用户必须升级到 0.5.1 或更高版本。有关迁移说明，请参阅[文档](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/tree/master/docs)。
1. 更长的 JWT 标准会破坏某些 CI/CD 配置文件中使用的 `echo $CI_JOB_TOKEN | base64` 命令。您可以改用 `echo $CI_JOB_TOKEN | base64 -w0` 命令。

<a id="bin_path-and-use_bundled_binaries-configuration-options-in-gitaly"></a>

### Gitaly 中的 `bin_path` 和 `use_bundled_binaries` 配置选项

- 于极狐GitLab 18.2 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/9181)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

在 Gitaly 中使用 `bin_path` 和 `use_bundled_binaries` 配置选项的支持已弃用，并将在极狐GitLab 19.0 中移除。

Gitaly 提供的 Git 二进制文件将是执行 Git 的唯一受支持方式。

<a id="kpt-based-agentk-is-deprecated"></a>

### 基于 `kpt`的 `agentk` 已弃用

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/issues/656)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

我们将移除对基于 `kpt` 安装极狐GitLab Kubernetes Agent 的支持。取而代之，您应使用以下受支持的安装方法之一安装 Agent：

- Helm（推荐）
- GitLab CLI
- Flux

要从 `kpt` 迁移到 Helm，请遵循 [Agent 安装文档](https://gitlab.cn/docs/jh/user/clusters/agent/install/)覆盖您通过 `kpt` 部署的 `agentk` 实例。

<a id="mergetrainindex-and-mergetrainscount-graphql-fields-deprecated"></a>

### `mergeTrainIndex` 和 `mergeTrainsCount` GraphQL 字段已弃用

- 于极狐GitLab 17.5 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/473759)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

`MergeRequest`中的 GraphQL 字段 `mergeTrainIndex` 和 `mergeTrainsCount` 已弃用。要确定合并请求在合并列车上的位置，请改用 `MergeTrainCar`中的 `index` 字段。要获取合并列车中合并请求的数量，请改用 `MergeTrains::TrainType`中 `cars`的 `count`。

<a id="scanresultpolicies-graphql-field-is-deprecated"></a>

### `scanResultPolicies` GraphQL 字段已弃用

- 于极狐GitLab 17.8 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439199)。

> [!note]
> 此变更已从其原定里程碑中移除，正在重新评估。

在 16.10 中，扫描结果策略被重命名为合并请求审批策略，以更准确地反映该策略类型在范围和能力上的变化。

因此，我们更新了 GraphQL 端点。请使用 `approvalPolicies` 代替 `scanResultPolicies`。

<a id="canceled-changes"></a>

## 已取消的变更

以下变更已取消。

<a id="container-scanning-default-severity-threshold-set-to-medium"></a>

### 容器扫描默认严重程度阈值设置为 `medium`

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/515358)。

> [!note]
> 此变更已取消。

容器扫描安全功能会生成大量安全发现，这一数量通常让工程团队难以管理。通过将严重程度阈值更改为 `medium`，我们为用户提供了一个更合理的默认值，即任何严重程度低于 `medium`的发现都不会被报告。从极狐GitLab 18.0 开始，`CS_SEVERITY_THRESHOLD` 环境变量的默认值将设置为 `medium`，而不是 `unknown`。因此，严重程度级别为 `low` 和 `unknown`的安全发现将默认不再报告。相应地，之前默认分支上报告的具有这些严重程度的任何漏洞，将在下次执行容器扫描时被标记为不再检测到。要继续显示这些发现，您必须将 `CS_SEVERITY_THRESHOLD` 变量配置为所需级别。

<a id="deprecate-license-scanning-cicd-artifact-report-type"></a>

### 弃用许可证扫描 CI/CD 产物报告类型

- 于极狐GitLab 16.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439301)。

> [!note]
> 此变更已取消。

CI/CD [产物报告](https://gitlab.cn/docs/jh/ci/yaml/artifacts_reports/)类型已在极狐GitLab 16.9 中弃用，并将在极狐GitLab 18.0 中移除。使用此关键字的 CI/CD 配置将在极狐GitLab 18.0 中停止工作。

由于极狐GitLab 16.3 中移除了旧版许可证扫描 CI/CD 作业，该产物报告类型已不再使用。取而代之，您应使用 [CycloneDX 文件的许可证扫描](https://gitlab.cn/docs/jh/user/compliance/license_scanning_of_cyclonedx_files/)。

<a id="end-of-support-sast-jobs-will-be-removed-from-the-cicd-template"></a>

### 支持结束的 SAST 作业将从 CI/CD 模板中移除

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/519133)。

> [!note]
> 此变更已取消。

在极狐GitLab 18.0 中，我们将更新 SAST CI/CD 模板，以移除在之前版本中已达到支持结束状态的分析器作业。以下作业将从 `SAST.gitlab-ci.yml` 和 `SAST.latest.gitlab-ci.yml`中移除：

- `bandit-sast`，[在 15.4 中达到支持结束](#sast-analyzer-consolidation-and-cicd-template-changes)
- `brakeman-sast`，[在 17.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-170)
- `eslint-sast`，[在 15.4 中达到支持结束](#sast-analyzer-consolidation-and-cicd-template-changes)
- `flawfinder-sast`，[在 17.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-170)
- `gosec-sast`，[在 15.4 中达到支持结束](#sast-analyzer-consolidation-and-cicd-template-changes)
- `mobsf-android-sast`，[在 17.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-170)
- `mobsf-ios-sast`，[在 17.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-170)
- `nodejs-scan-sast`，[在 17.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-170)
- `phpcs-security-audit-sast`，[在 17.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-170)
- `security-code-scan-sast`，[在 16.0 中达到支持结束](#sast-analyzer-coverage-changing-in-gitlab-160)

在每个分析器达到支持结束时，我们更新了其作业的 `rules`，使其默认不运行，并停止发布更新。但是，您可能已经自定义了模板以继续使用这些作业，或者依赖于它们存在于您的流水线中。如果您有任何依赖于上述作业的自定义设置，请在升级到 18.0 之前执行[所需操作](https://gitlab.com/gitlab-org/gitlab/-/issues/519133#actions-required)，以避免对您的 CI/CD 流水线造成中断。

<a id="public-use-of-secure-container-registries-is-deprecated"></a>

### 公开使用 Secure 容器镜像仓库已弃用

- 于极狐GitLab 17.4 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/470641)。

> [!note]
> 此变更已取消。

`registry.gitlab.com/gitlab-org/security-products/` 下的容器镜像仓库在极狐GitLab 18.0 中将不再可访问。[自极狐GitLab 14.8 起](https://gitlab.cn/docs/jh/update/deprecations/#secure-and-protect-analyzer-images-published-in-new-location)，正确的位置是 `registry.gitlab.com/security-products` 下（请注意地址中没有 `gitlab-org`）。

此变更提高了极狐GitLab [漏洞扫描器](https://gitlab.cn/docs/jh/user/application_security/#vulnerability-scanner-maintenance)发布流程的安全性。

建议用户使用 `registry.gitlab.com/security-products/` 下的等效镜像仓库，这是 GitLab 安全扫描器镜像的规范位置。相关的 GitLab CI 模板已经使用此位置，因此对于使用未修改模板的用户来说，应该无需进行任何更改。

离线部署应查看[特定扫描器说明](https://gitlab.cn/docs/jh/user/application_security/offline_deployments/#specific-scanner-instructions)，以确保使用正确的位置来镜像所需的扫描器镜像。

<a id="sast-jobs-no-longer-use-global-cache-settings"></a>

### SAST 作业不再使用全局缓存设置

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/512564)。

> [!note]
> 此变更已取消。

在极狐GitLab 18.0 中，我们将更新 SAST 和 IaC 扫描，默认显式[禁用 CI/CD 作业缓存的使用](https://gitlab.cn/docs/jh/ci/caching/#disable-cache-for-specific-jobs)。

此变更影响以下 CI/CD 模板：

- SAST：`SAST.gitlab-ci.yml`。
- IaC 扫描：`SAST-IaC.gitlab-ci.yml`。

我们已经更新了 `latest` 模板 `SAST.latest.gitlab-ci.yml` 和 `SAST-IaC.latest.gitlab-ci.yml`。有关这些模板版本的更多详细信息，请参阅[稳定版和最新版模板](https://gitlab.cn/docs/jh/user/application_security/sast/#stable-vs-latest-sast-templates)。

在大多数项目中，缓存目录不在扫描范围内，因此获取缓存可能会导致超时或误报结果。

如果您在扫描项目时需要用到缓存，可以通过在项目的 CI 配置中[覆盖](https://gitlab.cn/docs/jh/user/application_security/sast/#overriding-sast-jobs) [`cache`](https://gitlab.cn/docs/jh/ci/yaml/#cache) 属性来恢复之前的行为。

<a id="secret-detection-analyzer-doesnt-run-as-root-user-by-default"></a>

### 密钥检测分析器默认不以 root 用户身份运行

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/476160)。

> [!note]
> 此变更已取消。

此项针对密钥检测分析器的计划变更已取消。您仍然可以默认使用 root 用户。

<a id="support-for-project-build-as-part-of-spotbugs-scans"></a>

### 支持在 SpotBugs 扫描中构建项目

- 于极狐GitLab 17.9 中宣布
- 如需讨论此变更或了解更多信息，请参阅[弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513409)。

> [!note]
> 此变更已取消。

SpotBugs [SAST 分析器](https://gitlab.cn/docs/jh/user/application_security/sast/#supported-languages-and-frameworks)可以在待扫描的产物不存在时执行构建。虽然这对于简单项目通常很有效，但在更复杂的构建中可能会失败。

从极狐GitLab 18.0 起，要解决 SpotBugs 分析器构建失败的问题，您应该：

1. [预编译](https://gitlab.cn/docs/jh/user/application_security/sast/#pre-compilation)项目。
1. 将要扫描的产物传递给分析器。

这不是功能上的变更，因此为清晰起见，我们已将本公告标记为“已取消”。

> [!disclaimer]
