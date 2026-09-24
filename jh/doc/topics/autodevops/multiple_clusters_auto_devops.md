---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用于 Auto DevOps 的多个 Kubernetes 集群
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

使用 Auto DevOps 时，您可以将不同的环境部署到不同的 Kubernetes 集群。

Auto DevOps 使用的 [Deploy Job 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml)定义了三个环境名称：

- `review/`（所有以 `review/` 开头的环境）
- `staging`
- `production`

这些环境通过 [Auto Deploy](stages.md#auto-deploy) 与作业绑定，因此它们必须具有不同的部署域名。您必须为这三个环境分别定义单独的 [`KUBE_CONTEXT`](../../user/clusters/agent/ci_cd_workflow.md#environments-that-use-auto-devops) 和 [`KUBE_INGRESS_BASE_DOMAIN`](requirements.md#auto-devops-base-domain) 变量。

<a id="deploy-to-different-clusters"></a>

## 部署到不同集群

要将您的环境部署到不同的 Kubernetes 集群：

1. [使用 OpenTofu 和极狐GitLab 创建 Kubernetes 集群](../../user/infrastructure/iac/_index.md)。
1. 将集群与您的项目关联：
   1. [在每个集群上安装极狐GitLab Kubernetes 代理](../../user/clusters/agent/_index.md)。
   1. [配置每个代理以访问您的项目](../../user/clusters/agent/work_with_agent.md#configure-your-agent)。
1. 在每个集群中[安装 NGINX Ingress Controller](cloud_deployments/auto_devops_with_gke.md#install-ingress)。保存 IP 地址和 Kubernetes 命名空间，用于下一步。
1. [配置 Auto DevOps CI/CD 流水线变量](cicd_variables.md#build-and-deployment-variables)
   - [为每个环境](../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)设置一个 `KUBE_CONTEXT` 变量。该值必须指向相关集群的代理。
   - 设置一个 `KUBE_INGRESS_BASE_DOMAIN`。您必须为每个环境[配置基础域](requirements.md#auto-devops-base-domain)，以指向相关集群的 Ingress。
   - 添加一个 `KUBE_NAMESPACE` 变量，其值为您希望部署的目标 Kubernetes 命名空间。您可以将变量范围限定到多个环境。

对于已弃用的[基于证书的集群](../../user/infrastructure/clusters/_index.md#certificate-based-kubernetes-integration-deprecated)：

1. 转到项目，从左侧边栏中选择 **操作** > **Kubernetes 集群**。
1. [设置每个集群的环境范围](../../user/project/clusters/multiple_kubernetes_clusters.md#setting-the-environment-scope)。
1. 对于每个集群，[基于其 Ingress IP 地址添加域](../../user/project/clusters/gitlab_managed_clusters.md#base-domain)。

> [!note]
> [检查活动 Kubernetes 集群时不考虑集群环境范围](https://jihulab.com/gitlab-cn/gitlab/-/issues/20351)。对于多集群设置要与 Auto DevOps 配合使用，您必须创建一个回退集群，并将其 **集群环境范围** 设置为 `*`。您可以将已添加的任何集群设置为回退集群。

<a id="example-configurations"></a>

### 示例配置

| 集群名称 | 集群环境范围 | `KUBE_INGRESS_BASE_DOMAIN` 值 | `KUBE CONTEXT` 值               | 变量环境范围 | 备注 |
|:-------------|:--------------------------|:---------------------------------|:-----------------------------------|:---------------------------|:------|
| review       | `review/*`                | `review.example.com`             | `path/to/project:review-agent`     | `review/*`                 | 运行所有[评审应用](../../ci/review_apps/_index.md)的评审集群。 |
| staging      | `staging`                 | `staging.example.com`            | `path/to/project:staging-agent`    | `staging`                  | 可选。运行预发布环境部署的预发布集群。您必须[首先启用它](cicd_variables.md#deploy-policy-for-staging-and-production-environments)。 |
| production   | `production`              | `example.com`                    | `path/to/project:production-agent` | `production`               | 运行生产环境部署的生产集群。您可以使用[增量发布](cicd_variables.md#incremental-rollout-to-production)。 |

<a id="test-your-configuration"></a>

## 测试您的配置

完成配置后，通过创建合并请求来测试您的设置。
验证您的应用程序是否作为评审应用部署在具有 `review/*` 环境范围的 Kubernetes 集群中。同样，检查其他环境。