---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用来自其他文件的 CI/CD 配置
description: 使用 `include` 关键字从其他 YAML 文件扩展您的 CI/CD 配置。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 [`include`](_index.md#include) 将外部 YAML 文件包含到 CI/CD 作业中。

<a id="include-a-single-configuration-file"></a>

## 包含单个配置文件

要包含单个配置文件，请使用 `include` 并指定单个文件，可以使用以下两种语法之一：

- 在同一行：

  ```yaml
  include: 'my-config.yml'
  ```

- 作为数组中的单个项目：

  ```yaml
  include:
    - 'my-config.yml'
  ```

如果文件是本地文件，其行为与 [`include:local`](_index.md#includelocal) 相同。
如果文件是远程文件，其行为与 [`include:remote`](_index.md#includeremote) 相同。

<a id="include-an-array-of-configuration-files"></a>

## 包含配置文件数组

您可以包含一个配置文件数组：

- 如果您未指定 `include` 类型，则每个数组项将根据需要默认为 [`include:local`](_index.md#includelocal) 或 [`include:remote`](_index.md#includeremote)：

  ```yaml
  include:
    - 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
    - 'templates/.after-script-template.yml'
  ```

- 您可以定义一个单项目数组：

  ```yaml
  include:
    - remote: 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
  ```

- 您可以定义一个数组并显式指定多个 `include` 类型：

  ```yaml
  include:
    - remote: 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
    - local: 'templates/.after-script-template.yml'
    - template: Auto-DevOps.gitlab-ci.yml
  ```

- 您可以定义一个结合了默认和特定 `include` 类型的数组：

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

## 使用来自被包含配置文件的 `default` 配置

您可以在配置文件中定义 [`default`](_index.md#default) 部分。当您将 `default` 部分与 `include` 关键字一起使用时，这些默认设置将应用于流水线中的所有作业。

例如，您可以将 `default` 部分与 [`before_script`](_index.md#before_script) 一起使用。

名为 `/templates/.before-script-template.yml` 的自定义配置文件的内容：

```yaml
default:
  before_script:
    - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
    - gem install bundler --no-document
    - bundle install --jobs $(nproc)  "${FLAGS[@]}"
```

`.gitlab-ci.yml` 的内容：

```yaml
include: 'templates/.before-script-template.yml'

rspec1:
  script:
    - bundle exec rspec

rspec2:
  script:
    - bundle exec rspec
```

默认的 `before_script` 命令将在两个 `rspec` 作业中执行，位于 `script` 命令之前。

<a id="override-included-configuration-values"></a>

## 覆盖被包含的配置值

当您使用 `include` 关键字时，您可以覆盖被包含的配置值，使其适应您的流水线需求。

以下示例展示了一个在 `.gitlab-ci.yml` 文件中被自定义的 `include` 文件。特定的 YAML 定义变量和 `production` 作业的详细信息被覆盖。

名为 `autodevops-template.yml` 的自定义配置文件的内容：

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

`.gitlab-ci.yml` 的内容：

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

在 `.gitlab-ci.yml` 文件中定义的 `POSTGRES_USER` 和 `POSTGRES_PASSWORD` 变量以及 `production` 作业的 `environment:url` 会覆盖 `autodevops-template.yml` 文件中定义的值。其他关键字保持不变。此方法称为*合并*。

<a id="merge-method-for-include"></a>

### `include` 的合并方法

`include` 配置与主配置文件按以下过程合并：

- 按照配置文件中定义的顺序读取被包含的文件，并且被包含的配置按相同顺序合并在一起。
- 如果被包含的文件也使用了 `include`，则该嵌套的 `include` 配置会首先被合并（递归）。
- 如果参数重叠，在合并来自被包含文件的配置时，最后被包含的文件具有优先权。
- 在所有通过 `include` 添加的配置合并在一起之后，主配置会与被包含的配置合并。

此合并方法是*深度合并*，哈希映射在配置中的任何深度都会被合并。要合并哈希映射 "A"（包含到目前为止合并的配置）和 "B"（下一部分配置），键和值按如下方式处理：

- 当键仅存在于 A 中时，使用 A 中的键和值。
- 当键同时存在于 A 和 B 中，并且它们的值都是哈希映射时，合并这些哈希映射。
- 当键同时存在于 A 和 B 中，并且其中一个值不是哈希映射时，使用 B 中的值。
- 否则，使用 B 中的键和值。

例如，一个由两个文件组成的配置：

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

合并后的结果是：

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

- 变量仅在所有文件合并在一起后才被评估。被包含文件中的作业最终可能会使用在不同文件中定义的变量值。
- `rules` 是一个数组，因此无法合并。顶层文件具有优先权。
- `artifacts` 是一个哈希映射，因此可以进行深度合并。

<a id="override-included-configuration-arrays"></a>

## 覆盖被包含的配置数组

您可以使用合并来扩展和覆盖被包含模板中的配置，但不能添加或修改数组中的单个项目。例如，要向扩展的 `production` 作业的 `script` 数组添加一个额外的 `notify_owner` 命令：

`autodevops-template.yml` 的内容：

```yaml
production:
  stage: production
  script:
    - install_dependencies
    - deploy
```

`.gitlab-ci.yml` 的内容：

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

如果 `install_dependencies` 和 `deploy` 没有在 `.gitlab-ci.yml` 文件中重复，那么 `production` 作业的脚本中将只有 `notify_owner`。

<a id="use-nested-includes"></a>

## 使用嵌套的 include

您可以在配置文件中嵌套 `include` 部分，然后这些配置文件又被包含在另一个配置中。例如，嵌套三层的 `include` 关键字：

`.gitlab-ci.yml` 的内容：

```yaml
include:
  - local: /.gitlab-ci/another-config.yml
```

`/.gitlab-ci/another-config.yml` 的内容：

```yaml
include:
  - local: /.gitlab-ci/config-defaults.yml
```

`/.gitlab-ci/config-defaults.yml` 的内容：

```yaml
default:
  after_script:
    - echo "Job complete."
```

<a id="use-nested-includes-with-duplicate-include-entries"></a>

### 在嵌套的 include 中使用重复的 `include` 条目

您可以在主配置文件和嵌套的 include 中多次包含同一个配置文件。

如果任何文件使用[覆盖](#override-included-configuration-values)更改了被包含的配置，那么 `include` 条目的顺序可能会影响最终配置。最后一次包含该配置会覆盖之前包含该文件的任何配置。例如：

- `defaults.gitlab-ci.yml` 文件的内容：

  ```yaml
  default:
    before_script: echo "Default before script"
  ```

- `unit-tests.gitlab-ci.yml` 文件的内容：

  ```yaml
  include:
    - template: defaults.gitlab-ci.yml

  default:  # 覆盖被包含的默认值
    before_script: echo "Unit test default override"

  unit-test-job:
    script: unit-test.sh
  ```

- `smoke-tests.gitlab-ci.yml` 文件的内容：

  ```yaml
  include:
    - template: defaults.gitlab-ci.yml

  default:  # 覆盖被包含的默认值
    before_script: echo "Smoke test default override"

  smoke-test-job:
    script: smoke-test.sh
  ```

对于这三个文件，它们被包含的顺序会改变最终配置。如果：

- 先包含 `unit-tests`，`.gitlab-ci.yml` 文件的内容为：

  ```yaml
  include:
    - local: unit-tests.gitlab-ci.yml
    - local: smoke-tests.gitlab-ci.yml
  ```

  最终配置将是：

  ```yaml
  unit-test-job:
   before_script: echo "Smoke test default override"
   script: unit-test.sh

  smoke-test-job:
   before_script: echo "Smoke test default override"
   script: smoke-test.sh
  ```

- 最后包含 `unit-tests`，`.gitlab-ci.yml` 文件的内容为：

  ```yaml
  include:
    - local: smoke-tests.gitlab-ci.yml
    - local: unit-tests.gitlab-ci.yml
  ```

  最终配置将是：

  ```yaml
  unit-test-job:
   before_script: echo "Unit test default override"
   script: unit-test.sh

  smoke-test-job:
   before_script: echo "Unit test default override"
   script: smoke-test.sh
  ```

如果没有文件覆盖被包含的配置，则 `include` 条目的顺序不会影响最终配置。

<a id="use-variables-with-include"></a>

## 在 `include` 中使用变量

在 `.gitlab-ci.yml` 文件的 `include` 部分中，您可以使用：

- [项目变量](../variables/_index.md#for-a-project)。
- [群组变量](../variables/_index.md#for-a-group)。
- [实例变量](../variables/_index.md#for-an-instance)。
- 项目[预定义变量](../variables/predefined_variables.md)（`CI_PROJECT_*`）。
- [触发器变量](../triggers/_index.md#pass-cicd-variables-in-the-api-call)。
- [定时流水线变量](../pipelines/schedules.md#create-a-pipeline-schedule)。
- [手动运行流水线变量](../pipelines/_index.md#run-a-pipeline-manually)。
- `CI_PIPELINE_SOURCE` 和 `CI_PIPELINE_TRIGGERED` [预定义变量](../variables/predefined_variables.md)。
- `$CI_COMMIT_REF_NAME` [预定义变量](../variables/predefined_variables.md)。

例如：

```yaml
include:
  project: '$CI_PROJECT_PATH'
  file: '.compliance-gitlab-ci.yml'
```

您不能使用在作业中定义的变量，或者全局 [`variables`](_index.md#variables) 部分中为所有作业定义默认变量的变量。`include` 在作业之前被评估，因此这些变量不能与 `include` 一起使用。

有关如何包含预定义变量以及变量对 CI/CD 作业影响的示例，请观看此 [CI/CD 变量演示](https://youtu.be/4XR8gw3Pkos)。

您不能在动态子流水线的配置中的 `include` 部分使用 CI/CD 变量。

<a id="use-rules-with-include"></a>

## 在 `include` 中使用 `rules`

{{< history >}}

- 在极狐GitLab 15.11 中引入对 `needs` 作业依赖的支持。

{{< /history >}}

您可以将 [`rules`](_index.md#rules) 与 `include` 一起使用，以根据条件包含其他配置文件。

您只能将 `rules` 与[某些变量](#use-variables-with-include)以及以下关键字一起使用：

- [`rules:if`](_index.md#rulesif)。
- [`rules:exists`](_index.md#rulesexists)。
- [`rules:changes`](_index.md#ruleschanges)。

<a id="include-with-rulesif"></a>

### `include` 与 `rules:if`

{{< history >}}

- 在极狐GitLab 16.1 中引入对 `when: never` 和 `when:always` 的支持，[带有一个功能标志](../../administration/feature_flags/_index.md) 名为 `ci_support_include_rules_when_never`。默认禁用。
- 在极狐GitLab 16.2 中，对 `when: never` 和 `when:always` 的支持 GA 并移除功能标志 `ci_support_include_rules_when_never`。

{{< /history >}}

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

{{< history >}}

- 在极狐GitLab 16.1 中引入对 `when: never` 和 `when:always` 的支持，[带有一个功能标志](../../administration/feature_flags/_index.md) 名为 `ci_support_include_rules_when_never`。默认禁用。
- 在极狐GitLab 16.2 中，对 `when: never` 和 `when:always` 的支持 GA 并移除功能标志 `ci_support_include_rules_when_never`。

{{< /history >}}

使用 [`rules:exists`](_index.md#rulesexists) 根据文件的存在性有条件地包含其他配置文件。例如：

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

如果您在来自不同项目的 include 文件中使用 `include` 与 `rules:exists`，请仔细检查您的配置。极狐GitLab 会在其他项目中检查文件的存在性。例如：

```yaml
# my-group/my-project 中的流水线配置
include:
  - project: my-group/other-project
    ref: other_branch
    file: other-file.yml

test:
  script: exit 0

# my-group/other-project 中 ref 为 other_branch 的 other-file.yml
include:
  - project: my-group/my-project
    ref: main
    file: my-file.yml
    rules:
      - exists:
          - file.md
```

在此示例中，极狐GitLab 会在 `my-group/other-project` 的提交 ref `other_branch` 中搜索 `file.md` 的存在性，而不是在流水线运行的项目/ref 中。

要更改搜索上下文，您可以使用 [`rules:exists:paths`](_index.md#rulesexistspaths) 与 [`rules:exists:project`](_index.md#rulesexistsproject)。例如：

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

{{< history >}}

- 在极狐GitLab 16.4 中引入。

{{< /history >}}

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
- 当 `Dockerfile` 发生更改且流水线源是合并请求事件时，包含 `builds3.yml`。`builds3.yml` 中的作业还必须配置为针对[合并请求流水线](../pipelines/merge_request_pipelines.md#configure-merge-request-pipelines)运行。

<a id="use-includelocal-with-wildcard-file-paths"></a>

## 使用 `include:local` 与通配符文件路径

您可以在 `include:local` 中使用通配符路径（`*` 和 `**`）。

示例：

```yaml
include: 'configs/*.yml'
```

当流水线运行时，极狐GitLab：

- 将 `configs` 目录中的所有 `.yml` 文件添加到流水线配置中。
- 不会添加 `configs` 目录子文件夹中的 `.yml` 文件。要允许此操作，请添加以下配置：

  ```yaml
  # 这将匹配 `configs` 及其任何子文件夹中的所有 `.yml` 文件。
  include: 'configs/**.yml'

  # 这将仅匹配 `configs` 子文件夹中的所有 `.yml` 文件。
  include: 'configs/**/*.yml'
  ```

<a id="troubleshooting"></a>

## 故障排查

<a id="maximum-of-150-nested-includes-are-allowed-error"></a>

### `Maximum of 150 nested includes are allowed!` 错误

一个流水线中[嵌套包含文件](#use-nested-includes)的最大数量为 150。如果您在流水线中收到 `Maximum 150 includes are allowed` 错误消息，可能的原因是：

- 某些嵌套配置包含了过多的额外嵌套 `include` 配置。
- 嵌套的 include 中存在意外循环。例如，`include1.yml` 包含 `include2.yml`，而 `include2.yml` 又包含 `include1.yml`，从而形成递归循环。

为了降低发生这种情况的风险，请使用[流水线编辑器](../pipeline_editor/_index.md)编辑流水线配置文件，该编辑器会验证是否达到限制。您可以每次移除一个被包含的文件，以尝试缩小哪个配置文件是循环或过多包含文件的来源。

在极狐GitLab 16.0 及更高版本中，私有化部署用户可以更改[最大包含数](../../administration/settings/continuous_integration.md#set-maximum-includes)的值。

<a id="error-local-file-file-does-not-exist-with-includelocal"></a>

### 错误：`include:local` 中出现 `Local file <file> does not exist!`

即使文件存在于仓库中，您在使用 [`include:local`](_index.md#includelocal) 时也可能会收到 `Local file <file> does not exist!` 错误。

此错误是一个已知的系统级问题，而非 CI/CD 配置问题。在分布式 Gitaly 或 Praefect 设置中偶尔会观察到。如果您遇到此错误，请重试流水线。

<a id="ssl_connect-syscall-returned=5-errno=0-state=sslv3/tls-write-client-hello-and-other-network-failures"></a>

### `SSL_connect SYSCALL returned=5 errno=0 state=SSLv3/TLS write client hello` 及其他网络故障

当使用 [`include:remote`](_index.md#includeremote) 时，极狐GitLab 尝试通过 HTTP(S) 获取远程文件。此过程可能因各种连接问题而失败。

`SSL_connect SYSCALL returned=5 errno=0 state=SSLv3/TLS write client hello` 错误发生在极狐GitLab 无法与远程主机建立 HTTPS 连接时。如果远程主机有速率限制以防止服务器请求过载，则可能导致此问题。

例如，JihuLab.com 的[极狐GitLab Pages](../../user/project/pages/_index.md) 服务器有速率限制。重复尝试获取托管在极狐GitLab Pages 上的 CI/CD 配置文件可能会导致达到速率限制并引发错误。您应避免将 CI/CD 配置文件托管在极狐GitLab Pages 站点上。

如果可能，请使用 [`include:project`](_index.md#includeproject) 从极狐GitLab 实例内的其他项目获取配置文件，而无需进行外部 HTTP(S) 请求。