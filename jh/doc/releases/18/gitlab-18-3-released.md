---
stage: Release Notes
group: Monthly Release
date: 2025-08-21
title: "极狐GitLab 18.3 发行说明"
description: "极狐GitLab 18.3 released with Duo Agent Platform in Visual Studio (Beta)"
---

2025 年 8 月 21 日，极狐GitLab 18.3 发布，包含了以下功能。

此外，我们感谢所有贡献者，包括本月的杰出贡献者。

<a id="primary-features"></a>

## 主要功能

<a id="embedded-views-powered-by-glql"></a>

### 嵌入式视图（由 GLQL 驱动）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/glql/_index.md#embedded-views) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15008)

{{< /details >}}

本版本将基于 GLQL 的嵌入式视图正式推出。你可以直接在 wiki 页面、史诗描述、议题评论以及合并请求中，创建并嵌入动态、可查询的极狐GitLab 数据视图。

嵌入式视图为团队提供了一个稳定的基础，无需在多个位置之间切换即可跟踪工作进展。使用熟悉的语法查询议题、合并请求、史诗等工作项，然后将结果以表格或列表形式展示，并可自定义字段和过滤。

嵌入式视图将静态文档转化为实时仪表板，与项目数据保持同步，帮助团队在整个工作流中保持上下文并改善协作。

我们欢迎你的反馈，以帮助我们持续增强嵌入式视图。请在[反馈议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/509792)中分享你的想法和建议。

<a id="migration-by-direct-transfer"></a>

### 直接传输迁移

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/import/direct_transfer_migrations.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11398)

{{< /details >}}

直接传输迁移现已正式推出。你可以使用极狐GitLab UI 或 [REST API](../../api/bulk_imports.md)，通过直接传输在极狐GitLab 实例之间迁移群组和项目。

相比于[通过上传导出文件进行迁移](../../user/project/settings/import_export.md#migrate-projects-by-uploading-an-export-file)，直接传输：

- 在处理大型项目时更可靠。
- 支持源实例和目标实例之间存在更大的版本差异的迁移。
- 在迁移过程和结果方面提供更好的洞察。

在 JihuLab.com 上，直接传输迁移默认启用。在私有化部署版上，管理员必须[启用该功能](../../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。

<a id="fine-grained-permissions-for-cicd-job-tokens"></a>

### CI/CD 作业令牌的细粒度权限

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/fine_grained_permissions.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15258)

{{< /details >}}

流水线安全变得更加灵活。作业令牌是提供对流水线中资源访问权限的临时凭证。在此之前，这些令牌会继承用户的全部权限，往往导致权限范围过宽。

借助我们新的作业令牌细粒度权限功能，你现在可以精确控制作业令牌在项目中可以访问哪些具体资源。这使你能够在 CI/CD 工作流中实施最小权限原则，在通过 CI/CD 作业令牌访问你的项目时，仅授予作业完成任务所需的最低访问权限。

我们正在积极努力增加[更多的细粒度权限](https://jihulab.com/groups/gitlab-cn/-/epics/6310)，以减少对流水线中长期令牌的依赖。

<a id="code-review-available-on-gitlab-duo-self-hosted-beta"></a>

### 极狐GitLab Duo 自托管版中的代码审查（Beta）

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/524929)

{{< /details >}}

你现在可以在极狐GitLab Duo 自托管版中使用极狐GitLab Duo 代码审查。该功能在极狐GitLab Duo 自托管版中为 Beta 阶段，支持国内 SOTA 模型。

使用极狐GitLab Duo 自托管版中的代码审查，可以在不牺牲数据主权的情况下加速你的开发流程。当代码审查你的合并请求时，它会识别潜在的错误并建议可立即应用的改进。在你请真人审查之前，先使用代码审查来迭代和改进你的变更。

请在[议题 517386](https://jihulab.com/gitlab-cn/gitlab/-/issues/517386)中提供有关代码审查的反馈。

<a id="customize-instructions-for-gitlab-duo-code-review"></a>

### 自定义极狐GitLab Duo 代码审查的说明指令

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/project/merge_requests/duo_in_merge_requests.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/545136)

{{< /details >}}

通过极狐GitLab Duo 代码审查的自定义说明指令，可以在项目中统一执行一致的代码审查标准。使用 glob 模式为不同的文件类型定义具体的审查标准，确保语言特定的规范在最需要的地方得以应用。

借助自定义说明指令，你可以：

- 描述团队的代码审查标准
- 使用 glob 模式定义文件特定的说明
- 查看明确标注了引用自定义指令的反馈

只需在仓库中创建一个包含自定义指令的 `.GitLab/duo/mr-review-instructions.YAML` 文件，极狐GitLab Duo 就会自动将这些指令纳入审查，并在提供反馈时引用具体的指令组。

请通过我们的[反馈议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/517386)分享你的想法和建议，帮助我们改进该功能。

<a id="bring-your-own-models-to-gitlab-duo-self-hosted-beta"></a>

### 将自有模型引入极狐GitLab Duo 自托管版（Beta）

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/517581)

{{< /details >}}

极狐GitLab Duo 自托管版现在允许你将自己的模型与极狐GitLab Duo 功能配合使用。该功能处于 Beta 阶段，面向所有拥有 GitLab Duo Enterprise 的私有化部署版客户开放。实例管理员可以为支持的极狐GitLab Duo 功能配置任何兼容的模型。

该功能使极狐GitLab Duo 自托管版更加灵活，但极狐GitLab 无法保证所有极狐GitLab Duo 功能都能与每个兼容模型正常工作。实例管理员负责验证所选模型的兼容性和性能。极狐GitLab 不为特定于你所选模型或平台的问题提供技术支持。

<a id="hybrid-model-selection-on-gitlab-duo-self-hosted-beta"></a>

### 极狐GitLab Duo 自托管版的混合模型选择（Beta）

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/17192)

{{< /details >}}

你现在可以在极狐GitLab Duo 自托管版中混合使用极狐GitLab AI 供应商模型和私有配置的自部署模型。该功能处于 Beta 阶段，面向所有 GitLab Duo Enterprise 客户的私有化部署版开放。

通过极狐GitLab Duo 自托管版的混合模型，私有化部署版的实例管理员现在可以按功能逐一选择使用自部署模型和自托管 AI 网关，或者极狐GitLab AI 供应商模型和极狐GitLab 托管的 AI 网关。这使管理员能够平衡安全性和可扩展性需求。要提供关于混合模型选择的反馈，请参阅[议题 561048](https://jihulab.com/gitlab-cn/gitlab/-/issues/561048)。

<a id="surfacing-violations-of-compliance-framework-controls-beta"></a>

### 合规框架控制违规的展示（Beta）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_violations_report.md)

{{< /details >}}

此前，合规违规报告提供了群组内所有项目合并请求活动的高层次视图。可用的合规违规主要与职责分离相关，例如：

- 检测到合并请求的作者批准了自己的合并请求。
- 合并请求在少于两次审批的情况下被合并。

然而，用户反馈表明，由于违规分类与实际合规用例不匹配，用户觉得分类令人困惑且难以理解。

极狐GitLab 18.3 显著增强了违规报告，将范围扩展到职责分离之外，涵盖了合规框架中合规控制与要求的违规行为。
每个自定义合规框架控制都关联了一个审计事件，提供关于违规行为的详细上下文：违规执行者、发生时间以及如何修复。
这包括用户名称和 IP 地址，以及可操作的修复建议。

这些改进为合规经理提供了更强大、更相关的上下文，确保组织遵守特定的合规框架，同时让人放心，不合规行为能够被有效识别、纠正和预防。

<a id="aws-secrets-manager-support-for-gitlab-cicd"></a>

### AWS Secrets Manager 对于极狐GitLab CI/CD 的支持

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/secrets/aws_secrets_manager.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/17822)

{{< /details >}}

存储在 AWS Secrets Manager 中的密钥现在可以轻松检索并在 CI/CD 作业中使用。我们与 AWS 的新集成简化了通过极狐GitLab CI/CD 与 AWS Secrets Manager 交互的流程，帮助我们的 AWS 客户简化构建和部署过程！

感谢 [Markus Siebert](https://gitlab.com/m-s-db) 和 [Henry Sachs](https://gitlab.com/DerAstronaut) 通过[极狐GitLab 的共创计划](https://gitlab.cn/community/co-create/)帮助构建了此功能！

<a id="custom-admin-role"></a>

### 自定义管理员角色

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15069)

{{< /details >}}

自定义管理员角色为私有化部署实例的管理区域带来了细粒度权限。管理员现在可以创建仅访问用户所需特定功能的专项角色，而非授予完全访问权限。该功能有助于组织实现管理功能的最小权限原则，降低因过度授权带来的安全风险，并提高运营效率。

如有疑问、希望分享实施经验，或想直接与我们的团队交流潜在改进，请参阅[反馈议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/509376)。

<a id="agentic-core"></a>

## 智能核心

<a id="more-models-available-for-use-with-gitlab-duo-self-hosted"></a>

### 更多可用于极狐GitLab Duo 自托管版的模型

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/560016)

{{< /details >}}

拥有 GitLab Duo Enterprise 的私有化部署版客户现在可以将国内 SOTA 模型与极狐GitLab Duo 自托管版配合使用。
国内 SOTA 模型支持在 AWS Bedrock 上使用。开源的国内 SOTA 模型已作为实验性模型添加，并可在 vLLM、Azure OpenAI 和 AWS Bedrock 上使用。要就使用这些模型提供反馈，请参阅[议题 523918](https://jihulab.com/gitlab-cn/gitlab/-/issues/523918)。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="new-navigation-experience-for-groups-in-your-work"></a>

### 您的工作中群组的新导航体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/_index.md#group-visibility) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/502487)

{{< /details >}}

我们很高兴地宣布对**您的工作**中的群组概览进行了重大改进，旨在简化你发现和访问群组的方式。
新的选项卡界面包含**成员**选项卡（提供可访问群组的综合视图）和**非活跃**选项卡（用于跟踪待删除的群组）。
我们还通过为具有适当权限的用户在列表视图中添加**编辑**和**删除**操作，简化了群组管理。
我们希望这些改进能让你更轻松地找到和管理对你最重要的群组。

我们重视你对此更新的反馈！加入[史诗 18401](https://jihulab.com/groups/gitlab-cn/-/epics/18401) 中的讨论，分享你使用新导航系统的体验。

<a id="enhanced-admin-area-projects-list"></a>

### 增强的管理区域项目列表

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/admin_area.md#administering-projects) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/17782)

{{< /details >}}

我们升级了**管理员**区域的项目列表，为极狐GitLab 管理员提供更一致的体验：

- 延迟删除保护：项目删除现在遵循整个极狐GitLab 使用的相同安全删除流程，防止意外数据丢失。
- 更快的交互：无需重新加载页面即可筛选、排序和分页项目，响应更迅速。
- 一致的界面：项目列表现在与极狐GitLab 中其他项目列表的外观和行为一致。

此更新使管理员体验符合极狐GitLab 的设计标准，并增加了重要的安全功能以保护你的数据。未来对项目管理的增强将自动在所有平台的项目列表中体现。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="improved-file-location-information-for-dependency-scanning-analyzer"></a>

### 依赖扫描分析器改进的文件位置信息

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#customizing-behavior-with-the-cicd-template) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/537716)

{{< /details >}}

能够将依赖项追溯到其来源非常重要，尤其在漏洞修复时。此前，依赖扫描分析器有时会指向作业产物，而这些产物在过期时会被删除。这使得追溯依赖来源变得困难。
依赖扫描分析器现在可以链接到引入依赖的项目文件。启用此选项后，依赖列表和漏洞报告中的链接是可靠的。
用户可以通过为依赖扫描作业设置 `DS_FF_LINK_COMPONENTS_TO_GIT_FILES=true` 来启用此功能。

<a id="user-defined-source-for-license-information"></a>

### 用户自定义的许可证信息来源

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#use-cyclonedx-report-as-a-source-of-license-information) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/501662)

{{< /details >}}

用户现在可以选择许可证信息的优先来源——极狐GitLab 许可证数据库或 CycloneDX SBOM 报告。这为用户在获取其开源依赖的许可证信息方面提供了更大的灵活性。
希望定义许可证信息来源的用户可以使用[安全配置 UI](../../user/application_security/detect/security_configuration.md#with-the-ui) 进行选择。默认情况下，我们使用 SBOM 数据作为许可证信息的来源。

<a id="concise-dast-job-output"></a>

### 简洁的 DAST 作业输出

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/browser/troubleshooting.md#what-is-dast-doing) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/18342)

{{< /details >}}

极狐GitLab 18.3 对动态应用安全测试作业输出进行了多项改进。

改进后的作业输出提供了清晰、结构化的信息，有助于你理解扫描结果并排查故障。

输出的每个部分都简洁直观，并在底部提供了指向我们故障排查文档的链接。
要覆盖简洁作业输出，可在 DAST 配置中设置 `DAST_FF_DIAGNOSTIC_JOB_OUTPUT: "true"`。

<a id="instance-level-compliance-and-policy-management-beta"></a>

### 实例级合规与策略管理（Beta）

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)

{{< /details >}}

企业用户希望跨多个顶级群组管理其合规框架和安全策略。
当实例中的所有群组都满足以下情况时，这通常是必要的：

- 共享相同的合规框架。例如，某一群组中的所有项目都必须遵守 ISO 27001 标准。
- 强制执行类似的策略。例如，所有群组共享相同的流水线执行策略。

从极狐GitLab 18.3 开始，合规和安全策略管理以 Beta 版本向私有化部署实例提供。你现在可以从一个顶级群组创建、配置和分配合规框架及安全策略，并将其强制执行到整个私有化部署实例的所有其他顶级群组。

当你使用合规和安全策略顶级群组时，你就拥有了一个唯一的真实来源，可以在此管理和编辑合规框架与安全策略。
然后，群组管理员可以将这些合规框架和安全策略应用于这些群组内的所有项目。

当你从选定的顶级合规和安全策略群组管理关键框架和策略时，可以更轻松地在整个私有化部署实例中管理和强制执行关键的合规与安全需求。
不过，群组仍然可以创建自己的合规框架和安全策略，以应对这些群组中可能出现的特定情况或工作流。

此功能面向私有化部署版客户，因为 JihuLab.com 客户已经能够在单个顶级群组或命名空间内集中管理策略。

<a id="faster-workspace-startup-with-shallow-cloning"></a>

### 通过浅克隆加速工作区启动

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/_index.md#shallow-cloning)

{{< /details >}}

工作区现在使用浅克隆来缩短启动时间。在初始化过程中，极狐GitLab 仅下载最新的提交历史记录，而不是完整的 Git 历史记录。工作区启动后，Git 会在后台将浅克隆转换为完整克隆。

此功能自动应用于所有新工作区，无需配置，且不会影响你的开发工作流。

<a id="new-cli-commands-for-gitlab-managed-opentofu-and-terraform-states"></a>

### 用于极狐GitLab 管理的 OpenTofu 和 Terraform 状态的新 CLI 命令

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/infrastructure/iac/terraform_state.md) | [相关议题](https://jihulab.com/gitlab-cn/cli/-/issues/7954)

{{< /details >}}

极狐GitLab CLI (`glab`) 现在包含一个新的顶级命令 `opentofu`。
`opentofu` 命令被别名为 `terraform` 和 `tf` 命令，以辅助管理极狐GitLab 管理的 OpenTofu 和 Terraform 状态。

已添加以下命令：

- `glab opentofu init`：在本地初始化状态后端。
- `glab opentofu state list`：列出项目中的所有状态。
- `glab opentofu state download`：下载最新状态或特定版本。
- `glab opentofu state delete`：删除整个状态或特定版本。
- `glab opentofu state lock`：锁定一个状态。
- `glab opentofu state unlock`：解锁一个状态。

要使用 `opentofu` 命令管理状态，你必须至少安装 `glab` 1.66 或更高版本。

<a id="kubernetes-133-support"></a>

### Kubernetes 1.33 支持

{{< details >}}
{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/538906)

{{< /details >}}

极狐GitLab 现已完全支持 Kubernetes 1.33 版本。如果你将应用部署到 Kubernetes，可以将已连接的集群升级到最新版本，并利用其所有功能。

更多信息，请参阅[极狐GitLab 功能支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。

<a id="oauth-apps-support-sso-authentication"></a>

### OAuth 应用支持 SSO 认证

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/oauth2.md#authorization-code-flow)

{{< /details >}}

OAuth 应用现在可以无缝集成组织的单点登录要求。以前，用户需要进行两次认证：先是极狐GitLab，然后是 SSO，这造成了不必要的摩擦和复杂性。

现在，OAuth 应用可以在其授权请求中指定一个参数，以便在需要时自动触发 SSO 认证。这提供了：

- 统一的用户认证体验
- 自动遵守组织的 SSO 策略
- 所有极狐GitLab 集成的一致性安全
- 开发者只需添加一个参数即可实现简单集成

你的 OAuth 集成现在会自动遵守 SSO 策略，消除混乱的认证工作流，同时保持安全性。

<a id="control-unique-domains-default-for-gitlab-pages-sites"></a>

### 控制极狐GitLab Pages 站点的唯一域名默认值

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/pages/_index.md#disable-unique-domains-by-default)

{{< /details >}}

管理员现在可以为新的极狐GitLab Pages 站点设置唯一域名的默认行为。默认情况下，新的 Pages 站点使用唯一域名 URL（例如 `my-project-1a2b3c.example.com`）来防止站点之间的 Cookie 共享。

通过针对实例的这个新设置，你可以默认将新的 Pages 站点设置为使用基于路径的 URL（例如 `my-namespace.example.com/my-project`）。这有助于组织将极狐GitLab Pages 行为与其工作流程和安全要求保持一致。

用户仍然可以为单个项目覆盖此设置，现有的 Pages 站点不受影响。

<a id="enhancements-to-wiki-functionality"></a>

### Wiki 功能增强

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/discussions/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16403)

{{< /details >}}

此版本引入了增强的 Wiki 体验，包含三项关键改进：你现在可以订阅 Wiki 页面，在编辑页面时查看 Wiki 评论，以及对 Wiki 页面评论进行排序。

这些增强功能通过以下方式帮助团队更有效地协作文档：

- 在上下文中直接讨论内容。
- 提出改进和更正建议。
- 保持文档准确和最新。
- 分享知识和专业技能。

通过这些更新，你的极狐GitLab Wiki 变成了活的文档，通过直接反馈和讨论随着项目一起演进。

<a id="bulk-edit-epic-assignees-milestones-and-more"></a>

### 批量编辑史诗指派人、里程碑等

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#bulk-edit-epics) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11901)

{{< /details >}}

你现在可以在群组中批量编辑更多史诗属性。除了标签之外，你现在可以一次更新多个史诗的指派人、健康状态、订阅、机密性和里程碑。

此增强功能通过让你同时对多个史诗应用相同的更改，加快了大量史诗的管理速度。

<a id="grant-pipeline-execution-policies-access-to-cicd-configurations-via-api"></a>

### 通过 API 授予流水线执行策略对 CI/CD 配置的访问权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/projects.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524124)

{{< /details >}}

使用项目 REST API，通过新的 `spp_repository_pipeline_access` 字段，以编程方式启用或禁用安全策略项目中的**流水线执行政策**设置。以前，此设置只能通过极狐GitLab 用户界面进行管理。通过此次增强，你现在可以：

- `GET` 当前的**流水线执行政策**状态。
- `PUT` 以编程方式启用或禁用该设置。

此改进为大规模管理安全策略的团队提供了更好的自动化和集成工作流。

<a id="group-by-owasp-2021-in-the-vulnerability-report"></a>

### 在漏洞报告中按 OWASP 2021 分组

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#advanced-vulnerability-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/532703)

{{< /details >}}

在项目和群组的漏洞报告中，你现在可以按 OWASP 十大 2021 类别对漏洞进行分组。仅在 JihuLab.com 实例上可用。

<a id="scan-execution-policy-templates"></a>

### 扫描执行策略模板

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md#scan-execution-policy-editor) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11919)

{{< /details >}}

扫描执行策略模板帮助你根据常见用例快速创建扫描执行策略。从三个模板中选择：

- 合并请求安全
- 定时扫描
- 发布安全

选择模板后，选择要使用该模板启用哪些极狐GitLab 安全扫描，即可立即启动并运行。如果你有更高级的用例，可以切换到自定义配置以使用特定的分支模式、流水线来源等扩展策略。

<a id="security-policy-audit-events"></a>

### 安全策略审计事件

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_streaming.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15869)

{{< /details >}}

极狐GitLab 旗舰版现在为安全策略管理提供全面的审计事件，事件在各个安全策略项目中整理和集中。

安全团队现在可以：

- 使用详细的元数据跟踪所有策略修改。
- 监控执行失败，包括扫描和流水线执行失败。
- 监控被跳过的扫描执行和流水线执行流水线。
- 检测每个项目内的策略违规，包括合并带有策略违规的 MR。
- 在超出限制时接收警报。
- 检测策略配置错误。
- 对 high-volume 场景使用仅流式选项。

新的审计事件包括：

- [security_policy_create](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_create.yml)
- [security_policy_delete](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_delete.yml)
- [security_policy_update](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_update.yml)
- [security_policy_merge_request_merged_with_policy_violations](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_merge_request_merged_with_policy_violations.yml)
- [security_policy_yaml_invalidated](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_yaml_invalidated.yml)
- [security_policies_limit_exceeded](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_yaml_invalidated.yml)
- [security_policy_violations_detected](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_violations_detected.yml) (仅流式)
- [security_policy_pipeline_failed](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_pipeline_failed.yml) (仅流式)
- [security_policy_pipeline_skipped](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_pipeline_skipped.yml) (仅流式)
- [merge_request_branch_bypassed_by_security_policy](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/audit_events/types/merge_request_branch_bypassed_by_security_policy.yml)

此增强功能通过确保你能访问策略更改、配置错误和执行漏洞来加强你的安全态势，从而实现更快的事件响应和全面的审计能力。

<a id="service-account-and-access-token-exceptions-for-approval-policies"></a>

### 审批策略的服务账户和访问令牌例外

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md#access-token-and-service-account-exceptions) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18112)

{{< /details >}}

新的**服务账户和访问令牌例外**功能允许你指定可以在必要时绕过合并请求审批策略的服务账户和访问令牌。这消除了已知自动化的摩擦，同时保留了安全控制。

**主要功能包括：**

- 自动化工作流支持：配置特定的服务账户、Bot 用户、群组访问令牌和项目访问令牌，以绕过 CI/CD 流水线、拉取镜像和自动版本更新的审批要求。服务账户可以使用已批准的令牌直接推送到受保护分支，同时对人类用户保持限制。
- 紧急访问和审计：通过全面的审计跟踪为关键事件启用“玻璃破碎”场景。所有绕过事件都会生成带有上下文和推理的详细审计日志，支持合规性要求，同时允许在中断或安全修复期间快速响应。
- GitOps 集成：解决常见的自动化挑战，包括仓库镜像、外部 CI 系统（Jenkins、CloudBees）、自动更改日志生成和 GitFlow 发布流程。服务账户获得所需的最低权限，令牌访问范围限定于特定的项目和分支。

此增强功能为现代 DevOps 自动化需求保持了严格的安全策略与灵活性，消除了自定义变通方法，同时保留了治理控制。

<a id="saml-sso-support-for-session-timeout-attribute"></a>

### SAML SSO 支持会话超时属性

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/saml_sso/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/262074)

{{< /details >}}

极狐GitLab 现在自动检测并遵守来自身份提供商 (IdP) 的 SAML 断言中的 `SessionNotOnOrAfter` 属性。
当此属性存在时，极狐GitLab 会将用户会话设置为在 IdP 指定的时间过期，
确保整个组织内的会话管理保持一致。此功能不需要更改配置 - 如果你的 IdP 提供了该属性，极狐GitLab 会自动遵守指定的过期时间。

<a id="additional-service-account-email-configuration-options"></a>

### 额外的服务账号邮箱配置选项

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/service_accounts.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/537976)

{{< /details >}}

默认情况下，极狐GitLab 会自动为新的服务账号生成邮箱地址。组织现在可以通过 UI 为服务账号分配自定义邮箱地址。以前，自定义邮箱配置只能通过 Service Accounts API 实现。此项变更使组织能够更好地将通知路由到指定的邮箱地址。

<a id="enterprise-user-enhancements"></a>

### 企业用户增强

{{< details >}}

- Tier: Silver，Gold
- Offering: JihuLab.com
- Links: [文档](../../user/enterprise_user/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9262)

{{< /details >}}

极狐GitLab 18.3 引入了企业用户增强功能，使组织能够更好地控制用户隐私和生命周期管理。

群组所有者现在可以使用 Users API 删除其命名空间中的企业用户。这是一个破坏性操作，会取消用户贡献的关联，并将其与系统范围的 Ghost 用户关联起来。这些选项对于清理通过自动 SCIM 导入错误创建的用户或管理需要重新利用用户名和邮箱的联合环境特别有价值。

此外，组织现在可以在其用户档案上隐藏企业用户的邮箱，为所有企业用户提供更广泛的邮箱隐私执行。

<a id="ssh-key-security-warnings"></a>

### SSH 密钥安全警告

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/ssh.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432624)

{{< /details >}}

当用户上传弱 SSH 密钥时，极狐GitLab 现在会在 UI 中显示安全警告。此警告出现在较旧的密钥类型或位长不足（小于 2048 位）的密钥上。此变更有助于教育用户了解 SSH 密钥安全最佳实践，并鼓励使用更强的加密密钥。

<a id="gitlab-runner-183"></a>

### 极狐GitLab Runner 18.3

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.3！极狐GitLab Runner 是高度可扩展的构建代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab 中包含的开源持续集成服务极狐GitLab CI/CD 协同工作。

#### Bug 修复

- [在极狐GitLab 18.2.0 中，Runner 无法使用子目录文件作为缓存键拉取作业缓存](https://gitlab.com/gitlab-org/gitlab/-/issues/556464)
- [Docker 执行器间歇性无法启动作业并返回 `incorrect username or password` 错误消息。](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38707)
- [`none` 和 `empty` Git 策略之间 `*_get_sources` 钩子使用不一致](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38703)
- [使用非 OLM 清单部署的 Operator 假定错误的默认镜像](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/228)
- [如果 CR 具有 `app.kubernetes.io/instance` 标签，Operator 会创建名称错误的 ConfigMap](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/183)
- [OpenShift 4.9 上的 Operator 1.10.0 无法创建 Runner ConfigMap 并在 `gitlab-runner` 命名空间中启动 pod](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/138)

#### 新功能

- [极狐GitLab Runner Operator 现在支持 Runner Manager Pod 注解](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/245)
- [极狐GitLab Runner Operator 现在支持 OpenShift 4.19](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/253)

所有变更的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-3-stable/CHANGELOG.md) 中。