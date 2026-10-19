---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计事件架构与示例
---

<a id="audit-event-schema"></a>

## 审计事件架构

审计事件在响应正文中具有可预测的架构。

| 字段            | 描述                                                | 说明                                                                             | 仅流式传输字段 |
|------------------|------------------------------------------------------------|-----------------------------------------------------------------------------------|----------------------|
| `author_id`      | 触发该事件的用户的用户 ID                |                                                                                   | {{< no >}}           |
| `author_name`    | 触发该事件的作者的可读名称 | 当作者已不存在时很有用                                          | {{< yes >}}          |
| `created_at`     | 触发事件时的时间戳                         |                                                                                   | {{< no >}}           |
| `details`        | 包含附加元数据的 JSON 对象                 | 没有定义的架构，但通常包含有关事件的附加信息    | {{< no >}}           |
| `entity_id`      | 审计事件实体的 ID                             |                                                                                   | {{< no >}}           |
| `entity_path`    | 受可审计事件影响的实体的完整路径    |                                                                                   | {{< yes >}}          |
| `entity_type`    | 实体类型的字符串表示                | 可接受的值包括 `User`、`Group` 和 `Key`。此列表并非详尽无遗 | {{< no >}}           |
| `event_type`     | 审计事件类型的字符串表示           |                                                                                   | {{< yes >}}          |
| `id`             | 审计事件的唯一标识符                      | 如有需要，可用于去重                                         | {{< no >}}           |
| `ip_address`     | 用于触发事件的主机的 IP 地址           |                                                                                   | {{< yes >}}          |
| `target_details` | 有关目标的附加详细信息                        |                                                                                   | {{< yes >}}          |
| `target_id`      | 审计事件目标的 ID                             |                                                                                   | {{< yes >}}          |
| `target_type`    | 目标类型的字符串表示                 |                                                                                   | {{< yes >}}          |

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

<a id="gitlab-duo-related-events"></a>

### 极狐GitLab Duo 相关事件

当审计事件与极狐GitLab Duo Agent Platform 相关时，`details` 对象
会包含一个设置为 `true`的 `duo_related` 字段。

以下事件可以包含此字段：

| 事件类型                    | 描述                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| `application_setting_updated` | 与极狐GitLab Duo Agent Platform 相关的应用设置被更新。 |
| `member_destroyed`            | 极狐GitLab Duo Agent Platform 服务账号的成员资格被移除。   |

使用此字段可在您的安全信息和事件管理（SIEM）工具或其他外部工具中识别极狐GitLab Duo Agent Platform 活动，而无需依赖服务账号命名模式。

<a id="events-created-with-a-composite-identity"></a>

### 使用复合身份创建的事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当服务账号代表人类用户通过[复合身份](../duo_agent_platform/composite_identity.md)执行操作时，审计事件会归属于该服务账号：

- `author_id` 包含该服务账号的用户 ID。
- `author_name` 包含 `<service account name> on behalf of @<human username>`，截断为
  255 个字符。此值会显示在审计事件页面的 **作者** 列以及 CSV 导出中。

`details` 对象记录授权该操作的人类用户：

| 字段                   | 描述                     |
|-------------------------|---------------------------------|
| `human_author_id`       | 人类用户的用户 ID       |
| `human_author_name`     | 人类用户的名称          |
| `human_author_username` | 人类用户的用户名      |

这些字段包含在流式审计事件中，以及[审计事件 API](../../api/audit_events.md) 返回的 `details` 对象中。

对于这些事件，`details` 对象中的 `author_class` 字段包含 `Gitlab::Audit::CompositeIdentityAuthor`。使用此值可在您的 SIEM 或其他外部工具中识别复合身份事件。

AI Agent 会话事件（例如 `ai_agent_session_started` 和 `ai_tool_invoked`）也会记录 `human_author_*` 字段，但不使用此 `author_class` 值。要匹配这两类事件，请改为根据是否存在 `human_author_id` 进行筛选。

当人类用户执行操作而服务账号仅参与该操作时，例如当人类用户将服务账号指派为合并请求审核人时，审计事件会归属于该人类用户，并且不会添加 `human_author_*` 字段。

<a id="headers"></a>

### 请求头

请求头的格式如下：

```plaintext
POST /logs HTTP/1.1
Host: <DESTINATION_HOST>
Content-Type: application/x-www-form-urlencoded
X-Gitlab-Event-Streaming-Token: <DESTINATION_TOKEN>
X-Gitlab-Audit-Event-Type: repository_git_operation
```

<a id="example-audit-event-streaming-on-git-operations"></a>

## 示例：Git 操作上的审计事件流式传输

当已认证用户推送、拉取或克隆项目的远程 Git 代码仓库时，可以发送流式审计事件：

- [使用 SSH](../ssh.md)。
- 使用 HTTP 或 HTTPS。
- 使用极狐GitLab UI 中的 **下载**（{{< icon name="download" >}}）。

不会为未登录的用户捕获审计事件。例如，下载公开项目时。

<a id="example-audit-event-payloads-for-git-over-ssh-events-with-deploy-key"></a>

### 示例：使用部署密钥的 Git over SSH 事件的审计事件负载

获取：

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
      "received_bytes": 2048,
      "gl_key_type": "deploy_key",
      "gl_key_id": 24
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

- `written_bytes`：Git 操作期间（例如在克隆、获取或拉取期间）发送到客户端的字节数。
- `received_bytes`：Git 操作期间（例如在推送期间）从客户端接收的字节数。

当没有传输任何字节时会省略这些字段，例如请求在任何数据交换之前就失败时。

`custom_message` 对象包含使用 SSH 密钥或部署密钥进行身份验证的 Git 操作的关键信息：

- `gl_key_type`：用于身份验证的密钥类型。用户 SSH 密钥为 `key`，部署密钥为 `deploy_key`。
- `gl_key_id`：用于身份验证的密钥的 ID。

当操作未使用密钥进行身份验证时会省略这些字段，例如使用用户名和密码的 HTTP(S)，或部署令牌。
