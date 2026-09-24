---
title: 变量的使用位置
description: 极狐GitLab CI/CD 变量在不同环境中的使用和扩展
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

正如 [CI/CD 变量](_index.md) 文档中所述，你可以定义许多不同的变量。其中一些可用于所有极狐GitLab CI/CD 功能，但也有一些或多或少受到限制。

本文档描述了不同类型变量的使用位置和方式。

<a id="variables-usage"></a>

## 变量用法

定义的变量可以在两个地方使用：

1. 极狐GitLab 侧，在 `.gitlab-ci.yml` 文件中。
1. GitLab Runner 侧，在 `config.toml` 中。

<a id=".gitlab-ci.yml-file"></a>

### `.gitlab-ci.yml` 文件

{{< history >}}

- 极狐GitLab 16.4 中引入了对除 `CI_ENVIRONMENT_SLUG` 以外的 `CI_ENVIRONMENT_*` 变量的支持。

{{< /history >}}

| 定义                                                                     | 能否扩展？ | 扩展位置               | 描述 |
|:-------------------------------------------------------------------------|:-----------|:-----------------------|:------------|
| [`after_script`](../yaml/_index.md#after_script)                         | 是         | 脚本执行 Shell          | 变量扩展由[执行 Shell 环境](#execution-shell-environment)完成。 |
| [`artifacts:name`](../yaml/_index.md#artifactsname)                      | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`artifacts:paths`](../yaml/_index.md#artifactspaths)                    | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`artifacts:exclude`](../yaml/_index.md#artifactsexclude)                | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`before_script`](../yaml/_index.md#before_script)                       | 是         | 脚本执行 Shell          | 变量扩展由[执行 Shell 环境](#execution-shell-environment)完成。 |
| [`cache:key`](../yaml/_index.md#cachekey)                                | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`cache:paths`](../yaml/_index.md#cachepaths)                            | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`cache:policy`](../yaml/_index.md#cachepolicy)                          | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`environment:name`](../yaml/_index.md#environmentname)                  | 是         | 极狐GitLab               | 与 `environment:url` 类似，但变量扩展不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:url`](../yaml/_index.md#environmenturl)                    | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/>支持为作业定义的所有变量（项目/群组变量、来自 `.gitlab-ci.yml` 的变量、来自触发器的变量、来自流水线计划的变量）。<br/><br/>不支持在 GitLab Runner 的 `config.toml` 中定义的变量以及在作业的 `script` 中创建的变量。 |
| [`environment:deployment_tier`](../yaml/_index.md#environmentdeployment_tier) | 是     | 极狐GitLab               | 与 `environment:url` 类似，但变量扩展不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:auto_stop_in`](../yaml/_index.md#environmentauto_stop_in)  | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/> 被替换的变量的值应为一段人类可读的自然语言时间。更多信息请参见[支持的值](../yaml/_index.md#environmentauto_stop_in)。 |
| [`environment:kubernetes:agent`](../yaml/_index.md#environmentkubernetes) | 是        | 极狐GitLab               | 与 `environment:url` 类似，但变量扩展不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`environment:kubernetes:namespace`](../yaml/_index.md#environmentkubernetes) | 是    | 极狐GitLab               | 与 `environment:url` 类似，但变量扩展不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_*` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`id_tokens:aud`](../yaml/_index.md#id_tokens)                           | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。变量扩展功能在 极狐GitLab 16.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/414293)。 |
| [`image`](../yaml/_index.md#image)                                       | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`include`](../yaml/_index.md#include)                                   | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/>有关支持的变量的更多信息，请参见[在 include 中使用变量](../yaml/includes.md#use-variables-with-include)。 |
| [`resource_group`](../yaml/_index.md#resource_group)                     | 是         | 极狐GitLab               | 与 `environment:url` 类似，但变量扩展不支持以下内容：<br/>- `CI_ENVIRONMENT_URL`<br/>- [持久化变量](#persisted-variables)。 |
| [`rules:changes`](../yaml/_index.md#ruleschanges)                        | 否         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`rules:changes:compare_to`](../yaml/_index.md#ruleschangescompare_to)   | 否         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`rules:exists`](../yaml/_index.md#rulesexists)                          | 否         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`rules:if`](../yaml/_index.md#rulesif)                                  | 否         | 不适用                  | 变量必须采用 `$variable` 形式。不支持以下内容：<br/><br/>- `CI_ENVIRONMENT_SLUG` 变量。<br/>- [持久化变量](#persisted-variables)。 |
| [`script`](../yaml/_index.md#script)                                     | 是         | 脚本执行 Shell          | 变量扩展由[执行 Shell 环境](#execution-shell-environment)完成。 |
| [`services:name`](../yaml/_index.md#services)                            | 是         | Runner                 | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| [`tags`](../yaml/_index.md#tags)                                         | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。 |
| [`trigger` 和 `trigger:project`](../yaml/_index.md#trigger)              | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。`trigger:project` 的变量扩展功能在 极狐GitLab 15.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/367660)。 |
| [`variables`](../yaml/_index.md#variables)                               | 是         | 极狐GitLab/Runner        | 变量扩展首先由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成，然后任何无法识别或不可用的变量由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)扩展。 |
| [`workflow:name`](../yaml/_index.md#workflowname)                        | 是         | 极狐GitLab               | 变量扩展由极狐GitLab 的[内部变量扩展机制](#gitlab-internal-variable-expansion-mechanism)完成。<br/><br/>支持 `workflow` 中可用的所有变量：<br/>- 项目/群组变量。<br/>- 全局 `variables` 和 `workflow:rules:variables`（当匹配规则时）。<br/>- 从父流水线继承的变量。<br/>- 来自触发器的变量。<br/>- 来自流水线计划的变量。<br/><br/>不支持在 GitLab Runner 的 `config.toml` 中定义的变量、在作业中定义的变量或[持久化变量](#persisted-variables)。 |

<a id="config.toml-file"></a>

### `config.toml` 文件

| 定义                                    | 能否扩展？ | 描述 |
|:---------------------------------------|:-----------|:------------|
| `runners.environment`                 | 是         | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| `runners.kubernetes.pod_labels`       | 是         | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |
| `runners.kubernetes.pod_annotations`  | 是         | 变量扩展由 GitLab Runner 的[内部变量扩展机制](#gitlab-runner-internal-variable-expansion-mechanism)完成。 |

你可以在 [极狐GitLab Runner 文档](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 中阅读更多关于 `config.toml` 的信息。

<a id="expansion-mechanisms"></a>

## 扩展机制

存在三种扩展机制：

- 极狐GitLab
- GitLab Runner
- 执行 Shell 环境

<a id="gitlab-internal-variable-expansion-mechanism"></a>

### 极狐GitLab 内部变量扩展机制

需要扩展的部分必须采用 `$variable`、`${variable}` 或 `%variable%` 的形式。无论哪个操作系统/Shell 处理该作业，这些形式都以相同的方式处理，因为扩展是在任何 Runner 获取作业之前由 极狐GitLab 完成的。

<a id="nested-variable-expansion"></a>

#### 嵌套变量扩展

极狐GitLab 在将作业变量值发送给 Runner 之前会递归地扩展它们。例如，在以下场景中：

```yaml
- BUILD_ROOT_DIR: '${CI_BUILDS_DIR}'
- OUT_PATH: '${BUILD_ROOT_DIR}/out'
- PACKAGE_PATH: '${OUT_PATH}/pkg'
```

Runner 会接收到一个有效且完整格式的路径。例如，如果 `${CI_BUILDS_DIR}` 是 `/output`，那么 `PACKAGE_PATH` 将是 `/output/out/pkg`。

对不可用变量的引用将保持原样。在这种情况下，Runner 会在运行时[尝试扩展变量值](#gitlab-runner-internal-variable-expansion-mechanism)。例如，像 `CI_BUILDS_DIR` 这样的变量只有 Runner 在运行时才知道。

<a id="gitlab-runner-internal-variable-expansion-mechanism"></a>

### GitLab Runner 内部变量扩展机制

- 支持：项目/群组变量、`.gitlab-ci.yml` 变量、`config.toml` 变量以及来自触发器、流水线计划和手动流水线的变量。
- 不支持：在脚本内部定义的变量（例如 `export MY_VARIABLE="test"`）。

Runner 使用 Go 的 `os.Expand()` 方法进行变量扩展。这意味着它只处理定义为 `$variable` 和 `${variable}` 的变量。同样重要的是，扩展只进行一次，因此嵌套变量可能有效也可能无效，这取决于变量定义的顺序以及 极狐GitLab 中是否启用了[嵌套变量扩展](#nested-variable-expansion)。

对于产物和缓存上传，Runner 使用 [mvdan.cc/sh/v3/expand](https://pkg.go.dev/mvdan.cc/sh/v3/expand) 进行变量扩展，而不是 Go 的 `os.Expand()`，因为 `mvdan.cc/sh/v3/expand` 支持[参数扩展](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)。

<a id="execution-shell-environment"></a>

### 执行 Shell 环境

这是在 `script` 执行期间发生的一个扩展阶段。其行为取决于所使用的 Shell（`bash`、`sh`、`cmd`、PowerShell）。例如，如果作业的 `script` 包含一行 `echo $MY_VARIABLE-${MY_VARIABLE_2}`，它应该由 bash/sh 正确处理（根据变量是否定义，留下空字符串或某些值），但不能在 Windows 的 `cmd` 或 PowerShell 中工作，因为这些 Shell 使用不同的变量语法。

支持：

- `script` 可以使用 Shell 默认的所有可用变量（例如所有 bash/sh Shell 中都应存在的 `$PATH`）以及极狐GitLab CI/CD 定义的所有变量（项目/群组变量、`.gitlab-ci.yml` 变量、`config.toml` 变量以及来自触发器和流水线计划的变量）。
- `script` 也可以使用在前面的行中定义的所有变量。因此，例如，如果你定义了一个变量 `export MY_VARIABLE="test"`：
  - 在 `before_script` 中，它可以在后续的 `before_script` 行和相关的 `script` 的所有行中工作。
  - 在 `script` 中，它可以在后续的 `script` 行中工作。
  - 在 `after_script` 中，它可以在后续的 `after_script` 行中工作。

对于 `after_script` 脚本，它们可以：

- 仅使用在同一 `after_script` 部分中脚本之前定义的变量。
- 不能使用在 `before_script` 和 `script` 中定义的变量。

这些限制存在是因为 `after_script` 脚本是在一个[独立的 Shell 上下文](../yaml/_index.md#after_script)中执行的。

<a id="persisted-variables"></a>

## 持久化变量

一些预定义变量被称为持久化变量。持久化变量：

- 支持在[扩展位置](#gitlab-ciyml-file)为以下对象的定义中使用：
  - Runner。
  - 脚本执行 Shell。
- 不支持：
  - 在[扩展位置](#gitlab-ciyml-file)为 极狐GitLab 的定义中使用。
  - 在 `rules` [变量表达式](../jobs/job_rules.md#cicd-variable-expressions)中使用。

[流水线触发任务](../yaml/_index.md#trigger)不能使用作业级别的持久化变量，但可以使用流水线级别的持久化变量。

某些持久化变量包含令牌，出于安全原因不能在某些定义中使用。

流水线级别的持久化变量：

- `CI_PIPELINE_ID`
- `CI_PIPELINE_URL`

作业级别的持久化变量：

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

## 具有环境范围的变量

支持使用定义了环境范围的变量。假设在 `review/staging/*` 范围内定义了一个变量 `$STAGING_SECRET`，下面这个使用动态环境的任务将基于匹配的变量表达式创建：

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