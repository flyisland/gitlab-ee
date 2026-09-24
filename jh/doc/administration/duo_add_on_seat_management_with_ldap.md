---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo 附加组件席位管理与 LDAP
description: 通过将席位状态与指定 LDAP 群组中的用户成员身份同步，自动分配和移除极狐GitLab Duo 附加组件席位
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.8 中引入。

{{< /history >}}

极狐GitLab 管理员可以基于 LDAP 群组成员身份配置自动的极狐GitLab Duo 附加组件席位分配。启用后，极狐GitLab 将在用户登录时根据其 LDAP 群组成员身份自动分配或移除附加组件席位。

<a id="seat-management-workflow"></a>

## 席位管理工作流

1. **配置**：管理员在 `duo_add_on_groups` [配置设置](#configure-gitlab-duo-add-on-seat-management) 中指定 LDAP 群组。
1. **席位同步**：极狐GitLab 通过两种方式检查 LDAP 群组成员身份：
   - **用户登录时**：当用户通过 LDAP 登录时，极狐GitLab 立即检查其群组成员身份。
   - **定时同步**：极狐GitLab 每天凌晨 2:00 自动同步所有 LDAP 用户，以确保即使没有用户登录，席位分配也保持最新。
1. **席位分配**：
   - 如果用户属于 `duo_add_on_groups` 中列出的任何群组，则为其分配附加组件席位（如果尚未分配）。
   - 如果用户不属于任何列出的群组，则移除其附加组件席位（如果之前已分配）。
1. **异步处理**：席位分配和移除以异步方式处理，以确保主登录流程不被中断。

下图展示了该工作流：

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
sequenceDiagram
    accTitle: 极狐GitLab Duo 附加组件席位管理与 LDAP 的工作流
    accDescr: 序列图展示了基于 LDAP 群组成员身份的自动极狐GitLab Duo 附加组件席位管理。用户登录，极狐GitLab 进行身份验证，然后将后台任务入队以根据其群组成员身份同步席位分配。

    participant 用户
    participant 极狐GitLab
    participant LDAP
    participant 后台任务

    用户->>极狐GitLab: 使用 LDAP 凭据登录
    极狐GitLab->>LDAP: 验证用户
    LDAP-->>极狐GitLab: 用户已验证
    极狐GitLab->>后台任务: 将 'LdapAddOnSeatSyncWorker' 席位同步任务入队
    极狐GitLab-->>用户: 登录完成
    后台任务->>后台任务: 开始
    后台任务->>LDAP: 根据 duo_add_on_groups 检查用户所在群组
    LDAP-->>后台任务: 返回群组成员身份
    alt 用户是否属于任何 duo_add_on_groups？
        后台任务->>极狐GitLab: 分配 Duo 附加组件席位
    else 用户不在 duo_add_on_groups 中
        后台任务->>极狐GitLab: 移除 Duo 附加组件席位（如果已分配）
    end
    后台任务-->>后台任务: 完成

    Note over 极狐GitLab, 后台任务: 此外，LdapAllAddOnSeatSyncWorker 每天凌晨 2 点运行以同步所有 LDAP 用户
```

<a id="configure-gitlab-duo-add-on-seat-management"></a>

## 配置极狐GitLab Duo 附加组件席位管理

要启用基于 LDAP 的附加组件席位管理：

1. 打开你为[安装](auth/ldap/ldap_synchronization.md#gitlab-duo-add-on-for-groups)编辑过的极狐GitLab 配置文件。
1. 将 `duo_add_on_groups` 设置添加到你的 LDAP 服务器配置中。
1. 指定应拥有极狐GitLab Duo 附加组件席位的 LDAP 群组名称数组。

以下示例是适用于 Linux 软件包安装的 `gitlab.rb` 配置：

```ruby
gitlab_rails['ldap_servers'] = {
  'main' => {
    # 为便于阅读，已移除其他 LDAP 设置
    'duo_add_on_groups' => ['duo_users', 'admins'],
  }
}
```