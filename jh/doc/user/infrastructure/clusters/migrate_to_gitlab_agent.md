---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 迁移到极狐GitLab Kubernetes Agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要将您的 Kubernetes 集群与极狐GitLab 连接，您可以使用：

- [GitOps 工作流](../../clusters/agent/gitops.md)
- [极狐GitLab CI/CD 工作流](../../clusters/agent/ci_cd_workflow.md)
- [基于证书的集成](_index.md)

基于证书的集成在极狐GitLab 14.5 中 [**已弃用**](https://gitlab.cn/blog/deprecating-the-cert-based-kubernetes-integration/)。其淘汰计划针对：

- [JihuLab.com 用户](../../../update/deprecations.md#gitlabcom-certificate-based-integration-with-kubernetes)
- [私有化部署用户](../../../update/deprecations.md#gitlab-self-managed-certificate-based-integration-with-kubernetes)

如果您正在使用基于证书的集成，应尽快迁移到其他工作流。

通常，要迁移依赖极狐GitLab CI/CD 的集群，您可以使用 [CI/CD 工作流](../../clusters/agent/ci_cd_workflow.md)。该工作流通过 Agent 连接您的集群。Agent：

- 不暴露于互联网
- 不需要对极狐GitLab 的完整 [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 访问权限

> [!note]
> 基于证书的集成曾用于多个流行的极狐GitLab 功能，例如极狐GitLab 管理的应用、极狐GitLab 管理的集群以及 Auto DevOps。

## 查找基于证书的集群

<a id="find-certificate-based-clusters"></a>

您可以通过 [专用 API](../../../api/cluster_discovery.md#retrieve-certificate-based-clusters) 在极狐GitLab 实例或群组（包括子群组和项目）内查找所有基于证书的集群。使用群组 ID 查询该 API 将返回指定群组及其下属所有基于证书的集群。

父群组中定义的集群不会通过此方式返回。此行为有助于群组所有者查找需要迁移的所有集群。

已禁用的集群同样会被返回，以避免无意的遗留。

> [!note]
> 集群发现 API 不适用于个人命名空间。

## 迁移通用部署

<a id="migrate-generic-deployments"></a>

要迁移通用部署：

1. 安装 [极狐GitLab Kubernetes Agent](../../clusters/agent/install/_index.md)。
1. 按照 CI/CD 工作流 [授权 Agent 访问](../../clusters/agent/ci_cd_workflow.md#authorize-agent-access) 群组和项目，或通过 [模拟身份限定安全访问](../../clusters/agent/ci_cd_workflow.md#restrict-project-and-group-access-by-using-impersonation)。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 从基于证书的集群部分，打开服务于同一环境范围的集群。
1. 选择 **详情** 选项卡并关闭该集群。

## 从极狐GitLab 管理的集群迁移到 Kubernetes 资源

<a id="migrate-from-gitlab-managed-clusters-to-kubernetes-resources"></a>

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

在极狐GitLab 管理的集群中，极狐GitLab 会为每个分支创建单独的服务账号和命名空间，并利用这些资源进行部署。

现在，您可以使用 [极狐GitLab 管理的 Kubernetes 资源](../../clusters/agent/managed_kubernetes_resources.md) 以增强的安全控制自助式提供资源。

借助极狐GitLab 管理的 Kubernetes 资源，您可以：

- 无需手动干预即可安全地设置环境
- 控制资源创建和访问，而无需给予开发者集群管理员权限
- 为开发者提供自助式能力，使其在创建新项目或环境时自动获取资源
- 允许开发者在专用或共享的命名空间中部署测试和开发版本

先决条件：

- 安装 [极狐GitLab Kubernetes Agent](../../clusters/agent/install/_index.md)
- [授权 Agent](../../clusters/agent/ci_cd_workflow.md#authorize-agent-access) 访问相关项目或群组
- 检查您的基于证书的集集群成页面中 **按环境命名空间** 复选框的状态

要从极狐GitLab 管理的集群迁移到极狐GitLab 管理的 Kubernetes 资源：

1. 如果您正在迁移现有环境，请通过 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md#configure-a-dashboard) 或 [环境 API](../../../api/environments.md) 为该环境配置 Agent。
1. 在 Agent 配置文件中开启资源管理：

   ```yaml
   ci_access:
      projects:
        - id: <your_group/your_project>
          access_as:
            ci_job: {}
          resource_management:
            enabled: true
      groups:
        - id: <your_other_group>
          access_as:
            ci_job: {}
          resource_management:
            enabled: true
   ```

1. 在 `.gitlab/agents/<agent-name>/environment_templates/default.yaml` 下创建环境模板。检查您的基于证书的集集群成页面中 **按环境命名空间** 复选框的状态。

   如果 **按环境命名空间** 已选中，请使用以下模板：

   ```yaml
   objects:
     - apiVersion: v1
       kind: Namespace
       metadata:
         # `.legacy_namespace` 生成类似于：
         # '{{ .project.slug }}-{{ .project.id }}-{{ .environment.slug }}'
         # 与基于证书的集集群成所生成的保持兼容
         name: '{{ .legacy_namespace }}'
     - apiVersion: rbac.authorization.k8s.io/v1
       kind: RoleBinding
       metadata:
         name: 'bind-{{ .agent.id }}-{{ .project.id }}-{{ .environment.slug }}'
         namespace: '{{ .legacy_namespace }}'
       subjects:
         - kind: Group
           apiGroup: rbac.authorization.k8s.io
           name: 'gitlab:project_env:{{ .project.id }}:{{ .environment.slug }}'
       roleRef:
         apiGroup: rbac.authorization.k8s.io
         kind: ClusterRole
         name: admin
   ```

   如果 **按环境命名空间** 未选中，请使用以下模板：

   ```yaml
   objects:
     - apiVersion: v1
       kind: Namespace
       metadata:
         name: '{{ .project.slug | slugify }}-{{ .project.id }}'
     - apiVersion: rbac.authorization.k8s.io/v1
       kind: RoleBinding
       metadata:
         name: 'bind-{{ .agent.id }}-{{ .project.id }}-{{ .environment.slug }}'
         namespace: '{{ .project.slug | slugify }}-{{ .project.id }}'
       subjects:
         - kind: Group
           apiGroup: rbac.authorization.k8s.io
           name: 'gitlab:project_env:{{ .project.id }}:{{ .environment.slug }}'
       roleRef:
         apiGroup: rbac.authorization.k8s.io
         kind: ClusterRole
         name: admin
   ```

1. 在您的 CI/CD 配置中，使用 `environment.kubernetes.agent: <path/to/agent/project:agent-name>` 语法指定 Agent。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 从基于证书的集群部分，打开服务于同一环境范围的集群。
1. 选择 **详情** 选项卡并关闭该集群。

## 从 Auto DevOps 迁移

<a id="migrate-from-auto-devops"></a>

在您的 Auto DevOps 项目中，您可以使用极狐GitLab Kubernetes Agent 连接您的 Kubernetes 集群。

先决条件

- 安装 [极狐GitLab Kubernetes Agent](../../clusters/agent/install/_index.md)
- [授权 Agent](../../clusters/agent/ci_cd_workflow.md#authorize-agent-access) 访问相关项目或群组

要从 Auto DevOps 迁移：

1. 在极狐GitLab 中，前往使用 Auto DevOps 的项目。
1. 添加三个变量。在左侧边栏中，选择 **设置** > **CI/CD** 并展开 **变量**。
   - 添加一个名为 `KUBE_INGRESS_BASE_DOMAIN` 的键，其值为应用部署域名。
   - 添加一个名为 `KUBE_CONTEXT` 的键，其值类似于 `path/to/agent/project:agent-name`。
     选择您期望的环境范围。
     如果您不确定 Agent 的上下文，请编辑 `.gitlab-ci.yml` 文件并添加一个作业来查看可用的上下文：

     ```yaml
     deploy:
       image: debian:13-slim
       variables:
         KUBECTL_VERSION: v1.34
         DEBIAN_FRONTEND: noninteractive
       script:
         # 依照 https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
         - apt-get update
         - apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg
         - curl --fail --silent --show-error --location "https://pkgs.k8s.io/core:/stable:/${KUBECTL_VERSION}/deb/Release.key" | gpg --dearmor --output /etc/apt/keyrings/kubernetes-apt-keyring.gpg
         - chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
         - echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBECTL_VERSION}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
         - chmod 644 /etc/apt/sources.list.d/kubernetes.list
         - apt-get update
         - apt-get install -y --no-install-recommends kubectl
         - kubectl config get-contexts
      ```

   - 添加一个名为 `KUBE_NAMESPACE` 的键，其值为您部署所针对的 Kubernetes 命名空间。设置相同的环境范围。
1. 选择 **添加变量**。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 从基于证书的集群部分，打开服务于同一环境范围的集群。
1. 选择 **详情** 选项卡并禁用该集群。
1. 编辑您的 `.gitlab-ci.yml` 文件，确保它使用了 Auto DevOps 模板。例如：

   ```yaml
   include:
     template: Auto-DevOps.gitlab-ci.yml

   variables:
     KUBE_INGRESS_BASE_DOMAIN: 74.220.23.215.nip.io
     KUBE_CONTEXT: "gitlab-examples/ops/gitops-demo/k8s-agents:demo-agent"
     KUBE_NAMESPACE: "demo-agent"
   ```

1. 要测试您的流水线，在左侧边栏中，选择 **构建** > **流水线**，然后 **新建流水线**。

有关示例，请 [查看此项目](https://jihulab.com/gitlab-examples/ops/gitops-demo/hello-world-service)。

## 从极狐GitLab 管理的应用程序迁移

<a id="migrate-from-gitlab-managed-applications"></a>

极狐GitLab 管理的应用程序（GMA）已在极狐GitLab 14.0 中弃用，并在 15.0 中移除。Kubernetes Agent 不支持这些应用程序。要从 GMA 迁移到 Agent，请执行以下步骤：

1. [从极狐GitLab 管理的应用程序迁移到集群管理项目](../../clusters/migrating_from_gma_to_project_template.md)
1. [将集群管理项目迁移至使用 Agent](../../clusters/management_project_template.md)

## 迁移集群管理项目

<a id="migrate-a-cluster-management-project"></a>

请参阅 [如何将集群管理项目与极狐GitLab Kubernetes Agent 配合使用](../../clusters/management_project_template.md)。

## 迁移集群监控功能

<a id="migrate-cluster-monitoring-features"></a>

使用 Kubernetes Agent 将 Kubernetes 集群连接到极狐GitLab 后，在启用 [用户访问](../../clusters/agent/user_access.md) 的情况下，您可以使用 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md)。