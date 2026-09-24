---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 控制作业运行
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在新流水线启动前，极狐GitLab 会检查流水线配置以确定哪些作业可以在该流水线中运行。您可以根据变量值或流水线类型等条件，使用 [`rules`](job_rules.md) 配置作业运行。在使用作业规则时，了解如何[避免重复流水线](job_rules.md#avoid-duplicate-pipelines)。要控制流水线的创建，使用 [`workflow:rules`](../yaml/workflow.md)。

<a id="create-a-job-that-must-be-run-manually"></a>

## 创建必须手动运行的作业

您可以要求作业在用户启动后才运行，这被称为 **手动作业**。您可能希望对部署到生产环境之类的操作使用手动作业。

要将作业指定为手动，在 `.gitlab-ci.yml` 文件中的作业里添加 [`when: manual`](../yaml/_index.md#when)。

默认情况下，当流水线开始时，手动作业显示为已跳过。

您可以使用[受保护的分支](../../user/project/repository/branches/protected.md)来更严格地[保护手动部署](#protect-manual-jobs)，防止未经授权的用户运行。

[已归档](../../administration/settings/continuous_integration.md#archive-pipelines)的手动作业不会运行。

<a id="types-of-manual-jobs"></a>

### 手动作业的类型

手动作业可以是可选作业或阻塞作业。

在可选手动作业中：

- [`allow_failure`](../yaml/_index.md#allow_failure) 为 `true`，这也是在 `rules` 之外定义了 `when: manual` 的作业的默认设置。
- 状态不影响整个流水线状态。即使所有手动作业都失败，流水线也能成功。

在阻塞手动作业中：

- `allow_failure` 为 `false`，这也是在 [`rules`](../yaml/_index.md#rules) 内部定义了 `when: manual` 的作业的默认设置。
- 流水线会在定义该作业的阶段停止。要让流水线继续运行，[运行该手动作业](#run-a-manual-job)。
- 在启用了[**流水线必须成功**](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)的项目中，合并请求不能在流水线阻塞时合并。
- 流水线显示 **阻塞** 状态。

在下游流水线中使用带有 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 的手动作业时，手动作业的类型会影响触发作业在流水线运行期间的状态。

<a id="run-a-manual-job"></a>

### 运行手动作业

要运行手动作业，您必须拥有合并到指定分支的权限：

1. 转到流水线、作业、[环境](../environments/deployments.md#configure-manual-deployments)或部署视图。
1. 在手动作业旁边，选择 **运行** ({{< icon name="play" >}})。

<a id="specify-variables-when-running-manual-jobs"></a>

### 运行手动作业时指定变量

在运行手动作业时，您可以提供额外的作业特定的 CI/CD 变量。当您想要改变使用 [CI/CD 变量](../variables/_index.md)的作业的执行方式时，可在此处指定变量。

对于在运行和重试手动作业时都可覆盖的类型化、已验证参数，请改用[作业输入](job_inputs.md)。

要运行手动作业并指定额外变量：

- 在流水线视图中选择手动作业的 **名称**，而不是 **运行** ({{< icon name="play" >}})。
- 在表单中添加变量键值对。
- 选择 **运行作业**。

> [!warning]
> 任何有权运行手动作业的项目成员都可以重试该作业并查看最初运行时提供的变量。这包括：
>
> - 在公开项目中：具有开发者、维护者或所有者角色的用户。
> - 在私有或内部项目中：具有访客、计划者、报告者、开发者、维护者或所有者角色的用户。
>
> 请输入敏感信息作为手动作业变量时，请考虑此可见性。

如果您添加的变量已在 CI/CD 设置或 `.gitlab-ci.yml` 文件中定义，[变量将被新值覆盖](../variables/_index.md#use-pipeline-variables)。通过此过程覆盖的任何变量都会[展开](../variables/_index.md#allow-cicd-variable-expansion)且不会被[屏蔽](../variables/_index.md#mask-a-cicd-variable)。

<a id="retry-a-manual-job-with-updated-variables"></a>

#### 使用更新的变量重试手动作业

{{< history >}}

在极狐GitLab 15.7 引入。

{{< /history >}}

当您重试一个先前使用手动指定变量运行过的手动作业时，您可以更新变量或使用相同的变量。

要使用类型化、已验证的参数重试手动作业，请改用[作业输入](job_inputs.md)。

要使用先前指定的变量重试手动作业：

- 使用相同变量：
  - 从作业详情页，选择 **重试** ({{< icon name="retry" >}})。
- 使用更新后的变量：
  - 从作业详情页，在下拉菜单中选择 **使用修改后的值重试作业**。
  - 先前运行中指定的变量会预填在表单中。您可以在该表单中添加、修改或删除 CI/CD 变量。
  - 选择 **再次运行作业**。

<a id="require-confirmation-for-manual-jobs"></a>

### 要求确认手动作业

将 [`manual_confirmation`](../yaml/_index.md#manual_confirmation) 与 `when: manual` 结合使用，以要求对手动作业进行确认。这有助于防止意外部署或删除敏感作业，例如部署到生产环境的作业。

当您运行该作业时，必须在运行前确认该操作。

<a id="protect-manual-jobs"></a>

### 保护手动作业

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用[受保护的环境](../environments/protected_environments.md)来定义有权运行手动作业的用户列表。您可以仅授权与受保护环境关联的用户运行手动作业，这可以：

- 更精确地限制谁可以部署到环境。
- 在获得批准用户的“核准”之前阻塞流水线。

要保护手动作业：

1. 为作业添加 `environment`。例如：

   ```yaml
   deploy_prod:
     stage: deploy
     script:
       - echo "Deploy to production server"
     environment:
       name: production
       url: https://example.com
     when: manual
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
   ```

1. 在[受保护环境设置](../environments/protected_environments.md#protecting-environments)中，选择环境（本例中为 `production`）并将有权运行该手动作业的用户、角色或群组添加到 **允许部署** 列表。只有此列表中的用户以及始终可以使用受保护环境的极狐GitLab 管理员才能运行此手动作业。

您可以将受保护环境与阻塞手动作业结合使用，以获得一个允许批准后续流水线阶段的用户列表。将 `allow_failure: false` 添加到受保护的手动作业中，流水线的后续阶段仅在授权用户触发手动作业后才会运行。

<a id="run-a-job-after-a-delay"></a>

## 延迟后运行作业

使用 [`when: delayed`](../yaml/_index.md#when) 在等待一段时期后执行脚本，或者当您希望避免作业立即进入 `pending` 状态时。

您可以使用 `start_in` 关键字设置等待时间。除非提供了单位，否则 `start_in` 的值是以秒为单位的经过时间。最小值为一秒，最大值为一周。有效值的示例包括：

- `'5'`（无单位的值必须用单引号括起来）
- `5 seconds`
- `30 minutes`
- `1 day`
- `1 week`

当一个阶段包含延迟作业时，流水线在延迟作业完成之前不会继续。您可以使用此关键字在不同阶段之间插入延迟。

延迟作业的计时器在前一个阶段完成后立即开始。与其他类型的作业类似，延迟作业的计时器只有在前一个阶段通过后才会开始。

以下示例创建一个名为 `timed rollout 10%` 的作业，该作业在前一个阶段完成后 30 分钟执行：

```yaml
timed rollout 10%:
  stage: deploy
  script: echo 'Rolling out 10% ...'
  when: delayed
  start_in: 30 minutes
  environment: production
```

要停止延迟作业的活跃计时器，选择 **取消计划** ({{< icon name="time-out" >}})。此作业将无法再自动调度运行。但是，您可以手动执行该作业。

要手动启动延迟作业，选择 **取消计划** ({{< icon name="time-out" >}}) 停止延迟计时器，然后选择 **运行** ({{< icon name="play" >}})。很快极狐GitLab Runner 便会启动作业。

[已归档](../../administration/settings/continuous_integration.md#archive-pipelines)的延迟作业不会运行。

<a id="parallelize-large-jobs"></a>

## 并行化大型作业

要将大型作业拆分为多个并行运行的较小作业，请在 `.gitlab-ci.yml` 文件中使用 [`parallel`](../yaml/_index.md#parallel) 关键字。

不同的语言和测试套件有不同的并行化方法。例如，使用 [Semaphore Test Boosters](https://github.com/renderedtext/test-boosters) 和 RSpec 并行运行 Ruby 测试：

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'rspec'
gem 'semaphore_test_boosters'
```

```yaml
test:
  parallel: 3
  script:
    - bundle
    - bundle exec rspec_booster --job $CI_NODE_INDEX/$CI_NODE_TOTAL
```

然后您可以转到新流水线构建的 **作业** 选项卡，看到您的 RSpec 作业拆分成三个独立的作业。

> [!warning]
> Test Boosters 会向作者报告使用统计信息。

<a id="run-a-one-dimensional-matrix-of-parallel-jobs"></a>

### 运行并行作业的一维矩阵

要在单个流水线中并行运行多次作业，但为每个作业实例提供不同的值，请使用 [`parallel:matrix`](../yaml/_index.md#parallelmatrix) 关键字：

```yaml
deploystacks:
  stage: deploy
  script:
    - bin/deploy
  parallel:
    matrix:
      - PROVIDER: [aws, ovh, gcp, vultr]
  environment: production/$PROVIDER
```

在此示例中，创建了 4 个 `deploystacks` 作业，`PROVIDER` 成为一个在每个作业中具有不同值的 CI/CD 变量：

- `deploystacks: [aws]`
- `deploystacks: [ovh]`
- `deploystacks: [gcp]`
- `deploystacks: [vultr]`

<a id="run-a-matrix-of-parallel-trigger-jobs"></a>

### 运行并行触发作业的矩阵

您可以在单个流水线中并行运行多次[触发](../yaml/_index.md#trigger)作业，但为每个作业实例提供不同的可用变量。

例如：

```yaml
deploystacks:
  stage: deploy
  trigger:
    include: path/to/child-pipeline.yml
  parallel:
    matrix:
      - PROVIDER: aws
        STACK: [monitoring, app1]
      - PROVIDER: ovh
        STACK: [monitoring, backup]
      - PROVIDER: [gcp, vultr]
        STACK: [data]
```

此示例生成 6 个并行的 `deploystacks` 触发作业，每个作业具有不同的 `PROVIDER` 和 `STACK` 值，并使用这些变量创建 6 个不同的子流水线。

```plaintext
deploystacks: [aws, monitoring]
deploystacks: [aws, app1]
deploystacks: [ovh, monitoring]
deploystacks: [ovh, backup]
deploystacks: [gcp, data]
deploystacks: [vultr, data]
```

<a id="select-different-runner-tags-for-each-parallel-matrix-job"></a>

### 为每个并行矩阵作业选择不同的 Runner 标签

您可以将 `parallel: matrix` 中定义的值与 [`tags`](../yaml/_index.md#tags) 关键字结合使用，进行动态 Runner 选择：

```yaml
deploystacks:
  stage: deploy
  script:
    - bin/deploy
  parallel:
    matrix:
      - PROVIDER: aws
        STACK: [monitoring, app1]
      - PROVIDER: gcp
        STACK: [data]
  tags:
    - ${PROVIDER}-${STACK}
  environment: $PROVIDER/$STACK
```

<a id="fetch-artifacts-from-a-parallelmatrix-job"></a>

### 从 `parallel:matrix` 作业获取产物

您可以使用 [`dependencies`](../yaml/_index.md#dependencies) 关键字从由 [`parallel:matrix`](../yaml/_index.md#parallelmatrix) 创建的作业中获取产物。使用作业名称作为 `dependencies` 的字符串值，格式为：

```plaintext
<job_name> [<matrix argument 1>, <matrix argument 2>, ... <matrix argument N>]
```

例如，要从 `RUBY_VERSION` 为 `2.7` 且 `PROVIDER` 为 `aws` 的作业获取产物：

```yaml
ruby:
  image: ruby:${RUBY_VERSION}
  parallel:
    matrix:
      - RUBY_VERSION: ["2.5", "2.6", "2.7", "3.0", "3.1"]
        PROVIDER: [aws, gcp]
  script: bundle install

deploy:
  image: ruby:2.7
  stage: deploy
  dependencies:
    - "ruby: [2.7, aws]"
  script: echo hello
  environment: production
```

`dependencies` 条目必须用引号括起来。

<a id="specify-a-parallelized-job-using-needs-with-multiple-parallelized-jobs"></a>

### 使用 `needs` 指定并行化作业与多个并行化作业的依赖关系

{{< history >}}

在极狐GitLab 16.3 引入。

{{< /history >}}

使用 [`needs:parallel:matrix`](../yaml/_index.md#needsparallelmatrix) 在多个并行化作业之间创建[作业依赖关系](../yaml/needs.md)。

您可以使用两种配置技术：

- 使用 [`matrix.` 表达式](../yaml/matrix_expressions.md) 自动配置。
- 手动配置，如下所示。

例如：

```yaml
linux:build:
  stage: build
  script: echo "Building linux..."
  parallel:
    matrix:
      - PROVIDER: aws
        STACK:
          - monitoring
          - app1
          - app2

mac:build:
  stage: build
  script: echo "Building mac..."
  parallel:
    matrix:
      - PROVIDER: [gcp, vultr]
        STACK: [data, processing]

linux:rspec:
  stage: test
  needs:
    - job: linux:build
      parallel:
        matrix:
          - PROVIDER: aws
            STACK: app1
  script: echo "Running rspec on linux..."

mac:rspec:
  stage: test
  needs:
    - job: mac:build
      parallel:
        matrix:
          - PROVIDER: [gcp, vultr]
            STACK: [data]
  script: echo "Running rspec on mac..."

production:
  stage: deploy
  script: echo "Running production..."
  environment: production
```

此示例生成多个作业。并行作业各自具有不同的 `PROVIDER` 和 `STACK` 值。

- 3 个并行的 `linux:build` 作业：
  - `linux:build: [aws, monitoring]`
  - `linux:build: [aws, app1]`
  - `linux:build: [aws, app2]`
- 4 个并行的 `mac:build` 作业：
  - `mac:build: [gcp, data]`
  - `mac:build: [gcp, processing]`
  - `mac:build: [vultr, data]`
  - `mac:build: [vultr, processing]`
- 一个 `linux:rspec` 作业。
- 一个 `production` 作业。

这些作业有三条执行路径：

- Linux 路径：`linux:rspec` 作业在 `linux:build: [aws, app1]` 作业完成后立即运行，无需等待 `mac:build` 完成。
- macOS 路径：`mac:rspec` 作业在 `mac:build: [gcp, data]` 和 `mac:build: [vultr, data]` 作业完成后立即运行，无需等待 `linux:build` 完成。
- `production` 作业在所有之前的作业完成后立即运行。

<a id="specify-needs-between-parallelized-jobs"></a>

#### 指定并行化作业之间的 `needs` 依赖

您可以使用 [`needs:parallel:matrix`](../yaml/_index.md#needsparallelmatrix) 进一步定义每个并行矩阵作业的顺序。

例如：

```yaml
build_job:
  stage: build
  script:
    # 确保除 build_job [1, A] 之外的其他并行作业运行更长时间
    - '[[ "$VERSION" == "1" && "$MODE" == "A" ]] || sleep 30'
    - echo build $VERSION $MODE
  parallel:
    matrix:
      - VERSION: [1,2]
        MODE: [A, B]

deploy_job:
  stage: deploy
  script: echo deploy $VERSION $MODE
  parallel:
    matrix:
      - VERSION: [3,4]
        MODE: [C, D]

'deploy_job: [3, D]':
  stage: deploy
  script: echo something
  needs:
  - 'build_job: [1, A]'
```

此示例生成多个作业。并行作业各自具有不同的 `VERSION` 和 `MODE` 值。

- 4 个并行的 `build_job` 作业：
  - `build_job: [1, A]`
  - `build_job: [1, B]`
  - `build_job: [2, A]`
  - `build_job: [2, B]`
- 4 个并行的 `deploy_job` 作业：
  - `deploy_job: [3, C]`
  - `deploy_job: [3, D]`
  - `deploy_job: [4, C]`
  - `deploy_job: [4, D]`

`deploy_job: [3, D]` 作业在 `build_job: [1, A]` 作业完成后立即运行，无需等待其他 `build_job` 作业完成。

<a id="troubleshooting"></a>

## 故障排除

<a id="inconsistent-user-assignment-when-running-manual-jobs"></a>

### 运行手动作业时用户分配不一致

在某些边缘情况下，运行手动作业的用户不会被分配为依赖于该手动作业的后续作业的用户。

如果您需要对依赖于手动作业的作业的用户分配进行严格的安全控制，您应该[保护该手动作业](#protect-manual-jobs)。