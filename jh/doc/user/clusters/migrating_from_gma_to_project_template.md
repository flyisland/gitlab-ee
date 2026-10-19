---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从极狐GitLab 托管应用迁移到集群管理项目（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 托管应用已废弃，
取而代之的是用户可控的集群管理项目。通过项目来管理集群应用，比通过已停止支持的极狐GitLab 托管应用管理集群要灵活得多。要迁移到集群管理项目，您必须拥有
[极狐GitLab Runner](../../ci/runners/_index.md)，
并熟悉 [Helm](https://helm.sh/)。

<a id="migrate-to-a-cluster-management-project"></a>

## 迁移到集群管理项目

要从极狐GitLab 托管应用迁移到集群管理项目，
请按照以下步骤操作。

1. 基于[集群管理项目模板](management_project_template.md#create-a-project-based-on-the-cluster-management-project-template)创建一个新项目。
1. 在您的集群中为此项目[安装一个代理](agent/install/_index.md)。
1. 按照项目模板中 `.gitlab-ci.yml`的说明，将 `KUBE_CONTEXT` CI/CD 变量设置为新安装代理的上下文。
1. 使用预配置的 [`.gitlab-ci.yml`](management_project_template.md#the-gitlab-ciyml-file) 文件检测通过 Helm v2 release 部署的应用：

   - 如果您覆盖了默认的极狐GitLab 托管应用命名空间，请编辑 `.gitlab-ci.yml`，
     并确保脚本接收到正确的命名空间作为参数：

     ```yaml
     script:
       - gl-fail-if-helm2-releases-exist <your_custom_namespace>
     ```

   - 如果您保留了默认名称（`gitlab-managed-apps`），则脚本已经
     设置好了。

   无论哪种情况，都请[手动运行流水线](../../ci/pipelines/_index.md#run-a-pipeline-manually)，并阅读
   `detect-helm2-releases` 作业的日志，以了解您有哪些 Helm v2 release（如果有的话）。

1. 如果您没有 Helm v2 release，请跳过此步骤。否则，请遵循 Helm 官方文档中关于
   [如何从 Helm v2 迁移到 Helm v3](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/)的说明，
   并在确认它们已成功迁移后清理 Helm v2 release。

1. 在此步骤中，您应该只剩下 Helm v3 release。
   在主 [`./helmfile.yaml`](management_project_template.md#the-main-helmfileyml-file)中取消注释您希望通过此项目
   管理的应用的路径。虽然您可以一次性取消注释所有想要
   管理的内容，但您应该针对每个应用分别重复以下步骤，以免在
   过程中迷失方向。
1. 编辑关联的 `applications/{app}/helmfiles.yaml`，使其与您的应用所部署的
   chart 版本匹配。以极狐GitLab Runner Helm v3 release 为例：

   以下命令列出 release 及其版本：

   ```shell
   helm ls -n gitlab-managed-apps

   NAME NAMESPACE REVISION UPDATED STATUS CHART APP VERSION
   runner gitlab-managed-apps 1 2021-06-09 19:36:55.739141644 +0000 UTC deployed gitlab-runner-0.28.0 13.11.0
   ```

   从 `CHART` 列中获取格式为 `{release}-v{chart_version}` 的版本，
   然后编辑 `./applications/gitlab-runner/helmfile.yaml`中的 `version:` 属性，使其与您部署的版本
   匹配。这是一个安全的步骤，可避免在此迁移过程中升级版本。
   如果您将应用部署到了不同的命名空间，请确保替换上一条命令中的
   `gitlab-managed-apps`。

1. 编辑与您的应用关联的 `applications/{app}/values.yaml`，使其与
   已部署的值匹配。例如，对于极狐GitLab Runner：

   1. 复制以下命令的输出（它可能很大）：

      ```shell
      helm get values runner -n gitlab-managed-apps -a --output yaml
      ```

   1. 用上一条命令的输出覆盖 `applications/gitlab-runner/values.yaml`。

   这个安全的步骤可确保没有意外的默认值覆盖您已部署的值。
   例如，您的极狐GitLab Runner 的 `gitlabUrl` 或 `runnerRegistrationToken` 可能会被错误地覆盖。

1. 某些应用需要特别注意：

   - Ingress：由于一个已有的 [chart 问题](https://github.com/helm/charts/pull/13646)，在尝试运行 [`./gl-helmfile`](management_project_template.md#the-gitlab-ciyml-file)
     命令时，您可能会看到 `spec.clusterIP: Invalid value`。要变通解决此问题，在覆盖 `applications/ingress/values.yaml`中的 release 值之后，
     您可能需要覆盖所有出现的 `omitClusterIP: false`，将其设置为 `omitClusterIP: true`。
     另一种方法是运行 `kubectl get services -n gitlab-managed-apps` 收集这些 IP，
     然后用该命令得到的值覆盖它报错的每个 `ClusterIP`。

   - Vault：此应用引入了从 Helm v2 中使用的 chart 到 Helm v3 中使用的 chart
     的破坏性变更。因此，将其与此集群管理项目集成的唯一方法是实际卸载此应用，并接受
     `applications/vault/values.yaml`中建议的 chart 版本。

   - Cert-manager：

     - 对于使用 Kubernetes 1.20 或更高版本的用户，已废弃的 cert-manager v0.10 不再有效，
       并且升级包含破坏性变更。因此，您应该[备份并卸载 cert-manager v0.10](#backup-and-uninstall-cert-manager-v010)，
       并改为安装最新的 cert-manager。要安装此版本，请从
       [`./helmfile.yaml`](management_project_template.md#the-main-helmfileyml-file)中取消注释 `applications/cert-manager/helmfile.yaml`。
       这会触发一条流水线来安装新版本。
     - 对于使用低于 1.20 的 Kubernetes 版本的用户，您可以通过在项目的主 Helmfile
       （[`./helmfile.yaml`](management_project_template.md#the-main-helmfileyml-file)）中取消注释
       `applications/cert-manager-legacy/helmfile.yaml`，
       继续使用 v0.10。

       > [!warning]
       > 当 Kubernetes 升级到 1.20 或更高版本时，Cert-manager v0.10 会失效。

1. 完成上述所有步骤后，[手动运行流水线](../../ci/pipelines/_index.md#run-a-pipeline-manually)
   并查看 `apply` 作业日志，了解您的应用是否被成功检测、安装，以及它们是否得到了任何
   意外的更新。

   某些注解校验和以及以下属性预计会被更新：

   ```diff
   --- heritage: Tiller
   +++ heritage: Tiller
   ```

在流水线成功运行后，对您希望通过集群管理项目管理的任何其他已部署应用重复这些步骤。

<a id="backup-and-uninstall-cert-manager-v010"></a>

## 备份并卸载 cert-manager v0.10

1. 遵循[官方文档](https://cert-manager.io/docs/devops-tips/backup/)了解如何
   备份您的 cert-manager v0.10 数据。
1. 通过编辑 `applications/cert-manager/helmfile.yaml` 文件并将所有
   出现的 `installed: true` 设置为 `installed: false`，来卸载 cert-manager。
1. 通过执行以下命令搜索任何遗留资源 `kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges,Secrets,ConfigMaps -n gitlab-managed-apps | grep certmanager`。
1. 对于上一步中找到的每个资源，使用 `kubectl delete -n gitlab-managed-apps {ResourceType} {ResourceName}` 删除它们。
   例如，如果您找到类型为 `ConfigMap`、名称为 `cert-manager-controller`的资源，请通过执行以下命令删除它：
   `kubectl delete configmap -n gitlab-managed-apps cert-manager-controller`。
