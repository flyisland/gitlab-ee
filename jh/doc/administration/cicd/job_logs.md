---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业日志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

作业日志由 Runner 在处理作业时发送。你可以在作业页面、流水线和邮件通知等地方查看日志。

<a id="data-flow"></a>

## 数据流

通常，作业日志有两种状态：`log` 和 `archived log`。下表展示日志经过的阶段：

| 阶段           | 状态          | 条件                      | 数据流                                    | 存储路径 |
| -------------- | ------------ | ----------------------- | -----------------------------------------| ----------- |
| 1：补丁       | log          | 作业运行时               | Runner => Puma => 文件存储 | `#{ROOT_PATH}/gitlab-ci/builds/#{YYYY_mm}/#{project_id}/#{job_id}.log` |
| 2：归档       | archived log | 作业完成后               | Sidekiq 将日志移动到产物目录    | `#{ROOT_PATH}/gitlab-rails/shared/artifacts/#{disk_hash}/#{YYYY_mm_dd}/#{job_id}/#{job_artifact_id}/job.log` |
| 3：上传       | archived log | 日志归档后               | Sidekiq 将归档日志移动到 [对象存储](#uploading-logs-to-object-storage)（如果已配置） | `#{bucket_name}/#{disk_hash}/#{YYYY_mm_dd}/#{job_id}/#{job_artifact_id}/job.log` |

`ROOT_PATH` 因环境而异：

- 对于 Linux 软件包，为 `/var/opt/gitlab`。
- 对于自行编译安装，为 `/home/git/gitlab`。

<a id="changing-the-job-logs-local-location"></a>

## 更改作业日志的本地存储位置

> [!note]
> 对于 Docker 安装，你可以更改数据挂载的路径。
> 对于 Helm Chart，请使用对象存储。

要更改作业日志的存储位置：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 可选。如果你已有作业日志，可通过临时停止 Sidekiq 来暂停持续集成数据处理：

   ```shell
   sudo gitlab-ctl stop sidekiq
   ```

1. 在 `/etc/gitlab/gitlab.rb` 中设置新的存储位置：

   ```ruby
   gitlab_ci['builds_directory'] = '/mnt/gitlab-ci/builds'
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 使用 `rsync` 将作业日志从当前位置移动到新位置：

   ```shell
   sudo rsync -avzh --remove-source-files --ignore-existing --progress /var/opt/gitlab/gitlab-ci/builds/ /mnt/gitlab-ci/builds/
   ```

   使用 `--ignore-existing` 以避免用旧版日志覆盖新的作业日志。

1. 如果你选择了暂停持续集成数据处理，可以重新启动 Sidekiq：

   ```shell
   sudo gitlab-ctl start sidekiq
   ```

1. 删除旧的作业日志存储位置：

   ```shell
   sudo rm -rf /var/opt/gitlab/gitlab-ci/builds
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 可选。如果你已有作业日志，可通过临时停止 Sidekiq 来暂停持续集成数据处理：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl stop gitlab-sidekiq

   # 对于使用 SysV init 的系统
   sudo service gitlab stop
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 设置新的存储位置：

   ```yaml
   production: &base
     gitlab_ci:
       builds_path: /mnt/gitlab-ci/builds
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

1. 使用 `rsync` 将作业日志从当前位置移动到新位置：

   ```shell
   sudo rsync -avzh --remove-source-files --ignore-existing --progress /home/git/gitlab/builds/ /mnt/gitlab-ci/builds/
   ```

   使用 `--ignore-existing` 以避免用旧版日志覆盖新的作业日志。

1. 如果你选择了暂停持续集成数据处理，可以重新启动 Sidekiq：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl start gitlab-sidekiq

   # 对于使用 SysV init 的系统
   sudo service gitlab start
   ```

1. 删除旧的作业日志存储位置：

   ```shell
   sudo rm -rf /home/git/gitlab/builds
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="uploading-logs-to-object-storage"></a>

## 将日志上传到对象存储

归档日志被视为 [作业产物](job_artifacts.md)。因此，当你 [设置对象存储集成](job_artifacts.md#using-object-storage) 时，作业日志会随其他作业产物自动迁移到对象存储。

请参阅 [数据流](#data-flow) 中的“阶段 3：上传”了解该过程。

<a id="maximum-log-file-size"></a>

## 最大日志文件大小

极狐GitLab 中作业日志文件大小默认限制为 100 MB。任何超过限制的作业都会被标记为失败，并由 Runner 丢弃。更多详情，请参见 [作业日志的最大文件大小](../instance_limits.md#maximum-file-size-for-job-logs)。

<a id="prevent-local-disk-usage"></a>

## 防止本地磁盘使用

如果你想避免作业日志占用任何本地磁盘，可以通过以下选项之一实现：

- 启用 [增量日志记录](#configure-incremental-logging)。
- 将 [作业日志存储位置](#changing-the-job-logs-local-location) 设置为 NFS 驱动器。

<a id="how-to-remove-job-logs"></a>

## 如何删除作业日志

没有自动清除旧作业日志的方法。不过，如果它们占用了太多空间，可以安全删除。如果手动删除日志，UI 中的作业输出将变为空。

有关如何使用极狐GitLab CLI 删除作业日志的详细信息，请参阅 [删除作业日志](../../user/storage_management_automation.md#delete-job-logs)。

对于 Helm Chart，请使用对象存储自带的存储管理工具。

或者，你可以通过 shell 命令删除作业日志。例如，要删除所有 60 天前的作业日志，请在极狐GitLab 实例的 shell 中运行以下命令。

> [!warning]
> 以下命令将永久删除日志文件且不可逆。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
find /var/opt/gitlab/gitlab-rails/shared/artifacts -name "job.log" -mtime +60 -delete
```

{{< /tab >}}

{{< tab title="Docker" >}}

假设你将 `/var/opt/gitlab` 挂载到了 `/srv/gitlab`：

```shell
find /srv/gitlab/gitlab-rails/shared/artifacts -name "job.log" -mtime +60 -delete
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
find /home/git/gitlab/shared/artifacts -name "job.log" -mtime +60 -delete
```

{{< /tab >}}

{{< /tabs >}}

日志删除后，你可以通过运行检查 [上传文件完整性](../raketasks/check.md#uploaded-files-integrity) 的 Rake 任务来查找所有损坏的文件引用。更多信息，请参见 [删除对缺失产物的引用](../raketasks/check.md#delete-references-to-missing-artifacts)。

<a id="incremental-logging"></a>

## 增量日志记录

增量日志记录改变了作业日志的处理和存储方式，提高了横向扩展部署的性能。

默认情况下，作业日志从 GitLab Runner 分块发送并临时缓存在磁盘上。作业完成后，后台作业将日志归档到产物目录或对象存储（如果已配置）。

启用增量日志记录后，日志将存储在 Redis 和持久化存储中，而非文件存储。这种方式：

- 避免作业日志占用本地磁盘。
- 无需在 Rails 和 Sidekiq 服务器之间共享 NFS。
- 提高多节点安装的性能。

增量日志记录过程使用 Redis 作为临时存储，流程如下：

1. Runner 从极狐GitLab 获取作业。
1. Runner 向极狐GitLab 发送一段日志。
1. 极狐GitLab 将数据追加到 `Gitlab::Redis::TraceChunks` 命名空间中的 Redis。
1. 当 Redis 中的数据达到 128 KB 后，数据被刷新到持久化存储。
1. 重复上述步骤直到作业完成。
1. 作业完成后，极狐GitLab 调度一个 Sidekiq 工作进程来归档日志。
1. Sidekiq 工作进程将日志归档到对象存储并清理临时数据。

增量日志记录不支持 Redis 集群。更多信息，请参见 [议题 224171](https://jihulab.com/gitlab-cn/gitlab/-/issues/224171)。

<a id="configure-incremental-logging"></a>

### 配置增量日志记录

启用增量日志记录之前，你必须为 CI/CD 产物、日志和构建 [配置对象存储](job_artifacts.md#using-object-storage)。启用增量日志记录后，文件将无法写入磁盘，且配置错误无保护。

开启增量日志记录时，正在运行的作业日志仍会写入磁盘，但新作业将使用增量日志记录。

关闭增量日志记录时，正在运行的作业继续使用增量日志记录，但新作业将写入磁盘。

要配置增量日志记录：

- 使用 [管理员区域](../settings/continuous_integration.md#access-job-log-settings) 中的设置或 [Settings API](../../api/settings.md)。