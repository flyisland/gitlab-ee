---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Rake 任务
description: 管理与运维 Rake 任务。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供 [Rake](https://ruby.github.io/rake/) 任务，协助您完成常见的管理与运维流程。

除非某个任务的文档另有明确说明，否则所有 Rake 任务都必须在 Rails 节点上运行。

您可以通过以下方式执行极狐GitLab Rake 任务：

- 对于 Linux 软件包和 GitLab Helm chart 安装，使用 `gitlab-rake <raketask>`。
- 对于自行编译的安装，使用 `bundle exec rake <raketask>`。

<a id="available-rake-tasks"></a>

## 可用的 Rake 任务

以下 Rake 任务可供极狐GitLab 使用：

| 任务                                                                                                 | 描述 |
|:------------------------------------------------------------------------------------------------------|:------------|
| [访问令牌过期任务](tokens/_index.md)                                                     | 批量延长或移除访问令牌的过期日期。 |
| [AI 目录外部 Agent](ai_catalog.md)                                                           | 导入 AI 目录外部 Agent。 |
| [备份与恢复](../backup_restore/_index.md)                                                    | 在服务器之间备份、恢复和迁移极狐GitLab 实例。 |
| [清理](cleanup.md)                                                                                | 清理极狐GitLab 实例中不需要的条目。 |
| 开发                                                                                           | 面向 GitLab 贡献者的任务。更多信息，请参阅开发文档。 |
| [Elasticsearch](../../integration/advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks) | 在极狐GitLab 实例中维护 Elasticsearch。 |
| [常规维护](maintenance.md)                                                                 | 常规维护和自检任务。 |
| [GitHub 导入](../../user/project/import/github.md)                                                  | 从 GitHub 检索并导入代码仓库。 |
| [导入大型项目导出](project_import_export.md#import-large-projects)                        | 导入大型极狐GitLab [项目导出](../../user/project/settings/import_export.md)。 |
| [接收邮件](incoming_email.md)                                                                   | 与接收邮件相关的任务。 |
| [完整性检查](check.md)                                                                          | 检查代码仓库、文件、LDAP 等的完整性。 |
| [保留引用](keep_around.md)                                                              | 查找某个项目的所有孤立保留引用。 |
| [LDAP 维护](ldap.md)                                                                           | 与 [LDAP](../auth/ldap/_index.md) 相关的任务。 |
| [密码](password.md)                                                                               | 密码管理任务。 |
| [Praefect Rake 任务](praefect.md)                                                                    | 与 [Praefect](../gitaly/praefect/_index.md) 相关的任务。 |
| [项目导入/导出](project_import_export.md)                                                     | 为[项目导出和导入](../../user/project/settings/import_export.md)做准备。 |
| [Sidekiq 作业迁移](../sidekiq/sidekiq_job_migration.md)                                          | 将计划在未来日期执行的 Sidekiq 作业迁移到新队列。 |
| [密钥管理器维护](../secrets_manager/maintenance.md#enable-secrets-access-from-external-requests) | 为现有密钥管理器启用来自外部请求的 API 认证。 |
| [密钥管理器恢复密钥](../secrets_manager/recovery_key.md)                                   | 存储、查看和获取 OpenBao 恢复密钥，并从中生成根令牌。 |
| [服务台邮件](service_desk_email.md)                                                           | 与服务台邮件相关的任务。 |
| [SMTP 维护](smtp.md)                                                                           | 与 SMTP 相关的任务。 |
| [SPDX 许可证列表导入](spdx.md)                                                                   | 导入 [SPDX 许可证列表](https://spdx.org/licenses/)的本地副本，用于匹配[许可证审批策略](../../user/compliance/license_approval_policies.md)。 |
| [重置用户密码](../../security/reset_user_password.md#use-a-rake-task)                         | 使用 Rake 重置用户密码。 |
| [语义代码搜索](../semantic_code_search.md#check-semantic-code-search-status) | 检查语义代码搜索状态。 |
| [上传迁移](uploads/migrate.md)                                                                 | 在本地存储和对象存储之间迁移上传内容。 |
| [上传清理](uploads/sanitize.md)                                                               | 从上传到早期版本极狐GitLab 的图片中移除 EXIF 数据。 |
| 服务数据                                                                                          | 生成 Service Ping 并对其进行故障排除。更多信息，请参阅 Service Ping 开发文档。 |
| [用户管理](user_management.md)                                                                 | 执行用户管理任务。 |
| [Webhook 管理](web_hooks.md)                                                                | 维护项目 webhook。 |
| [X.509 签名](x509_signatures.md)                                                                | 更新 X.509 提交签名，当证书存储发生变化时，此操作会很有用。 |

列出所有可用的 Rake 任务：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake -vT
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

```shell
gitlab-rake -vT
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
cd /home/git/gitlab
sudo -u git -H bundle exec rake -vT RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}
