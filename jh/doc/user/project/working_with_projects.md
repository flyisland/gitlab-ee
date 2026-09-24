---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理项目
description: Settings, configuration, project activity, and project deletion.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 中的大部分工作都在 [项目](_index.md) 中完成。文件和代码保存在项目中，大部分功能都以项目为单位。

<a id="project-overview"></a>

## 项目概览

{{< history >}}

- 在极狐GitLab 16.10 [引入] 了项目创建日期。

{{< /history >}}

当你选择一个项目时，**项目概览** 页面会显示项目内容：

- 仓库中的文件
- 项目信息（描述）
- 主题
- 徽章
- 项目中的星标、派生、提交、分支、标签、发布和环境的数量
  - 提交计数是根据项目的默认分支计算的，而不是所有分支
- 项目存储大小
- 可选文件与配置
- `README` 或索引文件
  - Wiki 页面
  - 许可证
  - 变更日志
  - 贡献指南
  - Kubernetes 集群
  - CI/CD 配置
  - 集成
  - GitLab Pages
- 创建日期

对于公开项目，以及拥有 [查看项目代码权限](../permissions.md#project-permissions) 的内部和私有项目的成员，项目概览页面会显示：

- 一个 [`README` 或索引文件](repository/files/_index.md#readme-and-index-files)。
- 项目仓库中的目录列表。

对于没有权限查看项目代码的用户，概览页面会显示：

- Wiki 主页。
- 项目中的议题列表。

你可以通过 ID 而不是项目名称来访问项目，地址为 `https://gitlab.example.com/projects/<id>`。
例如，如果你的个人命名空间 `alex` 下有一个 ID 为 `123456` 的项目 `my-project`，你可以通过 `https://gitlab.example.com/alex/my-project` 或 `https://gitlab.example.com/projects/123456` 访问该项目。

> [!note]
> 在极狐GitLab 17.5 及更高版本中，还可以使用 `https://gitlab.example.com/-/p/<id>` 访问此端点。

<a id="find-the-project-id"></a>

## 查找项目 ID

如果你想要使用 [极狐GitLab API](../../api/_index.md) 与项目交互，可能需要项目 ID。

要查找项目 ID：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **复制项目 ID**。

<a id="view-projects"></a>

## 查看项目

使用 **项目** 列表可以查看：

- 实例上的所有项目
- 你参与或拥有的项目
- 非活跃项目，包括已归档项目和待删除的项目

<a id="explore-all-projects-on-an-instance"></a>

### 浏览实例上的所有项目

查看极狐GitLab 实例上的所有项目。可以按活跃、非活跃和热门项目筛选列表：

- 活跃项目是近期有活动或正在开发的项目。
- 非活跃项目是已归档或计划删除的项目。
- 热门项目是根据过去 30 天内收到的评论数量被认为受欢迎的公开项目。

如果你未认证，列表仅显示公开项目。

要查看极狐GitLab 实例上的项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **探索**。
1. 可选。选择一个选项卡来筛选显示的项目。

<a id="view-projects-you-work-with"></a>

### 查看您参与的项目

{{< history >}}

- 在极狐GitLab 17.9 [引入]，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `your_work_projects_vue`。默认未启用。
- 在极狐GitLab 17.9 中，将选项卡标签从 **Yours** [更改为] **Member**，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `your_work_projects_vue`。默认未启用。
- 在极狐GitLab 17.10 [GA]。功能标志 `your_work_projects_vue` 被移除。

{{< /history >}}

要查看你交互过的项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **查看我的所有项目**。
1. 可选。选择一个选项卡来筛选显示的项目：
   - **贡献过**：你在其中执行过以下操作的项目：
     - 创建了议题、合并请求或史诗
     - 评论了议题、合并请求或史诗
     - 关闭了议题、合并请求或史诗
     - 推送了提交
     - 批准了合并请求
     - 合并了合并请求
   - **已星标**：你 [星标过](#star-a-project) 的项目
   - **个人**：在你的个人命名空间下创建的项目
   - **成员**：你是成员的项目
   - **非活跃**：已归档项目和待删除的项目

你也可以从个人资料中查看已星标和个人项目：

1. 在右上角，选择你的头像，然后选择你的用户名。
1. 在左侧边栏中，选择 **已星标项目** 或 **个人项目**。

<a id="view-inactive-projects"></a>

### 查看非活跃项目

{{< history >}}

- 在极狐GitLab 17.9 中，将选项卡标签从“Pending deletion” [更改为](../../administration/feature_flags/_index.md) “Inactive”，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `your_work_projects_vue`。默认未启用。
- 在极狐GitLab 17.10 [选项卡标签更改 GA](https://gitlab.com/gitlab-org/gitlab/-/issues/465889)。功能标志 `your_work_projects_vue` 被移除。
- 在 18.0 中，从专业版 [移至] 基础版。
- 在极狐GitLab 18.0 中，为个人命名空间中的项目 [启用](https://gitlab.com/gitlab-org/gitlab/-/issues/536244)。

{{< /history >}}

当项目处于待删除或已归档状态时，它就是非活跃项目。

要查看所有非活跃项目：

1. 选择：
   - **查看我的所有项目**，筛选你的项目。
   - **探索**，筛选你可以访问的所有项目。
1. 选择 **非活跃** 选项卡。

列表中的每个非活跃项目会显示一个徽章，指示该项目是已归档还是待删除。

如果项目是待删除状态，列表中还会显示：

- 项目计划被最终删除的时间。
- 一个 **恢复** 操作。恢复项目时：
  - **待删除** 标签会被移除。项目不再计划删除。
  - 项目会从 **非活跃** 选项卡中移除。

<a id="view-only-projects-you-own"></a>

### 仅查看您拥有的项目

要仅查看你拥有的项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择：
   - **查看我的所有项目**，筛选你的项目。
   - **探索**，筛选你可以访问的所有项目。
1. 在项目列表上方，选择 **搜索或过滤结果**。
1. 从 **角色** 下拉列表中，选择 **所有者**。

<a id="view-project-activity"></a>

## 查看项目活动

要查看项目活动：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **管理** > **活动**。
1. 可选。要按贡献类型筛选活动，请选择一个选项卡：

   - **所有**：项目成员的所有贡献。
   - **推送事件**：项目中的推送事件。
   - **合并事件**：已接受的合并请求。
   - **议题事件**：项目中打开和关闭的议题。
   - **评论**：项目成员发表的评论。
   - **设计**：项目中新增、更新和删除的设计。
   - **团队**：加入和离开项目的成员。

出于性能原因，极狐GitLab 会从事件表中移除超过三年的项目活动事件。

<a id="filter-projects-by-language"></a>

## 按语言筛选项目

{{< history >}}

- 在极狐GitLab 15.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/385465)，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `project_language_search`。默认启用。
- 在极狐GitLab 15.9 [GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110956)。功能标志 `project_language_search` 被移除。

{{< /history >}}

你可以按项目使用的编程语言进行筛选。操作步骤如下：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择：
   - **查看我的所有项目**，筛选你的项目。
   - **探索**，筛选你可以访问的所有项目。
1. 在项目列表上方，选择 **搜索或过滤结果**。
1. 从 **语言** 下拉列表中，选择你想用来筛选项目的语言。

将显示使用所选语言的项目列表。

<a id="star-a-project"></a>

## 星标项目

你可以星标你经常使用的项目，以便更容易找到它们。

要星标项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在页面右上角，选择 **星标**。

<a id="leave-a-project"></a>

## 退出项目

{{< history >}}

- 退出项目的按钮在极狐GitLab 16.7 中 [移动](https://gitlab.com/gitlab-org/gitlab/-/issues/431539) 到了操作菜单。

{{< /history >}}

当你退出项目时：

- 你不再是项目成员，无法再进行贡献。
- 所有分配给你的议题和合并请求都将被取消分配。

先决条件：

- 只有当项目属于某个 [群组命名空间](../namespace/_index.md) 下的群组时，你才能通过这种方式退出项目。
- 你必须是项目的 [直接成员](members/_index.md#membership-types)。

要退出项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **退出项目**，然后再次选择 **退出项目**。

要从 **你的工作** 列表视图直接退出项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **查看我的所有项目**。
1. 在 **成员** 选项卡中，找到你想要退出的项目，然后选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **退出项目**。

此操作也可在其他列表页面上使用。

<a id="edit-a-project"></a>

## 编辑项目

使用项目通用设置编辑项目详细信息。

先决条件：

- 你必须对项目具有维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **项目名称** 文本框中，输入你的项目名称。请参阅 [项目名称限制](../reserved_names.md)。
1. 可选。在 **项目描述** 文本框中，输入你的项目描述。描述限制为 2,000 个字符。
   发布在 CI/CD 目录中的组件需要项目描述。
1. 选择 **保存更改**。

<a id="rename-a-repository"></a>

### 重命名仓库

项目的仓库名称定义了其 URL。

先决条件：

- 你必须是管理员，或者对项目具有维护者或所有者角色。

> [!note]
> 当你更改仓库路径时，如果用户从旧 URL 推送或拉取，可能会遇到问题。
> 有关重定向持续时间及其副作用的更多信息，请参阅
> [重命名仓库时的重定向](repository/_index.md#repository-path-changes)。

要重命名仓库：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 在 **更改路径** 文本框中，编辑路径。
1. 选择 **更改路径**。

<a id="add-a-project-avatar"></a>

### 添加项目头像

添加项目头像有助于直观地识别你的项目。如果你未添加头像，极狐GitLab 会显示你项目名称的第一个字母作为默认项目头像。

要添加项目头像，请使用以下方法之一：

- 将 logo 文件添加到仓库中。
- 在项目设置中上传头像。

<a id="add-a-logo-to-your-repository"></a>

#### 将 logo 文件添加到仓库中

如果你尚未在项目设置中上传头像，极狐GitLab 会在你的仓库中查找名为 `logo` 的文件，用作默认项目头像。

先决条件：

- 你必须对项目具有维护者或所有者角色。
- 你的文件大小不得超过 200 KB。理想的图片尺寸为 192 x 192 像素。
- 文件必须命名为 `logo`，扩展名为 `.png`、`.jpg` 或 `.gif`。例如，`logo.gif`。

要添加 logo 文件用作项目头像：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在你的项目仓库根目录中，上传 logo 文件。

<a id="upload-an-avatar-in-project-settings"></a>

#### 在项目设置中上传头像

先决条件：

- 你必须对项目具有维护者或所有者角色。
- 你的文件大小不得超过 200 KB。理想的图片尺寸为 192 x 192 像素。
- 图片必须是以下文件类型之一：
  - `.bmp`
  - `.gif`
  - `.ico`
  - `.jpeg`
  - `.png`
  - `.tiff`

要在项目设置中上传头像：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **项目头像** 部分，选择 **选择文件**。
1. 选择你的头像文件。
1. 选择 **保存更改**。

<a id="delete-a-project"></a>

## 删除项目

{{< history >}}

- 在 16.0 中，[JihuLab.com](https://gitlab.com/gitlab-org/gitlab/-/issues/393622) 和 [私有化部署](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/119606) 上专业版和旗舰版的默认行为 [更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/389557) 延迟项目删除。
- 在 18.0 中，[基础版](https://gitlab.com/groups/gitlab-org/-/epics/17208) 和 [个人项目](https://gitlab.com/gitlab-org/gitlab/-/issues/536244) 的默认行为也改为延迟项目删除。

{{< /history >}}

默认情况下，当你首次删除项目时，它会进入待删除状态。
再次删除项目可以立即将其移除。

先决条件：

- 你必须具有项目的所有者角色。
- 必须 [允许所有者删除项目](../../administration/settings/visibility_and_access_controls.md#restrict-project-deletion-to-administrators)。

要删除项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **删除**。
1. 在确认对话中，输入项目名称，然后选择 **是，删除项目**。

此操作会添加一个后台任务，将项目标记为待删除。在 JihuLab.com 上，项目在 30 天后删除。在私有化部署的极狐GitLab 上，你可以通过 [实例设置](../../administration/settings/visibility_and_access_controls.md#deletion-protection) 修改保留期限。

如果安排删除项目的用户在删除发生之前失去了对项目的访问权限（例如，退出了项目、角色被降级或被禁止访问项目），则删除任务会改为恢复项目，项目不再计划删除。

当项目被标记为待删除时，计划的 CI/CD 流水线将停止运行。

> [!warning]
> 如果安排删除项目的用户在任务执行前重新获得了所有者角色或管理员访问权限，那么该任务会永久删除项目。

你还可以 [使用 Rails 控制台删除项目](troubleshooting.md#delete-a-project-using-console)。

<a id="delete-a-project-immediately"></a>

## 立即删除项目

{{< history >}}

- 在极狐GitLab 16.0 [GA]。仅限专业版和旗舰版。
- 在极狐GitLab 18.0 中，从专业版移至基础版。

{{< /history >}}

如果你不想等待配置的保留期限来删除项目，可以立即删除项目。

先决条件：

- 你必须具有项目的所有者角色。
- 你已经 [将项目安排为待删除](#delete-a-project)。

要永久删除安排删除的项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **永久删除**。
1. 在确认对话中，输入项目名称，然后选择 **是，删除项目**。

此操作将删除项目及其所有相关资源，包括议题和合并请求。

<a id="restore-a-project"></a>

### 恢复项目

{{< history >}}

- 在 18.0 中，从专业版移至基础版。
- 在极狐GitLab 18.0 中，对个人命名空间中的项目 [启用](https://gitlab.com/gitlab-org/gitlab/-/issues/536244)。

{{< /history >}}

先决条件：

- 你必须具有项目的所有者角色。

要恢复待删除的项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **恢复**。

<a id="archive-a-project"></a>

## 归档项目

{{< history >}}

- 在极狐GitLab 17.5 中 [引入] 了 Pages 移除。

{{< /history >}}

归档项目可以使其变为只读，并保留其数据以供将来参考。

归档项目后：

- 项目变为非活跃状态，并显示 `Archived` 徽章
- 大多数功能变为只读，包括仓库、议题、合并请求和软件包
- 派生关系被移除，来自派生的开放合并请求被关闭
- 已部署的 Pages 以及自定义域被移除
- 计划的 CI/CD 流水线停止运行
- 拉取镜像停止

先决条件：

- 你必须是管理员，或者对项目具有所有者角色。

要归档项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **归档**。

要从 **你的工作** 列表视图直接归档项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 在下拉菜单中，选择 **查看我的所有项目**。
1. 在 **成员** 选项卡中，找到你想要归档的项目，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **归档**。

此操作也可在其他列表页面上使用。

<a id="unarchive-a-project"></a>

### 取消归档项目

取消归档项目后：

- 只读限制会被移除
- 项目不再标记为非活跃
- 计划的 CI/CD 流水线会自动恢复
- 拉取镜像会自动恢复

作为群组归档一部分被归档的项目无法单独取消归档。
你必须 [取消归档父群组](../group/manage.md#unarchive-a-group) 来取消归档其所有的项目和子群组。

> [!note]
> 已部署的 Pages 不会自动恢复。你必须重新运行流水线来恢复 Pages。

先决条件：

- 你必须是管理员，或者对项目具有所有者角色。

要取消归档项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在项目概览页面的右上角，选择 **操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **取消归档**。

要从 **你的工作** 列表视图直接取消归档项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 在下拉菜单中，选择 **查看我的所有项目**。
1. 在 **非活跃** 选项卡中，找到你想要取消归档的项目，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **取消归档**。

此操作也可在其他列表页面上使用。

<a id="transfer-a-project"></a>

## 转移项目

{{< history >}}

- 在极狐GitLab 17.7 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/499163)，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `transfer_project_with_tags`。默认未启用。
- 在极狐GitLab 17.7 中，[在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/499163)。功能标志已移除。
- 在极狐GitLab 18.11 中，[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594575) 了项目的异步转移，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `groups_and_projects_async_transfer`。默认未启用。

{{< /history >}}

转移项目可以将其移动到不同的群组。项目转移可以将单个项目移动到同一极狐GitLab 实例中的任何命名空间。

你可以将项目从以下位置转移：

- 个人命名空间到群组
- 群组到另一个群组
- 群组到个人命名空间

先决条件：

- 对目标群组具有维护者或所有者角色。
- 对要转移的项目具有所有者角色。
- 为目标群组启用项目创建。

> [!note]
> 如果项目已归档或待删除，则无法转移。

要转移项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 在 **转移项目** 下，选择要将项目转移到的命名空间。
1. 选择 **转移项目**。
1. 输入项目名称，然后选择 **确认**。

确认转移后：

- 项目异步转移。
- 转移完成或失败后会发送确认邮件。
- 旧项目 URL 将重定向到新项目 URL。刷新页面以查看新的项目 URL。对于大型项目，必须等待转移完成后才能在目标命名空间下查看项目。

转移项目后，请确保：

- 更新本地仓库 remote 地址为新 URL。
- 验证项目成员访问权限和权限设置。
- 更新软件包配置，必要时重新发布。
- 测试 CI/CD 流水线和集成。
- 如有必要，审查并重新分配安全策略。

管理员可以从 [管理区域](../../administration/admin_area.md#administering-projects) 转移项目。

<a id="what-data-gets-transferred"></a>

### 转移了哪些数据

项目转移包括：

- 项目组件：
  - 议题、合并请求和议题讨论
  - CI/CD 流水线和配置
  - 仪表板和 Wiki
  - 仓库代码和 Git 历史
  - 项目访问令牌
- 项目成员：
  - 直接项目成员及其角色
  - 待处理的成员邀请
- 自动调整：
  - 如果目标群组中不存在匹配的群组标签，则创建新的项目标签
  - 如有必要，在目标群组中创建史诗副本，每个项目有单独的副本
    - 当你转移多个项目，且这些项目的议题都分配给了同一个史诗时，会在目标群组中为每个项目创建该史诗的单独副本。

> [!warning]
> 转移过程中的错误可能会导致项目组件或最终用户依赖项的数据丢失。

<a id="known-issues"></a>

### 已知问题

转移项目时，请注意以下限制。

对于具有继承成员资格的项目：

- 通过 [继承成员资格](members/_index.md#membership-types) 加入项目的成员将失去访问权限，除非他们也是目标群组的成员。
- 项目将从目标群组继承新的成员权限。

对于启用了容器镜像仓库的项目：

- 在 JihuLab.com 上：你只能在同一顶级群组内转移项目。
- 在私有化部署的极狐GitLab 上：项目不得包含 [容器镜像](../packages/container_registry/_index.md#move-or-rename-container-registry-repositories)。
- 拥有超过 1,000 个容器仓库的项目无法转移。更多信息，请参阅 [移动或重命名容器镜像仓库](../packages/container_registry/_index.md#move-or-rename-container-registry-repositories)。

对于使用软件包仓库的项目：

- 如果根命名空间更改，你必须从项目中移除遵循 [命名约定](../packages/npm_registry/_index.md#naming-convention) 的 npm 软件包。转移项目后，你可以：
  - 使用新的根命名空间路径更新软件包范围，并重新发布到项目中。
  - 将软件包重新发布到项目而不更新根命名空间路径，这将导致软件包不再遵循命名约定。如果不更新根命名空间路径重新发布，该软件包将无法用于 [实例端点](../packages/npm_registry/_index.md#install-from-an-instance)。

对于具有安全策略的项目：

- 项目不得具有安全策略。如果项目被分配了安全策略，则在转移过程中会自动取消分配。

对于存在名称或路径冲突的项目：

- 如果目标命名空间中已存在具有相同名称或路径的项目或子群组，则无法转移项目。这包括 [待删除](#delete-a-project) 的项目。要解决冲突，请在转移项目之前重命名或移除目标命名空间中的冲突项。

转移项目时：

- 项目 [路径会更改](repository/_index.md#repository-path-changes)。请确保在必要时更改项目组件的 URL。

<a id="transfer-a-jihulab-com-project-to-a-different-subscription-tier"></a>

### 将 JihuLab.com 项目转移到不同的订阅层级
当您将项目从授权为 JihuLab.com 专业版或旗舰版的命名空间转移到极狐GitLab 基础版时：

- [项目访问令牌](settings/project_access_tokens.md) 被撤销。
- [流水线订阅](../../ci/pipelines/_index.md#trigger-a-pipeline-when-an-upstream-project-is-rebuilt) 和 [测试用例](../../ci/test_cases/_index.md) 被删除。

<a id="manage-projects-with-the-actions-menu"></a>

## 使用操作菜单管理项目

您可以查看所有项目的列表，并使用 **操作** 菜单管理它们。

先决条件：

- 您必须具有所需的 [项目权限](../permissions.md#projects) 才能执行操作。

要使用 **操作** 菜单管理项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 从下拉列表中，选择 **查看我的所有项目**。
1. 在 **项目** 页面上，找到您的项目并选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择一个操作。

根据项目状态，以下操作可用：

| 项目状态 | 可用操作 |
|----------|-------------------------|
| 活跃   | **复制项目 ID**、**编辑**、**归档**、**转移**、**离开项目**、**删除** |
| 已归档 | **复制项目 ID**、**取消归档**、**离开项目**、**删除** |
| 待删除 | **复制项目 ID**、**恢复**、**离开项目**、**永久删除** |

<a id="add-a-compliance-framework-to-a-project"></a>

## 向项目添加合规框架

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将合规框架添加到具有 [合规框架](../compliance/compliance_frameworks/_index.md) 的群组中的项目。

<a id="manage-project-access-through-ldap-groups"></a>

## 通过 LDAP 群组管理项目访问

您可以 [使用 LDAP 管理群组成员资格](../group/access_and_permissions.md#manage-group-memberships-with-ldap)。

您不能使用 LDAP 群组来管理项目访问，但可以使用以下变通方法。

先决条件：

- 您必须 [将 LDAP 与极狐GitLab 集成](../../administration/auth/ldap/_index.md)。
- 您必须是管理员。

1. [创建一个群组](../group/_index.md#create-a-group) 来跟踪项目的成员资格。
1. 为该群组 [设置 LDAP 同步](../../administration/auth/ldap/ldap_synchronization.md)。
1. 要使用 LDAP 群组管理对项目的访问，请 [将 LDAP 同步的群组作为成员添加](../group/manage.md) 到项目中。

<a id="project-aliases"></a>

## 项目别名

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 仓库通常通过命名空间和项目名称访问。但是，当将频繁访问的仓库迁移到极狐GitLab 时，您可以使用项目别名以原始名称访问这些仓库。通过项目别名访问仓库可降低迁移此类仓库的风险。

此功能仅适用于通过 SSH 的 Git。此外，只有极狐GitLab 管理员才能创建项目别名，并且只能通过 API 进行。有关更多信息，请参阅 [项目别名 API 文档](../../api/project_aliases.md)。

管理员为项目创建别名后，您可以使用别名克隆仓库。例如，如果管理员为项目 `https://jihulab.com/gitlab-cn/gitlab` 创建了别名 `gitlab`，则可以使用 `git clone git@jihulab.com:gitlab.git` 而不是 `git clone git@jihulab.com:gitlab-cn/gitlab.git` 克隆项目。