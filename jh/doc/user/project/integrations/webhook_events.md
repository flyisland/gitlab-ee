---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Webhook 事件
description: "极狐GitLab Webhook 事件及负载列表。包含 JSON 示例。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Webhook 将极狐GitLab 连接到您的外部应用程序，并自动化您的工作流程。
当极狐GitLab 中发生特定事件时，Webhook 会向您配置的端点发送包含详细信息的 HTTP POST 请求。
构建能够响应代码变更、部署、评论和其他活动的自动化流程，无需人工干预。

此页面列出了为[项目 Webhook](webhooks.md)和[群组 Webhook](webhooks.md#group-webhooks)触发的事件。

有关系统 Webhook 触发的事件列表，请参阅[系统 Webhook](../../../administration/system_hooks.md)。

<a id="events-triggered-for-both-project-and-group-webhooks"></a>

## 项目和群组 Webhook 均触发的事件

| 事件类型                                                                    | 触发条件 |
|-------------------------------------------------------------------------------|---------|
| [评论事件](#comment-events)                                              | 在提交、合并请求、议题和代码片段上创建或编辑新评论。 |
| [部署事件](#deployment-events)                                        | 部署开始、完成、失败、被取消、等待批准或等待手动操作。在专业版和旗舰版上，还包括部署被批准或拒绝时。 |
| [表情事件](#emoji-events)                                                  | 添加或移除表情反应。 |
| [功能标志事件](#feature-flag-events)                                    | 功能标志被开启或关闭。 |
| [作业事件](#job-events)                                                      | 作业状态发生变化。 |
| [合并请求事件](#merge-request-events)                                  | 创建、编辑、合并或关闭合并请求，或在源分支中添加提交。 |
| [里程碑事件](#milestone-events)                                          | 创建、关闭、重新打开或删除里程碑。 |
| [流水线事件](#pipeline-events)                                            | 流水线状态发生变化。 |
| [项目或群组访问令牌事件](#project-and-group-access-token-events) | 项目或群组访问令牌将在 7、30 或 60 天后过期。 |
| [推送事件](#push-events)                                                    | 向代码仓库进行推送。 |
| [发布事件](#release-events)                                              | 创建、编辑或删除发布。 |
| [标签事件](#tag-events)                                                      | 在代码仓库中创建或删除标签。 |
| [漏洞事件](#vulnerability-events)                                  | 创建或更新漏洞。 |
| [Wiki 页面事件](#wiki-page-events)                                          | 创建、编辑或删除 Wiki 页面。 |
| [工作项事件](#work-item-events)                                          | 创建新的工作项，或编辑、关闭、重新打开现有工作项。 |

<a id="events-triggered-for-group-webhooks-only"></a>

## 仅群组 Webhook 触发的事件

| 事件类型                                 | 触发条件 |
|--------------------------------------------|---------|
| [群组成员事件](#group-member-events) | 用户被添加到群组或从群组中移除，或用户的访问级别或访问过期日期发生变化。 |
| [项目事件](#project-events)           | 在群组中创建或删除项目。 |
| [子群组事件](#subgroup-events)         | 在群组中创建或移除子群组。 |

> [!note]
> 如果作者在其 [极狐GitLab 个人资料](https://gitlab.com/-/user_settings/profile) 中没有列出公开邮箱，则 Webhook 负载中的 `email` 属性显示为 `[REDACTED]`。

<a id="push-events"></a>

## 推送事件

当您推送到代码仓库时，会触发推送事件，但以下情况除外：

- 您推送标签。
- 默认情况下，单次推送包含超过三个分支的更改（取决于 [`push_event_hooks_limit` 设置](../../../api/settings.md#available-settings)）。

如果您一次推送超过 20 个提交，负载中的 `commits` 属性仅包含最新 20 个提交的信息。
加载详细的提交数据开销较大，因此出于性能原因存在此限制。
`total_commits_count` 属性包含实际的提交数量。

> [!note]
> 另一个设置 `push_event_activities_limit` 控制极狐GitLab 在活动源中是创建单个推送事件还是批量推送事件。有关更多信息，请参阅 [推送事件活动限制](../../../administration/settings/push_event_activities_limit.md)。

如果您创建并推送一个没有新提交的分支，负载中的 `commits` 属性为空。

请求头：

```plaintext
X-Gitlab-Event: Push Hook
```

负载示例：

```json
{
  "object_kind": "push",
  "event_name": "push",
  "before": "95790bf891e76fee5e1747ab589903a6a1f80f22",
  "after": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
  "ref": "refs/heads/master",
  "ref_protected": true,
  "checkout_sha": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
  "message": "Hello World",
  "user_id": 4,
  "user_name": "John Smith",
  "user_username": "jsmith",
  "user_email": "john@example.com",
  "user_avatar": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
  "project_id": 15,
  "project": {
    "id": 15,
    "name": "Diaspora",
    "description": "",
    "web_url": "http://example.com/mike/diaspora",
    "avatar_url": null,
    "git_ssh_url": "git@example.com:mike/diaspora.git",
    "git_http_url": "http://example.com/mike/diaspora.git",
    "namespace": "Mike",
    "visibility_level": 0,
    "path_with_namespace": "mike/diaspora",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "http://example.com/mike/diaspora",
    "url": "git@example.com:mike/diaspora.git",
    "ssh_url": "git@example.com:mike/diaspora.git",
    "http_url": "http://example.com/mike/diaspora.git"
  },
  "commits": [
    {
      "id": "b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
      "message": "Update Catalan translation to e38cb41.\n\nSee https://gitlab.com/gitlab-org/gitlab for more information",
      "title": "Update Catalan translation to e38cb41.",
      "timestamp": "2011-12-12T14:27:31+02:00",
      "url": "http://example.com/mike/diaspora/commit/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
      "author": {
        "name": "Jordi Mallach",
        "email": "jordi@softcatala.org"
      },
      "added": ["CHANGELOG"],
      "modified": ["app/controller/application.rb"],
      "removed": []
    },
    {
      "id": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "message": "fixed readme",
      "title": "fixed readme",
      "timestamp": "2012-01-03T23:36:29+02:00",
      "url": "http://example.com/mike/diaspora/commit/da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "author": {
        "name": "GitLab dev user",
        "email": "gitlabdev@dv6700.(none)"
      },
      "added": ["CHANGELOG"],
      "modified": ["app/controller/application.rb"],
      "removed": []
    }
  ],
  "total_commits_count": 4,
  "push_options": {},
  "repository": {
    "name": "Diaspora",
    "url": "git@example.com:mike/diaspora.git",
    "description": "",
    "homepage": "http://example.com/mike/diaspora",
    "git_http_url": "http://example.com/mike/diaspora.git",
    "git_ssh_url": "git@example.com:mike/diaspora.git",
    "visibility_level": 0
  }
}
```

<a id="tag-events"></a>

## 标签事件

当您在代码仓库中创建或删除标签时，会触发标签事件。

默认情况下，如果单次推送包含超过三个标签的更改，则不会执行此钩子。此限制由 `push_event_hooks_limit` 设置控制（默认值：`3`），该设置同时适用于标签和分支。超过此限制时，该推送事件不会触发任何 Webhook。

对于极狐GitLab 私有化部署实例，管理员可以使用[应用程序设置 API](../../../api/settings.md#available-settings) 修改此限制。

请求头：

```plaintext
X-Gitlab-Event: Tag Push Hook
```

负载示例：

```json
{
  "object_kind": "tag_push",
  "event_name": "tag_push",
  "before": "0000000000000000000000000000000000000000",
  "after": "82b3d5ae55f7080f1e6022629cdb57bfae7cccc7",
  "ref": "refs/tags/v1.0.0",
  "ref_protected": true,
  "checkout_sha": "82b3d5ae55f7080f1e6022629cdb57bfae7cccc7",
  "message": "Tag message",
  "user_id": 1,
  "user_name": "John Smith",
  "user_username": "jsmith",
  "user_email": "john@example.com",
  "user_avatar": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
  "project_id": 1,
  "project": {
    "id": 1,
    "name": "Example",
    "description": "",
    "web_url": "http://example.com/jsmith/example",
    "avatar_url": null,
    "git_ssh_url": "git@example.com:jsmith/example.git",
    "git_http_url": "http://example.com/jsmith/example.git",
    "namespace": "Jsmith",
    "visibility_level": 0,
    "path_with_namespace": "jsmith/example",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "http://example.com/jsmith/example",
    "url": "git@example.com:jsmith/example.git",
    "ssh_url": "git@example.com:jsmith/example.git",
    "http_url": "http://example.com/jsmith/example.git"
  },
  "commits": [],
  "total_commits_count": 0,
  "push_options": {},
  "repository": {
    "name": "Example",
    "url": "ssh://git@example.com/jsmith/example.git",
    "description": "",
    "homepage": "http://example.com/jsmith/example",
    "git_http_url": "http://example.com/jsmith/example.git",
    "git_ssh_url": "git@example.com:jsmith/example.git",
    "visibility_level": 0
  }
}
```

<a id="work-item-events"></a>

## 工作项事件

当工作项被创建、编辑、关闭或重新打开时，会触发工作项事件。
支持的工作项类型包括：

- [史诗](../../group/epics/_index.md)
- [议题](../issues/_index.md)
- [任务](../../tasks.md)
- [事件](../../../operations/incident_management/incidents.md)
- [测试用例](../../../ci/test_cases/_index.md)
- [需求](../requirements/_index.md)
- [目标与关键结果 (OKR)](../../okrs.md)

对于议题和 [服务台](../service_desk/_index.md) 议题，`object_kind` 为 `issue`，`type` 为 `Issue`。
对于所有其他工作项，`object_kind` 字段为 `work_item`，`type` 为工作项类型。

对于工作项类型 `Epic`，要获取变更事件，Webhook 必须注册到群组。

负载中 `object_attributes.action` 的可用值为：

- `open`
- `close`
- `reopen`
- `update`

`assignee` 和 `assignee_id` 键已弃用，仅包含第一个指派人。

`escalation_status` 和 `escalation_policy` 字段仅适用于[支持升级](../../../operations/incident_management/paging.md#paging)的议题类型，例如事件。

请求头：

```plaintext
X-Gitlab-Event: Issue Hook
```

负载示例：

```json
{
  "object_kind": "issue",
  "event_type": "issue",
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
    "ci_config_path": null,
    "homepage":"http://example.com/gitlabhq/gitlab-test",
    "url":"http://example.com/gitlabhq/gitlab-test.git",
    "ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
    "http_url":"http://example.com/gitlabhq/gitlab-test.git"
  },
  "object_attributes": {
    "id": 301,
    "title": "New API: create/update/delete file",
    "assignee_ids": [51],
    "assignee_id": 51,
    "author_id": 51,
    "project_id": 14,
    "created_at": "2013-12-03T17:15:43Z",
    "updated_at": "2013-12-03T17:15:43Z",
    "updated_by_id": 1,
    "last_edited_at": null,
    "last_edited_by_id": null,
    "relative_position": 0,
    "description": "Create new API for manipulations with repository",
    "milestone_id": null,
    "state_id": 1,
    "confidential": false,
    "discussion_locked": true,
    "due_date": null,
    "start_date": null,
    "moved_to_id": null,
    "duplicated_to_id": null,
    "time_estimate": 0,
    "total_time_spent": 0,
    "time_change": 0,
    "human_total_time_spent": null,
    "human_time_estimate": null,
    "human_time_change": null,
    "weight": null,
    "health_status": "at_risk",
    "type": "Issue",
    "iid": 23,
    "url": "http://example.com/diaspora/issues/23",
    "state": "opened",
    "action": "open",
    "severity": "high",
    "escalation_status": "triggered",
    "escalation_policy": {
      "id": 18,
      "name": "Engineering On-call"
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
      }]
  },
  "repository": {
    "name": "Gitlab Test",
    "url": "http://example.com/gitlabhq/gitlab-test.git",
    "description": "Aut reprehenderit ut est.",
    "homepage": "http://example.com/gitlabhq/gitlab-test"
  },
  "assignees": [{
    "name": "User1",
    "username": "user1",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
  }],
  "assignee": {
    "name": "User1",
    "username": "user1",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
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
      "current": "2017-09-15 16:52:00 UTC"
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

<a id="comment-events"></a>

## 评论事件

当在提交、合并请求、议题和代码片段上创建或编辑新评论时，会触发评论事件。

评论数据存储在 `object_attributes` 中（例如，`note` 或 `noteable_type`）。
负载包含有关评论目标的信息。例如，对议题的评论会在 `issue` 键下包含特定的议题信息。

可用的目标类型为：

- `commit`
- `merge_request`
- `issue`
- `snippet`

负载中 `object_attributes.action` 的可用值为：

- `create`
- `update`

<a id="comment-on-a-commit"></a>

### 对提交的评论

请求头：

```plaintext
X-Gitlab-Event: Note Hook
```

负载示例：

```json
{
  "object_kind": "note",
  "event_type": "note",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon",
    "email": "admin@example.com"
  },
  "project_id": 5,
  "project":{
    "id": 5,
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
  "repository":{
    "name": "Gitlab Test",
    "url": "http://example.com/gitlab-org/gitlab-test.git",
    "description": "Aut reprehenderit ut est.",
    "homepage": "http://example.com/gitlab-org/gitlab-test"
  },
  "object_attributes": {
    "id": 1243,
    "internal": false,
    "note": "This is a commit comment. How does this work?",
    "noteable_type": "Commit",
    "author_id": 1,
    "created_at": "2015-05-17 18:08:09 UTC",
    "updated_at": "2015-05-17 18:08:09 UTC",
    "project_id": 5,
    "attachment":null,
    "line_code": "bec9703f7a456cd2b4ab5fb3220ae016e3e394e3_0_1",
    "commit_id": "cfe32cf61b73a0d5e9f13e774abde7ff789b1660",
    "noteable_id": null,
    "system": false,
    "st_diff": {
      "diff": "--- /dev/null\n+++ b/six\n@@ -0,0 +1 @@\n+Subproject commit 409f37c4f05865e4fb208c771485f211a22c4c2d\n",
      "new_path": "six",
      "old_path": "six",
      "a_mode": "0",
      "b_mode": "160000",
      "new_file": true,
      "renamed_file": false,
      "deleted_file": false
    },
    "action": "create",
    "url": "http://example.com/gitlab-org/gitlab-test/commit/cfe32cf61b73a0d5e9f13e774abde7ff789b1660#note_1243"
  },
  "commit": {
    "id": "cfe32cf61b73a0d5e9f13e774abde7ff789b1660",
    "message": "Add submodule\n\nSigned-off-by: Example User \u003cuser@example.com.com\u003e\n",
    "timestamp": "2014-02-27T10:06:20+02:00",
    "url": "http://example.com/gitlab-org/gitlab-test/commit/cfe32cf61b73a0d5e9f13e774abde7ff789b1660",
    "author": {
      "name": "Example User",
      "email": "user@example.com"
    }
  }
}
```

<a id="comment-on-a-merge-request"></a>

### 对合并请求的评论

请求头：

```plaintext
X-Gitlab-Event: Note Hook
```

负载示例：

```json
{
  "object_kind": "note",
  "event_type": "note",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon",
    "email": "admin@example.com"
  },
  "project_id": 5,
  "project":{
    "id": 5,
    "name":"Gitlab Test",
    "description":"Aut reprehenderit ut est.",
    "web_url":"http://example.com/gitlab-org/gitlab-test",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
    "git_http_url":"http://example.com/gitlab-org/gitlab-test.git",
    "namespace":"Gitlab Org",
    "visibility_level":10,
    "path_with_namespace":"gitlab-org/gitlab-test",
    "default_branch":"master",
    "homepage":"http://example.com/gitlab-org/gitlab-test",
    "url":"http://example.com/gitlab-org/gitlab-test.git",
    "ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
    "http_url":"http://example.com/gitlab-org/gitlab-test.git"
  },
  "repository":{
    "name": "Gitlab Test",
    "url": "http://localhost/gitlab-org/gitlab-test.git",
    "description": "Aut reprehenderit ut est.",
    "homepage": "http://example.com/gitlab-org/gitlab-test"
  },
  "object_attributes": {
    "id": 1244,
    "internal": false,
    "note": "This MR needs work.",
    "noteable_type": "MergeRequest",
    "author_id": 1,
    "created_at": "2015-05-17 18:21:36 UTC",
    "updated_at": "2015-05-17 18:21:36 UTC",
    "project_id": 5,
    "attachment": null,
    "line_code": null,
    "commit_id": "",
    "noteable_id": 7,
    "system": false,
    "st_diff": null,
    "action": "create",
    "url": "http://example.com/gitlab-org/gitlab-test/merge_requests/1#note_1244"
  },
  "merge_request": {
    "id": 7,
    "target_branch": "markdown",
    "source_branch": "master",
    "source_project_id": 5,
    "author_id": 8,
    "assignee_id": 28,
    "title": "Tempora et eos debitis quae laborum et.",
    "created_at": "2015-03-01 20:12:53 UTC",
    "updated_at": "2015-03-21 18:27:27 UTC",
    "milestone_id": 11,
    "state": "opened",
    "merge_status": "cannot_be_merged",
    "target_project_id": 5,
    "iid": 1,
    "description": "Et voluptas corrupti assumenda temporibus. Architecto cum animi eveniet amet asperiores. Vitae numquam voluptate est natus sit et ad id.",
    "position": 0,
    "labels": [
      {
        "id": 25,
        "title": "Afterpod",
        "color": "#3e8068",
        "project_id": null,
        "created_at": "2019-06-05T14:32:20.211Z",
        "updated_at": "2019-06-05T14:32:20.211Z",
        "template": false,
        "description": null,
        "type": "GroupLabel",
        "group_id": 4
      },
      {
        "id": 86,
        "title": "Element",
        "color": "#231afe",
        "project_id": 4,
        "created_at": "2019-06-05T14:32:20.637Z",
        "updated_at": "2019-06-05T14:32:20.637Z",
        "template": false,
        "description": null,
        "type": "ProjectLabel",
        "group_id": null
      }
    ],
    "source":{
      "name":"Gitlab Test",
      "description":"Aut reprehenderit ut est.",
      "web_url":"http://example.com/gitlab-org/gitlab-test",
      "avatar_url":null,
      "git_ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
      "git_http_url":"http://example.com/gitlab-org/gitlab-test.git",
      "namespace":"Gitlab Org",
      "visibility_level":10,
      "path_with_namespace":"gitlab-org/gitlab-test",
      "default_branch":"master",
      "homepage":"http://example.com/gitlab-org/gitlab-test",
      "url":"http://example.com/gitlab-org/gitlab-test.git",
      "ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
      "http_url":"http://example.com/gitlab-org/gitlab-test.git"
    },
    "target": {
      "name":"Gitlab Test",
      "description":"Aut reprehenderit ut est.",
      "web_url":"http://example.com/gitlab-org/gitlab-test",
      "avatar_url":null,
      "git_ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
      "git_http_url":"http://example.com/gitlab-org/gitlab-test.git",
      "namespace":"Gitlab Org",
      "visibility_level":10,
      "path_with_namespace":"gitlab-org/gitlab-test",
      "default_branch":"master",
      "homepage":"http://example.com/gitlab-org/gitlab-test",
      "url":"http://example.com/gitlab-org/gitlab-test.git",
      "ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
      "http_url":"http://example.com/gitlab-org/gitlab-test.git"
    },
    "last_commit": {
      "id": "562e173be03b8ff2efb05345d12df18815438a4b",
      "message": "Merge branch 'another-branch' into 'master'\n\nCheck in this test\n",
      "timestamp": "2015-04-08T21: 00:25-07:00",
      "url": "http://example.com/gitlab-org/gitlab-test/commit/562e173be03b8ff2efb05345d12df18815438a4b",
      "author": {
        "name": "John Smith",
        "email": "john@example.com"
      }
    },
    "work_in_progress": false,
    "draft": false,
    "assignee": {
      "name": "User1",
      "username": "user1",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
    },
    "detailed_merge_status": "checking"
  }
}
```

<a id="comment-on-an-issue"></a>

### 对议题的评论

- `assignee_id` 字段已弃用，仅显示第一个指派人。
- 对于机密议题，`event_type` 设置为 `confidential_note`。

请求头：

```plaintext
X-Gitlab-Event: Note Hook
```

负载示例：

```json
{
  "object_kind": "note",
  "event_type": "note",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon",
    "email": "admin@example.com"
  },
  "project_id": 5,
  "project":{
    "id": 5,
    "name":"Gitlab Test",
    "description":"Aut reprehenderit ut est.",
    "web_url":"http://example.com/gitlab-org/gitlab-test",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
    "git_http_url":"http://example.com/gitlab-org/gitlab-test.git",
    "namespace":"Gitlab Org",
    "visibility_level":10,
    "path_with_namespace":"gitlab-org/gitlab-test",
    "default_branch":"master",
    "homepage":"http://example.com/gitlab-org/gitlab-test",
    "url":"http://example.com/gitlab-org/gitlab-test.git",
    "ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
    "http_url":"http://example.com/gitlab-org/gitlab-test.git"
  },
  "repository":{
    "name":"diaspora",
    "url":"git@example.com:mike/diaspora.git",
    "description":"",
    "homepage":"http://example.com/mike/diaspora"
  },
  "object_attributes": {
    "id": 1241,
    "internal": false,
    "note": "Hello world",
    "noteable_type": "Issue",
    "author_id": 1,
    "created_at": "2015-05-17 17:06:40 UTC",
    "updated_at": "2015-05-17 17:06:40 UTC",
    "project_id": 5,
    "attachment": null,
    "line_code": null,
    "commit_id": "",
    "noteable_id": 92,
    "system": false,
    "st_diff": null,
    "action": "create",
    "url": "http://example.com/gitlab-org/gitlab-test/issues/17#note_1241"
  },
  "issue": {
    "id": 92,
    "title": "test",
    "assignee_ids": [],
    "assignee_id": null,
    "author_id": 1,
    "project_id": 5,
    "created_at": "2015-04-12 14:53:17 UTC",
    "updated_at": "2015-04-26 08:28:42 UTC",
    "position": 0,
    "branch_name": null,
    "description": "test",
    "milestone_id": null,
    "state": "closed",
    "iid": 17,
    "labels": [
      {
        "id": 25,
        "title": "Afterpod",
        "color": "#3e8068",
        "project_id": null,
        "created_at": "2019-06-05T14:32:20.211Z",
        "updated_at": "2019-06-05T14:32:20.211Z",
        "template": false,
        "description": null,
        "type": "GroupLabel",
        "group_id": 4
      },
      {
        "id": 86,
        "title": "Element",
        "color": "#231afe",
        "project_id": 4,
        "created_at": "2019-06-05T14:32:20.637Z",
        "updated_at": "2019-06-05T14:32:20.637Z",
        "template": false,
        "description": null,
        "type": "ProjectLabel",
        "group_id": null
      }
    ]
  }
}
```

<a id="comment-on-a-code-snippet"></a>

### 对代码片段的评论

请求头：

```plaintext
X-Gitlab-Event: Note Hook
```

负载示例：

```json
{
  "object_kind": "note",
  "event_type": "note",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon",
    "email": "admin@example.com"
  },
  "project_id": 5,
  "project":{
    "id": 5,
    "name":"Gitlab Test",
    "description":"Aut reprehenderit ut est.",
    "web_url":"http://example.com/gitlab-org/gitlab-test",
    "avatar_url":null,
    "git_ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
    "git_http_url":"http://example.com/gitlab-org/gitlab-test.git",
    "namespace":"Gitlab Org",
    "visibility_level":10,
    "path_with_namespace":"gitlab-org/gitlab-test",
    "default_branch":"master",
    "homepage":"http://example.com/gitlab-org/gitlab-test",
    "url":"http://example.com/gitlab-org/gitlab-test.git",
    "ssh_url":"git@example.com:gitlab-org/gitlab-test.git",
    "http_url":"http://example.com/gitlab-org/gitlab-test.git"
  },
  "repository":{
    "name":"Gitlab Test",
    "url":"http://example.com/gitlab-org/gitlab-test.git",
    "description":"Aut reprehenderit ut est.",
    "homepage":"http://example.com/gitlab-org/gitlab-test"
  },
  "object_attributes": {
    "id": 1245,
    "internal": false,
    "note": "Is this snippet doing what it's supposed to be doing?",
    "noteable_type": "Snippet",
    "author_id": 1,
    "created_at": "2015-05-17 18:35:50 UTC",
    "updated_at": "2015-05-17 18:35:50 UTC",
    "project_id": 5,
    "attachment": null,
    "line_code": null,
    "commit_id": "",
    "noteable_id": 53,
    "system": false,
    "st_diff": null,
    "action": "create",
    "url": "http://example.com/gitlab-org/gitlab-test/-/snippets/53#note_1245"
  },
  "snippet": {
    "id": 53,
    "title": "test",
    "description": "A snippet description.",
    "content": "puts 'Hello world'",
    "author_id": 1,
    "project_id": 5,
    "created_at": "2015-04-09 02:40:38 UTC",
    "updated_at": "2015-04-09 02:40:38 UTC",
    "file_name": "test.rb",
    "type": "ProjectSnippet",
    "visibility_level": 0,
    "url": "http://example.com/gitlab-org/gitlab-test/-/snippets/53"
  }
}
```

<a id="merge-request-events"></a>

## 合并请求事件

在以下情况下会触发合并请求事件：

- 创建新的合并请求。
- 更新、批准（由所有必需批准者）、取消批准、合并或关闭现有的合并请求。
- 单个用户对现有的合并请求添加或移除其批准。
- 重新请求审核人评审合并请求。
- 合并请求设置为自动合并，或取消自动合并。
- 在源分支中添加提交。
- 合并请求上的所有讨论串均已解决。

即使 `changes` 字段为空，也可能触发合并请求事件。
Webhook 接收方应始终检查 `changes` 字段的内容，以了解合并请求中的实际变更。

<a id="payload-structure"></a>

### 负载结构

Webhook 负载的 JSON 结构在所有操作类型中保持一致。
差异在于哪些字段包含数据，以及 `oldrev`、`system` 和 `system_action` 等条件字段是否存在。

负载中 `object_attributes.action` 的可用值为：

- `open`：创建合并请求。
- `close`：关闭合并请求。
- `reopen`：重新打开已关闭的合并请求。
- `update`：更新合并请求。这包括常规更新、重新请求评审操作以及设置或取消自动合并。检查 `changes` 字段以确定具体的更新类型。当设置或取消自动合并时，`changes` 字段会反映合并请求自动合并状态的变更。
- `approval`：用户添加其批准。
- `approved`：合并请求已获得所有必需批准者的完全批准。
- `unapproval`：用户移除其批准，无论是手动还是由系统执行。
- `unapproved`：先前已批准的合并请求失去其批准状态，无论是手动还是由系统执行。
- `merge`：合并请求被合并。

合并请求 Webhook 负载包含以下顶级字段：

| 字段               | 类型   | 描述 |
|---------------------|--------|-------------|
| `object_kind`       | 字符串 | `"merge_request"` |
| `event_type`        | 字符串 | `"merge_request"` |
| `user`              | 对象 | 触发事件的用户。 |
| `project`           | 对象 | 目标项目。 |
| `object_attributes` | 对象 | 合并请求数据。 |
| `changes`           | 对象 | 包含操作期间更改的属性。 |
| `assignees`         | 数组  | 当前指派的用户。 |
| `reviewers`         | 数组  | 当前指派的审核人。 |
| `labels`            | 数组  | 标记对象。 |
| `repository`        | 对象 | 已弃用。请改用 `project`。代码仓库信息。 |

<a id="deprecated-fields"></a>

### 已弃用的字段

以下字段已弃用，仅出于向后兼容性而包含。请改用推荐的替代字段：

| 已弃用字段                     | 推荐替代字段 |
|--------------------------------------|-------------------------|
| `object_attributes.assignee_id`      | `object_attributes.assignee_ids` |
| `object_attributes.work_in_progress` | `object_attributes.draft` |
| `project.http_url`                   | `project.git_http_url`  |
| `project.homepage`                   | `project.web_url`       |
| `project.ssh_url`                    | `project.git_ssh_url`   |
| `project.url`                        | `project.git_ssh_url` 或 `project.git_http_url` |
| `repository`                         | `project`               |

<a id="object_attributes-field"></a>

### `object_attributes` 字段

`object_attributes` 字段包含合并请求的当前状态。
它包括以下字段：

| 字段                           | 类型    | 描述 |
|---------------------------------|---------|-------------|
| `action`                        | 字符串  | 触发 Webhook 的操作。例如，`open`、`update` 或 `merge`。 |
| `actioned_at`                   | 字符串  | 触发 Webhook 的操作发生的时间。 |
| `approval_rules`                | 数组   | 批准规则对象数组（仅限企业版）。 |
| `assignee_ids`                  | 数组   | 指派人 ID 数组。 |
| `author_id`                     | 整数 | 合并请求作者的 ID。 |
| `blocking_discussions_resolved` | 布尔值 | 阻塞性讨论是否已解决。 |
| `created_at`                    | 字符串  | 合并请求的创建时间。 |
| `description`                   | 字符串  | 合并请求的描述。 |
| `detailed_merge_status`         | 字符串  | 详细的合并状态信息。有关可能值的列表，请参阅 [合并状态](../../../api/merge_requests.md#merge-status)。 |
| `draft`                         | 布尔值 | 合并请求是否为草稿。 |
| `first_contribution`            | 布尔值 | 这是否是作者的首次贡献。 |
| `head_pipeline_id`              | 整数 | 头部流水线的 ID。 |
| `human_time_change`             | 字符串  | 人类可读的时间变更。 |
| `human_time_estimate`           | 字符串  | 人类可读的时间估算。 |
| `human_total_time_spent`        | 字符串  | 人类可读的总花费时间。 |
| `id`                            | 整数 | 合并请求 ID。 |
| `iid`                           | 整数 | 合并请求的内部 ID。 |
| `labels`                        | 数组   | 标记对象数组。 |
| `last_commit`                   | 对象  | 包含详细信息的最后一个提交对象。 |
| `last_edited_at`                | 字符串  | 合并请求的最后编辑时间。 |
| `last_edited_by_id`             | 整数 | 最后编辑它的用户的 ID。 |
| `merge_commit_sha`              | 字符串  | 合并提交的 SHA。 |
| `merged_at`                     | 字符串  | 合并请求的合并时间。如果尚未合并，则为 `null`。 |
| `merge_error`                   | 字符串  | 任何合并错误消息。 |
| `merge_params`                  | 对象  | 合并参数。 |
| `merge_status`                  | 字符串  | 合并请求的状态。 |
| `merge_user_id`                 | 整数 | 合并它的用户的 ID。 |
| `merge_when_pipeline_succeeds`  | 布尔值 | 是否启用自动合并。 |
| `milestone_id`                  | 整数 | 里程碑的 ID。 |
| `oldrev`                        | 字符串  | 旧的提交 SHA（仅存在于与推送相关的事件中）。 |
| `prepared_at`                   | 字符串  | 合并请求准备完成的时间戳。此字段仅在所有[准备步骤](../../../api/merge_requests.md#preparation-steps)完成后填充一次，如果添加更多更改，则不会更新。 |
| `reviewer_ids`                  | 数组   | 审核人 ID 数组。 |
| `source_branch`                 | 字符串  | 源分支名称。 |
| `source`                        | 对象  | 源项目详细信息。例如，名称和描述。 |
| `source_project_id`             | 整数 | 源项目的 ID。 |
| `squash_commit_sha`             | 字符串  | 压缩提交的 SHA。仅当合并请求使用压缩合并时存在。 |
| `state_id`                      | 整数 | 状态 ID（`1`：已打开，`2`：已关闭，`3`：已合并，`4`：已锁定）。 |
| `state`                         | 字符串  | 合并请求的状态（`opened`、`closed`、`merged`、`locked`）。 |
| `system_action`                 | 字符串  | 系统操作（仅当 `system` 为 `true` 时存在）。 |
| `system`                        | 布尔值 | 事件是否由系统发起。 |
| `target_branch`                 | 字符串  | 目标分支名称。 |
| `target_branch_protected`       | 布尔值 | 目标分支是否为[受保护分支](../repository/branches/protected.md)。 |
| `target`                        | 对象  | 目标项目详细信息。例如，名称和描述。 |
| `target_project_id`             | 整数 | 目标项目的 ID。 |
| `time_change`                   | 整数 | 花费时间的变更（秒）。 |
| `time_estimate`                 | 整数 | 时间估算（秒）。 |
| `title`                         | 字符串  | 合并请求的标题。 |
| `total_time_spent`              | 整数 | 总花费时间（秒）。 |
| `updated_at`                    | 字符串  | 合并请求的最后更新时间。 |
| `updated_by_id`                 | 整数 | 最后更新它的用户的 ID。 |
| `url`                           | 字符串  | 合并请求的 URL。 |

<a id="changes-field"></a>

### `changes` 字段

`changes` 字段仅包含操作期间修改的字段。
并非 `object_attributes` 中的所有字段都会出现在 `changes` 中。

每个更改的字段遵循以下格式：

```json
{
  "field_name": {
    "previous": "old_value",
    "current": "new_value"
  }
}
```

<a id="attributes"></a>

#### 属性

- `assignees`
- `blocking_discussions_resolved`
- `description`
- `draft`
- `head_pipeline_id`
- `labels`
- `last_edited_at`
- `last_edited_by_id`
- `merge_commit_sha`
- `merge_error`
- `merge_params`
- `merge_status`
- `merge_user_id`
- `merge_when_pipeline_succeeds`
- `milestone_id`
- `prepared_at`
- `reviewer_ids`
- `reviewers`
- `squash_commit_sha`
- `state_id`
- `target_branch`
- `time_change`
- `time_estimate`
- `title`
- `total_time_spent`
- `updated_at`
- `updated_by_id`

<a id="merge-request-action-specific-fields"></a>

### 合并请求操作特定字段

`object_attributes.oldrev` 字段仅在存在实际代码更改时的 `update` 操作中可用，例如：

- 新代码被推送到源分支。
- 应用了[建议](../merge_requests/reviews/suggestions.md)。

以下示例显示了带有 `oldrev` 的 `update` 事件（部分负载）：

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "object_attributes": {
    "action": "update",
    "oldrev": "e59094b8de0f2f91abbe4760a52d9137260252d8"
  }
}
```

<a id="system-initiated-merge-request-events"></a>

### 系统发起的合并请求事件

某些合并请求事件由系统自动触发，例如由于新的提交推送而重置批准时。这些系统发起的 Webhook 事件仅由推送事件触发，并在负载中包含更多字段：

- `object_attributes.system`：布尔字段。如果为 `true`，则事件由系统触发。如果为 `false`，则用户操作触发了该事件。
- `object_attributes.system_action`：字符串字段，仅当 `system` 为 `true` 时存在。提供有关系统操作的更多上下文。可用值为：

  - `approvals_reset_on_push`：项目已启用 **推送时重置批准**，并且推送了新提交。
  - `code_owner_approvals_reset_on_push`：项目已启用 **选择性代码所有者移除**，并且由于匹配 CODEOWNERS 规则的文件发生更改，代码所有者批准被重置。
- `object_attributes.action`：对于批准重置事件，值为：
  - 当合并请求从已批准变为未批准时，为 `unapproved`。
  - 当移除批准但未改变整体批准状态时，为 `unapproval`。

其他批准重置场景不会触发 Webhook。

以下示例显示了一个系统发起的事件（部分负载）：

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "object_attributes": {
    "action": "unapproved",
    "system": true,
    "system_action": "approvals_reset_on_push"
  }
}
```

<a id="reviewer-state-tracking"></a>

### 审核人状态跟踪

合并请求 Webhook 负载中的 `reviewers` 数组为每个审核人包含一个 `state` 字段。`state` 字段指示审核人的当前评审状态：

- `unreviewed`：审核人尚未评审合并请求
- `review_started`：审核人已开始评审但尚未完成
- `reviewed`：审核人已完成评审
- `requested_changes`：审核人已请求进行更改
- `approved`：审核人已批准合并请求
- `unapproved`：审核人先前已批准，但其批准被移除

以下示例显示了一个审核人数组（部分负载）：

```json
{
  "reviewers": [
    {
      "id": 6,
      "name": "User1",
      "username": "user1",
      "state": "unreviewed",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "email": "user1@example.com"
    }
  ]
}
```

<a id="re-request-review-events"></a>

### 重新请求评审事件

当为合并请求重新请求审核人时，会触发一个 Webhook，其中包含 `action: "update"`，并在 `changes` 对象中包含增强信息。更改负载包括：

- **先前状态**（第一个数组）：显示重新请求前审核人的状态，其中 `re_requested: false`
- **当前状态**（第二个数组）：显示重新请求后审核人的更新状态，对于被重新请求的审核人，其中 `re_requested: true`
- **状态转换**：演示审核人的状态如何变化（例如，从 `approved` 到 `unreviewed`）

以下示例显示了重新请求评审的更改（部分负载）：

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "object_attributes": {
    "action": "update"
  },
  "changes": {
    "reviewers": [
      [
        {
          "id": 6,
          "name": "User1",
          "username": "user1",
          "state": "approved",
          "re_requested": false,
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
          "email": "user1@example.com"
        }
      ],
      [
        {
          "id": 6,
          "name": "User1",
          "username": "user1",
          "state": "unreviewed",
          "re_requested": true,
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
          "email": "user1@example.com"
        }
      ]
    ]
  }
}
```

<a id="submit-review-events"></a>

### 提交评审事件

当审核人提交评审时，极狐GitLab 会触发一个包含 `action: "update"` 的 Webhook，反映审核人的新状态。
无论审核人是请求更改、将评审标记为已评审、批准还是取消批准，此规则均适用。
`changes` 对象在第一个数组中包含审核人的先前状态，在第二个数组中包含更新后的状态。
例如，请求更改的审核人会从 `review_started` 转换为 `requested_changes`。

`re_requested` 字段在两个数组中均为 `false`，因为提交的评审不是重新请求。

以下示例显示了提交评审的更改（部分负载）：

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "object_attributes": {
    "action": "update"
  },
  "changes": {
    "reviewers": [
      [
        {
          "id": 6,
          "name": "User1",
          "username": "user1",
          "state": "review_started",
          "re_requested": false,
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
          "email": "user1@example.com"
        }
      ],
      [
        {
          "id": 6,
          "name": "User1",
          "username": "user1",
          "state": "requested_changes",
          "re_requested": false,
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
          "email": "user1@example.com"
        }
      ]
    ]
  }
}
```

<a id="complete-payload-example"></a>

### 完整负载示例

请求头：

```plaintext
X-Gitlab-Event: Merge Request Hook
```

以下示例是 `open` 操作的完整合并请求 Webhook 负载。
为清晰起见，省略了已弃用的字段。有关已弃用字段及其推荐替代字段的列表，请参阅[已弃用字段](#deprecated-fields)。

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "user": {
    "id": 1,
    "name": "Alex Garcia",
    "username": "agarcia",
    "avatar_url": "https://www.gravatar.com/avatar/1a29da0ccd099482194440fac762f5ccb4ec53227761d1859979367644a889a5?s=80&d=identicon",
    "email": "agarcia@example.com"
  },
  "project": {
    "id": 2,
    "name": "Flight Management",
    "description": "Flight management application for tracking aircraft status.",
    "web_url": "http://gitlab.example.com/flightjs/flight-management",
    "avatar_url": null,
    "git_ssh_url": "ssh://git@gitlab.example.com:flightjs/flight-management.git",
    "git_http_url": "http://gitlab.example.com/flightjs/flight-management.git",
    "namespace": "Flightjs",
    "visibility_level": 0,
    "path_with_namespace": "flightjs/flight-management",
    "default_branch": "main",
    "ci_config_path": null
  },
  "object_attributes": {
    "author_id": 1,
    "created_at": "2026-01-16 05:56:22 UTC",
    "description": "This merge request adds input validation to the booking form.",
    "draft": false,
    "head_pipeline_id": null,
    "id": 93,
    "iid": 16,
    "last_edited_at": null,
    "last_edited_by_id": null,
    "merge_commit_sha": null,
    "merged_at": null,
    "merge_error": null,
    "merge_params": {
      "force_remove_source_branch": "1"
    },
    "merge_status": "checking",
    "merge_user_id": null,
    "merge_when_pipeline_succeeds": false,
    "milestone_id": 8,
    "source_branch": "feature/booking-validation",
    "source_project_id": 2,
    "squash_commit_sha": null,
    "state_id": 1,
    "target_branch": "main",
    "target_branch_protected": true,
    "target_project_id": 2,
    "time_estimate": 0,
    "title": "Add input validation to booking form",
    "updated_at": "2026-01-16 05:56:25 UTC",
    "updated_by_id": null,
    "prepared_at": "2026-01-16 05:56:25 UTC",
    "assignee_ids": [
      1
    ],
    "blocking_discussions_resolved": true,
    "detailed_merge_status": "checking",
    "first_contribution": true,
    "human_time_change": null,
    "human_time_estimate": null,
    "human_total_time_spent": null,
    "labels": [
      {
        "id": 19,
        "title": "enhancement",
        "color": "#adb21a",
        "project_id": null,
        "created_at": "2026-01-07 00:03:52 UTC",
        "updated_at": "2026-01-07 00:03:52 UTC",
        "template": false,
        "description": null,
        "type": "GroupLabel",
        "group_id": 24
      }
    ],
    "last_commit": {
      "id": "e59094b8de0f2f91abbe4760a52d9137260252d8",
      "message": "Add email format validation",
      "title": "Add email format validation",
      "timestamp": "2026-01-16T05:01:10+00:00",
      "url": "http://gitlab.example.com/flightjs/flight-management/-/commit/e59094b8de0f2f91abbe4760a52d9137260252d8",
      "author": {
        "name": "Alex Garcia",
        "email": "agarcia@example.com"
      }
    },
    "reviewer_ids": [
      25
    ],
    "source": {
      "id": 2,
      "name": "Flight Management",
      "description": "Flight management application for tracking aircraft status.",
      "web_url": "http://gitlab.example.com/flightjs/flight-management",
      "avatar_url": null,
      "git_ssh_url": "ssh://git@gitlab.example.com:flightjs/flight-management.git",
      "git_http_url": "http://gitlab.example.com/flightjs/flight-management.git",
      "namespace": "Flightjs",
      "visibility_level": 0,
      "path_with_namespace": "flightjs/flight-management",
      "default_branch": "main",
      "ci_config_path": null
    },
    "state": "opened",
    "system": false,
    "target": {
      "id": 2,
      "name": "Flight Management",
      "description": "Flight management application for tracking aircraft status.",
      "web_url": "http://gitlab.example.com/flightjs/flight-management",
      "avatar_url": null,
      "git_ssh_url": "ssh://git@gitlab.example.com:flightjs/flight-management.git",
      "git_http_url": "http://gitlab.example.com/flightjs/flight-management.git",
      "namespace": "Flightjs",
      "visibility_level": 0,
      "path_with_namespace": "flightjs/flight-management",
      "default_branch": "main",
      "ci_config_path": null
    },
    "time_change": 0,
    "total_time_spent": 0,
    "url": "http://gitlab.example.com/flightjs/flight-management/-/merge_requests/16",
    "approval_rules": [
      {
        "id": 4,
        "approvals_required": 0,
        "name": "All Members",
        "rule_type": "any_approver",
        "report_type": null,
        "merge_request_id": 93,
        "section": null,
        "modified_from_project_rule": false,
        "orchestration_policy_idx": null,
        "vulnerabilities_allowed": 0,
        "scanners": [],
        "severity_levels": [],
        "vulnerability_states": [
          "new_needs_triage",
          "new_dismissed"
        ],
        "security_orchestration_policy_configuration_id": null,
        "scan_result_policy_id": null,
        "applicable_post_merge": null,
        "project_id": 2,
        "approval_policy_rule_id": null,
        "updated_at": "2026-01-16 05:56:22 UTC",
        "created_at": "2026-01-16 05:56:22 UTC"
      }
    ],
    "action": "open",
    "actioned_at": "2026-01-16 05:56:26 UTC"
  },
  "labels": [
    {
      "id": 19,
      "title": "enhancement",
      "color": "#adb21a",
      "project_id": null,
      "created_at": "2026-01-07 00:03:52 UTC",
      "updated_at": "2026-01-07 00:03:52 UTC",
      "template": false,
      "description": null,
      "type": "GroupLabel",
      "group_id": 24
    }
  ],
  "changes": {
    "merge_status": {
      "previous": "preparing",
      "current": "checking"
    },
    "updated_at": {
      "previous": "2026-01-16 05:56:22 UTC",
      "current": "2026-01-16 05:56:25 UTC"
    },
    "prepared_at": {
      "previous": null,
      "current": "2026-01-16 05:56:25 UTC"
    }
  },
  "assignees": [
    {
      "id": 1,
      "name": "Alex Garcia",
      "username": "agarcia",
      "avatar_url": "https://www.gravatar.com/avatar/1a29da0ccd099482194440fac762f5ccb4ec53227761d1859979367644a889a5?s=80&d=identicon",
      "email": "[REDACTED]"
    }
  ],
  "reviewers": [
    {
      "id": 25,
      "name": "Sidney Jones",
      "username": "sjones",
      "avatar_url": "https://www.gravatar.com/avatar/1be419860e7f852e20ca2691e6b55949f7809177e7765181da42e4448491e367?s=80&d=identicon",
      "email": "[REDACTED]",
      "state": "unreviewed",
      "re_requested": false
    }
  ]
}
```

> [!note]
> `assignee_id` 和 `merge_status` 字段已[弃用](../../../api/merge_requests.md)。

<a id="wiki-page-events"></a>

## Wiki 页面事件

当 Wiki 页面被创建、更新或删除时，会触发 Wiki 页面事件。

请求头：

```plaintext
X-Gitlab-Event: Wiki Page Hook
```

负载示例：

```json
{
  "object_kind": "wiki_page",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
    "email": "admin@example.com"
  },
  "project": {
    "id": 1,
    "name": "awesome-project",
    "description": "This is awesome",
    "web_url": "http://example.com/root/awesome-project",
    "avatar_url": null,
    "git_ssh_url": "git@example.com:root/awesome-project.git",
    "git_http_url": "http://example.com/root/awesome-project.git",
    "namespace": "root",
    "visibility_level": 0,
    "path_with_namespace": "root/awesome-project",
    "default_branch": "master",
    "homepage": "http://example.com/root/awesome-project",
    "url": "git@example.com:root/awesome-project.git",
    "ssh_url": "git@example.com:root/awesome-project.git",
    "http_url": "http://example.com/root/awesome-project.git"
  },
  "wiki": {
    "web_url": "http://example.com/root/awesome-project/-/wikis/home",
    "git_ssh_url": "git@example.com:root/awesome-project.wiki.git",
    "git_http_url": "http://example.com/root/awesome-project.wiki.git",
    "path_with_namespace": "root/awesome-project.wiki",
    "default_branch": "master"
  },
  "object_attributes": {
    "title": "Awesome",
    "content": "awesome content goes here",
    "format": "markdown",
    "message": "adding an awesome page to the wiki",
    "slug": "awesome",
    "url": "http://example.com/root/awesome-project/-/wikis/awesome",
    "action": "create",
    "diff_url": "http://example.com/root/awesome-project/-/wikis/home/diff?version_id=78ee4a6705abfbff4f4132c6646dbaae9c8fb6ec",
    "version_id": "3ad67c972065298d226dd80b2b03e0fc2421e731"
  }
}
```

<a id="pipeline-events"></a>

## 流水线事件

当流水线的状态发生变化时，会触发流水线事件。

由被阻止的用户触发的流水线 Webhook 不会被处理。

流水线 Webhook 会公开 `object_attributes.name`。

请求头：

```plaintext
X-Gitlab-Event: Pipeline Hook
```

负载示例：

```json
{
  "object_kind": "pipeline",
  "object_attributes": {
    "id": 31,
    "iid": 3,
    "name": "Pipeline for branch: master",
    "ref": "master",
    "tag": false,
    "sha": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
    "before_sha": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
    "source": "merge_request_event",
    "status": "success",
    "detailed_status": "passed",
    "stages": [
      "build",
      "test",
      "deploy"
    ],
    "created_at": "2016-08-12 15:23:28 UTC",
    "finished_at": "2016-08-12 15:26:29 UTC",
    "duration": 63,
    "queued_duration": 10,
    "protected_ref": false,
    "default_branch": true,
    "variables": [
      {
        "key": "NESTOR_PROD_ENVIRONMENT",
        "value": "us-west-1"
      }
    ],
    "url": "http://example.com/gitlab-org/gitlab-test/-/pipelines/31"
  },
  "merge_request": {
    "id": 1,
    "iid": 1,
    "title": "Test",
    "source_branch": "test",
    "source_project_id": 1,
    "target_branch": "master",
    "target_project_id": 1,
    "state": "opened",
    "merge_status": "can_be_merged",
    "detailed_merge_status": "mergeable",
    "url": "http://192.168.64.1:3005/gitlab-org/gitlab-test/merge_requests/1"
  },
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
    "email": "user_email@gitlab.com"
  },
  "project": {
    "id": 1,
    "name": "Gitlab Test",
    "description": "Atque in sunt eos similique dolores voluptatem.",
    "web_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test",
    "avatar_url": null,
    "git_ssh_url": "git@192.168.64.1:gitlab-org/gitlab-test.git",
    "git_http_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test.git",
    "namespace": "Gitlab Org",
    "visibility_level": 20,
    "path_with_namespace": "gitlab-org/gitlab-test",
    "default_branch": "master",
    "ci_config_path": null
  },
  "commit": {
    "id": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
    "message": "test\n",
    "title": "test",
    "timestamp": "2016-08-12T17:23:21+02:00",
    "url": "http://example.com/gitlab-org/gitlab-test/commit/bcbb5ec396a2c0f828686f14fac9b80b780504f2",
    "author": {
      "name": "User",
      "email": "user@gitlab.com"
    }
  },
  "builds": [
    {
      "id": 380,
      "stage": "deploy",
      "name": "production",
      "status": "skipped",
      "created_at": "2016-08-12 15:23:28 UTC",
      "started_at": null,
      "finished_at": null,
      "duration": null,
      "queued_duration": null,
      "failure_reason": null,
      "when": "manual",
      "manual": true,
      "allow_failure": false,
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
        "email": "admin@example.com"
      },
      "runner": null,
      "artifacts_file": {
        "filename": null,
        "size": null
      },
      "environment": {
        "name": "production",
        "action": "start",
        "deployment_tier": "production"
      }
    },
    {
      "id": 377,
      "stage": "test",
      "name": "test-image",
      "status": "success",
      "created_at": "2016-08-12 15:23:28 UTC",
      "started_at": "2016-08-12 15:26:12 UTC",
      "finished_at": "2016-08-12 15:26:29 UTC",
      "duration": 17.0,
      "queued_duration": 196.0,
      "failure_reason": null,
      "when": "on_success",
      "manual": false,
      "allow_failure": false,
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
        "email": "admin@example.com"
      },
      "runner": {
        "id": 380987,
        "description": "shared-runners-manager-6.gitlab.com",
        "runner_type": "instance_type",
        "active": true,
        "is_shared": true,
        "tags": [
          "linux",
          "docker",
          "shared-runner"
        ]
      },
      "artifacts_file": {
        "filename": null,
        "size": null
      },
      "environment": null
    },
    {
      "id": 378,
      "stage": "test",
      "name": "test-build",
      "status": "failed",
      "created_at": "2016-08-12 15:23:28 UTC",
      "started_at": "2016-08-12 15:26:12 UTC",
      "finished_at": "2016-08-12 15:26:29 UTC",
      "duration": 17.0,
      "queued_duration": 196.0,
      "failure_reason": "script_failure",
      "when": "on_success",
      "manual": false,
      "allow_failure": false,
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
        "email": "admin@example.com"
      },
      "runner": {
        "id": 380987,
        "description": "shared-runners-manager-6.gitlab.com",
        "runner_type": "instance_type",
        "active": true,
        "is_shared": true,
        "tags": [
          "linux",
          "docker"
        ]
      },
      "artifacts_file": {
        "filename": null,
        "size": null
      },
      "environment": null
    },
    {
      "id": 376,
      "stage": "build",
      "name": "build-image",
      "status": "success",
      "created_at": "2016-08-12 15:23:28 UTC",
      "started_at": "2016-08-12 15:24:56 UTC",
      "finished_at": "2016-08-12 15:25:26 UTC",
      "duration": 17.0,
      "queued_duration": 196.0,
      "failure_reason": null,
      "when": "on_success",
      "manual": false,
      "allow_failure": false,
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
        "email": "admin@example.com"
      },
      "runner": {
        "id": 380987,
        "description": "shared-runners-manager-6.gitlab.com",
        "runner_type": "instance_type",
        "active": true,
        "is_shared": true,
        "tags": [
          "linux",
          "docker"
        ]
      },
      "artifacts_file": {
        "filename": null,
        "size": null
      },
      "environment": null
    },
    {
      "id": 379,
      "stage": "deploy",
      "name": "staging",
      "status": "created",
      "created_at": "2016-08-12 15:23:28 UTC",
      "started_at": null,
      "finished_at": null,
      "duration": null,
      "queued_duration": null,
      "failure_reason": null,
      "when": "on_success",
      "manual": false,
      "allow_failure": false,
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
        "email": "admin@example.com"
      },
      "runner": null,
      "artifacts_file": {
        "filename": null,
        "size": null
      },
      "environment": {
        "name": "staging",
        "action": "start",
        "deployment_tier": "staging"
      }
    }
  ],
  "source_pipeline": {
    "project": {
      "id": 41,
      "web_url": "https://gitlab.example.com/gitlab-org/upstream-project",
      "path_with_namespace": "gitlab-org/upstream-project"
    },
    "pipeline_id": 30,
    "job_id": 3401
  }
}
```

<a id="job-events"></a>

## 作业事件

当作业状态发生变化时，会触发作业事件。触发作业除外。

负载中的 `commit.id` 是流水线的 ID，而不是提交的 ID。

由被阻止的用户触发的作业事件不会被处理。

请求头：

```plaintext
X-Gitlab-Event: Job Hook
```

负载示例：

```json
{
  "object_kind": "build",
  "ref": "gitlab-script-trigger",
  "tag": false,
  "before_sha": "2293ada6b400935a1378653304eaf6221e0fdb8f",
  "sha": "2293ada6b400935a1378653304eaf6221e0fdb8f",
  "retries_count": 2,
  "build_id": 1977,
  "build_name": "test",
  "build_stage": "test",
  "build_status": "created",
  "build_created_at": "2021-02-23T02:41:37.886Z",
  "build_started_at": null,
  "build_finished_at": null,
  "build_created_at_iso": "2021-02-23T02:41:37Z",
  "build_started_at_iso": null,
  "build_finished_at_iso": null,
  "build_duration": null,
  "build_queued_duration": 1095.588715,
  "build_allow_failure": false,
  "build_failure_reason": "unknown_failure",
  "pipeline_id": 2366,
  "runner": {
    "id": 380987,
    "description": "shared-runners-manager-6.gitlab.com",
    "runner_type": "project_type",
    "active": true,
    "is_shared": false,
    "tags": [
      "linux",
      "docker"
    ]
  },
  "project_id": 380,
  "project_name": "gitlab-org/gitlab-test",
  "user": {
    "id": 3,
    "name": "User",
    "username": "user",
    "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon",
    "email": "user@gitlab.com"
  },
  "commit": {
    "id": 2366,
    "name": "Build pipeline",
    "sha": "2293ada6b400935a1378653304eaf6221e0fdb8f",
    "message": "test\n",
    "author_name": "User",
    "author_email": "user@gitlab.com",
    "author_url": "http://192.168.64.1:3005/user",
    "status": "created",
    "duration": null,
    "started_at": null,
    "finished_at": null,
    "started_at_iso": null,
    "finished_at_iso": null
  },
  "repository": {
    "name": "gitlab_test",
    "url": "http://192.168.64.1:3005/gitlab-org/gitlab-test",
    "description": "Atque in sunt eos similique dolores voluptatem.",
    "homepage": "http://192.168.64.1:3005/gitlab-org/gitlab-test",
    "git_ssh_url": "git@192.168.64.1:gitlab-org/gitlab-test.git",
    "git_http_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test.git",
    "visibility_level": 20
  },
  "project": {
    "id": 380,
    "name": "Gitlab Test",
    "description": "Atque in sunt eos similique dolores voluptatem.",
    "web_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test",
    "avatar_url": null,
    "git_ssh_url": "git@192.168.64.1:gitlab-org/gitlab-test.git",
    "git_http_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test.git",
    "namespace": "Gitlab Org",
    "visibility_level": 20,
    "path_with_namespace": "gitlab-org/gitlab-test",
    "default_branch": "master",
    "ci_config_path": null
  },
  "environment": null,
  "source_pipeline": {
    "project": {
      "id": 41,
      "web_url": "https://gitlab.example.com/gitlab-org/upstream-project",
      "path_with_namespace": "gitlab-org/upstream-project"
    },
    "pipeline_id": 30,
    "job_id": 3401
  }
}
```

<a id="number-of-retries"></a>

### 重试次数

`retries_count` 是一个整数，指示作业是否为重试。`0` 表示作业尚未重试。`1` 表示这是第一次重试。

<a id="pipeline-name"></a>

### 流水线名称

您可以使用 [`workflow:name`](../../../ci/yaml/_index.md#workflowname) 为流水线设置自定义名称。
如果流水线有名称，则该名称就是 `commit.name` 的值。

<a id="failure-reason"></a>

### 失败原因

`build_failure_reason` 使用与 [`retry:when`](../../../ci/yaml/_index.md#retrywhen) 相同的失败原因值，但排除 `always`。

如果作业未失败，极狐GitLab 会在此字段中返回 `unknown_failure`，因为没有适用的失败原因。要检查作业是否成功，请使用 `build_status` 而不是 `build_failure_reason`。

<a id="deployment-events"></a>

## 部署事件

部署事件在以下情况触发：

- 部署开始
- 部署成功
- 部署失败
- 部署被取消
- 部署被阻塞、等待批准或等待手动操作
- 部署被批准（仅限专业版和旗舰版）
- 部署被拒绝（仅限专业版和旗舰版）

`status` 字段反映触发事件的实体的新状态：

- 对于部署生命周期变更（`running`、`success`、`failed`、`canceled`、`blocked`），该字段与部署的当前状态一致。
- 对于批准操作，该字段与批准记录的最终状态（`approved`或`rejected`）一致。

负载中的 `deployable_id` 和 `deployable_url` 表示执行部署的 CI/CD 作业。
当部署事件通过 [API](../../../ci/environments/external_deployment_tools.md) 或 [`trigger` 作业](../../../ci/pipelines/downstream_pipelines.md) 发生时，`deployable_url` 为 `null`。

请求头：

```plaintext
X-Gitlab-Event: Deployment Hook
```

负载示例：

```json
{
  "object_kind": "deployment",
  "status": "success",
  "status_changed_at":"2021-04-28 21:50:00 +0200",
  "deployment_id": 15,
  "deployable_id": 796,
  "deployable_url": "http://10.126.0.2:3000/root/test-deployment-webhooks/-/jobs/796",
  "environment": "staging",
  "environment_tier": "staging",
  "environment_slug": "staging",
  "environment_external_url": "https://staging.example.com",
  "project": {
    "id": 30,
    "name": "test-deployment-webhooks",
    "description": "",
    "web_url": "http://10.126.0.2:3000/root/test-deployment-webhooks",
    "avatar_url": null,
    "git_ssh_url": "ssh://vlad@10.126.0.2:2222/root/test-deployment-webhooks.git",
    "git_http_url": "http://10.126.0.2:3000/root/test-deployment-webhooks.git",
    "namespace": "Administrator",
    "visibility_level": 0,
    "path_with_namespace": "root/test-deployment-webhooks",
    "default_branch": "master",
    "ci_config_path": "",
    "homepage": "http://10.126.0.2:3000/root/test-deployment-webhooks",
    "url": "ssh://vlad@10.126.0.2:2222/root/test-deployment-webhooks.git",
    "ssh_url": "ssh://vlad@10.126.0.2:2222/root/test-deployment-webhooks.git",
    "http_url": "http://10.126.0.2:3000/root/test-deployment-webhooks.git"
  },
  "short_sha": "279484c0",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "email": "admin@example.com"
  },
  "user_url": "http://10.126.0.2:3000/root",
  "commit_url": "http://10.126.0.2:3000/root/test-deployment-webhooks/-/commit/279484c09fbe69ededfced8c1bb6e6d24616b468",
  "commit_title": "Add new file"
}
```

<a id="deployment-approval-and-rejection-events"></a>

### 部署批准和拒绝事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

对需要批准的[受保护环境](../../../ci/environments/deployment_approvals.md)进行部署时，每次批准者批准或拒绝部署都会触发 Deployment Webhook。负载保持与其他部署事件相同的 `object_kind`，并添加批准专属字段：

- `status` 为 `approved` 或 `rejected`，反映批准操作。
- `status_changed_at` 是批准记录的时间，采用 ISO 8601 格式。
- `approver` 是记录批准或拒绝的用户。如果批准者未公开其邮箱，则 `approver.email` 字段为 `[REDACTED]`。
- `approval` 描述批准信息，包括授权批准的受保护环境规则。`approval.approval_rule.access_level_description` 字段是该规则的人类可读标签。
  - 对于基于角色的规则，该字段是与语言环境无关的标签，例如 `"Maintainers"`。
  - 对于用户范围或群组范围的规则，该字段是用户或群组的显示名称（用户控制的字符串）。接收方应将该字段视为不受信任的显示文本，并使用 `user_id`、`group_id` 和 `access_level` 进行机器可读的路由。

`approver` 和 `approval` 字段是批准和拒绝事件专属的，不存在于其他部署生命周期事件中。接收方可以通过 `status` 的值或这些字段的存在来识别批准事件。

负载示例：

```json
{
  "object_kind": "deployment",
  "status": "approved",
  "status_changed_at": "2026-05-08T10:30:00.000Z",
  "deployment_id": 15,
  "deployable_id": 796,
  "deployable_url": "http://10.126.0.2:3000/root/test-deployment-webhooks/-/jobs/796",
  "environment": "production",
  "environment_tier": "production",
  "environment_slug": "production",
  "environment_external_url": "https://production.example.com",
  "project": {
    "id": 30,
    "name": "test-deployment-webhooks",
    "web_url": "http://10.126.0.2:3000/root/test-deployment-webhooks",
    "path_with_namespace": "root/test-deployment-webhooks"
  },
  "short_sha": "279484c0",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "email": "admin@example.com"
  },
  "user_url": "http://10.126.0.2:3000/root",
  "commit_url": "http://10.126.0.2:3000/root/test-deployment-webhooks/-/commit/279484c09fbe69ededfced8c1bb6e6d24616b468",
  "commit_title": "Add new file",
  "approver": {
    "id": 5,
    "name": "Ops Lead",
    "username": "ops_lead",
    "avatar_url": "https://www.gravatar.com/avatar/abcdef1234567890?s=80&d=identicon",
    "email": "ops@example.com"
  },
  "approval": {
    "id": 42,
    "status": "approved",
    "comment": "LGTM",
    "created_at": "2026-05-08T10:30:00.000Z",
    "approval_rule": {
      "id": 7,
      "user_id": null,
      "group_id": null,
      "access_level": 40,
      "access_level_description": "Maintainers",
      "required_approvals": 2,
      "group_inheritance_type": 0
    }
  }
}
```

对于拒绝，`status` 和 `approval.status` 均为 `rejected`。当受保护环境不使用批准规则时，`approval.approval_rule` 的值为 `null`。

<a id="event-sequence-around-rejection-and-full-approval"></a>

#### 拒绝和完全批准前后的事件顺序

批准和生命周期 Webhook 是相互独立的。经过批准工作流的部署会产生多个具有相同 `deployment_id` 的 Webhook。当部署进入等待批准状态时，首先触发 `status: "blocked"` 事件。随后，批准或拒绝操作会产生各自的事件。

事件按以下顺序触发：

1. 当部署首次进入等待批准状态时，触发 `status: "blocked"` 事件。这是部署生命周期事件，不包含批准字段。
1. 随后，拒绝会产生 `status: "rejected"`（包含 `approver` 和 `approval`），当部署作业被丢弃时，同一部署会接着触发 `status: "failed"`。`failed` 事件是现有的旧版生命周期事件，不包含批准字段。
1. 最终批准会产生 `status: "approved"`，随后当部署作业启动时触发 `status: "running"`，然后是最终事件，例如 `status: "success"` 或 `status: "failed"`。

有关处理由拒绝导致的重复失败告警的指导，请参阅 [Webhook 故障排查](webhooks_troubleshooting.md#duplicate-deployment-failure-alerts-after-a-rejection)。

<a id="group-member-events"></a>

## 群组成员事件

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

这些事件仅针对[群组 Webhook](webhooks.md#group-webhooks)触发。

成员事件在以下情况触发：

- 用户被添加为群组成员。
- 用户的访问级别发生变化。
- 用户访问的过期日期被更新。
- 用户被从群组中移除。
- 用户请求访问群组。
- 访问请求被拒绝。

<a id="add-member-to-group"></a>

### 向群组添加成员

请求头：

```plaintext
X-Gitlab-Event: Member Hook
```

负载示例：

```json
{
  "created_at": "2020-12-11T04:57:22Z",
  "updated_at": "2020-12-11T04:57:22Z",
  "group_name": "webhook-test",
  "group_path": "webhook-test",
  "group_id": 100,
  "user_username": "test_user",
  "user_name": "Test User",
  "user_email": "testuser@webhooktest.com",
  "user_id": 64,
  "group_access": "Guest",
  "group_plan": null,
  "expires_at": "2020-12-14T00:00:00Z",
  "event_name": "user_add_to_group"
}
```

<a id="update-member-access-level-or-expiration-date"></a>

### 更新成员访问级别或过期日期

请求头：

```plaintext
X-Gitlab-Event: Member Hook
```

负载示例：

```json
{
  "created_at": "2020-12-11T04:57:22Z",
  "updated_at": "2020-12-12T08:48:19Z",
  "group_name": "webhook-test",
  "group_path": "webhook-test",
  "group_id": 100,
  "user_username": "test_user",
  "user_name": "Test User",
  "user_email": "testuser@webhooktest.com",
  "user_id": 64,
  "group_access": "Developer",
  "group_plan": null,
  "expires_at": "2020-12-20T00:00:00Z",
  "event_name": "user_update_for_group"
}
```

<a id="remove-member-from-group"></a>

### 从群组移除成员

请求头：

```plaintext
X-Gitlab-Event: Member Hook
```

负载示例：

```json
{
  "created_at": "2020-12-11T04:57:22Z",
  "updated_at": "2020-12-12T08:52:34Z",
  "group_name": "webhook-test",
  "group_path": "webhook-test",
  "group_id": 100,
  "user_username": "test_user",
  "user_name": "Test User",
  "user_email": "testuser@webhooktest.com",
  "user_id": 64,
  "group_access": "Guest",
  "group_plan": null,
  "expires_at": "2020-12-14T00:00:00Z",
  "event_name": "user_remove_from_group"
}
```

<a id="a-user-requests-access"></a>

### 用户请求访问

请求头：

```plaintext
X-Gitlab-Event: Member Hook
```

负载示例：

```json
{
  "created_at": "2020-12-11T04:57:22Z",
  "updated_at": "2020-12-12T08:52:34Z",
  "group_name": "webhook-test",
  "group_path": "webhook-test",
  "group_id": 100,
  "user_username": "test_user",
  "user_name": "Test User",
  "user_email": "testuser@webhooktest.com",
  "user_id": 64,
  "group_access": "Guest",
  "group_plan": null,
  "expires_at": "2020-12-14T00:00:00Z",
  "event_name": "user_access_request_to_group"
}
```

<a id="an-access-request-is-denied"></a>

### 访问请求被拒绝

请求头：

```plaintext
X-Gitlab-Event: Member Hook
```

负载示例：

```json
{
  "created_at": "2020-12-11T04:57:22Z",
  "updated_at": "2020-12-12T08:52:34Z",
  "group_name": "webhook-test",
  "group_path": "webhook-test",
  "group_id": 100,
  "user_username": "test_user",
  "user_name": "Test User",
  "user_email": "testuser@webhooktest.com",
  "user_id": 64,
  "group_access": "Guest",
  "group_plan": null,
  "expires_at": "2020-12-14T00:00:00Z",
  "event_name": "user_access_request_denied_for_group"
}
```

<a id="project-events"></a>

## 项目事件

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

这些事件仅针对[群组 Webhook](webhooks.md#group-webhooks)触发。

项目事件在以下情况触发：

- 在群组中[创建项目](#create-a-project-in-a-group)。
- 在群组中[删除项目](#delete-a-project-in-a-group)。

<a id="create-a-project-in-a-group"></a>

### 在群组中创建项目

请求头：

```plaintext
X-Gitlab-Event: Project Hook
```

负载示例：

```json
{
  "event_name": "project_create",
  "created_at": "2024-10-07T10:43:48Z",
  "updated_at": "2024-10-07T10:43:48Z",
  "name": "project1",
  "path": "project1",
  "path_with_namespace": "group1/project1",
  "project_id": 22,
  "project_namespace_id": 32,
  "owners": [{
    "name": "John",
    "email": "user1@example.com"
  }],
  "project_visibility": "private"
}
```

<a id="delete-a-project-in-a-group"></a>

### 在群组中删除项目

请求头：

```plaintext
X-Gitlab-Event: Project Hook
```

负载示例：

```json
{
  "event_name": "project_destroy",
  "created_at": "2024-10-07T10:43:48Z",
  "updated_at": "2024-10-07T10:43:48Z",
  "name": "project1",
  "path": "project1",
  "path_with_namespace": "group1/project1",
  "project_id": 22,
  "project_namespace_id": 32,
  "owners": [{
    "name": "John",
    "email": "user1@example.com"
  }],
  "project_visibility": "private"
}
```

<a id="subgroup-events"></a>

## 子群组事件

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

这些事件仅针对[群组 Webhook](webhooks.md#group-webhooks)触发。

子群组事件在以下情况触发：

- 在群组中[创建子群组](#create-a-subgroup-in-a-group)。
- 从群组中[移除子群组](#remove-a-subgroup-from-a-group)。

<a id="create-a-subgroup-in-a-group"></a>

### 在群组中创建子群组

请求头：

```plaintext
X-Gitlab-Event: Subgroup Hook
```

负载示例：

```json
{

  "created_at": "2021-01-20T09:40:12Z",
  "updated_at": "2021-01-20T09:40:12Z",
  "event_name": "subgroup_create",
  "name": "subgroup1",
  "path": "subgroup1",
  "full_path": "group1/subgroup1",
  "group_id": 10,
  "parent_group_id": 7,
  "parent_name": "group1",
  "parent_path": "group1",
  "parent_full_path": "group1"

}
```

<a id="remove-a-subgroup-from-a-group"></a>

### 从群组中移除子群组

当[子群组被转移到新的父群组](../../group/manage.md#transfer-a-group)时，不会触发此 Webhook。

请求头：

```plaintext
X-Gitlab-Event: Subgroup Hook
```

负载示例：

```json
{

  "created_at": "2021-01-20T09:40:12Z",
  "updated_at": "2021-01-20T09:40:12Z",
  "event_name": "subgroup_destroy",
  "name": "subgroup1",
  "path": "subgroup1",
  "full_path": "group1/subgroup1",
  "group_id": 10,
  "parent_group_id": 7,
  "parent_name": "group1",
  "parent_path": "group1",
  "parent_full_path": "group1"

}
```

<a id="feature-flag-events"></a>

## 功能标志事件

功能标志事件在功能标志开启或关闭时触发。

请求头：

```plaintext
X-Gitlab-Event: Feature Flag Hook
```

负载示例：

```json
{
  "object_kind": "feature_flag",
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
    "ci_config_path": null,
    "homepage":"http://example.com/gitlabhq/gitlab-test",
    "url":"http://example.com/gitlabhq/gitlab-test.git",
    "ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
    "http_url":"http://example.com/gitlabhq/gitlab-test.git"
  },
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "email": "admin@example.com"
  },
  "user_url": "http://example.com/root",
  "object_attributes": {
    "id": 6,
    "name": "test-feature-flag",
    "description": "test-feature-flag-description",
    "active": true
  }
}
```

<a id="release-events"></a>

## 发布事件

发布事件在发布被创建、更新或删除时触发。

负载中 `object_attributes.action` 的可用值为：

- `create`
- `update`
- `delete`

请求头：

```plaintext
X-Gitlab-Event: Release Hook
```

负载示例：

```json
{
  "id": 1,
  "created_at": "2020-11-02 12:55:12 UTC",
  "description": "v1.1 has been released",
  "name": "v1.1",
  "released_at": "2020-11-02 12:55:12 UTC",
  "tag": "v1.1",
  "object_kind": "release",
  "project": {
    "id": 2,
    "name": "release-webhook-example",
    "description": "",
    "web_url": "https://example.com/gitlab-org/release-webhook-example",
    "avatar_url": null,
    "git_ssh_url": "ssh://git@example.com/gitlab-org/release-webhook-example.git",
    "git_http_url": "https://example.com/gitlab-org/release-webhook-example.git",
    "namespace": "Gitlab",
    "visibility_level": 0,
    "path_with_namespace": "gitlab-org/release-webhook-example",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "https://example.com/gitlab-org/release-webhook-example",
    "url": "ssh://git@example.com/gitlab-org/release-webhook-example.git",
    "ssh_url": "ssh://git@example.com/gitlab-org/release-webhook-example.git",
    "http_url": "https://example.com/gitlab-org/release-webhook-example.git"
  },
  "url": "https://example.com/gitlab-org/release-webhook-example/-/releases/v1.1",
  "action": "create",
  "assets": {
    "count": 5,
    "links": [
      {
        "id": 1,
        "link_type": "other",
        "name": "Changelog",
        "url": "https://example.net/changelog"
      }
    ],
    "sources": [
      {
        "format": "zip",
        "url": "https://example.com/gitlab-org/release-webhook-example/-/archive/v1.1/release-webhook-example-v1.1.zip"
      },
      {
        "format": "tar.gz",
        "url": "https://example.com/gitlab-org/release-webhook-example/-/archive/v1.1/release-webhook-example-v1.1.tar.gz"
      },
      {
        "format": "tar.bz2",
        "url": "https://example.com/gitlab-org/release-webhook-example/-/archive/v1.1/release-webhook-example-v1.1.tar.bz2"
      },
      {
        "format": "tar",
        "url": "https://example.com/gitlab-org/release-webhook-example/-/archive/v1.1/release-webhook-example-v1.1.tar"
      }
    ]
  },
  "commit": {
    "id": "ee0a3fb31ac16e11b9dbb596ad16d4af654d08f8",
    "message": "Release v1.1",
    "title": "Release v1.1",
    "timestamp": "2020-10-31T14:58:32+11:00",
    "url": "https://example.com/gitlab-org/release-webhook-example/-/commit/ee0a3fb31ac16e11b9dbb596ad16d4af654d08f8",
    "author": {
      "name": "Example User",
      "email": "user@example.com"
    }
  }
}
```

<a id="milestone-events"></a>

## 里程碑事件

里程碑事件在里程碑被创建、关闭、重新打开或删除时触发。

负载中 `object_attributes.action` 的可用值为：

- `create`
- `close`
- `reopen`

请求头：

```plaintext
X-Gitlab-Event: Milestone Hook
```

负载示例：

```json
{
  "object_kind": "milestone",
  "event_type": "milestone",
  "project": {
    "id": 1,
    "name": "Gitlab Test",
    "description": "Aut reprehenderit ut est.",
    "web_url": "http://example.com/gitlabhq/gitlab-test",
    "avatar_url": null,
    "git_ssh_url": "git@example.com:gitlabhq/gitlab-test.git",
    "git_http_url": "http://example.com/gitlabhq/gitlab-test.git",
    "namespace": "GitlabHQ",
    "visibility_level": 20,
    "path_with_namespace": "gitlabhq/gitlab-test",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "http://example.com/gitlabhq/gitlab-test",
    "url": "http://example.com/gitlabhq/gitlab-test.git",
    "ssh_url": "git@example.com:gitlabhq/gitlab-test.git",
    "http_url": "http://example.com/gitlabhq/gitlab-test.git"
  },
  "object_attributes": {
    "id": 61,
    "iid": 10,
    "title": "v1.0",
    "description": "First stable release",
    "state": "active",
    "created_at": "2025-06-16 14:10:57 UTC",
    "updated_at": "2025-06-16 14:10:57 UTC",
    "due_date": "2025-06-30",
    "start_date": "2025-06-16",
    "group_id": null,
    "project_id": 1
  },
  "action": "create"
}
```

<a id="emoji-events"></a>

## 表情事件

当在以下对象上添加或移除[表情反应](../../emoji_reactions.md)时，会触发表情事件：

- 议题
- 合并请求
- 项目代码片段
- Wiki 页面
- 以下对象的评论：
  - 议题
  - 合并请求
  - 项目代码片段
  - Wiki 页面
  - 提交

负载中 `object_attributes.action` 的可用值为：

- `award` 用于添加反应
- `revoke` 用于移除反应

请求头：

```plaintext
X-Gitlab-Event: Emoji Hook
```

负载示例：

```json
{
  "object_kind": "emoji",
  "event_type": "award",
  "user": {
    "id": 1,
    "name": "Blake Bergstrom",
    "username": "root",
    "avatar_url": "http://example.com/uploads/-/system/user/avatar/1/avatar.png",
    "email": "[REDACTED]"
  },
  "project_id": 6,
  "project": {
    "id": 6,
    "name": "Flight",
    "description": "Velit fugit aperiam illum deleniti odio sequi.",
    "web_url": "http://example.com/flightjs/Flight",
    "avatar_url": null,
    "git_ssh_url": "ssh://git@example.com/flightjs/Flight.git",
    "git_http_url": "http://example.com/flightjs/Flight.git",
    "namespace": "Flightjs",
    "visibility_level": 20,
    "path_with_namespace": "flightjs/Flight",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "http://example.com/flightjs/Flight",
    "url": "ssh://git@example.com/flightjs/Flight.git",
    "ssh_url": "ssh://git@example.com/flightjs/Flight.git",
    "http_url": "http://example.com/flightjs/Flight.git"
  },
  "object_attributes": {
    "user_id": 1,
    "created_at": "2023-07-04 20:44:11 UTC",
    "id": 1,
    "name": "thumbsup",
    "awardable_type": "Note",
    "awardable_id": 363,
    "updated_at": "2023-07-04 20:44:11 UTC",
    "action": "award",
    "awarded_on_url": "http://example.com/flightjs/Flight/-/issues/42#note_363"
  },
  "note": {
    "attachment": null,
    "author_id": 1,
    "change_position": null,
    "commit_id": null,
    "created_at": "2023-07-04 15:09:55 UTC",
    "discussion_id": "c3d97fd471f210a5dc8b97a409e3bea95ee06c14",
    "id": 363,
    "line_code": null,
    "note": "Testing 123",
    "noteable_id": 635,
    "noteable_type": "Issue",
    "original_position": null,
    "position": null,
    "project_id": 6,
    "resolved_at": null,
    "resolved_by_id": null,
    "resolved_by_push": null,
    "st_diff": null,
    "system": false,
    "type": null,
    "updated_at": "2023-07-04 19:58:46 UTC",
    "updated_by_id": null,
    "description": "Testing 123",
    "url": "http://example.com/flightjs/Flight/-/issues/42#note_363"
  },
  "issue": {
    "author_id": 1,
    "closed_at": null,
    "confidential": false,
    "created_at": "2023-07-04 14:59:43 UTC",
    "description": "Issue description!",
    "discussion_locked": null,
    "due_date": null,
    "id": 635,
    "iid": 42,
    "last_edited_at": null,
    "last_edited_by_id": null,
    "milestone_id": null,
    "moved_to_id": null,
    "duplicated_to_id": null,
    "project_id": 6,
    "relative_position": 18981,
    "state_id": 1,
    "time_estimate": 0,
    "title": "New issue!",
    "updated_at": "2023-07-04 15:09:55 UTC",
    "updated_by_id": null,
    "weight": null,
    "health_status": null,
    "url": "http://example.com/flightjs/Flight/-/issues/42",
    "total_time_spent": 0,
    "time_change": 0,
    "human_total_time_spent": null,
    "human_time_change": null,
    "human_time_estimate": null,
    "assignee_ids": [
      1
    ],
    "assignee_id": 1,
    "labels": [

    ],
    "state": "opened",
    "severity": "unknown"
  }
}
```

<a id="project-and-group-access-token-events"></a>

## 项目和群组访问令牌事件

访问令牌过期事件在[访问令牌](../../../security/tokens/_index.md)过期前触发。这些事件在以下时间触发：

- 令牌过期前 7 天
- 令牌过期前 30 天（需要配置）
- 令牌过期前 60 天（需要配置）

有关配置 30 天和 60 天通知的信息，请参阅：

- [为项目访问令牌过期添加额外的 Webhook 触发器](../settings/_index.md#add-additional-webhook-triggers-for-project-access-token-expiration)。
- [为群组访问令牌过期添加额外的 Webhook 触发器](../../group/manage.md#add-additional-webhook-triggers-for-group-access-token-expiration)。

负载中 `event_name` 的可用值为：

- `expiring_access_token`

请求头：

```plaintext
X-Gitlab-Event: Resource Access Token Hook
```

项目负载示例：

```json
{
  "object_kind": "access_token",
  "project": {
    "id": 7,
    "name": "Flight",
    "description": "Eum dolore maxime atque reprehenderit voluptatem.",
    "web_url": "https://example.com/flightjs/Flight",
    "avatar_url": null,
    "git_ssh_url": "ssh://git@example.com/flightjs/Flight.git",
    "git_http_url": "https://example.com/flightjs/Flight.git",
    "namespace": "Flightjs",
    "visibility_level": 0,
    "path_with_namespace": "flightjs/Flight",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "https://example.com/flightjs/Flight",
    "url": "ssh://git@example.com/flightjs/Flight.git",
    "ssh_url": "ssh://git@example.com/flightjs/Flight.git",
    "http_url": "https://example.com/flightjs/Flight.git"
  },
  "object_attributes": {
    "user_id": 90,
    "created_at": "2024-01-24 16:27:40 UTC",
    "id": 25,
    "name": "acd",
    "expires_at": "2024-01-26",
    "last_used_at": "2024-01-20 10:15:30 UTC"
  },
  "event_name": "expiring_access_token"
}
```

群组负载示例：

```json
{
  "object_kind": "access_token",
  "group": {
    "group_name": "Twitter",
    "group_path": "twitter",
    "group_id": 35,
    "full_path": "twitter"
  },
  "object_attributes": {
    "user_id": 90,
    "created_at": "2024-01-24 16:27:40 UTC",
    "id": 25,
    "name": "acd",
    "expires_at": "2024-01-26",
    "last_used_at": "2024-01-20 10:15:30 UTC"
  },
  "event_name": "expiring_access_token"
}
```

<a id="project-and-group-deploy-token-events"></a>

## 项目和群组部署令牌事件

部署令牌过期事件在[部署令牌](../../../security/tokens/_index.md)过期前触发。这些事件在以下时间触发：

- 令牌过期前 7 天。
- 令牌过期前 30 天。
- 令牌过期前 60 天。

负载中 `event_name` 的可用值为：

- `expiring_deploy_token`

请求头：

```plaintext
X-Gitlab-Event: Resource Deploy Token Hook
```

项目负载示例：

```json
{
  "object_kind": "deploy_token",
  "project": {
    "id": 2,
    "name": "Gitlab Test",
    "description": "Voluptates sit architecto quos distinctio.",
    "web_url": "https://gitlab.example.com/gitlab-org/gitlab-test",
    "avatar_url": null,
    "git_ssh_url": "ssh://git@gitlab.example.com:2222/gitlab-org/gitlab-test.git",
    "git_http_url": "https://gitlab.example.com/gitlab-org/gitlab-test.git",
    "namespace": "Gitlab Org",
    "visibility_level": 10,
    "path_with_namespace": "gitlab-org/gitlab-test",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "https://gitlab.example.com/gitlab-org/gitlab-test",
    "url": "ssh://git@gitlab.example.com:2222/gitlab-org/gitlab-test.git",
    "ssh_url": "ssh://git@gitlab.example.com:2222/gitlab-org/gitlab-test.git",
    "http_url": "https://gitlab.example.com/gitlab-org/gitlab-test.git"
  },
  "object_attributes": {
    "id": 79,
    "name": "seven-days-6days",
    "expires_at": "2025-08-03 07:57:25 UTC",
    "created_at": "2025-07-28 07:57:25 UTC",
    "revoked": false,
    "deploy_token_type": "project_type"
  },
  "event_name": "expiring_deploy_token"
}
```

<a id="vulnerability-events"></a>

## 漏洞事件

漏洞事件在以下情况触发：

- 创建漏洞。
- 漏洞的[状态发生变化](../../application_security/vulnerabilities/_index.md#vulnerability-status-values)。
- 议题被链接到漏洞。

请求头：

```plaintext
X-Gitlab-Event: Vulnerability Hook
```

负载示例：

```json
{
  "object_kind": "vulnerability",
  "object_attributes": {
    "url": "https://example.com/flightjs/Flight/-/security/vulnerabilities/1",
    "title": "REXML DoS vulnerability",
    "state": "confirmed",
    "project_id": 50,
    "location": {
      "file": "Gemfile.lock",
      "dependency": {
        "package": {
          "name": "rexml"
        },
        "version": "3.3.1"
      }
    },
    "cvss": [
      {
        "vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H",
        "vendor": "NVD"
      }
    ],
    "severity": "high",
    "severity_overridden": false,
    "identifiers": [
      {
        "name": "Gemnasium-29dce398-220a-4315-8c84-16cd8b6d9b05",
        "external_id": "29dce398-220a-4315-8c84-16cd8b6d9b05",
        "external_type": "gemnasium",
        "url": "https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/blob/master/gem/rexml/CVE-2024-41123.yml"
      },
      {
        "name": "CVE-2024-41123",
        "external_id": "CVE-2024-41123",
        "external_type": "cve",
        "url": "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-41123"
      }
    ],
    "issues": [
      {
        "title": "REXML ReDoS vulnerability",
        "url": "https://example.com/flightjs/Flight/-/issues/1",
        "created_at": "2025-01-08T00:46:14.429Z",
        "updated_at": "2025-01-08T00:46:14.429Z"
      }
    ],
    "report_type": "dependency_scanning",
    "scanner_external_id": "gitlab-sbom-vulnerability-scanner",
    "confidence": "unknown",
    "confidence_overridden": false,
    "confirmed_at": "2025-01-08T00:46:14.413Z",
    "confirmed_by_id": 1,
    "dismissed_at": null,
    "dismissed_by_id": null,
    "resolved_at": null,
    "resolved_by_id": null,
    "auto_resolved": false,
    "resolved_on_default_branch": false,
    "created_at": "2025-01-08T00:46:14.413Z",
    "updated_at": "2025-01-08T00:46:14.413Z"
  }
}
```
