---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 导入和迁移群组和项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

将您现有的工作带入极狐GitLab 并保留您的贡献历史。整合来自多个平台的项目或在极狐GitLab 实例之间传输数据。

极狐GitLab 提供不同的方法来：

- 使用直接传输迁移极狐GitLab 群组和项目。
- 从各种支持的来源导入项目。

<a id="migrate-from-gitlab-to-gitlab-by-using-direct-transfer"></a>

## 从极狐GitLab 迁移到极狐GitLab，使用直接传输

复制极狐GitLab 实例之间或同一极狐GitLab 实例中的群组和项目的最佳方式是[使用直接传输](../../group/import/_index.md)。

另一种选择是使用[群组传输](../../group/manage.md#transfer-a-group)移动极狐GitLab 群组。

您还可以使用极狐GitLab 文件导出复制极狐GitLab 项目，这是一个支持的导入来源。

<a id="supported-import-sources"></a>

## 支持的导入来源

{{< history >}}

- 所有导入器默认对极狐GitLab 私有化部署实例禁用。此更改在极狐GitLab 16.0 中引入。

{{< /history >}}

默认情况下可供您使用的导入来源取决于您使用的极狐GitLab：

- JihuLab.com：所有可用的导入来源均[默认启用](../../jihulab_com/_index.md#default-import-sources)。
- 极狐GitLab 私有化部署：没有导入来源默认启用，必须[启用](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。

极狐GitLab 可以从这些支持的导入来源导入项目。

| 导入来源                                     | 描述 |
|:--------------------------------------------|:-----|
| [Bitbucket Cloud](bitbucket.md)             | 使用 [Bitbucket.org 作为 OmniAuth 提供者](../../../integration/bitbucket.md)，导入 Bitbucket 仓库。 |
| [Bitbucket Server](bitbucket_server.md)     | 从 Bitbucket Server（也称为 Stash）导入仓库。 |
| [FogBugz](fogbugz.md)                       | 导入 FogBugz 项目。 |
| [Gitea](gitea.md)                           | 导入 Gitea 项目。 |
| [GitHub](github.md)                         | 从 GitHub.com 或 GitHub Enterprise 导入。 |
| [极狐GitLab 导出](../settings/import_export.md) | 使用极狐GitLab 导出文件一个一个地迁移项目。 |
| [Manifest 文件](manifest.md)                | 上传 Manifest 文件。 |
| [通过 URL 的仓库](repo_by_url.md)          | 提供一个 Git 仓库 URL 创建一个新项目。 |

开始迁移后，不应对源实例上的导入群组或项目进行任何更改，因为这些更改可能不会复制到目标实例。

<a id="disable-unused-import-sources"></a>

### 禁用未使用的导入来源

只从您信任的来源导入项目。如果您从不信任的来源导入项目，攻击者可能会窃取您的敏感数据。例如，带有恶意 `.gitlab-ci.yml` 文件的导入项目可能允许攻击者窃取群组 CI/CD 变量。

极狐GitLab 私有化部署管理员可以通过禁用他们不需要的导入来源来减少攻击面：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 常规**。
1. 展开 **导入和导出设置**。
1. 滚动到 **导入来源**。
1. 清除不需要的导入器的复选框。

<a id="other-import-sources"></a>

## 其他导入来源

您还可以阅读有关从以下其他导入来源进行导入的信息：

- [ClearCase](clearcase.md)
- [并发版本系统 (CVS)](cvs.md)
- [Jira （仅议题）](jira.md)
- [Perforce Helix](perforce.md)
- [团队基金会版本控制 (TFVC)](tfvc.md)

<a id="import-repositories-from-subversion"></a>

### 从 Subversion 导入仓库

极狐GitLab 无法自动迁移 Subversion 仓库到 Git。将 Subversion 仓库转换为 Git 可能很困难，但有几个工具可用，包括：

- `git svn`，适用于非常小和基本的仓库。
- `reposurgeon`，适用于较大和更复杂的仓库。

<a id="user-contribution-and-membership-mapping"></a>

## 用户贡献和成员映射

{{< details >}}

- Offering: JihuLab.com, 私有化部署

{{< /details >}}

{{< history >}}

- 直接转移功能引入于极狐GitLab 17.4，使用名为 `importer_user_mapping` 和 `bulk_import_importer_user_mapping` 的[功能标志](../../../administration/feature_flags.md)。默认禁用。
- 在极狐GitLab 17.5 中引入对于 Gitea 的，使用名为 `importer_user_mapping` 和 `gitea_user_mapping` 的[功能标志](../../../administration/feature_flags.md)。默认禁用；对于 GitHub，使用名为 `importer_user_mapping` 和 `github_user_mapping` 的[功能标志](../../../administration/feature_flags.md)。默认禁用。
- 在极狐GitLab 17.7 中引入对于 Bitbucket Server 的支持，使用名为 `importer_user_mapping` 和 `bitbucket_server_user_mapping` 的[功能标志](../../../administration/feature_flags.md)。默认禁用。
- 在极狐GitLab 17.7 中，直接传输功能在 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 17.7 中，在 JihuLab.com 上启用 Bitbucket Server、Gitea 和 GitHub 导入器。
- 在极狐GitLab 17.8 中，在极狐GitLab 私有化部署上启用 Bitbucket Server、Gitea 和 GitHub 导入器。

{{< /history >}}

{{< alert type="flag" >}}

此功能的可用性由功能标志控制。有关更多信息，请查看历史记录。

{{< /alert >}}

此用户贡献和成员映射方法默认可用于[直接传输](../../group/import/_index.md)、[GitHub 导入器](github.md)、[Bitbucket Server 导入器](bitbucket_server.md)和[ Gitea 导入器](gitea.md)在 JihuLab.com 和极狐GitLab 私有化部署上。有关极狐GitLab 私有化部署的其他可用方法的信息，请参阅每个导入器的文档。

您导入的任何成员和贡献首先映射到[占位符用户](#placeholder-users)。即使源实例上存在具有相同电子邮件地址的用户，这些占位符也会在目标实例上创建。在您重新分配目标实例上的贡献之前，所有贡献都显示为与占位符相关联。有关后续导入到同一顶级群组的行为，请参阅[占位符用户限制](#placeholder-user-limits)。

{{< alert type="note" >}}

幽灵用户贡献处理方式不同。源实例上由幽灵用户（已删除用户）先前进行的贡献将自动映射到目标实例上的幽灵用户，而无需创建占位符用户。

{{< /alert >}}

导入完成后，您可以：

- 在审核结果后，将成员和贡献重新分配给目标实例上的现有用户。您可以为源和目标实例上具有不同电子邮件地址的用户映射成员和贡献。
- 在目标实例上创建新用户以重新分配成员和贡献。

当您将贡献重新分配给目标实例上的用户时，该用户可以[接受](#accept-contribution-reassignment)或[拒绝](#reject-contribution-reassignment)重新分配。

{{< alert type="note" >}}

在导入项目到[个人命名空间](../../namespace/_index.md#types-of-namespaces)时，不支持用户贡献映射。当您导入到个人命名空间时，所有贡献都分配给一个名为 `Import User` 的单一非功能性用户，并且无法重新分配。[议题 525342](https://jihulab.com/gitlab-cn/gitlab/-/issues/525342)提议将所有贡献映射到导入用户。

{{< /alert >}}

<a id="requirements"></a>

### 要求

- 您必须能够创建足够的用户，受[用户限制](#placeholder-user-limits)的约束。
- 如果您导入到 JihuLab.com，必须在导入前设置付费命名空间。
- 如果您导入到 JihuLab.com 并使用[极狐GitLab.com 群组的 SAML SSO](../../group/saml_sso/_index.md)，所有用户必须将他们的 SAML 身份链接到他们的 JihuLab.com 账户，您才能[重新分配贡献和成员](#reassign-contributions-and-memberships)。

<a id="placeholder-users"></a>

### 占位符用户

在目标实例上，贡献和成员不会立即分配给用户，而是为任何活跃、非活跃或机器人用户创建一个占位符用户，这些用户具有导入的贡献或成员。对于源实例上的已删除用户，创建占位符时不具备所有[占位符用户属性](#placeholder-user-attributes)。您应该[将这些用户保留为占位符](#keep-as-placeholder)。有关更多信息，请参阅[议题 506432](https://jihulab.com/gitlab-cn/gitlab/-/issues/506432)。

贡献和成员首先分配给这些占位符用户，可以在导入后重新分配给目标实例上的现有用户。在重新分配之前，贡献显示为与占位符相关联。占位符成员不会显示在成员列表中。

占位符用户不计入许可证限制。

<a id="exceptions"></a>

#### 例外情况

为源实例上的每个用户创建占位符用户，除以下情况外：

- 您正在从 [Gitea](gitea.md) 导入项目，并且用户在导入前在 Gitea 上被删除。来自这些“幽灵用户”的贡献映射到导入项目的用户，而不是占位符用户。
- 您已超过[占位符用户限制](#placeholder-user-limits)。超过限制后任何新用户的贡献映射到一个名为 `Import User` 的单一非功能性用户。
- 您正在导入到[个人命名空间](../../namespace/_index.md#types-of-namespaces)。贡献分配给一个名为 `Import User` 的单一非功能性用户。

<a id="placeholder-user-attributes"></a>

#### 占位符用户属性

占位符用户不同于常规用户，无法：

- 登录。
- 执行任何操作。例如，运行流水线。
- 在议题和合并请求中显示为指派人或审阅者的建议。
- 成为项目和群组的成员。

为了保持与源实例用户的连接，占位符用户具有：

- 用于导入过程的唯一标识符 (`source_user_id`) ，用于确定是否需要新的占位符用户。
- 源主机名或域名 (`source_hostname`)。
- 源用户的姓名 (`source_name`) ，以帮助重新分配贡献。
- 源用户的用户名 (`source_username`) ，以便在重新分配贡献时帮助群组所有者。
- 导入类型 (`import_type`) ，以区分哪个导入器创建了占位符。
- 源用户在本地时间创建的时间戳 (`created_at`) ，用于迁移跟踪（在极狐GitLab 17.10 中引入）。

为了保留历史上下文，占位符用户名和用户名派生自源用户名和用户名：

- 占位符用户的姓名是 `Placeholder <source user name>`。
- 占位符用户的用户名是 `%{source_username}_placeholder_user_%{incremental_number}`。

<a id="view-placeholder-users"></a>

#### 查看占位符用户

前提条件：

- 您必须具有群组的所有者角色。

导入群组或项目期间，会在目标实例上创建占位符用户。要查看在导入到顶级群组及其子群组期间创建的占位符用户：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。

<a id="placeholder-user-limits"></a>

#### 占位符用户限制

占位符用户是根据[导入来源](#supported-import-sources)和顶级群组创建的：

- 如果您两次将同一项目导入到目标实例上的同一顶级群组，第二次导入使用与第一次导入相同的占位符用户。
- 如果您两次导入同一项目，但导入到目标实例上的不同顶级群组，第二次导入会在该顶级群组下创建新的占位符用户。

如果导入到 JihuLab.com，占位符用户在目标实例上的顶级群组中受到限制。限制因您的计划和座位数而异。占位符用户不计入许可证限制。

| JihuLab.com 计划        | 座位数量 | 顶级群组上的占位符用户限制 |
|:-----------------------|:--------|:------------------------|
| 基础版和任何试用       | 任意数量 | 200                     |
| 专业版                | < 100   | 500                     |
| 专业版                | 101-500 | 2000                    |
| 专业版                | 501-1000| 4000                    |
| 专业版                | > 1000  | 6000                    |
| 旗舰版和开源          | < 100   | 1000                    |
| 旗舰版和开源          | 101-500 | 4000                    |
| 旗舰版和开源          | 501-1000| 6000                    |
| 旗舰版和开源          | > 1000  | 8000                    |

遗留 Bronze、Silver 或 Gold 计划的客户具有相应的基础版、专业版或旗舰版限制。对于尝试旗舰版的专业版客户（旗舰版试用付费客户计划），适用专业版限制。如果这些限制不足以满足您的导入需求，[联系极狐GitLab 支持](https://gitlab.cn/support/)。

对于极狐GitLab 私有化部署和极狐GitLab Dedicated，默认情况下不适用占位符限制。极狐GitLab 管理员可以在其实例上[设置占位符限制](../../../administration/instance_limits.md#import-placeholder-user-limits)。

要查看您当前的占位符用户使用情况和限制：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **设置 > 使用配额**。
1. 选择 **导入** 选项卡。

对于导入到 JihuLab.com 的情况，某些贡献可能无法创建，因为这些贡献映射到同一个用户。例如，如果多个合并请求批准者映射到同一个用户，则只有第一个批准会被添加，其他的则会被忽略。这些贡献包括：

- 成员
- 合并请求审批、指派和审阅者
- 议题指派
- 表情符号
- 推送、合并请求和部署访问级别
- 审批规则

您无法提前确定所需的占位符用户数量。当达到占位符用户限制时，导入不会失败。相反，所有贡献都分配给一个名为 `Import User` 的单一非功能性用户。

每次更改都会创建一个系统注释，受占位符用户限制影响。

<a id="reassign-contributions-and-memberships"></a>

### 重新分配贡献和成员

顶级群组的所有者角色用户可以将贡献和成员从占位符用户重新分配给现有的活跃（非机器人）用户。在目标实例上，顶级群组的所有者角色用户可以：

- 请求用户在[界面中](#request-reassignment-in-ui)或[通过 CSV 文件](#request-reassignment-by-using-a-csv-file)审阅贡献和成员的重新分配。对于大量占位符用户，您应该使用 CSV 文件。在这两种情况下，用户会通过电子邮件收到请求以接受或拒绝重新分配。重新分配仅在选定的用户[接受重新分配请求](#accept-contribution-reassignment)后开始。
- 选择不重新分配贡献和成员，[保留他们分配给占位符用户](#keep-as-placeholder)。

最初分配给单个占位符用户的所有贡献只能重新分配给目标实例上的单个活跃常规用户。分配给单个占位符用户的贡献不能在多个活跃常规用户之间拆分。如果分配的用户在接受重新分配请求之前变得不活跃，则待处理的重新分配仍链接到用户，直到他们接受。

源实例上的机器人用户贡献和成员不能重新分配给目标实例上的机器人用户。您可以选择将源机器人用户贡献[分配给占位符用户](#keep-as-placeholder)。

收到重新分配请求的用户可以：

- [接受请求](#accept-contribution-reassignment)。所有之前归属占位符用户的贡献和成员重新归属到接受者。这一过程可能需要几分钟，具体取决于贡献数量。
- [拒绝请求](#reject-contribution-reassignment)或报告为垃圾邮件。此选项在重新分配请求电子邮件中可用。

在同一顶级群组的后续导入中，属于同一源用户的贡献和成员会自动映射到之前接受源用户重新分配的用户。

<a id="completing-the-reassignment"></a>

#### 完成重新分配

重新分配过程必须在您：

- [在同一极狐GitLab 实例中移动导入群组](../../group/manage.md#transfer-a-group)之前完全完成。
- [将导入项目移动到不同群组](../settings/migrate_projects.md)之前完全完成。
- 复制导入议题之前。
- 提升导入议题为史诗之前。

如果过程未完成，仍分配给占位符用户的贡献不能重新分配给真实用户，并且它们保持与占位符用户关联。

<a id="security-considerations"></a>

#### 安全考虑

贡献和成员重新分配不能撤销，因此在开始之前仔细检查一切。

将贡献和成员重新分配给错误的用户构成安全威胁，因为用户成为您群组的成员。因此，他们可以查看不应该看到的信息。

默认情况下禁用将贡献重新分配给具有管理员访问权限的用户，但您可以[启用](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)它。

<a id="membership-security-considerations"></a>

##### 成员安全考虑

由于极狐GitLab 的权限模型，当群组或项目导入到现有父群组时，父群组的成员获得导入群组或项目的[继承成员](../members/_index.md#membership-types)。

选择已经拥有导入群组或项目的现有继承成员的用户进行贡献和成员重新分配可能会影响成员如何重新分配给他们。

极狐GitLab 不允许子项目或群组中的成员资格低于继承成员资格。如果分配用户的导入成员资格低于他们现有的继承成员资格，则导入成员资格不会重新分配给用户。

这导致他们在源实例上的成员资格比在目标实例上的更高。

<a id="request-reassignment-in-ui"></a>

#### 在界面中请求重新分配

前提条件：

- 您必须具有群组的所有者角色。

您可以在顶级群组中重新分配贡献和成员。请求重新分配贡献和成员：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符列表在一个表中。
1. 对每个占位符，审查表列中的 **占位符用户** 和 **来源** 信息。
1. 在 **重新分配占位符到** 列中，从下拉列表中选择一个用户。
1. 选择 **重新分配**。

只有一个占位符用户的贡献可以重新分配给目标实例上的活跃非机器人用户。

在用户接受重新分配之前，您可以[取消请求](#cancel-reassignment-request)。

<a id="request-reassignment-by-using-a-csv-file"></a>

#### 使用 CSV 文件请求重新分配

{{< history >}}

- 在极狐GitLab 17.10 中引入，使用名为 `importer_user_mapping_reassignment_csv` 的[功能标志](../../../administration/feature_flags.md)。默认启用。

{{< /history >}}

{{< alert type="flag" >}}

此功能的可用性由功能标志控制。有关更多信息，请查看历史记录。

{{< /alert >}}

前提条件：

- 您必须具有群组的所有者角色。

对于大量占位符用户，您可能希望使用 CSV 文件重新分配贡献和成员。您可以下载一个预填充的 CSV 模板，其中包含以下信息。例如：

| 来源主机          | 导入类型 | 来源用户标识符 | 来源用户名 | 来源用户名 |
|-------------------|----------|----------------|------------|------------|
| `gitlab.example.com` | `gitlab` | `alice`        | `Alice Coder` | `a.coer`   |

不要更新 **来源主机**、**导入类型** 或 **来源用户标识符**。此信息在上传完成的 CSV 文件后定位相应的数据库记录。**来源用户名** 和 **来源用户名** 标识源用户，在上传 CSV 文件后不使用。

您不必更新 CSV 文件的每一行。只有带有 **极狐GitLab 用户名** 或 **极狐GitLab 公共电子邮件** 的行会被处理。其他行会被跳过。

要使用 CSV 文件请求重新分配贡献和成员：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 选择 **使用 CSV 重新分配**。
1. 下载预填充的 CSV 模板。
1. 在 **极狐GitLab 用户名** 或 **极狐GitLab 公共电子邮件** 中，输入目标实例上的极狐GitLab 用户的用户名或公共电子邮件地址。实例管理员可以重新分配任何已确认电子邮件地址的用户。
1. 上传完成的 CSV 文件。
1. 选择 **重新分配**。

您只能将贡献从单个占位符用户分配给目标实例上的每个活跃非机器人用户。用户会收到电子邮件以审阅您重新分配给他们的任何贡献。[在用户审阅之前您可以取消重新分配请求](#cancel-reassignment-request)。

重新分配贡献后，极狐GitLab 会向您发送电子邮件，内容包括：

- 成功处理的行数
- 未成功处理的行数
- 跳过的行数

如果任何行未成功处理，电子邮件将包含一个 CSV 文件，其中有更详细的结果。

要批量重新分配占位符用户而不使用界面，请参阅[群组占位符重新分配 API](../../../api/group_placeholder_reassignments.md)。

<a id="keep-as-placeholder"></a>

#### 保留为占位符

您可能不希望将贡献和成员重新分配给目标实例上的用户。例如，您可能有在源实例上贡献的前员工，但他们在目标实例上不存在为用户。

在这些情况下，您可以将贡献保留为分配给占位符用户。占位符用户不会保留成员信息，因为他们[不能成为项目或群组的成员](#placeholder-user-attributes)。

因为占位符用户的姓名和用户名类似于源用户的姓名和用户名，您保留了大量历史上下文。

请记住，如果您将剩余的占位符用户保留为占位符，您不能稍后将他们的贡献重新分配给实际用户。确保在保留剩余的占位符用户为占位符之前完成所有必需的重新分配。

您可以一次保留一个占位符用户的贡献，也可以批量保留。

当批量应用时，它会影响整个命名空间，并且只有在**等待重新分配**选项卡中的以下**重新分配状态**值的用户：

- `未开始`
- `已拒绝`

要一次保留一个占位符用户：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符列表在一个表中。
1. 通过审阅 **占位符用户** 和 **来源** 列查找您要保留的占位符用户。
1. 在 **重新分配占位符到** 列中，选择 **不重新分配**。
1. 选择 **确认**。

要批量保留占位符用户：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 在列表上方，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **保留所有为占位符**。
1. 在确认对话框中，选择 **确认**。

<a id="cancel-reassignment-request"></a>

#### 取消重新分配请求

在用户接受重新分配请求之前，您可以取消请求：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符列表在一个表中。
1. 在正确的行中选择 **取消**。

<a id="notify-user-again-about-pending-reassignment-requests"></a>

#### 再次通知用户关于待处理的重新分配请求

如果用户没有对重新分配请求采取行动，您可以通过发送另一封电子邮件再次提示他们：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符列表在一个表中。
1. 在正确的行中选择 **通知**。

<a id="view-and-filter-and-sort-by-reassignment-status"></a>

#### 查看和筛选并按重新分配状态排序

您可以查看重新分配过程尚未完成的所有占位符用户的状态：

1. 在左侧边栏，选择 **搜索或转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **管理 > 成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符列表在一个表中。
1. 在 **重新分配状态** 列中查看每个占位符用户的状态。

您可以按重新分配状态进行筛选：

1. 在筛选器下拉列表中，选择 **状态**。
1. 选择一个可用的状态。

在 **等待重新分配** 选项卡中可能的状态是：

- `未开始` - 重新分配尚未开始。
- `待批准` - 重新分配等待用户批准。
- `重新分配中` - 重新分配正在进行中。
- `已拒绝` - 重新分配被用户拒绝。
- `失败` - 重新分配失败。

在 **已重新分配** 选项卡中可能的状态是：

- `成功` - 重新分配成功。
- `保留为占位符` - 占位符用户被永久化。

默认情况下，表格按占位符用户名字母顺序排序。您还可以按重新分配状态对表格进行排序：

1. 在排序下拉列表中选择。
1. 选择 **重新分配状态**。

<a id="accept-contribution-reassignment"></a>

### 接受贡献重新分配

您可能会收到一封电子邮件，通知您进行了导入过程，并要求您确认将贡献重新分配给自己。

如果您收到有关此导入过程的通知，您仍必须非常仔细地审查重新分配细节。电子邮件中列出的详细信息包括：

- **导入自** - 导入内容的来源平台。例如，另一个极狐GitLab 实例、GitHub 或 Bitbucket。
- **原始用户** - 源平台上的用户姓名和用户名。这可能是您在该平台上的姓名和用户名。
- **导入到** - 新平台的名称，这只能是一个极狐GitLab 实例。
- **重新分配给** - 您在极狐GitLab 实例上的全名和用户名。
- **重新分配者** - 执行导入的同事或经理的全名和用户名。

<a id="reject-contribution-reassignment"></a>

#### 拒绝贡献重新分配

如果您收到电子邮件，要求您确认将贡献重新分配给自己，并且您不认识或注意到此信息有误：

1. 不要进行任何操作或拒绝贡献重新分配。
1. 与值得信赖的同事或经理交谈。

<a id="security-considerations"></a>

#### 安全考虑

您必须非常仔细地审查任何重新分配请求的重新分配详情。如果您没有收到值得信赖的同事或经理的通知，请格外小心。

而不是接受任何您有疑虑的重新分配：

1. 不要对电子邮件采取行动。
1. 与值得信赖的同事或经理交谈。

仅接受您认识和信任的用户的重新分配。贡献重新分配是永久性的，不能撤销。接受重新分配可能导致贡献错误地归属到您。

只有在您在极狐GitLab 中选择**批准重新分配**后，贡献重新分配过程才会启动。选择电子邮件中的链接不会启动该过程。

<a id="view-project-import-history"></a>

## 查看项目导入历史

您可以查看由您创建的所有项目导入。此列表包括以下内容：

- 如果项目从外部系统导入，则为源项目的路径，或如果项目被迁移，则为导入方法。
- 目标项目的路径。
- 每次导入的开始日期。
- 每次导入的状态。
- 如果发生任何错误，错误详情。

要查看项目导入历史：

1. 登录极狐GitLab。
1. 在左侧边栏顶部，选择 **创建新** ({{< icon name="plus" >}}) 和 **新项目/仓库**。
1. 选择 **导入项目**。
1. 在右上角，选择 **历史记录** 链接。
1. 如果特定导入有任何错误，请选择 **详细信息** 查看它们。

历史记录还包括从[内置模板](../_index.md#create-a-project-from-a-built-in-template)或[自定义模板](../_index.md#create-a-project-from-a-custom-template)创建的项目。极狐GitLab 使用[通过 URL 导入仓库](repo_by_url.md)从模板创建新项目。

<a id="importing-projects-with-lfs-objects"></a>

## 导入含有 LFS 对象的项目

当导入包含 LFS 对象的项目时，如果项目有一个 `.lfsconfig` 文件，且其中的 URL 主机 (`lfs.url`) 与仓库 URL 主机不同，则 LFS 文件不会被下载。

<a id="migrate-by-engaging-professional-services"></a>

## 通过专业服务进行迁移

如果您愿意，您可以通过极狐GitLab 专业服务迁移群组和项目到极狐GitLab，而不是自己进行。

<a id="sidekiq-configuration"></a>

## Sidekiq 配置

导入器高度依赖 Sidekiq 任务来处理群组和项目的导入和导出。这些任务中的一些可能消耗大量资源（CPU 和内存），并且需要很长时间才能完成，这可能会影响其他任务的执行。要解决此问题，您应该将导入器任务路由到专用 Sidekiq 队列，并分配专用 Sidekiq 进程来处理该队列。

例如，您可以使用以下配置：

```conf
sidekiq['concurrency'] = 20

sidekiq['routing_rules'] = [
  # 将导入和导出任务路由到导入器队列
  ['feature_category=importers', 'importers'],

  # 使用通配符匹配将所有其他任务路由到默认队列
  ['*', 'default']
]

sidekiq['queue_groups'] = [
  # 为导入器队列运行专用进程
  'importers',

  # 为默认和邮件队列运行单独的进程
  'default,mailers'
]
```

在此设置中：

- 专用 Sidekiq 进程通过导入器队列处理导入和导出任务。
- 另一个 Sidekiq 进程处理所有其他任务（默认和邮件队列）。
- 默认情况下，两个 Sidekiq 进程配置为运行 20 个并发线程。对于内存受限的环境，您可能希望减少此数量。

如果您的实例有足够的资源支持更多并发任务，您可以配置额外的 Sidekiq 进程以加快迁移速度。例如：

```conf
sidekiq['queue_groups'] = [
  # 为导入器任务运行三个进程
  'importers',
  'importers',
  'importers',

  # 为默认和邮件队列运行单独的进程
  'default,mailers'
]
```

通过此设置，多个 Sidekiq 进程可以并发地处理导入和导出任务，只要实例有足够的资源，就能加快迁移速度。

对于最大数量的 Sidekiq 进程，请记住以下几点：

- 进程数量不应超过可用的 CPU 核心数量。
- 每个进程最多可以使用 2 GB 的内存，因此请确保实例有足够的内存来支持任何额外的进程。
- 每个进程根据 `sidekiq['concurrency']` 定义的线程添加一个数据库连接。

有关更多信息，请参阅[运行多个 Sidekiq 进程](../../../administration/sidekiq/extra_sidekiq_processes.md)和[处理特定任务类](../../../administration/sidekiq/processing_specific_job_classes.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="imported-repository-is-missing-branches"></a>

### 导入的仓库缺少分支

如果导入的仓库不包含源仓库的所有分支：

1. 设置[环境变量](../../../administration/logs/_index.md#override-default-log-level) `IMPORT_DEBUG=true`。
1. 使用不同的群组、子群组或项目名称重试导入。
1. 如果仍然缺少某些分支，请检查 [`importer.log`](../../../administration/logs/_index.md#importerlog)（例如，使用 [`jq`](../../../administration/logs/log_parsing.md#parsing-gitlab-railsimporterlog)）。

<a id="exception-error-importing-repository-no-such-file-or-directory-rb_sysopen-filename"></a>

### 异常：`导入仓库时出错 - 没有这样的文件或目录 @ rb_sysopen - (文件名)`

如果您尝试导入一个仓库源代码的 `tar.gz` 文件下载，则会发生错误。

导入需要一个[极狐GitLab 导出](../settings/import_export.md#export-a-project-and-its-data)文件，而不仅仅是仓库下载文件。

<a id="diagnosing-prolonged-or-failed-imports"></a>

### 诊断长时间或失败的导入

如果您在使用文件导入时遇到长时间延迟或失败，尤其是使用 S3 的导入，以下可能有助于识别问题的根本原因：

- [检查导入步骤](#check-import-status)
- [查看日志](#review-logs)
- [识别常见问题](#identify-common-issues)

<a id="check-import-status"></a>

#### 检查导入状态

检查导入状态：

1. 使用极狐GitLab API 检查受影响项目的[导入状态](../../../api/project_import_export.md#import-status)。
1. 查看响应中的任何错误消息或状态信息，尤其是 `status` 和 `import_error` 值。
1. 记下响应中的 `correlation_id`，因为它对于进一步故障排除至关重要。

<a id="review-logs"></a>

#### 查看日志

搜索日志以获取相关信息：

对于极狐GitLab 私有化部署实例：

1. 查看 [Sidekiq 日志](../../../administration/logs/_index.md#sidekiqlog)和 [`exceptions_json` 日志](../../../administration/logs/_index.md#exceptions_jsonlog)。
1. 搜索与 `RepositoryImportWorker` 和来自[检查导入状态](#check-import-status)的相关 ID 相关的条目。
1. 查找诸如 `job_status`、`interrupted_count` 和 `exception` 等字段。

对于 JihuLab.com（仅极狐GitLab 团队成员）：

1. 使用 Kibana 搜索 Sidekiq 日志，使用以下查询：

   目标：`pubsub-sidekiq-inf-gprd*`

   ```plaintext
   json.class: "RepositoryImportWorker" AND json.correlation_id.keyword: "<CORRELATION_ID>"
   ```

   或

   ```plaintext
   json.class: "RepositoryImportWorker" AND json.meta.project: "<project.full_path>"
   ```

1. 查找与极狐GitLab 私有化部署实例中提到的相同字段。

<a id="identify-common-issues"></a>

#### 识别常见问题

将[查看日志](#review-logs)中收集的信息与以下常见问题对照检查：

- **中断任务**：如果您看到 `interrupted_count` 或 `job_status` 表示失败的高值，则导入任务可能已多次中断并置于死队列中。
- **S3 连接性**：对于使用 S3 的导入，请检查日志中的任何与 S3 相关的错误消息。
- **大型仓库**：如果仓库非常大，导入可能会超时。在这种情况下，请考虑使用[直接传输](../../group/import/_index.md)。
