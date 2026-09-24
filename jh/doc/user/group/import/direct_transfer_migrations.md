---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用直接转移迁移群组和项目
description: "Migrate groups and projects between 极狐GitLab instances by using direct transfer."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要使用直接转移迁移极狐GitLab 群组和项目：

1. 确保满足[前提条件](#prerequisites)。
1. 查看[用户贡献](../../import/mapping/post_migration_mapping.md)和[用户成员](#user-membership-mapping)映射。
1. [连接源极狐GitLab 实例](#connect-the-source-gitlab-instance)。
1. [选择要导入的群组和项目](#select-the-groups-and-projects-to-import) 并开始迁移。
1. [查看导入结果](#review-results-of-the-import)。

如果遇到任何问题，您可以：

1. [取消](#cancel-a-running-migration) 或 [重试](#retry-failed-or-partially-successful-migrations) 迁移。
1. 查看[故障排除文档](troubleshooting.md)。

<a id="prerequisites"></a>

## 前提条件

{{< history >}}

- 在极狐GitLab 18.6.7 及更高版本、18.7.5 及更高版本和 18.8.5 及更高版本中引入了重命名里程碑标题以避免与目标实例冲突的功能。

{{< /history >}}

在使用直接转移进行迁移之前，请查看以下前提条件。

<a id="network-and-storage-space"></a>

### 网络与存储空间

- 实例之间或 JihuLab.com 的网络连接必须支持 HTTPS。
- 防火墙不得阻止源极狐GitLab 实例和目标极狐GitLab 实例之间的连接。
- 源和目标极狐GitLab 实例的 `/tmp` 目录必须有足够的可用空间来创建和提取传输的项目和群组的存档。

<a id="versions"></a>

### 版本

为了最大限度地提高迁移的成功率和性能：

- 将源和目标实例都升级到极狐GitLab 16.8 或更高版本。有关更多信息，请参阅史诗 9036。
- 在尽可能晚的版本之间进行迁移，以获得错误修复和其他改进。

如果源实例和目标实例的版本不同，源实例不得比目标实例早超过两个[次要](../../../policy/maintenance.md#versioning)版本。

<a id="configuration"></a>

### 配置

- 确保 [Sidekiq 已正确配置](../../../administration/sidekiq/configuration_for_imports.md)。
- 两个极狐GitLab 实例都必须由实例管理员在应用程序设置中[启用通过直接转移进行群组迁移](../../../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。
- 您必须拥有用于源极狐GitLab 实例的[个人访问令牌](../../profile/personal_access_tokens.md)，且具有 `api` 作用域。
- 您必须在源实例和目标实例上拥有所需的权限。对于：
  - 大多数用户，您需要：
    - 在源群组中具有所有者角色以进行迁移。
    - 在目标命名空间中具有允许您在该命名空间中[创建子群组](../subgroups/_index.md#create-a-subgroup)的角色。
  - 对于没有所需角色的两个实例的管理员，您可以通过使用 [API](../../../api/bulk_imports.md#start-a-group-or-project-migration) 来启动迁移。
- 要导入项目代码片段，请确保在源项目中[启用了代码片段](../../snippets.md#change-default-visibility-of-snippets)。
- 要导入存储在对象存储中的项目，您必须执行以下操作之一：
  - [配置 `proxy_download`](../../../administration/object_storage.md#configure-the-common-parameters)。
  - 确保目标极狐GitLab 实例可以访问源极狐GitLab 实例的对象存储。
- 如果源实例或群组的 **创建项目所需的最低默认角色** 设置为 **无**，则无法导入带有项目的群组。如有必要，可以更改此设置：
  - 针对[整个实例](../../../administration/settings/visibility_and_access_controls.md#define-which-roles-can-create-projects)。
  - 针对[特定群组](../_index.md#specify-who-can-add-projects-to-a-group)。
- 导入的里程碑标题如果与目标命名空间中[现有里程碑标题匹配](../../project/milestones/_index.md#milestone-title-rules)，则会在导入时更新标题。新标题将附加一个唯一后缀，例如 `18.0` 将变为 `18.0 (imported-3d-1770206299)`。为避免这种情况，请在发起直接转移之前重命名源群组或源项目中的里程碑。

<a id="user-membership-mapping"></a>

## 用户成员映射

{{< history >}}

- 在极狐GitLab 16.3 中引入了将共享和继承的共享成员映射为直接成员的功能。
- 在极狐GitLab 16.11 中，对已导入群组或项目的现有成员，将共享和继承的共享成员映射为直接成员的行为发生了更改。
- 在极狐GitLab 17.1 中引入了映射继承成员的功能。
- 在极狐GitLab 17.3 中引入了将用户成员最初映射到占位用户的功能，并带有一个名为 `bulk_import_importer_user_mapping` 的[功能标志](../../../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 17.5 中，在 JihuLab.com 上启用了将用户成员最初映射到占位用户的功能。
- 在极狐GitLab 17.7 中，在私有化部署上启用了将用户成员最初映射到占位用户的功能。
- 在极狐GitLab 18.4 中，将用户成员最初映射到占位用户的功能已 GA。功能标志 `bulk_import_importer_user_mapping` 已移除。

{{< /history >}}

迁移过程中不会创建用户。
相反，源实例上的用户成员身份会映射到目标实例上的用户。
用户成员映射的类型取决于源实例上的[成员类型](../../project/members/_index.md#membership-types)：

- 导入的成员身份最初映射到[占位用户](../../import/mapping/post_migration_mapping.md#placeholder-users)。
- 直接成员身份映射为目标实例上的直接成员身份。
- 继承成员身份映射为目标实例上的继承成员身份。
- 共享成员身份映射为目标实例上的直接成员身份，除非用户已有共享成员身份。对共享成员映射的完全支持在议题 458345 中提出。

在极狐GitLab 18.4 及更高版本中，当您在直接导入项目到现有群组时创建直接成员身份，将遵循 [**此群组中的项目不能添加用户** 设置](../access_and_permissions.md#prevent-members-from-being-added-to-projects-in-a-group)。

映射[继承和共享](../../project/members/_index.md#membership-types)成员身份时，如果用户在目标命名空间中已有比正在映射的角色更高的[角色](../../permissions.md#roles)的现有成员身份，则将该成员身份映射为直接成员身份。这样可以确保成员不会获得提升的权限。

> [!note]
> 有一个影响共享成员映射的[已知问题](_index.md#known-issues)。

<a id="configure-users-on-destination-instance"></a>

### 在目标实例上配置用户

为了确保极狐GitLab 在源实例和目标实例之间正确映射用户及其贡献：

1. 在目标极狐GitLab 实例上创建所需的用户。您只能通过 API 在私有化部署实例上创建用户，因为这需要管理员访问权限。迁移到 JihuLab.com 或私有化部署时，您可以：
   - 手动创建用户。
   - 设置或使用现有的 [SAML SSO 提供程序](../saml_sso/_index.md)，并利用通过 [SCIM](../saml_sso/scim_setup.md) 支持的 SAML SSO 群组用户同步。您可以通过[已验证的电子邮件域绕过 GitLab 用户帐户验证](../saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。
1. 确保用户在源极狐GitLab 实例上拥有与目标极狐GitLab 实例上任何已确认电子邮件地址匹配的[公开电子邮件](../../profile/_index.md#set-your-public-email)。大多数用户会收到一封要求他们确认电子邮件地址的电子邮件。
1. 如果目标实例上已经存在用户，并且您使用 [JihuLab.com 群组的 SAML SSO](../saml_sso/_index.md)，则所有用户必须 [将其 SAML 身份关联到其 JihuLab.com 帐户](../saml_sso/_index.md#link-saml-to-your-existing-gitlabcom-account)。

在极狐GitLab UI 或 API 中无法自动为用户设置公开电子邮件地址。如果您需要为大量用户帐户设置公开电子邮件地址，请参阅议题 284495 以了解可能的解决方法。

<a id="connect-the-source-gitlab-instance"></a>

## 连接源极狐GitLab 实例

在目标极狐GitLab 实例上，创建要导入到的群组，并连接源极狐GitLab 实例：

1. 创建以下之一：
   - 新群组。在右上角，选择 **创建新**（{{< icon name="plus" >}}）和 **新建群组**。然后选择 **导入群组**。
   - 新子群组。在现有群组页面上，可以：
     - 选择 **创建子群组**。
     - 在右上角，选择 **创建新**（{{< icon name="plus" >}}）和 **新建子群组**。然后选择 **导入现有群组** 链接。
1. 输入极狐GitLab 实例的基本 URL。
1. 输入源极狐GitLab 实例的[个人访问令牌](../../profile/personal_access_tokens.md)。
1. 选择 **连接实例**。

<a id="select-the-groups-and-projects-to-import"></a>

## 选择要导入的群组和项目

{{< history >}}

- 在极狐GitLab 15.8 中引入了带项目或不带项目导入群组的选项。
- 在极狐GitLab 17.6 中引入了 **导入用户成员** 复选框。

{{< /history >}}

授权访问源极狐GitLab 实例后，您将被重定向到极狐GitLab 群组导入器页面。您可以看到已连接的源实例上您拥有所有者角色的顶级群组列表。

如果您不想从源实例导入所有用户成员，请确保 **导入用户成员** 复选框未选中。例如，源实例可能有 200 名成员，但您可能只想导入 50 名成员。导入完成后，您可以向群组和项目添加更多成员。

1. 默认情况下，建议的群组命名空间与源实例中的名称一致，但根据您的权限，您可以在继续导入任何群组之前编辑这些名称。群组和项目路径必须符合[命名规则](../../reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)，并在必要时进行规范化以避免导入失败。
1. 在要导入的群组旁边，选择以下之一：
   - **带项目导入**。如果此选项不可用，请参阅[前提条件](#prerequisites)。
   - **不带项目导入**。
1. **状态** 列显示每个群组的导入状态。如果页面保持打开状态，它会实时更新。
1. 群组导入完成后，选择其极狐GitLab 路径以打开其极狐GitLab URL。

<a id="review-results-of-the-import"></a>

## 查看导入结果

{{< history >}}

- 在极狐GitLab 16.6 中引入了带有名为 `bulk_import_details_page` 的[功能标志](../../../administration/feature_flags/list.md)，默认启用。
- 功能标志 `bulk_import_details_page` 在极狐GitLab 16.8 中移除。
- 在极狐GitLab 16.9 中添加了部分完成和已完成导入的详细信息。
- 在极狐GitLab 17.0 中引入了 **已导入** 徽章，用于指示设计、史诗、议题、合并请求、评论（系统笔记和评论）、代码片段和用户个人资料活动已被导入。

{{< /history >}}

要查看导入结果：

1. 转到[群组导入历史页面](#group-import-history)。
1. 要查看失败导入的详细信息，请在任何状态为 **失败** 或 **部分完成** 的导入上选择 **显示错误** 链接。
1. 如果导入的状态为 **部分完成** 或 **完成**，要查看哪些项目已导入和未导入，请选择 **查看详细信息**。

当您在极狐GitLab UI 中某些项目上看到 **已导入** 徽章时，也可以知道该项目已被导入。

<a id="group-import-history"></a>

## 群组导入历史

{{< history >}}

- 在极狐GitLab 16.7 中引入了 **部分完成** 状态。

{{< /history >}}

您可以在群组导入历史页面上查看您通过直接转移迁移的所有群组。此列表包括：

- 源群组的路径。
- 目标群组的路径。
- 每个导入的开始日期。
- 每个导入的状态。
- 如果发生任何错误，则包含错误详细信息。

要查看群组导入历史：

1. 登录极狐GitLab。
1. 在右上角，选择 **创建新**（{{< icon name="plus" >}}）和 **新建群组**。
1. 选择 **导入群组**。
1. 在右上角，选择 **查看导入历史**。
1. 如果某个特定导入有任何错误，请选择 **显示错误** 以查看其详细信息。

<a id="cancel-a-running-migration"></a>

## 取消正在运行的迁移

如有必要，您可以使用 REST API 或 Rails 控制台取消正在运行的迁移。

<a id="cancel-with-the-rest-api"></a>

### 使用 REST API 取消

有关使用 REST API 取消正在运行的迁移的信息，请参阅[取消迁移](../../../api/bulk_imports.md#cancel-a-migration)。

<a id="cancel-with-a-rails-console"></a>

### 使用 Rails 控制台取消

要使用 Rails 控制台取消正在运行的迁移：

1. 开始目标极狐GitLab 实例上的 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下命令查找最后一个导入。将 `USER_ID` 替换为启动导入的用户的用户 ID：

   ```ruby
   bulk_import = BulkImport.where(user_id: USER_ID).last
   ```

1. 运行以下命令使导入及其所有关联项失败：

   ```ruby
   bulk_import.entities.each do |entity|
     entity.trackers.each do |tracker|
       tracker.batches.each(&:fail_op!)
     end
     entity.trackers.each(&:fail_op!)
     entity.fail_op!
   end
   bulk_import.fail_op!
   ```

取消 `bulk_import` 不会停止在源实例上导出项目的 worker，但会阻止目标实例：

- 向源实例请求更多要导出的项目。
- 对源实例进行其他 API 调用以进行各种检查和获取信息。

<a id="retry-failed-or-partially-successful-migrations"></a>

## 重试失败或部分成功的迁移

如果您的迁移失败，或者部分成功但缺少项目，您可以重试迁移。
要重试顶级群组及其所有子群组和项目的迁移，或特定的子群组或项目，请使用极狐GitLab UI 或[直接转移的群组和项目迁移 API](../../../api/bulk_imports.md)。

