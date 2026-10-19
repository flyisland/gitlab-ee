---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Carmen 测量云基础设施和应用程序的碳排放。
title: Carmen
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> Carmen 是尚未获得绿色软件基金会批准或采用的草案软件。
> 除审查当前开发状态外，请勿将 Carmen 用于任何其他目的。
> 极狐GitLab 不维护或支持此工具，
> 也不声明此工具满足任何监管或合规要求。
> Carmen 不适用于企业 ESG 报告、合规披露或营销材料。

[Carmen](https://github.com/Green-Software-Foundation/if-carmen)（碳测量引擎）
是一个开源工具，用于测量云基础设施和应用程序的碳排放。

Carmen 从两个来源测量碳排放：

- 基础设施：使用 CSV 格式的虚拟机使用数据，测量虚拟机和云工作负载的能耗和碳排放。
- 应用程序：使用 Prometheus 指标，测量 Kubernetes 集群中运行的工作负载和 Pod 的碳排放。

Carmen 输出一份 CSV 报告，您可以在 Grafana、FinOps 仪表板或您自己的工具中使用。

<a id="input-data-format"></a>

## 输入数据格式

Carmen 守护进程期望 CSV 格式的虚拟机使用数据。对于本地文件，
将 `config.yaml` 指向您的 CSV 文件所在路径。如果您使用 Azure Blob 存储，
请在 `config.yaml` 中配置您的存储账户，Carmen 将直接读取数据。

必填字段如下：

| 字段                  | 描述                                                    | 示例 |
| ---------------------- | -------------------------------------------------------------- | ------- |
| `Time`                 | ISO 8601 格式的时间戳。                                  | `2024-10-15T14:30:00Z` |
| `Id`                   | 虚拟机的唯一标识符（控制报告粒度）。    | `vm-a1b2c3d4` |
| `Size`                 | 虚拟机实例大小。                                              | `Standard_D4s_v3` |
| `Region`               | 虚拟机部署的区域。                               | `eastus` |
| `Service`              | 云服务或产品类别。                             | `Compute` |
| `Component`            | 虚拟机服务的应用层。                               | `api-gateway` |
| `Subscription`         | 云订阅标识符。                                 | `prod-subscription-001` |
| `Name`                 | 虚拟机的人类可读名称。                                        | `production-web-01` |
| `Instance`             | 部署组中虚拟机的实例标识符。            | `web-server-03` |
| `Environment`          | 部署环境。                                        | `production` |
| `Partition`            | 逻辑分区或租户。                                   | `team-finance` |
| `AverageCpuPercentage` | 测量期间的平均 CPU 利用率（0-100）。 | `45.7`  |
| `DiskSizeGb`           | 预配磁盘存储总量（以 GB 为单位）。                   | `128`   |

`Id` 字段控制报告粒度。`Id` 中的每个唯一值在输出中生成一个组件。
通常按虚拟机粒度，但您也可以根据所需洞察使用更粗（按服务）或更细的标识符。

<a id="add-carmen-to-your-pipeline"></a>

## 将 Carmen 添加到您的流水线

您可以将 Carmen 作为 CI/CD 作业运行，以从虚拟机使用数据生成碳排放报告，
并保存为流水线产物。

先决条件：

- 您的 Runner 环境中需要 Python 3.12、pip、npm、Git、`lsb-release` 和 bash。
- 虚拟机使用数据为所需格式的本地 CSV 文件。
  Carmen 也支持从 Azure Blob 存储读取。
- 位于已知路径的 `config.yaml` 文件。

要将 Carmen 添加到您的流水线：

1. 在您的 `.gitlab-ci.yml` 文件中，添加一个作业，用于安装 Carmen 并针对 Carmen 附带的示例数据运行守护进程：

   ```yaml
   carbon-report:
     image: python:3.12
     before_script:
       - apt-get update && apt-get install -y nodejs npm git lsb-release
       - git clone https://github.com/Green-Software-Foundation/if-carmen.git
       - npm install -g "@grnsft/if@1.0.0" "@grnsft/if-plugins@0.3.2" "@grnsft/if-unofficial-plugins@0.3.1"
       - pip install --upgrade pip && pip install -e $CI_PROJECT_DIR/if-carmen
     script:
       - cd $CI_PROJECT_DIR/if-carmen/example-data && carbon-daemon
     artifacts:
       paths:
         - if-carmen/example-data/output/
       expire_in: 1 week
   ```

1. 运行流水线，并确认该作业在产物中生成一个 `CO2_<date>.csv` 文件，
   且 `EnergykWh` 和 `TotalCarbonGramsCO2eq` 列中的值为非零。
1. 在您的代码仓库中添加一个指向本地 CSV 数据的 `config.yaml`：

   ```yaml
   carmen_daemon:
     source:
       type: local
       file_names:
         - "vm_metrics.csv"
       local:
         source_path: "data/vm-metrics"
     upload:
       type: local
       local:
         upload_path: "./output"
   ```

   对于 Azure Blob 存储，将 `source.type` 设置为 `azure`，并添加您的 Azure 存储账户设置和凭据。
   有关所有选项，请参阅 [Carmen 配置](https://github.com/Green-Software-Foundation/if-carmen/blob/dev/docs/configuration.md)。

1. 替换作业中的 `script` 和 `artifacts` 部分：

   ```yaml
   script:
     - mkdir -p $CI_PROJECT_DIR/output
     - cd $CI_PROJECT_DIR && carbon-daemon
   artifacts:
     paths:
       - output/
     expire_in: 1 week
   ```

1. 再次运行流水线，并确认输出 `CO2_<date>.csv` 包含您自己的数据。

<a id="view-results"></a>

## 查看结果

Carmen 生成一份 CSV 报告，每个组件（虚拟机）每天一行。输出文件
遵循命名模式 `CO2_<date>.csv`，并保存到
`upload.local.upload_path` 中配置的路径。

要查看结果：

1. 转到您的流水线。
1. 选择 `carbon-report` 作业。
1. 在 **作业产物** 下，选择 **浏览**。
1. 打开 `CO2_<date>.csv` 文件。

报告包含以下字段：

| 字段                         | 描述 |
| ----------------------------- | ----------- |
| `Date`                        | 24 小时报告时段。 |
| `Id`                          | 组件（虚拟机）的唯一标识符。 |
| `Name`                        | 虚拟机的人类可读名称。 |
| `EnergykWh`                   | 消耗的总能量（以千瓦时为单位）。 |
| `OperationalCarbonGramsCO2eq` | 运行期间能源消耗产生的碳排放。 |
| `EmbodiedCarbonGramsCO2eq`    | 硬件制造、运输和处置产生的碳排放。 |
| `TotalCarbonGramsCO2eq`       | 运行和隐含碳排放的总和。 |
| `CarbonIntensity`             | 区域电网的碳强度（gCO2eq/kWh）。 |

<a id="application-measurement"></a>

## 应用程序测量

要测量 Kubernetes 集群中单个工作负载的碳排放，您可以
将 Carmen 作为 sidecar API 服务与 Prometheus 一起部署。此模式按可配置的时间间隔拉取每个 Pod 的 CPU 和内存指标。

此部署需要具有 Helm、Prometheus、kube-state-metrics
和 cAdvisor 的 Kubernetes 集群。有关更多信息，请参阅
Carmen 代码仓库中的
[Carmen as a Service](https://github.com/Green-Software-Foundation/if-carmen/blob/dev/docs/carmen-as-a-service.md)。

<a id="troubleshooting"></a>

## 故障排查

使用 Carmen 时，您可能会遇到以下问题。

<a id="first-report-output-looks-incorrect"></a>

### 首次报告输出看起来不正确

您的碳排放值似乎异常高或低。

当 Carmen 因未提供真实虚拟机规格而回退到默认基准硬件配置时，会出现此问题。

要解决此问题，请从云提供商 API 提供真实的虚拟机规格。

<a id="output-contains-only-one-row-per-vm"></a>

### 输出仅包含每个虚拟机一行

您的报告行数少于预期。

当多条记录共享相同的 `Id` 值时，会出现此问题。

要解决此问题，请检查输入 CSV 中的 `Id` 列。
`Id` 中的每个唯一值在输出中生成一个组件。

<a id="carmen-produces-no-output"></a>

### Carmen 不产生输出

运行 `carbon-daemon` 后，输出目录为空。

此问题可能是由于 Impact Framework 未全局安装，或
`config.yaml` 中的路径无法从您运行 `carbon-daemon` 的目录解析所致。

要解决此问题：

- 验证 `@grnsft/if` 已安装且可访问：`if-run --version`
- 检查 `config.yaml` 中的路径是否可以从您的工作目录解析。

<a id="measurements-aggregate-to-daily-totals-only"></a>

### 测量仅聚合到每日总计

您需要每小时或更细粒度的碳排放值。

Carmen 仅聚合到每日总计。小时级分辨率是一个已知限制。
