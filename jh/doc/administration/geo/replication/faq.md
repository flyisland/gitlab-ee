---
stage: GitLab Dedicated
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

要求列在[索引页面](../_index.md#requirements-for-running-geo)中。

<a id="how-does-geo-know-which-projects-to-sync"></a>

## Geo 如何知道要同步哪些项目？

在每个从站点上，都有一个只读的极狐GitLab 数据库复制副本。从站点还有一个跟踪数据库，用于存储已同步的项目。Geo 会比较这两个数据库，找出尚未跟踪的项目。

开始时，该跟踪数据库为空，因此 Geo 会尝试从极狐GitLab 数据库中可见的每个项目进行更新。

对于每个要同步的项目：

1. Geo 会执行 `git fetch geo --mirror`，从主站点获取最新信息。
   如果没有变更，同步会很快。否则，它必须拉取最新的提交。
1. 从站点会更新跟踪数据库，按名称记录已同步的项目。
1. 重复此过程，直到所有项目都同步完成。

当有人向主站点推送提交时，会在极狐GitLab 数据库中生成一个代码仓库已变更的事件。从站点会看到此事件，将相关项目标记为脏，并安排重新同步该项目。

为确保流水线的问题（例如同步失败次数过多或作业丢失）不会永久阻止项目同步，Geo 还会定期检查跟踪数据库中标记为脏的项目。此检查会在并发同步数低于 `repos_max_capacity` 且没有等待同步的新项目时进行。

Geo 还具有校验和功能，会对所有 Git 引用到 SHA 值运行 SHA256 求和。如果主站点和从站点之间的引用不匹配，从站点会将该代码仓库标记为脏并尝试重新同步。因此，即使我们的跟踪数据库已过时，校验也应会激活，发现代码仓库状态中的差异并重新同步。

<a id="can-you-use-geo-in-a-disaster-recovery-situation"></a>

## 可以在灾难恢复场景中使用 Geo 吗？

可以，但我们复制的数据存在限制（请参阅[哪些数据会复制到从站点？](#what-data-is-replicated-to-a-secondary-site)）。

请阅读[灾难恢复](../disaster_recovery/_index.md)文档。

<a id="what-data-is-replicated-to-a-secondary-site"></a>

## 哪些数据会复制到从站点？

我们会复制整个 Rails 数据库、项目代码仓库、LFS 对象、生成的附件、头像等。这意味着用户账号、议题、合并请求、群组和项目数据等信息都可供查询。

有关 Geo 复制的数据的完整列表，请参阅[支持的 Geo 数据类型页面](datatypes.md)。

<a id="can-i-git-push-to-a-secondary-site"></a>

## 我可以 `git push` 到从站点吗？

支持直接推送到从站点（HTTP 和 SSH 均支持，包括 Git LFS）。

<a id="how-long-does-it-take-to-have-a-commit-replicated-to-a-secondary-site"></a>

## 将提交复制到从站点需要多长时间？

所有复制操作都是异步的，会排队等待调度。因此，这取决于许多因素，例如流量大小、提交的大小、站点之间的连接情况以及您的硬件。

<a id="what-if-the-ssh-server-runs-at-a-different-port"></a>

## 如果 SSH 服务器运行在不同的端口上怎么办？

这完全没问题。我们使用 HTTP(s) 将代码仓库变更从主站点拉取到所有从站点。

<a id="can-i-make-a-container-registry-for-a-secondary-site-to-mirror-the-primary"></a>

## 我可以为从站点创建容器镜像仓库来镜像主站点吗？

可以，但我们仅在灾难恢复场景中支持此功能。请参阅[从站点的容器镜像仓库](container_registry.md)。

<a id="can-you-sign-in-to-a-secondary-site"></a>

## 可以登录从站点吗？

可以，但从站点会从主站点接收所有身份验证数据（例如用户账号和登录信息）。这意味着您会被重定向到主站点进行身份验证，然后再路由回来。

<a id="do-all-geo-sites-need-to-be-the-same-as-the-primary"></a>

## 所有 Geo 站点都需要与主站点相同吗？

不需要，Geo 站点可以基于不同的参考架构。例如，您可以让主站点基于 3K 参考架构，一个从站点基于 3K 参考架构，另一个基于 1K 参考架构。

<a id="does-geo-replicate-archived-projects"></a>

## Geo 会复制已归档的项目吗？

会，前提是它们未通过[选择性同步](selective_synchronization.md)被排除。

<a id="does-geo-replicate-personal-projects"></a>

## Geo 会复制个人项目吗？

会，前提是它们未通过[选择性同步](selective_synchronization.md)被排除。

<a id="are-delayed-deletion-projects-replicated-to-secondary-sites"></a>

## 延迟删除的项目会复制到从站点吗？

会，通过[延迟删除](../../settings/visibility_and_access_controls.md#deletion-protection)安排删除但尚未永久删除的项目会复制到从站点。

<a id="what-happens-to-my-secondary-sites-when-my-primary-site-goes-down"></a>

## 当主站点宕机时，我的从站点会怎样？

当主站点宕机时，[您的从站点将无法通过 UI 访问](../secondary_proxy/_index.md#behavior-of-secondary-sites-when-the-primary-geo-site-is-down)，除非您恢复主站点上的服务，或在从站点上执行提升。
