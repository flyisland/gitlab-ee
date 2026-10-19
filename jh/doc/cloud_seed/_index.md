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

云播种是一个开源项目，由 GitLab 与
[Google Cloud](https://cloud.google.com/) 合作主导。

云播种将类似 Heroku 的易用性与超大规模云的灵活性结合在一起。为此，我们使用 OAuth 2 在超大规模云上预配服务，并以 Terraform 和基础设施即代码为基础，支持后续运维。

<a id="purpose"></a>

## 目的

我们认为，从极狐GitLab 将 Web 应用（以及其他工作负载）部署到主流云服务商应当是一件轻而易举的事。

为支持这一目标，云播种让在极狐GitLab 中使用合适的 Google Cloud 服务变得简单直观。

<a id="why-google-cloud"></a>

## 为什么选择 Google Cloud

*或者为什么不选 AWS 或 Azure？*

云播种是一个开源项目，任何人都可以扩展它，我们也希望与所有主流云服务商合作。我们选择与 Google Cloud 合作，是因为他们的团队在这项工作中平易近人、乐于支持且善于协作。

作为一个开源项目，[每个人都可以贡献](#contribute-to-cloud-seed)并影响我们的方向。

<a id="deploy-to-google-cloud-run"></a>

## 部署到 Google Cloud Run

在极狐GitLab 项目中准备好 Web 应用后，请按照以下步骤
使用 云播种将应用从极狐GitLab 部署到 Google Cloud：

1. [设置部署凭证](#set-up-deployment-credentials)
1. （可选）[配置您偏好的 GCP 区域](#configure-your-preferred-gcp-region)
1. [配置 Cloud Run 部署流水线](#configure-the-cloud-run-deployment-pipeline)

<a id="set-up-deployment-credentials"></a>

### 设置部署凭证

云播种提供了一个界面，用于从您的极狐GitLab 项目创建 Google Cloud Platform (GCP) 服务账号。必须在服务账号创建工作流中选择关联的 GCP 项目。此过程会生成服务账号、密钥和部署权限。

创建服务账号：

1. 转到 `Project :: Infrastructure :: Google Cloud` 页面。
1. 选择 **创建服务账号**。
1. 按照 Google OAuth 2 工作流操作，并授权极狐GitLab。
1. 选择您的 GCP 项目。
1. 为选定的 GCP 项目关联一个 Git 引用（例如分支或标签）。
1. 提交表单以创建服务账号。

生成的服务账号、服务账号密钥和关联的 GCP 项目 ID 会作为项目 CI 变量存储在极狐GitLab 中。您可以在 `Project :: Settings :: CI` 页面中查看和管理这些变量。

生成的服务账号具有以下角色：

- `roles/iam.serviceAccountUser`
- `roles/artifactregistry.admin`
- `roles/cloudbuild.builds.builder`
- `roles/run.admin`
- `roles/storage.admin`
- `roles/cloudsql.client`
- `roles/browser`

您可以通过将 CI 变量存储在密钥管理器中来增强安全性。有关更多信息，请参阅[使用极狐GitLab 进行密钥管理](../ci/secrets/_index.md)。

<a id="configure-your-preferred-gcp-region"></a>

### 配置您偏好的 GCP 区域

当您为部署配置 GCP 区域时，所提供的区域列表是所有可用 GCP 区域的子集。

配置区域：

1. 转到 `Project :: Infrastructure :: Google Cloud` 页面。
1. 选择 **配置 GCP 区域**。
1. 选择您偏好的 GCP 区域。
1. 为选定的 GCP 区域关联一个 Git 引用（例如分支或标签）。
1. 提交表单以配置 GCP 区域。

配置的 GCP 区域会作为项目 CI 变量存储在极狐GitLab 中。您可以在 `Project :: Settings :: CI` 页面中查看和管理这些变量。

<a id="configure-the-cloud-run-deployment-pipeline"></a>

### 配置 Cloud Run 部署流水线

您可以在流水线中配置 Google Cloud Run 部署作业。此类流水线的一个典型用例是持续部署您的 Web 应用。

项目流水线本身可能有更广泛的用途，跨越多个阶段，例如构建、测试和安全。因此，Cloud Run 部署功能被打包为一个作业，可嵌入到规模大得多的流水线中。

配置 Cloud Run 部署流水线：

1. 转到 `Project :: Infrastructure :: Google Cloud` 页面。
1. 转到 `Deployments` 选项卡。
1. 对于 `Cloud Run`，选择 **通过合并请求配置**。
1. 查看更改并提交，以创建合并请求。

这会创建一个包含 Cloud Run 部署流水线的新分支（或将其注入现有流水线），并创建一个关联的合并请求，可在其中查看更改和部署流水线的执行情况，并将其合并到主分支。

<a id="provision-cloud-sql-databases"></a>

## 预配 Cloud SQL 数据库

可以从 `Project :: Infrastructure :: Google Cloud` 页面预配关系型数据库实例。Cloud SQL 是用于预配数据库实例的底层 Google Cloud 服务。

支持以下数据库和版本：

- PostgreSQL：14、13、12、11、10 和 9.6
- MySQL：8.0、5.7 和 5.6
- SQL Server
  - 2019：Standard、Enterprise、Express 和 Web
  - 2017：Standard、Enterprise、Express 和 Web

适用 Google Cloud 定价。请参阅 [Cloud SQL 定价页面](https://cloud.google.com/sql/pricing)。

1. [创建数据库实例](#create-a-database-instance)
1. [通过后台工作进程进行数据库设置](#database-setup-through-a-background-worker)
1. [连接到数据库](#connect-to-the-database)
1. [管理数据库实例](#managing-the-database-instance)

<a id="create-a-database-instance"></a>

### 创建数据库实例

在 `Project :: Infrastructure :: Google Cloud` 页面中，选择 **数据库** 选项卡。在这里，您会找到三个
按钮，用于创建 Postgres、MySQL 和 SQL Server 数据库实例。

数据库实例创建表单包含 GCP 项目、Git 引用（分支或标签）、数据库版本和机器类型等字段。提交后，数据库实例即被创建，数据库设置会作为后台作业排队。

<a id="database-setup-through-a-background-worker"></a>

### 通过后台工作进程进行数据库设置

数据库实例成功创建后，会触发一个后台工作进程执行以下任务：

- 创建数据库用户
- 创建数据库模式
- 将数据库详细信息存储在项目的 CI/CD 变量中

<a id="connect-to-the-database"></a>

### 连接到数据库

数据库实例设置完成后，数据库连接详细信息会作为项目变量提供。这些信息可以通过 `Project :: Settings :: CI` 页面进行管理，并可供在相应环境中执行的流水线使用。

<a id="managing-the-database-instance"></a>

### 管理数据库实例

`Project :: Infrastructure :: Google Cloud :: Databases`中的实例列表会链接回 Google Cloud
控制台。选择某个实例以查看详细信息并管理该实例。

<a id="contribute-to-cloud-seed"></a>

## 为云播种 贡献

您可以通过多种方式为云播种 贡献：

- 使用云播种 并[分享反馈](https://gitlab.com/gitlab-org/incubation-engineering/five-minute-production/feedback/-/issues/new?template=general_feedback)。
- 如果您熟悉 Ruby on Rails 或 Vue.js，
  可以考虑以开发者身份为 GitLab 贡献。
  - 云播种的很大一部分是极狐GitLab 代码库中的内部模块。
- 如果您熟悉极狐GitLab 流水线，可以考虑为
  [云播种库](https://gitlab.com/gitlab-org/incubation-engineering/five-minute-production/library) 项目贡献。
