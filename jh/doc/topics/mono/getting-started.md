---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Mono, Repo, Project, labels.
title: 如何安装 Mono 与基本工作流程
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/2861)于极狐GitLab 16.4。[功能标志](../../user/feature_flags.md)为 `ff_monorepo`，默认禁用。

本文介绍如何安装 Mono 工具，并提供一个基本工作流示例。

<a id="installation-preparation"></a>

## 安装准备

1. 您的计算机需要安装 Python 3.6+。您可以用以下命令检测

    ```bash
    /usr/bin/env python --version
    ```

2. 准备好包含 manifest 文件（默认为 `default.xml`）的项目，作为 mono 工具的初始化项目。您可以在 manifest 文件中配置要通过 mono 管理的多代码仓库，示例如下：


    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
      <remote name="origin" fetch=".." />
      <default revision="main" remote="origin" sync-j="4" />
      <project path="local-dirname/repo1" name="root-group/repo1"/>
      <project path="local-dirname/repo2" name="root-group/repo2" />
    </manifest>
    ```

    在 `project` 标签中：
    - `path`：指定代码仓库在**本地**的存储路径
    - `name`：指定代码仓库在极狐GitLab **服务端**的项目路径

## 安装步骤

安装 mono 工具并完成初始化的步骤如下：

1. 使用以下命令，在当前目录下载 mono 安装脚本：

    ```bash
    mkdir -p ~/.bin
    PATH="${HOME}/.bin:${PATH}"
    curl https://jihulab.com/gitlab-cn/mono-client/-/raw/main-jh/mono?inline=false > ~/.bin/mono
    chmod a+rx ~/.bin/mono
    ```
    
1. 使用 [init 命令](../mono/command-line-options.md#init)，安装并初始化 mono 工具。假设初始化项目为 `example-group/root-project`，则初始化命令为：
    
    ```bash
    mono init -u git@jihulab.com:example-group/root-project.git
    ```          

1. 使用 [sync 命令](../mono/command-line-options.md#sync)，下载初始化项目的 manifest 文件中指定的仓库：

    ```bash
    mono sync
    ```


1. 下载成功后，使用 info 命令可以查看本地项目的信息，例如：

	```bash
	$ mono info
	Manifest branch: main
	Manifest merge branch: refs/heads/main
	Manifest groups: default,platform-linux
	----------------------------
	Project: test-mono/repo1
	Mount path: /home/Deer/test-mono/local-dirname/repo1
	Current revision: f20311818185d6e82e5cf6b9758f2fab37409af1
	Manifest revision: main
	Local Branches: 0
	----------------------------
	Project: test-mono/repo2
	Mount path: /home/Deer/test-mono/local-dirname/repo2
	Current revision: 3695cbd74d2bf4fdc49d91380494dba25e78338f
	Manifest revision: main
	Local Branches: 0
	----------------------------
	```

## 基本工作流程

安装完成后，使用 Mono 工具与代码库交互的基本工作流如下：

1. 使用 [start 命令](../mono/command-line-options.md#start)，在本地创建主题分支，例如在项目 `local-dirname/repo1` 中创建分支 `feature30`：

    ```bash
    cd local-dirname/repo1
    mono start feature30 .
    ```

1. 进行代码变更后，使用以下命令暂存代码变更：

    ```bash
    git add
    ```

1. 使用 [status 命令](../mono/command-line-options.md#status)和 [diff 命令](../mono/command-line-options.md#diff)，分别查看文件变更状态和差异：

    ```bash
    mono status
    mono diff
    ```

1. 使用以下命令，提交代码变更：

    ```bash
    git commit -m 'commit message'    
    ```
    
1. 使用 [sync 命令](../mono/command-line-options.md#sync)拉取远端代码，检测是否有代码冲突；使用 [upload 命令](../mono/command-line-options.md#upload) 推送代码，并在极狐GitLab 上自动创建合并请求。

    ```bash
    mono sync
    mono upload
    ```
