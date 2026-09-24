---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Harbor
description: 配置 Harbor 作为您极狐GitLab 项目的开源容器镜像仓库，以跨平台管理制品。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 Harbor 作为极狐GitLab 项目的容器镜像仓库。

[Harbor](https://goharbor.io/) 是一个开源镜像仓库，可帮助您跨 Kubernetes 和 Docker 等云原生计算平台管理制品。

如果您需要极狐GitLab CI/CD 和容器镜像仓库，Harbor 集成可以为您提供帮助。

<a id="prerequisites"></a>

## 前提条件

在 Harbor 实例中，确保：

- 已创建要集成的项目。
- 已认证用户具有在 Harbor 项目中拉取、推送和编辑镜像的权限。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

极狐GitLab 支持在群组或项目级别集成 Harbor 项目。在极狐GitLab 中完成以下步骤：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Harbor**。
1. 在 **启用集成** 下，选中 **激活** 复选框。
1. 提供 Harbor 配置信息：
   - **Harbor URL**：要链接到此极狐GitLab 项目的 Harbor 实例的基础 URL。例如，`https://harbor.example.net`。
   - **Harbor 项目名称**：Harbor 实例中的项目名称。例如，`testproject`。
   - **用户名**：您在 Harbor 实例中的用户名，应符合[前提条件](#prerequisites)中的要求。
   - **密码**：您的用户名的密码。

1. 选择 **保存更改**。

Harbor 集成激活后：

- 全局变量 `$HARBOR_USERNAME`、`$HARBOR_HOST`、`$HARBOR_OCI`、`$HARBOR_PASSWORD`、`$HARBOR_URL` 和 `$HARBOR_PROJECT` 被创建用于 CI/CD。
- 项目级集成设置会覆盖群组级集成设置。

<a id="security-considerations"></a>

## 安全注意事项

<a id="secure-your-requests-to-the-harbor-apis"></a>

### 保护对 Harbor API 的请求

对于通过 Harbor 集成发出的每个 API 请求，连接到 Harbor API 的凭证使用 `username:password` 组合。以下是安全使用的建议：

- 在您连接的 Harbor API 上使用 TLS。
- 遵循最小权限原则（在 Harbor 上的访问权限）使用您的凭证。
- 为您的凭证制定轮换策略。

<a id="ci-cd-variable-security"></a>

### CI/CD 变量安全

推送到您的 `.gitlab-ci.yml` 文件的恶意代码可能会危及您的变量，包括 `$HARBOR_PASSWORD`，并将其发送到第三方服务器。有关更多详细信息，请参阅[CI/CD 变量安全](../../../ci/variables/_index.md#cicd-variable-security)。

<a id="use-harbor-variables"></a>

## 使用 Harbor 变量

<a id="push-a-helm-chart-with-an-oci-registry"></a>

### 使用 OCI 镜像仓库推送 Helm Chart

Helm 默认支持 OCI 镜像仓库。[Harbor 2.0](https://github.com/goharbor/harbor/releases/tag/v2.0.0) 及更高版本支持 OCI。在 Helm 的[博客](https://helm.sh/blog/storing-charts-in-oci/)和[文档](https://helm.sh/docs/topics/registries/#enabling-oci-support)中了解更多关于 OCI 的信息。

```yaml
helm:
  stage: helm
  image:
    name: dtzar/helm-kubectl:latest
    entrypoint: ['']
  variables:
    # 启用 OCI 支持（自 Helm v3.8.0 起不再需要）
    HELM_EXPERIMENTAL_OCI: 1
  script:
    # 登录 Helm 镜像仓库
    - helm registry login "${HARBOR_URL}" -u "${HARBOR_USERNAME}" -p "${HARBOR_PASSWORD}"
    # 打包您的 Helm Chart，它位于 `test` 目录中
    - helm package test
    # 您的 Helm Chart 创建为 <chart name>-<chart release>.tgz
    # 您可以将所有构建的 Chart 推送到您的 Harbor 仓库
    - helm push test-*.tgz ${HARBOR_OCI}/${HARBOR_PROJECT}
```

