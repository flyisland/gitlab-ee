---
stage: Verify
group: Pipeline Execution
info: 要确定与此页面关联的 Stage/Group 的指定技术文档作者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: JaCoCo 覆盖率报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.3 中引入，以一个名为 `jacoco_coverage_reports` 的功能标志禁用。默认禁用。
- 在极狐GitLab 17.6 中 GA。功能标志 `jacoco_coverage_reports` 已移除。

{{< /history >}}

为了让 JaCoCo 覆盖率报告正常工作，你必须生成一个格式正确的 [JaCoCo XML 文件](https://www.jacoco.org/jacoco/trunk/coverage/jacoco.xml)，该文件提供[行覆盖率](https://www.eclemma.org/jacoco/trunk/doc/counters.html)数据。

> [!note]
> 不支持来自多模块项目的聚合报告。要为此支持做出贡献，请参阅[议题 491015](https://gitlab.com/gitlab-org/gitlab/-/issues/491015)。

JaCoCo 覆盖率报告可视化支持：

- [指令 (C0 覆盖率)](https://www.eclemma.org/jacoco/trunk/doc/counters.html)，报告中指代 `ci`（已覆盖指令）。

覆盖率信息在合并请求差异视图中通过以下指示器展示：

- 已覆盖指令（绿色）：至少有一条已覆盖指令的行 (`ci > 0`)
- 无已覆盖指令（红色）：没有任何已覆盖指令的行 (`ci = 0`)
- 无覆盖率信息：未包含在覆盖率报告中的行

例如，使用以下报告输出：

```xml
<line nr="83" mi="2" ci="0" mb="0" cb="0"/>
<line nr="84" mi="2" ci="0" mb="0" cb="0"/>
<line nr="85" mi="2" ci="0" mb="0" cb="0"/>
<line nr="86" mi="2" ci="0" mb="0" cb="0"/>
<line nr="88" mi="0" ci="7" mb="0" cb="1"/>
```

合并请求差异视图中的覆盖率显示如下：

![合并请求差异视图显示了覆盖率指示器，其中红色条表示未覆盖行，绿色条表示已覆盖行。](img/jacoco_coverage_example_v18_3.png)

在这个示例中，第 83-86 行显示表示未覆盖代码的红色条，第 88 行显示表示已覆盖代码的绿色条，第 87、89-90 行没有覆盖率数据。

<a id="add-jacoco-coverage-job"></a>

## 添加 JaCoCo 覆盖率作业

要配置你的流水线以生成覆盖率报告，请在你的 `.gitlab-ci.yml` 文件中添加一个作业。例如：

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

在这个示例中：

- `mvn` 命令生成 JaCoCo 覆盖率报告。
- `path` 指向所生成的报告。

如果作业生成了多个报告，请在产物路径中使用[通配符](../../jobs/job_artifacts.md#with-wildcards)。

<a id="relative-file-path-correction"></a>

## 相对文件路径修正

<a id="file-path-conversion"></a>

### 文件路径转换

JaCoCo 报告提供相对文件路径，但覆盖率报告可视化需要绝对路径。极狐GitLab 尝试使用来自相关合并请求的数据将相对路径转换为绝对路径。

路径匹配过程如下：

1. 查找同一流水线引用的所有合并请求。
1. 对于所有已更改的文件，查找所有绝对路径。
1. 对于报告中的每个相对路径，使用第一个匹配的绝对路径。

此过程可能并非总能找到合适的匹配绝对路径。

<a id="multiple-modules-or-source-directories"></a>

### 多模块或源目录

对于具有相同文件名的多个模块或源目录，默认情况下可能无法找到绝对路径。

例如，如果在合并请求中更改了以下文件，极狐GitLab 无法找到绝对路径：

- `src/main/java/org/acme/DemoExample.java`
- `src/main/other-module/org/acme/DemoExample.java`

要使路径转换成功，你必须在相对路径中有一些独特的差异。例如，你可以更改其中一个文件或目录名：

- 更改文件名：

  ```diff
  src/main/java/org/acme/DemoExample.java
  - src/main/other-module/org/acme/DemoExample.java
  + src/main/other-module/org/acme/OtherDemoExample.java
  ```

- 更改路径：

  ```diff
  src/main/java/org/acme/DemoExample.java
  - src/main/other-module/org/acme/DemoExample.java
  + src/main/other-module/org/other-acme/DemoExample.java
  ```

你也可以添加一个新目录，只要完整的相对路径是唯一的即可。

<a id="troubleshooting"></a>

## 故障排除

<a id="metrics-do-not-display-for-all-changed-files"></a>

### 指标未对所有已更改文件显示

如果你从相同的源分支但不同的目标分支创建新的合并请求，指标可能无法正确显示。

作业不会考虑新合并请求中的差异，并且不会为其他合并请求差异中未包含的任何文件显示指标。即使生成的覆盖率报告包含指定文件的指标，也会发生这种情况。

要解决此问题，请等待新合并请求创建，然后重新运行你的流水线或启动一个新的流水线。然后新合并请求将被考虑在内。