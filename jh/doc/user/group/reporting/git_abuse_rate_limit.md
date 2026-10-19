---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Git 滥用速率限制
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

这是群组级文档。对于极狐GitLab 私有化部署实例，请参阅[管理文档](../../../administration/reporting/git_abuse_rate_limit.md)。

Git 滥用速率限制是一项功能，可自动封禁在给定时间范围内下载、克隆、拉取、获取或 fork 群组代码仓库数量超过指定值的用户。被封禁的用户无法通过 HTTP 或 SSH 访问顶级群组或其任何非公开子群组。该速率限制同样适用于使用[个人访问令牌](../../profile/personal_access_tokens.md)或[群组访问令牌](../settings/group_access_tokens.md)进行身份验证的用户，以及 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。对无关群组的访问不受影响。

Git 滥用速率限制不适用于顶级群组所有者、[部署令牌](../../project/deploy_tokens/_index.md)或[部署密钥](../../project/deploy_keys/_index.md)。

<a id="automatic-ban-notifications"></a>

## 自动封禁通知

当用户被封禁时，选定的用户会收到电子邮件通知。

如果自动封禁已禁用，用户超过限制时不会被自动封禁。但是，仍会发送通知。您可以使用此设置来确定速率限制设置的正确值，然后再启用自动封禁。

如果自动封禁已启用，当用户即将被封禁时会发送电子邮件通知，并且该用户会被自动封禁，无法访问该群组及其子群组。

<a id="configure-git-abuse-rate-limiting"></a>

## 配置 Git 滥用速率限制

1. 在左侧边栏中，选择**设置** > **报告**。
1. 更新 Git 滥用速率限制设置：
   1. 在**代码仓库数量**字段中输入一个大于或等于 `0` 且小于或等于 `10,000`的数字。该数字指定用户在指定时间段内可下载的唯一代码仓库的最大数量，超过该数量后将被封禁。设置为 `0` 时，Git 滥用速率限制将被禁用。
   1. 在**报告时间段（秒）**字段中输入一个大于或等于 `0` 且小于或等于 `86,400`（10 天）的数字。该数字指定用户可下载最大数量代码仓库的时间（以秒为单位），超过该时间后将被封禁。设置为 `0` 时，Git 滥用速率限制将被禁用。
   1. 可选。通过将用户添加到**排除的用户**字段，最多可排除 `100` 名用户。被排除的用户不会被自动封禁。
   1. 将最多 `100` 名用户添加到**发送通知给**字段。您必须至少选择一名用户。默认情况下，主群组中所有具有所有者角色的用户都会被选中。
   1. 可选。开启**当用户超过指定限制时自动从该命名空间封禁用户**开关以启用自动封禁。
1. 选择**保存更改**。
