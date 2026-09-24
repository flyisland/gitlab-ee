---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用文件导出迁移极狐GitLab 数据
description: "使用文件导出迁移极狐GitLab 数据。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

文件导出为您提供极狐GitLab 数据的便携软件包，适用于离线环境。
此迁移方法可保留大部分项目数据，包括
代码仓库、议题、合并请求和评论。

使用文件导出可以：

- 在离线环境之间迁移。
- 移动特定项目，而无需移动其整个群组结构。

对于大多数情况，[直接传输](../../group/import/_index.md) 仍是推荐的迁移方法。

> [!note]
> 您不应使用项目导出文件来备份数据。
> 使用项目导出文件进行备份并不总是有效，且并非所有条目都会被导出。

<a id="known-issues"></a>

## 已知问题

- 由于已知问题，您可能会遇到
  `PG::QueryCanceled: ERROR: canceling statement due to statement timeout` 错误。
  有关详细信息，请参阅
  [故障排查文档](import_export_troubleshooting.md#error-pgquerycanceled-error-canceling-statement-due-to-statement-timeout)。
- 在极狐GitLab 17.0、17.1 和 17.2 中，导入的史诗和工作项会映射
  到导入用户，而非原始作者。
- 对于合并请求，导入或导出期间仅保留最新的差异。
  导入或导出项目后，仅最新的差异版本和合并请求中的最新流水线可见。
- 目标命名空间内标题[与现有里程碑匹配](../milestones/_index.md#milestone-title-rules)的已导入里程碑，其标题将在导入时更新。新标题将附加唯一后缀。例如，`18.0` 将变为 `18.0
  (imported-3d-1770206299)`。为避免此情况，请在发起直接传输前，在源群组或项目中重命名里程碑。

<a id="migrate-projects-by-uploading-an-export-file"></a>

## 通过上传导出文件迁移项目

现有项目可以导出到文件，然后导入到另一个极狐GitLab 实例。

<a id="preserving-user-contributions"></a>

### 保留用户贡献

保留用户贡献的要求取决于您是迁移到 JihuLab.com
还是迁移到极狐GitLab 私有化部署实例。

<a id="when-migrating-from-gitlab-self-managed-to-gitlabcom"></a>

#### 从极狐GitLab 私有化部署迁移到 JihuLab.com

使用文件导出迁移项目时，需要管理员访问令牌才能正确映射用户贡献。

因此，从极狐GitLab 私有化部署实例导入文件导出到 JihuLab.com 时，用户贡献永远无法正确映射。
相反，所有极狐GitLab 用户关联（例如评论作者）都会更改为导入项目的用户。要保留
贡献历史，请执行以下任一操作：

- [使用直接传输迁移](../../group/import/_index.md)。
- 考虑联系专业服务团队。有关详细信息，请参阅
  [专业服务目录](https://about.gitlab.com/professional-services/catalog/)。

<a id="when-migrating-to-gitlab-self-managed"></a>

#### 迁移到极狐GitLab 私有化部署

为确保极狐GitLab 正确映射用户及其贡献：

- 项目顶级群组的所有者应导出项目，以便将所有有权访问该项目的成员（直接
  和继承）信息包含在导出文件中。项目维护者和所有者可以
  发起项目导出。但是，这样只会导出项目的直接成员。
- 必须由管理员执行导入。
- 目标极狐GitLab 实例上必须存在所需的用户。管理员可以在 Rails 控制台中
  批量创建已确认用户，也可以在 UI 中逐一创建。
- 用户必须在源极狐GitLab
  实例的[个人资料中设置公共邮箱](../../profile/_index.md#set-your-public-email)，该邮箱需与目标极狐GitLab 实例上的主邮箱地址匹配。您也可以通过[编辑项目导出文件](#edit-project-export-files)手动添加用户的公共邮箱。
- [在极狐GitLab 18.4 及更高版本中](https://gitlab.com/gitlab-org/gitlab/-/issues/559224)，当您将项目直接导入现有群组并创建直接成员资格时，[**此群组中的项目无法添加用户**设置](../../group/access_and_permissions.md#prevent-members-from-being-added-to-projects-in-a-group)会生效。

当现有用户的邮箱与导入用户的邮箱匹配时，该用户将作为
[直接成员](../members/_index.md)添加到导入的项目中。

如果上述任一条件未满足，用户贡献将无法正确映射。相反，所有极狐GitLab 用户
关联都会更改为执行导入的用户。该用户将成为其他用户创建的合并请求的作者。提及原始作者的补充评论：

- 会为评论、合并请求批准、关联的任务和条目添加。
- 不会为合并请求或议题创建者、添加或移除的标记以及合并信息添加。

<a id="edit-project-export-files"></a>

### 编辑项目导出文件

您可以向导出文件添加或删除数据。例如，您可以：

- 手动将用户的公共邮箱添加到 `project_members.ndjson` 文件。
- 通过从 `ci_pipelines.ndjson` 文件中删除行来精简 CI 流水线。

要编辑项目导出文件：

1. 解压导出的 `.tar.gz` 文件。
1. 编辑相应的文件。例如，`tree/project/project_members.ndjson`。
1. 将文件重新压缩为 `.tar.gz` 文件。

您还可以通过检查 `project_members.ndjson` 文件来确保所有成员都已导出。

<a id="compatibility"></a>

### 兼容性

项目文件导出采用 NDJSON 格式。

您可以导入从落后最多两个[次要](../../../policy/maintenance.md#versioning)版本的极狐GitLab 导出的项目文件导出。

例如：

| 目标版本 | 兼容的源版本 |
|:--------------------|:---------------------------|
| 13.0                | 13.0, 12.10, 12.9          |
| 13.1                | 13.1, 13.0, 12.10          |

<a id="configure-file-exports-as-an-import-source"></a>

### 将文件导出配置为导入源

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 私有化部署上使用文件导出迁移项目之前，极狐GitLab 管理员必须：

1. 在源实例上[启用文件导出](../../../administration/settings/import_and_export_settings.md#enable-project-export)。
1. 为目标实例启用文件导出作为导入源。在 JihuLab.com 上，文件导出已作为导入源启用。

要为目标实例启用文件导出作为导入源：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 滚动到 **导入源**。
1. 选中 **极狐GitLab 导出** 复选框。

<a id="between-ce-and-ee"></a>

### 在基础版和企业版之间

只要满足[兼容性](#compatibility)要求，您可以将项目从基础版导出到企业版，
反之亦然。

如果您将项目从企业版导出到基础版，可能会丢失
仅在企业版中保留的数据。有关详细信息，请参阅
[从企业版还原到基础版](../../../update/convert_to_ee/revert.md)。

<a id="export-a-project-and-its-data"></a>

### 导出项目及其数据

在导入项目之前，您必须先导出它。

先决条件：

- 查看[已导出的项目条目](#project-items-that-are-exported)列表。并非所有条目都会被导出。
- 您必须具有该项目的维护者或所有者角色。
- 对于具有大量 Git 引用的代码仓库，要显著提升性能，请使用极狐GitLab 18.0 或更高版本。有关详细信息，请参阅
  [关于缩短极狐GitLab 代码仓库备份时间的博客文章](https://about.gitlab.com/blog/how-we-decreased-gitlab-repo-backup-times-from-48-hours-to-41-minutes/)。

要导出项目及其数据，请执行以下步骤：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 选择 **导出项目**。
1. 导出生成后，您可以：
   - 点击您应收到的电子邮件中包含的链接。
   - 刷新项目设置页面，在 **导出项目** 区域，选择 **下载导出**。

导出文件生成在您配置的 `shared_path` 中，这是一个临时共享目录
（默认情况下为 `<shared_path>/tmp/gitlab_exports`），然后：

- 移动到您配置的 `uploads_directory`。
- 或上传到对象存储。

每 24 小时，一个 worker 会删除这些导出文件。

在具有独立 Sidekiq、Gitaly 和极狐GitLab 应用程序（Rails）节点的极狐GitLab 实例上，
[`shared_path`](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/b350e3cd5b06a94adb463ece4d41b9f3df6ab282/files/gitlab-config-template/gitlab.rb.template#L731)
设置中指定的目录必须对所有节点可用。

<a id="project-items-that-are-exported"></a>

#### 已导出的项目条目

导出的项目条目取决于您使用的极狐GitLab 版本。要确定某个特定项目条目是否会被导出：

1. 检查 [`exporters` 数组](https://gitlab.com/gitlab-org/gitlab/-/blob/b819a6aa6d53573980dd9ee4a1bfe597d69e88e5/app/services/projects/import_export/export_service.rb#L24)。
1. 检查您极狐GitLab 版本对应的项目的 [`project/import_export.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/import_export/project/import_export.yml)
   文件。例如，极狐GitLab 19.2 对应 <https://gitlab.com/gitlab-org/gitlab/-/blob/19-2-stable-ee/lib/gitlab/import_export/project/import_export.yml>。

快速概览，导出的条目包括：

- 项目和 Wiki 代码仓库
- 项目上传
- 项目配置，不包括集成
- 议题
  - 议题评论
  - 议题迭代
  - 议题资源状态事件
  - 议题资源里程碑事件
  - 议题资源迭代事件
- 合并请求
  - 合并请求差异
  - 合并请求评论
  - 合并请求资源状态事件
  - 合并请求多个指派人
  - 合并请求审核人
  - 合并请求批准者
- 提交评论
- 标记
- 里程碑
- 代码片段
- 发布
- 时间跟踪和其他项目实体
- 设计管理文件和设计数据
- LFS 对象
- 议题看板
- CI/CD 流水线（已归档）
- 流水线计划（未激活并分配给发起导入的用户）
- 受保护分支和标签
- 推送规则
- 表情反应

  > [!note]
  > 使用自定义表情的反应仅在目标实例上存在同名自定义表情时才会被导入。引用目标实例上缺失的自定义表情的反应将被跳过。

- 直接项目成员
  （如果您对导出项目的群组具有维护者或所有者角色）
- 作为直接项目成员的继承项目成员
  （如果您对导出项目的群组具有所有者角色或对实例具有管理员访问权限）
- 部分合并请求批准规则：
  - [受保护分支的批准](../merge_requests/approvals/rules.md#approvals-for-protected-branches)
  - [符合条件的批准者](../merge_requests/approvals/rules.md#eligible-approvers)
- 漏洞报告（在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/501466)）

<a id="project-items-that-are-not-exported"></a>

#### 未导出的项目条目

未导出的条目包括：

- [子流水线历史](https://gitlab.com/gitlab-org/gitlab/-/issues/221088)
- 流水线触发器
- CI/CD 作业跟踪和产物
- 软件包和容器镜像仓库中的镜像
- CI/CD 变量
- CI/CD 作业令牌允许列表
- Webhook
- 任何加密令牌
- [所需批准数量](https://gitlab.com/gitlab-org/gitlab/-/issues/221087)
- 代码仓库大小限制
- 允许推送到受保护分支的部署密钥
- 安全文件
- [Git 相关事件的活动日志](https://gitlab.com/gitlab-org/gitlab/-/issues/214700)（例如，推送和创建标签）
- 与您的项目关联的安全策略
- 议题与关联条目之间的链接
- 相关合并请求的链接
- 流水线计划变量

<a id="import-a-project-and-its-data"></a>

### 导入项目及其数据

您可以导入项目及其数据。您可以导入的数据量取决于最大导入文件大小：

- 在极狐GitLab 私有化部署上，管理员可以
  [设置最大导入文件大小](#set-maximum-import-file-size)。
- 在 JihuLab.com 上，该值[设置为 5 GB](../../jihulab_com/_index.md#account-and-limit-settings)。

> [!warning]
> 只从您信任的来源导入项目。如果您从不信任的来源导入项目，攻击者可能会窃取您的敏感数据。

<a id="prerequisites"></a>

#### 先决条件

- 您必须已[导出项目及其数据](#export-a-project-and-its-data)。
- 比较极狐GitLab 版本，确保您导入到的极狐GitLab 版本与导出的版本相同或更高。
- 查看[兼容性](#compatibility)是否存在任何问题。
- 对要迁移到的目标群组具有维护者或所有者角色。
- 源和目标极狐GitLab 实例上都必须安装 `tar` 命令。

<a id="import-a-project"></a>

#### 导入项目

要导入项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码仓库**。
1. 选择 **导入项目**。
1. 在 **从以下位置导入项目** 中，选择 **极狐GitLab 导出**。
1. 输入您的项目名称和 URL。然后选择您之前导出的文件。
1. 选择 **导入项目**。

您可以使用 [API](../../../api/project_import_export.md#retrieve-the-status-of-a-project-import) 查询导入状态。
该查询可能返回导入错误或异常。

<a id="changes-to-imported-items"></a>

#### 导入条目的变更

导出的条目在导入时会进行以下更改：

- 具有所有者角色的项目成员将以维护者角色导入。
- 如果导入的项目包含来自复刻的合并请求，则会在项目中创建与这些合并请求关联的新分支。因此，新项目中的分支数可能多于源项目。
- 如果 `Internal` 可见性级别[受到限制](../../public_access.md#restrict-use-of-public-or-internal-projects)，
  则所有导入的项目都会被赋予 `Private` 可见性。
- 受保护分支和受保护标签的访问级别将重置为维护者。
  例如，**允许合并** 设置为 **开发者 + 维护者** 将变为
  **维护者**。
  设置为 **无人** 的访问级别将保留。
  - 要保留原始访问级别，执行导入的用户必须对目标项目
    的顶级群组具有所有者角色，或者是极狐GitLab 管理员。
  - 当目标项目位于个人命名空间中时，访问级别始终会重置。

部署密钥不会被导入。要使用部署密钥，您必须在导入的项目中启用它们并更新受保护分支。

<a id="import-large-projects"></a>

#### 导入大型项目

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

如果您有较大的项目，请考虑[使用 Rake 任务](../../../administration/raketasks/project_import_export.md#import-large-projects)。

<a id="set-maximum-import-file-size"></a>

### 设置最大导入文件大小

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

管理员可以通过以下两种方式之一设置最大导入文件大小：

- 使用 [应用程序设置 API](../../../api/settings.md#update-application-settings) 中的 `max_import_size` 选项。
- 在 [**管理员** 区域 UI](../../../administration/settings/import_and_export_settings.md#max-import-size) 中。

默认值为 `0`（无限制）。

<a id="rate-limits"></a>

### 速率限制

为避免滥用，默认情况下，用户受到以下速率限制：

| 请求类型    | 限制                           |
|:----------------|:--------------------------------|
| 导出          | 每分钟 6 个项目           |
| 下载导出 | 每分钟每个项目 1 次下载 |
| 导入          | 每分钟 6 个项目           |

<a id="migrate-groups-by-uploading-an-export-file-deprecated"></a>

## 通过上传导出文件迁移群组（已弃用）

> [!warning]
> 此功能在极狐GitLab 14.6 中已[弃用](https://gitlab.com/groups/gitlab-org/-/work_items/4619)，并由
> [通过直接传输迁移群组](../../group/import/_index.md) 取代。但是，此功能仍推荐
> 用于[离线环境](../../application_security/offline_deployments/_index.md)中的迁移。离线实例之间的迁移支持已在
> [史诗 8985](https://gitlab.com/groups/gitlab-org/-/work_items/8985) 中提出。

先决条件：

- 对要迁移的群组具有所有者角色。

使用文件导出，您可以：

- 将任何群组导出到文件，并将该文件上传到另一个极狐GitLab 实例或同一实例上的另一个位置。
- 使用极狐GitLab UI 或 [API](../../../api/group_import_export.md)。
- 逐个迁移群组，然后逐个导出和导入这些群组的每个项目。

当使用管理员访问令牌执行导入时，极狐GitLab 会正确映射用户贡献。当您从极狐GitLab 私有化部署实例导入到 JihuLab.com 时，极狐GitLab 无法正确映射用户贡献。从极狐GitLab 私有化部署实例导入到 JihuLab.com 时，可以通过付费参与专业服务团队来保留用户贡献的正确映射。

<a id="additional-information"></a>

### 其他信息

- 导出文件存储在临时目录中，并由特定 worker 每 24 小时删除一次。
- 要保留导入项目的群组级关系，请先导出和导入群组，以便项目可以导入到所需的群组结构中。
- 导入的群组会被赋予 `private` 可见性级别，除非导入到父群组中。
- 如果导入到父群组中，子群组将继承相同的可见性级别，除非另有限制。
- 您可以将群组从[基础版导出到企业版](https://gitlab.cn/install)，
  反之亦然。企业版保留了一些基础版不包含的群组数据。如果您将群组从企业版导出到基础版，您可能会丢失这些数据。有关详细信息，请参阅[从企业版还原到基础版](../../../update/convert_to_ee/revert.md)。

最大导入文件大小取决于您是导入到极狐GitLab 私有化部署还是 JihuLab.com：

- 如果导入到极狐GitLab 私有化部署实例，您可以导入任意大小的导入文件。管理员可以使用以下任一方式更改此行为：
  - [应用程序设置 API](../../../api/settings.md#update-application-settings) 中的 `max_import_size` 选项。
  - [**管理员** 区域](../../../administration/settings/account_and_limit_settings.md)。
- 在 JihuLab.com 上，您可以使用大小不超过
  [5 GB](../../jihulab_com/_index.md#account-and-limit-settings) 的导入文件导入群组。

<a id="compatibility-1"></a>

### 兼容性

群组文件导出采用 NDJSON 格式。

您可以导入从落后最多两个[次要](../../../policy/maintenance.md#versioning)版本的极狐GitLab 导出的群组文件导出。

例如：

| 目标版本 | 兼容的源版本 |
|:--------------------|:---------------------------|
| 13.0                | 13.0, 12.10, 12.9          |
| 13.1                | 13.1, 13.0, 12.10          |

<a id="group-items-that-are-exported"></a>

### 已导出的群组条目

群组的 [`import_export.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/import_export/group/import_export.yml) 文件列出了使用文件导出迁移群组时导出和导入的条目。在您极狐GitLab 版本对应的分支中查看此文件，以检查哪些条目可以导入到目标极狐GitLab 实例。例如，
[`import_export.yml` 在 `19-2-stable-ee` 分支上](https://gitlab.com/gitlab-org/gitlab/-/blob/19-2-stable-ee/lib/gitlab/import_export/group/import_export.yml)。

导出的群组条目包括：

- 里程碑
- 群组标记（不包含关联的标记优先级）
- 看板和看板列表
- 徽章
- 子群组（包括上述所有数据）
- 史诗
  - 史诗资源状态事件。
- 事件
- [Wiki](../wiki/group.md)
- 迭代节奏。

<a id="group-items-that-are-not-exported"></a>

### 未导出的群组条目

未导出的条目包括：

- 项目
- Runner 令牌
- SAML 发现令牌
- 上传

<a id="preparation"></a>

### 准备

- 要保留导入群组上的成员列表及其各自的权限，请查看这些群组中的用户。确保
  在导入所需群组之前这些用户已存在。
- 用户必须在源极狐GitLab 实例中设置公共邮箱，该邮箱需与目标
  极狐GitLab 实例中已确认的主邮箱匹配。大多数用户会收到一封要求确认其邮箱地址的电子邮件。

<a id="export-a-group"></a>

### 导出群组

先决条件：

- 您必须对该群组具有所有者角色。

要导出群组内容：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **高级** 部分，选择 **导出群组**。
1. 导出生成后，您可以：
   - 点击您应收到的电子邮件中包含的链接。
   - 刷新群组设置页面，在 **导出项目** 区域，选择 **下载导出**。

<a id="import-the-group"></a>

### 导入群组

要导入群组：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建群组**。
1. 选择 **导入群组**。
1. 在 **从文件导入群组** 部分，输入群组名称并接受或修改关联的群组 URL。
1. 选择 **选择文件**。
1. 选择您要导入的极狐GitLab 导出文件。
1. 要开始导入，请选择 **导入**。

<a id="rate-limits-1"></a>

### 速率限制

为避免滥用，默认情况下，用户受到以下速率限制：

| 请求类型    | 限制 |
|-----------------|-------|
| 导出          | 每分钟 6 个群组 |
| 下载导出 | 每分钟每个群组 1 次下载 |
| 导入          | 每分钟 6 个群组 |
