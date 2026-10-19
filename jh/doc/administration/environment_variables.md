---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 环境变量
description: 覆盖支持的环境变量。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 公开了某些环境变量，可用于覆盖其默认值。

人们通常使用以下方式配置极狐GitLab：

- 对于 Linux 软件包安装，使用 `/etc/gitlab/gitlab.rb`。
- 对于自行编译安装，使用 `gitlab.yml`。

您可以使用以下环境变量覆盖某些值：

<a id="supported-environment-variables"></a>

## 支持的环境变量

| 变量                                     | 类型    | 描述                                                                                                                                                                                                                                                                                                                      |
|----------------------------------------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DATABASE_URL`                               | string  | 数据库 URL；格式为：`postgresql://localhost/blog_development`。                                                                                                                                                                                                                                                     |
| `ENABLE_BOOTSNAP`                            | string  | 切换 [Bootsnap](https://github.com/rails/bootsnap) 以加快 Rails 的初始启动。在非生产环境中默认启用。设置为 `0` 可禁用。                                                                                                                                                           |
| `EXTERNAL_URL`                               | string  | 在[安装时](https://gitlab.cn/docs/omnibus/settings/configuration/#specify-the-external-url-at-the-time-of-installation)指定外部 URL。                                                                                                                                                     |
| `EXTERNAL_VALIDATION_SERVICE_TIMEOUT`        | integer | [外部 CI/CD 流水线验证服务](cicd/external_pipeline_validation.md)的超时时间（以秒为单位）。默认值为 `5`。                                                                                                                                                                                                  |
| `EXTERNAL_VALIDATION_SERVICE_URL`            | string  | [外部 CI/CD 流水线验证服务](cicd/external_pipeline_validation.md)的 URL。                                                                                                                                                                                                                                    |
| `EXTERNAL_VALIDATION_SERVICE_TOKEN`          | string  | 用于向[外部 CI/CD 流水线验证服务](cicd/external_pipeline_validation.md)进行身份验证的 `X-Gitlab-Token`。                                                                                                                                                                                              |
| `GITLAB_CDN_HOST`                            | string  | 设置用于提供静态资源的 CDN 基础 URL（例如 `https://mycdnsubdomain.fictional-cdn.com`）。                                                                                                                                                                                                                    |
| `GITLAB_EMAIL_DISPLAY_NAME`                  | string  | 极狐GitLab 发送的电子邮件中 **From** 字段使用的名称。                                                                                                                                                                                                                                                                    |
| `GITLAB_EMAIL_FROM`                          | string  | 极狐GitLab 发送的电子邮件中 **From** 字段使用的电子邮件地址。                                                                                                                                                                                                                                                           |
| `GITLAB_EMAIL_REPLY_TO`                      | string  | 极狐GitLab 发送的电子邮件中 **Reply-To** 字段使用的电子邮件地址。                                                                                                                                                                                                                                                       |
| `GITLAB_EMAIL_SUBJECT_PREFIX`                | string  | 极狐GitLab 发送的电子邮件中使用的电子邮件主题前缀。                                                                                                                                                                                                                                                                          |
| `GITLAB_EMAIL_SUBJECT_SUFFIX`                | string  | 极狐GitLab 发送的电子邮件中使用的电子邮件主题后缀。                                                                                                                                                                                                                                                                          |
| `GITLAB_HOST`                                | string  | 极狐GitLab 服务器的完整 URL（包括 `http://` 或 `https://`）。                                                                                                                                                                                                                                                           |
| `GITLAB_MARKUP_TIMEOUT`                      | string  | 由 [`gitlab-markup` gem](https://gitlab.com/gitlab-org/gitlab-markup/) 执行的 `rest2html` 和 `pod2html` 命令的超时时间（以秒为单位）。默认值为 `10`。                                                                                                                                                               |
| `GITLAB_ROOT_EMAIL` | string | 在安装时设置管理员的电子邮件地址。 |
| `GITLAB_ROOT_ORG_NAME` | string | 在安装时设置为管理员创建的组织名称。 |
| `GITLAB_ROOT_ORG_PATH` | string | 在安装时设置为管理员创建的组织路径。 |
| `GITLAB_ROOT_PASSWORD`                       | string  | 在安装时设置管理员的密码。                                                                                                                                                                                                                                                                           |
| `GITLAB_ROOT_USERNAME` | string | 在安装时设置管理员的用户名。 |
| `GITLAB_SHARED_RUNNERS_REGISTRATION_TOKEN`   | string  | 设置用于 runner 的初始注册令牌。[在极狐GitLab 16.11 中已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/148310)。                                                                                                                                                                                |
| `RAILS_ENV`                                  | string  | Rails 环境；可以是 `production`、`development`、`staging` 或 `test` 之一。                                                                                                                                                                                                                                          |
| `GITLAB_RAILS_CACHE_DEFAULT_TTL_SECONDS`     | integer | 存储在 Rails 缓存中的条目所使用的默认 TTL。默认值为 `28800`。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/95042) 15.3。                                                                                                                                                               |
| `GITLAB_CI_CONFIG_FETCH_TIMEOUT_SECONDS`     | integer | 解析 CI 配置中远程 include 的超时时间（以秒为单位）。必须介于 `0` 和 `60` 之间。默认值为 `30`。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/116383) 15.11。                                                                                                                               |
| `GITLAB_CI_CONFIG_GITALY_TIMEOUT_SECONDS`    | integer | 获取 CI 配置文件（本地、项目和组件 include）时，Gitaly 调用的每请求超时时间（以秒为单位）。默认值为 `10`。                                                              |
| `GITLAB_CI_CONFIG_HTTP_OPEN_TIMEOUT_SECONDS`  | integer | 获取远程 CI 配置文件时，HTTP 调用的每请求打开（连接）超时时间（以秒为单位）。必须介于 `1` 和 `60` 之间。默认值为 `10`。                                                                                   |
| `GITLAB_CI_CONFIG_HTTP_READ_TIMEOUT_SECONDS`  | integer | 获取远程 CI 配置文件时，HTTP 调用的每请求读取超时时间（以秒为单位）。必须介于 `1` 和 `60` 之间。默认值为 `30`。                                                                                                |
| `GITLAB_CI_MAX_COMMIT_MESSAGE_SIZE_IN_BYTES` | integer | 可发送到 CI runner 的提交消息最大大小（以字节为单位）。必须介于 `0` 和 `1000000` 之间。默认值为 `100000`。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/208666) 18.6。                                                                                                                                                                           |
| `GITLAB_DISABLE_MARKDOWN_TIMEOUT`            | string  | 如果设置为 `true`、`1` 或 `yes`，则后端的 Markdown 渲染不会超时。默认值为 `false`。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/163662) 17.4。                                                                                                                                    |
| `GITLAB_LFS_LINK_BATCH_SIZE`                 | integer | 设置链接 LFS 文件的批处理大小。默认值为 `1000`。                                                                                                                                                                                                                                                                    |
| `GITLAB_LFS_MAX_OID_TO_FETCH`                | integer | 设置要链接的 LFS 对象的最大数量。默认值为 `100000`。                                                                                                                                                                                                                                                            |
| `SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT`        | integer | 设置 Sidekiq 半可靠获取的超时时间。默认值为 `5`。[在极狐GitLab 16.7 之前](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/139583)，默认值为 `3`。如果您在极狐GitLab 16.6 及更早版本上遇到 Redis CPU 消耗过高的情况，或者您已自定义此变量，则应将该变量更新为 `5`。 |
| `SSL_IGNORE_UNEXPECTED_EOF`                  | string  | OpenSSL 3.0 要求服务器在关闭 SSL 连接之前发送 `close_notify` 警报。默认值为 `false`。如果将此变量设置为 `true`，则会禁用该警报。有关更多信息，请参阅 [OpenSSL 文档](https://docs.openssl.org/3.0/man3/SSL_CTX_set_options/#notes)。                                                        |

<a id="adding-more-variables"></a>

## 添加更多变量

我们欢迎通过合并请求使用变量来使更多设置可配置。对 `config/initializers/1_settings.rb` 文件进行更改，并使用命名方案 `GITLAB_#{name in 1_settings.rb in upper case}`。

<a id="linux-package-installation-configuration"></a>

## Linux 软件包安装配置

要设置环境变量，请遵循[这些说明](https://gitlab.cn/docs/omnibus/settings/environment-variables/)。

可以通过在 `docker run` 命令中添加环境变量 `GITLAB_OMNIBUS_CONFIG` 来预配置极狐GitLab Docker 镜像。有关更多信息，请参阅[预配置 Docker 容器](../install/docker/configuration.md#pre-configure-docker-container)。
