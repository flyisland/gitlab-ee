---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少软件包仓库存储
---

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

软件包仓库会随着时间的推移积累软件包及其资产。如果不定期清理：

- 获取软件包列表所需时间会更长，影响 CI/CD 流水线性能
- 服务器会将更多存储空间分配给未使用或旧的软件包
- 用户可能难以在众多过时的软件包版本中找到所需的相关软件包

您应该实施定期清理策略，以减少软件包仓库的膨胀并释放存储空间。

<a id="review-package-registry-storage-use"></a>

## 审查软件包仓库存储使用情况

要查看存储**使用明细**：

1. 在顶栏中，选择**搜索或跳转到**并查找您的项目。
1. 在左侧边栏中，选择**设置** > **使用配额**。
1. 在**使用配额**页面上，查看软件包的**使用明细**。

<a id="delete-a-package"></a>

## 删除软件包

在软件包仓库中发布软件包后，您无法对其进行编辑。相反，您必须删除该软件包并重新发布。

Prerequisites：

- 项目的维护者或所有者角色。

要删除软件包：

1. 在顶栏中，选择**搜索或跳转到**并查找您的项目或群组。
1. 在左侧边栏中，选择**部署** > **软件包仓库**。
1. 在**软件包仓库**页面上，选择要删除的软件包。
   - 或者，在**软件包仓库**页面上，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 并选择**删除软件包**。
1. 在**删除软件包版本**确认对话框中，选择**永久删除**。

该软件包将被永久删除。

您也可以使用 [API](../../../api/packages.md#delete-a-project-package) 删除软件包。

> [!note]
> 如果在启用[请求转发](supported_functionality.md#forwarding-requests)的情况下删除软件包，可能会导致依赖混淆风险。

<a id="delete-package-assets"></a>

## 删除软件包资产

删除与软件包关联的资产以减少存储。

Prerequisites：

- 项目的维护者或所有者角色。

要删除软件包资产：

1. 在顶栏中，选择**搜索或跳转到**并查找您的项目或群组。
1. 在左侧边栏中，选择**部署** > **软件包仓库**。
1. 在**软件包仓库**页面上，选择一个软件包以查看其他详细信息。
1. 在**资产**表中，找到要删除的资产的名称。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 并选择**删除资产**。

软件包资产将被永久删除。

您也可以使用 [API](../../../api/packages.md#delete-a-package-file) 删除软件包。

<a id="cleanup-policy"></a>

## 清理策略

{{< history >}}

- 在极狐GitLab 15.2 中引入。

{{< /history >}}

当您将同名且同版本的软件包上传到软件包仓库时，将向该软件包添加更多资产。

为节省存储空间，您应仅保留最新的资产。使用清理策略来定义自动删除项目中软件包资产的规则，这样您就无需手动删除它们。

<a id="enable-the-cleanup-policy"></a>

### 启用清理策略

Prerequisites：

- 必须具备维护者或所有者角色。

软件包清理策略默认禁用。要启用它：

1. 在顶栏中，选择**搜索或跳转到**并查找您的项目。
1. 在左侧边栏中，选择**设置** > **软件包与镜像仓库**。
1. 展开**软件包仓库**。
1. 在**管理软件包资产使用的存储**下，适当设置规则。

<a id="available-rules"></a>

### 可用规则

- `保留的重复资产数量`：某些软件包格式支持同一资产的多个副本。您可以设置保留重复资产数量的上限。当达到上限时，将自动删除最旧的资产。唯一文件名（例如 Maven 快照生成的文件名）不计入重复资产。

- `保留的重复资产数量` 规则[每 12 小时运行一次](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/models/packages/cleanup/policy.rb)。

<a id="set-cleanup-limits-to-conserve-resources"></a>

### 设置清理限制以节约资源

后台进程执行软件包清理策略。此过程可能需要很长时间才能完成，并且在运行时消耗服务器资源。

使用以下设置限制清理工作线程数：

- `软件包仓库清理策略工作线程容量`：同时运行的最大清理工作线程数。此数值必须大于或等于 `0`。您应从一个较小的数值开始，并在监控后台工作线程使用的资源后增加它。要移除所有工作线程并不执行清理策略，请将此设置设为 `0`。默认值为 `2`。

