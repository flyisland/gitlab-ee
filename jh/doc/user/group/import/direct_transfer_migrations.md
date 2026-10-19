---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用直接转移迁移群组和项目
description: "使用直接转移在极狐GitLab 实例之间迁移群组和项目。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要使用直接转移迁移极狐GitLab 群组和项目：

1. 确保您满足[先决条件](#prerequisites)。
1. 查看[用户贡献](../../import/mapping/post_migration_mapping.md)和[用户成员关系](#user-membership-mapping)映射。
1. [连接源极狐GitLab 实例](#connect-the-source-gitlab-instance)。
1. [选择要导入的群组和项目](#select-the-groups-and-projects-to-import)并开始迁移。
1. [查看导入结果](#review-results-of-the-import)。

如果遇到任何问题，您可以：

1. [取消](#cancel-a-running-migration)或[重试](#retry-failed-or-partially-successful-migrations)迁移。
1. 查看[故障排除文档](troubleshooting.md)。

<a id="prerequisites"></a>

## 先决条件

使用直接转移进行迁移之前，请查看以下先决条件。

<a id="network-and-storage-space"></a>

### 网络和存储空间

- 实例之间或与 JihuLab.com 之间的网络连接必须支持 HTTPS。
- 防火墙不得阻止源极狐GitLab 实例和目标极狐GitLab 实例之间的连接。
- 源极狐GitLab 实例和目标极狐GitLab 实例必须在 `/tmp` 目录中有足够的可用空间，
  以创建和提取所转移项目与群组的归档。

<a id="versions"></a>

### 版本

为了尽可能提高迁移成功率和性能：

- 将源实例和目标实例都升级到极狐GitLab 16.8 或更高版本。
  更多信息，请参见[史诗 9036](https://gitlab.com/groups/gitlab-org/-/epics/9036)。
- 在尽可能新的版本之间进行迁移，以获得缺陷修复和其他改进。

如果源实例和目标实例的版本不同，源实例的[次要](../../../policy/maintenance.md#versioning)版本不得比目标实例早超过两个版本。

<a id="configuration"></a>

### 配置

- 确保[正确配置了 Sidekiq](../../../administration/sidekiq/configuration_for_imports.md)。
- 两个极狐GitLab 实例都必须由实例管理员在应用程序设置中
  [启用通过直接转移进行群组迁移](../../../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。
- 您必须拥有源极狐GitLab 实例的
  [个人访问令牌](../../profile/personal_access_tokens.md)，且具有 `api` 范围。
- 您必须在源实例和目标实例上拥有所需的权限。对于：
  - 大多数用户，您需要：
    - 在要迁移的源群组上拥有所有者角色。
    - 在目标命名空间中拥有允许您在该命名空间中[创建子群组](../subgroups/_index.md#create-a-subgroup)的角色。
  - 两个实例的管理员如果没有所需的角色，可以改为使用
    [API](../../../api/bulk_imports.md#start-a-group-or-project-migration) 启动导入。
- 要导入项目代码片段，请确保在源项目中
  [启用了代码片段](../../snippets.md#change-default-visibility-of-snippets)。
- 要导入存储在对象存储中的条目，您必须执行以下任一操作：
  - [配置 `proxy_download`](../../../administration/object_storage.md#configure-the-common-parameters)。
  - 确保目标极狐GitLab 实例可以访问源极狐GitLab 实例的对象存储。
- 当源实例或群组的**创建项目所需的默认最低角色**设置为**无**时，您无法导入带有项目的群组。如有需要，可以更改此设置：
  - 针对[整个实例](../../../administration/settings/visibility_and_access_controls.md#define-which-roles-can-create-projects)。
  - 针对[特定群组](../_index.md#specify-who-can-add-projects-to-a-group)。
- 导入的里程碑如果其标题与目标命名空间中[现有里程碑匹配](../../project/milestones/_index.md#milestone-title-rules)，
  其标题将在导入时更新。新标题将附加唯一后缀，例如 `18.0` 将变为 `18.0
  (imported-3d-1770206299)`。要避免这种情况，请在启动直接转移之前重命名源群组或项目中的里程碑。
- 确保满足以下任一条件：
  - 源命名空间和目标命名空间属于同一组织。
  - 当源命名空间和目标命名空间属于不同组织时，两个组织都未被标记为隔离。

<a id="user-membership-mapping"></a>

## 用户成员关系映射

迁移过程中绝不会创建用户。而是将源实例上的用户成员关系映射到目标实例上的用户。用户成员关系的映射类型取决于源实例上的[成员关系类型](../../project/members/_index.md#membership-types)：

- 导入的成员关系最初映射为[占位用户](../../import/mapping/post_migration_mapping.md#placeholder-users)。
- 直接成员关系映射为目标实例上的直接成员关系。
- 继承成员关系映射为目标实例上的继承成员关系。
- 共享成员关系映射为目标实例上的直接成员关系，除非该用户已有共享
  成员关系。对共享成员关系映射的完整支持已在
  [议题 458345](https://gitlab.com/gitlab-org/gitlab/-/issues/458345)中提出。

[在极狐GitLab 18.4 及更高版本中](https://gitlab.com/gitlab-org/gitlab/-/issues/559224)，当您在将项目直接导入现有群组时创建直接成员关系，将遵循[**无法将用户添加到此群组中的项目**设置](../access_and_permissions.md#prevent-members-from-being-added-to-projects-in-a-group)。

在映射[继承和共享](../../project/members/_index.md#membership-types)成员关系时，如果该用户在目标命名空间中已有成员关系，且其[角色](../../permissions.md#roles)高于正在映射的角色，则该成员关系将改为映射为直接成员关系。这可确保该成员不会获得更高的权限。

> [!note]
> 有一个[已知问题](_index.md#known-issues)会影响共享成员关系的映射。

<a id="configure-users-on-destination-instance"></a>

### 在目标实例上配置用户

为确保极狐GitLab 在源实例和目标实例之间正确映射用户及其贡献：

1. 在目标极狐GitLab 实例上创建所需的用户。您只能在极狐GitLab 私有化部署实例上使用 API 创建用户，因为这需要
   管理员访问权限。迁移到 JihuLab.com 或极狐GitLab 私有化部署时，您可以：
   - 手动创建用户。
   - 设置或使用您现有的 [SAML SSO 提供商](../saml_sso/_index.md)，并利用通过
     [SCIM](../saml_sso/scim_setup.md) 支持的 SAML SSO 群组用户同步。您可以
     [使用已验证的电子邮件域绕过极狐GitLab 用户账号验证](../saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。
1. 确保用户在源极狐GitLab 实例上拥有[公开电子邮件](../../profile/_index.md#set-your-public-email)，且该电子邮件与目标极狐GitLab 实例上任何已确认的电子邮件地址匹配。大多数
   用户会收到一封要求他们确认电子邮件地址的电子邮件。
1. 如果用户已存在于目标实例上，并且您使用 [JihuLab.com 群组的 SAML SSO](../saml_sso/_index.md)，则所有用户都必须
   [将其 SAML 身份关联到其 JihuLab.com 账号](../saml_sso/_index.md#link-saml-to-your-existing-gitlabcom-account)。

在极狐GitLab UI 或 API 中无法自动为用户设置公开电子邮件地址。如果您需要为大量用户账号设置公开电子邮件地址，请参见[议题 284495](https://gitlab.com/gitlab-org/gitlab/-/issues/284495#note_1910159855)了解可能的变通方法。

<a id="connect-the-source-gitlab-instance"></a>

## 连接源极狐GitLab 实例

在目标极狐GitLab 实例上，创建您要导入到的群组并连接源极狐GitLab 实例：

1. 创建以下任一内容：
   - 新群组。在右上角，选择**创建新** ({{< icon name="plus" >}}) 和**新建群组**。然后选择**导入群组**。
   - 新子群组。在现有群组的页面上，执行以下任一操作：
     - 选择**创建子群组**。
     - 在右上角，选择**创建新** ({{< icon name="plus" >}}) 和**新建子群组**。然后选择**导入现有群组**链接。
1. 输入极狐GitLab 实例的基础 URL。
1. 输入源极狐GitLab 实例的[个人访问令牌](../../profile/personal_access_tokens.md)。
1. 选择**连接实例**。

<a id="select-the-groups-and-projects-to-import"></a>

## 选择要导入的群组和项目

在您授权访问源极狐GitLab 实例后，您将被重定向到极狐GitLab 群组导入器页面。在这里，您可以看到已连接源实例上您拥有所有者角色的顶级群组列表。

如果您不想从源实例导入所有用户成员关系，请确保清除**导入用户成员关系**复选框。例如，源实例可能有 200 名成员，但您可能只想导入 50 名成员。导入完成后，您可以向群组和项目添加更多成员。

1. 默认情况下，建议的群组命名空间与源实例中存在的名称一致，但根据您的权限，您可以选择在继续导入其中任何内容之前编辑这些名称。群组和项目路径必须符合[命名规则](../../reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)，并在必要时进行规范化以避免导入失败。
1. 在您要导入的群组旁边，选择以下任一选项：
   - **导入项目**。如果此选项不可用，请参见[先决条件](#prerequisites)。
   - **不导入项目**。
1. **状态**列显示每个群组的导入状态。如果您保持页面打开，它会实时更新。
1. 群组导入后，选择其极狐GitLab 路径以打开其极狐GitLab URL。

<a id="review-results-of-the-import"></a>

## 查看导入结果

要查看导入结果：

1. 转到[群组导入历史记录页面](#group-import-history)。
1. 要查看失败导入的详细信息，请在任何状态为**失败**或**部分完成**的导入上选择**显示错误**链接。
1. 如果导入的状态为**部分完成**或**完成**，要查看哪些条目已导入、哪些未导入，请选择**查看详情**。

当您在极狐GitLab UI 中看到某些条目上显示**已导入**徽章时，也可以确认该条目已导入。

<a id="group-import-history"></a>

## 群组导入历史记录

您可以在群组导入历史记录页面上查看您通过直接转移迁移的所有群组。此列表包括：

- 源群组的路径。
- 目标群组的路径。
- 每次导入的开始日期。
- 每次导入的状态。
- 如果发生任何错误，则显示错误详情。

要查看群组导入历史记录：

1. 登录极狐GitLab。
1. 在右上角，选择**创建新** ({{< icon name="plus" >}}) 和**新建群组**。
1. 选择**导入群组**。
1. 在右上角，选择**查看导入历史记录**。
1. 如果特定导入有任何错误，请选择**显示错误**以查看其详情。

<a id="cancel-a-running-migration"></a>

## 取消正在运行的迁移

如有需要，您可以使用 REST API 或 Rails 控制台取消正在运行的迁移。

<a id="cancel-with-the-rest-api"></a>

### 使用 REST API 取消

有关使用 REST API 取消正在运行的迁移的信息，请参见[取消迁移](../../../api/bulk_imports.md#cancel-a-migration)。

<a id="cancel-with-a-rails-console"></a>

### 使用 Rails 控制台取消

要使用 Rails 控制台取消正在运行的迁移：

1. 在目标极狐GitLab 实例上启动 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 通过运行以下命令查找最后一次导入。将 `USER_ID` 替换为启动导入的用户的用户 ID：

   ```ruby
   bulk_import = BulkImport.where(user_id: USER_ID).last
   ```

1. 通过运行以下命令使该导入及其关联的所有条目失败：

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

取消 `bulk_import` 不会停止在源实例上导出项目的工作进程，但会阻止目标实例：

- 向源实例请求更多要导出的项目。
- 为各种检查和信息向源实例发起其他 API 调用。

<a id="retry-failed-or-partially-successful-migrations"></a>

## 重试失败或部分成功的迁移

如果您的迁移失败，或部分成功但缺少条目，您可以重试迁移。要重试顶级群组及其所有子群组和项目的迁移，或特定子群组或项目的迁移，请使用极狐GitLab UI 或[通过直接转移进行群组和项目迁移 API](../../../api/bulk_imports.md)。
