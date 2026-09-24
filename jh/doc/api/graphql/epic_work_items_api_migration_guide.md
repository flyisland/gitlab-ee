---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将史诗 API 迁移到工作项
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.2 中引入，有一个功能标志 `work_item_epics`，默认禁用。必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。在[测试版](../../policy/development_stages_support.md#beta)中引入。
- 在极狐GitLab 17.4 中引入，可以使用 [GraphQL API](reference/_index.md) 列出史诗。
- 在极狐GitLab 17.6 中于 JihuLab.com 上启用。
- 在极狐GitLab 17.7 中于私有化部署上默认启用。
- 在极狐GitLab 18.1 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/468310)。功能标志 `work_item_epics` 已移除。

{{< /history >}}

极狐GitLab 17.2 引入了[作为工作项的史诗](../../user/group/epics/_index.md#epics-as-work-items)。

为确保您的集成继续工作：

- 如果您使用[史诗 GraphQL API](reference/_index.md#epic)，请在史诗 GraphQL API 被移除之前迁移到工作项 API。
- 如果您使用[史诗 REST API](../epics.md)，可以继续使用，但应该进行迁移以保证集成的未来兼容性。
- 对于新功能（例如指派人、健康状态、与其他类型的关联项），您必须使用 `WorkItem` GraphQL API。

<a id="api-status"></a>

## API 状态

<a id="rest-api-apiv4"></a>

### REST API (`/api/v4/`)

史诗的 REST API：

- 仍受支持但已弃用。
- 继续与现有端点一起工作。
- 不接收新功能。
- 没有设定移除日期，但会在一个主要版本中移除。

<a id="graphql-api"></a>

### GraphQL API

`WorkItem` GraphQL API：

- 标记为实验版。
- 在生产环境中使用。
- 将在极狐GitLab 19.0 之前 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/500620)。
- 计划在极狐GitLab 19.0 之前退出[实验状态](https://gitlab.com/gitlab-org/gitlab/-/issues/500620)。

[史诗 GraphQL API](reference/_index.md#epic) 计划在极狐GitLab 19.0 中移除。

<a id="migrate-to-the-work-item-api"></a>

## 迁移到工作项 API

工作项 API 使用小部件来表示诸中健康状态、指派人和层级等史诗属性。

<a id="set-up-the-graphiql-explorer"></a>

### 设置 GraphiQL 浏览器

要运行这些示例，您可以使用 GraphiQL——一个交互式 GraphQL API 浏览器，您可以在其中尝试现有查询：

1. 打开 GraphiQL 浏览器工具：
   - 对于 JihuLab.com，请访问 <https://jihulab.com/-/graphql-explorer>。
   - 对于极狐GitLab 私有化部署，请访问 `https://gitlab.example.com/-/graphql-explorer`。将 `gitlab.example.com` 更改为您的实例 URL。
1. 将一个示例中的查询粘贴到 GraphiQL 浏览器工具的左侧窗口中。
1. 选择 **执行**。

<a id="query-epics"></a>

### 查询史诗

> [!note]
> 史诗 ID 与工作项 ID 不同，但 IID（每个群组递增的 ID）保持不变。
> 例如，位于 `/gitlab-org/-/epics/123` 的史诗与工作项具有相同的 IID `123`。

**之前（史诗 API）**：

```graphql
query Epics {
  group(fullPath: "gitlab-org") {
    epics {
      nodes {
        id
        iid
        title
      }
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "group": {
      "epics": {
        "nodes": [
          {
            "id": "gid://gitlab/Epic/2335843",
            "iid": "15596",
            "title": "First epic"
          },
          {
            "id": "gid://gitlab/Epic/2335762",
            "iid": "15595",
            "title": "Second epic"
          }
        ]
      }
    }
  }
}
```

**之后（工作项 API）**：

```graphql
query EpicsAsWorkItem {
  group(fullPath: "gitlab-org") {
    workItems(types: [EPIC]) {
      nodes {
        id
        iid
        title
      }
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "group": {
      "workItems": {
        "nodes": [
          {
            "id": "gid://gitlab/WorkItem/154888575",
            "iid": "15596",
            "title": "First epic"
          },
          {
            "id": "gid://gitlab/WorkItem/154877868",
            "iid": "15595",
            "title": "Second epic"
          }
        ]
      }
    }
  }
}
```

<a id="create-an-epic"></a>

### 创建一个史诗

**之前（史诗 API）**：

```graphql
mutation CreateEpic {
  createEpic(input: { title: "New epic", groupPath: "gitlab-org" }) {
    epic {
      id
      title
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "createEpic": {
      "epic": {
        "id": "gid://gitlab/Epic/806",
        "title": "New epic"
      }
    }
  }
}
```

**之后（工作项 API）**：

创建一个史诗：

1. 获取命名空间中史诗的工作项类型 ID (`workItemTypeId`)。

   史诗的 `workItemTypeId` 在极狐GitLab 实例或命名空间之间并不保证相同。为确保默认工作项类型的 ID 相同，相关工作正在跟踪中，见史诗 15272。

   ```graphql
   query WorkItemTypes {
     namespace(fullPath: "gitlab-org") {
       workItemTypes(name: EPIC) {
         nodes {
           id
           name
         }
       }
     }
   }
   ```

   示例响应：

   ```json
   {
     "data": {
       "namespace": {
         "workItemTypes": {
           "nodes": [
             {
               // <WorkItemTypeId> 将根据您的命名空间和实例而有所不同
               "id": "gid://gitlab/WorkItems::Type/<WorkItemTypeId>",
               "name": "Epic"
             }
           ]
         }
       }
     }
   }
   ```

1. 使用该 ID 创建史诗（类型为 `epic` 的工作项）：

   ```graphql
   mutation CreateWorkItemEpic {
     workItemCreate(
       input: {
         title: "New work item epic"
         namespacePath: "gitlab-org"
         workItemTypeId: "gid://gitlab/WorkItems::Type/<WorkItemTypeID>"
       }
     ) {
       workItem {
         id
         title
       }
     }
   }
   ```

   示例响应：

   ```json
   {
     "data": {
       "workItemCreate": {
         "workItem": {
           "id": "gid://gitlab/WorkItem/2243",
           "title": "New work item epic"
         }
       }
     }
   }
   ```

<a id="widgets"></a>

### 小部件

工作项 API 引入小部件的概念。小部件代表工作项类型的特定功能或属性，范围可从健康状态或指派人之类的属性到日期或层级。每个工作项类型都有一组独特可用的小部件。

<a id="query-epics-with-widgets"></a>

#### 使用小部件查询史诗

要检索有关史诗的详细信息，您可以在 GraphQL 查询中使用各种小部件。以下示例演示如何查询史诗的：

- 层级（父/子关系）
- 指派人
- 表情符号回应
- 颜色
- 健康状态
- 开始和截止日期

关于所有可用小部件，请参阅[工作项小部件参考](reference/_index.md#workitemwidget)。

使用小部件查询史诗：

**之前（史诗 API）**：

```graphql
query DetailedEpicQuery {
  group(fullPath: "gitlab-org") {
    epic(iid: 1000) {
      id
      iid
      title
      confidential
      author {
        id
        name
      }
      state
      color
      parent {
        id
        title
      }
      startDate
      dueDate
      ancestors {
        nodes {
          id
          title
        }
      }
      children {
        nodes {
          id
          title
        }
      }
      notes {
        nodes {
          body
          createdAt
          author {
            name
          }
        }
      }
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "group": {
      "epic": {
        "id": "gid://gitlab/Epic/5579",
        "iid": "1000",
        "title": "Pajamas component: Pagination - Style",
        "confidential": false,
        "author": {
          "id": "gid://gitlab/User/3079878",
          "name": "Sidney Jones"
        },
        "state": "opened",
        "color": "#1068bf",
        "parent": {
          "id": "gid://gitlab/Epic/5576",
          "title": "Pajamas component: Pagination"
        },
        "startDate": null,
        "dueDate": null,
        "ancestors": {
          "nodes": [
            {
              "id": "gid://gitlab/Epic/5523",
              "title": "Components of Pajamas Design System"
            },
            {
              "id": "gid://gitlab/Epic/5576",
              "title": "Pajamas component: Pagination"
            }
          ]
        },
        "children": {
          "nodes": []
        },
        "notes": {
          "nodes": [
            {
              "body": "changed the description",
              "createdAt": "2019-04-02T17:03:05Z",
              "author": {
                "name": "Sidney Jones"
              }
            },
            {
              "body": "mentioned in epic &997",
              "createdAt": "2019-04-26T15:45:49Z",
              "author": {
                "name": "Zhang Wei"
              }
            },
            {
              "body": "added issue gitlab-ui#302",
              "createdAt": "2019-06-27T09:20:43Z",
              "author": {
                "name": "Alex Garcia"
              }
            },
            {
              "body": "added issue gitlab-ui#304",
              "createdAt": "2019-06-27T09:20:43Z",
              "author": {
                "name": "Alex Garcia"
              }
            },
            {
              "body": "added issue gitlab-ui#316",
              "createdAt": "2019-07-11T08:26:25Z",
              "author": {
                "name": "Alex Garcia"
              }
            },
            {
              "body": "mentioned in issue gitlab-design#528",
              "createdAt": "2019-08-05T14:12:51Z",
              "author": {
                "name": "Jan Kowalski"
              }
            }
          ]
        }
      }
    }
  }
}
```

**之后（工作项 API）**：

```graphql
query DetailedEpicWorkItem {
  namespace(fullPath: "gitlab-org") {
    workItem(iid: "10") {
      id
      title
      confidential
      author {
        id
        name
      }
      state
      widgets {
        ... on WorkItemWidgetColor {
          color
          textColor
          __typename
        }
        ... on WorkItemWidgetHierarchy {
          children {
            nodes {
              id
              title
            }
          }
          parent {
            title
          }
          __typename
        }
        ... on WorkItemWidgetHealthStatus {
          type
          healthStatus
        }
        ... on WorkItemWidgetAssignees {
          assignees {
            nodes {
              name
            }
          }
          __typename
        }
        ... on WorkItemWidgetAwardEmoji {
          downvotes
          upvotes
          awardEmoji {
            nodes {
              unicode
            }
          }
          __typename
        }
        ... on WorkItemWidgetStartAndDueDate {
          dueDate
          isFixed
          startDate
          __typename
        }
        ... on WorkItemWidgetNotes {
          discussions {
            nodes {
              notes {
                edges {
                  node {
                    body
                    id
                    author {
                      name
                    }
                  }
                }
              }
            }
          }
        }
        __typename
      }
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "namespace": {
      "workItem": {
        "id": "gid://gitlab/WorkItem/146171815",
        "title": "Pajamas component: Pagination - Style",
        "confidential": false,
        "author": {
          "id": "gid://gitlab/User/3079878",
          "name": "Sidney Jones"
        },
        "state": "OPEN",
        "widgets": [
          {
            "assignees": {
              "nodes": []
            },
            "__typename": "WorkItemWidgetAssignees"
          },
          {
            "__typename": "WorkItemWidgetDescription"
          },
          {
            "children": {
              "nodes": [
                {
                  "id": "gid://gitlab/WorkItem/24697619",
                  "title": "Pagination does not conform with button styling and interaction styling"
                },
                {
                  "id": "gid://gitlab/WorkItem/22693964",
                  "title": "Remove next and previous labels on mobile and smaller viewports for pagination component"
                },
                {
                  "id": "gid://gitlab/WorkItem/22308883",
                  "title": "Update pagination border and background colors according to the specs"
                },
                {
                  "id": "gid://gitlab/WorkItem/22294339",
                  "title": "Pagination \"active\" page contains gray border on right side"
                }
              ]
            },
            "parent": {
              "title": "Pajamas component: Pagination"
            },
            "__typename": "WorkItemWidgetHierarchy"
          },
          {
            "__typename": "WorkItemWidgetLabels"
          },
          {
            "discussions": {
              "nodes": [
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "changed the description",
                          "id": "gid://gitlab/Note/156548315",
                          "author": {
                            "name": "Sidney Jones"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "added ~10161862 label",
                          "id": "gid://gitlab/LabelNote/853dc8176d8eff789269d69c31c019ecd9918996",
                          "author": {
                            "name": "Jan Kowalski"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "mentioned in epic &997",
                          "id": "gid://gitlab/Note/164703873",
                          "author": {
                            "name": "Zhang Wei"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "added issue gitlab-ui#302",
                          "id": "gid://gitlab/Note/185977331",
                          "author": {
                            "name": "Alex Garcia"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "added issue gitlab-ui#304",
                          "id": "gid://gitlab/Note/185977335",
                          "author": {
                            "name": "Alex Garcia"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "added issue gitlab-ui#316",
                          "id": "gid://gitlab/Note/190661279",
                          "author": {
                            "name": "Alex Garcia"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "mentioned in issue gitlab-design#528",
                          "id": "gid://gitlab/Note/200228415",
                          "author": {
                            "name": "Jan Kowalski"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "notes": {
                    "edges": [
                      {
                        "node": {
                          "body": "added ~8547186 ~10161725 labels and removed ~10161862 label",
                          "id": "gid://gitlab/LabelNote/dfa79f5c4e6650850cc9e767f0dc0d3896bfd0f9",
                          "author": {
                            "name": "Sidney Jones"
                          }
                        }
                      }
                    ]
                  }
                }
              ]
            },
            "__typename": "WorkItemWidgetNotes"
          },
          {
            "dueDate": null,
            "isFixed": false,
            "startDate": null,
            "__typename": "WorkItemWidgetStartAndDueDate"
          },
          {
            "type": "HEALTH_STATUS",
            "healthStatus": null,
            "__typename": "WorkItemWidgetHealthStatus"
          },
          {
            "__typename": "WorkItemWidgetVerificationStatus"
          },
          {
            "__typename": "WorkItemWidgetNotifications"
          },
          {
            "downvotes": 0,
            "upvotes": 0,
            "awardEmoji": {
              "nodes": []
            },
            "__typename": "WorkItemWidgetAwardEmoji"
          },
          {
            "__typename": "WorkItemWidgetLinkedItems"
          },
          {
            "__typename": "WorkItemWidgetCurrentUserTodos"
          },
          {
            "__typename": "WorkItemWidgetRolledupDates"
          },
          {
            "__typename": "WorkItemWidgetParticipants"
          },
          {
            "__typename": "WorkItemWidgetWeight"
          },
          {
            "__typename": "WorkItemWidgetTimeTracking"
          },
          {
            "color": "#1068bf",
            "textColor": "#FFFFFF",
            "__typename": "WorkItemWidgetColor"
          }
        ]
      }
    }
  }
}
```

<a id="create-a-work-item-epic-with-widgets"></a>

#### 使用小部件创建工作项史诗

在 `input` 参数中使用小部件来创建或更新工作项。

例如，运行以下查询来创建一个具有以下属性的史诗：

- 标题
- 描述
- 颜色
- 健康状态
- 开始日期
- 截止日期
- 指派人

```graphql
mutation createEpicWithWidgets {
  workItemCreate(
    input: {
      title: "New work item epic"
      namespacePath: "gitlab-org"
      workItemTypeId: "gid://gitlab/WorkItems::Type/<WorkItemTypeID>"
      colorWidget: { color: "#e24329" }
      descriptionWidget: { description: "My new plans ..." }
      healthStatusWidget: { healthStatus: onTrack }
      startAndDueDateWidget: { startDate: "2024-10-12", dueDate: "2024-12-12", isFixed: true }
      assigneesWidget: { assigneeIds: "gid://gitlab/User/<UserID>" }
    }
  ) {
    workItem {
      id
      title
      description
      widgets {
        ... on WorkItemWidgetColor {
          color
          textColor
          __typename
        }
        ... on WorkItemWidgetAssignees {
          assignees {
            nodes {
              id
              name
            }
          }
          __typename
        }
        ... on WorkItemWidgetHealthStatus {
          healthStatus
          __typename
        }
        ... on WorkItemWidgetStartAndDueDate {
          startDate
          dueDate
          isFixed
          __typename
        }
      }
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "workItemCreate": {
      "workItem": {
        "id": "gid://gitlab/WorkItem/2252",
        "title": "New epic",
        "description": "My new plans ...",
        "widgets": [
          {
            "assignees": {
              "nodes": [
                {
                  "id": "gid://gitlab/User/46",
                  "name": "Jane Smith"
                }
              ]
            },
            "__typename": "WorkItemWidgetAssignees"
          },
          {
            "color": "#e24329",
            "textColor": "#FFFFFF",
            "__typename": "WorkItemWidgetColor"
          },
          {
            "healthStatus": "onTrack",
            "__typename": "WorkItemWidgetHealthStatus"
          },
          {
            "startDate": "2024-10-12",
            "dueDate": "2024-12-12",
            "isFixed": true,
            "__typename": "WorkItemWidgetStartAndDueDate"
          }
        ]
      }
    }
  }
}
```

<a id="update-a-work-item-epic-using-widgets"></a>

#### 使用小部件更新工作项史诗

要编辑工作项，可以重用[使用小部件创建工作项史诗](#create-a-work-item-epic-with-widgets)中的小部件输入，但改用 `workItemUpdate` 变更。

获取工作项的全局 ID（格式为 `gid://gitlab/WorkItem/<WorkItemID>`），并将其作为 `input` 的 `id` 使用：

```graphql
mutation updateEpicWorkItemWithWidgets {
  workItemUpdate(
    input: {
      id: "gid://gitlab/WorkItem/<WorkItemID>"
      title: "Updated work item epic title"
      colorWidget: { color: "#fc6d26" }
      descriptionWidget: { description: "My other new plans ..." }
      healthStatusWidget: { healthStatus: onTrack }
      startAndDueDateWidget: { startDate: "2025-10-12", dueDate: "2025-12-12", isFixed: true }
      assigneesWidget: { assigneeIds: "gid://gitlab/User/45" }
    }
  ) {
    workItem {
      id
      title
      description
      widgets {
        ... on WorkItemWidgetColor {
          color
          textColor
          __typename
        }
        ... on WorkItemWidgetAssignees {
          assignees {
            nodes {
              id
              name
            }
          }
          __typename
        }
        ... on WorkItemWidgetHealthStatus {
          healthStatus
          __typename
        }
        ... on WorkItemWidgetStartAndDueDate {
          startDate
          dueDate
          isFixed
          __typename
        }
      }
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "workItemUpdate": {
      "workItem": {
        "id": "gid://gitlab/WorkItem/2252",
        "title": "Updated work item epic title",
        "description": "My other new plans ...",
        "widgets": [
          {
            "assignees": {
              "nodes": [
                {
                  "id": "gid://gitlab/User/45",
                  "name": "Ardella Williamson"
                }
              ]
            },
            "__typename": "WorkItemWidgetAssignees"
          },
          {
            "color": "#fc6d26",
            "textColor": "#FFFFFF",
            "__typename": "WorkItemWidgetColor"
          },
          {
            "healthStatus": "onTrack",
            "__typename": "WorkItemWidgetHealthStatus"
          },
          {
            "startDate": "2025-10-12",
            "dueDate": "2025-12-12",
            "isFixed": true,
            "__typename": "WorkItemWidgetStartAndDueDate"
          }
        ]
      }
    }
  }
}
```

<a id="delete-an-epic-work-item"></a>

### 删除一个史诗工作项

要删除一个史诗工作项，使用 `workItemDelete` 变更：

```graphql
mutation deleteEpicWorkItem {
  workItemDelete(input: { id: "gid://gitlab/WorkItem/<WorkItemID>" }) {
    clientMutationId
    errors
    namespace {
      id
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "workItemDelete": {
      "clientMutationId": null,
      "errors": [],
      "namespace": {
        "id": "gid://gitlab/Group/24"
      }
    }
  }
}
```