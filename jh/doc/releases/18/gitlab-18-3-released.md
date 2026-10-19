---
stage: Release Notes
group: Monthly Release
date: 2025-08-21
title: "极狐GitLab 18.3 发布说明"
description: "极狐GitLab 18.3 发布，包含 Visual Studio 中的 Duo Agent Platform（测试版）"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 8 月 21 日，极狐GitLab 18.3 发布，包含了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="duo-agent-platform-in-visual-studio-beta"></a>

### Visual Studio 中的 Duo Agent Platform（测试版）

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/editor-extensions/-/epics/179)

{{< /details >}}

我们很高兴地宣布，面向 Visual Studio 的 Duo Agent Platform 公开测试版正式发布！通过此版本，Visual Studio 用户现在可以直接在其 IDE 中使用 Duo Agent Platform 先进的 AI 驱动能力。

Duo Agent Platform 为您的开发工作流带来两项强大的功能：

- **Agentic Chat**：快速完成对话式任务，例如创建和编辑文件、使用模式匹配和 grep 搜索代码库，以及即时获取有关代码的解答——全程无需离开 Visual Studio。
- **Agent 任务流**：借助全面的规划和实施支持，处理更大、更复杂的任务。Agent 任务流可帮助您将高层级想法转化为架构和代码，并利用议题、合并请求、提交、CI/CD 流水线和安全漏洞等极狐GitLab 资源。

这两项功能都支持跨文档、代码模式和项目信息的智能搜索，让您能够无缝地从快速编辑过渡到深入的项目分析。

立即在 Visual Studio 中试用 Duo Agent Platform 测试版，在您的开发工作流中体验全新水平的生产力和 AI 辅助。

<a id="embedded-views-powered-by-glql"></a>

### 嵌入式视图（由 GLQL 提供支持）

<!-- categories: Markdown, Wiki, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/glql/_index.md#embedded-views) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15008)

{{< /details >}}

此版本将由 GLQL 提供支持的嵌入式视图正式发布。您可以直接在工作所在的位置创建并嵌入极狐GitLab 数据的动态、可查询视图：Wiki 页面、史诗描述、议题评论和合并请求。

嵌入式视图为团队提供了稳定的基础，无需在多个位置之间切换即可跟踪工作进度。使用熟悉的语法查询议题、合并请求、史诗和其他工作项，然后将结果以表格或列表形式显示，并支持自定义字段和筛选。

嵌入式视图将静态文档转变为与项目数据保持同步的动态仪表板，帮助团队在整个工作流中保持上下文并改善协作。

在我们持续增强嵌入式视图的过程中，欢迎您提供反馈。请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/509792)中分享您的想法和建议。

<a id="migration-by-direct-transfer"></a>

### 通过直接传输进行迁移

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/direct_transfer_migrations.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11398)

{{< /details >}}

通过直接传输进行迁移已正式发布。要通过直接传输在极狐GitLab 实例之间迁移极狐GitLab 群组和项目，您可以使用极狐GitLab UI 或 [REST API](../../api/bulk_imports.md)。

与[通过上传导出文件进行迁移](../../user/project/settings/import_export.md#migrate-projects-by-uploading-an-export-file)相比，直接传输：

- 在处理大型项目时更可靠。
- 支持源实例和目标实例之间更大的版本差距。
- 提供对迁移过程和结果的更好洞察。

在 JihuLab.com 上，通过直接传输进行迁移默认启用。在极狐GitLab 私有化部署上，管理员必须[启用该功能](../../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。

<a id="fine-grained-permissions-for-cicd-job-tokens"></a>

### CI/CD 作业令牌的精细权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/fine_grained_permissions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15258)

{{< /details >}}

流水线安全现在更加灵活。作业令牌是临时凭证，用于访问流水线中的资源。在此之前，这些令牌会继承用户的完整权限，往往导致不必要的宽泛访问能力。

借助我们全新的作业令牌精细权限功能，您现在可以精确控制作业令牌在项目中可以访问哪些特定资源。这使您能够在 CI/CD 工作流中实施最小权限原则，在使用 CI/CD 作业令牌访问项目时，仅授予作业完成任务所需的最小访问权限。

我们正在积极添加[更多精细权限](https://gitlab.com/groups/gitlab-org/-/epics/6310)，以减少流水线中对长期有效令牌的依赖。

<a id="code-review-available-on-gitlab-duo-self-hosted-beta"></a>

### 代码评审已在极狐GitLab Duo 自部署版本上推出（测试版）

<!-- categories: Code Suggestions, Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524929)

{{< /details >}}

您现在可以在极狐GitLab Duo 自部署版本上使用极狐GitLab Duo 代码评审。此功能在极狐GitLab Duo 自部署版本上处于测试版阶段，支持 Mistral、Meta Llama、Anthropic Claude 和 OpenAI GPT 模型系列。

在极狐GitLab Duo 自部署版本上使用代码评审，可在不牺牲数据主权的情况下加速您的开发流程。当代码评审审阅您的合并请求时，它会识别潜在缺陷并建议改进，供您直接应用。在请人工审阅之前，您可以使用代码评审来迭代和改进您的变更。

请在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中提供有关代码评审的反馈。

<a id="customize-instructions-for-gitlab-duo-code-review"></a>

### 为极狐GitLab Duo 代码评审自定义审查指令

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/545136)

{{< /details >}}

使用极狐GitLab Duo 代码评审的自定义审查指令，在您的项目中强制执行一致的代码评审标准。使用 glob 模式为不同文件类型定义特定的审查标准，确保在最需要的地方应用特定语言的约定。

借助自定义审查指令，您可以：

- 描述您团队的代码评审标准
- 使用 glob 模式定义针对特定文件的指令
- 查看明确标注并引用您的自定义审查指令的反馈

只需在您的代码仓库中创建一个包含自定义审查指令的`.GitLab/duo/mr-review-instructions.YAML` 文件。极狐GitLab Duo 会自动将这些指令纳入其评审中，并在提供反馈时引用特定的指令组。

请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中分享您的想法和建议，帮助我们改进此功能。

<a id="bring-your-own-models-to-gitlab-duo-self-hosted-beta"></a>

### 将您自己的模型引入极狐GitLab Duo 自部署版本（测试版）

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/517581)

{{< /details >}}

极狐GitLab Duo 自部署版本现在允许您引入自己的模型，以配合极狐GitLab Duo 功能使用。此功能处于测试版阶段，面向所有拥有极狐GitLab Duo Enterprise 的极狐GitLab 私有化部署客户提供。实例管理员可以配置任何兼容的模型，以配合受支持的极狐GitLab Duo 功能使用。

此功能使极狐GitLab Duo 自部署版本更加灵活，但极狐GitLab 无法保证所有极狐GitLab Duo 功能都能与每个兼容模型配合使用。实例管理员负责验证其所选模型的兼容性和性能。极狐GitLab 不针对您所选模型或平台特有的问题提供技术支持。

<a id="hybrid-model-selection-on-gitlab-duo-self-hosted-beta"></a>

### 极狐GitLab Duo 自部署版本上的混合模型选择（测试版）

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17192)

{{< /details >}}

您现在可以在极狐GitLab Duo 自部署版本上混合使用极狐GitLab AI 供应商模型和私有配置的自部署模型。此功能处于测试版阶段，在极狐GitLab 私有化部署上面向所有极狐GitLab Duo Enterprise 客户提供。

借助极狐GitLab Duo 自部署版本上的混合模型，极狐GitLab 私有化部署实例管理员现在可以按功能逐一选择使用自部署模型和自部署 AI 网关，或使用极狐GitLab AI 供应商模型和极狐GitLab 托管的 AI 网关。这使管理员能够平衡其安全性和可扩展性需求。要提供有关混合模型选择的反馈，请参阅[议题 561048](https://gitlab.com/gitlab-org/gitlab/-/issues/561048)。

<a id="surfacing-violations-of-compliance-framework-controls-beta"></a>

### 呈现合规框架控制的违规情况（测试版）

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_violations_report.md)

{{< /details >}}

此前，合规违规报告提供群组中所有项目合并请求活动的高层级视图。可用的合规违规涉及职责分离方面的关注点，例如：

- 检测合并请求的作者何时批准了自己的合并请求。
- 合并请求在少于两次审批的情况下被合并。

然而，用户反馈显示，用户认为违规分类令人困惑且难以理解，因为它们与实际合规用例的契合度不佳。

极狐GitLab 18.3 显著增强了违规报告，将其范围从职责分离扩展到包括合规框架中合规控制和要求的违规情况。每个自定义合规框架控制都有一个关联的审计事件，提供有关违规的详细上下文：谁实施了违规、何时发生以及如何修复。这包括用户的姓名和 IP 地址，以及可操作的补救建议。

这些改进为合规管理员提供了更强大、更相关的上下文，以确保其组织遵守特定的合规框架，同时让他们确信不合规情况可以被有效识别、纠正和预防。

<a id="new-web-ide-source-control-operations"></a>

### 新的 Web IDE 源代码管理操作

<!-- categories: Web IDE -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/web_ide/_index.md#use-source-control)

{{< /details >}}

我们很高兴地宣布 Web IDE 中新增了源代码管理功能。您无需离开浏览器即可更高效地管理 Git 工作流。在**源代码管理**面板中，您现在可以：

- 创建和删除分支。
- 以任何现有分支为基础创建分支。
- 修正上一次提交以进行快速修复。
- 直接从界面强制推送变更。

这些增强功能让 Git 操作触手可及。有关您可用的功能的信息，请参阅[使用源代码管理](../../user/project/web_ide/_index.md#use-source-control)。

<a id="aws-secrets-manager-support-for-gitlab-cicd"></a>

### 极狐GitLab CI/CD 支持 AWS 密钥管理器

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/secrets/aws_secrets_manager.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17822)

{{< /details >}}

存储在 AWS 密钥管理器中的密钥现在可以轻松检索并在 CI/CD 作业中使用。我们与 AWS 的新集成简化了通过极狐GitLab CI/CD 与 AWS 密钥管理器交互的过程，帮助我们的 AWS 客户简化构建和部署流程！

感谢 [Markus Siebert](https://gitlab.com/m-s-db) 和 [Henry Sachs](https://gitlab.com/DerAstronaut)，他们通过 [GitLab 的 Co-Create 计划](https://about.gitlab.com/community/co-create/)帮助构建了此功能！

<a id="custom-admin-role"></a>

### 自定义管理员角色

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 链接: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15069)

{{< /details >}}

自定义管理员角色为极狐GitLab 私有化部署实例的管理区域带来了精细权限。管理员现在可以创建专门的角色，仅访问用户所需的特定功能，而不是授予完整访问权限。此功能帮助组织对管理功能实施最小权限原则，降低因权限过高而带来的安全风险，并提高运营效率。

如果您有疑问、想分享您的实施经验，或希望就潜在改进直接与我们的团队交流，请参阅[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/509376)。

<a id="agentic-core"></a>

## AI 功能

<a id="more-models-available-for-use-with-gitlab-duo-self-hosted"></a>

### 更多可用于极狐GitLab Duo 自部署版本的模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/560016)

{{< /details >}}

拥有极狐GitLab Duo Enterprise 的极狐GitLab 私有化部署客户现在可以在极狐GitLab Duo 自部署版本上使用 Anthropic Claude 4。
Claude 4 在 AWS Bedrock 上受支持。开源 OpenAI GPT OSS 20B 和 120B 已作为实验性模型添加，
可在 vLLM、Azure OpenAI 和 AWS Bedrock 上使用。要提供有关在极狐GitLab Duo 自部署版本上使用这些模型的反馈，
请参阅[议题 523918](https://gitlab.com/gitlab-org/gitlab/-/issues/523918)。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="new-navigation-experience-for-groups-in-your-work"></a>

### “您的工作”中群组的新导航体验

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/_index.md#group-visibility) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502487)

{{< /details >}}

我们很高兴地宣布对**您的工作**中的群组概览进行了重大改进，旨在简化您发现和访问群组的方式。新的选项卡式界面包含一个**成员**选项卡，提供可访问群组的全面视图，以及一个**非活跃**选项卡，用于跟踪待删除的群组。我们还通过为具有相应权限的用户在列表视图中添加**编辑**和**删除**操作，简化了群组管理。我们希望这些改进能让您更轻松地查找和管理对您最重要的群组。

我们重视您对此更新的反馈！请加入[史诗 18401](https://gitlab.com/groups/gitlab-org/-/epics/18401)中的讨论，分享您对新导航系统的体验。

<a id="enhanced-admin-area-projects-list"></a>

### 增强的**管理**区域项目列表

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/admin_area.md#administering-projects) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17782)

{{< /details >}}

我们升级了**管理**区域项目列表，为极狐GitLab 管理员提供更一致的体验：

- 延迟删除保护：项目删除现在遵循极狐GitLab 中通用的安全删除流程，防止意外数据丢失。
- 更快的交互：无需重新加载页面即可筛选、排序和分页项目，体验更流畅。
- 一致的界面：项目列表现在与极狐GitLab 中其他项目列表的外观和行为保持一致。

此更新使管理员体验与极狐GitLab 设计标准保持一致，并添加了重要的安全功能来保护您的数据。未来对项目管理的增强将自动出现在整个平台的所有项目列表中。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="improved-file-location-information-for-dependency-scanning-analyzer"></a>

### 改进依赖扫描分析器的文件位置信息

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#customizing-behavior-with-the-cicd-template) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/537716)

{{< /details >}}

能够将依赖项追溯到其来源非常重要，尤其是在漏洞修复方面。此前，依赖扫描分析器有时会链接到作业产物，而这些产物在过期时会被删除。这使得追溯依赖项的来源变得困难。依赖扫描分析器现在可以链接到引入该依赖项的项目文件。启用此选项后，依赖项列表和漏洞报告中的链接是可靠的。用户可以通过为依赖扫描作业设置 `DS_FF_LINK_COMPONENTS_TO_GIT_FILES=true` 来启用此功能。

<a id="user-defined-source-for-license-information"></a>

### 用户定义的许可证信息来源

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#use-cyclonedx-report-as-a-source-of-license-information) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501662)

{{< /details >}}

用户现在可以选择哪个许可证信息来源具有优先级——
极狐GitLab 许可证数据库或 CycloneDX SBOM 报告。这为用户
为其开源依赖项获取许可证信息提供了更大的灵活性。希望定义许可证信息来源的用户可以使用[安全配置 UI](../../user/application_security/detect/security_configuration.md#with-the-ui) 进行选择。默认情况下，我们使用 SBOM 数据作为许可证信息的来源。

<a id="concise-dast-job-output"></a>

### 简洁的 DAST 作业输出

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/troubleshooting.md#what-is-dast-doing) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18342)

{{< /details >}}

极狐GitLab 18.3 为动态分析安全测试作业输出引入了多项改进。

这种改进的作业输出提供清晰、结构化的信息，帮助您理解扫描结果并对故障进行故障排除。

作业输出的每个部分都简洁直观，输出底部附有指向我们故障排除文档的链接。要覆盖简洁的作业输出，请在 DAST 配置中设置 `DAST_FF_DIAGNOSTIC_JOB_OUTPUT: "true"`。

<a id="instance-level-compliance-and-policy-management-beta"></a>

### 实例级合规与策略管理（测试版）

<!-- categories: Compliance Management, Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 链接: [文档](../../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)

{{< /details >}}

企业用户希望跨多个顶级群组管理其合规框架和安全策略。当实例中的所有群组出现以下情况时，通常就是如此：

- 共享相同的合规框架。例如，当群组中的所有项目都必须遵守 ISO 27001 标准时。
- 强制执行类似的策略。例如，当所有群组共享相同的流水线执行策略时。

借助极狐GitLab 18.3，合规与安全策略管理现已在极狐GitLab 私有化部署实例上以测试版提供。您现在可以从单个顶级群组创建、配置和分配合规框架和安全策略，并在您的极狐GitLab 私有化部署实例中的所有其他顶级群组中强制执行它们。

当您使用合规与安全策略顶级群组时，您就拥有了一个单一事实来源，可以在其中管理和编辑您的合规框架和安全策略。群组管理员随后可以将这些合规框架和安全策略应用于这些群组内的所有项目。

当您从选定的顶级合规与安全策略群组管理关键框架和策略时，在您的极狐GitLab 私有化部署实例中管理和强制执行关键合规与安全需求会更容易。不过，群组仍然保留创建自己的合规框架和安全策略的能力，以应对这些群组中可能出现的特定情况或工作流。

此功能面向极狐GitLab 私有化部署客户，因为 JihuLab.com 客户已经能够在单个顶级群组或命名空间内集中管理策略。

<a id="faster-workspace-startup-with-shallow-cloning"></a>

### 通过浅克隆加快工作区启动速度

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md#shallow-cloning)

{{< /details >}}

工作区现在使用浅克隆来缩短启动时间。在初始化期间，极狐GitLab 仅下载最新的提交历史，而不是完整的 Git 历史。工作区启动后，Git 会在后台将浅克隆转换为完整克隆。

此功能自动应用于所有新工作区，无需任何配置，并且不会影响您的开发工作流。

<a id="new-cli-commands-for-gitlab-managed-opentofu-and-terraform-states"></a>

### 极狐GitLab 托管的 OpenTofu 和 Terraform 状态的新 CLI 命令

<!-- categories: GitLab CLI, Infrastructure as Code -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/infrastructure/iac/terraform_state.md) | [相关议题](https://gitlab.com/gitlab-org/cli/-/issues/7954)

{{< /details >}}

GitLab CLI（`glab`）现在包含一个新的顶级命令 `opentofu`。`opentofu` 命令是 `terraform` 和 `tf` 命令的别名，用于协助管理极狐GitLab 托管的
OpenTofu 和 Terraform 状态。

已添加以下命令：

- `glab opentofu init`：在本地初始化状态后端。
- `glab opentofu state list`：列出项目中的所有状态。
- `glab opentofu state download`：下载最新状态或特定版本。
- `glab opentofu state delete`：删除整个状态或特定版本。
- `glab opentofu state lock`：锁定状态。
- `glab opentofu state unlock`：解锁状态

要使用 `opentofu` 命令管理状态，您必须至少使用 `glab` 1.66 或更高版本。

<a id="kubernetes-133-support"></a>

### 支持 Kubernetes 1.33

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/538906)

{{< /details >}}

极狐GitLab 现在完全支持 Kubernetes 1.33 版本。如果您将应用部署到 Kubernetes，可以将已连接的集群升级到最新版本，并利用其所有功能。

有关更多信息，请参阅[极狐GitLab 功能支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。

<a id="oauth-apps-support-sso-authentication"></a>

### OAuth 应用支持 SSO 身份验证

<!-- categories: Pages, System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/oauth2.md#authorization-code-flow)

{{< /details >}}

OAuth 应用现在可以与您组织的单点登录要求无缝集成。此前，用户必须进行两次身份验证：先通过极狐GitLab，再通过 SSO，造成了不必要的摩擦和复杂性。

现在，OAuth 应用可以在其授权请求中指定一个参数，以在需要时自动触发 SSO 身份验证。这提供了：

- 统一的用户身份验证体验
- 自动遵守您组织的 SSO 策略
- 所有极狐GitLab 集成中一致的安全性
- 开发者只需添加一个参数即可轻松实现

您的 OAuth 集成现在会自动遵守 SSO 策略，在保持安全性的同时消除了令人困惑的身份验证工作流。

<a id="control-unique-domains-default-for-gitlab-pages-sites"></a>

### 控制 GitLab Pages 站点的唯一域名默认设置

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/pages/_index.md#disable-unique-domains-by-default)

{{< /details >}}

管理员现在可以为新的 GitLab Pages 站点设置唯一域名的默认行为。默认情况下，新的 Pages 站点使用唯一域名 URL（如 `my-project-1a2b3c.example.com`）以防止站点之间共享 cookie。

借助此实例新设置，您可以将新的 Pages 站点默认设置为使用基于路径的 URL（如 `my-namespace.example.com/my-project`）。这有助于组织将 GitLab Pages 行为与其工作流和安全要求保持一致。

用户仍然可以为单个项目覆盖此设置，现有 Pages 站点不受影响。

<a id="enhancements-to-wiki-functionality"></a>

### Wiki 功能增强

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/discussions/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16403)

{{< /details >}}

此版本引入了增强的 Wiki 体验，包含三项关键改进：您现在可以订阅 Wiki 页面、在编辑页面时查看 Wiki 评论，以及对 Wiki 页面评论进行排序。

这些增强功能通过让您能够执行以下操作，帮助团队更有效地在文档上协作：

- 直接在上下文中讨论内容。
- 提出改进和更正建议。
- 保持文档准确且最新。
- 分享知识和专业技能。

借助这些更新，您的极狐GitLab Wiki 成为动态文档，通过直接反馈和讨论与您的项目一同演进。

<a id="bulk-edit-epic-assignees-milestones-and-more"></a>

### 批量编辑史诗的指派人、里程碑等

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md#bulk-edit-epics) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11901)

{{< /details >}}

您现在可以在群组中批量编辑更多史诗属性。除了标记之外，您现在还可以一次更新多个史诗的指派人、健康状态、订阅、机密性和里程碑。

此增强功能让您能够同时对多个史诗应用相同的更改，从而更快地管理大量史诗。

<a id="grant-pipeline-execution-policies-access-to-cicd-configurations-via-api"></a>

### 通过 API 授予流水线执行策略访问 CI/CD 配置的权限

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/projects.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524124)

{{< /details >}}

使用项目 REST API，通过新的 `spp_repository_pipeline_access` 字段，以编程方式启用或禁用安全策略项目中的**流水线执行策略**设置。此前，此设置只能通过极狐GitLab UI 管理。借助此增强功能，您现在可以：

- `GET` 当前的**流水线执行策略**状态。
- `PUT` 以编程方式启用或禁用该设置。

此改进为大规模管理安全策略的团队实现了更好的自动化和集成工作流。

<a id="group-by-owasp-2021-in-the-vulnerability-report"></a>

### 在漏洞报告中按 OWASP 2021 分组

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#advanced-vulnerability-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/532703)

{{< /details >}}

在项目和群组的漏洞报告中，您现在可以按 OWASP Top 10 2021 类别对漏洞进行分组。仅适用于 JihuLab.com 实例。

<a id="scan-execution-policy-templates"></a>

### 扫描执行策略模板

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md#scan-execution-policy-editor) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11919)

{{< /details >}}

扫描执行策略模板可帮助您基于常见用例快速创建扫描执行策略。可从三个模板中选择：

- 合并请求安全
- 计划扫描
- 发布安全

选择模板后，选择要随模板启用的极狐GitLab 安全扫描，即可立即开始使用。如果您有更高级的用例，可以切换到自定义配置，使用特定的分支模式、流水线来源等来扩展策略。

<a id="security-policy-audit-events"></a>

### 安全策略审计事件

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_streaming.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15869)

{{< /details >}}

极狐GitLab 旗舰版现在为安全策略管理提供全面的审计事件，事件在每个安全策略项目中组织并集中管理。

安全团队现在可以：

- 使用详细的元数据跟踪所有策略修改。
- 监控执行失败，包括扫描和流水线执行失败。
- 监控被跳过的扫描执行和流水线执行流水线。
- 检测每个项目中的策略违规，包括在存在策略违规的情况下合并的合并请求。
- 在超出限制时接收提醒。
- 检测策略配置错误。
- 对高流量场景使用仅流式选项。

新的审计事件包括：

- [security_policy_create](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_create.yml)
- [security_policy_delete](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_delete.yml)
- [security_policy_update](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_update.yml)
- [security_policy_merge_request_merged_with_policy_violations](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_merge_request_merged_with_policy_violations.yml)
- [security_policy_yaml_invalidated](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_yaml_invalidated.yml)
- [security_policies_limit_exceeded](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_yaml_invalidated.yml)
- [security_policy_violations_detected](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_violations_detected.yml)（仅流式）
- [security_policy_pipeline_failed](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_pipeline_failed.yml)（仅流式）
- [security_policy_pipeline_skipped](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/audit_events/types/security_policy_pipeline_skipped.yml)（仅流式）
- [merge_request_branch_bypassed_by_security_policy](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/audit_events/types/merge_request_branch_bypassed_by_security_policy.yml)

此增强功能通过确保您可以访问策略变更、配置错误和执行缺口，增强了您的安全态势，从而实现更快的事件响应和全面的审计能力。

<a id="service-account-and-access-token-exceptions-for-approval-policies"></a>

### 审批策略的服务账号和访问令牌例外

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#access-token-and-service-account-exceptions) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18112)

{{< /details >}}

新的**服务账号与访问令牌例外**功能允许您指定在必要时可以绕过合并请求审批策略的服务账号和访问令牌。这消除了已知自动化流程的摩擦，同时保留了安全控制。

**主要能力包括：**

- 自动化工作流支持：配置特定的服务账号、机器人用户、群组访问令牌和项目访问令牌，以绕过 CI/CD 流水线、拉取镜像和自动版本更新的审批要求。服务账号可以使用已批准的令牌直接推送到受保护分支，同时保持对人工用户的限制。
- 紧急访问和审计：为关键事件启用紧急访问场景，并提供全面的审计事件记录。所有绕过事件都会生成带有上下文和理由的详细审计日志，在支持合规要求的同时允许在中断或安全修复期间快速响应。
- GitOps 集成：解除常见的自动化挑战，包括代码仓库镜像、外部 CI 系统（Jenkins、CloudBees）、自动生成变更日志和 GitFlow 发布流程。服务账号获得最低所需权限，基于令牌的访问范围限定于特定项目和分支。

此增强功能在保持严格安全策略的同时，为现代 DevOps 自动化需求提供了灵活性，消除了自定义变通方法，同时保留了治理控制。

<a id="saml-sso-support-for-session-timeout-attribute"></a>

### SAML SSO 支持会话超时属性

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/saml_sso/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/262074)

{{< /details >}}

极狐GitLab 现在会自动检测并遵循来自您的身份提供商（IdP）的 SAML 断言中的 `SessionNotOnOrAfter` 属性。当此属性存在时，极狐GitLab 会将用户会话设置为在您的 IdP 指定的时间过期，确保您组织中的会话管理保持一致。此功能无需更改配置——如果您的 IdP 提供该属性，极狐GitLab 会自动遵循指定的过期时间。

<a id="additional-service-account-email-configuration-options"></a>

### 额外的服务账号电子邮件配置选项

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/service_accounts.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/537976)

{{< /details >}}

默认情况下，极狐GitLab 会自动为新服务账号生成电子邮件地址。组织现在可以通过 UI 为服务账号分配自定义电子邮件地址。此前，自定义电子邮件配置只能通过服务账号 API 进行。此变更允许组织更好地将通知路由到指定的电子邮件地址。

<a id="enterprise-user-enhancements"></a>

### 企业用户增强

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/enterprise_user/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9262)

{{< /details >}}

极狐GitLab 18.3 引入了企业用户增强功能，使组织能够更好地控制用户隐私和生命周期管理。

群组所有者现在可以使用用户 API 删除其命名空间中的企业用户。此破坏性操作会解除用户贡献的关联，并将其与系统范围的 Ghost 用户关联。此选项对于清理通过自动 SCIM 导入错误创建的用户，或管理需要重新使用用户名和电子邮件的联合环境特别有价值。

此外，组织现在可以在其用户个人资料中隐藏企业用户电子邮件，为所有企业用户提供更广泛的电子邮件隐私保护。

<a id="ssh-key-security-warnings"></a>

### SSH 密钥安全警告

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/ssh.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432624)

{{< /details >}}

当用户上传弱 SSH 密钥时，极狐GitLab 现在会在 UI 中显示安全警告。此警告会针对较旧的密钥类型或位长度不足（少于 2048 位）的密钥显示。此变更有助于教育用户了解 SSH 密钥安全最佳实践，并鼓励使用更强的加密密钥。

<a id="gitlab-runner-183"></a>

### 极狐GitLab Runner 18.3

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.3！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [在极狐GitLab 18.2.0 中，Runner 无法使用子目录文件作为缓存键来拉取作业缓存](https://gitlab.com/gitlab-org/gitlab/-/issues/556464)
- [Docker executor 间歇性无法启动作业，并返回 `incorrect username or password` 错误消息。](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38707)
- [在 `none` 和 `empty` Git 策略之间，`*_get_sources` hook 的使用不一致](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38703)
- [使用非 OLM 清单部署的 Operator 假定了错误的默认镜像](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/228)
- [如果 CR 具有 `app.kubernetes.io/instance` 标签，Operator 会创建名称错误的 ConfigMap](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/183)
- [OpenShift 4.9 上的 Operator 1.10.0 无法创建 runner ConfigMap 并在 `gitlab-runner` 命名空间中启动 pod](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/138)

<a id="whats-new"></a>

#### 新增功能

- [GitLab Runner Operator 现在支持 runner manager pod 注解](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/245)
- [GitLab Runner Operator 现在支持 OpenShift 4.19](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/253)

所有变更的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-3-stable/CHANGELOG.md)中。
