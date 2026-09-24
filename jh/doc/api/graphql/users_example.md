---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 GraphQL 查询用户
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用以下方式查询极狐GitLab 实例中的用户子集：

- GraphiQL。
- [`cURL`](getting_started.md#command-line)。

## 使用 GraphiQL

1. 打开 GraphiQL：
   - 对于 JihuLab.com，使用：`https://jihulab.com/-/graphql-explorer`
   - 对于极狐GitLab 私有化部署，使用：`https://gitlab.example.com/-/graphql-explorer`
1. 复制以下文本并将其粘贴到左侧窗口中。
   此查询按用户名查找极狐GitLab 实例中的用户子集。
   您也可以使用他们的 [全局 ID](_index.md#global-ids)。

   ```graphql
    {
      users(usernames: ["user1", "user3", "user4"]) {
        pageInfo {
          endCursor
          startCursor
          hasNextPage
        }
        nodes {
          id
          username,
          publicEmail
          location
          webUrl
          userPermissions {
            createSnippet
          }
        }
      }
    }
   ```

1. 选择 **执行**。

> [!note]
> [GraphQL API 返回 GlobalID，而不是标准 ID](getting_started.md#queries-and-mutations)。
> 它还期望将 GlobalID 作为输入，而不是单个整数。

此查询返回具有所列用户名的三个用户的指定信息。

- 由于 GraphiQL 使用会话令牌来授权对资源的访问，因此输出仅限于当前已验证用户可访问的工程和群组。
- 如果您以实例管理员身份登录，则可以访问所有资源。

<a id="show-administrators-only"></a>

### 仅显示管理员

如果您以管理员身份登录，则可以通过向查询添加 `admins: true` 参数来显示实例上匹配的管理员。
将第二行更改为：

```graphql
  users(usernames: ["user1", "user3", "user4"], admins: true) {
    ...
  }
```

或者，您可以获取所有管理员：

```graphql
  users(admins: true) {
    ...
  }
```

<a id="pagination-and-graph-nodes"></a>

## 分页与图节点

查询包括：

- [`pageInfo`](#pageinfo)
- [`nodes`](#nodes)

<a id="pageinfo"></a>

### 分页信息

它包含实现分页所需的数据。极狐GitLab 使用基于游标的[分页](getting_started.md#pagination)。有关更多信息，请参阅 GraphQL 文档中的[分页](https://graphql.org/learn/pagination/)。

<a id="nodes"></a>

### 节点

在 GraphQL 查询中，`nodes` 表示图上[节点](https://en.wikipedia.org/wiki/Vertex_(graph_theory))的集合。
在这种情况下，节点集合是 `User` 对象的集合。对于每个对象，输出包括：

- 用户的 `id`。
- `membership` 片段，它表示属于该用户的工程或群组成员资格。片段由 `...memberships` 符号指示。