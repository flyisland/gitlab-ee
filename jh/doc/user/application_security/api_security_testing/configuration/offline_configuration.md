---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 离线配置
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

对于通过互联网访问外部资源受限、受限制或时断时续的环境中的实例，需要进行一些调整，API 安全测试作业才能成功运行。

步骤：

1. 将 Docker 镜像托管在本地容器镜像仓库中。
1. 将 `SECURE_ANALYZERS_PREFIX` 设置为该本地容器镜像仓库。

API 安全测试的 Docker 镜像必须从公共镜像仓库拉取（下载），然后推送（导入）到本地镜像仓库。可以使用极狐GitLab 容器镜像仓库在本地托管该 Docker 镜像。此过程可以使用一个特殊模板来完成。有关说明，请参阅[将 Docker 镜像加载到离线主机](../../offline_deployments/_index.md#loading-docker-images-onto-your-offline-host)。

在本地托管 Docker 镜像后，将 `SECURE_ANALYZERS_PREFIX` 变量设置为本地镜像仓库的位置。设置该变量时，必须确保拼接 `/api-security:2` 后能得到有效的镜像位置。

> [!note]
> API 安全测试和 API 模糊测试使用相同的底层 Docker 镜像 `api-security:2`。

例如，下面这行代码为镜像 `registry.gitlab.com/security-products/api-security:2` 设置了一个镜像仓库：

`SECURE_ANALYZERS_PREFIX: "registry.gitlab.com/security-products"`

> [!note]
> 设置 `SECURE_ANALYZERS_PREFIX` 会更改所有极狐GitLab 安全模板的 Docker 镜像仓库位置。

有关更多信息，请参阅[离线环境](../../offline_deployments/_index.md)。
