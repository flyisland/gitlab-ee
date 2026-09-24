---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 每个项目多个集群（使用集群证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 使用单个项目的多个 Kubernetes 集群 **使用集群证书** 在极狐GitLab 14.5 中[已弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。
> 要将集群连接到极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

你可以将多个 Kubernetes 集群关联到你的项目。这样你就可以为不同的环境（例如开发、预发布、生产等）使用不同的集群。
像第一次那样添加另一个集群，并务必[设置环境范围](#setting-the-environment-scope)以将新集群与其他集群区分开来。

<a id="setting-the-environment-scope"></a>

## 设置环境范围

向项目添加多个 Kubernetes 集群时，你需要使用环境范围来区分它们。环境范围将集群与[环境](../../../ci/environments/_index.md)关联起来，其工作方式类似于[特定环境的 CI/CD 变量](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

默认的环境范围是 `*`，这意味着所有任务（无论其环境如何）都使用该集群。一个项目中的每个范围只能被一个集群使用，否则会发生验证错误。此外，未设置环境关键字的任务将无法访问任何集群。

例如，一个项目可能包含以下 Kubernetes 集群：

| 集群 | 环境范围 |
|------|----------|
| 开发 | `*`      |
| 生产 | `production`     |

并且在 `.gitlab-ci.yml` 文件中设置了以下环境：

```yaml
stages:
  - test
  - deploy

test:
  stage: test
  script: sh test

deploy to staging:
  stage: deploy
  script: make deploy
  environment:
    name: staging
    url: https://staging.example.com/

deploy to production:
  stage: deploy
  script: make deploy
  environment:
    name: production
    url: https://example.com/
```

结果如下：

- 开发集群的详细信息在 `deploy to staging` 任务中可用。
- 生产集群的详细信息在 `deploy to production` 任务中可用。
- `test` 任务中没有可用的集群详细信息，因为它没有定义任何环境。

