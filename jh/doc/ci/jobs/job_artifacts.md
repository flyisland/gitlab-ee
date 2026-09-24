---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Create, download, browse, and manage job artifacts in 极狐GitLab CI/CD.
title: 作业产物
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

作业可以输出文件和目录的归档。这个输出称为作业产物。
产物可以包含构建输出或报告文件。默认情况下，后续作业会拉取之前阶段中所有作业的产物副本。

例如，一个早期作业可以构建一个项目，并将输出保存为产物。
然后一个后期作业拉取该产物，并对已保存的构建输出运行测试。

关于 `artifacts` 关键字的完整支持配置列表，
请参阅[极狐GitLab CI/CD YAML 语法参考](../yaml/_index.md#artifacts)。

相关主题：

- [作业产物 API](../../api/job_artifacts.md)
- [作业产物管理](../../administration/cicd/job_artifacts.md)

<a id="create-job-artifacts"></a>

## 创建作业产物

要创建作业产物，请在 `.gitlab-ci.yml` 文件中使用 `artifacts` 关键字：

```yaml
pdf:
  script: xelatex mycv.tex
  artifacts:
    paths:
      - mycv.pdf
```

在此示例中，一个名为 `pdf` 的作业调用 `xelatex` 命令，从 LaTeX 源文件 `mycv.tex` 构建 PDF 文件。

`paths` 关键字决定了哪些文件会被添加到作业产物中。
所有文件和目录的路径都是相对于创建作业的仓库的。

<a id="with-wildcards"></a>

### 使用通配符

你可以对路径和目录使用通配符。例如，创建一个包含所有以 `xyz` 结尾的目录中的文件的产物：

```yaml
job:
  script: echo "build xyz project"
  artifacts:
    paths:
      - path/*xyz/*
```

<a id="with-an-expiry"></a>

### 设置过期时间

`expire_in` 关键字决定了极狐GitLab 保留 `artifacts:paths` 中定义的产物的时长。例如：

```yaml
pdf:
  script: xelatex mycv.tex
  artifacts:
    paths:
      - mycv.pdf
    expire_in: 1 week
```

如果未定义 `expire_in`，将使用[**默认产物过期时间**](../../administration/settings/continuous_integration.md#set-default-artifacts-expiration)实例设置。

要防止产物过期，你可以在作业详情页选择 **保留**。
当产物没有设置过期时间时，此选项不可用。

默认情况下，每个引用上最近成功的流水线产物会始终保留。

<a id="with-an-explicitly-defined-artifact-name"></a>

### 显式定义产物名称

你可以使用 `artifacts:name` 配置来自定义产物名称：

```yaml
job:
  artifacts:
    name: "job1-artifacts-file"
    paths:
      - binaries/
```

<a id="without-excluded-files"></a>

### 排除文件

使用 `artifacts:exclude` 可以防止文件被添加到产物归档中。

例如，存储 `binaries/` 中的所有文件，但不包括位于 `binaries/` 子目录下的 `*.o` 文件：

```yaml
artifacts:
  paths:
    - binaries/
  exclude:
    - binaries/**/*.o
```

与 `artifacts:paths` 不同，`exclude` 路径不是递归的。要排除某个目录的所有内容，请明确匹配它们而不是匹配目录本身。

例如，存储 `binaries/` 中的所有文件，但排除 `temp/` 子目录下的所有内容：

```yaml
artifacts:
  paths:
    - binaries/
  exclude:
    - binaries/temp/**/*
```

<a id="with-untracked-files"></a>

### 包含未跟踪文件

使用 `artifacts:untracked` 可以将所有 Git 未跟踪的文件作为产物添加，同时包括在 `artifacts:paths` 中定义的路径。未跟踪文件是指尚未添加到仓库中但存在于仓库检出中的文件。

例如，保存所有 Git 未跟踪文件和 `binaries` 中的文件：

```yaml
artifacts:
  untracked: true
  paths:
    - binaries/
```

例如，保存所有未跟踪文件但排除 `*.txt` 文件：

```yaml
artifacts:
  untracked: true
  exclude:
    - "*.txt"
```

<a id="with-variable-expansion"></a>

### 变量扩展

`artifacts:name`、`artifacts:paths` 和 `artifacts:exclude` 支持变量扩展。

极狐GitLab Runner 不使用 Shell，而是使用其内部的变量扩展机制。
在此上下文中仅支持 CI/CD 变量。

例如，使用当前的分支或标签名称创建一个归档，并且只包含以当前项目命名的目录中的文件：

```yaml
job:
  artifacts:
    name: "$CI_COMMIT_REF_NAME"
    paths:
      - binaries/${CI_PROJECT_NAME}/
```

当你的分支名称包含正斜杠（例如 `feature/my-feature`）时，
请使用 `$CI_COMMIT_REF_SLUG` 而不是 `$CI_COMMIT_REF_NAME`，以确保产物命名正确。

变量会在通配符之前展开。

<a id="fetching-artifacts"></a>

## 拉取产物

默认情况下，作业会拉取之前阶段中定义的所有作业的产物。这些产物
会被下载到作业的工作目录中。

你可以使用 `dependencies` 或 `needs:artifacts` 关键字来控制要下载哪些产物。

当你使用这些关键字时，默认行为会发生改变，只会从你指定的作业中拉取产物。

<a id="prevent-a-job-from-fetching-artifacts"></a>

### 防止作业拉取产物

要防止作业下载任何产物，可以将 `dependencies` 设置为空数组（`[]`）：

```yaml
job:
  stage: test
  script: make build
  dependencies: []
```

<a id="view-all-job-artifacts-in-a-project"></a>

## 查看项目中的所有作业产物

{{< history >}}

- 在极狐GitLab 16.0 中 GA，功能标志 `artifacts_management_page` 被移除。

{{< /history >}}

你可以从 **构建** > **产物** 页面查看项目中存储的所有产物。
此列表显示了所有作业及其关联的产物。展开一个条目可以访问与作业关联的所有产物，包括：

- 使用 `artifacts:` 关键字创建的产物。
- 报告产物。
- 作业日志和元数据，它们被作为独立的产物内部存储。

你可以从此列表中下载或删除单个产物。

<a id="download-job-artifacts"></a>

## 下载作业产物

你可以通过极狐GitLab UI 或 API 下载作业产物。

从极狐GitLab UI 中，你可以从以下位置下载作业产物：

- 任何 **流水线** 列表。在流水线的右侧，选择 **下载产物** ({{< icon name="download" >}})。
- 任何 **作业** 列表。在作业的右侧，选择 **下载产物** ({{< icon name="download" >}})。
- 作业详情页。在页面右侧，选择 **下载**。
- 合并请求 **概览** 页面。在最新流水线的右侧，选择 **产物** ({{< icon name="download" >}})。
- **产物** 页面。在作业的右侧，选择 **下载** ({{< icon name="download" >}})。
- 产物浏览器。在页面顶部，选择 **下载产物归档** ({{< icon name="download" >}})。

[报告产物](../yaml/artifacts_reports.md) 只能从 **流水线** 列表或 **产物** 页面下载。

<a id="from-a-url"></a>

### 通过 URL

你可以使用一个公开可访问的 URL 下载特定作业的产物归档。

例如，要下载 JihuLab.com 上一个项目中 `main` 分支上名为 `build` 的作业的最新产物：

```plaintext
https://jihulab.com/api/v4/projects/<project-id>/jobs/artifacts/main/download?job=build
```

要从产物中下载特定文件：

```plaintext
https://jihulab.com/api/v4/projects/<project-id>/jobs/artifacts/main/raw/review/index.html?job=build
```

此端点返回的文件始终具有 `plain/text` 内容类型。

在这两个示例中，将 `<project-id>` 替换为有效的项目 ID。你可以在
[项目概览页面](../../user/project/working_with_projects.md#find-the-project-id) 找到项目 ID。

父子流水线的产物将按照从父到子的层级顺序进行搜索。
例如，如果父流水线和子流水线都有一个同名的作业，则将返回父流水线的作业产物。

<a id="with-a-cicd-job-token"></a>

### 使用 CI/CD 作业令牌

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以使用 CI/CD 作业令牌来认证作业产物 API 端点，并从另一个流水线拉取产物。你必须指定要从哪个作业检索产物，例如：

```yaml
build_submodule:
  stage: test
  script:
    - apt update && apt install -y unzip
    - |
      curl --location --output artifacts.zip \
        --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/main/download?job=test&job_token=$CI_JOB_TOKEN"
    - unzip artifacts.zip
```

要从同一流水线中的作业拉取产物，请使用 `needs:artifacts` 关键字。

<a id="control-who-can-download-artifacts"></a>

### 控制谁可以下载产物

要限制谁可以下载作业产物，请在 `.gitlab-ci.yml` 文件中使用 `artifacts:access` 关键字。例如：

```yaml
job:
  artifacts:
    access: maintainer
    paths:
      - build/
```

<a id="browse-the-contents-of-the-artifacts-archive"></a>

## 浏览产物归档内容

你可以在 UI 中浏览产物内容，而无需将产物下载到本地，可以从以下位置进行：

- 任何 **作业** 列表。在作业的右侧，选择 **浏览** ({{< icon name="folder-open" >}})。
- 作业详情页。在页面右侧，选择 **浏览**。
- **产物** 页面。在作业的右侧，选择 **浏览** ({{< icon name="folder-open" >}})。

如果极狐GitLab Pages 已在全局启用，即使项目设置中已禁用，
你仍然可以直接在浏览器中预览某些产物文件扩展名。如果项目是内部或私有的，你必须启用极狐GitLab Pages 访问控制才能启用预览。

支持以下扩展名：

| 文件扩展名 | JihuLab.com | 内置 NGINX 的 Linux 软件包 |
|------------|-------------|---------------------------|
| `.html`    | {{< yes >}} | {{< yes >}}               |
| `.json`    | {{< yes >}} | {{< yes >}}               |
| `.xml`     | {{< yes >}} | {{< yes >}}               |
| `.txt`     | {{< no >}}  | {{< yes >}}               |
| `.log`     | {{< no >}}  | {{< yes >}}               |

<a id="from-a-url"></a>

### 通过 URL

你可以使用一个公开可访问的 URL 浏览特定作业的最新成功流水线的作业产物。

例如，要浏览 JihuLab.com 上一个项目中 `main` 分支上名为 `build` 的作业的最新产物：

```plaintext
https://jihulab.com/<full-project-path>/-/jobs/artifacts/main/browse?job=build
```

将 `<full-project-path>` 替换为有效的项目路径，你可以在项目的 URL 中找到它。

<a id="delete-job-log-and-artifacts"></a>

## 删除作业日志和产物

> [!警告]
> 删除作业日志和产物是一项破坏性操作，无法撤销。请谨慎使用。
> 删除某些文件，包括报告产物、作业日志和元数据文件，会影响
> 极狐GitLab 将这些文件用作数据源的功能。

你可以删除作业的产物和日志。

前提条件：

- 你必须是作业的所有者，或者是具有项目维护者或所有者角色的用户。

要删除一个作业：

1. 转到作业的详情页。
1. 在作业日志的右上角，选择 **清除作业日志和产物** ({{< icon name="remove" >}})。

你也可以从 **产物** 页面删除单个产物。

<a id="bulk-delete-artifacts"></a>

### 批量删除产物

{{< history >}}

- 在极狐GitLab 15.10 中引入，使用功能标志 `ci_job_artifact_bulk_destroy`，默认禁用。
- 在极狐GitLab 16.1 中 GA，功能标志 `ci_job_artifact_bulk_destroy` 被移除。

{{< /history >}}

你可以同时删除多个产物：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **产物**。
1. 选择你想要删除的产物旁边的复选框。你最多可以选择 100 个产物。
1. 选择 **删除所选**。

<a id="link-to-job-artifacts-in-the-merge-request-ui"></a>

## 在合并请求界面中链接作业产物

使用 `artifacts:expose_as` 关键字可以从合并请求 UI 直接访问产物。

例如，对于一个包含单个文件的产物：

```yaml
test:
  script: ["echo 'test' > file.txt"]
  artifacts:
    expose_as: 'artifact 1'
    paths: ['file.txt']
```

使用此配置，**查看暴露的产物** 部分会显示一个指向 `file.txt` 的链接，标记为 **artifact 1**。

![一个链接到暴露的产物的合并请求组件。](img/mr_artifact_expose_v18_4.png)

<a id="keep-artifacts-from-most-recent-successful-jobs"></a>

## 保留最近成功作业的产物

{{< history >}}

- 从极狐GitLab 16.7 开始，[阻塞](https://gitlab.com/gitlab-org/gitlab/-/issues/387087)或[失败](https://gitlab.com/gitlab-org/gitlab/-/issues/266958)流水线的产物不再无限期保留。

{{< /history >}}

默认情况下，每个引用上最近成功的流水线产物会始终保留。
任何 `expire_in` 配置都不适用于最近一次的产物。

当同一引用上新的流水线成功完成时，前一个流水线的产物会根据 `expire_in` 配置被删除。新流水线的产物会被自动保留。

一个流水线的产物仅当同一引用上运行了新的流水线并且：

- 成功。
- 由于手动作业而受阻停止运行。

才会根据 `expire_in` 配置被删除。

在具有许多作业或大型产物的项目中，保留最新的产物可能会占用大量存储空间。如果项目中不需要最新的产物，你可以禁用此行为以节省空间：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **产物**。
1. 清除 **保留最近成功作业的产物** 复选框。

禁用此设置后，所有新的产物将根据 `expire_in` 配置过期。
旧流水线中的产物将继续保留，直到同一引用上运行新的流水线。
然后该引用上较早流水线的产物也允许过期。

你可以在私有化部署实例上通过
[**保留最新成功流水线的产物**](../../administration/settings/continuous_integration.md#keep-artifacts-from-latest-successful-pipelines) 实例设置为所有项目禁用此行为。

你可以在私有化部署实例的
[实例的 CI/CD 设置](../../administration/settings/continuous_integration.md#keep-artifacts-from-latest-successful-pipelines)中为所有项目禁用此行为。

<a id="related-topics"></a>

## 相关主题

- [使用 dotenv 报告产物在作业间传递环境变量](../variables/dotenv_variables.md)