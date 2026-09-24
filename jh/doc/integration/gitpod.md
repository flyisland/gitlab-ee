---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Ona to build and configure prebuilt development environments for your 极狐GitLab project.
title: Ona
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [Ona](https://ona.com/)（原 Gitpod），你可以将开发环境以代码形式描述，为任何 极狐GitLab 项目获得完全设置、编译并测试的开发环境。这些开发环境不仅自动化，而且是预构建的，这意味着 Ona 像 CI/CD 服务器一样持续构建你的 Git 分支。

这意味着你无需等待依赖项下载和构建完成即可立即开始编码。使用 Ona，你可以在浏览器中立即开始对任何项目、分支和合并请求进行编码。

要使用 极狐GitLab Ona 集成，你必须为你的 极狐GitLab 实例以及在你的偏好设置中启用它。对于以下用户：
- JihuLab.com 用户可以在其用户偏好设置中[启用 Ona](#enable-ona-in-your-user-preferences) 后立即使用。
- 私有化部署实例的用户可以在以下操作后使用：
  1. 由 极狐GitLab 管理员[启用并配置](#configure-a-gitlab-self-managed-instance)。
  2. 在用户设置中[启用 Ona](#enable-ona-in-your-user-preferences)。

有关 Ona 的更多信息，请参阅 Ona [功能](https://ona.com/) 和 [文档](https://ona.com/docs)。

<a id="enable-ona-in-your-user-preferences"></a>

## 在用户偏好中启用 Ona

在为你的 极狐GitLab 实例启用 Ona 集成后，要为自身启用它：

1. 在右上角，选择你的头像。
1. 选择 **偏好设置**。
1. 在 **偏好设置** 下，找到 **集成** 部分。
1. 勾选 **启用 Ona 集成** 复选框并选择 **保存更改**。

<a id="configure-a-gitlab-self-managed-instance"></a>

## 配置私有化部署实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

对于私有化部署，极狐GitLab 管理员必须：

1. 在 极狐GitLab 中启用 Ona 集成：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏，选择 **设置** > **通用**。
   1. 展开 **Ona** 配置部分。
   1. 勾选 **启用 Ona 集成** 复选框。
   1. 输入 Ona 实例 URL（例如，`https://app.ona.com`）。
   1. 选择 **保存更改**。
1. 在 Ona 中注册该实例。更多信息，请参阅 [Ona 文档](https://ona.com/docs/ona/source-control/gitlab)。

极狐GitLab 用户之后可以[为自己启用 Ona 集成](#enable-ona-in-your-user-preferences)。

<a id="launch-ona-in-gitlab"></a>

## 在 极狐GitLab 中启动 Ona

在你[启用 Ona](#enable-ona-in-your-user-preferences) 之后，你可以通过以下方式之一从 极狐GitLab 启动它：

- 从项目仓库：
  1. 在顶栏，选择 **搜索或跳转到** 并找到你的项目。
  1. 在右上角，选择 **代码** > **Ona**。
- 从合并请求：
  1. 前往你的合并请求。
  1. 在右上角，选择 **代码** > **在 Ona 中打开**。

Ona 会为你的分支构建开发环境。