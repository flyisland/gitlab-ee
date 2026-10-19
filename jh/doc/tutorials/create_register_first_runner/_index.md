---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：创建、注册并运行您自己的项目 Runner'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程介绍如何在极狐GitLab 中配置并运行您的第一个 Runner。

Runner 是极狐GitLab Runner 应用程序中的一个代理，用于运行极狐GitLab CI/CD 流水线中的作业。
作业在 `.gitlab-ci.yml` 文件中定义，并分配给可用的 Runner。

极狐GitLab 有三种类型的 Runner：

- 共享：可供极狐GitLab 实例中的所有群组和项目使用。
- 群组：可供某个群组中的所有项目和子群组使用。
- 项目：与特定项目关联。通常，项目 Runner 一次只由一个项目使用。

在本教程中，您将创建一个项目 Runner，用于运行基本流水线配置中定义的作业：

1. [创建空白项目](#create-a-blank-project)
1. [创建项目流水线](#create-a-project-pipeline)。
1. [创建并注册项目 Runner](#create-and-register-a-project-runner)。
1. [触发流水线以运行您的 Runner](#trigger-a-pipeline-to-run-your-runner)。

<a id="before-you-begin"></a>

## 开始之前

在创建、注册并运行 Runner 之前，您必须在本地计算机上[安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。

<a id="create-a-blank-project"></a>

## 创建空白项目

首先，创建一个空白项目，以便在其中创建 CI/CD 流水线和 Runner。

创建空白项目：

1. 在右上角，选择**创建新的** ({{< icon name="plus" >}}) 和**新建项目/仓库**。
1. 选择**创建空白项目**。
1. 输入项目详细信息：
   - 在**项目名称**字段中，输入项目名称。名称必须以小写或大写字母 (`a-zA-Z`)、数字 (`0-9`)、emoji 或下划线 (`_`) 开头。还可以包含点 (`.`)、加号 (`+`)、短横线 (`-`) 或空格。
   - 在**项目路径**字段中，输入项目的路径。极狐GitLab 实例使用
     该路径作为项目的 URL 路径。要更改路径，请先输入项目名称，
     然后更改路径。
1. 选择**创建项目**。

<a id="create-a-project-pipeline"></a>

## 创建项目流水线

接下来，为您的项目创建 `.gitlab-ci.yml` 文件。这是一个 YAML 文件，您可以在其中指定极狐GitLab CI/CD 的指令。

在该文件中，您需要定义：

- Runner 应执行的作业的结构和顺序。
- 遇到特定条件时 Runner 应做出的决策。

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
1. 选择**项目概览**。
1. 选择加号图标 ({{< icon name="plus" >}})，然后选择**新建文件**。
1. 在**文件名**字段中，输入 `.gitlab-ci.yml`。
1. 在大型文本框中，粘贴以下示例配置：

   ```yaml
   stages:
     - build
     - test

   job_build:
     stage: build
     script:
       - echo "Building the project"

   job_test:
     stage: test
     script:
       - echo "Running tests"
   ```

   在此配置中，Runner 会运行两个作业：一个构建作业和一个测试作业。
1. 选择**提交更改**。

<a id="create-and-register-a-project-runner"></a>

## 创建并注册项目 Runner

接下来，创建一个项目 Runner 并注册它。您必须注册 Runner 以将其关联到极狐GitLab，这样它才能从项目流水线中获取作业。

创建项目 Runner：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runner** 部分。
1. 选择**创建项目 Runner**。
1. 在**标签**部分，选中**运行未打标签的作业**复选框。[标签](../../ci/runners/configure_runners.md#control-jobs-that-a-runner-can-run)用于指定
   Runner 可以运行哪些作业，是可选的。
1. 选择**创建 Runner**。
1. 选择您的操作系统。
1. 按照屏幕上的说明从命令行注册 Runner。出现提示时：
   - 对于 `executor`，由于您的 Runner 将直接在主机上运行，请输入 `shell`。[executor](https://gitlab.cn/docs/runner/executors/)
     是 Runner 执行作业的环境。
   - 对于 `GitLab instance URL`，请使用您的极狐GitLab 实例的 URL。例如，如果您的项目
     托管在 `gitlab.example.com/yourname/yourproject`，那么您的极狐GitLab 实例 URL 就是 `https://gitlab.example.com`。
     如果您的项目托管在 JihuLab.com 上，则该 URL 为 `https://gitlab.com`。
1. 启动您的 Runner：

   ```shell
   gitlab-runner run
   ```

<a id="check-the-runner-configuration-file"></a>

### 检查 Runner 配置文件

注册 Runner 后，配置和 Runner 认证令牌会保存到您的 `config.toml`中。Runner 在从作业队列中获取作业时，会使用该令牌向极狐GitLab 进行认证。

您可以使用 `config.toml` 定义更多[高级 Runner 配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)。

注册并启动 Runner 后，您的 `config.toml` 应如下所示：

```toml
[[runners]]
  name = "my-project-runner1"
  url = "http://127.0.0.1:3000"
  id = 38
  token = "glrt-TOKEN"
  token_obtained_at = 2023-07-05T08:56:33Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "shell"
```

<a id="trigger-a-pipeline-to-run-your-runner"></a>

## 触发流水线以运行您的 Runner

接下来，在您的项目中触发流水线，以便查看您的 Runner 执行作业。

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择**新流水线**。
1. 选择一个作业以查看作业日志。输出应类似于以下示例，其中显示
   您的 Runner 成功执行了该作业：

   ```shell
      Running with gitlab-runner 18.0.0 (d7f2cea7)
      on my-project-runner TOKEN, system ID: SYSTEM ID
      Preparing the "shell" executor
      00:00
      Using Shell (bash) executor...
      Preparing environment
      00:00
      /Users/username/.bash_profile: line 9: setopt: command not found
      Running on MACHINE-NAME...
      Getting source from Git repository
      00:01
      /Users/username/.bash_profile: line 9: setopt: command not found
      Fetching changes with git depth set to 20...
      Reinitialized existing Git repository in /Users/username/project-repository
      Checking out 7226fc70 as detached HEAD (ref is main)...
      Skipping object checkout, Git LFS is not installed for this repository.
      Consider installing it with 'git lfs install'.
      Skipping Git submodules setup
      Executing "step_script" stage of the job script
      00:00
      /Users/username/.bash_profile: line 9: setopt: command not found
      $ echo "Building the project"
      Building the project
      Job succeeded

   ```

现在，您已成功创建、注册并运行了您的第一个 Runner！
