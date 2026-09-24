---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 创建、查看、编辑、删除和运行按需 DAST 扫描。
title: DAST 按需扫描
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 不要对生产服务器运行 DAST 扫描。它不仅会执行用户可执行的任何功能，例如点击按钮或提交表单，还可能触发漏洞，导致生产数据被修改或丢失。请仅对测试服务器运行 DAST 扫描。

## 按需扫描

{{< history >}}

- 在极狐GitLab 16.3 中，Runner 标签选择[已在 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/111499)。
- 基于浏览器的按需 DAST 扫描在极狐GitLab 17.0 及更高版本中可用，因为[基于代理的 DAST 已在同一版本中移除](../../../update/deprecations.md#proxy-based-dast-deprecated)。

{{< /history >}}

按需 DAST 扫描在 DevOps 生命周期之外运行。代码仓中的更改不会触发该扫描。你必须手动启动它，或将其安排为定时运行。对于按需 DAST 扫描，[站点配置文件](profiles.md#site-profile)定义了要扫描的**内容**，而[扫描器配置文件](profiles.md#scanner-profile)定义了**如何**扫描应用程序。

按需扫描可以在被动或主动模式下运行：

- **被动模式**：默认模式，运行[基于被动浏览器的扫描](browser/_index.md#passive-scans)。
- **主动模式**：运行[基于主动浏览器的扫描](browser/_index.md#active-scans)，该模式可能会对正在扫描的站点造成损害。为了最大限度地降低意外损害的风险，运行主动扫描需要[已验证的站点配置文件](profiles.md#site-profile-validation)。

<a id="view-on-demand-dast-scans"></a>

### 查看按需 DAST 扫描

要查看按需扫描：

1. 在顶部栏中，选择**搜索或跳转到**并查找你的项目或群组。
1. 在左侧边栏中，选择**安全** > **按需扫描**。

按需扫描按其状态分组。扫描库包含所有可用的按需扫描。

<a id="run-an-on-demand-dast-scan"></a>

### 运行按需 DAST 扫描

先决条件：

- 你必须拥有对受保护分支运行按需 DAST 扫描的权限。默认分支会自动受到保护。更多信息，请参见[受保护分支的流水线安全](../../../ci/pipelines/_index.md#pipeline-security-on-protected-branches)。

要运行现有的按需扫描：

1. 在顶部栏中，选择**搜索或跳转到**并查找你的项目。
1. 在左侧边栏中，选择**安全** > **按需扫描**。
1. 选择**扫描库**选项卡。
1. 在扫描所在行中，选择**运行扫描**。

   如果扫描中保存的分支不再存在，你必须：

   1. [编辑扫描](#edit-an-on-demand-scan)。
   1. 选择一个新的分支。
   1. 保存已编辑的扫描。

按需 DAST 扫描运行后，项目的仪表板会显示结果。

<a id="create-an-on-demand-scan"></a>

#### 创建按需扫描

创建按需扫描可以：

- 立即运行它。
- 保存它以便将来运行。
- 安排它在指定时间运行。

要创建按需 DAST 扫描：

1. 在顶部栏中，选择**搜索或跳转到**并查找你的项目或群组。
1. 在左侧边栏中，选择**安全** > **按需扫描**。
1. 选择**新建扫描**。
1. 填写**扫描名称**和**描述**字段。
1. 在**分支**下拉列表中，选择所需的分支。
1. 可选。选择 Runner 标签。
1. 选择**选择扫描器配置文件**或**更改扫描器配置文件**以打开抽屉，然后任选其一：
   - 从抽屉中选择一个扫描器配置文件，**或者**
   - 选择**新建配置文件**，创建一个[扫描器配置文件](profiles.md#scanner-profile)，然后选择**保存配置文件**。
1. 选择**选择站点配置文件**或**更改站点配置文件**以打开抽屉，然后任选其一：
   - 从**站点配置文件库**抽屉中选择一个站点配置文件，或者
   - 选择**新建配置文件**，创建一个[站点配置文件](profiles.md#site-profile)，然后选择**保存配置文件**。
1. 要运行按需扫描：

   - 立即运行，选择**保存并运行扫描**。
   - 将来运行，选择**保存扫描**。
   - 按计划运行：

     - 开启**启用扫描计划**开关。
     - 填写计划相关字段。
     - 选择**保存扫描**。

按需 DAST 扫描将按指定方式运行，项目的仪表板会显示结果。

<a id="view-details-of-an-on-demand-scan"></a>

### 查看按需扫描的详细信息

先决条件：

- 你必须能够向与 DAST 扫描关联的分支推送代码。

要查看按需扫描的详细信息：

1. 在顶部栏中，选择**搜索或跳转到**并查找你的项目。
1. 在左侧边栏中，选择**安全** > **按需扫描**。
1. 选择**扫描库**选项卡。
1. 在已保存扫描所在行中，选择**更多操作** ({{< icon name="ellipsis_v" >}})，然后选择**编辑**。

<a id="edit-an-on-demand-scan"></a>

### 编辑按需扫描

先决条件：

- 你必须能够向与 DAST 扫描关联的分支推送代码。

要编辑按需扫描：

1. 在顶部栏中，选择**搜索或跳转到**并查找你的项目。
1. 在左侧边栏中，选择**安全** > **按需扫描**。
1. 选择**扫描库**选项卡。
1. 在已保存扫描所在行中，选择**更多操作** ({{< icon name="ellipsis_v" >}})，然后选择**编辑**。
1. 编辑已保存扫描的详细信息。
1. 选择**保存扫描**。

<a id="delete-an-on-demand-scan"></a>

### 删除按需扫描

要删除按需扫描：

1. 在顶部栏中，选择**搜索或跳转到**并查找你的项目。
1. 在左侧边栏中，选择**安全** > **按需扫描**。
1. 选择**扫描库**选项卡。
1. 在已保存扫描所在行中，选择**更多操作** ({{< icon name="ellipsis_v" >}})，然后选择**删除**。
1. 在确认对话框中，选择**删除**。