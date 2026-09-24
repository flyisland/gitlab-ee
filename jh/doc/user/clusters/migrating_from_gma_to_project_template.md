---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从极狐GitLab 托管应用迁移至集群管理项目（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 托管应用在极狐GitLab 14.0 中已弃用，转而采用用户管理的集群管理项目。通过项目管理集群应用可以让您比通过旧的极狐GitLab 托管应用拥有更大的灵活性来管理集群。要迁移到集群管理项目，您需要[极狐GitLab Runner](../../ci/runners/_index.md)可用，并熟悉 [Helm](https://helm.sh/)。

<a id="migrate-to-a-cluster-management-project"></a>

## 迁移至集群管理项目

要从极狐GitLab 托管应用迁移到集群管理项目，请按照以下步骤操作。另请参见带有示例的[视频演练](#video-walk-throughs)。

1. 基于[集群管理项目模板](management_project_template.md#create-a-project-based-on-the-cluster-management-project-template)创建一个新项目。
1. 在您的集群中为此项目[安装一个代理](agent/install/_index.md)。
1. 根据项目模板中的 `.gitlab-ci.yml` 文件指示，将 `KUBE_CONTEXT` CI/CD 变量设置为新安装的代理的上下文。
1. 使用预配置的 [`.gitlab-ci.yml`](management_project_template.md#the-gitlab-ciyml-file) 文件检测通过 Helm v2 发布部署的应用：

   - 如果您曾覆盖了默认的极狐GitLab 托管应用命名空间，请编辑 `.gitlab-ci.yml`，确保脚本将正确的命名空间作为参数接收：

     ```yaml
     script:
       - gl-fail-if-helm2-releases-exist <your_custom_namespace>
     ```

   - 如果您保留了默认名称（`gitlab-managed-apps`），则脚本已配置好。

   无论哪种方式，[手动运行一次流水线](../../ci/pipelines/_index.md#run-a-pipeline-manually)并阅读 `detect-helm2-releases` 作业的日志，以确认是否有任何 Helm v2 版本以及它们是什么。

1. 如果您没有 Helm v2 版本，请跳过此步骤。否则，请按照官方 Helm 文档中关于[如何从 Helm v2 迁移到 Helm v3](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/) 的说明进行操作，并在确信它们已成功迁移后清理 Helm v2 版本。

1. 在这一步中，您应该已经只有 Helm v3 版本。从主 [`./helmfile.yaml`](management_project_template.md#the-main-helmfileyml-file) 中取消注释您想要使用此项目管理的应用程序的路径。尽管您可以一次取消注释所有想要管理的应用，但建议为每个应用分别重复以下步骤，以免在过程中迷失方向。

1. 编辑关联的 `applications/{app}/helmfiles.yaml` 以匹配您的应用部署的图表版本。以极狐GitLab Runner Helm v3 版本为例：

   以下命令列出发布的版本及其版本号：

   ```shell
   helm ls -n gitlab-managed-apps

   NAME NAMESPACE REVISION UPDATED STATUS CHART APP VERSION
   runner gitlab-managed-apps 1 2021-06-09 19:36:55.739141644 +0000 UTC deployed gitlab-runner-0.28.0 13.11.0
   ```

   从 `CHART` 列获取版本号，其格式为 `{release}-v{chart_version}`，然后编辑 `./applications/gitlab-runner/helmfile.yaml` 中的 `version:` 属性，使其与您部署的版本匹配。这是避免在迁移过程中升级版本的安全步骤。
   如果您将应用部署到了不同的命名空间，请确保用正确的名称替换前面命令中的 `gitlab-managed-apps`。

1. 编辑与应用关联的 `applications/{app}/values.yaml`，以匹配已部署的值。例如，对于极狐GitLab Runner：

   1. 复制以下命令的输出（可能很大）：

      ```shell
      helm get values runner -n gitlab-managed-apps -a --output yaml
      ```

   1. 用上一个命令的输出覆盖 `applications/gitlab-runner/values.yaml`。

   这一安全步骤可确保不会有意外的默认值覆盖您已部署的值。例如，您的极狐GitLab Runner 可能会错误地覆盖其 `gitlabUrl` 或 `runnerRegistrationToken`。

1. 某些应用需要特别注意：

   - Ingress：由于存在一个[现有的图表问题](https://github.com/helm/charts/pull/13646)，在尝试运行 [`./gl-helmfile`](management_project_template.md#the-gitlab-ciyml-file) 命令时，您可能会看到 `spec.clusterIP: Invalid value` 错误。为解决此问题，在 `applications/ingress/values.yaml` 中覆盖发布值后，您可能需要将所有 `omitClusterIP: false` 的实例覆盖为 `omitClusterIP: true`。另一种方法是通过运行 `kubectl get services -n gitlab-managed-apps` 收集这些 IP，然后用从该命令获得的值覆盖每个报错的 `ClusterIP`。

   - Vault：此应用引入了从 Helm v2 中使用的图表到 Helm v3 中使用的图表的重大更改。因此，将其集成到此集群管理项目的唯一方法是实际卸载此应用，并接受 `applications/vault/values.yaml` 中建议的图表版本。

   - Cert-manager：

     - 对于 Kubernetes 版本 1.20 或更高版本的用户，已弃用的 cert-manager v0.10 不再有效，升级包含重大更改。因此，您应该[备份并卸载 cert-manager v0.10](#backup-and-uninstall-cert-manager-v010)，然后安装最新的 cert-manager。要安装此版本，请从 [`./helmfile.yaml`](management_project_template.md#the-main-helmfileyml-file) 中取消注释 `applications/cert-manager/helmfile.yaml`。这将触发一个流水线来安装新版本。
     - 对于 Kubernetes 版本低于 1.20 的用户，您可以通过在项目的主 Helmfile（[`./helmfile.yaml`](management_project_template.md#the-main-helmfileyml-file)）中取消注释 `applications/cert-manager-legacy/helmfile.yaml` 来继续使用 v0.10。

       > [!warning]
       > 当 Kubernetes 升级到版本 1.20 或更高版本时，cert-manager v0.10 会损坏。

1. 按照前面所有步骤操作后，[手动运行一次流水线](../../ci/pipelines/_index.md#run-a-pipeline-manually)并观察 `apply` 作业日志，查看是否有任何应用被成功检测、安装，以及是否发生了任何意外更新。

   预期会更新一些注解校验和以及以下属性：

   ```diff
   --- heritage: Tiller
   +++ heritage: Tiller
   ```

获得成功的流水线后，对您想要通过集群管理项目管理的任何其他已部署应用重复这些步骤。

<a id="backup-and-uninstall-cert-manager-v010"></a>

## 备份并卸载 cert-manager v0.10

1. 按照[官方文档](https://cert-manager.io/docs/devops-tips/backup/)的说明备份您的 cert-manager v0.10 数据。
1. 通过将 `applications/cert-manager/helmfile.yaml` 文件中所有 `installed: true` 的实例编辑为 `installed: false` 来卸载 cert-manager。
1. 执行以下命令搜索任何残留资源：`kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges,Secrets,ConfigMaps -n gitlab-managed-apps | grep certmanager`。
1. 对于上一步中找到的每个资源，使用 `kubectl delete -n gitlab-managed-apps {ResourceType} {ResourceName}` 将其删除。例如，如果找到一个类型为 `ConfigMap`、名称为 `cert-manager-controller` 的资源，请执行：`kubectl delete configmap -n gitlab-managed-apps cert-manager-controller`。