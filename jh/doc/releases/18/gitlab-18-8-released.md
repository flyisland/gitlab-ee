---
stage: Release Notes
group: Monthly Release
date: 2026-01-15
title: "极狐GitLab 18.8 发布说明"
description: "极狐GitLab 18.8 发布，极狐GitLab Duo Agent Platform 现已正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 1 月 15 日，极狐GitLab 18.8 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-agent-platform-now-generally-available"></a>

### 极狐GitLab Duo Agent Platform 现已正式发布

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/585273)

{{< /details >}}

极狐GitLab Duo Agent Platform 已正式发布，将 Agentic AI 编排能力引入您的整个软件开发生命周期。与那些只能孤立地加速单个任务的 AI 工具不同，Agent Platform 可帮助团队在规划、构建、保护和交付软件的过程中协调 AI Agent，弥合了单个任务加速与软件交付所需的协作式多阶段现实之间的差距。

该平台提供集中的 AI 目录，团队可以在其中发现、管理并共享整个组织内的 Agent 和任务流。Planner、Security Analyst 和 Data Analyst 等内置 Agent 可在关键决策点处理结构化工作，而可自定义的任务流则可自动执行开发工作流中的多步骤 Agent 和任务，涵盖从议题到合并请求、CI/CD 迁移、流水线故障排除以及代码评审等环节。

借助治理控制、用量可见性以及包括面向离线环境的自部署模型在内的灵活部署选项，组织可以大规模采用 AI，同时获得所需的透明度和控制力。

极狐GitLab 专业版和旗舰版用户现在即可在 JihuLab.com 和极狐GitLab 私有化部署实例上使用 Agent Platform，并享受促销[极狐GitLab Credits](../../subscriptions/gitlab_credits.md)。

<a id="gitlab-duo-planner-agent-now-generally-available"></a>

### 极狐GitLab Duo Planner Agent 现已正式发布

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/planner.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/583008)

{{< /details >}}

Planner Agent 已正式发布！Planner Agent 是一个内置 Agent，旨在直接在极狐GitLab 中为产品经理提供支持。

使用 Planner Agent 可以创建、编辑和分析极狐GitLab 工作项。无需再手动追踪更新、排定优先级或汇总规划数据，Planner Agent 可帮助您分析待办事项、应用 RICE 或 MoSCoW 等框架，并找出真正需要您关注的内容。它就像一位主动的队友，了解您的规划工作流，并与您一起做出更好、更高效的决策。

请在[议题 583008](https://gitlab.com/gitlab-org/gitlab/-/work_items/583008)中提供您的反馈。

<a id="gitlab-duo-security-analyst-agent-now-generally-available"></a>

### 极狐GitLab Duo Security Analyst Agent 现已正式发布

<!-- categories: Vulnerability Management, Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/security_analyst_agent.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19659)

{{< /details >}}

极狐GitLab Duo Security Analyst Agent 在 [极狐GitLab 18.5 中作为测试版引入](gitlab-18-5-released.md#gitlab-security-analyst-agent-for-duo-agent-catalog-beta)，现已在极狐GitLab 18.8 中正式发布。

Security Analyst Agent 使工程师能够通过极狐GitLab Duo Agentic Chat 中的自然语言命令管理漏洞。安全团队无需再手动点击漏洞仪表板或为批量操作编写自定义脚本，现在可以在 Chat 对话中对漏洞进行排查、评估并提供指导。

作为内置 Agent，Security Analyst Agent 默认在极狐GitLab Duo Agentic Chat 中可用，无需手动设置。

<a id="auto-dismiss-irrelevant-vulnerabilities-with-vulnerability-management-policies"></a>

### 使用漏洞管理策略自动忽略不相关的漏洞

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/vulnerability_management_policy.md#auto-dismiss-policies) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10894)

{{< /details >}}

安全团队现在可以使用漏洞管理策略自动忽略不适用于其组织的漏洞。忽略与您的组织不相关的漏洞可以减少噪音，帮助开发者专注于构成实际风险的漏洞。

您可以创建策略，根据以下条件自动忽略漏洞：

- 文件路径
- 目录
- 标识符（CVE、CWE 或 OWASP）

自动忽略的漏洞会以**自动忽略**标记显示在合并请求的安全小组件中，并会在漏洞报告活动中记录忽略原因，以供审计。

<a id="agentic-core"></a>

## AI 功能

<a id="turn-the-gitlab-duo-agent-platform-on-or-off"></a>

### 开启或关闭极狐GitLab Duo Agent Platform

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/583980)

{{< /details >}}

您现在可以为顶级群组或整个实例开启或关闭极狐GitLab Duo Agent Platform，包括极狐GitLab Duo Chat（Agentic）、Agent 和任务流。关闭此设置后，这些功能将不可用。

<a id="group-access-control-for-gitlab-duo-features"></a>

### 极狐GitLab Duo 功能的群组访问控制

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/gitlab_duo/configure/access_control.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/585355)

{{< /details >}}

您现在可以定义群组访问规则，以控制谁可以使用极狐GitLab Duo 功能，从而实现从立即全组织范围访问到分阶段推广的灵活采用策略。

此功能提供精细的治理控制，让您可以按自己的节奏扩大采用范围，同时保持安全性和合规性。

<a id="gitlab-duo-agent-platform-for-gitlab-duo-self-hosted-offline-licensing-now-generally-available"></a>

### 面向极狐GitLab Duo 自部署版本的极狐GitLab Duo Agent Platform（离线许可）现已正式发布

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/19125)

{{< /details >}}

极狐GitLab Duo Agent Platform 已正式发布，适用于 Duo 自部署版本。此功能面向持有离线许可的极狐GitLab 私有化部署客户提供，采用基于席位的定价方式。

私有化部署管理员可以配置[兼容模型](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)以供极狐GitLab Duo Agent Platform 使用。使用 AWS Bedrock 或 Azure OpenAI 的管理员还可以配置 Anthropic Claude 或 OpenAI GPT 模型。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="cc-support-in-advanced-sast-now-generally-available"></a>

### 高级 SAST 中的 C/C++ 支持现已正式发布

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/advanced_sast_cpp.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/18369)

{{< /details >}}

极狐GitLab 高级 SAST 中针对 C/C++ 的跨文件、跨函数扫描支持已正式发布。

<a id="multiple-container-scanning"></a>

### 多容器扫描

<!-- categories: Container Scanning -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/container_scanning/multi_container_scanning.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/3139)

{{< /details >}}

在极狐GitLab 18.8 中，我们发布了测试版的多容器扫描。

用户现在可以传入一个镜像数组，作为多个容器扫描作业的一部分进行扫描。

<a id="centralized-credential-management-api-for-group-owners"></a>

### 面向群组所有者的集中式凭据管理 API

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../api/groups.md#credentials-inventory-management) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16343)

{{< /details >}}

凭据清单 API 现已面向 JihuLab.com 上的企业用户提供。它新增了此前仅在自托管实例上可用的凭据管理能力，使组织能够更好地管理和保护其身份验证令牌和密钥。

凭据清单 API 提供以编程方式查看整个组织凭据的能力，包括：

- 个人访问令牌（PAT）
- 群组访问令牌（GrAT）
- 项目访问令牌（PrAT）
- SSH 密钥
- GPG 密钥

此 API 是对现有凭据清单 UI 的补充，使企业管理员能够自动执行此前需要人工干预的凭据管理任务。借助凭据清单 API，您可以：

- 自动化安全工作流：构建自动化流程来监控、审计和撤销凭据。
- 强制执行凭据策略：识别并撤销未使用或已过期的令牌。
- 改善安全态势：通过定期审计降低凭据滥用的风险。
- 简化运维：将凭据管理集成到您现有的安全工具和工作流中。

<a id="group-owners-can-disable-ssh-keys-for-enterprise-users"></a>

### 群组所有者可以为企业用户禁用 SSH 密钥

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/ssh_advanced.md#disable-ssh-keys-for-enterprise-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30343)

{{< /details >}}

群组所有者现在可以为其群组中的所有企业用户禁用 SSH 密钥。禁用后，用户无法添加新的 SSH 密钥，其现有密钥也会被停用。这适用于该群组中的所有企业用户，包括拥有所有者角色的用户。

感谢 [Wesley Yarde](https://gitlab.com/WYarde) 帮助构建此功能！

<a id="gitlab-runner-188"></a>

### 极狐GitLab Runner 18.8

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.8！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增功能

- [改进了作业输入插值错误的错误消息](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39163)

<a id="bug-fixes"></a>

#### 缺陷修复

- [`WaitForServicesTimeout` 不再支持使用 `-1` 禁用超时](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39172)
- [自定义 URL 会破坏使用 `insteadOf` 规则的子模块身份验证](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39170)
- [Windows 2025 上的自定义 runner 短令牌使用 9 个字符而非 8 个](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39122)
- [极狐GitLab Runner 17.8.3 中 Docker 执行器缺少 PowerShell 默认辅助镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/38669)
- [带有 Docker 自动扩缩器的极狐GitLab Runner 不会重用可用的缓存卷](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/37906)
- [作业被取消时 VirtualBox 会留下悬空的虚拟机](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/37344)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-8-stable/CHANGELOG.md)。
