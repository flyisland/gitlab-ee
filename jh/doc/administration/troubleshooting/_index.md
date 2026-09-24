---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查极狐GitLab 安装问题
description: Troubleshooting a 极狐GitLab installation.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页面汇总了一系列资源，帮助您排查极狐GitLab 安装问题。

此列表不一定全面。如果您在此列表中未找到所需内容，应搜索文档。

<a id="troubleshooting-guides"></a>

## 排查指南

- [SSL](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/)
- [Geo](../geo/replication/troubleshooting/_index.md)
- [SAML](../../user/group/saml_sso/troubleshooting.md)
- [Kubernetes 速查表](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/)
- [Linux 速查表](linux_cheat_sheet.md)
- [使用 `jq` 解析极狐GitLab 日志](../logs/log_parsing.md)
- [诊断工具](diagnostics_tools.md)

某些功能文档页面末尾也有排查部分，您可以查看以获取特定功能的帮助，包括有用的 Rails 命令。

如果您需要测试环境进行排查，请参阅[测试环境应用](test_environments.md)。

<a id="support-team-troubleshooting-info"></a>

## 支持团队排查信息

极狐GitLab 支持团队收集了大量关于排查极狐GitLab 的信息。
以下文档供支持团队使用，或由客户在支持团队成员的直接指导下使用。极狐GitLab 管理员可能会发现这些信息对排查有用。但是，如果您的极狐GitLab 实例遇到问题，在参考这些文档之前，应先查看您的[支持选项](https://gitlab.cn/support/)。

> [!warning]
> 以下文档中的命令可能导致数据丢失或对极狐GitLab 实例造成其他损害。仅应由了解风险的经验丰富的管理员使用。

- [诊断工具](diagnostics_tools.md)
- [Linux 命令](linux_cheat_sheet.md)
- [排查 Kubernetes](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/)
- [排查 PostgreSQL](postgresql.md)
- [测试环境指南](test_environments.md)（适用于支持工程师）
- [排查 SSL](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/)
- 相关链接：
  - [修复和恢复损坏的 Git 仓库](https://git.seveas.net/repairing-and-recovering-broken-git-repositories.html)
  - [使用 OpenSSL 进行测试](https://www.feistyduck.com/library/openssl-cookbook/online/testing-with-openssl/index.html)
  - [`strace` 小册子](https://wizardzines.com/zines/strace/)

