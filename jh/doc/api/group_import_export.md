---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组导入导出 API
description: "使用 REST API 导入和导出群组。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来[迁移群组结构](../user/group/import/_index.md)。
当您将此 API 与[项目导入导出 API](project_import_export.md) 一起使用时，可以保留
群组级别的关联关系，例如项目议题与群组史诗之间的连接。

群组导出包含以下内容：

- 群组里程碑
- 群组看板
- 群组标记
- 群组徽章
- 群组成员
- 群组事件
- 群组 Wiki（仅限专业版和旗舰版）
- 子群组。每个子群组都包含上述列表中的所有数据。

要保留导入项目的群组级关联关系，您应该先运行群组导出和导入。这样，您就可以将项目导出导入到所需的群组结构中。

由于[议题 405168](https://gitlab.com/gitlab-org/gitlab/-/issues/405168)，导入的群组具有 `private`
可见性级别，除非您将它们导入到父群组中。默认情况下，如果您将群组导入到父群组中，子群组会继承与父群组相同的可见性级别。

要保留导入群组上的成员列表及其各自的权限，请审阅这些群组中的用户。在导入所需群组之前，请确保这些用户已存在。

<a id="create-a-group-export"></a>

## 创建群组导出

为指定群组创建群组导出。

```plaintext
POST /groups/:id/export
```

| 属性 | 类型              | 必填 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组的 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/export"
```

```json
{
  "message": "202 Accepted"
}
```

<a id="retrieve-a-group-export-download"></a>

## 获取群组导出下载

检索指定群组的导出归档文件。

```plaintext
GET /groups/:id/export/download
```

| 属性 | 类型              | 必填 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组的 ID。 |

```shell
group=1
token=secret

curl --request GET \
  --header "PRIVATE-TOKEN: ${token}" \
  --output download_group_${group}.tar.gz \
  --url "https://gitlab.example.com/api/v4/groups/${group}/export/download"
```

```shell
ls *export.tar.gz
2020-12-05_22-11-148_namespace_export.tar.gz
```

导出群组所需的时间可能因群组大小而异。此端点返回以下任一结果：

- 导出的归档文件（可用时）
- 404 消息

<a id="create-a-group-import"></a>

## 创建群组导入

通过上传文件来创建群组导入。

最大导入文件大小可由管理员在极狐GitLab 私有化部署上设置（默认为 `0`（无限制））。作为管理员，您可以通过以下任一方式修改最大导入文件大小：

- 在 [**管理员**区域](../administration/settings/import_and_export_settings.md) 中。
- 通过使用[应用程序设置 API](settings.md#update-application-settings) 中的 `max_import_size` 选项。

有关 JihuLab.com 上最大导入文件大小的信息，请参阅
[账户和限制设置](../user/jihulab_com/_index.md#account-and-limit-settings)。

```plaintext
POST /groups/import
```

| 属性   | 类型           | 必填 | 描述 |
| ----------- | -------------- | -------- | ----------- |
| `file`      | 字符串         | 是      | 要上传的文件。 |
| `name`      | 字符串         | 是      | 要导入的群组名称。 |
| `path`      | 字符串         | 是      | 新群组的名称和路径。 |
| `parent_id` | 整数        | 否       | 要将群组导入到的父群组的 ID。如果未提供，则默认为当前用户的命名空间。 |

要从文件系统上传文件，请使用 `--form` 参数。这会使 cURL 使用 `Content-Type: multipart/form-data` 请求头发布数据。
`file=` 参数必须指向文件系统上的文件，并且前面
加上 `@`。例如：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "name=imported-group" \
  --form "path=imported-group" \
  --form "file=@/path/to/file" \
  --url "https://gitlab.example.com/api/v4/groups/import"
```
