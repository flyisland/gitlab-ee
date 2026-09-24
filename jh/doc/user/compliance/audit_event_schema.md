---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计事件架构与示例
---

<a id="audit-event-schema"></a>

## 审计事件架构

{{< history >}}

- 审计事件流架构的文档在极狐GitLab 15.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/358149)。

{{< /history >}}

审计事件在响应体中具有可预测的架构。

| 字段              | 描述                                                         | 备注                                                                                 | 仅流式字段           |
|-------------------|--------------------------------------------------------------|--------------------------------------------------------------------------------------|----------------------|
| `author_id`       | 触发事件的用户 ID                                            |                                                                                      | {{< no >}}           |
| `author_name`     | 触发事件的作者的可读名称                                     | 当作者不再存在时很有用                                                                | {{< yes >}}          |
| `created_at`      | 事件触发时的时间戳                                           |                                                                                      | {{< no >}}           |
| `details`         | 包含额外元数据的 JSON 对象                                   | 没有定义的架构，但通常包含有关事件的额外信息                                          | {{< no >}}           |
| `entity_id`       | 审计事件实体的 ID                                            |                                                                                      | {{< no >}}           |
| `entity_path`     | 受审计事件影响的实体的完整路径                               |                                                                                      | {{< yes >}}          |
| `entity_type`     | 实体类型的字符串表示                                         | 可接受的值包括 `User`、`Group` 和 `Key`。此列表并非详尽无遗                          | {{< no >}}           |
| `event_type`      | 审计事件类型的字符串表示                                     |                                                                                      | {{< yes >}}          |
| `id`              | 审计事件的唯一标识符                                         | 如果需要，可用于去重                                                                  | {{< no >}}           |
| `ip_address`      | 用于触发事件的主机的 IP 地址                                 |                                                                                      | {{< yes >}}          |
| `target_details`  | 有关目标的额外详细信息                                       |                                                                                      | {{< yes >}}          |
| `target_id`       | 审计事件目标的 ID                                            |                                                                                      | {{< yes >}}          |
| `target_type`     | 目标类型的字符串表示                                         |                                                                                      | {{< yes >}}          |

<a id="audit-event-json-schema"></a>

### 审计事件 JSON 架构

```json
{
  "properties": {
    "id": {
      "type": "string"
    },
    "author_id": {
      "type": "integer"
    },
    "author_name": {
      "type": "string"
    },
    "details": {},
    "ip_address": {
      "type": "string"
    },
    "entity_id": {
      "type": "integer"
    },
    "entity_path": {
      "type": "string"
    },
    "entity_type": {
      "type": "string"
    },
    "event_type": {
      "type": "string"
    },
    "target_id": {
      "type": "integer"
    },
    "target_type": {
      "type": "string"
    },
    "target_details": {
      "type": "string"
    },
  },
  "type": "object"
}
```

<a id="headers"></a>

### 标头

{{< history >}}

- `X-Gitlab-Audit-Event-Type` 在极狐GitLab 15.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/86881)。

{{< /history >}}

标头的格式如下：

```plaintext
POST /logs HTTP/1.1
主机: <DESTINATION_HOST>
内容类型: application/x-www-form-urlencoded
X-Gitlab-Event-Streaming-Token: <DESTINATION_TOKEN>
X-Gitlab-Audit-Event-Type: repository_git_operation
```

<a id="example-audit-event-streaming-on-git-operations"></a>

## 示例：Git 操作的审计事件流

当经过身份验证的用户推送、拉取或克隆项目的远程 Git 仓库时，可以发送流式审计事件：

- [使用 SSH](../ssh.md)。
- 使用 HTTP 或 HTTPS。
- 在极狐GitLab UI 中使用 **下载** ({{< icon name="download" >}})。

对于未登录的用户，不会捕获审计事件。例如，下载公开项目时。

<a id="example-audit-event-payloads-for-git-over-ssh-events-with-deploy-key"></a>

### 示例：使用部署密钥的 SSH Git 操作的审计事件负载

提取：

```json
{
  "id": "1",
  "author_id": -3,
  "entity_id": 29,
  "entity_type": "Project",
  "details": {
    "author_name": "deploy-key-name",
    "author_class": "DeployKey",
    "target_id": 29,
    "target_type": "Project",
    "target_details": "example-project",
    "custom_message": {
      "protocol": "ssh",
      "action": "git-upload-pack",
      "written_bytes": 1048576,
      "received_bytes": 2048
    },
    "ip_address": "127.0.0.1",
    "entity_path": "example-group/example-project"
  },
  "ip_address": "127.0.0.1",
  "author_name": "deploy-key-name",
  "entity_path": "example-group/example-project",
  "target_details": "example-project",
  "created_at": "2022-07-26T05:43:53.662Z",
  "target_type": "Project",
  "target_id": 29,
  "event_type": "repository_git_operation"
}
```

`custom_message` 对象包含 Git 操作的数据传输大小字段：

- `written_bytes`：在 Git 操作期间发送给客户端的字节数（例如，在克隆、提取或拉取期间）。
- `received_bytes`：在 Git 操作期间从客户端接收的字节数（例如，在推送期间）。

当没有字节传输时，这些字段会被省略，例如在交换任何数据之前请求失败的情况。