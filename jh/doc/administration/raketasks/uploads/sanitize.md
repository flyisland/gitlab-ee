---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 上传内容清理 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

JPG 或 TIFF 图片上传中的 EXIF 数据会被自动剥离。

EXIF 数据可能包含敏感信息（例如 GPS 位置），因此您可以移除已上传到早期版本极狐GitLab 的现有图片中的 EXIF 数据。

<a id="prerequisite"></a>

## 先决条件

要运行此 Rake 任务，您的系统上需要安装 `exiftool`。如果您通过以下方式安装极狐GitLab：

- 使用 Linux 软件包，则无需额外操作。
- 使用自行编译的安装方式，请确保已安装 `exiftool`：

  ```shell
  # Debian/Ubuntu
  sudo apt-get install libimage-exiftool-perl

  # RHEL/CentOS
  sudo yum install perl-Image-ExifTool
  ```

<a id="remove-exif-data-from-existing-uploads"></a>

## 移除现有上传内容中的 EXIF 数据

要移除现有上传内容中的 EXIF 数据，请运行以下命令：

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:sanitize:remove_exif
```

默认情况下，此命令以“试运行”模式运行，不会移除 EXIF 数据。它可用于检查是否（以及有多少）图片应被清理。

该 Rake 任务接受以下参数。

| 参数    | 类型    | 描述                                                                                                                 |
|:-------------|:--------|:----------------------------------------------------------------------------------------------------------------------------|
| `start_id`   | integer | 仅处理 ID 等于或大于该值的上传内容                                                                     |
| `stop_id`    | integer | 仅处理 ID 等于或小于该值的上传内容                                                                     |
| `dry_run`    | boolean | 不移除 EXIF 数据，仅检查是否存在 EXIF 数据。默认为 `true`                                     |
| `sleep_time` | float   | 处理每张图片后暂停的秒数。默认为 0.3 秒                                            |
| `uploader`   | string  | 仅对指定上传器的上传内容执行清理：`FileUploader`、`PersonalFileUploader` 或 `NamespaceFileUploader` |
| `since`      | date    | 仅对晚于指定日期的上传内容执行清理。例如 `2019-05-01`                                          |

如果您的上传内容过多，可以通过以下方式加快清理速度：

- 将 `sleep_time` 设置为较低的值。
- 并行运行多个 Rake 任务，每个任务使用不同的上传 ID 范围（通过设置
  `start_id` 和 `stop_id`）。

要移除所有上传内容中的 EXIF 数据，请使用：

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:sanitize:remove_exif[,,false,] 2>&1 | tee exif.log
```

要移除 ID 在 100 到 5000 之间的上传内容中的 EXIF 数据，并在每个文件后暂停 0.1 秒，请使用：

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:uploads:sanitize:remove_exif[100,5000,false,0.1] 2>&1 | tee exif.log
```

输出会写入 `exif.log` 文件，因为输出内容通常很长。

如果某个上传内容的清理失败，Rake 任务的输出中应包含错误消息。常见原因包括存储中缺少该文件，或者该文件不是有效的图片。

[报告](https://gitlab.com/gitlab-org/gitlab/-/work_items/new)任何问题，并在议题标题中使用前缀 'EXIF'，同时附上错误输出以及（如果可能）该图片。
