---
stage: Facilitated functionality
group: Facilitated functionality
info: For more information, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
title: 同类群组联邦学习（FLoC）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

同类群组联邦学习（FLoC）曾是 Google Chrome 提出的一项功能，旨在将用户划分为不同的同类群组，以进行基于兴趣的广告投放。FLoC 已被 [Topics API](https://patcg-individual-drafts.github.io/topics/) 取代，后者提供了类似的功能，可帮助广告商定位和跟踪用户。

默认情况下，极狐GitLab 通过发送以下响应头，选择不参与基于兴趣的广告用户跟踪：

```plaintext
Permissions-Policy: interest-cohort=()
```

此响应头可防止用户在任何极狐GitLab 实例中被跟踪和分类。该响应头与 Topics API 及已弃用的 FLoC 系统兼容。

先决条件：

- 管理员访问权限。

要启用基于兴趣的广告用户跟踪：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **Federated Learning of Cohorts (FLoC)**。
1. 选中**参加 FLoC** 复选框。
1. 选择**保存更改**。
