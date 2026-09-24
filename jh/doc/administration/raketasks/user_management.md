---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Perform bulk user operations and manage authentication settings using Rake tasks.
title: 用户管理 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了用于管理用户的 Rake 任务。管理员也可以使用**管理员**区域来[管理用户](../admin_area.md#administering-users)。

<a id="add-user-as-a-developer-to-all-projects"></a>

## 将用户作为开发者添加到所有项目

要将用户作为开发者添加到所有项目，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:import:user_to_projects[username@domain.tld]

# 从源代码安装
bundle exec rake gitlab:import:user_to_projects[username@domain.tld] RAILS_ENV=production
```

<a id="add-all-users-to-all-projects"></a>

## 将所有用户添加到所有项目

要将所有用户添加到所有项目，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:import:all_users_to_all_projects

# 从源代码安装
bundle exec rake gitlab:import:all_users_to_all_projects RAILS_ENV=production
```

管理员被添加为维护者，所有其他用户被添加为开发者。

<a id="add-user-as-a-developer-to-all-groups"></a>

## 将用户作为开发者添加到所有群组

要将用户作为开发者添加到所有群组，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:import:user_to_groups[username@domain.tld]

# 从源代码安装
bundle exec rake gitlab:import:user_to_groups[username@domain.tld] RAILS_ENV=production
```

<a id="add-all-users-to-all-groups"></a>

## 将所有用户添加到所有群组

要将所有用户添加到所有群组，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:import:all_users_to_all_groups

# 从源代码安装
bundle exec rake gitlab:import:all_users_to_all_groups RAILS_ENV=production
```

管理员被添加为所有者，这样他们就可以向群组添加其他用户。

<a id="update-all-users-in-a-given-group-to-project_limit0-and-can_create_group-false"></a>

## 将指定群组中的所有用户更新为 `project_limit:0` 和 `can_create_group: false`

要将指定群组中的所有用户更新为 `project_limit: 0` 和 `can_create_group: false`，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:user_management:disable_project_and_group_creation\[:group_id\]

# 从源代码安装
bundle exec rake gitlab:user_management:disable_project_and_group_creation\[:group_id\] RAILS_ENV=production
```

它会更新指定群组、其子群组以及此群组命名空间中的项目中的所有用户，并应用上述限制。

<a id="control-the-number-of-billable-users"></a>

## 控制可计费用户的数量

启用此设置以保持新用户被阻止，直到他们被管理员清除。默认为 `false`：

```plaintext
block_auto_created_users: false
```

<a id="disable-two-factor-authentication-for-all-users"></a>

## 为所有用户禁用双重身份验证

此任务为所有启用了双重身份验证（2FA）的用户禁用它。例如，如果极狐GitLab 的 `config/secrets.yml` 文件丢失并且用户无法登录时，这可能很有用。

要为所有用户禁用双重身份验证，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:two_factor:disable_for_all_users

# 从源代码安装
bundle exec rake gitlab:two_factor:disable_for_all_users RAILS_ENV=production
```

<a id="rotate-two-factor-authentication-encryption-key"></a>

## 轮换双重身份验证加密密钥

极狐GitLab 将双重身份验证（2FA）所需的密钥数据存储在加密的数据库列中。该数据的加密密钥称为 `otp_key_base`，并存储在 `config/secrets.yml` 中。

如果该文件泄露，但各用户的 2FA 密钥尚未泄露，则可使用新的加密密钥重新加密这些密钥。这使您可以更改已泄露的密钥，而无需强制所有用户更改其 2FA 详细信息。

要轮换双重身份验证加密密钥：

1. 在 `config/secrets.yml` 文件中查找旧密钥，但**请确保您正在操作的是生产环境部分**。您感兴趣的行如下所示：

   ```yaml
   production:
     otp_key_base: fffffffffffffffffffffffffffffffffffffffffffffff
   ```

1. 生成新密钥：

   ```shell
   # omnibus-gitlab
   sudo gitlab-rake secret

   # 从源代码安装
   bundle exec rake secret RAILS_ENV=production
   ```

1. 停止极狐GitLab 服务器，备份现有的 secrets 文件，并更新数据库：

   ```shell
   # omnibus-gitlab
   sudo gitlab-ctl stop
   sudo cp config/secrets.yml config/secrets.yml.bak
   sudo gitlab-rake gitlab:two_factor:rotate_key:apply filename=backup.csv old_key=<old key> new_key=<new key>

   # 从源代码安装
   sudo /etc/init.d/gitlab stop
   cp config/secrets.yml config/secrets.yml.bak
   bundle exec rake gitlab:two_factor:rotate_key:apply filename=backup.csv old_key=<old key> new_key=<new key> RAILS_ENV=production
   ```

   可以从 `config/secrets.yml` 中读取 `<old key>` 的值（`<new key>` 是之前生成的）。用户 2FA 密钥的**加密**值会写入指定的 `filename`。您可以使用它来回滚以防出错。

1. 更改 `config/secrets.yml` 将 `otp_key_base` 设置为 `<new key>` 并重启。同样，请确保您正在操作**生产**环境部分。

   ```shell
   # omnibus-gitlab
   sudo gitlab-ctl start

   # 从源代码安装
   sudo /etc/init.d/gitlab start
   ```

如果出现任何问题（例如为 `old_key` 使用了错误的值），您可以恢复 `config/secrets.yml` 的备份并回滚更改：

```shell
# omnibus-gitlab
sudo gitlab-ctl stop
sudo gitlab-rake gitlab:two_factor:rotate_key:rollback filename=backup.csv
sudo cp config/secrets.yml.bak config/secrets.yml
sudo gitlab-ctl start

# 从源代码安装
sudo /etc/init.d/gitlab start
bundle exec rake gitlab:two_factor:rotate_key:rollback filename=backup.csv RAILS_ENV=production
cp config/secrets.yml.bak config/secrets.yml
sudo /etc/init.d/gitlab start
```

<a id="bulk-assign-users-to-gitlab-duo"></a>

## 批量将用户分配给极狐GitLab Duo

您可以使用包含用户名的 CSV 文件批量将用户分配给极狐GitLab Duo。CSV 文件必须有一个名为 `username` 的表头，然后在后续每一行中包含用户名。

```plaintext
username
user1
user2
user3
user4
```

<a id="gitlab-duo-pro"></a>

### 极狐GitLab Duo Pro

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 16.9 引入。

{{< /history >}}

要对极狐GitLab Duo Pro 执行批量用户分配，您可以使用以下 Rake 任务：

```shell
bundle exec rake duo_pro:bulk_user_assignment DUO_PRO_BULK_USER_FILE_PATH=path/to/your/file.csv
```

如果您希望在文件路径中使用方括号，可以对其进行转义或使用双引号：

```shell
bundle exec rake duo_pro:bulk_user_assignment\['path/to/your/file.csv'\]
# 或者
bundle exec rake "duo_pro:bulk_user_assignment[path/to/your/file.csv]"
```

<a id="gitlab-duo-pro-and-enterprise"></a>

### 极狐GitLab Duo Pro 和 Enterprise

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.0 引入。

{{< /history >}}

<a id="gitlab-self-managed"></a>

#### 极狐GitLab 私有化部署

此 Rake 任务根据已购买的可购买附加产品，在实例级别将极狐GitLab Duo Pro 或 Enterprise 席位批量分配给 CSV 文件中的用户列表。

要对私有化部署的极狐GitLab 实例执行批量用户分配：

```shell
bundle exec rake gitlab_subscriptions:duo:bulk_user_assignment DUO_BULK_USER_FILE_PATH=path/to/your/file.csv
```

如果您希望在文件路径中使用方括号，可以对其进行转义或使用双引号：

```shell
bundle exec rake gitlab_subscriptions:duo:bulk_user_assignment\['path/to/your/file.csv'\]
# 或者
bundle exec rake "gitlab_subscriptions:duo:bulk_user_assignment[path/to/your/file.csv]"
```

<a id="gitlab-com"></a>

#### JihuLab.com

JihuLab.com 管理员也可以使用此 Rake 任务，根据该群组已购买的可购买附加产品，为 JihuLab.com 群组批量分配极狐GitLab Duo Pro 或 Enterprise 席位。

要为 JihuLab.com 群组执行批量用户分配：

```shell
bundle exec rake gitlab_subscriptions:duo:bulk_user_assignment DUO_BULK_USER_FILE_PATH=path/to/your/file.csv NAMESPACE_ID=<namespace_id>
```

如果您希望在文件路径中使用方括号，可以对其进行转义或使用双引号：

```shell
bundle exec rake gitlab_subscriptions:duo:bulk_user_assignment\['path/to/your/file.csv','<namespace_id>'\]
# 或者
bundle exec rake "gitlab_subscriptions:duo:bulk_user_assignment[path/to/your/file.csv,<namespace_id>]"
```

<a id="troubleshooting"></a>

## 故障排除

<a id="errors-during-bulk-user-assignment"></a>

### 批量用户分配期间的错误

当使用 Rake 任务进行批量用户分配时，你可能会遇到以下错误：

- `User is not found`：找不到指定的用户。请确保提供的用户名与现有用户匹配。
- `ERROR_NO_SEATS_AVAILABLE`：没有更多可用席位可用于用户分配。请参阅如何[查看已分配的极狐GitLab Duo 用户](../../subscriptions/subscription-add-ons.md#view-assigned-gitlab-duo-users)以检查当前的席位分配情况。
- `ERROR_INVALID_USER_MEMBERSHIP`：用户不符合分配资格，原因可能是用户处于非活跃状态、是机器人或幽灵用户。请确保用户是活跃的，并且如果在 JihuLab.com 上，还要确保用户是所提供命名空间的成员。