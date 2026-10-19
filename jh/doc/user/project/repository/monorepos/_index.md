---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 提升 monorepo 性能
---

monorepo 是包含多个子项目的代码仓库。单个应用通常包含相互依赖的项目，例如后端、Web 前端、iOS 应用和 Android 应用。monorepo 很常见，但可能带来性能风险。一些常见问题：

- 大型二进制文件。
- 大量历史记录很长的文件。
- 大量同时进行的克隆和推送。
- 纵向扩展限制。
- 网络带宽限制。
- 磁盘带宽限制。

极狐GitLab 本身基于 Git。其 Git 存储服务 [Gitaly](https://gitlab.com/gitlab-org/gitaly) 也会遇到与 monorepo 相关的性能约束。我们从中获得的经验可以帮助您更好地管理自己的 monorepo。

- 哪些代码仓库特征会影响性能。
- 优化 monorepo 的一些工具和步骤。

<a id="optimize-gitaly-for-monorepos"></a>

## 为 monorepo 优化 Gitaly

Git 将对象压缩为 [packfile](https://git-scm.com/book/en/v2/Git-Internals-Packfiles) 以占用更少空间。当您克隆、拉取或推送时，Git 会使用 packfile。它们可以减少磁盘空间和网络带宽占用，但创建 packfile 需要大量 CPU 和内存。

大型 monorepo 比小型代码仓库拥有更多的提交、文件、分支和标签。当对象变得更大、传输时间更长时，创建 packfile 会变得更昂贵、更缓慢。在 Git 中，[`git-pack-objects`](https://git-scm.com/docs/git-pack-objects) 进程是资源消耗最大的操作，因为它会：

1. 分析提交历史和文件。
1. 确定要将哪些文件发送回客户端。
1. 创建 packfile。

来自 `git clone` 和 `git fetch`的流量会在服务器上启动 `git-pack-objects` 进程。像极狐GitLab CI/CD 这样的自动化持续集成系统可能产生大量此类流量。大量自动化 CI/CD 流量会发送许多克隆和拉取请求，可能使您的 Gitaly 服务器不堪重负。

使用以下策略来降低 Gitaly 服务器的负载。

<a id="enable-the-gitaly-pack-objects-cache"></a>

### 启用 Gitaly `pack-objects` 缓存

启用 [Gitaly `pack-objects` 缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)，以降低克隆和拉取带来的服务器负载。

当 Git 客户端发送克隆或拉取请求时，`git-pack-objects` 生成的数据可以被缓存以供复用。如果您的 monorepo 被频繁克隆，启用 [Gitaly `pack-objects` 缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)可以降低服务器负载。启用后，Gitaly 会维护内存缓存，而不是为每次克隆或拉取调用重新生成响应数据。

更多信息，请参见 [Pack-objects 缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)。

<a id="configure-git-bundle-uris"></a>

### 配置 Git bundle URI

在低延迟的第三方存储（如 CDN）上创建并存储 [Git bundle](https://git-scm.com/docs/bundle-uri)。Git 会先从您的 bundle 下载包，然后从您的 Git 远程仓库拉取剩余的对象和引用。这种方法可以更快地引导您的对象数据库，并降低 Gitaly 的负载。

- 对于与极狐GitLab 服务器网络连接较差的用户，它可以加快克隆和拉取速度。
- 通过预加载 bundle，它可以降低运行 CI/CD 作业的服务器的负载。

要了解更多信息，请参见 [Bundle URI](../../../../administration/gitaly/bundle_uris.md)。

<a id="configure-gitaly-negotiation-timeouts"></a>

### 配置 Gitaly 协商超时

在尝试拉取或归档代码仓库时，如果出现以下情况，可能会发生 `fatal: the remote end hung up unexpectedly` 错误：

- 代码仓库很大。
- 并行处理的代码仓库很多。
- 并行处理同一个大型代码仓库。

要缓解此问题，请增大[默认协商超时值](../../../../administration/settings/gitaly_timeouts.md#configure-the-negotiation-timeouts)。

<a id="size-your-hardware-correctly"></a>

### 正确规划硬件规模

monorepo 通常面向用户众多的大型组织。为支持您的 monorepo，您的极狐GitLab 环境应匹配 GitLab Test Platform 和 Support 团队提供的[参考架构](../../../../administration/reference_architectures/_index.md)之一。这些架构是在保持性能的同时大规模部署极狐GitLab 的推荐方式。

<a id="reduce-the-number-of-git-references"></a>

### 减少 Git 引用数量

在 Git 中，[引用](https://git-scm.com/book/en/v2/Git-Internals-Git-References)是指向特定提交的分支名和标签名。Git 将引用以松散文件的形式存储在代码仓库的 `.git/refs` 文件夹中。要查看代码仓库中的所有引用，请运行 `git for-each-ref`。

当代码仓库中的引用数量增长时，查找特定引用所需的寻道时间也会增长。每次 Git 解析引用时，寻道时间的增加都会导致延迟增加。

要解决此问题，Git 使用 [pack-refs](https://git-scm.com/docs/git-pack-refs) 创建一个包含该代码仓库所有引用的 `.git/packed-refs` 文件。这种方法减少了引用所需的存储空间，也减少了寻道时间，因为在单个文件中查找比在目录中的所有文件中查找更快。

Git 使用松散文件处理新建或更新的引用。在您运行 `git pack-refs` 之前，它们不会被清理并添加到 `.git/packed-refs` 文件中。Gitaly 会在[内务整理](../../../../administration/housekeeping.md#heuristical-housekeeping)期间运行 `git pack-refs`。虽然这对许多代码仓库有帮助，但写入频繁的代码仓库仍存在以下性能问题：

- 创建或更新引用会创建新的松散文件。
- 删除引用需要编辑现有的 `packed-refs` 文件以移除现有引用。

当您拉取或克隆代码仓库时，Git 会遍历所有引用。服务器会审查（“遍历”）每个引用的内部图结构，找出任何缺失的对象，并将它们发送给客户端。遍历和审查过程是 CPU 密集型的，会增加延迟。在活动频繁的代码仓库中，这种延迟可能引发连锁反应。每个操作都更慢，而每个操作都会阻塞后续操作。

要缓解 monorepo 中大量引用的影响：

- 创建自动化流程来清理旧分支。
- 如果某些引用不需要对客户端可见，请使用 [`transfer.hideRefs`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-transferhideRefs) 配置设置隐藏它们。Gitaly 会忽略服务器上的任何 Git 配置，因此您必须在 `/etc/gitlab/gitlab.rb`中更改 Gitaly 配置本身：

  ```ruby
  gitaly['configuration'] = {
    # ...
    git: {
      # ...
      config: [
        # ...
        { key: "transfer.hideRefs", value: "refs/namespace_to_hide" },
      ],
    },
  }
  ```

在 Git 2.42.0 及更高版本中，不同的 Git 操作在进行对象图遍历时可以跳过隐藏的引用。

<a id="schedule-repository-optimization-tasks"></a>

### 安排代码仓库优化任务

Git 代码仓库对象数据库中数据的存储方式可能会随时间推移变得低效，从而拖慢 Git 操作。您可以[安排 Gitaly 运行每日后台任务](../../../../administration/housekeeping.md#configure-scheduled-housekeeping)，并设置最长持续时间，以清理这些项目并提升性能。

<a id="optimize-cicd-for-monorepos"></a>

## 为 monorepo 优化 CI/CD

为使极狐GitLab 能够随您的 monorepo 一起扩展，请优化 CI/CD 作业与代码仓库的交互方式。大型、冗长的流水线是 monorepo 常见的痛点。在 monorepo 的流水线配置中，使用[构建规则](../../../../ci/yaml/_index.md#rules)来检测所做的更改类型，并：

- 跳过不必要的作业。
- 在子流水线中仅运行相关的作业。

<a id="reduce-concurrent-clones-in-cicd"></a>

### 减少 CI/CD 中的并发克隆

通过[错开计划流水线](../../../../ci/pipelines/schedules.md#distribute-pipeline-schedules-to-prevent-system-load)在不同时间运行，来降低 CI/CD 流水线的并发度。即使只相隔几分钟也有帮助。

CI/CD 负载通常是并发的，因为流水线是[在特定时间计划的](../../../../ci/pipelines/pipeline_efficiency.md#reduce-how-often-jobs-run)。在这些时段，对代码仓库的 Git 请求可能会激增，并影响 CI/CD 流程和用户的性能。

<a id="use-shallow-clones-and-filters-in-cicd-processes"></a>

### 在 CI/CD 流程中使用浅克隆和过滤器

对于 CI/CD 系统中的 `git clone` 和 `git fetch` 调用，可以使用以下选项限制传输的数据量：

- [`--depth`](https://git-scm.com/docs/git-clone#Documentation/git-clone.txt---depthltdepthgt)
- [`--filter`](https://git-scm.com/docs/git-clone#Documentation/git-clone.txt---filterfilter-spec)

<a id="shallow-clone-in-cicd"></a>

#### 在 CI/CD 中进行浅克隆

`--depth` 过滤器会创建所谓的*浅克隆*。极狐GitLab 和极狐GitLab Runner 默认执行[浅克隆](../../../../ci/pipelines/settings.md#limit-the-number-of-changes-fetched-during-clone)。

可以在极狐GitLab CI/CD 流水线配置中使用 `GIT_DEPTH` 配置克隆深度，例如：

```yaml
variables:
  GIT_DEPTH: 10

test:
  script:
    - ls -al
```

<a id="partial-clone-in-cicd"></a>

#### 在 CI/CD 中进行部分克隆

使用 `--filter` 选项可以创建*部分克隆*。要将此参数传递给 `git-clone`，请设置 `GIT_CLONE_EXTRA_FLAGS` 变量。例如，要将 blob 的最大大小限制为 1MB，请添加：

```yaml
variables:
  GIT_CLONE_EXTRA_FLAGS: --filter=blob:limit=1m
```

<a id="filter-out-paths-and-object-types"></a>

### 过滤掉路径和对象类型

要过滤掉特定类型的对象或来自特定路径的对象，请使用 `git sparse-checkout` 选项。更多信息，请参见[按文件路径过滤](../../../../topics/git/clone.md#filter-by-file-path)。

<a id="use-git-fetch-in-cicd-operations"></a>

### 在 CI/CD 操作中使用 `git fetch`

如果能够保留代码仓库的工作副本，请在 CI/CD 系统上使用 `git fetch` 而不是 `git clone`。`git fetch` 对服务器的要求更低：

- `git clone` 会从头请求整个代码仓库。`git-pack-objects` 必须处理并发送所有分支和标签。
- `git fetch` 只请求代码仓库中缺失的 Git 引用。`git-pack-objects` 只处理全部 Git 引用中的一部分。此策略还能减少传输的数据总量。

默认情况下，极狐GitLab 使用推荐用于大型代码仓库的 [`fetch` Git 策略](../../../../ci/runners/configure_runners.md#git-strategy)。

<a id="set-a-git-clone-path"></a>

### 设置 `git clone` 路径

如果您的 monorepo 与基于 fork 的工作流一起使用，请考虑设置 [`GIT_CLONE_PATH`](../../../../ci/runners/configure_runners.md#custom-build-directories) 来控制克隆代码仓库的位置。

Git 将 forks 存储为具有独立工作树的独立代码仓库。极狐GitLab Runner 无法优化工作树的使用。请仅为给定项目配置和使用极狐GitLab Runner executor。为提高流程效率，不要在不同项目之间共享它。

[`GIT_CLONE_PATH`](../../../../ci/runners/configure_runners.md#custom-build-directories) 必须位于 `$CI_BUILDS_DIR` 设置的目录中。您不能从磁盘上任意选择路径。

<a id="disable-git-clean-on-cicd-jobs"></a>

### 在 CI/CD 作业中禁用 `git clean`

`git clean` 命令会从工作树中移除未跟踪的文件。在大型代码仓库中，它会使用大量磁盘 I/O。如果您复用现有机器，并且可以复用现有工作树，请考虑在 CI/CD 作业中禁用它。例如，`GIT_CLEAN_FLAGS: -ffdx -e .build/` 可以避免在两次运行之间删除工作树中的目录。这可以加快增量构建。

要在 CI/CD 作业中禁用 `git clean`，请为它们将 [`GIT_CLEAN_FLAGS`](../../../../ci/runners/configure_runners.md#git-clean-flags) 设置为 `none`。

默认情况下，极狐GitLab 确保：

- 您的工作树位于给定的 SHA 上。
- 您的代码仓库是干净的。

有关 `GIT_CLEAN_FLAGS` 接受的确切参数，请参见 [`git clean`](https://git-scm.com/docs/git-clean)的 Git 文档。可用参数取决于您的 Git 版本。

<a id="change-git-fetch-behavior-with-flags"></a>

### 使用标志更改 `git fetch` 行为

更改 `git fetch`的行为，以排除 CI/CD 作业不需要的任何数据。如果您的项目包含许多标签，而您的 CI/CD 作业不需要它们，请使用 `GIT_FETCH_EXTRA_FLAGS` 设置 [`--no-tags`](https://git-scm.com/docs/git-fetch#Documentation/git-fetch.txt---no-tags)。此设置可以让您的拉取更快、更紧凑。

即使您的代码仓库不包含许多标签，`--no-tags` 在某些情况下也能提升性能。更多信息，请参见[议题 746](https://gitlab.com/gitlab-com/gl-infra/observability/team/-/issues/746) 和 [`GIT_FETCH_EXTRA_FLAGS` Git 文档](../../../../ci/runners/configure_runners.md#git-fetch-extra-flags)。

<a id="use-long-polling-for-runners"></a>

### 为 runner 使用长轮询

Runner 会定期轮询极狐GitLab 实例以获取新的 CI/CD 作业。轮询间隔取决于以下两者：

- `check_interval` 设置。
- runner 配置文件中配置的 runner 数量。

如果您的服务器处理许多 runner，这种轮询可能会导致极狐GitLab 实例出现性能问题，例如排队时间更长和 CPU 使用率更高。长轮询会保持来自 runner 的作业请求，直到有新作业准备就绪。

有关配置说明，请参见[长轮询](../../../../ci/runners/long_polling.md)。

<a id="optimize-git-for-monorepos"></a>

## 为 monorepo 优化 Git

为使极狐GitLab 能够随您的 monorepo 一起扩展，请优化代码仓库本身。

<a id="avoid-shallow-clones-for-development"></a>

### 开发时避免浅克隆

开发时避免浅克隆。浅克隆会大幅增加推送更改所需的时间。浅克隆适合 CI/CD 作业，因为检出后代码仓库内容不会更改。

对于本地开发，请改用[部分克隆](https://www.git-scm.com/docs/git-clone#Documentation/git-clone.txt---filterltfilter-specgt)，以：

- 使用 `git clone --filter=blob:none` 过滤掉 blob
- 使用 `git clone --filter=tree:0` 过滤掉 tree

更多信息，请参见[减小克隆大小](../../../../topics/git/clone.md#reduce-clone-size)。

<a id="profile-your-repository-to-find-problems"></a>

### 对代码仓库进行性能分析以找出问题

大型代码仓库通常会在 Git 中遇到性能问题。[`git-sizer`](https://github.com/github/git-sizer) 项目会对您的代码仓库进行性能分析，帮助您了解潜在问题。它可以帮助您制定缓解策略，以防止性能问题。分析代码仓库需要完整的 Git 镜像或裸克隆，以确保所有 Git 引用都存在。

要使用 `git-sizer` 对代码仓库进行性能分析：

1. [安装 `git-sizer`](https://github.com/github/git-sizer?tab=readme-ov-file#getting-started)。
1. 运行此命令，以与 `git-sizer` 兼容的裸 Git 格式克隆您的代码仓库：

   ```shell
   git clone --mirror <git_repo_url>
   ```

1. 在您的 Git 代码仓库目录中，运行 `git-sizer` 并输出所有统计信息：

   ```shell
   git-sizer -v
   ```

处理完成后，`git-sizer`的输出应类似以下示例。每一行都包含代码仓库该方面的**关注级别**。关注级别越高，显示的星号越多。关注级别极高的项目会以感叹号显示。在此示例中，有几项的关注级别很高：

```shell
Processing blobs: 1652370
Processing trees: 3396199
Processing commits: 722647
Matching commits to trees: 722647
Processing annotated tags: 534
Processing references: 539
| Name                         | Value     | Level of concern               |
| ---------------------------- | --------- | ------------------------------ |
| Overall repository size      |           |                                |
| * Commits                    |           |                                |
|   * Count                    |   723 k   | *                              |
|   * Total size               |   525 MiB | **                             |
| * Trees                      |           |                                |
|   * Count                    |  3.40 M   | **                             |
|   * Total size               |  9.00 GiB | ****                           |
|   * Total tree entries       |   264 M   | *****                          |
| * Blobs                      |           |                                |
|   * Count                    |  1.65 M   | *                              |
|   * Total size               |  55.8 GiB | *****                          |
| * Annotated tags             |           |                                |
|   * Count                    |   534     |                                |
| * References                 |           |                                |
|   * Count                    |   539     |                                |
|                              |           |                                |
| Biggest objects              |           |                                |
| * Commits                    |           |                                |
|   * Maximum size         [1] |  72.7 KiB | *                              |
|   * Maximum parents      [2] |    66     | ******                         |
| * Trees                      |           |                                |
|   * Maximum entries      [3] |  1.68 k   | *                              |
| * Blobs                      |           |                                |
|   * Maximum size         [4] |  13.5 MiB | *                              |
|                              |           |                                |
| History structure            |           |                                |
| * Maximum history depth      |   136 k   |                                |
| * Maximum tag depth      [5] |     1     |                                |
|                              |           |                                |
| Biggest checkouts            |           |                                |
| * Number of directories  [6] |  4.38 k   | **                             |
| * Maximum path depth     [7] |    13     | *                              |
| * Maximum path length    [8] |   134 B   | *                              |
| * Number of files        [9] |  62.3 k   | *                              |
| * Total size of files    [9] |   747 MiB |                                |
| * Number of symlinks    [10] |    40     |                                |
| * Number of submodules       |     0     |                                |
```

<a id="use-git-lfs-for-large-binary-files"></a>

### 对大型二进制文件使用 Git LFS

将二进制文件（如软件包、音频、视频或图形）存储为 Git Large File Storage (Git LFS) 对象。

当用户将文件提交到 Git 时，Git 使用 blob [对象类型](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)来存储和管理其内容。Git 无法高效处理大型二进制数据，因此大型 blob 对 Git 来说是个问题。如果 `git-sizer` 报告超过 10 MB 的 blob，通常说明您的代码仓库中存在大型二进制文件。大型二进制文件会给服务器和客户端都带来问题：

- 对于服务器：与基于文本的源代码不同，二进制数据通常已经压缩过。Git 无法进一步压缩二进制数据，这会导致 packfile 很大。大型 packfile 需要更多 CPU、内存和带宽来创建和发送。
- 对于客户端：Git 会将 blob 内容同时存储在 packfile（通常在 `.git/objects/pack/` 中）和常规文件（位于[工作树](https://git-scm.com/docs/git-worktree)中）中。二进制文件所需的空间远多于基于文本的源代码。

Git LFS 将对象存储在外部，例如对象存储中。您的 Git 代码仓库包含指向对象位置的指针，而不是二进制文件本身。这可以提升代码仓库性能。更多信息，请参见 [Git LFS 文档](../../../../topics/git/lfs/_index.md)。
