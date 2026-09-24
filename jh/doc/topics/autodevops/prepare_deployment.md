---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为部署准备 Auto DevOps
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果你在没有设置基础域和部署策略的情况下启用 Auto DevOps，极狐GitLab 无法直接部署你的应用程序。因此，你应该在启用 Auto DevOps 之前准备好这些策略。

<a id="deployment-strategy"></a>

## 部署策略

当使用 Auto DevOps 部署你的应用程序时，选择最适合你需求的[持续部署策略](../../ci/_index.md)：

| 部署策略 | 设置 | 方法 |
|---------|------|-----|
| **持续部署到生产环境** | 启用 [Auto Deploy](stages.md#auto-deploy)，默认分支持续部署到生产环境。 | 持续部署到生产环境。 |
| **使用定时增量发布的持续部署到生产环境** | 将 [`INCREMENTAL_ROLLOUT_MODE`](cicd_variables.md#timed-incremental-rollout-to-production) 变量设置为 `timed`。 | 持续部署到生产环境，每次发布之间延迟 5 分钟。 |
| **自动部署到预发布环境，手动部署到生产环境** | 将 [`STAGING_ENABLED`](cicd_variables.md#deploy-policy-for-staging-and-production-environments) 设置为 `1`，并将 [`INCREMENTAL_ROLLOUT_MODE`](cicd_variables.md#incremental-rollout-to-production) 设置为 `manual`。 | 默认分支持续部署到预发布环境，并持续交付到生产环境。 |

你可以在启用 Auto DevOps 时或之后选择部署方法：

1. 在极狐GitLab 中，进入你的项目的 **设置** > **CI/CD** > **Auto DevOps**。
1. 选择部署策略。
1. 选择 **保存更改**。

> [!note]
> 使用[蓝绿部署](../../ci/environments/incremental_rollouts.md#blue-green-deployment)技术以最小化停机时间和风险。

<a id="auto-devops-base-domain"></a>

## Auto DevOps 基础域

要使用 [Auto Review Apps](stages.md#auto-review-apps) 和 [Auto Deploy](stages.md#auto-deploy)，需要设置 Auto DevOps 基础域。

要定义基础域，可以通过以下方式：

- 在项目、群组或实例中：进入集群设置并在那里添加。
- 在项目或群组中：将其添加为环境变量：`KUBE_INGRESS_BASE_DOMAIN`。
- 在实例中：进入 **管理员** 区域，然后 **设置** > **CI/CD** > **持续集成和交付** 并在那里添加。

基础域变量 `KUBE_INGRESS_BASE_DOMAIN` 与其他环境[变量](../../ci/variables/_index.md#cicd-variable-precedence)遵循相同的优先级顺序。

如果你没有在项目和群组中指定基础域，Auto DevOps 将使用实例范围的 **Auto DevOps 域**。

Auto DevOps 需要一个与基础域匹配的通配符 DNS `A` 记录。对于 `example.com` 基础域，你需要类似如下的 DNS 条目：

```plaintext
*.example.com   3600     A     10.0.2.2
```

在这种情况下，部署的应用程序通过 `example.com` 提供服务，`10.0.2.2` 是你的负载均衡器的 IP 地址，通常是 NGINX（[参见要求](requirements.md)）。设置 DNS 记录不在本文档范围内；请向你的 DNS 提供商咨询相关信息。

或者，你可以使用像 [nip.io](https://nip.io) 这样的免费公共服务，它们提供自动通配符 DNS，无需任何配置。对于 [nip.io](https://nip.io)，将 Auto DevOps 基础域设置为 `10.0.2.2.nip.io`。

完成设置后，所有请求都会到达负载均衡器，该均衡器将请求路由到运行你的应用程序的 Kubernetes Pod。

