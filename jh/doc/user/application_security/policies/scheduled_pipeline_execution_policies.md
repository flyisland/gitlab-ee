---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 定时流水线执行策略
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.0 中作为实验性功能引入，功能标志名称为 `scheduled_pipeline_execution_policy_type`，定义在 `policy.yml` 文件中。

{{< /history >}}

流水线执行策略强制在你的项目流水线中执行自定义 CI/CD 任务。借助定时流水线执行策略，你可以将这种强制扩展到按固定频率（每天、每周或每月）运行 CI/CD 任务，确保即使在没有任何新提交时，合规脚本、安全扫描或其他自定义 CI/CD 任务也能被执行。

<a id="scheduling-your-pipeline-execution-policies"></a>

## 配置定时流水线执行策略

与在现有流水线中注入或覆盖任务的常规流水线执行策略不同，定时策略会创建独立的流水线，并按照你定义的定时计划独立运行。
定时流水线与项目的 `.gitlab-ci.yml` 分开，不会执行项目中的任何 CI/CD 任务。

常见用例包括：

- 按固定频率强制执行安全扫描以满足合规要求。
- 定期检查项目配置。
- 在非活跃代码仓库上运行依赖项扫描，以发现新发现的漏洞。
- 按计划执行合规报告脚本。

<a id="enable-scheduled-pipeline-execution-policies"></a>

## 启用定时流水线执行策略

定时流水线执行策略作为实验性功能提供。要在你的环境中启用此功能，请在安全策略配置中启用 `pipeline_execution_schedule_policy` 实验。`.gitlab/security-policies/policy.yml` YAML 配置文件存储在你的安全策略项目中：

```yaml
experiments:
  pipeline_execution_schedule_policy:
    enabled: true
```

> [!note]
> 此功能为实验性功能，未来版本可能有变化。你应该仅在非生产环境中进行充分测试。不应在生产环境中使用此功能，因为它可能不稳定。

<a id="configure-schedule-pipeline-execution-policies"></a>

## 配置定时流水线执行策略

要配置定时流水线执行策略，请向安全策略项目的 `.gitlab/security-policies/policy.yml` 文件中的 `pipeline_execution_schedule_policy` 部分添加额外的配置字段：

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

### 定时计划配置架构

`schedules` 部分允许你配置安全策略任务何时自动运行。你可以创建每天、每周或每月的定时计划，并指定具体的执行时间和分布时间窗口。

<a id="schedules-configuration-options"></a>

### 定时计划配置选项

`schedules` 部分支持以下选项：

| 参数 | 描述 |
|-----------|-------------|
| `type` | 定时计划类型：`daily`、`weekly` 或 `monthly` |
| `start_time` | 定时计划开始时间，采用 24 小时制（HH:MM） |
| `time_window` | 用于分散流水线执行的时间窗口 |
| `time_window.value` | 持续时间（秒），最小值 600，最大值 2629746 |
| `time_window.distribution` | 分布方式（目前仅支持 `random`） |
| `timezone` | IANA 时区标识符（如未指定则默认为 UTC） |
| `branches` | 可选的数组，指定要在其上调度流水线的分支名称。如果指定了 `branches`，流水线仅在指定的分支上运行，且仅当这些分支在项目中存在时才运行。如果未指定，流水线仅在默认分支上运行。每个定时计划最多可提供五个唯一的分支名称。 |
| `days` | 仅用于每周定时计划：定时计划运行的日期数组（例如 `["Monday", "Friday"]`） |
| `days_of_month` | 仅用于每月定时计划：定时计划运行的日期数组（例如 `[1, 15]`，可包含 1 到 31 的值） |
| `snooze` | 可选配置，用于临时暂停定时计划 |
| `snooze.until` | ISO8601 格式的日期和时间，表示暂停后定时计划恢复的时间（格式：`2025-06-13T20:20:00+00:00`） |
| `snooze.reason` | 可选的文档说明，解释定时计划被暂停的原因 |

<a id="schedule-examples"></a>

### 定时计划示例

使用每天、每周或每月的定时计划。

<a id="daily-schedule-example"></a>

#### 每天定时计划示例

```yaml
schedules:
  - type: daily
    start_time: "01:00"
    time_window:
      value: 3600  # 1 小时窗口
      distribution: random
    timezone: "America/New_York"
    branches:
      - main
      - develop
      - staging
```

<a id="weekly-schedule-example"></a>

#### 每周定时计划示例

```yaml
schedules:
  - type: weekly
    days:
      - Monday
      - Wednesday
      - Friday
    start_time: "04:30"
    time_window:
      value: 7200  # 2 小时窗口
      distribution: random
    timezone: "Europe/Berlin"
```

<a id="monthly-schedule-example"></a>

#### 每月定时计划示例

```yaml
schedules:
  - type: monthly
    days_of_month:
      - 1
      - 15
    start_time: "02:15"
    time_window:
      value: 14400  # 4 小时窗口
      distribution: random
    timezone: "Asia/Tokyo"
```

<a id="time-window-distribution"></a>

### 时间窗口分布

为防止在将策略应用于多个项目时压垮你的 CI/CD 基础设施，定时流水线执行策略会根据一些通用规则将流水线的创建分散在一个时间窗口内：

- 所有流水线都按 `random` 方式调度。流水线将在指定的时间窗口内随机分布。
- 最小时间窗口为 10 分钟（600 秒），最大约为 1 个月（2,629,746 秒）。
- 对于每月定时计划，如果你指定的日期在某些月份不存在（例如 2 月的 31 日），则会跳过这些运行。
- 一个定时策略一次只能有一个定时计划配置。
- 当你将一个策略应用于多个项目时，请确保时间窗口足够大，以根据你可用的 Runner 容量容纳项目数量。例如，一个应用于 1000 个项目、时间窗口为一小时的策略，会在这一个小时内均匀创建流水线（大约每分钟 16 条流水线）。请验证你的 Runner 能否处理此流水线创建速率，或选择更大的时间窗口以避免排队或延迟。
- 对于每月定时计划，由于时间窗口内的随机分布，连续运行之间的间隔可能会有所不同。例如，一个月度定时计划可能在某次运行 20 天后再次运行，然后 30 天后再次运行。这种分布是预期的行为，因为它有助于在你的基础设施上分散负载。

<a id="snooze-scheduled-pipeline-execution-policies"></a>

## 暂停定时流水线执行策略

你可以使用暂停功能临时暂停定时流水线执行策略。在维护窗口、假期或需要防止定时流水线在特定时间段运行时，可使用暂停功能。

<a id="how-snoozing-works"></a>

### 暂停的工作原理

当你暂停定时流水线执行策略时：

- 在暂停期间不会创建新的定时流水线。
- 在暂停之前创建的流水线将继续执行。
- 策略保持启用状态，但处于暂停状态。
- 暂停期结束后，定时流水线执行将自动恢复。

<a id="configuring-snooze"></a>

### 配置暂停

要暂停一个定时流水线执行策略，请在定时计划配置中添加一个 `snooze` 部分：

```yaml
pipeline_execution_schedule_policy:
- name: Weekly Security Scan
  description: '每周运行安全扫描'
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
      until: "2025-06-26T16:27:00+00:00"  # ISO8601 格式
      reason: "关键生产部署"
```

`snooze.until` 参数使用 ISO8601 格式指定暂停期何时结束：`YYYY-MM-DDThh:mm:ss+00:00`，其中：

- `YYYY-MM-DD`：年、月、日
- `T`：日期与时间之间的分隔符
- `hh:mm:ss`：24 小时制的小时、分钟、秒
- `+00:00`：相对于 UTC 的时区偏移量（或 Z 表示 UTC）

例如，`2025-06-26T16:27:00+00:00` 表示 2025 年 6 月 26 日下午 4:27 UTC。

<a id="removing-a-snooze"></a>

### 取消暂停

要在暂停到期前取消暂停，请从策略配置中移除 `snooze` 部分，或将 `until` 的值设置为一个过去的日期。

<a id="schedule-pipelines-for-specific-branches"></a>

## 为特定分支定时计划流水线

默认情况下，定时计划仅在默认分支上运行。定时流水线执行策略支持分支过滤，这允许你为其他分支定时计划流水线。使用 `branches` 属性可以定期对项目中的其他重要分支执行扫描或检查。

当你在定时计划中配置 `branches` 属性时：

- 如果你不指定任何分支，定时流水线仅在默认分支上运行。
- 如果你指定了分支，策略会为项目中实际存在的每个指定分支定时计划流水线。
- 每个定时计划最多可以指定五个唯一的分支名称。
- 你必须完整地指定每个分支名称。不支持通配符匹配。

<a id="branch-filtering-example"></a>

### 分支过滤示例

```yaml
pipeline_execution_schedule_policy:
- name: 扫描多个分支
  description: '对 main、staging 和 develop 分支运行安全扫描'
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

在这个示例中，如果项目中存在所有指定的分支，策略将创建四条独立的流水线（每个分支一条）。

<a id="prerequisites"></a>

## 先决条件

要使用定时流水线执行策略，你的项目必须满足以下要求：

- 你的 CI/CD 配置文件存储在以下位置之一：
  - 你的安全策略项目中
  - 一个公开项目中
  - 一个启用了访问权限的私有项目中（请参阅[启用对 CI/CD 配置文件的访问](#enable-access-to-cicd-configuration-files)）
- 你的 CI/CD 配置文件必须包含适用于定时流水线的适当工作流规则。

<a id="enable-access-to-cicd-configuration-files"></a>

## 启用对 CI/CD 配置文件的访问

当你的策略引用 CI/CD 配置文件时，安全策略机器人必须有权访问这些文件。
默认情况下，公开项目中的文件是可访问的。
对于安全策略项目或其他私有项目中的文件，请使用以下选项之一启用访问。

<a id="option-1-grant-access-to-files-in-the-security-policy-project"></a>

### 选项 1：授予对安全策略项目中文件的访问权限

如果你的 CI/CD 配置文件存储在安全策略项目本身中，请使用此选项。
此设置适用于任何通过注入流水线执行策略来触发流水线的用户。

1. 在你的安全策略项目中，在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性，项目功能，权限**。
1. 打开 **授予安全策略项目访问 CI/CD 配置的权限**。
1. 选择 **保存更改**。

<a id="option-2-allow-security-policy-bot-access-to-private-projects"></a>

### 选项 2：允许安全策略机器人访问私有项目

如果你的策略 `include:` 值引用了存储在一个私有项目（非安全策略项目）中的 CI/CD 配置文件，请使用此选项。
此设置仅适用于安全策略机器人用户，并且可以在任何项目上启用。

1. 在你的安全策略项目中启用 `pipeline_execution_policy_bot_access` 实验。
   在 `.gitlab/security-policies/policy.yml` 文件中，添加以下行：

   ```yaml
   experiments:
     pipeline_execution_policy_bot_access:
       enabled: true
   ```

   > [!note]
   > 你的私有项目或其上级群组之一必须与此安全策略项目关联。
   > 如果尚未关联，你必须[关联安全策略项目](enforcement/security_policy_projects.md#link-to-a-security-policy-project)。

1. 在存储 CI/CD 文件的私有项目中，在左侧边栏中，选择 **设置** >
   **通用**。
1. 展开 **可见性，项目功能，权限**。
1. 在 **安全策略机器人访问** 中，选择
   **允许安全策略机器人访问此项目中的 CI/CD 配置文件**。
1. 在 **允许的文件模式** 中，添加一个或多个 glob 模式以指定机器人可以访问的文件，用逗号分隔。
1. 选择 **保存更改**。

允许的文件的 glob 模式必须与 `include:file:` 值中指定的路径匹配。例如：

- 对于 `include:file: ci/security-scan.yml`，请使用 `ci/**/*.yml` 或 `ci/security-scan.yml`。
- 对于 `include:file: policy-ci.yml`，请使用 `*.yml` 或 `policy-ci.yml`。
- 对于多个目录，请使用多个模式，用逗号分隔，例如 `ci/**/*.yml, templates/**/*.yml`。

<a id="security-policy-bot-user"></a>

## 安全策略机器人用户

定时流水线由安全策略机器人用户执行，这是极狐GitLab 为策略适用的每个项目自动创建的一个专用系统账户。
为确保策略执行保持隔离和安全，该机器人用户具有以下安全限制：

- 机器人用户仅是该特定项目的成员。它不能添加到群组或其他项目中。
- 机器人用户可以访问安全策略项目和公开项目中的文件。
- 机器人用户只有在那些私有项目明确启用
  **安全策略机器人访问** 且文件路径与项目中指定的模式匹配时，才能访问私有项目中的文件。

由于机器人用户不是其他项目的成员，因此它无法完成以下任何操作：

- 从不允许机器人访问或不符合允许文件模式的私有项目中访问 CI/CD 配置文件。
- 启动以私有项目为目标的多项目子流水线。
- 从私有项目访问产物或资源。

> [!重要]
> 当你从私有项目包含文件时，请在该私有项目中启用 **安全策略机器人访问** 并设置匹配的文件模式。如果没有这些设置，流水线执行将因访问错误而失败。

<a id="scheduling-limits"></a>

## 定时计划限制

此功能是实验性功能，未来版本中可能会有变化。此外，在创建定时流水线执行策略时，请注意以下限制：

- 每个安全策略项目最多只能有一个带有单个定时计划的定时流水线执行策略。
- 定时计划的最大频率为每天一次（每天）。
- 如果未指定分支，定时流水线执行策略仅在默认分支上运行。
- 你最多可以在 `branches` 数组中指定五个唯一的分支名称。
- 时间窗口必须至少为 10 分钟（600 秒），以确保流水线有足够的分布。
- 如果没有足够的可用的 Runner，定时流水线可能会延迟。

<a id="troubleshooting"></a>

## 故障排除

如果你的定时流水线未按预期运行，请按照以下故障排除步骤操作：

1. **验证实验性标志**：确保在 `policy.yml` 文件的 `experiments` 部分中设置了 `pipeline_execution_schedule_policy: enabled: true` 标志。
1. **检查策略访问权限**：验证：
   - CI/CD 配置文件位于安全策略项目、公开项目中，或位于已启用机器人访问并具有匹配文件模式的私有项目中。
   - 在安全策略项目中启用了 **流水线执行策略** 设置（**设置** > **通用** > **可见性，项目功能，权限**）。
1. **验证 CI 配置**：
   - 检查 CI/CD 配置文件是否存在于指定路径。
   - 通过手动运行流水线来验证配置是否有效。
   - 确保配置包含适用于定时流水线的适当工作流规则。
1. **验证策略配置**：
   - 确保策略已启用（`enabled: true`）。
   - 验证定时计划配置格式正确且值有效。
   - 如果指定了分支，请验证这些分支在项目中存在。
   - 验证时区设置是否正确（如果指定了）。
1. **检查日志和活动**：
   - 检查安全策略项目的 CI/CD 流水线日志中是否有任何错误。
1. **检查 Runner 可用性**：
   - 确保 Runner 可用且配置正确。
   - 验证 Runner 是否具有处理定时作业的容量。