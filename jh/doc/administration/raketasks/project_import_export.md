---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目导入与导出 Rake 任务
description: 用于导入和导出大型项目的 Rake 任务。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了用于 [项目导入与导出](../../user/project/settings/import_export.md) 的 Rake 任务。

你只能从 [兼容的](../../user/project/settings/import_export.md#compatibility) 极狐GitLab 实例导入。

<a id="import-large-projects"></a>

## 导入大型项目

[Rake 任务](https://jihulab.com/gitlab-cn/-/blob/master/lib/tasks/gitlab/import_export/import.rake) 用于导入大型极狐GitLab 项目导出文件。

我们可以从终端运行此任务：

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `username`      | 字符串 | 是 | 用户名 |
| `namespace_path` | 字符串 | 是 | 命名空间路径 |
| `project_path` | 字符串 | 是 | 项目路径 |
| `archive_path` | 字符串 | 是 | 要导入的导出项目压缩包路径 |

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
gitlab-rake "gitlab:import_export:import[root, group/subgroup, testingprojectimport, /path/to/file.tar.gz]"
```

{{< /tab >}}

{{< tab title="自行编译 (源代码)" >}}

```shell
bundle exec rake "gitlab:import_export:import[root, group/subgroup, testingprojectimport, /path/to/file.tar.gz]" RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="export-large-projects"></a>

## 导出大型项目

你可以使用 Rake 任务导出大型项目。

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `username`      | 字符串 | 是 | 用户名 |
| `namespace_path` | 字符串 | 是 | 命名空间路径 |
| `project_path` | 字符串 | 是 | 项目名称 |
| `archive_path` | 字符串 | 是 | 存储导出的项目压缩包的文件路径 |

```shell
gitlab-rake "gitlab:import_export:export[username, namespace_path, project_path, archive_path]"
```

