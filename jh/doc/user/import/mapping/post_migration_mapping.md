---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 迁移后的贡献和成员映射
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中为直接迁移引入，带有名为 `importer_user_mapping` 和 `bulk_import_importer_user_mapping` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 17.6 中为 Gitea 引入，带有名为 `importer_user_mapping` 和 `gitea_user_mapping` 的[功能标志](../../../administration/feature_flags/_index.md)，并为 GitHub 引入，带有名为 `importer_user_mapping` 和 `github_user_mapping` 的功能标志。默认禁用。
- 在极狐GitLab 17.7 中为 Bitbucket Server 引入，带有名为 `importer_user_mapping` 和 `bitbucket_server_user_mapping` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 17.7 中为直接迁移已在 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 17.7 中，已在 JihuLab.com 上为 Bitbucket Server、Gitea 和 GitHub 启用。
- 在极狐GitLab 17.8 中，已在私有化部署上为 Bitbucket Server、Gitea 和 GitHub 启用。
- 在导入到个人命名空间时，将贡献重新分配给个人命名空间所有者，在极狐GitLab 18.3 中引入，带有名为 `user_mapping_to_personal_namespace_owner` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 18.4 中为直接迁移 GA。功能标志 `bulk_import_importer_user_mapping` 已移除。
- 将贡献重新分配给服务账号、项目机器人和群组机器人在极狐GitLab 18.5 中引入，带有名为 `user_mapping_service_account_and_bots` 的[功能标志](../../../administration/feature_flags/_index.md)。默认启用。
- 在极狐GitLab 18.6 中为 Gitea GA。功能标志 `gitea_user_mapping` 已移除。
- 在导入到个人命名空间时，将贡献重新分配给个人命名空间所有者，在极狐GitLab 18.6 中 GA。功能标志 `user_mapping_to_personal_namespace_owner` 已移除。
- `github_user_mapping` 功能标志在极狐GitLab 18.8 中移除。
- `user_mapping_service_account_and_bots` 功能标志在极狐GitLab 18.10 中移除。

{{< /history >}}

使用迁移后映射，来自源实例的用户贡献和成员关系最初会分配给占位用户，而不是目标实例上的真实用户。

由于您可以推迟分配给真实用户，您有时间审查导入并将贡献重新分配给正确的用户。此过程确保准确的归属，同时保持对映射过程的控制。

默认情况下，迁移后用户贡献和成员映射适用于从以下来源的迁移：
- [极狐GitLab（使用直接迁移时）](../../group/import/_index.md)
- [GitHub](../../project/import/github.md)
- [Bitbucket Server](../bitbucket_server.md)
- [Gitea](../gitea.md)

当您将项目导入到个人命名空间时，不支持用户贡献映射和成员映射，所有贡献都分配给个人命名空间所有者。这些贡献无法重新分配。

<a id="prerequisites"></a>

## 先决条件

- 根据[用户限制](#placeholder-user-limits)规划用户数量。
- 如果您导入到 JihuLab.com，请设置您的付费命名空间。
- 如果您导入到 JihuLab.com 并使用 JihuLab.com 群组的 SAML SSO，请确保所有用户将他们的 SAML 身份链接到他们的 JihuLab.com 账户。

<a id="post-migration-mapping-workflow"></a>

## 迁移后映射工作流

使用迁移后映射时，极狐GitLab 会将您导入的任何成员关系和贡献映射到占位用户。占位用户会在目标实例上创建，即使目标实例上存在具有相同电子邮件地址的用户。在您在目标实例上重新分配贡献之前，所有贡献都与占位用户关联。

导入完成并审查结果后，您可以按以下方式更新映射：
- 将成员关系和贡献重新分配给目标实例上的现有用户。您可以为源实例和目标实例上具有不同电子邮件地址的用户映射成员关系和贡献。
- 在目标实例上创建新用户，并将成员关系和贡献重新分配给他们。

您还可以保留某些分配给占位用户的贡献以保留历史上下文。

当您将贡献重新分配给目标实例上的用户时，该用户可以：
- 接受重新分配。重新分配过程可能需要几分钟。在随后的从同一源实例到目标实例上的同一顶级群组或子群组的导入中，贡献会自动映射给该用户。
- 拒绝重新分配。

<a id="enterprise-users"></a>

## 企业用户

{{< history >}}

- 在极狐GitLab 18.0 中引入。

{{< /history >}}

如果您的顶级群组至少有一个[企业用户](../../enterprise_user/_index.md)，您只能将贡献重新分配给组织中的企业用户。这意味着您无法意外地将贡献重新分配给组织外的用户。

<a id="deleted-users"></a>

## 已删除的用户

源实例上由现已删除的用户所做的贡献会在目标实例上映射给[幽灵用户](../../../administration/internal_users.md)，除了以下情况：
- 贡献在源实例上从未正确地从已删除用户分离。
- 从 Bitbucket Server 迁移。

<a id="placeholder-users"></a>

## 占位用户

使用贡献和成员映射，您不会立即将贡献和成员关系分配给目标实例上的用户。相反，对于具有导入贡献或成员关系的任何活跃、非活跃或机器人用户，都会创建一个占位用户。贡献和成员关系最初都分配给这些占位用户，并且可以在导入后重新分配给目标实例上的现有用户。在重新分配之前，贡献与占位用户关联。占位成员关系不显示在成员列表中。占位用户不计入许可证限制。

<a id="exceptions"></a>

### 例外情况

在以下情况下不会创建占位用户：
- 您从 Gitea 导入项目，并且涉及已删除用户的贡献。这些用户的贡献映射到导入项目的用户。
- 您已超过[占位用户限制](#placeholder-user-limits)。任何新用户的贡献映射到一个导入用户。

<a id="placeholder-user-attributes"></a>

### 占位用户属性

占位用户与普通用户不同，不能：
- 登录。
- 执行任何操作。例如，运行流水线。
- 在议题和合并请求的建议中作为指派人或审核者出现。
- 成为项目和群组的成员。

为了保持与源实例上用户的连接，占位用户具有：
- 导入过程用于确定是否需要新占位用户的唯一标识符（`source_user_id`）。
- 源主机名或域（`source_hostname`）。
- 源用户的名称（`source_name`）以帮助重新分配贡献。
- 源用户的用户名（`source_username`）以方便群组所有者在重新分配贡献时使用。
- 导入类型（`import_type`）以区分哪个导入器创建了占位用户。
- 源用户创建时的本地时间戳（`created_at`）用于迁移跟踪（在极狐GitLab 17.10 中引入）。

为了保留历史上下文，占位用户的名称和用户名源自源用户的名称和用户名：
- 占位用户的名称是 `Placeholder <源用户名称>`。
- 占位用户的用户名是 `%{source_username}_placeholder_user_%{incremental_number}`。

<a id="view-placeholder-users"></a>

### 查看占位用户

**先决条件：**

- 您必须具有群组的所有者角色。

占位用户在导入群组或项目时在目标实例上创建。
要查看在导入到顶级群组及其子群组期间创建的占位用户：
1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。此群组必须是顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位** 选项卡。

<a id="filter-for-placeholder-users"></a>

### 筛选占位用户

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

**先决条件：**

- 您必须具有实例的管理员访问权限。

占位用户在导入群组或项目时在目标实例上创建。
要为整个实例筛选导入期间创建的占位用户：
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 在搜索框中，按 **类型** 筛选用户。

<a id="creating-placeholder-users"></a>

### 创建占位用户

占位用户是按导入源和每个顶级群组创建的：
- 如果您将同一个项目导入到目标实例的同一个顶级群组两次，第二次导入将使用与第一次导入相同的占位用户。
- 如果您将同一个项目导入两次，但导入到目标实例的不同顶级群组，第二次导入将在该顶级群组下创建新的占位用户。

> [!note]
> 占位用户仅与顶级群组关联。
> 当您删除子群组或项目时，它们的占位用户不再引用顶级群组中的任何贡献。
> 为了测试，您应该使用指定的顶级群组。

当用户[接受重新分配](reassignment.md#accept-contribution-reassignment)时，后续从同一源实例到目标实例上同一顶级群组或子群组的导入不会创建占位用户。相反，贡献会自动映射给该用户。

<a id="placeholder-user-deletion"></a>

### 占位用户删除

{{< history >}}

- 在极狐GitLab 18.0 中引入。

{{< /history >}}

当您删除包含占位用户的顶级群组时，这些用户会自动被安排移除。此过程可能需要一些时间才能完成。但是，如果占位用户还与其他项目或群组关联，它们会保留在系统中。

<a id="placeholder-user-limits"></a>

### 占位用户限制

如果导入到 JihuLab.com，目标实例上的每个顶级群组对占位用户有限制。限制因您的计划和席位数量而异。占位用户不计入许可证限制。

| JihuLab.com 计划          | 席位数量 | 顶级群组占位用户限制 |
|:-------------------------|:----------------|:------------------------------------------|
| 基础版和任何试用版       | 任意数量      | 200                                       |
| 专业版                  | < 100           | 500                                       |
| 专业版                  | 101-500         | 2000                                      |
| 专业版                  | 501 - 1000      | 4000                                      |
| 专业版                  | > 1000          | 6000                                      |
| 旗舰版和开源版 | < 100           | 1000                                      |
| 旗舰版和开源版 | 101-500         | 4000                                      |
| 旗舰版和开源版 | 501 - 1000      | 6000                                      |
| 旗舰版和开源版 | > 1000          | 8000                                      |

对于私有化部署，默认不适用占位用户限制。极狐GitLab 管理员可以[在其设置实例的占位用户限制](../../../administration/instance_limits.md#import-placeholder-user-limits)。

要查看您当前的占位用户用量和限制：
1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。此群组必须是顶级群组。
1. 选择 **设置** > **用量配额**。
1. 选择 **导入** 选项卡。

您无法提前确定所需的占位用户数量。

当达到占位用户限制时，所有贡献都会分配给一个名为 `Import User` 的非功能性用户。分配给 `Import User` 的贡献可能会被去重，某些贡献在导入期间可能不会被创建。例如，如果合并请求审批者的多个审批分配给 `Import User`，则只会创建第一个审批，其他审批将被忽略。可能被去重的贡献包括：
- 审批规则
- 表情回应
- 议题指派人
- 成员关系
- 合并请求审批者、指派人及审核者
- 推送、合并请求和部署访问级别

每次更改都会创建一条系统笔记，这不受占位用户限制的影响。

<a id="alternative-mapping-method"></a>

## 替代映射方法

迁移后映射的一种替代方案是在迁移期间进行映射的方法。不推荐使用此方法，发现的问题不太可能得到修复。

替代映射方法：
- 仅适用于迁移到私有化部署的情况。
- 在迁移前需要一些准备工作，包括禁用适用的 `*_user_mapping` 功能标志。
- 适用于从以下来源的迁移：
  - GitHub。
  - Bitbucket Server。
  - Gitea（适用于极狐GitLab 18.5 及更早版本）。

有关更多信息，请参阅每个导入器的替代映射方法文档。