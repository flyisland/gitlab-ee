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

[Grafana](https://grafana.com/) 是一款工具，可让您通过图表和仪表板可视化时间序列指标。极狐GitLab 将性能数据写入 Prometheus，而 Grafana 允许您查询这些数据以显示图表。

<a id="integrate-with-gitlab-ui"></a>

## 与极狐GitLab UI 集成

先决条件：

- 管理员访问权限。

设置 Grafana 后，您可以启用一个链接，从极狐GitLab 侧边栏访问它：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **指标和分析**。
1. 展开**指标 - Grafana**。
1. 选中**添加指向 Grafana 的链接**复选框。
1. 配置 **Grafana URL**。输入 Grafana 实例的完整 URL。
1. 选择**保存更改**。

极狐GitLab 会在**管理**区域中的**监控** > **指标仪表板**下显示您的链接。

<a id="required-scopes"></a>

## 所需范围

通过上述过程设置 Grafana 时，在**管理**区域中的**应用程序** > **GitLab Grafana** 下，屏幕上不会显示任何范围。但是，`read_user` 范围是必需的，并且会自动提供给该应用程序。设置除 `read_user` 之外的任何范围，而未同时包含 `read_user`，会导致您尝试使用极狐GitLab 作为 OAuth 提供商登录时出现以下错误：

```plaintext
The requested scope is invalid, unknown, or malformed.
```

如果您看到此错误，请确保在 GitLab Grafana 配置屏幕中满足以下条件之一：

- 未显示任何范围。
- 已包含 `read_user` 范围。
