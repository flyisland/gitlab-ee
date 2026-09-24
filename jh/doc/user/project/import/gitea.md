---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 从 Gitea 导入项目到极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.8，极狐GitLab 不再自动创建不存在的命名空间或群组。极狐GitLab 也不再使用用户的个人命名空间作为备选。
- 在路径中导入具有 `.` 项目的能力引入于极狐GitLab 16.11。
- 在一些导入的项目上的 **导入的** 徽章引入于极狐GitLab 17.2。

{{< /history >}}

从 Gitea 导入项目到极狐GitLab。

Gitea 导入工具可以导入：

- 仓库描述
- Git 仓库数据
- 议题
- 拉取请求
- 里程碑
- 标签

导入时：

- 仓库的公开访问权限保持不变。如果 Gitea 中的仓库是私有的，那么在极狐GitLab 中创建时也是私有的。
- 导入的议题、合并请求和评论在极狐GitLab 中有一个 **Imported** 徽章。

<a id="known-issues"></a>

## 已知问题

- 因为 Gitea 不是 OAuth 提供者，作者或受托人无法映射到您极狐GitLab 实例上的用户。项目创建者（通常是启动导入过程的用户）会被设为作者。对于议题，您仍然可以看到原始的 Gitea 作者。
- Gitea 导入工具不会从拉取请求中导入差异备注。

<a id="prerequisites"></a>

## 前提条件

{{< history >}}

- Requirement for Maintainer role instead of Developer role introduced in 极狐GitLab 16.0 and backported to 极狐GitLab 15.11.1 and 极狐GitLab 15.10.5.

{{< /history >}}

- Gitea 版本 1.0.0 或更高。
- 必须启用 [Gitea 导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。如果未启用，请要求您的极狐GitLab 管理员启用它。Gitea 导入源在 JihuLab.com 上默认启用。
- 在目标群组上至少拥有维护者角色才能进行导入。

<a id="import-your-gitea-repositories"></a>

## 导入您的 Gitea 仓库

当您创建一个新项目时，Gitea 导入页面是可见的。要开始 Gitea 导入：

1. 在左侧边栏顶部，选择 **创建新的** ({{< icon name="plus" >}}) 和 **新项目/仓库**。
1. 选择 **Gitea** 以开始导入授权过程。

<a id="authorize-access-to-your-repositories-using-a-personal-access-token"></a>

### 使用个人访问令牌授权访问您的仓库

使用这种方法，您可以与 Gitea 进行一次授权，以授予极狐GitLab 访问您的仓库：

1. 转到 `https://your-gitea-instance/user/settings/applications`（将 `your-gitea-instance` 替换为您的 Gitea 实例的主机）。
1. 选择 **生成新令牌**。
1. 输入令牌描述。
1. 选择 **生成令牌**。
1. 复制令牌哈希。
1. 返回极狐GitLab 并将令牌提供给 Gitea 导入工具。
1. 选择 **列出您的 Gitea 仓库**，并等待极狐GitLab 读取您的仓库信息。完成后，极狐GitLab 显示导入页面以选择要导入的仓库。

<a id="select-which-repositories-to-import"></a>

### 选择要导入的仓库

在您授权访问您的 Gitea 仓库后，您会被重定向到 Gitea 导入页面。

在这里，您可以查看您的 Gitea 仓库的导入状态：

- 正在导入的显示为 _已开始_ 状态。
- 已成功导入的显示为绿色，状态为 _已完成_。
- 尚未导入的在表格右侧有 **导入**。
- 已导入的在表格右侧有 **重新导入**。

您还可以：

- 在左上角选择 **导入所有项目** 以一次性导入所有 Gitea 项目。
- 按名称筛选项目。如果应用了筛选器，**导入所有项目** 仅导入选定的项目。
- 如果您有权限，可以为项目选择不同的名称和不同的命名空间。

<a id="user-contribution-and-membership-mapping"></a>

## 用户贡献和成员映射

{{< history >}}

- 在极狐GitLab 17.8 中，更改为[用户贡献和关系映射](_index.md#user-contribution-and-membership-mapping)。
- 在极狐GitLab 17.8 中，为 JihuLab.com 和极狐GitLab 私有化部署启用。

{{< /history >}}

Gitea 导入工具使用了一种 [改进的方法](_index.md#user-contribution-and-membership-mapping) 来映射 JihuLab.com 和极狐GitLab 私有化部署的用户贡献。

<a id="old-method-of-user-contribution-mapping"></a>

### 用户贡献映射的旧方法

您可以使用旧的用户贡献映射方法将数据导入到极狐GitLab 私有化部署和极狐GitLab Dedicated 实例。要使用此方法，必须禁用 `importer_user_mapping` 和 `gitea_user_mapping`。对于导入到 JihuLab.com，您必须使用 [改进的方法](_index.md#user-contribution-and-membership-mapping)。

使用旧的方法，用户贡献默认分配给项目创建者（通常是启动导入过程的用户）。
