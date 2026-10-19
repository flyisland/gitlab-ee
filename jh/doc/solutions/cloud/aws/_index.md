---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
title: AWS Solutions
---

本文档涵盖了在 Amazon Web Services (AWS) 上以及通过 AWS 使用 极狐GitLab 的相关解决方案。

- [极狐GitLab 获得的 AWS 合作伙伴认证与称号](gitlab_aws_partner_designations.md)
- [极狐GitLab AWS 集成索引](gitlab_aws_integration.md)
- [在 AWS EKS 上部署 极狐GitLab 实例](gitlab_instance_on_aws.md)
- [针对 AWS 上 Gitaly 的 SRE 考量](gitaly_sre_for_aws.md)
- [在 AWS 的单台 EC2 实例上部署 极狐GitLab](gitlab_single_box_on_aws.md)

<a id="cloud-platform-well-architected-compliance"></a>

## 云平台良好架构合规性

基于测试的架构认证是云解决方案实施的基础理念：

- 云解决方案实施遵守 极狐GitLab 参考架构，并提供 [极狐GitLab 性能工具](https://jihulab.com/gitlab-cn/quality/performance) (GPT) 报告以证明其符合性。
- 云解决方案实施可由技术供应商进行认证和（或）贡献。例如，针对 AWS 的实施模式可能由 AWS 官方评审。
- 云解决方案实施可以指定和测试云平台 PaaS 服务对 极狐GitLab 的适用性。这项测试可以协调进行，并帮助认证这些技术适合参考架构。例如，认证 PostgreSQL 和 Redis 等顶层 PaaS 运行时版本的兼容性和可用性。
- 云解决方案实施能够提供针对平台限制的认证测试，例如，确保 Gitaly 集群 (Praefect) 能在特定云平台可用区的延迟和吞吐量特性下正常工作，或者认证什么级别的可用平台伙伴本地磁盘性能能够使 Gitaly 服务器正常运行。

<a id="aws-known-issues-list"></a>

## AWS 已知问题列表

已知问题来自 极狐GitLab 内部和客户报告的问题。客户在实施 极狐GitLab 时成功使用了各种“即服务”组件，而 极狐GitLab 并未针对这些组件专门设计，也没有对其进行持续测试。虽然 极狐GitLab 非常重视合作伙伴技术，但此处列出已知问题只是为了方便实施者，并不表示 极狐GitLab 已经定向兼容这些合作伙伴技术，也不提供任何在这些技术之上运行的保证。请查阅各个问题以了解 极狐GitLab 对每个已知问题的立场和计划。

完整列表请参见 [极狐GitLab AWS 已知问题列表](https://jihulab.com/gitlab-cn/alliances/aws/public-tracker/-/issues?label_name[]=AWS+Known+Issue)。

<a id="patterns-with-working-code-examples-for-using-gitlab-with-aws"></a>

## 含有效代码示例的使用 极狐GitLab 与 AWS 的模式

[AWS 引导式探索子群组](https://jihulab.com/gitlab-cn/guided-explorations/aws) 包含了各种可运行的示例项目。

<a id="platform-partner-specificity"></a>

## 平台合作伙伴特定性

云解决方案实施会采用平台特定的术语、最佳实践架构和平台特定的构建清单：

- 云解决方案实施更具供应商特定性。例如，会建议具体的计算实例 / 虚拟机 / 节点，而非 vCPU 或其他通用度量标准。
- 云解决方案实施面向为指定供应商构建良好架构。
- 云解决方案实施面向熟悉该实施模式所基于的基础设施的受众。例如，如果实施模式针对 GCP，则使用 GCP 的特定术语——包括使用 PaaS 服务的具体名称。
- 云解决方案实施可以测试和认证可用 PaaS 服务的版本是否与 极狐GitLab 兼容（例如 PostgreSQL、Redis 等）。

<a id="aws-platform-as-a-service-paas-specification-and-usage"></a>

## AWS 平台即服务 (PaaS) 规范与使用方法

平台即服务选项是云平台提供价值的核心部分，它简化了运维复杂度，降低了操作高级、高可用技术服务所需的 SRE 和安全技能门槛。云解决方案实施可以针对合作伙伴 PaaS 选项进行预认证。

- 云解决方案实施帮助实施者了解哪些 PaaS 选项已被证实可用，以及当同一平台为相同的 极狐GitLab 角色提供多种 PaaS 方案时如何做出选择。
- 例如，当参考架构对于 极狐GitLab 外发邮件服务所使用的技术或所需规模没有具体建议时，参考实施可能会建议使用云提供商的邮件即服务 (PaaS)，甚至可能给出具体设置。

更多信息可参阅 [可使用 AWS 服务部署 极狐GitLab 基础设施](gitlab_instance_on_aws.md)。

<a id="cost-optimizing-engineering"></a>

## 成本优化工程

成本工程是云架构的一个基本方面，平台上可用的节省能力常常强烈影响大规模计算的建设方式。

- 云解决方案实施可能会针对平台供应商提供的节省模式进行专门的工程设计。AWS 的一个示例是最大化特定实例类型的使用，以利用预留实例的优势。
- 云解决方案实施可能在适当的地方，并在适当的客户指南下，利用临时计算资源。例如，一个专用于临时计算上运行 Runner 的 Kubernetes 节点组（并使用适当的 GitLab Runner 标签标示计算类型）。
- 云解决方案实施可能包含供应商特定的成本计算器。

<a id="actionability-and-automatability-orientation"></a>

## 可操作性与可自动化性导向

云解决方案实施更接近可用于构建指令和自动化代码的具体内容：

- 云解决方案实施使构建者能够生成一份针对给定参考架构实施 极狐GitLab 所需的供应商特定资源清单。
- 云解决方案实施使构建者能够使用手动指令或创建自动化来构建参考实施。

<a id="intended-audiences-and-contributors"></a>

## 目标受众与贡献者

此信息的主要受众和贡献者是 极狐GitLab **实施生态系统**，至少包括：

极狐GitLab 实施社区：

- 客户
- 极狐GitLab 渠道合作伙伴（集成商）
- 平台合作伙伴

极狐GitLab 内部实施团队：

- 质量 / 分发 / 私有化部署
- 联盟
- 培训
- 支持
- 专业服务
- 公共部门