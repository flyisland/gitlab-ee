---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: JihuLab.com 凭据清单
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.5 中为 JihuLab.com 引入。

{{< /history >}}

{{< alert type="note" >}}

对极狐GitLab 私有化部署，查看[私有化部署凭据清单](../../administration/credentials_inventory.md)。

{{< /alert >}}

使用凭证清单来监控和控制 JihuLab.com 上您群组和项目的访问。

作为顶级群组的所有者，您可以：

- 撤销个人访问令牌。
- 删除 SSH 密钥。
- 审查您的[企业用户](../enterprise_user/_index.md)的凭证详情，包括：
  - 所有权。
  - 访问范围。
  - 使用模式。
  - 过期日期。
  - 撤销日期。

<a id="revoke-personal-access-tokens"></a>

## 撤销个人访问令牌

要撤销您群组中企业用户的个人访问令牌：

1. 在左侧边栏，选择 **安全**。
1. 选择 **凭证**。
1. 在个人访问令牌旁边，选择 **撤销**。
   如果令牌之前已过期或已撤销，您将看到发生日期。

访问令牌被撤销，用户会收到邮件通知。

<a id="delete-ssh-keys"></a>

## 删除 SSH 密钥

要删除您群组中企业用户的 SSH 密钥：

1. 在左侧边栏，选择 **安全**。
1. 选择 **凭证**。
1. 选择 **SSH 密钥** 标签。
1. 在 SSH 密钥旁边，选择 **删除**。

SSH 密钥被删除，用户会收到通知。

<a id="revoke-project-or-group-access-tokens"></a>

## 撤销项目或群组访问令牌

您无法在 JihuLab.com 上使用凭证清单查看或撤销项目或群组访问令牌。

