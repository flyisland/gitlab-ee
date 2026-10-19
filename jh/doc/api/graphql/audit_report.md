---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 GraphQL 创建审计报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以通过以下方式为特定用户子集创建审计报告：

- GraphiQL。
- [`cURL`](getting_started.md#command-line)。

<a id="use-graphiql"></a>

## 使用 GraphiQL

你可以使用 GraphiQL 查询用户子集的相关信息。

1. 打开 GraphiQL：
   - 对于 JihuLab.com，使用：`https://jihulab.com/-/graphql-explorer`
   - 对于极狐GitLab 私有化部署，使用：`https://gitlab.example.com/-/graphql-explorer`
1. 复制以下文本并粘贴到左侧窗口中。
   此查询会按用户名搜索用户子集。或者，你也可以使用他们的
   [Global ID](_index.md#global-ids)。

   ```graphql
   {
     users(usernames: ["user1", "user2", "user3"]) {
       pageInfo {
         endCursor
         startCursor
         hasNextPage
       }
       nodes {
         id
         ...memberships
       }
     }
   }

   fragment membership on MemberInterface {
     createdAt
     updatedAt
     accessLevel {
       integerValue
       stringValue
     }
     createdBy {
       id
     }
   }

   fragment memberships on User {
     groupMemberships {
       nodes {
         ...membership
         group {
           id
           name
         }
       }
     }

     projectMemberships {
       nodes {
         ...membership
         project {
           id
           name
         }
       }
     }
   }
   ```

1. 选择 **执行**。

> [!note]
> [GraphQL API 返回的是 GlobalID，而非标准 ID](getting_started.md#queries-and-mutations)。它同样期望输入的是 GlobalID，而非单一整数。

此查询会返回用户已被明确添加为成员的所有群组和项目。

- 由于 GraphiQL 使用会话令牌来授权资源访问，因此输出仅限于当前已认证用户有权访问的项目和群组。
- 如果你以实例管理员的身份登录，则可以访问所有资源。

<a id="pagination-and-graph-nodes"></a>

## 分页和图形节点

该查询包含：

- [`pageInfo`](#pageinfo)
- [`nodes`](#nodes)

<a id="pageinfo"></a>

### `pageInfo`

其中包含了实现分页所需的数据。极狐GitLab 使用基于游标的
[分页](getting_started.md#pagination)。更多信息请参阅 GraphQL 文档中的
[分页](https://graphql.org/learn/pagination/)。

<a id="nodes"></a>

### `nodes`

在 GraphQL 查询中，`nodes` 表示图上的一个 [`节点` 集合](https://en.wikipedia.org/wiki/Vertex_(graph_theory))。
在此例中，该节点集合是一个 `User` 对象的集合。对于每一个用户，输出均包含：

- 用户的 `id`。
- `membership` 片段，它代表了属于该用户的项目或群组成员资格。片段由 `...memberships` 标记表示。

## 相关主题

- [GraphQL API 参考](reference/_index.md)
- [GraphQL 特定实体，如片段和接口](https://graphql.org/learn/)