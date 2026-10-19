---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 密钥检测
description: 检测、预防、监控、存储、撤销和报告。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您的应用程序可能会使用外部资源，包括 CI/CD 服务、数据库或外部存储。访问这些资源需要进行身份验证，通常使用私钥和令牌等静态方式。这些方式被称为“密钥”，因为它们不应与任何其他人共享。

为了尽可能降低密钥泄露的风险，请始终[将密钥存储在代码仓库之外](../../../ci/secrets/_index.md)。不过，密钥有时会被意外提交到 Git 代码仓库中。敏感值被推送到远程代码仓库后，任何有权访问该代码仓库的人都可以使用该密钥来冒充已授权用户。

密钥检测会监控您的活动，以实现以下两个目标：

- 帮助防止您的密钥被泄露。
- 帮助您在密钥泄露时做出响应。

您应该采用多层安全防护方法，并启用所有可用的密钥检测方式：

- [密钥推送保护](secret_push_protection/_index.md)会在您将更改推送到极狐GitLab 时扫描提交中的密钥。如果检测到密钥，推送会被阻止，除非您跳过密钥推送保护。这种方式可降低密钥泄露的风险。
- [流水线密钥检测](pipeline/_index.md)作为项目 CI/CD 流水线的一部分运行。系统会扫描推送到代码仓库默认分支的提交中的密钥。如果在合并请求流水线中启用了流水线密钥检测，系统会扫描推送到开发分支的提交中的密钥，让您能够在密钥被提交到默认分支之前做出响应。
- [客户端密钥检测](client/_index.md)会在议题和合并请求的描述与评论保存到极狐GitLab 之前，扫描其中的密钥。检测到密钥时，您可以选择编辑输入内容并移除密钥，或者如果这是误报，则保存该描述或评论。

如果密钥被提交到代码仓库，极狐GitLab 会在漏洞报告中记录该泄露事件。对于某些密钥类型，极狐GitLab 甚至可以自动撤销已泄露的密钥。您应始终尽快撤销并替换已泄露的密钥。有关针对特定密钥的修复指导，请查看漏洞报告中提供的详细信息。

<a id="reducing-false-positives-with-gitlab-duo"></a>

## 使用极狐GitLab Duo 减少误报

密钥检测扫描器可能会产生误报，从而在漏洞报告中造成干扰。[极狐GitLab Duo 误报检测](../vulnerabilities/secret_false_positive_detection.md)功能会自动分析密钥检测发现结果，以识别可能的误报。这有助于您的安全团队专注于真正的密钥，并减少手动排查所花费的时间。

对于购买了极狐GitLab Duo 附加组件的旗舰版客户，误报检测会在每次安全扫描后自动运行，并为每项评估提供置信度分数和说明。
