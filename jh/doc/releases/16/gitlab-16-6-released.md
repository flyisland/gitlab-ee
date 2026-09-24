---
stage: Release Notes
group: Monthly Release
date: 2023-11-16
title: "极狐GitLab 16.6 发布说明"
description: "极狐GitLab 16.6 发布，极狐GitLab Duo Chat 测试版可用"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 11 月 16 日，极狐GitLab 16.6 发布了以下功能。

## 主要功能

### 极狐GitLab Duo Chat 测试版可用

{{< details >}}

- Tier: Gold
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10550)

{{< /details >}}

软件开发过程中的每个人都会花费大量时间来熟悉代码、史诗、议题和冗长的讨论线程。你经常会因为编写摘要、文档、测试甚至代码等常规任务而放慢速度。如果有一位专家在你身边，能够无偏见地回答 DevSecOps 问题并处理后续问题，这可以帮助你加速软件开发过程。

极狐GitLab Duo Chat 旨在积极解决这些痛点并加速你的工作流。其功能包括：

- 解释或总结议题、史诗和代码。
- 回答关于这些工件的特定问题，例如“收集评论中关于此议题提出的解决方案的所有论点。”
- 根据这些工件中的信息生成代码或内容。例如，“你能为这段代码编写文档吗？”
- 或者让你从头开始，例如“创建一个用于在极狐GitLab CI/CD 流水线中测试和构建 Ruby on Rails 应用程序的 .GitLab-ci.yml 配置文件。”
- 回答你所有的 DevSecOps 相关问题，无论你是初学者还是专家。例如，“如何为 REST API 设置动态应用程序安全测试？”
- 回答后续问题，以便你可以迭代地处理上述所有场景。

极狐GitLab Duo Chat 作为测试版功能在 JihuLab.com 上可用。它还作为实验性功能集成到我们的 Web IDE 和 VS Code 的极狐GitLab Workflow 扩展中。

你也可以通过提供关于 Duo Chat 体验的反馈来帮助我们完善这些功能，可以在产品内反馈，也可以通过我们的 [反馈议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/430124) 反馈。

### 企业用户的自动声明

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/enterprise_user/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/9675)

{{< /details >}}

当 JihuLab.com 用户的主电子邮件地址与现有的已验证域匹配时，该用户将自动被声明为企业用户。这为群组所有者提供了更多的用户管理控制权和对用户账户的可见性。用户成为企业用户后，只能将其主电子邮件更改为其组织拥有的、符合已验证域的电子邮件。

### 最小化派生 - 仅包含默认分支

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/forking_workflow.md#create-a-fork)

{{< /details >}}

在极狐GitLab 的早期版本中，派生仓库时，派生始终包含仓库中的所有分支。现在，你可以创建仅包含默认分支的派生，从而降低复杂性并节省存储空间。如果你不需要其他分支中正在进行的更改，可以创建最小化派生。

默认的派生方法不会改变，仍然包含仓库中的所有分支。新选项会显示哪个分支是默认分支，以便你准确了解新派生中将包含哪个分支。

### 允许用户强制执行合并请求审批作为合规策略

{{< details >}}

- Tier: Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md#any_merge_request-rule-type) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/9696)

{{< /details >}}

对于可能进入生产应用程序并给企业带来合规风险和安全漏洞的代码变更，审查日益严格。借助扫描结果策略，你可以通过在所有合并请求上强制执行两人审批来确保无法进行单方面更改。

扫描结果策略新增了一个选项，可以针对 `任何合并请求`，该选项可以与定义 [基于角色的审批者](../../user/application_security/policies/merge_request_approval_policies.md#require_approval-action-type) 结合使用，以确保针对定义的分支的每个 MR 都需要由具有给定角色（所有者、维护者或开发者）的两名（或更多）用户审批。

在 16.6 中可用于 SaaS。在私有化部署中，该功能受功能标志 `scan_result_any_merge_request` 控制，并将在 16.7 中默认启用。

### 持续漏洞扫描默认可用于容器扫描

{{< details >}}

- Tier: Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/continuous_vulnerability_scanning/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10174)

{{< /details >}}

容器扫描的持续漏洞扫描现在默认可用。默认可用性消除了通过功能标志选择加入此功能的需要。要了解有关持续漏洞扫描优势的更多信息，请参阅文档链接。

### 改进了对 sbt 的依赖扫描支持

{{< details >}}

- Tier: Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390287)

{{< /details >}}

我们更新了用于为使用 sbt 的项目生成依赖项列表的机制。此更改仅适用于使用 sbt 1.7.2 及更高版本的项目。要充分利用 sbt 项目的依赖扫描，你应该升级到 sbt 1.7.2 及更高版本。

### DAST 分析器性能更新

{{< details >}}

- Tier: Ultimate
- Links: [文档](../../user/application_security/dast/browser/_index.md) | [相关议题](https://jihulab.com/groups/gitlab-cn/-/epics/12194)

{{< /details >}}

在 16.10 发布里程碑期间，基于代理的 DAST 进行了以下更新：

- 将 ZAP 升级到版本 2.14.0。有关更多信息，请参阅 [议题 442056](https://jihulab.com/gitlab-cn/gitlab/-/issues/442056)。

我们还完成了以下基于浏览器的 DAST 爬虫性能改进：

- 限制爬取时创建的 goroutine 数量。有关更多信息，请参阅 [议题 440151](https://jihulab.com/gitlab-cn/gitlab/-/issues/440151)。
- 优化查找要交互的元素。这将扫描时间缩短了 6%。有关更多信息，请参阅 [议题 440295](https://jihulab.com/gitlab-cn/gitlab/-/issues/440295)。
- 优化 DevTools 消息的 JSON 反序列化。这将扫描时间缩短了 7%。有关更多信息，请参阅 [议题 439726](https://jihulab.com/gitlab-cn/gitlab/-/issues/439726)。

### 极狐GitLab Runner 16.6

{{< details >}}

- Tier: Free, Premium, Ultimate
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.6！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 配合使用，极狐GitLab CI/CD 是极狐GitLab 中包含的开源持续集成服务。

#### 新功能

### 使用新的容器镜像仓库 API 列出仓库标签

{{< details >}}

- Tier: Free, Silver, Gold
- Links: [文档](../../api/container_registry.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10208)

{{< /details >}}

以前，容器镜像仓库依赖于 Docker/OCI [列出镜像标签的仓库 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/docker/v2/api.md#listing-image-tags) 在极狐GitLab 中显示标签。此 API 在性能和可发现性方面存在重大限制。

此 API 运行缓慢，因为针对仓库的网络请求数量随着标签列表中标签数量的增加而增加。此外，由于该 API 不跟踪发布时间，因此发布的时间戳通常不正确。在基于 Docker 清单列表或 OCI 索引（例如多架构镜像）显示镜像时也存在限制。

为了解决这些限制，我们引入了一个新的仓库 [列出仓库标签 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/gitlab/api.md#list-repository-tags)。在极狐GitLab 16.10 中，我们完成了向新 API 的迁移。现在，无论你使用 UI 还是 REST API，你都可以期待性能的提升、准确的发布时间戳以及对多架构镜像的强大支持。

此改进仅在 JihuLab.com 上可用。私有化部署支持将被阻止，直到下一代容器镜像仓库正式发布。要了解更多信息，请参阅 [议题 423459](https://jihulab.com/gitlab-cn/gitlab/-/issues/423459)。

### 价值流仪表板中的新贡献者计数指标

{{< details >}}

- Tier: Gold
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/433353)

{{< /details >}}

为了使软件领导者能够深入了解团队速度、软件稳定性、安全暴露和团队生产力之间的关系，我们在价值流仪表板中引入了新的 [**贡献者计数** 指标](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)。贡献者计数表示群组中每月有贡献的唯一用户数。此指标旨在跟踪随时间推移的采用趋势，并基于 [贡献日历事件](../../user/profile/contributions_calendar.md#user-contribution-events)。

**贡献者计数** 指标仅在 JihuLab.com 上可用，并且需要 [将贡献分析报告配置为通过 ClickHouse 运行](../../user/group/contribution_analytics/_index.md#contribution-analytics-with-clickhouse)。[议题 441626](https://jihulab.com/gitlab-cn/gitlab/-/issues/441626) 跟踪了将此功能也提供给私有化部署客户的努力。

### 价值流分析中的继承过滤器，实现无缝且准确的工作流分析

{{< details >}}

- Tier: Premium, Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/group/issues_analytics/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/439615)

{{< /details >}}

[价值流分析](../../user/group/value_stream_analytics/_index.md) 现在在从 **前置时间** 磁贴下钻到 [**议题分析** 报告](../../user/group/issues_analytics/_index.md) 时会应用相同的过滤器。过滤器继承可帮助你在切换分析视图时更深入地无缝分析数据。

### 使用快速操作将议题添加到当前或下一个迭代

{{< details >}}

- Tier: Premium, Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/project/quick_actions.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/384885)

{{< /details >}}

`/iteration` 快速操作现在接受带有 `--current` 或 `--next` 参数的节奏引用。如果你的群组只有一个迭代节奏，你可以通过使用 `/iteration --current|next` 快速将议题分配到当前或下一个迭代。如果你的群组包含多个迭代节奏，你可以通过在快速操作中引用节奏名称或 ID 来指定所需的节奏。例如，`/iteration [cadence:"<cadence name>"|<cadence ID>] --next|current`。

### 容器扫描默认启用持续漏洞扫描

{{< details >}}

- Tier: Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/continuous_vulnerability_scanning/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10174)

{{< /details >}}

容器扫描的持续漏洞扫描现在默认可用。默认可用性消除了通过功能标志选择加入此功能的需要。要了解有关持续漏洞扫描优势的更多信息，请参阅文档链接。

### 改进了对 sbt 的依赖扫描支持

{{< details >}}

- Tier: Ultimate
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390287)

{{< /details >}}

我们更新了用于为使用 sbt 的项目生成依赖项列表的机制。此更改仅适用于使用 sbt 1.7.2 及更高版本的项目。要充分利用 sbt 项目的依赖扫描，你应该升级到 sbt 1.7.2 及更高版本。

### DAST 分析器性能更新

{{< details >}}

- Tier: Ultimate
- Links: [文档](../../user/application_security/dast/browser/_index.md) | [相关议题](https://jihulab.com/groups/gitlab-cn/-/epics/12194)

{{< /details >}}

在 16.10 发布里程碑期间，基于代理的 DAST 进行了以下更新：

- 将 ZAP 升级到版本 2.14.0。有关更多信息，请参阅 [议题 442056](https://jihulab.com/gitlab-cn/gitlab/-/issues/442056)。

我们还完成了以下基于浏览器的 DAST 爬虫性能改进：

- 限制爬取时创建的 goroutine 数量。有关更多信息，请参阅 [议题 440151](https://jihulab.com/gitlab-cn/gitlab/-/issues/440151)。
- 优化查找要交互的元素。这将扫描时间缩短了 6%。有关更多信息，请参阅 [议题 440295](https://jihulab.com/gitlab-cn/gitlab/-/issues/440295)。
- 优化 DevTools 消息的 JSON 反序列化。这将扫描时间缩短了 7%。有关更多信息，请参阅 [议题 439726](https://jihulab.com/gitlab-cn/gitlab/-/issues/439726)。

### 极狐GitLab Runner 16.6

{{< details >}}

- Tier: Free, Premium, Ultimate
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.6！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 配合使用，极狐GitLab CI/CD 是极狐GitLab 中包含的开源持续集成服务。

#### 新功能

（以下内容为第二部分，此处省略）
- [适用于 GCP Compute Engine 的极狐GitLab Runner Fleeting 插件 - Beta](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/29409)
- [为 Docker 执行器实现优雅关闭](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/6359)
- [为 Kubernetes 动态创建带有存储类的 PVC 卷](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/27835)
- [在 Kubernetes 执行器中通过 `image.entrypoint` 覆盖容器入口点](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/30713)

#### 错误修复

- [升级到极狐GitLab Runner 16.5.0 后，Pod 因存活探针失败错误而不断重启](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/36959)
- [调试终端 - 变量包含文件内容而非文件路径](https://jihulab.com/gitlab-cn/gitlab/-/issues/399770)
- [Kubernetes 中的作业执行 Pod 不处理信号](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/28162)
- [使用 Podman 的极狐GitLab Runner Docker 执行器中的服务无法启动](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/29480)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-6-stable/CHANGELOG.md)。