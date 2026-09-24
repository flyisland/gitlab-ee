---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 环境变量
description: Override supported environment variables.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 会公开某些环境变量，您可以使用这些变量来覆盖其默认值。

用户通常通过以下方式配置极狐GitLab：

- 对于 Linux 软件包安装，使用 `/etc/gitlab/gitlab.rb`。
- 对于自行编译安装，使用 `gitlab.yml`。

您可以使用以下环境变量来覆盖特定值：

## 支持的环境变量

<a id="supported-environment-variables"></a>

| 变量 | 类型 | 描述 |
|----------------------------------------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DATABASE_URL` | string | 数据库 URL；格式为：`postgresql://localhost/blog_development`。 |
| `ENABLE_BOOTSNAP` | string | 切换 [Bootsnap](https://github.com/Shopify/bootsnap) 以加速 Rails 初始启动。非生产环境下默认启用。设置为 `0` 以禁用。 |
| `EXTERNAL_URL` | string | 在[安装时](https://gitlab.cn/docs/omnibus/settings/configuration/#specify-the-external-url-at-the-time-of-installation)指定外部 URL。 |
| `EXTERNAL_VALIDATION_SERVICE_TIMEOUT` | integer | [外部 CI/CD 流水线验证服务](cicd/external_pipeline_validation.md)的超时时间，以秒为单位。默认值为 `5`。 |
| `EXTERNAL_VALIDATION_SERVICE_URL` | string | [外部 CI/CD 流水线验证服务](cicd/external_pipeline_validation.md)的 URL。 |
| `EXTERNAL_VALIDATION_SERVICE_TOKEN` | string | 用于与[外部 CI/CD 流水线验证服务](cicd/external_pipeline_validation.md)进行身份验证的 `X-Gitlab-Token`。 |
| `GITLAB_CDN_HOST` | string | 设置用于提供静态资源的 CDN 的基础 URL（例如，`https://mycdnsubdomain.fictional-cdn.com`）。 |
| `GITLAB_EMAIL_DISPLAY_NAME` | string | 极狐GitLab 发送的电子邮件中**发件人**字段使用的名称。 |
| `GITLAB_EMAIL_FROM` | string | 极狐GitLab 发送的电子邮件中**发件人**字段使用的邮箱地址。 |
| `GITLAB_EMAIL_REPLY_TO` | string | 极狐GitLab 发送的电子邮件中**回复**字段使用的邮箱地址。 |
| `GITLAB_EMAIL_SUBJECT_PREFIX` | string | 极狐GitLab 发送的电子邮件中使用的邮件主题前缀。 |
| `GITLAB_EMAIL_SUBJECT_SUFFIX` | string | 极狐GitLab 发送的电子邮件中使用的邮件主题后缀。 |
| `GITLAB_HOST` | string | 极狐GitLab 服务器的完整 URL（包括 `http://` 或 `https://`）。 |
| `GITLAB_MARKUP_TIMEOUT` | string | [`gitlab-markup` gem](https://gitlab.com/gitlab-org/gitlab-markup/) 执行的 `rest2html` 和 `pod2html` 命令的超时时间，以秒为单位。默认值为 `10`。 |
| `GITLAB_ROOT_PASSWORD` | string | 设置安装时 `root` 用户的密码。 |
| `GITLAB_SHARED_RUNNERS_REGISTRATION_TOKEN` | string | 设置用于 runner 的初始注册令牌。在极狐GitLab 16.11 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/148310)。 |
| `RAILS_ENV` | string | Rails 环境；可以是 `production`、`development`、`staging` 或 `test` 中的一个。 |
| `GITLAB_RAILS_CACHE_DEFAULT_TTL_SECONDS` | integer | 用于存储在 Rails 缓存中的条目的默认 TTL。默认值为 `28800`。在 15.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/95042)。 |
| `GITLAB_CI_CONFIG_FETCH_TIMEOUT_SECONDS` | integer | 在 CI 配置中解析远程 includes 的超时时间，以秒为单位。必须介于 `0` 和 `60` 之间。默认值为 `30`。在 15.11 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/116383)。 |
| `GITLAB_CI_CONFIG_GITALY_TIMEOUT_SECONDS` | integer | 在获取 CI 配置文件（本地、项目和组件 includes）时，每个 Gitaly 调用的请求超时时间，以秒为单位。默认值为 `10`。需要启用 `ci_config_gitaly_timeout` 功能标志。 |
| `GITLAB_CI_CONFIG_HTTP_OPEN_TIMEOUT_SECONDS` | integer | 在获取远程 CI 配置文件时，每个 HTTP 调用的打开（连接）超时时间，以秒为单位。必须介于 `1` 和 `60` 之间。默认值为 `10`。需要 `ci_config_http_timeout` 功能标志。 |
| `GITLAB_CI_CONFIG_HTTP_READ_TIMEOUT_SECONDS` | integer | 在获取远程 CI 配置文件时，每个 HTTP 调用的读取超时时间，以秒为单位。必须介于 `1` 和 `60` 之间。默认值为 `30`。需要 `ci_config_http_timeout` 功能标志。 |
| `GITLAB_CI_MAX_COMMIT_MESSAGE_SIZE_IN_BYTES` | integer | 可以发送给 CI runner 的最大提交消息大小，以字节为单位。必须介于 `0` 和 `1000000` 之间。默认值为 `100000`。在 18.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/208666)。 |
| `GITLAB_DISABLE_MARKDOWN_TIMEOUT` | string | 如果设置为 `true`、`1` 或 `yes`，则后端的 Markdown 渲染不会超时。默认值为 `false`。在 17.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/163662)。 |
| `GITLAB_LFS_LINK_BATCH_SIZE` | integer | 设置链接 LFS 文件的批处理大小。默认值为 `1000`。 |
| `GITLAB_LFS_MAX_OID_TO_FETCH` | integer | 设置要链接的 LFS 对象的最大数量。默认值为 `100000`。 |
| `SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT` | integer | 设置 Sidekiq 半可靠获取的超时时间。默认值为 `5`。在极狐GitLab 16.7 [之前](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/139583)，默认值为 `3`。如果您在极狐GitLab 16.6 及更早版本上遇到 Redis CPU 使用率高的问题，或者您自定义了这个变量，您应该将此变量更新为 `5`。 |
| `SSL_IGNORE_UNEXPECTED_EOF` | string | OpenSSL 3.0 要求服务器在关闭 SSL 连接之前发送 `close_notify` 警报。默认值为 `false`。如果您将此变量设置为 `true`，则会禁用该警报。有关更多信息，请参阅 [OpenSSL 文档](https://docs.openssl.org/3.0/man3/SSL_CTX_set_options/#notes)。 |

## 添加更多变量

<a id="adding-more-variables"></a>

我们欢迎合并请求，以使更多设置可以通过变量进行配置。
请修改 `config/initializers/1_settings.rb` 文件，并使用命名方案 `GITLAB_#{1_settings.rb 中名称的大写形式}`。

## Linux 软件包安装配置

<a id="linux-package-installation-configuration"></a>

要设置环境变量，请遵循[这些说明](https://gitlab.cn/docs/omnibus/settings/environment-variables/)。

可以通过在 `docker run` 命令中添加环境变量 `GITLAB_OMNIBUS_CONFIG` 来预配置极狐GitLab Docker 镜像。
有关更多信息，请参见[预配置 Docker 容器](../install/docker/configuration.md#pre-configure-docker-container)。
