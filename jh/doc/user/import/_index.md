---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 导入并迁移到极狐GitLab
description: 代码仓库迁移、第三方代码仓库以及用户贡献映射。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将您现有的工作带入极狐GitLab。

部分第三方平台提供了迁移工具。部分平台支持用户贡献和成员关系的[迁移后映射](mapping/post_migration_mapping.md)。

| 迁移来源                                                                   | 群组                  | 项目    | 迁移工具 | 迁移后映射 |
|:-------------------------------------------------------------------------------|:------------------------|:------------|:---------------|:-----------------------|
| [极狐GitLab（使用直接转移）](../group/import/_index.md)| {{< yes >}}             | {{< yes >}} | {{< yes >}}    | {{< yes >}}            |
| [极狐GitLab（使用文件导出）](../project/settings/import_export.md)| {{< yes >}}<sup>1</sup> | {{< yes >}} | {{< yes >}}    | {{< no >}}             |
| [Bitbucket Server](bitbucket_server.md)                                        | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< yes >}}            |
| [GitHub](../project/import/github.md)                                          | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< yes >}}            |
| [Gitea](gitea.md)                                                              | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< yes >}}            |
| [Bitbucket Cloud](bitbucket_cloud.md)                                          | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< no >}}             |
| [FogBugz](third_party_systems/fogbugz.md)                                      | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< no >}}             |
| 通过[清单文件](third_party_systems/manifest_file.md)迁移 Git 代码仓库 | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< no >}}             |
| 通过[代码仓库 URL](third_party_systems/repo_by_url.md) 迁移 Git 代码仓库  | {{< no >}}              | {{< yes >}} | {{< yes >}}    | {{< no >}}             |
| [IBM DevOps ClearCase](third_party_systems/clearcase.md)                       | {{< no >}}              | {{< yes >}} | {{< no >}}     | {{< no >}}             |
| [并发版本系统 (CVS)](third_party_systems/cvs.md)                 | {{< no >}}              | {{< yes >}} | {{< no >}}     | {{< no >}}             |
| [Perforce P4](third_party_systems/perforce.md)                                 | {{< no >}}              | {{< yes >}} | {{< no >}}     | {{< no >}}             |
| [Subversion](#migrate-from-subversion)                                         | {{< no >}}              | {{< yes >}} | {{< no >}}     | {{< no >}}             |
| [Team Foundation 版本控制 (TFVC)](third_party_systems/tfvc.md)          | {{< no >}}              | {{< yes >}} | {{< no >}}     | {{< no >}}             |
| [Jira（仅议题）](third_party_systems/jira.md)| {{< no >}}              | {{< no >}}  | {{< yes >}}    | {{< no >}}             |

**脚注**：

1. 使用文件导出进行群组迁移已废弃。

<a id="migrate-from-subversion"></a>

## 从 Subversion 迁移

极狐GitLab 无法自动将 Subversion 代码仓库迁移到 Git。要将 Subversion 代码仓库转换为 Git，
您可以使用外部工具，例如：

- [`git svn`](https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git)，适用于非常小且基础的代码仓库。
- [`reposurgeon`](http://www.catb.org/~esr/reposurgeon/repository-editing.html)，适用于更大、更复杂的代码仓库。

<a id="migrate-by-engaging-professional-services"></a>

## 通过专业服务进行迁移

如果您愿意，也可以聘请 GitLab 专业服务将群组和项目迁移到极狐GitLab，而不必自行迁移。有关更多信息，请参见[专业服务目录](https://about.gitlab.com/services/catalog/)。

<a id="view-project-import-history"></a>

## 查看项目导入历史

您可以查看您创建的所有项目导入。此列表包括：

- 如果项目是从外部系统导入的，则显示源项目的路径；如果迁移的是极狐GitLab 项目，则显示导入方法。
- 目标项目的路径。
- 每次导入的开始日期。
- 每次导入的状态。
- 如果发生任何错误，则显示错误详情。

该历史记录还包括通过以下方式创建的项目：

- [内置](../project/_index.md#create-a-project-from-a-built-in-template)模板。
- [自定义](../project/_index.md#create-a-project-from-a-custom-template)模板。

极狐GitLab 使用[通过 URL 导入代码仓库](third_party_systems/repo_by_url.md)从模板创建新项目。

要查看项目导入历史：

1. 在右上角，选择 **创建新的**（{{< icon name="plus" >}}）和 **新建项目/仓库**。
1. 选择 **导入项目**。
1. 在右上角，选择 **历史** 链接。
1. 如果某次导入出现任何错误，选择 **详情** 查看这些错误。

<a id="importing-projects-with-lfs-objects"></a>

## 导入包含 LFS 对象的项目

导入包含 LFS 对象的项目时，如果该项目有一个 [`.lfsconfig`](https://github.com/git-lfs/git-lfs/blob/main/docs/man/git-lfs-config.adoc) 文件，其中的 URL 主机（`lfs.url`）与代码仓库 URL 主机不同，则不会下载 LFS 文件。
