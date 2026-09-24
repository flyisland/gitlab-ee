---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Terraform 状态设置
description: 配置 Terraform 状态加密和存储限制。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以配置 [Terraform 状态文件](../terraform_state.md) 的设置，包括加密和存储限制。

<a id="terraform-state-encryption"></a>

## Terraform 状态加密

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

默认情况下，极狐GitLab 在存储之前会加密 Terraform 状态文件。如果需要，您可以关闭加密。

关闭加密后，Terraform 状态文件将以接收时的形式存储，不会应用任何加密。

前提条件：

- 您必须具有管理员访问权限。

配置 Terraform 状态加密：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **Terraform 状态**。
1. 选中或清除 **开启 Terraform 状态加密** 复选框。
1. 选择 **保存更改**。

> [!warning]
> 当您关闭加密时，更改仅影响新的 Terraform 状态文件。现有的加密文件保持加密状态，并继续正常工作。

<a id="terraform-state-storage-limits"></a>

## Terraform 状态存储限制

{{< history >}}

- 在极狐GitLab 15.7 中引入。

{{< /history >}}

您可以限制 [Terraform 状态文件](../terraform_state.md) 的总存储量。该限制适用于每个单独的状态文件版本，并在创建新版本时进行检查。

前提条件：

- 您必须具有管理员访问权限。

添加存储限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **Terraform 状态**。
1. 在 **Terraform 状态大小限制（字节）** 字段中，输入以字节为单位的大小限制。设置为 `0` 以允许无限大小的文件。
1. 选择 **保存更改**。

当 Terraform 状态文件超过此限制时，极狐GitLab 将不保存它们并拒绝相关的 Terraform 操作。
 
</output>