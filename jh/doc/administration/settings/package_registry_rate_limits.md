---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 软件包仓库速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

借助[极狐GitLab 软件包仓库](../../user/packages/package_registry/_index.md)，您可以将极狐GitLab 用作多种常见软件包管理器的私有或公共仓库。您可以发布和共享软件包，其他项目可通过[软件包 API](../../api/packages.md) 将这些软件包作为下游项目中的依赖项进行使用。

如果下游项目经常下载此类依赖项，会通过软件包 API 产生许多请求。因此您可能会达到强制执行的[用户和 IP 速率限制](user_and_ip_rate_limits.md)。为解决此问题，您可以为软件包 API 定义特定的速率限制：

- [未认证请求（每个 IP）](#enable-unauthenticated-request-rate-limit-for-packages-api)。
- [已认证 API 请求（每个用户）](#enable-authenticated-api-request-rate-limit-for-packages-api)。

这些限制默认禁用。

启用后，它们将取代针对软件包 API 请求的通用用户和 IP 速率限制。因此，您可以保留通用用户和 IP 速率限制，同时提高软件包 API 的速率限制。除了这种优先级之外，其功能与通用用户和 IP 速率限制没有区别。

<a id="enable-unauthenticated-request-rate-limit-for-packages-api"></a>

## 启用软件包 API 未认证请求速率限制

前提条件：

- 管理员访问权限。

要启用未认证请求速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **软件包仓库速率限制**。
1. 选择 **启用未认证请求速率限制**。

   - 可选。更新 **每个速率限制周期每个 IP 的最大未认证请求数** 值。默认为 `800`。
   - 可选。更新 **未认证速率限制周期（秒）** 值。默认为 `15`。

<a id="enable-authenticated-api-request-rate-limit-for-packages-api"></a>

## 启用软件包 API 已认证 API 请求速率限制

前提条件：

- 管理员访问权限。

要启用已认证 API 请求速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **软件包仓库速率限制**。
1. 选择 **启用已认证 API 请求速率限制**。

   - 可选。更新 **每个速率限制周期每个用户的最大已认证 API 请求数** 值。默认为 `1000`。
   - 可选。更新 **已认证 API 速率限制周期（秒）** 值。默认为 `15`。