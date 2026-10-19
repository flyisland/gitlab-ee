---
stage: Analytics
group: Knowledge Graph
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Orbit
description: 为极狐GitLab 私有化部署配置 GitLab Orbit。
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="orbit-in-gitlab-duo-default"></a>

## 极狐GitLab Duo 中默认启用 Orbit

在极狐GitLab 私有化部署上，极狐GitLab Duo 中的 Orbit 默认启用。
该实例默认值不适用于 JihuLab.com。用户显式设置的 Orbit 偏好会覆盖实例默认值。

此默认值不会绕过 Orbit 的可用性、许可或命名空间注册要求。

<a id="turn-off-orbit-in-gitlab-duo-by-default"></a>

### 默认关闭极狐GitLab Duo 中的 Orbit

先决条件：

- 您必须具有管理员访问权限。
- 您的实例必须具有包含 Orbit 功能的许可证。

要为尚未设置 Orbit 偏好的用户关闭极狐GitLab Duo 中的 Orbit：

1. 在左侧边栏的底部，选择**管理员**。
1. 选择 **Orbit**。
1. 展开 **Orbit 设置**。
1. 清除**默认在极狐GitLab Duo 中启用 Orbit**。
1. 选择**保存更改**。

<a id="index-top-level-group-namespaces-automatically"></a>

## 自动为顶层群组命名空间建立索引

先决条件：

- 您必须具有管理员访问权限。
- 您的实例必须具有包含 Orbit 功能的许可证。

要自动为现有和新建的顶层群组命名空间建立索引：

1. 在左侧边栏的底部，选择**管理员**。
1. 选择 **Orbit**。
1. 展开 **Orbit 设置**。
1. 选择**自动为根命名空间建立索引**。
1. 选择**保存更改**。

保存该设置后，极狐GitLab 会将一个后台作业加入队列。该作业会注册尚未注册或未被管理员排除的顶层群组命名空间。注册会在稍后不久进行，而不是立即进行。每小时运行的后台作业还会注册新建的顶层群组，并移除已排除群组的注册。在直接更改数据库后，该每小时作业可作为安全网。这些更改最多可能需要一小时。个人命名空间不会被注册。

当您清除**自动为根命名空间建立索引**时，现有的未排除注册会保留。在您再次选择该设置之前，后台作业不会注册新的顶层群组。

<a id="exclude-top-level-groups-from-automatic-indexing"></a>

### 从自动索引中排除顶层群组

无论是否启用自动索引，管理员都可以管理排除项：

1. 在左侧边栏的底部，选择**管理员**。
1. 选择 **Orbit**。
1. 在**已排除的群组**中，选择**排除群组**。
1. 选择一个顶层群组，然后选择**排除**。

已排除的群组不会被自动注册。如果已排除的群组已建立索引，极狐GitLab 会在几分钟内移除其注册和索引。要再次允许自动注册，请选择该群组旁边的**移除**。

> [!note]
> 此设置对 JihuLab.com 没有影响。

<a id="view-orbit-status"></a>

## 查看 Orbit 状态

要查看 Orbit 配置和索引状态，请运行：

```shell
sudo gitlab-rake gitlab:orbit:info
```
