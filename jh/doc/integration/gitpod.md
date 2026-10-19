---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Ona 为您的极狐GitLab 项目构建和配置预构建的开发环境。
title: Ona
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

借助 [Ona](https://ona.com/)（原 Gitpod），您可以将开发环境以代码形式描述，从而为任何极狐GitLab 项目获得完全配置好、已编译并已测试的开发环境。这些开发环境不仅自动化，而且是预构建的，这意味着 Ona 会像 CI/CD 服务器一样持续构建您的 Git 分支。

这意味着您无需等待依赖项下载和构建完成，即可立即开始编码。借助 Ona，您可以从浏览器中立即对任何项目、分支和合并请求开始编码。

要使用极狐GitLab Ona 集成，您必须在您的极狐GitLab 实例和您的偏好设置中启用它。以下用户：

- JihuLab.com 用户可[在其用户偏好设置中启用](#enable-ona-in-your-user-preferences)后立即使用。
- 极狐GitLab 私有化部署实例的用户可在以下操作完成后使用：
  1. [由极狐GitLab 管理员启用并配置](#configure-a-gitlab-self-managed-instance)。
  1. [在其用户设置中启用](#enable-ona-in-your-user-preferences)。

有关 Ona 的更多信息，请参阅 Ona 的[功能](https://ona.com/)和[文档](https://ona.com/docs)。

<a id="enable-ona-in-your-user-preferences"></a>

## 在用户偏好设置中启用 Ona

在为您的极狐GitLab 实例启用 Ona 集成后，要为您自己启用它：

1. 在右上角，选择您的头像。
1. 选择 **偏好设置**。
1. 在 **偏好设置** 下，找到 **集成** 部分。
1. 选中 **启用 Ona 集成** 复选框，然后选择 **保存更改**。

<a id="configure-a-gitlab-self-managed-instance"></a>

## 配置极狐GitLab 私有化部署实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

对于极狐GitLab 私有化部署，极狐GitLab 管理员必须：

1. 在极狐GitLab 中启用 Ona 集成：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择**设置** > **通用**。
   1. 展开 **Ona** 配置部分。
   1. 选中 **启用Ona集成** 复选框。
   1. 输入 Ona 实例 URL（例如 `https://app.ona.com`）。
   1. 选择 **保存更改**。
1. 在 Ona 中注册该实例。有关更多信息，请参阅 [Ona 文档](https://ona.com/docs/ona/source-control/gitlab)。

随后，极狐GitLab 用户可以[为自己启用 Ona 集成](#enable-ona-in-your-user-preferences)。

<a id="launch-ona-in-gitlab"></a>

## 在极狐GitLab 中启动 Ona

在您[启用 Ona](#enable-ona-in-your-user-preferences) 后，可以通过以下方式之一从极狐GitLab 中启动它：

- 从项目代码仓库：
  1. 在顶部栏中，选择 **搜索或转到…** 并找到您的项目。
  1. 在右上角，选择 **代码** > **Ona**。
- 从合并请求：
  1. 转到您的合并请求。
  1. 在右上角，选择 **代码** > **在Ona中打开**。

Ona 会为您的分支构建开发环境。
