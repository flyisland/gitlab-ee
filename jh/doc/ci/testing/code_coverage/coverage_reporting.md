---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在合并请求、分析和徽章中显示测试覆盖率百分比。
title: 覆盖率报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [`coverage`](../../yaml/_index.md#coverage) 关键字从测试作业的日志输出中提取覆盖率百分比，并将其显示在合并请求和分析中。

此关键字仅显示覆盖率百分比。它不会在合并请求的差异中生成逐行注释。要显示逐行注释，请单独配置
[`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report)。

<a id="configure-coverage-reporting"></a>

## 配置覆盖率报告

要配置覆盖率报告：

1. 将 `coverage` 关键字添加到您的作业中，并使用与测试工具输出匹配的正则表达式：

   ```yaml
   test:
     script:
       - pytest --cov
     coverage: '/TOTAL.*? (100(?:\.0+)?\%|[1-9]?\d(?:\.\d+)?\%)$/'
   ```

1. 要从多个作业聚合覆盖率，请将 `coverage` 关键字添加到每个作业。

<a id="coverage-regex-patterns"></a>

### 覆盖率正则表达式模式

以下正则表达式模式可匹配常见测试覆盖率工具的输出。
请仔细测试这些模式，因为工具输出格式可能会随时间变化。

{{< tabs >}}

{{< tab title="Python and Ruby" >}}

| 工具       | 语言   | 命令        | 正则表达式模式 |
| ---------- | -------- | -------------- | ------------- |
| pytest-cov | Python   | `pytest --cov` | `/TOTAL.*? (100(?:\.0+)?\%\|[1-9]?\d(?:\.\d+)?\%)$/` |
| SimpleCov  | Ruby     | `rspec spec`   | `/Line\sCoverage:\s\d+\.\d+%/` |

{{< /tab >}}

{{< tab title="C/C++ and Rust" >}}

| 工具      | 语言   | 命令           | 正则表达式模式 |
| --------- | -------- | ----------------- | ------------- |
| gcovr     | C/C++    | `gcovr`           | `/^TOTAL.*\s+(\d+\%)$/` |
| Tarpaulin | Rust     | `cargo tarpaulin` | `/^\d+.\d+% coverage/` |

{{< /tab >}}

{{< tab title="Java and JVM" >}}

| 工具      | 语言    | 命令                            | 正则表达式模式 |
| --------- | ----------- | ---------------------------------- | ------------- |
| JaCoCo    | Java/Kotlin | `./gradlew test jacocoTestReport`  | `/Total.*?([0-9]{1,3})%/` |
| scoverage | Scala       | `sbt coverage test coverageReport` | `/(?i)total.*? (100(?:\.0+)?\%\|[1-9]?\d(?:\.\d+)?\%)$/` |

{{< /tab >}}

{{< tab title="Node.js" >}}

| 工具      | 命令                                    | 正则表达式模式 |
| --------- | ------------------------------------------ | ------------- |
| tap       | `tap --coverage-report=text-summary`       | `/^Statements\s*:\s*([^%]+)/` |
| nyc       | `nyc npm test`                             | `/All files[^\x7c]*\x7c[^\x7c]*\s+([\d\.]+)/` |
| Jest      | `jest --ci --coverage`                     | `/All files[^\x7c]*\x7c[^\x7c]*\s+([\d\.]+)/` |
| node:test | `node --experimental-test-coverage --test` | `/all files[^\x7c]*\x7c[^\x7c]*\s+([\d\.]+)/` |

{{< /tab >}}

{{< tab title="PHP" >}}

| 工具    | 命令                                  | 正则表达式模式 |
| ------- | ---------------------------------------- | ------------- |
| Pest    | `pest --coverage --colors=never`         | `/Statement coverage[A-Za-z\.*]\s*:\s*([^%]+)/` |
| PHPUnit | `phpunit --coverage-text --colors=never` | `/^\s*Lines:\s*\d+.\d+\%/` |

{{< /tab >}}

{{< tab title="Go" >}}

| 工具              | 命令                                                                    | 正则表达式模式 |
| ----------------- | -------------------------------------------------------------------------- | ------------- |
| go test (single)  | `go test -cover`                                                           | `/coverage: \d+.\d+% of statements/` |
| go test (project) | `go test -coverprofile=cover.profile && go tool cover -func cover.profile` | `/total:\s+\(statements\)\s+\d+.\d+%/` |

{{< /tab >}}

{{< tab title=".NET and PowerShell" >}}

| 工具        | 语言   | 命令       | 正则表达式模式 |
| ----------- | ---------- | ------------- | ------------- |
| OpenCover   | .NET       | 无          | `/(Visited Points).*\((.*)\)/` |
| dotnet test | .NET       | `dotnet test` | `/Total\s*\x7c*\s(\d+(?:\.\d+)?)/` |
| Pester      | PowerShell | 无          | `/Covered \d{1,3}[.,]?\d{0,2}%/` |

{{< /tab >}}

{{< tab title="Elixir" >}}

| 工具        | 命令            | 正则表达式模式 |
| ----------- | ------------------ | ------------- |
| ExCoveralls | 无               | `/\[TOTAL\]\s+(\d+\.\d+)%/` |
| Mix         | `mix test --cover` | `/\d+.\d+\%\s+\x7c\s+Total/` |

{{< /tab >}}

{{< /tabs >}}

<a id="add-a-coverage-check-approval-rule"></a>

## 添加覆盖率检查审批规则

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

您可以要求特定用户或群组批准会降低项目测试覆盖率的合并请求。

先决条件：

- 配置覆盖率报告。

要添加 `Coverage-Check` 审批规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 下，执行以下操作之一：
   - 在 `Coverage-Check` 审批规则旁边，选择 **启用**。
   - 如需手动设置，请选择 **添加审批规则**，然后在 **规则名称** 中输入 `Coverage-Check`。
1. 选择 **目标分支**。
1. 设置 **所需审批数量**。
1. 选择要提供审批的 **用户** 或 **群组**。
1. 选择 **保存更改**。

> [!note]
> 当合并基础的流水线不包含覆盖率数据时，`Coverage-Check` 审批规则要求进行审批，即使该合并请求提高了整体覆盖率。

<a id="view-coverage-history"></a>

## 查看覆盖率历史

您可以跟踪项目或群组在一段时间内的覆盖率趋势。

<a id="for-a-project"></a>

### 对于项目

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **分析** > **代码仓库分析**。
1. 从下拉列表中，选择您要查看历史数据的作业。
1. 可选。要下载数据，请选择 **下载原始数据 (.csv)**。

<a id="for-a-group"></a>

### 对于群组

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **分析** > **代码仓库分析**。
1. 可选。要下载数据，请选择 **下载历史测试覆盖率数据 (.csv)**。

<a id="display-coverage-badges"></a>

## 显示覆盖率徽章

要向项目添加覆盖率徽章，请参阅
[测试覆盖率报告徽章](../../../user/project/badges.md#test-coverage-report-badges)。

<a id="troubleshooting"></a>

## 故障排查

使用覆盖率报告时，您可能会遇到以下问题。

<a id="coverage-percentage-does-not-appear-in-the-mr-widget"></a>

### 覆盖率百分比未出现在合并请求小部件中

`coverage` 关键字使用正则表达式从作业的日志输出中提取百分比。如果百分比未出现：

- 验证您的正则表达式是否与工具的实际输出匹配。从作业日志中复制一行，并针对您的正则表达式进行测试。
- 某些工具会输出 ANSI 颜色代码，这会破坏正则表达式匹配。如果您的工具不支持禁用颜色输出，请在解析前剥离这些代码：

  ```shell
  lein cloverage | perl -pe 's/\e\[?.*?[\@-~]//g'
  ```

- 检查作业是否成功完成。仅从成功的作业中提取覆盖率。
- 不记录来自子流水线的覆盖率输出。有关详细信息，请参阅
  [议题 280818](https://gitlab.com/gitlab-org/gitlab/-/issues/280818)。

> [!note]
> `coverage` 关键字仅在合并请求小部件中显示百分比。要在差异中显示逐行注释，请单独配置
> [`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report)。
