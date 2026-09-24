---
stage: Data Access
group: Database Frameworks
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 数据库迁移 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.2 中引入。

{{< /history >}}

使用此 API 管理极狐GitLab 数据库迁移。

先决条件：

- 您必须拥有实例的管理员权限。

<a id="mark-a-migration-as-successful"></a>

## 标记迁移为成功

将待处理的迁移标记为已成功执行，以防止它们被 `db:migrate` 任务执行。当您确定可以安全跳过失败的迁移后，使用此 API 跳过它们。

```plaintext
POST /api/v4/admin/migrations/:version/mark
```

| Attribute       | Type           | Required | Description                                                                   |
|-----------------|----------------|----------|-------------------------------------------------------------------------------|
| `version`       | integer        | yes      | 要跳过的迁移的版本时间戳                                                      |
| `database`      | string         | no       | 迁移所针对的数据库名称。默认为 `main`。                                       |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
   --url "https://gitlab.example.com/api/v4/admin/migrations/:version/mark"
```

<a id="list-pending-migrations"></a>

## 列出待处理的迁移

返回指定数据库中所有待处理（尚未执行的）迁移的列表。

```plaintext
GET /api/v4/admin/migrations/pending
```

| Attribute       | Type           | Required | Description                                                                   |
|-----------------|----------------|----------|-------------------------------------------------------------------------------|
| `database`      | string         | no       | 要查询的数据库名称。默认为 `main`。                                           |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
   --url "https://gitlab.example.com/api/v4/admin/migrations/pending?database=main"
```

示例响应：

```json
{
  "pending_migrations": [
    {
      "version": 20240101120000,
      "name": "create_users_table",
      "filename": "20240101120000_create_users_table.rb",
      "status": "pending"
    },
    {
      "version": 20240102150000,
      "name": "add_email_to_users",
      "filename": "20240102150000_add_email_to_users.rb",
      "status": "pending"
    }
  ],
  "database": "main",
  "total_pending": 2
}
```