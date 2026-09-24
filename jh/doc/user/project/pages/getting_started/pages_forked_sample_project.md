---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从派生的示例项目创建极狐GitLab Pages 网站
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了[针对最流行的静态站点生成器 (SSG) 的示例项目](https://gitlab.com/pages)。
您可以派生其中一个示例项目并运行 CI/CD 流水线来生成 Pages 网站。

当您想要测试极狐GitLab Pages 或启动一个已配置为生成 Pages 站点的新项目时，可以派生一个示例项目。

要派生示例项目并创建 Pages 网站：

1. 通过导航到 [极狐GitLab Pages 示例](https://gitlab.com/pages) 群组来查看示例项目。
1. 选择您想要[派生](../../repository/forking_workflow.md#create-a-fork)的项目名称。
1. 在右上角，选择 **派生**，然后选择一个命名空间进行派生。
1. 对于您的项目，在左侧边栏中，选择 **构建** > **流水线**，然后选择 **新建流水线**。
   极狐GitLab CI/CD 会构建并部署您的站点。

站点部署大约需要 30 分钟。
流水线完成后，转到 **部署** > **Pages** 以找到您的 Pages 网站的链接。

对于推送到仓库的每次更改，极狐GitLab CI/CD 都会运行一条新流水线，立即将您的更改发布到 Pages 站点。

<a id="remove-the-fork-relationship"></a>

## 移除派生关系

如果您想为派生来源项目做出贡献，可以保留派生关系。否则：

1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级设置**。
1. 选择 **移除派生关系**。

<a id="change-the-url"></a>

## 更改 URL

您可以更改 URL 以匹配您的命名空间。
如果您的 Pages 站点托管在 JihuLab.com 上，您可以将其重命名为 `<namespace>.gitlab.io`，其中 `<namespace>` 是您的极狐GitLab 命名空间（即您派生项目时选择的命名空间）。

1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 在 **更改路径** 中，将路径更新为 `<namespace>.gitlab.io`。

   例如，如果您的项目 URL 是 `gitlab.com/gitlab-tests/jekyll`，那么您的命名空间是 `gitlab-tests`。

   如果您将仓库路径设置为 `gitlab-tests.gitlab.io`，那么您的 Pages 网站的最终 URL 为 `https://gitlab-tests.gitlab.io`。

   ![更改仓库路径](img/change_path_v12_10.png)

1. 打开您的 SSG 配置文件，并将[基础 URL](../getting_started_part_one.md#urls-and-base-urls) 从 `"project-name"` 更改为 `""`。项目名称设置因 SSG 而异，并且可能不在配置文件中。

