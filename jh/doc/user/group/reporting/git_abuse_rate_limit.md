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

{{< history >}}

- 在 GitLab 15.2 中引入，带有功能标志 `limit_unique_project_downloads_per_namespace_user`。默认禁用。
- 在 GitLab 15.6 中在 JihuLab.com 上启用。
- 在 GitLab 18.0 中 GA。功能标志 `limit_unique_project_downloads_per_namespace_user` 已移除。

{{< /history >}}

这是群组级别的文档。对于私有化部署实例，请参阅[管理文档](../../../administration/reporting/git_abuse_rate_limit.md)。

Git 滥用速率限制是一项功能，可自动封禁在指定时间范围内下载、克隆、拉取、获取或派生超过指定数量群组仓库的用户。被封禁的用户无法通过 HTTP 或 SSH 访问顶级群组或其任何非公开子群组。该速率限制也适用于使用[个人访问令牌](../../profile/personal_access_tokens.md)或[群组访问令牌](../settings/group_access_tokens.md)以及 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)进行认证的用户。访问无关群组不受影响。

Git 滥用速率限制不适用于顶级群组所有者、[部署令牌](../../project/deploy_tokens/_index.md)或[部署密钥](../../project/deploy_keys/_index.md)。

极狐GitLab 如何确定用户的速率限制仍在开发中。极狐GitLab 团队成员可以在此机密史诗中查看更多信息：`https://gitlab.com/groups/gitlab-org/modelops/anti-abuse/-/epics/14`。

<a id="automatic-ban-notifications"></a>

## 自动封禁通知

选定的用户会在用户被封禁时收到电子邮件通知。

如果禁用了自动封禁，则用户超过限制时不会自动被封禁。但是，仍会发送通知。您可以使用此设置来确定速率限制设置的正确值，然后再启用自动封禁。

如果启用了自动封禁，则在用户即将被封禁时会发送电子邮件通知，并且该用户会自动从群组及其子群组中被封禁。

<a id="configure-git-abuse-rate-limiting"></a>

## 配置 Git 滥用速率限制

1. 在左侧边栏中，选择 **设置** > **报告**。
1. 更新 Git 滥用速率限制设置：
   1. 在 **仓库数量** 字段中输入一个数字，大于或等于 `0` 且小于或等于 `10,000`。此数字指定用户在指定时间段内可以下载的唯一仓库的最大数量，超过后将被封禁。设置为 `0` 时，Git 滥用速率限制被禁用。
   1. 在 **报告时间段（秒）** 字段中输入一个数字，大于或等于 `0` 且小于或等于 `86,400`（10 天）。此数字指定用户在被封禁前可以下载最大数量仓库的时间（以秒为单位）。设置为 `0` 时，Git 滥用速率限制被禁用。
   1. 可选。通过将最多 `100` 个用户添加到 **排除的用户** 字段来排除他们。被排除的用户不会被自动封禁。
   1. 将最多 `100` 个用户添加到 **发送通知给** 字段。您必须至少选择一个用户。默认情况下，主群组的所有具有所有者角色的用户都会被选中。
   1. 可选。打开 **当用户超过指定限制时自动从此命名空间封禁用户** 切换开关以启用自动封禁。
1. 选择 **保存更改**。

<a id="related-topics"></a>

## 相关主题

- [封禁和解封用户](../moderate_users.md)。