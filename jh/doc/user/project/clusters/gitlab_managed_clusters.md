---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 管理的集群（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，此功能默认不可用。要使其可用，管理员可以[启用功能标志](../../../administration/feature_flags/_index.md)，名称为 `certificate_based_clusters`。

您可以选择允许极狐GitLab 为您管理集群。如果您的集群由极狐GitLab 管理，系统会自动为您的项目创建资源。有关所创建资源的详细信息，请参阅[访问控制](cluster_access.md)部分。

> [!warning]
> 此功能已在极狐GitLab 14.5 中[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
> 要将集群连接到极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。
> 要管理应用，请使用[集群项目管理模板](../../clusters/management_project_template.md)。

如果您选择自行管理集群，则不会自动创建项目专属资源。如果您使用 [Auto DevOps](../../../topics/autodevops/_index.md)，则必须为部署作业显式提供 `KUBE_NAMESPACE` [部署变量](deploy_to_cluster.md#deployment-variables)。否则，系统会为您创建一个命名空间。

> [!warning]
> 请注意，手动管理由极狐GitLab 创建的资源（例如命名空间和服务账号）可能会导致意外错误。如果发生这种情况，请尝试[清除集群缓存](#clearing-the-cluster-cache)。

<a id="clearing-the-cluster-cache"></a>

## 清除集群缓存

如果您允许极狐GitLab 管理您的集群，极狐GitLab 会保存它为您的项目创建的命名空间和服务账号的缓存版本。如果您在集群中手动修改这些资源，此缓存可能会与您的集群不同步。这可能会导致部署作业失败。

要清除缓存：

1. 转到您项目的**运维** > **Kubernetes 集群**页面，然后选择您的集群。
1. 展开**高级设置**部分。
1. 选择**清除集群缓存**。

<a id="base-domain"></a>

## 基础域名

指定基础域名会自动将 `KUBE_INGRESS_BASE_DOMAIN` 设置为部署变量。如果您使用 [Auto DevOps](../../../topics/autodevops/_index.md)，此域名将用于各个阶段。例如，自动审查应用和自动部署。

该域名应配置一个指向 Ingress IP 地址的通配符 DNS。您可以：

- 在您的域名提供商处创建一条指向 Ingress IP 地址的 `A` 记录。
- 使用 `nip.io` 或 `xip.io` 等服务输入通配符 DNS 地址。例如，`192.168.1.1.xip.io`。

要确定外部 Ingress IP 地址或外部 Ingress 主机名：

- 如果集群位于 GKE 上：
  1. 在**高级设置**中选择 **Google Kubernetes Engine** 链接，或直接转到 [Google Kubernetes Engine 仪表板](https://console.cloud.google.com/kubernetes/)。
  1. 选择正确的项目和集群。
  1. 选择**连接**。
  1. 在本地终端中或使用 **Cloud Shell** 执行 `gcloud` 命令。

- 如果集群不在 GKE 上：请按照您的 Kubernetes 提供商的特定说明，使用正确的凭据配置 `kubectl`。以下示例的输出显示了集群的外部端点。然后，您可以使用此信息来设置 DNS 记录和转发规则，以允许从外部访问您部署的应用。

根据您的 Ingress，可以通过多种方式获取外部 IP 地址。以下列表提供了一种通用解决方案，以及一些极狐GitLab 特有的方法：

- 通常，您可以通过运行以下命令列出所有负载均衡器的 IP 地址：

  ```shell
  kubectl get svc --all-namespaces -o jsonpath='{range.items[?(@.status.loadBalancer.ingress)]}{.status.loadBalancer.ingress[*].ip} '
  ```

- 如果您使用**应用**安装了 Ingress，请运行：

  ```shell
  kubectl get service --namespace=gitlab-managed-apps ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
  ```

- 某些 Kubernetes 集群会返回主机名，例如 [Amazon EKS](https://aws.amazon.com/eks/)。对于这些平台，请运行：

  ```shell
  kubectl get service --namespace=gitlab-managed-apps ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  ```

  如果您使用 EKS，还会创建一个 [Elastic Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/)，这会产生额外的 AWS 费用。

- Istio/Knative 使用不同的命令。请运行：

  ```shell
  kubectl get svc --namespace=istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip} '
  ```

如果您在某些 Kubernetes 版本上看到末尾的 `%`，请不要包含它。
