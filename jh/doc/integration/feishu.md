---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 飞书 OmniAuth 提供商和个人通知
description: 使用飞书自建应用登录极狐GitLab，并接收个人通知。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

飞书成员可以绑定已有的极狐GitLab 账号，使用飞书登录，并选择接收个人通知。
此功能仅用于私有化部署实例。

本功能使用 OmniAuth 中的 `feishu` 提供商作为应用凭据的唯一来源。
现有的飞书群通知和 ChatOps 配置保持不变，本功能不读取管理员设置中的飞书应用凭据。

## 前提条件

- 一个飞书自建应用。
- 极狐GitLab 实例能够访问 `open.feishu.cn` 和 `accounts.feishu.cn`。
- 应用已发布，使用此功能的成员在应用的**可用范围**内。
- 应用已添加重定向 URL `https://gitlab.example.com/users/auth/feishu/callback`。
- 对于个人通知，应用已启用机器人能力，并申请 `im:message:send_as_bot` 权限。
- 可选。如需在通知卡片上显示极狐GitLab 图标，应用已申请 `im:resource` 权限。
- 可选。如果应用启用了 IP 白名单，已将实例的全部公网出口 IP 加入白名单。

飞书中国站的授权登录、账号绑定和个人通知卡片已在真实企业中完成验证。
Lark 国际版尚未验证。

## 配置流程

管理员：

1. [创建并配置飞书自建应用](#创建并配置飞书自建应用)。
1. [配置极狐GitLab](#配置极狐gitlab)，并重新配置实例。
1. 对于个人通知，[启用功能标志](#启用功能标志) `jh_feishu_app_notification`。

用户：

1. [绑定自己的飞书账号](#绑定与登录)。
1. 对于个人通知，在通知设置中[开启接收飞书通知](#用户开启接收)。

## 创建并配置飞书自建应用

1. 登录[飞书开发者后台](https://open.feishu.cn/app)，创建企业自建应用。
1. 在 **凭证与基础信息** 中记录 **App ID** 和 **App Secret**。
1. 记录应用所属企业的 `tenant_key`。
1. 在 **安全设置** 中添加重定向 URL：

   ```plaintext
   https://gitlab.example.com/users/auth/feishu/callback
   ```

1. 在 **应用发布 > 版本管理与发布** 中配置应用的**可用范围**，创建版本并发布。
1. 对于个人通知，启用[机器人能力](https://open.feishu.cn/document/uAjLw4CM/ugTN1YjL4UTN24CO1UjN/trouble-shooting/how-to-enable-bot-ability)，
   申请 `im:message:send_as_bot` 权限，再发布新版本使配置生效。
1. 可选。如需在通知卡片上显示极狐GitLab 图标，申请 `im:resource` 权限，并发布新版本。
1. 可选。如果启用应用的
   [IP 白名单](https://open.feishu.cn/document/ukTMukTMukTM/ucTMxYjL3ETM24yNxEjN)，
   将极狐GitLab 服务器的全部公网出口 IP 加入白名单。

未发布机器人能力或权限时，个人通知无法发送。
成员不在应用的可用范围内时，无法授权应用或接收机器人消息。

## 配置极狐GitLab

1. 参见[配置通用设置](omniauth.md#configure-common-settings)完成通用配置。
1. 添加 `feishu` 提供商配置。

   对于 Linux 软件包实例，编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_enabled'] = true
   gitlab_rails['omniauth_providers'] = [
     {
       'name' => 'feishu',
       'app_id' => 'YOUR_APP_ID',
       'app_secret' => 'YOUR_APP_SECRET',
       'args' => {
         'tenant_key' => 'YOUR_TENANT_KEY'
       }
     }
   ]
   ```

   可选项 `label` 可以覆盖默认显示名 `Feishu`。

   对于源码安装实例，编辑 `config/gitlab.yml`：

   ```yaml
   omniauth:
     enabled: true
     providers:
       - { name: 'feishu',
           app_id: 'YOUR_APP_ID',
           app_secret: 'YOUR_APP_SECRET',
           args: { tenant_key: 'YOUR_TENANT_KEY' } }
   ```

   | 配置项 | 默认值 | 说明 |
   | --- | --- | --- |
   | `app_id` | 无 | 自建应用的 App ID，必填 |
   | `app_secret` | 无 | 自建应用的 App Secret，必填 |
   | `args.tenant_key` | 无 | 应用所属企业的租户标识，必填 |
   | `args.client_options.site` | `https://open.feishu.cn` | 飞书开放平台地址 |
   | `args.client_options.authorize_url` | `https://accounts.feishu.cn/open-apis/authen/v1/authorize` | 用户授权地址 |
   | `args.client_options.token_url` | `https://accounts.feishu.cn/oauth/v3/token` | OAuth v3 令牌地址 |

   默认地址对应飞书中国站。
   如需连接 Lark，必须同时配置以下地址：

   ```ruby
   'args' => {
     'tenant_key' => 'YOUR_TENANT_KEY',
     'client_options' => {
       'site' => 'https://open.larksuite.com',
       'authorize_url' => 'https://accounts.larksuite.com/open-apis/authen/v1/authorize',
       'token_url' => 'https://accounts.larksuite.com/oauth/v3/token'
     }
   }
   ```

   这些地址采用 Lark 对应的官方域名。
   Lark 配置尚未在真实环境中验证。

1. 将 `allow_single_sign_on` 和 `auto_link_user` 设置为 `false`，或使用不含 `feishu` 的列表：

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
   gitlab_rails['omniauth_auto_link_user'] = ['saml']
   ```

   飞书说明用户信息中的手机号和邮箱由管理员导入，未经过用户本人实时验证。
   极狐GitLab 不使用这些字段创建账号，也不按邮箱自动关联已有账号。

1. 保存文件并重新配置极狐GitLab。

有关授权码、令牌和用户资料接口，参见飞书的
[获取授权码](https://open.feishu.cn/document/common-capabilities/sso/api/obtain-oauth-code)、
[获取 user_access_token](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/authentication-management/access-token/get-user-access-token-v3)
和[获取用户信息](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/authen-v1/user_info/get)。

## 绑定与登录

用户必须先有极狐GitLab 账号，再绑定飞书：

1. 登录极狐GitLab。
1. 转到 **用户设置 > Access > Password and authentication**。
1. 在 **Service sign-in** 中选择 **Connect Feishu**，完成飞书授权。
1. 退出极狐GitLab，在登录页选择 **Feishu** 验证登录。

在 **Service sign-in** 中选择 **Disconnect Feishu** 可以解除绑定。
注册页不显示 **Feishu** 按钮，飞书不能用于注册或按邮箱自动关联账号。

必须在同一个桌面浏览器会话中发起并完成绑定。
不要从飞书客户端内置浏览器发起绑定，再切换到另一个浏览器完成回调。
跨浏览器会话会导致 OAuth `state` 校验失败，并记录 `csrf_detected`。

绑定身份保存为 `<tenant_key>:<app_id>:<open_id>`。
回调取得的用户信息必须返回与 `args.tenant_key` 相同的 `tenant_key`，否则登录或绑定失败。
这项检查可防止其他租户的用户绑定到当前应用配置。

### 更换租户或应用后重新绑定

`open_id` 只在单个应用中标识用户。
更换 `tenant_key` 或 `app_id` 后，现有绑定不会匹配新配置。
用户必须先解除旧绑定，再使用新应用重新绑定。

## 飞书个人通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验性功能

{{< /details >}}

{{< history >}}

- 计划在极狐GitLab 19.4 中随功能标志 `jh_feishu_app_notification`
  [引入](https://jihulab.com/gitlab-cn/gitlab/-/work_items/5317)。默认禁用。

{{< /history >}}

> [!FLAG]
> 此功能由 `jh_feishu_app_notification` 功能标志控制，默认禁用。
> 此标志的作用域是整个实例，计划在极狐GitLab 19.4 中发布。

用户绑定飞书账号后，可以选择把邮件通知对应的个人卡片发送到飞书。
此功能不改变现有飞书群通知和 ChatOps 集成。

### 启用功能标志

在 Rails 控制台中启用：

```ruby
Feature.enable(:jh_feishu_app_notification)
```

禁用：

```ruby
Feature.disable(:jh_feishu_app_notification)
```

个人通知必须同时满足四个条件：

| 条件 | 不满足时 |
| --- | --- |
| `jh_feishu_app_notification` 已启用 | 不显示设置，也不投递个人通知 |
| 许可证包含 `feishu_app_integration` | 不显示设置，也不投递个人通知 |
| 实例为私有化部署 | 极狐GitLab.com 不提供此功能 |
| `app_id`、`app_secret` 和 `args.tenant_key` 配置完整 | 登录与个人通知不可用 |

功能标志仅控制个人通知。
禁用标志不会影响飞书登录或绑定，已保存的用户选择也会保留。

### 用户开启接收

满足四个条件后，用户可以在 **用户设置 > 通知** 中开启
**同时发送通知到我的飞书账号**。
该设置保存在用户自定义属性中，默认关闭。
绑定飞书不会自动开启通知。

### 推送范围

飞书个人通知沿用邮件通知的收件人和事件判断。
同时开启企业微信和飞书个人通知时，两个渠道使用同一封邮件的内容，各自投递。

因此：

- 邮件发给用户时，才会生成对应的飞书个人卡片。
- 项目关闭邮件通知后，用户也不会收到该项目的飞书个人卡片。
- 飞书卡片只使用同一封邮件中的标题、链接和正文，不从其他数据源补充内容。
- 各渠道独立重试，一个渠道的失败不会影响邮件和其他渠道，也不会让其他渠道重复投递。

### 消息内容

卡片布局与企业微信个人通知一致：标题栏显示极狐GitLab 图标、通知标题和“极狐GitLab”，
正文依次显示摘要、项目和通知原因，点击卡片或 **在极狐GitLab 中查看** 按钮打开通知对象。

卡片标题和链接取自对应邮件。
普通通知的摘要取自同一封邮件的纯文本正文。
内部备注、机密史诗、机密议题、机密工作项及其保密讨论只发送标题和链接，
省略项目、通知原因和正文摘要。

投递使用用户绑定中的 `open_id`，并通过飞书的
[发送消息](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/im-v1/message/create)
接口发送卡片。
每次发送使用唯一的 `uuid`，飞书在一小时内对相同 `uuid` 的请求最多成功发送一次。

飞书卡片不能直接引用图片地址。
极狐GitLab 首次发送卡片时，通过飞书的
[上传图片](https://open.feishu.cn/document/server-docs/im-v1/image/create)
接口上传实例图标，并缓存返回的 `image_key`。
应用未获得 `im:resource` 权限或上传失败时，卡片不显示图标，通知照常发送，
10 分钟后再次尝试上传。

### 令牌和重试

登录使用的 `user_access_token` 只在当前请求的内存中使用，不持久化，也不缓存。
授权请求不申请 `offline_access`，因此不取得或保存 `refresh_token`。

个人通知使用自建应用的
[tenant_access_token](https://open.feishu.cn/document/server-docs/authentication-management/access-token/tenant_access_token_internal)。
令牌按接口地址、App ID、App Secret 和租户隔离，在 Rails 缓存中加密保存。

投递失败最多重试三次：

- 飞书明确标记为暂时性的服务错误和网络错误会重试。
- 限流错误（HTTP `429`、错误码 `99991400` 或 `230020`）会延迟重试。
  响应带有 `Retry-After` 或 `x-ogw-ratelimit-reset` 时按其秒数等待，最长 1 小时；否则使用 Sidekiq 默认退避。
  重试沿用原消息内容和 `uuid`。
- 飞书只在首次请求后一小时内对相同 `uuid` 去重。距离首次发送超过 55 分钟时不再发送，
  记录 `Dropping a Feishu notification past its UUID deduplication window`，避免重复通知。
- 权限、参数、成员范围和其他未知错误按永久失败处理，记录后不重试。
- 三次重试后仍失败时，记录 `Giving up on a Feishu notification` 并停止。

飞书对同一用户限制为 5 QPS。
发送消息接口还限制为每分钟 1000 次、每秒 50 次。
高通知量实例应监控重试用尽的记录。

### Sidekiq 队列

个人通知使用以下 Sidekiq 队列：

| 队列 | 用途 |
| --- | --- |
| `notifications:notifications_fanout` | 渲染邮件内容，并为每个已开启的渠道创建任务 |
| `notifications:notifications_channel_enqueue` | 检查单个渠道的用户开关和账号绑定 |
| `feishu:feishu_send_notification` | 发送飞书卡片 |
| `wecom:wecom_send_notification` | 发送企业微信卡片 |

使用默认[路由规则](../administration/sidekiq/processing_specific_job_classes.md#路由规则)
（`[['*', 'default']]`）或以 `*` 结尾并指向某个已处理队列的规则时，无需额外配置。

如果路由规则把队列名设为空，使任务进入上表中的队列，并且 `sidekiq['queue_groups']` 只列出了具体队列名，
必须把上表中的队列加入某个进程。例如，对于 Linux 软件包实例，编辑 `/etc/gitlab/gitlab.rb`：

```ruby
sidekiq['queue_groups'] = [
  # 保留原有的队列组
  'notifications:notifications_fanout,notifications:notifications_channel_enqueue,feishu:feishu_send_notification,wecom:wecom_send_notification'
]
```

保存文件并重新配置极狐GitLab。
多节点部署时，所有 Sidekiq 节点使用相同配置。

## 限制

- 飞书授权登录未启用 PKCE。飞书换取令牌时对 PKCE 请求固定返回错误码 `20049`，
  见 [larksuite/oapi-sdk-go#230](https://github.com/larksuite/oapi-sdk-go/issues/230)。
  OAuth `state` 校验仍然防护 CSRF，但不能替代 PKCE 对授权码注入的防护。
  飞书修复该问题后再启用 PKCE。
- 飞书只能用于绑定已有账号和登录，不能用于注册，也不按邮箱自动关联账号。
- `feishu` OmniAuth 配置是登录和个人通知的唯一凭据来源。

## 故障排查

| 现象 | 排查方向 |
| --- | --- |
| 登录页没有 **Feishu** 按钮 | 检查 `omniauth.enabled` 以及 `providers` 中是否有 `feishu` |
| 注册页没有 **Feishu** 按钮 | 预期行为。飞书只用于绑定和登录 |
| 提示需要先拥有账号 | 预期行为。先创建极狐GitLab 账号，再从 **Service sign-in** 绑定 |
| 登录或绑定显示 `Feishu authentication failed` | 检查 `args.tenant_key` 是否完整，并确认授权账号与应用属于同一租户 |
| 回调后出现 `csrf_detected` | 在同一个桌面浏览器会话中重新发起并完成绑定 |
| 更换租户或应用后无法登录 | 解除旧绑定，并使用新应用重新绑定 |
| 看不到 **同时发送通知到我的飞书账号** | 检查功能标志、许可证、部署类型和完整的 OmniAuth 配置 |
| 收到邮件但收不到飞书卡片 | 检查用户开关、账号绑定、机器人能力、应用版本、权限和可用范围 |
| 收不到邮件，也收不到飞书卡片 | 先检查项目和用户的邮件通知设置 |
| 错误 `230006` | 启用机器人能力并发布应用版本 |
| 错误 `230013` | 把用户加入机器人可用范围，确认用户未离职或被禁用 |
| 错误 `230020`、`99991400` 或 HTTP `429` | 已触发飞书频率限制。消息会延迟重试，三次后仍失败则记录并停止 |
| 卡片不显示极狐GitLab 图标 | 为应用申请 `im:resource` 权限并发布版本，10 分钟后生效 |
| 通知长时间未送达，队列持续堆积 | 检查 Sidekiq 是否处理[个人通知使用的队列](#sidekiq-队列) |
| 错误 `99991401` | 应用启用了 IP 白名单，把服务器全部公网出口 IP 加入白名单 |
| 错误 `20024` | 授权码与 App ID 不匹配，检查是否混用了不同应用的凭据 |

飞书开放平台错误的含义可能调整。
排查其他错误时，参见[服务端错误码](https://open.feishu.cn/document/server-docs/api-call-guide/generic-error-code)。
