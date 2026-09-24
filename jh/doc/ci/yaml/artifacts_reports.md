---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Artifact report types for test results, security scans, code quality checks, and performance metrics.
title: CI/CD 产物报告类型
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [`artifacts:reports`](_index.md#artifactsreports) 来：

- 收集由作业中包含的模板生成的测试报告、代码质量报告、安全报告和其他产物。
- 其中一些报告用于在以下位置显示信息：
  - 合并请求。
  - 流水线视图。
  - [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。

为 `artifacts: reports` 创建的产物始终会被上传，无论作业结果如何（成功或失败）。
你可以使用 [`artifacts:expire_in`](_index.md#artifactsexpire_in) 为产物设置过期时间，这会覆盖实例的[默认设置](../../administration/settings/continuous_integration.md#set-maximum-artifacts-size)。
JihuLab.com 可能有[不同的默认产物过期值](../../user/jihulab_com/_index.md#gitlab-cicd)。

一些 `artifacts:reports` 类型可以由同一流水线中的多个作业生成，并被每个作业的合并请求或流水线功能使用。

要浏览报告输出文件，请确保在作业定义中包含 [`artifacts:paths`](_index.md#artifactspaths) 关键词。

> [!note]
> 不支持在父流水线中使用[来自子流水线的产物](_index.md#needspipelinejob)来合并报告。该功能的支持提案在[史诗 8205](https://gitlab.com/groups/gitlab-org/-/epics/8205)中。

<a id="artifacts-reports-accessibility"></a>

## 可访问性报告

`accessibility` 报告使用 [pa11y](https://pa11y.org/) 来报告合并请求中引入的变更对可访问性的影响。

极狐GitLab 可以在合并请求的[可访问性组件](../testing/accessibility_testing.md#accessibility-merge-request-widget)中显示一个或多个报告的结果。

更多信息，请参见[可访问性测试](../testing/accessibility_testing.md)。

<a id="artifacts-reports-annotations"></a>

## 注解报告

{{< history >}}

- 在极狐GitLab 16.3 引入。

{{< /history >}}

`annotations` 报告用于将辅助数据附加到作业上。

注解报告是一个 JSON 文件，其中包含注解部分。每个注解部分可以有任何所需名称，并且可以包含任意数量的相同或不同类型的注解。

每个注解都是一个单独的键（注解类型），包含该注解数据的子键。

### 注解类型

#### `external_link`

可以将 `external_link` 注解附加到作业上，以向作业输出页面添加一个链接。`external_link` 注解的值是一个包含以下键的对象：

| 键     | 描述 |
|---------|-------------|
| `label` | 与链接关联的人类可读标签。 |
| `url`   | 链接指向的 URL。 |

### 示例报告

下面是一个作业注解报告可能看起来的示例：

```json
{
  "my_annotation_section_1": [
    {
      "external_link": {
        "label": "URL 1",
        "url": "https://url1.example.com/"
      }
    },
    {
      "external_link": {
        "label": "URL 2",
        "url": "https://url2.example.com/"
      }
    }
  ]
}
```

<a id="artifacts-reports-api_fuzzing"></a>

## API 模糊测试报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`api_fuzzing` 报告收集 [API 模糊测试缺陷](../../user/application_security/api_fuzzing/_index.md)作为产物。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[安全组件](../../user/application_security/api_fuzzing/configuration/enabling_the_analyzer.md#view-details-of-an-api-fuzzing-vulnerability)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- 流水线的[**安全**选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表盘](../../user/application_security/api_fuzzing/configuration/enabling_the_analyzer.md#security-dashboard)。

<a id="artifacts-reports-browser_performance"></a>

## 浏览器性能报告

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

`browser_performance` 报告收集浏览器性能测试指标作为产物。
该产物是一个由[适用于 sitespeed.io 的极狐GitLab 插件](https://gitlab.com/gitlab-org/gl-performance)生成的 JSON 文件。

极狐GitLab 在合并请求中显示结果。更多信息，请参见[浏览器性能测试](../testing/browser_performance_testing.md)。

极狐GitLab 无法显示多个 `browser_performance` 报告的组合结果。

<a id="artifacts-reports-coverage_report"></a>

## 覆盖率报告

使用 `coverage_report:` 收集 Cobertura 或 JaCoCo 格式的[覆盖率报告](../testing/_index.md)。

`coverage_format:` 可以是 [`cobertura`](../testing/code_coverage/cobertura.md) 或 [`jacoco`](../testing/code_coverage/jacoco.md)。

Cobertura 最初是为 Java 开发的，但有许多针对其他语言（如 JavaScript、Python 和 Ruby）的第三方移植版本。

```yaml
artifacts:
  reports:
    coverage_report:
      coverage_format: cobertura
      path: coverage/cobertura-coverage.xml
```

收集到的覆盖率报告作为产物上传到极狐GitLab。

你可以生成多个 JaCoCo 或 Cobertura 报告，并使用[通配符](../jobs/job_artifacts.md#with-wildcards)将它们包含在最终的作业产物中。
这些报告的结果会被聚合到最终的覆盖率报告中。

覆盖率报告的结果会显示在合并请求的[差异注解](../testing/code_coverage/_index.md#coverage-visualization)中。

> [!note]
> 来自子流水线的覆盖率报告会显示在合并请求差异注解中，但产物本身不与父流水线共享。

<a id="artifacts-reports-codequality"></a>

## 代码质量报告

`codequality` 报告收集[代码质量问题](../testing/code_quality.md)。收集到的代码质量报告作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[代码质量组件](../testing/code_quality.md#merge-request-widget)。
- 合并请求的[差异注解](../testing/code_quality.md#merge-request-changes-view)。
- [完整报告](../testing/metrics_reports.md)。

[`artifacts:expire_in`](_index.md#artifactsexpire_in) 值被设置为 `1 周`。

<a id="artifacts-reports-container_scanning"></a>

## 容器扫描报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`container_scanning` 报告收集[容器扫描漏洞](../../user/application_security/container_scanning/_index.md)。
收集到的容器扫描报告作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[容器扫描组件](../../user/application_security/container_scanning/_index.md)。
- 流水线的[**安全**选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。

<a id="artifacts-reports-coverage_fuzzing"></a>

## 覆盖率模糊测试报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`coverage_fuzzing` 报告收集[覆盖率模糊测试缺陷](../../user/application_security/coverage_fuzzing/_index.md)。
收集到的覆盖率模糊测试报告作为产物上传到极狐GitLab。
极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[覆盖率模糊测试组件](../../user/application_security/coverage_fuzzing/_index.md#interacting-with-the-vulnerabilities)。
- 流水线的[**安全**选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。

<a id="artifacts-reports-cyclonedx"></a>

## CycloneDX 报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

该报告是一个软件物料清单，描述了遵循 [CycloneDX](https://cyclonedx.org/docs/1.4) 协议格式的项目组件。

每个作业可以指定多个 CycloneDX 报告。这些报告可以以文件名列表、文件名模式或两者兼有的形式提供：

- 文件名模式（如 `cyclonedx: gl-sbom-*.json`、`junit: test-results/**/*.json`）。
- 文件名数组（如 `cyclonedx: [gl-sbom-npm-npm.cdx.json, gl-sbom-bundler-gem.cdx.json]`）。
- 两者的组合（如 `cyclonedx: [gl-sbom-*.json, my-cyclonedx.json]`）。
- 不支持目录（如 `cyclonedx: test-results`、`cyclonedx: test-results/**`）。

以下示例展示了一个公开 CycloneDX 产物的作业：

```yaml
artifacts:
  reports:
    cyclonedx:
      - gl-sbom-npm-npm.cdx.json
      - gl-sbom-bundler-gem.cdx.json
```

<a id="artifacts-reports-dast"></a>

## DAST 报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`dast` 报告收集 [DAST 漏洞](../../user/application_security/dast/_index.md)。收集到的 DAST 报告作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的安全组件。
- 流水线的[**安全**选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。

<a id="artifacts-reports-dependency_scanning"></a>

## 依赖扫描报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`dependency_scanning` 报告收集[依赖扫描漏洞](../../user/application_security/dependency_scanning/_index.md)。
收集到的依赖扫描报告作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[依赖扫描组件](../../user/application_security/dependency_scanning/_index.md)。
- 流水线的[**安全**选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [依赖列表](../../user/application_security/dependency_list/_index.md)。

<a id="artifacts-reports-dotenv"></a>

## dotenv 报告

`dotenv` 报告从文件中收集环境变量，并使它们作为 CI/CD 变量可供流水线中后续的作业使用。

更多信息，请参见 [dotenv 变量](../variables/dotenv_variables.md)。

<a id="artifacts-reports-junit"></a>

## JUnit 测试报告

`junit` 报告收集 [JUnit 报告格式 XML 文件](https://www.ibm.com/docs/en/developer-for-zos/16.0?topic=formats-junit-xml-format)。
收集到的单元测试报告作为产物上传到极狐GitLab。尽管 JUnit 最初是在 Java 中开发的，但也有许多针对其他语言（如 JavaScript、Python 和 Ruby）的第三方移植。

有关更多详细信息和示例，请参见[单元测试报告](../testing/unit_test_reports.md)。
以下示例展示了如何从 Ruby RSpec 测试中收集 JUnit XML 报告：

```yaml
rspec:
  stage: test
  script:
    - bundle install
    - rspec --format RspecJunitFormatter --out rspec.xml
  artifacts:
    reports:
      junit: rspec.xml
```

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[**测试摘要**面板](../testing/unit_test_reports.md#view-test-results-in-merge-requests)。
- [流水线的 **Tests** 选项卡](../testing/unit_test_reports.md#view-test-results-in-pipelines)。

一些 JUnit 工具会导出多个 XML 文件。你可以在单个作业中指定多个测试报告路径，将它们合并到一个文件中。使用下列任一方式：

- 文件名模式（如 `junit: rspec-*.xml`、`junit: test-results/**/*.xml`）。
- 文件名数组（如 `junit: [rspec-1.xml, rspec-2.xml, rspec-3.xml]`）。
- 两者的组合（如 `junit: [rspec.xml, test-results/TEST-*.xml]`）。
- 不支持目录（如 `junit: test-results`、`junit: test-results/**`）。

<a id="artifacts-reports-load_performance"></a>

## 负载性能报告

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

`load_performance` 报告收集[负载性能测试指标](../testing/load_performance_testing.md)，并作为产物上传。

结果显示在合并请求的[负载测试组件](../testing/load_performance_testing.md#load-performance-results-in-merge-requests)中。
不支持来自多个 `load_performance` 报告的组合结果。

<a id="artifacts-reports-metrics"></a>

## 指标报告

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

`metrics` 报告收集[指标](../testing/metrics_reports.md)。收集到的指标报告作为产物上传到极狐GitLab。

极狐GitLab 可以在合并请求的[指标报告组件](../testing/metrics_reports.md)中显示一个或多个报告的结果。

<a id="artifacts-reports-requirements"></a>

## 需求报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`requirements` 报告收集 `requirements.json` 文件。收集到的需求报告作为产物上传到极狐GitLab，并且现有的[需求](../../user/project/requirements/_index.md)被标记为“已满足”。

极狐GitLab 可以在[项目需求](../../user/project/requirements/_index.md#view-a-requirement)中显示一个或多个报告的结果。

<a id="artifacts-reports-sarif"></a>

## SARIF 报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.11 引入，有一个名为 `sarif_ingestion` 的[功能标志](../../administration/feature_flags/_index.md)，默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由一个名为 `sarif_ingestion` 的功能标志控制。更多信息，请参见历史记录。

`sarif` 报告收集来自发出 [SARIF 2.1.0](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html) 输出的工具的安全发现。
收集到的 SARIF 报告作为产物上传到极狐GitLab。

使用此报告类型来采集来自任何兼容 SARIF 的扫描器的发现，例如 Semgrep、ESLint 安全插件或 GitHub Advanced Security 工具。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 流水线的[**安全**选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。

**示例**：

```yaml
semgrep:
  image: returntocorp/semgrep
  script:
    - semgrep ci --sarif --output gl-sarif-report.sarif
  artifacts:
    reports:
      sarif: gl-sarif-report.sarif
```

<a id="artifacts-reports-sast"></a>

## SAST 报告

`sast` 报告收集 [SAST 漏洞](../../user/application_security/sast/_index.md)。
收集到的 SAST 报告作为产物上传到极狐GitLab。

更多信息，请参见：

- [查看 SAST 结果](../../user/application_security/sast/_index.md#understanding-the-results)
- [SAST 输出](../../user/application_security/sast/_index.md#download-a-sast-report)

<a id="artifacts-reports-secret_detection"></a>

## 密钥检测报告

`secret-detection` 报告收集[检测到的密钥](../../user/application_security/secret_detection/pipeline/_index.md)。
收集到的密钥检测报告会上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[密钥扫描组件](../../user/application_security/secret_detection/pipeline/_index.md)。
- [流水线安全选项卡](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表盘](../../user/application_security/security_dashboard/_index.md)。

<a id="artifacts-reports-terraform"></a>

## OpenTofu 报告

`terraform` 报告获取 OpenTofu `tfplan.json` 文件。[需要 JQ 处理以移除凭证](../../user/infrastructure/iac/mr_integration.md#configure-opentofu-report-artifacts)。
收集到的 OpenTofu 计划报告作为产物上传到极狐GitLab。

极狐GitLab 可以在合并请求的[OpenTofu 组件](../../user/infrastructure/iac/mr_integration.md#output-opentofu-plan-information-into-a-merge-request)中显示一个或多个报告的结果。

更多信息，请参见[将 `tofu plan` 信息输出到合并请求](../../user/infrastructure/iac/mr_integration.md)。