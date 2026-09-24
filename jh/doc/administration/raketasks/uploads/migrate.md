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

有一个 Rake 任务用于在不同存储类型之间迁移上传文件。

- 使用 [`gitlab:uploads:migrate:all`](#all-in-one-rake-task) 迁移所有上传文件，或
- 要仅迁移特定上传类型，请使用 [`gitlab:uploads:migrate`](#individual-rake-tasks)。

<a id="migrate-to-object-storage"></a>

## 迁移至对象存储

在为极狐GitLab 的上传文件[配置对象存储](../../uploads.md#using-object-storage)后，使用此任务将现有上传文件从本地存储迁移到远程存储。

所有处理在后台工作进程中完成，且**无需停机**。

了解更多关于[极狐GitLab 与对象存储](../../object_storage.md)的使用信息。

<a id="all-in-one-rake-task"></a>

### 一体化 Rake 任务

极狐GitLab 提供了一个封装 Rake 任务，可一步将所有上传文件（如头像、标志、附件和 favicon）迁移至对象存储。该封装任务会逐个调用各个 Rake 任务，按类别逐一迁移文件。

这些[单独的 Rake 任务](#individual-rake-tasks)将在下一节中描述。

要将所有上传文件从本地存储迁移至对象存储，请运行：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
gitlab-rake "gitlab:uploads:migrate:all"
```

{{< /tab >}}

{{< tab title="自编译版（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:migrate:all
```

{{< /tab >}}

{{< /tabs >}}

您可以选择使用 [PostgreSQL 控制台](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database) 跟踪进度并验证所有上传文件是否已成功迁移：

- 对于 Linux 软件包安装：`sudo gitlab-rails dbconsole --database main`
- 对于自编译安装：`sudo -u git -H psql -d gitlabhq_production`

验证以下 `objectstg`（其中 `store=2`）的产物数量：

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

如果您已经运行了[一体化 Rake 任务](#all-in-one-rake-task)，则无需运行这些单独的任务。

该 Rake 任务使用三个参数来查找要迁移的上传文件：

| 参数            | 类型          | 描述                                                         |
|:-----------------|:--------------|:-------------------------------------------------------------|
| `uploader_class` | string        | 要从中迁移的上传器类型。                                    |
| `model_class`    | string        | 要从中迁移的模型类型。                                      |
| `mount_point`    | string/symbol | 上传器挂载的模型列名称。                                    |

> [!note]
> 这些参数主要供极狐GitLab 结构内部使用，建议参考下方的任务列表。运行这些单独的任务后，我们建议您运行[一体化 Rake 任务](#all-in-one-rake-task)以迁移未包含在所列类型中的任何上传文件。

该任务还接受一个环境变量，您可以使用它来覆盖默认的批量大小：

| 变量     | 类型    | 描述                                                 |
|:---------|:--------|:------------------------------------------------------|
| `BATCH`  | integer | 指定批量大小。默认为 200。                            |

以下显示如何针对特定上传类型运行 `gitlab:uploads:migrate`。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
# gitlab-rake gitlab:uploads:migrate[uploader_class, model_class, mount_point]

# 头像
gitlab-rake "gitlab:uploads:migrate[AvatarUploader, Project, :avatar]"
gitlab-rake "gitlab:uploads:migrate[AvatarUploader, Group, :avatar]"
gitlab-rake "gitlab:uploads:migrate[AvatarUploader, User, :avatar]"

# 附件
gitlab-rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :logo]"
gitlab-rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :header_logo]"

# Favicon
gitlab-rake "gitlab:uploads:migrate[FaviconUploader, Appearance, :favicon]"

# Markdown
gitlab-rake "gitlab:uploads:migrate[FileUploader, Project]"
gitlab-rake "gitlab:uploads:migrate[PersonalFileUploader, Snippet]"
gitlab-rake "gitlab:uploads:migrate[NamespaceFileUploader, Snippet]"
gitlab-rake "gitlab:uploads:migrate[FileUploader, MergeRequest]"

# 设计管理设计缩略图
gitlab-rake "gitlab:uploads:migrate[DesignManagement::DesignV432x230Uploader, DesignManagement::Action, :image_v432x230]"
```

{{< /tab >}}

{{< tab title="自编译版（源代码）" >}}

每个任务都要使用 `RAILS_ENV=production`。

```shell
# sudo -u git -H bundle exec rake gitlab:uploads:migrate

# 头像
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AvatarUploader, Project, :avatar]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AvatarUploader, Group, :avatar]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AvatarUploader, User, :avatar]"

# 附件
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :logo]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[AttachmentUploader, Appearance, :header_logo]"

# Favicon
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[FaviconUploader, Appearance, :favicon]"

# Markdown
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[FileUploader, Project]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[PersonalFileUploader, Snippet]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[NamespaceFileUploader, Snippet]"
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[FileUploader, MergeRequest]"

# 设计管理设计缩略图
sudo -u git -H bundle exec rake "gitlab:uploads:migrate[DesignManagement::DesignV432x230Uploader, DesignManagement::Action]"
```

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-to-local-storage"></a>

## 迁移至本地存储

如果出于任何原因需要禁用[对象存储](../../object_storage.md)，则必须先将数据从对象存储迁移回本地存储。

> [!warning]
> **需要延长停机时间**，以便在迁移期间不会在对象存储中创建新文件。关于允许在配置更改只需短暂停机的情况下从对象存储迁移到本地文件的功能，正在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30979)中跟踪。
>
> **此外，**在云原生极狐GitLab 中，将数据迁移到本地存储通常不安全，因为本地存储是临时的，并且不与所有极狐GitLab Rails 应用容器共享。

<a id="all-in-one-rake-task-1"></a>

### 一体化 Rake 任务

极狐GitLab 提供了一个封装 Rake 任务，可一步将所有上传文件（如头像、标志、附件和 favicon）迁移至本地存储。该封装任务会逐个调用各个 Rake 任务，按类别逐一迁移文件。

有关这些 Rake 任务的详细信息，请参阅[单独的 Rake 任务](#individual-rake-tasks)。注意，此处的任务名称为 `gitlab:uploads:migrate_to_local`。

要将上传文件从对象存储迁移至本地存储，请运行：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
gitlab-rake "gitlab:uploads:migrate_to_local:all"
```

{{< /tab >}}

{{< tab title="自编译版（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:migrate_to_local:all
```

{{< /tab >}}

{{< /tabs >}}

运行 Rake 任务后，您可以通过撤销[配置对象存储](../../uploads.md#using-object-storage)说明中所述的更改来禁用对象存储。