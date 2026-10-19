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

- [GitOps 工作流](../../clusters/agent/gitops.md)。
- [极狐GitLab CI/CD 工作流](../../clusters/agent/ci_cd_workflow.md)。
- [基于证书的集成](_index.md)。

基于证书的集成在极狐GitLab 14.5 中已[弃用](https://about.gitlab.com/blog/deprecating-the-cert-based-kubernetes-integration/)。停用计划如下：

- 针对 [JihuLab.com 客户](../../../update/deprecations.md#gitlabcom-certificate-based-integration-with-kubernetes)。
- 针对[极狐GitLab 私有化部署客户](../../../update/deprecations.md#gitlab-self-managed-certificate-based-integration-with-kubernetes)。

如果您正在使用基于证书的集成，应尽快迁移到其他工作流。

一般来说，要迁移依赖极狐GitLab CI/CD 的集群，您可以使用 [CI/CD 工作流](../../clusters/agent/ci_cd_workflow.md)。此工作流使用 Agent 连接到您的集群。该 Agent：

- 不暴露于互联网。
- 不需要对极狐GitLab 拥有完整的 [`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) 访问权限。

> [!note]
> 基于证书的集成曾用于极狐GitLab 的常用功能，例如
> 极狐GitLab 管理的应用、极狐GitLab 管理的集群和 Auto DevOps。

<a id="find-certificate-based-clusters"></a>

## 查找基于证书的集群

您可以使用[专用 API](../../../api/cluster_discovery.md#retrieve-certificate-based-clusters)，查找极狐GitLab 实例或群组（包括子群组和项目）中的所有基于证书的集群。使用群组 ID 查询该 API 会返回在所提供的群组及其下级定义的所有基于证书的集群。

在这种情况下，不会返回在父群组中定义的集群。此行为可帮助群组所有者找到他们需要迁移的所有集群。

已禁用的集群也会返回，以避免意外遗漏集群。

> [!note]
> 集群发现 API 不适用于个人命名空间。

<a id="migrate-generic-deployments"></a>

## 迁移通用部署

要迁移通用部署：

1. 安装[极狐GitLab Kubernetes Agent](../../clusters/agent/install/_index.md)。
1. 按照 CI/CD 工作流[授权 Agent 访问](../../clusters/agent/ci_cd_workflow.md#authorize-agent-access)群组和项目，或[使用模拟限制项目与群组访问](../../clusters/agent/ci_cd_workflow.md#restrict-project-and-group-access-by-using-impersonation)。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 在基于证书的集群部分，打开服务于相同环境范围的集群。
1. 选择**详细信息**标签页并关闭该集群。

<a id="migrate-from-gitlab-managed-clusters-to-kubernetes-resources"></a>

## 从极狐GitLab 管理的集群迁移到 Kubernetes 资源

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

使用极狐GitLab 管理的集群时，极狐GitLab 会为每个分支创建单独的服务账号和命名空间，并使用这些资源进行部署。

现在，您可以使用[极狐GitLab 管理的 Kubernetes 资源](../../clusters/agent/managed_kubernetes_resources.md)，通过增强的安全控制自助管理资源。

使用极狐GitLab 管理的 Kubernetes 资源，您可以：

- 无需人工干预即可安全地设置环境。
- 在不授予开发者集群管理权限的情况下控制资源创建和访问。
- 在开发者创建新项目或环境时为其提供自助服务能力。
- 允许开发者在专用或共享命名空间中部署测试和开发版本。

先决条件：

- 安装[极狐GitLab Kubernetes Agent](../../clusters/agent/install/_index.md)。
- [授权 Agent](../../clusters/agent/ci_cd_workflow.md#authorize-agent-access) 访问相关项目或群组。
- 在基于证书的集群集成页面中检查**每个环境一个命名空间**复选框的状态。

要从极狐GitLab 管理的集群迁移到极狐GitLab 管理的 Kubernetes 资源：

1. 如果您要迁移现有环境，请通过 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md#configure-a-dashboard)或[环境 API](../../../api/environments.md) 为该环境配置 Agent。
1. 在 Agent 配置文件中配置 Agent 以开启资源管理：

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

1. 在 `.gitlab/agents/<agent-name>/environment_templates/default.yaml` 下创建环境模板。在基于证书的集群集成页面中检查**每个环境一个命名空间**复选框的状态。

   如果**每个环境一个命名空间**已勾选，请使用以下模板：

   ```yaml
   objects:
     - apiVersion: v1
       kind: Namespace
       metadata:
         # the `.legacy_namespace` produces something like:
         # '{{ .project.slug }}-{{ .project.id }}-{{ .environment.slug }}'
         # that is compatible with what the certificate-based cluster integration
         # would have generated.
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

   如果**每个环境一个命名空间**未勾选，请使用以下模板：

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

1. 在您的 CI/CD 配置中，使用 `environment.kubernetes.agent: <path/to/agent/project:agent-name>` 语法来使用该 Agent。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 在基于证书的集群部分，打开服务于相同环境范围的集群。
1. 选择**详细信息**标签页并关闭该集群。

<a id="migrate-from-auto-devops"></a>

## 从 Auto DevOps 迁移

在您的 Auto DevOps 项目中，您可以使用极狐GitLab Kubernetes Agent 连接到您的 Kubernetes 集群。

先决条件：

- 安装[极狐GitLab Kubernetes Agent](../../clusters/agent/install/_index.md)。
- [授权 Agent](../../clusters/agent/ci_cd_workflow.md#authorize-agent-access) 访问相关项目或群组。

要从 Auto DevOps 迁移：

1. 在极狐GitLab 中，转到您使用 Auto DevOps 的项目。
1. 添加三个变量。在左侧边栏中，选择**设置** > **CI/CD** 并展开**变量**。
   - 添加一个名为 `KUBE_INGRESS_BASE_DOMAIN`的键，其值为应用部署域名。
   - 添加一个名为 `KUBE_CONTEXT`的键，其值类似于 `path/to/agent/project:agent-name`。
     选择您想要的环境范围。
     如果您不确定 Agent 的上下文是什么，请编辑您的 `.gitlab-ci.yml` 文件并添加一个作业以查看可用的上下文：

     ```yaml
     deploy:
       image: debian:13-slim
       variables:
         KUBECTL_VERSION: v1.34
         DEBIAN_FRONTEND: noninteractive
       script:
         # Follows https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
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

   - 添加一个名为 `KUBE_NAMESPACE`的键，其值为您的部署要指向的 Kubernetes 命名空间。设置相同的环境范围。
1. 选择**添加变量**。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 在基于证书的集群部分，打开服务于相同环境范围的集群。
1. 选择**详细信息**标签页并禁用该集群。
1. 编辑您的 `.gitlab-ci.yml` 文件，确保它使用 Auto DevOps 模板。例如：

   ```yaml
   include:
     template: Auto-DevOps.gitlab-ci.yml

   variables:
     KUBE_INGRESS_BASE_DOMAIN: 74.220.23.215.nip.io
     KUBE_CONTEXT: "gitlab-examples/ops/gitops-demo/k8s-agents:demo-agent"
     KUBE_NAMESPACE: "demo-agent"
   ```

1. 要测试您的流水线，请在左侧边栏中，选择**构建** > **流水线**，然后选择**新建流水线**。

有关示例，请[查看此项目](https://gitlab.com/gitlab-examples/ops/gitops-demo/hello-world-service)。

<a id="migrate-from-gitlab-managed-applications"></a>

## 从极狐GitLab 管理的应用迁移

极狐GitLab 管理的应用（GMA）已被弃用并移除。
极狐GitLab Kubernetes Agent 不支持它们。要从 GMA 迁移到
Agent，请执行以下步骤：

1. [从极狐GitLab 管理的应用迁移到集群管理项目](../../clusters/migrating_from_gma_to_project_template.md)。
1. [将集群管理项目迁移为使用 Agent](../../clusters/management_project_template.md)。

<a id="migrate-a-cluster-management-project"></a>

## 迁移集群管理项目

请参阅[如何将集群管理项目与极狐GitLab Kubernetes Agent 一起使用](../../clusters/management_project_template.md)。

<a id="migrate-cluster-monitoring-features"></a>

## 迁移集群监控功能

使用极狐GitLab Kubernetes Agent 将 Kubernetes 集群连接到极狐GitLab 后，您可以在启用[用户访问](../../clusters/agent/user_access.md)后使用 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md)。
