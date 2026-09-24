---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 轮询间隔乘数
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab UI 会根据资源情况按计划轮询不同资源（例如议题备注、议题标题和流水线状态）的更新。

调整这些计划的乘数可以调整极狐GitLab UI 轮询更新的频率。如果将乘数设置为：

- 大于 `1` 的值，UI 轮询速度会变慢。如果发现大量客户端轮询更新导致数据库负载问题，增加乘数可以作为完全禁用轮询的一个不错替代方案。例如，将该值设置为 `2`，所有轮询间隔都会乘以 2，这意味着轮询频率减半。
- 介于 `0` 和 `1` 之间的值，UI 轮询会更频繁地获取更新。**不推荐**。
- `0`，所有轮询都将禁用。在下一次轮询时，客户端将停止轮询更新。

默认值（`1`）推荐用于大多数极狐GitLab 安装。

<a id="configure"></a>

## 配置

前提条件：

- 管理员访问权限。

调整轮询间隔乘数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **轮询间隔乘数**。
1. 为轮询间隔乘数设置一个值。此乘数将同时应用于所有资源。
1. 选择 **保存更改**。