---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Assign GitLab Duo seats to users using the GraphQL API. Learn prerequisites, queries, mutations, and how to manage add-on seat assignments efficiently.
title: 通过 GraphQL 分配极狐GitLab Duo 席位
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.11 引入。

{{< /history >}}

使用此 API 向用户分配 [极狐GitLab Duo 席位](../../user/gitlab_duo/_index.md)。

<a id="prerequisites"></a>

## 先决条件

- 必须具有要为其分配席位的群组的所有者角色。
- 必须具有带有 `api` 范围的个人访问令牌。

<a id="get-the-add-on-purchase-id"></a>

## 获取插件购买 ID

首先，获取 GitLab Duo 插件的购买 ID。对于 JihuLab.com：

```graphql
query {
 addOnPurchases (namespaceId: "gid://gitlab/Group/YOUR_NAMESPACE_ID")
 {
  name
  purchasedQuantity
  assignedQuantity
  id
 }
}
```

对于私有化部署：

```graphql
query {
 addOnPurchases
 {
  name
  purchasedQuantity
  assignedQuantity
  id
 }
}
```

<a id="assign-a-gitlab-duo-seat-to-specific-users"></a>

## 分配 GitLab Duo 席位给特定用户

然后向特定用户分配席位：

```graphql
mutation {
  userAddOnAssignmentBulkCreate(input: {
    addOnPurchaseId: "gid://gitlab/GitlabSubscriptions::AddOnPurchase/YOUR_ADDON_PURCHASE_ID",
    userIds: [
      "gid://gitlab/User/USER_ID_1",
      "gid://gitlab/User/USER_ID_2",
      "gid://gitlab/User/USER_ID_3"
    ]
  }) {
    addOnPurchase {
      id
      name
      assignedQuantity
      purchasedQuantity
    }
    users {
      nodes {
        id
        username
        }
      }
    errors
  }
}
```

<a id="use-graphql"></a>

## 使用 GraphQL

你可以使用 [GraphQL](https://jihulab.com/-/graphql-explorer) 向用户分配席位。

1. 复制插件购买 ID 的代码片段。
1. 打开 GraphQL。
1. 在左侧窗口中，输入[获取插件购买 ID](#get-the-add-on-purchase-id) 的查询。
1. 选择 **执行**。
1. 重复此操作来分配 GitLab Duo 席位给特定用户。

