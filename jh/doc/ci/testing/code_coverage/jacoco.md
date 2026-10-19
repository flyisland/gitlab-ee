---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 JaCoCo XML 报告在合并请求差异中逐行显示测试覆盖率标注。
title: JaCoCo 覆盖率可视化
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 JaCoCo 覆盖率报告在合并请求差异中逐行显示覆盖率标注。极狐GitLab 读取 JaCoCo XML 报告，并将每个变更行标注为已覆盖（绿色）或未覆盖（红色）。

覆盖率可视化使用 [`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report) 关键字。它不会在合并请求小组件中显示覆盖率百分比，也不会填充覆盖率历史图表。要显示覆盖率百分比，请单独配置 [`coverage`](../../yaml/_index.md#coverage) 关键字。

> [!note]
> 不支持来自多模块项目的聚合报告。如需为聚合报告支持做出贡献，请参见[议题 491015](https://gitlab.com/gitlab-org/gitlab/-/issues/491015)。

<a id="add-a-jacoco-coverage-job"></a>

## 添加 JaCoCo 覆盖率作业

当您希望在合并请求差异中逐行显示覆盖率标注时，请添加 JaCoCo 覆盖率作业。

先决条件：

- 格式正确的 [JaCoCo XML 文件](https://www.jacoco.org/jacoco/trunk/coverage/jacoco.xml)，提供[行覆盖率](https://www.eclemma.org/jacoco/trunk/doc/counters.html)。

要添加 JaCoCo 覆盖率作业：

1. 在`.gitlab-ci.yml` 文件中添加一个作业，将 `artifacts:reports:coverage_report`
   设置为 `jacoco`。例如：

   ```yaml
   test-jdk11:
     stage: test
     image: maven:3.6.3-jdk-11
     script:
       - mvn $MAVEN_CLI_OPTS clean org.jacoco:jacoco-maven-plugin:prepare-agent test jacoco:report
     artifacts:
       reports:
         coverage_report:
           coverage_format: jacoco
           path: target/site/jacoco/jacoco.xml
   ```

1. 将 `path` 设置为生成的 JaCoCo XML 报告的位置。

如果该作业生成多个报告，请使用[产物路径中的通配符](../../jobs/job_artifacts.md#with-wildcards)。

<a id="coverage-indicators"></a>

## 覆盖率指示器

JaCoCo 可视化使用[指令（C0 覆盖率）](https://www.eclemma.org/jacoco/trunk/doc/counters.html)，在报告中表示为 `ci`（已覆盖指令）。

流水线完成后，覆盖率会在合并请求差异视图中显示，并使用以下指示器：

- 已覆盖指令（绿色）：至少有一条已覆盖指令的行（`ci > 0`）
- 未覆盖任何指令（红色）：没有任何已覆盖指令的行（`ci = 0`）
- 无覆盖率信息：未包含在覆盖率报告中的行

例如，对于以下报告输出：

```xml
<line nr="83" mi="2" ci="0" mb="0" cb="0"/>
<line nr="84" mi="2" ci="0" mb="0" cb="0"/>
<line nr="85" mi="2" ci="0" mb="0" cb="0"/>
<line nr="86" mi="2" ci="0" mb="0" cb="0"/>
<line nr="88" mi="0" ci="7" mb="0" cb="1"/>
```

合并请求差异视图会按如下方式显示覆盖率：

![显示覆盖率指示器的合并请求差异视图，未覆盖行显示红色条，已覆盖行显示绿色条。](img/jacoco_coverage_example_v18_3.png)

在此示例中，第 83-86 行显示红色条，表示未覆盖的代码；第 88 行显示绿色条，表示已覆盖的代码；第 87、89-90 行没有覆盖率数据。

<a id="troubleshooting"></a>

## 故障排除

有关覆盖率可视化的故障排除，包括路径解析失败以及标注未按预期显示，请参见[覆盖率可视化故障排除](coverage_visualization.md#troubleshooting)。

<a id="give-feedback"></a>

## 提供反馈

JaCoCo 覆盖率可视化正在持续改进。要报告问题或提出改进建议，请在[议题 479804](https://gitlab.com/gitlab-org/gitlab/-/issues/479804)中留下您的反馈。
