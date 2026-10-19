---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 GraphQL 使用自定义表情符号
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于 极狐GitLab 13.6 引入，[带有一个功能标志](../../administration/feature_flags/_index.md) 命名为 `custom_emoji`，默认禁用。
- 于 极狐GitLab 14.0 在 JihuLab.com 上启用。
- 于 极狐GitLab 16.7 在私有化部署实例上启用。
- 于 极狐GitLab 16.9 GA。功能标志 `custom_emoji` 已移除。

{{< /history >}}

要在评论和描述中使用自定义表情符号，你可以通过 GraphQL API 将它们添加到顶级群组中。

<a id="create-a-custom-emoji"></a>

## 创建自定义表情符号

```graphql
mutation CreateCustomEmoji($groupPath: ID!) {
  createCustomEmoji(input: {groupPath: $groupPath, name: "party-parrot", url: "https://cultofthepartyparrot.com/parrots/hd/parrot.gif"}) {
    clientMutationId
    customEmoji {
      name
    }
    errors
  }
}
```

将自定义表情符号添加到群组后，成员可以像在评论中使用其他表情符号一样使用它。

<a id="attributes"></a>

### 属性

查询接受以下属性：

| 属性          | 类型           | 是否必需               | 描述                                                                 |
| :----------- | :------------- | :--------------------- | :------------------------------------------------------------------- |
| `group_path` | 整数或字符串   | 是                     | 顶级群组的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `name`       | 字符串         | 是                     | 自定义表情符号的名称。                                                 |
| `file`       | 字符串         | 是                     | 自定义表情符号图片的 URL。                                             |

<a id="use-graphiql"></a>

## 使用 GraphiQL

你可以使用 GraphiQL 查询群组的表情符号。

1. 打开 GraphiQL：
   - 对于 JihuLab.com，请使用：`https://jihulab.com/-/graphql-explorer`
   - 对于私有化部署实例，请使用：`https://gitlab.example.com/-/graphql-explorer`
1. 复制以下文本并粘贴到左侧窗口中。
   在此查询中，`gitlab-org` 是群组路径。

   ```graphql
       query GetCustomEmoji {
         group(fullPath: "gitlab-org") {
           id
           customEmoji {
             nodes {
               name,
               url
             }
           }
         }
       }
   ```

1. 选择 **运行**。

<a id="related-topics"></a>

## 相关主题

- [GraphQL API 参考](reference/_index.md)
- [GraphQL 特定实体，如片段和接口](https://graphql.org/learn/)