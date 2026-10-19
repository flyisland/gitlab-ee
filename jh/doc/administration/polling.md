---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 轮询间隔乘数
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab UI 会按适合各资源的计划轮询不同资源的更新（例如议题评论、议题标题和流水线状态）。

调整这些计划的乘数，即可调整极狐GitLab UI 轮询更新的频率。如果将乘数设置为：

- 大于 `1`的值，UI 轮询会变慢。如果您遇到大量客户端轮询更新导致数据库负载的问题，增大乘数是不错的选择，可以替代完全禁用轮询。例如，如果将该值设置为 `2`，所有轮询间隔都会乘以 2，这意味着轮询频率减半。
- `0` 到 `1` 之间的值，UI 轮询会更频繁，因此更新也更频繁。不推荐。
- `0`，所有轮询都会被禁用。在下一次轮询时，客户端会停止轮询更新。

对于大多数极狐GitLab 安装实例，建议使用默认值（`1`）。

<a id="configure"></a>

## 配置

先决条件：

- 管理员访问权限。

要调整轮询间隔乘数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开**轮询间隔乘数**。
1. 为轮询间隔乘数设置一个值。该乘数会同时应用于所有资源。
1. 选择**保存更改**。
