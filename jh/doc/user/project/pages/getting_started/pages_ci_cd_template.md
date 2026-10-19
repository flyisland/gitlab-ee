---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 CI/CD 模板创建 GitLab Pages 网站
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 为最流行的静态站点生成器（SSG）提供了 `.gitlab-ci.yml` 模板。您可以从这些模板之一创建自己的 `.gitlab-ci.yml` 文件，并运行
CI/CD 流水线来生成 Pages 网站。

当您有一个现有项目并想为其添加 Pages 站点时，可以使用 `.gitlab-ci.yml` 模板。

您的极狐GitLab 代码仓库应包含特定于 SSG 的文件或纯 HTML。完成这些步骤后，您可能还需要进行额外配置，Pages 站点才能正常生成。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 从**添加**（{{< icon name="plus" >}}）下拉列表中，选择**新建文件**。
1. 在**文件名**文本框中，输入 `.gitlab-ci.yml`。文本框右侧会出现一个下拉列表。
1. 从**应用模板**下拉列表的**页面**部分中，选择您的 SSG 名称。
   对于纯 HTML，请选择 **HTML**。
1. 在**提交信息**框中，输入提交信息。
1. 选择**提交更改**。

如果一切配置正确，站点部署大约需要 30 分钟。

要查看流水线，请转到**构建** > **流水线**。

当流水线完成后，转到**部署** > **页面**，找到指向您的 Pages 网站的链接。

对于推送到代码仓库的每次更改，极狐GitLab CI/CD 都会运行新的流水线，并立即将您的更改发布到 Pages 站点。

要查看为站点创建的 HTML 和其他资产，
[请下载作业产物](../../../../ci/jobs/job_artifacts.md#download-job-artifacts)。
