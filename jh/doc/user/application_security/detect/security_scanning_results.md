---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全扫描结果
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在极狐GitLab 中查看并处理流水线安全扫描的结果。安全扫描器在流水线中运行，并输出安全报告。这些报告的内容会在极狐GitLab 中进行处理并呈现。

必须为您的项目配置安全扫描，才能生成结果。有关配置安全扫描器的信息，请参见[安全配置](security_configuration.md)。

理解安全扫描结果的关键术语：

发现
: 发现是在开发分支中识别出的潜在漏洞。当该分支合并到默认分支时，发现就会成为漏洞。
: 发现会在相关 CI/CD 作业产物过期时，或在流水线创建后的一段设定时间后过期，即使相关作业产物已被锁定。在 JihuLab.com 上，该期限为 30 天。在极狐GitLab 私有化部署上，默认期限为 90 天。管理员可以[更改保留期限](../../../administration/settings/security_and_compliance.md#security-scan-retention-period)，将其设置为 7 到 90 天之间的值。

漏洞
: 漏洞是在默认分支中识别出的软件安全弱点。
: 漏洞记录会一直保留，直到被[归档](../vulnerability_archival/_index.md)，即使该漏洞在默认分支中已不再被检测到。

在默认分支中识别出的漏洞会列在[漏洞报告](../vulnerability_report/_index.md)中。

<a id="security-report-artifacts"></a>

## 安全报告产物

安全扫描器在分支流水线中运行，如果已启用，也会在合并请求流水线中运行。每个安全扫描器都会输出一个安全报告产物，其中包含该特定安全扫描器检测到的所有发现或漏洞的详细信息。

来自[子流水线](../../../ci/pipelines/downstream_pipelines.md#view-child-pipeline-reports-in-merge-requests)的安全报告会包含在流水线安全报告和合并请求报告中。

在开发（非默认）分支中，发现会包含创建开发分支时目标分支中存在的任何漏洞。

发现会在相关 CI/CD 作业产物过期时，或在流水线创建后的一段设定时间后过期，即使相关作业产物已被锁定。在 JihuLab.com 上，该期限为 30 天。在极狐GitLab 私有化部署上，默认期限为 90 天，管理员可以将保留期限更改为 7 到 90 天之间的值。过期的发现不会显示在流水线的 **安全** 选项卡中。要重新生成它们，请重新运行流水线。

<a id="download-a-security-report"></a>

### 下载安全报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以下载安全报告，例如用于在极狐GitLab 之外进行分析或用于存档。安全报告是一个 JSON 文件。

先决条件：

- 项目需具有安全管理员、开发者、维护者或所有者角色。

要下载安全报告：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 选择**下载结果**，然后选择所需的安全报告。

所选安全报告会下载到您的设备。

![安全报告列表](img/security_report_v18_1.png)

<a id="pipeline-security-report"></a>

## 流水线安全报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

流水线安全报告包含该流水线运行检测到的所有发现或漏洞的详细信息。结果反映的是流水线运行所针对的提交时分支的状态，因此同一分支上的不同流水线可能会显示不同的结果。对于针对默认分支运行的流水线，流水线安全报告中的所有漏洞也会出现在漏洞报告中。

![流水线运行检测到的发现列表](img/pipeline_security_report_v18_1.png)

<a id="view-pipeline-security-report"></a>

### 查看流水线安全报告

查看流水线安全报告，以了解流水线运行检测到的所有发现或漏洞的详细信息。

先决条件：

- 项目需具有安全管理员、开发者、维护者或所有者角色。

要查看流水线安全报告：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择最新的流水线。

要查看发现或漏洞的详细信息，请选择其描述。

<a id="create-an-issue"></a>

### 创建议题

创建议题以跟踪、记录和管理发现或漏洞的修复工作。

先决条件：

- 项目需具有安全管理员、开发者、维护者或所有者角色。

要创建议题：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 选择某个发现的描述。
1. 选择**创建议题**。

系统会在项目中创建一个议题，其描述会从发现或漏洞的描述中复制。

<a id="change-status"></a>

### 更改状态

您可以在流水线的安全选项卡中更改发现或漏洞的状态。当分支合并到默认分支时，对发现所做的任何更改都会保留。

先决条件：

- 项目需具有维护者角色或 `admin_vulnerability` 自定义权限。

要更改发现或漏洞的状态：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择最新的流水线。
1. 选择 **安全** 选项卡。
1. 在发现报告中：

     1. 选择要更改的发现或漏洞。

        - 要选择单个发现或漏洞，请选择每个旁边的复选框。
        - 要选择页面上的所有发现或漏洞，请选择表头中的复选框。

     1. 在**选择操作**下拉列表中，选择**已忽略**或**需要分类**。
     1. 选择**更改状态**。

<a id="download-a-security-report-1"></a>

### 下载安全报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以下载安全报告，例如用于在极狐GitLab 之外进行分析或用于存档。安全报告是一个 JSON 文件。

先决条件：

- 项目需具有安全管理员、开发者、维护者或所有者角色。

要下载安全报告：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 选择**下载结果**，然后选择所需的安全报告。

所选安全报告会下载到您的设备。

![安全报告列表](img/security_report_v18_1.png)

<a id="merge-request-reports"></a>

## 合并请求报告

有关合并请求中的安全扫描结果，请参见[合并请求报告](../../project/merge_requests/reports.md)。

<a id="troubleshooting"></a>

## 故障排除

使用安全扫描时，您可能会遇到以下问题。

<a id="report-parsing-and-scan-ingestion-errors"></a>

### 报告解析和扫描摄取错误

> [!note]
> 这些步骤供极狐GitLab 支持用于重现此类错误。

某些安全扫描可能会导致流水线的 **安全** 选项卡中出现与报告解析或扫描摄取相关的错误。如果无法从用户处获取项目副本，您可以使用扫描生成的报告来重现该错误。

要重现该错误：

1. 从用户处获取报告副本。在本示例中为 `gl-sast-report.json`。
1. 创建一个项目。
1. 将报告提交到代码仓库。
1. 添加您的`.gitlab-ci.yml` 文件，并将该报告作为作业中的产物。

   例如，要重现由 SAST 作业引起的错误：

   ```yaml
   sample-job:
     script:
       - echo "Testing report"
     artifacts:
       reports:
         sast: gl-sast-report.json
   ```

1. 在流水线完成后，检查流水线的 **安全** 选项卡内容是否有错误。

您可以根据生成报告的扫描类型，将 `sast: gl-sast-report.json` 替换为相应的 [`artifacts:reports`](../../../ci/yaml/_index.md#artifactsreports) 类型和正确的 JSON 报告文件名。
