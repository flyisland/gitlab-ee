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

当一个命名空间超过免费用户限制，并且命名空间可见性为私有时，该命名空间会被置于只读状态。

要解除命名空间及其项目的只读状态，你可以：

- [减少命名空间中的成员数量](free_user_limit.md#manage-members-in-your-group-namespace)。
- [开始免费试用](https://jihulab.com/-/trial_registrations/new)，包含无限制的成员数量。
- [购买付费版本](https://gitlab.cn/pricing/)。

<a id="restricted-actions"></a>

### 受限操作

当命名空间处于只读状态时，你无法执行下表中列出的操作。如果你尝试执行受限操作，可能会收到 `404` 错误。

| 功能 | 受限操作 |
|---------|-------------------|
| 容器镜像仓库 | 创建、编辑和删除清理策略。<br>将镜像推送到容器镜像仓库。 |
| 合并请求 | 创建和更新合并请求。 |
| 软件包仓库 | 发布一个软件包。 |
| CI/CD | 创建、编辑、管理和运行流水线。<br>创建、编辑、管理和运行构建。<br>创建和编辑管理环境。<br>创建和编辑管理部署。<br>创建和编辑管理集群。<br>创建和编辑管理发布。 |
| 命名空间 | **对于超出免费用户限制**：邀请新用户。 |

<a id="read-only-projects"></a>

## 只读项目

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

当一个项目超出其分配的存储限制时，该项目会被置于只读状态，具体如下：

- 基础版：当命名空间中的任何项目超出[免费限制](storage_usage_quotas.md#free-limit)时。
- 专业版和旗舰版：当命名空间中的任何项目超出[固定项目限制](storage_usage_quotas.md#fixed-project-limit)时。

<a id="restricted-actions-2"></a>

### 受限操作

当项目因存储限制而只读时，你无法将大文件 (LFS) 推送或添加到项目的仓库中。项目或命名空间页面顶部的横幅会指示只读状态。