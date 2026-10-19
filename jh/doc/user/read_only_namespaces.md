---
stage: Growth
group: Acquisition
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 只读命名空间和项目
---

<a id="read-only-namespaces"></a>

## 只读命名空间

{{< details >}}

- Tier: 基础版
- Offering: JihuLab.com

{{< /details >}}

当命名空间超出[基础版用户数限制](free_user_limit.md)，且命名空间可见性为私有时，该命名空间会进入只读状态。

要解除命名空间及其项目的只读状态，您可以：

- [减少您命名空间中的成员数量](free_user_limit.md#manage-members-in-your-group-namespace)。
- [开始免费试用](https://jihulab.com/-/trial_registrations/new)，其中包含不限数量的成员。
- [购买付费套餐](https://gitlab.cn/pricing)。

<a id="restricted-actions"></a>

### 受限操作

当命名空间处于只读状态时，您无法执行下表列出的操作。如果尝试执行受限操作，您可能会收到 `404` 错误。

| 功能 | 受限操作 |
|---------|-------------------|
| 容器镜像仓库 | 创建、编辑和删除清理策略。<br> 将镜像推送到容器镜像仓库。 |
| 合并请求 | 创建和更新合并请求。 |
| 软件包仓库 | 发布软件包。 |
| CI/CD | 创建、编辑、管理和运行流水线。<br>  创建、编辑、管理和运行构建。<br>  创建、编辑和管理环境。<br> 创建、编辑和管理部署。<br>  创建、编辑和管理集群。<br> 创建、编辑和管理发布。 |
| 命名空间 | **超出基础版用户数限制时**：邀请新用户。 |

<a id="read-only-projects"></a>

## 只读项目

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

当项目超出以下已分配的存储限制时，该项目会进入只读状态：

- 基础版：当命名空间中的任一项目超出[基础版限制](storage_usage_quotas.md#free-limit)时。
- 专业版和旗舰版：当命名空间中的任一项目超出[固定项目限制](storage_usage_quotas.md#fixed-project-limit)时。

<a id="restricted-actions-1"></a>

### 受限操作

当项目因存储限制而处于只读状态时，您无法将大型文件（LFS）推送或添加到项目的代码仓库中。项目或命名空间页面顶部的横幅会显示只读状态。
