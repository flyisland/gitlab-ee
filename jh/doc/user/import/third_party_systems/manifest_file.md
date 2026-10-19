---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过清单文件迁移
description: "使用清单文件将代码仓库导入到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

基于清单文件导入 Git 代码仓库，例如 [Android 代码仓库](https://android.googlesource.com/platform/manifest/+/6dc9af1b583e5c6a4ab9c38e3f5646efd8079b7d/default.xml)所使用的清单文件。使用该清单可以导入包含多个代码仓库的项目，例如 Android 开源项目（AOSP）。

<a id="prerequisites"></a>

## 先决条件

- 已启用[清单导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。
  如果未启用，请让极狐GitLab 管理员启用。在 JihuLab.com 上，清单导入源默认启用。
- 在要导入到的目标顶级群组上具有维护者或所有者角色。您可能需要为导入创建一个新的顶级
  群组。

<a id="manifest-file-format"></a>

## 清单文件格式

清单文件必须是大小不超过 1 MB 的 XML 文件。该文件必须包含：

- 一个 `remote` 标签，其中包含一个 `review` 属性，该属性包含指向 Git 服务器的 URL。
- 带有 `name` 和 `path` 属性的 `project` 标签。

极狐GitLab 通过将 `remote` 标签中的 URL 与项目名称组合来构建代码仓库的 URL。path 属性用于表示项目在极狐GitLab 中的路径。

例如：

```xml
<manifest>
  <remote review="https://android.googlesource.com/" />

  <project path="build/make" name="platform/build" />
  <project path="build/blueprint" name="platform/build/blueprint" />
</manifest>
```

在此示例中，极狐GitLab 会创建以下项目：

| 极狐GitLab                                            | 导入 URL |
|:--------------------------------------------------|:-----------|
| `https://gitlab.com/<group_name>/build/make`      | <https://android.googlesource.com/platform/build> |
| `https://gitlab.com/<group_name>/build/blueprint` | <https://android.googlesource.com/platform/build/blueprint> |

<a id="import-the-repositories"></a>

## 导入代码仓库

要使用清单文件导入代码仓库：

1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建项目/仓库**。
1. 选择**导入项目**。
1. 选择**清单文件**。
1. 选择要导入到的群组。
1. 选择要使用的 XML 格式清单文件。
1. 选择**列出可用代码仓库**。您会被重定向到导入状态页面，其中显示基于
   该清单文件的项目列表。
1. 要导入：
   - 首次导入所有项目，选择**导入所有代码仓库**。
   - 再次导入单个项目，选择**重新导入**。指定新名称并再次选择**重新导入**。重新导入
     会创建源项目的新副本。
