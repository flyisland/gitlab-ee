---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 每个项目使用集群证书配置多个集群（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 为单个项目使用多个 Kubernetes 集群并**配合集群证书**的做法已在极狐GitLab 14.5 中[废弃](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)。
> 要将集群连接到极狐GitLab，请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

您可以将多个 Kubernetes 集群关联到您的项目。这样，您就可以为不同的环境使用不同的集群，例如开发、预发布、生产等。像第一次那样添加另一个集群，并确保[设置环境范围](#setting-the-environment-scope)，以将新集群与其他集群区分开。

<a id="setting-the-environment-scope"></a>

## 设置环境范围

当向项目添加多个 Kubernetes 集群时，您需要使用环境范围来区分它们。环境范围将集群与[环境](../../../ci/environments/_index.md)关联，其工作方式类似于[特定于环境的 CI/CD 变量](../../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

默认环境范围是 `*`，这意味着所有作业无论其环境如何，都使用该集群。每个范围在项目中只能由一个集群使用，否则会出现验证错误。此外，未设置环境关键字的作业无法访问任何集群。

例如，一个项目可能具有以下 Kubernetes 集群：

| 集群     | 环境范围 |
| ----------- | ----------------- |
| 开发 | `*`               |
| 生产  | `production`      |

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

- 开发集群的详细信息可在 `deploy to staging`
  作业中获取。
- 生产集群的详细信息可在 `deploy to production`
  作业中获取。
- `test` 作业中没有任何集群详细信息，因为它没有
  定义任何环境。
