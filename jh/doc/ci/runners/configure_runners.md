---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 设置超时、保护敏感信息、通过标签和变量控制行为，并配置极狐GitLab Runner 的产物和缓存设置。
title: 配置 runners
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档介绍了如何在极狐GitLab UI 中配置 runners。

如果您需要在安装了极狐GitLab Runner 的机器上配置 runners，请参见
[极狐GitLab Runner 文档](https://gitlab.cn/docs/runner/configuration/)。

<a id="set-the-maximum-job-timeout"></a>

## 设置最大作业超时

您可以为每个 runner 指定最大作业超时，以防止具有更长作业超时的项目使用该 runner。如果该超时值小于项目中定义的作业超时，则会使用最大作业超时。

要设置 runner 的最大超时，请在 REST API 端点 [`PUT /runners/:id`](../../api/runners.md#update-runners-details) 中设置 `maximum_timeout` 参数。

<a id="for-an-instance-runner"></a>

### 对于实例 runner

先决条件：

- 您必须是管理员。

您可以在私有化部署的极狐GitLab 上覆盖实例 runner 的作业超时。

在 JihuLab.com 上，您无法覆盖极狐GitLab 托管的实例 runner 的作业超时，必须改用[项目定义的超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)。

要设置最大作业超时：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在您要编辑的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 在 **最大作业超时** 字段中，输入一个以秒为单位的值。最小值为 600 秒（10 分钟）。
1. 选择 **保存更改**。

<a id="for-a-group-runner"></a>

### 对于群组 runner

先决条件：

- 您必须对群组具有所有者角色。

要设置最大作业超时：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在您要编辑的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 在 **最大作业超时** 字段中，输入一个以秒为单位的值。最小值为 600 秒（10 分钟）。
1. 选择 **保存更改**。

<a id="for-a-project-runner"></a>

### 对于项目 runner

先决条件：

- 您必须对项目具有所有者角色。

要设置最大作业超时：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在您要编辑的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 在 **最大作业超时** 字段中，输入一个以秒为单位的值。最小值为 600 秒（10 分钟）。如果未定义，则将改用[项目的作业超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)。
1. 选择 **保存更改**。

<a id="how-maximum-job-timeout-works"></a>

## 最大作业超时如何工作

**示例 1 - Runner 超时大于项目超时**

1. 您将 runner 的 `maximum_timeout` 参数设置为 24 小时。
1. 您将项目的 **最大作业超时** 设置为 **2 小时**。
1. 您启动作业。
1. 如果作业运行时间更长，则会在 **2 小时** 后超时。

**示例 2 - 未配置 Runner 超时**

1. 您从 runner 中移除了 `maximum_timeout` 参数配置。
1. 您将项目的 **最大作业超时** 设置为 **2 小时**。
1. 您启动作业。
1. 如果作业运行时间更长，则会在 **2 小时** 后超时。

**示例 3 - Runner 超时小于项目超时**

1. 您将 runner 的 `maximum_timeout` 参数设置为 **30 分钟**。
1. 您将项目的 **最大作业超时** 设置为 2 小时。
1. 您启动作业。
1. 如果作业运行时间更长，则会在 **30 分钟** 后超时。

<a id="set-script-and-after_script-timeouts"></a>

## 设置 `script` 和 `after_script` 超时

{{< history >}}

- 在 GitLab Runner 16.4 [引入]。

{{< /history >}}

要控制 `script` 和 `after_script` 在终止前运行的时间，请在 `.gitlab-ci.yml` 文件中指定超时值。

例如，您可以指定超时以提前终止长时间运行的 `script`。这确保了在超过[作业超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)之前，仍能上传产物和缓存。
`script` 和 `after_script` 的超时值必须小于作业超时。

- 要为 `script` 设置超时，请使用作业变量 `RUNNER_SCRIPT_TIMEOUT`。
- 要为 `after_script` 设置超时并覆盖默认的 5 分钟，请使用作业变量 `RUNNER_AFTER_SCRIPT_TIMEOUT`。

这两个变量都接受 [Go 的持续时间格式](https://pkg.go.dev/time#ParseDuration)（例如，`40s`、`1h20m`、`2h`、`4h30m30s`）。

例如：

```yaml
job-with-script-timeouts:
  variables:
    RUNNER_SCRIPT_TIMEOUT: 15m
    RUNNER_AFTER_SCRIPT_TIMEOUT: 10m
  script:
    - "我允许在 min(15m, 剩余作业超时) 内运行。"
  after_script:
    - "我允许在 min(10m, 剩余作业超时) 内运行。"

job-artifact-upload-on-timeout:
  timeout: 1h                           # 将作业超时设置为 1 小时
  variables:
     RUNNER_SCRIPT_TIMEOUT: 50m         # 仅允许 script 运行 50 分钟
  script:
    - long-running-process > output.txt # 将在 50 分钟后终止

  artifacts: # 产物将有大约 10 分钟上传时间
    paths:
      - output.txt
    when: on_failure # on_failure 是因为超时导致的脚本终止被视为失败
```

<a id="ensuring-after_script-execution"></a>

### 确保 `after_script` 执行

要确保 `after_script` 成功运行，`RUNNER_SCRIPT_TIMEOUT` + `RUNNER_AFTER_SCRIPT_TIMEOUT` 的总和不得超过作业配置的超时。

以下示例展示了如何配置超时，以确保即使主脚本超时，`after_script` 也能运行：

```yaml
job-with-script-timeouts:
  timeout: 5m
  variables:
    RUNNER_SCRIPT_TIMEOUT: 1m
    RUNNER_AFTER_SCRIPT_TIMEOUT: 1m
  script:
    - echo "开始构建..."
    - sleep 120 # 等待 2 分钟触发超时。由于 RUNNER_SCRIPT_TIMEOUT，脚本在 1 分钟后中止。
    - echo "构建完成。"
  after_script:
    - echo "开始清理..."
    - sleep 15 # 仅等待几秒钟。由于在 RUNNER_AFTER_SCRIPT_TIMEOUT 内，成功运行。
    - echo "清理完成。"
```

`script` 被 `RUNNER_SCRIPT_TIMEOUT` 取消，但 `after_script` 成功运行，因为它花费了 15 秒，小于 `RUNNER_AFTER_SCRIPT_TIMEOUT` 和作业的 `timeout` 值。

<a id="protecting-sensitive-information"></a>

## 保护敏感信息

使用实例 runner 时，安全风险更大，因为它们在极狐GitLab 实例中默认对所有群组和项目可用。
runner 执行器和文件系统配置会影响安全性。能够访问 runner 主机环境的用户可以查看 runner 执行的代码和 runner 认证信息。
例如，有权访问 runner 认证令牌的用户可以克隆 runner，并在矢量攻击中提交虚假作业。有关更多信息，请参见[安全注意事项](https://gitlab.cn/docs/runner/security/)。

<a id="configuring-long-polling"></a>

## 配置长轮询

要减少作业排队时间和对极狐GitLab 服务器的负载，请配置[长轮询](long_polling.md)。

<a id="using-instance-runners-in-forked-projects"></a>

## 在派生项目中使用实例 runner

当项目被派生时，与作业相关的设置会被复制。如果您为项目配置了实例 runner，并且用户派生了该项目，那么实例 runner 将为该项目的作业提供服务。

由于一个已知问题，如果派生项目的 runner 设置与新项目命名空间不匹配，则会显示以下消息：
`An error occurred while forking the project. Please try again.`。

要变通解决此问题，请确保派生项目和新命名空间中的实例 runner 设置一致。

- 如果实例 runner 在派生项目中为 **启用** 状态，那么在新命名空间中也应为 **启用** 状态。
- 如果实例 runner 在派生项目中为 **禁用** 状态，那么在新命名空间中也应为 **禁用** 状态。

<a id="reset-the-runner-registration-token-for-a-project-deprecated"></a>

## 重置项目的 runner 注册令牌（已弃用）

> [!warning]
> 传递 runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不推荐使用。
> 请使用 [runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 来生成用于注册 runner 的认证令牌。此流程提供了 runner 所有权的完全可追溯性，并增强了您的 runner 集群的安全性。
> 有关更多信息，请参见
> [迁移到新的 runner 注册工作流](new_creation_workflow.md)。

如果您认为项目的注册令牌已泄露，您应该重置它。注册令牌可用于为该项目注册另一个 runner。然后，该新 runner 可能被用于获取密钥变量值或克隆项目代码。

要重置注册令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在 **新建项目 runner** 右侧，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **重置注册令牌**。
1. 选择 **重置令牌**。

重置注册令牌后，它将不再有效，并且不再向项目注册任何新的 runner。您还应更新用于供应和注册新值的工具中的注册令牌。

<a id="authentication-token-security"></a>

## 认证令牌安全性

{{< history >}}

- 在 GitLab 15.3 [引入]，伴随一个名为 `enforce_runner_token_expires_at` 的功能标志，默认为禁用。
- 在 GitLab 15.5 [GA]。功能标志 `enforce_runner_token_expires_at` 已移除。

{{< /history >}}

每个 runner 都使用 [runner 认证令牌](../../api/runners.md#registration-and-authentication-tokens) 连接到极狐GitLab 实例并进行身份验证。

为了帮助防止令牌泄露，您可以让令牌按指定间隔自动轮换。轮换令牌时，无论 runner 的状态（`online` 还是 `offline`），每个 runner 的令牌都会更新。

无需手动干预，且不应影响正在运行的作业。
有关令牌轮换的更多信息，请参见
[轮换时 runner 认证令牌未更新](new_creation_workflow.md#runner-authentication-token-does-not-update-when-rotated)。

如果您需要手动更新 runner 认证令牌，可以运行命令来[重置令牌](https://gitlab.cn/docs/runner/commands/#gitlab-runner-reset-token)。

<a id="reset-the-runner-configuration-authentication-token"></a>

### 重置 runner 配置认证令牌

如果 runner 的认证令牌泄露，攻击者可能利用它来[克隆 runner](https://gitlab.cn/docs/runner/security/#cloning-a-runner)。

要重置 runner 配置认证令牌：

1. 删除 runner：
   - [删除一个实例 runner](runners_scope.md#delete-instance-runners)。
   - [删除一个群组 runner](runners_scope.md#delete-a-group-runner)。
   - [删除一个项目 runner](runners_scope.md#delete-a-project-runner)。
1. 创建一个新的 runner，使其获得新的 runner 认证令牌：
   - [创建一个实例 runner 并附带 runner 认证令牌](runners_scope.md#create-an-instance-runner-with-a-runner-authentication-token)。
   - [创建一个群组 runner 并附带 runner 认证令牌](runners_scope.md#create-a-group-runner-with-a-runner-authentication-token)。
   - [创建一个项目 runner 并附带 runner 认证令牌](runners_scope.md#create-a-project-runner-with-a-runner-authentication-token)。
1. 可选。要验证之前的 runner 认证令牌是否已被吊销，请使用 [Runners API](../../api/runners.md#verify-authentication-for-a-registered-runner)。

您也可以使用 [Runners API](../../api/runners.md) 来重置 runner 配置认证令牌。

<a id="automatically-rotate-runner-authentication-tokens"></a>

### 自动轮换 runner 认证令牌

您可以指定轮换 runner 认证令牌的时间间隔。
定期轮换 runner 认证令牌有助于最大限度地降低通过泄露令牌对极狐GitLab 实例进行未经授权访问的风险。

先决条件：

- Runner 必须使用 [GitLab Runner 15.3 或更高版本](https://gitlab.cn/docs/runner/#gitlab-runner-versions)。
- 您必须是管理员。

要自动轮换 runner 认证令牌：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成与部署**。
1. 为 runner 设置一个 **Runners 过期** 时间，留空表示永不过期。
1. 选择 **保存更改**。

在间隔到期之前，runner 会自动请求一个新的 runner 认证令牌。
有关令牌轮换的更多信息，请参见
[轮换时 runner 认证令牌未更新](new_creation_workflow.md#runner-authentication-token-does-not-update-when-rotated)。

<a id="prevent-runners-from-revealing-sensitive-information"></a>

## 阻止 runner 泄露敏感信息

为确保 runner 不泄露敏感信息，您可以将其配置为仅对[受保护的分支](../../user/project/repository/branches/protected.md)上的作业，或具有[受保护的标签](../../user/project/protected_tags.md)的作业运行。

配置为在受保护的分支上运行作业的 runner 可以[有选择地在合并请求流水线中运行作业](../pipelines/merge_request_pipelines.md#control-access-to-protected-variables-and-runners)。

<a id="for-an-instance-runner-1"></a>

### 对于实例 runner

先决条件：

- 您必须是管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在您要保护的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 选中 **受保护** 复选框。
1. 选择 **保存更改**。

<a id="for-a-group-runner-1"></a>

### 对于群组 runner

先决条件：

- 您必须对群组具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在您要保护的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 选中 **受保护** 复选框。
1. 选择 **保存更改**。

<a id="for-a-project-runner-1"></a>

### 对于项目 runner

先决条件：

- 您必须对项目具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在您要保护的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 选中 **受保护** 复选框。
1. 选择 **保存更改**。

<a id="control-jobs-that-a-runner-can-run"></a>

## 控制 runner 可以运行的作业

您可以使用[标签](../yaml/_index.md#tags)来控制 runner 可以运行的作业。
例如，您可以为具有运行 Rails 测试套件所需依赖项的 runner 指定 `rails` 标签。

极狐GitLab CI/CD 标签与 Git 标签不同。极狐GitLab CI/CD 标签与 runner 关联。
Git 标签与提交关联。

<a id="for-an-instance-runner-2"></a>

### 对于实例 runner

先决条件：

- 您必须是管理员。

要控制实例 runner 可以运行的作业：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在您要编辑的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 将 runner 设置为运行带有标签或不带标签的作业：
   - 要运行带有标签的作业，请在 **标签** 字段中输入以逗号分隔的作业标签。例如，`macos`、`rails`。
   - 要运行不带标签的作业，请选中 **运行未带标签的作业** 复选框。
1. 选择 **保存更改**。

<a id="for-a-group-runner-2"></a>

### 对于群组 runner

先决条件：

- 您必须对群组具有所有者角色。

要控制群组 runner 可以运行的作业：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在您要编辑的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 将 runner 设置为运行带有标签或不带标签的作业：
   - 要运行带有标签的作业，请在 **标签** 字段中输入以逗号分隔的作业标签。例如，`macos`、`ruby`。
   - 要运行不带标签的作业，请选中 **运行未带标签的作业** 复选框。
1. 选择 **保存更改**。

<a id="for-a-project-runner-2"></a>

### 对于项目 runner

先决条件：

- 您必须对项目具有所有者角色。

要控制项目 runner 可以运行的作业：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在您要编辑的 runner 右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 将 runner 设置为运行带有标签或不带标签的作业：
   - 要运行带有标签的作业，请在 **标签** 字段中输入以逗号分隔的作业标签。例如，`macos`、`ruby`。
   - 要运行不带标签的作业，请选中 **运行未带标签的作业** 复选框。
1. 选择 **保存更改**。

<a id="how-the-runner-uses-tags"></a>

### Runner 如何使用标签

<a id="runner-runs-only-tagged-jobs"></a>

#### Runner 仅运行带标签的作业

以下示例说明了将 runner 设置为仅运行带标签的作业可能产生的影响。

示例 1：

1. Runner 配置为仅运行带标签的作业，并具有 `docker` 标签。
1. 一个带有 `hello` 标签的作业被执行并停滞。

示例 2：

1. Runner 配置为仅运行带标签的作业，并具有 `docker` 标签。
1. 一个带有 `docker` 标签的作业被执行并运行。

示例 3：

1. Runner 配置为仅运行带标签的作业，并具有 `docker` 标签。
1. 一个未定义标签的作业被执行并停滞。

<a id="runner-is-allowed-to-run-untagged-jobs"></a>

#### Runner 被允许运行不带标签的作业

以下示例说明了将 runner 设置为运行带标签和不带标签的作业可能产生的影响。

示例 1：

1. Runner 配置为运行不带标签的作业，并具有 `docker` 标签。
1. 一个未定义标签的作业被执行并运行。
1. 第二个定义有 `docker` 标签的作业被执行并运行。

示例 2：

1. Runner 配置为运行不带标签的作业，且未定义任何标签。
1. 一个未定义标签的作业被执行并运行。
1. 第二个定义有 `docker` 标签的作业停滞。

<a id="a-runner-and-a-job-have-multiple-tags"></a>

#### Runner 和作业具有多个标签

匹配作业和 runner 的选择逻辑基于作业中定义的 `tags` 列表。

以下示例说明了 runner 和作业具有多个标签的影响。要使 runner 被选中来运行作业，它必须具有作业脚本块中定义的所有标签。

示例 1：

1. Runner 配置有标签 `[docker, shell, gpu]`。
1. 作业具有标签 `[docker, shell, gpu]`，被执行并运行。

示例 2：

1. Runner 配置有标签 `[docker, shell, gpu]`。
1. 作业具有标签 `[docker, shell]`，被执行并运行。

示例 3：

1. Runner 配置有标签 `[docker, shell]`。
1. 作业具有标签 `[docker, shell, gpu]`，不被执行。

<a id="use-tags-to-run-jobs-on-different-platforms"></a>

### 使用标签在不同平台上运行作业

您可以使用标签在不同的平台上运行不同的作业。例如，如果您有一个带有 `osx` 标签的 OS X runner 和一个带有 `windows` 标签的 Windows runner，则可以在每个平台上运行作业。

更新 `.gitlab-ci.yml` 中的 `tags` 字段：

```yaml
windows job:
  stage: build
  tags:
    - windows
  script:
    - echo 你好, %USERNAME%!

osx job:
  stage: build
  tags:
    - osx
  script:
    - echo "你好, $USER!"
```

<a id="use-cicd-variables-in-tags"></a>

### 在标签中使用 CI/CD 变量

在 `.gitlab-ci.yml` 文件中，使用带有 `tags` 的 [CI/CD 变量](../variables/_index.md) 来实现动态 runner 选择：

```yaml
variables:
  KUBERNETES_RUNNER: kubernetes

  job:
    tags:
      - docker
      - $KUBERNETES_RUNNER
    script:
      - echo "你好 runner 选择器功能"
```

<a id="configure-runner-behavior-with-variables"></a>

## 使用变量配置 runner 行为

您可以使用 [CI/CD 变量](../variables/_index.md) 全局或针对单个作业配置 runner 的 Git 行为：

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
- [`TRANSFER_METER_FREQUENCY`](#artifact-and-cache-settings)（产物/缓存计量更新频率）
- [`ARTIFACT_COMPRESSION_LEVEL`](#artifact-and-cache-settings)（产物归档器压缩级别）
- [`CACHE_COMPRESSION_LEVEL`](#artifact-and-cache-settings)（缓存归档器压缩级别）
- [`CACHE_REQUEST_TIMEOUT`](#artifact-and-cache-settings)（缓存请求超时）
- [`RUNNER_SCRIPT_TIMEOUT`](#set-script-and-after_script-timeouts)
- [`RUNNER_AFTER_SCRIPT_TIMEOUT`](#set-script-and-after_script-timeouts)
- [`AFTER_SCRIPT_IGNORE_ERRORS`](#ignore-errors-in-after_script)

您也可以使用变量来配置 runner [尝试作业执行的某些阶段的次数](#job-stages-attempts)。

使用 Kubernetes executor 时，您可以使用变量[覆盖 Kubernetes 的 CPU 和内存分配请求和限制](https://gitlab.cn/docs/runner/executors/kubernetes/#overwrite-container-resources)。

[Runner 功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags) 也可以作为[作业和流水线变量](https://gitlab.cn/docs/runner/configuration/feature-flags/#enable-feature-flag-in-pipeline-configuration) 接受。

<a id="git-strategy"></a>

### Git 策略

`GIT_STRATEGY` 变量配置如何准备构建目录以及获取代码仓内容。您可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或为每个作业设置此变量。

```yaml
variables:
  GIT_STRATEGY: clone
```

可能的值为 `clone`、`fetch`、`none` 和 `empty`。如果您未指定值，作业将使用[项目的流水线设置](../pipelines/settings.md#choose-the-default-git-strategy)。

`clone` 是最慢的选项。它为每个作业从头开始克隆代码仓，确保本地工作副本始终是原始的。
如果找到现有的工作树，则会在克隆前将其删除。

`fetch` 更快，因为它重用本地工作副本（如果不存在则回退到 `clone`）。`git clean` 用于撤消上一个作业所做的任何更改，`git fetch` 用于检索在上一个作业运行之后所做的提交。

但是，`fetch` 确实需要访问前一个工作树。这在使用 `shell` 或 `docker` executor 时效果很好，因为它们会尝试保留工作树并默认尝试重用它们。

在使用 [Docker Machine executor](https://gitlab.cn/docs/runner/executors/docker_machine/) 时，这有局限性。

策略为 `none` 的 Git 也重用本地工作副本，但跳过通常由极狐GitLab 完成的所有 Git 操作。极狐GitLab Runner 的预克隆脚本（如果存在）也会跳过。此策略可能意味着您需要将 `fetch` 和 `checkout` 命令添加到[您的 `.gitlab-ci.yml` 脚本](../yaml/_index.md#script)中。

它可用于专门处理产物的作业，例如部署作业。Git 代码仓数据可能存在，但很可能已过时。您应仅依赖从缓存或产物中引入本地工作副本的文件。请注意，来自先前流水线的缓存和产物文件可能仍然存在。

与 `none` 不同，`empty` Git 策略会删除然后重新创建专门的构建目录，然后再下载缓存或产物文件。
使用此策略时，极狐GitLab Runner 钩子脚本仍然会运行（如果提供），以允许进一步自定义行为。
在以下情况下使用 `empty` Git 策略：

- 您不需要代码仓数据存在。
- 您希望在每次作业运行时都有一个干净、受控或自定义的起始状态。

<a id="git-submodule-strategy"></a>

### Git 子模块策略

`GIT_SUBMODULE_STRATEGY` 变量用于控制在构建前获取代码时是否以及如何包含 [Git 子模块](https://git-scm.com/book/en/v2/Git-Tools-Submodules)。您可以在 [`variables`](../yaml/_index.md#variables) 部分全局或按作业设置它们。

可能的三个值为 `none`、`normal` 和 `recursive`：

- `none` 表示在获取项目代码时不包含子模块。此设置与 1.10 之前版本的默认行为一致。

- `normal` 表示仅包含顶级子模块。相当于：

  ```shell
  git submodule sync
  git submodule update --init
  ```
 - `recursive` 意味着所有子模块（包括子模块的子模块）均会被包含。该功能需要 Git v1.8.1 及以上版本。当使用不基于 Docker 的执行器运行极狐GitLab Runner 时，请确保 Git 版本满足该要求。其等效于：

  ```shell
  git submodule sync --recursive
  git submodule update --init --recursive
  ```

为使该功能正常工作，子模块需要在 `.gitmodules` 文件中配置为以下两种情况之一：

- 一个可公开访问的仓库的 HTTP(S) URL，或者
- 指向同一极狐GitLab 服务器上另一个仓库的相对路径。参见 [Git 子模块](git_submodules.md) 文档。

你可以通过 [`GIT_SUBMODULE_UPDATE_FLAGS`](#git-submodule-update-flags) 提供额外标志来控制高级行为。

### Git 检出

当将 `GIT_STRATEGY` 设置为 `clone` 或 `fetch` 时，`GIT_CHECKOUT` 变量可用于指定是否需要执行 `git checkout`。如果未指定，其默认值为 `true`。你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

如果设置为 `false`，runner 的行为如下：

- 执行 `fetch` 时 - 更新仓库并在当前修订版本上保留工作副本，
- 执行 `clone` 时 - 克隆仓库并在默认分支上保留工作副本。

如果 `GIT_CHECKOUT` 设置为 `true`，`clone` 和 `fetch` 的行为相同。Runner 会检出与 CI 流水线相关的修订版本的工作副本：

```yaml
variables:
  GIT_STRATEGY: clone
  GIT_CHECKOUT: "false"
script:
  - git checkout -B master origin/master
  - git merge $CI_COMMIT_SHA
```

### Git 清理标志

`GIT_CLEAN_FLAGS` 变量用于控制在检出源代码后 `git clean` 的默认行为。你可以在 [`variables`](../yaml/_index.md#variables) 部分全局或按作业进行设置。

`GIT_CLEAN_FLAGS` 接受 [`git clean`](https://git-scm.com/docs/git-clean) 命令的所有可用选项。

如果指定了 `GIT_CHECKOUT: "false"`，则 `git clean` 会被禁用。

如果 `GIT_CLEAN_FLAGS` 处于以下状态：

- 未指定，`git clean` 标志默认为 `-ffdx`。
- 给定值 `none`，则不会执行 `git clean`。

例如：

```yaml
variables:
  GIT_CLEAN_FLAGS: -ffdx -e cache/
script:
  - ls -al cache/
```

### Git 获取额外标志

使用 `GIT_FETCH_EXTRA_FLAGS` 变量来控制 `git fetch` 的行为。你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

`GIT_FETCH_EXTRA_FLAGS` 接受 [`git fetch`](https://git-scm.com/docs/git-fetch) 命令的所有选项。但是，`GIT_FETCH_EXTRA_FLAGS` 标志会追加在不可修改的默认标志之后。

默认标志包括：

- [`GIT_DEPTH`](#浅克隆)。
- [refspecs](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec) 列表。
- 一个名为 `origin` 的远程仓库。

如果 `GIT_FETCH_EXTRA_FLAGS` 处于以下状态：

- 未指定，`git fetch` 标志默认为 `--prune --quiet` 以及默认标志。
- 给定值 `none`，则仅使用默认标志执行 `git fetch`。

例如，默认标志为 `--prune --quiet`，因此你可以通过仅设置 `--prune` 来覆盖默认值，使 `git fetch` 输出更详细的信息：

```yaml
variables:
  GIT_FETCH_EXTRA_FLAGS: --prune
script:
  - ls -al cache/
```

上述配置将导致 `git fetch` 以下列方式调用：

```shell
git fetch origin $REFSPECS --depth 20  --prune
```

其中 `$REFSPECS` 是由极狐GitLab 内部提供给 runner 的值。

### Git 克隆额外标志

使用 `GIT_CLONE_EXTRA_FLAGS` 变量向原生的 `git clone` 操作传递额外参数。你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

要使用 `GIT_CLONE_EXTRA_FLAGS`：

- 将 `FF_USE_GIT_NATIVE_CLONE` 设置为 `true` 以启用原生的 `git clone` 功能。
- 将 `GIT_STRATEGY` 设置为 `clone` 以使用克隆策略而非 fetch 策略。
- Git 客户端版本必须至少为 2.49。如果 [helper image](https://docs.gitlab.com/runner/configuration/advanced-configuration/#helper-image) 是 Linux 风格的镜像且版本为 18.1 或更高，则自动满足该条件。

`GIT_CLONE_EXTRA_FLAGS` 接受 `git clone` 命令的所有选项。标志会追加到原生 `git clone` 命令之后，以支持高级场景，包括引用备用仓库或优化克隆性能。

例如，你可以通过使用引用仓库来优化克隆性能：

```yaml
variables:
  FF_USE_GIT_NATIVE_CLONE: true
  GIT_STRATEGY: clone
  GIT_CLONE_EXTRA_FLAGS: "--reference-if-available /tmp/test"
```

如果未指定 `GIT_CLONE_EXTRA_FLAGS`，则 `git clone` 仅使用默认标志。

### 在 CI 作业中同步或排除特定子模块

使用 `GIT_SUBMODULE_PATHS` 变量来控制需要同步或更新哪些子模块。你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

路径语法与 [`git submodule`](https://git-scm.com/docs/git-submodule#Documentation/git-submodule.txt-ltpathgt82308203) 相同：

- 同步和更新特定路径：

  ```yaml
  variables:
     GIT_SUBMODULE_PATHS: submoduleA submoduleB
  ```

- 排除特定路径：

  ```yaml
  variables:
     GIT_SUBMODULE_PATHS: ":(exclude)submoduleA :(exclude)submoduleB"
  ```

> [!warning]
> Git 会忽略嵌套路径。要忽略嵌套的子模块，请排除父模块，然后在作业脚本中手动克隆。例如，`git clone <repo> --recurse-submodules=':(exclude)nested-submodule'`。请确保使用单引号将字符串括起来，以便 YAML 能被成功解析。

### Git 子模块更新标志

当 [`GIT_SUBMODULE_STRATEGY`](#git-子模块策略) 设置为 `normal` 或 `recursive` 时，使用 `GIT_SUBMODULE_UPDATE_FLAGS` 变量来控制 `git submodule update` 的行为。你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

`GIT_SUBMODULE_UPDATE_FLAGS` 接受 [`git submodule update`](https://git-scm.com/docs/git-submodule#Documentation/git-submodule.txt-update--init--remote-N--no-fetch--no-recommend-shallow-f--force--checkout--rebase--merge--referenceltrepositorygt--depthltdepthgt--recursive--jobsltngt--no-single-branch--ltpathgt82308203) 子命令的所有选项。但是，`GIT_SUBMODULE_UPDATE_FLAGS` 标志会追加在一些默认标志之后：

- `--init`，如果 [`GIT_SUBMODULE_STRATEGY`](#git-子模块策略) 设置为 `normal` 或 `recursive`。
- `--recursive`，如果 [`GIT_SUBMODULE_STRATEGY`](#git-子模块策略) 设置为 `recursive`。
- `GIT_DEPTH`。请参见 [浅克隆](#浅克隆) 部分的默认值。

Git 会采用参数列表中最后出现的标志，因此在 `GIT_SUBMODULE_UPDATE_FLAGS` 中手动提供这些标志会覆盖这些默认标志。

例如，你可以使用此变量来：

- 通过 `--remote` 标志获取远程最新 `HEAD`，而不是仓库中跟踪的提交（默认行为），从而自动将所有子模块更新到远程最新版本。
- 通过 `--jobs 4` 标志并行获取多个子模块以加速检出。

```yaml
variables:
  GIT_SUBMODULE_STRATEGY: recursive
  GIT_SUBMODULE_UPDATE_FLAGS: --remote --jobs 4
script:
  - ls -al .git/modules/
```

上述配置将导致 `git submodule update` 以下列方式调用：

```shell
git submodule update --init --depth 20 --recursive --remote --jobs 4
```

> [!warning]
> 你应该清楚使用 `--remote` 标志对构建的安全性、稳定性和可重现性的影响。大多数情况下，更好的做法是显式跟踪子模块的提交（按照设计），并使用自动修复或依赖机器人来更新它们。
>
> 检出子模块的已提交版本并不需要 `--remote` 标志。仅当你希望自动将子模块更新到其远程最新版本时才使用此标志。

`--remote` 的行为取决于你的 Git 版本。
如果父项目的 `.gitmodules` 文件中指定的分支与子模块仓库的默认分支不同，某些 Git 版本将会失败并显示以下错误：

`fatal: Unable to find refs/remotes/origin/<branch> revision in submodule path '<submodule-path>'`

Runner 实现了一个“尽力而为”的降级方案，当子模块更新失败时会尝试拉取远程引用。

如果此降级方案不适用于你的 Git 版本，请尝试以下任一解决方法：

- 将子模块仓库的默认分支更新为与父项目 `.gitmodules` 中设置的分支一致。
- 将 `GIT_SUBMODULE_DEPTH` 设置为 `0`。
- 单独更新子模块并从 `GIT_SUBMODULE_UPDATE_FLAGS` 中移除 `--remote` 标志。

### 将子模块 URL 重写为 HTTPS

{{< history >}}

- [在极狐GitLab Runner 15.11 中引入](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/3198)。

{{< /history >}}

使用 `GIT_SUBMODULE_FORCE_HTTPS` 变量强制将所有 Git 和 SSH 子模块 URL 重写为 HTTPS。这样即使子模块配置了 Git 或 SSH 协议，你也可以在同一个极狐GitLab 实例上克隆使用绝对 URL 的子模块。

```yaml
variables:
  GIT_SUBMODULE_STRATEGY: recursive
  GIT_SUBMODULE_FORCE_HTTPS: "true"
```

启用后，极狐GitLab Runner 使用 [CI/CD 作业令牌](../jobs/ci_job_token.md) 来克隆子模块。该令牌使用执行作业的用户的权限，不需要 SSH 凭据。

### 浅克隆

你可以使用 `GIT_DEPTH` 指定获取和克隆的深度。
`GIT_DEPTH` 会对仓库进行浅克隆，可以显著加快克隆速度。
对于提交数量多或包含旧的大型二进制文件的仓库，它非常有用。该值会传递给 `git fetch` 和 `git clone`。

新建项目默认具有一个
[默认 `git depth` 值，为 `20`](../pipelines/settings.md#限制克隆时获取的变更数量)。

如果你使用深度为 `1`，并且有作业队列或重试作业，作业可能会失败。

Git 的获取和克隆基于引用（例如分支名称），因此 runner 无法克隆特定的提交 SHA。如果队列中有多个作业，或者你重试了旧的作业，要测试的提交必须存在于克隆的 Git 历史中。将 `GIT_DEPTH` 设置得太小可能无法运行这些旧提交，作业日志中会显示 `unresolved reference`。此时你应考虑将 `GIT_DEPTH` 调高。

当设置了 `GIT_DEPTH` 时，依赖于 `git describe` 的作业可能无法正常工作，因为只有部分 Git 历史存在。

如只要获取或克隆最近的 3 次提交：

```yaml
variables:
  GIT_DEPTH: "3"
```

你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

### Git 子模块深度

{{< history >}}

- [在极狐GitLab Runner 15.5 中引入](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/3651)。

{{< /history >}}

当 [`GIT_SUBMODULE_STRATEGY`](#git-子模块策略) 设置为 `normal` 或 `recursive` 时，使用 `GIT_SUBMODULE_DEPTH` 变量来指定子模块的获取和克隆深度。你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或为特定作业进行设置。

设置 `GIT_SUBMODULE_DEPTH` 变量时，它会仅对子模块覆盖 [`GIT_DEPTH`](#浅克隆) 的设定。

如只要获取或克隆最近的 3 次提交：

```yaml
variables:
  GIT_SUBMODULE_DEPTH: 3
```

### 自定义构建目录

默认情况下，极狐GitLab Runner 会在 `$CI_BUILDS_DIR` 目录下的一个唯一子路径中克隆仓库。但是，你的项目可能需要代码位于特定目录（例如 Go 项目）。在这种情况下，你可以指定 `GIT_CLONE_PATH` 变量来告诉 runner 仓库的克隆目录：

```yaml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/project-name

test:
  script:
    - pwd
```

`GIT_CLONE_PATH` 必须始终在 `$CI_BUILDS_DIR` 内。`$CI_BUILDS_DIR` 中设置的目录取决于执行器类型和 [runners.builds_dir](https://docs.gitlab.com/runner/configuration/advanced-configuration/#the-runners-section) 设置的配置。

这只能在 runner 配置中启用了 `custom_build_dir` 时使用
[runner 的配置](https://docs.gitlab.com/runner/configuration/advanced-configuration/#the-runnerscustom_build_dir-section)。

#### 处理并发

使用大于 `1` 的并发数的执行器可能导致失败。如果 `builds_dir` 在多个作业间共享，多个作业可能会在同一目录上工作。

Runner 不会尝试阻止这种情况。这需要管理员和开发者遵循 runner 配置的要求。

为避免此情况，你可以在 `$CI_BUILDS_DIR` 中使用唯一路径，因为 runner 暴露了两个提供唯一并发 ID 的附加变量：

- `$CI_CONCURRENT_ID`：给定执行器中运行的所有作业的唯一 ID。
- `$CI_CONCURRENT_PROJECT_ID`：给定执行器和项目中运行的所有作业的唯一 ID。

在任何场景及任何执行器上都应该能正常工作的最稳定配置，是在 `GIT_CLONE_PATH` 中使用 `$CI_CONCURRENT_ID`。例如：

```yaml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/$CI_CONCURRENT_ID/project-name

test:
  script:
    - pwd -P
```

`$CI_CONCURRENT_PROJECT_ID` 应与 `$CI_PROJECT_PATH` 结合使用。
`$CI_PROJECT_PATH` 提供 `group/subgroup/project` 格式的仓库路径。
例如：

```yaml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/$CI_CONCURRENT_ID/$CI_PROJECT_PATH

test:
  script:
    - pwd -P
```

#### 嵌套路径

`GIT_CLONE_PATH` 的值仅展开一次。你不能在此值中嵌套变量。

例如，你在 `.gitlab-ci.yml` 文件中定义了以下变量：

```yaml
variables:
  GOPATH: $CI_BUILDS_DIR/go
  GIT_CLONE_PATH: $GOPATH/src/namespace/project
```

`GIT_CLONE_PATH` 的值会一次展开为 `$CI_BUILDS_DIR/go/src/namespace/project`，并导致失败，因为 `$CI_BUILDS_DIR` 未被展开。

### 忽略 `after_script` 中的错误

你可以在作业中使用 [`after_script`](../yaml/_index.md#after_script) 来定义一组命令，它们应在作业的 `before_script` 和 `script` 部分之后运行。无论脚本的终止状态是成功还是失败，`after_script` 命令都会运行。

默认情况下，极狐GitLab Runner 会忽略运行 `after_script` 时发生的任何错误。
要设置在运行 `after_script` 时发生错误时作业立即失败，请将 `AFTER_SCRIPT_IGNORE_ERRORS` CI/CD 变量设置为 `false`。例如：

```yaml
variables:
  AFTER_SCRIPT_IGNORE_ERRORS: false
```

### 作业阶段重试次数

你可以设置运行作业尝试执行以下阶段的次数：

| 变量                            | 描述                                                                                              |
|---------------------------------|---------------------------------------------------------------------------------------------------|
| `ARTIFACT_DOWNLOAD_ATTEMPTS`    | 运行作业时下载产物的尝试次数                                                                      |
| `EXECUTOR_JOB_SECTION_ATTEMPTS` | 在遭遇 [`No Such Container`](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/4450) 错误后，运行作业中某个部分的尝试次数（仅限 [Docker executor](https://docs.gitlab.com/runner/executors/docker/)）。 |
| `GET_SOURCES_ATTEMPTS`          | 运行作业时获取源代码的尝试次数                                                                    |
| `RESTORE_CACHE_ATTEMPTS`        | 运行作业时恢复缓存的尝试次数                                                                      |

默认值为一次。

示例：

```yaml
variables:
  GET_SOURCES_ATTEMPTS: 3
```

你可以在 [`variables`](../yaml/_index.md#variables) 部分中全局或按作业进行设置。

## 在 JihuLab.com 实例 runner 上不可用的系统调用

JihuLab.com 实例 runner 运行在 CoreOS 上。这意味着你不能使用 C 标准库中的某些系统调用，例如 `getlogin`。

## 产物和缓存设置

产物和缓存设置控制产物和缓存的压缩比。
使用这些设置可指定作业生成的归档文件的大小。

- 在慢速网络上，较小的归档文件可能使上传速度更快。
- 在快速网络上，如果带宽和存储不是问题，使用最快的压缩比可能使上传速度更快，尽管生成的归档文件会更大。

为了让 [极狐GitLab Pages](../../user/project/pages/_index.md) 支持
[HTTP Range requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests)，产物应使用 `ARTIFACT_COMPRESSION_LEVEL: fastest` 设置，因为只有未压缩的 zip 归档文件支持此功能。

可以启用传输速率计量器来提供上传和下载的传输速率。

你可以使用 `CACHE_REQUEST_TIMEOUT` 设置为缓存上传和下载设置最大时间。当缓慢的缓存上传显著增加作业持续时间时使用此设置。

```yaml
variables:
  # 每 2 秒输出一次上传和下载进度
  TRANSFER_METER_FREQUENCY: "2s"

  # 对产物使用快速压缩，生成较大的归档文件
  ARTIFACT_COMPRESSION_LEVEL: "fast"

  # 对缓存不使用压缩
  CACHE_COMPRESSION_LEVEL: "fastest"

  # 设置缓存上传和下载的最大持续时间
  CACHE_REQUEST_TIMEOUT: 5
```

| 变量                         | 描述                                                                                              |
|------------------------------|---------------------------------------------------------------------------------------------------|
| `TRANSFER_METER_FREQUENCY`   | 指定打印传输速率计量器的频率。可以设置为持续时间（例如 `1s` 或 `1m30s`）。持续时间为 `0` 则禁用计量器（默认值）。当设置了一个值时，流水线会显示产物和缓存上传、下载的进度计量。 |
| `ARTIFACT_COMPRESSION_LEVEL` | 调整压缩比，设置为 `fastest`、`fast`、`default`、`slow` 或 `slowest`。此设置仅适用于 Fastzip 归档器，因此必须同时启用极狐GitLab Runner 功能标志 [`FF_USE_FASTZIP`](https://docs.gitlab.com/runner/configuration/feature-flags/#available-feature-flags)。 |
| `CACHE_COMPRESSION_LEVEL`    | 调整压缩比，设置为 `fastest`、`fast`、`default`、`slow` 或 `slowest`。此设置仅适用于 Fastzip 归档器，因此必须同时启用极狐GitLab Runner 功能标志 [`FF_USE_FASTZIP`](https://docs.gitlab.com/runner/configuration/feature-flags/#available-feature-flags)。 |
| `CACHE_REQUEST_TIMEOUT`      | 配置单个作业的缓存上传和下载操作的最长持续时间（以分钟为单位）。默认值为 `10` 分钟。 |

### 调整高延迟连接的 TCP 设置

如果 runner 与极狐GitLab 实例之间存在显著的网络延迟，则默认的 TCP 窗口大小可能会限制吞吐量。在 runner 主机上，增大 TCP 窗口大小以允许传输更多数据。

例如，在 Linux 上，增加最大 TCP 缓冲区大小：

```shell
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"
```

要使这些更改在重启后仍然有效，请将它们添加到 `/etc/sysctl.conf` 文件中。

> [!note]
> TCP 调整是主机级别的更改，会影响 runner 机器上的所有网络连接。首先在非生产环境中测试更改。

## 产物来源元数据

{{< history >}}

- [在极狐GitLab Runner 15.1 中引入](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28940)。

{{< /history >}}

Runner 可以生成 [SLSA Provenance](https://slsa.dev/spec/v1.0/provenance) 并生成一个 [SLSA Statement](https://slsa.dev/spec/v1.0/attestation-model#model-and-terminology)，该声明将来源信息绑定到所有构建产物。
该声明被称为产物来源元数据。

要启用产物来源元数据，请将 `RUNNER_GENERATE_ARTIFACTS_METADATA` 环境变量设置为 `true`。你可以全局或为单个作业设置该变量：

```yaml
variables:
  RUNNER_GENERATE_ARTIFACTS_METADATA: "true"

job1:
  variables:
    RUNNER_GENERATE_ARTIFACTS_METADATA: "true"
```

元数据会呈现为一个存储在产物中的纯文本 `.json` 文件。文件名为 `{ARTIFACT_NAME}-metadata.json`。`ARTIFACT_NAME` 是
[产物名称](../jobs/job_artifacts.md#带有明确定义的产物名称)，
在 `.gitlab-ci.yml` 文件中定义。如果未定义名称，默认文件名为
`artifacts-metadata.json`。

### 来源元数据格式

产物来源元数据以
[in-toto v0.1 Statement](https://github.com/in-toto/attestation/tree/v0.1.0/spec#statement) 格式生成。
它包含一个以 [SLSA 1.0 Provenance](https://slsa.dev/spec/v1.0/provenance) 格式生成的来源谓词。

以下字段默认被填充：

| 字段                                                             | 值 |
|-------------------------------------------------------------------|----|
| `_type`                                                           | `https://in-toto.io/Statement/v0.1` |
| `subject`                                                         | 此元数据适用的软件产物的集合 |
| `subject[].name`                                                  | 产物的文件名。 |
| `subject[].sha256`                                                | 产物的 `sha256` 校验和。 |
| `predicateType`                                                   | `https://slsa.dev/provenance/v1` |
| `predicate.buildDefinition.buildType`                             | `https://gitlab.com/gitlab-org/gitlab-runner/-/blob/{GITLAB_RUNNER_VERSION}/PROVENANCE.md`。例如 v15.0.0 |
| `predicate.runDetails.builder.id`                                 | 指向 runner 详细信息页面的 URI，例如 `https://gitlab.com/gitlab-com/www-gitlab-com/-/runners/3785264`。 |
| `predicate.buildDefinition.externalParameters`                    | 构建命令执行期间可用的任何 CI/CD 或环境变量的名称。该值始终表示为空字符串以保护机密。 |
| `predicate.buildDefinition.externalParameters.source`             | 项目的 URL。 |
| `predicate.buildDefinition.externalParameters.entryPoint`         | 触发构建的 CI/CD 作业的名称。 |
| `predicate.buildDefinition.internalParameters.name`               | runner 的名称。 |
| `predicate.buildDefinition.internalParameters.executor`           | runner 执行器。 |
| `predicate.buildDefinition.internalParameters.architecture`       | 运行 CI/CD 作业的架构。 |
| `predicate.buildDefinition.internalParameters.job`                | 触发构建的 CI/CD 作业的 ID。 |
| `predicate.buildDefinition.resolvedDependencies[0].uri`           | 项目的 URL。 |
| `predicate.buildDefinition.resolvedDependencies[0].digest.sha256` | 项目的提交修订版本。 |
| `predicate.runDetails.metadata.invocationId`                      | 触发构建的 CI/CD 作业的 ID。 |
| `predicate.runDetails.metadata.startedOn`                         | 构建开始的时间。此字段格式为 `RFC3339`。 |
| `predicate.runDetails.metadata.finishedOn`                        | 构建结束的时间。由于元数据生成发生在构建期间，此时间会略早于极狐GitLab 中报告的时间。此字段格式为 `RFC3339`。 |

一个来源声明应类似于以下示例：
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
   "buildType": "https://jihulab.com/gitlab-cn/gitlab-runner/-/blob/2147fb44/PROVENANCE.md",
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
    "source": "https://jihulab.com/my-group/my-project/test-runner-generated-slsa-statement"
   },
   "internalParameters": {
    "architecture": "amd64",
    "executor": "docker+machine",
    "job": "10340684631",
    "name": "green-4.saas-linux-small-amd64.runners-manager.gitlab.com/default"
   },
   "resolvedDependencies": [
    {
     "uri": "https://jihulab.com/my-group/my-project/test-runner-generated-slsa-statement",
     "digest": {
      "sha256": "bdd2ecda9ef57b129c88617a0215afc9fb223521"
     }
    }
   ]
  },
  "runDetails": {
   "builder": {
    "id": "https://jihulab.com/my-group/my-project/test-runner-generated-slsa-statement/-/runners/12270857",
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

{{< history >}}

- 在 GitLab Runner 15.0 引入。

{{< /history >}}

如果你不想在系统默认的临时目录中归档缓存和产物，可以指定一个不同的目录。

在系统默认临时路径存在限制时，你可能需要更改目录。
如果对该目录位置使用高速磁盘，也能提升性能。

要更改目录，请在 CI 作业中将 `ARCHIVER_STAGING_DIR` 设置为变量，或者在注册 Runner 时使用 Runner 变量（`gitlab register --env ARCHIVER_STAGING_DIR=<dir>`）。

你指定的目录将用作下载产物但尚未提取时的位置。如果使用了 `fastzip` 归档器，
此位置也会在归档时用作暂存空间。

<a id="configure-fastzip-to-improve-performance"></a>

## 配置 `fastzip` 以提升性能

{{< history >}}

- 在 GitLab Runner 15.0 引入。

{{< /history >}}

要调优 `fastzip`，请确保启用了 [`FF_USE_FASTZIP`](https://docs.gitlab.com/runner/configuration/feature-flags/#available-feature-flags) 功能标志。
然后使用以下任意环境变量。

| 变量 | 描述 |
|---------------------------------|-------------|
| `FASTZIP_ARCHIVER_CONCURRENCY` | 并发压缩的文件数量。默认为可用的 CPU 数量。 |
| `FASTZIP_ARCHIVER_BUFFER_SIZE` | 为每个文件的每个并发分配的缓冲区大小。超出此大小的数据将移入暂存空间。默认为 2 MiB。 |
| `FASTZIP_EXTRACTOR_CONCURRENCY` | 并发解压的文件数量。默认为可用的 CPU 数量。 |

Zip 归档中的文件是按顺序追加的。这使得并发压缩变得困难。`fastzip` 绕过此限制的方法是：先将文件并发压缩到磁盘，然后再按顺序将结果复制回 Zip 归档。

为了避免对小文件进行磁盘写入和回读操作，会为每个并发使用一个小缓冲区。此设置可以通过 `FASTZIP_ARCHIVER_BUFFER_SIZE` 控制。此缓冲区的默认大小为 2 MiB，因此，16 的并发将分配 32 MiB。超出缓冲区大小的数据将被写入磁盘并回读。
因此，不使用缓冲区（`FASTZIP_ARCHIVER_BUFFER_SIZE: 0`），而只使用暂存空间也是一种有效的选择。

`FASTZIP_ARCHIVER_CONCURRENCY` 控制着有多少文件被并发压缩。如前所述，此设置因此可能会增加内存的使用量。它也可能增加写入暂存空间的临时数据量。
默认值为可用的 CPU 数量，但考虑到内存方面的影响，这并不总是最佳的设置。

`FASTZIP_EXTRACTOR_CONCURRENCY` 控制着一次解压的文件数量。Zip 归档中的文件原生支持并发读取，因此除了提取器所需的内存外，不会分配额外的内存。这
默认可用的 CPU 数量。