---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Geo 站点管理区域
description: 配置 Geo 站点。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为极狐GitLab Geo 站点配置各种设置。更多信息，请参阅
[Geo 文档](geo/_index.md)。

先决条件：

- 管理员访问权限。

在主站点或从站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。

<a id="common-settings"></a>

## 通用设置

所有 Geo 站点都有以下设置：

| 设置 | 描述 |
| --------| ----------- |
| Primary | 将某个 Geo 站点标记为主站点。只能有一个主站点。 |
| Name    | Geo 站点的唯一标识符。强烈建议使用物理位置作为名称。例如 `London Office` 或 `us-east-1`。避免使用 `primary`、`secondary`、`Geo` 或 `DR` 等词。这样可以使故障转移过程更简单，因为物理位置不会改变，但 Geo 站点的角色可以改变。单个 Geo 站点中的所有节点使用相同的站点名称。节点使用 `/etc/gitlab/gitlab.rb`中的 `gitlab_rails['geo_node_name']` 设置，在 PostgreSQL 数据库中查找其 Geo 站点记录。如果未设置 `gitlab_rails['geo_node_name']`，则回退使用节点的 `external_url`（带末尾斜杠）。`Name`的值区分大小写，且允许使用大多数字符。 |
| URL     | 实例面向用户的 URL。 |

<a id="allowed-geo-ip"></a>

### 允许的 Geo IP

**允许的 Geo IP** 设置控制允许从站点使用哪些 IP 地址向主站点发起请求。主站点使用此设置来验证：

- 来自从站点的 Git HTTP 请求。
- 来自从站点的 Geo API 请求。

**允许的 Geo IP** 设置：

- 对从站点没有影响。该设置会复制到从站点的数据库中，但不会在那里使用。
- 接受以逗号分隔的 IP 地址和 CIDR 块列表，例如 `192.168.1.1, 10.0.0.0/8, 2001:db8::/32`。
- 默认值为 `0.0.0.0/0, ::/0`，允许来自任何 IP 地址的请求。
- 无法在从站点上修改，因为其数据库是只读的。

<a id="secondary-site-settings"></a>

## 从站点设置

从站点有许多可用的附加设置：

| 设置                   | 描述 |
|---------------------------|-------------|
| 选择性同步 | 为此从站点启用 Geo [选择性同步](geo/replication/selective_synchronization.md)。 |
| 代码仓库同步容量  | 回填代码仓库时，此从站点向主站点发起的并发请求数。 |
| 文件同步容量        | 回填文件时，此从站点向主站点发起的并发请求数。 |

<a id="geo-backfill"></a>

## Geo 回填

主站点会将代码仓库和文件的变更通知从站点，从站点始终会尽快尝试同步这些变更。

回填是指将从站点添加到数据库之前就已存在的代码仓库和文件填充到从站点。由于代码仓库和文件的数量可能极其庞大，无法一次性全部下载；因此，极狐GitLab 对这些操作的并发数设置了上限。

回填所需的时间取决于最大并发数，但较高的值会给主站点带来更大的压力。这些限制是可配置的。如果您的主站点有大量富余容量，可以提高这些值以在更短的时间内完成回填。如果主站点负载很高，且回填降低了其处理标准请求的可用性，则可以降低这些值。

<a id="set-up-the-internal-urls"></a>

## 设置内部 URL

您可以为主站点和从站点之间的同步设置不同的 URL。

主站点的内部 URL 供从站点联系它时使用，例如同步代码仓库。内部 URL 这一名称将其与[外部 URL](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-the-external-url-for-gitlab) 区分开来，后者供用户使用。内部 URL 不必是私有地址。

从站点的内部 URL 供主站点联系它时使用，例如检索同步或验证跟踪元数据，以便在管理区域的 **Geo** > **站点** > **项目代码仓库** 中显示。

内部 URL 默认为外部 URL。要更改它：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在您要自定义的站点上选择**编辑**。
1. 编辑内部 URL。
1. 选择**保存更改**。

启用后，Geo 的**管理员**区域会直接从主站点的 UI 显示每个站点的复制详情，如果启用了 Geo 从站点代理，也会通过该代理显示。

> [!warning]
> 建议在配置 Geo 站点时使用 HTTPS 连接。为避免在使用
> HTTPS 时中断主站点和从站点之间的通信，请将内部 URL 自定义为
> 指向一个在负载均衡器处终止 TLS 的负载均衡器。
