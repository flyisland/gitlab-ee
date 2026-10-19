---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 `git push` 创建项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 `git push` 将本地项目代码仓库添加到极狐GitLab。添加代码仓库后，极狐GitLab 会在您选择的命名空间中创建项目。

> [!note]
> 您不能使用 `git push` 创建路径曾被使用过或
> [重命名过](../../user/project/working_with_projects.md#rename-a-repository)的项目。
> 曾使用过的项目路径会有重定向。重定向不会创建新项目，
> 而是使推送请求重定向到重命名后的项目位置。
> 要为曾使用过或重命名过的项目创建新项目，请使用用户界面
> 或 [项目 API](../../api/projects.md#create-a-project)。

先决条件：

<!--- To push with SSH, you must have [an SSH key](../ssh.md) that is
  [added to your GitLab account](../ssh.md#add-an-ssh-key-to-your-gitlab-account).
-->
- 您必须有权向[命名空间](../../user/namespace/_index.md)添加新项目。
  要验证您的权限：

  1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
  1. 在右上角，确认**新建项目**可见。

  如果您没有所需的权限，请联系您的极狐GitLab 管理员。

要使用 `git push` 创建项目：

1. 使用以下方式之一将本地代码仓库推送到极狐GitLab：

   - 使用 SSH：

     - 如果您的项目使用标准端口 22，请运行：

       ```shell
       git push --set-upstream git@gitlab.example.com:namespace/myproject.git main
       ```

     - 如果您的项目需要非标准端口号，请运行：

       ```shell
       git push --set-upstream ssh://git@gitlab.example.com:00/namespace/myproject.git main
       ```

   - 使用 HTTP，请运行：

     ```shell
     git push --set-upstream https://gitlab.example.com/namespace/myproject.git master
     ```

     替换以下值：

     - `gitlab.example.com` 替换为托管您的 Git 代码仓库的机器域名。
     - `namespace` 替换为您的[命名空间](../../user/namespace/_index.md)名称。
     - `myproject` 替换为您的项目名称。
     - 如果指定端口，请将 `00` 更改为您的项目所需的端口号。
     - 可选。要导出已有的代码仓库标签，请将 `--tags` 标志附加到
       您的 `git push` 命令。

1. 可选。配置远程：

   ```shell
   git remote add origin https://gitlab.example.com/namespace/myproject.git
   ```

当 `git push` 操作完成后，极狐GitLab 会显示以下消息：

```shell
remote: The private project namespace/myproject was created.
```

要查看您的新项目，请转到 `https://gitlab.example.com/namespace/myproject`。默认情况下，您项目的可见性设置为**私有**，但您可以[更改项目的可见性](../../user/public_access.md#change-project-visibility)。
