---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 获取极狐GitLab Duo 和 SDLC 趋势数据
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 GraphQL API 检索和导出极狐GitLab Duo 数据。

<a id="retrieve-ai-usage-data"></a>

## 检索 AI 使用数据

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.5 中引入了名为 `code_suggestions_usage_events_in_pg` 的功能标志。默认禁用。
- 功能标志 `move_ai_tracking_to_instrumentation_layer` 在极狐GitLab 17.7 中添加。默认禁用。
- 在极狐GitLab 17.8 中移除了对 `move_ai_tracking_to_instrumentation_layer` 的依赖。
- 功能标志 `code_suggestions_usage_events_in_pg` 在极狐GitLab 17.8 中移除。
- `AiUsageData` 的极狐GitLab Duo Enterprise 插件要求在极狐GitLab 18.7 中移除。

{{< /history >}}

`AiUsageData` 端点提供原始事件数据。它通过 `codeSuggestionEvents` 暴露 代码建议 相关事件，并通过 `all` 暴露所有原始事件数据。

> [!note]
> 在较早版本中使用 极狐GitLab Duo Pro 时，`AiUsageData` 端点会返回 `null` 而不报错。

你可以使用该端点将事件导入 BI 工具，或者编写脚本聚合极狐GitLab Duo 所有事件的数据、接受率和每个用户的指标。

对于未安装 ClickHouse 的客户，数据保留三个月。对于已配置 ClickHouse 的客户，目前没有数据保留策略。

`all` 和 `codeSuggestionEvents` 属性的最大日期范围是一个月。如果你需要跨多个月的数据，请分别查询每个月。

`all` 属性可通过 `startDate`、`endDate`、`events`、`userIds` 以及标准分页值进行过滤。

要查看正在跟踪的事件，你可以检查 [`ai_tracking.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/gitlab/tracking/ai_tracking.rb) 文件中声明的事件。

极狐GitLab Duo Chat 事件 (`request_duo_chat_response`) 不填充 `extras` 字段。
与 代码建议 事件不同，Chat 交互不携带语言或建议元数据。
Chat 事件的 `extras` 字段为空是正常行为。

<a id="for-projects-and-groups"></a>

### 针对项目与群组

例如，要检索 `gitlab-org` 群组中所有 代码建议 事件的使用数据：

```graphql
query {
  group(fullPath: "gitlab-org") {
    aiUsageData {
      codeSuggestionEvents(startDate: "2025-09-26") {
        nodes {
          event
          timestamp
          language
          suggestionSize
          user {
            username
          }
        }
      }
    }
  }
}
```

查询返回以下输出：

```graphql
{
  "data": {
    "group": {
      "aiUsageData": {
        "codeSuggestionEvents": {
          "nodes": [
            {
              "event": "CODE_SUGGESTION_SHOWN_IN_IDE",
              "timestamp": "2025-09-26T18:17:25Z",
              "language": "python",
              "suggestionSize": 2,
              "user": {
                "username": "jasbourne"
              }
            },
            {
              "event": "CODE_SUGGESTION_REJECTED_IN_IDE",
              "timestamp": "2025-09-26T18:13:45Z",
              "language": "python",
              "suggestionSize": 2,
              "user": {
                "username": "jasbourne"
              }
            },
            {
              "event": "CODE_SUGGESTION_ACCEPTED_IN_IDE",
              "timestamp": "2025-09-26T18:13:44Z",
              "language": "python",
              "suggestionSize": 2,
              "user": {
                "username": "jasbourne"
              }
            }
          ]
        }
      }
    }
  }
}
```

或者，要检索 `gitlab-org` 群组中所有 极狐GitLab Duo 事件的使用数据：

```graphql
query {
  group(fullPath: "gitlab-org") {
    aiUsageData {
      all(startDate: "2025-09-26") {
        nodes {
          event
          timestamp
          user {
            username
          }
        }
      }
    }
  }
}
```

查询返回以下输出：

```graphql
{
  "data": {
    "group": {
      "aiUsageData": {
        "all": {
          "nodes": [
            {
              "event": "FIND_NO_ISSUES_DUO_CODE_REVIEW_AFTER_REVIEW",
              "timestamp": "2025-09-26T18:17:25Z",
              "user": {
                "username": "jasbourne"
              }
            },
            {
              "event": "REQUEST_REVIEW_DUO_CODE_REVIEW_ON_MR_BY_AUTHOR",
              "timestamp": "2025-09-26T18:13:45Z",
              "user": {
                "username": "jasbourne"
              }
            },
            {
              "event": "AGENT_PLATFORM_SESSION_STARTED",
              "timestamp": "2025-09-26T18:13:44Z",
              "user": {
                "username": "jasbourne"
              }
            }
          ]
        }
      }
    }
  }
}
```

<a id="for-instances"></a>

### 针对实例

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.7 中引入。此功能为[实验性功能](../../policy/development_stages_support.md)。

{{< /history >}}

前置条件：

- 你必须是实例的管理员。

例如，要检索整个实例的所有 极狐GitLab Duo 使用事件：

```graphql
query {
  aiUsageData {
    all(startDate: "2025-09-26", endDate: "2025-09-30") {
      nodes {
        event
        timestamp
        user {
          username
        }
        extras
      }
    }
  }
}
```

查询返回以下输出：

```json
{
  "data": {
    "aiUsageData": {
      "all": {
        "nodes": [
          {
            "event": "CODE_SUGGESTION_SHOWN_IN_IDE",
            "timestamp": "2025-09-26T18:17:25Z",
            "user": {
              "username": "jasbourne"
            },
            "extras": {}
          },
          {
            "event": "AGENT_PLATFORM_SESSION_STARTED",
            "timestamp": "2025-09-26T18:13:44Z",
            "user": {
              "username": "johndoe"
            },
            "extras": {
              "session_id": "abc123"
            }
          }
        ]
      }
    }
  }
}
```

<a id="retrieve-ai-user-metrics"></a>

## 检索 AI 用户指标

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.6 中引入。
- 特定于功能的指标类型在极狐GitLab 18.7 中引入。

{{< /history >}}

`AiUserMetrics` 端点提供所有已注册的 极狐GitLab Duo 功能的每个用户预聚合指标，包括 代码建议、极狐GitLab Duo Chat、代码审核、Agent Platform、作业排障和模型上下文协议（MCP）工具调用。

你可以使用此端点来分析 极狐GitLab Duo 的用户参与度并衡量不同 极狐GitLab Duo 功能的使用频率。

前置条件：

- 你必须已配置 ClickHouse。

<a id="total-event-counts"></a>

### 事件总数

`AiUserMetrics` 端点提供以下级别的事件计数聚合：

- 顶层 `totalEventCount`：返回某个用户在所有 极狐GitLab Duo 功能上的所有事件计数总和。
- 功能级别 `totalEventCount`：在每个功能指标类型中可用，返回该特定功能的所有事件计数总和。

你可以使用这些字段在不同粒度级别上获取聚合计数。

例如，要同时检索顶层和功能级别总数：

```graphql
query {
  group(fullPath:"gitlab-org") {
    aiUserMetrics {
      nodes {
        user {
          username
        }
        totalEventCount
        codeSuggestions {
          totalEventCount
          codeSuggestionAcceptedInIdeEventCount
          codeSuggestionShownInIdeEventCount
        }
        chat {
          totalEventCount
          requestDuoChatResponseEventCount
        }
      }
    }
  }
}
```

查询返回以下输出：

```graphql
{
  "data": {
    "group": {
      "aiUserMetrics": {
        "nodes": [
          {
            "user": {
              "username": "USER_1"
            },
            "totalEventCount": 82,
            "codeSuggestions": {
              "totalEventCount": 60,
              "codeSuggestionAcceptedInIdeEventCount": 10,
              "codeSuggestionShownInIdeEventCount": 50
            },
            "chat": {
              "totalEventCount": 22,
              "requestDuoChatResponseEventCount": 22
            }
          },
          {
            "user": {
              "username": "USER_2"
            },
            "totalEventCount": 102,
            "codeSuggestions": {
              "totalEventCount": 72,
              "codeSuggestionAcceptedInIdeEventCount": 12,
              "codeSuggestionShownInIdeEventCount": 60
            },
            "chat": {
              "totalEventCount": 30,
              "requestDuoChatResponseEventCount": 30
            }
          }
        ]
      }
    }
  }
}
```

在此示例中：

- 顶层的 `totalEventCount`（USER_1 为 82）是所有功能中所有事件的总和。
- 每个功能的 `totalEventCount` 仅表示该功能范围内事件的总和。
  - 代码建议：60 个事件（10 个已接受 + 50 个已展示）
  - Chat：22 个事件

<a id="feature-specific-metric-types"></a>

### 特定于功能的指标类型

`AiUserMetrics` 端点通过特定于功能的嵌套类型提供详细指标。每个 极狐GitLab Duo 功能都有自己专用的指标类型，该类型暴露与该功能相关的所有已跟踪事件的事件计数字段。

可用的功能指标类型包括：

- `codeSuggestions`：代码建议 特定指标
- `chat`：极狐GitLab Duo Chat 特定指标
- `codeReview`：代码审核 特定指标
- `agentPlatform`：Agent Platform 特定指标（包括 Agent 模式 Chat 会话）
- `troubleshootJob`：作业排障 特定指标
- `mcp`：模型上下文协议（MCP）工具调用指标

每个功能指标类型都包括：

- 该功能所有已跟踪事件的每个事件计数字段
- 一个汇总该特定功能所有事件的 `totalEventCount` 字段

可用的事件计数字段根据系统中注册的事件动态生成。要查看每个功能跟踪的事件，请检查 [`ai_tracking.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/gitlab/tracking/ai_tracking.rb) 文件中声明的事件。

例如，要检索多个 极狐GitLab Duo 功能的详细指标：

```graphql
query {
  group(fullPath:"gitlab-org") {
    aiUserMetrics {
      nodes {
        user {
          username
        }
        codeSuggestions {
          totalEventCount
          codeSuggestionAcceptedInIdeEventCount
          codeSuggestionShownInIdeEventCount
        }
        chat {
          totalEventCount
          requestDuoChatResponseEventCount
        }
        codeReview {
          totalEventCount
          requestReviewDuoCodeReviewOnMrByAuthorEventCount
          findNoIssuesDuoCodeReviewAfterReviewEventCount
        }
        agentPlatform {
          totalEventCount
          agentPlatformSessionStartedEventCount
          agentPlatformSessionFinishedEventCount
        }
      }
    }
  }
}
```

查询返回以下输出：

```graphql
{
  "data": {
    "group": {
      "aiUserMetrics": {
        "nodes": [
          {
            "user": {
              "username": "USER_1"
            },
            "codeSuggestions": {
              "totalEventCount": 60,
              "codeSuggestionAcceptedInIdeEventCount": 10,
              "codeSuggestionShownInIdeEventCount": 50
            },
            "chat": {
              "totalEventCount": 22,
              "requestDuoChatResponseEventCount": 22
            },
            "codeReview": {
              "totalEventCount": 8,
              "requestReviewDuoCodeReviewOnMrByAuthorEventCount": 5,
              "findNoIssuesDuoCodeReviewAfterReviewEventCount": 3
            },
            "agentPlatform": {
              "totalEventCount": 15,
              "agentPlatformSessionStartedEventCount": 8,
              "agentPlatformSessionFinishedEventCount": 7
            }
          },
          {
            "user": {
              "username": "USER_2"
            },
            "codeSuggestions": {
              "totalEventCount": 72,
              "codeSuggestionAcceptedInIdeEventCount": 12,
              "codeSuggestionShownInIdeEventCount": 60
            },
            "chat": {
              "totalEventCount": 30,
              "requestDuoChatResponseEventCount": 30
            },
            "codeReview": {
              "totalEventCount": 5,
              "requestReviewDuoCodeReviewOnMrByAuthorEventCount": 3,
              "findNoIssuesDuoCodeReviewAfterReviewEventCount": 2
            },
            "agentPlatform": {
              "totalEventCount": 20,
              "agentPlatformSessionStartedEventCount": 12,
              "agentPlatformSessionFinishedEventCount": 8
            }
          }
        ]
      }
    }
  }
}
```

<a id="retrieve-gitlab-duo-and-sdlc-trend-metrics"></a>

## 检索极狐GitLab Duo 和 SDLC 趋势指标

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.11 中引入。
- 插件要求从 GitLab Duo Enterprise 变更为极狐GitLab Duo Pro 在极狐GitLab 17.6 中。
- 插件要求在极狐GitLab 18.7 中移除。

{{< /history >}}

`AiMetrics` 端点支持极狐GitLab Duo 和 SDLC 趋势仪表板，并提供以下 代码建议 和 极狐GitLab Duo Chat 的预聚合指标：

- `codeSuggestionsShown`
- `codeSuggestionsAccepted`
- `codeSuggestionAcceptanceRate`
- `codeSuggestionUsers`
- `duoChatUsers`

前置条件：

- 你必须已配置 ClickHouse。

例如，要检索 `gitlab-org` 群组在指定时间段内的 代码建议 和 极狐GitLab Duo Chat 使用数据：

```graphql
query {
  group(fullPath: "gitlab-org") {
    aiMetrics(startDate: "2024-12-01", endDate: "2024-12-31") {
      codeSuggestions{
        shownCount
        acceptedCount
        acceptedLinesOfCode
        shownLinesOfCode
      }
      codeContributorsCount
      duoChatContributorsCount
      duoUsedCount
    }
  }
}
```

查询返回以下输出：

```graphql
{
  "data": {
    "group": {
      "aiMetrics": {
        "codeSuggestions": {
          "shownCount": 88728,
          "acceptedCount": 7016,
          "acceptedLinesOfCode": 9334,
          "shownLinesOfCode": 124118
        },
        "codeContributorsCount": 719,
        "duoChatContributorsCount": 681,
        "duoUsedCount": 714
      }
    }
  },
}
```

<a id="export-ai-metrics-data-to-csv"></a>

## 导出 AI 指标数据到 CSV

你可以使用
[极狐GitLab AI Metrics Exporter 工具](https://gitlab.com/smathur/custom-duo-metrics)将 AI 指标数据导出到 CSV 文件。