---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业产物管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是管理文档。要了解如何在极狐GitLab CI/CD 流水线中使用作业产物，请参见[作业产物配置文档](../../ci/jobs/job_artifacts.md)。

产物是作业完成后附加到作业的文件和目录列表。此功能在所有极狐GitLab 安装中默认启用。

<a id="disabling-job-artifacts"></a>

## 禁用作业产物

要全站禁用产物：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['artifacts_enabled'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       artifacts:
         enabled: false
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['artifacts_enabled'] = false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     artifacts:
       enabled: false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="storing-job-artifacts"></a>

## 存储作业产物

极狐GitLab Runner 可以将包含作业产物的存档上传到极狐GitLab。默认情况下，这是在作业成功时完成的，但也可以通过 [`artifacts:when`](../../ci/yaml/_index.md#artifactswhen) 参数在失败时或始终上传。

大多数产物在发送到协调器之前由极狐GitLab Runner 压缩。例外情况是[报告产物](../../ci/yaml/_index.md#artifactsreports)，它们在上传后压缩。

<a id="using-local-storage"></a>

### 使用本地存储

如果你使用的是 Linux 软件包或自编译安装，你可以更改本地存储产物的位置。

> [!note]
> 对于 Docker 安装，你可以更改数据挂载的路径。
> 对于 Helm Chart，请使用[对象存储](https://gitlab.cn/docs/charts/advanced/external-object-storage/)。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

产物默认存储在 `/var/opt/gitlab/gitlab-rails/shared/artifacts`。

1. 要更改存储路径，例如更改为 `/mnt/storage/artifacts`，编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['artifacts_path'] = "/mnt/storage/artifacts"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

产物默认存储在 `/home/git/gitlab/shared/artifacts`。

1. 要更改存储路径，例如更改为 `/mnt/storage/artifacts`，编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   production: &base
     artifacts:
       enabled: true
       path: /mnt/storage/artifacts
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="using-object-storage"></a>

### 使用对象存储

如果你不想使用安装极狐GitLab 的本地磁盘来存储产物，你可以改用对象存储，例如 AWS S3。

如果你配置极狐GitLab 将产物存储在对象存储上，你可能还想要[消除作业日志的本地磁盘使用](job_logs.md#prevent-local-disk-usage)。在这两种情况下，作业日志会在作业完成时归档并移至对象存储。

> [!warning]
> 在多服务器设置中，你必须使用其中一种选项来[消除作业日志的本地磁盘使用](job_logs.md#prevent-local-disk-usage)，否则作业日志可能会丢失。

你应该使用[合并的对象存储设置](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="migrating-to-object-storage"></a>

### 迁移到对象存储

你可以将作业产物从本地存储迁移到对象存储。处理在后台工作进程中完成，且**无需停机**。

1. [配置对象存储](#using-object-storage)。
1. 迁移产物：

   {{< tabs >}}

   {{< tab title="Linux 软件包 (Omnibus)" >}}

   ```shell
   sudo gitlab-rake gitlab:artifacts:migrate
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   ```shell
   sudo docker exec -t <container name> gitlab-rake gitlab:artifacts:migrate
   ```

   {{< /tab >}}

   {{< tab title="自编译 (源代码)" >}}

   ```shell
   sudo -u git -H bundle exec rake gitlab:artifacts:migrate RAILS_ENV=production
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 可选。使用 PostgreSQL 控制台跟踪进度并验证所有作业产物是否成功迁移。
   1. 打开 PostgreSQL 控制台：

      {{< tabs >}}

      {{< tab title="Linux 软件包 (Omnibus)" >}}

      ```shell
      sudo gitlab-psql
      ```

      {{< /tab >}}

      {{< tab title="Docker" >}}

      ```shell
      sudo docker exec -it <container_name> /bin/bash
      gitlab-psql
      ```

      {{< /tab >}}

      {{< tab title="自编译 (源代码)" >}}

      ```shell
      sudo -u git -H psql -d gitlabhq_production
      ```

      {{< /tab >}}

      {{< /tabs >}}

   1. 使用以下 SQL 查询验证所有产物是否已迁移到对象存储。`objectstg` 的数量应与 `total` 相同：

      ```shell
      gitlabhq_production=# SELECT count(*) AS total, sum(case when file_store = '1' then 1 else 0 end) AS filesystem, sum(case when file_store = '2' then 1 else 0 end) AS objectstg FROM p_ci_job_artifacts;

      total | filesystem | objectstg
      ------+------------+-----------
         19 |          0 |        19
      ```

1. 验证磁盘上的 `artifacts` 目录中没有文件：

   {{< tabs >}}

   {{< tab title="Linux 软件包 (Omnibus)" >}}

   ```shell
   sudo find /var/opt/gitlab/gitlab-rails/shared/artifacts -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   假设你将 `/var/opt/gitlab` 挂载到 `/srv/gitlab`：

   ```shell
   sudo find /srv/gitlab/gitlab-rails/shared/artifacts -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< tab title="自编译 (源代码)" >}}

   ```shell
   sudo find /home/git/gitlab/shared/artifacts -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 如果启用了 [Geo](../geo/_index.md)，请[重新验证所有作业产物](../geo/replication/troubleshooting/synchronization_verification.md#reverify-one-component-on-all-sites)。

在某些情况下，你需要运行[孤儿产物文件清理 Rake 任务](../raketasks/cleanup.md#remove-orphan-artifact-files)来清理孤儿产物。

<a id="migrating-from-object-storage-to-local-storage"></a>

### 从对象存储迁移到本地存储

要将产物迁移回本地存储：

1. 运行 `gitlab-rake gitlab:artifacts:migrate_to_local`。
1. 在 `gitlab.rb` 中[有选择地禁用产物存储](../object_storage.md#disable-object-storage-for-specific-features)。
1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

在极狐GitLab 18.6 之前，从远程存储迁移到本地存储可能会导致[产物被复制为错误的文件名](job_artifacts_troubleshooting.md#job-artifacts-can-have-wrong-filenames)。

<a id="expiring-artifacts"></a>

## 过期产物

如果使用 [`artifacts:expire_in`](../../ci/yaml/_index.md#artifactsexpire_in) 为产物设置过期时间，则在该日期过后，产物会立即被标记为删除。否则，它们将按照[默认产物过期设置](../settings/continuous_integration.md#set-default-artifacts-expiration)过期。

产物由 `expire_build_artifacts_worker` 定时任务删除，Sidekiq 每 7 分钟运行一次（[Cron](../../topics/cron/_index.md) 语法中的 `*/7 * * * *`）。

要更改删除过期产物的默认计划：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行（如果已存在并被注释掉，则取消注释），用 cron 语法替换你的计划：

   ```ruby
   gitlab_rails['expire_build_artifacts_worker_cron'] = "*/7 * * * *"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       cron_jobs:
         expire_build_artifacts_worker:
           cron: "*/7 * * * *"
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['expire_build_artifacts_worker_cron'] = "*/7 * * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     cron_jobs:
       expire_build_artifacts_worker:
         cron: "*/7 * * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="set-the-maximum-file-size-of-the-artifacts"></a>

## 设置产物的最大文件大小

如果启用了产物，你可以通过[**管理员**区域设置](../settings/continuous_integration.md#set-maximum-artifacts-size)更改产物的最大文件大小。

<a id="storage-statistics"></a>

## 存储统计

你可以在以下位置查看群组和项目的作业产物总存储使用量：

- **管理员**区域
- [群组](../../api/groups.md)和[项目](../../api/projects.md) API

<a id="implementation-details"></a>

## 实现细节

当极狐GitLab 接收到产物存档时，[GitLab Workhorse](https://jihulab.com/gitlab-cn/gitlab-workhorse) 也会生成一个存档元数据文件。此元数据文件描述了产物存档本身中的所有条目。元数据文件采用二进制格式，并附加了 Gzip 压缩。

极狐GitLab 不会提取产物存档，以节省空间、内存和磁盘 I/O。相反，它会检查包含所有相关信息的元数据文件。当存在大量产物或存档文件非常大时，这一点尤为重要。

当选择特定文件时，[GitLab Workhorse](https://jihulab.com/gitlab-cn/gitlab-workhorse) 会从存档中提取该文件并开始下载。这种实现方式节省了空间、内存和磁盘 I/O。