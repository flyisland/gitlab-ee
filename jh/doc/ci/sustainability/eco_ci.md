---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Eco CI 测量 CI/CD 流水线的能耗和碳排放。
title: Eco CI
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> Eco CI 是一款与极狐GitLab CI/CD 流水线集成的第三方工具。
> 极狐GitLab 不维护也不为该工具提供支持，
> 且不声明该工具满足任何法规或合规要求。

[Eco CI](https://www.green-coding.io/products/eco-ci/) 是一款开源工具，用于测量 CI/CD 流水线的能耗和碳排放。

<a id="add-eco-ci-to-your-pipeline"></a>

## 将 Eco CI 添加到您的流水线

将 Eco CI 添加到您的流水线，以测量作业执行期间的能耗和碳排放。

Eco CI 使用 `ECO_CI_LABEL` 变量来标识和分组您的测量数据，因此请选择一个能代表您的项目或流水线阶段的描述性名称。默认情况下，测量数据会发送到 Green Coding Solutions 仪表板进行分析，但您可以将 `ECO_CI_SEND_DATA` 设置为 `false`，仅将结果存储在本地。

先决条件：

- 在支持 bash 的 runner 上运行的流水线作业。
- 具备 `curl`、`jq`、`awk`、`bash`、`git` 和 `coreutils` 实用工具的 runner 环境。

要将 Eco CI 添加到您的流水线：

1. 在您的 `.gitlab-ci.yml` 文件中，包含 Eco CI 模板并配置您的项目标识符：

   ```yaml
   variables:
     ECO_CI_LABEL: "my-project-pipeline"
     ECO_CI_SEND_DATA: "false"

   include:
     - remote: 'https://raw.githubusercontent.com/green-coding-solutions/eco-ci-energy-estimation/main/eco-ci-gitlab.yml'
   ```

1. 将测量脚本添加到您的作业中：

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

1. 可选。要分别测量各个命令，请为每个命令使用测量脚本：

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

## 查看测量结果

Eco CI 将测量结果存储在作业产物中，您可以通过极狐GitLab 界面访问这些产物。测量结果包括：

- 能耗：以焦耳和瓦特显示。
- 碳排放：以克二氧化碳当量（gCO₂eq）估算的排放量。
- 时长：测量时段的长度，以秒为单位。
- CPU 利用率：测量期间的平均 CPU 使用率。
- 软件碳强度（SCI）：每次流水线运行的碳排放量。

要查看测量结果：

1. 转到您的流水线。
1. 选择包含 Eco CI 测量数据的作业。
1. 在作业详情中，在**作业产物**下，选择**浏览**。
1. 打开 `eco-ci-output.txt` 文件。

输出示例：

```plaintext
"build-job: Label: my-project-pipeline: Energy Used [Joules]:" 5.82
"build-job: Label: my-project-pipeline: Avg. CPU Utilization:" 22.69
"build-job: Label: my-project-pipeline: Avg. Power [Watts]:" 1.91
"build-job: Label: my-project-pipeline: Duration [seconds]:" 3.04
----------------
"build-job: Energy [Joules]:" 5.82
"build-job: Avg. CPU Utilization:" 22.69
"build-job: Avg. Power [Watts]:" 1.91
"build-job: Duration [seconds]:" 3.04
----------------
🌳 CO2 Data:
CO₂ from energy is: 0.001944 g
CO₂ from manufacturing (embodied carbon) is: 0.000442 g
Carbon Intensity for this location: 334 gCO₂eq/kWh
SCI: 0.002386 gCO₂eq / pipeline run emitted
```

<a id="dashboard-integration"></a>

## 仪表板集成

如果您将 `ECO_CI_SEND_DATA` 设置为 `true`，测量数据会自动发送到 [Eco CI 指标仪表板](https://metrics.green-coding.io/ci-index.html)。该仪表板提供历史记录、趋势分析以及流水线运行之间的比较。默认情况下，这些仪表板是公开的，任何人都可以查看。

您可以查看能耗随时间的变化趋势、碳排放模式，并比较不同分支、提交或时间段之间的测量数据。使用您项目的 `ECO_CI_LABEL` 标识符访问该仪表板。

<a id="add-a-badge-to-your-project"></a>

### 为您的项目添加徽章

您可以在项目的 `README.md` 文件中显示 Eco CI 徽章，以展示能耗指标。

先决条件：

- `ECO_CI_SEND_DATA` 必须设置为 `true`。
- 至少有一个启用 Eco CI 的流水线必须已成功运行。

要将徽章添加到 `README.md` 文件：

1. 将以下内容复制并粘贴到您的 `README.md` 文件中：

   ```markdown
   [![Eco CI](https://api.green-coding.io/v1/ci/badge/get?repo=<namespace>/<project>&branch=<branch>&workflow=<project-id>)](https://metrics.green-coding.io/ci.html?repo=<namespace>/<project>&branch=<branch>&workflow=<project-id>)
   ```

1. 替换占位符：

   - `<namespace>/<project>` 替换为您的极狐GitLab 项目路径（例如 `mygroup/myproject`）
   - `<branch>` 替换为您的分支名称（例如 `main`）
   - `<project-id>` 替换为您的极狐GitLab 项目 ID（例如 `52215136`）

示例：

```markdown
[![Eco CI](https://api.green-coding.io/v1/ci/badge/get?repo=lyspin/eco-ci-demo&branch=main&workflow=52215136)](https://metrics.green-coding.io/ci.html?repo=lyspin/eco-ci-demo&branch=main&workflow=52215136)
```

<a id="troubleshooting"></a>

## 故障排除

使用 Eco CI 时，您可能会遇到以下问题。

<a id="error-date-has-returned-a-timestamp-that-is-not-accurate-to-microseconds"></a>

### 错误：日期返回的时间戳未精确到微秒

您可能会收到以下错误消息：

```shell
ERROR: Date has returned a timestamp that is not accurate to microseconds! You may need to install `coreutils`.
```

当使用 Alpine Linux 或其他默认不包含 GNU `coreutils`的精简发行版时，会出现此问题。

要解决此问题，请安装 `coreutils`。例如，在 Alpine 上：

```yaml
before_script:
  - apk add --no-cache coreutils
```

<a id="no-measurement-data-appears-in-artifacts"></a>

### 产物中没有出现测量数据

您在作业产物中看不到 `eco-ci-output.txt` 文件。

当作业缺少 `artifacts` 配置时，会出现此问题。

要解决此问题，请确保您的作业包含正确的 `artifacts` 配置：

```yaml
artifacts:
  paths:
    - eco-ci-output.txt
    - metrics.txt
```

<a id="measurements-show-zero-energy-consumption"></a>

### 测量结果显示能耗为零

您的 `eco-ci-output.txt` 文件显示类似 `Energy [Joules]: 0.00`的值。

当测量脚本放置位置不正确时，会出现此问题。

要解决此问题，请确保测量脚本包围 CPU 密集型命令：

```yaml
script:
  - !reference [.start_measurement, script]
  - npm install  # CPU-intensive command
  - npm run build  # CPU-intensive command
  - !reference [.get_measurement, script]
  - !reference [.display_results, script]
```
