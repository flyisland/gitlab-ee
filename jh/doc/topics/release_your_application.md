---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Environments, packages, review apps, 极狐GitLab Pages.
title: 部署和发布您的应用程序
---

部署是软件交付流程中将应用程序部署到最终目标基础设施的环节。

您可以将应用部署到内部环境或公开环境。
在 Review App 中预览发布效果，并使用功能标志逐步发布功能。

{{< cards >}}

- [入门](../user/get_started/get_started_deploy_release.md)
- [软件包与镜像仓库](../user/packages/_index.md)
- [环境](../ci/environments/_index.md)
- [部署](../ci/environments/deployments.md)
- [发布](../user/project/releases/_index.md)
- [增量发布应用](../ci/environments/incremental_rollouts.md)
- [功能标志](../operations/feature_flags.md)
- [极狐GitLab Pages](../user/project/pages/_index.md)

{{< /cards >}}

<a id="related-topics"></a>

## 相关主题

- [Auto DevOps](autodevops/_index.md) 是一个自动化的基于 CI/CD 的工作流，支持整个软件供应链：使用极狐GitLab CI/CD 构建、测试、代码检查、打包、部署、防护和监控应用程序。它提供了一组开箱即用的模板，可满足绝大多数使用场景。
- [Auto Deploy](autodevops/stages.md#auto-deploy) 是专用于使用极狐GitLab CI/CD 进行软件部署的 DevOps 阶段。Auto Deploy 内置了对 EC2 和 ECS 部署的支持。
- 使用 [极狐GitLab Kubernetes 代理](../user/clusters/agent/install/_index.md) 部署到 Kubernetes 集群。
- 使用 Docker 镜像从极狐GitLab CI/CD 运行 AWS 命令，并使用模板来简化 [部署到 AWS](../ci/cloud_deployment/_index.md)。
- 使用极狐GitLab CI/CD 来针对极狐GitLab Runner 可访问的任何类型的基础设施。[用户和预定义环境变量](../ci/variables/_index.md) 以及 CI/CD 模板支持设置多种部署策略。
- 使用极狐GitLab [Cloud Seed](../cloud_seed/_index.md) 设置部署凭证，并以最小摩擦将应用程序部署到 Google Cloud Run。

