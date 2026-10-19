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

您可以为 [Terraform 状态文件](../terraform_state.md)配置设置，包括加密和存储限制。

<a id="terraform-state-encryption"></a>

## Terraform 状态加密

默认情况下，极狐GitLab 会在存储 Terraform 状态文件之前对其进行加密。如有需要，您可以关闭加密。

关闭加密后，Terraform 状态文件将按接收时的原样存储，不应用任何加密。

先决条件：

- 您必须具有管理员访问权限。

配置 Terraform 状态加密：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开 **Terraform 状态**。
1. 选中或清除**开启 Terraform 状态加密**复选框。
1. 选择**保存更改**。

> [!warning]
> 关闭加密后，该更改仅影响新的 Terraform 状态文件。
> 现有的已加密文件仍保持加密，并继续按预期正常工作。

<a id="encryption-key-rotation"></a>

## 加密密钥轮换

您无法轮换 Terraform 状态加密密钥。

该加密密钥派生自 `db_key_base` 应用密钥和项目 ID。更多信息，请参见[解密过程](../terraform_state.md#decryption-process)。由于该密钥是派生而来而非直接存储，因此不存在可轮换的独立 Terraform 状态密钥。

不支持轮换 `db_key_base` 本身，因为它会加密整个实例中的数据，包括 CI/CD 变量、集成和 Webhook 凭据以及身份验证令牌。

> [!warning]
> 如果您更改 `db_key_base`，现有的 Terraform 状态文件将变得不可读。
> 如果配置了多个 `db_key_base` 且不存在重新加密工具，极狐GitLab 会引发错误。

密钥轮换已在[议题 25332](https://gitlab.com/gitlab-org/gitlab/-/issues/25332)中提出。

<a id="terraform-state-storage-limits"></a>

## Terraform 状态存储限制

您可以限制 [Terraform 状态文件](../terraform_state.md)的总存储量。该限制适用于每个单独的状态文件版本，并在创建新版本时进行检查。

先决条件：

- 您必须具有管理员访问权限。

添加存储限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开 **Terraform 状态**。
1. 在 **Terraform 状态大小限制（字节）**字段中，输入以字节为单位的大小限制。设置为 `0` 以允许文件大小不受限制。
1. 选择**保存更改**。

当 Terraform 状态文件超过此限制时，极狐GitLab 不会保存它们，并拒绝相关的 Terraform 操作。
