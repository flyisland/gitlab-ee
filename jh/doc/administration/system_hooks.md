---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 系统钩子
description: "使用系统钩子从极狐GitLab 事件触发 HTTP POST 请求。包含 JSON 负载示例。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当特定事件发生时，系统钩子会向外部 URL 发送 HTTP POST 请求，或在服务器上运行本地脚本。

与项目 webhook 不同，系统钩子监控的是整个极狐GitLab 实例中的事件，而不仅仅是单个项目。这些钩子会捕获用户创建、项目和群组变更，以及来自任意项目的代码仓库推送等事件。

<a id="triggered-events"></a>

## 触发的事件

| 事件类型                                | 触发条件 |
|-------------------------------------------|---------|
| `group_create`                            | 创建群组。 |
| `group_destroy`                           | 删除群组。 |
| `group_rename`                            | 群组路径或名称发生变化。 |
| `key_create`                              | 创建 SSH 密钥。 |
| `key_destroy`                             | 删除 SSH 密钥。 |
| `project_create`                          | 创建项目。 |
| `project_destroy`                         | 删除项目。 |
| `project_rename`                          | 项目路径或名称发生变化。 |
| `project_transfer`                        | 项目被转移到新的命名空间。 |
| `project_update`                          | 项目属性发生变化（项目路径除外）。 |
| `repository_update`                       | 推送中包含标签或多个分支。 |
| `user_access_request_revoked_for_group`   | 用户对群组的访问请求被取消。 |
| `user_access_request_revoked_for_project` | 用户对项目的访问请求被取消。 |
| `user_access_request_to_group`            | 用户请求访问群组。 |
| `user_access_request_to_project`          | 用户请求访问项目。 |
| `user_add_to_group`                       | 用户被添加为群组成员。 |
| `user_add_to_team`                        | 用户被添加为项目成员。 |
| `user_create`                             | 创建用户账号。 |
| `user_destroy`                            | 删除用户账号。 |
| `user_failed_login`                       | 被阻止的用户尝试登录。 |
| `user_remove_from_group`                  | 用户被从群组中删除。 |
| `user_remove_from_team`                   | 用户被从项目中删除。 |
| `user_rename`                             | 用户的用户名发生变化。 |
| `user_update_for_group`                   | 群组成员的角色发生变化。 |
| `user_update_for_team`                    | 项目成员的角色发生变化。 |
| `gitlab_subscription_member_approval`     | 请求角色提升（`"action": "enqueue"`）。 |
| `gitlab_subscription_member_approvals`    | 角色提升被批准（`"action": "approve"`）或被拒绝（`"action": "deny"`）。 |
| `push`                                    | 向代码仓库进行推送（标签除外）。 |
| `tag_push`                                | 添加或删除标签。 |
| `merge_request`                           | 创建、更新、合并或关闭合并请求。 |

> [!note]
> 对于推送和标签事件，遵循与
> [项目和群组 webhook](../user/project/integrations/webhooks.md) 相同的结构和弃用规则。
> 但提交记录从不显示。

<a id="create-a-system-hook"></a>

## 创建系统钩子

先决条件：

- 管理员访问权限。

创建系统钩子：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**系统钩子**。
1. 选择**添加新 webhook**。
1. 在 **URL**中，输入 webhook 端点的 URL。
   特殊字符请使用百分号编码。
1. 可选。在**名称**文本框中，输入 webhook 的名称。
1. 可选。在**描述**文本框中，输入 webhook 的描述。
1. 可选。在**密钥令牌**文本框中，输入用于验证请求的密钥令牌。

   该令牌会随 webhook 请求通过 `X-Gitlab-Token` HTTP 请求头发送。
   您的 webhook 端点可以使用此令牌来验证请求的合法性。

1. 可选。要遮盖 URL 中的敏感部分，请选择**添加 URL 遮盖**。
   更多信息，请参阅[遮盖系统钩子 URL 的敏感部分](#mask-sensitive-portions-of-system-hook-urls)。
1. 可选。要为外部服务添加身份验证请求头，请选择**添加自定义请求头**。
   更多信息，请参阅[自定义请求头](#custom-headers)。
1. 在**触发器**部分，为您希望触发该钩子的每个极狐GitLab
   [事件](#optional-triggers)选中复选框。
1. 可选。设置**自定义 webhook 模板**以控制请求正文。
   更多信息，请参阅[自定义 webhook 模板](#custom-webhook-template)。
1. 可选。清除**启用 SSL 验证**复选框
   以禁用 [SSL 验证](../user/project/integrations/_index.md#ssl-verification)。
1. 选择**添加系统钩子**。

<a id="mask-sensitive-portions-of-system-hook-urls"></a>

### 遮盖系统钩子 URL 的敏感部分

系统钩子 URL 敏感部分的遮盖方式与项目和群组 webhook 相同。URL 中被遮盖的部分会：

- 在钩子执行时替换为配置的值。
- 不记录到日志。
- 在数据库中静态加密。

有关配置的更多信息，请参阅项目和群组文档中的
[遮盖 webhook URL 的敏感部分](../user/project/integrations/webhooks.md#mask-sensitive-portions-of-webhook-urls)。

<a id="custom-headers"></a>

### 自定义请求头

系统钩子的自定义请求头与项目和群组 webhook 的工作方式相同。每个钩子最多可配置 20 个自定义请求头。自定义请求头会在**最近事件**中显示，其值会被遮盖。

有关请求头的要求，请参阅项目和群组文档中的[自定义请求头](../user/project/integrations/webhooks.md#custom-headers)。

<a id="optional-triggers"></a>

### 可选触发器

系统钩子会在[支持的事件](#triggered-events)（例如用户和群组生命周期变更）上自动触发。您还可以启用以下可选触发器：

| 触发器                      | 描述 |
|:-----------------------------|:------------|
| **代码仓库更新事件** | 包含标签或多个分支的推送。 |
| **推送事件**              | 向任意分支的推送。 |
| **标签推送事件**          | 添加或删除标签。 |
| **合并请求事件**     | 创建、更新、合并或关闭合并请求。 |

<a id="filter-push-events-by-branch"></a>

#### 按分支筛选推送事件

按分支筛选推送事件的方式与项目和群组 webhook 相同。更多信息，请参阅项目和群组文档中的[按分支筛选推送事件](../user/project/integrations/webhooks.md#filter-push-events-by-branch)。

<a id="custom-webhook-template"></a>

### 自定义 webhook 模板

自定义 webhook 模板与项目和群组 webhook 的工作方式相同。有关用法和示例，请参阅项目和群组文档中的[自定义 webhook 模板](../user/project/integrations/webhooks.md#custom-webhook-template)。

<a id="system-hook-limits"></a>

## 系统钩子限制

系统钩子受与项目 webhook 相同的推送事件限制约束。默认情况下，当单次推送包含超过 3 个分支或标签时，系统钩子不会被触发。

此限制由 `push_event_hooks_limit` 设置控制（默认值：`3`）。对于极狐GitLab 私有化部署实例，管理员可以使用[应用设置 API](../api/settings.md#available-settings) 修改此限制。

<a id="hooks-request-example"></a>

## 钩子请求示例

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

创建项目：

```json
{
            "created_at": "2012-07-21T07:30:54Z",
            "updated_at": "2012-07-21T07:38:22Z",
            "event_name": "project_create",
                  "name": "StoreCloud",
           "owner_email": "johnsmith@example.com",
            "owner_name": "John Smith",
                "owners": [{
                           "name": "John",
                           "email": "user1@example.com"
                          }],
                  "path": "storecloud",
   "path_with_namespace": "jsmith/storecloud",
            "project_id": 74,
 "project_namespace_id" : 23,
    "project_visibility": "private"
}
```

删除项目：

```json
{
            "created_at": "2012-07-21T07:30:58Z",
            "updated_at": "2012-07-21T07:38:22Z",
            "event_name": "project_destroy",
                  "name": "Underscore",
           "owner_email": "johnsmith@example.com",
            "owner_name": "John Smith",
                "owners": [{
                           "name": "John",
                           "email": "user1@example.com"
                          }],
                  "path": "underscore",
   "path_with_namespace": "jsmith/underscore",
            "project_id": 73,
 "project_namespace_id" : 23,
    "project_visibility": "internal"
}
```

重命名项目：

```json
{
               "created_at": "2012-07-21T07:30:58Z",
               "updated_at": "2012-07-21T07:38:22Z",
               "event_name": "project_rename",
                     "name": "Underscore",
                     "path": "underscore",
      "path_with_namespace": "jsmith/underscore",
               "project_id": 73,
               "owner_name": "John Smith",
              "owner_email": "johnsmith@example.com",
                   "owners": [{
                              "name": "John",
                              "email": "user1@example.com"
                             }],
    "project_namespace_id" : 23,
       "project_visibility": "internal",
  "old_path_with_namespace": "jsmith/overscore"
}
```

如果命名空间发生变化，则不会触发 `project_rename`。这种情况请参考 `group_rename` 和 `user_rename`。

转移项目：

```json
{
               "created_at": "2012-07-21T07:30:58Z",
               "updated_at": "2012-07-21T07:38:22Z",
               "event_name": "project_transfer",
                     "name": "Underscore",
                     "path": "underscore",
      "path_with_namespace": "scores/underscore",
               "project_id": 73,
               "owner_name": "John Smith",
              "owner_email": "johnsmith@example.com",
                   "owners": [{
                              "name": "John",
                              "email": "user1@example.com"
                             }],
    "project_namespace_id" : 23,
       "project_visibility": "internal",
  "old_path_with_namespace": "jsmith/overscore"
}
```

更新项目：

```json
{
            "created_at": "2012-07-21T07:30:54Z",
            "updated_at": "2012-07-21T07:38:22Z",
            "event_name": "project_update",
                  "name": "StoreCloud",
           "owner_email": "johnsmith@example.com",
            "owner_name": "John Smith",
                "owners": [{
                           "name": "John",
                           "email": "user1@example.com"
                          }],
                  "path": "storecloud",
   "path_with_namespace": "jsmith/storecloud",
            "project_id": 74,
 "project_namespace_id" : 23,
    "project_visibility": "private"
}
```

移除群组访问请求：

```json
{
    "created_at": "2012-07-21T07:30:56Z",
    "updated_at": "2012-07-21T07:38:22Z",
    "event_name": "user_access_request_revoked_for_group",
  "group_access": "Maintainer",
      "group_id": 78,
    "group_name": "StoreCloud",
    "group_path": "storecloud",
    "user_email": "johnsmith@example.com",
     "user_name": "John Smith",
 "user_username": "johnsmith",
       "user_id": 41
}
```

移除项目访问请求：

```json
{
                  "created_at": "2012-07-21T07:30:56Z",
                  "updated_at": "2012-07-21T07:38:22Z",
                  "event_name": "user_access_request_revoked_for_project",
                "access_level": "Maintainer",
                  "project_id": 74,
                "project_name": "StoreCloud",
                "project_path": "storecloud",
 "project_path_with_namespace": "jsmith/storecloud",
                  "user_email": "johnsmith@example.com",
                   "user_name": "John Smith",
               "user_username": "johnsmith",
                     "user_id": 41,
          "project_visibility": "private"
}
```

创建群组访问请求：

```json
{
    "created_at": "2012-07-21T07:30:56Z",
    "updated_at": "2012-07-21T07:38:22Z",
    "event_name": "user_access_request_to_group",
  "group_access": "Maintainer",
      "group_id": 78,
    "group_name": "StoreCloud",
    "group_path": "storecloud",
    "user_email": "johnsmith@example.com",
     "user_name": "John Smith",
 "user_username": "johnsmith",
       "user_id": 41
}
```

创建项目访问请求：

```json
{
                  "created_at": "2012-07-21T07:30:56Z",
                  "updated_at": "2012-07-21T07:38:22Z",
                  "event_name": "user_access_request_to_project",
                "access_level": "Maintainer",
                  "project_id": 74,
                "project_name": "StoreCloud",
                "project_path": "storecloud",
 "project_path_with_namespace": "jsmith/storecloud",
                  "user_email": "johnsmith@example.com",
                   "user_name": "John Smith",
               "user_username": "johnsmith",
                     "user_id": 41,
          "project_visibility": "private"
}
```

新团队成员：

```json
{
                  "created_at": "2012-07-21T07:30:56Z",
                  "updated_at": "2012-07-21T07:38:22Z",
                  "event_name": "user_add_to_team",
                "access_level": "Maintainer",
                  "project_id": 74,
                "project_name": "StoreCloud",
                "project_path": "storecloud",
 "project_path_with_namespace": "jsmith/storecloud",
                  "user_email": "johnsmith@example.com",
                   "user_name": "John Smith",
               "user_username": "johnsmith",
                     "user_id": 41,
          "project_visibility": "private"
}
```

移除团队成员：

```json
{
                  "created_at": "2012-07-21T07:30:56Z",
                  "updated_at": "2012-07-21T07:38:22Z",
                  "event_name": "user_remove_from_team",
                "access_level": "Maintainer",
                  "project_id": 74,
                "project_name": "StoreCloud",
                "project_path": "storecloud",
 "project_path_with_namespace": "jsmith/storecloud",
                  "user_email": "johnsmith@example.com",
                   "user_name": "John Smith",
               "user_username": "johnsmith",
                     "user_id": 41,
          "project_visibility": "private"
}
```

更新团队成员：

```json
{
                  "created_at": "2012-07-21T07:30:56Z",
                  "updated_at": "2012-07-21T07:38:22Z",
                  "event_name": "user_update_for_team",
                "access_level": "Maintainer",
                  "project_id": 74,
                "project_name": "StoreCloud",
                "project_path": "storecloud",
 "project_path_with_namespace": "jsmith/storecloud",
                  "user_email": "johnsmith@example.com",
                   "user_name": "John Smith",
               "user_username": "johnsmith",
                     "user_id": 41,
          "project_visibility": "private"
}
```

创建用户：

```json
{
   "created_at": "2012-07-21T07:44:07Z",
   "updated_at": "2012-07-21T07:38:22Z",
        "email": "js@gitlabhq.com",
   "event_name": "user_create",
         "name": "John Smith",
     "username": "js",
      "user_id": 41
}
```

删除用户：

```json
{
   "created_at": "2012-07-21T07:44:07Z",
   "updated_at": "2012-07-21T07:38:22Z",
        "email": "js@gitlabhq.com",
   "event_name": "user_destroy",
         "name": "John Smith",
     "username": "js",
      "user_id": 41
}
```

用户登录失败：

```json
{
  "event_name": "user_failed_login",
  "created_at": "2017-10-03T06:08:48Z",
  "updated_at": "2018-01-15T04:52:06Z",
        "name": "John Smith",
       "email": "user4@example.com",
     "user_id": 26,
    "username": "user4",
       "state": "blocked"
}
```

如果用户通过 LDAP 被阻止，则 `state` 为 `ldap_blocked`。

重命名用户：

```json
{
    "event_name": "user_rename",
    "created_at": "2017-11-01T11:21:04Z",
    "updated_at": "2017-11-01T14:04:47Z",
          "name": "new-name",
         "email": "best-email@example.tld",
       "user_id": 58,
      "username": "new-exciting-name",
  "old_username": "old-boring-name"
}
```

添加密钥：

```json
{
    "event_name": "key_create",
    "created_at": "2014-08-18 18:45:16 UTC",
    "updated_at": "2012-07-21T07:38:22Z",
      "username": "root",
           "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC58FwqHUbebw2SdT7SP4FxZ0w+lAO/erhy2ylhlcW/tZ3GY3mBu9VeeiSGoGz8hCx80Zrz+aQv28xfFfKlC8XQFpCWwsnWnQqO2Lv9bS8V1fIHgMxOHIt5Vs+9CAWGCCvUOAurjsUDoE2ALIXLDMKnJxcxD13XjWdK54j6ZXDB4syLF0C2PnAQSVY9X7MfCYwtuFmhQhKaBussAXpaVMRHltie3UYSBUUuZaB3J4cg/7TxlmxcNd+ppPRIpSZAB0NI6aOnqoBCpimscO/VpQRJMVLr3XiSYeT6HBiDXWHnIVPfQc03OGcaFqOit6p8lYKMaP/iUQLm+pgpZqrXZ9vB john@localhost",
           "id": 4
}
```

删除密钥：

```json
{
    "event_name": "key_destroy",
    "created_at": "2014-08-18 18:45:16 UTC",
    "updated_at": "2012-07-21T07:38:22Z",
      "username": "root",
           "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC58FwqHUbebw2SdT7SP4FxZ0w+lAO/erhy2ylhlcW/tZ3GY3mBu9VeeiSGoGz8hCx80Zrz+aQv28xfFfKlC8XQFpCWwsnWnQqO2Lv9bS8V1fIHgMxOHIt5Vs+9CAWGCCvUOAurjsUDoE2ALIXLDMKnJxcxD13XjWdK54j6ZXDB4syLF0C2PnAQSVY9X7MfCYwtuFmhQhKaBussAXpaVMRHltie3UYSBUUuZaB3J4cg/7TxlmxcNd+ppPRIpSZAB0NI6aOnqoBCpimscO/VpQRJMVLr3XiSYeT6HBiDXWHnIVPfQc03OGcaFqOit6p8lYKMaP/iUQLm+pgpZqrXZ9vB john@localhost",
            "id": 4
}
```

创建群组：

```json
{
   "created_at": "2012-07-21T07:30:54Z",
   "updated_at": "2012-07-21T07:38:22Z",
   "event_name": "group_create",
         "name": "StoreCloud",
         "path": "storecloud",
     "group_id": 78
}
```

删除群组：

```json
{
   "created_at": "2012-07-21T07:30:54Z",
   "updated_at": "2012-07-21T07:38:22Z",
   "event_name": "group_destroy",
         "name": "StoreCloud",
         "path": "storecloud",
     "group_id": 78
}
```

重命名群组：

```json
{
     "event_name": "group_rename",
     "created_at": "2017-10-30T15:09:00Z",
     "updated_at": "2017-11-01T10:23:52Z",
           "name": "Better Name",
           "path": "better-name",
      "full_path": "parent-group/better-name",
       "group_id": 64,
       "old_path": "old-name",
  "old_full_path": "parent-group/old-name"
}
```

新群组成员：

```json
{
    "created_at": "2012-07-21T07:30:56Z",
    "updated_at": "2012-07-21T07:38:22Z",
    "event_name": "user_add_to_group",
  "group_access": "Maintainer",
      "group_id": 78,
    "group_name": "StoreCloud",
    "group_path": "storecloud",
    "user_email": "johnsmith@example.com",
     "user_name": "John Smith",
 "user_username": "johnsmith",
       "user_id": 41
}
```

移除群组成员：

```json
{
    "created_at": "2012-07-21T07:30:56Z",
    "updated_at": "2012-07-21T07:38:22Z",
    "event_name": "user_remove_from_group",
  "group_access": "Maintainer",
      "group_id": 78,
    "group_name": "StoreCloud",
    "group_path": "storecloud",
    "user_email": "johnsmith@example.com",
     "user_name": "John Smith",
 "user_username": "johnsmith",
       "user_id": 41
}
```

更新群组成员：

```json
{
    "created_at": "2012-07-21T07:30:56Z",
    "updated_at": "2012-07-21T07:38:22Z",
    "event_name": "user_update_for_group",
  "group_access": "Maintainer",
      "group_id": 78,
    "group_name": "StoreCloud",
    "group_path": "storecloud",
    "user_email": "johnsmith@example.com",
     "user_name": "John Smith",
 "user_username": "johnsmith",
       "user_id": 41
}
```

<a id="push-events"></a>

## 推送事件

当您向代码仓库推送时触发，推送标签时除外。每个修改的分支会生成一个事件。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

请求正文：

```json
{
  "event_name": "push",
  "before": "95790bf891e76fee5e1747ab589903a6a1f80f22",
  "after": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
  "ref": "refs/heads/master",
  "checkout_sha": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
  "user_id": 4,
  "user_name": "John Smith",
  "user_email": "john@example.com",
  "user_avatar": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
  "project_id": 15,
  "project":{
    "name":"Diaspora",
    "description":"",
    "web_url":"http://example.com/mike/diaspora",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:mike/diaspora.git",
    "git_http_url":"http://example.com/mike/diaspora.git",
    "namespace":"Mike",
    "visibility_level":0,
    "path_with_namespace":"mike/diaspora",
    "default_branch":"master",
    "homepage":"http://example.com/mike/diaspora",
    "url":"git@example.com:mike/diaspora.git",
    "ssh_url":"git@example.com:mike/diaspora.git",
    "http_url":"http://example.com/mike/diaspora.git"
  },
  "repository":{
    "name": "Diaspora",
    "url": "git@example.com:mike/diaspora.git",
    "description": "",
    "homepage": "http://example.com/mike/diaspora",
    "git_http_url":"http://example.com/mike/diaspora.git",
    "git_ssh_url":"git@example.com:mike/diaspora.git",
    "visibility_level":0
  },
  "commits": [
    {
      "id": "c5feabde2d8cd023215af4d2ceeb7a64839fc428",
      "message": "Add simple search to projects in public area",
      "timestamp": "2013-05-13T18:18:08+00:00",
      "url": "https://dev.gitlab.org/gitlab/gitlabhq/commit/c5feabde2d8cd023215af4d2ceeb7a64839fc428",
      "author": {
        "name": "Example User",
        "email": "user@example.com"
      }
    }
  ],
  "total_commits_count": 1
}
```

<a id="tag-events"></a>

## 标签事件

当您向代码仓库创建（或删除）标签时触发。每个修改的标签会生成一个事件。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

请求正文：

```json
{
  "event_name": "tag_push",
  "before": "0000000000000000000000000000000000000000",
  "after": "82b3d5ae55f7080f1e6022629cdb57bfae7cccc7",
  "ref": "refs/tags/v1.0.0",
  "checkout_sha": "5937ac0a7beb003549fc5fd26fc247adbce4a52e",
  "user_id": 1,
  "user_name": "John Smith",
  "user_avatar": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
  "project_id": 1,
  "project":{
    "name":"Example",
    "description":"",
    "web_url":"http://example.com/jsmith/example",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:jsmith/example.git",
    "git_http_url":"http://example.com/jsmith/example.git",
    "namespace":"Jsmith",
    "visibility_level":0,
    "path_with_namespace":"jsmith/example",
    "default_branch":"master",
    "homepage":"http://example.com/jsmith/example",
    "url":"git@example.com:jsmith/example.git",
    "ssh_url":"git@example.com:jsmith/example.git",
    "http_url":"http://example.com/jsmith/example.git"
  },
  "repository":{
    "name": "Example",
    "url": "ssh://git@example.com/jsmith/example.git",
    "description": "",
    "homepage": "http://example.com/jsmith/example",
    "git_http_url":"http://example.com/jsmith/example.git",
    "git_ssh_url":"git@example.com:jsmith/example.git",
    "visibility_level":0
  },
  "commits": [],
  "total_commits_count": 0
}
```

<a id="merge-request-events"></a>

## 合并请求事件

当创建新的合并请求、更新/合并/关闭现有合并请求，或在源分支中添加提交时触发。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon",
    "email": "admin@example.com"
  },
  "project": {
    "id": 1,
    "name":"Gitlab Test",
    "description":"Aut reprehenderit ut est.",
    "web_url":"http://example.com/gitlabhq/gitlab-test",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
    "git_http_url":"http://example.com/gitlabhq/gitlab-test.git",
    "namespace":"GitlabHQ",
    "visibility_level":20,
    "path_with_namespace":"gitlabhq/gitlab-test",
    "default_branch":"master",
    "homepage":"http://example.com/gitlabhq/gitlab-test",
    "url":"http://example.com/gitlabhq/gitlab-test.git",
    "ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
    "http_url":"http://example.com/gitlabhq/gitlab-test.git"
  },
  "repository": {
    "name": "Gitlab Test",
    "url": "http://example.com/gitlabhq/gitlab-test.git",
    "description": "Aut reprehenderit ut est.",
    "homepage": "http://example.com/gitlabhq/gitlab-test"
  },
  "object_attributes": {
    "id": 99,
    "target_branch": "master",
    "source_branch": "ms-viewport",
    "source_project_id": 14,
    "author_id": 51,
    "assignee_id": 6,
    "title": "MS-Viewport",
    "created_at": "2013-12-03T17:23:34Z",
    "updated_at": "2013-12-03T17:23:34Z",
    "milestone_id": null,
    "state": "opened",
    "merge_status": "unchecked",
    "target_project_id": 14,
    "iid": 1,
    "description": "",
    "source": {
      "name":"Awesome Project",
      "description":"Aut reprehenderit ut est.",
      "web_url":"http://example.com/awesome_space/awesome_project",
      "avatar_url":null,
      "git_ssh_url":"git@example.com:awesome_space/awesome_project.git",
      "git_http_url":"http://example.com/awesome_space/awesome_project.git",
      "namespace":"Awesome Space",
      "visibility_level":20,
      "path_with_namespace":"awesome_space/awesome_project",
      "default_branch":"master",
      "homepage":"http://example.com/awesome_space/awesome_project",
      "url":"http://example.com/awesome_space/awesome_project.git",
      "ssh_url":"git@example.com:awesome_space/awesome_project.git",
      "http_url":"http://example.com/awesome_space/awesome_project.git"
    },
    "target": {
      "name":"Awesome Project",
      "description":"Aut reprehenderit ut est.",
      "web_url":"http://example.com/awesome_space/awesome_project",
      "avatar_url":null,
      "git_ssh_url":"git@example.com:awesome_space/awesome_project.git",
      "git_http_url":"http://example.com/awesome_space/awesome_project.git",
      "namespace":"Awesome Space",
      "visibility_level":20,
      "path_with_namespace":"awesome_space/awesome_project",
      "default_branch":"master",
      "homepage":"http://example.com/awesome_space/awesome_project",
      "url":"http://example.com/awesome_space/awesome_project.git",
      "ssh_url":"git@example.com:awesome_space/awesome_project.git",
      "http_url":"http://example.com/awesome_space/awesome_project.git"
    },
    "last_commit": {
      "id": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "message": "fixed readme",
      "timestamp": "2012-01-03T23:36:29+02:00",
      "url": "http://example.com/awesome_space/awesome_project/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "author": {
        "name": "GitLab dev user",
        "email": "gitlabdev@dv6700.(none)"
      }
    },
    "work_in_progress": false,
    "url": "http://example.com/diaspora/merge_requests/1",
    "action": "open",
    "assignee": {
      "name": "User1",
      "username": "user1",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
    }
  },
  "labels": [{
    "id": 206,
    "title": "API",
    "color": "#ffffff",
    "project_id": 14,
    "created_at": "2013-12-03T17:15:43Z",
    "updated_at": "2013-12-03T17:15:43Z",
    "template": false,
    "description": "API related issues",
    "type": "ProjectLabel",
    "group_id": 41
  }],
  "changes": {
    "updated_by_id": {
      "previous": null,
      "current": 1
    },
    "updated_at": {
      "previous": "2017-09-15 16:50:55 UTC",
      "current":"2017-09-15 16:52:00 UTC"
    },
    "labels": {
      "previous": [{
        "id": 206,
        "title": "API",
        "color": "#ffffff",
        "project_id": 14,
        "created_at": "2013-12-03T17:15:43Z",
        "updated_at": "2013-12-03T17:15:43Z",
        "template": false,
        "description": "API related issues",
        "type": "ProjectLabel",
        "group_id": 41
      }],
      "current": [{
        "id": 205,
        "title": "Platform",
        "color": "#123123",
        "project_id": 14,
        "created_at": "2013-12-03T17:15:43Z",
        "updated_at": "2013-12-03T17:15:43Z",
        "template": false,
        "description": "Platform related issues",
        "type": "ProjectLabel",
        "group_id": 41
      }]
    }
  }
}
```

<a id="repository-update-events"></a>

## 代码仓库更新事件

当您向代码仓库推送（包括标签）时仅触发一次。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

请求正文：

```json
{
  "event_name": "repository_update",
  "user_id": 1,
  "user_name": "John Smith",
  "user_email": "admin@example.com",
  "user_avatar": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
  "project_id": 1,
  "project": {
    "name":"Example",
    "description":"",
    "web_url":"http://example.com/jsmith/example",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:jsmith/example.git",
    "git_http_url":"http://example.com/jsmith/example.git",
    "namespace":"Jsmith",
    "visibility_level":0,
    "path_with_namespace":"jsmith/example",
    "default_branch":"master",
    "homepage":"http://example.com/jsmith/example",
    "url":"git@example.com:jsmith/example.git",
    "ssh_url":"git@example.com:jsmith/example.git",
    "http_url":"http://example.com/jsmith/example.git"
  },
  "changes": [
    {
      "before":"8205ea8d81ce0c6b90fbe8280d118cc9fdad6130",
      "after":"4045ea7a3df38697b3730a20fb73c8bed8a3e69e",
      "ref":"refs/heads/master"
    }
  ],
  "refs":["refs/heads/master"]
}
```

<a id="events-for-member-approval-in-subscription"></a>

## 订阅中成员审批的事件

如果已开启[角色提升的管理员审批](settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则会触发这些事件。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

成员的角色提升请求已入队，等待管理员处理：

```json
{
  "object_kind": "gitlab_subscription_member_approval",
  "action": "enqueue",
  "object_attributes": {
    "new_access_level": 30,
    "old_access_level": 10,
    "existing_member_id": 123
  },
  "user_id": 42,
  "requested_by_user_id": 99,
  "promotion_namespace_id": 789,
  "created_at": "2025-04-10T14:00:00Z",
  "updated_at": "2025-04-10T14:05:00Z"
}
```

实例管理员批准用户使用计费角色：

```json
{
  "object_kind": "gitlab_subscription_member_approvals",
  "action": "approve",
  "object_attributes": {
    "promotion_request_ids_that_failed_to_apply": [],
    "status": "success"
  },
  "reviewed_by_user_id": 101,
  "user_id": 42,
  "updated_at": "2025-04-10T14:10:00Z"
}
```

实例管理员拒绝用户使用计费角色：

```json
{
"object_kind": "gitlab_subscription_member_approvals",
"action": "deny",
"object_attributes": {
"status": "success"
},
"reviewed_by_user_id": 101,
"user_id": 42,
"updated_at": "2025-04-10T14:12:00Z"
}
```

<a id="local-requests-in-system-hooks"></a>

## 系统钩子中的本地请求

[系统钩子对本地网络的请求](../security/webhooks.md)可由管理员允许或阻止。
