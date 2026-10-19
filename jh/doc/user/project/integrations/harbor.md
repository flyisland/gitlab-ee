---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Harbor
description: 将 Harbor 配置为开源容器镜像仓库，用于您的极狐GitLab 项目，以跨平台管理产物。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将 Harbor 用作极狐GitLab 项目的容器镜像仓库。

[Harbor](https://goharbor.io/) 是一个开源镜像仓库，可帮助您跨云原生计算平台（如 Kubernetes 和 Docker）管理产物。

如果您需要极狐GitLab CI/CD 和容器镜像仓库，Harbor 集成可以为您提供帮助。

<a id="prerequisites"></a>

## 先决条件

在 Harbor 实例中，请确保：

- 已创建要集成的项目。
- 已认证的用户有权在 Harbor 项目中拉取、推送和编辑镜像。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

极狐GitLab 支持在群组或项目级别集成 Harbor 项目。请在极狐GitLab 中完成以下步骤：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Harbor**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 提供 Harbor 配置信息：
   - **Harbor URL**：要链接到此极狐GitLab 项目的 Harbor 实例的基础 URL。例如，`https://harbor.example.net`。
   - **Harbor 项目名称**：Harbor 实例中的项目名称。例如，`testproject`。
   - **用户名**：您在 Harbor 实例中的用户名，应满足[先决条件](#prerequisites)中的要求。
   - **密码**：您用户名的密码。

1. 选择**保存更改**。

Harbor 集成激活后：

- 会创建全局变量 `$HARBOR_USERNAME`、`$HARBOR_HOST`、`$HARBOR_OCI`、`$HARBOR_PASSWORD`、`$HARBOR_URL` 和 `$HARBOR_PROJECT`，供 CI/CD 使用。
- 项目级集成设置会覆盖群组级集成设置。

<a id="security-considerations"></a>

## 安全注意事项

<a id="secure-your-requests-to-the-harbor-apis"></a>

### 保护您对 Harbor API 的请求

对于通过 Harbor 集成发出的每个 API 请求，您连接 Harbor API 的凭据使用 `username:password` 组合。以下是安全使用建议：

- 在您连接的 Harbor API 上使用 TLS。
- 对您的凭据遵循最小权限原则（针对 Harbor 上的访问）。
- 为您的凭据制定轮换策略。

<a id="cicd-variable-security"></a>

### CI/CD 变量安全

推送到 `.gitlab-ci.yml` 文件中的恶意代码可能会泄露您的变量，包括 `$HARBOR_PASSWORD`，并将其发送到第三方服务器。有关更多详细信息，请参阅 [CI/CD 变量安全](../../../ci/variables/_index.md#cicd-variable-security)。

<a id="use-harbor-variables"></a>

## 使用 Harbor 变量

<a id="push-a-helm-chart-with-an-oci-registry"></a>

### 使用 OCI 镜像仓库推送 Helm chart

Helm 默认支持 OCI 镜像仓库。OCI 在 [Harbor 2.0](https://github.com/goharbor/harbor/releases/tag/v2.0.0) 及更高版本中受支持。在 Helm [博客](https://helm.sh/blog/storing-charts-in-oci/)和[文档](https://helm.sh/docs/topics/registries/#enabling-oci-support)中阅读有关 OCI 的更多信息。

```yaml
helm:
  stage: helm
  image:
    name: dtzar/helm-kubectl:latest
    entrypoint: ['']
  variables:
    # Enable OCI support (not required since Helm v3.8.0)
    HELM_EXPERIMENTAL_OCI: 1
  script:
    # Log in to the Helm registry
    - helm registry login "${HARBOR_URL}" -u "${HARBOR_USERNAME}" -p "${HARBOR_PASSWORD}"
    # Package your Helm chart, which is in the `test` directory
    - helm package test
    # Your helm chart is created with <chart name>-<chart release>.tgz
    # You can push all building charts to your Harbor repository
    - helm push test-*.tgz ${HARBOR_OCI}/${HARBOR_PROJECT}
```
