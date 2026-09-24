---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 导入并迁移到极狐GitLab
description: Repository migration, third-party repositories, and user contribution mapping.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.0 中，所有导入器默认对私有化部署实例禁用。

{{< /history >}}

将现有工作迁移到极狐GitLab。

一些第三方平台可使用迁移工具。部分支持[迁移后映射](mapping/post_migration_mapping.md)用户贡献和成员资格。

| 迁移来源 | 群组 | 项目 | 迁移工具 | 迁移后映射 |
|:---|:---|:---|:---|:---|
| [极狐GitLab（通过直接迁移）](../group/import/_index.md) | {{< yes >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [极狐GitLab（通过文件导出）](../project/settings/import_export.md) | {{< yes >}}<sup>1</sup> | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [Bitbucket Server](bitbucket_server.md) | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [GitHub](../project/import/github.md) | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [Gitea](gitea.md) | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [Bitbucket Cloud](bitbucket_cloud.md) | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [FogBugz](../project/import/fogbugz.md) | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< no >}} |
| 通过[清单文件](third_party_systems/manifest_file.md)导入 Git 仓库 | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< no >}} |
| 通过[仓库 URL](third_party_systems/repo_by_url.md)导入 Git 仓库 | {{< no >}} | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [IBM DevOps ClearCase](third_party_systems/clearcase.md) | {{< no >}} | {{< yes >}} | {{< no >}} | {{< no >}} |
| [Concurrent Versions System (CVS)](third_party_systems/cvs.md) | {{< no >}} | {{< yes >}} | {{< no >}} | {{< no >}} |
| [Perforce P4](third_party_systems/perforce.md) | {{< no >}} | {{< yes >}} | {{< no >}} | {{< no >}} |
| [Subversion](#migrate-from-subversion) | {{< no >}} | {{< yes >}} | {{< no >}} | {{< no >}} |
| [Team Foundation Version Control (TFVC)](third_party_systems/tfvc.md) | {{< no >}} | {{< yes >}} | {{< no >}} | {{< no >}} |
| [Jira（仅议题）](../project/import/jira.md) | {{< no >}} | {{< no >}} | {{< yes >}} | {{< no >}} |

**脚注**：

1. 使用文件导出进行群组迁移已被废弃。

<a id="migrate-from-subversion"></a>

## 从 Subversion 迁移

极狐GitLab 无法自动将 Subversion 仓库迁移到 Git。要将 Subversion 仓库转换为 Git，你可以使用外部工具，例如：

- [`git svn`](https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git)，适用于非常小和简单的仓库。
- [`reposurgeon`](http://www.catb.org/~esr/reposurgeon/repository-editing.html)，适用于更大和更复杂的仓库。

<a id="migrate-by-engaging-professional-services"></a>

## 通过专业服务进行迁移

如果你愿意，你可以聘请极狐GitLab 专业服务来迁移群组和项目到极狐GitLab，而无需自行操作。更多信息，请参阅[专业服务目录](https://gitlab.cn/services/catalog/)。

<a id="view-project-import-history"></a>

## 查看项目导入历史

你可以查看你创建的所有项目导入。此列表包括：

- 如果项目是从外部系统导入的，则为源项目的路径；如果迁移的是极狐GitLab 项目，则为导入方式。
- 目标项目的路径。
- 每次导入的开始日期。
- 每次导入的状态。
- 如果发生错误，显示错误详情。

历史记录还包括从以下方式创建的项目：

- [内置](../project/_index.md#create-a-project-from-a-built-in-template)模板。
- [自定义](../project/_index.md#create-a-project-from-a-custom-template)模板。

极狐GitLab 使用[通过 URL 导入仓库](third_party_systems/repo_by_url.md)从模板创建新项目。

查看项目导入历史：

1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新建项目/仓库**。
1. 选择 **导入项目**。
1. 在右上角，选择 **历史** 链接。
1. 如果某个导入存在任何错误，请选择 **详情** 查看。

<a id="importing-projects-with-lfs-objects"></a>

## 导入包含 LFS 对象的项目

当导入包含 LFS 对象的项目时，如果项目有一个 [`.lfsconfig`](https://github.com/git-lfs/git-lfs/blob/main/docs/man/git-lfs-config.adoc) 文件，且其中的 URL 主机（`lfs.url`）与仓库 URL 主机不同，则不会下载 LFS 文件。