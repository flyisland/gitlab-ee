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

对于处于互联网访问受限、受限或间歇性访问外部资源的环境中的实例，需要做一些调整才能使 Web API 模糊测试作业成功运行。

步骤：

1. 将 Docker 镜像托管在本地容器镜像仓库中。
2. 将 `SECURE_ANALYZERS_PREFIX` 设置为本地容器镜像仓库。

API 模糊测试的 Docker 镜像必须从公共仓库拉取（下载），然后推送（导入）到本地仓库中。可以使用极狐GitLab 容器镜像仓库在本地托管 Docker 镜像。此过程可以使用特殊模板执行。有关说明，请参见[将 Docker 镜像加载到离线主机上](../../offline_deployments/_index.md#loading-docker-images-onto-your-offline-host)。

一旦 Docker 镜像在本地托管，`SECURE_ANALYZERS_PREFIX` 变量将被设置为本地仓库的位置。该变量必须设置为使得拼接 `/api-security:2` 后能得到一个有效的镜像位置。

例如，下面这行为镜像 `registry.gitlab.com/security-products/api-security:2` 设置了仓库：

`SECURE_ANALYZERS_PREFIX: "registry.gitlab.com/security-products"`

> [!note]
> 设置 `SECURE_ANALYZERS_PREFIX` 会更改所有极狐GitLab 安全模板的 Docker 镜像仓库位置。

更多信息，请参见[离线环境](../../offline_deployments/_index.md)。

