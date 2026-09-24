---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群证书添加集群（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 14.0 中已废弃。

{{< /history >}}

> [!warning]
> 此功能在 GitLab 14.0 中已废弃。要创建和管理新集群，请使用[基础设施即代码](../../infrastructure/iac/_index.md)。

<a id="disable-a-cluster"></a>

## 停用集群

当您通过集群证书成功连接现有集群后，该集群与极狐GitLab 的连接即处于启用状态。要将其停用：

1. 前往您相应的页面：
   - 对于项目级集群，访问项目的 {{< icon name="cloud-gear" >}} **运维** > **Kubernetes 集群** 页面。
   - 对于群组级集群，访问群组的 {{< icon name="cloud-gear" >}} **Kubernetes** 页面。
   - 对于实例级集群，访问 **管理员** 区域的 **Kubernetes** 页面。
1. 选择您要停用的集群名称。
1. 将 **极狐GitLab 集成** 切换为关闭状态（灰色）。
1. 选择 **保存更改**。

<a id="remove-a-cluster"></a>

## 移除集群

当您移除集集群成时，您只是移除了集群与极狐GitLab 的关联关系，而不是集群本身。要移除集群本身，请前往您的集群的 GKE 或 EKS 控制台，通过 UI 操作或使用 `kubectl`。

您至少需要拥有项目或群组的维护者[权限](../../permissions.md)才能移除与极狐GitLab 的集成。

在移除集集群成时，您有两个选项：

- **移除集成**：仅移除 Kubernetes 集成。
- **移除集成和资源**：移除集集群成以及所有与极狐GitLab 集群相关的资源，如命名空间、角色和绑定。

要移除 Kubernetes 集集群成：

1. 前往您的集群详情页面。
1. 选择 **高级设置** 选项卡。
1. 选择 **移除集成** 或 **移除集成和资源**。

<a id="remove-clusters-by-using-the-rails-console"></a>

### 通过 Rails 控制台移除集群

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[启动 Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。

要查找集群：

``` ruby
cluster = Clusters::Cluster.find(1)
cluster = Clusters::Cluster.find_by(name: 'cluster_name')
```

要删除集群但不删除关联的资源：

```ruby
# 找到拥有管理员权限的用户
user = User.find_by(username: 'admin_user')

# 通过 ID 查找集群
cluster = Clusters::Cluster.find(1)

# 删除集群
Clusters::DestroyService.new(user).execute(cluster)
```