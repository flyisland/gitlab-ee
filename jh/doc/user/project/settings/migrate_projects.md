---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 转移项目
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

<a id="transfer-a-project-to-another-namespace"></a>

## 将项目转移到另一个命名空间

{{< history >}}

- 支持在同一顶级命名空间内转移带有容器镜像的项目引入于极狐GitLab 17.7（仅限 SaaS），使用名为 `transfer_project_with_tags` 的[功能标志](../../../administration/feature_flags.md)。默认禁用。
- 支持在同一顶级命名空间内转移带有容器镜像的项目功能，在极狐GitLab 17.7 中在 SaaS 上启用。功能标志被删除。

{{< /history >}}

转移项目以将其移动到不同的群组。项目转移包括：

- 项目组件：
  - 议题
  - 合并请求
  - 流水线
  - 仪表板
- 项目成员：
  - 直接成员
  - 成员邀请

   {{< alert type="note" >}}

   在项目中具有[继承成员资格](../members/_index.md#membership-types)的成员将失去访问权限，除非他们也是目标群组的成员。项目继承您转移到的群组的新成员权限。

   {{< /alert >}}

项目的[路径也会更改](../repository/_index.md#repository-path-changes)，因此请确保在必要时更新项目组件的 URL。

如果目标命名空间中尚不存在匹配的群组标签，则会为议题和合并请求创建新的项目级标签。

{{< alert type="warning" >}}

转移过程中的错误可能导致项目组件或终端用户依赖项的数据丢失。

{{< /alert >}}

先决条件：

- 您必须至少拥有您要转移到的[群组](../../group/_index.md#create-a-group)的维护者角色。
- 您必须是您要转移的项目的所有者。
- 群组必须允许创建新项目。
- 对于启用了容器镜像仓库的项目：
  - 在 JihuLab.com 上：您只能在同一顶级命名空间内转移项目。
  - 在极狐GitLab 私有化部署上：项目不得包含[容器镜像](../../packages/container_registry/_index.md#move-or-rename-container-registry-repositories)。
- 项目不得有安全策略。如果项目分配了安全策略，则在转移过程中会自动取消分配。
- 如果根命名空间更改，您必须从项目中删除遵循[命名约定](../../packages/npm_registry/_index.md#naming-convention)的 npm 软件包。转移项目后，您可以：

  - 使用新的根命名空间路径更新软件包范围，然后再次将其发布到项目。
  - 将软件包重新发布到项目而不更新根命名空间路径，这将导致软件包不再遵循命名约定。如果您在不更新根命名空间路径的情况下重新发布软件包，它将无法用于[实例端点](../../packages/npm_registry/_index.md#install-from-an-instance)。

要转移项目：

1. 在左侧边栏中，选择 **搜索或前往** 并找到您的项目。
1. 选择 **设置 > 常规**。
1. 展开 **高级**。
1. 在 **转移项目** 下，选择要转移项目到的命名空间。
1. 选择 **转移项目**。
1. 输入项目的名称并选择 **确认**。

您将被重定向到项目的新页面，极狐GitLab 应用重定向。有关存储库重定向的更多信息，请参阅[当存储库路径更改时会发生什么](../repository/_index.md#repository-path-changes)。

{{< alert type="note" >}}

如果您是管理员，您也可以使用[管理界面](../../../administration/admin_area.md#administering-projects)将任何项目移动到任何命名空间。

{{< /alert >}}

<a id="transferring-a-gitlab-com-project-to-a-different-subscription-tier"></a>

## 将 JihuLab.com 项目转移到不同的订阅层级

当您将项目从极狐GitLab.com 专业版或旗舰版授权的命名空间转移到极狐GitLab 基础版时：

- [项目访问令牌](project_access_tokens.md)将被撤销。
- [流水线订阅](../../../ci/pipelines/_index.md#trigger-a-pipeline-when-an-upstream-project-is-rebuilt-deprecated)和[测试用例](../../../ci/test_cases/_index.md)将被删除。

<a id="troubleshooting"></a>

## 故障排除

在处理项目设置时，您可能会遇到以下问题，或需要使用其他方法完成特定任务。

<a id="transfer-a-project-through-console"></a>

### 通过控制台转移项目

如果通过 UI 或 API 无法转移项目，您可以尝试在[Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)中进行转移。

```ruby
p = Project.find_by_full_path('<project_path>')

# To set the owner of the project
current_user = p.creator

# Namespace where you want this to be moved
namespace = Namespace.find_by_full_path("<new_namespace>")

Projects::TransferService.new(p, current_user).execute(namespace)
```

<a id="related-topics"></a>

## 相关主题

- [使用文件导出迁移项目](import_export.md)
- [故障排除文件导出项目迁移](import_export_troubleshooting.md)
