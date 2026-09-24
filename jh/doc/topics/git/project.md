---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 `git push` 创建项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以使用 `git push` 将本地项目仓库添加到极狐GitLab。添加仓库后，极狐GitLab 会在你选择的命名空间中创建项目。

> [!note]
> 你不能使用 `git push` 创建路径曾被使用过或[重命名](../../user/project/working_with_projects.md#rename-a-repository)的项目。
> 曾经使用的项目路径存在重定向。重定向会导致推送尝试将请求重定向到已重命名的项目位置，而不是创建新项目。
> 要为曾经使用或已重命名的项目创建新项目，请使用用户界面或[项目 API](../../api/projects.md#create-a-project)。

前提条件：

<!--- 要通过 SSH 推送，你必须拥有一个[已添加到极狐GitLab 账户的 SSH 密钥](../../ssh.md#add-an-ssh-key-to-your-gitlab-account)。 --->
- 你必须拥有向[命名空间](../../user/namespace/_index.md)添加新项目的权限。
  验证你的权限：

  1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
  1. 在右上角，确认 **新项目** 可见。

  如果你没有所需的权限，请联系你的极狐GitLab 管理员。

要通过 `git push` 创建项目：

1. 使用以下任一方式将本地仓库推送到极狐GitLab：

   - 使用 SSH：

     - 如果你的项目使用标准端口 22，运行：

       ```shell
       git push --set-upstream git@gitlab.example.com:namespace/myproject.git main
       ```

     - 如果你的项目需要非标准端口号，运行：

       ```shell
       git push --set-upstream ssh://git@gitlab.example.com:00/namespace/myproject.git main
       ```

   - 使用 HTTP，运行：

     ```shell
     git push --set-upstream https://gitlab.example.com/namespace/myproject.git master
     ```

     替换以下值：

     - `gitlab.example.com` 替换为托管你的 Git 仓库的机器域名。
     - `namespace` 替换为你的[命名空间](../../user/namespace/_index.md)名称。
     - `myproject` 替换为你的项目名称。
     - 如果指定了端口，将 `00` 更改为你的项目所需端口号。
     - 可选。要导出已有的仓库标签，请在 `git push` 命令后添加 `--tags` 标志。

1. 可选。配置远程仓库：

   ```shell
   git remote add origin https://gitlab.example.com/namespace/myproject.git
   ```

当 `git push` 操作完成后，极狐GitLab 显示以下消息：

```shell
remote: 私有项目 namespace/myproject 已创建。
```

要查看你的新项目，请访问 `https://gitlab.example.com/namespace/myproject`。
默认情况下，项目可见性设置为 **私有**，但你可以[更改项目可见性](../../user/public_access.md#change-project-visibility)。

<a id="related-topics"></a>

## 相关主题

- [创建一个空白项目](../../user/project/_index.md)
- [从模板创建项目](../../user/project/_index.md#create-a-project-from-a-built-in-template)
- [克隆仓库到本地机器](clone.md)