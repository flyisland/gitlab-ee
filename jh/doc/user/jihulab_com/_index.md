---
title: JihuLab.com 设置
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

{{< details >}}
- Tier: Free, Premium, Ultimate
- Offering: JihuLab.com
{{< /details >}}

# JihuLab.com 设置

此页面展示 JihuLab.com 上的设置信息，可供[极狐GitLab SaaS](https://gitlab.cn/pricing/) 用户使用。

<!--See some of these settings on the [instance configuration page](https://gitlab.com/help/instance_configuration) of GitLab.com.-->

## 电子邮件确认

JihuLab.com 将：

- [`email_confirmation_setting`](../../administration/settings/sign_up_restrictions.md#confirm-user-email) 设置为 **硬设置**。
- [`unconfirmed_users_delete_after_days`](../../administration/moderate_users.md#automatically-delete-unconfirmed-users) 设置为三天。

## 密码要求

JihuLab.com 对新账户的密码和更改的密码有以下要求：

- 最小字符长度为 10 个字符；
- 最大字符长度为 128 个字符；
- 必须包含大写字母、小写字母和数字；
- 可以使用任何字符。例如：`~`、`!`、`@`、`#`、`$`、`%`、`^`、`&`、`*`、`()`、`[]`、`_`、`+`、`=`、`-`。

## SSH 密钥限制

JihuLab.com 使用默认 [SSH 密钥限制](../../security/ssh_keys_restrictions.md)。

<a id="ssh-host-keys-fingerprints"></a>

## SSH 主机密钥指纹

进行当前实例配置以在 JihuLab.com 上查看 SSH 主机密钥指纹。

1. 登录极狐GitLab。
1. 在左侧边栏中，选择 **帮助** (**{question-o}**) > **帮助**。
1. 在帮助页面上，选择 **检查当前实例配置**。

在实例配置中，您会看到 **SSH 主机密钥指纹**：

| 算法      | SHA256  |
|----------|---------|
| ED25519  | `oFjzO7Pjq2iFPAVDPI9LmQLeC7Vmst/vFy6Bd1Mlljw` |
| RSA  | `NH6pILFtJnZCTefvALgWVShVUSyXmhnnwj/RjR76CJ4` |
| DSA (deprecated) | `X42tkbvmtfwwPXggioadkFni7DgBybAdI9aensl/Hh4` |
| ECDSA | `/YbJq0B1VPMOFY0SOs9DINmpXC7Ihyd6amYgZnrWFVc` |

## SSH `known_hosts` 条目

将以下内容添加到 `.ssh/known_hosts` 以跳过 SSH 中的手动指纹确认：

```plaintext
JihuLab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAF3eNpQq0GNg0IZgh6gWOd1UOoaVJAQU9tjj6ocVuMT
JihuLab.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpndvpEtk3Ajwp74T6t6/uofKW6HzS/ZYmzqEFNxl+er1uroc0ZYfo3c211k3y3ickN8fKkOcADagC9QI3Wt/sKfff/46gpKie70bUyEjdSVA42hdhUvLQ+jASjU3QE+7frJQ/7Qzbff8URPJ9HQba3vPA8QDAvbDEWpLN7n364zELXKiuN1jGD0oemTsJsKDcc07cSwNTwTVDLdRYPCU4RhT0q/l2Xtmd1KgDFOmPoI0S2wkRO47soJcjbMlUhh5p/uZBV+XJxj2BWUlJERoBQie/AbZZfWjdRNZSKf4y7qHoR8YBAD7gSRKBkQM20Dd0DqGRI7HUyYdCQtU5Ex+3Zh7WtJwhWBWJ42zu+ILUfRsXQvJnGZ3fgc8BlEO3hzP+rJWKGZbVjgkMNsX7ZkXwNZ/xzj8oBHhCE2EvfjLo0+nHpRjppQXC7VWQSpxMv4M6RTcwuEW/hC5L/QpXEaORW1I5T68eJCsMuOIBOnZb+t7lM5ftOLLW2/7DUz8FS9tKyfCVHohHfOJexqrACF3FkGsXYxx5XKm9KjLrQtfXZLeWDaColIX0w6szCha9NnclQfs38izoYCpyE2ue8HwPdMJT9M19XW+ZfidLPBf/U0SK5eSwSQRj+HFSKxAz7kLZRmxi61jdaOVvdgUmT/ByvwVnWyne0EE8M0zLesm8Tw==
JihuLab.com ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAD6qo5z7vy4J1dTRyhaf8ats0lDWVgpgMddICUaVRTSMcNjfSaq4XHdPnSeXwWsAuSYN/3KZzoVsKcvZ/y5bc15fQHomE2B4Wn0+AnFv8XDv0ZHuAnZ4JLvbjtG0aVjsdO/97MF3kAeabQm4+ci4YPx4GZVxE/2LcN+W8S024Ky7+qLKA==
```

## 邮件配置

JihuLab.com 使用阿里云邮箱推送服务发送通知邮件，系统邮件的域名为 `msg.jihulab.com`。
JihuLab.com 使用阿里云企业邮箱服务接收特定邮件，接收邮件的域名为 `mg.jihulab.com`。

### 服务台自定义邮箱

JihuLab.com 提供的服务台（Service Desk）功能允许用户通过发送邮件的方式创建议题。邮件地址为 `contact-project+%{key}@mg.jihulab.com`。您可以在项目设置中自定义邮件后缀。<!--[custom suffix](../project/service_desk/configure.md#configure-a-suffix-for-service-desk-alias-email)-->

## 备份

当前 JihuLab.com 的备份策略：

* 生产数据库的 base backup 备份是每 24 小时进行一次，同时通过 [wal](https://github.com/wal-e/wal-e) 进行连续增量备份，流向腾讯云 COS。这些备份都是加密的，备份保留 40 天。
* 存储所有用户 git 仓库数据的文件系统通过磁盘快照的方式进行备份，每 15 分钟进行一次，备份保留 7 天。
* 存储在对象存储（腾讯云 COS）中的数据，如产物、容器镜像库等，没有额外的备份，服务可靠性由云厂商提供保障（参见[对象存储服务等级协议](https://cloud.tencent.com/document/product/301/1979)）

用户可以采用以下两种方式，自行备份 JihuLab.com 上的的项目：

* [通过界面](../project/settings/import_export.md)。
* [通过 API](../../api/project_import_export.md#schedule-an-export)。您还可以使用 API，以编程方式将导出内容上传到存储平台。

{{< details >}}
- Tier: Premium, Ultimate
- Offering: JihuLab.com
{{< /details >}}

## 延迟群组删除

所有群组都默认启用延迟删除。延迟 7 天后，群组将被永久删除。
如果您使用的是基础版，您的群组将立即被删除，并且无法恢复。

{{< details >}}
- Tier: Premium, Ultimate
- Offering: JihuLab.com
{{< /details >}}

<a id="delayed-project-deletion"></a>

## 延迟项目删除

所有群组都默认启用延迟项目删除。延迟 7 天后，项目将被永久删除。
如果您使用的是基础版，您的项目将立即被删除，并且无法恢复。

<a id="inactive-project-deletion"></a>

## 非活跃项目删除

[非活跃项目删除](../../administration/inactive_project_deletion.md)在 JihuLab.com 上默认禁用。

<a id="alternative-ssh-port"></a>

## 备用 SSH 端口

可以通过为 `git+SSH` 使用不同的 SSH 端口，来访问 JihuLab.com。

| 设置    | 值               |
|------------|---------------------|
| `Hostname` | `altssh.jihulab.com` |
| `Port`     | `443`               |

`~/.ssh/config` 的示例如下：

```plaintext
Host jihulab.com
  Hostname altssh.jihulab.com
  User git
  Port 443
  PreferredAuthentications publickey
```

<a id="gitlab-pages"></a>

## 极狐GitLab Pages

由于安全合规等因素，JihuLab.com 暂未开启 Pages 功能。

<a id="gitlab-cicd"></a>

## 极狐GitLab CI/CD

以下是有关[极狐GitLab CI/CD](../../ci/index.md) 的当前设置。
此处未列出的设置或功能限制均使用相关文档中列出的默认值。

| 设置                                                       | JihuLab.com                                                                                             | 默认值（私有化部署版）                                                                                                                                         |
|:---------------------------------------------------------|:--------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------|
| 最大产物大小（压缩）                                               | 1 GB                                                                                                    | 查看[最大产物大小](../../administration/settings/continuous_integration.md#maximum-artifacts-size)。                                                        |
| 产物[过期时间](../../ci/yaml/index.md#artifactsexpire_in)      | <!--From June 22, 2020, -->默认 30 天后删除，除非另有规定<!--(artifacts created before that date have no expiry).--> | 查看[默认产物过期](../../administration/settings/continuous_integration.md#default-artifacts-expiration)。                                                          |
| 计划流水线 Cron                                               | `*/5 * * * *`                                                                                           | 查看[流水线计划高级配置](../../administration/cicd.md#change-maximum-scheduled-pipeline-frequency)。                                                            |
| 活跃流水线的最大作业数量                                             | 基础版：`500`<br>专业版和旗舰版：`1000`                                                                             | 查看[活跃流水线作业数](../../administration/instance_limits.md#number-of-jobs-in-active-pipelines)。                                                           |
| 项目的最大 CI/CD 订阅量                                          | `2`                                                                                                     | 查看[项目的 CI/CD 订阅数](../../administration/instance_limits.md#number-of-cicd-subscriptions-to-a-project)。                                               |
| 项目中流水线触发器的最大数量                                           | 基础版：`25000`<br>专业版和旗舰版：无限制                                                                                  | 查看[限制流水线触发器的数量](../../administration/instance_limits.md#limit-the-number-of-pipeline-triggers)。                                                     |
| 项目中流水线计划的最大数量                                            | 基础版：`10`<br>专业版和旗舰版：`50`                                                                                    | 查看[最大流水线计划数量](../../administration/instance_limits.md#number-of-pipeline-schedules)。                                                                |
| 由流水线计划创建的最大流水线数量                                         | 基础版：`24`<br>专业版和旗舰版：`288`                                                                                   | 查看[限制每天由流水线计划创建的流水线数量](../../administration/instance_limits.md#limit-the-number-of-pipelines-created-by-a-pipeline-schedule-per-day)。               |
| 每个安全策略项目定义的计划规则的最大数量                                     | 所有用户无限制                                                                                                 | 查看[为安全策略项目定义的计划规则的数量](../../administration/instance_limits.md#limit-the-number-of-schedule-rules-defined-for-security-policy-project)（引入于 15.1 版本）。 |
| 计划作业归档                                                   | 3 个月                                                                                                    | 从不                                                                                                                                                  |
| 每个[单元测试报告](../../ci/testing/unit_test_reports.md)的最多测试用例 | `500000`                                                                                                | 无限制                                                                                                                                                 |
| 注册 Runner 的最大数量                                          | 基础版：每个群组 `50`，每个项目 `50`<br>专业版和旗舰版：每个群组 `1000`，每个项目 `1000`                                                  | 查看[每个范围的注册 Runner 的数量](../../administration/instance_limits.md#number-of-registered-runners-per-scope)。                                             |
| dotenv 变量限制                                              | 基础版：`50`<br>专业版：`100`<br>旗舰版：`150`                                                                      | 查看[限制 dotenv 变量](../../administration/instance_limits.md#limit-dotenv-variables)。                                                                   |
| 授权令牌持续时间（分钟）                                             | `15`                                                                                                    | 要设置自定义值，请在 Rails 控制台中运行：`ApplicationSetting.last.update(container_registry_token_expire_delay: <integer>)`，其中 `<integer>` 是所需的分钟数。                  |

<a id="package-registry-limits"></a>

## 软件包限制

上传到[极狐GitLab 软件包库](../../user/packages/package_registry/index.md)的包的[最大文件大小](../../administration/instance_limits.md#file-size-limits)因格式而异：

| 包类型 | JihuLab.com |
|--------------|------------|
| Conan        | 5 GB       |
| Generic      | 5 GB       |
| Helm         | 5 MB       |
| Maven        | 5 GB       |
| npm:         | 5 GB       |
| NuGet        | 5 GB       |
| PyPI         | 5 GB       |
| Terraform    | 1 GB       |

<a id="account-and-limit-settings"></a>

## 账户和限制设置

JihuLab.com 启用以下账户限制。如果设置未列出，则默认值与[私有化部署实例的设置相同](../../administration/settings/account_and_limit_settings.md)：

| 设置                                                                                                                                 | JihuLab.com 默认值 |
|------------------------------------------------------------------------------------------------------------------------------------|-----------------|
| [包括 LFS 的仓库大小](../../administration/settings/account_and_limit_settings.md#repository-size-limit)                                  | 2 GB            |
| [最大导入大小](../project/settings/import_export.md#import-a-project-and-its-data)                                                       | 2 GB            |
| 从外部对象存储导入的最大远端文件大小                                                                                                                 | 2 GB            |
| 通过直接传输从源极狐GitLab 实例导入时的最大下载文件大小                                                                                                    | 2 GB            |
| 最大附件大小                                                                                                                             | 100 MB          |
| [导入归档的最大解压缩文件大小](../../administration/settings/account_and_limit_settings.md#maximum-decompressed-file-size-for-imported-archives) | 5 GB           |
 
如果您接近或已经超过了仓库大小限制，您可以[使用 Git 降低您的仓库大小](../project/repository/repository_size.md)或[购买额外存储](https://gitlab.cn/pricing/licensing-faq)。

NOTE:
`git push` 和极狐GitLab 项目导入通过 Cloudflare 的每个请求限制为 5 GB。文件上传以外的导入不受此限制的影响。仓库限制适用于公共和私有项目。

<a id="default-import-sources"></a>

## 默认导入源

> 为新的极狐GitLab 私有化部署安装禁用所有导入器引入于极狐GitLab 16.0。

| 导入源                                                                                     | JihuLab.com 默认       |
|:----------------------------------------------------------------------------------------|:---------------------|
| [Bitbucket 云](../project/import/bitbucket.md)                                           | **{check-circle}** 是 |
| [Bitbucket 服务器](../project/import/bitbucket_server.md)                                  | **{check-circle}** 否 | 
| FogBugz<!--[FogBugz](../project/import/fogbugz.md) -->                                  | **{check-circle}** 否 | 
| Gitea<!--[Gitea](../project/import/gitea.md) -->                                        | **{check-circle}** 否 |
| Gitee                                                                                   | **{check-circle}** 是 |
| [直接传输的极狐GitLab](../group/import/index.md#migrate-groups-by-direct-transfer-recommended) | **{check-circle}** 是 |
| [使用文件导出的极狐GitLab](../project/settings/import_export.md)                                 | **{check-circle}** 是 | 
| [GitHub](../project/import/github.md)                                                   | **{check-circle}** 是 |
| [Manifest 文件](../project/import/manifest.md)                                            | **{check-circle}** 是 | 
| [通过 URL 方式从仓库导入](../project/import/repo_by_url.md)                                      | **{check-circle}** 是 |

<!--[Other importers](../project/import/index.md#available-project-importers) are available.-->

<a id="ip-range"></a>

## IP 范围

在配置 JihuLab.com 的 Webhook 和仓库镜像时，需要允许以下 IP 列表：

- `1.117.22.3/32`
- `1.117.26.213/32`

JihuLab.com 前端使用的是星盾，如果需要连接到 JihuLab.com，您可能需要允许星盾的 CIDR 块（[IPv4 和 IPv6](https://jihulab.com/jihulab/jh-infra/jihulab-com-ip-cidrs/-/wikis/JihuLab.com-IP-CIDRs)）。

JihuLab.com 上的共享 Runner 部署在腾讯云上，不提供静态 IP。

## 主机名列表

在本地 HTTP 代理（或其它网络屏蔽软件）中配置允许列表，添加如下主机名：

- `jihulab.com`
- `*.jihulab.com`
- `gitlab.cn`
- `*.gitlab.cn`

<a id="webhooks"></a>

## Webhook

以下限制适用于 [Webhook](../project/integrations/webhooks.md)：

<a id="webhook-rate-limits"></a>

### 速率限制

Webhook 速率限制是指每个顶级命名空间每分钟可以调用 Webhook 的次数。
限制的数值根据您的订阅级别和订阅中的席位数量而有所不同。

| 订阅级别   | JihuLab.com 默认                                                                            |
|--------|-------------------------------------------------------------------------------------------|
| 基础版    | `500`                                                                                     |
| 专业版    | 不多于 `99` 个席位：`1,600`<br>`100-399` 个席位：`2,800`<br>不少于 `400` 个席位：`4,000`                    |
| 旗舰版及开源 | 不多于 `999` 个席位：`6,000`<br>`1,000-4,999` 个席位：`9,000`<br>不少于 `5,000` 个席位：`13,000` |

<a id="other-limits"></a>

### 其他限制

| 设置         | JihuLab.com 默认                                               |
|------------|--------------------------------------------------------------|
| Webhook 数量 | 每个项目 `100` 个，每个群组 `50` 个（子群组 Webhook 数量不计入父群组 Webhook 数量限制中） |
| 最大负载大小     | 25 MB                                                        |
| 超时时间       | 10 秒                                                         |

对于私有化部署实例的限制，请参见：

- [Webhook 速率限制](../../administration/instance_limits.md#webhook-rate-limit)
- [Webhook 数量](../../administration/instance_limits.md#number-of-webhooks)
- [Webhook 超时时间](../../administration/instance_limits.md#webhook-timeout)

## Runner SaaS

Runner SaaS 是托管的、安全的、受管理的构建环境，您可以使用它来为您的 JihuLab.com 托管项目运行 CI/CD 作业。

更多内容请参阅 [Runner SaaS](../../ci/runners/index.md)。

## Puma

JihuLab.com 的 [Puma 请求超时时间](../../administration/operations/puma.md#change-the-worker-timeout)默认为 60 秒。

## 最大指派人和审核者的数量

> - 最大指派人的数量引入于极狐GitLab 15.6。
> - 最大审核者的数量引入于极狐GitLab 15.9。

合并请求执行以下指派人和审核者数量：

- 最大指派人的数量：200
- 最大审核者的数量：200

<a id="jihulabcom-specific-rate-limits"></a>

## JihuLab.com 特定的速率限制

NOTE:
更多内容请查看管理员文档中的[速率限制](../../security/rate_limits.md)。

当请求受到速率限制时，系统会以 `429` 状态码响应。在再次进行请求之前，客户端应该等待。在[速率限制响应](#rate-limiting-responses)中，还详细说明了此响应的信息标头。

下表描述了 JihuLab.com 的速率限制：

| 速率限制                                                                | 从 2021-02-12               | 从 2022-02-03                         |
|:---------------------------------------------------------------------------|:------------------------------|:----------------------------------------|
| **受保护的路径**（对于给定的 **IP 地址**）                           | 每分钟 **10** 个请求   | 每分钟 **10** 个请求              |
| **原始端点**流量（对于给定的**项目、提交和文件路径**）                        | 每分钟 **300** 个请求  | 每分钟 **300** 个请求             |
| **未经身份验证的**流量（来自给定的 **IP 地址**）                  | 每分钟 **500** 个请求   | 每分钟 **500** 个请求             |
| **经过身份验证的** API 流量（对于给定的**用户**）                      | 每分钟 **2000** 个请求 | 每分钟 **2000** 个请求          |
| **经过身份验证的**非 API HTTP 流量（对于给定的**用户**）              | 每分钟 **1000** 个请求 | 每分钟 **1000** 个请求           |
| **所有**流量（来自给定的 **IP 地址**）                             | 每分钟 **2000** 个请求 | 每分钟 **2000** 个请求           |
| **议题创建**                                                         | 每分钟 **300** 个请求   | 每分钟 **200** 个请求             |
| **备注创建**（议题与合并请求中）                           | 每分钟 **60** 个请求    | 每分钟 **60** 个请求              |
| **高级、项目和群组搜索** API（对于给定的**用户**）   | 每分钟 **10** 个请求    | 每分钟 **10** 个请求              |
| **流水线创建**请求（对于给定的**项目、用户和提交**） |                               | 每分钟 **25** 个请求              |

<!--
| **GitLab Pages** requests (for a given **IP address**)                     |                               | **1000** requests per **50 seconds** |
| **GitLab Pages** requests (for a given **GitLab Pages domain**)            |                               | **5000** requests per **10 seconds** |
| **GitLab Pages** TLS connections (for a given **IP address**)              |                               | **1000** requests per **50 seconds** |
| **GitLab Pages** TLS connections (for a given **GitLab Pages domain**)     |                               | **400** requests per **10 seconds**  |
| **Alert integration endpoint** requests (for a given **project**)          |                               | 每小时 **3600** 个请求 |
-->

您可以查看[受保护路径](#protected-paths-throttle)和[原始端点](../../administration/settings/rate_limits_on_raw_endpoints.md)的速率限制的更多详细信息。

极狐GitLab 可以在几个层级上限制请求的速率，这里列出的速率限制是在应用程序中配置的，这些限制是每个 IP 地址最严格的限制。

<!--For more information about the rate limits
for GitLab.com, see
[an overview](https://gitlab.com/gitlab-com/runbooks/-/tree/master/docs/rate-limiting).-->

<a id="rate-limiting-responses"></a>

### 速率限制响应

有关速率限制响应的信息，请参阅：

- [响应被阻止请求的标头列表](../../administration/settings/user_and_ip_rate_limits.md#response-headers)。
- [可自定义的响应文本](../../administration/settings/user_and_ip_rate_limits.md#use-a-custom-rate-limit-response)。

<a id="protected-paths-throttle"></a>

### 受保护的路径节流

JihuLab.com 以 HTTP 状态代码 `429`，来响应每个 IP 地址每分钟超过 10 个的受保护路径上的 POST 请求。

请参阅下文，了解哪些路径受到保护，包括用户创建、用户确认、用户登录和密码重置。

[用户和 IP 速率限制](../../administration/settings/user_and_ip_rate_limits.md#response-headers)包括响应被阻止请求的标头列表。

查看[受保护的路径](../../administration/settings/protected_paths.md)，获取更多信息。

<a id="ip-blocks"></a>

### IP 阻塞

当 JihuLab.com 从系统视为潜在恶意的单个 IP 地址接收异常流量时，可能会发生 IP 阻塞。这可以基于速率限制设置。异常流量停止后，IP 地址会根据阻塞的类型自动释放，如下节所述。

如果您收到对 JihuLab.com 的所有请求的 `403 Forbidden` 错误，请检查任何可能触发阻塞的自动化进程。如需帮助，请联系[极狐技术支持](https://support.gitlab.cn/#/portal/index)，并提供详细信息，例如受影响的 IP 地址。

<a id="git-and-container-registry-failed-authentication-ban"></a>

#### Git 和容器镜像库未通过身份验证禁用

如果在 3 分钟内从单个 IP 地址收到 30 个失败的身份验证请求，JihuLab.com 会以 HTTP 状态代码 `403` 响应 1 小时。

这仅适用于 Git 请求和容器镜像库 (`/jwt/auth`) 请求（组合）。

此限制：

- 可由成功验证的请求重置。例如，29 个失败的身份验证请求后跟 1 个成功的请求，然后再有 29 个失败的身份验证请求不会触发禁用。
- 不适用于 `gitlab-ci-token` 认证的 JWT 请求。

没有提供响应标头。

<a id="pagination-response-headers"></a>

### 分页响应标头

出于性能原因，如果查询返回超过 10,000 条记录，[系统会排除一些标头](../../api/rest/index.md#pagination-response-headers)。

<a id="visibility-settings"></a>

### 可见性设置

在 JihuLab.com 上禁用了[内部可见性](../public_access.md#internal-projects-and-groups)设置：

- 项目
- 群组
- 代码片段

### SSH 最大连接数

JihuLab.com 通过 [MaxStartups 设置](https://man.openbsd.org/sshd_config.5#MaxStartups)，定义了最大并发数、未验证 SSH 连接数。如果并发的连接数超过允许的最大连接数，它们将被删除，且出现 [`ssh_exchange_identification` 错误](../../topics/git/troubleshooting_git.md#ssh_exchange_identification-error)。

### 通过上传导出文件进行群组和项目导入

为防止滥用，将为以下操作进行速率限制：

- 导入项目和群组。
- 使用文件导出群组和项目。
- 导出下载内容。

详情请参阅：

- [项目导入/导出速率限制](../../user/project/settings/import_export.md#rate-limits)
- 群组导入/导出速率限制 <!--[Group import/export rate limits](../../user/group/import/index.md#rate-limits)-->

### 不可配置的限制

有关不可配置的速率限制的信息，请参阅[不可配置的限制文档](../../security/rate_limits.md#non-configurable-limits)，也适用于 JihuLab.com。

## JihuLab.com 特定的 Gitaly RPC 并发限制

极狐GitLab 为不同类型的 Git 操作配置每个仓库的 Gitaly RPC 并发和排队限制，例如 `git clone`。当超过这些限制时，会向客户端返回 `fatal: remote error: GitLab is currently unable to handle this request due to load` 消息。

<!--For administrator documentation, see [limit RPC concurrency](../../administration/gitaly/configure_gitaly.md#limit-rpc-concurrency).-->

<a id="logging"></a>

## JihuLab.com 日志记录

我们使用 Fluentd 来解析我们的日志。Fluentd 将我们的日志发送到 kafka，Filebeat 将日志转发到 Elastic 集群。

### 作业日志

默认情况下，极狐GitLab 不会使作业日志过期。作业日志无限期保留且无法在 JihuLab.com 上配置为过期。您可以使用[作业 API](../../api/jobs.md#erase-a-job) 或通过[删除流水线](../../ci/pipelines/index.md#delete-a-pipeline)，手动清除作业日志。

<!--
## Sidekiq

JihuLab.com 运行 Sidekiq 时，使用参数 `--timeout=4 --concurrency=4` 和以下环境变量：

| 设置                                | JihuLab.com  | 默认值   |
|----------------------------------------|-------------|-----------|
| `SIDEKIQ_DAEMON_MEMORY_KILLER`         | -           | `1`       |
| `SIDEKIQ_MEMORY_KILLER_MAX_RSS`        | `2000000`   | `2000000` |
| `SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS` | -           | -         |
| `SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL` | -           | `3`       |
| `SIDEKIQ_MEMORY_KILLER_GRACE_TIME`     | -           | `900`     |
| `SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT`  | -           | `30`      |
| `SIDEKIQ_LOG_ARGUMENTS`                | `1`         | `1`       |

NOTE:
Sidekiq 导入节点和 Sidekiq 导出节点上的 `SIDEKIQ_MEMORY_KILLER_MAX_RSS` 设置为 `16000000`。


## PostgreSQL

JihuLab.com 是一个大规模的极狐GitLab 安装实例，这意味着我们要更改各种 PostgreSQL 设置来更好地满足我们的需求。例如，我们使用流式复制和热备模式的服务器来平衡不同数据库服务器之间的查询。
JihuLab.com 特定设置（及其默认设置）列表如下：


| 设置                               | JihuLab.com                                                          | 默认值                               |
|:--------------------------------------|:--------------------------------------------------------------------|:--------------------------------------|
| `archive_command`                     | `/usr/bin/envdir /etc/wal-e.d/env /opt/wal-e/bin/wal-e wal-push %p` | 空值                                 |
| `archive_mode`                        | on                                                                  | off                                   |
| `autovacuum_analyze_scale_factor`     | 0.01                                                                | 0.01                                  |
| `autovacuum_max_workers`              | 6                                                                   | 3                                     |
| `autovacuum_vacuum_cost_limit`        | 1000                                                                | -1                                    |
| `autovacuum_vacuum_scale_factor`      | 0.01                                                                | 0.02                                  |
| `checkpoint_completion_target`        | 0.7                                                                 | 0.9                                   |
| `checkpoint_segments`                 | 32                                                                  | 10                                    |
| `effective_cache_size`                | 338688MB                                                            | 取决于可用的服务器内存 |
| `hot_standby`                         | on                                                                  | off                                   |
| `hot_standby_feedback`                | on                                                                  | off                                   |
| `log_autovacuum_min_duration`         | 0                                                                   | -1                                    |
| `log_checkpoints`                     | on                                                                  | off                                   |
| `log_line_prefix`                     | `%t [%p]: [%l-1]`                                                   | 空值                                 |
| `log_min_duration_statement`          | 1000                                                                | -1                                    |
| `log_temp_files`                      | 0                                                                   | -1                                    |
| `maintenance_work_mem`                | 2048MB                                                              | 16 MB                                 |
| `max_replication_slots`               | 5                                                                   | 0                                     |
| `max_wal_senders`                     | 32                                                                  | 0                                     |
| `max_wal_size`                        | 5GB                                                                 | 1GB                                   |
| `shared_buffers`                      | 112896MB                                                            | 取决于可用的服务器内存 |
| `shared_preload_libraries`            | pg_stat_statements                                                  | 空值                                 |
| `shmall`                              | 30146560                                                            | 取决于服务器    |
| `shmmax`                              | 123480309760                                                        | 取决于服务器    |
| `wal_buffers`                         | 16MB                                                                | -1                                    |
| `wal_keep_segments`                   | 512                                                                 | 10                                    |
| `wal_level`                           | replica                                                             | minimal                               |
| `statement_timeout`                   | 15s                                                                 | 60s                                   |
| `idle_in_transaction_session_timeout` | 60s                                                                 | 60s                                   |

Some of these settings are in the process being adjusted. For example, the value
for `shared_buffers` is quite high, and we are
[considering adjusting it](https://gitlab.com/gitlab-com/gl-infra/infrastructure/-/issues/4985).-->

<!--
## GitLab.com at scale

In addition to the GitLab Enterprise Edition Linux package install, GitLab.com uses
the following applications and settings to achieve scale. All settings are
publicly available, as [Kubernetes configuration](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com)
or [Chef cookbooks](https://gitlab.com/gitlab-cookbooks).

### Elastic cluster

We use Elasticsearch and Kibana for part of our monitoring solution:

- [`gitlab-cookbooks` / `gitlab-elk` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab-elk)
- [`gitlab-cookbooks` / `gitlab_elasticsearch` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab_elasticsearch)

### Fluentd

We use Fluentd to unify our GitLab logs:

- [`gitlab-cookbooks` / `gitlab_fluentd` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab_fluentd)

### Prometheus

Prometheus complete our monitoring stack:

- [`gitlab-cookbooks` / `gitlab-prometheus` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab-prometheus)

### Grafana

For the visualization of monitoring data:

- [`gitlab-cookbooks` / `gitlab-grafana` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab-grafana)

### Sentry

Open source error tracking:

- [`gitlab-cookbooks` / `gitlab-sentry` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab-sentry)

### Consul

Service discovery:

- [`gitlab-cookbooks` / `gitlab_consul` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab_consul)

### HAProxy

High Performance TCP/HTTP Load Balancer:

- [`gitlab-cookbooks` / `gitlab-haproxy` · GitLab](https://gitlab.com/gitlab-cookbooks/gitlab-haproxy)

## Sidekiq

GitLab.com runs [Sidekiq](https://sidekiq.org) as an [external process](../../administration/sidekiq/index.md)
for Ruby job scheduling.

The current settings are in the [GitLab.com Kubernetes pod configuration](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/releases/gitlab/values/gprd.yaml.gotmpl).

-->
