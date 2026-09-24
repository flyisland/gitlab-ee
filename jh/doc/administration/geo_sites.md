---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Geo 站点管理区域
description: Configure Geo sites.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为极狐GitLab Geo 站点配置各种设置。有关更多信息，请参阅
[Geo 文档](geo/_index.md)。

先决条件：

- 管理员权限。

在主站点或次级站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。

<a id="common-settings"></a>

通用设置

所有 Geo 站点都具有以下设置：

| 设置 | 描述 |
| --------| ----------- |
| Primary | 将此 Geo 站点标记为**主**站点。只能有一个**主**站点。 |
| Name    | Geo 站点的唯一标识符。强烈建议使用物理位置作为名称，例如 `London Office` 或 `us-east-1`。避免使用诸如 `primary`、`secondary`、`Geo` 或 `DR` 之类的词。这有助于简化故障转移过程，因为物理位置不会改变，但 Geo 站点的角色可能会变。单个 Geo 站点中的所有节点都使用相同的站点名称。节点通过 `/etc/gitlab/gitlab.rb` 中的 `gitlab_rails['geo_node_name']` 设置在 PostgreSQL 数据库中查找其 Geo 站点记录。如果未设置 `gitlab_rails['geo_node_name']`，则会使用节点的 `external_url`（带尾部斜杠）作为回退。`Name` 的值区分大小写，并允许大多数字符。 |
| URL     | 实例面向用户的 URL。 |

<a id="allowed-geo-ip"></a>

允许的 Geo IP

**允许的 Geo IP** 设置控制允许哪些 IP 地址从次级站点向主站点发起请求。主站点使用此设置来验证：

- 来自次级站点的 Git HTTP 请求。
- 来自次级站点的 Geo API 请求。

**允许的 Geo IP** 设置：

- 对次级站点没有影响。该设置会复制到次级站点的数据库中，但在那里不会被使用。
- 接受以逗号分隔的 IP 地址和 CIDR 块列表，例如 `192.168.1.1, 10.0.0.0/8, 2001:db8::/32`。
- 默认值为 `0.0.0.0/0, ::/0`，即允许来自任何 IP 地址的请求。
- 无法在次级站点上修改，因为它们的数据库是只读的。

<a id="secondary-site-settings"></a>

次级站点设置

**次级** 站点具有许多额外可用的设置：

| 设置                   | 描述 |
|---------------------------|-------------|
| 选择性同步 | 为此**次级**站点启用 Geo [选择性同步](geo/replication/selective_synchronization.md)。 |
| 仓库同步容量  | 在回填仓库时，此**次级**站点向**主**站点发出的并发请求数。 |
| 文件同步容量        | 在回填文件时，此**次级**站点向**主**站点发出的并发请求数。 |

<a id="geo-backfill"></a>

Geo 回填

**次级**站点会收到**主**站点关于仓库和文件更改的通知，
并始终尝试尽可能快地同步这些更改。

回填是指在**次级**站点添加到数据库之前已存在的仓库和文件中，
将其填充到**次级**站点的过程。由于可能存在海量的仓库和文件，
一次下载所有内容并不现实；因此，极狐GitLab 对这些操作的并发性设置了上限。

回填所需的时间取决于最大并发数，但是更高的值会对**主**站点造成更大的压力。
这些限制是可配置的。如果您的**主**站点有大量富裕容量，
您可以增加这些值以在更短的时间内完成回填。如果它处于高负载状态，
并且回填降低了其对标准请求的可用性，则可以减小它们。

<a id="set-up-the-internal-urls"></a>

设置内部 URL

您可以为主站点和次级站点之间的同步设置不同的 URL。

**主**站点的内部 URL 由**次级**站点用于联系它（例如同步仓库）。名称“内部 URL”将其与用户使用的
[外部 URL](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-the-external-url-for-gitlab) 区分开来。内部 URL 不需要是私有地址。

**次级**站点的内部 URL 由**主**站点用于联系它（例如，获取同步或验证跟踪元数据，
以便在管理区域的 **Geo** > **站点** > **项目仓库** 中显示）。

内部 URL 默认为外部 URL。要更改它：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在您要自定义的站点上选择 **编辑**。
1. 编辑内部 URL。
1. 选择 **保存更改**。

启用后，Geo 的管理区域可以直接从主站点的 UI 以及通过 Geo 次级代理（如果已启用）显示每个站点的复制详细信息。

> [!warning]
> 我们建议在配置 Geo 站点时使用 HTTPS 连接。为避免使用 HTTPS 时
> **主**站点和**次级**站点之间的通信中断，请自定义您的内部 URL 以指向一个负载均衡器，
> 并在负载均衡器处终止 TLS。
