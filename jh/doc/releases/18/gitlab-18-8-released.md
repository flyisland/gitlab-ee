---
stage: Release Notes
group: Monthly Release
date: 2026-01-15
title: "极狐GitLab 18.8 发布说明"
description: "极狐GitLab 18.8 发布，极狐GitLab Duo Agent Platform 现已正式可用"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 1 月 15 日，极狐GitLab 18.8 发布，包含以下功能。

此外，我们要感谢所有的贡献者，包括本月的杰出贡献者。

<a id="this-month-notable-contributor-wesley-yarde"></a>

## 本月的杰出贡献者：Wesley Yarde

本月的杰出贡献者是 [Wesley Yarde](https://gitlab.com/WYarde)，他构建了一项基础性的新功能，允许组织为他们的企业用户禁用 SSH 密钥。

Wesley 的贡献之所以突出，有以下几个原因：

- **安全与合规**：此功能使组织能够强制执行 SSH 密钥要求，并在整个企业内增强安全性。
- **基础性工作**：由于没有现成的实现可供参考，Wesley 必须与极狐GitLab 团队紧密合作，从零开始定义需求和架构。
- **首次贡献**：值得注意的是，这是 Wesley 对极狐GitLab 的首次贡献——展示了其驾驭复杂代码库并解决具有挑战性功能的非凡能力。
- **赋能未来开发**：这项工作为实例级 SSH 密钥禁用和服务账户控制等类似功能奠定了基础。

该实现跨越了多个合并请求，经过了彻底的审查周期。尽管非常复杂，Wesley 在整个过程中表现出了出色的协作和耐心。

“很高兴能与 Wesley 就这个功能请求进行合作！虽然贡献者和审查者可能都觉得审查过程很艰巨，但双方都表现出了理解和出色协作，以确保实现是稳固和完整的。” —— [Bogdan Denkovych](https://gitlab.com/bdenkovych)，提名 Wesley 获得此荣誉。

恭喜 Wesley，并感谢你对极狐GitLab 做出的宝贵贡献！

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-agent-platform-now-generally-available"></a>

### 极狐GitLab Duo Agent Platform 现已正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/duo_agent_platform/_index.md)

{{< /details >}}

极狐GitLab Duo Agent Platform 现已正式可用，为你的整个软件开发生命周期带来 Agent 化的 AI 编排。与孤立地加速单个任务的 AI 工具不同，Agent Platform 帮助团队在规划、构建、安全和发布软件的过程中协调 AI Agent，弥合了个人工作加速与软件交付的协作性、多阶段现实之间的差距。

该平台提供了一个中央 AI 目录，团队可以在其中发现、管理和共享整个组织中的 Agent 和流程。内置的内置 Agent（如计划者、安全分析师和数据分析师）在关键决策点处理结构化工作，而可定制的流程则能从议题到合并请求、CI/CD 迁移、流水线故障排除和代码审查的开发工作流中，自动化多步骤的 Agent 和任务。

通过治理控制、使用可见性以及包括用于离线环境的自部署模型在内的灵活部署选项，组织可以大规模采用 AI，并具备所需的透明度和控制力。

极狐GitLab 专业版和旗舰版用户可以立即在 JihuLab.com 和极狐GitLab 私有化部署实例上，通过促销的[极狐GitLab Credits](../../subscriptions/gitlab_credits.md) 开始使用 Agent Platform。

<a id="gitlab-duo-planner-agent-now-generally-available"></a>

### 极狐GitLab Duo 计划者 Agent 现已正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/planner.md)

{{< /details >}}

计划者 Agent 现已正式可用！计划者 Agent 是一个基础性 Agent，旨在直接为极狐GitLab 中的产品经理提供支持。

使用计划者 Agent 来创建、编辑和分析极狐GitLab 工作项。计划者 Agent 可以帮你分析待办事项、应用 RICE 或 MoSCoW 等框架，并找出真正需要你关注的事项，而无需你手动追踪更新、确定工作优先级或总结规划数据。它就像一个积极主动的队友，了解你的规划工作流，并与你一起做出更好、更高效的决策。

<a id="gitlab-duo-security-analyst-agent-now-generally-available"></a>

### 极狐GitLab Duo 安全分析师 Agent 现已正式可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/security_analyst_agent.md)

{{< /details >}}

极狐GitLab Duo 安全分析师 Agent 在极狐GitLab 18.8 中正式可用。

安全分析师 Agent 使工程师能够通过极狐GitLab Duo Agentic Chat 中的自然语言命令来管理漏洞。安全团队现在可以在聊天对话中对漏洞进行分类、评估和提供指导，而无需手动点击漏洞仪表盘或为批量操作编写自定义脚本。

作为一个内置 Agent，安全分析师 Agent 在极狐GitLab Duo Agentic Chat 中默认可用，无需手动设置。

<a id="auto-dismiss-irrelevant-vulnerabilities-with-vulnerability-management-policies"></a>

### 使用漏洞管理策略自动关闭不相关的漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/policies/vulnerability_management_policy.md#auto-dismiss-policies)

{{< /details >}}

安全团队现在可以使用漏洞管理策略，自动关闭那些不适用于其组织的漏洞。关闭与你的组织无关的漏洞可以减少干扰，并帮助开发者专注于构成实际风险的漏洞。

你可以创建基于以下条件的自动关闭漏洞策略：

- 文件路径
- 目录
- 标识符（CVE、CWE 或 OWASP）

被自动关闭的漏洞会在合并请求的安全部件中显示 **已自动关闭** 标签，并会在漏洞报告活动中跟踪其关闭原因，以供审计。

<a id="agentic-core"></a>

## Agentic 核心

<a id="turn-the-gitlab-duo-agent-platform-on-or-off"></a>

### 开启或关闭极狐GitLab Duo Agent Platform

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off)

{{< /details >}}

你现在可以为顶级群组或整个实例开启或关闭极狐GitLab Duo Agent Platform，包括极狐GitLab Duo Chat（Agentic）、Agent 和流程。关闭此设置后，这些功能将不可用。

<a id="group-access-control-for-gitlab-duo-features"></a>

### 极狐GitLab Duo 功能的群组访问控制

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../administration/gitlab_duo/configure/access_control.md)

{{< /details >}}

你现在可以定义群组访问规则来控制谁可以使用极狐GitLab Duo 功能，从而实现灵活的采用策略，从即时的组织范围访问到分阶段推广。

此功能提供了精细的治理控制，因此你可以在保持安全和合规性的同时，按照你的节奏扩大采用。

<a id="gitlab-duo-agent-platform-for-gitlab-duo-self-hosted-offline-licensing-now-generally-available"></a>

### 适用于极狐GitLab Duo 私有化部署（离线许可证）的极狐GitLab Duo Agent Platform 现已正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Add-ons: Duo Enterprise
- Links: [Documentation](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform)

{{< /details >}}

极狐GitLab Duo Agent Platform 现已在 Duo 私有化部署中正式可用。此功能适用于持有离线许可证的极狐GitLab 私有化部署客户，并使用基于席位的定价。

私有化部署管理员可以配置[兼容的模型](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)，以与极狐GitLab Duo Agent Platform 一起使用。使用 AWS Bedrock 或 Azure OpenAI 的管理员也可以配置国内 SOTA 大模型。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="cc-support-in-advanced-sast-now-generally-available"></a>

### 高级 SAST 中的 C/C++ 支持现已正式可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/sast/advanced_sast_cpp.md)

{{< /details >}}

跨文件、跨功能扫描对 C/C++ 的支持现已在极狐GitLab 高级 SAST 中正式可用。

<a id="multiple-container-scanning"></a>

### 多容器扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/container_scanning/multi_container_scanning.md)

{{< /details >}}

在极狐GitLab 18.8 中，我们发布了多容器扫描的测试版。

用户现在可以传入一个镜像数组，作为许多容器扫描任务的一部分进行扫描。

<a id="centralized-credential-management-api-for-group-owners"></a>

### 面向群组所有者的集中式凭据管理 API

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [Documentation](../../api/groups.md#credentials-inventory-management)

{{< /details >}}

凭据清单 API 现已在 JihuLab.com 上对 Enterprise 用户可用。这增加了以前仅在私有化部署实例上可用的凭据管理功能，使组织能够更好地管理和保护其身份验证令牌和密钥。

凭据清单 API 提供以编程方式查看整个组织凭据的能力，包括：

- 个人访问令牌 (PAT)
- 群组访问令牌 (GrAT)
- 项目访问令牌 (PrAT)
- SSH 密钥
- GPG 密钥

此 API 补充了现有的凭据清单 UI，允许企业管理员自动化以前需要手动干预的凭据管理任务。通过凭据清单 API，你可以：

- 自动化安全工作流：构建自动化流程来监控、审计和撤销凭据。
- 强制执行凭据策略：识别并撤销未使用或过期的令牌。
- 改善安全态势：通过定期审计降低凭据滥用的风险。
- 简化运维：将凭据管理集成到你现有的安全工具和工作流中。

<a id="group-owners-can-disable-ssh-keys-for-enterprise-users"></a>

### 群组所有者可以为企业用户禁用 SSH 密钥

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [Documentation](../../user/ssh_advanced.md#disable-ssh-keys-for-enterprise-users)

{{< /details >}}

群组所有者现在可以为其群组中的所有企业用户禁用 SSH 密钥。禁用后，用户无法添加新的 SSH 密钥，并且他们现有的密钥将被停用。这适用于群组中的所有企业用户，包括具有所有者角色的用户。

感谢 [Wesley Yarde](https://gitlab.com/WYarde) 帮助构建此功能！

<a id="gitlab-runner-188"></a>

### 极狐GitLab Runner 18.8

{{< details >}}

- Tier: 基础版，专业版, 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](https://gitlab.cn/docs/runner)

{{< /details >}}

我们也在今天发布了极狐GitLab Runner 18.8！极狐GitLab Runner 是一个高度可扩展的构建代理，它运行你的 CI/CD 任务并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 随附的开源持续集成服务。

#### 新增功能

- [改进了作业输入插值错误的错误消息](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39163)

#### 错误修复

- [`WaitForServicesTimeout` 不再支持 `-1` 来禁用超时](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39172)
- [自定义 URL 导致使用 `insteadOf` 规则的子模块认证失败](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39170)
- [Windows 2025 上的自定义 runner 短令牌使用 9 个字符而不是 8 个](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39122)
- [极狐GitLab Runner 17.8.3 中 Docker 执行器缺少 PowerShell 默认辅助镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/38669)
- [带有 Docker Autoscaler 的极狐GitLab Runner 未重用可用的缓存卷](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/37906)
- [作业取消时 VirtualBox 留下悬空的 VM](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/37344)

所有变更列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-8-stable/CHANGELOG.md) 中。

<a id="related-topics"></a>

## 相关主题

- [错误修复](https://gitlab.com/groups/gitlab-org/-/issues/?sort=updated_desc&state=closed&label_name%5B%5D=type%3A%3Abug&or%5Blabel_name%5D%5B%5D=workflow%3A%3Acomplete&or%5Blabel_name%5D%5B%5D=workflow%3A%3Averification&or%5Blabel_name%5D%5B%5D=workflow%3A%3Aproduction&milestone_title=18.8)
- [性能改进](https://gitlab.com/groups/gitlab-org/-/issues/?sort=updated_desc&state=closed&label_name%5B%5D=bug%3A%3Aperformance&or%5Blabel_name%5D%5B%5D=workflow%3A%3Acomplete&or%5Blabel_name%5D%5B%5D=workflow%3A%3Averification&or%5Blabel_name%5D%5B%5D=workflow%3A%3Aproduction&milestone_title=18.8)
- [UI 改进](https://papercuts.gitlab.com/?milestone=18.8)
- [弃用和移除](../../update/deprecations.md)
- [升级说明](../../update/versions/_index.md)