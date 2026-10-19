---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 密码维护 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供用于管理密码的 Rake 任务。

<a id="reset-passwords"></a>

## 重置密码

要使用 Rake 任务重置密码，请参阅[重置用户密码](../../security/reset_user_password.md#use-a-rake-task)。

<a id="check-password-hashes"></a>

## 检查密码哈希

从极狐GitLab 17.11 开始，当用户登录时，FIPS 实例上密码哈希的盐值会增加。

非 FIPS 实例从极狐GitLab 17.9 开始使用更新后的 bcrypt 工作因子。

您可以检查有多少用户仍在使用未迁移的密码哈希：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:password:check_hashes:[true]

# installation from source
bundle exec rake gitlab:password:check_hashes:[true] RAILS_ENV=production
```

> [!note]
> 在极狐GitLab 18.6 之前，此任务名为 `gitlab:password:fips_check_salts`，
> 且仅限于 FIPS/PBKDF2 哈希验证。该任务已重命名为 `:check_hashes`，
> 现在会检查所有密码迁移，而旧名称仍作为别名保留。
