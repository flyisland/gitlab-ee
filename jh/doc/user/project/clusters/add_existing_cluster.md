---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过集群证书连接现有集群（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[弃用](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
> 要将集群连接到极狐GitLab，请改用 [极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

如果您有现有的 Kubernetes 集群，可以将其添加到项目、群组或实例中，并受益于与极狐GitLab 的集成。

<a id="prerequisites"></a>

## 先决条件

请参阅以下先决条件，将现有集群添加到极狐GitLab。

<a id="all-clusters"></a>

### 所有集群

要将任何集群添加到极狐GitLab，您需要：

- 拥有 JihuLab.com 或极狐GitLab 私有化部署实例的账户。
- 对于群组级和项目级集群，需要维护者角色。
- 对于实例级集群，需要访问 **管理** 区域。
- 一个 Kubernetes 集群。
- 通过 `kubectl` 对集群具有集群管理访问权限。

您可以将集群托管在 [EKS](#eks-clusters)、[GKE](#gke-clusters)、本地环境以及其他提供商中。
要在本地环境和其他提供商中托管集群，请使用 EKS 或 GKE 方法作为指导，并手动输入集群的设置。

> [!warning]
> 极狐GitLab 不支持 `arm64` 集群。有关详细信息，请参阅议题
> [Helm Tiller 无法在 `arm64` 集群上安装](https://gitlab.com/gitlab-org/gitlab/-/issues/29838)。

<a id="eks-clusters"></a>

### EKS 集群

要添加现有的 **EKS** 集群，您需要：

- 一个具有正确配置的工作节点的 Amazon EKS 集群。
- 已[安装并配置](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#get-started-kubectl) `kubectl` 以访问 EKS 集群。
- 确保账户的令牌对该集群具有管理员权限。

<a id="gke-clusters"></a>

### GKE 集群

要添加现有的 **GKE** 集群，您需要：

- 具有 `container.clusterRoleBindings.create` 权限以创建集群角色绑定。您可以按照 [Google Cloud 文档](https://cloud.google.com/iam/docs/granting-changing-revoking-access) 授予访问权限。

<a id="how-to-add-an-existing-cluster"></a>

## 如何添加现有集群

<!-- (REVISE -  BREAK INTO SMALLER STEPS) -->

要将 Kubernetes 集群添加到您的项目、群组或实例：

1. 转到：
   1. 对于项目级集群，请转到项目的 {{< icon name="cloud-gear" >}} **运维** > **Kubernetes 集群** 页面。
   1. 对于群组级集群，请转到群组的 {{< icon name="cloud-gear" >}} **Kubernetes** 页面。
   1. 对于实例级集群，请转到 **管理** 区域的 **Kubernetes** 页面。
1. 在 **Kubernetes 集群** 页面上，从 **操作** 下拉列表中选择 **使用证书连接** 选项。
1. 在 **连接集群** 页面上，填写详细信息：
   1. **Kubernetes 集群名称**（必填）- 您希望为该集群指定的名称。
   1. **环境范围**（必填）- 与此集群的[关联环境](multiple_kubernetes_clusters.md#setting-the-environment-scope)。
   1. **API URL**（必填）-
      这是极狐GitLab 用于访问 Kubernetes API 的 URL。Kubernetes 公开了多个
      API。请使用它们共有的“基础”URL。例如，
      `https://kubernetes.example.com` 而不是 `https://kubernetes.example.com/api/v1`。

      通过运行以下命令获取 API URL：

      ```shell
      kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'
      ```

   1. **CA 证书**（必填）- 需要有效的 Kubernetes 证书才能对集群进行身份验证。使用默认创建的证书。
      1. 使用 `kubectl get secrets` 列出密钥，其中一个应命名为类似于
         `default-token-xxxxx`。复制该令牌名称以供下面使用。
      1. 通过运行以下命令获取证书：

         ```shell
         kubectl get secret <secret name> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
         ```

         如果命令返回整个证书链，您必须复制链底部的根 CA
         证书和任何中间证书。
         链文件具有以下结构：

         ```plaintext
            -----BEGIN MY CERTIFICATE-----
            -----END MY CERTIFICATE-----
            -----BEGIN INTERMEDIATE CERTIFICATE-----
            -----END INTERMEDIATE CERTIFICATE-----
            -----BEGIN INTERMEDIATE CERTIFICATE-----
            -----END INTERMEDIATE CERTIFICATE-----
            -----BEGIN ROOT CERTIFICATE-----
            -----END ROOT CERTIFICATE-----
         ```

   1. **令牌** -
      极狐GitLab 使用服务令牌对 Kubernetes 进行身份验证，这些令牌限定在特定的 `namespace` 中。
      使用的令牌应属于具有
      [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)
      权限的服务账号。要创建此服务账号：
      1. 创建一个名为 `gitlab-admin-service-account.yaml` 的文件，内容如下：

         ```yaml
         apiVersion: v1
         kind: ServiceAccount
         metadata:
           name: gitlab
           namespace: kube-system
         ---
         apiVersion: rbac.authorization.k8s.io/v1
         kind: ClusterRoleBinding
         metadata:
           name: gitlab-admin
         roleRef:
           apiGroup: rbac.authorization.k8s.io
           kind: ClusterRole
           name: cluster-admin
         subjects:
           - kind: ServiceAccount
             name: gitlab
             namespace: kube-system
         ```

      1. 将服务账号和集群角色绑定应用到您的集群：

         ```shell
         kubectl apply -f gitlab-admin-service-account.yaml
         ```

         您需要 `container.clusterRoleBindings.create` 权限才能创建集群级角色。如果您没有此权限，
         您可以改为启用基本身份验证，然后以管理员身份运行
         `kubectl apply` 命令：

         ```shell
         kubectl apply -f gitlab-admin-service-account.yaml --username=admin --password=<password>
         ```

         > [!note]
         > 可以启用基本身份验证，并且可以使用 Google Cloud Console 获取密码凭据。

         输出：

         ```shell
         serviceaccount "gitlab" created
         clusterrolebinding "gitlab-admin" created
         ```

      1. 检索 `gitlab` 服务账号的令牌：

         ```shell
         kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
         ```

         从输出中复制 `<authentication_token>` 值：

         ```plaintext
         Name:         gitlab-token-b5zv4
         Namespace:    kube-system
         Labels:       <none>
         Annotations:  kubernetes.io/service-account.name=gitlab
                      kubernetes.io/service-account.uid=bcfe66ac-39be-11e8-97e8-026dce96b6e8

         Type:  kubernetes.io/service-account-token

         Data
         ====
         ca.crt:     1025 bytes
         namespace:  11 bytes
         token:      <authentication_token>
         ```

   1. **极狐GitLab 管理的集群** - 如果您希望极狐GitLab 管理此集群的命名空间和服务账号，请保持选中此选项。
      有关更多信息，请参阅[受管集群部分](gitlab_managed_clusters.md)。
   1. **项目命名空间**（可选）- 您不必填写此项。留空时，
      极狐GitLab 会为您创建一个。此外：
      - 每个项目应具有唯一的命名空间。
      - 如果您使用的是具有更广泛权限的密钥（例如来自 `default` 的密钥），则项目命名空间不一定是该密钥的命名空间。
      - 您不应使用 `default` 作为项目命名空间。
      - 如果您或其他人专门为项目创建了密钥（通常具有有限权限），则密钥的命名空间和项目命名空间可能相同。

1. 选择 **添加 Kubernetes 集群** 按钮。

大约 10 分钟后，您的集群就会准备就绪。

<a id="disable-role-based-access-control-rbac-optional"></a>

## 禁用基于角色的访问控制（RBAC）（可选）

通过极狐GitLab 集成连接集群时，您可以指定集群是否启用 RBAC。这会影响极狐GitLab 在某些操作中与集群交互的方式。如果您在创建时未选中 **启用 RBAC 的集群** 复选框，极狐GitLab 在与集群交互时会假定您的集群已禁用 RBAC。如果是这样，您必须在集群上禁用 RBAC，集成才能正常工作。

![用于启用 RBAC 的极狐GitLab Kubernetes 集群集成设置。](img/rbac_v13_1.png)

> [!warning]
> 禁用 RBAC 意味着集群中运行的任何应用程序，
> 或任何可以向集群进行身份验证的用户，都拥有完整的 API 访问权限。这是一个
> [安全问题](../../infrastructure/clusters/connect/_index.md#security-implications-for-clusters-connected-with-certificates)，
> 可能并不可取。

要有效禁用 RBAC，可以应用授予完全访问权限的全局权限：

```shell
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
```

<a id="troubleshooting"></a>

## 故障排查

<a id="ca-certificate-and-token-errors-during-authentication"></a>

### 身份验证期间的 CA 证书和令牌错误

如果您在连接 Kubernetes 集群时遇到此错误：

```plaintext
There was a problem authenticating with your cluster.
Please ensure your CA Certificate and Token are valid
```

请确保您正确粘贴了服务令牌。某些 shell 可能会在服务令牌中添加换行符，使其无效。请将令牌粘贴到编辑器中并删除任何多余的空格，以确保没有换行符。

如果您的证书无效，也可能会遇到此错误。要检查证书的主题备用名称是否包含集群 API 的正确域，请运行以下命令：

```shell
echo | openssl s_client -showcerts -connect kubernetes.example.com:443 -servername kubernetes.example.com 2>/dev/null |
openssl x509 -inform pem -noout -text
```

`-connect` 参数需要 `host:port` 组合。例如，`https://kubernetes.example.com` 应为 `kubernetes.example.com:443`。`-servername` 参数需要不带任何 URI 的域名，例如 `kubernetes.example.com`。
