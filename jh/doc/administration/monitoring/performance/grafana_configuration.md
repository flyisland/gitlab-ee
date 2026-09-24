---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 Grafana
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 随 极狐GitLab 捆绑的 Grafana 在 极狐GitLab 16.0 已弃用。
- 随 极狐GitLab 捆绑的 Grafana 在 极狐GitLab 16.3 已移除。

{{< /history >}}

[Grafana](https://grafana.com/) 是一个工具，使你能够通过图形和仪表板可视化时间序列指标。极狐GitLab 将性能数据写入 Prometheus，Grafana 允许你查询数据以显示图形。

<a id="integrate-with-gitlab-ui"></a>

## 与极狐GitLab UI 集成

先决条件：

- 管理员权限。

设置 Grafana 后，你可以启用在极狐GitLab 侧边栏中访问它的链接：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **指标与分析**。
1. 展开 **指标 - Grafana**。
1. 勾选 **添加指向 Grafana 的链接** 复选框。
1. 配置 **Grafana URL**。输入 Grafana 实例的完整 URL。
1. 选择 **保存更改**。

极狐GitLab 在 **管理员** 区域中的 **监控** > **指标仪表板** 下显示你的链接。

<a id="required-scopes"></a>

## 必需的作用域

通过上述流程设置 Grafana 时，在 **管理员** 区域的 **应用** > **极狐GitLab Grafana** 下，屏幕上不会显示任何作用域。但是，需要 `read_user` 作用域，并且会自动提供给应用程序。设置除 `read_user` 之外的任何作用域但不同时包含 `read_user`，会导致在使用极狐GitLab 作为 OAuth 提供者登录时出现此错误：

```plaintext
请求的作用域无效、未知或格式错误。
```

如果看到此错误，请确保在 极狐GitLab Grafana 配置界面中满足以下条件之一：

- 没有显示任何作用域。
- 包含 `read_user` 作用域。