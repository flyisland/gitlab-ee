---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：创建、注册并运行自己的项目 runner'
---

本教程向您展示如何在极狐GitLab 中配置和运行您的第一个 runner。

runner 是极狐GitLab Runner 应用程序中的一个代理，用于在极狐GitLab CI/CD 流水线中运行作业。
作业在 `.gitlab-ci.yml` 文件中定义，并分配给可用的 runner。

极狐GitLab 有三种类型的 runner：

- 共享型：对极狐GitLab 实例中的所有群组和项目可用。
- 群组型：对群组中的所有项目和子群组可用。
- 项目型：与特定项目关联。通常，项目 runner 一次只供一个项目使用。

在本教程中，您将创建一个项目 runner 来运行基础流水线配置中定义的作业：

1. [创建空白项目](#create-a-blank-project)
1. [创建项目流水线](#create-a-project-pipeline)
1. [创建并注册项目 runner](#create-and-register-a-project-runner)
1. [触发流水线来运行您的 runner](#trigger-a-pipeline-to-run-your-runner)

<a id="before-you-begin"></a>

## 准备工作

在创建、注册和运行 runner 之前，您必须在本地计算机上[安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。

<a id="create-a-blank-project"></a>

## 创建空白项目

首先，创建一个空白项目，您可以在其中创建 CI/CD 流水线和 runner。

要创建空白项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/仓库**。
1. 选择 **创建空白项目**。
1. 输入项目详情：
   - 在 **项目名称** 字段中，输入您的项目名称。名称必须以小写或大写字母 (`a-zA-Z`)、数字 (`0-9`)、表情符号或下划线 (`_`) 开头。还可以包含点 (`.`)、加号 (`+`)、破折号 (`-`) 或空格。
   - 在 **项目路径** 字段中，输入项目的路径。极狐GitLab 实例会使用该路径作为项目的 URL 路径。要更改路径，请先输入项目名称，然后更改路径。
1. 选择 **创建项目**。

<a id="create-a-project-pipeline"></a>

## 创建项目流水线

接下来，为您的项目创建一个 `.gitlab-ci.yml` 文件。这是一个 YAML 文件，用于指定极狐GitLab CI/CD 的指令。

在此文件中，您定义：

- runner 应执行的作业结构和顺序。
- runner 在遇到特定情况时应做出的决策。

1. 在顶部导航栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 选择 **项目概览**。
1. 选择加号图标 ({{< icon name="plus" >}})，然后选择 **新文件**。
1. 在 **文件名** 字段中，输入 `.gitlab-ci.yml`。
1. 在大文本框中，粘贴以下示例配置：

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

   在此配置中，有两个 runner 运行的作业：构建作业和测试作业。
1. 选择 **提交变更**。

<a id="create-and-register-a-project-runner"></a>

## 创建并注册项目 runner

接下来，创建项目 runner 并进行注册。您必须注册 runner 以将其链接到极狐GitLab，以便它可以从项目流水线中获取作业。

要创建项目 runner：

1. 在顶部导航栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners** 部分。
1. 选择 **创建项目 runner**。
1. 在 **标签** 部分，选中 **运行未标记** 复选框。[标签](../../ci/runners/configure_runners.md#control-jobs-that-a-runner-can-run) 指定 runner 可以运行哪些作业，此步骤为可选。
1. 选择 **创建 runner**。
1. 选择您的操作系统。
1. 按照屏幕上的说明从命令行注册 runner。当提示时：
   - 对于 `执行器`，因为您的 runner 将直接在主机上运行，请输入 `shell`。[执行器](https://gitlab.cn/docs/runner/executors/) 是 runner 执行作业的环境。
   - 对于 `极狐GitLab 实例 URL`，使用您的极狐GitLab 实例的 URL。例如，如果您的项目托管在 `gitlab.example.com/yourname/yourproject`，那么您的极狐GitLab 实例 URL 是 `https://gitlab.example.com`。如果您的项目托管在 JihuLab.com 上，则 URL 是 `https://jihulab.com`。
1. 启动您的 runner：

   ```shell
   gitlab-runner run
   ```

<a id="check-the-runner-configuration-file"></a>

### 检查 runner 配置文件

注册 runner 后，配置和 runner 认证令牌会保存到您的 `config.toml` 文件中。runner 使用该令牌在从作业队列中获取作业时向极狐GitLab 认证。

您可以使用 `config.toml` 定义更多[高级 runner 配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)。

注册并启动 runner 后，您的 `config.toml` 应如下所示：

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

## 触发流水线来运行您的 runner

接下来，在您的项目中触发流水线，以便查看您的 runner 执行作业。

1. 在顶部导航栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择 **新流水线**。
1. 选择一个作业以查看作业日志。输出应类似于以下示例，显示您的 runner 成功执行了作业：

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

您现在已经成功创建、注册并运行了您的第一个 runner！