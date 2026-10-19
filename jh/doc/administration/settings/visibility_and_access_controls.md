---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 控制项目可见性、创建、保留和删除。
title: 控制访问和可见性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 实例的管理员可以对分支、项目、代码片段、群组等强制执行特定控制。例如，您可以定义：

- 哪些角色可以创建或删除项目。
- 已删除项目和群组的保留期。
- 群组、项目和代码片段的可见性。
- SSH 密钥的允许类型和长度。
- Git 设置，例如接受的协议（SSH 或 HTTPS）和克隆 URL。
- 允许或阻止推送镜像和拉取镜像。

先决条件：

- 您必须是管理员。

要访问可见性和访问控制选项：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。

<a id="define-which-roles-can-create-projects"></a>

## 定义哪些角色可以创建项目

您可以为实例添加项目创建保护。这些保护定义了哪些角色可以在实例上[将项目添加到群组](../../user/group/_index.md#specify-who-can-add-projects-to-a-group)。

当您配置**创建项目所需的默认最低角色**设置时，您为新建群组设置默认值。现有群组保留其当前权限。

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 对于**创建项目所需的默认最低角色**，选择所需的角色：
   - 无人。
   - 管理员。
   - 所有者。
   - 维护者。
   - 开发者。
1. 选择**保存更改**。

> [!note]
> 如果您选择**管理员**并且启用了[管理员模式](sign_in_restrictions.md#admin-mode)，
> 则管理员必须进入管理员模式才能创建新项目。

<a id="restrict-project-deletion-to-administrators"></a>

## 将项目删除限制为仅管理员

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员，或在项目中拥有所有者角色。

要将项目删除限制为仅管理员：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 滚动到**允许删除项目**，然后选择**管理员**。
1. 选择**保存更改**。

要禁用该限制：

1. 选择**所有者和管理员**。
1. 选择**保存更改**。

<a id="deletion-protection"></a>

## 删除保护

删除保护可防止意外删除实例上的群组和项目。

<a id="retention-period"></a>

### 保留期

在您定义的保留期内，群组和项目仍可恢复。默认情况下，保留期为 30 天，但您可以将其更改为 `1` 到 `90` 天之间的值。

先决条件：

- 您必须拥有管理员访问权限。

要为群组和项目配置删除保护：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 滚动到**保留期**，并将保留期设置为 `1` 到 `90` 天之间的值。
1. 选择**保存更改**。

<a id="override-defaults-and-delete-permanently"></a>

### 覆盖默认值并永久删除

要覆盖延迟，并永久删除标记为待移除的项目：

1. [恢复项目](../../user/project/working_with_projects.md#restore-a-project)。
1. 按照
   [管理项目](../admin_area.md#administering-projects)中所述删除项目。

<a id="configure-project-visibility-defaults"></a>

## 配置项目可见性默认值

要设置[新项目的默认可见性级别](../../user/public_access.md)：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 选择所需的默认项目可见性：
   - **私有** - 向每个用户显式授予项目访问权限。如果此
     项目是群组的一部分，则向群组成员授予访问权限。
   - **内部** - 任何已认证用户（外部用户除外）都可以访问该项目。
   - **公开** - 任何用户无需任何认证即可访问该项目。
1. 选择**保存更改**。

<a id="configure-snippet-visibility-defaults"></a>

## 配置代码片段可见性默认值

要设置新[代码片段](../../user/snippets.md)的默认可见性级别：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 对于**默认代码片段可见性**，选择所需的可见性级别：
   - **私有**。
   - **内部**。在 JihuLab.com 上，此设置对新项目、群组和代码片段已禁用。
     使用 `Internal` 可见性设置的现有代码片段会保留此设置。要详细了解
     此变更，请参阅[议题 12388](https://gitlab.com/gitlab-org/gitlab/-/issues/12388)。
   - **公开**。
1. 选择**保存更改**。

<a id="configure-group-visibility-defaults"></a>

## 配置群组可见性默认值

要设置新群组的默认可见性级别：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 对于**默认群组可见性**，选择所需的可见性级别：
   - **私有** - 只有成员可以查看该群组及其项目。
   - **内部** - 任何已认证用户（外部用户除外）都可以查看该群组及任何内部项目。
   - **公开** - 查看该群组及任何公开项目无需认证。
1. 选择**保存更改**。

有关群组可见性的更多详细信息，请参阅[群组可见性](../../user/group/_index.md#group-visibility)。

<a id="restrict-visibility-levels"></a>

## 限制可见性级别

在限制可见性级别时，请考虑这些限制如何与从您所更改的项继承可见性的子群组和项目的权限相互作用。

此设置不适用于在个人命名空间下创建的项目。有一个[功能请求](https://gitlab.com/gitlab-org/gitlab/-/issues/382749)希望将此功能扩展到[企业用户](../../user/enterprise_user/_index.md)。

要限制群组、项目、代码片段和选定页面的可见性级别：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 对于**受限可见性级别**，选择要限制的所需可见性级别。
   - 如果您限制**公开**级别：
     - 只有管理员可以创建公开群组、项目和代码片段。
     - 用户个人资料仅对已认证用户通过 Web 界面可见。
     - 用户属性无法通过 GraphQL API 查看。
   - 如果您限制**内部**级别：
     - 只有管理员可以创建内部群组、项目和代码片段。
   - 如果您限制**私有**级别：
     - 只有管理员可以创建私有群组、项目和代码片段。
1. 选择**保存更改**。

> [!note]
> 您不能限制已设置为新项目或群组默认值的可见性级别。
> 反之，您也不能将受限的可见性级别设置为新项目或群组的默认值。

<a id="configure-enabled-git-access-protocols"></a>

## 配置启用的 Git 访问协议

通过极狐GitLab 访问限制，您可以选择用户可用于与极狐GitLab 通信的协议。禁用某个访问协议不会阻止对服务器本身的端口访问。用于该协议（SSH 或 HTTP(S)）的端口仍然可访问。极狐GitLab 限制在应用层生效。

极狐GitLab 仅允许您所选协议执行 Git 操作：

- 如果您同时启用 SSH 和 HTTP(S)，用户可以选择任一协议。
- 如果您只启用一个协议，项目页面只显示所允许协议的
  URL，且没有更改它的选项。

要为实例上的所有项目指定启用的 Git 访问协议：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 对于**启用的 Git 访问协议**，选择所需的协议：
   - SSH 和 HTTP(S)。
   - 仅 SSH。
   - 仅 HTTP(S)。
1. 选择**保存更改**。

> [!warning]
> 极狐GitLab [允许 HTTP(S) 协议](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/18021)
> 用于[使用极狐GitLab CI/CD 作业令牌](../../ci/jobs/ci_job_token.md)执行的 Git 克隆或获取请求。
> 即使您选择**仅 SSH** 也会如此，因为极狐GitLab Runner 和 CI/CD 作业需要此设置。

<a id="customize-git-clone-url-for-https"></a>

## 自定义 HTTP(S) 的 Git 克隆 URL

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以自定义项目的 HTTP(S) Git 克隆 URL，这会影响项目页面上向用户显示的克隆面板。例如，如果：

- 您的极狐GitLab 实例位于 `https://example.com`，则项目克隆 URL 类似于
  `https://example.com/foo/bar.git`。
- 您希望克隆 URL 类似于 `https://git.example.com/gitlab/foo/bar.git`，
  则可以将此设置设为 `https://git.example.com/gitlab/`。

要在 `gitlab.rb`中为 HTTP(S) 指定自定义 Git 克隆 URL，请为 `gitlab_rails['gitlab_ssh_host']` 设置新值。要从极狐GitLab UI 指定新值：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 为 **自定义 HTTP(S) 的 Git 克隆 URL** 输入根 URL。
1. 选择**保存更改**。

<a id="configure-defaults-for-rsa-dsa-ecdsa-ed25519-ecdsa_sk-ed25519_sk-ssh-keys"></a>

## 配置 RSA、DSA、ECDSA、ED25519、ECDSA_SK、ED25519_SK SSH 密钥的默认值

这些选项指定 SSH 密钥的[允许类型和长度](../../security/ssh_keys_restrictions.md)。

要为每种密钥类型指定限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 转到 **RSA SSH 密钥**。
1. 对于每种密钥类型，您可以完全允许或阻止其使用，或仅允许以下长度：
   - 至少 1024 位。
   - 至少 2048 位。
   - 至少 3072 位。
   - 至少 4096 位。
   - 至少 1024 位。
1. 选择**保存更改**。

<a id="enable-project-mirroring"></a>

## 启用项目镜像

极狐GitLab 默认启用项目镜像。如果您禁用它，[拉取镜像](../../user/project/repository/mirror/pull.md)和[推送镜像](../../user/project/repository/mirror/push.md)在所有代码仓库中都将不再有效。只有管理员用户才能按项目重新启用它们。

要允许实例上的项目维护者按项目配置镜像：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库镜像**。
1. 选择**允许项目维护者配置代码仓库镜像**。
1. 选择**保存更改**。

<a id="configure-globally-allowed-ip-address-ranges"></a>

## 配置全局允许的 IP 地址范围

管理员可以将 IP 地址范围与[按群组的 IP 限制](../../user/group/access_and_permissions.md#restrict-group-access-by-ip-address)结合使用。全局允许的 IP 地址使极狐GitLab 安装的各个方面能够正常工作，即使群组设置了自己的 IP 地址限制。

例如，如果 GitLab Pages 守护进程在 `10.0.0.0/24` 范围内运行，则全局允许该范围。即使群组的 IP 地址限制不包含 `10.0.0.0/24` 范围，GitLab Pages 仍可以从流水线获取产物。

要将 IP 地址范围添加到群组的允许名单：

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 在**全局允许的 IP 范围**中，提供 IP 地址范围列表。此列表：
   - 对 IP 地址范围的数量没有限制。
   - 适用于 SSH 或 HTTP 授权的 IP 地址范围。您不能按授权类型
     拆分此列表。
1. 选择**保存更改**。

<a id="prevent-invitations-to-groups-and-projects"></a>

## 阻止向群组和项目发送邀请

管理员可以阻止非管理员邀请用户加入实例上的所有群组或项目。当您配置此设置后，只有管理员可以邀请用户加入实例上的群组或项目。

> [!note]
> [共享](../../user/project/members/sharing_projects_groups.md)或[迁移](../../user/import/_index.md)等功能仍可允许访问这些群组和项目。

先决条件：

- 您必须是管理员。

要阻止邀请：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 选中**阻止群组成员邀请**复选框。
1. 选择**保存更改**。

<a id="display-gitlab-credits-user-data"></a>

## 显示极狐GitLab Credits 用户数据

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员。

要在[极狐GitLab Credits 仪表板](../../subscriptions/gitlab_credits_dashboard.md)上开启用户数据显示：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 对于**极狐GitLab Credits 仪表板**，选中**显示用户数据**复选框。
1. 选择**保存更改**。

<a id="allow-access-to-the-mcp-server"></a>

## 允许访问 MCP 服务器

默认情况下，MCP 服务器访问处于开启状态。当您升级到极狐GitLab 19.5 时，除非管理员将其关闭，否则您的实例会开启该访问。

先决条件：

- 管理员访问权限。

要更改实例的 MCP 服务器访问权限：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 在 **MCP 客户端访问**部分，选中或清除**允许连接到极狐GitLab** 复选框。
1. 选择**保存更改**。

当您关闭此设置后，MCP API 会拒绝所有请求。
