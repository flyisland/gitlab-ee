---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 LDAP 管理极狐GitLab Duo 附加组件席位
description: 通过将席位状态与指定 LDAP 群组中的用户成员关系同步，自动分配和移除极狐GitLab Duo 附加组件席位。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 管理员可以根据 LDAP 群组成员关系配置极狐GitLab Duo 附加组件席位的自动分配。启用后，极狐GitLab 会在用户登录时，根据其 LDAP 群组成员关系自动为用户分配或移除附加组件席位。

<a id="seat-management-workflow"></a>

## 席位管理工作流

1. **配置**：管理员在 `duo_add_on_groups` [配置设置](#configure-gitlab-duo-add-on-seat-management)中指定 LDAP 群组。
1. **席位同步**：极狐GitLab 通过两种方式检查 LDAP 群组成员关系：
   - **用户登录时**：当用户通过 LDAP 登录时，极狐GitLab 会立即检查其群组成员关系。
   - **定时同步**：极狐GitLab 每天凌晨 02:00 自动同步所有 LDAP 用户，以确保即使没有用户登录，席位分配也保持最新。
1. **席位分配**：
   - 如果用户属于 `duo_add_on_groups`中列出的任一群组，则会为其分配一个附加组件席位（如果尚未分配）。
   - 如果用户不属于任何列出的群组，则会移除其附加组件席位（如果之前已分配）。
1. **异步处理**：席位的分配和移除以异步方式处理，以确保主登录流程不被打断。

下图展示了该工作流：

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
sequenceDiagram
    accTitle: Workflow of GitLab Duo add-on seat management with LDAP
    accDescr: Sequence diagram showing automatic GitLab Duo add-on seat management based on LDAP group membership. Users sign in, GitLab authenticates them, then enqueues a background job to sync seat assignment based on their group membership.

    participant User
    participant GitLab
    participant LDAP
    participant Background Job

    User->>GitLab: Sign in with LDAP credentials
    GitLab->>LDAP: Authenticate user
    LDAP-->>GitLab: User authenticated
    GitLab->>Background Job: Enqueue 'LdapAddOnSeatSyncWorker' seat sync job
    GitLab-->>User: Sign-in complete
    Background Job->>Background Job: Start
    Background Job->>LDAP: Check user's groups against duo_add_on_groups
    LDAP-->>Background Job: Return membership of groups
    alt User member of any duo_add_on_groups?
        Background Job->>GitLab: Assign Duo Add-on seat
    else User not in duo_add_on_groups
        Background Job->>GitLab: Remove Duo Add-on seat (if assigned)
    end
    Background Job-->>Background Job: Complete

    Note over GitLab, Background Job: Additionally, LdapAllAddOnSeatSyncWorker runs daily at 2 AM to sync all LDAP users
```

<a id="configure-gitlab-duo-add-on-seat-management"></a>

## 配置极狐GitLab Duo 附加组件席位管理

要开启基于 LDAP 的附加组件席位管理：

1. 打开您为[安装](auth/ldap/ldap_synchronization.md#gitlab-duo-add-on-for-groups)而编辑的极狐GitLab 配置文件。
1. 将 `duo_add_on_groups` 设置添加到您的 LDAP 服务器配置中。
1. 指定应拥有极狐GitLab Duo 附加组件席位的 LDAP 群组名称数组。

以下示例是 Linux 软件包安装的 `gitlab.rb` 配置：

```ruby
gitlab_rails['ldap_servers'] = {
  'main' => {
    # Additional LDAP settings removed for readability
    'duo_add_on_groups' => ['duo_users', 'admins'],
  }
}
```
