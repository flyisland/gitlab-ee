---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: SSH 密钥限制、双因素认证、令牌、安全加固。
title: 保护极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="general-information"></a>

## 一般信息

本节介绍有关该平台的一般信息和建议。

- [密码和 OAuth 令牌存储](../user/profile/user_passwords.md)
- [为通过集成身份验证创建的用户生成密码](../user/profile/user_passwords.md)
- [CRIME 漏洞管理](crime_vulnerability.md)
- [第三方集成的密钥轮换](rotate_integrations_secrets.md)

<a id="recommendations"></a>

## 建议

有关改善极狐GitLab 环境安全状况的更多信息，请参阅[安全加固建议](hardening.md)。

<a id="antivirus-software"></a>

### 防病毒软件

通常，不建议在极狐GitLab 主机上运行防病毒软件。

但是，如果您必须使用防病毒软件，则应从扫描中排除系统上极狐GitLab 的所有位置，因为它可能会被误报为病毒并被隔离。

具体而言，您应从扫描中排除以下极狐GitLab 目录：

- `/var/opt/gitlab`
- `/etc/gitlab/`
- `/var/log/gitlab/`
- `/opt/gitlab/`

您可以在 [Linux 软件包配置文档](https://gitlab.cn/docs/omnibus/settings/configuration/)中找到列出的所有这些目录。

<a id="user-accounts"></a>

### 用户账号

- [查看身份验证选项](../administration/auth/_index.md)。
- [修改密码复杂度要求](../administration/settings/sign_up_restrictions.md#modify-password-complexity-requirements)。
- [限制 SSH 密钥技术并设置最小密钥长度](ssh_keys_restrictions.md)。
- [限制新用户账号](../administration/settings/sign_up_restrictions.md)。
- [在创建新账号时发送电子邮件确认](user_email_confirmation.md)
- [强制使用双因素认证](two_factor_authentication.md)，要求用户[启用双因素认证](../user/profile/account/two_factor_authentication.md)。
- [限制来自多个 IP 的登录](../administration/reporting/ip_addr_restrictions.md)。
- [如何重置用户密码](reset_user_password.md)。
- [如何解锁被锁定的用户](unlock_user.md)。

<a id="data-access"></a>

### 数据访问

- [项目成员身份的安全注意事项](../user/project/members/_index.md#security-considerations)。
- [保护并移除用户文件上传](user_file_uploads.md)。
- [代理链接图片以保护用户隐私](asset_proxy.md)。

<a id="platform-usage-and-settings"></a>

### 平台使用和设置

- [查看极狐GitLab 令牌类型和用途](tokens/_index.md)。
- [如何配置速率限制以提升安全性和可用性](../rate_limits/_index.md)。
- [如何过滤出站 webhook 请求](webhooks.md)。
- [如何配置导入和导出限制及超时](../administration/settings/import_and_export_settings.md)。
- [查看 Runner 安全注意事项和建议](https://gitlab.cn/docs/runner/security/)。
- [查看 CI/CD 变量安全注意事项](../ci/variables/_index.md#cicd-variable-security)。
- [查看流水线安全，了解 CI/CD 流水线中密钥的使用和保护](../ci/pipeline_security/_index.md)。
- [实例范围的合规和安全策略管理](compliance_security_policy_management.md)。

<a id="patching"></a>

### 补丁

极狐GitLab 私有化部署客户和管理员负责其底层主机的安全，并负责保持极狐GitLab 本身为最新版本。重要的是[定期为极狐GitLab 打补丁](../policy/maintenance.md)、为您的操作系统及其软件打补丁，并按照厂商指南加固您的主机。

<a id="monitoring"></a>

## 监控

<a id="logs"></a>

### 日志

- [查看极狐GitLab 生成的日志类型和内容](../administration/logs/_index.md)。
- [查看 Runner 作业日志信息](../administration/cicd/job_logs.md)。
- [如何使用关联 ID 追踪日志](../administration/logs/tracing_correlation_id.md)。
- [日志配置和访问](https://gitlab.cn/docs/omnibus/settings/logs/)。
- [如何配置审计事件流](../administration/compliance/audit_event_streaming.md)。

<a id="response"></a>

## 响应

- [响应安全事件](responding_to_security_incidents.md)。

<a id="rate-limits"></a>

## 速率限制

有关速率限制的信息，请参阅[速率限制](../rate_limits/_index.md)。
