---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过集群证书连接 GKE 集群（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
> 请使用[基于 OpenTofu 和极狐GitLab 的基础设施即代码](../../infrastructure/iac/_index.md)。
> 您也可以使用自己偏好的工具实现自己的 IaC 解决方案。

通过极狐GitLab，您可以创建托管在 Google Kubernetes Engine (GKE) 上的新集群，并连接现有集群。

<a id="connect-an-existing-gke-cluster"></a>

## 连接现有 GKE 集群

如果您已有 GKE 集群，并希望将其连接到极狐GitLab，
请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

<a id="create-a-new-gke-cluster-from-gitlab"></a>

## 从极狐GitLab 创建新的 GKE 集群

所有由极狐GitLab 预配的 GKE 集群都是 [VPC 原生](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/alias-ips)的。

要从极狐GitLab 创建新的 GKE 集群，请使用[基于 OpenTofu 和极狐GitLab 的基础设施即代码](../../infrastructure/iac/_index.md)。

<a id="create-a-new-cluster-on-gke-through-cluster-certificates"></a>

## 通过集群证书在 GKE 上创建新集群

先决条件：

- 已设置并具有访问权限的 [Google Cloud 结算账号](https://docs.cloud.google.com/billing/docs/how-to/manage-billing-account)。
- 已启用 Kubernetes Engine API 及相关服务。它应立即生效，但在您创建项目后
  最多可能需要 10 分钟。有关更多信息，请参阅
  [Kubernetes Engine 文档的“开始之前”部分](https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster#before-you-begin)。

请注意以下事项：

- 必须在极狐GitLab 的实例级别启用 [Google 身份验证集成](../../../integration/google.md)。
  如果尚未启用，请让您的极狐GitLab 管理员启用它。在
  JihuLab.com 上，此功能已启用。
- 由极狐GitLab 创建的所有 GKE 集群都启用了 RBAC。有关
  更多信息，请参阅 [RBAC 部分](cluster_access.md#rbac-cluster-resources)。
- 集群的 Pod 地址 IP 范围设置为 `/16`，而不是常规的 `/14`。`/16` 是一种 CIDR
  表示法。
- 极狐GitLab 要求启用基本身份验证并为集群颁发客户端证书，以便
  设置[初始服务账号](cluster_access.md)。在
  [GitLab 11.10 及更高版本](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/58208)中，集群创建过程
  会明确请求 GKE 创建启用了基本身份验证和客户端
  证书的集群。

要通过集群证书为您的项目、群组或实例创建新的 Kubernetes 集群：

1. 转到您的：
   - 项目的 {{< icon name="cloud-gear" >}} **运维** > **Kubernetes 集群**页面，用于项目级
     集群。
   - 群组的 {{< icon name="cloud-gear" >}} **Kubernetes** 页面，用于群组级集群。
   - **管理**区域的 **Kubernetes** 页面，用于实例级集群。
1. 选择 **使用集群证书集成**。
1. 在 **创建新集群** 标签页下，选择 **Google GKE**。
1. 如果您尚未连接 Google 账号，请选择
   **使用 Google 登录** 按钮进行连接。
1. 选择集群的设置：
   - **Kubernetes 集群名称** - 您希望为该集群指定的名称。
   - **环境范围** - 与此集群[关联的环境](multiple_kubernetes_clusters.md#setting-the-environment-scope)。
   - **Google Cloud Platform 项目** - 选择您在 GCP
     控制台中创建的、用于托管 Kubernetes 集群的项目。有关更多信息，请参阅
     [创建和管理项目](https://cloud.google.com/resource-manager/docs/creating-managing-projects)。
   - **可用区** - 选择要在其下创建集群的[区域可用区](https://docs.cloud.google.com/compute/docs/regions-zones)。
   - **节点数量** - 输入您希望集群具有的节点数。
   - **机器类型** - 作为集群基础的虚拟机实例的[机器类型](https://docs.cloud.google.com/compute/docs/machine-resource)。
   - **为 Anthos 启用 Cloud Run** - 如果您想为此集群使用 Cloud Run for Anthos，请勾选此项。
     有关更多信息，请参阅 [Cloud Run for Anthos 部分](#cloud-run-for-anthos)。
   - **极狐GitLab 托管的集群** - 如果您希望极狐GitLab 为此集群管理命名空间和服务账号，请保持勾选此项。
     有关更多信息，请参阅[受管集群部分](gitlab_managed_clusters.md)。
1. 最后，选择 **创建 Kubernetes 集群** 按钮。

几分钟后，您的集群就绪。

<a id="cloud-run-for-anthos"></a>

### Cloud Run for Anthos

您可以选择使用 Cloud Run for Anthos，以替代在集群创建后
单独安装 Knative 和 Istio。这意味着 Cloud Run
(Knative)、Istio 和 HTTP 负载均衡从一开始就在集群上启用，且无法安装或卸载。
