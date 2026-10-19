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

极狐GitLab 利用 [reCAPTCHA](https://www.google.com/recaptcha/about/)
来防范垃圾信息和滥用行为。极狐GitLab 会在新用户账号页面上显示 CAPTCHA 表单，以确认尝试创建账号的是真实用户而非机器人。

<a id="configuration"></a>

## 配置

要使用 reCAPTCHA，请先创建一个站点和私钥。

1. 前往 [Google reCAPTCHA 页面](https://www.google.com/recaptcha/admin)。
1. 要获取 reCAPTCHA v2 密钥，请填写表单并选择**提交**。
1. 以管理员身份登录您的极狐GitLab 服务器。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **报告**。
1. 展开**垃圾信息和反机器人保护**。
1. 在 reCAPTCHA 字段中，输入您在前述步骤中获取的密钥。
1. 选中**启用 reCAPTCHA** 复选框。
1. 要为通过密码登录启用 reCAPTCHA，请选中**为登录启用 reCAPTCHA** 复选框。
1. 选择**保存更改**。
1. 要绕过垃圾信息检查并触发返回 `recaptcha_html` 的响应：
   1. 打开 `app/services/spam/spam_verdict_service.rb`。
   1. 将 `#execute` 方法的第一行改为 `return CONDITIONAL_ALLOW`。

> [!note]
> 请确保您查看的对象位于公开项目中。如果您处理的是议题，则该议题必须公开。

<a id="enable-recaptcha-for-user-logins-using-the-http-header"></a>

## 使用 HTTP 请求头为用户登录启用 reCAPTCHA

您可以通过[用户界面](#configuration)为通过密码登录的用户启用 reCAPTCHA，也可以通过设置 `X-GitLab-Show-Login-Captcha` HTTP 请求头来启用。例如，在 NGINX 中，可以通过 `proxy_set_header` 配置变量来实现：

```nginx
proxy_set_header X-GitLab-Show-Login-Captcha 1;
```

对于 Linux 软件包实例，请在 `/etc/gitlab/gitlab.rb`中配置：

```ruby
nginx['proxy_set_headers'] = { 'X-GitLab-Show-Login-Captcha' => '1' }
```
