---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 离线配置
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

对于处于有限、受限或间歇性通过互联网访问外部资源的环境中的实例，需要一些调整才能使 DAST 作业成功运行。更多信息，请参见[离线环境](../../../offline_deployments/_index.md)。

<a id="requirements-for-offline-dast-support"></a>

## 离线 DAST 支持的要求

您可以在离线环境中使用任意版本的 DAST。为此，您需要：

- 具有 [`docker` 或 `kubernetes` 执行器](../_index.md)的极狐GitLab Runner。
  该 Runner 必须能够通过网络访问目标应用程序。
- 一个包含本地可用 DAST 副本的 Docker 容器镜像仓库
  [容器镜像](https://gitlab.com/security-products/dast)，该镜像可在
  [DAST 容器镜像仓库](https://gitlab.com/security-products/dast/container_registry)中找到。
  请参见[将 Docker 镜像加载到您的离线主机上](../../../offline_deployments/_index.md#loading-docker-images-onto-your-offline-host)。

极狐GitLab Runner 的[默认 `pull policy` 为 `always`](https://gitlab.cn/docs/runner/executors/docker/#using-the-always-pull-policy)，这意味着即使本地已有副本，Runner 仍会尝试从极狐GitLab 容器镜像仓库拉取 Docker 镜像。在离线环境中，如果您希望仅使用本地可用的 Docker 镜像，可以将极狐GitLab Runner 的 [`pull_policy` 设置为 `if-not-present`](https://gitlab.cn/docs/runner/executors/docker/#using-the-if-not-present-pull-policy)。但是，如果不在离线环境中，建议将 pull policy 设置保持为 `always`，以便在 CI/CD 流水线中使用更新的扫描器。

<a id="make-gitlab-dast-analyzer-images-available-inside-your-docker-registry"></a>

## 将极狐GitLab DAST 分析器镜像提供给您的 Docker 镜像仓库

对于 DAST，请将以下默认 DAST 分析器镜像从 `registry.gitlab.com` 导入到您的[本地 Docker 容器镜像仓库](../../../../packages/container_registry/_index.md)：

- `registry.gitlab.com/security-products/dast:latest`

将 Docker 镜像导入本地离线 Docker 镜像仓库的过程取决于**您的网络安全策略**。请咨询您的 IT 人员，以确定可接受且经过批准的方式，用于导入或临时访问外部资源。这些扫描器会[定期更新](../../../detect/vulnerability_scanner_maintenance.md)新定义，您或许能够自行进行偶尔的更新。

有关将 Docker 镜像保存和传输为文件的详细信息，请参阅 Docker 文档中的以下命令：
[`docker save`](https://docs.docker.com/reference/cli/docker/image/save/)、
[`docker load`](https://docs.docker.com/reference/cli/docker/image/load/)、
[`docker export`](https://docs.docker.com/reference/cli/docker/container/export/) 和
[`docker import`](https://docs.docker.com/reference/cli/docker/image/import/)。

<a id="set-dast-cicd-job-variables-to-use-local-dast-analyzers"></a>

## 设置 DAST CI/CD 作业变量以使用本地 DAST 分析器

将以下配置添加到您的 `.gitlab-ci.yml` 文件中。您必须将 `image` 替换为指向您本地 Docker 容器镜像仓库中托管的 DAST Docker 镜像：

```yaml
include:
  - template: DAST.gitlab-ci.yml
dast:
  image: registry.example.com/namespace/dast:latest
```

现在，DAST 作业应使用本地的 DAST 分析器副本扫描您的代码并生成安全报告，而无需互联网访问。

或者，您也可以使用 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 来覆盖 `dast` 镜像的基础镜像仓库地址。