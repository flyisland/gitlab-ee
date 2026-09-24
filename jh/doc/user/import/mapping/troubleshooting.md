---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查迁移后贡献和成员映射问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在占位用户重新分配过程中，您可能会遇到以下问题。

<a id="source-user-reassignment-failed"></a>

## 源用户重新分配失败

若要重试状态为 `failed` 的源用户的重新分配，您可以使用 GraphQL API 或 Rails 控制台。有关更多信息，请参阅[议题 589777](https://jihulab.com/gitlab-cn/gitlab/-/work_items/589777)。关于 UI 支持的讨论见[议题 593001](https://jihulab.com/gitlab-cn/gitlab/-/work_items/593001)。

<a id="use-the-graphql-api"></a>

### 使用 GraphQL API

{{< history >}}

- 在极狐GitLab 18.11 中引入。

{{< /history >}}

使用 `importSourceUserRetryFailedReassignment` 变更重试失败的重新分配：

```graphql
mutation {
  importSourceUserRetryFailedReassignment(input: { id: "gid://gitlab/Import::SourceUser/<SOURCE_USER_ID>" }) {
    importSourceUser {
      id
      status
    }
    errors
  }
}
```

将 `<SOURCE_USER_ID>` 替换为导入源用户 ID。
您可以通过在命名空间上查询 `importSourceUsers` 来找到此 ID。

<a id="use-the-rails-console"></a>

### 使用 Rails 控制台

您可以在 [Rails 控制台](../../../administration/operations/rails_console.md) 中手动重试失败的源用户：

```ruby
# 通过源用户的占位用户 ID 查找，因为占位用户 ID 很容易从 UI 中获取
placeholder_user_id = <PLACEHOLDER_USER_ID>
import_source_user = Import::SourceUser.find_by(placeholder_user_id: placeholder_user_id)

if import_source_user.failed?
  import_source_user.update!(status: Import::SourceUser::STATUSES[:reassignment_in_progress])
  Import::ReassignPlaceholderUserRecordsWorker.perform_async(import_source_user.id)
  puts "已排队重试重新分配"
else
  puts "导入源用户状态：#{import_source_user.status} (预期为 'failed')"
end
```

<a id="investigate-repeated-failures"></a>

### 调查重复失败

如果源用户再次失败，请检查 [`importer.log`](../../../administration/logs/_index.md#importerlog) 中是否有任何日志包含消息 `Failed to reassign placeholder user`，以开始调查根本原因。

<a id="source-user-reassigned-successfully-but-its-placeholder-user-was-not-deleted"></a>

## 源用户重新分配成功但其占位用户未被删除

在成功重新分配用户贡献后，占位用户会被删除。但是，重新分配后数据库中可能仍然存在一些引用占位用户 ID 的记录，导致占位用户无法被删除。当发生这种情况时，管理员仍然可以在管理员用户表中看到占位用户。尽管占位用户不计入许可证配额，并且对极狐GitLab 的典型操作没有影响，但有些管理员可能希望迁移后删除所有占位用户。

在极狐GitLab 18.5 及更早版本中重新分配占位用户的用户更容易遇到这种情况。发生这种情况时，[`importer.log`](../../../administration/logs/_index.md#importerlog) 中会关联到占位用户的 ID，显示消息 `Unable to delete placeholder user because it is still referenced in other tables`。

要删除这些用户，您可以：

- [作为管理员删除占位用户](../../profile/account/delete_account.md#delete-users-and-user-contributions)。当您确信任何剩余的占位用户贡献都可以被删除时，此方法最佳。
- 将极狐GitLab 实例升级到 18.6 或更高版本，并在 Rails 控制台中为占位用户重试占位符重新分配。当重新分配是在极狐GitLab 18.5 或更早版本上完成并且您不确定还有哪些占位用户贡献存在时，此方法最佳。

要在 [Rails 控制台](../../../administration/operations/rails_console.md) 中重试已完成占位用户的重新分配：

```ruby
# 查找占位用户的源用户
placeholder_user_id = <PLACEHOLDER_USER_ID>
import_source_user = Import::SourceUser.find_by(placeholder_user_id: placeholder_user_id)

if import_source_user.completed?
  import_source_user.update!(status: Import::SourceUser::STATUSES[:reassignment_in_progress])
  Import::ReassignPlaceholderUserRecordsWorker.perform_async(import_source_user.id)
  puts "已排队重试重新分配"
else
  puts "导入源用户状态：#{import_source_user.status} (预期为 'completed')"
end
```