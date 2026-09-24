---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab CI/CD 中使用缓存，在作业和流水线中下载依赖项。
title: 极狐GitLab CI/CD 中的缓存
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

缓存是作业下载并保存的一个或多个文件。使用相同缓存的后续作业无需再次下载这些文件，因此运行速度更快。

要了解如何在 `.gitlab-ci.yml` 文件中定义缓存，请参阅 [`cache` 参考文档](../yaml/_index.md#cache)。

对于高级缓存键策略，你可以使用：

- [`cache:key:files`](../yaml/_index.md#cachekeyfiles)：生成与特定文件内容关联的键。
- [`cache:key:files_commits`](../yaml/_index.md#cachekeyfiles_commits)：生成与特定文件的最新提交关联的键。

更多用例和示例，请参阅 [CI/CD 缓存示例](examples.md)。

<a id="how-cache-is-different-from-artifacts"></a>

## 缓存与产物的区别

使用缓存存储从互联网下载的依赖项，例如软件包。缓存存储在安装 GitLab Runner 的位置，如果启用了[分布式缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)，还会上传至 S3。

产物用于在阶段之间传递中间构建结果。产物由作业生成，存储在极狐GitLab 中，可供下载。

产物和缓存都相对于项目目录定义其路径，不能链接到目录外的文件。

<a id="cache"></a>

### 缓存

- 使用 `cache` 关键字按作业定义缓存，否则将被禁用。
- 后续流水线可以使用缓存。
- 如果依赖项相同，同一流水线中的后续作业可以使用缓存。
- 不同项目无法共享缓存。
- 默认情况下，受保护和未受保护的分支[不共享缓存](#cache-key-names)。但你可以[更改此行为](#use-the-same-cache-for-all-branches)。

<a id="artifacts"></a>

### 产物

- 按作业定义产物。
- 同一流水线后续阶段的作业可以使用产物。
- 产物默认在 30 天后过期。你可以定义自定义[过期时间](../yaml/_index.md#artifactsexpire_in)。
- 如果启用了[保留最新产物](../jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs)，最新产物不会过期。
- 使用 [dependencies](../yaml/_index.md#dependencies) 控制哪些作业获取产物。

<a id="good-caching-practices"></a>

## 良好的缓存实践

为了确保缓存的最大可用性，请执行以下一项或多项操作：

- [为 Runner 打标签](../runners/configure_runners.md#control-jobs-that-a-runner-can-run) 并在共享缓存的作业上使用这些标签。
- [使用仅对特定项目可用的 Runner](../runners/runners_scope.md#prevent-a-project-runner-from-being-enabled-for-other-projects)。
- [使用适合你工作流的 `key`](../yaml/_index.md#cachekey)。例如，你可以为每个分支配置不同的缓存。

为了让 Runner 有效使用缓存，你必须执行以下操作之一：

- 为所有作业使用单个 Runner。
- 使用多个已启用[分布式缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)的 Runner，缓存存储在 S3 桶中。JihuLab.com 上的实例 Runner 即采用此方式。这些 Runner 可以处于自动伸缩模式，但不强制要求。要管理缓存对象，应用生命周期规则，在一段时间后删除缓存对象。生命周期规则在对象存储服务器上可用。
- 使用多个架构相同的 Runner，并让这些 Runner 共享一个通用的网络挂载目录来存储缓存。此目录应使用 NFS 或类似技术。这些 Runner 必须处于自动伸缩模式。

<a id="use-multiple-caches"></a>

## 使用多个缓存

每个作业最多可以有四个缓存：

```yaml
test-job:
  stage: build
  cache:
    - key:
        files:
          - Gemfile.lock
      paths:
        - vendor/ruby
    - key:
        files:
          - yarn.lock
      paths:
        - .yarn-cache/
  script:
    - bundle config set --local path 'vendor/ruby'
    - bundle install
    - yarn install --cache-folder .yarn-cache
    - echo Run tests...
```

如果多个缓存与回退缓存键结合使用，则每次找不到缓存时都会获取全局回退缓存。

<a id="use-a-fallback-cache-key"></a>

## 使用回退缓存键

<a id="per-cache-fallback-keys"></a>

### 每个缓存的回退键

{{< history >}}

- 在极狐GitLab 16.0 中引入。

{{< /history >}}

每个缓存条目通过 [`fallback_keys` 关键字](../yaml/_index.md#cachefallback_keys)最多支持五个回退键。当作业找不到缓存键时，作业会尝试获取回退缓存。回退键按顺序查找，直到找到缓存。如果未找到任何缓存，作业将在不使用缓存的情况下运行。例如：

```yaml
test-job:
  stage: build
  cache:
    - key: cache-$CI_COMMIT_REF_SLUG
      fallback_keys:
        - cache-$CI_DEFAULT_BRANCH
        - cache-default
      paths:
        - vendor/ruby
  script:
    - bundle config set --local path 'vendor/ruby'
    - bundle install
    - echo Run tests...
```

在此示例中：

1. 作业查找 `cache-$CI_COMMIT_REF_SLUG` 缓存。
1. 如果未找到 `cache-$CI_COMMIT_REF_SLUG`，作业查找 `cache-$CI_DEFAULT_BRANCH` 作为回退选项。
1. 如果也未找到 `cache-$CI_DEFAULT_BRANCH`，作业查找 `cache-default` 作为第二个回退选项。
1. 如果都未找到，作业将在不使用缓存的情况下下载所有 Ruby 依赖项，但在作业完成时会为 `cache-$CI_COMMIT_REF_SLUG` 创建新缓存。

回退键遵循与 `cache:key` 相同的处理逻辑：

- 如果[手动清除缓存](#clear-the-cache-manually)，每个缓存回退键会像其他缓存键一样附加索引。
- 如果启用了[**为受保护分支使用单独的缓存**](#cache-key-names)设置，每个缓存回退键会附加 `-protected` 或 `-non_protected`。

<a id="global-fallback-key"></a>

### 全局回退键

你可以使用 `$CI_COMMIT_REF_SLUG` [预定义变量](../variables/predefined_variables.md) 来指定 [`cache:key`](../yaml/_index.md#cachekey)。例如，如果 `$CI_COMMIT_REF_SLUG` 是 `test`，你可以设置作业下载标记为 `test` 的缓存。

如果找不到带有此标记的缓存，你可以使用 `CACHE_FALLBACK_KEY` 指定在无缓存时使用的缓存。

在以下示例中，如果未找到 `$CI_COMMIT_REF_SLUG`，作业将使用由 `CACHE_FALLBACK_KEY` 变量定义的键：

```yaml
variables:
  CACHE_FALLBACK_KEY: fallback-key

job1:
  script:
    - echo
  cache:
    key: "$CI_COMMIT_REF_SLUG"
    paths:
      - binaries/
```

缓存提取顺序为：

1. 尝试获取 `cache:key`
1. 按顺序尝试 `fallback_keys` 中的每个条目
1. 尝试获取 `CACHE_FALLBACK_KEY` 中的全局回退键

首次成功获取缓存后，缓存提取过程即停止。

<a id="disable-cache-for-specific-jobs"></a>

## 为特定作业禁用缓存

如果全局定义了缓存，则每个作业都使用相同的定义。你可以按作业覆盖此行为。

要完全禁用作业的缓存，请使用空列表：

```yaml
job:
  cache: []
```

<a id="inherit-global-configuration-but-override-specific-settings-per-job"></a>

## 继承全局配置，但按作业覆盖特定设置

你可以使用[锚点](../yaml/yaml_optimization.md#anchors)在不覆盖全局缓存的情况下覆盖缓存设置。例如，如果你想覆盖一个作业的 `policy`：

```yaml
default:
  cache: &global_cache
    key: $CI_COMMIT_REF_SLUG
    paths:
      - node_modules/
      - public/
      - vendor/
    policy: pull-push

job:
  cache:
    # 继承所有全局缓存设置
    <<: *global_cache
    # 覆盖 policy
    policy: pull
```

更多信息，请参见 [`cache: policy`](../yaml/_index.md#cachepolicy)。

<a id="cache-key-names"></a>

## 缓存键名称

{{< history >}}

- 在极狐GitLab 15.0 中引入。
- 针对维护者角色及更高角色的 `-protected` 后缀[引入于](https://gitlab.cn/releases/2025/11/26/patch-release-gitlab-18-6-1-released/)极狐GitLab 18.4.5。

{{< /history >}}

缓存键会添加后缀，但[全局回退缓存键](#global-fallback-key)除外。

如果流水线满足以下条件，缓存键将获得 `-protected` 后缀：

- 针对受保护分支或标签运行。用户必须有向[受保护分支](../../user/project/repository/branches/protected.md)合并的权限，或有创建[受保护标签](../../user/project/protected_tags.md)的权限。
- 由具有维护者或所有者角色的用户启动。

其他流水线中生成的键将获得 `non_protected` 后缀。

例如，假设：

- `cache:key` 设置为 `$CI_COMMIT_REF_SLUG`。
- `main` 是受保护分支。
- `feature` 是未受保护分支。

| 分支        | 开发者角色缓存键       | 维护者角色缓存键       |
|------------|----------------------|----------------------|
| `main`     | `main-protected`     | `main-protected`     |
| `feature`  | `feature-non_protected` | `feature-protected`  |

此外，对于标签流水线，标签的受保护状态决定后缀，而非流水线执行所在的分支。此行为确保一致的安全边界，因为触发引用决定缓存访问权限。

例如，假设：

- `cache:key` 设置为 `$CI_COMMIT_TAG`。
- `main` 是受保护分支。
- `feature` 是未受保护分支。
- `1.0.0` 是受保护标签。
- `1.1.1-rc1` 是未受保护标签。

| 标签         | 分支      | 开发者角色缓存键           | 维护者角色缓存键           |
|-------------|-----------|--------------------------|--------------------------|
| `1.0.0`     | `main`    | `1.0.0-protected`        | `1.0.0-protected`        |
| `1.0.0`     | `feature` | `1.0.0-protected`        | `1.0.0-protected`        |
| `1.1.1-rc1` | `main`    | `1.1.1-rc1-non_protected` | `1.1.1-rc1-protected`    |
| `1.1.1-rc1` | `feature` | `1.1.1-rc1-non_protected` | `1.1.1-rc1-protected`    |

<a id="use-the-same-cache-for-all-branches"></a>

### 为所有分支使用相同的缓存

{{< history >}}

- 在极狐GitLab 15.0 中引入。

{{< /history >}}

如果你不想使用[缓存键名称](#cache-key-names)，你可以让所有分支（受保护和未受保护）使用相同的缓存。

通过[缓存键名称](#cache-key-names)进行缓存隔离是一项安全功能，仅在高度信任所有具有开发者角色的用户的环境中才应禁用。

要为所有分支使用相同的缓存：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **通用流水线**。
1. 清除 **为受保护分支使用单独的缓存** 复选框。
1. 选择 **保存更改**。

<a id="availability-of-the-cache"></a>

## 缓存的可用性

缓存是一种优化，但不能保证始终可用。你可能需要在每个需要它的作业中重新生成缓存文件。

在 [`.gitlab-ci.yml` 中定义缓存](../yaml/_index.md#cache)后，缓存的可用性取决于：

- Runner 的执行器类型。
- 是否使用不同的 Runner 在作业之间传递缓存。

<a id="where-the-caches-are-stored"></a>

### 缓存的存储位置

为作业定义的所有缓存都归档在一个 `cache.zip` 文件中。Runner 配置决定了文件存储的位置。默认情况下，缓存存储在安装 GitLab Runner 的机器上。位置还取决于执行器类型。

| Runner 执行器      | 缓存的默认路径 |
| ----------------- | ------------ |
| [Shell](https://gitlab.cn/docs/runner/executors/shell/) | 本地，位于 `gitlab-runner` 用户的主目录下: `/home/gitlab-runner/cache/<user>/<project>/<cache-key>/cache.zip`。 |
| [Docker](https://gitlab.cn/docs/runner/executors/docker/) | 本地，位于 [Docker 卷](https://gitlab.cn/docs/runner/executors/docker/#configure-directories-for-the-container-build-and-cache)下: `/var/lib/docker/volumes/<volume-id>/_data/<user>/<project>/<cache-key>/cache.zip`。 |
| [Docker Machine](https://gitlab.cn/docs/runner/executors/docker_machine/)（自动伸缩 Runner） | 与 Docker 执行器相同。 |

如果你在作业中使用缓存和产物存储相同路径，缓存可能会被覆盖，因为缓存在产物之前恢复。

<a id="how-archiving-and-extracting-works"></a>

### 归档和解压的工作方式

此示例展示了两个连续阶段中的两个作业：

```yaml
stages:
  - build
  - test

default:
  cache:
    key: build-cache
    paths:
      - vendor/
  before_script:
    - echo "Hello"

job A:
  stage: build
  script:
    - mkdir vendor/
    - echo "build" > vendor/hello.txt
  after_script:
    - echo "World"

job B:
  stage: test
  script:
    - cat vendor/hello.txt
```

如果一台机器上安装了一个 Runner，那么项目的所有作业都在同一主机上运行：

1. 流水线开始。
1. `job A` 运行。
1. 提取缓存（如果找到）。
1. 执行 `before_script`。
1. 执行 `script`。
1. 执行 `after_script`。
1. 运行 `cache` 并将 `vendor/` 目录压缩为 `cache.zip`。然后根据 [Runner 的设置](#where-the-caches-are-stored)和 `cache: key`，将此文件保存到目录中。
1. `job B` 运行。
1. 提取缓存（如果找到）。
1. 执行 `before_script`。
1. 执行 `script`。
1. 流水线完成。

在单台机器上使用单个 Runner 时，不会出现 `job B` 可能在与 `job A` 不同的 Runner 上执行的问题。此设置保证缓存可以在阶段之间重用。仅当执行从 `build` 阶段转到 `test` 阶段且在同一 Runner/机器上时才有效。否则，缓存[可能不可用](#cache-mismatch)。

在缓存过程中，还需要注意以下几点：

- 如果另一个具有不同缓存配置的作业将其缓存保存到同一 zip 文件，它将被覆盖。如果使用基于 S3 的共享缓存，文件还会根据缓存键上传到 S3 对象。因此，两个具有不同路径但相同缓存键的作业会相互覆盖缓存。
- 从 `cache.zip` 中提取缓存时，zip 文件中的所有内容都提取到作业的工作目录（通常是拉取的代码仓库）中，并且 Runner 不关心 `job A` 的存档是否覆盖 `job B` 存档中的内容。

这样工作的原因是，为一个 Runner 创建的缓存通常无法在被另一个 Runner 使用时有效。不同的 Runner 可能运行在不同的架构上（例如，当缓存包含二进制文件时）。此外，由于不同的步骤可能由运行在不同机器上的 Runner 执行，这是一个安全的默认设置。

<a id="clearing-the-cache"></a>

## 清除缓存

Runner 使用[缓存](../yaml/_index.md#cache)通过重用现有数据来加速作业执行。这有时可能导致不一致的行为。

有两种方法可以获取全新的缓存副本。

<a id="clear-the-cache-by-changing-cache-key"></a>

### 通过更改 cache:key 清除缓存

修改 `.gitlab-ci.yml` 文件中 `cache: key` 的值。下次流水线运行时，缓存将存储在不同位置。

<a id="clear-the-cache-manually"></a>

### 手动清除缓存

你可以在极狐GitLab UI 中清除缓存：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 在右上角，选择 **清除 Runner 缓存**。

在下一次提交时，你的 CI/CD 作业将使用新的缓存。

> [!note]
> 每次手动清除缓存时，[内部缓存名称](#where-the-caches-are-stored)会更新。名称使用格式 `cache-<index>`，索引递增 1。旧缓存不会被删除。你可以手动从 Runner 存储中删除这些文件。

<a id="troubleshooting"></a>

## 问题排查

<a id="cache-mismatch"></a>

### 缓存不匹配

如果遇到缓存不匹配问题，可按照以下步骤进行排查。

| 缓存不匹配的原因 | 解决方法 |
| --------------- | ------- |
| 你为同一个项目使用了多个独立 Runner（非自动伸缩模式），且没有共享缓存。 | 为项目使用单个 Runner，或使用启用了分布式缓存的多个 Runner。 |
| 你使用了自动伸缩模式的 Runner，但未启用分布式缓存。 | 配置自动伸缩 Runner 使用分布式缓存。 |
| 安装 Runner 的机器磁盘空间不足，或者如果设置了分布式缓存，存储缓存的 S3 桶空间不足。 | 确保释放一些空间以允许存储新缓存。没有自动执行此操作的方法。 |
| 你对缓存不同路径的作业使用了相同的 `key`。 | 使用不同的缓存键，以便缓存存档存储在不同位置，不会覆盖错误的缓存。 |
| 未在 Runner 上启用[分布式 Runner 缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)。 | 设置 `Shared = false` 并重新配置你的 Runner。 |

<a id="cache-mismatch-example-1"></a>

#### 缓存不匹配示例 1

如果仅有一个 Runner 分配给项目，则缓存默认存储在 Runner 的机器上。

如果两个作业具有相同的缓存键但路径不同，缓存可能会被覆盖。例如：

```yaml
stages:
  - build
  - test

job A:
  stage: build
  script: make build
  cache:
    key: same-key
    paths:
      - public/

job B:
  stage: test
  script: make test
  cache:
    key: same-key
    paths:
      - vendor/
```

1. `job A` 运行。
1. `public/` 被缓存为 `cache.zip`。
1. `job B` 运行。
1. 解压之前可能存在的缓存。
1. `vendor/` 被缓存为 `cache.zip` 并覆盖前一个。
1. 下次 `job A` 运行时，使用的是 `job B` 的缓存，内容不同，因此无效。

要解决此问题，请为每个作业使用不同的 `key`。

<a id="cache-mismatch-example-2"></a>

#### 缓存不匹配示例 2

在本示例中，你为项目分配了多个 Runner，且未启用分布式缓存。

第二次运行流水线时，你希望 `job A` 和 `job B` 重用其缓存（此处两者不同）：

```yaml
stages:
  - build
  - test

job A:
  stage: build
  script: build
  cache:
    key: keyA
    paths:
      - vendor/

job B:
  stage: test
  script: test
  cache:
    key: keyB
    paths:
      - vendor/
```

即使 `key` 不同，如果在后续流水线中作业运行在不同的 Runner 上，缓存文件可能会在每个阶段前被“清除”。

<a id="concurrent-runners-missing-local-cache"></a>

### 并发 Runner 缺少本地缓存

如果配置了多个并发 Runner 且使用 Docker 执行器，本地缓存文件可能不会像预期那样出现在并发运行的作业中。缓存卷的名称是为每个 Runner 实例唯一构建的，因此一个 Runner 实例缓存的文件无法被另一个 Runner 实例在缓存中找到。

要在并发 Runner 之间共享缓存，你可以：

- 使用 Runner 的 `config.toml` 的 `[runners.docker]` 部分，在主机上配置一个挂载点，映射到每个容器中的 `/cache`，例如 `volumes = ["/mnt/gitlab-runner/cache-for-all-concurrent-jobs:/cache"]`。此方法可防止 Runner 为并发作业创建唯一的卷名称。
- 使用分布式缓存。