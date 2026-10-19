---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置实例范围的用户设置，例如创建群组和更改用户名。
title: 修改全局用户设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以修改极狐GitLab 实例中每个用户的设置。

先决条件：

- 您必须是该实例的管理员。

<a id="prevent-users-from-creating-top-level-groups"></a>

## 阻止用户创建顶级群组

您可以阻止用户创建顶级群组。

阻止创建群组后：

- 用户无法创建顶级群组。
- 用户可以在他们拥有维护者或所有者角色的群组中创建子群组，具体取决于该群组的
  [子群组创建权限](../user/group/subgroups/_index.md#change-who-can-create-subgroups)。

要阻止用户创建顶级群组，请使用以下方法之一：

| 方法          | 对于新用户                                                                                                             | 对于现有用户 |
| ------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------ |
| UI            | [账号和限制设置](settings/account_and_limit_settings.md#prevent-new-users-from-creating-top-level-groups) | [管理区域中的用户设置](admin_area.md#prevent-a-user-from-creating-top-level-groups) |
| API           | [应用设置 API](../api/settings.md#update-application-settings)，用于修改 `can_create_group` 设置   | [用户 API](../api/users.md#modify-a-user)，用于修改 `can_create_group` 设置 |
| Rails 控制台  | 无                                                                                                                    | [使用 Rails 控制台](#use-the-rails-console) |

<a id="use-the-rails-console"></a>

### 使用 Rails 控制台

您可以使用 Rails 控制台阻止现有用户创建顶级群组。在对多个用户进行批量更新时，请使用此方法。

要阻止现有用户创建顶级群组：

1. 启动 [Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下命令之一：

   - 阻止除管理员以外的所有现有用户创建群组：

     ```ruby
     User.where.not(admin: true).update_all(can_create_group: false)
     ```

   - 阻止特定用户创建群组：

     ```ruby
     User.find_by(username: 'someuser').update(can_create_group: false)
     ```

1. 退出控制台：

   ```ruby
   exit
   ```

<a id="prevent-users-from-changing-their-usernames"></a>

## 阻止用户更改其用户名

默认情况下，用户可以更改其用户名。要阻止用户更改其用户名：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['gitlab_username_changing_enabled'] = false
   ```

1. [重新配置并重启极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml` 并取消注释以下行：

   ```yaml
   # username_changing_enabled: false # default: true - User can change their username/namespace
   ```

1. [重启极狐GitLab](restart_gitlab.md#self-compiled-installations)。

{{< /tab >}}

{{< /tabs >}}

<a id="prevent-guest-users-from-promoting-to-a-higher-role"></a>

## 阻止访客用户提升为更高角色

在极狐GitLab 旗舰版中，访客用户不计入付费席位。但是，当访客用户创建项目和命名空间时，他们会自动提升为高于访客的角色，并占用一个付费席位。

要阻止访客用户提升为更高角色并占用付费席位，请将该用户设置为[外部用户](external_users.md)。

外部用户无法创建个人项目或命名空间。如果拥有访客角色的用户被其他用户提升为更高角色，则必须先移除外部用户设置，他们才能创建个人项目或命名空间。有关外部用户限制的完整列表，请参阅[外部用户](external_users.md)。
