---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码覆盖率
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

配置代码覆盖率以跟踪和可视化测试覆盖了多少源代码。您可以：

- 使用 `coverage` 关键字跟踪整体覆盖率指标和趋势。
- 使用 `artifacts:reports:coverage_report` 关键字可视化逐行覆盖率。

<a id="configure-coverage-reporting"></a>

## 配置覆盖率报告

使用 [`coverage`](../../yaml/_index.md#coverage) 关键字监控测试覆盖率并在合并请求中强制执行覆盖率要求。

通过覆盖率报告，您可以：

- 在合并请求中显示整体覆盖率百分比。
- 聚合多个测试作业的覆盖率。
- 添加覆盖率检查审批规则。
- 随时间跟踪覆盖率趋势。

要配置覆盖率报告：

1. 将 `coverage` 关键字添加到流水线配置中：

   ```yaml
   test-unit:
     script:
       - coverage run unit/
     coverage: '/TOTAL.+ ([0-9]{1,3}%)/'

   test-integration:
     script:
       - coverage run integration/
     coverage: '/TOTAL.+ ([0-9]{1,3}%)/'
   ```

1. 配置正则表达式 (regex) 以匹配测试输出格式。常见模式请参见 [覆盖率正则表达式模式](#coverage-regex-patterns)。
1. 要从多个作业聚合覆盖率，请将 `coverage` 关键字添加到要包含的每个作业中。
1. 可选。[添加覆盖率检查审批规则](#add-a-coverage-check-approval-rule)。

<a id="coverage-regex-patterns"></a>

### 覆盖率正则表达式模式

以下示例正则表达式模式旨在解析常见测试覆盖率工具的覆盖率输出。

请仔细测试正则表达式模式。工具输出格式可能随时间变化，这些模式可能不再按预期工作。

<!-- vale gitlab_base.Spelling = NO -->
<!--
Verify regex patterns carefully, especially patterns containing the pipe (`|`) character.
To use `|` in the text of a table cell (not as cell delimiters), you must escape it with a backslash (`\|`).
Verify all tables render as expected both in GitLab and on `docs.gitlab.com`.
See: <https://docs.gitlab.com/user/markdown/#tables>
-->

{{< tabs >}}

{{< tab title="Python 和 Ruby" >}}

| 工具       | 语言   | 命令        | 正则表达式模式 |
|------------|----------|----------------|---------------|
| pytest-cov | Python   | `pytest --cov` | `/TOTAL.*? (100(?:\.0+)?\%\|[1-9]?\d(?:\.\d+)?\%)$/` |
| Simplecov-html  | Ruby     | `rspec spec`   | `/Line\sCoverage:\s\d+\.\d+%/` |

{{< /tab >}}

{{< tab title="C/C++ 和 Rust" >}}

| 工具      | 语言   | 命令           | 正则表达式模式 |
|-----------|----------|-------------------|---------------|
| gcovr     | C/C++    | `gcovr`           | `/^TOTAL.*\s+(\d+\%)$/` |
| tarpaulin | Rust     | `cargo tarpaulin` | `/^\d+.\d+% coverage/` |

{{< /tab >}}

{{< tab title="Java 和 JVM" >}}

| 工具      | 语言    | 命令                            | 正则表达式模式 |
|-----------|-------------|------------------------------------|---------------|
| JaCoCo    | Java/Kotlin | `./gradlew test jacocoTestReport`  | `/Total.*?([0-9]{1,3})%/` |
| Scoverage | Scala       | `sbt coverage test coverageReport` | `/(?i)total.*? (100(?:\.0+)?\%\|[1-9]?\d(?:\.\d+)?\%)$/` |

{{< /tab >}}

{{< tab title="Node.js" >}}

<!-- markdownlint-disable MD056 -->

| 工具      | 命令                                    | 正则表达式模式 |
|-----------|--------------------------------------------|---------------|
| tap       | `tap --coverage-report=text-summary`       | `/^Statements\s*:\s*([^%]+)/` |
| nyc       | `nyc npm test`                             | `/All files[^\|]*\\|[^\|]*\s+([\d\.]+)/` |
| jest      | `jest --ci --coverage`                     | `/All files[^\|]*\\|[^\|]*\s+([\d\.]+)/` |
| node:test | `node --experimental-test-coverage --test` | `/all files[^\|]*\\|[^\|]*\s+([\d\.]+)/` |

<!-- markdownlint-enable MD056 -->

{{< /tab >}}

{{< tab title="PHP" >}}

| 工具    | 命令                                  | 正则表达式模式 |
|---------|------------------------------------------|---------------|
| pest    | `pest --coverage --colors=never`         | `/Statement coverage[A-Za-z\.*]\s*:\s*([^%]+)/` |
| phpunit | `phpunit --coverage-text --colors=never` | `/^\s*Lines:\s*\d+.\d+\%/` |

{{< /tab >}}

{{< tab title="Go" >}}

| 工具              | 命令          | 正则表达式模式 |
|-------------------|------------------|---------------|
| go test (single)  | `go test -cover` | `/coverage: \d+.\d+% of statements/` |
| go test (project) | `go test -coverprofile=cover.profile && go tool cover -func cover.profile` | `/total:\s+\(statements\)\s+\d+.\d+%/` |

{{< /tab >}}

{{< tab title=".NET 和 PowerShell" >}}

<!-- markdownlint-disable MD056 -->

| 工具      | 语言   | 命令 | 正则表达式模式 |
|-----------|------------|---------|---------------|
| OpenCover | .NET       | None    | `/(Visited Points).*\((.*)\)/` |
| dotnet test ([MSBuild](https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/MSBuildIntegration.md)) | .NET | `dotnet test` | `/Total\s*\\|*\s(\d+(?:\.\d+)?)/` |
| Pester    | PowerShell | None    | `/Covered (\d{1,3}(\.\|,)?\d{0,2}%)/` |

<!-- markdownlint-enable MD056 -->

{{< /tab >}}

{{< tab title="Elixir" >}}

| 工具        | 命令            | 正则表达式模式 |
|-------------|--------------------|---------------|
| excoveralls | None               | `/\[TOTAL\]\s+(\d+\.\d+)%/` |
| mix         | `mix test --cover` | `/\d+.\d+\%\s+\|\s+Total/` |

{{< /tab >}}

{{< /tabs >}}

<!-- vale gitlab_base.Spelling = YES -->

<a id="coverage-visualization"></a>

## 覆盖率可视化

使用 [`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report) 关键字查看合并请求中哪些特定代码行被测试覆盖。

您可以生成以下格式的覆盖率报告：

- Cobertura：适用于多种语言，包括 Java、JavaScript、Python 和 Ruby。
- JaCoCo：仅适用于 Java 项目。

覆盖率可视化使用 [产物报告](../../yaml/_index.md#artifactsreports) 来：

1. 收集一个或多个覆盖率报告，包括来自通配符路径的报告。
1. 合并所有报告中的覆盖率信息。
1. 在合并请求差异中显示合并结果。

覆盖率文件在后台作业中解析，因此流水线完成与可视化出现在合并请求中之间可能会有延迟。

默认情况下，覆盖率可视化数据在创建一周后过期。

<a id="configure-coverage-visualization"></a>

### 配置覆盖率可视化

要配置覆盖率可视化：

1. 配置测试工具以生成覆盖率报告。
1. 将 `artifacts:reports:coverage_report` 配置添加到流水线中：

   ```yaml
   test:
     script:
       - run tests with coverage
     artifacts:
       reports:
         coverage_report:
           coverage_format: cobertura  # 或 jacoco
           path: coverage/coverage.xml
   ```

有关特定语言的配置详细信息，请参见：

- [Cobertura 覆盖率报告](cobertura.md)
- [JaCoCo 覆盖率报告](jacoco.md)

<a id="coverage-reports-for-child-pipelines"></a>

### 子流水线的覆盖率报告

子流水线的覆盖率报告会出现在合并请求差异注释中。
但是，父流水线无法访问这些覆盖率报告以在自己的作业中使用。

支持父流水线获取子流水线的覆盖率报告的功能在 [议题 285100](https://jihulab.com/gitlab-cn/gitlab/-/issues/285100) 中提出。

<a id="add-a-coverage-check-approval-rule"></a>

## 添加覆盖率检查审批规则

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

您可以要求特定用户或群组批准降低项目测试覆盖率的合并请求。

先决条件：

- [配置覆盖率报告](#configure-coverage-reporting)。

要添加 `Coverage-Check` 审批规则：

1. 前往您的项目并选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 下，执行以下操作之一：
   - 在 `Coverage-Check` 审批规则旁边，选择 **启用**。
   - 对于手动设置，选择 **添加审批规则**，然后输入 `Coverage-Check` 作为 **规则名称**。
1. 选择 **目标分支**。
1. 设置 **所需审批数量**。
1. 选择要提供审批的 **用户** 或 **群组**。
1. 选择 **保存更改**。

> [!note]
> 当合并基础流水线不包含覆盖率数据时，即使合并请求提高了整体覆盖率，`Coverage-Check` 审批规则也需要审批。

<a id="view-coverage-results"></a>

## 查看覆盖率结果

流水线成功运行后，您可以在以下位置查看代码覆盖率结果：

- 合并请求小部件：查看覆盖率百分比以及与目标分支相比的变化。

  ![显示代码覆盖率百分比的合并请求小部件](img/pipelines_test_coverage_mr_widget_v17_3.png)

- 合并请求差异：审查哪些行被测试覆盖。适用于 Cobertura 和 JaCoCo 报告。
- 流水线作业：监控各个作业的覆盖率结果。

<a id="view-coverage-history"></a>

## 查看覆盖率历史

您可以跟踪项目或群组代码覆盖率随时间的变化。

<a id="for-a-project"></a>

### 对于项目

要查看项目的代码覆盖率历史：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **分析** > **仓库分析**。
1. 从下拉列表中，选择要查看历史数据的作业。
1. 可选。要查看数据的 CSV 文件，选择 **下载原始数据 (.csv)**。

<a id="for-a-group"></a>

### 对于群组

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

要查看群组中所有项目的代码覆盖率历史：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **分析** > **仓库分析**。
1. 可选。要查看数据的 CSV 文件，选择 **下载历史测试覆盖率数据 (.csv)**。

<a id="display-coverage-badges"></a>

## 显示覆盖率徽章

使用流水线徽章分享项目的代码覆盖率状态。

要向项目添加覆盖率徽章，请参见 [测试覆盖率报告徽章](../../../user/project/badges.md#test-coverage-report-badges)。

<a id="troubleshooting"></a>

## 故障排除

<a id="remove-color-codes-from-code-coverage"></a>

### 从代码覆盖率中移除颜色代码

一些测试覆盖率工具输出带有 ANSI 颜色代码，这些代码无法被正则表达式正确解析。这会导致覆盖率解析失败。

一些覆盖率工具不提供禁用输出中颜色代码的选项。如果是这样，请通过一个单行脚本将覆盖率工具的输出管道化，以去除颜色代码。

例如：

```shell
lein cloverage | perl -pe 's/\e\[?.*?[\@-~]//g'
```