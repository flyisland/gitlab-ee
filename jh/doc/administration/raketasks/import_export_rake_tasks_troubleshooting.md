---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目导入和导出故障排除
---

如果导入或导出时遇到问题，请使用 Rake 任务启用调试模式：

```shell
# Import
IMPORT_DEBUG=true gitlab-rake "gitlab:import_export:import[root, group/subgroup, testingprojectimport, /path/to/file_to_import.tar.gz]"

# Export
EXPORT_DEBUG=true gitlab-rake "gitlab:import_export:export[root, group/subgroup, projectnametoexport, /tmp/export_file.tar.gz]"
```

然后，查看以下关于特定错误消息的详细信息。

<a id="exception-undefined-method-name-for-nilnilclass"></a>

## `Exception: undefined method 'name' for nil:NilClass`

`username` 无效。

<a id="exception-undefined-method-full_path-for-nilnilclass"></a>

## `Exception: undefined method 'full_path' for nil:NilClass`

`namespace_path` 不存在。例如，某个群组或子群组拼写错误或缺失，或者您在路径中指定了项目名称。

该任务只会创建项目。如果要将其导入到新的群组或子群组，请先创建该群组或子群组。

<a id="exception-no-such-file-or-directory--rb_sysopen---filename"></a>

## `Exception: No such file or directory @ rb_sysopen - (filename)`

`archive_path`中指定的项目导出文件缺失。

<a id="exception-permission-denied--rb_sysopen---filename"></a>

## `Exception: Permission denied @ rb_sysopen - (filename)`

`git` 用户无法访问指定的项目导出文件。

要解决此问题：

1. 将文件所有者设置为 `git:git`。
1. 将文件权限更改为 `0400`。
1. 将文件移动到公共文件夹（例如 `/tmp/`）。

<a id="name-can-contain-only-letters-digits-emoji-"></a>

## `Name can contain only letters, digits, emoji ...`

```plaintext
Name can contain only letters, digits, emoji, '_', '.', '+', dashes, or spaces. It must start with a letter,
digit, emoji, or '_', and Path can contain only letters, digits, '_', '-', or '.'. It cannot start
with '-', end in '.git', or end in '.atom'.
```

`project_path`中指定的项目名称因以下某一原因而无效。

请仅在 `project_path`中填写项目名称。例如，如果您提供的路径包含子群组，则会因 `/` 不是项目名称中的有效字符而失败并显示此错误。

<a id="name-has-already-been-taken-and-path-has-already-been-taken"></a>

## `Name has already been taken and Path has already been taken`

已存在使用该名称的项目。

<a id="exception-error-importing-repository-into-namespace---no-space-left-on-device"></a>

## `Exception: Error importing repository into (namespace) - No space left on device`

磁盘空间不足，无法完成导入。

导入期间，tarball 会缓存在您配置的 `shared_path` 目录中。请确认磁盘有足够的可用空间，以同时容纳缓存的 tarball 和磁盘上解包后的项目文件。

<a id="import-succeeds-with-total-number-of-not-imported-relations-xx-message"></a>

## 导入成功但显示 `Total number of not imported relations: XX` 消息

如果您收到 `Total number of not imported relations: XX` 消息，且导入期间未创建议题，请检查 [`exceptions_json.log`](../logs/_index.md#exceptions_jsonlog)。您可能会看到类似 `N is out of range for ActiveModel::Type::Integer with limit 4 bytes`的错误，其中 `N` 是超出 4 字节整数限制的整数。如果是这种情况，您很可能遇到了议题的 `relative_position` 字段重新平衡问题。

```ruby
# Check the current maximum value of relative_position
Issue.where(project_id: Project.find(ID).root_namespace.all_projects).maximum(:relative_position)

# Run the rebalancing process and check if the maximum value of relative_position has changed
Issues::RelativePositionRebalancingService.new(Project.find(ID).root_namespace.all_projects).execute
Issue.where(project_id: Project.find(ID).root_namespace.all_projects).maximum(:relative_position)
```

请重复导入尝试，并检查议题是否成功导入。

<a id="gitaly-calls-error-when-importing"></a>

## 导入时 Gitaly 调用出错

如果您尝试将大型项目导入到开发环境，Gitaly 可能会抛出关于调用或调用次数过多的错误。例如：

```plaintext
Error importing repository into qa-perf-testing/gitlabhq - GitalyClient#call called 31 times from single request. Potential n+1?
```

此错误是由于开发环境的 n+1 调用限制所致。要解决此错误，请将 `GITALY_DISABLE_REQUEST_LIMITS=1` 设置为环境变量。然后重启开发环境并重新导入。
