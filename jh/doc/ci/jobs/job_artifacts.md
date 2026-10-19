---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab CI/CD 中创建、下载、浏览和管理作业产物。
title: 作业产物
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

作业可以输出文件和目录的归档。此输出称为作业产物。产物可以包含构建输出或报告文件。默认情况下，后续作业会获取早期阶段作业的所有产物副本。

例如，早期作业可以构建项目并将输出保存为产物。然后，后续作业获取该产物并对保存的构建输出运行测试。

有关 `artifacts` 关键字支持的完整配置列表，
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

在此示例中，名为 `pdf`的作业调用 `xelatex` 命令，从
LaTeX 源文件 `mycv.tex` 构建 PDF 文件。

`paths` 关键字决定要将哪些文件添加到作业产物中。文件和目录的所有路径都相对于创建该作业的代码仓库。

<a id="with-wildcards"></a>

### 使用通配符

您可以在路径和目录中使用通配符。例如，要创建包含以 `xyz` 结尾的目录中所有文件的产物：

```yaml
job:
  script: echo "build xyz project"
  artifacts:
    paths:
      - path/*xyz/*
```

<a id="with-an-expiry"></a>

### 设置过期时间

`expire_in` 关键字决定极狐GitLab 保留 `artifacts:paths`中定义的产物的时长。例如：

```yaml
pdf:
  script: xelatex mycv.tex
  artifacts:
    paths:
      - mycv.pdf
    expire_in: 1 week
```

如果未定义 `expire_in`，则使用[**默认产物过期时间**](../../administration/settings/continuous_integration.md#set-default-artifacts-expiration)实例设置。

要防止产物过期，您可以在作业详情页面选择**保留**。当产物未设置过期时间时，该选项不可用。

默认情况下，无论 `expire_in` 如何，每个引用上最近完成的流水线和最近成功的流水线的产物都会保留。

<a id="with-an-explicitly-defined-artifact-name"></a>

### 显式定义产物名称

您可以使用 `artifacts:name` 配置显式自定义产物名称：

```yaml
job:
  artifacts:
    name: "job1-artifacts-file"
    paths:
      - binaries/
```

<a id="without-excluded-files"></a>

### 排除文件

使用 `artifacts:exclude` 可防止文件被添加到产物归档中。

例如，要存储 `binaries/` 中的所有文件，但不包括位于 `binaries/` 子目录中的 `*.o` 文件：

```yaml
artifacts:
  paths:
    - binaries/
  exclude:
    - binaries/**/*.o
```

与 `artifacts:paths` 不同，`exclude` 路径不是递归的。要排除某个目录的所有内容，请显式匹配这些内容，而不是匹配目录本身。

例如，要存储 `binaries/` 中的所有文件，但不存储 `temp/` 子目录中的任何内容：

```yaml
artifacts:
  paths:
    - binaries/
  exclude:
    - binaries/temp/**/*
```

<a id="with-untracked-files"></a>

### 包含未跟踪的文件

使用 `artifacts:untracked` 可将所有 Git 未跟踪文件连同 `artifacts:paths`中定义的路径一起添加为产物。未跟踪文件是指尚未添加到代码仓库但存在于代码仓库检出中的文件。

例如，要保存所有 Git 未跟踪文件以及 `binaries`中的文件：

```yaml
artifacts:
  untracked: true
  paths:
    - binaries/
```

例如，要保存所有未跟踪文件但排除 `*.txt` 文件：

```yaml
artifacts:
  untracked: true
  exclude:
    - "*.txt"
```

<a id="with-variable-expansion"></a>

### 使用变量展开

`artifacts:name`、`artifacts:paths` 和 `artifacts:exclude` 支持变量展开。

极狐GitLab Runner 不使用 shell，而是使用其内部变量展开机制。此上下文中仅支持 CI/CD 变量。

例如，要使用当前分支或标签名称创建归档，且仅包含来自以当前项目命名的目录中的文件：

```yaml
job:
  artifacts:
    name: "$CI_COMMIT_REF_NAME"
    paths:
      - binaries/${CI_PROJECT_NAME}/
```

当您的分支名称包含正斜杠时（例如 `feature/my-feature`），请使用 `$CI_COMMIT_REF_SLUG` 而不是 `$CI_COMMIT_REF_NAME`，以确保产物命名正确。

变量在 glob 之前展开。

<a id="with-upload-conditions"></a>

### 设置上传条件

默认情况下，产物仅在作业成功时上传（`on_success`）。使用 `artifacts:when: on_failure` 可仅在作业失败时上传，或使用 `artifacts:when: always` 无论作业状态如何都上传。

例如，要仅在构建失败时保存构建日志：

```yaml
build:
  script: make build > build.log 2>&1
  artifacts:
    when: on_failure
    paths:
      - build.log
```

<a id="fetching-artifacts"></a>

## 获取产物

默认情况下，作业会获取先前阶段中定义的作业的所有产物。这些产物会下载到作业的工作目录中。

您可以使用 `dependencies` 或 `needs:artifacts` 关键字控制要下载哪些产物。

当您使用这些关键字时，默认行为会改变，产物仅从您指定的作业中获取。

<a id="prevent-a-job-from-fetching-artifacts"></a>

### 阻止作业获取产物

要阻止作业下载任何产物，请将 `dependencies` 设置为空数组（`[]`）：

```yaml
job:
  stage: test
  script: make build
  dependencies: []
```

<a id="view-all-job-artifacts-in-a-project"></a>

## 查看项目中的所有作业产物

您可以从**构建** > **产物**页面查看项目中存储的所有产物。此列表显示所有作业及其关联的产物。展开某个条目可访问与作业关联的所有产物，包括：

- 使用 `artifacts:` 关键字创建的产物。
- 报告产物。
- 作业日志和元数据，它们在内部作为单独的产物存储。

您可以从此列表下载或删除单个产物。

<a id="download-job-artifacts"></a>

## 下载作业产物

您可以从极狐GitLab UI 或通过 API 下载作业产物。要使用 API，请使用可公开访问的 URL，可以按作业名称和分支获取最新产物，也可以按作业 ID 定位特定报告。

从极狐GitLab UI：

| 位置                          | 选择                                                        | 使用场景                                                                                                                       |
|-----------------------------------|---------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| 任何**流水线**列表            | **下载产物** ({{< icon name="download" >}})         | 您还不知道要下载哪个作业的产物。选择此项后，极狐GitLab 会打开该流水线的作业列表供您选择。 |
| 任何**作业**列表                 | **下载产物** ({{< icon name="download" >}})         | 您正在浏览多个作业，并希望在不打开作业的情况下从其中一个下载。                                                     |
| 作业详情页面               | **下载**                                                  | 您正在阅读该作业的日志，例如在调查失败时。                                                           |
| 合并请求**概览**页面 | **产物** ({{< icon name="download" >}})                  | 您想要合并请求最新流水线的产物。                                                                        |
| **产物**页面            | **下载** ({{< icon name="download" >}})                   | 您正在浏览项目中产物的完整列表。                                                                          |
| 产物浏览器             | **下载产物归档** ({{< icon name="download" >}}) | 您正在浏览归档的内容，并希望下载整个归档。                                                       |

要限制谁可以下载作业产物，请在 `.gitlab-ci.yml` 文件中使用 `artifacts:access` 关键字。例如：

```yaml
job:
  artifacts:
    access: maintainer
    paths:
      - build/
```

<a id="by-job-name-and-branch"></a>

### 按作业名称和分支

使用作业名称和分支下载作业的最新产物归档，无需先查找作业 ID。

例如，要下载 JihuLab.com 上某个项目的 `main` 分支中名为 `build`的作业的最新产物：

```plaintext
https://jihulab.com/api/v4/projects/<project-id>/jobs/artifacts/main/download?job=build
```

要从产物中下载特定文件：

```plaintext
https://jihulab.com/api/v4/projects/<project-id>/jobs/artifacts/main/raw/review/index.html?job=build
```

此端点返回的文件始终具有 `plain/text` 内容类型。

在这两个示例中，请将 `<project-id>` 替换为有效的项目 ID。您可以在[项目概览页面](../../user/project/working_with_projects.md#find-the-project-id)上找到项目 ID。

父流水线和子流水线的产物按从父到子的层级顺序搜索。例如，如果父流水线和子流水线都有一个同名作业，则返回父流水线的作业产物。

<a id="by-job-id"></a>

### 按作业 ID

[报告产物](../yaml/artifacts_reports.md)（例如 JUnit 测试结果）不包含在按作业名称和分支下载的产物归档中。要下载报告文件，请使用作业 ID 并在 URL 中添加 `file_type`：

```plaintext
https://jihulab.com/api/v4/projects/<project-id>/jobs/<job-id>/artifacts?file_type=junit
```

极狐GitLab 以 runner 上传报告时所用的格式提供报告，具体格式因报告类型而异。

<a id="with-a-cicd-job-token"></a>

### 使用 CI/CD 作业令牌

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 CI/CD 作业令牌向作业产物 API 端点进行身份验证，并从不同的流水线获取产物。您必须指定要从哪个作业获取产物，例如：

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

要从同一流水线中的作业获取产物，请使用 `needs:artifacts` 关键字。

<a id="browse-the-contents-of-the-artifacts-archive"></a>

## 浏览产物归档的内容

您可以从 UI 浏览产物的内容，而无需在本地下载产物，方法如下：

- 任何**作业**列表。在作业右侧，选择**浏览** ({{< icon name="folder-open" >}})。
- 作业详情页面。在页面右侧，选择**浏览**。
- **产物**页面。在作业右侧，选择**浏览** ({{< icon name="folder-open" >}})。

如果全局启用了 GitLab Pages，即使项目设置中已禁用它，您也可以直接在浏览器中预览某些产物文件扩展名。如果项目是内部或私有的，管理员还必须为实例开启
[GitLab Pages 访问控制](../../administration/pages/_index.md#access-control)。

支持以下扩展名：

| 文件扩展名 | JihuLab.com  | 内置 NGINX 的 Linux 软件包 |
|----------------|-------------|-----------------------------------|
| `.html`        | {{< yes >}} | {{< yes >}}                       |
| `.json`        | {{< yes >}} | {{< yes >}}                       |
| `.xml`         | {{< yes >}} | {{< yes >}}                       |
| `.txt`         | {{< no >}}  | {{< yes >}}                       |
| `.log`         | {{< no >}}  | {{< yes >}}                       |

<a id="browse-artifacts-from-a-url"></a>

### 从 URL 浏览产物

您可以通过可公开访问的 URL 浏览特定作业最新成功流水线的作业产物。

例如，要浏览 JihuLab.com 上某个项目的 `main` 分支中名为 `build`的作业的最新产物：

```plaintext
https://jihulab.com/<full-project-path>/-/jobs/artifacts/main/browse?job=build
```

请将 `<full-project-path>` 替换为有效的项目路径。您可以在项目的 URL 中找到它。

<a id="set-the-maximum-artifacts-size"></a>

## 设置最大产物大小

设置作业产物的大小限制，以控制存储使用量。作业中的每个产物文件默认最大大小为 100 MB。

> [!note]
> 此设置适用于最终归档文件的大小，而不是作业中的单个文件。

您可以为以下对象配置产物大小限制：

- [实例](../../administration/cicd/limits.md#maximum-artifacts-size)：
  适用于所有项目和群组的基础设置。
- 群组：覆盖该群组中所有项目的实例设置。
- 项目：覆盖特定项目的实例和群组设置。

要更改群组或项目的最大产物大小：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目或群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 更改**最大产物大小**的值（以 MB 为单位）。
1. 选择**保存更改**。

<a id="delete-job-log-and-artifacts"></a>

## 删除作业日志和产物

> [!warning]
> 删除作业日志和产物是破坏性操作，无法恢复。请谨慎使用。
> 删除某些文件（包括报告产物、作业日志和元数据文件）会影响
> 将这些文件用作数据源的极狐GitLab 功能。

您可以删除作业的产物和日志。

先决条件：

- 您必须是该作业的所有者，或者是对该项目具有维护者或所有者角色的用户。

要删除作业：

1. 转到作业详情页面。
1. 在作业日志的右上角，选择**清除作业日志和产物** ({{< icon name="remove" >}})。

您也可以从**产物**页面删除单个产物。

<a id="bulk-delete-artifacts"></a>

### 批量删除产物

您可以同时删除多个产物：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **产物**。
1. 选中要删除的产物旁边的复选框。您最多可以选择 100 个产物。
1. 选择**删除所选**。

<a id="link-to-job-artifacts-in-the-merge-request-ui"></a>

## 在合并请求 UI 中链接到作业产物

使用 `artifacts:expose_as` 关键字可从合并请求 UI 直接访问产物。

例如，对于包含单个文件的产物：

```yaml
test:
  script: ["echo 'test' > file.txt"]
  artifacts:
    expose_as: 'artifact 1'
    paths: ['file.txt']
```

使用此配置，**查看公开的产物**部分会显示一个指向 `file.txt`的链接，标记为 **artifact 1**。

![一个链接到公开产物的合并请求小组件。](img/mr_artifact_expose_v18_4.png)

<a id="keep-artifacts-from-most-recent-successful-jobs"></a>

## 保留最近成功作业的产物

默认情况下，对于每个 Git 引用（分支或标签），极狐GitLab 会保留以下产物：

- 该引用的最新流水线，即使它失败或被手动作业阻止。
- 最近成功的流水线（如果它与最新流水线不同）。

任何 `expire_in` 配置都不适用于这些产物。

当同一引用上更新的流水线执行以下任一操作时，该引用上其他较旧的流水线的产物开始过期：

- 成功。
- 失败。
- 被取消。
- 被跳过。
- 被手动作业阻止。

例如，如果某个分支上的最新流水线失败，极狐GitLab 会保留其产物以及上次成功流水线的产物。

在作业很多或产物很大的项目中，保留最新产物可能会占用大量存储空间。如果项目中不需要最新产物，您可以禁用此行为以节省空间：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**产物**。
1. 清除**保留最近成功作业的产物**复选框。

禁用此设置后，所有新产物都会根据 `expire_in` 配置过期。旧流水线中的产物会继续保留，直到同一引用运行新的流水线。之后，该引用中较早流水线的产物也会被允许过期。

您可以使用[**保留最新成功流水线的产物**](../../administration/settings/continuous_integration.md#keep-artifacts-from-latest-successful-pipelines)实例设置，为极狐GitLab 私有化部署上的所有项目禁用此行为。
