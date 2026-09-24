---
stage: Fulfillment
group: Utilization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 存储
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

极狐GitLab 项目对其 Git 仓库和大文件存储（LFS）设有存储限制。
仅项目的仓库和 LFS 计入存储限制。
容器镜像仓库、软件包仓库和构建产物不计入该限制。

当项目的仓库和 LFS 超过限制时，项目将被设置为[只读状态](read_only_namespaces.md)并限制某些操作。

<a id="free-limit"></a>

## 基础版限制

{{< details >}}

- Tier: 基础版

{{< /details >}}

JihuLab.com 上基础版命名空间中的每个项目拥有 10 GiB 的免费存储。

要将项目的仓库和 LFS 存储增加到超过 10 GiB，你必须购买更多存储。

<a id="fixed-project-limit"></a>

## 固定项目限制

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

JihuLab.com 上专业版或旗舰版中的每个项目拥有 500 GiB 的存储。

当项目超过存储限制时，群组和顶级命名空间的所有者会通过界面和电子邮件收到通知。

要管理存储用量，请联系你的客户团队或极狐GitLab 支持。

<a id="expired-storage"></a>

## 过期存储

过期存储是指当订阅期结束时已购存储未被取消配置。
如果你发现已购存储出现意外下降，过期存储可能已从你的账户中移除。
如需更多信息和解决方案，请联系支持。

<a id="view-storage"></a>

## 查看存储

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以在项目和命名空间中查看以下存储用量统计信息：

- 超过 JihuLab.com 存储限制或[极狐GitLab 私有化部署存储限制](../administration/settings/account_and_limit_settings.md#repository-size-limit)的存储用量。
- JihuLab.com 上可用的已购存储。

先决条件：

- 要查看项目的存储用量，你必须具备项目的维护者或所有者角色，或命名空间的所有者角色。
- 要查看群组命名空间的存储用量，你必须具备命名空间的所有者角色。

查看存储：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **设置** > **使用量配额**。
1. 选择 **存储** 选项卡以查看命名空间存储用量。
1. 要查看项目的存储用量，在底部的表格中选择一个项目。存储用量每 90 分钟更新一次。

如果你的命名空间显示 `'不适用。'`，请向该命名空间中的任意项目推送一个提交以重新计算存储。

存储和网络用量采用二进制计量系统（1024 单位倍数）计算。
存储用量以 kibibytes（KiB）、mebibytes（MiB）或 gibibytes（GiB）显示。1 KiB 为 2<sup>10</sup> 字节（1024 字节），1 MiB 为 2<sup>20</sup> 字节（1024 kibibytes），1 GiB 为 2<sup>30</sup> 字节（1024 mebibytes）。

<a id="view-project-fork-storage-usage"></a>

## 查看项目派生存储用量

对项目派生消耗的存储应用一个成本因子，使得派生消耗的命名空间存储少于其实际大小。派生存储缩减的成本因子仅适用于命名空间存储，不适用于项目仓库存储限制。

要查看派生已使用的命名空间存储量：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **设置** > **使用量配额**。
1. 选择 **存储** 选项卡。**总计** 列显示派生使用的命名空间存储量，该值表示为磁盘上派生实际大小的一定比例。

成本因子适用于项目仓库、LFS 对象、作业产物、软件包、代码片段和 wiki。

成本因子不适用于基础版计划中命名空间内的私有派生。

<a id="excess-storage-usage"></a>

## 超额存储用量

{{< details >}}

- Tier: 基础版

{{< /details >}}

超额存储用量是指超过项目仓库和 LFS 的 10 GiB 免费存储的部分。如果没有可用的已购存储，项目将被设置为只读状态。你无法向只读项目推送更改。

要移除只读状态，你必须为命名空间购买更多存储。
购买完成后，只读状态将被移除，项目会自动恢复。可用的已购存储量必须始终大于零。

**使用量配额** 页面的 **存储** 选项卡显示以下信息：

- 可用的已购存储即将耗尽。
- 如果可用的已购存储为零，存在变为只读风险的项目。
- 因可用的已购存储为零而处于只读状态的项目。只读项目名称旁会带有一个信息图标（{{< icon name="information-o" >}}）标识。

总存储包括免费存储和已购的超额存储。
剩余超额存储以百分比表示，计算方式为：
100% - ((已用超额存储 - 已购超额存储) × 100)。

<a id="excess-storage-example"></a>

### 超额存储示例

以下示例描述了一个命名空间中项目的超额存储场景：

| 仓库      | 已用存储 | 超额存储 | 配额    | 状态                   |
|-----------|---------|---------|--------|------------------------|
| Red       | 10 GiB   | 0 GiB   | 10 GiB | 只读 {{< icon name="lock" >}} |
| Blue      | 8 GiB    | 0 GiB   | 10 GiB | 未只读                 |
| Green     | 10 GiB   | 0 GiB   | 10 GiB | 只读 {{< icon name="lock" >}} |
| Yellow    | 2 GiB    | 0 GiB   | 10 GiB | 未只读                 |
| **总计**  | **30 GiB** | **0 GiB** | -      | -                    |

Red 和 Green 项目为只读状态，因为它们的仓库和 LFS 已达到配额。在此示例中，尚未购买额外存储。

为了解除 Red 和 Green 项目的只读状态，购买了 50 GiB 额外存储。

如果某些项目的仓库和 LFS 增长超过 10 GiB 配额，可用的已购存储会减少。

| 仓库      | 已用存储 | 超额存储 | 配额    | 状态            |
|-----------|---------|---------|--------|-----------------|
| Red       | 15 GiB   | 5 GiB   | 10 GiB | 未只读          |
| Blue      | 14 GiB   | 4 GiB   | 10 GiB | 未只读          |
| Green     | 11 GiB   | 1 GiB   | 10 GiB | 未只读          |
| Yellow    | 5 GiB    | 0 GiB   | 10 GiB | 未只读          |
| **总计**  | **45 GiB** | **10 GiB** | -     | -              |

在此示例中：

- 可用的已购存储为 40 GiB：50 GiB（已购存储） - 10 GiB（总已用超额存储）。因此，项目不再为只读。
- 超额存储用量为 20%：10 GiB / 50 GiB × 100。
- 剩余的已购存储为 80%。

<a id="manage-storage-usage"></a>

## 管理存储用量

要管理存储，如果你是免费 JihuLab.com 命名空间的所有者，你可以为命名空间购买更多存储。

在专业版和旗舰版中，根据你的角色，你还可以[缩减仓库大小](project/repository/repository_size.md#methods-to-reduce-repository-size)。
要自动化存储用量分析和管理，请参阅[存储管理自动化](storage_management_automation.md)。

除了管理存储用量外，你还可以考虑以下增加消耗性资源的选项：

- 如果你符合条件，可以申请[社区计划订阅](../subscriptions/community_programs.md)：
  - GitLab for Education
  - GitLab for Open Source
  - GitLab for Startups
- 考虑[极狐GitLab 私有化部署订阅](../subscriptions/manage_subscription.md)，它没有存储限制。
- [与专家交流](https://page.jihulab.com/usage_limits_help.html)，获取有关选项的更多信息。

<a id="purchase-more-storage"></a>

## 购买更多存储

{{< details >}}

- Tier: 基础版

{{< /details >}}

> [!note]
> 要超出免费基础版命名空间的 10 GiB 限制，你可以为个人或群组命名空间购买更多存储。

先决条件：

- 你必须拥有所有者角色或是账单账户管理员。
- 账单账户必须关联到个人或群组命名空间的订阅。

> [!note]
> 存储订阅 **每年自动续订**。
> 你可以[关闭自动订阅续订](../subscriptions/manage_subscription.md#turn-on-or-turn-off-automatic-subscription-renewal)。

<a id="for-your-personal-namespace"></a>

### 针对个人命名空间

1. 登录 JihuLab.com。
1. 从你的个人首页或群组页面，进入 **设置** > **使用量配额**。
1. 选择 **存储** 选项卡。
1. 对于每个只读项目，将其 **用量** 超过免费配额和已购存储的部分汇总。你必须购买超过此总额的存储增量。
1. 选择 **购买存储**。你将跳转至客户门户。
1. 在 **订阅详情** 部分，从下拉列表中选择用户名。
1. 输入所需的存储包数量。
1. 在 **客户信息** 部分，验证你的地址。
1. 在 **账单信息** 部分，从下拉列表中选择支付方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买存储**。

**可用已购存储** 总计增加所购数量。所有项目的只读状态被解除，其超额用量从额外存储中扣除。

<a id="for-your-group-namespace"></a>

### 针对群组命名空间

如果你正在使用 JihuLab.com，当你用完主配额的所有存储后，可以购买额外存储，以避免流水线受阻。你可以在[极狐GitLab 定价页面](https://gitlab.cn/pricing/#storage)上找到额外存储的价格。

要为 JihuLab.com 上的群组购买额外存储：

{{< tabs >}}

{{< tab title="群组所有者" >}}

1. 登录 JihuLab.com。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **使用量配额**。
1. 选择 **存储** 选项卡。
1. 选择 **购买存储**。你将跳转至客户门户。
1. 在 **订阅详情** 部分，在 **数量** 字段中输入所需的存储包数量。
1. 在 **客户信息** 部分，验证你的地址。
1. 在 **账单信息** 部分，从下拉列表中选择支付方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买存储**。

{{< /tab >}}

{{< tab title="账单账户管理员" >}}

1. 前往[客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 在订阅卡片上，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **购买更多存储**。
1. 在 **订阅详情** 部分，在 **数量** 字段中输入所需的存储包数量。
1. 在 **客户信息** 部分，验证你的地址。
1. 在 **账单信息** 部分，从下拉列表中选择支付方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买存储**。

{{< /tab >}}

{{< /tabs >}}

付款处理完毕后，额外存储即可用于你的群组命名空间。

要确认可用存储，请按照之前列出的前三个步骤操作。

**可用已购存储** 总计增加所购数量。所有锁定项目被解锁，其超额用量从额外存储中扣除。