---
stage: Application Security Testing
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SARIF 报告
description: 将第三方 SARIF 扫描器的发现结果添加到极狐GitLab 漏洞管理中。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用第三方 SARIF 报告，将任何
[SARIF 2.1.0](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html) 扫描器的发现结果
添加到极狐GitLab 漏洞管理中。CI/CD 作业运行生成 SARIF 的扫描器，并
添加 SARIF 产物。极狐GitLab 解析、验证这些产物，并将其添加为安全
发现结果。

添加报告后，发现结果会与极狐GitLab 原生扫描器的发现结果一起显示在
以下页面中：

- 流水线的 **安全** 选项卡
- 项目漏洞报告
- 安全仪表板
- 合并请求安全小组件
- 安全策略

第三方 SARIF 报告是对极狐GitLab 提供的内置扫描器的补充。您可以使用它们来集成
极狐GitLab 未原生提供的第三方扫描器，或整合您已在运行的
工具的发现结果。

<a id="add-sarif-reports"></a>

## 添加 SARIF 报告

要将 SARIF 发现结果添加到极狐GitLab 中：

先决条件：

- 项目中的维护者或所有者角色。
- 一个生成 SARIF 2.1.0 文件的 CI/CD 作业。

1. 在您的 `.gitlab-ci.yml` 文件中，定义一个运行扫描器并将其
   SARIF 输出保存为 `artifacts:reports:sarif` 产物的作业。示例：

   ```yaml
   sarif_scan:
     image: <scanner-image>
     script:
       - <scanner-command> --output sarif.json
     artifacts:
       reports:
         sarif: sarif.json
   ```

1. 提交并推送更改。作业完成后，极狐GitLab 会解析 SARIF 文件。
1. 在流水线的 **安全** 选项卡中查看添加的发现结果。

有关 CI/CD 产物参考，请参阅
[`artifacts:reports:sarif`](../../../ci/yaml/artifacts_reports.md#artifactsreportssarif)。

<a id="assigned-report-types"></a>

## 分配的报告类型

极狐GitLab 根据发现结果的位置和标识符，为每个 SARIF 发现结果分配一个漏洞报告类型。该类型决定了发现结果出现在漏洞报告中的位置，以及它与安全策略的交互方式。

极狐GitLab 按顺序评估以下规则，并分配第一个与发现结果匹配的类型。

| 规则                                                                                         | 分配的报告类型 |
|----------------------------------------------------------------------------------------------|----------------------|
| 任一标识符是 CVE。                                                                     | 依赖扫描  |
| 任一标识符是与密钥相关的 CWE。<sup>1</sup>                                         | 密钥检测     |
| 默认（无规则匹配）                                                          | SAST                 |

**脚注：**

1. 以下 CWE 与密钥相关：

   - [CWE-798（硬编码凭据）](https://cwe.mitre.org/data/definitions/798.html)。
   - [CWE-259（硬编码密码）](https://cwe.mitre.org/data/definitions/259.html)。
   - [CWE-321（硬编码加密密钥）](https://cwe.mitre.org/data/definitions/321.html)。
   - [CWE-522（保护不足的凭据）](https://cwe.mitre.org/data/definitions/522.html)。
   - [CWE-312（敏感信息的明文存储）](https://cwe.mitre.org/data/definitions/312.html)。
   - [CWE-319（敏感信息的明文传输）](https://cwe.mitre.org/data/definitions/319.html)。
   - [CWE-256（密码的明文存储）](https://cwe.mitre.org/data/definitions/256.html)。
   - [CWE-257（以可恢复格式存储密码）](https://cwe.mitre.org/data/definitions/257.html)。
   - [CWE-540（在源代码中包含敏感信息）](https://cwe.mitre.org/data/definitions/540.html)。

极狐GitLab 按以下顺序从结果及其规则的三个来源读取标识符：

1. `result.ruleId`，当条目匹配 `CVE-YYYY-N` 或 `CWE-N` 格式时。
1. `rule.properties.tags[]`，当条目匹配 `cwe:N`、`cwe-N`、
   `cve:YYYY-N` 或 `cve-YYYY-N` 格式时。
1. `rule.relationships[]`，当关系的
   `target.toolComponent.name` 为 `CWE` 时。

> [!note]
> 没有 CVE 或受支持的 CWE 标识符的发现结果会被分配为 SAST。要更改
> 极狐GitLab 分配的类型，请配置您的扫描器以输出匹配的 CVE
> 或 CWE 标识符。

<a id="sarif-field-mapping"></a>

## SARIF 字段映射

极狐GitLab 根据以下规则将 SARIF 字段分配给与极狐GitLab 兼容的字段。

| 极狐GitLab 字段          | SARIF 来源                                                                          | 是否必需    | 备注                                                                                                                                         |
|-----------------------|---------------------------------------------------------------------------------------|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| 严重程度              | 参见[严重程度解析](#severity-resolution)                                       | {{< no >}}  | 未设置严重程度字段时，默认为 `medium`。                                                                                           |
| 主要标识符    | `result.ruleId` 与 `run.tool.driver.rules[].id` 中的对应值匹配 | {{< yes >}} | 没有 `ruleId` 的发现结果不会被添加。                                                                                                    |
| 次要标识符 | `rule.properties.tags[]` 和 `rule.relationships[]`                                   | {{< no >}}  | 用于分配报告类型。                                                                                                               |
| 位置              | `result.locations[0].physicalLocation`                                                | {{< yes >}} | 没有物理位置的发现结果不会被添加。同一文件中共享 `ruleId` 且没有 `region` 的发现结果会合并为一个发现结果。参见[去重和发现结果标识](#deduplication-and-finding-identity)。 |
| 扫描器名称          | `run.tool.driver.name`                                                                | {{< yes >}} | [有效的 SARIF](https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/sarif-v2.1.0-errata01-os-complete.html#_Toc141790791) 所必需 |
| 扫描器供应商        | `run.tool.driver.organization`，然后是 `run.tool.driver.informationUri`                 | {{< no >}}  | 使用第一个非空值                                                                                                                 |
| 扫描器版本       | `run.tool.driver.version`，然后是 `run.tool.driver.semanticVersion`                     | {{< no >}}  | 使用第一个非空值                                                                                                                 |
| 抑制           | `result.suppressions[]`                                                               | {{< no >}}  | 被抑制的结果会被跳过，除非所有抑制都是 `underReview` 或 `rejected`。                                                       |

<a id="severity-resolution"></a>

## 严重程度解析

极狐GitLab 通过按优先级顺序检查以下字段来解析 SARIF 发现结果的严重程度。使用第一个有值的字段。

1. `result.rank`。一个从 `0.0` 到 `100.0` 的浮点数。
1. `rule.properties.security-severity`。一个从 `0.0` 到 `10.0` 的浮点数。该值在分桶前会乘以 10。
1. `result.properties.security-severity`。一个从 `0.0` 到 `10.0` 的浮点数。该值在分桶前会乘以 10。
1. `result.level`。
1. `rule.defaultConfiguration.level`。
1. 如果没有其他匹配项，则默认使用 `medium`。

来自 `result.rank` 或 `security-severity` 的数值分数使用以下范围分配为严重程度：

| 分数 (0-100) | 严重程度 |
|---------------|----------|
| `0.0`-`9.9`   | 信息     |
| `10.0`-`39.9` | 低      |
| `40.0`-`69.9` | 中   |
| `70.0`-`89.9` | 高     |
| `90.0`-`100`  | 严重 |

SARIF `level` 值的映射如下：

| `level`   | 严重程度 |
|-----------|----------|
| `error`   | 高     |
| `warning` | 中   |
| `note`    | 低      |
| `none`    | 信息     |

> [!note]
> 极狐GitLab 将 `level: error` 分配为高，而不是严重。要报告严重发现结果，请将
> `result.rank` 设置为 `90` 或更高，或将 `security-severity` 设置为 `9.0` 或更高。

<a id="ingestion-behavior"></a>

## 摄取行为

当 SARIF 文件格式正确但某些结果无法添加时，极狐GitLab 会使用其无法处理的结果百分比来决定如何处理整个扫描。

| 丢弃率     | 行为                                                | 报告为           |
|---------------|---------------------------------------------------------|------------------------|
| 0%            | 所有发现结果均被摄取。                              | 无消息。            |
| 1% 到 50%     | 有效发现结果被摄取。                        | 带有丢弃计数的警告。 |
| 超过 50% | 整个扫描失败。报告中的任何发现结果都不会被摄取。 | 带有丢弃计数的错误。   |

在以下任何情况下，极狐GitLab 都无法处理结果：

- `ruleId` 缺失。
- `physicalLocation` 缺失。
- 用于生成发现结果标识符的任何必需组件为空。
- 字符串字段超出其[字符限制](#limits)。

丢弃率是针对整个 SARIF 产物计算的，而不是针对文件中的每个 `run`。当所有运行中无法处理的结果比例超过阈值时，摄取反馈将应用于该产物生成的所有报告。

Schema 验证错误和不支持的 SARIF 版本会导致整个报告被拒绝，无论丢弃率如何。

<a id="multi-tool-reports"></a>

## 多工具报告

一个 SARIF 文件可以包含多个工具运行，每个运行都有自己的 `runs[]` 条目。对于每个运行，极狐GitLab 按推断的报告类型对发现结果进行分组，并为每个组创建单独的扫描记录。包含多种推断类型发现结果的运行会产生多条扫描记录。每次扫描都使用运行的 `tool.driver.name` 作为其扫描器。

使用多运行报告将多个扫描器的输出合并到一个产物中。例如，一个作业可以运行两个扫描器，并生成一个包含两个运行的 SARIF 文件。

有关每个文件的运行限制，请参阅[限制](#limits)。

<a id="limits"></a>

## 限制

| 限制                                  | 默认值                                                       | 可配置 |
|----------------------------------------|---------------------------------------------------------------|--------------|
| 最大 SARIF 产物大小            | 10 MB (`ci_max_artifact_size_sarif`)                          | {{< yes >}}  |
| 每个 SARIF 文件的最大运行数            | 20                                                            | {{< no >}}   |
| 每次运行的最大结果数                | 5,000                                                         | {{< no >}}   |
| 每次运行的最大规则数                  | 25,000                                                        | {{< no >}}   |
| 每条规则的最大标签数                  | 10                                                            | {{< no >}}   |
| 最大 `rule.name` 长度             | 255 个字符                                                | {{< no >}}   |
| 最大 `shortDescription.text` 长度 | 1,024 个字符                                              | {{< no >}}   |
| 最大 `fullDescription.text` 长度  | 1,024 个字符，用作发现结果标题时截断为 255 个字符 | {{< no >}}   |
| 最大 `message.text` 长度          | 1,024 个字符，用作发现结果标题时截断为 255 个字符 | {{< no >}}   |
| 最大 `helpUri` 长度               | 2,048 个字符                                              | {{< no >}}   |
| 支持的 SARIF 版本               | 仅 2.1.0                                                    | {{< no >}}   |

当每次运行的数量超过其限制时，极狐GitLab 会处理前 N 个条目并记录警告。
当结果中的字符串字段超出其字符限制时，整个结果将被跳过，并计入[丢弃率](#ingestion-behavior)。

对于极狐GitLab 私有化部署实例，管理员可以通过[实例限制](../../../administration/instance_limits.md)更改可配置的限制。

<a id="deduplication-and-finding-identity"></a>

## 去重和发现结果标识

当极狐GitLab 摄取 SARIF 报告时，它会为每个发现结果赋予一个由三个组件构建的唯一标识：报告类型、从发现结果的 `ruleId` 派生的主要标识符指纹，以及位置指纹。
对于 SARIF 发现结果，位置指纹的形式为 `file:startLine:endLine`。

SARIF `physicalLocation` 可以通过 `artifactLocation.uri` 命名文件，而无需 `region`。
发生这种情况时，极狐GitLab 仍会摄取该发现结果，并将其定位到整个文件，没有起始行或结束行。

当两个或多个结果共享相同的文件和相同的 `ruleId`，并且它们都不携带 `region` 时，所有三个标识组件都匹配。这些结果解析到相同的规则，因此它们共享报告类型和主要标识符指纹，并且位置指纹回退到仅文件路径。极狐GitLab 为每个结果计算相同的标识，保留第一个，并丢弃其余结果。

由于冲突发生在极狐GitLab 分配标识时，而不是在跳过摄取时，因此这些丢弃不计入[摄取丢弃率](#ingestion-behavior)，并且极狐GitLab 不会显示警告。

为避免此冲突，请输出带有至少 `startLine` 的 `region`，以便同一文件中的每个发现结果都获得自己的位置指纹。

<a id="known-issues"></a>

## 已知问题

- 分配为 SAST、依赖扫描或密钥检测的 SARIF 发现结果不会与等效的极狐GitLab 原生扫描器的发现结果进行去重。
  有关详细信息，请参阅
  [议题 592410](https://gitlab.com/gitlab-org/gitlab/-/issues/592410)。
- 尽管可以通过 SARIF 抑制排除发现结果，但极狐GitLab 不会基于抑制创建漏洞忽略。要忽略某个发现结果，请使用漏洞报告。

<a id="troubleshooting"></a>

## 故障排除

添加 SARIF 报告时，您可能会遇到以下问题：

<a id="warning--results-were-skipped-during-ingestion"></a>

### 警告：`... result(s) were skipped during ingestion`

在流水线的 **安全** 选项卡上，您可能会看到 **解析安全报告时出现警告** 警报，其中包含类似于以下内容的消息：

```plaintext
[Ingestion] 8 of 69 result(s) were skipped during ingestion. Causes: text field exceeded length limit (8). Check application logs for per-result details.
```

当 SARIF 报告中的结果不满足[限制](#limits)中描述的要求时，就会出现此问题。极狐GitLab 会跳过这些结果并摄取剩余的结果。

如果报告中超过一半的结果被跳过，则该消息是错误而不是警告，并以 `could not be ingested and the scan was aborted` 结尾。在这种情况下，极狐GitLab 不会存储报告中的任何结果。

要解决此问题，请更新扫描器配置或 SARIF 报告，使所有结果都满足文档化的限制，然后运行新的流水线。

要调查原因：

- 在 GitLab.com 上，GitLab 团队成员可以在 [Kibana](https://log.gprd.gitlab.net/) 中使用以下过滤器搜索 `pubsub-sidekiq-inf-gprd*` 索引：
  - `json.meta.feature_category: vulnerability_management`
  - `json.meta.pipeline_id: <pipeline-id>`
  - `json.message: Result skipped*` 或 `json.message: SARIF finding skipped*`
- 在极狐GitLab 私有化部署上，在 [`application_json.log`](../../../administration/logs/_index.md#application_jsonlog) 中搜索
  `Result skipped:` 或 `SARIF finding skipped:`。

日志会识别导致结果被跳过的字段或属性，但不会识别具体的结果。

在极狐GitLab 私有化部署上，您还可以从 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)中读取存储的消息：

```ruby
scan = Security::Scan.find_by!(pipeline_id: <pipeline-id>, project_id: <project-id>)
scan.processing_warnings
scan.processing_errors
```

<a id="fewer-findings-than-the-sarif-report-contains"></a>

### 发现结果数量少于 SARIF 报告包含的数量

漏洞报告显示的发现结果数量可能少于您的 SARIF 文件包含的数量，并且没有摄取警告。

当两个或多个结果解析为相同的标识，并且极狐GitLab 只保留第一个结果时，就会出现此问题。有关更多信息，请参阅
[去重和发现结果标识](#deduplication-and-finding-identity)。
