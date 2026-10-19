---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 设置超时、保护敏感信息、使用标签和变量控制行为，并配置极狐GitLab Runner 的产物和缓存设置。
title: 配置 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档介绍如何在极狐GitLab UI 中配置 Runner。

如果您需要在安装极狐GitLab Runner 的机器上配置 Runner，请参阅
[极狐GitLab Runner 文档](https://gitlab.cn/docs/runner/configuration/)。

<a id="set-the-maximum-job-timeout"></a>

## 设置最大作业超时

您可以为每个 Runner 指定最大作业超时，以防止作业超时时间较长的项目使用该 Runner。如果最大作业超时短于项目中定义的作业超时，则使用最大作业超时：

| Runner 超时 | 项目超时 | 作业超时时间 |
|----------------|------------------|----------------------|
| 24 小时       | 2 小时          | 2 小时              |
| 未配置 | 2 小时          | 2 小时              |
| 30 分钟     | 2 小时          | 30 分钟           |

要设置 Runner 的最大超时，请在 REST API 端点 [`PUT /runners/:id`](../../api/runners.md#update-runners-details)中设置 `maximum_timeout` 参数。

<a id="for-an-instance-runner"></a>

### 对于实例 Runner

先决条件：

- 您必须是管理员。

您可以在极狐GitLab 私有化部署上覆盖实例 Runner 的作业超时。

在 JihuLab.com 上，您无法覆盖极狐GitLab 托管的实例 Runner 的作业超时，必须改用[项目定义的超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)。

要设置最大作业超时：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 在要编辑的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 在**最大作业超时**字段中，输入以秒为单位的值。最小值为 600 秒（10 分钟）。
1. 选择**保存更改**。

<a id="for-a-group-runner"></a>

### 对于群组 Runner

先决条件：

- 您必须拥有该群组的所有者角色。

要设置最大作业超时：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runner**。
1. 在要编辑的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 在**最大作业超时**字段中，输入以秒为单位的值。最小值为 600 秒（10 分钟）。
1. 选择**保存更改**。

<a id="for-a-project-runner"></a>

### 对于项目 Runner

先决条件：

- 您必须拥有该项目的所有者角色。

要设置最大作业超时：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runner**。
1. 在要编辑的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 在**最大作业超时**字段中，输入以秒为单位的值。最小值为 600 秒（10 分钟）。如果未定义，则改用[项目的作业超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)。
1. 选择**保存更改**。

<a id="set-script-and-after_script-timeouts"></a>

## 设置 `script` 和 `after_script` 超时

要控制 `script` 和 `after_script` 在终止前运行的时间，请在 `.gitlab-ci.yml` 文件中指定超时值。

例如，您可以指定超时以提前终止长时间运行的 `script`。这可以确保在超过[作业超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)之前仍能上传产物和缓存。`script` 和 `after_script`的超时值必须小于作业超时。

- 要为 `script` 设置超时，请使用作业变量 `RUNNER_SCRIPT_TIMEOUT`。
- 要为 `after_script` 设置超时并覆盖默认的 5 分钟，请使用作业变量 `RUNNER_AFTER_SCRIPT_TIMEOUT`。

这两个变量都接受 [Go 的时长格式](https://pkg.go.dev/time#ParseDuration)（例如 `40s`、`1h20m`、`2h` `4h30m30s`）。

例如：

```yaml
job-with-script-timeouts:
  variables:
    RUNNER_SCRIPT_TIMEOUT: 15m
    RUNNER_AFTER_SCRIPT_TIMEOUT: 10m
  script:
    - "I am allowed to run for min(15m, remaining job timeout)."
  after_script:
    - "I am allowed to run for min(10m, remaining job timeout)."

job-artifact-upload-on-timeout:
  timeout: 1h                           # set job timeout to 1 hour
  variables:
     RUNNER_SCRIPT_TIMEOUT: 50m         # only allow script to run for 50 minutes
  script:
    - long-running-process > output.txt # will be terminated after 50m

  artifacts: # artifacts will have roughly ~10m to upload
    paths:
      - output.txt
    when: on_failure # on_failure because script termination after a timeout is treated as a failure
```

<a id="ensuring-after_script-execution"></a>

### 确保 `after_script` 执行

要使 `after_script` 成功运行，`RUNNER_SCRIPT_TIMEOUT` + `RUNNER_AFTER_SCRIPT_TIMEOUT`的总和不得超过作业配置的超时。

以下示例展示了如何配置超时，以确保即使主脚本超时，`after_script` 仍能运行：

```yaml
job-with-script-timeouts:
  timeout: 5m
  variables:
    RUNNER_SCRIPT_TIMEOUT: 1m
    RUNNER_AFTER_SCRIPT_TIMEOUT: 1m
  script:
    - echo "Starting build..."
    - sleep 120 # Wait 2 minutes to trigger timeout. Script aborts after 1 minute due to RUNNER_SCRIPT_TIMEOUT.
    - echo "Build finished."
  after_script:
    - echo "Starting Clean-up..."
    - sleep 15 # Wait just a few seconds. Runs successfully because it's within RUNNER_AFTER_SCRIPT_TIMEOUT.
    - echo "Clean-up finished."
```

`script` 被 `RUNNER_SCRIPT_TIMEOUT` 取消，但 `after_script` 成功运行，因为它耗时 15 秒，小于 `RUNNER_AFTER_SCRIPT_TIMEOUT` 和作业的 `timeout` 值。

<a id="protecting-sensitive-information"></a>

## 保护敏感信息

使用实例 Runner 时安全风险更大，因为默认情况下极狐GitLab 实例中的所有群组和项目都可以使用它们。Runner 执行器和文件系统配置会影响安全性。有权访问 Runner 主机环境的用户可以查看 Runner 执行的代码和 Runner 认证信息。例如，有权访问 Runner 认证令牌的用户可以克隆 Runner 并以向量攻击方式提交虚假作业。有关更多信息，请参阅[安全注意事项](https://gitlab.cn/docs/runner/security/)。

<a id="configuring-long-polling"></a>

## 配置长轮询

要减少作业排队时间和极狐GitLab 服务器上的负载，请配置[长轮询](long_polling.md)。

<a id="using-instance-runners-in-forked-projects"></a>

## 在 forked 项目中使用实例 Runner

当项目被 forked 时，与作业相关的作业设置会被复制。如果您为某个项目配置了实例 Runner，而用户 forks 了该项目，则实例 Runner 会为该项目的作业提供服务。

由于一个[已知问题](https://gitlab.com/gitlab-org/gitlab/-/issues/364303)，如果 forked 项目的 Runner 设置与新项目命名空间不匹配，则会显示以下消息：
`An error occurred while forking the project. Please try again.`。

要变通解决此问题，请确保实例 Runner 设置在 forked 项目和新命名空间中保持一致。

- 如果在 forked 项目上启用了实例 Runner，则在新命名空间上也应启用。
- 如果在 forked 项目上禁用了实例 Runner，则在新命名空间上也应禁用。

<a id="reset-the-runner-registration-token-for-a-project-deprecated"></a>

## 重置项目的 Runner 注册令牌（已弃用）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版
> 且不推荐使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌以注册 Runner。此过程可提供完整的
> Runner 所有权可追溯性，并增强 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](new_creation_workflow.md)。

如果您认为某个项目的注册令牌已泄露，则应重置它。注册令牌可用于为该项目注册另一个 Runner。然后，该新 Runner 可能被用来获取密钥变量的值或克隆项目代码。

要重置注册令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runner**。
1. 在**新建项目 Runner** 右侧，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择**重置注册令牌**。
1. 选择**重置令牌**。

重置注册令牌后，它将不再有效，并且不会向项目注册任何新 Runner。您还应更新用于预配和注册新值的工具中的注册令牌。

<a id="authentication-token-security"></a>

## 认证令牌安全

每个 Runner 都使用一个 [Runner 认证令牌](../../api/runners.md#registration-and-authentication-tokens)
来连接极狐GitLab 实例并与之进行认证。

为帮助防止令牌被泄露，您可以让令牌按指定间隔自动轮换。令牌轮换时，无论 Runner 的状态如何（`online` 或 `offline`），都会为每个 Runner 更新令牌。

无需任何手动干预，也不应影响任何正在运行的作业。有关令牌轮换的更多信息，请参阅 [Runner 认证令牌在轮换时不会更新](new_creation_workflow.md#runner-authentication-token-does-not-update-when-rotated)。

如果您需要手动更新 Runner 认证令牌，可以运行命令来[重置令牌](https://gitlab.cn/docs/runner/commands/#gitlab-runner-reset-token)。

<a id="reset-the-runner-configuration-authentication-token"></a>

### 重置 Runner 配置认证令牌

如果 Runner 的认证令牌被泄露，攻击者可能利用它来[克隆 Runner](https://gitlab.cn/docs/runner/security/#cloning-a-runner)。

要重置 Runner 配置认证令牌：

1. 删除该 Runner：
   - [删除实例 Runner](runners_scope.md#delete-instance-runners)。
   - [删除群组 Runner](runners_scope.md#delete-a-group-runner)。
   - [删除项目 Runner](runners_scope.md#delete-a-project-runner)。
1. 创建一个新 Runner，以便为其分配新的 Runner 认证令牌：
   - [创建实例 Runner](runners_scope.md#create-an-instance-runner-with-a-runner-authentication-token)。
   - [创建群组 Runner](runners_scope.md#create-a-group-runner-with-a-runner-authentication-token)。
   - [创建项目 Runner](runners_scope.md#create-a-project-runner-with-a-runner-authentication-token)。
1. 可选。要验证先前的 Runner 认证令牌已被撤销，请使用 [Runner API](../../api/runners.md#verify-authentication-for-a-registered-runner)。

要重置 Runner 配置认证令牌，您还可以使用 [Runner API](../../api/runners.md)。

<a id="automatically-rotate-runner-authentication-tokens"></a>

### 自动轮换 Runner 认证令牌

您可以指定轮换 Runner 认证令牌的间隔。定期轮换 Runner 认证令牌有助于最大程度降低因令牌泄露而导致未经授权访问极狐GitLab 实例的风险。

先决条件：

- 您必须是管理员。

要自动轮换 Runner 认证令牌：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 为 Runner 设置 **Runner 过期时间**，留空表示不过期。
1. 选择**保存更改**。

在间隔到期之前，Runner 会自动请求新的 Runner 认证令牌。有关令牌轮换的更多信息，请参阅 [Runner 认证令牌在轮换时不会更新](new_creation_workflow.md#runner-authentication-token-does-not-update-when-rotated)。

<a id="prevent-runners-from-revealing-sensitive-information"></a>

## 防止 Runner 泄露敏感信息

为确保 Runner 不泄露敏感信息，您可以将其配置为仅在[受保护分支](../../user/project/repository/branches/protected.md)上运行作业，或仅运行具有[受保护标签](../../user/project/protected_tags.md)的作业。

配置为在受保护分支上运行作业的 Runner [可以选择在合并请求流水线中运行作业](../pipelines/merge_request_pipelines.md#control-access-to-protected-variables-and-runners)。

<a id="for-an-instance-runner-1"></a>

### 对于实例 Runner

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 在要保护的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 选中**受保护**复选框。
1. 选择**保存更改**。

<a id="for-a-group-runner-1"></a>

### 对于群组 Runner

先决条件：

- 您必须拥有该群组的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runner**。
1. 在要保护的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 选中**受保护**复选框。
1. 选择**保存更改**。

<a id="for-a-project-runner-1"></a>

### 对于项目 Runner

先决条件：

- 您必须拥有该项目的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runner**。
1. 在要保护的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 选中**受保护**复选框。
1. 选择**保存更改**。

<a id="control-jobs-that-a-runner-can-run"></a>

## 控制 Runner 可以运行的作业

您可以使用[标签](../yaml/_index.md#tags)来控制 Runner 可以运行的作业。例如，您可以为具有运行 Rails 测试套件依赖项的 Runner 指定 `rails` 标签。

极狐GitLab CI/CD 标签不同于 Git 标签。极狐GitLab CI/CD 标签与 Runner 关联。
Git 标签与提交关联。

<a id="for-an-instance-runner-2"></a>

### 对于实例 Runner

先决条件：

- 您必须是管理员。

要控制实例 Runner 可以运行的作业：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 在要编辑的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 将 Runner 设置为运行带标签或不带标签的作业：
   - 要运行带标签的作业，请在**标签**字段中输入作业标签，以逗号分隔。例如 `macos`、`rails`。
   - 要运行不带标签的作业，请选中**运行未打标签的作业**复选框。
1. 选择**保存更改**。

<a id="for-a-group-runner-2"></a>

### 对于群组 Runner

先决条件：

- 您必须拥有该群组的所有者角色。

要控制群组 Runner 可以运行的作业：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runner**。
1. 在要编辑的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 将 Runner 设置为运行带标签或不带标签的作业：
   - 要运行带标签的作业，请在**标签**字段中输入作业标签，以逗号分隔。例如 `macos`、`ruby`。
   - 要运行不带标签的作业，请选中**运行未打标签的作业**复选框。
1. 选择**保存更改**。

<a id="for-a-project-runner-2"></a>

### 对于项目 Runner

先决条件：

- 您必须拥有该项目的所有者角色。

要控制项目 Runner 可以运行的作业：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runner**。
1. 在要编辑的 Runner 右侧，选择**编辑** ({{< icon name="pencil" >}})。
1. 将 Runner 设置为运行带标签或不带标签的作业：
   - 要运行带标签的作业，请在**标签**字段中输入作业标签，以逗号分隔。例如 `macos`、`ruby`。
   - 要运行不带标签的作业，请选中**运行未打标签的作业**复选框。
1. 选择**保存更改**。

<a id="how-the-runner-uses-tags"></a>

### Runner 如何使用标签

<a id="runner-runs-only-tagged-jobs"></a>

#### Runner 仅运行带标签的作业

以下示例说明了将 Runner 设置为仅运行带标签作业的潜在影响。

示例 1：

1. Runner 配置为仅运行带标签的作业，并具有 `docker` 标签。
1. 一个具有 `hello` 标签的作业被执行并卡住。

示例 2：

1. Runner 配置为仅运行带标签的作业，并具有 `docker` 标签。
1. 一个具有 `docker` 标签的作业被执行并运行。

示例 3：

1. Runner 配置为仅运行带标签的作业，并具有 `docker` 标签。
1. 一个未定义标签的作业被执行并卡住。

<a id="runner-is-allowed-to-run-untagged-jobs"></a>

#### 允许 Runner 运行不带标签的作业

以下示例说明了将 Runner 设置为运行带标签和不带标签作业的潜在影响。

示例 1：

1. Runner 配置为运行不带标签的作业，并具有 `docker` 标签。
1. 一个未定义标签的作业被执行并运行。
1. 第二个定义了 `docker` 标签的作业被执行并运行。

示例 2：

1. Runner 配置为运行不带标签的作业，且未定义标签。
1. 一个未定义标签的作业被执行并运行。
1. 第二个定义了 `docker` 标签的作业被卡住。

<a id="a-runner-and-a-job-have-multiple-tags"></a>

#### Runner 和作业有多个标签

匹配作业和 Runner 的选择逻辑基于作业中定义的 `tags` 列表。

以下示例说明了 Runner 和作业具有多个标签的影响。要选择某个 Runner 来运行作业，它必须具有作业脚本块中定义的所有标签。

示例 1：

1. Runner 配置了标签 `[docker, shell, gpu]`。
1. 作业具有标签 `[docker, shell, gpu]` 并被执行并运行。

示例 2：

1. Runner 配置了标签 `[docker, shell, gpu]`。
1. 作业具有标签 `[docker, shell,]` 并被执行并运行。

示例 3：

1. Runner 配置了标签 `[docker, shell]`。
1. 作业具有标签 `[docker, shell, gpu]` 且不会被执行。

<a id="use-tags-to-run-jobs-on-different-platforms"></a>

### 使用标签在不同平台上运行作业

您可以使用标签在不同平台上运行不同的作业。例如，如果您有一个带有 `osx` 标签的 OS X Runner 和一个带有 `windows` 标签的 Windows Runner，则可以在每个平台上运行作业。

更新 `.gitlab-ci.yml`中的 `tags` 字段：

```yaml
windows job:
  stage: build
  tags:
    - windows
  script:
    - echo Hello, %USERNAME%!

osx job:
  stage: build
  tags:
    - osx
  script:
    - echo "Hello, $USER!"
```

<a id="use-cicd-variables-in-tags"></a>

### 在标签中使用 CI/CD 变量

在 `.gitlab-ci.yml` 文件中，将 [CI/CD 变量](../variables/_index.md)与 `tags` 一起使用，以实现动态 Runner 选择：

```yaml
variables:
  KUBERNETES_RUNNER: kubernetes

  job:
    tags:
      - docker
      - $KUBERNETES_RUNNER
    script:
      - echo "Hello runner selector feature"
```

<a id="configure-runner-behavior-with-variables"></a>

## 使用变量配置 Runner 行为

您可以使用 [CI/CD 变量](../variables/_index.md)来全局配置 Runner 的 Git 行为，或为单个作业配置：

- [`GIT_STRATEGY`](#git-strategy)
- [`GIT_SUBMODULE_STRATEGY`](#git-submodule-strategy)
- [`GIT_CHECKOUT`](#git-checkout)
- [`GIT_CLEAN_FLAGS`](#git-clean-flags)
- [`GIT_FETCH_EXTRA_FLAGS`](#git-fetch-extra-flags)
- [`GIT_CLONE_EXTRA_FLAGS`](#git-clone-extra-flags)
- [`GIT_SUBMODULE_UPDATE_FLAGS`](#git-submodule-update-flags)
- [`GIT_SUBMODULE_FORCE_HTTPS`](#rewrite-submodule-urls-to-https)
- [`GIT_DEPTH`](#shallow-cloning)（浅克隆）
- [`GIT_SUBMODULE_DEPTH`](#git-submodule-depth)
- [`GIT_CLONE_PATH`](#custom-build-directories)（自定义构建目录）
- [`TRANSFER_METER_FREQUENCY`](#artifact-and-cache-settings)（产物/缓存计量器更新频率）
- [`ARTIFACT_COMPRESSION_LEVEL`](#artifact-and-cache-settings)（产物归档器压缩级别）
- [`CACHE_COMPRESSION_LEVEL`](#artifact-and-cache-settings)（缓存归档器压缩级别）
- [`CACHE_REQUEST_TIMEOUT`](#artifact-and-cache-settings)（缓存请求超时）
- [`RUNNER_SCRIPT_TIMEOUT`](#set-script-and-after_script-timeouts)
- [`RUNNER_AFTER_SCRIPT_TIMEOUT`](#set-script-and-after_script-timeouts)
- [`AFTER_SCRIPT_IGNORE_ERRORS`](#ignore-errors-in-after_script)

您还可以使用变量来配置 Runner [尝试作业执行某些阶段的次数](#job-stages-attempts)。

使用 Kubernetes 执行器时，您可以使用变量来[覆盖 Kubernetes 请求和限制的 CPU 和内存分配](https://gitlab.cn/docs/runner/executors/kubernetes/#overwrite-container-resources)。

[Runner 功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)也可作为[作业和流水线变量](https://gitlab.cn/docs/runner/configuration/feature-flags/#enable-feature-flag-in-pipeline-configuration)接受。

<a id="git-strategy"></a>

### Git 策略

`GIT_STRATEGY` 变量配置如何准备构建目录以及如何获取代码仓库内容。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置此变量，或为每个作业设置。

```yaml
variables:
  GIT_STRATEGY: clone
```

可能的值为 `clone`、`fetch`、`none` 和 `empty`。如果您未指定值，作业将使用[项目的流水线设置](../pipelines/settings.md#choose-the-default-git-strategy)。

`clone` 是最慢的选项。它会为每个作业从头克隆代码仓库，确保本地工作副本始终是干净的。如果发现现有的工作树，则在克隆之前将其删除。

`fetch` 更快，因为它会重用本地工作副本（如果不存在，则回退到 `clone`）。`git clean` 用于撤销上一个作业所做的任何更改，`git fetch` 用于获取上一个作业运行后所做的提交。

但是，`fetch` 确实需要访问先前的工作树。在使用 `shell` 或 `docker` 执行器时，这效果很好，因为这些执行器会尝试保留工作树并默认尝试重用它们。

在使用 [Docker Machine 执行器](https://gitlab.cn/docs/runner/executors/docker_machine/)时，这有局限性。

Git 策略为 `none` 时也会重用本地工作副本，但会跳过通常由极狐GitLab 执行的所有 Git 操作。如果存在极狐GitLab Runner 预克隆脚本，也会跳过。此策略可能意味着您需要将 `fetch` 和 `checkout` 命令添加到[您的 `.gitlab-ci.yml` 脚本](../yaml/_index.md#script)中。

它可用于仅对产物进行操作的作业，例如部署作业。Git 代码仓库数据可能存在，但很可能已过时。您应仅依赖从缓存或产物带入本地工作副本的文件。请注意，先前流水线中的缓存和产物文件可能仍然存在。

与 `none` 不同，`empty` Git 策略会在下载缓存或产物文件之前删除并重新创建专用构建目录。
使用此策略时，极狐GitLab Runner hook 脚本仍会运行
（如果提供），以允许进一步自定义行为。在以下情况下使用 `empty` Git 策略：

- 您不需要代码仓库数据存在。
- 您希望每次作业运行时都有一个干净、受控或自定义的起始状态。

<a id="git-submodule-strategy"></a>

### Git 子模块策略

`GIT_SUBMODULE_STRATEGY` 变量用于控制在构建前获取代码时是否包含 [Git 子模块](https://git-scm.com/book/en/v2/Git-Tools-Submodules)以及如何包含。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它们，或为每个作业设置。

三个可能的值为 `none`、`normal` 和 `recursive`：

- `none` 表示在获取项目
  代码时不包含子模块。此设置与 1.10 之前版本中的默认行为一致。

- `normal` 表示仅包含顶层子模块。它
  等效于：

  ```shell
  git submodule sync
  git submodule update --init
  ```

- `recursive` 表示包含所有子模块（包括子模块的子模块）。
  此功能需要 Git v1.8.1 及更高版本。当使用
  非基于 Docker 的执行器的极狐GitLab Runner 时，请确保 Git 版本
  满足该要求。它等效于：

  ```shell
  git submodule sync --recursive
  git submodule update --init --recursive
  ```

要使此功能正常工作，子模块必须（在 `.gitmodules`中）配置为以下之一：

- 可公开访问的代码仓库的 HTTP(S) URL，或
- 同一极狐GitLab 服务器上另一个代码仓库的相对路径。请参阅
  [Git 子模块](git_submodules.md)文档。

您可以使用 [`GIT_SUBMODULE_UPDATE_FLAGS`](#git-submodule-update-flags) 提供其他标志来控制高级行为。

<a id="git-checkout"></a>

### Git 检出

当 `GIT_STRATEGY` 设置为 `clone` 或 `fetch` 时，可以使用 `GIT_CHECKOUT` 变量来指定是否应运行 `git checkout`。如果未指定，则默认为 true。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它们，或为每个作业设置。

如果设置为 `false`，则 Runner：

- 执行 `fetch` 时 - 更新代码仓库并将工作副本保留在
  当前修订版本上，
- 执行 `clone` 时 - 克隆代码仓库并将工作副本保留在
  默认分支上。

如果 `GIT_CHECKOUT` 设置为 `true`，则 `clone` 和 `fetch`的工作方式相同。Runner 会检出与 CI 流水线相关的修订版本的工作副本：

```yaml
variables:
  GIT_STRATEGY: clone
  GIT_CHECKOUT: "false"
script:
  - git checkout -B master origin/master
  - git merge $CI_COMMIT_SHA
```

<a id="git-clean-flags"></a>

### Git clean 标志

`GIT_CLEAN_FLAGS` 变量用于控制检出源代码后 `git clean`的默认行为。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为每个作业设置。

`GIT_CLEAN_FLAGS` 接受 [`git clean`](https://git-scm.com/docs/git-clean) 命令的所有可能选项。

如果指定了 `GIT_CHECKOUT: "false"`，则 `git clean` 会被禁用。

如果 `GIT_CLEAN_FLAGS` 为：

- 未指定，则 `git clean` 标志默认为 `-ffdx`。
- 给定值 `none`，则不执行 `git clean`。

例如：

```yaml
variables:
  GIT_CLEAN_FLAGS: -ffdx -e cache/
script:
  - ls -al cache/
```

<a id="git-fetch-extra-flags"></a>

### Git fetch 额外标志

使用 `GIT_FETCH_EXTRA_FLAGS` 变量来控制 `git fetch`的行为。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为每个作业设置。

`GIT_FETCH_EXTRA_FLAGS` 接受 [`git fetch`](https://git-scm.com/docs/git-fetch) 命令的所有选项。但是，`GIT_FETCH_EXTRA_FLAGS` 标志会追加在无法修改的默认标志之后。

默认标志为：

- [`GIT_DEPTH`](#shallow-cloning)。
- [refspecs](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec) 列表。
- 名为 `origin`的远程。

如果 `GIT_FETCH_EXTRA_FLAGS` 为：

- 未指定，则 `git fetch` 标志默认为 `--prune --quiet` 以及默认标志。
- 给定值 `none`，则仅使用默认标志执行 `git fetch`。

例如，默认标志为 `--prune --quiet`，因此您可以通过仅用 `--prune` 覆盖它来使 `git fetch` 更详细：

```yaml
variables:
  GIT_FETCH_EXTRA_FLAGS: --prune
script:
  - ls -al cache/
```

先前的配置导致 `git fetch` 以这种方式被调用：

```shell
git fetch origin $REFSPECS --depth 20  --prune
```

其中 `$REFSPECS` 是由极狐GitLab 在内部提供给 Runner 的值。

<a id="git-clone-extra-flags"></a>

### Git clone 额外标志

使用 `GIT_CLONE_EXTRA_FLAGS` 变量将额外参数传递给原生 `git clone` 操作。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为每个作业设置。

要使用 `GIT_CLONE_EXTRA_FLAGS`：

- 将 `FF_USE_GIT_NATIVE_CLONE` 设置为 `true` 以启用原生 `git clone` 功能。
- 将 `GIT_STRATEGY` 设置为 `clone` 以使用 clone 策略而不是 fetch。
- Git 客户端必须至少为 2.49 版本。如果
  [辅助程序镜像](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#helper-image)
  是 Linux 风格的镜像，版本 18.1 或更高，则自动满足此条件。

`GIT_CLONE_EXTRA_FLAGS` 接受 `git clone` 命令的所有选项。这些标志会追加到原生 `git clone` 命令中，为高级用例提供灵活性，包括引用备用代码仓库或优化克隆性能。

例如，您可以通过使用引用代码仓库来优化克隆性能：

```yaml
variables:
  FF_USE_GIT_NATIVE_CLONE: true
  GIT_STRATEGY: clone
  GIT_CLONE_EXTRA_FLAGS: "--reference-if-available /tmp/test"
```

如果未指定 `GIT_CLONE_EXTRA_FLAGS`，则 `git clone` 仅使用默认标志。

<a id="sync-or-exclude-specific-submodules-from-ci-jobs"></a>

### 从 CI 作业同步或排除特定子模块

使用 `GIT_SUBMODULE_PATHS` 变量来控制必须同步或更新哪些子模块。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为每个作业设置。

路径语法与 [`git submodule`](https://git-scm.com/docs/git-submodule#Documentation/git-submodule.txt-ltpathgt82308203) 相同：

- 要同步和更新特定路径：

  ```yaml
  variables:
     GIT_SUBMODULE_PATHS: submoduleA submoduleB
  ```

- 要排除特定路径：

  ```yaml
  variables:
     GIT_SUBMODULE_PATHS: ":(exclude)submoduleA :(exclude)submoduleB"
  ```

> [!warning]
> Git 会忽略嵌套路径。要忽略嵌套子模块，请排除
> 父级子模块，然后在作业的脚本中手动克隆它。例如，
> `git clone <repo> --recurse-submodules=':(exclude)nested-submodule'`。请确保
> 将该字符串用单引号括起来，以便 YAML 能够成功解析。

<a id="git-submodule-update-flags"></a>

### Git 子模块更新标志

当 [`GIT_SUBMODULE_STRATEGY`](#git-submodule-strategy) 设置为 `normal` 或 `recursive` 时，使用 `GIT_SUBMODULE_UPDATE_FLAGS` 变量来控制 `git submodule update`的行为。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为每个作业设置。

`GIT_SUBMODULE_UPDATE_FLAGS` 接受
[`git submodule update`](https://git-scm.com/docs/git-submodule#Documentation/git-submodule.txt-update--init--remote-N--no-fetch--no-recommend-shallow-f--force--checkout--rebase--merge--referenceltrepositorygt--depthltdepthgt--recursive--jobsltngt--no-single-branch--ltpathgt82308203)
子命令的所有选项。但是，`GIT_SUBMODULE_UPDATE_FLAGS` 标志会追加在几个默认标志之后：

- `--init`，如果 [`GIT_SUBMODULE_STRATEGY`](#git-submodule-strategy) 设置为 `normal` 或 `recursive`。
- `--recursive`，如果 [`GIT_SUBMODULE_STRATEGY`](#git-submodule-strategy) 设置为 `recursive`。
- `GIT_DEPTH`。请参阅[浅克隆](#shallow-cloning)部分中的默认值。

Git 会采用参数列表中标志的最后一次出现，因此在 `GIT_SUBMODULE_UPDATE_FLAGS`中手动提供它们会覆盖这些默认标志。

例如，您可以使用此变量来：

- 使用 `--remote` 标志获取最新的远程 `HEAD`，而不是代码仓库中
  跟踪的提交（默认），以自动更新所有子模块。
- 使用 `--jobs 4` 标志在多个并行作业中获取子模块，以加快检出速度。

```yaml
variables:
  GIT_SUBMODULE_STRATEGY: recursive
  GIT_SUBMODULE_UPDATE_FLAGS: --remote --jobs 4
script:
  - ls -al .git/modules/
```

先前的配置导致 `git submodule update` 以这种方式被调用：

```shell
git submodule update --init --depth 20 --recursive --remote --jobs 4
```

> [!warning]
> 使用 `--remote` 标志时，您应了解其对构建的安全性、稳定性和
> 可重现性的影响。在大多数情况下，
> 最好按设计显式跟踪子模块提交，并使用自动修复/依赖机器人
> 更新它们。
>
> 检出子模块的已提交修订版本不需要 `--remote` 标志。
> 仅当您希望自动将子模块更新到其最新远程版本时，才使用此标志。

`--remote`的行为取决于您的 Git 版本。如果您的超级项目 `.gitmodules` 文件中指定的分支与子模块代码仓库的默认分支不同，某些 Git 版本会失败并显示以下错误：

`fatal: Unable to find refs/remotes/origin/<branch> revision in submodule path '<submodule-path>'`

Runner 实现了一种“尽力而为”的回退机制，当子模块更新失败时会尝试拉取远程引用。

如果此回退机制不适用于您的 Git 版本，请尝试以下变通方法之一：

- 将子模块代码仓库的默认分支更新为与超级项目中
  `.gitmodules` 设置的分支匹配。
- 将 `GIT_SUBMODULE_DEPTH` 设置为 `0`。
- 单独更新子模块，并从
  `GIT_SUBMODULE_UPDATE_FLAGS`中移除 `--remote` 标志。

<a id="rewrite-submodule-urls-to-https"></a>

### 将子模块 URL 重写为 HTTPS

使用 `GIT_SUBMODULE_FORCE_HTTPS` 变量强制将所有 Git 和 SSH 子模块 URL 重写为 HTTPS。您可以克隆同一极狐GitLab 实例上使用绝对 URL 的子模块，即使它们配置为使用 Git 或 SSH 协议。

```yaml
variables:
  GIT_SUBMODULE_STRATEGY: recursive
  GIT_SUBMODULE_FORCE_HTTPS: "true"
```

启用后，极狐GitLab Runner 会使用 [CI/CD 作业令牌](../jobs/ci_job_token.md)来克隆子模块。该令牌使用执行作业的用户的权限，并且不需要 SSH 凭据。

<a id="shallow-cloning"></a>

### 浅克隆

您可以使用 `GIT_DEPTH` 指定获取和克隆的深度。`GIT_DEPTH` 会对代码仓库进行浅克隆，并且可以显著加快克隆速度。它对于具有大量提交或旧的大型二进制文件的代码仓库很有帮助。该值会传递给 `git fetch` 和 `git clone`。

新建的项目自动具有[默认 `git depth` 值 `20`](../pipelines/settings.md#limit-the-number-of-changes-fetched-during-clone)。

如果您使用深度 `1` 并且有作业队列或重试作业，作业可能会失败。

Git 获取和克隆基于引用（例如分支名称），因此 Runner 无法克隆特定的提交 SHA。如果队列中有多个作业，或者您重试旧作业，则要测试的提交必须位于克隆的 Git 历史中。为 `GIT_DEPTH` 设置太小的值可能会导致无法运行这些旧提交，并且作业日志中会显示 `unresolved reference`。然后您应考虑将 `GIT_DEPTH` 更改为更高的值。

当设置了 `GIT_DEPTH` 时，依赖 `git describe`的作业可能无法正常工作，因为只存在部分 Git 历史。

要仅获取或克隆最近 3 个提交：

```yaml
variables:
  GIT_DEPTH: "3"
```

您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为每个作业设置。

<a id="git-submodule-depth"></a>

### Git 子模块深度

当 [`GIT_SUBMODULE_STRATEGY`](#git-submodule-strategy) 设置为 `normal` 或 `recursive` 时，使用 `GIT_SUBMODULE_DEPTH` 变量指定获取和克隆子模块的深度。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它，或为特定作业设置。

当您设置 `GIT_SUBMODULE_DEPTH` 变量时，它仅会覆盖子模块的 [`GIT_DEPTH`](#shallow-cloning) 设置。

要仅获取或克隆最近 3 个提交：

```yaml
variables:
  GIT_SUBMODULE_DEPTH: 3
```

<a id="custom-build-directories"></a>

### 自定义构建目录

默认情况下，极狐GitLab Runner 会将代码仓库克隆到 `$CI_BUILDS_DIR` 目录的唯一子路径中。但是，您的项目可能要求代码位于特定目录中（例如 Go 项目）。在这种情况下，您可以指定 `GIT_CLONE_PATH` 变量来告诉 Runner 将代码仓库克隆到哪个目录：

```yaml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/project-name

test:
  script:
    - pwd
```

`GIT_CLONE_PATH` 必须始终位于 `$CI_BUILDS_DIR` 内。在 `$CI_BUILDS_DIR`中设置的目录
取决于执行器和 [runners.builds_dir](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)
设置的配置。

这只能在 [Runner 的配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runnerscustom_build_dir-section)中启用 `custom_build_dir` 时使用。

<a id="handling-concurrency"></a>

#### 处理并发

使用大于 `1`的并发的执行器可能会导致失败。如果 `builds_dir` 在作业之间共享，则多个作业可能会在同一目录中工作。

Runner 不会尝试阻止这种情况。管理员和开发者需要遵守 Runner 配置的要求。

要避免这种情况，您可以在 `$CI_BUILDS_DIR`中使用唯一路径，因为 Runner 公开了两个额外的变量，它们提供并发的唯一 `ID`：

- `$CI_CONCURRENT_ID`：在给定执行器中运行的所有作业的唯一 ID。
- `$CI_CONCURRENT_PROJECT_ID`：在给定执行器和项目中运行的所有作业的唯一 ID。

在任何场景和任何执行器上都应能良好运行的最稳定配置是在 `GIT_CLONE_PATH`中使用 `$CI_CONCURRENT_ID`。例如：

```yaml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/$CI_CONCURRENT_ID/project-name

test:
  script:
    - pwd -P
```

`$CI_CONCURRENT_PROJECT_ID` 应与 `$CI_PROJECT_PATH` 结合使用。`$CI_PROJECT_PATH` 以 `group/subgroup/project` 格式提供代码仓库的路径。例如：

```yaml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/$CI_CONCURRENT_ID/$CI_PROJECT_PATH

test:
  script:
    - pwd -P
```

<a id="nested-paths"></a>

#### 嵌套路径

`GIT_CLONE_PATH`的值只会展开一次。您不能在此值中嵌套变量。

例如，您在 `.gitlab-ci.yml` 文件中定义以下变量：

```yaml
variables:
  GOPATH: $CI_BUILDS_DIR/go
  GIT_CLONE_PATH: $GOPATH/src/namespace/project
```

`GIT_CLONE_PATH`的值会展开一次为 `$CI_BUILDS_DIR/go/src/namespace/project`，并导致失败，因为 `$CI_BUILDS_DIR` 未被展开。

<a id="ignore-errors-in-after_script"></a>

### 忽略 `after_script`中的错误

您可以在作业中使用 [`after_script`](../yaml/_index.md#after_script) 来定义一组命令，这些命令应在作业的 `before_script` 和 `script` 部分之后运行。`after_script` 命令无论脚本终止状态（失败或成功）如何都会运行。

默认情况下，极狐GitLab Runner 会忽略 `after_script` 运行时发生的任何错误。要将作业设置为在 `after_script` 运行出错时立即失败，请将 `AFTER_SCRIPT_IGNORE_ERRORS` CI/CD 变量设置为 `false`。例如：

```yaml
variables:
  AFTER_SCRIPT_IGNORE_ERRORS: false
```

<a id="job-stages-attempts"></a>

### 作业阶段尝试次数

您可以设置正在运行的作业尝试执行以下阶段的次数：

| 变量                        | 描述 |
|---------------------------------|-------------|
| `ARTIFACT_DOWNLOAD_ATTEMPTS`    | 运行作业时下载产物的尝试次数 |
| `EXECUTOR_JOB_SECTION_ATTEMPTS` | 在 [`No Such Container`](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/4450) 错误后运行作业中某个部分的尝试次数（仅限 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/)）。 |
| `GET_SOURCES_ATTEMPTS`          | 运行作业时获取源代码的尝试次数 |
| `RESTORE_CACHE_ATTEMPTS`        | 运行作业时恢复缓存的尝试次数 |

默认值为一次尝试。

示例：

```yaml
variables:
  GET_SOURCES_ATTEMPTS: 3
```

您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局设置它们，或为每个作业设置。

<a id="system-calls-not-available-on-gitlabcom-instance-runners"></a>

## JihuLab.com 实例 Runner 上不可用的系统调用

JihuLab.com 实例 Runner 在 CoreOS 上运行。这意味着您无法使用某些系统调用，例如 C 标准库中的 `getlogin`。

<a id="artifact-and-cache-settings"></a>

## 产物和缓存设置

产物和缓存设置控制产物和缓存的压缩率。使用这些设置来指定作业生成的归档文件的大小。

- 在网络较慢的情况下，较小的归档文件上传速度可能更快。
- 在带宽和存储不成问题的快速网络上，使用最快的压缩率上传速度可能更快，尽管生成的归档文件更大。

为了让 [GitLab Pages](../../user/project/pages/_index.md) 提供
[HTTP Range 请求](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Range_requests)，产物
应使用 `ARTIFACT_COMPRESSION_LEVEL: fastest` 设置，因为只有未压缩的 zip 归档文件支持此功能。

可以启用计量器来提供上传和下载的传输速率。

您可以使用 `CACHE_REQUEST_TIMEOUT` 设置来设置缓存上传和下载的最大时间。当缓慢的缓存上传大幅增加作业持续时间时，请使用此设置。

```yaml
variables:
  # output upload and download progress every 2 seconds
  TRANSFER_METER_FREQUENCY: "2s"

  # Use fast compression for artifacts, resulting in larger archives
  ARTIFACT_COMPRESSION_LEVEL: "fast"

  # Use no compression for caches
  CACHE_COMPRESSION_LEVEL: "fastest"

  # Set maximum duration of cache upload and download
  CACHE_REQUEST_TIMEOUT: 5
```

| 变量                     | 描述 |
|------------------------------|-------------|
| `TRANSFER_METER_FREQUENCY`   | 指定打印计量器传输速率的频率。可以设置为时长（例如 `1s` 或 `1m30s`）。时长为 `0` 会禁用计量器（默认）。设置值后，流水线会显示产物和缓存上传及下载的进度计量器。 |
| `ARTIFACT_COMPRESSION_LEVEL` | 要调整压缩率，请设置为 `fastest`、`fast`、`default`、`slow` 或 `slowest`。此设置仅适用于 Fastzip 归档器，因此还必须启用极狐GitLab Runner 功能标志 [`FF_USE_FASTZIP`](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。 |
| `CACHE_COMPRESSION_LEVEL`    | 要调整压缩率，请设置为 `fastest`、`fast`、`default`、`slow` 或 `slowest`。此设置仅适用于 Fastzip 归档器，因此还必须启用极狐GitLab Runner 功能标志 [`FF_USE_FASTZIP`](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。 |
| `CACHE_REQUEST_TIMEOUT`      | 以分钟为单位配置单个作业的缓存上传和下载操作的最大持续时间。默认值为 `10` 分钟。 |

<a id="tune-tcp-settings-for-high-latency-connections"></a>

### 为高延迟连接调整 TCP 设置

如果 Runner 与极狐GitLab 实例之间存在显著的网络延迟，默认的 TCP 窗口大小可能会限制吞吐量。在 Runner 主机上，增大 TCP 窗口大小以允许更多数据在途。

例如，在 Linux 上，增大最大 TCP 缓冲区大小：

```shell
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"
```

要使这些更改在重启后仍然有效，请将它们添加到 `/etc/sysctl.conf`。

> [!note]
> TCP 调优是主机级别的更改，会影响 Runner 机器上的所有网络连接。
> 请先在非生产环境中测试更改。

<a id="artifact-provenance-metadata"></a>

## 产物来源元数据

Runner 可以生成 [SLSA Provenance](https://slsa.dev/spec/v1.0/provenance)
并生成 [SLSA Statement](https://slsa.dev/spec/v1.0/attestation-model#model-and-terminology)，
将来源绑定到所有构建产物。该声明称为产物来源元数据。

要启用产物来源元数据，请将 `RUNNER_GENERATE_ARTIFACTS_METADATA` 环境变量设置为 `true`。您可以全局设置该变量，或为单个作业设置：

```yaml
variables:
  RUNNER_GENERATE_ARTIFACTS_METADATA: "true"

job1:
  variables:
    RUNNER_GENERATE_ARTIFACTS_METADATA: "true"
```

元数据会以纯文本 `.json` 文件的形式呈现，并与产物一起存储。文件名为 `{ARTIFACT_NAME}-metadata.json`。`ARTIFACT_NAME` 是 `.gitlab-ci.yml` 文件中定义的[产物名称](../jobs/job_artifacts.md#with-an-explicitly-defined-artifact-name)。如果未定义名称，则默认文件名为
`artifacts-metadata.json`。

<a id="provenance-metadata-format"></a>

### 来源元数据格式

产物来源元数据以
[in-toto v0.1 Statement](https://github.com/in-toto/attestation/tree/v0.1.0/spec#statement) 格式生成。
它包含以 [SLSA 1.0 Provenance](https://slsa.dev/spec/v1.0/provenance) 格式生成的来源谓词。

默认情况下会填充以下字段：

| 字段                                                             | 值 |
|-------------------------------------------------------------------|-------|
| `_type`                                                           | `https://in-toto.io/Statement/v0.1` |
| `subject`                                                         | 元数据适用的软件产物集合 |
| `subject[].name`                                                  | 产物的文件名。 |
| `subject[].sha256`                                                | 产物的 `sha256` 校验和。 |
| `predicateType`                                                   | `https://slsa.dev/provenance/v1` |
| `predicate.buildDefinition.buildType`                             | `https://gitlab.com/gitlab-org/gitlab-runner/-/blob/{GITLAB_RUNNER_VERSION}/PROVENANCE.md`。例如 v19.0.0 |
| `predicate.runDetails.builder.id`                                 | 指向 Runner 详情页面的 URI，例如 `https://gitlab.com/gitlab-com/www-gitlab-com/-/runners/3785264`。 |
| `predicate.buildDefinition.externalParameters`                    | 构建命令执行期间可用的任何 CI/CD 或环境变量的名称。该值始终表示为空字符串以保护密钥。 |
| `predicate.buildDefinition.externalParameters.source`             | 项目的 URL。 |
| `predicate.buildDefinition.externalParameters.entryPoint`         | 触发构建的 CI/CD 作业的名称。 |
| `predicate.buildDefinition.internalParameters.name`               | Runner 的名称。 |
| `predicate.buildDefinition.internalParameters.executor`           | Runner 执行器。 |
| `predicate.buildDefinition.internalParameters.architecture`       | 运行 CI/CD 作业所基于的架构。 |
| `predicate.buildDefinition.internalParameters.job`                | 触发构建的 CI/CD 作业的 ID。 |
| `predicate.buildDefinition.resolvedDependencies[0].uri`           | 项目的 URL。 |
| `predicate.buildDefinition.resolvedDependencies[0].digest.sha256` | 项目的提交修订版本。 |
| `predicate.runDetails.metadata.invocationId`                      | 触发构建的 CI/CD 作业的 ID。 |
| `predicate.runDetails.metadata.startedOn`                         | 构建开始的时间。此字段采用 `RFC3339` 格式。 |
| `predicate.runDetails.metadata.finishedOn`                        | 构建结束的时间。由于元数据生成发生在构建期间，此时间略早于极狐GitLab 中报告的时间。此字段采用 `RFC3339` 格式。 |

来源声明应类似于以下示例：

```json
{
 "_type": "https://in-toto.io/Statement/v0.1",
 "predicateType": "https://slsa.dev/provenance/v1",
 "subject": [
  {
   "name": "x.txt",
   "digest": {
    "sha256": "ac097997b6ec7de591d4f11315e4aa112e515bb5d3c52160d0c571298196ea8b"
   }
  },
  {
   "name": "y.txt",
   "digest": {
    "sha256": "9eb634f80da849d828fcf42740d823568c49e8d7b532886134f9086246b1fdf3"
   }
  }
 ],
 "predicate": {
  "buildDefinition": {
   "buildType": "https://gitlab.com/gitlab-org/gitlab-runner/-/blob/2147fb44/PROVENANCE.md",
   "externalParameters": {
    "CI": "",
    "CI_API_GRAPHQL_URL": "",
    "CI_API_V4_URL": "",
    "CI_COMMIT_AUTHOR": "",
    "CI_COMMIT_BEFORE_SHA": "",
    "CI_COMMIT_BRANCH": "",
    "CI_COMMIT_DESCRIPTION": "",
    "CI_COMMIT_MESSAGE": "",
    [... additional environmental variables ...]
    "entryPoint": "build-job",
    "source": "https://gitlab.com/my-group/my-project/test-runner-generated-slsa-statement"
   },
   "internalParameters": {
    "architecture": "amd64",
    "executor": "docker+machine",
    "job": "10340684631",
    "name": "green-4.saas-linux-small-amd64.runners-manager.gitlab.com/default"
   },
   "resolvedDependencies": [
    {
     "uri": "https://gitlab.com/my-group/my-project/test-runner-generated-slsa-statement",
     "digest": {
      "sha256": "bdd2ecda9ef57b129c88617a0215afc9fb223521"
     }
    }
   ]
  },
  "runDetails": {
   "builder": {
    "id": "https://gitlab.com/my-group/my-project/test-runner-generated-slsa-statement/-/runners/12270857",
    "version": {
     "gitlab-runner": "2147fb44"
    }
   },
   "metadata": {
    "invocationId": "10340684631",
    "startedOn": "2025-06-13T07:25:13Z",
    "finishedOn": "2025-06-13T07:25:40Z"
   }
  }
 }
}
```

<a id="staging-directory"></a>

## 暂存目录

如果您不想在系统的默认临时目录中归档缓存和产物，可以指定其他目录。

如果系统的默认临时路径存在限制，您可能需要更改该目录。如果您为该目录位置使用快速磁盘，还可以提高性能。

要更改目录，请在 CI 作业中将 `ARCHIVER_STAGING_DIR` 设置为变量，或在注册 Runner 时使用 Runner 变量（`gitlab register --env ARCHIVER_STAGING_DIR=<dir>`）。

您指定的目录用作解压前下载产物的位置。如果使用 `fastzip` 归档器，此位置也用作归档时的暂存空间。

<a id="configure-fastzip-to-improve-performance"></a>

## 配置 `fastzip` 以提高性能

要调优 `fastzip`，请确保启用 [`FF_USE_FASTZIP`](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags) 标志。然后使用以下任一环境变量。

| 变量                        | 描述 |
|---------------------------------|-------------|
| `FASTZIP_ARCHIVER_CONCURRENCY`  | 并发压缩的文件数。默认值为可用的 CPU 数。 |
| `FASTZIP_ARCHIVER_BUFFER_SIZE`  | 为每个文件的每个并发分配的缓冲区大小。超过此数量的数据会移到暂存空间。默认值为 2 MiB。 |
| `FASTZIP_EXTRACTOR_CONCURRENCY` | 并发解压的文件数。默认值为可用的 CPU 数。 |

zip 归档文件中的文件是按顺序追加的。这使得并发压缩具有挑战性。`fastzip` 通过先将文件并发压缩到磁盘，然后按顺序将结果复制回 zip 归档文件，来变通解决此限制。

为避免对较小文件进行磁盘写入和读回内容，每个并发使用一个小缓冲区。此设置可以通过 `FASTZIP_ARCHIVER_BUFFER_SIZE` 控制。此缓冲区的默认大小为 2 MiB，因此，并发为 16 时会分配 32 MiB。超过缓冲区大小的数据会写入磁盘并从磁盘读回。因此，不使用缓冲区（`FASTZIP_ARCHIVER_BUFFER_SIZE: 0`）而仅使用暂存空间是一个有效选项。

`FASTZIP_ARCHIVER_CONCURRENCY` 控制并发压缩多少个文件。如前所述，此设置因此可能会增加内存使用量。它还可能会增加写入暂存空间的临时数据。默认值为可用的 CPU 数，但考虑到内存影响，这可能并不总是最佳设置。

`FASTZIP_EXTRACTOR_CONCURRENCY` 控制一次解压多少个文件。zip 归档文件中的文件可以原生并发读取，因此除了解压器所需的内存外，不会分配额外内存。此默认值为可用的 CPU 数。
