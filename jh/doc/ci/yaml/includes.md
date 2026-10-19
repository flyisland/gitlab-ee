---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用其他文件中的 CI/CD 配置
description: 使用 `include` 关键字，通过其他 YAML 文件中的内容扩展您的 CI/CD 配置。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 [`include`](_index.md#include) 将外部 YAML 文件包含到您的 CI/CD 作业中。

<a id="include-a-single-configuration-file"></a>

## 包含单个配置文件

要包含单个配置文件，请单独使用 `include` 并指定单个文件，可使用以下任一语法选项：

- 在同一行中：

  ```yaml
  include: 'my-config.yml'
  ```

- 作为数组中的单个条目：

  ```yaml
  include:
    - 'my-config.yml'
  ```

如果该文件是本地文件，其行为与 [`include:local`](_index.md#includelocal) 相同。如果该文件是远程文件，其行为与 [`include:remote`](_index.md#includeremote) 相同。

<a id="include-an-array-of-configuration-files"></a>

## 包含配置文件数组

您可以包含配置文件数组：

- 如果您未指定 `include` 类型，则每个数组条目会根据需要默认为 [`include:local`](_index.md#includelocal)
  或 [`include:remote`](_index.md#includeremote)：

  ```yaml
  include:
    - 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
    - 'templates/.after-script-template.yml'
  ```

- 您可以定义单条目数组：

  ```yaml
  include:
    - remote: 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
  ```

- 您可以定义数组并显式指定多个 `include` 类型：

  ```yaml
  include:
    - remote: 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
    - local: 'templates/.after-script-template.yml'
    - template: Auto-DevOps.gitlab-ci.yml
  ```

- 您可以定义数组，同时组合使用默认和特定的 `include` 类型：

  ```yaml
  include:
    - 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
    - 'templates/.after-script-template.yml'
    - template: Auto-DevOps.gitlab-ci.yml
    - project: 'my-group/my-project'
      ref: main
      file: 'templates/.gitlab-ci-template.yml'
  ```

<a id="use-default-configuration-from-an-included-configuration-file"></a>

## 使用所包含配置文件中的 `default` 配置

您可以在配置文件中定义 [`default`](_index.md#default) 部分。当您将 `default` 部分与 `include` 关键字一起使用时，这些默认值会应用于流水线中的所有作业。

例如，您可以将 `default` 部分与 [`before_script`](_index.md#before_script) 一起使用。

名为 `/templates/.before-script-template.yml`的自定义配置文件的内容：

```yaml
default:
  before_script:
    - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
    - gem install bundler --no-document
    - bundle install --jobs $(nproc)  "${FLAGS[@]}"
```

`.gitlab-ci.yml`的内容：

```yaml
include: 'templates/.before-script-template.yml'

rspec1:
  script:
    - bundle exec rspec

rspec2:
  script:
    - bundle exec rspec
```

默认的 `before_script` 命令会在两个 `rspec` 作业中执行，且在 `script` 命令之前执行。

<a id="override-included-configuration-values"></a>

## 覆盖所包含的配置值

当您使用 `include` 关键字时，您可以覆盖所包含的配置值，使其适应您的流水线需求。

以下示例展示了一个 `include` 文件，它在 `.gitlab-ci.yml` 文件中被自定义。其中特定的 YAML 定义变量以及 `production` 作业的详细信息被覆盖。

名为 `autodevops-template.yml`的自定义配置文件的内容：

```yaml
variables:
  POSTGRES_USER: user
  POSTGRES_PASSWORD: testing_password
  POSTGRES_DB: $CI_ENVIRONMENT_SLUG

production:
  stage: production
  script:
    - install_dependencies
    - deploy
  environment:
    name: production
    url: https://$CI_PROJECT_PATH_SLUG.$KUBE_INGRESS_BASE_DOMAIN
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

`.gitlab-ci.yml`的内容：

```yaml
include: 'https://company.com/autodevops-template.yml'

default:
  image: alpine:latest

variables:
  POSTGRES_USER: root
  POSTGRES_PASSWORD: secure_password

stages:
  - build
  - test
  - production

production:
  environment:
    url: https://domain.com
```

在 `.gitlab-ci.yml` 文件中定义的 `POSTGRES_USER` 和 `POSTGRES_PASSWORD` 变量以及 `production` 作业的 `environment:url` 会覆盖 `autodevops-template.yml` 文件中定义的值。其他关键字不会改变。此方法称为*合并*。

<a id="merge-method-for-include"></a>

### `include`的合并方法

`include` 配置通过以下过程与主配置文件合并：

- 所包含的文件按配置文件中定义的顺序读取，
  所包含的配置也按相同顺序合并在一起。
- 如果某个所包含的文件也使用了 `include`，则先合并该嵌套的 `include` 配置（递归进行）。
- 如果参数重叠，在合并所包含文件中的配置时，最后包含的文件优先。
- 在使用 `include` 添加的所有配置合并在一起之后，主配置
  会与所包含的配置合并。

此合并方法是一种*深度合并*，即配置中任意深度的哈希映射都会合并。要合并哈希映射“A”（包含目前合并的配置）和“B”（下一部分配置），键和值的处理方式如下：

- 当键仅存在于 A 中时，使用 A 中的键和值。
- 当键同时存在于 A 和 B 中，且它们的值都是哈希映射时，合并这些哈希映射。
- 当键同时存在于 A 和 B 中，且其中一个值不是哈希映射时，使用 B 中的值。
- 否则，使用 B 中的键和值。

例如，对于由两个文件组成的配置：

- `.gitlab-ci.yml` 文件：

  ```yaml
  include: 'common.yml'

  variables:
    POSTGRES_USER: username

  test:
    rules:
      - if: $CI_PIPELINE_SOURCE == "merge_request_event"
        when: manual
    artifacts:
      reports:
        junit: rspec.xml
  ```

- `common.yml` 文件：

  ```yaml
  variables:
    POSTGRES_USER: common_username
    POSTGRES_PASSWORD: testing_password

  test:
    rules:
      - when: never
    script:
      - echo LOGIN=${POSTGRES_USER} > deploy.env
      - rake spec
    artifacts:
      reports:
        dotenv: deploy.env
  ```

合并结果为：

```yaml
variables:
  POSTGRES_USER: username
  POSTGRES_PASSWORD: testing_password

test:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: manual
  script:
    - echo LOGIN=${POSTGRES_USER} > deploy.env
    - rake spec
  artifacts:
    reports:
      junit: rspec.xml
      dotenv: deploy.env
```

在此示例中：

- 变量只有在所有文件合并在一起之后才会求值。所包含文件中的作业
  最终可能会使用在另一个文件中定义的变量值。合并之后，
  [CI/CD 变量优先级](../variables/_index.md#cicd-variable-precedence)决定每个变量的最终
  值。
- `rules` 是数组，因此无法合并。顶层文件优先。
- `artifacts` 是哈希映射，因此可以深度合并。

<a id="override-included-configuration-arrays"></a>

## 覆盖所包含的配置数组

您可以使用合并来扩展和覆盖所包含模板中的配置，但无法添加或修改数组中的单个条目。例如，要向扩展后的 `production` 作业的 `script` 数组添加额外的 `notify_owner` 命令：

`autodevops-template.yml`的内容：

```yaml
production:
  stage: production
  script:
    - install_dependencies
    - deploy
```

`.gitlab-ci.yml`的内容：

```yaml
include: 'autodevops-template.yml'

stages:
  - production

production:
  script:
    - install_dependencies
    - deploy
    - notify_owner
```

如果 `install_dependencies` 和 `deploy` 未在 `.gitlab-ci.yml` 文件中重复，则 `production` 作业的脚本中将只有 `notify_owner`。

<a id="use-nested-includes"></a>

## 使用嵌套 include

您可以在配置文件中嵌套 `include` 部分，然后再将这些配置文件包含到另一个配置中。例如，对于嵌套三层的 `include` 关键字：

`.gitlab-ci.yml`的内容：

```yaml
include:
  - local: /.gitlab-ci/another-config.yml
```

`/.gitlab-ci/another-config.yml`的内容：

```yaml
include:
  - local: /.gitlab-ci/config-defaults.yml
```

`/.gitlab-ci/config-defaults.yml`的内容：

```yaml
default:
  after_script:
    - echo "Job complete."
```

<a id="use-nested-includes-with-duplicate-include-entries"></a>

### 使用带有重复 `include` 条目的嵌套 include

您可以在主配置文件和嵌套 include 中多次包含同一个配置文件。

如果任何文件使用[覆盖](#override-included-configuration-values)更改了所包含的配置，则 `include` 条目的顺序可能会影响最终配置。最后一次包含该配置时会覆盖之前包含该文件的所有情况。例如：

- `defaults.gitlab-ci.yml` 文件的内容：

  ```yaml
  default:
    before_script: echo "Default before script"
  ```

- `unit-tests.gitlab-ci.yml` 文件的内容：

  ```yaml
  include:
    - template: defaults.gitlab-ci.yml

  default:  # Override the included default
    before_script: echo "Unit test default override"

  unit-test-job:
    script: unit-test.sh
  ```

- `smoke-tests.gitlab-ci.yml` 文件的内容：

  ```yaml
  include:
    - template: defaults.gitlab-ci.yml

  default:  # Override the included default
    before_script: echo "Smoke test default override"

  smoke-test-job:
    script: smoke-test.sh
  ```

对于这三个文件，它们的包含顺序会改变最终配置。当：

- 先包含 `unit-tests` 时，`.gitlab-ci.yml` 文件的内容为：

  ```yaml
  include:
    - local: unit-tests.gitlab-ci.yml
    - local: smoke-tests.gitlab-ci.yml
  ```

  最终配置为：

  ```yaml
  unit-test-job:
   before_script: echo "Smoke test default override"
   script: unit-test.sh

  smoke-test-job:
   before_script: echo "Smoke test default override"
   script: smoke-test.sh
  ```

- 最后包含 `unit-tests` 时，`.gitlab-ci.yml` 文件的内容为：

  ```yaml
  include:
    - local: smoke-tests.gitlab-ci.yml
    - local: unit-tests.gitlab-ci.yml
  ```

- 最终配置为：

  ```yaml
  unit-test-job:
   before_script: echo "Unit test default override"
   script: unit-test.sh

  smoke-test-job:
   before_script: echo "Unit test default override"
   script: smoke-test.sh
  ```

如果没有文件覆盖所包含的配置，则 `include` 条目的顺序不会影响最终配置

<a id="use-variables-with-include"></a>

## 在 `include`中使用变量

在 `.gitlab-ci.yml` 文件的 `include` 部分中，您可以使用：

- [项目变量](../variables/_index.md#for-a-project)。
- [群组变量](../variables/_index.md#for-a-group)。
- [实例变量](../variables/_index.md#for-an-instance)。
- 项目[预定义变量](../variables/predefined_variables.md)（`CI_PROJECT_*`）。
- [触发器变量](../triggers/_index.md#pass-cicd-variables-in-the-api-call)。
- [计划流水线变量](../pipelines/schedules.md#create-a-pipeline-schedule)。
- [手动流水线运行变量](../pipelines/_index.md#run-a-pipeline-manually)。
- `CI_PIPELINE_SOURCE` 和 `CI_PIPELINE_TRIGGERED` [预定义变量](../variables/predefined_variables.md)。
- `$CI_COMMIT_REF_NAME` [预定义变量](../variables/predefined_variables.md)。

例如：

```yaml
include:
  project: '$CI_PROJECT_PATH'
  file: '.compliance-gitlab-ci.yml'
```

您不能使用作业中定义的变量，也不能使用全局 [`variables`](_index.md#variables) 部分中定义的变量，该部分为所有作业定义默认变量。include 在作业之前求值，因此这些变量不能与 `include` 一起使用。

您不能在动态子流水线配置的 `include` 部分中使用 CI/CD 变量。[议题 378717](https://gitlab.com/gitlab-org/gitlab/-/issues/378717) 提议修复此问题。

<a id="use-rules-with-include"></a>

## 将 `rules` 与 `include` 一起使用

您可以将 [`rules`](_index.md#rules) 与 `include` 一起使用，以有条件地包含其他配置文件。

您只能将 `rules` 与[特定变量](#use-variables-with-include)以及以下关键字一起使用：

- [`rules:if`](_index.md#rulesif)。
- [`rules:exists`](_index.md#rulesexists)。
- [`rules:changes`](_index.md#ruleschanges)。

<a id="include-with-rulesif"></a>

### `include` 与 `rules:if`

使用 [`rules:if`](_index.md#rulesif) 根据 CI/CD 变量的状态有条件地包含其他配置文件。例如：

```yaml
include:
  - local: builds.yml
    rules:
      - if: $DONT_INCLUDE_BUILDS == "true"
        when: never
  - local: builds.yml
    rules:
      - if: $ALWAYS_INCLUDE_BUILDS == "true"
        when: always
  - local: builds.yml
    rules:
      - if: $INCLUDE_BUILDS == "true"
  - local: deploys.yml
    rules:
      - if: $CI_COMMIT_BRANCH == "main"

test:
  stage: test
  script: exit 0
```

<a id="include-with-rulesexists"></a>

### `include` 与 `rules:exists`

使用 [`rules:exists`](_index.md#rulesexists) 根据文件是否存在有条件地包含其他配置文件。例如：

```yaml
include:
  - local: builds.yml
    rules:
      - exists:
          - exception-file.md
        when: never
  - local: builds.yml
    rules:
      - exists:
          - important-file.md
        when: always
  - local: builds.yml
    rules:
      - exists:
          - file.md

test:
  stage: test
  script: exit 0
```

在此示例中，极狐GitLab 会检查当前项目中是否存在 `file.md`。

如果您在来自其他项目的 include 文件中将 `include` 与 `rules:exists` 一起使用，请仔细检查您的配置。极狐GitLab 会检查该文件在另一个项目中是否存在。例如：

```yaml
# Pipeline configuration in my-group/my-project
include:
  - project: my-group/other-project
    ref: other_branch
    file: other-file.yml

test:
  script: exit 0

# other-file.yml in my-group/other-project on ref other_branch
include:
  - project: my-group/my-project
    ref: main
    file: my-file.yml
    rules:
      - exists:
          - file.md
```

在此示例中，极狐GitLab 会在 `my-group/other-project`中、提交引用 `other_branch` 上搜索是否存在 `file.md`，而不是运行流水线的项目/引用。

要更改搜索上下文，您可以将 [`rules:exists:paths`](_index.md#rulesexistspaths) 与 [`rules:exists:project`](_index.md#rulesexistsproject) 一起使用。例如：

```yaml
include:
  - project: my-group/my-project
    ref: main
    file: my-file.yml
    rules:
      - exists:
          paths:
            - file.md
          project: my-group/my-project
          ref: main
```

<a id="include-with-ruleschanges"></a>

### `include` 与 `rules:changes`

使用 [`rules:changes`](_index.md#ruleschanges) 根据更改的文件有条件地包含其他配置文件。例如：

```yaml
include:
  - local: builds1.yml
    rules:
      - changes:
        - Dockerfile
  - local: builds2.yml
    rules:
      - changes:
          paths:
            - Dockerfile
          compare_to: 'refs/heads/branch1'
        when: always
  - local: builds3.yml
    rules:
      - if: $CI_PIPELINE_SOURCE == "merge_request_event"
        changes:
          paths:
            - Dockerfile

test:
  stage: test
  script: exit 0
```

在此示例中：

- 当 `Dockerfile` 发生更改时，包含 `builds1.yml`。
- 当 `Dockerfile` 相对于 `refs/heads/branch1` 发生更改时，包含 `builds2.yml`。
- 当 `Dockerfile` 发生更改且流水线来源是合并请求事件时，包含 `builds3.yml`。`builds3.yml`中的作业还必须配置为针对[合并请求流水线](../pipelines/merge_request_pipelines.md#configure-merge-request-pipelines)运行。

<a id="use-includelocal-with-wildcard-file-paths"></a>

## 将 `include:local` 与通配符文件路径一起使用

您可以将通配符路径（`*` 和 `**`）与 `include:local` 一起使用。

示例：

```yaml
include: 'configs/*.yml'
```

当流水线运行时，极狐GitLab 会：

- 将 `configs` 目录中的所有 `.yml` 文件添加到流水线配置中。
- 不添加 `configs` 目录子文件夹中的 `.yml` 文件。要允许此操作，
  请添加以下配置：

  ```yaml
  # This matches all `.yml` files in `configs` and any subfolder in it.
  include: 'configs/**.yml'

  # This matches all `.yml` files only in subfolders of `configs`.
  include: 'configs/**/*.yml'
  ```

<a id="troubleshooting"></a>

## 故障排除

<a id="maximum-of-150-nested-includes-are-allowed-error"></a>

### `Maximum of 150 nested includes are allowed!` 错误

流水线的[嵌套包含文件](#use-nested-includes)数量上限为 150。如果您在流水线中收到 `Maximum 150 includes are allowed` 错误消息，可能是因为：

- 某些嵌套配置包含了过多额外的嵌套 `include` 配置。
- 嵌套 include 中存在意外的循环。例如，`include1.yml` 包含
  `include2.yml`，而后者又包含 `include1.yml`，从而形成递归循环。

为帮助降低发生此情况的风险，请使用[流水线编辑器](../pipeline_editor/_index.md)编辑流水线配置文件，它会验证是否达到该限制。您可以一次移除一个所包含的文件，以尝试缩小范围，找出导致循环或包含文件过多的配置文件。

极狐GitLab 私有化部署上的用户可以更改[最大 include 数](../../administration/cicd/limits.md#maximum-number-of-includes)值。

<a id="error-local-file-file-does-not-exist-with-includelocal"></a>

### 错误：使用 `include:local` 时出现 `Local file <file> does not exist!`

使用 [`include:local`](_index.md#includelocal) 时，即使文件存在于代码仓库中，您也可能收到 `Local file <file> does not exist!` 错误。

此错误是已知的系统级问题，而不是 CI/CD 配置问题。它已在分布式 Gitaly 或 Praefect 设置中间歇性出现。如果遇到此错误，请重试流水线。

更多信息，请参见[议题 336789](https://gitlab.com/gitlab-org/gitlab/-/issues/336789)。

<a id="ssl_connect-syscall-returned5-errno0-statesslv3tls-write-client-hello-and-other-network-failures"></a>

### `SSL_connect SYSCALL returned=5 errno=0 state=SSLv3/TLS write client hello` 及其他网络故障

使用 [`include:remote`](_index.md#includeremote) 时，极狐GitLab 会尝试通过 HTTP(S) 获取远程文件。此过程可能因各种连接问题而失败。

`SSL_connect SYSCALL returned=5 errno=0 state=SSLv3/TLS write client hello` 错误会在极狐GitLab 无法与远程主机建立 HTTPS 连接时发生。如果远程主机设置了速率限制以防止服务器因请求而过载，则可能引发此问题。

例如，JihuLab.com 的 [GitLab Pages](../../user/project/pages/_index.md) 服务器
有速率限制。反复尝试获取托管在 GitLab Pages 上的 CI/CD 配置文件可能会达到速率限制并导致该错误。您应避免将
CI/CD 配置文件托管在 GitLab Pages 站点上。

在可能的情况下，请使用 [`include:project`](_index.md#includeproject) 从极狐GitLab 实例中的其他项目获取配置文件，而无需发起外部 HTTP(S) 请求。
