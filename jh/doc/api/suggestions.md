---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 建议更改 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[代码建议](../user/project/merge_requests/reviews/suggestions.md)。

建议提供了一种提出可直接影响代码的特定更改的方式。您可以使用此 API 在合并请求讨论中程序化地创建和应用代码建议。对建议的每个 API 调用都必须经过认证。

<a id="create-a-suggestion"></a>

## 创建建议

要通过 API 创建建议，使用讨论 API [在合并请求差异中创建新讨论串](discussions.md#create-a-merge-request-thread)。建议的格式为：

````markdown
```suggestion:-3+0
示例文本
```
````

<a id="apply-a-suggestion"></a>

## 应用建议

在合并请求中应用建议补丁。

前提条件：

- 用户必须具有开发者、维护者或所有者角色。

```plaintext
PUT /suggestions/:id/apply
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|------------------|---------|----------|-------------|
| `id` | 整数 | 是 | 建议的 ID。 |
| `commit_message` | 字符串 | 否 | 要使用的自定义提交消息，替代默认生成的消息或项目的默认消息。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|----------------|---------|-------------|
| `applicable` | 布尔值 | 如果为 `true`，建议可以应用。 |
| `applied` | 布尔值 | 如果为 `true`，建议已经应用。 |
| `from_content` | 字符串 | 建议之前的原始内容。 |
| `from_line` | 整数 | 建议的起始行号。 |
| `id` | 整数 | 建议的 ID。 |
| `to_content` | 字符串 | 替换原始内容的建议内容。 |
| `to_line` | 整数 | 建议的结束行号。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/suggestions/5/apply"
```

示例响应：

```json
{
  "id": 5,
  "from_line": 10,
  "to_line": 10,
  "applicable": true,
  "applied": false,
  "from_content": "这是一个示例\n",
  "to_content": "这是一个示例\n"
}
```

<a id="apply-multiple-suggestions"></a>

## 应用多个建议

在合并请求中应用多个建议补丁。

前提条件：

- 用户必须具有开发者、维护者或所有者角色。

```plaintext
PUT /suggestions/batch_apply
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|------------------|---------------|----------|-------------|
| `ids` | 整数数组 | 是 | 要应用的建议 ID。 |
| `commit_message` | 字符串 | 否 | 要使用的自定义提交消息，替代默认生成的消息或项目的默认消息。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和建议对象数组，包含以下响应属性：

| 属性 | 类型 | 描述 |
|----------------|---------|-------------|
| `applicable` | 布尔值 | 如果为 `true`，建议可以应用。 |
| `applied` | 布尔值 | 如果为 `true`，建议已经应用。 |
| `from_content` | 字符串 | 建议之前的原始内容。 |
| `from_line` | 整数 | 建议的起始行号。 |
| `id` | 整数 | 建议的 ID。 |
| `to_content` | 字符串 | 替换原始内容的建议内容。 |
| `to_line` | 整数 | 建议的结束行号。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"ids": [5, 6]}' \
  --url "https://gitlab.example.com/api/v4/suggestions/batch_apply"
```

示例响应：

```json
[
  {
    "id": 5,
    "from_line": 10,
    "to_line": 10,
    "applicable": true,
    "applied": false,
    "from_content": "这是一个示例\n",
    "to_content": "这是一个示例\n"
  },
  {
    "id": 6,
    "from_line": 19,
    "to_line": 19,
    "applicable": true,
    "applied": false,
    "from_content": "这是另一个示例\n",
    "to_content": "这是另一个示例\n"
  }
]
```
