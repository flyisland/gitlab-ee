---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for GitLab Duo Chat.
title: 极狐GitLab Duo Chat 补全 API
---

此 API 用于为 [极狐GitLab Duo Chat](../user/gitlab_duo_chat/_index.md) 生成回复：

- 在 JihuLab.com 上，此 API 仅供内部使用。
- 在私有化部署实例上，您可以通过名为 `access_rest_chat` 的 [功能标志](../administration/feature_flags/_index.md) 启用此 API。

先决条件：

- 您必须是 [极狐GitLab 团队成员](https://gitlab.com/groups/gitlab-com/-/group_members)。

<a id="generate-a-chat-response"></a>

## 生成 Chat 回复

为极狐GitLab Duo Chat 问题生成回复。

{{< history >}}

- 在极狐GitLab 16.7 中引入，并通过功能标志 `access_rest_chat` 控制。默认禁用。此功能仅供内部使用。
- `additional_context` 参数在极狐GitLab 17.4 中添加，并通过功能标志 `duo_additional_context` 控制。默认禁用。此功能仅供内部使用。
- `additional_context` 参数在极狐GitLab 17.9 中已在 JihuLab.com 和私有化部署实例上启用。
- `additional_context` 参数在极狐GitLab 18.0 中 GA。功能标志 `duo_additional_context` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。更多信息，请参见历史记录。

```plaintext
POST /chat/completions
```

> [!note]
> 发往此端点的请求会被代理到 [AI 网关](https://jihulab.com/gitlab-cn/modelops/applied-ml/code-suggestions/ai-assist/-/blob/main/docs/api.md)。

支持的属性：

| 属性                    | 类型            | 是否必需 | 描述                                                             |
|--------------------------|-----------------|----------|-------------------------------------------------------------------------|
| `content`                | string          | 是      | 发送给 Chat 的问题。                                                  |
| `resource_type`          | string          | 否       | 随 Chat 问题发送的资源类型。                       |
| `resource_id`            | string, integer | 否       | 资源的 ID。可以是资源 ID（整型）或提交哈希（字符串）。 |
| `referer_url`            | string          | 否       | Referer URL。                                                            |
| `client_subscription_id` | string          | 否       | 客户端订阅 ID。                                                 |
| `with_clean_history`     | boolean         | 否       | 指示在请求前后是否应重置历史记录。 |
| `project_id`             | integer         | 否       | 项目 ID。如果 `resource_type` 为 commit 时必填。                    |
| `additional_context`     | array           | 否       | 此次 Chat 请求的附加上下文项数组。有关此属性接受的参数列表，请参见 [上下文属性](#context-attributes)。 |

<a id="context-attributes"></a>

### 上下文属性

`context` 属性接受具有以下属性的元素列表：

- `category` - 上下文元素的类别。有效值为 `file`、`merge_request`、`issue` 或 `snippet`。
- `id` - 上下文元素的 ID。
- `content` - 上下文元素的内容。取值取决于上下文元素的类别。
- `metadata` - 此上下文元素的可选附加元数据。取值取决于上下文元素的类别。

示例请求：

```shell
curl --request POST \
  --header "Authorization: Bearer <YOUR_ACCESS_TOKEN>" \
  --header "Content-Type: application/json" \
  --data '{
      "content": "如何在 Ruby 中定义类",
      "additional_context": [
        {
          "category": "file",
          "id": "main.rb",
          "content": "class Foo\nend"
        }
      ]
    }' \
  --url "https://gitlab.example.com/api/v4/chat/completions"
```

示例响应：

```json
"在 Ruby 中定义类..."
```