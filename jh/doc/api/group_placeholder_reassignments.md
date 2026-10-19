---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组占位符重新分配 API
description: "Reassign placeholder users in bulk with the REST API."
---

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- [引入] 于极狐GitLab 15.4，[带有功能标志] 名为 `importer_user_mapping_reassignment_csv`。默认启用。
- [GA] 于极狐GitLab 18.0。功能标志 `importer_user_mapping_reassignment_csv` 已移除。
- 当导入到个人命名空间时，将贡献重新分配给个人命名空间所有者 [引入] 于极狐GitLab 18.3，[带有功能标志] 名为 `user_mapping_to_personal_namespace_owner`。默认禁用。
- 当导入到个人命名空间时，将贡献重新分配给个人命名空间所有者 [GA] 于极狐GitLab 18.6。功能标志 `user_mapping_to_personal_namespace_owner` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。

使用此 API 来 [批量重新分配占位符用户](../user/import/mapping/reassignment.md#request-reassignment-by-using-a-csv-file)。

先决条件：

- 您必须具有群组的所有者角色。

> [!note]
> 当您将项目导入到 [个人命名空间](../user/namespace/_index.md#types-of-namespaces) 时，不支持用户贡献映射。
> 当您导入到个人命名空间时，所有贡献都会分配给个人命名空间所有者，并且无法重新分配。

<a id="retrieve-pending-reassignments"></a>

## 获取待处理的重新分配

获取包含待处理重新分配列表的 CSV 文件。

```plaintext
GET /groups/:id/placeholder_reassignments
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/2/placeholder_reassignments"
```

示例响应：

```csv
源主机,导入类型,源用户标识符,源用户名称,源用户名,极狐GitLab 用户名,极狐GitLab 公共电子邮件
http://gitlab.example,gitlab_migration,11,Bob,bob,"",""
http://gitlab.example,gitlab_migration,9,Alice,alice,"",""
```

<a id="reassign-placeholders"></a>

## 重新分配占位符

使用上传的 CSV 文件重新分配占位符用户。

```plaintext
POST /groups/:id/placeholder_reassignments
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "file=@placeholder_reassignments_for_group_2_1741253695.csv" \
  --url "http://gdk.test:3000/api/v4/groups/2/placeholder_reassignments"
```

示例响应：

```json
{"message":"文件正在处理，完成后您将收到一封电子邮件。"}
```