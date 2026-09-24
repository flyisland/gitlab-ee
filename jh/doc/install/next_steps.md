---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure email, authentication, CI/CD, GitLab Duo, and other features after installing GitLab.
title: 安装极狐GitLab 后的步骤
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下是完成安装后您可能需要查看的一些资源。

<a id="initial-sign-in"></a>

## 初始登录

安装极狐GitLab 后，您可以访问在安装过程中设置的 URL，并以 `root` 用户身份登录。

如果您在安装过程中未设置自己的密码，则会分配一个随机密码。您可以在安装极狐GitLab 的服务器上的 `/etc/gitlab/initial_root_password` 中找到它。

<a id="email-and-notifications"></a>

## 邮件与通知

- [SMTP](https://gitlab.cn/docs/omnibus/settings/smtp/)：配置 SMTP 以获得正确的电子邮件通知支持。
- [传入电子邮件](../administration/incoming_email.md)：配置传入电子邮件，以便用户可以使用电子邮件回复评论、创建新议题和合并请求等。

<a id="gitlab-duo"></a>

## 极狐GitLab Duo

- [极狐GitLab Duo](../user/gitlab_duo/_index.md)：了解极狐GitLab 提供的 AI 原生功能以及如何启用它们。
- [自部署模型的 极狐GitLab Duo](../administration/gitlab_duo_self_hosted/_index.md)：部署自部署模型的 极狐GitLab Duo，以使用您偏好的极狐GitLab 支持的 LLM。
- [极狐GitLab Duo 数据使用](../user/gitlab_duo/data_usage.md)：了解极狐GitLab 如何处理 AI 数据隐私。

<a id="cicd-runner"></a>

## CI/CD (Runner)

- [设置 runner](https://gitlab.cn/docs/runner/)：设置一个或多个 runner，这些代理负责运行 CI/CD 作业。

<a id="container-registry"></a>

## 容器镜像仓库

- [容器镜像仓库](../administration/packages/container_registry.md)：集成的容器镜像仓库，用于为每个极狐GitLab 项目存储容器镜像。
- [极狐GitLab 依赖代理](../administration/packages/dependency_proxy.md)：设置依赖代理，以便您可以缓存来自 Docker Hub 的容器镜像，从而获得更快、更可靠的构建。

<a id="pages"></a>

## Pages

- [极狐GitLab Pages](../user/project/pages/_index.md)：直接从极狐GitLab 中的仓库发布静态网站。

<a id="security"></a>

## 安全

- [保护极狐GitLab](../security/_index.md)：保护极狐GitLab 实例的推荐实践。
- 注册极狐GitLab [安全简报](https://gitlab.cn/company/preference-center/)，以便在发布时收到安全更新通知。

<a id="authentication"></a>

## 认证

- [LDAP](../administration/auth/ldap/_index.md)：配置 LDAP 作为极狐GitLab 的认证机制。
- [SAML 和 OAuth](../integration/omniauth.md)：通过 Okta、Google、Azure AD 等在线服务进行认证。

<a id="backup-and-upgrade"></a>

## 备份与升级

- [备份和恢复极狐GitLab](../administration/backup_restore/_index.md)：了解备份或恢复极狐GitLab 的不同方法。
- [升级极狐GitLab](../update/_index.md)：每个月都会发布一个功能丰富的新极狐GitLab 版本。了解如何升级到该版本，或升级到包含安全修复的临时版本。
- [发布和维护政策](../policy/maintenance.md)：了解极狐GitLab 关于版本命名以及主要、次要和补丁版本发布节奏的政策。

<a id="license"></a>

## 许可证

- [添加许可证](../administration/license.md) 或 [开始免费试用](https://gitlab.cn/free-trial/)：通过许可证激活所有极狐GitLab 付费功能。
- [定价](https://gitlab.cn/pricing/)：不同级别的定价。

<a id="cross-repository-code-search"></a>

## 跨仓库代码搜索

- [高级搜索](../integration/advanced_search/elasticsearch.md)：利用 [Elasticsearch](https://www.elastic.co/) 或 [OpenSearch](https://opensearch.org/) 在整个极狐GitLab 实例中进行更快、更高级的代码搜索。

<a id="scaling-and-replication"></a>

## 扩展与复制

- [扩展极狐GitLab](../administration/reference_architectures/_index.md)：极狐GitLab 支持多种不同类型的集群。
- [Geo 复制](../administration/geo/_index.md)：Geo 是适用于广泛分布的开发团队的解决方案。

<a id="install-the-product-documentation"></a>

## 安装产品文档

可选。如果您想在自己的服务器上托管文档，请参阅如何[自托管产品文档](../administration/docs_self_host.md)。
