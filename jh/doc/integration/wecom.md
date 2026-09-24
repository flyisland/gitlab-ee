---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 企业微信 OmniAuth 提供商
description: 使用企业微信自建应用登录极狐GitLab。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

企业成员可以用企业微信扫码登录极狐GitLab。

## 前提条件

- 一个企业微信**自建应用**。暂不支持第三方（服务商）应用。
- 极狐GitLab 实例能够访问 `qyapi.weixin.qq.com` 和 `login.work.weixin.qq.com`。
  部署在无出网权限的内网时，此功能无法使用。
- 一个可以完成归属校验的公网域名。企业微信按域名校验回调地址，`localhost`
  无法通过。
- 能够把实例的公网出口 IP 加入企业微信的**企业可信IP** 名单。

## 配置流程

登录与消息通知共用同一个自建应用。标注「仅消息通知」的步骤只在需要接收消息通知时执行，
其余步骤登录和绑定都必须完成。

管理员：

1. [在企业微信创建自建应用](#在企业微信创建自建应用)，取得企业 ID、AgentId 和 Secret，
   并配置授权回调域。
1. [配置极狐GitLab](#配置极狐gitlab)，把这三个值填入 OmniAuth 提供商配置并重新配置实例。
1. [配置企业可信IP](#配置企业可信ip)，把实例的公网出口 IP 加入名单。
1. （仅消息通知）[启用功能标志](#启用功能标志) `jh_wecom_app_notification`。

用户：

1. [绑定自己的企业微信账号](#绑定与登录)。绑定之后才能用企业微信登录。
1. （仅消息通知）在通知设置中[勾选接收企业微信通知](#用户开启接收)。

## 在企业微信创建自建应用

1. 登录[企业微信管理后台](https://work.weixin.qq.com/)。
1. 转到 **应用管理 > 自建 > 创建应用**，创建应用。
1. 记录下 **AgentId** 和 **Secret**。
1. 转到 **我的企业**，记录下 **企业 ID**（CorpID）。
1. 在应用详情页的 **企业微信授权登录** 中，把极狐GitLab 的域名填入
   **授权回调域**，并按页面提示完成域名归属校验。

   这里只填域名，不带协议、端口和路径。实例地址是 `https://gitlab.example.com` 时，
   填 `gitlab.example.com`。回调路径 `/users/auth/wecom/callback` 由极狐GitLab
   自行处理，不需要在企业微信这边登记。

1. 在应用的 **可见范围** 中，加入需要使用此登录方式的成员。

四个值的位置与形态：

| 值 | 位置 | 形态 | 示例 |
| --- | --- | --- | --- |
| 企业 ID（CorpID） | **我的企业 > 企业信息**，页面底部 | `ww` 加 16 位小写十六进制 | `ww9f3d5b2c8a1e4067` |
| AgentId | 应用详情页顶部 | 7 位数字 | `1000025` |
| Secret | 应用详情页，AgentId 下方，点 **查看** | 43 位随机字符串 | `Xk2pQ7mB…` |
| 可见范围 | 应用详情页 **可见范围** | 部门、标签或成员 | 研发中心 |

Secret 需要点击 **查看** 才显示，可能要求管理员扫码验证。重置 Secret 后旧值立即失效。

有两处容易混淆：

- **Secret 不是 EncodingAESKey。** 两者都是长随机字符串。Secret 在应用详情页顶部、与
  AgentId 相邻；EncodingAESKey 属于 **接收消息** 配置。填错时登录与消息都会报
  `40001 invalid credential`。本功能不需要 EncodingAESKey。
- **可见范围必须覆盖全体需要接收通知的成员。** 不在范围内的成员，企业微信在成功响应中
  以 `invaliduser` 返回，该成员收不到消息，但接口本身不报错。

## 配置极狐GitLab

1. 参见 [配置通用设置](omniauth.md#configure-common-settings) 完成通用配置。

1. 添加提供商配置。

   对于 Linux 软件包（Omnibus）实例，编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_enabled'] = true
   gitlab_rails['omniauth_providers'] = [
     {
       'name' => 'wecom',
       'app_id' => 'YOUR_CORP_ID',
       'app_secret' => 'YOUR_CORP_SECRET',
       'args' => {
         'agent_id' => 'YOUR_AGENT_ID'
       }
     }
   ]
   ```

   可选项 `label` 可以覆盖默认显示名“WeCom”，例如 `'label' => '企业微信登录'`。

   对于源码安装实例，编辑 `config/gitlab.yml`：

   ```yaml
   omniauth:
     enabled: true
     providers:
       - { name: 'wecom',
           app_id: 'YOUR_CORP_ID',
           app_secret: 'YOUR_CORP_SECRET',
           args: { agent_id: 'YOUR_AGENT_ID' } }
   ```

   | 配置项 | 说明 |
   | --- | --- |
   | `app_id` | 企业 ID（CorpID） |
   | `app_secret` | 自建应用的 Secret |
   | `args.agent_id` | 自建应用的 AgentID。**必填**，缺失时登录会报配置错误 |

1. **不要** 把 `wecom` 加入 `allow_single_sign_on` 或 `auto_link_user`：

   ```ruby
   # 保持 wecom 不在列表中
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
   gitlab_rails['omniauth_auto_link_user'] = ['saml']
   ```

   企业微信不提供可信的邮箱地址，因此不允许凭企业微信身份自动创建账号，也不
   允许按邮箱自动关联已有账号。用户必须先拥有极狐GitLab 账号，再主动绑定。

1. 保存文件并重新配置极狐GitLab。

## 配置企业可信IP

登录、绑定和消息通知都要求企业微信能够识别极狐GitLab 实例的来源 IP。在自建应用的
**开发者接口 > 企业可信IP** 中，填入实例的公网出口 IP；未配置时企业微信返回错误码
`60020`，**绑定会直接失败**，登录和消息通知同样无法完成。

配置企业可信IP 前，企业微信要求先设置**可信域名**或**接收消息服务器URL**。两者都要求
域名已完成 ICP 备案，且备案主体与企业主体相同或存在关联关系。公共内网穿透服务
（如 `trycloudflare.com`、`ngrok.io`）提供的域名无法通过此校验，需要使用企业自有域名。

### 获取实例的公网出口 IP

这里要填的是实例**主动访问外网时对方看到的源地址**，不是把实例域名 `ping` 出来的地址，
两者通常不是同一个。云上实例入站流量经弹性公网 IP 或负载均衡，出站流量经 NAT 网关，
是两个不同的公网 IP；照着 `ping` 域名得到的地址配置企业可信IP，会持续报 `60020`。

两种办法可以取得出口 IP：

1. 读 `60020` 报错信息中的 `from ip:` 字段，企业微信在错误信息里给出了它看到的来源 IP。
1. 在实例上执行 `curl -s ifconfig.me`。

出口 IP 不止一个时（例如 NAT 网关配置了多个 IP，或者所在网络启用了弹性伸缩），
把全部出口 IP 都加入名单。实例的出口 IP 变化后需要重新配置。

## 绑定与登录

重新配置完成后，登录页应当出现 **WeCom** 按钮。没有出现时参见[故障排查](#故障排查)。

绑定步骤：

1. 用户登录极狐GitLab 后，转到 **用户设置 > Access > Password and authentication**。
1. 在 **Service sign-in** 中点击 **Connect WeCom**，用企业微信扫码完成绑定。
1. 绑定完成后，即可在登录页使用 **WeCom** 登录。

**必须在桌面浏览器中发起并完成绑定。** 在企业微信客户端的内置浏览器中打开极狐GitLab
再点击绑定会失败：扫码授权后的回调会落在另一个会话中，state 校验不通过，日志中
记为 `csrf_detected`。

在 **Service sign-in** 中点击 **Disconnect WeCom** 可以解除绑定。

**注册页不提供企业微信按钮。** 企业微信不返回可信的邮箱地址，无法据此创建账号，
因此企业微信只用于登录和绑定。用户必须先有极狐GitLab 账号，再绑定企业微信。

## 验证配置

以下脚本在 Rails 控制台中一次性检查登录、绑定与消息通知所需的条件：

```ruby
u = User.find_by_username('YOUR_USERNAME')

{
  '非 SaaS 实例'   => !Gitlab.com?,
  '许可证'         => License.feature_available?(:wecom_app_integration),
  '功能标志'       => Feature.enabled?(:jh_wecom_app_notification, :instance),
  '自建应用配置'   => Gitlab::Wecom::App.configured?,
  '可投递通知'     => Gitlab::Wecom::App.notifications_available?,
  '用户已开启接收' => JH::Users::WecomNotification.enabled_for?(u),
  '企业微信 UserId' => JH::Users::WecomNotification.wecom_user_id_for(u),
  '绑定记录'       => u.identities.map { |i| [i.provider, i.extern_uid] }
}.each { |k, v| puts "#{k.ljust(18)} #{v.inspect}" }
```

- 「绑定记录」为空数组，说明该用户还没有绑定成功，参见[绑定与登录](#绑定与登录)。
- 「企业微信 UserId」为 `nil` 但「绑定记录」不为空，说明绑定记录中的 CorpID 与当前
  配置的 CorpID 不一致，需要参见[更换企业 ID 后需要重新绑定](#更换企业-id-后需要重新绑定)
  重新绑定。
- 「非 SaaS 实例」「许可证」「功能标志」「自建应用配置」四项是「可投递通知」的前置
  条件，任意一项为 `false`，通知设置页面都不会出现企业微信选项。
- 「功能标志」只影响消息通知，为 `false` 不影响登录和绑定。

## 更换企业 ID 后需要重新绑定

绑定记录中保存的是 `<CorpID>:<UserId>`。企业微信的 UserId 只在单个企业内唯一，
因此实例更换 CorpID 后，原有绑定会自动失效，用户需要重新绑定。这是有意为之：
否则旧绑定可能指向新企业中恰好同名的另一个成员。

## 企业微信消息通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验性功能

{{< /details >}}

{{< alert type="flag" >}}

此功能由名为 `jh_wecom_app_notification` 的功能标志控制，默认禁用。私有化部署实例的管理员可以启用此功能。

{{< /alert >}}

用户绑定企业微信账号后，可以选择把极狐GitLab 的通知同时发送到企业微信，以消息卡片形式呈现。

消息使用与登录**同一个自建应用**，不需要额外配置凭据。

### 前提条件

- 已按上文完成企业微信自建应用的配置。
- 已配置[企业可信IP](#配置企业可信ip)。
- 用户已绑定自己的企业微信账号。
- 用户在自建应用的**可见范围**内。不在范围内的成员，企业微信会拒收，日志中记录为无效收件人。

### 启用功能标志

在 Rails 控制台中启用：

```ruby
Feature.enable(:jh_wecom_app_notification)
```

禁用：

```ruby
Feature.disable(:jh_wecom_app_notification)
```

标志的作用范围是**整个实例**，不能按用户或按项目开启。它只控制**消息投递**这一段：

- 关闭时，通知设置页面不显示企业微信选项，已经勾选过的用户也不会收到消息。
  已保存的勾选状态会保留，重新启用后即刻恢复。
- 关闭时，企业微信**登录和绑定不受影响**。登录能力先于消息通知发布，不受此标志控制。
- 打开标志本身不会给任何人发消息，用户仍需自己勾选。

标志之外还有三个条件，任何一个不满足，通知设置页面同样不会出现企业微信选项：

| 条件 | 不满足时 |
| --- | --- |
| 实例不是 SaaS | 极狐GitLab.com 上不提供此功能 |
| 许可证包含 `wecom_app_integration` | 基础版及以上的许可证包含此特性 |
| 自建应用配置完整 | `app_id`、`app_secret`、`args.agent_id` 三项齐备 |

### 用户开启接收

功能启用后，用户在 **用户设置 > 通知** 页面会看到「同时发送通知到我的企业微信」选项。

该选项**默认关闭**：绑定企业微信账号本身不会开始接收通知，用户必须主动勾选。

### 推送范围

企业微信通知与**邮件通知完全一致**：邮件发给谁、什么时候发，企业微信就发给谁、什么时候发。
用户既有的通知级别、订阅关系和权限判断全部沿用，不新增也不减少通知事件。

由此带来三点后果：

- 邮件新增的通知类型，企业微信自动跟进，不需要额外配置。
- **项目关闭邮件通知后，企业微信也收不到。** 两个渠道共用同一套收件人判断。
- 用户邮箱因退信被限流时，企业微信同样收不到。

验证消息通知时需要用两个账号：极狐GitLab 不会给触发事件的用户自己发邮件，因此也不会
产生对应的企业微信卡片。可以让另一个成员在议题中提及你来测试。

### 消息内容

卡片标题取自对应邮件的**主题行**，去掉邮件会话用的 `Re:` 前缀和重复的项目名；链接指向
邮件中「在极狐GitLab 上查看」的同一地址。卡片另有两行：项目名称，以及**通知原因**
（被指派、被请求评审、被提及、已订阅）。

同一个议题或合并请求上的所有通知，邮件主题是相同的（这是邮件会话串联的需要），
因此仅凭标题无法区分是指派还是评论，通知原因这一行用于补足这一点。

卡片还带一段**摘要**，取自同一封邮件的纯文本正文（截断到 120 字，其中的链接会去掉，
因为卡片本身就可以点击）。摘要与邮件措辞一致。

**机密议题及其讨论不带摘要**，卡片只有标题和链接。卡片会离开实例发往第三方，
内容需要回到极狐GitLab 阅读，走既有的权限校验。

卡片左上角的图标由成员的企业微信客户端向实例地址请求。成员的手机无法访问实例时（例如实例只在内网开放），
卡片正常显示，只是没有图标，不影响消息送达。

### 已知限制

- 企业微信对单个应用向同一成员的发送频率有限制（30 次/分钟），并按账号规模设有每日人次额度。超出后企业微信会丢弃消息，极狐GitLab 记录日志但不会重试，以免加重限流。
- 由于与邮件同频，邮件量大的实例（例如开启了流水线通知）会产生同样多的卡片，更容易触及上述频率限制。
- 每条企业微信通知会额外渲染一次对应的邮件内容，用于取得卡片标题和链接。
- 实例更换 CorpID 后，用户需要重新绑定才能继续接收通知。

## 故障排查

| 现象 | 排查方向 |
| --- | --- |
| 登录页没有 **WeCom** 按钮 | 检查 `omniauth.enabled` 以及 `providers` 中是否有 `wecom` |
| 注册页没有 **WeCom** 按钮 | 预期行为。企业微信不用于注册，只用于登录和绑定 |
| 提示需要先拥有账号 | 预期行为。企业微信登录不自动建号，请先创建账号再绑定 |
| 报错 `agent_id` 未配置 | `args.agent_id` 缺失，扫码登录必须提供 |
| 回调后报错域名不匹配 | 应用的 **授权回调域** 与实例域名不一致，或未完成归属校验 |
| 报错无法连接企业微信 | 实例没有访问 `qyapi.weixin.qq.com` 的出网权限 |
| 成员提示不在可见范围 | 把该成员加入自建应用的 **可见范围** |
| 绑定后页面仍显示 **Connect WeCom** | 查 `application_json.log` 中的 `Authentication failure!` 记录，其中带有企业微信返回的具体错误 |
| 日志中出现 `Authentication failure! ... 60020` | 实例的公网出口 IP 不在自建应用的 **企业可信IP** 名单中 |
| 日志中出现 `Authentication failure! csrf_detected` | 在企业微信客户端的内置浏览器中发起了绑定，改用桌面浏览器 |
| 看不到「同时发送通知到我的企业微信」选项 | 逐项核对[启用功能标志](#启用功能标志)中列出的标志与三个条件，或用[验证配置](#验证配置)中的脚本一次性检查 |
| 勾选了但收不到通知 | 确认已绑定企业微信账号，且该成员在应用可见范围内 |
| 收到邮件但收不到企业微信 | 确认已勾选接收，且实例出口 IP 在 **企业可信IP** 名单中 |
| 收不到邮件，也收不到企业微信 | 预期行为。两个渠道共用收件人判断，先排查邮件通知设置 |
