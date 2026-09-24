---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Auto DevOps 的要求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在启用 [Auto DevOps](_index.md) 之前，你应该为部署做好准备。如果没有，你可以用它来构建和测试你的应用，之后再配置部署。

为准备部署：

1. 定义[部署策略](#auto-devops-deployment-strategy)。
1. 准备[基础域名](#auto-devops-base-domain)。
1. 定义你要部署到的位置：

   1. [Kubernetes](#auto-devops-requirements-for-kubernetes)。
   1. [裸金属](#auto-devops-requirements-for-bare-metal)。

1. [启用 Auto DevOps](_index.md#enable-or-disable-auto-devops)。

<a id="auto-devops-deployment-strategy"></a>

## Auto DevOps 部署策略

使用 Auto DevOps 部署应用程序时，请选择最适合你需求的[持续部署策略](../../ci/_index.md)：

| 部署策略                                                     | 设置 | 方法论 |
|-------------------------------------------------------------------------|-------|-------------|
| **持续部署到生产环境** | 启用 [Auto Deploy](stages.md#auto-deploy)，默认分支持续部署到生产环境。 | 持续部署到生产环境。|
| **使用定时增量发布持续部署到生产环境** | 将 [`INCREMENTAL_ROLLOUT_MODE`](cicd_variables.md#timed-incremental-rollout-to-production) 变量设置为 `timed`。 | 持续部署到生产环境，每次发布之间延迟 5 分钟。 |
| **自动部署到预发布环境，手动部署到生产环境** | 将 [`STAGING_ENABLED`](cicd_variables.md#deploy-policy-for-staging-and-production-environments) 设置为 `1`，[`INCREMENTAL_ROLLOUT_MODE`](cicd_variables.md#incremental-rollout-to-production) 设置为 `manual`。 | 默认分支持续部署到预发布环境，并持续交付到生产环境。 |

你可以在启用 Auto DevOps 时或之后选择部署方法：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Auto DevOps**。
1. 选择部署策略。
1. 选择 **保存更改**。

> [!note]
> 使用[蓝绿部署](../../ci/environments/incremental_rollouts.md#blue-green-deployment)技术，以最小化停机时间和风险。

<a id="auto-devops-base-domain"></a>

## Auto DevOps 基础域名

使用 [Auto Review Apps](stages.md#auto-review-apps) 和 [Auto Deploy](stages.md#auto-deploy) 需要 Auto DevOps 基础域名。

要定义基础域名，可以采用以下方式之一：

- 在项目、群组或实例级别：转到你的集群设置，并在其中添加。
- 在项目或群组级别：将其添加为环境变量：`KUBE_INGRESS_BASE_DOMAIN`。
- 在实例级别：进入 **管理员** 区域，然后 **设置** > **CI/CD** > **持续集成和交付**，并在其中添加。

基础域名变量 `KUBE_INGRESS_BASE_DOMAIN` 遵循与其他[环境变量相同的优先级顺序](../../ci/variables/_index.md#cicd-variable-precedence)。

如果你没有在项目和群组中指定基础域名，Auto DevOps 会使用实例范围的 **Auto DevOps 域名**。

Auto DevOps 需要与基础域匹配的通配符 DNS `A` 记录。对于 `example.com` 这样的基础域，你需要类似以下的 DNS 条目：

```plaintext
*.example.com   3600     A     10.0.2.2
```

在这种情况下，部署的应用程序通过 `example.com` 提供服务，而 `10.0.2.2` 是你的负载均衡器（通常是 NGINX）的 IP 地址（[参见要求](requirements.md)）。设置 DNS 记录不在本文档范围内；请咨询你的 DNS 提供商。

完成设置后，所有请求都会到达负载均衡器，负载均衡器将请求路由到运行你应用程序的 Kubernetes Pod。

<a id="auto-devops-requirements-for-kubernetes"></a>

## Auto DevOps 对 Kubernetes 的要求

要充分利用 Auto DevOps 与 Kubernetes，你需要：

- **Kubernetes**（用于 [Auto Review Apps](stages.md#auto-review-apps) 和 [Auto Deploy](stages.md#auto-deploy)）

  要启用部署，你需要：

  1. 为你的项目准备一个 [Kubernetes 1.12+ 集群](../../user/infrastructure/clusters/_index.md)。对于 Kubernetes 1.16+ 集群，你必须为 [Auto Deploy for Kubernetes 1.16+](stages.md#kubernetes-116) 执行额外配置。
  1. 对于外部 HTTP 流量，需要 Ingress 控制器。对于常规部署，任何 Ingress 控制器都应该可以工作，但从极狐GitLab 14.0 开始，[金丝雀部署](../../user/project/canary_deployments.md) 需要 NGINX Ingress。你可以通过极狐GitLab [集群管理项目模板](../../user/clusters/management_project_template.md) 或手动使用 [`ingress-nginx`](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) Helm Chart 将 NGINX Ingress 控制器部署到你的 Kubernetes 集群。

     在使用[自定义 Chart](customize.md#custom-helm-chart) 部署时，你必须使用 `prometheus.io/scrape: "true"` 和 `prometheus.io/port: "10254"` 对 Ingress 清单进行[注解](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)，以便 Prometheus 抓取。

     > [!note]
     > 如果你的集群安装在裸金属上，请参阅 [Auto DevOps 对裸金属的要求](#auto-devops-requirements-for-bare-metal)。

- **基础域名**（用于 [Auto Review Apps](stages.md#auto-review-apps) 和 [Auto Deploy](stages.md#auto-deploy)）

  你必须[指定 Auto DevOps 基础域名](#auto-devops-base-domain)，你的所有 Auto DevOps 应用程序都会使用它。该域名必须配置通配符 DNS。

- **极狐GitLab Runner**（用于所有阶段）

  你的 Runner 必须配置为运行 Docker，通常使用 [Docker](https://gitlab.cn/docs/runner/executors/docker/) 或 [Kubernetes](https://gitlab.cn/docs/runner/executors/kubernetes/) 执行器，并[启用特权模式](https://gitlab.cn/docs/runner/executors/docker/#use-docker-in-docker-with-privileged-mode)。Runner 不需要安装在 Kubernetes 集群中，但 Kubernetes 执行器易于使用并且可以自动扩缩。你也可以使用 [Docker Machine](https://gitlab.cn/docs/runner/executors/docker_machine/) 配置基于 Docker 的 Runner 进行自动扩缩。

  Runner 应注册为整个极狐GitLab 实例的[实例 Runner](../../ci/runners/runners_scope.md#instance-runners)，或分配给特定项目的[项目 Runner](../../ci/runners/runners_scope.md#project-runners)。

如果你没有配置 Kubernetes 或 Prometheus，那么 [Auto Review Apps](stages.md#auto-review-apps) 和 [Auto Deploy](stages.md#auto-deploy) 将被跳过。

满足所有要求后，你可以[启用 Auto DevOps](_index.md#enable-or-disable-auto-devops)。

<a id="auto-devops-requirements-for-bare-metal"></a>

## Auto DevOps 对裸金属的要求

根据 [Kubernetes Ingress-NGINX 文档](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/)：

> 在按需提供网络负载均衡器的传统云环境中，单个 Kubernetes 清单就足以为 NGINX Ingress 控制器提供外部客户端的单一联系点，并间接地为集群内运行的任何应用程序提供访问。裸金属环境缺乏这种便利，需要稍有不同的设置才能为外部消费者提供相同类型的访问。

前面链接的文档解释了该问题并提供了可能的解决方案，例如：

- 通过 [MetalLB](https://github.com/metallb/metallb)。
- 通过 [PorterLB](https://github.com/kubesphere/porterlb)。