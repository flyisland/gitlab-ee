---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 系统钩子
description: "Use system hooks to trigger HTTP POST requests from GitLab events. Includes JSON payload examples."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

系统钩子会在特定事件发生时向外部 URL 发送 HTTP POST 请求，或者在服务器上运行本地脚本。

与项目 webhooks 不同，系统钩子监控整个 极狐GitLab 实例中的事件，而不仅仅是单个项目。这些钩子可以捕获用户创建、项目和群组变更以及来自任何项目的代码仓库推送等事件。

## 触发的事件

| 事件类型                                  | 触发条件 |
|-------------------------------------------|---------|
| `group_create`                            | 群组被创建。 |
| `group_destroy`                           | 群组被删除。 |
| `group_rename`                            | 群组路径或名称发生变化。 |
| `key_create`                              | 一个 SSH 密钥被创建。 |
| `key_destroy`                             | 一个 SSH 密钥被删除。 |
| `project_create`                          | 项目被创建。 |
| `project_destroy`                         | 项目被删除。 |
| `project_rename`                          | 项目路径或名称发生变化。 |
| `project_transfer`                        | 项目被转移到新的命名空间。 |
| `project_update`                          | 项目属性发生变更（项目路径除外）。 |
| `repository_update`                       | 一次推送包含标签或多个分支。 |
| `user_access_request_revoked_for_group`   | 用户对群组的访问请求被取消。 |
| `user_access_request_revoked_for_project` | 用户对项目的访问请求被取消。 |
| `user_access_request_to_group`            | 用户请求访问群组。 |
| `user_access_request_to_project`          | 用户请求访问项目。 |
| `user_add_to_group`                       | 用户被添加为群组成员。 |
| `user_add_to_team`                        | 用户被添加为项目成员。 |
| `user_create`                             | 用户账户被创建。 |
| `user_destroy`                            | 用户账户被删除。 |
| `user_failed_login`                       | 被屏蔽的用户尝试登录。 |
| `user_remove_from_group`                  | 用户从群组中删除。 |
| `user_remove_from_team`                   | 用户从项目中删除。 |
| `user_rename`                             | 用户的用户名发生变化。 |
| `user_update_for_group`                   | 群组成员的角色发生变化。 |
| `user_update_for_team`                    | 项目成员的角色发生变化。 |
| `gitlab_subscription_member_approval`     | 请求角色提升（`"action": "enqueue"`）。 |
| `gitlab_subscription_member_approvals`    | 角色提升被批准（`"action": "approve"`）或被拒绝（`"action": "deny"`）。 |
| `push`                                    | 向代码仓库进行推送（标签除外）。 |
| `tag_push`                                | 标签被添加或删除。 |
| `merge_request`                           | 合并请求被创建、更新、合并或关闭。 |

> [!note]
> 对于推送和标签事件，其结构和弃用规则与[项目和群组 webhooks](../user/project/integrations/webhooks.md) 相同。但提交记录从不显示。

## 创建系统钩子

{{< history >}}

- **名称** 和 **描述** 文本框在极狐GitLab 16.9 中引入。
- **URL 屏蔽**、**自定义标头** 和 **自定义 webhook 模板** 文本框在极狐GitLab 19.0 中引入。

{{< /history >}}

前提条件：

- 管理员权限。

要创建系统钩子：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **系统钩子**。
1. 选择 **添加新 webhook**。
1. 在 **URL** 中，输入 webhook 端点的 URL。对于特殊字符使用百分号编码。
1. 可选。在 **名称** 文本框中，输入 webhook 的名称。
1. 可选。在 **描述** 文本框中，输入 webhook 的描述。
1. 可选。在 **密钥令牌** 文本框中，输入用于验证请求的密钥令牌。

   该令牌会通过 `X-Gitlab-Token` HTTP 请求头与 webhook 请求一起发送。你的 webhook 端点可以使用此令牌验证请求的合法性。

1. 可选。要屏蔽 URL 中的敏感部分，请选择 **添加 URL 屏蔽**。更多信息，请参见[屏蔽系统钩子 URL 的敏感部分](#mask-sensitive-portions-of-system-hook-urls)。
1. 可选。要为外部服务添加认证标头，请选择 **添加自定义标头**。更多信息，请参见[自定义标头](#custom-headers)。
1. 在 **触发器** 部分，勾选每个你希望触发该钩子的 极狐GitLab [事件](#optional-triggers) 对应的复选框。
1. 可选。设置 **自定义 webhook 模板** 以控制请求体。更多信息，请参见[自定义 webhook 模板](#custom-webhook-template)。
1. 可选。取消勾选 **启用 SSL 验证** 复选框以禁用 [SSL 验证](../user/project/integrations/_index.md#ssl-verification)。
1. 选择 **添加系统钩子**。

### 屏蔽系统钩子 URL 的敏感部分

系统钩子 URL 敏感部分的屏蔽方式与项目和群组 webhooks 相同。被屏蔽的 URL 部分会：

- 在钩子执行时替换为配置的值。
- 不被记录。
- 在数据库中静态加密。

有关配置的更多信息，请参见项目和群组文档中的 [屏蔽 webhook URL 的敏感部分](../user/project/integrations/webhooks.md#mask-sensitive-portions-of-webhook-urls)。

### 自定义标头

系统钩子的自定义标头与项目和群组 webhooks 的工作方式相同。每个钩子最多可以配置 20 个自定义标头。自定义标头在 **近期事件** 中显示时值会被屏蔽。

有关标头的要求，请参见项目和群组文档中的 [自定义标头](../user/project/integrations/webhooks.md#custom-headers)。

### 可选触发器

系统钩子会自动在[支持的事件](#triggered-events)上触发，例如用户和群组的生命周期变更。你还可以启用以下可选触发器：

| 触发器                      | 描述 |
|:-----------------------------|:------------|
| **仓库更新事件** | 包含标签或多个分支的推送。 |
| **推送事件**      | 向任何分支进行推送。 |
| **标签推送事件**  | 标签被添加或删除。 |
| **合并请求事件**   | 合并请求被创建、更新、合并或关闭。 |

#### 按分支过滤推送事件

按分支过滤推送事件与项目和群组 webhooks 的工作方式相同。更多信息，请参见项目和群组文档中的 [按分支过滤推送事件](../user/project/integrations/webhooks.md#filter-push-events-by-branch)。

### 自定义 webhook 模板

自定义 webhook 模板与项目和群组 webhooks 的工作方式相同。有关用法和示例，请参见项目和群组文档中的 [自定义 webhook 模板](../user/project/integrations/webhooks.md#custom-webhook-template)。

## 系统钩子限制

系统钩子受限于与项目 webhooks 相同的推送事件限制。默认情况下，当一次推送包含超过 3 个分支或标签时，系统钩子不会被触发。

此限制由 `push_event_hooks_limit` 设置控制（默认值：`3`）。对于 极狐GitLab 私有化部署实例，管理员可以使用[应用程序设置 API](../api/settings.md#available-settings) 修改此限制。

## 钩子请求示例

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

项目被创建：

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

项目被删除：

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

项目被重命名：

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

如果命名空间发生变化，`project_rename` 不会被触发。这种情况应参考 `group_rename` 和 `user_rename`。

项目被转移：

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

项目被更新：

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

群组访问请求被移除：

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

项目访问请求被移除：

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

群组访问请求被创建：

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

项目访问请求被创建：

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

新团队成员被添加：

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

团队成员被移除：

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

团队成员被更新：

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

用户被创建：

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

用户被删除：

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

如果用户是通过 LDAP 屏蔽的，则 `state` 为 `ldap_blocked`。

用户被重命名：

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

密钥被添加：

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

密钥被删除：

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

群组被创建：

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

群组被删除：

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

群组被重命名：

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

新群组成员被添加：

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

群组成员被移除：

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

群组成员被更新：

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

## 推送事件

当向代码仓库推送（标签除外）时触发。每个被修改的分支会生成一个事件。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

请求体：

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

## 标签事件

当向代码仓库创建（或删除）标签时触发。每个被修改的标签会生成一个事件。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

请求体：

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

## 合并请求事件

当新的合并请求被创建、已有的合并请求被更新/合并/关闭，或者源分支中添加了提交时触发。

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

## 仓库更新事件

仅当你推送到仓库（包括标签）时触发一次。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

请求体：

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

## 订阅中的成员审批事件

如果开启了[角色晋升的管理员审批](settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则会触发这些事件。

请求头：

```plaintext
X-Gitlab-Event: System Hook
```

排队等待晋升管理的成员：

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

实例管理员批准了用户的计费角色：

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

实例管理员拒绝了用户的计费角色：

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

管理员可以允许或阻止[系统钩子对本地网络的请求](../security/webhooks.md)。