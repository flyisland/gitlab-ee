---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
ignore_in_report: true
title: 云播种
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.4 中引入，带有名为 `google_cloud` 的功能标志。默认禁用。
- 于 极狐GitLab 15.5 中在 私有化部署 和 JihuLab.com 上启用。

{{< /history >}}

云播种 是由 极狐GitLab 与 [Google Cloud](https://cloud.google.com/) 合作领导的开源项目。

云播种 将类似 Heroku 的易用性与超云灵活性相结合。我们通过使用 OAuth 2 在超云上配置服务，并基于 Terraform 和基础设施即代码来实现后续运维。

<a id="purpose"></a>

## 目的

我们相信，从 极狐GitLab 将 Web 应用程序（及其他工作负载）部署到主流云提供商应该是轻而易举的。

为了支持这一目标，云播种 使在 极狐GitLab 中消费适当的 Google Cloud 服务变得直接且直观。

<a id="why-google-cloud"></a>

## 为什么选择 Google Cloud

*或者说为什么不是 AWS 或 Azure？*

云播种 是一个任何人都可以扩展的开源项目，我们期待与每一家主流云提供商合作。我们之所以选择与 Google Cloud 合作，是因为他们的团队在这个项目中易于接触、乐于支持且善于协作。

作为一个开源项目，[每个人都可以贡献](#contribute-to-cloud-seed)并塑造我们的方向。

<a id="deploy-to-google-cloud-run"></a>

## 部署到 Google Cloud Run

在你的 极狐GitLab 项目中已有 Web 应用程序后，按照以下步骤使用 云播种 将应用程序从 极狐GitLab 部署到 Google Cloud：

1. [设置部署凭证](#set-up-deployment-credentials)
1. (可选) [配置首选 GCP 区域](#configure-your-preferred-gcp-region)
1. [配置 Cloud Run 部署流水线](#configure-the-cloud-run-deployment-pipeline)

<a id="set-up-deployment-credentials"></a>

### 设置部署凭证

云播种 提供了一个接口，可以从你的 极狐GitLab 项目创建 Google Cloud Platform (GCP) 服务账号。相关的 GCP 项目必须在服务账号创建工作流中被选中。此过程会生成服务账号、密钥和部署权限。

要创建服务账号：

1. 前往 `项目 :: 基础设施 :: Google Cloud` 页面。
1. 选择 **创建服务账号**。
1. 遵循 Google OAuth 2 工作流并授权 极狐GitLab。
1. 选择你的 GCP 项目。
1. 为所选的 GCP 项目关联一个 Git 引用（例如分支或标签）。
1. 提交表单以创建服务账号。

生成的服务账号、服务账号密钥以及关联的 GCP 项目 ID 将作为项目 CI 变量存储在 极狐GitLab 中。你可以在 `项目 :: 设置 :: CI` 页面查看和管理这些变量。

生成的服务账号具有以下角色：

- `roles/iam.serviceAccountUser`
- `roles/artifactregistry.admin`
- `roles/cloudbuild.builds.builder`
- `roles/run.admin`
- `roles/storage.admin`
- `roles/cloudsql.client`
- `roles/browser`

你可以通过将 CI 变量存储在密钥管理器中来增强安全性。更多信息，请参阅 [极狐GitLab 中的密钥管理](../ci/secrets/_index.md)。

<a id="configure-your-preferred-gcp-region"></a>

### 配置首选 GCP 区域

当你为部署配置 GCP 区域时，提供的区域列表是所有可用 GCP 区域的一个子集。

要配置区域：

1. 前往 `项目 :: 基础设施 :: Google Cloud` 页面。
1. 选择 **配置 GCP 区域**。
1. 选择你的首选 GCP 区域。
1. 为所选的 GCP 区域关联一个 Git 引用（例如分支或标签）。
1. 提交表单以配置 GCP 区域。

配置好的 GCP 区域将作为项目 CI 变量存储在 极狐GitLab 中。你可以在 `项目 :: 设置 :: CI` 页面查看和管理这些变量。

<a id="configure-the-cloud-run-deployment-pipeline"></a>

### 配置 Cloud Run 部署流水线

你可以在流水线中配置 Google Cloud Run 部署作业。此类流水线的典型用例是 Web 应用程序的持续部署。

项目流水线本身可能具有更广泛的目的，涵盖多个阶段，如构建、测试和安全。因此，Cloud Run 部署功能被封装为一个可融入更大流水线的作业。

要配置 Cloud Run 部署流水线：

1. 前往 `项目 :: 基础设施 :: Google Cloud` 页面。
1. 进入 `部署` 标签页。
1. 对于 `Cloud Run`，选择 **通过合并请求配置**。
1. 检查更改并提交以创建合并请求。

这将创建一个包含 Cloud Run 部署流水线的新分支（或注入到现有流水线中），并创建一个关联的合并请求，可以在其中审查更改和部署流水线执行情况，然后合并到主分支。

<a id="provision-cloud-sql-databases"></a>

## 配置 Cloud SQL 数据库

可以从 `项目 :: 基础设施 :: Google Cloud` 页面配置关系型数据库实例。Cloud SQL 是用于配置数据库实例的底层 Google Cloud 服务。

支持以下数据库及版本：

- PostgreSQL：14、13、12、11、10 和 9.6
- MySQL：8.0、5.7 和 5.6
- SQL Server
  - 2019：Standard、Enterprise、Express 和 Web
  - 2017：Standard、Enterprise、Express 和 Web

适用 Google Cloud 定价。请参阅 [Cloud SQL 定价页面](https://cloud.google.com/sql/pricing)。

1. [创建数据库实例](#create-a-database-instance)
1. [通过后台 Worker 进行数据库设置](#database-setup-through-a-background-worker)
1. [连接到数据库](#connect-to-the-database)
1. [管理数据库实例](#managing-the-database-instance)

<a id="create-a-database-instance"></a>

### 创建数据库实例

在 `项目 :: 基础设施 :: Google Cloud` 页面，选择 **数据库** 标签。这里你会看到三个按钮，分别用于创建 Postgres、MySQL 和 SQL Server 数据库实例。

数据库实例创建表单包含 GCP 项目、Git 引用（分支或标签）、数据库版本和机器类型字段。提交后，数据库实例将被创建，数据库设置将作为后台作业排队。

<a id="database-setup-through-a-background-worker"></a>

### 通过后台 Worker 进行数据库设置

数据库实例成功创建后，将触发一个后台 Worker 执行以下任务：

- 创建数据库用户
- 创建数据库模式
- 将数据库详细信息存储在项目的 CI/CD 变量中

<a id="connect-to-the-database"></a>

### 连接到数据库

数据库实例设置完成后，数据库连接详细信息将作为项目变量提供。这些变量可以通过 `项目 :: 设置 :: CI` 页面进行管理，并可在适当环境中运行的流水线中使用。

<a id="managing-the-database-instance"></a>

### 管理数据库实例

`项目 :: 基础设施 :: Google Cloud :: 数据库` 中的实例列表链接回 Google Cloud Console。选择一个实例以查看详细信息并管理该实例。

<a id="contribute-to-cloud-seed"></a>

## 贡献到 云播种

你可以通过多种方式为 云播种 做出贡献：

- 使用 云播种 并 [分享反馈](https://jihulab.com/gitlab-cn/incubation-engineering/five-minute-production/feedback/-/issues/new?template=general_feedback)。
- 如果你熟悉 Ruby on Rails 或 Vue.js，可以考虑作为开发者向 极狐GitLab 贡献力量。
  - 云播种 的很大一部分是 极狐GitLab 代码库中的一个内部模块。
- 如果你熟悉 极狐GitLab 流水线，可以考虑为 [Cloud Seed 库](https://jihulab.com/gitlab-cn/incubation-engineering/five-minute-production/library) 项目贡献力量。