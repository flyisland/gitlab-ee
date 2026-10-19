---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 GraphQL 识别议题看板
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用以下方式识别项目的[议题看板](../../user/project/issue_board.md)：

- GraphiQL。
- [`cURL`](getting_started.md#command-line)。

<a id="use-graphiql"></a>

## 使用 GraphiQL

您可以使用 GraphiQL 列出项目的议题看板。

1. 打开 GraphiQL：
   - 对于 JihuLab.com，使用：`https://jihulab.com/-/graphql-explorer`
   - 对于私有化部署，使用：`https://gitlab.example.com/-/graphql-explorer`
1. 复制以下文本并粘贴到左侧窗口中。此查询获取 `docs-gitlab-com` 仓库的议题看板。

   ```graphql
   query {
     project(fullPath: "gitlab-org/technical-writing/docs-gitlab-com") {
       name
       forksCount
       statistics {
         wikiSize
       }
       issuesEnabled
       boards {
         nodes {
           id
           name
         }
       }
     }
   }
   ```

1. 选择 **播放**。

要查看其中一个议题看板，请从输出中复制一个数字标识符。例如，如果标识符是 `7174622`，则使用此 URL 跳转到该议题看板：

```http
https://jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/-/boards/7174622
```

## 相关主题

- [GraphQL API 参考](reference/_index.md)