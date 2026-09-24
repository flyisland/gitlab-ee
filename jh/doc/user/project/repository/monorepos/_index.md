---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 优化 monorepo 性能
---

monorepo 是包含子项目的仓库。单个应用通常包含相互依赖的项目。例如，一个后端、一个 Web 前端、一个 iOS 应用和一个 Android 应用。monorepo 很常见，但它们可能带来性能风险。一些常见的问题包括：

- 大型二进制文件。
- 大量历史版本文件。
- 大量并发的克隆和推送操作。
- 垂直扩展限制。
- 网络带宽限制。
- 磁盘带宽限制。

极狐GitLab 本身就是基于 Git 构建的。其 Git 存储服务 [Gitaly](https://jihulab.com/gitlab-cn/gitaly) 会经历与 monorepo 相关的性能限制。我们从中吸取的经验可以帮助你更好地管理自己的 monorepo。

- 哪些仓库特性会影响性能。
- 一些优化 monorepo 的工具和步骤。

<a id="optimize-gitaly-for-monorepos"></a>

## 优化 Gitaly 以处理 monorepo

Git 将对象压缩成 [packfile](https://git-scm.com/book/en/v2/Git-Internals-Packfiles) 以减少空间占用。当你执行克隆、拉取或推送操作时，Git 会使用 packfile。它们可减少磁盘空间和网络带宽消耗，但创建 packfile 需要消耗大量 CPU 和内存。

大型 monorepo 比小型仓库拥有更多的提交、文件、分支和标签。当对象变得更大并且传输时间更长时，packfile 的创建会变得更加昂贵和缓慢。在 Git 中，[`git-pack-objects`](https://git-scm.com/docs/git-pack-objects) 进程是资源最密集的操作，因为它会：

1. 分析提交历史和文件。
1. 确定要发送回客户端的文件。
1. 创建 packfile。

来自 `git clone` 和 `git fetch` 的流量会触发服务器上的 `git-pack-objects` 进程。自动化持续集成系统，例如极狐GitLab CI/CD，可能会产生大量此类流量。大量的自动化 CI/CD 流量会发送许多克隆和拉取请求，并可能使你的 Gitaly 服务器承受巨大压力。

请使用以下策略来降低 Gitaly 服务器的负载。

<a id="enable-the-gitaly-pack-objects-cache"></a>

### 启用 Gitaly `pack-objects` 缓存

启用 [Gitaly `pack-objects` 缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)可以减少克隆和拉取操作的服务器负载。

当 Git 客户端发送克隆或拉取请求时，`git-pack-objects` 生成的数据可以被缓存以供重用。如果你的 monorepo 经常被克隆，启用 [Gitaly `pack-objects` 缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)可以降低服务器负载。启用后，Gitaly 会维护一个内存缓存，而不是为每次克隆或拉取调用重新生成响应数据。

更多信息，请参阅 [Pack-objects 缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)。

<a id="configure-git-bundle-uris"></a>

### 配置 Git bundle URI

在低延迟的第三方存储（如 CDN）上创建和存储 [Git bundle](https://git-scm.com/docs/bundle-uri)。Git 首先从你的 bundle 中下载包，然后从你的 Git 远程仓库获取剩余的对象和引用。这种方法可以更快地初始化你的对象数据库，并减少 Gitaly 上的负载。

- 它可以为与极狐GitLab 服务器网络连接较差用户加快克隆和拉取速度。
- 它通过预加载 bundle 来减少运行 CI/CD 作业的服务器的负载。

要了解更多信息，请参阅 [Bundle URI](../../../../administration/gitaly/bundle_uris.md)。

<a id="configure-gitaly-negotiation-timeouts"></a>

### 配置 Gitaly 协商超时

在尝试拉取或归档仓库时，如果你有以下情况，可能会遇到 `fatal: the remote end hung up unexpectedly` 错误：

- 大型仓库。
- 并行处理多个仓库。
- 并行处理同一个大型仓库。

为缓解此问题，请增大[默认协商超时值](../../../../administration/settings/gitaly_timeouts.md#configure-the-negotiation-timeouts)。

<a id="size-your-hardware-correctly"></a>

### 正确配置硬件规模

monorepo 通常用于拥有众多用户的大型组织。为了支持你的 monorepo，你的极狐GitLab 环境应该匹配极狐GitLab 测试平台和支持团队提供的[参考架构](../../../../administration/reference_architectures/_index.md)之一。这些架构是在保持性能的同时大规模部署极狐GitLab 的推荐方式。

<a id="reduce-the-number-of-git-references"></a>

### 减少 Git 引用的数量

在 Git 中，[引用](https://git-scm.com/book/en/v2/Git-Internals-Git-References)是指向特定提交的分支和标签名称。Git 将引用存储为仓库 `.git/refs` 文件夹中的松散文件。要查看仓库中的所有引用，请运行 `git for-each-ref`。

当仓库中的引用数量增长时，查找特定引用所需的寻道时间也会增加。每次 Git 解析引用时，增加的寻道时间都会导致延迟增加。

为解决这个问题，Git 使用 [pack-refs](https://git-scm.com/docs/git-pack-refs) 创建了一个 `.git/packed-refs` 文件，其中包含该仓库的所有引用。这种方法减少了引用所需的存储空间，也减少了寻道时间，因为在单个文件中寻道比在目录中的所有文件中寻道更快。

Git 通过松散文件处理新创建或更新的引用。在你运行 `git pack-refs` 之前，它们不会被清理并添加到 `.git/packed-refs` 文件中。Gitaly 会在[日常维护](../../../../administration/housekeeping.md#heuristical-housekeeping)期间运行 `git pack-refs`。虽然这有助于许多仓库，但写入频繁的仓库仍然存在以下性能问题：

- 创建或更新引用会创建新的松散文件。
- 删除引用需要编辑现有的 `packed-refs` 文件，以移除已有的引用。

当你拉取或克隆仓库时，Git 会遍历所有引用。服务器会检查（“遍历”）每个引用的内部图形结构，查找任何缺失的对象，并将它们发送给客户端。迭代和遍历的过程非常消耗 CPU，并且会增加延迟。这种延迟可能在高活动量的仓库中产生连锁反应。每个操作都会变慢，而每个操作也会拖延后续操作。

为了缓解 monorepo 中大量引用的影响：

- 创建一个自动清理旧分支的流程。
- 如果某些引用不需要对客户端可见，可以使用 [`transfer.hideRefs`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-transferhideRefs) 配置设置来隐藏它们。Gitaly 会忽略任何服务器端的 Git 配置，因此你必须在 `/etc/gitlab/gitlab.rb` 中更改 Gitaly 配置本身：

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

在 Git 2.42.0 及更高版本中，不同的 Git 操作可以在进行对象图形遍历时跳过隐藏的引用。

<a id="schedule-repository-optimization-tasks"></a>

### 安排仓库优化任务

随着时间的推移，Git 仓库对象数据库中存储数据的方式可能会变得低效，这会减慢 Git 操作的速度。你可以[安排 Gitaly 运行一项每日后台任务](../../../../administration/housekeeping.md#configure-scheduled-housekeeping)，并设置最大持续时间来清理这些项目并提高性能。

<a id="optimize-cicd-for-monorepos"></a>

## 为 monorepo 优化 CI/CD

为了使极狐GitLab 与你的 monorepo 保持可扩展性，请优化你的 CI/CD 作业与仓库的交互方式。庞大而冗长的流水线是 monorepo 常见的痛点。在你的 monorepo 的流水线配置中，使用[构建规则](../../../../ci/yaml/_index.md#rules)来检测所做的更改类型，并：

- 跳过不必要的作业。
- 仅在子流水线中运行相关作业。

<a id="reduce-concurrent-clones-in-cicd"></a>

### 减少 CI/CD 中的并发克隆

通过[错开你的 cron 计划流水线](../../../../ci/pipelines/schedules.md#distribute-pipeline-schedules-to-prevent-system-load)在不同的时间运行，来减少 CI/CD 流水线的并发量。即使只错开几分钟也会有所帮助。

CI/CD 负载通常是并发的，因为流水线是[在特定时间安排的](../../../../ci/pipelines/pipeline_efficiency.md#reduce-how-often-jobs-run)。在这些时间段内，你的仓库的 Git 请求可能会激增，并影响 CI/CD 流程和用户的性能。

<a id="use-shallow-clones-and-filters-in-cicd-processes"></a>

### 在 CI/CD 流程中使用浅克隆和过滤器

对于 CI/CD 系统中的 `git clone` 和 `git fetch` 调用，可以使用以下选项来限制传输的数据量：

- [`--depth`](https://git-scm.com/docs/git-clone#Documentation/git-clone.txt---depthltdepthgt)
- [`--filter`](https://git-scm.com/docs/git-clone#Documentation/git-clone.txt---filterfilter-spec)

<a id="shallow-clone-in-cicd"></a>

#### CI/CD 中的浅克隆

`--depth` 过滤器会创建一个所谓的_浅克隆_。默认情况下，极狐GitLab 和极狐GitLab Runner 会执行[浅克隆](../../../../ci/pipelines/settings.md#limit-the-number-of-changes-fetched-during-clone)。

可以在极狐GitLab CI/CD 流水线配置中使用 `GIT_DEPTH` 来配置克隆深度，例如：

```yaml
variables:
  GIT_DEPTH: 10

test:
  script:
    - ls -al
```

<a id="partial-clone-in-cicd"></a>

#### CI/CD 中的部分克隆

你可以通过使用 `--filter` 选项来创建_部分克隆_。要将此参数传递给 `git-clone`，请设置 `GIT_CLONE_EXTRA_FLAGS` 变量。例如，要将 blob 的最大大小限制为 1MB，请添加：

```yaml
variables:
  GIT_CLONE_EXTRA_FLAGS: --filter=blob:limit=1m
```

<a id="filter-out-paths-and-object-types"></a>

### 过滤掉路径和对象类型

要过滤掉特定类型的对象或特定路径的对象，请使用 `git sparse-checkout` 选项。更多信息，请参阅[按文件路径过滤](../../../../topics/git/clone.md#filter-by-file-path)。

<a id="use-git-fetch-in-cicd-operations"></a>

### 在 CI/CD 操作中使用 `git fetch`

如果可以在 CI/CD 系统上保留仓库的工作副本，请使用 `git fetch` 而不是 `git clone`。`git fetch` 对服务器的要求更低：

- `git clone` 会从头开始请求整个仓库。`git-pack-objects` 必须处理并发送所有分支和标签。
- `git fetch` 只请求仓库中缺失的 Git 引用。`git-pack-objects` 只处理总 Git 引用的一部分。此策略也减少了传输的数据总量。

默认情况下，极狐GitLab 使用推荐用于大型仓库的 [`fetch` Git 策略](../../../../ci/runners/configure_runners.md#git-strategy)。

<a id="set-a-git-clone-path"></a>

### 设置 `git clone` 路径

如果你的 monorepo 使用基于派生（fork）的工作流，请考虑设置 [`GIT_CLONE_PATH`](../../../../ci/runners/configure_runners.md#custom-build-directories) 来控制克隆仓库的位置。

Git 将派生存储为具有单独工作树的单独仓库。极狐GitLab Runner 无法优化工作树的使用。仅为给定项目配置并使用极狐GitLab Runner 执行器。为了使流程更高效，不要在不同项目之间共享它。

[`GIT_CLONE_PATH`](../../../../ci/runners/configure_runners.md#custom-build-directories) 必须位于 `$CI_BUILDS_DIR` 设置的目录中。你不能从磁盘上任意选择路径。

<a id="disable-git-clean-on-cicd-jobs"></a>

### 在 CI/CD 作业中禁用 `git clean`

`git clean` 命令会从工作树中删除未跟踪的文件。在大型仓库中，它会消耗大量的磁盘 I/O。如果你重复使用现有的机器，并且可以重用现有的工作树，请考虑在 CI/CD 作业中禁用它。例如，`GIT_CLEAN_FLAGS: -ffdx -e .build/` 可以避免在运行之间从工作树中删除目录。这可以加速增量构建。

要在 CI/CD 作业中禁用 `git clean`，请将 [`GIT_CLEAN_FLAGS`](../../../../ci/runners/configure_runners.md#git-clean-flags) 设置为 `none`。

默认情况下，极狐GitLab 确保：

- 你的工作树处于给定的 SHA。
- 你的仓库是干净的。

有关 `GIT_CLEAN_FLAGS` 接受的确切参数，请参阅 Git 文档中的 [`git clean`](https://git-scm.com/docs/git-clean)。可用的参数取决于你的 Git 版本。

<a id="change-git-fetch-behavior-with-flags"></a>

### 使用标志更改 `git fetch` 行为

更改 `git fetch` 的行为以排除你的 CI/CD 作业不需要的任何数据。如果你的项目包含许多标签，而你的 CI/CD 作业不需要它们，请使用 `GIT_FETCH_EXTRA_FLAGS` 来设置 [`--no-tags`](https://git-scm.com/docs/git-fetch#Documentation/git-fetch.txt---no-tags)。此设置可以使你的拉取操作更快、更紧凑。

即使你的仓库不包含许多标签，`--no-tags` 在某些情况下也能提高性能。更多信息，请参阅 [issue 746](https://jihulab.com/gitlab-com/gl-infra/observability/team/-/issues/746) 和 [`GIT_FETCH_EXTRA_FLAGS` Git 文档](../../../../ci/runners/configure_runners.md#git-fetch-extra-flags)。

<a id="use-long-polling-for-runners"></a>

### 为 Runner 使用长轮询

Runner 会定期轮询极狐GitLab 实例以获取新的 CI/CD 作业。轮询间隔取决于：

- `check_interval` 设置。
- Runner 配置文件中配置的 Runner 数量。

如果你的服务器处理许多 Runner，此轮询可能会导致极狐GitLab 实例出现性能问题，例如更长的排队时间和更高的 CPU 使用率。长轮询会保留来自 Runner 的作业请求，直到有新作业准备好为止。

有关配置说明，请参阅[长轮询](../../../../ci/runners/long_polling.md)。

<a id="optimize-git-for-monorepos"></a>

## 为 monorepo 优化 Git

为了使极狐GitLab 与你的 monorepo 保持可扩展性，请优化仓库本身。

<a id="avoid-shallow-clones-for-development"></a>

### 避免在开发中使用浅克隆

请避免在开发中使用浅克隆。浅克隆会大大增加推送更改所需的时间。浅克隆适用于 CI/CD 作业，因为仓库内容在检出后不会更改。

对于本地开发，请改用[部分克隆](https://www.git-scm.com/docs/git-clone#Documentation/git-clone.txt---filterltfilter-specgt)，以：

- 过滤掉 blob，使用 `git clone --filter=blob:none`
- 过滤掉 tree，使用 `git clone --filter=tree:0`

更多信息，请参阅[减少克隆大小](../../../../topics/git/clone.md#reduce-clone-size)。

<a id="profile-your-repository-to-find-problems"></a>

### 分析你的仓库以查找问题

大型仓库通常会在 Git 中遇到性能问题。[`git-sizer`](https://github.com/github/git-sizer) 项目可以分析你的仓库，并帮助你了解潜在的问题。它可以帮助你制定缓解策略，以防止性能问题。分析你的仓库需要一个完整的 Git 镜像或裸克隆，以确保所有 Git 引用都存在。

要使用 `git-sizer` 分析你的仓库：

1. [安装 `git-sizer`](https://github.com/github/git-sizer?tab=readme-ov-file#getting-started)。
1. 运行此命令以与 `git-sizer` 兼容的裸 Git 格式克隆你的仓库：

   ```shell
   git clone --mirror <git_repo_url>
   ```

1. 在你的 Git 仓库目录中，使用所有统计信息运行 `git-sizer`：

   ```shell
   git-sizer -v
   ```

处理后，`git-sizer` 的输出应类似于此示例。每一行都包含该仓库某个方面的**关注级别**。关注级别越高，显示的星号越多。具有极高关注级别的项目会显示感叹号。在此示例中，有几个项目具有高关注级别：

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

### 为大型二进制文件使用 Git LFS

将二进制文件（如软件包、音频、视频或图形文件）存储为 Git LFS（Git 大文件存储）对象。

当用户将文件提交到 Git 时，Git 使用 blob [对象类型](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)来存储和管理其内容。Git 不能高效地处理大型二进制数据，因此大型 blob 对 Git 来说是个问题。如果 `git-sizer` 报告存在超过 10 MB 的 blob，你的仓库中通常包含大型二进制文件。大型二进制文件会给服务器和客户端都带来问题：

- 对于服务器：与基于文本的源代码不同，二进制数据通常是已经压缩过的。Git 无法进一步压缩二进制数据，这会导致生成大型 packfile。大型 packfile 需要更多的 CPU、内存和带宽来创建和发送。
- 对于客户端：Git 会将 blob 内容存储在 packfile（通常在 `.git/objects/pack/` 中）和常规文件（在[工作树](https://git-scm.com/docs/git-worktree)中）中，二进制文件需要比基于文本的源代码大得多的空间。

Git LFS 会将对象存储在外部，例如对象存储中。你的 Git 仓库包含一个指向对象位置的指针，而不是二进制文件本身。这可以提高仓库性能。更多信息，请参阅 [Git LFS 文档](../../../../topics/git/lfs/_index.md)。

<a id="related-topics"></a>

## 相关主题

- [配置 Gitaly](../../../../administration/gitaly/configure_gitaly.md)