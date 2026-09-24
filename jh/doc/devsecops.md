---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to use and administer GitLab, the most scalable Git-based fully integrated platform for software development.
title: '极狐GitLab: DevSecOps 平台'
---

DevSecOps 是开发、安全和运维的结合。它是一种在整个开发生命周期中整合安全的软件开发方法。

<a id="devsecops-compared-to-devops"></a>

## DevSecOps 与 DevOps 的对比

DevOps 结合了开发与运维，旨在提高软件开发和交付的效率、速度和安全性。

DevOps 意味着协同工作，以最快的速度构思、构建和交付安全的软件。DevOps 实践包括自动化、协作、快速反馈和迭代改进。

DevSecOps 是 DevOps 的演进。DevSecOps 在软件开发的每个阶段都融入了应用安全实践。

在整个开发过程中，工具和方法会保护并监控你的线上应用。新的攻击面，如容器和编排器，也必须受到监控和保护。DevSecOps 工具能够自动化安全工作流，为你的开发和安全团队创造一个适应性强的流程，从而改善协作并打破团队孤岛。
通过将安全嵌入到软件开发生命周期中，你可以始终如一地保障快速且迭代式的流程，在不牺牲质量的情况下提高效率。

<a id="devsecops-fundamentals"></a>

## DevSecOps 基础

DevSecOps 的基础包括：

- 自动化
- 协作
- 策略护栏
- 可见性

详情请参阅[这篇关于 DevSecOps 的文章](https://gitlab.cn/topics/devsecops/)。

<a id="devsecops-in-practice"></a>

## DevSecOps 实践

以下极狐GitLab 功能都是强大 DevSecOps 平台的一部分：

- 安全左移：静态应用安全测试 (SAST) 和合并请求中的依赖项扫描可在代码合并前捕获漏洞。
- 容器安全：镜像 CVE 扫描、运行时防护和 Kubernetes 安全策略可强制执行最小权限访问。
- 基础设施即代码 (IaC) 扫描：自动检测 Terraform、CloudFormation 和 Kubernetes 清单中的错误配置。
- 密钥检测：预提交钩子和 CI/CD 流水线扫描可防止凭据泄露到代码仓库中。
- 安全仪表板：通过 CVSS 评分、可利用性指标和修复工作流进行集中的漏洞跟踪。

<a id="is-devsecops-right-for-you"></a>

## DevSecOps 适合你吗？

如果你的组织正面临以下任何挑战，DevSecOps 方法或许适合你。

<!-- 不要删除这些行末尾的双空格。它们能改善渲染效果。 -->

- 开发、安全和运维团队各自为政。
  如果开发和运维团队与安全问题隔离，他们就无法构建安全的软件。而如果安全团队不参与开发过程，他们也无法主动识别风险。DevSecOps 将团队汇聚在一起，以改进工作流并分享想法。组织甚至可能看到员工士气和留任率的提升。

- 漫长的开发周期让你难以满足客户或利益相关者的需求。
  其中一个原因可能是安全因素。DevSecOps 在开发生命周期的每个步骤都实施安全措施，意味着扎实的安全性无需让整个流程停摆。

- 你正在迁移到云端（或正在考虑）。
  迁移到云端通常意味着引入新的开发流程、工具和系统。这是让流程变得更快、更安全的好时机，而 DevSecOps 可以让你轻松实现这一点。

要开始使用 DevSecOps，请[了解更多，并免费试用极狐GitLab 旗舰版](https://gitlab.cn/solutions/security-compliance/)。