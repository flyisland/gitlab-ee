---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 应用中固定的速率限制。
title: 不可配置的速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 在应用中强制执行以下速率限制。

| 限制                                | 速率限制                                                     | 详情 |
|:-------------------------------------|:---------------------------------------------------------------|:--------|
| 变更日志生成                 | 每个用户每个项目每分钟 5 次调用                        | 适用于 `:id/repository/changelog` 端点。该限制在 `GET` 和 `POST` 操作之间共享。 |
| 提交差异文件                    | 每分钟 6 个请求                                          | 适用于展开的提交差异文件（`/[group]/[project]/-/commit/[:sha]/diff_files?expanded=1`）。该限制对已认证请求按用户计，对未认证请求按 IP 地址计。 |
| 删除部署                  | 每个已认证用户每分钟 500 个请求                 | 适用于使用 `DELETE /projects/:id/deployments/:deployment_id` [删除部署](../api/deployments.md#delete-a-deployment)。减少大规模删除部署对基础设施的影响。在极狐GitLab 19.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/243738)。 |
| FogBugz 导入                       | 每个用户每分钟 1 次触发导入                         | 适用于从 FogBugz 触发项目导入。在极狐GitLab 17.6 中引入。 |
| GitHub 导入                        | 每个用户每分钟 6 次触发导入                        | 适用于从 GitHub 触发项目导入。 |
| 新用户账户                    | 每个 IP 地址每分钟 20 次调用                             | 适用于 `/users/sign_up` 端点。缓解大规模探测已使用的用户名或电子邮件地址的尝试。 |
| 通知电子邮件                  | 每个用户每个项目或群组每 24 小时 1,000 条通知 | 适用于与项目或群组相关的通知电子邮件。在极狐GitLab 17.2 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/439101)。 |
| 离线迁移导出和导入 | 每个用户每分钟 6 个请求                                 | 适用于[离线迁移](../user/import/gitlab_instances/offline-transfer-migrations.md)导出和导入，两者分别限制。在极狐GitLab 19.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/209344)。 |
| 代码仓库归档                  | 每个用户每分钟 5 个请求                                 | 适用于通过 UI 或 API [下载代码仓库归档](../api/repositories.md#retrieve-file-archive-from-a-repository)。该限制适用于项目以及发起下载的用户。 |
| 代码仓库 blob 和文件访问      | 每个项目每个对象每分钟 5 次调用                      | 适用于[代码仓库 blob](../api/repositories.md#retrieve-a-blob-from-a-repository) 和[代码仓库文件](../api/repository_files.md#retrieve-a-file-from-a-repository)端点上大于 10 MB 的文件。在极狐GitLab 18.1 中[引入](https://gitlab.com/gitlab-org/security/gitlab/-/issues/1302)。 |
| 创建代码片段                     | 每个已认证用户每小时 300 个请求                   | 适用于使用 `POST /snippets` [创建代码片段](../api/snippets.md#create-a-snippet)、使用 `POST /projects/:id/snippets` [创建项目代码片段](../api/project_snippets.md#create-a-snippet)，以及极狐GitLab UI 使用的 `createSnippet` GraphQL 变更。该限制在这三者之间共享。在极狐GitLab 19.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/251927)。 |
| 更新用户名                      | 每个已认证用户每分钟 10 次调用                     | 限制用户名更改的频率。缓解大规模探测哪些用户名已被使用的尝试。 |
| 用户名是否存在                      | 每个 IP 地址每分钟 20 次调用                             | 适用于内部 `/users/:username/exists` 端点，该端点检查所选用户名是否已被占用。 |
