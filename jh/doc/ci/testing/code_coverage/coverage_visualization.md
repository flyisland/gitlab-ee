---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Cobertura 或 JaCoCo 报告，在合并请求差异中显示逐行测试覆盖率注释。
title: 覆盖率可视化
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report)
关键字在合并请求差异中显示逐行覆盖率注释。

此关键字仅显示差异注释。它不会在合并请求小部件中显示覆盖率百分比，也不会填充覆盖率历史图表。要显示覆盖率百分比，请单独配置
[`coverage`](../../yaml/_index.md#coverage) 关键字。

流水线完成后，极狐GitLab 会在后台处理报告，并在合并请求差异中注释行：

- 绿色：该行已被测试覆盖。
- 红色：该行未被测试覆盖。
- 橙色（仅限 Cobertura）：该行已加载但从未执行。

注释仅出现在合并请求差异中更改的文件上。未在合并请求中更改的文件不会被注释，即使报告包含这些文件的覆盖率数据。

<a id="configure-coverage-visualization"></a>

## 配置覆盖率可视化

要配置覆盖率可视化，请将 `artifacts:reports:coverage_report` 添加到您的作业中：

```yaml
test:
  script:
    - run tests with coverage
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura  # or jacoco
        path: coverage/coverage.xml
```

有关特定语言的示例，请参阅：

- [Cobertura](cobertura.md)
- [JaCoCo](jacoco.md)

要收集多个报告，请在产物路径中使用
[通配符](../../jobs/job_artifacts.md#with-wildcards)。
极狐GitLab 会将结果合并为单个报告。

来自子流水线的覆盖率报告会出现在合并请求差异注释中。

<a id="limits"></a>

## 限制

| 限制                                            | 值 |
| ------------------------------------------------ | ----- |
| Cobertura XML 文件最大大小                  | 10 MiB |
| Cobertura XML 文件中 `<source>` 节点的最大数量 | 100   |

如果您的 Cobertura 报告超过 100 个 `<source>` 节点，差异视图中的注释可能会缺失或
不匹配。对于大型项目，请将报告拆分为较小的文件。
有关详细信息，请参阅 [议题 328772](https://gitlab.com/gitlab-org/gitlab/-/issues/328772)。

可视化仅在流水线完成后出现。如果流水线有
[阻塞手动作业](../../jobs/job_control.md#types-of-manual-jobs)，则该可视化
在该作业运行之前不可用。

要从作业详情页面下载覆盖率报告，请将其添加到
产物 `paths` 和 `reports` 中：

```yaml
artifacts:
  paths:
    - coverage/cobertura-coverage.xml
  reports:
    coverage_report:
      coverage_format: cobertura
      path: coverage/cobertura-coverage.xml
```

<a id="path-resolution"></a>

## 路径解析

覆盖率报告使用相对文件路径。极狐GitLab 通过将这些路径与合并请求中更改的文件进行匹配，将其解析为绝对代码仓库路径。

对于 JaCoCo，匹配过程如下：

1. 查找同一流水线 ref 的所有合并请求。
1. 对于所有更改的文件，收集绝对路径。
1. 对于报告中的每个相对路径，使用第一个匹配的绝对路径。

对于 Cobertura，极狐GitLab 还会使用 `<sources>` 元素来重建路径：

1. 从每个 `<source>` 条目中提取路径段。
1. 将每个段与每个 `<class>` 元素的 `filename` 属性组合。
1. 检查候选路径是否存在于代码仓库中。
1. 使用第一个匹配项作为绝对路径。

此自动更正仅在 `<source>` 路径遵循格式
`<CI_BUILDS_DIR>/<PROJECT_FULL_PATH>/...` 时有效。

<a id="path-resolution-example"></a>

### 路径解析示例

对于一个完整路径为 `test-org/test-cs-project` 的 C# 项目，以及这些相对于项目根目录的文件：

```plaintext
Auth/User.cs
Lib/Utils/User.cs
```

在 Cobertura XML 中使用这些 `sources`：

```xml
<sources>
  <source>/builds/test-org/test-cs-project/Auth</source>
  <source>/builds/test-org/test-cs-project/Lib/Utils</source>
</sources>
```

解析器从 `sources` 中提取 `Auth` 和 `Lib/Utils`，然后将每个与
每个 `<class>` 元素的 `filename` 属性组合。对于具有 `filename="User.cs"` 的类，与代码仓库中文件匹配的第一个候选路径是 `Auth/User.cs`。

对于每个 `<class>` 元素，解析器最多尝试 100 次迭代。如果未找到匹配项，
则该类不会包含在最终的覆盖率报告中。

<a id="troubleshooting"></a>

## 故障排查

使用覆盖率可视化时，您可能会遇到以下问题。

<a id="diff-annotations-do-not-appear"></a>

### 差异注释不显示

注释可能因以下原因而不显示：

- 流水线尚未完成。注释在流水线完成后生成。
  请等待流水线完成，然后重新加载合并请求差异。
- 该文件不在合并请求差异中。注释仅出现在合并请求中更改的文件上，
  即使报告包含其他文件的覆盖率数据。
- 报告中的文件路径与代码仓库路径不匹配。如果路径解析
  失败，注释会被静默跳过。要进行诊断，请下载覆盖率 XML
  产物，并将 `<class>` 元素上的 `filename` 属性与该文件在代码仓库中相对于项目根目录的路径进行比较。
- 项目有多个模块，且相对路径重复。当路径在
  模块间不唯一时，极狐GitLab 无法解析注释属于哪个文件。
  请确保相对路径在模块间是唯一的：

  ```diff
      src/main/java/org/acme/DemoExample.java
    - src/main/other-module/org/acme/DemoExample.java
    + src/main/other-module/org/acme/OtherDemoExample.java
  ```

- 未配置 `coverage` 关键字。`artifacts:reports:coverage_report` 不会
  在合并请求小部件中产生百分比。要显示覆盖率百分比，请单独配置
  `coverage` 关键字。

<a id="metrics-do-not-display-for-all-changed-files"></a>

### 并非所有更改文件的指标都显示

当您从同一源分支创建新的合并请求，但目标分支不同时，会出现此问题。流水线使用先前合并请求的差异，
并且不会显示该差异中未包含的文件的注释。

要解决此问题，请等待新合并请求创建完成，然后重新运行流水线。
