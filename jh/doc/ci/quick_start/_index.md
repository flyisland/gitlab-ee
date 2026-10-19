---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中配置并运行您的第一个 CI/CD 流水线。
title: '教程：创建并运行您的第一个极狐GitLab CI/CD 流水线'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程向您展示如何在极狐GitLab 中配置并运行您的第一个 CI/CD 流水线。

如果您已经熟悉[基本的 CI/CD 概念](../_index.md)，可以了解[教程：创建复杂的流水线](tutorial.md)中的常用关键字。

<a id="prerequisites"></a>

## 先决条件

在开始之前，请确保您已具备：

- 极狐GitLab 中一个您希望为其使用 CI/CD 的项目。
- 该项目的维护者或所有者角色。

如果您没有项目，可以在 <https://jihulab.com> 上创建一个公开项目。

<a id="steps"></a>

## 步骤

要创建并运行您的第一个流水线：

1. [确保您有可用的 runner](#ensure-you-have-runners-available) 来运行您的作业。

   如果您使用的是 JihuLab.com，可以跳过此步骤。JihuLab.com 会为您提供实例 runner。

1. 在代码仓库的根目录下[创建 `.gitlab-ci.yml` 文件](#create-a-gitlab-ciyml-file)。
   该文件是您定义 CI/CD 作业的地方。

当您将该文件提交到代码仓库后，runner 会运行您的作业。作业结果[会显示在流水线中](#view-the-status-of-your-pipeline-and-jobs)。

<a id="ensure-you-have-runners-available"></a>

## 确保您有可用的 runner

在极狐GitLab 中，runner 是运行您的 CI/CD 作业的代理。

如果您使用的是 JihuLab.com，可以跳过此步骤。JihuLab.com 会为您提供实例 runner。

要查看可用的 runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。

只要您至少有一个处于活动状态的 runner，且其旁边有绿色圆圈，您就有可用的 runner 来处理您的作业。

如果您无权访问这些设置，请联系您的极狐GitLab 管理员。

<a id="if-you-dont-have-a-runner"></a>

### 如果您没有 runner

如果您没有 runner：

1. 在本地机器上[安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 为您的项目[注册该 runner](https://gitlab.cn/docs/runner/register/)。
   选择 `shell` 执行器。

当您的 CI/CD 作业在后续步骤中运行时，它们会在您的本地机器上运行。

<a id="create-a-gitlab-ciyml-file"></a>

## 创建 `.gitlab-ci.yml` 文件

现在创建一个 `.gitlab-ci.yml` 文件。它是一个 [YAML](https://en.wikipedia.org/wiki/YAML) 文件，您可以在其中
为极狐GitLab CI/CD 指定指令。

在该文件中，您定义：

- runner 应执行的作业的结构和顺序。
- runner 在遇到特定条件时应做出的决策。

要在您的项目中创建 `.gitlab-ci.yml` 文件：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 在文件列表上方，选择您要提交到的分支。
   如果不确定，请保留默认分支。
   然后，在右上角，选择加号图标 ({{< icon name="plus" >}}) 和**新建文件**：

   ![用于在当前文件夹中创建文件的新建文件按钮。](img/new_file_v18_11.png)

1. 在**文件名**中，输入 `.gitlab-ci.yml`，然后在较大的窗口中
   粘贴以下示例代码：

   ```yaml
   build-job:
     stage: build
     script:
       - echo "Hello, $GITLAB_USER_LOGIN!"

   test-job1:
     stage: test
     script:
       - echo "This job tests something"

   test-job2:
     stage: test
     script:
       - echo "This job tests something, but takes more time than test-job1."
       - echo "After the echo commands complete, it runs the sleep command for 20 seconds"
       - echo "which simulates a test that runs 20 seconds longer than test-job1"
       - sleep 20

   deploy-prod:
     stage: deploy
     script:
       - echo "This job deploys something from the $CI_COMMIT_BRANCH branch."
     environment: production
   ```

   此示例展示了四个作业：`build-job`、`test-job1`、`test-job2` 和 `deploy-prod`。
   `echo` 命令中列出的注释会在您查看作业时显示在 UI 中。
   [预定义变量](../variables/predefined_variables.md)
   `$GITLAB_USER_LOGIN` 和 `$CI_COMMIT_BRANCH`的值会在作业运行时填充。

1. 选择**提交更改**。

流水线会启动并运行您在 `.gitlab-ci.yml` 文件中定义的作业。

<a id="view-the-status-of-your-pipeline-and-jobs"></a>

## 查看您的流水线和作业的状态

现在来看看您的流水线及其作业。

1. 转到**构建** > **流水线**。应显示一个包含三个阶段的流水线：

   ![流水线列表显示一个正在运行的流水线，包含 3 个阶段](img/three_stages_v18_11.png)

1. 通过选择流水线 ID（本示例中为 `#2435445330`）查看流水线的可视化表示：

   ![流水线图显示每个作业、其状态以及它在所有阶段中的依赖关系。](img/pipeline_graph_v18_11.png)

1. 通过选择作业名称查看作业的详细信息。例如，`deploy-prod`：

   ![作业详情页显示当前状态、时间信息以及作业日志的输出。](img/job_details_v18_11.png)

您已成功在极狐GitLab 中创建了您的第一个 CI/CD 流水线。恭喜！

现在您可以开始自定义您的 `.gitlab-ci.yml` 并定义更高级的作业了。

<a id="gitlab-ciyml-tips"></a>

## `.gitlab-ci.yml` 提示

以下是一些帮助您开始使用 `.gitlab-ci.yml` 文件的提示。

有关完整的 `.gitlab-ci.yml` 语法，请参阅完整的 [CI/CD YAML 语法参考](../yaml/_index.md)。

- 使用[流水线编辑器](../pipeline_editor/_index.md)来编辑您的 `.gitlab-ci.yml` 文件。
- 每个作业都包含一个 script 部分，并属于某个阶段：
  - [`stage`](../yaml/_index.md#stage) 描述作业的顺序执行。
    如果有可用的 runner，单个阶段中的作业会并行运行。
  - 使用 [`needs` 关键字](../yaml/_index.md#needs)来[不按阶段顺序运行作业](../yaml/needs.md)，
    以提高流水线的速度和效率。
- 您可以设置额外的配置来自定义作业和阶段的执行方式：
  - 使用 [`rules`](../yaml/_index.md#rules) 关键字来指定何时运行或跳过作业。
    旧版 `only` 和 `except` 关键字仍受支持，但不能
    与 `rules` 在同一作业中使用。
  - 使用 [`cache`](../yaml/_index.md#cache)
    和 [`artifacts`](../yaml/_index.md#artifacts) 在流水线中跨作业和阶段持久保留信息。这些关键字是存储
    依赖项和作业输出的方式，即使为每个作业使用临时 runner 也是如此。
  - 使用 [`default`](../yaml/_index.md#default) 关键字来指定应用于所有作业的
    额外配置。该关键字通常用于定义
    应在每个作业上运行的
    [`before_script`](../yaml/_index.md#before_script) 和 [`after_script`](../yaml/_index.md#after_script)
    部分。
