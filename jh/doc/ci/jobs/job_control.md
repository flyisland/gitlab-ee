---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 控制作业的运行方式
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在新的流水线启动之前，极狐GitLab 会检查流水线配置，以确定哪些作业可以在该流水线中运行。您可以根据变量值或流水线类型等条件，使用 [`rules`](job_rules.md) 配置作业的运行方式。使用作业规则时，请了解如何[避免重复流水线](job_rules.md#avoid-duplicate-pipelines)。要控制流水线的创建，请使用 [`workflow:rules`](../yaml/workflow.md)。

<a id="create-a-job-that-must-be-run-manually"></a>

## 创建必须手动运行的作业

您可以要求作业只有在用户启动时才运行。这类作业称为**手动作业**。您可能希望将手动作业用于部署到生产环境等场景。

要将作业指定为手动作业，请在`.gitlab-ci.yml` 文件中为该作业添加 [`when: manual`](../yaml/_index.md#when)。

默认情况下，当流水线启动时，手动作业显示为已跳过。

您可以使用[受保护分支](../../user/project/repository/branches/protected.md)来更严格地[保护手动部署](#protect-manual-jobs)，防止未经授权的用户运行。

已[归档](../../administration/settings/continuous_integration.md#archive-pipelines)的手动作业不会运行。

<a id="types-of-manual-jobs"></a>

### 手动作业的类型

手动作业可以是可选的或阻塞的。

在可选手动作业中：

- [`allow_failure`](../yaml/_index.md#allow_failure) 为 `true`，这是在 `rules` 之外定义 `when: manual`的作业的默认设置。
- 该状态不会影响整体流水线状态。即使所有手动作业都失败，流水线仍可成功。

在阻塞手动作业中：

- `allow_failure` 为 `false`，这是在 [`rules`](../yaml/_index.md#rules) 内定义 `when: manual`的作业的默认设置。
- 流水线会在定义该作业的阶段停止。要让流水线
  继续运行，请[运行该手动作业](#run-a-manual-job)。
- 在启用了[**流水线必须成功**](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)
  的项目中，合并请求无法在流水线被阻塞的情况下合并。
- 流水线显示的状态为 **已阻止**。

在下游流水线中使用手动作业并配合 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 时，手动作业的类型可能会在流水线运行期间影响触发作业的状态。

<a id="run-a-manual-job"></a>

### 运行手动作业

要运行手动作业，您必须拥有合并到所分配分支的权限：

1. 转到流水线、作业、[环境](../environments/deployments.md#configure-manual-deployments)
   或部署视图。
1. 在手动作业旁边，选择**运行** ({{< icon name="play" >}})。

<a id="specify-variables-when-running-manual-jobs"></a>

### 运行手动作业时指定变量

运行手动作业时，您可以提供额外的作业专属 CI/CD 变量。当您想要更改使用 [CI/CD 变量](../variables/_index.md)的作业的执行方式时，可在此处指定变量。

对于在运行和重试手动作业时均可覆盖的类型化、经过验证的参数，请改用[作业输入](job_inputs.md)。

要运行手动作业并指定额外变量：

- 在流水线视图中选择手动作业的**名称**，而不是**运行** ({{< icon name="play" >}})。
- 在表单中，添加变量键值对。
- 选择**运行作业**。

> [!warning]
> 任何拥有运行手动作业权限的项目成员都可以重试该作业，并查看作业初次运行时提供的变量。这包括：
>
> - 在公开项目中：拥有开发者、维护者或所有者角色的用户。
> - 在私有或内部项目中：拥有访客、计划者、报告者、开发者、维护者或所有者角色的用户。
>
> 在将敏感信息作为手动作业变量输入时，请考虑此可见性。

如果您添加的变量已在 CI/CD 设置或`.gitlab-ci.yml` 文件中定义，则该[变量会被新值覆盖](../variables/_index.md#use-pipeline-variables)。通过此过程覆盖的任何变量都会被[展开](../variables/_index.md#allow-cicd-variable-expansion)，而不会被[掩码](../variables/_index.md#mask-a-cicd-variable)。

<a id="retry-a-manual-job-with-updated-variables"></a>

#### 使用更新后的变量重试手动作业

当您重试之前使用手动指定的变量运行过的手动作业时，您可以更新这些变量，或使用相同的变量。

要使用类型化、经过验证的参数重试手动作业，请改用[作业输入](job_inputs.md)。

要使用之前指定的变量重试手动作业：

- 使用相同的变量：
  - 在作业详情页中，选择**重试** ({{< icon name="retry" >}})。
- 使用更新后的变量：
  - 在作业详情页中，从下拉列表中选择**使用修改后的值重试作业**。
  - 上次运行中指定的变量会预填到表单中。
    您可以在此表单中添加、修改或删除 CI/CD 变量。
  - 选择**再次运行作业**。

<a id="require-confirmation-for-manual-jobs"></a>

### 要求手动作业进行确认

将 [`manual_confirmation`](../yaml/_index.md#manual_confirmation) 与 `when: manual` 配合使用，以要求手动作业进行确认。这有助于防止敏感作业（例如部署到生产环境的作业）发生意外部署或删除。

运行该作业时，您必须在它运行之前确认该操作。

<a id="protect-manual-jobs"></a>

### 保护手动作业

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用[受保护环境](../environments/protected_environments.md)定义有权运行手动作业的用户列表。您可以仅授权与受保护环境关联的用户运行手动作业，这可以：

- 更精确地限制谁可以部署到某个环境。
- 阻止流水线，直到获得批准的用户“批准”它。

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

1. 在[受保护环境设置](../environments/protected_environments.md#protecting-environments)中，
   选择该环境（本示例中为 `production`），并将有权运行该手动作业的用户、角色或群组
   添加到**允许部署**列表中。只有此列表中的用户或极狐GitLab 管理员才能运行此手动作业。

您可以将受保护环境与阻塞手动作业配合使用，以获得一份允许批准后续流水线阶段的用户列表。为受保护的手动作业添加 `allow_failure: false`，则流水线的后续阶段只有在获得授权的用户触发该手动作业后才会运行。

<a id="run-a-job-after-a-delay"></a>

## 延迟后运行作业

使用 [`when: delayed`](../yaml/_index.md#when) 在等待一段时间后执行脚本，或者当您想要避免作业立即进入 `pending` 状态时使用。

您可以使用 `start_in` 关键字设置该时间段。除非提供了单位，否则 `start_in`的值是以秒为单位的经过时间。最小值为一秒，最大值为一周。有效值示例包括：

- `'5'`（不带单位的值必须用单引号括起来）
- `5 seconds`
- `30 minutes`
- `1 day`
- `1 week`

当某个阶段包含延迟作业时，流水线在该延迟作业完成之前不会继续推进。您可以使用此关键字在不同阶段之间插入延迟。

延迟作业的计时器会在上一阶段完成后立即启动。与其他类型的作业类似，除非上一阶段通过，否则延迟作业的计时器不会启动。

以下示例创建一个名为 `timed rollout 10%` 的作业，该作业在上一阶段完成后 30 分钟执行：

```yaml
timed rollout 10%:
  stage: deploy
  script: echo 'Rolling out 10% ...'
  when: delayed
  start_in: 30 minutes
  environment: production
```

要停止延迟作业的活动计时器，请选择**取消计划** ({{< icon name="time-out" >}})。该作业将无法再被安排自动运行。不过，您可以手动执行该作业。

要手动启动延迟作业，请选择**取消计划** ({{< icon name="time-out" >}}) 以停止延迟计时器，然后选择**运行** ({{< icon name="play" >}})。
随后极狐GitLab Runner 会启动作业。

已[归档](../../administration/settings/continuous_integration.md#archive-pipelines)的延迟作业不会运行。

<a id="parallelize-large-jobs"></a>

## 并行化大型作业

要将大型作业拆分为多个并行运行的较小作业，请在`.gitlab-ci.yml` 文件中使用 [`parallel`](../yaml/_index.md#parallel) 关键字。

不同的语言和测试套件有不同的并行化方法。
例如，使用 [Semaphore Test Boosters](https://github.com/renderedtext/test-boosters)
和 RSpec 并行运行 Ruby 测试：

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

然后，您可以转到新流水线构建的**作业**标签页，查看您的 RSpec 作业被拆分为三个独立的作业。

> [!warning]
> Test Boosters 会向作者报告使用统计数据。

<a id="run-a-one-dimensional-matrix-of-parallel-jobs"></a>

### 运行一维并行作业矩阵

要在单个流水线中并行多次运行一个作业，但每次作业实例使用不同的值，请使用 [`parallel:matrix`](../yaml/_index.md#parallelmatrix) 关键字：

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

在此示例中，会创建 4 个 `deploystacks` 作业，`PROVIDER` 成为 CI/CD 变量，每个作业中的值各不相同：

- `deploystacks: [aws]`
- `deploystacks: [ovh]`
- `deploystacks: [gcp]`
- `deploystacks: [vultr]`

<a id="run-a-matrix-of-parallel-trigger-jobs"></a>

### 运行并行触发作业矩阵

您可以在单个流水线中并行多次运行一个[触发](../yaml/_index.md#trigger)作业，但每次作业实例可用的变量各不相同。

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

此示例生成 6 个并行的 `deploystacks` 触发作业，每个作业的 `PROVIDER` 和 `STACK` 值各不相同，它们使用这些变量创建 6 个不同的子流水线。

```plaintext
deploystacks: [aws, monitoring]
deploystacks: [aws, app1]
deploystacks: [ovh, monitoring]
deploystacks: [ovh, backup]
deploystacks: [gcp, data]
deploystacks: [vultr, data]
```

<a id="select-different-runner-tags-for-each-parallel-matrix-job"></a>

### 为每个并行矩阵作业选择不同的 runner 标签

您可以将 `parallel: matrix`中定义的值与 [`tags`](../yaml/_index.md#tags) 关键字配合使用，以实现动态 runner 选择：

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

<a id="use-matrix-variables-in-rules"></a>

### 在规则中使用矩阵变量

极狐GitLab 会为每个单独的矩阵作业分别评估规则，并使用该作业的变量值。

<a id="use-matrix-variables-in-rulesif"></a>

#### 在 `rules:if`中使用矩阵变量

在 [`rules:if`](../yaml/_index.md#rulesif) 表达式中使用矩阵变量，以根据变量值包含或排除单个矩阵作业。

例如，当矩阵变量 `SKIP` 设置为 `"true"` 时跳过作业：

```yaml
test:
  script: echo "Building $ARCH"
  parallel:
    matrix:
      - ARCH: [amd64, arm64]
        SKIP: ["false", "true"]
  rules:
    - if: $SKIP == "true"
      when: never
    - when: on_success
```

只有 `SKIP` 为 `"false"` 的作业才会包含在流水线中。

> [!note]
> `rules:if`中的矩阵变量不支持嵌套展开。如果矩阵变量的值
> 引用了另一个 CI/CD 变量（例如 `FILE: $GLOBAL_FILE`），该引用不会被
> 解析。表达式使用字面字符串值，因此 `$FILE` 会求值为 `"$GLOBAL_FILE"`，
> 而不是 `GLOBAL_FILE`的值。

<a id="use-matrix-variables-in-ruleschanges"></a>

#### 在 `rules:changes`中使用矩阵变量

在 [`rules:changes`](../yaml/_index.md#ruleschanges) 路径中使用矩阵变量，以仅当与该作业相关的文件发生更改时才包含该矩阵作业。在 monorepo 中，当每个矩阵值对应一个拥有自己目录的组件或服务时，可使用此模式。

例如，仅针对文件发生更改的组件运行测试作业：

```yaml
test:
  script: echo "Testing $COMPONENT"
  parallel:
    matrix:
      - COMPONENT: [frontend, backend, database]
  rules:
    - if: $CI_PIPELINE_SOURCE == "push"
      changes:
        - components/$COMPONENT/**/*
```

在此示例中：

- 会评估三个 `test` 作业，每个 `COMPONENT` 值对应一个。
- 每个作业都会使用替换到路径中的自己的 `$COMPONENT` 值来检查 `rules:changes`。
- 只有匹配文件发生更改的作业才会添加到流水线中。

例如，如果只有 `components/frontend/npm.lock` 发生更改，则只有 `frontend` 作业会运行。

您可以在同一路径中使用多个矩阵变量：

```yaml
test:
  script: echo "Testing $SERVICE in $ENV"
  parallel:
    matrix:
      - SERVICE: [api, web]
        ENV: [dev, prod]
  rules:
    - changes:
        - config/$SERVICE/$ENV/**/*
```

<a id="use-matrix-variables-in-rulesexists"></a>

#### 在 `rules:exists`中使用矩阵变量

在 [`rules:exists`](../yaml/_index.md#rulesexists) 路径中使用矩阵变量，以仅当特定文件存在时才包含该矩阵作业。

例如：

```yaml
test:
  script: echo "Testing $TYPE"
  parallel:
    matrix:
      - TYPE: [go, ruby, python]
  rules:
    - exists:
        - "**/*.$TYPE"
```

<a id="fetch-artifacts-from-a-parallelmatrix-job"></a>

### 从 `parallel:matrix` 作业获取产物

您可以使用 [`dependencies`](../yaml/_index.md#dependencies) 关键字，从使用 [`parallel:matrix`](../yaml/_index.md#parallelmatrix) 创建的作业中获取产物。将作业名称作为 `dependencies`的值，以如下形式的字符串表示：

```plaintext
<job_name> [<matrix argument 1>, <matrix argument 2>, ... <matrix argument N>]
```

例如，要获取 `RUBY_VERSION` 为 `2.7` 且 `PROVIDER` 为 `aws`的作业的产物：

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

`dependencies` 条目周围的引号是必需的。

<a id="specify-a-parallelized-job-using-needs-with-multiple-parallelized-jobs"></a>

### 使用 needs 与多个并行化作业指定并行化作业

使用 [`needs:parallel:matrix`](../yaml/_index.md#needsparallelmatrix) 在多个并行化作业之间创建[作业依赖关系](../yaml/needs.md)。

您可以使用两种配置方法：

- 使用 [`matrix.` 表达式](../yaml/matrix_expressions.md)自动配置。
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

此示例生成多个作业。并行作业的 `PROVIDER` 和 `STACK` 值各不相同。

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

- Linux 路径：`linux:rspec` 作业在 `linux:build: [aws, app1]`
  作业完成后立即运行，无需等待 `mac:build` 完成。
- macOS 路径：`mac:rspec` 作业在 `mac:build: [gcp, data]` 和
  `mac:build: [vultr, data]` 作业完成后立即运行，无需等待 `linux:build` 完成。
- `production` 作业在所有先前的作业完成后立即运行。

<a id="specify-needs-between-parallelized-jobs"></a>

#### 在并行化作业之间指定 needs

您可以使用 [`needs:parallel:matrix`](../yaml/_index.md#needsparallelmatrix) 进一步定义每个并行矩阵作业的顺序。

例如：

```yaml
build_job:
  stage: build
  script:
    # ensure that other parallel job other than build_job [1, A] runs longer
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

此示例生成多个作业。并行作业的 `VERSION` 和 `MODE` 值各不相同。

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

在某些边缘情况下，运行手动作业的用户不会被分配为依赖该手动作业的后续作业的用户。

如果您需要对依赖手动作业的作业的用户分配进行严格的安全控制，则应[保护该手动作业](#protect-manual-jobs)。
