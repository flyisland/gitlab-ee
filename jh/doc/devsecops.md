---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何使用和管理极狐GitLab，这是最具扩展性的基于 Git 的完全集成软件开发平台。
title: '极狐GitLab：DevSecOps 平台'
---

DevSecOps 是开发、安全和运维的结合。它是一种将安全贯穿整个开发生命周期的软件开发方法。

<a id="devsecops-compared-to-devops"></a>

## DevSecOps 与 DevOps 的对比

DevOps 将开发与运维结合起来，旨在提高软件开发和交付的效率、速度与安全性。

DevOps 意味着协同工作，以最高速度构思、构建和交付安全的软件。DevOps 实践包括自动化、协作、快速反馈和迭代改进。

DevSecOps 是 DevOps 的演进。DevSecOps 将应用安全实践纳入软件开发的每个阶段。

在整个开发过程中，工具和方法会保护和监控您的线上应用。新的攻击面（如容器和编排器）也必须受到监控和保护。DevSecOps 工具将安全工作流自动化，为您的开发和安全团队打造一个适应性强的流程，改善协作并打破孤岛。通过将安全嵌入软件开发生命周期，您可以持续保障快速迭代流程的安全，在不牺牲质量的前提下提高效率。

<a id="devsecops-fundamentals"></a>

## DevSecOps 基础

DevSecOps 的基础包括：

- 自动化
- 协作
- 策略护栏
- 可见性

有关详情，请参阅[这篇关于 DevSecOps 的文章](https://about.gitlab.com/topics/devsecops/)。

<a id="devsecops-in-practice"></a>

## DevSecOps 实践

以下极狐GitLab 功能都是强大的 DevSecOps 平台的组成部分：

- 左移安全：合并请求中的静态应用安全测试（SAST）和依赖扫描可在代码合并前发现漏洞。
- 容器安全：针对 CVE 的镜像扫描、运行时保护以及 Kubernetes 安全策略，强制执行最小权限访问。
- 基础设施即代码（IaC）扫描：自动检测 Terraform、CloudFormation 和 Kubernetes 清单中的错误配置。
- 密钥检测：提交前钩子和 CI/CD 流水线扫描可防止凭据在代码仓库中泄露。
- 安全仪表板：集中化的漏洞跟踪，包含 CVSS 评分、可利用性指标和修复工作流。

<a id="is-devsecops-right-for-you"></a>

## DevSecOps 适合您吗？

如果您的组织正面临以下任一挑战，DevSecOps 方法可能适合您。

<!-- Do not delete the double spaces at the end of these lines. They improve the rendered view. -->

- 开发、安全和运维团队各自为政。
  如果开发和运维与安全问题相互隔离，
  他们就无法构建安全的软件。而如果安全团队不参与开发流程，
  他们就无法主动识别风险。DevSecOps 将各团队聚集在一起，改进工作流
  并分享想法。组织甚至可能看到员工士气和留任率的提升。

- 漫长的开发周期使您难以满足客户或利益相关方的需求。
  造成这种困境的原因之一可能是安全。DevSecOps 在开发生命周期的
  每一步都实施安全措施，这意味着扎实的安全并不需要让整个流程停滞。

- 您正在迁移到云（或正在考虑迁移）。
  迁移到云通常意味着引入新的开发流程、工具和系统。
  这是让流程变得更快、更安全的大好时机，而 DevSecOps 可以让这一切容易得多。

要开始使用 DevSecOps，
[了解更多，并免费试用极狐GitLab 旗舰版](https://about.gitlab.com/solutions/application-security-testing/)。
