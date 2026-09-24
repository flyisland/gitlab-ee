---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure and run your first CI/CD pipeline in 极狐GitLab.
title: '教程：创建并运行您的第一个极狐GitLab CI/CD 流水线'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程向您展示如何在极狐GitLab 中配置并运行您的第一条 CI/CD 流水线。

如果您已经熟悉[基本 CI/CD 概念](../_index.md)，您可以学习[教程：创建复杂的流水线](tutorial.md)中的常用关键词。

<a id="prerequisites"></a>

## 前提条件

在开始之前，请确保您具有：

- 一个您想要为其使用 CI/CD 的极狐GitLab 项目。
- 项目上的维护者或所有者角色。

如果您没有项目，可以在 <https://jihulab.com> 上免费创建一个公开项目。

<a id="steps"></a>

## 步骤

要创建并运行您的第一条流水线：

1. [确保有可用的 Runner](#ensure-you-have-runners-available) 来运行您的作业。

   如果您使用的是 JihuLab.com，可以跳过此步骤。JihuLab.com 会为您提供实例 Runner。

1. [创建一个 `.gitlab-ci.yml` 文件](#create-a-gitlab-ciyml-file) 在您的仓库根目录下。这个文件是您定义 CI/CD 作业的地方。

当您向仓库提交文件时，Runner 会运行您的作业。作业结果[会显示在流水线中](#view-the-status-of-your-pipeline-and-jobs)。

<a id="ensure-you-have-runners-available"></a>

## 确保有可用的 Runner

在极狐GitLab 中，Runner 是运行 CI/CD 作业的代理。

如果您使用的是 JihuLab.com，可以跳过此步骤。JihuLab.com 会为您提供实例 Runner。

要查看可用的 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。

只要您至少有一个处于活动状态（旁边带有绿色圆圈）的 Runner，就有一个可用的 Runner 来处理您的作业。

如果您没有访问这些设置的权限，请联系您的极狐GitLab 管理员。

<a id="if-you-dont-have-a-runner"></a>

### 如果您没有 Runner

如果您没有 Runner：

1. 在您的本地机器上[安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 为您的项目[注册 Runner](https://gitlab.cn/docs/runner/register/)。选择 `shell` 执行器。

当您的 CI/CD 作业运行时，在后面的步骤中，它们将在您的本地机器上运行。

<a id="create-a-gitlab-ciyml-file"></a>

## 创建一个 `.gitlab-ci.yml` 文件

现在创建一个 `.gitlab-ci.yml` 文件。它是一个 [YAML](https://en.wikipedia.org/wiki/YAML) 文件，您在其中为极狐GitLab CI/CD 指定指令。

在此文件中，您可以定义：

- Runner 应执行的作业的结构和顺序。
- Runner 在遇到特定条件时应做出的决定。

要在项目中创建 `.gitlab-ci.yml` 文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **代码仓**。
1. 在文件列表上方，选择您要提交到的分支。如果不确定，保留 `master` 或 `main`。然后，在右上角，选择加号图标 ({{< icon name="plus" >}}) 和 **新建文件**：

   ![在当前文件夹中创建文件的新建文件按钮。](img/new_file_v18_11.png)

1. 对于 **文件名称**，输入 `.gitlab-ci.yml`，并在较大的窗口中粘贴以下示例代码：

   ```yaml
   build-job:
     stage: build
     script:
       - echo "你好，$GITLAB_USER_LOGIN！"

   test-job1:
     stage: test
     script:
       - echo "这个作业测试某些东西"

   test-job2:
     stage: test
     script:
       - echo "这个作业测试某些东西，但比 test-job1 花费更多时间。"
       - echo "在 echo 命令完成后，它运行 sleep 命令 20 秒"
       - echo "这模拟了一个比 test-job1 多运行 20 秒的测试"
       - sleep 20

   deploy-prod:
     stage: deploy
     script:
       - echo "这个作业从 $CI_COMMIT_BRANCH 分支部署某些东西。"
     environment: production
   ```

   此示例显示了四个作业：`build-job`、`test-job1`、`test-job2` 和 `deploy-prod`。`echo` 命令中列出的注释会在您查看作业时显示在 UI 中。[预定义变量](../variables/predefined_variables.md) `$GITLAB_USER_LOGIN` 和 `$CI_COMMIT_BRANCH` 的值会在作业运行时填充。

1. 选择 **提交更改**。

流水线启动并运行您在 `.gitlab-ci.yml` 文件中定义的作业。

<a id="view-the-status-of-your-pipeline-and-jobs"></a>

## 查看流水线和作业的状态

现在来看看您的流水线及其中的作业。

1. 转到 **构建** > **流水线**。应该会显示一个包含三个阶段的流水线：

   ![流水线列表显示了一个正在运行的包含 3 个阶段的流水线](img/three_stages_v18_11.png)

1. 通过选择流水线 ID（此示例中为 `#676`）查看流水线的可视化表示：

   ![流水线图显示了每个作业、其状态以及跨所有阶段的依赖关系。](img/pipeline_graph_v18_11.png)

1. 通过选择作业名称来查看作业的详细信息。例如， `deploy-prod`：

   ![作业详情页面显示了当前状态、计时信息以及作业日志的输出。](img/job_details_v18_11.png)

您已经成功在极狐GitLab 中创建了您的第一条 CI/CD 流水线。恭喜！

现在您可以开始自定义 `.gitlab-ci.yml` 并定义更高级的作业。

<a id="gitlab-ciyml-tips"></a>

## `.gitlab-ci.yml` 提示

以下是一些使用 `.gitlab-ci.yml` 文件入门的提示。

有关完整的 `.gitlab-ci.yml` 语法，请参阅完整的 [CI/CD YAML 语法参考](../yaml/_index.md)。

- 使用[流水线编辑器](../pipeline_editor/_index.md)编辑您的 `.gitlab-ci.yml` 文件。
- 每个作业包含一个脚本部分，并属于一个阶段：
  - [`stage`](../yaml/_index.md#stage) 描述了作业的顺序执行。如果有可用的 Runner，单个阶段中的作业将并行运行。
  - 使用 [`needs` 关键词](../yaml/_index.md#needs) 来[按非阶段顺序运行作业](../yaml/needs.md)，以提高流水线的速度和效率。
- 您可以设置额外的配置来自定义作业和阶段的执行方式：
  - 使用 [`rules` 关键词](../yaml/_index.md#rules) 来指定何时运行或跳过作业。旧版 `only` 和 `except` 关键词仍然受支持，但不能与 `rules` 在同一个作业中使用。
  - 通过 [`cache`](../yaml/_index.md#cache) 和 [`artifacts`](../yaml/_index.md#artifacts) 使作业和阶段之间的信息在流水线中保持持久。这些关键词是存储依赖项和作业输出的方式，即使每个作业使用临时的 Runner。
  - 使用 [`default`](../yaml/_index.md#default) 关键词来指定应用于所有作业的额外配置。该关键词通常用于定义应在每个作业上运行的 [`before_script`](../yaml/_index.md#before_script) 和 [`after_script`](../yaml/_index.md#after_script) 部分。