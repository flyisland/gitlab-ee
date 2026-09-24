---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 文件锁定
---

文件锁定可以防止多人同时编辑同一个文件，从而有助于避免合并冲突。文件锁定对于无法合并的二进制文件（如设计文件、视频和其他非文本内容）尤其有价值。

极狐GitLab 支持两种不同类型的文件锁定：

- 排他文件锁：通过命令行，结合 Git LFS 和 [`.gitattributes`](repository/files/git_attributes.md) 进行应用。这些锁可以阻止在任何分支上对被锁定文件进行修改。适用于基础版、专业版和旗舰版。
  更多信息，请参见[排他文件锁](../../topics/git/file_management.md#exclusive-file-locks)。
- 默认分支文件和目录锁：通过极狐GitLab UI 进行应用。这些锁仅阻止在默认分支上对文件和目录的修改。

## 默认分支文件和目录锁

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认分支锁仅应用于项目设置中设定的[默认分支](repository/branches/default.md)。这些锁有助于在默认分支上保持稳定性，而不会阻碍其他分支上的协作工作流。

当某个文件或目录被用户锁定时：

- 只有创建锁的用户才能在默认分支上修改该文件或目录。
- 对于其他用户，被锁定的文件或目录在默认分支上是只读的。
- 在默认分支上对被锁定文件或目录的直接更改会被阻止。
- 修改了被锁定文件或目录的合并请求无法合并到默认分支。

> [!note]
> 在非默认分支上，所有用户仍然可以修改被锁定的文件和目录。
> 这些文件和目录上会显示一个**锁定**状态。这有助于团队成员
> 了解正在进行的工作，而不会限制他们在其他分支上的工作流。
>
> 在 Fork 同步过程中也会绕过文件锁定。
> 当你从上游项目[更新 Fork](repository/forking_workflow.md#update-your-fork)时，
> Fork 中被锁定的文件可能会被上游项目的更改覆盖。

### 权限

你必须具有项目的开发者、维护者或所有者角色，才能创建、查看或管理默认分支锁。更多信息，请参见[角色和权限](../permissions.md)。

### 锁定文件或目录

{{< history >}}

- 在极狐GitLab 17.10 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/519325)，[有功能标志](../../administration/feature_flags/_index.md) `blob_overflow_menu`。默认禁用。
- 在极狐GitLab 18.1 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/522993)。功能标志 `blob_overflow_menu` 已移除。

{{< /history >}}

锁定方法取决于你是锁定文件还是目录：

{{< tabs >}}

{{< tab title="锁定目录" >}}

1. 在顶部栏中，选择**搜索或跳转到**并找到你的项目。
1. 转到你想要锁定的目录。
1. 在右上角，选择**锁定**。
1. 在确认对话框中，选择**确认**。

要查看锁定目录的用户，请将鼠标悬停在**锁定**图标上。

{{< /tab >}}

{{< tab title="锁定文件" >}}

1. 在顶部栏中，选择**搜索或跳转到**并找到你的项目。
1. 转到你想要锁定的文件。
1. 在右上角，文件名旁边，选择**操作** ({{< icon name="ellipsis_v" >}}) > **锁定**。
1. 在确认对话框中，选择**确认**。

{{< /tab >}}

{{< /tabs >}}

如果锁定选项不可用或被禁用，则表明你没有锁定该文件或目录所需的权限。

### 查看已锁定的文件

查看已锁定的文件：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的项目。
1. 在左侧边栏中，选择**代码** > **已锁定的文件**。

**已锁定的文件**页面会显示所有通过 Git LFS 排他锁或极狐GitLab UI 锁定的文件。

### 移除文件锁

先决条件：

- 你必须满足以下条件之一：
  - 是创建锁的用户。
  - 具有项目的维护者或所有者角色。

移除锁：

{{< tabs >}}

{{< tab title="从文件移除" >}}

1. 在顶部栏中，选择**搜索或跳转到**并找到你的项目。
1. 转到你想要解锁的文件。
1. 选择**解锁**。
1. 在确认对话框中，选择**解锁**