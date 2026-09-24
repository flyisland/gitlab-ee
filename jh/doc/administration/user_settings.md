---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置实例范围内的用户设置，例如群组创建和用户名更改。
title: 修改全局用户设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以修改 极狐GitLab 实例中每个用户的设置。

前提条件：

- 您必须是该实例的管理员。

<a id="prevent-users-from-creating-top-level-groups"></a>

## 禁止用户创建顶级群组

您可以禁止用户创建顶级群组。

当禁止创建群组时：

- 用户无法创建顶级群组。
- 用户可以在其具有维护者或所有者角色的群组中创建子群组，具体取决于该群组的
  [子群组创建权限](../user/group/subgroups/_index.md#change-who-can-create-subgroups)。

要禁止用户创建顶级群组，请使用以下方法之一：

| 方法          | 适用于新用户                                                                                                         | 适用于现有用户 |
| ------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------ |
| UI            | [账户和限制设置](settings/account_and_limit_settings.md#prevent-new-users-from-creating-top-level-groups) | [管理员区域的用户设置](admin_area.md#prevent-a-user-from-creating-top-level-groups) |
| API           | [应用程序设置 API](../api/settings.md#update-application-settings) 修改 `can_create_group` 设置   | [用户 API](../api/users.md#modify-a-user) 修改 `can_create_group` 设置 |
| Rails 控制台 | 无                                                                                                                  | [使用 Rails 控制台](#use-the-rails-console) |

<a id="use-the-rails-console"></a>

### 使用 Rails 控制台

您可以使用 Rails 控制台来禁止现有用户创建顶级群组。
当需要对多个用户进行批量更新时，请使用此方法。

要禁止现有用户创建顶级群组：

1.  启动一个 [Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。
1.  运行以下命令之一：

    - 要禁止除管理员外的所有现有用户创建群组：

      ```ruby
      User.where.not(admin: true).update_all(can_create_group: false)
      ```

    - 要禁止特定用户创建群组：

      ```ruby
      User.find_by(username: 'someuser').update(can_create_group: false)
      ```

1.  退出控制台：

    ```ruby
    exit
    ```

<a id="prevent-users-from-changing-their-usernames"></a>

## 禁止用户更改其用户名

默认情况下，用户可以更改他们的用户名。要禁止用户更改其用户名：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1.  编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

    ```ruby
    gitlab_rails['gitlab_username_changing_enabled'] = false
    ```

1.  [重新配置并重启 极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1.  编辑 `config/gitlab.yml` 并取消注释以下行：

    ```yaml
    # username_changing_enabled: false # 默认值: true - 用户可以更改他们的用户名/命名空间
    ```

1.  [重启 极狐GitLab](restart_gitlab.md#self-compiled-installations)。

{{< /tab >}}

{{< /tabs >}}

<a id="prevent-guest-users-from-promoting-to-a-higher-role"></a>

## 禁止访客用户升级到更高角色

在 极狐GitLab 旗舰版中，访客用户不计入付费席位。但是，当访客用户创建项目和命名空间时，他们会自动升级到比访客更高的角色，并占用一个付费席位。

要防止访客用户被升级到更高的角色并占用付费席位，请将该用户设置为[外部用户](external_users.md)。

外部用户无法创建个人项目或命名空间。如果拥有访客角色的用户被其他用户升级到更高的角色，则必须先移除该外部用户设置，然后他们才能创建个人项目或命名空间。有关外部用户的完整限制列表，请参阅[外部用户](external_users.md)。