---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: reCAPTCHA
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 借助 [reCAPTCHA](https://www.google.com/recaptcha/about/) 来防范垃圾信息和滥用行为。极狐GitLab 会在新用户账号页面上显示验证码表单，以确认是真实用户而非机器人尝试创建账号。

<a id="configuration"></a>

## 配置

要使用 reCAPTCHA，请先创建站点及私钥。

1. 前往 [Google reCAPTCHA 页面](https://www.google.com/recaptcha/admin)。
1. 如需获取 reCAPTCHA v2 密钥，请填写表单并选择 **提交**。
1. 以管理员身份登录您的极狐GitLab 服务器。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **报告**。
1. 展开 **垃圾信息和反爬虫保护**。
1. 在 reCAPTCHA 字段中，输入您在前几步中获得的密钥。
1. 勾选 **启用 reCAPTCHA** 复选框。
1. 如需对通过密码登录启用 reCAPTCHA，请勾选 **启用登录 reCAPTCHA** 复选框。
1. 选择 **保存更改**。
1. 要绕过垃圾信息检查并触发返回 `recaptcha_html` 的响应：
   1. 打开 `app/services/spam/spam_verdict_service.rb`。
   1. 将 `#execute` 方法的第一行改为 `return CONDITIONAL_ALLOW`。

> [!note]
> 请确保您正在查看的是公开项目中的一个议题。如果您正处理某个议题，该议题必须是公开的。

<a id="enable-recaptcha-for-user-logins-using-the-http-header"></a>

## 通过 HTTP 头部为用户登录启用 reCAPTCHA

您可以通过[用户界面](#configuration)对密码登录启用 reCAPTCHA，或者通过设置 `X-GitLab-Show-Login-Captcha` HTTP 头部来启用。例如，在 NGINX 中，可以通过 `proxy_set_header` 配置变量来实现：

```nginx
proxy_set_header X-GitLab-Show-Login-Captcha 1;
```

对于 Linux 软件包实例，请在 `/etc/gitlab/gitlab.rb` 中进行配置：

```ruby
nginx['proxy_set_headers'] = { 'X-GitLab-Show-Login-Captcha' => '1' }
```

