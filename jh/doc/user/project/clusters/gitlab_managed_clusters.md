---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 管理的集群（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.0 中，对私有化部署版禁用。

{{< /history >}}

> [!flag]
> 在私有化部署版上，默认情况下此功能不可用。如需启用，管理员可以[启用功能标志](../../../administration/feature_flags/_index.md)，其名为 `certificate_based_clusters`。

你可以选择让极狐GitLab 为你管理集群。如果集群由极狐GitLab 管理，则会自动为你的项目创建资源。有关所创建资源的详细信息，请参见[访问控制](cluster_access.md)部分。

> [!warning]
> 此功能在 极狐GitLab 14.5 中[已弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。
> 要将集群连接到极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。
> 要管理应用程序，请使用[集群项目管理模板](../../clusters/management_project_template.md)。

如果你选择自行管理集群，则不会自动创建项目特定的资源。如果你使用 [Auto DevOps](../../../topics/autodevops/_index.md)，则必须明确为部署作业提供 `KUBE_NAMESPACE` [部署变量](deploy_to_cluster.md#deployment-variables)以供使用。否则，系统会为你创建一个命名空间。

> [!warning]
> 请注意，手动管理由极狐GitLab 创建的资源（如命名空间和服务账户）可能会导致意外错误。如果发生这种情况，请尝试[清除集群缓存](#清除集群缓存)。

<a id="clearing-the-cluster-cache"></a>

## 清除集群缓存

如果允许极狐GitLab 管理集群，极狐GitLab 会存储它为项目创建的命名空间和服务账户的缓存版本。如果你手动修改集群中的这些资源，此缓存可能与集群不同步，从而导致部署作业失败。

要清除缓存：

1. 进入项目 **运维** > **Kubernetes 集群** 页面，选择你的集群。
1. 展开 **高级设置** 部分。
1. 选择 **清除集群缓存**。

<a id="base-domain"></a>

## 基域

指定基域会自动将 `KUBE_INGRESS_BASE_DOMAIN` 设置为部署变量。如果你使用 [Auto DevOps](../../../topics/autodevops/_index.md)，此域将用于不同的阶段。例如 Auto Review Apps 和 Auto Deploy。

该域应配置一个指向 Ingress IP 地址的通配符 DNS。你可以：
- 通过你的域名提供商创建一个指向 Ingress IP 地址的 `A` 记录。
- 使用诸如 `nip.io` 或 `xip.io` 之类的服务输入通配符 DNS 地址。例如 `192.168.1.1.xip.io`。

要确定外部 Ingress IP 地址或外部 Ingress 主机名：
请按照你的 Kubernetes 提供商的具体说明配置 `kubectl` 的正确凭据。
以下示例的输出展示了集群的外部端点。然后可以使用这些信息设置 DNS 条目和转发规则，以允许外部访问已部署的应用程序。

根据你的 Ingress，可以通过多种方式检索外部 IP 地址。以下列表提供了一种通用解决方案以及一些极狐GitLab 特定的方法：

- 通常，你可以通过运行以下命令列出所有负载均衡器的 IP 地址：

  ```shell
  kubectl get svc --all-namespaces -o jsonpath='{range.items[?(@.status.loadBalancer.ingress)]}{.status.loadBalancer.ingress[*].ip} '
  ```

- 如果你使用 **应用程序** 安装了 Ingress，请运行：

  ```shell
  kubectl get service --namespace=gitlab-managed-apps ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
  ```

- Istio/Knative 使用不同的命令。请运行：

  ```shell
  kubectl get svc --namespace=istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip} '
  ```

如果在某些 Kubernetes 版本上看到尾随 `%`，请不要包含它。