---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 上传文件迁移 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

有一个 Rake 任务可用于在不同存储类型之间迁移上传内容。

- 使用 [`gitlab:uploads:migrate:all`](#all-in-one-rake-task) 迁移所有上传内容，或者
- 若只想迁移特定的上传类型，请使用 [`gitlab:uploads:migrate`](#individual-rake-tasks)。

<a id="migrate-to-object-storage"></a>

## 迁移到对象存储

为极狐GitLab 的上传内容[配置对象存储](../../uploads.md#using-object-storage)后，使用此任务将现有上传内容从本地存储迁移到远程存储。

所有处理都在后台工作进程中完成，无需停机。

进一步了解如何[将对象存储与极狐GitLab 配合使用](../../object_storage.md)。

<a id="all-in-one-rake-task"></a>

### 一体化 Rake 任务

极狐GitLab 提供了一个包装 Rake 任务，可一步将所有上传的文件（例如头像、徽标、附件和网站图标）迁移到对象存储。该包装任务会逐个调用各个 Rake 任务，以迁移属于上述各类别的文件。

这些[单独的 Rake 任务](#individual-rake-tasks)将在下一节中介绍。

要将所有上传内容从本地存储迁移到对象存储，请运行：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
gitlab-rake "gitlab:uploads:migrate:all"
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:migrate:all
```

{{< /tab >}}

{{< /tabs >}}

您可以选择使用 [PostgreSQL 控制台](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database)跟踪进度，并验证所有上传内容是否已成功迁移：

- 对于 Linux 软件包安装，使用 `sudo gitlab-rails dbconsole --database main`。
- 对于自行编译的安装，使用 `sudo -u git -H psql -d gitlabhq_production`。

验证下面的 `objectstg`（其中 `store=2`）是否包含所有产物的计数：

```shell
gitlabhq_production=# SELECT count(*) AS total, sum(case when store = '1' then 1 else 0 end) AS filesystem, sum(case when store = '2' then 1 else 0 end) AS objectstg FROM uploads;

total | filesystem | objectstg
------+------------+-----------
   2409 |          0 |      2409
```

验证磁盘上的 `uploads` 文件夹中没有文件：

```shell
sudo find /var/opt/gitlab/gitlab-rails/uploads -type f | grep -v tmp | wc -l
```

<a id="individual-rake-tasks"></a>

### 单独的 Rake 任务

如果您已经运行了[一体化 Rake 任务](#all-in-one-rake-task)，则无需再运行这些单独的任务。

该 Rake 任务使用三个参数来查找要迁移的上传内容：

| 参数        | 类型          | 描述                                            |
|:-----------------|:--------------|:-------------------------------------------------------|
| `uploader_class` | string        | 要迁移的上传器类型。                  |
| `model_class`    | string        | 要迁移的模型类型。                     |
| `mount_point`    | string/symbol | 上传器所挂载的模型列的名称。 |

> [!note]
> 这些参数主要属于极狐GitLab 的内部结构，您可能更想参考下面的任务列表。
> 运行这些单独的任务后，建议您运行[一体化 Rake 任务](#all-in-one-rake-task)，
> 以迁移未包含在所列类型中的任何上传内容。

此任务还接受一个环境变量，您可以用它来覆盖默认的批处理大小：

| 变量 | 类型    | 描述                                       |
|:---------|:--------|:--------------------------------------------------|
| `BATCH`  | integer | 指定批处理的大小。默认为 200。 |

下面展示了如何针对各个上传类型运行 `gitlab:uploads:migrate`。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
# gitlab-rake gitlab:uploads:migrate[uploader_class, model_class, mount_point]

# Avatars
gitlab-rake "gitlab:uploads:migrate[AvatarUploader, Project, :avatar]"
gitlab-rake "gitlab:uploads:migrate[AvatarUploader, Group, :avatar]"
gitlab-rake "gitlab:uploads:migrate[AvatarUploader, User, :avatar]"

# Attachments
gitlab-rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :logo]"
gitlab-rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :header_logo]"

# Favicon
gitlab-rake "gitlab:uploads:migrate[FaviconUploader, Appearance, :favicon]"

# Markdown
gitlab-rake "gitlab:uploads:migrate[FileUploader, Project]"
gitlab-rake "gitlab:uploads:migrate[PersonalFileUploader, Snippet]"
gitlab-rake "gitlab:uploads:migrate[NamespaceFileUploader, Snippet]"
gitlab-rake "gitlab:uploads:migrate[FileUploader, MergeRequest]"

# Design Management design thumbnails
gitlab-rake "gitlab:uploads:migrate[DesignManagement::DesignV432x230Uploader, DesignManagement::Action, :image_v432x230]"
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

每个任务都请使用 `RAILS_ENV=production`。

```shell
# sudo -u git -H bundle exec rake gitlab:uploads:migrate

# Avatars
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AvatarUploader, Project, :avatar]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AvatarUploader, Group, :avatar]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AvatarUploader, User, :avatar]"

# Attachments
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :logo]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :header_logo]"

# Favicon
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[FaviconUploader, Appearance, :favicon]"

# Markdown
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[FileUploader, Project]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[PersonalFileUploader, Snippet]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[NamespaceFileUploader, Snippet]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[FileUploader, MergeRequest]"

# Design Management design thumbnails
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[DesignManagement::DesignV432x230Uploader, DesignManagement::Action]"
```

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-to-local-storage"></a>

## 迁移到本地存储

如果您因任何原因需要禁用[对象存储](../../object_storage.md)，必须先将数据从对象存储迁出，迁回本地存储。

> [!warning]
> 需要较长的停机时间，以确保迁移期间对象存储中不会创建新文件。允许在仅需短暂停机以更改配置的情况下
> 从对象存储迁移到本地文件这一配置设置，
> 已在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30979)中跟踪。
>
> 此外，在 Cloud Native GitLab 中，将数据迁移到本地存储通常是不安全的，因为本地存储是临时的，并且不会与所有 GitLab Rails 应用容器共享。

<a id="all-in-one-rake-task-1"></a>

### 一体化 Rake 任务

极狐GitLab 提供了一个包装 Rake 任务，可一步将所有上传的文件（例如头像、徽标、附件和网站图标）迁移到本地存储。该包装任务会逐个调用各个 Rake 任务，以迁移属于上述各类别的文件。

有关这些 Rake 任务的详细信息，请参阅[单独的 Rake 任务](#individual-rake-tasks)。请记住，此情况下的任务名称为 `gitlab:uploads:migrate_to_local`。

要将上传内容从对象存储迁移到本地存储：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
gitlab-rake "gitlab:uploads:migrate_to_local:all"
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:migrate_to_local:all
```

{{< /tab >}}

{{< /tabs >}}

运行 Rake 任务后，您可以通过撤销[配置对象存储](../../uploads.md#using-object-storage)说明中所述的更改来禁用对象存储。
