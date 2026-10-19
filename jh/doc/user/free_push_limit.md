---
stage: Growth
group: Acquisition
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 基础版推送限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

在基础版中，将新文件推送到任何项目时，每个文件有 100 MiB 的限制。

如果将 100 MiB 或更大的新文件推送到基础版中的项目，会显示错误。例如：

```shell
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Delta compression using up to 10 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 100.03 MiB | 1.08 MiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
remote: GitLab: You are attempting to check in one or more files which exceed the 100MiB limit:

- 257cc5642cb1a054f08cc83f2d943e56fd3ebe99 (123 MiB)
- 5716ca5987cbf97d6bb54920bea6adde242d87e6 (396 MiB)

Please refer to https://docs.gitlab.com/user/free_user_limit/ for further information.
To https://gitlab.com/group/my-project.git
 ! [remote rejected] main -> main (pre-receive hook declined)
error: failed to push some refs to 'https://gitlab.com/group/my-project.git'
```

错误中列出的是文件的唯一 ID，而不是文件名。要根据唯一标识查找文件名，请运行以下命令：

```shell
tree -r | grep <id>
```

由于 Git 并非为妥善处理大型非文本数据而设计，您应使用 [Git LFS](../topics/git/lfs/_index.md) 处理这些文件。Git LFS 旨在与 Git 配合使用，以跟踪大型文件。

<a id="troubleshooting"></a>

## 故障排除

在尝试解决推送限制时，您可能会遇到以下问题。

<a id="error-message-displays-after-removing-large-file"></a>

### 移除大文件后仍显示错误消息

即使您已在本地代码仓库中删除大文件，仍可能遇到推送限制错误。要解决此问题，请尝试移除引入该大文件的提交。

更多信息，请参见[还原提交并修改历史](../topics/git/undo.md#revert-commits-and-modify-history)。
