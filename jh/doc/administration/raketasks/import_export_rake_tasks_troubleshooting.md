---
stage: 极狐GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目导入与导出疑难解答
---

如果您在导入或导出时遇到问题，可以使用 Rake 任务启用调试模式：

```shell
# 导入
IMPORT_DEBUG=true gitlab-rake "gitlab:import_export:import[root, group/subgroup, testingprojectimport, /path/to/file_to_import.tar.gz]"

# 导出
EXPORT_DEBUG=true gitlab-rake "gitlab:import_export:export[root, group/subgroup, projectnametoexport, /tmp/export_file.tar.gz]"
```

然后，查看下列特定错误消息的详细信息。

<a id="exception:-undefined-method-'name'-for-nil:nilclass"></a>

## `异常：nil:NilClass 的未定义方法 'name'`

`username` 无效。

<a id="exception:-undefined-method-'full_path'-for-nil:nilclass"></a>

## `异常：nil:NilClass 的未定义方法 'full_path'`

`namespace_path` 不存在。
例如，某个群组或子群组输入有误或缺失，
或者您在路径中指定了项目名称。

该任务仅创建项目。
如果您想将其导入到新的群组或子群组，请先创建它。

<a id="exception:-no-such-file-or-directory-@-rb_sysopen---(filename)"></a>

## `异常：没有这样的文件或目录 @ rb_sysopen - (文件名)`

`archive_path` 中指定的项目导出文件丢失。

<a id="exception:-permission-denied-@-rb_sysopen---(filename)"></a>

## `异常：权限被拒绝 @ rb_sysopen - (文件名)`

指定的项目导出文件无法被 `git` 用户访问。

解决此问题：

1. 将文件所有者设置为 `git:git`。
1. 将文件权限更改为 `0400`。
1. 将文件移动到公共文件夹（例如 `/tmp/`）。

<a id="name-can-contain-only-letters,-digits,-emoji-..."></a>

## `名称只能包含字母、数字、表情符号 ...`

```plaintext
名称只能包含字母、数字、表情符号、'_'、'.'、'+'、破折号或空格。必须以字母、
数字、表情符号或 '_' 开头，路径只能包含字母、数字、'_'、'-' 或 '.'。不能以 '-' 开头，
不能以 '.git' 或 '.atom' 结尾。
```

在 `project_path` 中指定的项目名称因上述原因之一无效。

仅在 `project_path` 中填入项目名称。例如，如果您提供了子群组路径，则会失败并报此错误，因为 `/` 不是项目名称中的有效字符。

<a id="name-has-already-been-taken-and-path-has-already-been-taken"></a>

## `名称已被占用，路径已被占用`

该名称的项目已存在。

<a id="exception:-error-importing-repository-into-(namespace)---no-space-left-on-device"></a>

## `异常：将仓库导入 (namespace) 时出错 - 设备上没有空间`

磁盘空间不足，无法完成导入。

在导入期间，打包文件会缓存在您配置的 `shared_path` 目录中。请验证磁盘有足够的可用空间来容纳缓存的打包文件和解压后的项目文件。

<a id="import-succeeds-with-total-number-of-not-imported-relations:-xx-message"></a>

## 导入成功，但显示 "未导入的关系总数：XX" 消息

如果您收到 `未导入的关系总数：XX` 消息，并且导入过程中未创建议题，请检查 [`exceptions_json.log`](../logs/_index.md#exceptions_jsonlog)。
您可能会看到类似 `N is out of range for ActiveModel::Type::Integer with limit 4 bytes` 的错误，
其中 `N` 是超出 4 字节整数限制的整数。如果是这种情况，您可能遇到了议题 `relative_position` 字段重新平衡的问题。

```ruby
# 检查 relative_position 的当前最大值
Issue.where(project_id: Project.find(ID).root_namespace.all_projects).maximum(:relative_position)

# 运行重新平衡过程并检查 relative_position 的最大值是否发生变化
Issues::RelativePositionRebalancingService.new(Project.find(ID).root_namespace.all_projects).execute
Issue.where(project_id: Project.find(ID).root_namespace.all_projects).maximum(:relative_position)
```

重复导入尝试并检查议题是否成功导入。

<a id="gitaly-calls-error-when-importing"></a>

## 导入时 Gitaly 调用错误

如果您尝试将大型项目导入到开发环境，Gitaly 可能会抛出关于过多调用或调用的错误。例如：

```plaintext
Error importing repository into qa-perf-testing/gitlabhq - GitalyClient#call called 31 times from single request. Potential n+1?
```

此错误是由于开发设置的 n+1 调用限制所致。要解决此错误，请将环境变量 `GITALY_DISABLE_REQUEST_LIMITS=1` 设置为 1。然后重启开发环境并重新导入。