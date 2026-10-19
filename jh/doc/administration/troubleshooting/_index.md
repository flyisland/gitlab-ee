---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除极狐GitLab 安装
description: 故障排除极狐GitLab 安装。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页面汇总了一系列资源，帮助您排查极狐GitLab 安装问题。

此列表未必详尽。如果您在此列表中找不到所需内容，请搜索文档。

<a id="troubleshooting-guides"></a>

## 故障排除指南

- [SSL](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/)
- [Geo](../geo/replication/troubleshooting/_index.md)
- [SAML](../../user/group/saml_sso/troubleshooting.md)
- [Kubernetes 速查表](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/)
- [Linux 速查表](linux_cheat_sheet.md)
- [使用 `jq` 解析极狐GitLab 日志](../logs/log_parsing.md)
- [诊断工具](diagnostics_tools.md)

部分功能文档页面末尾也提供了故障排除章节，您可以查看针对特定功能的帮助信息，其中包含实用的 Rails 命令。

如果您需要测试环境来进行故障排除，请参阅[测试环境应用](test_environments.md)。

<a id="support-team-troubleshooting-info"></a>

## 支持团队故障排除信息

极狐GitLab 支持团队收集了大量关于极狐GitLab 故障排除的信息。以下文档供支持团队使用，或由客户在支持团队成员的直接指导下使用。极狐GitLab 管理员可能会发现这些信息对故障排除很有帮助。但是，如果您的极狐GitLab 实例出现问题，在参考这些文档之前，您应先查看[支持选项](https://gitlab.cn/support)。

> [!warning]
> 以下文档中的命令可能会导致数据丢失或对极狐GitLab 实例造成其他损害。这些命令仅应由了解相关风险的经验丰富的管理员使用。

- [诊断工具](diagnostics_tools.md)
- [Linux 命令](linux_cheat_sheet.md)
- [故障排除 Kubernetes](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/)
- [故障排除 PostgreSQL](postgresql.md)
- [测试环境指南](test_environments.md)（供支持工程师使用）
- [故障排除 SSL](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/)
- 相关链接：
  - [修复和恢复损坏的 Git 代码仓库](https://git.seveas.net/repairing-and-recovering-broken-git-repositories.html)
  - [使用 OpenSSL 进行测试](https://www.feistyduck.com/library/openssl-cookbook/online/testing-with-openssl/index.html)
  - [`strace` 小册子](https://wizardzines.com/zines/strace/)
