---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: LDAP 同步
description: Learn how to configure LDAP synchronization for users and groups, and adjust the sync schedule.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您已经[配置 LDAP 与极狐GitLab 协同工作](_index.md)，极狐GitLab 可以自动同步用户和群组。

LDAP 同步会更新已分配 LDAP 身份的现有极狐GitLab 用户的用户和群组信息。它不会通过 LDAP 创建新的极狐GitLab 用户。

您可以更改同步发生的时间。

<a id="ldap-servers-with-rate-limits"></a>

## 具有速率限制的 LDAP 服务器

某些 LDAP 服务器配置了速率限制。

极狐GitLab 在以下情况下为每个对象查询一次 LDAP 服务器：

- 在计划的[用户同步](#user-sync)过程中，针对每个用户。
- 在计划的[群组同步](#group-sync)过程中，针对每个群组。

在某些情况下，可能会触发更多对 LDAP 服务器的查询。例如，当[群组同步查询返回 `memberuid` 属性](#queries)时。

如果 LDAP 服务器配置了速率限制，并且在以下过程中达到了该限制：

- 用户同步过程，LDAP 服务器会响应错误代码，极狐GitLab 将阻止该用户。
- 群组同步过程，LDAP 服务器会响应错误代码，极狐GitLab 将移除该用户的群组成员身份。

在配置 LDAP 同步时，您必须考虑 LDAP 服务器的速率限制，以防止不必要的用户阻止和群组成员身份移除。

<a id="user-sync"></a>

## 用户同步

{{< history >}}

- 阻止 LDAP 用户个人资料名称同步[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/11336)于极狐GitLab 15.11。

{{< /history >}}

极狐GitLab 每天运行一次工作器，根据 LDAP 检查和更新极狐GitLab 用户。

该过程执行以下访问检查：

- 确保用户仍然存在于 LDAP 中。
- 如果 LDAP 服务器是 Active Directory，确保用户处于活跃状态（未被阻止/禁用状态）。此检查仅在 LDAP 配置中设置了 `active_directory: true` 时执行。

在 Active Directory 中，如果用户的帐户控制属性 (`userAccountControl:1.2.840.113556.1.4.803`) 的第 2 位被设置，则该用户被标记为已禁用/已阻止。

<!-- vale gitlab_base.Spelling = NO -->

更多信息，请参见 [LDAP 中的位掩码搜索](https://ctovswild.com/2009/09/03/bitmask-searches-in-ldap/)。

<!-- vale gitlab_base.Spelling = YES -->

该过程还会更新以下用户信息：

- 姓名。由于一个[同步问题](https://gitlab.com/gitlab-org/gitlab/-/issues/342598)，如果启用了[**阻止用户更改其个人资料名称**](../../settings/account_and_limit_settings.md#disable-user-profile-name-changes)或 `sync_name` 设置为 `false`，则不会同步 `name`。
- 电子邮件地址。
- 如果设置了 `sync_ssh_keys`，则同步 SSH 公钥。
- 如果启用了 Kerberos，则同步 Kerberos 身份。

> [!note]
> 如果您的 LDAP 服务器有速率限制，该限制可能在用户同步过程中被达到。请查看[速率限制文档](#ldap-servers-with-rate-limits)以获取更多信息。

<a id="synchronize-ldap-users-profile-name"></a>

### 同步 LDAP 用户个人资料名称

默认情况下，极狐GitLab 会同步 LDAP 用户的个人资料名称字段。

要阻止此同步，您可以将 `sync_name` 设置为 `false`。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'sync_name' => false,
       }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             sync_name: false
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'sync_name' => false,
               }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           sync_name: false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="blocked-users"></a>

### 被阻止的用户

如果出现以下情况之一，用户会被阻止：

- [访问检查失败](#user-sync)，并且该用户在极狐GitLab 中被设置为 `ldap_blocked` 状态。
- 用户登录时 LDAP 服务器不可用。

如果用户被阻止，该用户将无法登录或推送或拉取代码。

当被阻止的用户通过 LDAP 登录时，如果满足以下所有条件，则该用户将被取消阻止：

- 所有访问检查条件均为真。
- 用户登录时 LDAP 服务器可用。

如果在运行 LDAP 用户同步时 LDAP 服务器不可用，则**所有用户**都会被阻止。

> [!note]
> 如果所有用户因为在运行 LDAP 用户同步时 LDAP 服务器不可用而被阻止，
> 后续的 LDAP 用户同步不会自动取消阻止这些用户。

<a id="group-sync"></a>

## 群组同步

如果您的 LDAP 支持 `memberof` 属性，当用户首次登录时，极狐GitLab 会触发对用户应所属群组的同步。
这样他们就无需等待每小时同步来获得对其群组和项目的访问权限。

群组同步过程每小时整点运行一次，并且必须在 LDAP 配置中设置 `group_base`，基于群组 CN 的 LDAP 同步才能工作。这允许极狐GitLab 群组成员身份根据 LDAP 群组成员自动更新。

`group_base` 配置应该是一个基础 LDAP '容器'，例如 '组织' 或 '组织单位'，其中包含应可用于极狐GitLab 的 LDAP 群组。例如，`group_base` 可以是 `ou=groups,dc=example,dc=com`。在配置文件中，它看起来如下所示。

> [!note]
> 如果您的 LDAP 服务器有速率限制，该限制可能在群组同步过程中被达到。请查看[速率限制文档](#ldap-servers-with-rate-limits)以获取更多信息。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'group_base' => 'ou=groups,dc=example,dc=com',
       }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             group_base: ou=groups,dc=example,dc=com
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'group_base' => 'ou=groups,dc=example,dc=com',
               }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           group_base: ou=groups,dc=example,dc=com
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

要利用群组同步，群组所有者或具有[维护者角色](../../../user/permissions.md)的用户必须[创建一个或多个 LDAP 群组链接](../../../user/group/access_and_permissions.md#manage-group-memberships-with-ldap)。

> [!note]
> 如果您经常遇到 LDAP 服务器和极狐GitLab 实例之间的连接问题，请尝试通过将群组同步工作器间隔设置为大于默认的 1 小时来降低极狐GitLab 执行 LDAP 群组同步的频率。

<a id="add-group-links"></a>

### 添加群组链接

有关使用 CN 和过滤器添加群组链接的信息，请参阅[极狐GitLab 群组文档](../../../user/group/access_and_permissions.md#manage-group-memberships-with-ldap)。

<a id="assign-an-admin-role-to-an-ldap-group"></a>

### 为 LDAP 群组分配管理员角色

作为群组同步的扩展，您可以自动管理您的全局极狐GitLab 管理员。为 `admin_group` 指定一个群组 CN，该 LDAP 群组的所有成员都将被授予管理员权限。配置如下所示。

> [!note]
> 除非同时指定了 `group_base` 和 `admin_group`，否则不会同步管理员。此外，仅指定 `admin_group` 的 CN，而不是完整的 DN。
> 另外，如果 LDAP 用户具有 `admin` 角色，但不是 `admin_group` 群组的成员，极狐GitLab 在同步时会撤销其 `admin` 角色。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'group_base' => 'ou=groups,dc=example,dc=com',
       'admin_group' => 'my_admin_group',
       }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             group_base: ou=groups,dc=example,dc=com
             admin_group: my_admin_group
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'group_base' => 'ou=groups,dc=example,dc=com',
               'admin_group' => 'my_admin_group',
               }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           group_base: ou=groups,dc=example,dc=com
           admin_group: my_admin_group
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="assign-a-custom-admin-role-to-an-ldap-group"></a>

### 为 LDAP 群组分配自定义管理员角色

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以为从外部 LDAP 群组同步的所有用户分配自定义管理员角色。此选项不适用于 SAML 群组。

如果用户属于多个具有不同分配自定义角色的 LDAP 群组，极狐GitLab 会分配与最先链接的 LDAP 群组相关联的角色。

> [!note]
> 如果在配置同步后，具有自定义管理员角色的 LDAP 用户被从 LDAP 群组中移除，
> 则自定义角色将在下一次同步时被移除。

先决条件：

- 与您的实例集成的 LDAP 服务器。
- 管理员访问权限。

{{< tabs >}}

{{< tab title="使用 LDAP CN 分配" >}}

要使用 LDAP CN 分配自定义管理员角色：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **角色和权限**。
1. 在 **LDAP 同步** 选项卡上，选择 **LDAP 服务器**。
1. 在 **同步方式** 字段中，选择 `Group cn`。
1. 在 **群组 CN** 字段中，开始输入群组的 CN。将出现一个下拉列表，其中包含配置的 `group_base` 中匹配的 CN。
1. 从下拉列表中选择您的 CN。
1. 在 **自定义管理员角色** 字段中，选择一个自定义管理员角色。
1. 选择 **添加**。

极狐GitLab 开始将该角色链接到任何匹配的 LDAP 用户。此过程可能需要一个多小时才能完成。

{{< /tab >}}

{{< tab title="使用 LDAP 过滤器分配" >}}

要使用 LDAP 过滤器分配自定义管理员角色：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **角色和权限**。
1. 在 **LDAP 同步** 选项卡上，选择 **LDAP 服务器**。
1. 在 **同步方式** 字段中，选择 `User filter`。
1. 在 **用户过滤器** 文本框中，输入过滤器。有关详细信息，请参见[设置 LDAP 用户过滤器](_index.md#set-up-ldap-user-filter)。
1. 在 **自定义管理员角色** 字段中，选择一个自定义管理员角色。
1. 选择 **添加**。

极狐GitLab 开始将该角色链接到任何匹配的 LDAP 用户。此过程可能需要一个多小时才能完成。

{{< /tab >}}

{{< /tabs >}}

<a id="global-ldap-group-memberships-lock"></a>

### 全局 LDAP 群组成员身份锁定

极狐GitLab 管理员可以阻止群组成员邀请新成员加入其成员身份与 LDAP 同步的子群组。

全局群组成员身份锁定仅适用于配置了 LDAP 同步的顶级群组的子群组。任何用户都不能修改配置了 LDAP 同步的顶级群组的成员身份。

当启用全局群组成员身份锁定时：

- 您不能将群组或子群组设置为代码所有者。
  更多信息，请参见[与全局群组成员身份锁定的不兼容性](../../../user/project/codeowners/troubleshooting.md#incompatibility-with-global-group-memberships-locks)。
- 只有管理员可以管理任何群组的成员身份，包括访问级别。
- 不允许用户与其他群组共享项目或邀请成员加入在群组中创建的项目。

要启用全局群组成员身份锁定：

1. [配置 LDAP](_index.md#configure-ldap)。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 确保选中 **锁定成员身份以进行 LDAP 同步** 复选框。

<a id="change-ldap-group-synchronization-settings-management"></a>

### 更改 LDAP 群组同步设置管理

默认情况下，具有所有者角色的群组成员可以管理 [LDAP 群组同步设置](../../../user/group/access_and_permissions.md#manage-group-memberships-with-ldap)。

极狐GitLab 管理员可以从群组所有者中移除此权限：

1. [配置 LDAP](_index.md#configure-ldap)。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 确保未选中 **允许群组所有者管理 LDAP 相关设置** 复选框。

当 **允许群组所有者管理 LDAP 相关设置** 被禁用时：

- 群组所有者无法更改顶级群组和子群组的 LDAP 同步设置。
- 实例管理员可以在实例的所有群组上管理 LDAP 群组同步设置。

<a id="external-groups"></a>

### 外部群组

使用 `external_groups` 设置，您可以将属于这些群组的所有用户标记为[外部用户](../../external_users.md)。群组成员身份通过 `LdapGroupSync` 后台任务定期检查。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'external_groups' => ['interns', 'contractors'],
       }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             external_groups: ['interns', 'contractors']
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'external_groups' => ['interns', 'contractors'],
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           external_groups: ['interns', 'contractors']
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="gitlab-duo-add-on-for-groups"></a>

### 群组的极狐GitLab Duo 附加组件

`duo_add_on_groups` 设置可自动为通过 LDAP 进行身份验证的用户[管理极狐GitLab Duo 附加组件席位](../../duo_add_on_seat_management_with_ldap.md)。此功能可帮助组织根据 LDAP 群组成员身份简化其 **极狐GitLab Duo** 席位分配过程。

极狐GitLab Duo 席位同步以两种方式进行：

- **用户登录时**：当用户通过 LDAP 登录时，极狐GitLab 立即检查其群组成员身份。
- **定时同步**：极狐GitLab 每天凌晨 02:00（服务器时间）自动同步所有 LDAP 用户，以确保即使没有用户登录，席位分配也能保持最新。

要为群组启用附加组件席位管理，您必须在极狐GitLab 实例中配置 `duo_add_on_groups` 设置：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'duo_add_on_groups' => ['duo_group_1', 'duo_group_2'],
       }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             duo_add_on_groups: ['duo_group_1', 'duo_group_2']
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
                 'duo_add_on_groups' => ['duo_group_1', 'duo_group_2'],
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           duo_add_on_groups: ['duo_group_1', 'duo_group_2']
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="group-sync-technical-details"></a>

### 群组同步技术细节

本节概述了执行了哪些 LDAP 查询以及您可以从群组同步中预期的行为。

如果用户的 LDAP 群组成员身份发生变化，其群组访问级别可能会被降级。例如，如果用户在群组中具有所有者角色，而下一次群组同步显示他们只应具有开发者角色，则其访问权限将相应调整。唯一的例外是如果用户是群组中的最后一个所有者。群组至少需要一名所有者来履行管理职责。

<a id="minimal-access-role-assignment-with-restricted-access"></a>

#### 受限访问下的最小访问角色分配

{{< history >}}

- [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/206932)于极狐GitLab 18.6，[使用功能标志](../../feature_flags/_index.md)名为 `bso_minimal_access_fallback`。默认禁用。
- [默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/225777)于极狐GitLab 18.10。

{{< /history >}}

当启用了[受限访问](../../../user/group/manage.md#restricted-access)并且没有可用的订阅席位时，在 LDAP 群组同步期间，用户将被分配最小访问角色。

更多信息，请参见[使用 SAML、SCIM 和 LDAP 的配置行为](../../../user/group/manage.md#provisioning-behavior-with-saml-scim-and-ldap)。

<a id="supported-ldap-group-typesattributes"></a>

#### 支持的 LDAP 群组类型/属性

极狐GitLab 支持使用以下成员属性的 LDAP 群组：

- `member`
- `submember`
- `uniquemember`
- `memberof`
- `memberuid`

这意味着群组同步至少支持具有以下对象类的 LDAP 群组：

- `groupOfNames`
- `posixGroup`
- `groupOfUniqueNames`

如果成员被定义为上述属性之一，其他对象类也应该可以工作。

Active Directory 支持嵌套群组。如果在配置文件中设置了 `active_directory: true`，群组同步会递归解析成员身份。

##### 嵌套群组成员身份

仅当在配置的 `group_base` 中找到嵌套群组时，才会解析嵌套群组成员身份。例如，如果极狐GitLab 看到一个 DN 为 `cn=nested_group,ou=special_groups,dc=example,dc=com` 的嵌套群组，但配置的 `group_base` 是 `ou=groups,dc=example,dc=com`，则 `cn=nested_group` 将被忽略。

<a id="queries"></a>

#### 查询

- 每个 LDAP 群组最多查询一次，使用基本 `group_base` 和过滤器 `(cn=<cn_from_group_link>)`。
- 如果 LDAP 群组具有 `memberuid` 属性，极狐GitLab 会为每个成员执行另一个 LDAP 查询，以获取每个用户的完整 DN。这些查询使用基本 `base`，范围 `baseObject`，以及取决于是否设置了 `user_filter` 的过滤器。过滤器可能是 `(uid=<uid_from_group>)` 或与 `user_filter` 的结合。

<a id="benchmarks"></a>

#### 基准测试

群组同步被编写为尽可能高性能。数据被缓存，数据库查询被优化，LDAP 查询被最小化。上次基准测试运行显示了以下指标：

对于 20,000 个 LDAP 用户、11,000 个 LDAP 群组和 1,000 个极狐GitLab 群组，每个群组有 10 个 LDAP 群组链接：

- 初始同步（极狐GitLab 中没有已分配的成员）耗时 1.8 小时
- 后续同步（检查成员身份，无写入）耗时 15 分钟

这些指标旨在提供一个基线，性能可能因多种因素而异。此基准测试是极端的，大多数实例没有这么多用户或群组。磁盘速度、数据库性能、网络和 LDAP 服务器响应时间都会影响这些指标。

<a id="adjust-ldap-sync-schedule"></a>

## 调整 LDAP 同步计划

您可以更改 LDAP 同步用户、群组和极狐GitLab Duo 附加组件席位的时间和间隔。

<a id="for-users"></a>

### 对于用户

默认情况下，极狐GitLab 每天凌晨 01:30（服务器时间）运行一次工作器，以根据 LDAP 检查和更新极狐GitLab 用户。

> [!warning]
> 不要过于频繁地运行同步过程，因为这可能导致多个同步同时运行。大多数安装不需要修改同步计划。有关更多信息，请参见 [LDAP 安全文档](_index.md#security)。

您可以通过以下配置值手动配置 LDAP 用户同步时间，格式为 cron。如有需要，可以使用 [crontab 生成器](https://it-tools.tech/crontab-generator)。下面的示例显示如何将 LDAP 用户同步设置为每 12 小时在整点运行一次。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_sync_worker_cron'] = "0 */12 * * *"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   待续...
```yaml
global:
  appConfig:
    cron_jobs:
      ldap_sync_worker:
        cron: "0 */12 * * *"
```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_sync_worker_cron'] = "0 */12 * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ee_cron_jobs:
       ldap_sync_worker:
         cron: "0 */12 * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

### 针对群组

默认情况下，极狐GitLab 每小时（整点）执行一次群组同步过程。所显示的值为 cron 格式。如果需要，你可以使用 [crontab 生成器](https://it-tools.tech/crontab-generator)。

> [!warning]
> 不要过于频繁地启动同步过程，因为这可能导致多个同步同时运行。大多数安装都不需要修改同步计划。

你可以通过设置以下配置值来手动配置 LDAP 群组同步时间。以下示例展示了如何设置群组同步每两小时在整点运行一次。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_group_sync_worker_cron'] = "0 */2 * * *"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       cron_jobs:
         ldap_group_sync_worker:
           cron: "*/30 * * * *"
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_group_sync_worker_cron'] = "0 */2 * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ee_cron_jobs:
       ldap_group_sync_worker:
         cron: "*/30 * * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

### 针对极狐GitLab Duo 附加席位

默认情况下，极狐GitLab 每天服务器时间凌晨 02:00 运行一次极狐GitLab Duo 附加席位同步过程，以检查 LDAP 群组成员资格并相应地分配或移除极狐GitLab Duo 附加席位。

> [!warning]
> 不要过于频繁地启动同步过程，因为这可能导致多个同步同时运行。大多数安装都不需要修改同步计划。

你可以通过设置配置值来手动配置 LDAP 极狐GitLab Duo 附加席位同步时间。以下示例展示了如何设置同步每四小时运行一次。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_add_on_seat_sync_worker_cron'] = "0 */4 * * *"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       cron_jobs:
         ldap_add_on_seat_sync_worker:
           cron: "0 */4 * * *"
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_add_on_seat_sync_worker_cron'] = "0 */4 * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ee_cron_jobs:
       ldap_add_on_seat_sync_worker:
         cron: "0 */4 * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}