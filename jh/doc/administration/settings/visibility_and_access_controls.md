---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: Control project visibility, creation, retention, and deletion.
title: 控制访问和可见性
---

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

极狐GitLab 实例的管理员可以对分支、项目、代码片段、群组等实施特定控制。
例如，你可以定义：

- 哪些角色可以创建或删除项目。
- 已删除项目和群组的保留期限。
- 群组、项目和代码片段的可见性。
- SSH 密钥允许的类型和长度。
- Git 设置，例如允许的协议（SSH 或 HTTPS）和克隆 URL。
- 允许或阻止推送镜像和拉取镜像。

前提条件：

- 你必须具有管理员权限。

要访问可见性和访问控制选项：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。

<a id="define-which-roles-can-create-projects"></a>

## 定义哪些角色可以创建项目

你可以向实例添加项目创建保护。这些保护定义了哪些角色可以在实例上
[向群组添加项目](../../user/group/_index.md#specify-who-can-add-projects-to-a-group)。

配置 **创建项目所需默认最低角色** 设置时，你为新建群组设置了默认值。现有群组保留其当前权限。

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 为 **创建项目所需默认最低角色**，选择所需角色：
   - 无人。
   - 管理员。
   - 所有者。
   - 维护者。
   - 开发者。
1. 选择 **保存更改**。

> [!note]
> 如果你选择了 **管理员** 且 [管理员模式](sign_in_restrictions.md#admin-mode)
> 已启用，管理员必须进入管理员模式才能创建新项目。

<a id="restrict-project-deletion-to-administrators"></a>

## 将项目删除限制为管理员

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 你必须具有管理员权限，或者在项目中具有所有者角色。

要将项目删除权限限制为仅管理员：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 滚动到 **允许删除项目**，选择 **管理员**。
1. 选择 **保存更改**。

要禁用此限制：

1. 选择 **所有者和管理员**。
1. 选择 **保存更改**。

<a id="deletion-protection"></a>

## 删除保护

{{< history >}}

- 在极狐GitLab 16.0 中 [一般可用]。仅专业版和旗舰版。
- 在极狐GitLab 18.0 中从极狐GitLab 专业版 [迁移](https://gitlab.com/groups/gitlab-org/-/epics/17208) 到极狐GitLab 基础版。

{{< /history >}}

删除保护可防止实例上的群组和项目被意外删除。

<a id="retention-period"></a>

### 保留期限

群组和项目在定义的保留期内可以恢复。默认保留期为 30 天，但可以将其更改为 `1` 至 `90` 天之间的值。

前提条件：

- 你必须具有管理员访问权限。

要为群组和项目配置删除保护：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 滚动到 **保留期限**，将保留期设置为 `1` 至 `90` 天之间的值。
1. 选择 **保存更改**。

<a id="override-defaults-and-delete-permanently"></a>

### 覆盖默认值并永久删除

要覆盖延迟并永久删除标记为要删除的项目：

1. [恢复项目](../../user/project/working_with_projects.md#restore-a-project)。
1. 按照 [管理项目](../admin_area.md#administering-projects) 中的描述删除项目。

<a id="configure-project-visibility-defaults"></a>

## 配置项目可见性默认值

要设置 [新项目的默认可见性级别](../../user/public_access.md)：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 选择所需的默认项目可见性：
   - **私有** - 明确授予每个用户的项目访问权限。如果此项目属于群组，则授予群组成员访问权限。
   - **内部** - 除外部用户外的任何经过认证的用户都可以访问该项目。
   - **公开** - 任何用户无需认证即可访问该项目。
1. 选择 **保存更改**。

<a id="configure-snippet-visibility-defaults"></a>

## 配置代码片段可见性默认值

要设置新 [代码片段](../../user/snippets.md) 的默认可见性级别：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 对于 **默认代码片段可见性**，选择所需的可见性级别：
   - **私有**。
   - **内部**。JihuLab.com 上的新项目、群组和代码片段已禁用此设置。
     使用 `内部` 可见性设置的现有代码片段保留此设置。要了解有关此更改的更多信息，请参阅议题 12388。
   - **公开**。
1. 选择 **保存更改**。

<a id="configure-group-visibility-defaults"></a>

## 配置群组可见性默认值

要设置新群组的默认可见性级别：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 对于 **默认群组可见性**，选择所需的可见性级别：
   - **私有** - 只有成员可以查看群组及其项目。
   - **内部** - 除外部用户外的任何经过认证的用户都可以查看群组和任何内部项目。
   - **公开** - 无需认证即可查看群组和任何公开项目。
1. 选择 **保存更改**。

有关群组可见性的更多详细信息，请参阅
[群组可见性](../../user/group/_index.md#group-visibility)。

<a id="restrict-visibility-levels"></a>

## 限制可见性级别

{{< history >}}

- 在极狐GitLab 16.3 中 [更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/124649)，以阻止限制默认项目和群组可见性，[使用功能标志](../feature_flags/_index.md) `prevent_visibility_restriction`。默认禁用。
- `prevent_visibility_restriction` 在极狐GitLab 16.4 中 [默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/131203)。
- `prevent_visibility_restriction` 在极狐GitLab 16.7 中 [移除](https://gitlab.com/gitlab-org/gitlab/-/issues/433280)。

{{< /history >}}

限制可见性级别时，请考虑这些限制如何与从你更改的项目继承可见性的子群组和项目的权限进行交互。

此设置不适用于在个人命名空间下创建的项目。
有一个功能请求，旨在将此功能扩展到 [企业用户](../../user/enterprise_user/_index.md)。

要限制群组、项目、代码片段和选定页面的可见性级别：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 对于 **受限可见性级别**，选择要限制的可见性级别。
   - 如果限制 **公开** 级别：
     - 只有管理员可以创建公开群组、项目和代码片段。
     - 用户资料仅对通过 Web 界面认证的用户可见。
     - 通过 GraphQL API 不可见用户属性。
   - 如果限制 **内部** 级别：
     - 只有管理员可以创建内部群组、项目和代码片段。
   - 如果限制 **私有** 级别：
     - 只有管理员可以创建私有群组、项目和代码片段。
1. 选择 **保存更改**。

> [!note]
> 你不能限制被设置为新项目或新群组的默认可见性级别。
> 相反，你不能将受限的可见性级别设置为新项目或新群组的默认值。

<a id="configure-enabled-git-access-protocols"></a>

## 配置启用的 Git 访问协议

通过极狐GitLab 访问限制，你可以选择用户可用于与极狐GitLab 通信的协议。禁用访问协议不会阻止对服务器本身的端口访问。用于该协议的端口（SSH 或 HTTP(S)）仍然可访问。
极狐GitLab 限制在应用程序级别生效。

极狐GitLab 仅对你选择的协议允许 Git 操作：

- 如果你同时启用 SSH 和 HTTP(S)，用户可以选择任一协议。
- 如果你只启用一个协议，项目页面仅显示允许协议的 URL，没有更改选项。

要为实例上的所有项目指定启用的 Git 访问协议：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 对于 **启用的 Git 访问协议**，选择所需协议：
   - 同时使用 SSH 和 HTTP(S)。
   - 仅 SSH。
   - 仅 HTTP(S)。
1. 选择 **保存更改**。

> [!warning]
> 极狐GitLab [允许 HTTP(S) 协议](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/18021)
> 用于 [使用极狐GitLab CI/CD 作业令牌](../../ci/jobs/ci_job_token.md) 执行的 Git 克隆或 fetch 请求。
> 即使你选择了 **仅 SSH**，这也会发生，因为极狐GitLab Runner 和 CI/CD 作业需要此设置。

<a id="customize-git-clone-url-for-http(s)"></a>

## 自定义 HTTP(S) 的 Git 克隆 URL

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

你可以自定义 HTTP(S) 的项目 Git 克隆 URL，这会影响项目页面上向用户显示的克隆面板。例如：

- 如果你的极狐GitLab 实例位于 `https://example.com`，那么项目克隆 URL 类似于 `https://example.com/foo/bar.git`。
- 你希望克隆 URL 显示为 `https://git.example.com/gitlab/foo/bar.git`，则可以将此设置设置为 `https://git.example.com/gitlab/`。

要在 `gitlab.rb` 中为 HTTP(S) 指定自定义 Git 克隆 URL，请为 `gitlab_rails['gitlab_ssh_host']` 设置新值。要通过极狐GitLab UI 指定新值：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 在 **自定义 HTTP(S) 的 Git 克隆 URL** 中输入根 URL。
1. 选择 **保存更改**。

<a id="configure-defaults-for-rsa,-dsa,-ecdsa,-ed25519,-ecdsa_sk,-ed25519_sk-ssh-keys"></a>

## 配置 RSA、DSA、ECDSA、ED25519、ECDSA_SK、ED25519_SK SSH 密钥的默认值

这些选项指定了 [允许的 SSH 密钥类型和长度](../../security/ssh_keys_restrictions.md)。

要为每种密钥类型指定限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 转到 **RSA SSH 密钥**。
1. 对于每种密钥类型，你可以完全允许或阻止其使用，或者只允许以下长度：
   - 至少 1024 位。
   - 至少 2048 位。
   - 至少 3072 位。
   - 至少 4096 位。
   - 至少 1024 位。
1. 选择 **保存更改**。

<a id="enable-project-mirroring"></a>

## 启用项目镜像

极狐GitLab 默认启用项目镜像。如果你禁用它，[拉取镜像](../../user/project/repository/mirror/pull.md) 和
[推送镜像](../../user/project/repository/mirror/push.md) 在所有仓库中都不再有效。它们只能由管理员用户按每个项目重新启用。

要允许实例上的项目维护者按项目配置镜像：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **代码仓镜像**。
1. 选择 **允许项目维护者配置仓库镜像**。
1. 选择 **保存更改**。

<a id="configure-globally-allowed-ip-address-ranges"></a>

## 配置全局允许的 IP 地址范围

管理员可以将 IP 地址范围与
[按群组限制 IP](../../user/group/access_and_permissions.md#restrict-group-access-by-ip-address) 结合使用。
全局允许的 IP 地址使得极狐GitLab 安装的某些方面能够正常工作，即使群组设置了各自的 IP 地址限制。

例如，如果极狐GitLab Pages 守护程序运行在 `10.0.0.0/24` 范围内，则全局允许该范围。
即使群组的 IP 地址限制不包括 `10.0.0.0/24` 范围，极狐GitLab Pages 仍然可以从流水线获取产物。

要将 IP 地址范围添加到群组的允许列表中：

前提条件：

- 你必须具有管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 在 **全局允许的 IP 范围** 中，提供 IP 地址范围的列表。此列表：
   - 对 IP 地址范围的数量没有限制。
   - 同时适用于 SSH 或 HTTP 授权 IP 地址范围。你不能按授权类型拆分此列表。
1. 选择 **保存更改**。

<a id="prevent-invitations-to-groups-and-projects"></a>

## 禁止邀请用户加入群组和项目

{{< history >}}

- 在极狐GitLab 18.0 中 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/189954)。默认禁用。

{{< /history >}}

管理员可以阻止非管理员邀请用户加入实例上的所有群组或项目。
当你配置此设置时，只有管理员可以邀请用户加入实例上的群组或项目。

> [!note]
> 诸如 [共享](../../user/project/members/sharing_projects_groups.md) 或 [迁移](../../user/import/_index.md) 等功能仍然可能允许访问这些群组和项目。

前提条件：

- 你必须具有管理员权限。

要禁止邀请：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 选中 **禁止群组成员邀请** 复选框。
1. 选择 **保存更改**。

<a id="display-gitlab-credits-user-data"></a>

## 显示极狐GitLab 积分用户数据

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.7 中，允许显示用户数据的实例设置
  [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/214538)，[使用功能标志](../feature_flags/_index.md) `usage_billing_dev`。[默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/215714)。
- 在极狐GitLab 18.10 中，功能标志 `usage_billing_dev` [移除](https://gitlab.com/gitlab-org/gitlab/-/work_items/566581)。

{{< /history >}}

前提条件：

- 你必须具有管理员权限。

要在 [极狐GitLab 积分仪表板](../../subscriptions/gitlab_credits.md#gitlab-credits-dashboard) 上启用用户数据的显示：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 对于 **极狐GitLab 积分仪表板**，选中 **显示用户数据** 复选框。
1. 选择 **保存更改**。