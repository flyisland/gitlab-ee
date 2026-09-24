---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Geo 常见问题解答
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="what-are-the-minimum-requirements-to-run-geo"></a>

## 运行 Geo 的最低要求是什么？

这些要求在[索引页面](../_index.md#requirements-for-running-geo)列出。

<a id="how-does-geo-know-which-projects-to-sync"></a>

## Geo 如何知道要同步哪些项目？

在每个**次要**站点上，都有一个极狐GitLab 数据库的只读复制副本。
**次要**站点还有一个跟踪数据库，存储了已经同步的项目。
Geo 比较这两个数据库，找出尚未跟踪的项目。

开始时，这个跟踪数据库是空的，因此 Geo 会尝试从其能在极狐GitLab 数据库中看到的所有项目中更新。

对于要同步的每个项目：

1. Geo 发起 `git fetch geo --mirror` 来从**主要**站点获取最新信息。
   如果没有变更，同步会很快。否则，就需要拉取最新的提交。
1. **次要**站点更新跟踪数据库，记录它已按名称同步了项目这一事实。
1. 重复此过程，直到所有项目都同步完成。

当有人向**主要**站点推送提交时，会在极狐GitLab 数据库中生成一个表示仓库已更改的事件。
**次要**站点看到此事件，将相应项目标记为脏（dirty），并安排重新同步该项目。

为了确保流水线问题（例如，同步失败太多次或作业丢失）不会永久停止项目同步，Geo 还会定期检查跟踪数据库中标记为脏的项目。当并发同步数低于 `repos_max_capacity` 且没有新项目等待同步时，就会执行此检查。

Geo 还有一个校验和特性，会对所有 Git 引用到 SHA 值运行 SHA256 总和计算。
如果**主要**站点和**次要**站点之间的引用不匹配，那么**次要**站点会将该项目标记为脏并尝试重新同步。
因此，即使我们有一个过时的跟踪数据库，验证机制也会被激活，发现仓库状态的差异并进行重新同步。

<a id="can-you-use-geo-in-a-disaster-recovery-situation"></a>

## 能否将 Geo 用于灾难恢复场景？

是的，但我们对复制的内容存在一些限制（请参阅
[哪些数据会复制到**次要**站点？](#what-data-is-replicated-to-a-secondary-site)）。
阅读[灾难恢复](../disaster_recovery/_index.md)文档。

<a id="what-data-is-replicated-to-a-secondary-site"></a>

## 哪些数据会复制到**次要**站点？

我们复制整个 Rails 数据库、项目仓库、LFS 对象、生成的附件、头像等。这意味着，诸如用户帐户、议题、合并请求、群组和项目数据等信息均可供查询。

要获取 Geo 复制的数据的完整列表，请参阅[支持的 Geo 数据类型页面](datatypes.md)。

<a id="can-i-git-push-to-a-secondary-site"></a>

## 我能否 `git push` 推送至**次要**站点？

支持直接推送至**次要**站点（包括 HTTP 和 SSH，以及 Git LFS）。

<a id="how-long-does-it-take-to-have-a-commit-replicated-to-a-secondary-site"></a>

## 将提交复制到**次要**站点需要多长时间？

所有复制操作都是异步的，并排队等待分发。因此，这取决于许多因素，例如流量大小、提交的大小、站点之间的连接性以及你的硬件。

<a id="what-if-the-ssh-server-runs-at-a-different-port"></a>

## 如果 SSH 服务器运行在不同的端口上怎么办？

完全没有问题。我们使用 HTTP(s) 从**主要**站点向所有**次要**站点获取仓库更改。

<a id="can-i-make-a-container-registry-for-a-secondary-site-to-mirror-the-primary"></a>

## 我能否为**次要**站点创建一个容器镜像仓库来镜像**主要**站点？

是的，但是，我们仅针对灾难恢复场景支持此功能。请参阅[**次要**站点的容器镜像仓库](container_registry.md)。

<a id="can-you-sign-in-to-a-secondary-site"></a>

## 能否登录到**次要**站点？

是的，但**次要**站点会从**主要**实例接收所有身份验证数据（如用户帐户和登录信息）。这意味着你会被重定向到**主要**站点进行身份验证，然后再路由回来。

<a id="do-all-geo-sites-need-to-be-the-same-as-the-primary"></a>

## 所有 Geo 站点是否都需要与**主要**站点相同？

不是的，Geo 站点可以基于不同的参考架构。例如，你可以让**主要**站点基于 3K 参考架构，一个**次要**站点基于 3K 参考架构，另一个基于 1K 参考架构。

<a id="does-geo-replicate-archived-projects"></a>

## Geo 是否复制已归档的项目？

是的，前提是它们没有被[选择性同步](selective_synchronization.md)排除。

<a id="does-geo-replicate-personal-projects"></a>

## Geo 是否复制个人项目？

是的，前提是它们没有被[选择性同步](selective_synchronization.md)排除。

<a id="are-delayed-deletion-projects-replicated-to-secondary-sites"></a>

## 延迟删除的项目是否会复制到**次要**站点？

是的，计划通过[延迟删除](../../settings/visibility_and_access_controls.md#deletion-protection)进行删除、但尚未永久删除的项目，会复制到**次要**站点。

<a id="what-happens-to-my-secondary-sites-with-when-my-primary-site-goes-down"></a>

## 当我的**主要**站点宕机时，我的**次要**站点会发生什么？

当**主要**站点宕机时，除非你恢复**主要**站点上的服务或对**次要**站点执行提升操作，否则[你的**次要**站点将无法通过用户界面访问](../secondary_proxy/_index.md#behavior-of-secondary-sites-when-the-primary-geo-site-is-down)。