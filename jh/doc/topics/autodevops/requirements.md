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

在启用 [Auto DevOps](_index.md) 之前，您应该先为部署做好准备。如果不这样做，您仍然可以使用它来构建和测试应用，之后再配置部署。

要准备部署：

1. 定义[部署策略](#auto-devops-deployment-strategy)。
1. 准备[基础域名](#auto-devops-base-domain)。
1. 定义您希望部署到哪里：

   1. [Kubernetes](#auto-devops-requirements-for-kubernetes)。
   1. [Amazon Elastic Container Service (ECS)](cloud_deployments/auto_devops_with_ecs.md)。
   1. [Amazon Elastic Kubernetes Service (EKS)](https://about.gitlab.com/blog/deploying-application-eks/)。
   1. [Amazon EC2](cloud_deployments/auto_devops_with_ec2.md)。
   1. [Google Kubernetes Engine](cloud_deployments/auto_devops_with_gke.md)。
   1. [裸金属](#auto-devops-requirements-for-bare-metal)。

1. [启用 Auto DevOps](_index.md#enable-or-disable-auto-devops)。

<a id="auto-devops-deployment-strategy"></a>

## Auto DevOps 部署策略

使用 Auto DevOps 部署应用时，请选择最符合您需求的[持续部署策略](../../ci/_index.md)：

| 部署策略                                                     | 设置 | 方法 |
|-------------------------------------------------------------------------|-------|-------------|
| **持续部署到生产环境**                                 | 启用 [Auto Deploy](stages.md#auto-deploy)，并将默认分支持续部署到生产环境。 | 持续部署到生产环境。|
| **使用定时增量发布持续部署到生产环境** | 将 [`INCREMENTAL_ROLLOUT_MODE`](cicd_variables.md#timed-incremental-rollout-to-production) 变量设置为 `timed`。 | 持续部署到生产环境，每次发布之间间隔 5 分钟。 |
| **自动部署到预发布环境，手动部署到生产环境**    | 将 [`STAGING_ENABLED`](cicd_variables.md#deploy-policy-for-staging-and-production-environments) 设置为 `1`，并将 [`INCREMENTAL_ROLLOUT_MODE`](cicd_variables.md#incremental-rollout-to-production) 设置为 `manual`。 | 默认分支持续部署到预发布环境，并持续交付到生产环境。 |

您可以在启用 Auto DevOps 时或之后选择部署方法：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Auto DevOps**。
1. 选择部署策略。
1. 选择**保存更改**。

> [!note]
> 使用[蓝绿部署](../../ci/environments/incremental_rollouts.md#blue-green-deployment)技术
> 来最大限度地减少停机时间和风险。

<a id="auto-devops-base-domain"></a>

## Auto DevOps 基础域名

使用 [Auto Review Apps](stages.md#auto-review-apps) 和 [Auto Deploy](stages.md#auto-deploy) 需要 Auto DevOps 基础域名。

要定义基础域名，您可以：

- 在项目、群组或实例级别：转到集群设置并在那里添加。
- 在项目或群组级别：将其添加为环境变量：`KUBE_INGRESS_BASE_DOMAIN`。
- 在实例级别：转到**管理**区域，然后选择 **设置** > **CI/CD** > **持续集成和交付** 并在那里添加。

基础域名变量 `KUBE_INGRESS_BASE_DOMAIN` 遵循与其他环境变量相同的[优先级顺序](../../ci/variables/_index.md#cicd-variable-precedence)。

如果您没有在项目和群组中指定基础域名，Auto DevOps 将使用实例范围的 **Auto DevOps 域**。

Auto DevOps 需要一条与基础域名匹配的通配符 DNS `A` 记录。对于基础域名 `example.com`，您需要如下 DNS 条目：

```plaintext
*.example.com   3600     A     10.0.2.2
```

在这种情况下，部署的应用将从 `example.com` 提供服务，而 `10.0.2.2` 是您的负载均衡器的 IP 地址，通常是 NGINX（请参阅要求）。设置 DNS 记录超出了本文档的范围；请咨询您的 DNS 提供商以获取相关信息。

或者，您可以使用像 [nip.io](https://nip.io) 这样的免费公共服务，它无需任何配置即可提供自动通配符 DNS。对于 [nip.io](https://nip.io)，将 Auto DevOps 基础域名设置为 `10.0.2.2.nip.io`。

完成设置后，所有请求都会到达负载均衡器，由它将请求路由到运行您应用的 Kubernetes pod。

<a id="auto-devops-requirements-for-kubernetes"></a>

## Kubernetes 的 Auto DevOps 要求

要充分利用 Kubernetes 上的 Auto DevOps，您需要：

- **Kubernetes**（用于 [Auto Review Apps](stages.md#auto-review-apps) 和
  [Auto Deploy](stages.md#auto-deploy)）

  要启用部署，您需要：

  1. 为您的项目准备一个 [Kubernetes 1.12+ 集群](../../user/infrastructure/clusters/_index.md)。
     对于 Kubernetes 1.16+ 集群，您必须为
     [Kubernetes 1.16+ 的 Auto Deploy](stages.md#kubernetes-116) 执行额外配置。
  1. 对于外部 HTTP 流量，需要 Ingress 控制器。对于常规
     部署，任何 Ingress 控制器都应该可以工作，但
     [金丝雀部署](../../user/project/canary_deployments.md)需要
     NGINX Ingress。您可以通过极狐GitLab [集群管理项目模板](../../user/clusters/management_project_template.md)
     将 NGINX Ingress 控制器部署到您的
     Kubernetes 集群，也可以使用 [`ingress-nginx`](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx)
     Helm Chart 手动部署。

     当[使用自定义 chart](customize.md#custom-helm-chart) 部署时，您必须
     [注解](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
     Ingress 清单，以便 Prometheus 使用
     `prometheus.io/scrape: "true"` 和 `prometheus.io/port: "10254"` 抓取它。

     > [!note]
     > 如果您的集群安装在裸金属上，请参阅
     > [裸金属的 Auto DevOps 要求](#auto-devops-requirements-for-bare-metal)。

- **基础域名**（用于 [Auto Review Apps](stages.md#auto-review-apps) 和
  [Auto Deploy](stages.md#auto-deploy)）

  您必须[指定 Auto DevOps 基础域名](#auto-devops-base-domain)，
  您的所有 Auto DevOps 应用都使用该域名。此域名必须配置
  通配符 DNS。
- **极狐GitLab Runner**（用于所有阶段）

  您的 runner 必须配置为运行 Docker，通常使用
  [Docker](https://gitlab.cn/docs/runner/executors/docker/)
  或 [Kubernetes](https://gitlab.cn/docs/runner/executors/kubernetes/) 执行器，并
  [启用特权模式](https://gitlab.cn/docs/runner/executors/docker/#use-docker-in-docker-with-privileged-mode)。
  runner 不需要安装在 Kubernetes 集群中，但
  Kubernetes 执行器易于使用且会自动扩缩。
  您也可以使用
  [Docker Machine](https://gitlab.cn/docs/runner/executors/docker_machine/) 将基于 Docker 的 runner 配置为自动扩缩。

  Runner 应注册为整个极狐GitLab 实例的[实例 runner](../../ci/runners/runners_scope.md#instance-runners)，
  或分配给特定项目的[项目 runner](../../ci/runners/runners_scope.md#project-runners)。
- **cert-manager**（可选，用于 TLS/HTTPS）

  要为您的应用启用 HTTPS 端点，您可以[安装 cert-manager](https://cert-manager.io/docs/releases/)，
  这是一个原生 Kubernetes 证书管理控制器，可帮助签发
  证书。在您的集群上安装 cert-manager 会签发
  [Let's Encrypt](https://letsencrypt.org/) 证书，并确保
  证书有效且为最新。

如果您没有配置 Kubernetes 或 Prometheus，那么
[Auto Review Apps](stages.md#auto-review-apps) 和
[Auto Deploy](stages.md#auto-deploy)
将被跳过。

满足所有要求后，您可以[启用 Auto DevOps](_index.md#enable-or-disable-auto-devops)。

<a id="auto-devops-requirements-for-bare-metal"></a>

## 裸金属的 Auto DevOps 要求

根据 [Kubernetes Ingress-NGINX 文档](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/)：

> 在传统的云环境中，网络负载均衡器可按需提供，
> 只需一个 Kubernetes 清单即可为 NGINX Ingress
> 控制器提供与外部客户端的单一联系点，并间接地为集群内运行的任何应用提供联系点。
> 裸金属环境缺乏这种便利，需要略微不同的设置才能为外部使用者提供
> 相同类型的访问。

前面链接的文档解释了该问题并提供了可能的解决方案，例如：

- 通过 [MetalLB](https://github.com/metallb/metallb)。
- 通过 [OpenELB（原 PorterLB）](https://github.com/openelb/openelb)。
