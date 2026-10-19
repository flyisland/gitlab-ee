---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 定时流水线执行策略
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

流水线执行策略会在您项目的流水线中强制执行自定义 CI/CD 作业。借助定时流水线执行策略，您可以将此强制执行扩展到按固定周期（每天、每周或每月）运行 CI/CD 作业，确保即使没有新提交，合规脚本、安全扫描或其他自定义 CI/CD 作业也能执行。

<a id="scheduling-your-pipeline-execution-policies"></a>

## 为流水线执行策略安排计划

与在现有流水线中注入或覆盖作业的常规流水线执行策略不同，定时策略会创建按您定义的计划独立运行的新流水线。定时流水线与您项目的`.gitlab-ci.yml` 相互独立，不会执行项目的任何 CI/CD 作业。

常见用例包括：

- 按固定周期强制执行安全扫描，以满足合规要求。
- 定期检查项目配置。
- 对不活跃的代码仓库运行依赖项扫描，以检测新发现的漏洞。
- 按计划执行合规报告脚本。

<a id="test-a-scheduled-pipeline-execution-policy"></a>

## 测试定时流水线执行策略

在将定时流水线执行策略启用至所有项目之前，您可以先运行测试，以验证流水线是否正常工作，并了解该策略对您基础设施的影响。测试运行会执行真实的流水线，以提供准确的时间和资源估算。

> [!note]
> 测试运行会创建真实的流水线，并消耗目标项目的计算分钟。

运行测试：

1. 在左侧边栏中，选择 **安全** > **策略**。
1. 选择您要测试的定时流水线执行策略。
1. 选择 **测试运行** 标签页。
1. 如果您是在群组级别查看该策略，请从下拉列表中选择一个目标项目。
1. 选择 **开始测试运行**。

测试运行会使用该策略的 CI/CD 配置，在所选项目上创建一个流水线。您可以在 **测试运行** 标签页中监控测试运行状态。

测试运行完成后，**测试运行** 标签页会显示结果，包括持续时间和任何错误消息。

<a id="configure-schedule-pipeline-execution-policies"></a>

## 配置定时流水线执行策略

要配置定时流水线执行策略，请在安全策略项目的`.gitlab/security-policies/policy.yml` 文件的 `pipeline_execution_schedule_policy` 部分中添加其他配置字段：

```yaml
pipeline_execution_schedule_policy:
- name: Scheduled Pipeline Execution Policy
  description: ''
  enabled: true
  content:
    include:
    - project: your-group/your-project
      file: security-scan.yml
  schedules:
  - type: daily
    start_time: '10:00'
    time_window:
      value: 600
      distribution: random
```

<a id="schedule-configuration-schema"></a>

### 计划配置架构

`schedules` 部分允许您配置安全策略作业自动运行的时间。您可以创建具有特定执行时间和分布窗口的每日、每周或每月计划。

<a id="schedules-configuration-options"></a>

### 计划配置选项

`schedules` 部分支持以下选项：

| 参数 | 描述 |
|-----------|-------------|
| `type` | 计划类型：`daily`、`weekly` 或 `monthly` |
| `start_time` | 计划的开始时间，采用 24 小时制（HH:MM） |
| `time_window` | 用于分散流水线执行的时间窗口 |
| `time_window.value` | 持续时间（秒）（最小值：600，最大值：2629746） |
| `time_window.distribution` | 分布方法（目前仅支持 `random`） |
| `timezone` | IANA 时区标识符（如果未指定，默认为 UTC） |
| `branches` | 可选数组，包含要在其上安排流水线的分支名称。如果指定了 `branches`，流水线仅在指定的分支上运行，且仅当这些分支存在于项目中时才运行。如果未指定，流水线仅在默认分支上运行。每个计划最多可提供五个唯一分支名称。 |
| `days` | 仅用于每周计划：计划运行的日期数组（例如`["Monday", "Friday"]`） |
| `days_of_month` | 仅用于每月计划：计划运行的日期数组（例如`[1, 15]`，可包含 1 到 31 的值） |
| `snooze` | 用于临时暂停计划的可选配置 |
| `snooze.until` | 暂停结束后计划恢复的 ISO8601 日期和时间（格式：`2025-06-13T20:20:00+00:00`） |
| `snooze.reason` | 说明计划暂停原因的可选文档 |

<a id="schedule-examples"></a>

### 计划示例

使用每日、每周或每月计划。

<a id="daily-schedule-example"></a>

#### 每日计划示例

```yaml
schedules:
  - type: daily
    start_time: "01:00"
    time_window:
      value: 3600  # 1 hour window
      distribution: random
    timezone: "America/New_York"
    branches:
      - main
      - develop
      - staging
```

<a id="weekly-schedule-example"></a>

#### 每周计划示例

```yaml
schedules:
  - type: weekly
    days:
      - Monday
      - Wednesday
      - Friday
    start_time: "04:30"
    time_window:
      value: 7200  # 2 hour window
      distribution: random
    timezone: "Europe/Berlin"
```

<a id="monthly-schedule-example"></a>

#### 每月计划示例

```yaml
schedules:
  - type: monthly
    days_of_month:
      - 1
      - 15
    start_time: "02:15"
    time_window:
      value: 14400  # 4 hour window
      distribution: random
    timezone: "Asia/Tokyo"
```

<a id="time-window-distribution"></a>

### 时间窗口分布

为避免在将策略应用于多个项目时使您的 CI/CD 基础设施不堪重负，定时流水线执行策略会在一个时间窗口内分散流水线的创建，并遵循以下通用规则：

- 所有流水线都按 `random` 安排。流水线会在指定的时间窗口内随机分布。
- 最小时间窗口为 10 分钟（600 秒），最大约为 1 个月（2,629,746 秒）。
- 对于每月计划，如果您指定的日期在某些月份不存在（例如 2 月的 31 日），这些运行会被跳过。
- 一个安全策略项目最多可包含五个定时流水线执行策略。
- 一个定时策略一次只能有一个计划配置。
- 一个定时策略最多可针对五个分支。如果省略 `branches`，该策略仅在项目默认分支上运行。
- 当您将策略应用于多个项目时，请根据可用的 runner 容量，确保时间窗口足够大，以容纳项目数量。例如，将策略应用于 1000 个项目且时间窗口为一小时，则流水线的创建会均匀分布在这一小时内（约每分钟 16 条流水线）。请确认您的 runner 能够处理此流水线创建速率，或选择更大的时间窗口，以避免排队或延迟。
- 对于每月计划，由于在时间窗口内随机分布，连续运行之间的间隔可能会有所不同。例如，每月计划可能在上次运行后 20 天运行，然后 30 天后再次运行。这种分布是预期行为，因为它有助于在您的基础设施中分散负载。

<a id="snooze-scheduled-pipeline-execution-policies"></a>

## 暂停定时流水线执行策略

您可以使用暂停功能临时暂停定时流水线执行策略。在维护窗口、假期或需要阻止定时流水线在特定时间段内运行时，可使用暂停功能。

<a id="how-snoozing-works"></a>

### 暂停的工作方式

当您暂停定时流水线执行策略时：

- 在暂停期间不会创建新的定时流水线。
- 在暂停之前已创建的流水线会继续执行。
- 该策略保持启用状态，但处于暂停状态。
- 暂停期结束后，定时流水线执行会自动恢复。

<a id="configuring-snooze"></a>

### 配置暂停

要暂停定时流水线执行策略，请在计划配置中添加 `snooze` 部分：

```yaml
pipeline_execution_schedule_policy:
- name: Weekly Security Scan
  description: 'Run security scans every week'
  enabled: true
  content:
    include:
    - project: your-group/your-project
      file: security-scan.yml
  schedules:
  - type: weekly
    start_time: '02:00'
    time_window:
      value: 3600
      distribution: random
    timezone: UTC
    days:
      - Monday
    snooze:
      until: "2025-06-26T16:27:00+00:00"  # ISO8601 format
      reason: "Critical production deployment"
```

`snooze.until` 参数使用 ISO8601 格式指定暂停期结束的时间：`YYYY-MM-DDThh:mm:ss+00:00`，其中：

- `YYYY-MM-DD`：年、月、日
- `T`：日期和时间之间的分隔符
- `hh:mm:ss`：24 小时制的小时、分钟和秒
- `+00:00`：相对于 UTC 的时区偏移（或使用 Z 表示 UTC）

例如，`2025-06-26T16:27:00+00:00` 表示 2025 年 6 月 26 日 UTC 时间下午 4:27。

<a id="removing-a-snooze"></a>

### 移除暂停

要在暂停到期时间之前移除暂停，请从策略配置中移除 `snooze` 部分，或将 `until` 值设置为过去的日期。

<a id="control-access-to-cicd-variables"></a>

## 控制对 CI/CD 变量的访问

默认情况下，定时流水线执行策略作业无法访问项目或群组 CI/CD 变量。此安全默认设置可防止策略意外泄露敏感的项目配置。

要允许策略作业访问项目和群组 CI/CD 变量，请在策略配置中添加 `variables_override` 选项：

```yaml
pipeline_execution_schedule_policy:
- name: Scheduled Security Scan
  description: 'Run security scans with access to project variables'
  enabled: true
  content:
    include:
    - project: your-group/your-project
      file: security-scan.yml
  variables_override:
    allowed: true
  schedules:
  - type: daily
    start_time: '02:00'
    time_window:
      value: 3600
      distribution: random
```

<a id="variables_override-configuration-options"></a>

### `variables_override` 配置选项

| 参数 | 描述 |
|-----------|-------------|
| `allowed` | 必填。当为 `true` 时，策略作业可以访问项目和群组 CI/CD 变量。当为 `false` 时，阻止访问这些变量。 |
| `exceptions` | 可选。不受强制执行约束的变量名称数组。当为 `allowed: true` 时，此列表中的变量会被阻止。当为 `allowed: false` 时，此列表中的变量会被允许。 |
| `dotenv` | 可选。控制 dotenv 产物变量是否遵循策略规则。设置为 `allow_override` 可让 dotenv 变量绕过策略规则。默认行为遵循策略规则。 |

<a id="variables_override-examples"></a>

### `variables_override` 示例

阻止所有项目变量，特定变量除外：

```yaml
variables_override:
  allowed: false
  exceptions:
    - DEPLOY_TOKEN
    - API_KEY
```

允许所有项目变量，敏感变量除外：

```yaml
variables_override:
  allowed: true
  exceptions:
    - SECRET_KEY
    - PRIVATE_TOKEN
```

<a id="schedule-pipelines-for-specific-branches"></a>

## 为特定分支安排流水线

默认情况下，计划仅在默认分支上运行。定时流水线执行策略支持分支筛选，允许您为其他分支安排流水线。使用 `branches` 属性对项目中其他重要分支执行定期扫描或检查。

当您在计划中配置 `branches` 属性时：

- 如果未指定任何分支，定时流水线仅在默认分支上运行。
- 如果指定了分支，该策略会为项目中实际存在的每个指定分支安排流水线。
- 每个计划最多可指定五个唯一分支名称。
- 您必须完整指定每个分支名称。不支持通配符匹配。

<a id="branch-filtering-example"></a>

### 分支筛选示例

```yaml
pipeline_execution_schedule_policy:
- name: Scan Multiple Branches
  description: 'Run security scans on main, staging, and develop branches'
  enabled: true
  content:
    include:
    - project: your-group/your-project
      file: security-scan.yml
  schedules:
  - type: weekly
    days:
      - Monday
    start_time: '02:00'
    time_window:
      value: 3600
      distribution: random
    branches:
      - main
      - staging
      - develop
      - feature/new-authentication
```

在此示例中，如果所有指定的分支都存在于项目中，该策略会创建四条独立的流水线（每个分支一条）。

<a id="prerequisites"></a>

## 先决条件

要使用定时流水线执行策略，您的项目必须满足以下要求：

- 您的 CI/CD 配置文件存储在以下位置之一：
  - 您的安全策略项目
  - 公开项目
  - 已启用访问权限的私有项目（请参阅[启用对 CI/CD 配置文件的访问](#enable-access-to-cicd-configuration-files)）
- 您的 CI/CD 配置文件必须包含适用于定时流水线的适当工作流规则。

<a id="enable-access-to-cicd-configuration-files"></a>

## 启用对 CI/CD 配置文件的访问

当您的策略引用 CI/CD 配置文件时，安全策略机器人必须能够访问这些文件。公开项目中的文件默认可访问。对于安全策略项目或其他私有项目中的文件，请使用以下选项之一启用访问权限。

<a id="option-1-grant-access-to-files-in-the-security-policy-project"></a>

### 选项 1：授予对安全策略项目中文件的访问权限

如果您的 CI/CD 配置文件存储在安全策略项目本身中，请使用此选项。此设置适用于任何触发注入了流水线执行策略的流水线的用户。

1. 在您的安全策略项目中，在左侧边栏中，选择**设置** > **通用**。
1. 展开 **可见性，项目功能，权限**。
1. 开启 **授予安全策略项目访问 CI/CD 配置的权限**。
1. 选择 **保存更改**。

<a id="option-2-allow-access-to-private-or-internal-projects"></a>

### 选项 2：允许访问私有或内部项目

如果您的策略 `include:`值引用的 CI/CD 配置文件存储在安全策略项目以外的私有或内部项目中，请使用此选项。

1. 在存储 CI/CD 文件的私有或内部项目中，在左侧边栏中，选择
   **设置** > **通用**。
1. 展开 **可见性，项目功能，权限**。
1. 在**流水线执行策略**中，选择
   **允许访问此项目中的 CI/CD 配置文件**。
1. 在 **允许的文件模式**中，添加一个或多个 glob 模式以指定可访问的文件，用逗号分隔。
1. 可选。在 **允许的群组**中，选择一个群组，以仅允许该群组中项目的用户
   访问 CI/CD 配置文件。

   如果未指定，则根祖先群组中任何项目的用户都可以访问这些文件。
1. 选择 **保存更改**。

允许文件的 glob 模式必须与 `include:file:`值中指定的路径匹配。例如：

- 对于 `include:file: ci/security-scan.yml`，使用 `ci/**/*.yml` 或 `ci/security-scan.yml`。
- 对于 `include:file: policy-ci.yml`，使用`*.yml` 或 `policy-ci.yml`。
- 对于多个目录，使用多个模式，用逗号分隔，例如 `ci/**/*.yml, templates/**/*.yml`。

<a id="security-policy-bot-user"></a>

## 安全策略机器人用户

定时流水线由安全策略机器人用户执行，这是极狐GitLab 为安全策略所适用的每个项目自动创建的专用系统账号。为确保策略执行保持隔离和安全，该机器人用户具有以下安全限制：

- 该机器人用户仅是该特定项目的成员。它不能被添加到群组或其他项目。
- 该机器人用户被视为外部用户，默认情况下无法访问内部项目。
- 该机器人用户可以访问安全策略项目和公开项目中的文件。
- 仅当私有或内部项目明确启用了**流水线执行策略**设置，且文件路径与项目中指定的模式匹配时，该机器人用户才能访问这些项目中的文件。

由于该机器人用户不是其他项目的成员，因此它无法完成以下任何操作：

- 访问不允许访问或与允许的文件模式不匹配的私有或内部项目中的 CI/CD 配置文件。
- 启动以私有或内部项目为目标的多项目子流水线。
- 访问私有或内部项目中的产物或资源。

> [!important]
> 当您包含来自私有或内部项目的文件时，请在该项目中启用**流水线执行策略**
> 设置并设置匹配的文件模式。如果没有这些设置，流水线执行会因访问错误而失败。

<a id="scheduling-limits"></a>

## 计划限制

创建定时流水线执行策略时，请注意以下限制：

- 每个安全策略项目的定时流水线执行策略数量上限为一个策略一个计划。
- 计划的最大频率为每天一次（每日）。
- 如果未指定分支，定时流水线执行策略仅在默认分支上运行。
- 您最多可以在 `branches` 数组中指定五个唯一分支名称。
- 时间窗口必须至少为 10 分钟（600 秒），以确保流水线的充分分布。
- 如果可用的 runner 不足，定时流水线可能会延迟。

<a id="troubleshooting"></a>

## 故障排除

<a id="first-scheduled-run-may-be-delayed"></a>

### 首次计划运行可能会延迟

当您创建或更新定时流水线执行策略时，后台工作进程会异步创建计划记录。如果后台工作进程队列出现延迟（例如由于系统负载过高），后台工作进程可能会在预期的首次运行时间过后才创建计划记录。在这种情况下，首次运行会在下一个计划时间点发生，而不是立即发生。

例如，如果您在下午 2:00 创建了一个计划在下午 6:00 运行的策略，但后台工作进程直到晚上 7:00 才处理该策略，则首次运行会安排在次日下午 6:00（或根据您的计划配置安排的下一个适用日期）。

要变通处理此行为：

- 在预期的首次运行时间之前尽早创建策略。
- 使用[测试运行功能](#test-a-scheduled-pipeline-execution-policy)在首次计划运行之前验证策略是否正常工作。

<a id="scheduled-pipelines-not-running"></a>

### 定时流水线未运行

如果您的定时流水线未按预期运行，请按照以下故障排除步骤操作：

1. **检查策略访问权限**：确认：
   - CI/CD 配置文件位于安全策略项目、公开项目中，或位于已启用机器人访问权限且文件模式匹配的私有或内部项目中。
   - 安全策略项目中已启用**流水线执行策略**设置（**设置** > **通用** > **可见性，项目功能，权限**）。
1. **验证 CI 配置**：
   - 检查 CI/CD 配置文件是否存在于指定路径。
   - 通过运行手动流水线来验证配置是否有效。
   - 确保配置包含适用于定时流水线的适当工作流规则。
1. **验证策略配置**：
   - 确保策略已启用（`enabled: true`）。
   - 验证计划配置的格式正确且值有效。
   - 如果您指定了分支，请验证这些分支是否存在于项目中。
   - 验证时区设置是否正确（如果已指定）。
1. **查看日志和活动**：
   - 检查安全策略项目的 CI/CD 流水线日志中是否有任何错误。
1. **检查 runner 可用性**：
   - 确保 runner 可用且配置正确。
   - 验证 runner 是否有能力处理定时作业。
