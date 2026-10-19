---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 Kubernetes 部署（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。

如果您要部署到与项目关联的 [Kubernetes 集群](../../user/infrastructure/clusters/_index.md)，您可以从 `.gitlab-ci.yml` 文件配置这些部署。

> [!note]
> [由极狐GitLab 管理](../../user/project/clusters/gitlab_managed_clusters.md)的 Kubernetes 集群不支持 Kubernetes 配置。

支持以下配置选项：

- [`namespace`](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

在以下示例中，该作业将您的应用程序部署到 `production` Kubernetes 命名空间。

```yaml
deploy:
  stage: deploy
  script:
    - echo "Deploy to production server"
  environment:
    name: production
    url: https://example.com
    kubernetes:
      agent: path/to/agent/project:agent-name
      dashboard:
        namespace: production
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

当您使用极狐GitLab Kubernetes 集成部署到 Kubernetes 集群时，
您可以查看集群和命名空间信息。在部署作业页面上，它显示在作业跟踪记录上方：

![包含集群和命名空间的部署集群信息。](img/environments_deployment_cluster_v12_8.png)

<a id="configure-incremental-rollouts"></a>

## 配置增量发布

了解如何使用[增量发布](incremental_rollouts.md)仅将生产变更发布到一部分 Kubernetes pod。
