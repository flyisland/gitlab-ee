---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 上传文件清洗 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

上传的 JPG 或 TIFF 图片中的 EXIF 数据会被自动移除。

EXIF 数据可能包含敏感信息（例如 GPS 位置），因此你可以从已上传到较早版本 极狐GitLab 的现有图片中移除 EXIF 数据。

<a id="prerequisite"></a>

## 前提条件

要运行此 Rake 任务，你需要在系统中安装 `exiftool`。如果你安装的 极狐GitLab：

- 使用 Linux 软件包安装，就已经准备就绪。
- 使用自行编译安装，请确保已安装 `exiftool`：

  ```shell
  # Debian/Ubuntu
  sudo apt-get install libimage-exiftool-perl

  # RHEL/CentOS
  sudo yum install perl-Image-ExifTool
  ```

<a id="remove-exif-data-from-existing-uploads"></a>

## 从现有上传文件中移除 EXIF 数据

要从现有上传文件中移除 EXIF 数据，请运行以下命令：

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:sanitize:remove_exif
```

默认情况下，此命令以“试运行”模式运行，不会移除 EXIF 数据。它可以用来检查有哪些图片（以及多少张）需要被清洗。

此 Rake 任务接受以下参数。

| 参数 | 类型 | 描述 |
|:-------------|:--------|:----------------------------------------------------------------------------------------------------------------------------|
| `start_id` | integer | 仅处理 ID 大于或等于此值的上传文件 |
| `stop_id` | integer | 仅处理 ID 小于或等于此值的上传文件 |
| `dry_run` | boolean | 不移除 EXIF 数据，只检查是否存在 EXIF 数据。默认为 `true` |
| `sleep_time` | float | 处理每张图片后暂停的秒数。默认为 0.3 秒 |
| `uploader` | string | 仅对指定上传器（`FileUploader`、`PersonalFileUploader` 或 `NamespaceFileUploader`）的上传文件执行清洗 |
| `since` | date | 仅对晚于给定日期的上传文件执行清洗。例如 `2019-05-01` |

如果你有大量上传文件，可以通过以下方式加速清洗：

- 将 `sleep_time` 设置为更小的值。
- 并行运行多个 Rake 任务，每个任务处理不同的上传 ID 范围（通过设置 `start_id` 和 `stop_id`）。

要移除所有上传文件中的 EXIF 数据，请使用：

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:sanitize:remove_exif[,,false,] 2>&1 | tee exif.log
```

要移除 ID 介于 100 到 5000 之间的上传文件中的 EXIF 数据，并在处理每个文件后暂停 0.1 秒，请使用：

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:sanitize:remove_exif[100,5000,false,0.1] 2>&1 | tee exif.log
```

输出会写入 `exif.log` 文件，因为输出通常很长。

如果清洗某个上传文件失败，Rake 任务的输出中会包含错误消息。常见原因包括存储中缺少该文件，或该文件不是有效图片。

