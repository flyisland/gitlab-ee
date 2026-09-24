---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Google Cloud Compute Engine 中部署 Runner
---

<a id="provision-runners-in-google-cloud-compute-engine"></a>

## 在 Google Cloud Compute Engine 中部署 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 16.10 中引入[作为功能标志](../../administration/feature_flags/_index.md)，命名为 `google_cloud_support_feature_flag`。此功能处于[测试版](../../policy/development_stages_support.md)。
- 在 极狐GitLab 17.1 中[在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/150472)。功能标志 `google_cloud_support_feature_flag` 被移除。

{{< /history >}}

您可以为 JihuLab.com 创建项目或群组 Runner，并在您的 Google Cloud 项目上部署它。当您创建 Runner 时，极狐GitLab UI 会提供屏幕上的说明和脚本，以在 Google Cloud 项目中自动部署此 Runner。

创建 Runner 时，系统会为该 Runner 分配一个 Runner 认证令牌。[GRIT](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/grit) Terraform 脚本使用此令牌来注册 Runner。然后，当 Runner 从作业队列中拾取作业时，它会使用此令牌向 极狐GitLab 进行身份验证。

部署完成后，一个自动伸缩的 Runner 集群就准备好在 Google Cloud 中运行 CI/CD 作业。Runner 管理器会自动创建临时 Runner。

先决条件：

- 对于群组 Runner：群组的所有者角色。
- 对于项目 Runner：项目的维护者角色。
- 对于您的 Google Cloud Platform 项目：具有 [Owner](https://cloud.google.com/iam/docs/understanding-roles#owner) IAM 角色。
- 您的 Google Cloud Platform 项目已[启用结算功能](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled#confirm_billing_is_enabled_on_a_project)。
- 一个已通过 Google Cloud 项目上的 IAM 角色进行身份验证且可正常运行的 [`gcloud` CLI 工具](https://cloud.google.com/sdk/docs/install)。
- [Terraform v1.5 或更高版本](https://releases.hashicorp.com/terraform/1.5.7/)以及 [Terraform CLI 工具](https://developer.hashicorp.com/terraform/install)。
- 已安装 Bash 的终端。

要创建群组或项目 Runner 并在 Google Cloud 上部署它，请执行以下操作：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 创建一个新的 Runner。
   - 要创建新的群组 Runner，请选择 **构建** > **Runner** > **新建群组 Runner**。
   - 要创建新的项目 Runner，请选择 **设置** > **CI/CD** > **Runner** > **新建项目 Runner**。
1. 在 **标签** 部分中的 **标签** 字段，输入作业标签以指定 Runner 可运行的作业。
   若要使 Runner 同时运行带有标签和不带标签的作业，请选择 **运行未标记的作业**。
1. 可选。在 **配置** 部分中，添加 Runner 描述和其他配置。
1. 选择 **创建 Runner**。
1. 在 **平台** 部分中，选择 **Google Cloud**。
1. 在 **环境** 中，输入以下 Google Cloud 环境的详细信息：

   - **Google Cloud 项目 ID**
   - **区域**
   - **可用区**
   - **机器类型**

1. 在 **设置极狐GitLab Runner** 中，选择 **设置说明**。在对话框中：

   1. 要启用所需的服务、服务账号和权限，请在 **配置 Google Cloud 项目** 中，为每个 Google Cloud 项目运行一次 Bash 脚本。
   1. 使用来自 **安装并注册极狐GitLab Runner** 的配置创建一个 `main.tf` 文件。
      该脚本使用 [极狐GitLab Runner 基础设施工具包](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/grit/-/blob/main/docs/scenarios/google/linux/docker-autoscaler-default/index.md)（GRIT）在 Google Cloud 项目上部署基础设施，以执行您的 Runner 管理器。

      > [!warning]
      > 默认情况下，Runner 配置可能导致虚拟机实例持续运行，即使没有活跃的 CI/CD 作业也是如此。
      > 要控制自动伸缩行为并降低成本，请在您的管理器实例上找到 Runner 配置文件，并编辑
      > [`[runners.machine]` 部分](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runnersmachine-section)
      > 以调整诸如 `IdleCount`、`IdleTime` 和实例限制等参数。

执行脚本后，一个 Runner 管理器会使用 Runner 认证令牌进行连接。Runner 管理器最多可能需要一分钟才能显示为在线并开始接收作业。