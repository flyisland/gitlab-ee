---
stage: Release Notes
group: Monthly Release
date: 2025-04-17
title: "极狐GitLab 17.11 发布说明"
description: "极狐GitLab 17.11 发布，支持使用要求和合规控制自定义合规框架"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 4 月 17 日，极狐GitLab 17.11 已发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="customize-compliance-frameworks-with-requirements-and-compliance-controls"></a>

### 使用要求和合规控制自定义合规框架

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_status_report.md)

{{< /details >}}

此前，极狐GitLab 中的合规框架可以创建为标记，用于标识您的项目具有某些合规要求或需要额外监督。该标记随后可用作范围界定机制，以确保安全策略可在群组内的所有项目上强制执行。

在此版本中，我们为合规管理员引入了一种新方式，通过“要求”在极狐GitLab 中获得更深入的合规监控。

借助要求，作为自定义合规框架的一部分，您可以定义来自多种不同合规标准、法律和法规的特定要求，这些要求是组织必须遵循的。

我们还将提供的合规控制（以前称为合规检查）数量从五项扩展到 50 多项！这 50 项开箱即用（OOTB）控制可以映射到合规框架要求。

这些控制会检查极狐GitLab 实例中的特定项目、安全和合并请求设置，帮助您满足 SOC2、NIST、ISO 27001 和 GitLab CIS Benchmark 等多种不同合规标准、法律和法规下的要求。

对这些控制的遵循情况会反映在标准遵循情况报告中，该报告经过重新设计，以考虑要求以及控制到这些要求的映射。

除了扩展我们的 OOTB 控制之外，我们现在还允许用户将要求映射到外部控制，这些控制可以针对极狐GitLab 平台之外存在的条目、程序或系统。这些映射让您可以将极狐GitLab 合规中心用作合规监控和审计证据需求的单一事实来源。

<a id="gitlab-eclipse-plugin-available-in-beta"></a>

### GitLab Eclipse 插件推出测试版

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](https://gitlab.cn/docs/jh/editor_extensions/eclipse/setup/) | [相关史诗](https://gitlab.com/groups/gitlab-org/editor-extensions/-/epics/89)

{{< /details >}}

我们非常高兴地宣布 GitLab Eclipse 插件推出测试版，现已在 [Eclipse Marketplace](https://marketplace.eclipse.org/content/gitlab-eclipse) 上提供。这个强大的新插件将极狐GitLab 的 Duo 功能直接扩展到您的 Eclipse IDE 中，让您可以无缝访问 Duo Chat 和 AI 驱动的代码建议。

由于该插件目前处于测试版，我们正在积极改进功能，包括扩展身份验证选项，并完善最终用户体验。您的反馈非常宝贵。请通过在[议题 162](https://gitlab.com/gitlab-org/editor-extensions/gitlab-eclipse-plugin/-/issues/162)中添加您的反馈，帮助我们让 GitLab Eclipse 插件变得更好。

<a id="more-gitlab-duo-features-now-available-on-gitlab-duo-self-hosted"></a>

### 更多极狐GitLab Duo 功能现已在极狐GitLab Duo 自部署版本上提供

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md#feature-versions-and-status) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17072)

{{< /details >}}

现在，您可以在极狐GitLab 私有化部署实例中使用极狐GitLab Duo 自部署版本的更多 [极狐GitLab Duo](https://about.gitlab.com/gitlab-duo/) 功能。以下功能处于测试版：

- [根因分析](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)
- [漏洞说明](../../user/application_security/analyze/duo.md)
- [漏洞解决](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution)
- [AI 影响仪表板](../../user/analytics/duo_and_sdlc_trends.md)
- [讨论摘要](../../user/discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat)
- [合并请求提交消息](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message)
- [合并请求摘要](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes)
- [适用于 CLI 的极狐GitLab Duo](https://gitlab.cn/docs/jh/editor_extensions/gitlab_cli/#gitlab-duo-for-the-cli)

[代码评审摘要](../../user/project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review)也已在极狐GitLab Duo 自部署版本上作为实验提供。

<a id="extension-marketplace-for-web-ide-on-self-managed-instances"></a>

### 私有化部署实例上的 Web IDE 扩展市场

<!-- categories: Web IDE -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/vscode_extension_marketplace.md)

{{< /details >}}

我们非常高兴地宣布，面向私有化部署用户的 Web IDE 扩展市场正式推出。借助扩展市场，您可以发现、安装和管理第三方扩展，以增强您的开发体验。

默认情况下，极狐GitLab 实例配置为使用 Open VSX 扩展注册表。要激活此功能，请按照[使用默认扩展注册表启用](../../administration/settings/vscode_extension_marketplace.md#enable-the-extension-registry)的步骤操作。

如果您想使用自己的或自定义的注册表，也可以选择[连接自定义扩展注册表](../../administration/settings/vscode_extension_marketplace.md#modify-the-extension-registry)。这为您管理可用扩展提供了更大的灵活性。

启用扩展市场后，单个用户仍必须选择启用它。他们可以通过转到[偏好设置](https://gitlab.com/-/profile/preferences)中的**集成**部分来执行此操作。

需要注意的是，某些扩展需要本地运行时环境，与仅限 Web 的版本不兼容。尽管如此，您仍然可以从数千个可用扩展中进行选择，以提高工作效率并自定义您的工作流。

<a id="gitlab-duo-with-amazon-q-is-generally-available"></a>

### 极狐GitLab Duo with Amazon Q 已正式发布

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/duo_amazon_q/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16879)

{{< /details >}}

我们很高兴地宣布极狐GitLab Duo with Amazon Q 正式发布，这是一项联合产品，将全面的极狐GitLab AI 驱动的 DevSecOps 平台与自主的 Amazon Q AI Agent 整合到一个集成解决方案中。极狐GitLab Duo with Amazon Q 将 AI Agent 直接集成到开发工作流中，让开发者无需切换工具即可加速关键任务。这些 Agent 作为极狐GitLab DevSecOps 平台内的智能助手，可自动执行代码生成、测试、评审和 Java 现代化等耗时流程，帮助团队在保持安全和质量标准的同时专注于创新。

极狐GitLab Duo with Amazon Q 为开发团队带来重大优势：

- 简化从想法到代码的功能开发：使用`/q dev`，它可以在几分钟内将议题描述直接转换为可合并的代码。
- 轻松实现遗留代码现代化：使用`/q transform` 自动执行整个 Java 现代化流程。
- 在不牺牲质量的情况下加速代码评审：使用`/q review` 直接在合并请求中获取关于代码质量和安全性的即时智能反馈。
- 自动化测试，自信交付：使用`/q test` 生成能够理解您应用程序逻辑的全面单元测试。

<a id="enhance-security-with-protected-container-tags"></a>

### 使用受保护的容器标签增强安全性

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/container_registry/protected_container_tags.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523893)

{{< /details >}}

容器镜像仓库是现代 DevSecOps 团队的关键基础设施。在此之前，拥有开发者角色或更高角色的极狐GitLab 用户可以推送和删除其项目中的任何容器标签，这带来了对生产关键容器镜像进行意外或未经授权更改的风险。

借助受保护的容器标签，您现在可以精细控制谁可以推送或删除特定的容器标签。您可以：

- 每个项目最多创建五条保护规则。
- 使用 RE2 正则表达式模式保护诸如 `latest`、语义化版本（例如 `v1.0.0`）或稳定发布标签（例如 `main-stable`）等标签。
- 将推送和删除操作限制为维护者、所有者或管理员角色。
- 防止受保护的标签被清理策略移除。

此功能需要下一代容器镜像仓库，该仓库已在 JihuLab.com 上默认启用。对于极狐GitLab 私有化部署实例，您需要启用[元数据数据库](../../administration/packages/container_registry_metadata_database.md)才能使用受保护的容器标签。

<a id="safeguard-your-registry-with-protected-maven-packages"></a>

### 使用受保护的 Maven 软件包保护您的仓库

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/package_registry/package_protection_rules.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/323969)

{{< /details >}}

我们非常高兴地推出对受保护 Maven 软件包的支持，以增强极狐GitLab 软件包仓库的安全性和稳定性。意外修改软件包可能会中断整个开发流程。借助受保护的软件包，您可以保护最重要的依赖项免受意外更改。

在极狐GitLab 17.11 中，您现在可以通过创建保护规则来保护 Maven 软件包。如果软件包匹配保护规则，则只有指定的用户才能推送该软件包的新版本。软件包保护规则可防止意外覆盖，提高对法规要求的合规性，并减少手动监督的需求。

对 Maven 和其他软件包格式的[受保护软件包](https://gitlab.com/groups/gitlab-org/-/epics/5574)支持都是来自 `gerardo-navarro` 和 Siemens 团队的社区贡献。感谢 Gerardo 以及 Siemens 团队的其他成员为 GitLab 做出的诸多贡献！

<a id="epic-issue-and-task-custom-fields"></a>

### 史诗、议题和任务自定义字段

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/work_items/custom_fields.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14904)

{{< /details >}}

在此版本中，您可以为议题、史诗、任务、目标和关键结果配置文本、数字、单选和多选自定义字段。虽然到目前为止，标记一直是分类工作项的主要方式，但自定义字段提供了一种更用户友好的方法，可为您的规划产物添加结构化元数据。

自定义字段在您的顶级群组中配置，并级联到所有子群组和项目。您可以将字段映射到一个或多个工作项类型，并在议题和史诗列表中按自定义字段值进行筛选。

<a id="new-issue-look-now-generally-available"></a>

### 新议题外观现已正式发布

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issues/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525547)

{{< /details >}}

自本版本起，新议题外观已正式发布，并取代旧版议题体验。议题现在与史诗和任务共享通用框架，具有实时更新和工作流改进：

- **抽屉视图：**您可以从列表或看板中在抽屉中打开条目以快速查看，而无需离开当前上下文。顶部的按钮可让您展开为整页视图。
- **更改类型：**使用“更改类型”操作在史诗、议题和任务之间转换类型（取代“提升为史诗”）
- **开始日期：**议题现在支持开始日期，使其功能与史诗和任务保持一致。
- **层级关系：**完整层级显示在标题上方和侧边栏中的父项字段中。要管理关系，请使用新的快速操作命令`/set_parent`、`/remove_parent`、`/add_child` 和`/remove_child`。
- **控制项：**所有操作现在都可以从顶部菜单（垂直省略号）访问，该菜单在滚动时仍显示在粘性标题中。
- **开发：**与议题或任务相关的所有开发条目（合并请求、分支和功能标志）现在都整合在一个便捷的列表中。
- **布局：**UI 改进在议题、史诗、任务和合并请求之间创造了更无缝的体验，帮助您更高效地导航工作流。
- **链接的条目：**使用改进的链接选项在任务、议题和史诗之间创建关系。拖放以更改链接类型，并切换标记和已关闭条目的可见性。

<a id="service-accounts-ui"></a>

### 服务账号 UI

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/service_accounts.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9965)

{{< /details >}}

您现在可以使用专用空间在极狐GitLab UI 中创建和管理服务账号。此界面允许您创建、监控和控制对极狐GitLab 资源的自动化访问。此前，此功能仅在 API 中可用。

<a id="automated-duo-pro-and-duo-enterprise-seat-assignment"></a>

### 自动分配 Duo Pro 和 Duo Enterprise 席位

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/group/saml_sso/group_sync.md#manage-gitlab-duo-seat-assignment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502496)

{{< /details >}}

您现在可以使用 SAML 群组同步自动为用户分配 Duo Pro 或 Duo Enterprise 席位。只要极狐GitLab 群组有可用的 Duo Pro 或 Duo Enterprise 席位，从身份提供商映射的任何用户都会自动分配一个席位。这减少了管理席位分配的工作量。

<a id="cicd-pipeline-inputs"></a>

### CI/CD 流水线输入

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/inputs/_index.md#for-a-pipeline)

{{< /details >}}

CI/CD 变量对于动态 CI/CD 工作流至关重要，可用于许多用途，包括作为环境变量、上下文变量、工具配置和矩阵变量。但开发者有时依赖 CI/CD 变量将[流水线变量](../../ci/variables/_index.md#use-pipeline-variables)注入流水线以手动修改流水线行为，由于流水线变量的优先级较高，这存在一些风险。

在极狐GitLab 17.11 及更高版本中，您现在可以使用 `inputs` 安全地修改流水线行为，而不是使用流水线变量，包括在计划流水线、下游流水线、触发的流水线和其他情况下。输入为开发者提供了一种更结构化、更灵活的解决方案，可在 CI/CD 作业运行时注入动态内容。切换到输入后，您可以完全[禁用对流水线变量的访问](../../ci/variables/_index.md#restrict-pipeline-variables)。

如果您能试用并通过这个专门的[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/533802)分享您的反馈，我们将不胜感激。

<a id="agentic-core"></a>

## AI 功能

<a id="gitlab-duo-chat-now-uses-anthropic-claude-sonnet-37"></a>

### 极狐GitLab Duo Chat 现在使用 Anthropic Claude Sonnet 3.7

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/examples.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521034)

{{< /details >}}

极狐GitLab Duo Chat 现在使用 Anthropic Claude Sonnet 3.7 作为基础模型，取代 Claude 3.5 Sonnet 来回答大多数问题。

Claude 3.7 Sonnet 显著改进了编码和推理能力，使其在解释代码、生成代码、处理文本数据和回答复杂的 DevSecOps 问题方面表现更佳。您会注意到在这些领域中 Chat 的响应更加详细和准确。

此升级适用于所有 Chat 功能，并确保整个 Chat 界面具有一致且改进的体验。

<a id="open-files-as-context-now-available-on-gitlab-duo-self-hosted-code-suggestions"></a>

### 将打开的文件作为上下文现已在极狐GitLab Duo 自部署版本代码建议中提供

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/context.md#using-open-files-as-context) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16611)

{{< /details >}}

在极狐GitLab Duo 自部署版本上，您现在可以在使用代码建议时将[在 IDE 标签页中打开的文件](../../user/project/repository/code_suggestions/context.md#using-open-files-as-context)用作上下文。

<a id="select-individual-models-for-ai-powered-features-on-gitlab-duo-self-hosted"></a>

### 在极狐GitLab Duo 自部署版本上为 AI 驱动的功能选择单个模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#select-a-self-hosted-model-for-a-feature) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17099)

{{< /details >}}

在极狐GitLab Duo 自部署版本上，您现在可以在极狐GitLab 私有化部署实例上为每个极狐GitLab Duo 功能和子功能选择和配置单个受支持的模型。

要留下反馈，请转到[议题 524175](https://gitlab.com/gitlab-org/gitlab/-/issues/524175)。

<a id="llama-3-models-generally-available-for-gitlab-duo-chat-and-code-suggestions"></a>

### Llama 3 模型已正式发布，适用于极狐GitLab Duo Chat 和代码建议

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15678)

{{< /details >}}

Llama 3 模型在极狐GitLab Duo 自部署版本中已正式发布，以支持极狐GitLab Duo Chat 和代码建议。

要留下关于在极狐GitLab Duo 自部署版本中使用这些模型的反馈，请参阅[议题 523918](https://gitlab.com/gitlab-org/gitlab/-/issues/523918)。

<a id="manage-multiple-conversations-in-gitlab-duo-chat"></a>

### 在极狐GitLab Duo Chat 中管理多个对话

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/_index.md#have-multiple-conversations) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16108)

{{< /details >}}

与极狐GitLab Duo Chat 的多个对话现已在极狐GitLab 私有化部署实例的 Web UI 中提供。您可以创建新对话、浏览对话历史，并在对话之间切换而不会丢失上下文。

为保护您的隐私，30 天无活动的对话会自动删除，您可以随时手动删除任何对话。在极狐GitLab 私有化部署上，管理员可以缩短对话的保留时长。

请在[议题 526013](https://gitlab.com/gitlab-org/gitlab/-/issues/526013)中与我们分享您的体验。

<a id="scale-and-deployments"></a>

## 规模和部署

<a id="all-auto-disabled-webhooks-now-automatically-re-enable"></a>

### 所有自动禁用的 Webhook 现在会自动重新启用

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhooks.md#auto-disabled-webhooks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/396577)

{{< /details >}}

在此版本中，返回 `4xx` 错误的 Webhook 现在会自动重新启用。所有错误（`4xx`、`5xx` 或服务器错误）都以相同方式处理，从而实现更可预测的行为和更轻松的故障排除。此更改已在[此博客文章](https://about.gitlab.com/blog/gitlab-webhooks-get-smarter-with-self-healing-capabilities/)中宣布。

失败的 Webhook 会被临时禁用一分钟，最长可延长至 24 小时。在 Webhook 连续失败 40 次后，现在会变为永久禁用。

在极狐GitLab 17.10 及更早版本中被永久禁用的 Webhook 经历了数据迁移。

- 对于 JihuLab.com，这些更改会自动应用。
- 对于极狐GitLab 私有化部署，这些更改仅影响启用了 `auto_disabling_webhooks``ops` 功能标志的实例。

感谢 [Phawin](https://gitlab.com/lifez)的[这项社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/166329)！

<a id="ghost-user-contributions-auto-mapped-during-imports"></a>

### 导入期间自动映射幽灵用户贡献

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/mapping/post_migration_mapping.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/514014)

{{< /details >}}

此前，幽灵用户贡献会创建需要手动重新分配的占位符引用，在迁移期间造成额外工作。现在，使用新的[贡献和成员关系映射功能](../../user/import/mapping/post_migration_mapping.md)的导入器、通过直接传输迁移、GitHub、Bitbucket Server 和 Gitea 导入器，会更智能地处理幽灵用户贡献。将内容导入极狐GitLab 时，源实例上先前由幽灵用户做出的贡献现在会自动映射到目标实例上的幽灵用户。

此增强功能消除了为幽灵用户贡献创建不必要的占位符用户，减少了用户映射界面中的杂乱，并简化了迁移流程。

<a id="saml-verification-for-contribution-reassignment-when-importing-to-gitlabcom"></a>

### 导入到 JihuLab.com 时对贡献重新分配进行 SAML 验证

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/mapping/reassignment.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513686)

{{< /details >}}

在此里程碑中，我们为导入到 JihuLab.com 时的贡献重新分配添加了 SAML 验证检查。这些检查可防止在启用了 SAML SSO 的群组中出现重新分配错误。

如果您导入到 JihuLab.com 并为 JihuLab.com 群组使用 SAML SSO，则所有用户都必须先将其 SAML 身份关联到其 JihuLab.com 账号，然后您才能重新分配贡献和成员关系。当您将贡献重新分配给尚未验证其 SAML 身份的用户时，您会收到错误消息。这些消息说明了为确保您的群组成员关系正确归属而需要采取的步骤。

<a id="filter-placeholder-users-in-admin-area"></a>

### 在管理区域中筛选占位符用户

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/admin_area.md#administering-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521974)

{{< /details >}}

此前，导入期间创建的占位符用户会与常规用户混在一起显示，在**管理**区域的**用户**页面中没有明确的区分。

在此版本中，管理员现在可以从**管理**区域的**用户**页面中的搜索框筛选占位符账号。为此，请在下拉列表中选择 `Type`，然后选择 `Placeholder`。

<a id="placeholder-user-limits-appear-in-group-usage-quotas"></a>

### 占位符用户限制显示在群组用量配额中

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/mapping/post_migration_mapping.md#placeholder-user-limits) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/486691)

{{< /details >}}

对于导入到 JihuLab.com 的情况，占位符用户按顶级群组进行限制。这些限制取决于您的极狐GitLab 许可证和席位数。在此版本中，可以在 UI 中查看顶级群组的占位符用户用量和限制。

要查看您当前的用量和限制：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。该群组必须位于顶级。
1. 选择**设置 > 用量配额**。
1. 选择**导入**标签页。

<a id="geo---new-replicables-view"></a>

### Geo - 新的可复制项视图

<!-- categories: Disaster Recovery, Geo Replication -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/_index.md)

{{< /details >}}

我们为 Geo 中的可复制项视图引入了全新的外观和体验。新体验与极狐GitLab 的其他部分更好地保持一致，并提供了更精简、更整洁的界面，用于查看 Geo 从站点的同步和验证状态。此外，现在每个可复制项都有可点击进入的详细视图，提供主站点和从站点的校验和、错误详情等信息。这些信息将使 Geo 同步问题的故障排除变得更加容易。

<a id="linux-package-improvements"></a>

### Linux 软件包改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/) | [相关议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8504)

{{< /details >}}

在极狐GitLab 18.0 中，最低支持的 PostgreSQL 版本将是版本 16。为准备此更改，在
不使用 [PostgreSQL 集群](../../administration/postgresql/replication_and_failover.md)的实例上，
升级到极狐GitLab 17.11 将尝试自动将 PostgreSQL 升级到版本 16。

如果您使用 [PostgreSQL 集群](../../administration/postgresql/replication_and_failover.md)或[选择退出此自动升级](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades)，则必须[手动升级到 PostgreSQL 16](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server) 才能升级到极狐GitLab 18.0。

<a id="pre-deployment-opt-out-toggle-to-disable-event-data-sharing"></a>

### 部署前选择退出开关以禁用事件数据共享

<!-- categories: Application Instrumentation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/event_data.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/510333)

{{< /details >}}

在极狐GitLab 18.0 中，我们计划启用从极狐GitLab 私有化部署实例收集事件级产品使用数据。与聚合数据不同，事件级数据为极狐GitLab 提供了对使用情况的更深入洞察，使我们能够改善平台上的用户体验并提高功能采用率。

从极狐GitLab 17.11 开始，您将能够在事件数据收集开始之前选择退出，从而有效地让您提前选择是否参与。有关更多信息以及如何选择退出的详细信息，请参阅我们的文档。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="increased-rule-coverage-for-secret-push-protection-and-pipeline-secret-detection"></a>

### 扩展密钥推送保护和流水线密钥检测的规则覆盖范围

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/detected_secrets.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/534106)

{{< /details >}}

极狐GitLab 密钥检测已获得重大更新，包括 17 条新的密钥推送保护规则和 12 条新的流水线密钥检测规则。一些现有规则也已更新，以提高质量并减少误报。有关详细信息，请参阅[变更日志](https://gitlab.com/gitlab-org/security-products/secret-detection/secret-detection-rules/-/blob/main/CHANGELOG.md#v090)中的 v0.9.0。

<a id="static-reachability-beta-with-python-support"></a>

### 支持 Python 的静态可达性测试版

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/static_reachability.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15781)

{{< /details >}}

组合分析团队已发布对 Python 静态可达性的测试版支持。此测试版侧重于增强稳定性、可观测性，并通过更简单的配置提供更好的用户体验。

静态可达性丰富了软件成分分析（SCA）结果。静态可达性由极狐GitLab 高级 SAST 提供支持，会扫描项目源代码以识别正在使用哪些开源依赖项。

您可以将静态可达性产生的数据用作分类和修复决策的一部分。静态可达性数据还可以与 CVSS 和 EPSS 分数以及 KEV 指标一起使用，以提供对漏洞更聚焦的视图。

我们欢迎对此功能提出反馈。如果您有疑问、意见或希望与我们的团队交流，请参阅此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/535498)。

<a id="dynamic-analysis-support-for-reflected-xss-checks"></a>

### 动态分析支持反射型 XSS 检查

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525861)

{{< /details >}}

动态分析团队引入了对 [CWE-79](https://cwe.mitre.org/data/definitions/79.html)的检查。这项工作使我们的 DAST 扫描器能够检查反射型 XSS 攻击。

反射型 XSS 检查默认开启。要关闭此检查，请在您的配置中设置 `DAST_FF_XSS_ATTACK: false`。如果您有疑问或反馈，请参阅[议题 525861](https://gitlab.com/gitlab-org/gitlab/-/issues/525861)。

<a id="use-imported-files-as-context-in-code-suggestions"></a>

### 在代码建议中使用导入的文件作为上下文

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/context.md#using-imported-files-as-context) | [相关史诗](https://gitlab.com/groups/gitlab-org/editor-extensions/-/epics/58)

{{< /details >}}

极狐GitLab Duo 代码建议现在可以使用 IDE 中导入的文件来丰富并提高建议的质量。导入的文件提供有关您项目的额外上下文。JavaScript 和 TypeScript 文件支持导入文件上下文。

<a id="assign-projects-when-creating-compliance-frameworks"></a>

### 创建合规框架时分配项目

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md#apply-a-compliance-framework-to-a-project) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/500520)

{{< /details >}}

过去，在创建合规框架后，您必须先导航到合规中心的**项目**标签页，才能将新的合规框架分配给项目。这种情况为在群组中创建新的合规框架造成了不必要的摩擦。

在极狐GitLab 17.11 中，创建合规框架时，我们引入了一个新步骤，提供了在创建合规框架之前将多个项目分配给该合规框架的选项。

此新功能：

- 帮助您保持在合规框架创建的工作流中。
- 为您提供指导，让您了解合规框架与群组中的项目协同工作，以监控和强制执行整个群组的合规遵循情况。

<a id="kubernetes-132-support"></a>

### 支持 Kubernetes 1.32

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/509283)

{{< /details >}}

此版本增加了对 2024 年 12 月发布的 Kubernetes 版本 1.32 的全面支持。如果您将应用部署到 Kubernetes，现在可以将已连接的集群升级到最新版本，并利用其所有功能。

您可以阅读更多关于[我们的 Kubernetes 支持策略和其他受支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)的信息。

<a id="docker-hub-authentication-ui-for-the-dependency-proxy"></a>

### 依赖代理的 Docker Hub 身份验证 UI

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/dependency_proxy/_index.md#authenticate-with-docker-hub) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521954)

{{< /details >}}

我们非常高兴地宣布极狐GitLab 依赖代理中 Docker Hub 身份验证的 UI 支持。此功能最初在极狐GitLab 17.10 中引入，仅支持 GraphQL API，现在包含用户界面以便更轻松地配置。

借助此增强功能，您现在可以直接从群组设置页面配置 Docker Hub 身份验证，帮助您：

- 避免因速率限制导致的流水线失败。
- 访问私有 Docker Hub 镜像。
- 安全地存储您的 Docker Hub 凭据、[个人访问令牌](https://docs.docker.com/security/for-developers/access-tokens/)或[组织访问令牌](https://docs.docker.com/security/for-admins/access-tokens/)。

这种简化的方法使您更容易在 CI/CD 流水线中保持对 Docker Hub 镜像的不间断访问，而无需使用 GraphQL API。

<a id="set-work-in-progress-limits-by-weight"></a>

### 按权重设置进行中限制

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issue_board.md#work-in-progress-limits) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/119208)

{{< /details >}}

除了议题数量之外，您现在还可以按权重设置进行中限制，从而在管理团队工作量方面获得更大的灵活性。

根据每个任务的复杂性或工作量来控制工作流，而不仅仅是议题数量。使用议题权重来表示工作量的团队现在可以通过限制给定看板列表中议题的总权重来确保不会过度承诺。

使用此功能来优化团队的工作效率，并创建更平衡的工作流，以考虑不同的任务复杂性。

<a id="improved-wiki-sidebar-styling"></a>

### 改进的 Wiki 侧边栏样式

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md#customize-sidebar)

{{< /details >}}

自定义 Wiki 侧边栏现在具有改进的样式，标题尺寸减小，列表的左内边距更好。这些人体工学增强功能提高了通过`_sidebar` Wiki 页面创建的自定义导航的可读性。

自定义侧边栏帮助团队以适合其独特知识库结构的方式组织 Wiki 内容。通过此样式更新，侧边栏现在更易于浏览，创建了更清晰的视觉层次，帮助团队成员更快地找到相关信息。

<a id="display-last-comment-as-a-column-in-glql-views"></a>

### 在 GLQL 视图中将最后一条评论显示为列

<!-- categories: Wiki, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/glql/fields.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/512154)

{{< /details >}}

GLQL 视图现在支持将议题或合并请求上的最后一条评论显示为列。通过在 GLQL 查询中包含 `lastComment` 作为字段，您无需离开当前上下文即可查看最新更新。

此前，您必须单独打开每个议题或合并请求才能查看最后一条评论，这很耗时，并且难以快速概览进展。此改进通过提供对进行中的对话和状态更新的一目了然的可见性，帮助团队保持势头。

我们欢迎您在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/509791)上对此增强功能以及 GLQL 视图提出反馈。

<a id="nuxt-project-template-for-gitlab-pages"></a>

### 用于 GitLab Pages 的 Nuxt 项目模板

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/getting_started/pages_new_project_template.md)

{{< /details >}}

极狐GitLab 为最流行的静态站点生成器（SSG）提供模板，您现在可以使用 Nuxt（一个基于 Vue.js 构建的强大框架）创建 GitLab Pages 站点。对于希望以更少的配置开销构建现代、高性能 Web 应用程序的团队来说，Nuxt 尤其有价值。

此新增功能扩展了您的选项，可通过内置 CI/CD 流水线和现代开发体验快速启动 Pages 站点，而无需在初始设置和配置上花费时间。

<a id="cyclonedx-export-for-the-project-dependency-list"></a>

### 项目依赖项列表的 CycloneDX 导出

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#export) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524733)

{{< /details >}}

许多组织现在需要软件物料清单（SBOM）来满足法规要求，并帮助进一步提高软件供应链的安全性。此前，您只能从极狐GitLab 将依赖项列表导出为 JSON 或 CSV 文件。现在，极狐GitLab 可以通过以广泛采用的 CycloneDX 格式导出您的依赖项列表来生成您的 SBOM。

要直接将 SBOM 下载为 CycloneDX 文件，请在依赖项列表中选择**导出** > **导出为 CycloneDX (JSON)**。

<a id="email-delivery-for-dependency-list-and-vulnerability-report-export"></a>

### 依赖项列表和漏洞报告导出的电子邮件发送

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#export) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513149)

{{< /details >}}

此前，在导出依赖项列表或漏洞报告时，您必须停留在页面上直到导出完成，然后才能下载报告。

现在，当依赖项列表或漏洞报告导出完成时，您会收到带有下载链接的电子邮件通知。

<a id="export-dependency-list-in-csv-format"></a>

### 以 CSV 格式导出依赖项列表

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#export) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435843)

{{< /details >}}

此前，您无法从极狐GitLab 将依赖项列表导出为 CSV 文件。现在，当您下载依赖项列表时，可以选择新的 CSV 选项以该格式导出列表。

<a id="tool-filter-replaced-with-scanner-and-report-type-filters"></a>

### 工具筛选器替换为扫描器和报告类型筛选器

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#report-type-filter) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/503371)

{{< /details >}}

此前，漏洞报告中的**工具**搜索筛选器允许您基于一组工具筛选结果，这组工具包括扫描器类型（如 ESLint 或 Gemnasium）和报告类型（如 SAST 或容器扫描）。

为帮助您更轻松地找到合适的工具，我们将**工具**筛选器替换为**扫描器**筛选器和**报告类型**筛选器。您现在可以分别基于这些类型的工具进行搜索筛选。

<a id="store-and-filter-a-source-value-for-cicd-jobs"></a>

### 为 CI/CD 作业存储和筛选 `source` 值

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/jobs.md#retrieve-a-job-by-job-id) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11796)

{{< /details >}}

极狐GitLab 17.11 引入了一项新功能，允许用户通过跟踪 CI/CD 作业的 source 属性来验证构建产物的来源。此增强功能对于安全和合规工作流尤其有价值。例如，组织可以实施软件供应链安全措施，或为合规目的要求可验证的安全扫描证据。

极狐GitLab 中的作业现在会存储并显示一个 `source` 值，用于标识它们是否源自：

- 扫描执行策略
- 流水线执行策略
- 常规流水线

您可以在**构建** > **作业**页面上使用新的筛选选项访问 `source` 属性，使用作业 API，或通过 ID 令牌 `claims` 进行产物验证。

借助此新功能，您现在可以：

- 验证安全扫描结果的真实性。
- 按来源类型筛选作业，以快速识别策略强制执行的扫描。
- 使用新的 ID 令牌声明实施产物的加密验证。
- 通过适当的审计事件记录确保满足合规要求。

安全和合规团队可以利用此功能来：

- 使用作业页面上的新筛选器仅查看策略强制执行的作业。
- 通过访问作业 API 中的 `source` 字段来自动执行任务。
- 使用新的 ID 令牌声明实施产物验证：
  - `job_source`：标识作业的来源。
  - `job_policy_ref_uri`：指向策略文件（对于策略定义的作业）。
  - `job_policy_ref_sha`：包含策略的 git 提交 SHA。

<a id="enhanced-sorting-options-for-access-tokens"></a>

### 访问令牌的增强排序选项

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/personal_access_tokens.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/519716)

{{< /details >}}

UI 和 API 中的访问令牌现在有额外的排序选项。这些排序选项补充了极狐GitLab 现有的令牌管理功能，让您可以更好地控制访问令牌清单，并帮助您更好地维护访问令牌安全。新的排序选项包括：

- 按到期日期排序（升序）：查看最快到期的令牌。
- 按到期日期排序（降序）：查看剩余有效期最长的令牌。
- 按上次使用日期排序（升序）：查看最近未使用的令牌。
- 按上次使用日期排序（降序）：查看最近使用的令牌。

<a id="token-statistics-for-service-account-management"></a>

### 服务账号管理的令牌统计信息

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/service_accounts.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/520472)

{{< /details >}}

服务账号的令牌管理界面现在包含一个实用的统计仪表板，可一目了然地提供有关您令牌清单的信息。这些信息可以帮助您评估令牌的状态并识别需要关注的令牌。统计仪表板包含四个关键指标：

- 活跃令牌：查看活跃令牌的总数
- 即将到期的令牌：识别将在未来两周内到期的令牌
- 已撤销的令牌：跟踪被手动撤销的令牌
- 已过期的令牌：监控先前已过期的令牌
感谢 [Chaitanya Sonwane](https://gitlab.com/chaitanyason9)的贡献！

<a id="improved-pipeline-graph-visualization-for-failed-jobs"></a>

### 改进的失败作业流水线图可视化

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/_index.md#view-pipelines)

{{< /details >}}

您现在可以通过新的视觉指示器在流水线图中快速识别失败的作业。失败的作业组会在流水线图中高亮显示，失败的作业会分组在每个阶段的顶部。这种改进的可视化帮助您对流水线失败进行故障排除，而无需在复杂的流水线结构中搜索。

<a id="force-cancel-cicd-jobs-stuck-in-canceling-state"></a>

### 强制取消卡在取消中状态的 CI/CD 作业

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/_index.md#force-cancel-a-job) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467107)

{{< /details >}}

CI/CD 作业偶尔会卡在“取消中”状态，阻塞部署或对共享资源的访问。

拥有维护者[角色](../../user/permissions.md)的用户现在可以直接从作业日志页面强制取消这些卡住的作业，确保有问题的作业可以被正确终止。

<a id="improved-runner-management-in-projects"></a>

### 改进项目中的 Runner 管理

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/runners/runners_scope.md#project-runners)

{{< /details >}}

您现在可以在项目中更高效地管理 Runner。Runner 以单列布局显示，并组织在各自的列表中，而不是以前的两列视图。

这种改进的组织方式使查找和管理 Runner 变得更简单，新功能包括已分配项目列表、Runner 管理器以及 Runner 已运行的作业。有关计划在极狐GitLab 18.0 中提供的其他 Runner 管理改进的信息，请参阅[议题 33803](https://gitlab.com/gitlab-org/gitlab/-/issues/33803)。

<a id="gitlab-runner-1711"></a>

### 极狐GitLab Runner 17.11

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.11！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [对极狐GitLab Runner Windows 可执行文件进行代码签名](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/2483)

<a id="bug-fixes"></a>

#### 缺陷修复

- [在极狐GitLab Runner 17.10.0 中清理 Git 配置会导致错误](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38681)
- [`FF_DISABLE_UMASK_FOR_KUBERNETES_EXECUTOR` 标志不会禁用 `umask` 命令](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38382)

所有更改的列表在极狐GitLab Runner 的 [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-11-stable/CHANGELOG.md)中。
