---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Measure energy consumption and carbon emissions of your CI/CD pipelines with Eco CI.
title: Eco CI
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> Eco CI 是一款与极狐GitLab CI/CD 流水线集成的第三方工具。
> 极狐GitLab 不维护也不为此工具提供支持，
> 且不保证此工具满足任何监管或合规要求。

[Eco CI](https://www.green-coding.io/products/eco-ci/) 是一款用于测量 CI/CD 流水线能量消耗和碳排放的开源工具。
它以轻量级 bash 脚本在流水线作业中运行，无需单独的服务器或数据库。

在流水线作业中，您将测量脚本放置在命令之前和之后。
该工具在命令执行期间监控 CPU 利用率，并使用来自 SPECpower 数据库的预计算功耗曲线计算能量消耗。
它将所有测量结果存储为文本文件，您可以将其保存为作业产物以供下载和查看。
您也可以将结果发送到外部仪表板进行历史分析。

<a id="add-eco-ci-to-your-pipeline"></a>

将 Eco CI 添加至您的流水线

将 Eco CI 添加至您的流水线，以便在作业执行期间测量能量消耗和碳排放。

Eco CI 使用 `ECO_CI_LABEL` 变量来识别和分组您的测量数据，
因此请选择一个能代表您的项目或流水线阶段的描述性名称。
默认情况下，测量数据会发送到 Green Coding Solutions 仪表板进行分析，
但您可以将 `ECO_CI_SEND_DATA` 设置为 `false`，以仅在本地存储结果。

先决条件：

- 运行在支持 bash 的 Runner 上的流水线作业。
- 带有 `curl`、`jq`、`awk`、`bash`、`git` 和 `coreutils` 实用程序的 Runner 环境。

要将 Eco CI 添加至您的流水线：

1. 在您的 `.gitlab-ci.yml` 文件中，包含 Eco CI 模板并配置您的项目标识符：

   ```yaml
   variables:
     ECO_CI_LABEL: "my-project-pipeline"
     ECO_CI_SEND_DATA: "false"

   include:
     - remote: 'https://raw.githubusercontent.com/green-coding-solutions/eco-ci-energy-estimation/main/eco-ci-gitlab.yml'
   ```

1. 将测量脚本添加至您的作业：

   ```yaml
   build-job:
     image: node:alpine
     before_script:
       - apk add --no-cache curl jq gawk bash git coreutils
     script:
       - !reference [.start_measurement, script]
       - npm install
       - npm run build
       - npm test
       - !reference [.get_measurement, script]
       - !reference [.display_results, script]
     artifacts:
       paths:
         - eco-ci-output.txt
         - metrics.txt
       expire_in: 1 week
   ```

1. 可选。要分别测量命令，请为每个命令使用测量脚本：

   ```yaml
   build-job:
     image: node:alpine
     before_script:
       - apk add --no-cache curl jq gawk bash git coreutils
     script:
       - !reference [.start_measurement, script]
       - npm install
       - !reference [.get_measurement, script]
       - !reference [.display_results, script]

       - !reference [.start_measurement, script]
       - npm run build
       - !reference [.get_measurement, script]
       - !reference [.display_results, script]

       - !reference [.start_measurement, script]
       - npm test
       - !reference [.get_measurement, script]
       - !reference [.display_results, script]
     artifacts:
       paths:
         - eco-ci-output.txt
         - metrics.txt
       expire_in: 1 week
   ```

<a id="view-measurement-results"></a>

查看测量结果

Eco CI 将测量结果存储在作业产物中，您可以通过极狐GitLab 界面进行访问。测量结果包括：

- 能量消耗：以焦耳和瓦特显示
- 碳排放：估计的排放量，以克二氧化碳当量 (gCO₂eq) 为单位
- 持续时间：测量时段的长度，以秒为单位
- CPU 利用率：测量期间的平均 CPU 使用率
- 软件碳强度 (SCI)：每次流水线运行的碳排放

要查看测量结果：

1. 转到您的流水线。
1. 选择包含 Eco CI 测量结果的作业。
1. 在作业详情中，在 **作业产物** 下，选择 **浏览**。
1. 打开 `eco-ci-output.txt` 文件。

示例输出：

```plaintext
"build-job: Label: my-project-pipeline: 能量消耗 [焦耳]:" 5.82
"build-job: Label: my-project-pipeline: 平均 CPU 利用率:" 22.69
"build-job: Label: my-project-pipeline: 平均功率 [瓦特]:" 1.91
"build-job: Label: my-project-pipeline: 持续时间 [秒]:" 3.04
----------------
"build-job: 能量 [焦耳]:" 5.82
"build-job: 平均 CPU 利用率:" 22.69
"build-job: 平均功率 [瓦特]:" 1.91
"build-job: 持续时间 [秒]:" 3.04
----------------
🌳 CO2 数据：
来自能源的 CO₂: 0.001944 g
来自制造（隐含碳）的 CO₂: 0.000442 g
该地区的碳强度: 334 gCO₂eq/kWh
SCI: 0.002386 gCO₂eq/每次流水线运行排放
```

<a id="dashboard-integration"></a>

仪表板集成

如果您将 `ECO_CI_SEND_DATA` 设置为 `true`，测量数据将自动发送到
[Eco CI 指标仪表板](https://metrics.green-coding.io/ci-index.html)。
该仪表板提供历史记录、趋势分析以及流水线运行之间的比较。
默认情况下，仪表板是公开的，任何人都可以查看。

您可以查看随时间变化的能量消耗趋势、碳排放模式，
并比较不同分支、提交或时间段的测量结果。
使用项目的 `ECO_CI_LABEL` 标识符访问仪表板。

<a id="add-a-badge-to-your-project"></a>

将徽章添加至您的项目

您可以在项目的 `README.md` 文件中显示 Eco CI 徽章，以展示能量消耗指标。

先决条件：

- `ECO_CI_SEND_DATA` 必须设置为 `true`。
- 至少有一个流水线在启用 Eco CI 的情况下成功运行。

要将徽章添加至 `README.md` 文件：

1. 将以下内容复制并粘贴到您的 `README.md` 文件中：

   ```markdown
   [![Eco CI](https://api.green-coding.io/v1/ci/badge/get?repo=<namespace>/<project>&branch=<branch>&workflow=<project-id>)](https://metrics.green-coding.io/ci.html?repo=<namespace>/<project>&branch=<branch>&workflow=<project-id>)
   ```

1. 替换占位符：

   - 将 `<namespace>/<project>` 替换为您的极狐GitLab 项目路径（例如 `mygroup/myproject`）
   - 将 `<branch>` 替换为您的分支名称（例如 `main`）
   - 将 `<project-id>` 替换为您的极狐GitLab 项目 ID（例如 `52215136`）

示例：

```markdown
[![Eco CI](https://api.green-coding.io/v1/ci/badge/get?repo=lyspin/eco-ci-demo&branch=main&workflow=52215136)](https://metrics.green-coding.io/ci.html?repo=lyspin/eco-ci-demo&branch=main&workflow=52215136)
```

<a id="troubleshooting"></a>

故障排除

在使用 Eco CI 时，您可能会遇到以下问题。

<a id="error-date-has-returned-a-timestamp-that-is-not-accurate-to-microseconds"></a>

错误：日期返回的时间戳不精确到微秒

您可能会收到错误消息：

```shell
ERROR: Date has returned a timestamp that is not accurate to microseconds! You may need to install `coreutils`.
```

该问题发生在使用 Alpine Linux 或其他默认不包含 GNU `coreutils` 的最小化发行版时。

要解决此问题，请安装 `coreutils`。例如，在 Alpine 中：

```yaml
before_script:
  - apk add --no-cache coreutils
```

<a id="no-measurement-data-appears-in-artifacts"></a>

作业产物中未出现测量数据

您在作业产物中未看到 `eco-ci-output.txt` 文件。

此问题可能是由于缺少产物配置造成的，因此请确保
您的作业包含正确的 `artifacts` 配置：

```yaml
artifacts:
  paths:
    - eco-ci-output.txt
    - metrics.txt
```

<a id="measurements-show-zero-energy-consumption"></a>

测量结果显示能量消耗为零

您的 `eco-ci-output.txt` 文件显示诸如 `Energy [Joules]: 0.00` 之类的值。

此问题发生在测量脚本放置不正确的情况下。

要解决此问题，请确保测量脚本在 CPU 密集型命令周围：

```yaml
script:
  - !reference [.start_measurement, script]
  - npm install  # CPU 密集型命令
  - npm run build  # CPU 密集型命令
  - !reference [.get_measurement, script]
  - !reference [.display_results, script]
```