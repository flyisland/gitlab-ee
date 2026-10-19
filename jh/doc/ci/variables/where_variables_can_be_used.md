---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab CI/CD 变量在不同环境中的使用与展开。
title: 变量的使用位置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如 [CI/CD 变量](_index.md)文档所述，您可以定义许多不同的变量。其中一些可用于所有极狐GitLab CI/CD 功能，而另一些则或多或少有所限制。

本文档介绍不同类型的变量可以在何处以及如何使用。

<a id="variables-usage"></a>

## 变量的使用

您可以在以下文件中使用已定义的变量：

- 在极狐GitLab 中，使用 `.gitlab-ci.yml`
- 在极狐GitLab Runner 中，使用 `config.toml`

<a id="gitlab-ciyml-file"></a>

### `.gitlab-ci.yml` 文件

| 定义                                                              | 可以展开？ | 展开位置        | 描述 |
|:------------------------------------------------------------------------|:-----------------|:-----------------------|:------------|
| [`after_script`](../yaml/_index.md#after_script)                        | 是              | 脚本执行 shell | 变量展开由[执行 shell 环境](#execution-shell-environment)完成。 |
| [`artifacts:name`](../yaml/_index.md#artifactsname)                     | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`artifacts:paths`](../yaml/_index.md#artifactspaths)                   | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`artifacts:exclude`](../yaml/_index.md#artifactsexclude)               | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`before_script`](../yaml/_index.md#before_script)                      | 是              | 脚本执行 shell | 变量展开由[执行 shell 环境](#execution-shell-environment)完成 |
| [`cache:key`](../yaml/_index.md#cachekey)                               | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`cache:paths`](../yaml/_index.md#cachepaths)                           | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`cache:policy`](../yaml/_index.md#cachepolicy)                         | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`environment:name`](../yaml/_index.md#environmentname)                 | 是              | 极狐GitLab                 | 与 `environment:url` 类似，但变量展开不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:url`](../yaml/_index.md#environmenturl)                   | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/>支持为作业定义的所有变量（项目/群组变量、来自 `.gitlab-ci.yml`的变量、来自触发器的变量、来自流水线计划的变量）。<br/><br/>不支持在极狐GitLab Runner `config.toml`中定义的变量以及在作业的 `script`中创建的变量。 |
| [`environment:deployment_tier`](../yaml/_index.md#environmentdeployment_tier) | 是              | 极狐GitLab                 | 与 `environment:url` 类似，但变量展开不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:auto_stop_in`](../yaml/_index.md#environmentauto_stop_in) | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/> 被替换的变量值应为人类可读自然语言形式的一段时间。更多信息请参见[支持的值](../yaml/_index.md#environmentauto_stop_in)。 |
| [`environment:kubernetes:agent`](../yaml/_index.md#environmentkubernetes) | 是            | 极狐GitLab                 | 与 `environment:url` 类似，但变量展开不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:kubernetes:flux_resource_path`](../yaml/_index.md#environmentkubernetes) | 是 | 极狐GitLab               | 与 `environment:url` 类似，但变量展开不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:kubernetes:namespace`](../yaml/_index.md#environmentkubernetes) | 是        | 极狐GitLab                 | 与 `environment:url` 类似，但变量展开不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`id_tokens:aud`](../yaml/_index.md#id_tokens)                          | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`image`](../yaml/_index.md#image)                                      | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`include`](../yaml/_index.md#include)                                  | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 <br/><br/>有关支持的变量的更多信息，请参见[将变量与 include 一起使用](../yaml/includes.md#use-variables-with-include)。 |
| [`resource_group`](../yaml/_index.md#resource_group)                    | 是              | 极狐GitLab                 | 与 `environment:url` 类似，但变量展开不支持以下内容：<br/>- `CI_ENVIRONMENT_URL`<br/>- [持久化变量](#persisted-variables)。 |
| [`rules:changes`](../yaml/_index.md#ruleschanges)                       | 否               | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`rules:changes:compare_to`](../yaml/_index.md#ruleschangescompare_to)  | 否               | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`rules:exists`](../yaml/_index.md#rulesexists)                         | 否               | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`rules:if`](../yaml/_index.md#rulesif)                                 | 否               | 不适用         | 变量必须采用 `$variable` 形式。不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_SLUG` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`script`](../yaml/_index.md#script)                                    | 是              | 脚本执行 shell | 变量展开由[执行 shell 环境](#execution-shell-environment)完成。 |
| [`services:name`](../yaml/_index.md#services)                           | 是              | Runner                 | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`tags`](../yaml/_index.md#tags)                                        | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`trigger` 和 `trigger:project`](../yaml/_index.md#trigger)            | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`variables`](../yaml/_index.md#variables)                              | 是              | 极狐GitLab/Runner          | 变量展开首先由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成，然后任何无法识别或不可用的变量由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)展开。 |
| [`workflow:name`](../yaml/_index.md#workflowname)                       | 是              | 极狐GitLab                 | 变量展开由极狐GitLab 中的[内部变量展开机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/>支持 `workflow`中可用的所有变量：<br/>- 项目/群组变量。<br/>- 全局 `variables` 和 `workflow:rules:variables`（当匹配规则时）。<br/>- 从父流水线继承的变量。<br/>- 来自触发器的变量。<br/>- 来自流水线计划的变量。<br/><br/>不支持在极狐GitLab Runner `config.toml`中定义的变量、在作业中定义的变量或[持久化变量](#persisted-variables)。 |

<a id="configtoml-file"></a>

### `config.toml` 文件

| 定义                           | 可以展开？ | 描述 |
|:-------------------------------------|:-----------------|:------------|
| `runners.environment`                | 是              | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成 |
| `runners.kubernetes.pod_labels`      | 是              | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成 |
| `runners.kubernetes.pod_annotations` | 是              | 变量展开由极狐GitLab Runner 的[内部变量展开机制](#gitlab-runner-internal-variable-expansion-mechanism)完成 |

有关 `config.toml`的更多信息，请参见[高级配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)。

<a id="expansion-mechanisms"></a>

## 展开机制

变量可以通过以下方式展开：

- 在极狐GitLab 中，在 runner 接收作业之前
- 在极狐GitLab Runner 中，当其处理作业时
- 在执行 shell 环境中，在脚本执行期间

<a id="gitlab-internal-variable-expansion-mechanism"></a>

### 极狐GitLab 内部变量展开机制

被展开的部分需要采用 `$variable`、`${variable}` 或 `%variable%` 的形式。无论由哪种操作系统/shell 处理作业，每种形式的处理方式都相同，因为展开是在任何 runner 获取作业之前由极狐GitLab 完成的。

<a id="nested-variable-expansion"></a>

#### 嵌套变量展开

极狐GitLab 在将作业变量值发送给 runner 之前会递归展开这些值。例如，在以下场景中：

```yaml
- BUILD_ROOT_DIR: '${CI_BUILDS_DIR}'
- OUT_PATH: '${BUILD_ROOT_DIR}/out'
- PACKAGE_PATH: '${OUT_PATH}/pkg'
```

runner 会收到一个有效且格式完整的路径。例如，如果 `${CI_BUILDS_DIR}` 为 `/output`，那么 `PACKAGE_PATH` 将为 `/output/out/pkg`。

对不可用变量的引用会保持原样。在这种情况下，runner 会在运行时[尝试展开变量值](#gitlab-runner-internal-variable-expansion-mechanism)。例如，像 `CI_BUILDS_DIR` 这样的变量只有 runner 在运行时才知道。

<a id="gitlab-runner-internal-variable-expansion-mechanism"></a>

### 极狐GitLab Runner 内部变量展开机制

- 支持：项目/群组变量、`.gitlab-ci.yml` 变量、`config.toml` 变量，以及
  来自触发器、流水线计划和手动流水线的变量。
- 不支持：在脚本内部定义的变量（例如 `export MY_VARIABLE="test"`）。

runner 使用 Go 的 `os.Expand()` 方法进行变量展开。这意味着它只处理定义为 `$variable` 和 `${variable}` 的变量。同样重要的是，展开只执行一次，因此嵌套变量可能有效也可能无效，具体取决于变量定义的顺序，以及极狐GitLab 中是否启用了[嵌套变量展开](#nested-variable-expansion)。

对于产物和缓存上传，runner 使用
[mvdan.cc/sh/v3/expand](https://pkg.go.dev/mvdan.cc/sh/v3/expand) 进行变量
展开，而不是 Go 的 `os.Expand()`，因为 `mvdan.cc/sh/v3/expand` 支持[参数展开](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)。

<a id="execution-shell-environment"></a>

### 执行 shell 环境

执行 shell 环境是在 `script` 执行期间发生的展开阶段。其行为取决于所使用的 shell（`bash`、`sh`、`cmd`、PowerShell）。例如，如果作业的 `script` 包含一行 `echo $MY_VARIABLE-${MY_VARIABLE_2}`，它应能被 bash/sh 正确处理（根据变量是否已定义，留下空字符串或某些值），
但在 Windows 的 `cmd` 或 PowerShell 中无法正常工作，因为这些 shell
使用不同的变量语法。

支持：

- `script` 可以使用 shell 默认的所有可用变量（例如 `$PATH`，
  它应存在于所有 bash/sh shell 中）以及极狐GitLab CI/CD 定义的所有变量（项目/群组变量、
  `.gitlab-ci.yml` 变量、`config.toml` 变量，以及来自触发器和流水线计划的变量）。
- `script` 还可以使用前面几行中定义的所有变量。因此，例如，如果您定义
  一个变量 `export MY_VARIABLE="test"`：
  - 在 `before_script`中，它可在 `before_script`的后续行以及
    相关 `script`的所有行中生效。
  - 在 `script`中，它可在 `script`的后续行中生效。
  - 在 `after_script`中，它可在 `after_script`的后续行中生效。

对于 `after_script` 脚本，它们可以：

- 仅使用同一 `after_script` 区段中脚本之前定义的变量。
- 不能使用在 `before_script` 和 `script`中定义的变量。

存在这些限制是因为 `after_script` 脚本在[独立的 shell 上下文](../yaml/_index.md#after_script)中执行。

<a id="persisted-variables"></a>

## 持久化变量

一些预定义变量被称为持久化变量。持久化变量：

- 支持[展开位置](#gitlab-ciyml-file)为以下内容的定义：
  - Runner。
  - 脚本执行 shell。
- 不支持：
  - [展开位置](#gitlab-ciyml-file)为极狐GitLab 的定义。
  - 在 `rules` [变量表达式](../jobs/job_rules.md#cicd-variable-expressions)中。

[流水线触发作业](../yaml/_index.md#trigger)不能使用作业级持久化变量，但可以使用流水线级持久化变量。

一些持久化变量包含令牌，出于安全原因，某些定义无法使用它们。

流水线级持久化变量：

- `CI_PIPELINE_ID`
- `CI_PIPELINE_URL`

作业级持久化变量：

- `CI_DEPLOY_PASSWORD`
- `CI_DEPLOY_USER`
- `CI_JOB_ID`
- `CI_JOB_STARTED_AT`
- `CI_JOB_TOKEN`
- `CI_JOB_URL`
- `CI_PIPELINE_CREATED_AT`
- `CI_REGISTRY_PASSWORD`
- `CI_REGISTRY_USER`
- `CI_REPOSITORY_URL`

<a id="variables-with-an-environment-scope"></a>

## 带环境作用域的变量

支持使用环境作用域定义的变量。假设在 `review/staging/*` 的作用域中定义了一个变量 `$STAGING_SECRET`，则会根据匹配的变量表达式创建以下使用动态环境的作业：

```yaml
my-job:
  stage: staging
  environment:
    name: review/$CI_JOB_STAGE/deploy
  script:
    - 'deploy staging'
  rules:
    - if: $STAGING_SECRET == 'something'
```
