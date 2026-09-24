---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过集群证书连接 GKE 集群（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 14.5 中弃用。

{{< /history >}}

> [!warning]
> 此功能在极狐GitLab 14.5 中已弃用。
> 请使用[基于 OpenTofu 和极狐GitLab 的基础设施即代码](../../infrastructure/iac/_index.md)。
> 你也可以使用自己喜欢的工具实现自己的 IaC 解决方案。

通过极狐GitLab，你可以创建新的并连接托管在 Google Kubernetes Engine (GKE) 上的现有集群。

<a id="connect-an-existing-gke-cluster"></a>

## 连接现有 GKE 集群

如果你已有 GKE 集群并希望将其连接到极狐GitLab，
请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

<a id="create-a-new-gke-cluster-from-gitlab"></a>

## 从极狐GitLab 创建新的 GKE 集群

极狐GitLab 预配的所有 GKE 集群都是[VPC-native](https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips)的。

要从极狐GitLab 创建新的 GKE 集群，请使用[基于 OpenTofu 和极狐GitLab 的基础设施即代码](../../infrastructure/iac/_index.md)。

<a id="create-a-new-cluster-on-gke-through-cluster-certificates"></a>

## 通过集群证书在 GKE 上创建新集群

{{< history >}}

- 在极狐GitLab 14.0 中弃用。

{{< /history >}}

先决条件：

- 一个已设置访问权限的[Google Cloud 计费账号](https://cloud.google.com/billing/docs/how-to/manage-billing-account)。
- 已启用 Kubernetes Engine API 和相关服务。在你创建项目后，应该可以立即生效，但也可能需要最多 10 分钟。有关更多信息，请参阅 [Kubernetes Engine 文档的“开始之前”部分](https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster#before-you-begin)。

请注意以下事项：

- 必须在实例级别在极狐GitLab 中启用[Google 认证集成](../../../integration/google.md)。如果不是这样，请让你的极狐GitLab 管理员启用它。在 JihuLab.com 上，此功能已启用。
- 极狐GitLab 创建的所有 GKE 集群都支持 RBAC。查看 [RBAC 部分](cluster_access.md#rbac-cluster-resources)了解更多信息。
- 集群的 Pod 地址 IP 范围设置为 `/16` 而不是常规的 `/14`。`/16` 是 CIDR 表示法。
- 极狐GitLab 要求启用基本认证并为集群颁发客户端证书，以设置[初始服务账号](cluster_access.md)。在 [极狐GitLab 11.10 及更高版本](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/58208)中，集群创建过程明确要求 GKE 创建启用基本认证和客户端证书的集群。

要通过集群证书为你的项目、群组或实例创建新的 Kubernetes 集群：

1. 前往：
   - 对于项目级集群，前往项目的 {{< icon name="cloud-gear" >}} **运维** > **Kubernetes 集群** 页面。
   - 对于群组级集群，前往群组的 {{< icon name="cloud-gear" >}} **Kubernetes** 页面。
   - 对于实例级集群，前往 **管理员** 区域的 **Kubernetes** 页面。
1. 选择 **使用集群证书集成**。
1. 在 **创建新集群** 选项卡下，选择 **Google GKE**。
1. 如果尚未连接 Google 账号，请选择 **Sign in with Google** 按钮进行连接。
1. 选择集群的设置：
   - **Kubernetes 集群名称** - 你希望为集群指定的名称。
   - **环境范围** - 此集群的[关联环境](multiple_kubernetes_clusters.md#setting-the-environment-scope)。
   - **Google Cloud Platform 项目** - 选择你在 GCP 控制台中创建的用于托管 Kubernetes 集群的项目。有关更多信息，请参阅[创建和管理项目](https://cloud.google.com/resource-manager/docs/creating-managing-projects)。
   - **区域** - 选择用于创建集群的[区域](https://cloud.google.com/compute/docs/regions-zones/)。
   - **节点数量** - 输入你希望集群拥有的节点数量。
   - **机器类型** - 作为集群基础的虚拟机实例的[机器类型](https://cloud.google.com/compute/docs/machine-resource)。
   - **为 Anthos 启用 Cloud Run** - 如果希望为此集群使用 Cloud Run for Anthos，请勾选此项。有关更多信息，请参阅 [Cloud Run for Anthos 部分](#cloud-run-for-anthos)。
   - **极狐GitLab 托管的集群** - 如果希望极狐GitLab 为此集群管理命名空间和服务账号，请保持勾选。有关更多信息，请参阅[托管集群部分](gitlab_managed_clusters.md)。
1. 最后，选择 **创建 Kubernetes 集群** 按钮。

几分钟之后，你的集群就准备就绪。

### Cloud Run for Anthos

你可以选择使用 Cloud Run for Anthos，而不是在集群创建后单独安装 Knative 和 Istio。这意味着 Cloud Run (Knative)、Istio 和 HTTP 负载均衡从一开始就在集群上启用，并且无法安装或卸载。

