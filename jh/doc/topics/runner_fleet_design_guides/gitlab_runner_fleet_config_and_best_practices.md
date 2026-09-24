---
stage: Verify
group: CI Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Runner Fleet.
title: 在 Google Kubernetes Engine 上设计和配置极狐GitLab Runner 集群
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用这些建议来分析您的 CI/CD 构建需求，以设计、配置和验证托管在 Google Kubernetes Engine (GKE) 上的极狐GitLab Runner 集群。

下图说明了您的 Runner 集群实施旅程的路径。本指南遵循以下步骤：

![Runner 集群步骤图](img/runner_fleet_steps_diagram_v17_5.png)

您可以使用此框架为单个群组或为整个组织提供服务的极狐GitLab 实例规划 Runner 部署。

此框架包括以下步骤：

1. [评估预期的 CI/CD 工作负载](#assess-the-expected-cicd-workloads)
1. [规划 Runner 集群配置](#plan-the-runner-fleet-configuration)
1. [在 GKE 上部署 Runner](#deploy-the-runner-on-gke)
1. [优化](#optimize)

<a id="assess-the-expected-cicd-workloads"></a>

## 评估预期的 CI/CD 工作负载

在此阶段，您收集所支持的开发团队的 CI/CD 构建需求。如果适用，创建正在使用的编程、脚本和标记语言清单。

您可能支持多个开发团队、各种编程语言和构建需求。从第一个深入分析的一个团队、一个项目、一组 CI/CD 构建需求开始。

要评估预期的 CI/CD 工作负载：

- 估算您预期支持的 CI/CD 作业需求（每小时、每天、每周）。
- 估算特定项目的代表性样本 CI/CD 作业的 CPU 和 RAM 资源需求。这些估算有助于识别您可能支持的不同配置文件。这些配置文件的特征对于确定支持您需求所需的正确 GKE 集群非常重要。请参考此示例了解如何确定 CPU 和 RAM 需求。
- 确定您是否有任何安全或策略要求，需要按群组或项目分段访问某些 Runner。

<a id="estimate-the-cpu-and-ram-requirements-for-a-cicd-job"></a>

### 估算 CI/CD 作业的 CPU 和 RAM 需求

CPU 和 RAM 资源需求因编程语言类型或 CI/CD 作业类型（构建、集成测试、单元测试、安全扫描）等因素而异。以下部分描述了一种收集 CI/CD 作业 CPU 和资源需求的方法。您可以根据自己的需求采用并构建此方法。

例如，运行类似于 FastAPI 项目分支中定义的 CI/CD 作业：[`ra-group/fastapi`](https://gitlab.com/ra-group2/fastapi)。
此示例中的作业使用 Python 镜像，下载项目需求并运行现有的单元测试。
该作业的 `.gitlab-ci.yml` 如下：

```yaml
tests:
  image: python:3.11.10-bookworm
  parallel: 25
  script:
  - pip install -r requirements.txt
  - pytest
```

要确定所需的计算和 RAM 资源，请使用 Docker：

- 创建一个使用 FastAPI 分支和 CI/CD 作业脚本作为入口点的特定镜像。
- 使用构建的镜像运行容器并监控资源使用情况。

完成以下步骤以确定所需的计算和 RAM 资源：

1. 在您的项目中创建一个包含所有 CI 命令的脚本文件。该脚本文件名为 `entrypoint.sh`。

   ```shell
   #!/bin/bash
   cd /fastapi || exit
   pip install -r requirements.txt
   pytest
   ```

1. 创建一个 Dockerfile 来创建一个镜像，其中 `entrypoint.sh` 文件运行 CI 脚本。

   ```dockerfile
   FROM python:3.11.10-bookworm
   RUN mkdir /fastapi
   COPY . /fastapi
   RUN chmod +x /fastapi/entrypoint.sh
   CMD [ "bash", "/fastapi/entrypoint.sh" ]
   ```

1. 构建镜像。为简化流程，所有操作（如构建、存储和运行镜像）均在本地执行。此方法无需在线镜像仓库来拉取和推送镜像。

   ```shell
   ❯ docker build . -t my-project_dir/fastapi:testing
   ...
   Successfully tagged my-project_dir/fastapi:testing
   ```

1. 使用构建的镜像运行容器，同时在容器执行期间监控资源使用情况。创建一个名为 `metrics.sh` 的脚本，包含以下命令：

   ```shell
   #! /bin/bash

   container_id=$(docker run -d --rm my-project_dir/fastapi:testing)

   while true; do
       echo "Collecting metrics..."
       metrics=$(docker stats --no-trunc --no-stream --format "table {{.ID}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep "$container_id")
       if [ -z "$metrics" ]; then
           exit 0
       fi
       echo "Saving metrics..."
       echo "$metrics" >> metrics.log
       sleep 1
   done
   ```

   此脚本使用构建的镜像运行一个分离的容器。然后使用容器 ID 收集其 `CPU` 和 `Memory` 使用情况，直到容器成功完成退出。收集的指标保存在名为 `metrics.log` 的文件中。

   > [!note]
   > 在此示例中，CI/CD 作业是短暂的，因此每次容器轮询之间的休眠设置为一秒。请调整此值以更好地满足您的需求。
1. 分析 `metrics.log` 文件以识别测试容器的峰值使用情况。

   在此示例中，最大 CPU 使用率为 `107.50%`，最大内存使用率为 `303.1Mi`。

   ```log
   223e93dd05c6   94.98%    83.79MiB / 15.58GiB
   223e93dd05c6   28.27%    85.4MiB / 15.58GiB
   223e93dd05c6   53.92%    121.8MiB / 15.58GiB
   223e93dd05c6   70.73%    171.9MiB / 15.58GiB
   223e93dd05c6   20.78%    177.2MiB / 15.58GiB
   223e93dd05c6   26.19%    180.3MiB / 15.58GiB
   223e93dd05c6   77.04%    224.1MiB / 15.58GiB
   223e93dd05c6   97.16%    226.5MiB / 15.58GiB
   223e93dd05c6   98.52%    259MiB / 15.58GiB
   223e93dd05c6   98.78%    303.1MiB / 15.58GiB
   223e93dd05c6   100.03%   159.8MiB / 15.58GiB
   223e93dd05c6   103.97%   204MiB / 15.58GiB
   223e93dd05c6   107.50%   207.8MiB / 15.58GiB
   223e93dd05c6   105.96%   215.7MiB / 15.58GiB
   223e93dd05c6   101.88%   226.2MiB / 15.58GiB
   223e93dd05c6   100.44%   226.7MiB / 15.58GiB
   223e93dd05c6   100.20%   226.9MiB / 15.58GiB
   223e93dd05c6   100.60%   227.6MiB / 15.58GiB
   223e93dd05c6   100.46%   228MiB / 15.58GiB
   ```

<a id="analyzing-the-metrics-collected"></a>

### 分析收集的指标

根据收集的指标，对于此作业配置文件，您可以将 Kubernetes 执行器作业限制为 `1 CPU` 和 `~304 Mi` 内存。即使此结论准确，也可能不适用于所有用例。

如果您使用具有三个 `e2-standard-4` 节点池的集群来运行作业，则 `1 CPU` 限制仅允许同时运行 12 个作业（`e2-standard-4` 节点具有 4 个 vCPU 和 16 GB 内存）。其他作业将等待正在运行的作业完成并释放资源后才能启动。

请求的内存至关重要，因为 Kubernetes 会终止任何使用超过设置限制或集群可用内存的 Pod。然而，CPU 限制更灵活，但会影响作业持续时间。设置较低的 CPU 限制会增加作业完成所需的时间。在前面的示例中，将 CPU 限制设置为 `250m`（或 `0.25`）而不是 `1`，会使作业持续时间增加四倍（从大约两分钟增加到八到十分钟）。

由于指标收集方法使用轮询机制，您应该将确定的最大使用量向上取整。例如，对于内存使用量，不要使用 `303 Mi`，而是取整为 `400 Mi`。

前面示例的重要注意事项：

- 指标是在本地机器上收集的，该机器的 CPU 配置与 Google Kubernetes Engine 集群不同。但是，这些指标已通过在一个具有 `e2-standard-4` 节点的 Kubernetes 集群上进行监控而得到验证。
- 要获得这些指标的准确表示，请在 Google Compute Engine VM 上运行[评估阶段](#assess-the-expected-cicd-workloads)中描述的测试。

<a id="plan-the-runner-fleet-configuration"></a>

## 规划 Runner 集群配置

在规划阶段，为您的组织规划合适的 Runner 集群配置。根据以下因素考虑 Runner 范围（实例、群组、项目）和 Kubernetes 集群配置：

- 您对 CI/CD 作业资源需求的评估
- 您的 CI/CD 作业类型清单

<a id="runner-scope"></a>

### Runner 范围

要规划 Runner 范围，请考虑以下问题：

- 您是否希望项目所有者和群组所有者创建和管理自己的 Runner？

  - 默认情况下，项目所有者和群组所有者可以创建 Runner 配置，并将 Runner 注册到极狐GitLab 中的项目或群组。
  - 这种设计允许开发者快速创建构建环境。这种方法减少了开发者开始使用极狐GitLab CI/CD 时的摩擦。但是，在大型组织中，这种方法可能导致环境中出现许多未充分利用或未使用的 Runner。
- 您的组织是否有安全或其他策略要求将某些类型的 Runner 的访问权限分段到特定群组或项目？

在极狐GitLab 私有化部署环境中部署 Runner 的最直接方法是将其创建为实例。默认情况下，范围为实例的 Runner 可用于所有群组和项目。

如果您可以使用实例 Runner 满足组织的所有需求，那么这种部署模式是最有效的模式。它确保您可以高效且经济地大规模运营 CI/CD 构建集群。

如果有要求将特定 Runner 的访问权限分段到某些群组或项目，请将这些要求纳入您的规划过程。

<a id="example-runner-fleet-configuration---instance-runners"></a>

#### 示例 Runner 集群配置 - 实例 Runner

表中的配置展示了在为您的组织配置 Runner 集群时可用的灵活性。此示例使用具有不同实例大小和不同作业标签的多个 Runner。这些 Runner 使您能够支持不同类型的 CI/CD 作业，每种作业都有特定的 CPU 和 RAM 资源需求。但是，在使用 Kubernetes 时，这可能不是最有效的模式。

| Runner 类型 | Runner 标签       | 范围                                                               | 提供的 Runner 类型数量 | Runner Worker 规格 | Runner 主机环境 | 环境配置 |
|:------------|:-----------------|:--------------------------------------------------------------------|:------------------------------|:----------------------------|:------------------------|:--------------------------|
| 实例    | ci-runner-small  | 默认可用于所有群组和项目的 CI/CD 作业。 | 5                             | 2 vCPU，8 GB RAM            | Kubernetes              | → 3 个节点 <br> → Runner worker 计算节点 = `e2-standard-2` |
| 实例    | ci-runner-medium | 默认可用于所有群组和项目的 CI/CD 作业。 | 2                             | 4 vCPU，16 GB RAM           | Kubernetes              | → 3 个节点 <br> → Runner worker 计算节点 = `e2-standard-4` |
| 实例    | ci-runner-large  | 默认可用于所有群组和项目的 CI/CD 作业。 | 1                             | 8 vCPU，32 GB RAM           | Kubernetes              | → 3 个节点 <br> → Runner worker 计算节点 = `e2-standard-8` |

在 Runner 集群配置示例中，共有三个 Runner 配置和八个 Runner 正在积极运行 CI/CD 作业。

使用 Kubernetes 执行器，您可以使用 Kubernetes 调度器并覆盖容器资源。
理论上，您可以在具有足够资源的 Kubernetes 集群上部署单个极狐GitLab Runner。然后，您可以覆盖容器资源，为每个 CI/CD 作业选择适当的计算类型。
实施此模式可减少您需要部署和操作的独立 Runner 配置的数量。

<a id="best-practices"></a>

### 最佳实践

- 始终为 Runner Manager 专用一个节点池。
  - 日志处理以及缓存或产物管理可能占用大量 CPU。
- 始终在 `config.toml` 文件中设置默认限制（构建/辅助/服务容器的 CPU/内存）。
- 始终在 `config.toml` 文件中允许最大资源覆盖。
- 在作业定义（`.gitlab-ci.yml`）中，指定作业所需的正确限制。
  - 如果未指定，则使用 `config.toml` 文件中设置的默认值。
  - 如果容器超出其内存限制，系统会使用内存不足（OOM）终止进程自动终止它。
- 使用功能标志 `FF_RETRIEVE_POD_WARNING_EVENTS` 和 `FF_PRINT_POD_EVENTS`。有关更多详细信息，请参阅[功能标志文档](https://gitlab.cn/docs/runner/configuration/feature-flags/)。

<a id="deploy-the-runner-on-gke"></a>

## 在 GKE 上部署 Runner

当您准备好在 Google Kubernetes 集群上安装极狐GitLab Runner 时，您有很多选择。如果您已在 GKE 上创建了集群，则可以使用极狐GitLab Runner Helm Chart 或 Operator 在集群上安装 Runner。

如果您尚未在 GKE 上设置集群，极狐GitLab 提供了极狐GitLab Runner Infrastructure Toolkit (GRIT)，它可以同时：

- 创建一个多节点池 GKE 集群：标准版和标准模式。
- 使用极狐GitLab Runner Kubernetes operator 在集群上安装极狐GitLab Runner

以下示例使用 GRIT 部署 Google Kubernetes 集群和极狐GitLab Runner Manager。

要正确配置集群和极狐GitLab Runner，请考虑以下信息：

- 我需要覆盖多少种作业类型？
  - 此信息来自评估阶段。评估阶段汇总指标，并考虑组织约束，确定结果组的数量。
    “作业类型”是在访问阶段识别出的分类作业的集合。
    此分类基于作业所需的最大资源。
- 我需要运行多少个极狐GitLab Runner Manager？
  - 此信息来自规划阶段。如果组织单独管理项目，请将此框架单独应用于每个项目。仅当识别出多个作业配置文件（针对整个组织或特定项目），并且它们都由单个或一组极狐GitLab Runner 处理时，此方法才相关。基本配置通常每个 GKE 集群使用一个极狐GitLab Runner Manager。
- 估计的最大并发 CI/CD 作业数是多少？
  - 此信息表示在任何时间点运行的最大并发 CI/CD 作业数的估计值。配置极狐GitLab Runner Manager 时需要此信息，以提供它在 `Prepare` 阶段等待的时间：在可用资源有限的节点上调度作业 Pod。

<a id="real-life-applications-for-the-fastapi-fork"></a>

### FastAPI 分支的实际应用

对于 FastAPI 分支，请考虑以下信息：

- 我需要覆盖多少个作业配置文件？
  - 您有一个具有以下特征的作业配置文件：`1 CPU` 和 `303 Mi` 内存。
    如[分析收集的指标](#analyzing-the-metrics-collected)部分所述，这些原始值更改为：
    - 内存限制为 `400 Mi` 而不是 `303 Mi`，以避免因内存限制导致任何作业失败。
    - CPU 为 `0.20` 而不是 `1 CPU`。对于此示例，您优先考虑完成任务的准确性和质量，而不是速度。
- 我需要运行多少个极狐GitLab Runner Manager？
  - 对于您的测试，只需要一个极狐GitLab Runner Manager。
- 预期的工作负载是多少？
  - 您希望在任何时间最多同时运行 20 个作业。

基于这些输入，任何具有以下最低特性的 GKE 集群应该足够：

- 最低 CPU：`(0.20 + 辅助 CPU 使用量) * 同时作业数`。在此示例中，将辅助容器限制设置为 `0.15 CPU`，您将获得 `7 vCPU`。
- 最低内存：`(400Mi + 辅助内存使用量) * 同时作业数`。在此示例中，将辅助限制设置为 `100 Mi`，您将获得至少 `10 Gi`。

还应考虑其他特性，例如所需的最低存储。但是，该示例未考虑这一点。

我们的 GKE 集群的可能配置可以是（两种配置都允许运行超过 20 个同时作业）：

- 具有 `3 个 e2-standard-4` 节点池的 GKE 集群，总计 `12 vCPU` 和 `48 GiB` 内存
- 仅具有一个 `e2-standard-8` 节点池的 GKE 集群，总计 `8 vCPU` 和 `32 GiB` 内存

此示例中使用第一种配置。为防止极狐GitLab Runner Manager 的日志处理影响整体日志处理，请使用安装极狐GitLab Runner 的专用节点池。

<a id="gke-grit-configuration"></a>

#### GKE GRIT 配置

GRIT 的最终 GKE 配置类似于以下内容：

```terraform
google_project     = "GCLOUD_PROJECT"
google_region      = "GCLOUD_REGION"
google_zone        = "GCLOUD_ZONE"
name               = "my-grit-gke-cluster"
node_pools = {
  "runner-manager" = {
    node_count = 1,
    node_config = {
      machine_type = "e2-standard-2",
      image_type   = "cos_containerd",   #仅限 Linux OS 容器。对于 Windows OS 容器，更改为 windows_ltsc_containerd
      disk_size_gb = 50,
      disk_type    = "pd-balanced",
      labels = {
        "app" = "gitlab-runner",
      }
    },
  },
  "worker-pool" = {
    node_count = 3,
    node_config = {
      machine_type = "e2-standard-4",    #每个 4 vCPU，16 GB
      image_type   = "cos_containerd",   #仅限 Linux OS 容器。对于 Windows OS 容器，更改为 windows_ltsc_containerd
      disk_size_gb = 150,
      disk_type    = "pd-balanced",
      labels = {
        "app" = "gitlab-runner-job"
      }
    },
  },
}
```

在前面的配置中：

- `runner-manager` 块指的是安装极狐GitLab Runner 的节点池。在我们的示例中，`e2-standard-2` 绰绰有余。
- `runner-manager` 块中的标签部分在极狐GitLab 上安装极狐GitLab Runner 时很有用。通过 operator 配置配置节点选择器，以确保极狐GitLab Runner 安装在此节点池的节点上。
- `worker-pool` 块指的是创建 CI/CD 作业 Pod 的节点池。提供的配置创建了一个具有 `3 个 e2-standard-4` 节点的节点池，标记为 `"app" = "gitlab-runner-job"`，用于托管作业 Pod。
- `image_type` 参数可用于设置节点使用的镜像。如果您的工作负载主要依赖于 Windows 镜像，则可以将其设置为 `windows_ltsc_containerd`。

以下是此配置的图示：

![配置集群图示](img/nodepool_illustration_example_v17_5.png)

<a id="gitlab-runner-grit-configuration"></a>

#### 极狐GitLab Runner GRIT 配置

GRIT 的最终极狐GitLab Runner 配置类似于以下内容：

```terraform
gitlab_pat         = "glpat-REDACTED"
gitlab_project_id  = GITLAB_PROJECT_ID
runner_description = "my-grit-gitlab-runner"
runner_image       = "registry.gitlab.com/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-ocp:amd64-v17.3.1"
helper_image       = "registry.gitlab.com/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-helper-ocp:x86_64-v17.3.1"
concurrent     = 20
check_interval = 1
runner_tags    = ["my-custom-tag"]
config_template    = <<EOT
[[runners]]
  name = "my-grit-gitlab-runner"
  shell = "bash"
  environment = [
    "FF_RETRIEVE_POD_WARNING_EVENTS=true",
    "FF_PRINT_POD_EVENTS=true",
  ]
  [runners.kubernetes]
    image = "alpine"
    cpu_limit = "0.25"
    memory_limit = "400Mi"
    helper_cpu = "150m"
    helper_memory = "150Mi"
    cpu_limit_overwrite_max_allowed = "0.25"
    memory_limit_overwrite_max_allowed = "400Mi"
    helper_cpu_limit_overwrite_max_allowed = "150m"
    helper_memory_limit_overwrite_max_allowed = "150Mi"
  [runners.kubernetes.node_selector]
    "app" = "gitlab-runner-job"
EOT
pod_spec = [
  {
    name      = "selector",
    patchType = "merge",
    patch     = <<EOT
nodeSelector:
  app: "gitlab-runner"
EOT
  }
]
```

在前面的配置中：

- `pod_spec` 参数允许我们为运行极狐GitLab Runner 的 Pod 设置节点选择器。在配置中，节点选择器设置为 `"app" = "gitlab-runner"`，以确保极狐GitLab Runner 安装在 runner-manager 节点池上。
- `config_template` 参数为极狐GitLab Runner Manager 运行的所有作业提供默认限制。它还允许覆盖这些限制，只要设置的值不大于默认值。
- 还设置了功能标志 `FF_RETRIEVE_POD_WARNING_EVENTS` 和 `FF_PRINT_POD_EVENTS`，以便在作业失败时简化调试。有关更多详细信息，请参阅[功能标志文档](https://gitlab.cn/docs/runner/configuration/feature-flags/)。

<a id="real-life-applications-for-a-hypothetical-use-case"></a>

### 假设用例的实际应用

请考虑以下信息：

- 我需要覆盖多少个作业配置文件？
  - 两个配置文件（提供的规格已考虑辅助限制）：
    - 中等作业：`300m CPU` 和 `200 MiB`
    - CPU 密集型作业：`1 CPU` 和 `1 GiB`
- 我需要运行多少个极狐GitLab Runner Manager？
  - 一个。
- 预期的工作负载是多少？
  - 最多同时 50 个中等作业
  - 最多同时 25 个 CPU 密集型作业

<a id="gke-configuration"></a>

#### GKE 配置

- 中等作业的需求：
  - CPU：`300m * 50 = 5 CPU`（近似值）
  - 内存：`200 MiB * 50 = 10 GiB`
- CPU 密集型作业的需求：
  - CPU：`1 * 25 = 25`
  - 内存：`1 GiB * 25 = 25 GiB`

GKE 集群应具有：

- 一个用于极狐GitLab Runner Manager 的节点池（假设日志处理要求不高）：**1 个 e2-standard-2** 节点
- 一个用于中等作业的节点池：3 个 `e2-standard-4` 节点
- 一个用于 CPU 密集型作业的节点池：1 个 `e2-highcpu-32` 节点（`32 vCPU` 和 `32 GiB` 内存）

```terraform
google_project     = "GCLOUD_PROJECT"
google_region      = "GCLOUD_REGION"
google_zone        = "GCLOUD_ZONE"
name               = "my-grit-gke-cluster"
node_pools = {
  "runner-manager" = {
    node_count = 1,
    node_config = {
      machine_type = "e2-standard-2",
      image_type   = "cos_containerd",   #仅限 Linux OS 容器。对于 Windows OS 容器，更改为 windows_ltsc_containerd
      disk_size_gb = 50,
      disk_type    = "pd-balanced",
      labels = {
        "app" = "gitlab-runner",
      }
    },
  },
  "medium-pool" = {
    node_count = 3,
    node_config = {
      machine_type = "e2-standard-4",    #每个 4 vCPU，16 GB
      image_type   = "cos_containerd",   #仅限 Linux OS 容器。对于 Windows OS 容器，更改为 windows_ltsc_containerd
      disk_size_gb = 150,
      disk_type    = "pd-balanced",
      labels = {
        "app" = "gitlab-runner-job"
      }
    },
  },
  "cpu-intensive-pool" = {
    node_count = 1,
    node_config = {
      machine_type = "e2-highcpu-32", #每个 32 vCPU，32 GB
      image_type   = "cos_containerd",
      disk_size_gb = 150,
      disk_type    = "pd-balanced",
      labels = {
        "app" = "gitlab-runner-job"
      }
    },
  },
}
```

<a id="gitlab-runner-configuration"></a>

#### 极狐GitLab Runner 配置

GRIT 的当前实现不允许一次安装多个 Runner。提供的 `config_template` 未设置像前面示例中那样的 `node_selection` 和其他限制。一个简单的配置允许 CPU 密集型作业的最大允许覆盖值，并在 `.gitlab-ci.yml` 文件中设置正确的值。最终的极狐GitLab Runner 配置类似于以下内容：

```terraform
gitlab_pat         = "glpat-REDACTED"
gitlab_project_id  = GITLAB_PROJECT_ID
runner_description = "my-grit-gitlab-runner"
runner_image       = "registry.gitlab.com/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-ocp:amd64-v17.3.1"
helper_image       = "registry.gitlab.com/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-helper-ocp:x86_64-v17.3.1"
concurrent     = 100
check_interval = 1
runner_tags    = ["my-custom-tag"]
config_template    = <<EOT
[[runners]]
  name = "my-grit-gitlab-runner"
  shell = "bash"
  environment = [
    "FF_RETRIEVE_POD_WARNING_EVENTS=true",
    "FF_PRINT_POD_EVENTS=true",
  ]
  [runners.kubernetes]
    image = "alpine"
    cpu_limit_overwrite_max_allowed = "0.75"
    memory_limit_overwrite_max_allowed = "900Mi"
    helper_cpu_limit_overwrite_max_allowed = "250m"
    helper_memory_limit_overwrite_max_allowed = "100Mi"
EOT
pod_spec = [
  {
    name      = "selector",
    patchType = "merge",
    patch     = <<EOT
nodeSelector:
  app: "gitlab-runner"
EOT
  }
]
```

`.gitlab-ci.yml` 文件类似于以下内容：

- 对于中等作业：

  ```yaml
  variables:
    KUBERNETES_CPU_LIMIT: "200m"
    KUBERNETES_MEMORY_LIMIT: "100Mi"
    KUBERNETES_HELPER_CPU_LIMIT: "100m"
    KUBERNETES_HELPER_MEMORY_LIMIT: "100Mi"

  tests:
    image: some-image:latest
    script:
    - command_1
    - command_2
    # ...
    - command_n
    tags:
      - my-custom-tag
  ```

- 对于 CPU 密集型作业：
```yaml
  variables:
    KUBERNETES_CPU_LIMIT: "0.75"
    KUBERNETES_MEMORY_LIMIT: "900Mi"
    KUBERNETES_HELPER_CPU_LIMIT: "150m"
    KUBERNETES_HELPER_MEMORY_LIMIT: "100Mi"

  tests:
    image: custom-cpu-intensive-image:latest
    script:
    - cpu_intensive_command_1
    - cpu_intensive_command_2
    # ...
    - cpu_intensive_command_n
    tags:
      - my-custom-tag
  ```

> [!note]
> 为了更简单的配置，为每个任务配置文件使用一个 GitLab Runner 每个集群。在极狐GitLab 支持在同一集群上安装多个 GitLab Runner 或在 `config.toml` 模板中支持多个 `[[runners]]` 部分之前，推荐使用此方法。

### 设置监控和可观测性

作为部署阶段的最后一步，你必须建立一套解决方案来监控 Runner 主机环境和 GitLab Runner。基础设施层、Runner 和 CI/CD 任务指标可以让你深入了解 CI/CD 构建基础设施的效率和可靠性。它们还提供了调整和优化 Kubernetes 集群、GitLab Runner 和 CI/CD 任务配置所需的洞察。

#### 监控最佳实践

- 监控任务级指标：任务持续时间、任务成功率和失败率。
  - 要分析任务级指标，请了解哪些 CI/CD 任务运行最频繁，以及总体上消耗最多的计算和 RAM 资源。此任务配置文件是评估优化机会的良好起点。
- 监控 Kubernetes 集群资源利用率：
  - CPU 利用率
  - 内存利用率
  - 网络利用率
  - 磁盘利用率

请参阅 [GitLab Runner 监控页面](https://gitlab.cn/docs/runner/monitoring/) 了解更多详情。

## 优化

优化 CI/CD 构建环境是一个持续的过程。CI/CD 任务的类型和数量在不断发展，需要你的积极参与。

你可能对 CI/CD 和 CI/CD 构建基础设施有特定的组织目标。因此，第一步是定义你的优化需求和可量化的目标。

以下是我们客户群中一组示例优化需求：

- CI/CD 任务启动时间
- CI/CD 任务持续时间
- CI/CD 任务可靠性
- CI/CD 计算成本优化

下一步是开始结合 Kubernetes 集群的基础设施指标分析 CI/CD 指标。需要分析的一个关键关联如下：

- 按 Kubernetes 命名空间划分的 CPU 利用率
- 按 Kubernetes 命名空间划分的内存利用率
- 按节点划分的 CPU 利用率
- 按节点划分的内存利用率
- CI/CD 任务失败率

通常在 Kubernetes 上，高 CI/CD 任务失败率（独立于因不稳定测试导致的失败）归因于 Kubernetes 集群的资源限制。分析这些指标，以在你的 Kubernetes 集群配置中实现 CI/CD 任务启动时间、任务持续时间、任务可靠性和基础设施资源利用率的最佳平衡。

### 最佳实践

- 建立一个流程，按任务类型对组织内的 CI/CD 任务进行分类。
- 建立一个任务类型分类框架，以简化对 Kubernetes 上的极狐GitLab CI/CD 构建基础设施和 CI/CD 任务类型的监控配置和优化方法。
- 为每种任务类型在集群上分配自己的节点，可能会在 CI/CD 任务性能、任务可靠性和基础设施利用率之间实现最佳平衡。

使用 Kubernetes 作为 CI/CD 构建环境的基础设施堆栈具有显著优势。但是，它需要持续监控和优化 Kubernetes 基础设施。建立可观测性和优化框架后，你可以支持每月数百万个 CI/CD 任务。你可以消除资源争用，实现确定性的 CI/CD 任务运行和最佳资源使用。这些改进可带来运营效率和成本优化。

## 后续步骤

采取以下步骤以提供更好的用户体验：

- 支持在同一集群上安装多个 GitLab Runner。这样可以更好地管理需要处理多个任务配置文件的场景（可以适当配置 GitLab Runner 以防止任何资源滥用）。
- 启用任务指标监控。这使管理员能够根据实际使用情况更好地优化其集群和 GitLab Runner。