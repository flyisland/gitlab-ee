---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过清单文件迁移
description: "Import repositories to GitLab by using manifest files."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

根据清单文件导入 Git 仓库，就像 [Android 仓库](https://android.googlesource.com/platform/manifest/+/6dc9af1b583e5c6a4ab9c38e3f5646efd8079b7d/default.xml) 使用的文件一样。使用清单文件可导入包含多个仓库的项目，例如 Android 开源项目 (AOSP)。

<a id="prerequisites"></a>

## 前提条件

{{< history >}}

- 在极狐GitLab 16.0 中引入为维护者角色（而非开发者角色）的要求，并向后移植到极狐GitLab 15.11.1 和 15.10.5。

{{< /history >}}

- [清单导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources) 已启用。如果未启用，请让您的极狐GitLab 管理员启用它。清单导入源在 JihuLab.com 上默认启用。
- 目标顶级群组上需要维护者或所有者角色才能进行导入。您可能需要为导入创建一个新的顶级群组。

<a id="manifest-file-format"></a>

### 清单文件格式

清单文件必须是一个大小不超过 1 MB 的 XML 文件。该文件必须包含：

- 一个 `remote` 标签，该标签具有一个 `review` 属性，其中包含一个指向 Git 服务器的 URL。
- 带有 `name` 和 `path` 属性的 `project` 标签。

极狐GitLab 通过将 `remote` 标签中的 URL 与项目名称组合在一起来构建仓库的 URL。`path` 属性用于表示极狐GitLab 中的项目路径。

例如：

```xml
<manifest>
  <remote review="https://android.googlesource.com/" />

  <project path="build/make" name="platform/build" />
  <project path="build/blueprint" name="platform/build/blueprint" />
</manifest>
```

在此示例中，极狐GitLab 创建以下项目：

| 极狐GitLab                                            | 导入 URL |
|:--------------------------------------------------|:-----------|
| `https://jihulab.com/<group_name>/build/make`      | <https://android.googlesource.com/platform/build> |
| `https://jihulab.com/<group_name>/build/blueprint` | <https://android.googlesource.com/platform/build/blueprint> |

<a id="import-the-repositories"></a>

### 导入仓库

要使用清单文件导入仓库：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/仓库**。
1. 选择 **导入项目**。
1. 选择 **清单文件**。
1. 选择您要导入到的群组。
1. 选择要使用的 XML 格式清单文件。
1. 选择 **列出可用仓库**。您将根据清单文件被重定向到显示项目列表的导入状态页面。
1. 要导入：
   - 所有项目（首次），选择 **导入所有仓库**。
   - 再次导入个别项目，选择 **重新导入**。指定新名称，然后再次选择 **重新导入**。重新导入会创建源项目的新副本。

<a id="related-topics"></a>

### 相关主题

- [导入和导出设置](../../../administration/settings/import_and_export_settings.md)
- [Sidekiq 导入配置](../../../administration/sidekiq/configuration_for_imports.md)
- [运行多个 Sidekiq 进程](../../../administration/sidekiq/extra_sidekiq_processes.md)
- [处理特定的作业类](../../../administration/sidekiq/processing_specific_job_classes.md)