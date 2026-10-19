---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 管理概览。
title: 开始管理极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

开始使用极狐GitLab 管理功能。配置您的组织及其身份验证，然后保护、监控和备份极狐GitLab。

<a id="authentication"></a>

## 身份验证

身份验证是确保安装安全的第一步。

- [为所有用户强制启用双重身份验证（2FA）](../security/two_factor_authentication.md)。
- 确保用户执行以下操作：
  - 选择一个强且安全的密码。如有可能，将其存储在密码管理系统中。
  - 如果未为所有人配置，请为您的账户开启[双重身份验证（2FA）](../user/profile/account/two_factor_authentication.md)。
    此一次性密钥代码是额外的防护措施，即使入侵者获得了您的密码，也能将其拒之门外。
  - 添加备用电子邮件。如果您无法访问自己的账户，极狐GitLab 支持团队可以更快地为您提供帮助。
  - 保存或打印您的恢复代码。如果您无法访问身份验证设备，可以使用这些恢复代码登录您的极狐GitLab 账户。
  - 将 [SSH 密钥](../user/ssh.md)添加到您的个人资料中。您可以根据需要使用 SSH 生成恢复代码。
  - 创建[个人访问令牌](../user/profile/personal_access_tokens.md)。使用 2FA 时，您可以使用这些令牌访问极狐GitLab API。

<a id="projects-and-groups"></a>

## 项目和群组

通过配置群组和项目来组织您的环境。

- [项目](../user/project/working_with_projects.md)：为您的文件和代码指定一个归属位置，或在业务类别中跟踪和组织议题。
- [群组](../user/group/_index.md)：组织用户或项目的集合。使用这些群组可以快速分配人员和项目。
- [角色](../user/permissions.md)：定义用户对项目和群组的访问权限和可见性。


开始使用：

- 创建一个[项目](../user/project/_index.md)。
- 创建一个[群组](../user/group/_index.md#create-a-group)。
- 向该群组[添加成员](../user/group/_index.md#add-users-to-a-group)。
- 创建一个[子群组](../user/group/subgroups/_index.md#create-a-subgroup)。
- 向该子群组[添加成员](../user/group/subgroups/_index.md#subgroup-membership)。
- 开启[外部授权控制](settings/external_authorization.md#configuration)。

**更多资源**

- [使用 LDAP 同步群组成员关系](auth/ldap/ldap_synchronization.md#group-sync)。
- 使用继承权限管理用户访问。最多可使用 20 层子群组来组织团队和项目。
  - [继承成员关系](../user/project/members/_index.md#membership-types)。
  - [示例](../user/group/subgroups/_index.md)。

<a id="import-projects"></a>

## 导入项目

您可能需要从 GitHub、Bitbucket 或另一个极狐GitLab 实例等外部来源导入项目。许多外部来源都可以导入到极狐GitLab 中。

- 查看[极狐GitLab 项目文档](../user/project/_index.md)。
- 考虑使用[代码仓库镜像](../user/project/repository/mirror/_index.md)，它是[项目迁移的替代方案](../ci/ci_cd_for_external_repos/_index.md)。
- 查看[导入并迁移到极狐GitLab](../user/import/_index.md)，了解常见迁移路径的文档。
- 使用我们的[导入/导出 API](../api/project_import_export.md#export-a-project) 安排项目导出。

<a id="popular-project-imports"></a>

### 常用项目导入

- [GitHub Enterprise 迁移到极狐GitLab 私有化部署](../integration/github.md)
- [Bitbucket Server](../user/import/bitbucket_server.md)

如需这些数据类型方面的帮助，请联系您的极狐GitLab 客户经理，或就我们的专业迁移服务联系极狐GitLab 支持。

<a id="gitlab-instance-security"></a>

## 极狐GitLab 实例安全

安全是入门流程的重要组成部分。保护您的实例可以保护您的工作和您的组织。

虽然这不是一份详尽的清单，但遵循以下步骤可以为保护您的实例打下坚实基础。

- 使用较长的 root 密码，并将其存储在保险库中。
- 安装受信任的 SSL 证书，并建立续订和吊销流程。
- 根据您组织的准则[配置 SSH 密钥限制](../security/ssh_keys_restrictions.md)。
- [关闭新用户账户创建](settings/sign_up_restrictions.md#disable-new-user-account-creation)。
- 要求进行电子邮件确认。
- 设置密码长度限制，配置 SSO 或 SAML 用户管理。
- 如果允许新用户创建账户，请限制电子邮件域名。
- 要求使用双重身份验证（2FA）。
- 关闭[通过 HTTPS 进行 Git 操作的密码身份验证](settings/sign_in_restrictions.md#allow-password-authentication-for-git-over-https)。
- 设置[未知登录的电子邮件通知](settings/sign_in_restrictions.md#email-notification-for-unknown-sign-ins)。
- 配置[用户和 IP 速率限制](https://about.gitlab.com/blog/gitlab-instance-security-best-practices/#user-and-ip-rate-limits)。
- 限制 [webhook 本地访问](https://about.gitlab.com/blog/gitlab-instance-security-best-practices/#webhooks)。
- 设置[受保护路径的速率限制](settings/protected_paths.md)。
- 在通信偏好中心订阅[安全警报](https://about.gitlab.com/company/preference-center/)。
- 在我们的[博客页面](https://about.gitlab.com/blog/gitlab-instance-security-best-practices/)上了解安全最佳实践。

<a id="monitor-gitlab-performance"></a>

## 监控极狐GitLab 性能

完成基本设置后，您就可以查看极狐GitLab 监控服务了。Prometheus 是我们的核心性能监控工具。与其他监控解决方案（例如 Zabbix 或 New Relic）不同，Prometheus 与极狐GitLab 紧密集成，并拥有广泛的社区支持。

- [Prometheus](monitoring/prometheus/_index.md) 会采集
  [这些极狐GitLab 指标](monitoring/prometheus/gitlab_metrics.md#metrics-available)。
- 详细了解极狐GitLab [内置软件指标](monitoring/prometheus/_index.md#bundled-software-metrics)。
- Prometheus 及其 exporter 默认开启。但是，您必须[配置该服务](monitoring/prometheus/_index.md#configuring-prometheus)。
- 了解[应用性能指标](https://about.gitlab.com/blog/working-with-performance-metrics/)为何重要。

<a id="components-of-monitoring"></a>

### 监控组件

- [Web 服务器](monitoring/prometheus/gitlab_metrics.md#puma-metrics)：处理服务器请求并协助其他后端服务事务。
  监控 CPU、内存和网络 IO 流量，以跟踪此节点的健康状况。
- [Workhorse](monitoring/prometheus/gitlab_metrics.md#metrics-available)：缓解主服务器的 Web 流量拥塞。
  监控延迟峰值，以跟踪此节点的健康状况。
- [Sidekiq](monitoring/prometheus/gitlab_metrics.md#sidekiq-metrics)：处理后台操作，使极狐GitLab 平稳运行。
  监控长时间未处理的任务队列，以跟踪此节点的健康状况。

<a id="back-up-your-gitlab-data"></a>

## 备份极狐GitLab 数据

极狐GitLab 提供备份方法，以确保您的数据安全且可恢复。

- 确定备份策略。
- 考虑编写 cron 作业以进行每日备份。
- 单独备份配置文件。
- 确定哪些内容应排除在备份之外。
- 确定将备份上传到何处。
- 限制备份保留时间。
- 运行测试备份和恢复。
- 设置定期验证备份的方法。

<a id="back-up-an-instance"></a>

### 备份实例

具体流程因您使用 Linux 软件包还是 Helm Chart 部署而有所不同。

要备份使用 Linux 软件包的单节点安装，您可以使用单个 Rake 任务。

了解[备份 Linux 软件包或 Helm 变体](backup_restore/_index.md)。
此过程会备份您的整个实例，但不会备份配置文件。请确保单独备份这些文件。将配置文件和备份归档保存在单独的位置，以确保加密密钥不与加密数据存放在一起。

<a id="restore-a-backup"></a>

#### 恢复备份

您只能将备份恢复到创建该备份时所用的完全相同版本和类型（基础版或企业版）的极狐GitLab。

- 查看 [Linux 软件包（Omnibus）备份和恢复文档](https://gitlab.cn/docs/omnibus/settings/backups/)。
- 查看 [Helm Chart 备份和恢复文档](https://gitlab.cn/docs/charts/backup-restore/)。

<a id="alternative-backup-strategies"></a>

### 替代备份策略

在某些情况下，用于备份的 Rake 任务可能不是最优解决方案。如果 Rake 任务不适用于您，可以考虑以下
[替代方案](backup_restore/_index.md)。

<a id="file-system-snapshot"></a>

#### 文件系统快照

如果您的极狐GitLab 服务器包含大量 Git 代码仓库数据，您可能会发现极狐GitLab 备份脚本太慢。在备份到异地位置时，它可能尤其慢。

缓慢通常从 Git 代码仓库数据大小达到约 200 GB 时开始。在这种情况下，您可以考虑将文件系统快照作为备份策略的一部分。例如，考虑一台具有以下组件的极狐GitLab 服务器：

- 使用 Linux 软件包。
- 托管在 AWS 上，带有一个 EBS 驱动器，其中包含挂载在 `/var/opt/gitlab`的 ext4 文件系统。

该 EC2 实例通过创建 EBS 快照满足应用数据备份的要求。该备份包括所有代码仓库、上传内容和 PostgreSQL 数据。

如果您在虚拟化服务器上运行极狐GitLab，可以为整个极狐GitLab 服务器创建 VM 快照。VM 快照通常要求您关闭服务器。

<a id="gitlab-geo"></a>

#### 极狐GitLab Geo

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

Geo 为您的极狐GitLab 实例提供本地只读实例。

极狐GitLab Geo 通过使用本地极狐GitLab 节点帮助远程团队更高效地工作，同时它也可以用作灾难恢复解决方案。
详细了解如何[将 Geo 用作灾难恢复解决方案](geo/disaster_recovery/_index.md)。

Geo 会复制您的数据库、Git 代码仓库以及其他一些资产。
详细了解 [Geo 复制的数据类型](geo/replication/datatypes.md#replicated-data-types)。

<a id="get-help-with-gitlab-support"></a>

## 获取极狐GitLab 支持团队的帮助

极狐GitLab 通过不同渠道为极狐GitLab 私有化部署提供支持。

- 优先支持：[专业版和旗舰版](https://gitlab.cn/pricing) 极狐GitLab 私有化部署客户可获得优先支持，响应时间分级。
- 实时升级协助：在生产升级期间获得一对一专家指导。通过您的优先支持计划，
  您有资格与我们的支持团队成员进行实时、预约的屏幕共享会话。

获取帮助：

- 使用极狐GitLab 文档进行自助支持。
- 加入 [极狐GitLab 论坛](https://forum.gitlab.cn/)获取社区支持。
- [提交支持工单](https://gitlab.cn/support)。

<a id="api-and-rate-limits"></a>

## API 和速率限制

速率限制可防止拒绝服务或暴力破解攻击。在大多数情况下，您可以通过限制来自单个 IP 地址的请求速率，来减轻应用和基础设施的负载。

速率限制还能提高应用的安全性。

<a id="configure-rate-limits"></a>

### 配置速率限制

您可以在**管理**区域更改默认速率限制。有关配置的更多信息，请参阅[**管理**区域页面](../rate_limits/_index.md#configuration-options)。

- 定义[内容创建速率限制](../rate_limits/content_creation.md)，以设置每个用户每分钟创建议题请求的最大数量。
- 对未认证的 Web 请求强制执行[用户和 IP 速率限制](settings/user_and_ip_rate_limits.md)。
- 查看 [raw 端点上的速率限制](settings/rate_limits_on_raw_endpoints.md)。raw 文件访问的默认设置为每分钟 300 个请求。
- 查看六个活动默认值的[导入/导出速率限制](settings/import_export_rate_limits.md)。

有关 API 和速率限制的更多信息，请参阅我们的 [API 页面](../api/rest/_index.md)。

<a id="gitlab-training-resources"></a>

## 极狐GitLab 培训资源

您可以进一步了解如何管理极狐GitLab。

- 参与 [极狐GitLab 论坛](https://forum.gitlab.cn/)，与我们才华横溢的社区交流技巧。
- 查看[我们的博客](https://about.gitlab.com/blog/)，了解以下方面的持续更新：
  - 版本发布
  - 应用
  - 贡献
  - 新闻
  - 活动

<a id="paid-gitlab-training"></a>

### 付费极狐GitLab 培训

- 极狐GitLab 教育服务：通过我们的专业培训课程，进一步了解[极狐GitLab 和 DevOps 最佳实践](https://about.gitlab.com/professional-services/education/)。查看我们的完整课程目录。

<a id="free-gitlab-training"></a>

### 免费极狐GitLab 培训

- 极狐GitLab 基础：探索关于 [Git 和极狐GitLab 基础](../tutorials/_index.md)的自助指南。

<a id="third-party-training"></a>

### 第三方培训

- Udemy：如需更经济实惠的引导式培训选项，请考虑
  Udemy 上的 [GitLab CI: Pipelines, CI/CD, and DevOps for Beginners](https://www.udemy.com/course/gitlab-ci-pipelines-ci-cd-and-devops-for-beginners/)。
- LinkedIn Learning：查看 LinkedIn Learning 上的[使用 GitLab 进行持续交付](https://www.linkedin.com/learning/continuous-integration-and-continuous-delivery-with-gitlab?replacementOf=continuous-delivery-with-gitlab)，
  了解另一个低成本的引导式培训选项。
