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

在基础版中向任何项目推送新文件时，每个文件限制为 100 MiB。

如果向基础版项目推送一个大小等于或超过 100 MiB 的新文件，则会显示错误。例如：

```shell
枚举对象: 3, 完成.
对象计数: 100% (3/3), 完成.
使用最多 10 个线程进行增量压缩
压缩对象: 100% (2/2), 完成.
写入对象: 100% (3/3), 100.03 MiB | 1.08 MiB/s, 完成.
总计 3 (delta 0), 复用 0 (delta 0), pack-复用 0
remote: 极狐GitLab: 你正在尝试检入一个或多个超过 100MiB 限制的文件:

- 257cc5642cb1a054f08cc83f2d943e56fd3ebe99 (123 MiB)
- 5716ca5987cbf97d6bb54920bea6adde242d87e6 (396 MiB)

更多信息请参考 https://gitlab.cn/docs/user/free_user_limit/。
到 https://jihulab.com/group/my-project.git
 ! [远程拒绝] main -> main (pre-receive hook 被拒绝)
错误: 未能推送一些引用到 'https://jihulab.com/group/my-project.git'
```

错误信息列出了文件的唯一标识符而非文件名。要查找文件名，请运行以下命令：

```shell
tree -r | grep <id>
```

由于 Git 并非为处理大型非文本数据而设计，你应该为这些文件使用 [Git LFS](../topics/git/lfs/_index.md)。Git LFS 旨在与 Git 配合跟踪大文件。

<a id="troubleshooting"></a>

## 故障排除

在尝试解决推送限制时，你可能会遇到以下问题。

<a id="error-message-displays-after-removing-large-file"></a>

### 移除大文件后仍显示错误信息

即使你从本地仓库删除了大文件，仍可能收到推送限制错误。要解决此问题，请尝试删除引入该大文件的提交。

更多信息，请参见[还原提交并修改历史](../topics/git/undo.md#revert-commits-and-modify-history)。