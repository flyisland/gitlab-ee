---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sourcegraph
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 在 JihuLab.com 上，此功能仅适用于公开项目。

[Sourcegraph](https://sourcegraph.com) 在极狐GitLab UI 中提供代码智能功能。
启用后，参与的项目会在以下代码视图中显示代码智能弹出框：

- 合并请求差异
- 提交视图
- 文件视图

访问这些视图时，将鼠标悬停在代码引用上，会看到一个弹出框，其中包含：

- 关于此引用如何定义的详细信息。
- **转到定义**，跳转到定义此引用的代码行。
- **查找引用**，跳转到已配置的 Sourcegraph 实例，显示指向高亮代码的引用列表。

更多信息，请参见史诗 2201。

## 设置私有化部署实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须拥有一个已[配置并运行](https://sourcegraph.com/docs/admin)的 Sourcegraph 实例，并将您的极狐GitLab 实例作为外部服务。
- 如果您的 Sourcegraph 实例使用 HTTPS 连接极狐GitLab，您必须为 Sourcegraph 实例[配置 HTTPS](https://sourcegraph.com/docs/admin/http_https_configuration)。

在 Sourcegraph 中：

1. 进入 **站点管理员** 区域。
1. 可选。[配置您的极狐GitLab 外部服务](https://sourcegraph.com/docs/admin/code_hosts/gitlab)。如果您的极狐GitLab 仓库已在 Sourcegraph 中可搜索，您可以跳过此步骤。
1. 通过运行测试查询，确认您可以在 Sourcegraph 实例中搜索来自极狐GitLab 的仓库。
1. 将您的极狐GitLab 实例 URL 添加到 Sourcegraph 配置中的 [`corsOrigin` 设置](https://sourcegraph.com/docs/admin/config/site_config#corsOrigin)。

接下来，配置您的极狐GitLab 实例以连接到 Sourcegraph 实例。

### 使用 Sourcegraph 配置您的极狐GitLab 实例

先决条件：

- 您必须是管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **Sourcegraph**。
1. 选择 **启用 Sourcegraph**。
1. 可选。选择 **阻止私有和内部项目**。
1. 将 **Sourcegraph URL** 设置为您的 Sourcegraph 实例，例如 `https://sourcegraph.example.com`。
1. 选择 **保存更改**。

## 在用户偏好中启用 Sourcegraph

私有化部署实例上的用户还必须配置其用户设置以使用 Sourcegraph 集成。

在 JihuLab.com 上，该集成适用于所有公开项目。不支持私有项目。

先决条件：

- 对于私有化部署实例，必须启用 Sourcegraph。

要在极狐GitLab 用户偏好中启用此功能：

1. 在右上角，选择您的头像。
1. 选择 **偏好设置**。
1. 滚动到 **集成** 部分。在 **Sourcegraph** 下，选择 **在代码视图上启用集成代码智能**。
1. 选择 **保存更改**。

## 参考资料

- Sourcegraph 文档中的[隐私信息](https://sourcegraph.com/docs/integration/browser_extension/references/privacy)

## 故障排查

### Sourcegraph 不工作

如果您为项目启用了 Sourcegraph 但它不工作，可能是 Sourcegraph 尚未索引该项目。您可以通过访问 `https://sourcegraph.com/gitlab.com/<项目路径>` 来检查 Sourcegraph 是否可用于您的项目，将 `<项目路径>` 替换为您的极狐GitLab 项目路径。

