---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Google Cloud Compute Engine 中预配 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

您可以为 JihuLab.com 创建项目 Runner 或群组 Runner，并将其预配到您的 Google Cloud 项目中。
创建 Runner 时，极狐GitLab UI 会提供屏幕上的说明和脚本，以便在您的 Google Cloud 项目中自动预配该 Runner。

创建 Runner 时，系统会为其分配一个 Runner 认证令牌。[GRIT](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit) Terraform 脚本使用此令牌
注册该 Runner。随后，Runner 在从作业队列中获取作业时，会使用该令牌向极狐GitLab 进行认证。

预配完成后，一个自动扩缩的 Runner 集群即可在 Google Cloud 中运行 CI/CD 作业。
Runner 管理器会自动创建临时 Runner。

先决条件：

- 对于群组 Runner：拥有该群组的所有者角色。
- 对于项目 Runner：拥有该项目的维护者角色。
- 对于您的 Google Cloud Platform 项目：拥有 [Owner](https://cloud.google.com/iam/docs/understanding-roles#owner) IAM 角色。
- 您的 Google Cloud Platform 项目已[启用结算](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled#confirm_billing_is_enabled_on_a_project)。
- 一个可用的 [`gcloud` CLI 工具](https://docs.cloud.google.com/sdk/docs/install-sdk)，已使用 Google Cloud 项目上的
  IAM 角色完成认证。
- [Terraform v1.5 或更高版本](https://releases.hashicorp.com/terraform/1.5.7/)以及 [Terraform CLI 工具](https://developer.hashicorp.com/terraform/install)。
- 一个已安装 Bash 的终端。

要创建群组 Runner 或项目 Runner 并将其预配到 Google Cloud：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组。
1. 创建新的 Runner。
   - 要创建新的群组 Runner，选择**构建** > **Runner** > **新建群组 Runner**。
   - 要创建新的项目 Runner，选择**设置** > **CI/CD** > **Runner** > **新建项目 Runner**。
1. 在**标签**部分的**标签**字段中，输入作业标签，以指定该 Runner 可以运行的作业。
   除了带标签的作业外，如果还要将该 Runner 用于不带标签的作业，请选择**运行未打标签的作业**。
1. 可选。在**配置**部分中，添加 Runner 描述和其他配置。
1. 选择**创建 Runner**。
1. 在**平台**部分中，选择 **Google Cloud**。
1. 在**环境**中，输入 Google Cloud 环境的以下详细信息：

   - **Google Cloud 项目 ID**
   - **区域**
   - **可用区**
   - **机器类型**

1. 在**设置极狐GitLab Runner**中，选择**设置说明**。在对话框中：

   1. 要启用所需的服务、服务账号和权限，请在**配置 Google Cloud 项目**中为每个 Google Cloud 项目运行一次 Bash 脚本。
   1. 使用**安装并注册极狐GitLab Runner**中的配置创建一个 `main.tf` 文件。
      该脚本使用 [GitLab Runner Infrastructure Toolkit](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/blob/main/docs/scenarios/google/linux/docker-autoscaler-default/index.md)
      （GRIT）在 Google Cloud 项目上预配基础设施，以执行您的 Runner 管理器。

      > [!warning]
      > 默认情况下，Runner 的配置可能会导致 VM 实例持续运行，即使没有活动的 CI/CD 作业也是如此。
      > 要控制自动扩缩行为并降低成本，请在管理器实例上找到 Runner 配置文件，并编辑
      > [`[runners.machine]` 部分](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runnersmachine-section)
      > 以调整 `IdleCount`、`IdleTime` 和实例限制等参数。

执行脚本后，Runner 管理器会使用 Runner 认证令牌进行连接。Runner 管理器最多可能需要一分钟才会显示为在线并开始接收作业。
