---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Rake 任务
description: Administration and operational Rake tasks.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了 [Rake](https://ruby.github.io/rake/) 任务来帮助你完成常见的管理和运维流程。

除非特定任务的文件另有说明，否则所有 Rake 任务都必须在 Rails 节点上运行。

你可以通过以下方式执行极狐GitLab Rake 任务：

- `gitlab-rake <raketask>` 适用于 [Linux 软件包](https://gitlab.cn/docs/omnibus/) 和 [极狐GitLab Helm Chart](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/#gitlab-specific-kubernetes-information) 安装。
- `bundle exec rake <raketask>` 适用于 [自编译](../../install/self_compiled/_index.md) 安装。

<a id="available-rake-tasks"></a>

## 可用 Rake 任务

以下 Rake 任务可在极狐GitLab 中使用：

| 任务                                                                                                 | 描述 |
|:------------------------------------------------------------------------------------------------------|:------------|
| [访问令牌过期任务](tokens/_index.md)                                                                    | 批量延长或删除访问令牌的过期日期。 |
| [AI 目录外部代理](ai_catalog.md)                                                                       | 种子 AI 目录外部代理。 |
| [备份和恢复](../backup_restore/_index.md)                                                              | 备份、恢复和跨服务器迁移极狐GitLab 实例。 |
| [清理](cleanup.md)                                                                                     | 清理极狐GitLab 实例中不需要的条目。 |
| 开发                                                                                                   | 面向极狐GitLab 贡献者的任务。更多信息请参见开发文档。 |
| [Elasticsearch](../../integration/advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks) | 维护极狐GitLab 实例中的 Elasticsearch。 |
| [常规维护](maintenance.md)                                                                             | 常规维护和自检任务。 |
| [GitHub 导入](../../user/project/import/github.md)                                                    | 从 GitHub 检索并导入仓库。 |
| [导入大型项目导出](project_import_export.md#import-large-projects)                                    | 导入大型极狐GitLab [项目导出](../../user/project/settings/import_export.md)。 |
| [接收邮件](incoming_email.md)                                                                           | 与接收邮件相关的任务。 |
| [完整性检查](check.md)                                                                                  | 检查仓库、文件、LDAP 等的完整性。 |
| [保留引用](keep_around.md)                                                                              | 查找项目中所有孤儿保留引用。 |
| [LDAP 维护](ldap.md)                                                                                   | [LDAP](../auth/ldap/_index.md) 相关任务。 |
| [密码](password.md)                                                                                     | 密码管理任务。 |
| [Praefect Rake 任务](praefect.md)                                                                      | [Praefect](../gitaly/praefect/_index.md) 相关任务。 |
| [项目导入/导出](project_import_export.md)                                                               | 为[项目导出和导入](../../user/project/settings/import_export.md)做准备。 |
| [Sidekiq 作业迁移](../sidekiq/sidekiq_job_migration.md)                                                | 将安排在未来日期执行的 Sidekiq 作业迁移到新队列。 |
| [Service Desk 邮件](service_desk_email.md)                                                             | 与 Service Desk 邮件相关的任务。 |
| [SMTP 维护](smtp.md)                                                                                    | SMTP 相关任务。 |
| [SPDX 许可证列表导入](spdx.md)                                                                          | 导入 [SPDX 许可证列表](https://spdx.org/licenses/) 的本地副本，用于匹配[许可证批准策略](../../user/compliance/license_approval_policies.md)。 |
| [重置用户密码](../../security/reset_user_password.md#use-a-rake-task)                                   | 使用 Rake 重置用户密码。 |
| [语义代码搜索](../../user/gitlab_duo/semantic_code_search.md#check-semantic-code-search-status)          | 检查语义代码搜索状态。 |
| [上传迁移](uploads/migrate.md)                                                                           | 在本地存储和对象存储之间迁移上传的文件。 |
| [上传净化](uploads/sanitize.md)                                                                          | 删除上传到较早极狐GitLab 版本图片中的 EXIF 数据。 |
| 服务数据                                                                                                | 生成并排查 Service Ping 故障。更多信息请参见 Service Ping 开发文档。 |
| [用户管理](user_management.md)                                                                           | 执行用户管理任务。 |
| [Webhook 管理](web_hooks.md)                                                                             | 维护项目 Webhook。 |
| [X.509 签名](x509_signatures.md)                                                                         | 更新 X.509 提交签名，当证书存储发生变化时可能会有用。 |

要列出所有可用 Rake 任务：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
sudo gitlab-rake -vT
```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

```shell
gitlab-rake -vT
```

{{< /tab >}}

{{< tab title="自编译（源码）" >}}

```shell
cd /home/git/gitlab
sudo -u git -H bundle exec rake -vT RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

