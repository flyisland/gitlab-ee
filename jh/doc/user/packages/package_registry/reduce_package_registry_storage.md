---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少软件包仓库存储占用
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

软件包仓库会随着时间推移不断累积软件包及其资产。如果不定期清理：

- 获取软件包列表需要更长时间，从而影响 CI/CD 流水线性能
- 服务器会为未使用或旧的软件包分配更多存储空间
- 用户可能难以在众多过时的软件包版本中找到相关的软件包

您应该实施定期清理策略，以减少软件包仓库的膨胀并释放存储空间。

<a id="review-package-registry-storage-use"></a>

## 查看软件包仓库存储使用情况

要查看存储的**使用量明细**：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **使用配额**。
1. 在**使用配额**页面中，查看软件包的**使用量明细**。

<a id="delete-a-package"></a>

## 删除软件包

软件包在软件包仓库中发布后，您无法再编辑它。您必须删除该软件包并重新发布。

先决条件：

- 项目的维护者或所有者角色。

要删除软件包：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择**部署** > **软件包仓库**。
1. 在**软件包仓库**页面中，选择您要删除的软件包。
   - 或者，在**软件包仓库**页面中，选择垂直省略号 ({{< icon name="ellipsis_v" >}})
     并选择**删除软件包**。
1. 在**删除软件包版本**确认对话框中，选择**永久删除**。

该软件包将被永久删除。

要删除软件包，您也可以使用 [API](../../../api/packages.md#delete-a-project-package)。

> [!note]
> 如果在开启[请求转发](supported_functionality.md#forwarding-requests)的情况下删除软件包，
> 可能会引入依赖混淆风险。

<a id="delete-package-assets"></a>

## 删除软件包资产

删除与软件包关联的资产以减少存储占用。

先决条件：

- 项目的维护者或所有者角色。

要删除软件包资产：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择**部署** > **软件包仓库**。
1. 在**软件包仓库**页面中，选择一个软件包以查看详细信息。
1. 在**资产**表格中，找到您要删除的资产的名称。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 并选择**删除资产**。

软件包资产将被永久删除。

要删除软件包，您也可以使用 [API](../../../api/packages.md#delete-a-package-file)。

<a id="cleanup-policy"></a>

## 清理策略

当您将同名同版本的软件包上传到软件包仓库时，该软件包会添加更多资产。

为节省存储空间，您应该只保留最新的资产。使用清理策略定义规则，自动删除项目中的软件包资产，这样您就无需手动删除它们。

<a id="enable-the-cleanup-policy"></a>

### 启用清理策略

先决条件：

- 您必须具有维护者或所有者角色。

默认情况下，软件包清理策略处于禁用状态。要启用它：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **软件包与镜像库**。
1. 展开**软件包仓库**。
1. 在**管理软件包资产使用的存储空间**下，适当设置规则。

<a id="available-rules"></a>

### 可用规则

- `Number of duplicated assets to keep`：某些软件包格式支持同一资产的多个副本。
  您可以设置要保留的重复资产数量上限。
  达到上限后，最旧的资产会被自动删除。
  唯一文件名（例如 Maven 快照生成的文件名）不计为重复资产。

- `Number of duplicated assets to keep` [每 12 小时](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/models/packages/cleanup/policy.rb)运行一次。

<a id="set-cleanup-limits-to-conserve-resources"></a>

### 设置清理限制以节省资源

后台进程会执行软件包清理策略。该进程可能需要很长时间才能完成，并且在运行期间会消耗服务器资源。

使用以下设置限制清理工作进程的数量：

- `package_registry_cleanup_policies_worker_capacity`：并发运行的清理工作进程的最大数量。
  该数值必须大于或等于 `0`。
  您应该先从一个较小的数值开始，在监控后台工作进程使用的资源后再逐步增加。
  要移除所有工作进程且不执行清理策略，请将该设置设为 `0`。默认值为 `2`。
