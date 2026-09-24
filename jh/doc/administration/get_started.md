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

开始使用极狐GitLab 管理。配置您的组织及其身份验证，然后保护、监控和备份极狐GitLab。

<a id="authentication"></a>

## 身份验证

身份验证是确保安装安全的第一步。

- [为所有用户强制执行双因素身份验证 (2FA)](../security/two_factor_authentication.md)。
- 确保用户执行以下操作：
  - 选择强且安全的密码。如果可能，请将其存储在密码管理系统中。
  - 如果未为所有人配置，请为您的账户开启[双因素身份验证 (2FA)](../user/profile/account/two_factor_authentication.md)。
    此一次性密钥代码是额外的安全措施，即使入侵者拥有您的密码，也能将其拒之门外。
  - 添加备用电子邮件。如果您无法访问您的账户，极狐GitLab 支持团队可以更快地为您提供帮助。
  - 保存或打印您的恢复代码。如果您无法访问身份验证设备，可以使用这些恢复代码登录您的极狐GitLab 账户。
  - 向您的个人资料添加 [SSH 密钥](../user/ssh.md)。您可以根据需要使用 SSH 生成恢复代码。
  - 创建[个人访问令牌](../user/profile/personal_access_tokens.md)。当您使用 2FA 时，可以使用这些令牌访问极狐GitLab API。

<a id="projects-and-groups"></a>

## 项目和群组

通过配置群组和项目来组织您的环境。

- [项目](../user/project/working_with_projects.md)：为您的文件和代码指定一个位置，或在业务类别中跟踪和组织议题。
- [群组](../user/group/_index.md)：组织用户或项目的集合。使用这些群组快速分配人员和项目。
- [角色](../user/permissions.md)：为您的项目和群组定义用户访问权限和可见性。


开始使用：

- 创建[项目](../user/project/_index.md)。
- 创建[群组](../user/group/_index.md#create-a-group)。
- 向群组[添加成员](../user/group/_index.md#add-users-to-a-group)。
- 创建[子群组](../user/group/subgroups/_index.md#create-a-subgroup)。
- 向子群组[添加成员](../user/group/subgroups/_index.md#subgroup-membership)。
- 开启[外部授权控制](settings/external_authorization.md#configuration)。

**更多资源**

- [使用 LDAP 同步群组成员](auth/ldap/ldap_synchronization.md#group-sync)。
- 使用继承权限管理用户访问。使用最多 20 层子群组来组织团队和项目。
  - [继承成员资格](../user/project/members/_index.md#membership-types)。
  - [示例](../user/group/subgroups/_index.md)。

<a id="import-projects"></a>

## 导入项目

您可能需要从外部来源（如 GitHub、Bitbucket 或另一个极狐GitLab 实例）导入项目。许多外部来源都可以导入到极狐GitLab。

- 查看[极狐GitLab 项目文档](../user/project/_index.md)。
- 考虑[代码仓库镜像](../user/project/repository/mirror/_index.md)，这是[项目迁移的替代方案](../ci/ci_cd_for_external_repos/_index.md)。
- 查看[导入并迁移到极狐GitLab](../user/import/_index.md) 以获取常见迁移路径的文档。
- 使用我们的[导入/导出 API](../api/project_import_export.md#export-a-project) 安排项目导出。

<a id="popular-project-imports"></a>

### 常见的项目导入

- [GitHub Enterprise 到极狐GitLab 私有化部署](../integration/github.md)
- [Bitbucket Server](../user/import/bitbucket_server.md)

如需这些数据类型的帮助，请联系您的极狐GitLab 客户经理或极狐GitLab 支持团队，了解我们的专业迁移服务。

<a id="gitlab-instance-security"></a>

## 极狐GitLab 实例安全

安全是入门流程的重要组成部分。保护您的实例可以保护您的工作和组织。

虽然这不是一份详尽的清单，但遵循以下步骤可以为保护您的实例打下坚实基础。

- 使用长度较长的 root 密码，并将其存储在保险库中。
- 安装受信任的 SSL 证书，并建立续期和吊销流程。
- 根据您组织的准则[配置 SSH 密钥限制](../security/ssh_keys_restrictions.md)。
- [关闭新用户账户创建](settings/sign_up_restrictions.md#disable-new-user-account-creation)。
- 要求电子邮件确认。
- 设置密码长度限制，配置 SSO 或 SAML 用户管理。
- 如果允许新用户创建账户，请限制电子邮件域名。
- 要求双因素身份验证 (2FA)。
- 关闭 [Git over HTTPS 的密码身份验证](settings/sign_in_restrictions.md#allow-password-authentication-for-git-over-https)。
- 设置[未知登录的电子邮件通知](settings/sign_in_restrictions.md#email-notification-for-unknown-sign-ins)。
- 配置[用户和 IP 速率限制](https://about.gitlab.com/blog/gitlab-instance-security-best-practices/#user-and-ip-rate-limits)。
- 限制 [Webhook 本地访问](https://about.gitlab.com/blog/gitlab-instance-security-best-practices/#webhooks)。
- 为受保护路径设置[速率限制](settings/protected_paths.md)。
- 从通信偏好中心订阅[安全警报](https://about.gitlab.com/company/preference-center/)。
- 在我们的[博客页面](https://about.gitlab.com/blog/gitlab-instance-security-best-practices/)上了解安全最佳实践。

<a id="monitor-gitlab-performance"></a>

## 监控极狐GitLab 性能

完成基本设置后，您就可以查看极狐GitLab 监控服务了。Prometheus 是我们的核心性能监控工具。
与其他监控解决方案（例如 Zabbix 或 New Relic）不同，Prometheus 与极狐GitLab 紧密集成，并拥有广泛的社区支持。

- [Prometheus](monitoring/prometheus/_index.md) 捕获
  [这些极狐GitLab 指标](monitoring/prometheus/gitlab_metrics.md#metrics-available)。
- 了解有关极狐GitLab [内置软件指标](monitoring/prometheus/_index.md#bundled-software-metrics) 的更多信息。
- Prometheus 及其导出器默认开启。但是，您必须[配置该服务](monitoring/prometheus/_index.md#configuring-prometheus)。
- 了解为什么[应用程序性能指标](https://about.gitlab.com/blog/working-with-performance-metrics/)很重要。
<a id="components-of-monitoring"></a>

### 监控的组件

- [Web 服务器](monitoring/prometheus/gitlab_metrics.md#puma-metrics)：处理服务器请求并促进其他后端服务事务。
  监控 CPU、内存和网络 IO 流量以跟踪此节点的健康状况。
- [Workhorse](monitoring/prometheus/gitlab_metrics.md#metrics-available)：缓解主服务器的 Web 流量拥塞。
  监控延迟峰值以跟踪此节点的健康状况。
- [Sidekiq](monitoring/prometheus/gitlab_metrics.md#sidekiq-metrics)：处理使极狐GitLab 平稳运行的后台操作。
  监控长时间未处理的任务队列以跟踪此节点的健康状况。

<a id="back-up-your-gitlab-data"></a>

## 备份您的极狐GitLab 数据

极狐GitLab 提供备份方法以确保您的数据安全且可恢复。

- 决定备份策略。
- 考虑编写 cron 作业以进行每日备份。
- 单独备份配置文件。
- 决定备份中应排除的内容。
- 决定备份上传的位置。
- 限制备份保留时间。
- 运行测试备份和恢复。
- 设置定期验证备份的方法。

<a id="back-up-an-instance"></a>

### 备份实例

根据您是使用 Linux 软件包还是 Helm chart 部署，备份流程会有所不同。

要备份使用 Linux 软件包的单节点安装，您可以使用单个 Rake 任务。

了解[备份 Linux 软件包或 Helm 变体](backup_restore/_index.md)。
此过程会备份您的整个实例，但不会备份配置文件。请确保这些文件单独备份。
将您的配置文件和备份存档保存在单独的位置，以确保加密密钥不与加密数据存放在一起。

<a id="restore-a-backup"></a>

#### 恢复备份

您只能将备份恢复到创建该备份时完全相同的极狐GitLab 版本和类型（基础版或企业版）。

- 查看 [Linux 软件包 (Omnibus) 备份和恢复文档](https://gitlab.cn/docs/omnibus/settings/backups/)。
- 查看 [Helm Chart 备份和恢复文档](https://gitlab.cn/docs/charts/backup-restore/)。

<a id="alternative-backup-strategies"></a>

### 替代备份策略

在某些情况下，用于备份的 Rake 任务可能不是最优解决方案。如果 Rake 任务对您不适用，这里有一些
[替代方案](backup_restore/_index.md) 供您考虑。

<a id="file-system-snapshot"></a>

#### 文件系统快照

如果您的极狐GitLab 服务器包含大量 Git 代码仓库数据，您可能会发现极狐GitLab 备份脚本太慢。尤其是在备份到异地位置时，速度可能会特别慢。

当 Git 代码仓库数据大小达到约 200 GB 时，通常会出现速度变慢的情况。在这种情况下，您可以考虑将文件系统快照作为备份策略的一部分。
例如，考虑具有以下组件的极狐GitLab 服务器：

- 使用 Linux 软件包。
- 托管在 AWS 上，使用挂载在 `/var/opt/gitlab` 的包含 ext4 文件系统的 EBS 驱动器。

EC2 实例通过获取 EBS 快照来满足应用程序数据备份的要求。备份包括所有代码仓库、上传文件和 PostgreSQL 数据。

如果您在虚拟化服务器上运行极狐GitLab，您可以创建整个极狐GitLab 服务器的 VM 快照。
VM 快照通常需要您关闭服务器电源。

<a id="gitlab-geo"></a>

#### 极狐GitLab Geo

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

Geo 为您的极狐GitLab 实例提供本地的只读实例。

虽然极狐GitLab Geo 通过使用本地极狐GitLab 节点帮助远程团队更高效地工作，但它也可以用作灾难恢复解决方案。
了解有关使用 [Geo 作为灾难恢复解决方案](geo/disaster_recovery/_index.md) 的更多信息。

Geo 会复制您的数据库、Git 代码仓库以及其他一些资产。
了解有关 [Geo 复制的数据类型](geo/replication/datatypes.md#replicated-data-types) 的更多信息。

<a id="get-help-with-gitlab-support"></a>

## 获取极狐GitLab 支持团队的帮助

极狐GitLab 通过不同渠道为极狐GitLab 私有化部署提供支持。

- 优先支持：[专业版和旗舰版](https://gitlab.cn/pricing) 极狐GitLab 私有化部署客户可享受分级响应时间的优先支持。
- 实时升级协助：在生产环境升级期间获得一对一的专家指导。凭借您的**优先支持计划**，
  您有资格与我们的支持团队成员进行实时、定时的屏幕共享会话。

要获得帮助：

- 使用极狐GitLab 文档进行自助支持。
- 加入 [极狐GitLab 论坛](https://forum.gitlab.com/) 获取社区支持。
- [提交支持工单](https://support.gitlab.com/hc/en-us/requests/new)。

<a id="api-and-rate-limits"></a>

## API 和速率限制

速率限制可防止拒绝服务或暴力攻击。在大多数情况下，您可以通过限制来自单个 IP 地址的请求速率来减少应用程序和基础设施的负载。

速率限制还可以提高应用程序的安全性。

<a id="configure-rate-limits"></a>

### 配置速率限制

您可以在**管理**区域更改默认速率限制。有关配置的更多信息，请参阅 [**管理**区域页面](../rate_limits/_index.md#configuration-options)。

- 定义[内容创建速率限制](../rate_limits/content_creation.md)，为每个用户每分钟的议题创建请求设置最大数量。
- 对未经身份验证的 Web 请求强制执行[用户和 IP 速率限制](settings/user_and_ip_rate_limits.md)。
- 查看[原始端点上的速率限制](settings/rate_limits_on_raw_endpoints.md)。原始文件访问的默认设置为每分钟 300 个请求。
- 查看六个活动默认值的[导入/导出速率限制](settings/import_export_rate_limits.md)。

有关 API 和速率限制的更多信息，请参阅我们的 [API 页面](../api/rest/_index.md)。

<a id="gitlab-training-resources"></a>

## 极狐GitLab 培训资源

您可以了解更多关于如何管理极狐GitLab 的信息。

- 参与 [极狐GitLab 论坛](https://forum.gitlab.com/)，与我们的优秀社区交流技巧。
- 查看[我们的博客](https://about.gitlab.com/blog/) 以获取以下方面的持续更新：
  - 版本发布
  - 应用程序
  - 贡献
  - 新闻
  - 活动

<a id="paid-gitlab-training"></a>

### 付费极狐GitLab 培训

- 极狐GitLab 教育服务：通过我们的专业培训课程，了解有关 [极狐GitLab 和 DevOps 最佳实践](https://about.gitlab.com/professional-services/education/) 的更多信息。查看我们的完整课程目录。

<a id="free-gitlab-training"></a>

### 免费极狐GitLab 培训

- 极狐GitLab 基础知识：在 [Git 和极狐GitLab 基础知识](../tutorials/_index.md) 中发现自助指南。
- 极狐GitLab 大学：在 [极狐GitLab 大学](https://university.gitlab.com/learn/dashboard) 通过结构化课程学习新的极狐GitLab 技能。

<a id="third-party-training"></a>

### 第三方培训

- Udemy：如需更实惠的引导式培训选项，请考虑 Udemy 上的
  [极狐GitLab CI: 流水线, CI/CD, and DevOps for Beginners](https://www.udemy.com/course/gitlab-ci-pipelines-ci-cd-and-devops-for-beginners/) 课程。
- LinkedIn Learning：查看 LinkedIn Learning 上的 [Continuous Delivery with GitLab](https://www.linkedin.com/learning/continuous-integration-and-continuous-delivery-with-gitlab?replacementOf=continuous-delivery-with-gitlab)
  作为另一种低成本、引导式的培训选项。
