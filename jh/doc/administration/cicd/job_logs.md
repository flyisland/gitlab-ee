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

作业日志由 Runner 在处理作业时发送。您可以在作业页面、流水线和电子邮件通知等位置查看日志。

<a id="data-flow"></a>

## 数据流

通常，作业日志有两种状态：`log` 和 `archived log`。在下表中，您可以看到日志经历的各个阶段：

| 阶段           | 状态         | 条件                    | 数据流                                   | 存储路径 |
| -------------- | ------------ | ----------------------- | -----------------------------------------| ----------- |
| 1：修补        | log          | 作业运行时              | Runner => Puma => 文件存储 | `#{ROOT_PATH}/gitlab-ci/builds/#{YYYY_mm}/#{project_id}/#{job_id}.log` |
| 2：归档        | archived log | 作业完成后              | Sidekiq 将日志移动到产物文件夹           | `#{ROOT_PATH}/gitlab-rails/shared/artifacts/#{disk_hash}/#{YYYY_mm_dd}/#{job_id}/#{job_artifact_id}/job.log` |
| 3：上传        | archived log | 日志归档后              | Sidekiq 将已归档的日志移动到[对象存储](#uploading-logs-to-object-storage)（如果已配置） | `#{bucket_name}/#{disk_hash}/#{YYYY_mm_dd}/#{job_id}/#{job_artifact_id}/job.log` |

`ROOT_PATH` 因环境而异：

- 对于 Linux 软件包，它是 `/var/opt/gitlab`。
- 对于自行编译的安装，它是 `/home/git/gitlab`。

<a id="changing-the-job-logs-local-location"></a>

## 更改作业日志的本地位置

> [!note]
> 对于 Docker 安装，您可以更改数据挂载的路径。
> 对于 Helm chart，请使用对象存储。

要更改作业日志的存储位置：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 可选。如果您已有作业日志，请通过暂时停止 Sidekiq 来暂停持续集成数据处理：

   ```shell
   sudo gitlab-ctl stop sidekiq
   ```

1. 在 `/etc/gitlab/gitlab.rb`中设置新的存储位置：

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

   使用 `--ignore-existing`，以免用同一日志的旧版本覆盖新的作业日志。

1. 如果您选择暂停持续集成数据处理，可以再次启动 Sidekiq：

   ```shell
   sudo gitlab-ctl start sidekiq
   ```

1. 移除旧的作业日志存储位置：

   ```shell
   sudo rm -rf /var/opt/gitlab/gitlab-ci/builds
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 可选。如果您已有作业日志，请通过暂时停止 Sidekiq 来暂停持续集成数据处理：

   ```shell
   # For systems running systemd
   sudo systemctl stop gitlab-sidekiq

   # For systems running SysV init
   sudo service gitlab stop
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 以设置新的存储位置：

   ```yaml
   production: &base
     gitlab_ci:
       builds_path: /mnt/gitlab-ci/builds
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

1. 使用 `rsync` 将作业日志从当前位置移动到新位置：

   ```shell
   sudo rsync -avzh --remove-source-files --ignore-existing --progress /home/git/gitlab/builds/ /mnt/gitlab-ci/builds/
   ```

   使用 `--ignore-existing`，以免用同一日志的旧版本覆盖新的作业日志。

1. 如果您选择暂停持续集成数据处理，可以再次启动 Sidekiq：

   ```shell
   # For systems running systemd
   sudo systemctl start gitlab-sidekiq

   # For systems running SysV init
   sudo service gitlab start
   ```

1. 移除旧的作业日志存储位置：

   ```shell
   sudo rm -rf /home/git/gitlab/builds
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="uploading-logs-to-object-storage"></a>

## 将日志上传到对象存储

已归档的日志被视为[作业产物](job_artifacts.md)。因此，当您[设置对象存储集成](job_artifacts.md#using-object-storage)时，作业日志会与其他作业产物一起自动迁移到其中。

请参阅[数据流](#data-flow)中的“阶段 3：上传”以了解该过程。

<a id="maximum-log-file-size"></a>

## 日志文件大小上限

极狐GitLab 中作业日志文件的大小限制默认为 100 MB。任何超过该限制的作业都会被标记为失败，并由 Runner 丢弃。更多详情，请参阅[作业日志的文件大小上限](limits.md#maximum-file-size-for-job-logs)。

<a id="prevent-local-disk-usage"></a>

## 避免占用本地磁盘

如果您希望作业日志完全不占用本地磁盘，可以使用以下选项之一：

- 开启[增量日志记录](#configure-incremental-logging)。
- 将[作业日志位置](#changing-the-job-logs-local-location)
  设置为 NFS 驱动器。

<a id="how-to-remove-job-logs"></a>

## 如何删除作业日志

无法自动使旧作业日志过期。不过，如果它们占用过多空间，可以安全地将其删除。如果您手动删除日志，UI 中的作业输出将为空。

有关如何使用 GitLab CLI 删除作业日志的详情，请参阅[删除作业日志](../../user/storage_management_automation.md#delete-job-logs)。

对于 Helm chart，请使用对象存储随附的存储管理工具。

或者，您也可以使用 shell 命令删除作业日志。例如，要删除所有超过 60 天的作业日志，请在极狐GitLab 实例的 shell 中运行以下命令。

> [!warning]
> 以下命令会永久删除日志文件，且不可逆。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
find /var/opt/gitlab/gitlab-rails/shared/artifacts -name "job.log" -mtime +60 -delete
```

{{< /tab >}}

{{< tab title="Docker" >}}

假设您将 `/var/opt/gitlab` 挂载到 `/srv/gitlab`：

```shell
find /srv/gitlab/gitlab-rails/shared/artifacts -name "job.log" -mtime +60 -delete
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
find /home/git/gitlab/shared/artifacts -name "job.log" -mtime +60 -delete
```

{{< /tab >}}

{{< /tabs >}}

删除日志后，您可以运行检查[已上传文件的完整性](../raketasks/check.md#uploaded-files-integrity)的 Rake 任务，以查找任何损坏的文件引用。更多信息，请参阅如何[删除对缺失产物的引用](../raketasks/check.md#delete-references-to-missing-artifacts)。

<a id="frequency-of-job-log-updates"></a>

## 作业日志更新频率

作业运行期间，`X-GitLab-Trace-Update-Interval` 请求头指定极狐GitLab Runner 发送作业日志更新的频率。

默认情况下：

- 如果作业的日志未打开，则每 60 秒发送一次更新。
- 如果作业的日志已打开，则每 3 秒发送一次更新。

要配置作业日志更新间隔，请使用[管理区域](../settings/continuous_integration.md#configure-the-frequency-of-job-log-updates)中的设置或 [Settings API](../../api/settings.md)。

<a id="incremental-logging"></a>

## 增量日志记录

增量日志记录会改变作业日志的处理和存储方式，从而提升横向扩展部署的性能。

默认情况下，作业日志由极狐GitLab Runner 分块发送，并临时缓存在磁盘上。作业完成后，后台作业会将日志归档到产物目录，或者归档到对象存储（如果已配置）。

使用增量日志记录时，日志存储在 Redis 和持久化存储中，而不是文件存储中。这种方式：

- 避免作业日志占用本地磁盘。
- 无需在 Rails 和 Sidekiq 服务器之间共享 NFS。
- 提升多节点安装的性能。

增量日志记录过程使用 Redis 作为临时存储，流程如下：

1. Runner 从极狐GitLab 中获取一个作业。
1. Runner 将一段日志发送到极狐GitLab。
1. 极狐GitLab 将数据追加到 `Gitlab::Redis::TraceChunks` 命名空间中的 Redis。
1. Redis 中的数据达到 128 KB 后，数据会被刷写到持久化存储。
1. 重复上述步骤，直到作业完成。
1. 作业完成后，极狐GitLab 会调度一个 Sidekiq 工作进程来归档日志。
1. 该 Sidekiq 工作进程将日志归档到对象存储，并清理临时数据。

增量日志记录不支持 Redis Cluster。
更多信息，请参阅[议题 224171](https://gitlab.com/gitlab-org/gitlab/-/issues/224171)。

<a id="configure-incremental-logging"></a>

### 配置增量日志记录

在开启增量日志记录之前，您必须为 CI/CD 产物、日志和构建[配置对象存储](job_artifacts.md#using-object-storage)。开启增量日志记录后，文件无法写入磁盘，且没有针对错误配置的保护措施。

开启增量日志记录时，正在运行的作业的日志会继续写入磁盘，但新作业会使用增量日志记录。

关闭增量日志记录时，正在运行的作业会继续使用增量日志记录，但新作业会写入磁盘。

要配置增量日志记录：

- 使用[管理区域](../settings/continuous_integration.md#access-job-log-settings)中的设置或 [Settings API](../../api/settings.md)。
