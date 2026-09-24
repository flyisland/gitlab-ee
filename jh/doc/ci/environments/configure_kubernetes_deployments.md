---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 Kubernetes 部署（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 14.5 中已弃用。

如果你在部署到与项目关联的 [Kubernetes 集群](../../user/infrastructure/clusters/_index.md)，可以从 `.gitlab-ci.yml` 文件中配置这些部署。

> [!note]
> 对于[极狐GitLab 管理](../../user/project/clusters/gitlab_managed_clusters.md)的 Kubernetes 集群，不支持 Kubernetes 配置。

支持以下配置选项：

- [`namespace`](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)（命名空间）

在以下示例中，作业将你的应用程序部署到 `production` Kubernetes 命名空间。

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

当你使用极狐GitLab Kubernetes 集成部署到 Kubernetes 集群时，可以查看集群和命名空间信息。在部署作业页面，它显示在作业跟踪上方：

![具有集群和命名空间的部署集群信息。](img/environments_deployment_cluster_v12_8.png)

<a id="configure-incremental-rollouts"></a>

## 配置增量发布

了解如何通过[增量发布](incremental_rollouts.md)将生产变更仅发布到部分 Kubernetes Pod。

<!-- Related topics 部分已按规则删除 -->

