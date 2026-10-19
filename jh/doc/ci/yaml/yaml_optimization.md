---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 优化极狐GitLab CI/CD 配置文件
description: 使用 YAML 锚点、!reference 标签和 `extends` 关键字来降低 CI/CD 配置文件的复杂度。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用以下方式降低极狐GitLab CI/CD 配置文件中的复杂度和重复配置：

- YAML 特有的功能，例如[锚点（`&`）](#anchors)、别名（`*`）和映射合并（`<<`）。
  详细了解各种 [YAML 功能](https://learnxinyminutes.com/docs/yaml/)。
- [`extends` 关键字](#use-extends-to-reuse-configuration-sections)，
  它更灵活、更易读。应尽可能使用 `extends`。

要创建多个类似但变量值不同的作业，请使用 [`parallel:matrix`](../jobs/job_control.md#run-a-matrix-of-parallel-trigger-jobs)。

<a id="anchors"></a>

## 锚点

YAML 有一项称为“锚点”的功能，可用于在文档中复制内容。

您可以使用锚点来复制或继承属性。将锚点与[隐藏作业](../jobs/_index.md#hide-a-job)结合使用，可以为作业提供模板。

`&` 字符标记锚点名称，`*` 字符是引用该锚点的别名。您必须在 YAML 文件中比任何引用该锚点的别名更靠前的位置定义该锚点。

当存在重复键时，最后包含的键生效并覆盖其他键。

在某些情况下（请参阅[脚本的 YAML 锚点](#yaml-anchors-for-scripts)），您可以使用 YAML 锚点构建数组，其中的多个组成部分在其他位置定义。例如：

```yaml
.default_scripts: &default_scripts
  - ./default-script1.sh
  - ./default-script2.sh

job1:
  script:
    - *default_scripts
    - ./job-script.sh
```

使用 [`include`](_index.md#include) 关键字时，不能跨多个文件使用 YAML 锚点。锚点仅在其定义所在的文件中有效。要复用不同 YAML 文件中的配置，请使用 [`!reference` 标签](#reference-tags)或 [`extends` 关键字](#use-extends-to-reuse-configuration-sections)。

以下示例使用锚点和映射合并。它创建两个作业 `test1` 和 `test2`，它们继承 `.job_template` 配置，各自定义了自己的自定义 `script`：

```yaml
.job_template: &job_configuration  # Hidden yaml configuration that defines an anchor named 'job_configuration'
  image: ruby:2.6
  services:
    - postgres
    - redis

test1:
  <<: *job_configuration           # Add the contents of the 'job_configuration' alias
  script:
    - test1 project

test2:
  <<: *job_configuration           # Add the contents of the 'job_configuration' alias
  script:
    - test2 project
```

`&` 设置锚点的名称（`job_configuration`），`<<` 表示“将给定的哈希合并到当前哈希中”，`*` 包含指定的锚点（再次为 `job_configuration`）。此示例的[展开](../pipeline_editor/_index.md#view-full-configuration)版本为：

```yaml
.job_template:
  image: ruby:2.6
  services:
    - postgres
    - redis

test1:
  image: ruby:2.6
  services:
    - postgres
    - redis
  script:
    - test1 project

test2:
  image: ruby:2.6
  services:
    - postgres
    - redis
  script:
    - test2 project
```

您可以使用锚点定义两组服务。例如，`test:postgres` 和 `test:mysql` 共享 `.job_template`中定义的 `script`，但使用不同的 `services`，分别在 `.postgres_services` 和 `.mysql_services`中定义：

```yaml
.job_template: &job_configuration
  script:
    - test project
  tags:
    - dev

.postgres_services:
  services: &postgres_configuration
    - postgres
    - ruby

.mysql_services:
  services: &mysql_configuration
    - mysql
    - ruby

test:postgres:
  <<: *job_configuration
  services: *postgres_configuration
  tags:
    - postgres

test:mysql:
  <<: *job_configuration
  services: *mysql_configuration
```

[展开](../pipeline_editor/_index.md#view-full-configuration)版本为：

```yaml
.job_template:
  script:
    - test project
  tags:
    - dev

.postgres_services:
  services:
    - postgres
    - ruby

.mysql_services:
  services:
    - mysql
    - ruby

test:postgres:
  script:
    - test project
  services:
    - postgres
    - ruby
  tags:
    - postgres

test:mysql:
  script:
    - test project
  services:
    - mysql
    - ruby
  tags:
    - dev
```

您可以看到，隐藏作业被方便地用作模板，并且 `tags: [postgres]` 覆盖了 `tags: [dev]`。

<a id="yaml-anchors-for-scripts"></a>

### 脚本的 YAML 锚点

您可以将 [YAML 锚点](#anchors)与 [script](_index.md#script)、[`before_script`](_index.md#before_script)
和 [`after_script`](_index.md#after_script) 结合使用，以在多个作业中使用预定义命令：

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

## 使用 `extends` 复用配置节

您可以使用 [`extends` 关键字](_index.md#extends)在多个作业中复用配置。它类似于 [YAML 锚点](#anchors)，但更简单，而且您可以[将 `extends` 与 `includes` 一起使用](#use-extends-and-include-together)。

`extends` 支持多级继承。由于会增加复杂度，您应避免使用超过三级的继承，但最多可以使用十一级。以下示例有两级继承：

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

### 从 `extends`中排除某个键

要从扩展内容中排除某个键，必须将其赋值为 `null`，例如：

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

### 同时使用 `extends` 和 `include`

要复用不同配置文件中的配置，请结合使用 `extends` 和 [`include`](_index.md#include)。

在以下示例中，`included.yml` 文件中定义了一个 `script`。然后，在 `.gitlab-ci.yml` 文件中，`extends` 引用了 `script`的内容：

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

您可以使用 `extends` 合并哈希，但不能合并数组。当存在重复键时，极狐GitLab 会基于这些键执行反向深度合并。最后一个成员中的键始终覆盖其他层级中定义的任何内容。例如：

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

结果就是以下 `rspec` 作业：

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

在此示例中：

- `variables` 节会合并，但 `URL: "http://docker-url.internal"` 会覆盖 `URL: "http://my-url.internal"`。
- `tags: ['docker']` 会覆盖 `tags: ['production']`。
- `script` 不会合并，但 `script: ['rake rspec']` 会覆盖
  `script: ['echo "Hello world!"']`。您可以使用 [YAML 锚点](#anchors)来合并数组。

<a id="reference-tags"></a>

## `!reference` 标签

使用 `!reference` 自定义 YAML 标签可以从其他作业节中选择关键字配置，并在当前节中复用它。与 [YAML 锚点](#anchors)不同，您可以使用 `!reference` 标签复用[包含文件](_index.md#include)中的配置。

如果您使用 `!reference` 标签来覆盖已包含文件中的配置，请考虑改用
[CI/CD 输入](../inputs/_index.md)。

您不能将 `!reference` 标签与输入结合使用：

- 您不能在 `!reference` 标签的路径中使用输入，例如
  `!reference [.settings, "$[[ inputs.key ]]"]`。路径段在解析 YAML 文件时读取，
  此时输入尚未插值，因此输入会被视为字面文本，引用将无法找到。
- 不要在输入值中使用 `!reference` 标签，因为
  [标签在输入插值之后才会解析](../inputs/_index.md#input-value-looks-like-gitlabciconfigyamltagsreference)。

在以下示例中，来自两个不同位置的 `script` 和 `after_script` 在 `test` 作业中被复用：

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

在以下示例中，`test-vars-1` 复用 `.vars`中的所有变量，而 `test-vars-2` 选择特定变量并将其复用为新的 `MY_VAR` 变量。

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

您可以使用多个 `!reference` 标签，用 `rules`、`script` 或 stages 构建数组。例如：

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

对于所有其他关键字，您会收到 [`config should be an array of` 验证错误](../debugging.md#config-should-be-an-array-of-hashes-error-message)。

<a id="nest-reference-tags-in-script-before_script-and-after_script"></a>

### 在 `script`、`before_script` 和 `after_script`中嵌套 `!reference` 标签

您可以在 `script`、`before_script` 和 `after_script` 节中将 `!reference` 标签嵌套最多 10 层。在构建更复杂的脚本时，使用嵌套标签来定义可复用的节。例如：

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

在此示例中，`nested-references` 作业会运行全部三个 `echo` 命令。

<a id="configure-your-ide-to-support-reference-tags"></a>

### 配置 IDE 以支持 `!reference` 标签

[流水线编辑器](../pipeline_editor/_index.md)支持 `!reference` 标签。不过，您的编辑器默认可能会将 `!reference` 等自定义 YAML 标签的架构规则视为无效。您可以配置某些编辑器以接受 `!reference` 标签。例如：

- 在 VS Code 中，您可以将 `vscode-yaml` 设置为在 `settings.json` 文件中解析 `customTags`：

  ```json
  "yaml.customTags": [
     "!reference sequence"
  ]
  ```

- 在 Sublime Text 中，如果您使用 `LSP-yaml` 包，可以在 `LSP-yaml` 用户设置中设置 `customTags`：

  ```json
  {
    "settings": {
      "yaml.customTags": ["!reference sequence"]
    }
  }
  ```
