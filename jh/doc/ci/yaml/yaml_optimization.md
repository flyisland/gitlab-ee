---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 优化极狐GitLab CI/CD 配置文件
description: Use YAML anchors, !reference tags, and the `extends` keyword to reduce CI/CD configuration file complexity.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以通过以下方式降低 极狐GitLab CI/CD 配置文件的复杂度和重复配置：

- 使用 YAML 特有的功能，例如[锚点 (`&`)](#锚点)、别名 (`*`) 和映射合并 (`<<`)。
  了解更多关于[各种 YAML 特性](https://learnxinyminutes.com/docs/yaml/)的信息。
- 使用 [`扩展` 关键字](#使用扩展来重用配置部分)，
  它更加灵活且可读性更强。你应该在可能的情况下使用 `扩展`。

想要创建多个相似的作业，但变量值不同，请使用 [`并行：矩阵`](../jobs/job_control.md#run-a-matrix-of-parallel-trigger-jobs)。

<a id="anchors"></a>

## 锚点

YAML 有一项名为“锚点”的功能，你可以用它来在文档中复制内容。

你可以使用锚点来复制或继承属性。可以将锚点与[隐藏作业](../jobs/_index.md#hide-a-job)结合使用，为作业提供模板。

`&` 字符标记锚点名称，`*` 字符是引用该锚点的别名。你必须在 YAML 文件中将锚点定义在引用它的所有别名之上。

当存在重复的键时，最后包含的键会胜出，并覆盖其他键。

在某些情况下（参见[脚本中的 YAML 锚点](#脚本中的-yaml-锚点)），你可以使用 YAML 锚点来构建包含其他位置定义多个组件的数组。例如：

```yaml
.default_scripts: &default_scripts
  - ./default-script1.sh
  - ./default-script2.sh

job1:
  script:
    - *default_scripts
    - ./job-script.sh
```

当使用 [`包含`](_index.md#include) 关键字时，你不能跨多个文件使用 YAML 锚点。锚点仅在其定义的文件内有效。要从不同的 YAML 文件中重用配置，请使用 [`!引用` 标签](#引用-标签)或[`扩展` 关键字](#使用扩展来重用配置部分)。

以下示例使用了锚点和映射合并。它创建了两个作业 `test1` 和 `test2`，它们继承了 `.作业模板` 的配置，每个作业都定义了自己的自定义 `脚本`：

```yaml
.作业模板: &作业配置  # 隐藏的 YAML 配置，定义了一个名为 '作业配置' 的锚点
  镜像: ruby:2.6
  服务:
    - postgres
    - redis

test1:
  <<: *作业配置           # 添加 '作业配置' 别名的内容
  脚本:
    - test1 project

test2:
  <<: *作业配置           # 添加 '作业配置' 别名的内容
  脚本:
    - test2 project
```

`&` 用来设置锚点的名称（`作业配置`），`<<` 表示“将给定的哈希合并到当前哈希中”，`*` 表示引用命名的锚点（再次表示 `作业配置`）。此示例的[展开](../pipeline_editor/_index.md#view-full-configuration)版本如下：

```yaml
.作业模板:
  镜像: ruby:2.6
  服务:
    - postgres
    - redis

test1:
  镜像: ruby:2.6
  服务:
    - postgres
    - redis
  脚本:
    - test1 project

test2:
  镜像: ruby:2.6
  服务:
    - postgres
    - redis
  脚本:
    - test2 project
```

你可以使用锚点来定义两组服务。例如，`test:postgres` 和 `test:mysql` 共享定义在 `.作业模板` 中的 `脚本`，但使用定义在 `.postgres_服务` 和 `.mysql_服务` 中不同的 `服务`：

```yaml
.作业模板: &作业配置
  脚本:
    - test project
  标签:
    - dev

.postgres_服务:
  服务: &postgres_配置
    - postgres
    - ruby

.mysql_服务:
  服务: &mysql_配置
    - mysql
    - ruby

test:postgres:
  <<: *作业配置
  服务: *postgres_配置
  标签:
    - postgres

test:mysql:
  <<: *作业配置
  服务: *mysql_配置
```

[展开](../pipeline_editor/_index.md#view-full-configuration)版本如下：

```yaml
.作业模板:
  脚本:
    - test project
  标签:
    - dev

.postgres_服务:
  服务:
    - postgres
    - ruby

.mysql_服务:
  服务:
    - mysql
    - ruby

test:postgres:
  脚本:
    - test project
  服务:
    - postgres
    - ruby
  标签:
    - postgres

test:mysql:
  脚本:
    - test project
  服务:
    - mysql
    - ruby
  标签:
    - dev
```

你可以看到隐藏作业很方便地充当了模板，并且 `标签: [postgres]` 覆盖了 `标签: [dev]`。

<a id="yaml-anchors-for-scripts"></a>

### 脚本中的 YAML 锚点

{{< history >}}

- 在 极狐GitLab 16.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/439451) 了对 [`阶段`](_index.md#stages) 关键词使用锚点的支持。

{{< /history >}}

你可以将 [YAML 锚点](#锚点) 与 [`脚本`](_index.md#script)、[`前置脚本`](_index.md#before_script)以及[`后置脚本`](_index.md#after_script)一起使用，在多个作业中使用预定义的命令：

```yaml
.some-script-before: &some-script-before
  - echo "Execute this script first"

.some-script: &some-script
  - echo "Execute this script second"
  - echo "Execute this script too"

.some-script-after: &some-script-after
  - echo "Execute this script last"

job1:
  before_script:
    - *some-script-before
  script:
    - *some-script
    - echo "Execute something, for this job only"
  after_script:
    - *some-script-after

job2:
  script:
    - *some-script-before
    - *some-script
    - echo "Execute something else, for this job only"
    - *some-script-after
```

<a id="use-extends-to-reuse-configuration-sections"></a>

## 使用 `扩展` 来重用配置部分

你可以使用 [`扩展` 关键字](_index.md#extends) 在多个作业中重用配置。它与 [YAML 锚点](#锚点) 类似，但更简单，并且你可以[将 `扩展` 与 `包含` 一起使用](#同时使用扩展和包含)。

`扩展` 支持多层继承。由于会增加复杂性，你应该避免超过三层，但你最多可以使用十一层。以下示例包含两层继承：

```yaml
.tests:
  rules:
    - if: $CI_PIPELINE_SOURCE == "push"

.rspec:
  extends: .tests
  script: rake rspec

rspec 1:
  variables:
    RSPEC_SUITE: '1'
  extends: .rspec

rspec 2:
  variables:
    RSPEC_SUITE: '2'
  extends: .rspec

spinach:
  extends: .tests
  script: rake spinach
```

<a id="exclude-a-key-from-extends"></a>

### 从 `扩展` 中排除键

要从扩展内容中排除某个键，你必须将其赋值为 `null`，例如：

```yaml
.base:
  script: test
  variables:
    VAR1: base var 1

test1:
  extends: .base
  variables:
    VAR1: test1 var 1
    VAR2: test2 var 2

test2:
  extends: .base
  variables:
    VAR2: test2 var 2

test3:
  extends: .base
  variables: {}

test4:
  extends: .base
  variables: null
```

合并后的配置：

```yaml
test1:
  script: test
  variables:
    VAR1: test1 var 1
    VAR2: test2 var 2

test2:
  script: test
  variables:
    VAR1: base var 1
    VAR2: test2 var 2

test3:
  script: test
  variables:
    VAR1: base var 1

test4:
  script: test
  variables: null
```

<a id="use-extends-and-include-together"></a>

### 同时使用 `扩展` 和 `包含`

要重用不同配置文件中的配置，请结合使用 `扩展` 和 [`包含`](_index.md#include)。

在以下示例中，`included.yml` 文件中定义了一个 `脚本`。然后，在 `.gitlab-ci.yml` 文件中，`扩展` 引用了该 `脚本` 的内容：

- `included.yml`：

  ```yaml
  .template:
    script:
      - echo Hello!
  ```

- `.gitlab-ci.yml`：

  ```yaml
  include: included.yml

  useTemplate:
    image: alpine
    extends: .template
  ```

<a id="merge-details"></a>

### 合并细节

你可以使用 `扩展` 来合并哈希，但不能合并数组。
当存在重复的键时，极狐GitLab 会根据键执行反向深度合并。
最后一个成员中的键始终会覆盖其他层级中定义的任何内容。例如：

```yaml
.only-important:
  variables:
    URL: "http://my-url.internal"
    IMPORTANT_VAR: "the details"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_BRANCH == "stable"
  tags:
    - production
  script:
    - echo "Hello world!"

.in-docker:
  variables:
    URL: "http://docker-url.internal"
  tags:
    - docker
  image: alpine

rspec:
  variables:
    GITLAB: "is-awesome"
  extends:
    - .only-important
    - .in-docker
  script:
    - rake rspec
```

结果是这个 `rspec` 作业：

```yaml
rspec:
  variables:
    URL: "http://docker-url.internal"
    IMPORTANT_VAR: "the details"
    GITLAB: "is-awesome"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_BRANCH == "stable"
  tags:
    - docker
  image: alpine
  script:
    - rake rspec
```

在这个例子中：

- `变量` 部分合并了，但 `URL: "http://docker-url.internal"` 覆盖了 `URL: "http://my-url.internal"`。
- `标签: ['docker']` 覆盖了 `标签: ['production']`。
- `脚本` 不进行合并，但 `脚本: ['rake rspec']` 覆盖了 `脚本: ['echo "Hello world!"']`。你可以使用 [YAML 锚点](#锚点) 来合并数组。

<a id="reference-tags"></a>

## `!引用` 标签

使用 `!引用` 自定义 YAML 标签可以从其他作业部分选择关键字配置，并在当前部分中重用。与 [YAML 锚点](#锚点) 不同，你也可以使用 `!引用` 标签来重用来自[包含文件](_index.md#include)的配置。

如果你使用 `!引用` 标签来覆盖来自包含文件的配置，可以考虑改用 [CI/CD 输入](../inputs/_index.md)。你不能在 `!引用` 标签中使用 CI/CD 输入，因为 `!引用` 标签会在输入插值之前进行评估。

在以下示例中，来自两个不同位置的 `脚本` 和 `后置脚本` 在 `test` 作业中被重用：

- `configs.yml`：

  ```yaml
  .setup:
    script:
      - echo creating environment
  ```

- `.gitlab-ci.yml`：

  ```yaml
  include:
    - local: configs.yml

  .teardown:
    after_script:
      - echo deleting environment

  test:
    script:
      - !reference [.setup, script]
      - echo running my own command
    after_script:
      - !reference [.teardown, after_script]
  ```

在以下示例中，`test-vars-1` 重用了 `.vars` 中的所有变量，而 `test-vars-2` 选择一个特定变量并将其重用为一个新的 `MY_VAR` 变量。

```yaml
.vars:
  variables:
    URL: "http://my-url.internal"
    IMPORTANT_VAR: "the details"

test-vars-1:
  variables: !reference [.vars, variables]
  script:
    - printenv

test-vars-2:
  variables:
    MY_VAR: !reference [.vars, variables, IMPORTANT_VAR]
  script:
    - printenv
```

你可以使用多个 `!引用` 标签来构建一个包含 `规则`、`脚本` 或 `阶段` 的数组。例如：

```yaml
.rules_prod:
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  - if: $CI_PIPELINE_SOURCE == "schedule"

.rules_staging:
  - if: $CI_COMMIT_BRANCH =~ /^wip-.*/
  - if: $CI_PIPELINE_SOURCE == "push"

deploy_job:
  script: echo test
  rules:
    - !reference [.rules_prod]
    - !reference [.rules_staging]
```

对于所有其他关键字，你会得到一个[`配置应该是一个数组的` 验证错误](../debugging.md#config-should-be-an-array-of-hashes-error-message)。

<a id="nest-reference-tags-in-script-before-script-and-after-script"></a>

### 在 `脚本`、`前置脚本` 和 `后置脚本` 中嵌套 `!引用` 标签

{{< history >}}

- 对 [`阶段`](_index.md#stages) 关键字使用 `!引用` 的支持在 极狐GitLab 16.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/439451)。

{{< /history >}}

你可以在 `脚本`、`前置脚本` 和 `后置脚本` 部分中嵌套 `!引用` 标签，最多可嵌套 10 层。在构建更复杂的脚本时，可以使用嵌套标签来定义可重用部分。例如：

```yaml
.snippets:
  one:
    - echo "ONE!"
  two:
    - !reference [.snippets, one]
    - echo "TWO!"
  three:
    - !reference [.snippets, two]
    - echo "THREE!"

nested-references:
  script:
    - !reference [.snippets, three]
```

在这个例子中，`nested-references` 作业会运行全部三条 `echo` 命令。