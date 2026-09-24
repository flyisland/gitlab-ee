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

您的应用可能使用了外部资源，包括 CI/CD 服务、数据库或外部存储。访问这些资源需要认证，通常采用静态方法，例如私钥和令牌。这些方法称为“密钥”，因为它们不应与其他人共享。

为最大限度地降低密钥泄露风险，请始终[将密钥存储于代码仓之外](../../../ci/secrets/_index.md)。然而，密钥有时会意外地被提交到 Git 仓库。敏感值被推送至远程仓库后，任何可以访问该仓库的人都能够使用该密钥冒充授权用户。

密钥检测会监控您的活动，以同时：

- 帮助防止密钥泄露。
- 在密钥泄露后帮助您做出响应。

您应当采取多层安全防护措施，并启用所有可用的密钥检测方法：

- [密钥推送保护](secret_push_protection/_index.md) 在您推送更改到极狐GitLab 时扫描提交中的密钥。如果检测到密钥，推送会被阻止，除非您跳过密钥推送保护。此方法可降低密钥泄露的风险。
- [流水线密钥检测](pipeline/_index.md) 作为项目 CI/CD 流水线的一部分运行。对仓库默认分支的提交会进行密钥扫描。如果在合并请求流水线中启用了流水线密钥检测，对开发分支的提交也会被扫描，使您能够在密钥被合入默认分支前做出响应。
- [客户端密钥检测](client/_index.md) 在议题和合并请求的描述和评论保存至极狐GitLab 之前扫描其中的密钥。当检测到密钥时，您可以选择编辑输入内容并移除密钥，或者如果是误报，则保存描述或评论。

如果密钥被提交到仓库，极狐GitLab 会在漏洞报告中记录此次泄露。对于某些密钥类型，极狐GitLab 甚至可以自动撤销泄露的密钥。您应当始终尽快撤销并更换已泄露的密钥。有关特定密钥的修复指导，请查看漏洞报告中提供的详细信息。

<a id="reducing-false-positives-with-gitlab-duo"></a>

## 通过极狐GitLab Duo 减少误报

密钥检测扫描器可能产生误报，给您的漏洞报告带来干扰。[极狐GitLab Duo 误报检测](../vulnerabilities/secret_false_positive_detection.md)功能会自动分析密钥检测发现，以识别可能的误报。这有助于您的安全团队聚焦于真实密钥，并减少手动排查所花费的时间。

对于拥有极狐GitLab Duo 附加组件的旗舰版客户，每次安全扫描后误报检测会自动运行，并提供每个评估的置信度评分及解释。

<a id="related-topics"></a>

## 相关主题

- [密钥检测排除项](exclusions.md)
- [漏洞报告](../vulnerability_report/_index.md)
- [泄露密钥自动响应](automatic_response.md)
- [推送规则](../../project/repository/push_rules.md)
- [密钥误报检测](../vulnerabilities/secret_false_positive_detection.md)