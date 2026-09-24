---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to modify the HTML header tags of your GitLab instance.
title: 自定义 HTML 头部标签
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.1。

{{< /history >}}

<a id="custom-html-header-tags"></a>

## 自定义 HTML 头部标签

如果您在欧盟或任何需要 Cookie 同意横幅的司法管辖区中私有化部署极狐GitLab 实例，则需要额外的 HTML 头部标签来添加脚本和样式表。

<a id="security-implications"></a>

### 安全影响

在启用此功能之前，您应了解可能带来的安全影响。

之前合法外部资源最终可能会被攻破，然后用于从极狐GitLab 实例的任何用户中窃取几乎所有数据。因此，您绝不应添加来自不受信任的外部源的内容。如果可能的话，您应始终使用第三方资源的完整性检查，如[子资源完整性](https://www.w3.org/TR/SRI/)（Subresource Integrity），以确认所加载资源的真实性。

将您通过 HTML 头部标签添加的功能限制到最少。否则，如果您与极狐GitLab 的其他应用程序代码进行交互，也可能导致稳定性或功能问题。

<a id="add-a-custom-html-header-tag"></a>

### 添加自定义 HTML 头部标签

您必须在 `content_security_policy` 选项中可用的内容安全策略 (CSP) 中添加外部源。对于以下示例，您必须扩展 `script_src` 和 `style_src`。

要添加自定义 HTML 头部标签：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加您的配置。例如：

   ```ruby
   gitlab_rails['custom_html_header_tags'] = <<-'EOS'
   <script src="https://example.com/cookie-consent.js" integrity="sha384-Li9vy3DqF8tnTXuiaAJuML3ky+er10rcgNR/VqsVpcw+ThHmYcwiB1pbOxEbzJr7" crossorigin="anonymous"></script>
   <link rel="stylesheet" href="https://example.com/cookie-consent.css" integrity="sha384-+/M6kredJcxdsqkczBUjMLvqyHb1K/JThDXWsBVxMEeZHEaMKEOEct339VItX1zB" crossorigin="anonymous">
   EOS

   gitlab_rails['content_security_policy'] = {
   # extend the following directives
     'directives' => {
       'script_src' => "'self' 'unsafe-eval' https://example.com https://www.google.com/recaptcha/ https://www.recaptcha.net/ https://www.gstatic.com/recaptcha/ https://apis.google.com",
       'style_src' => "'self' 'unsafe-inline' https://example.com",
     }
    }
   ```

1. 保存文件，然后[重新配置](restart_gitlab.md#reconfigure-a-linux-package-installation)并[重启](restart_gitlab.md#restart-a-linux-package-installation)极狐GitLab。

{{< /tab >}}

{{< tab title="自编译 (Source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     gitlab:
       custom_html_header_tags: |
         <script src="https://example.com/cookie-consent.js" integrity="sha384-Li9vy3DqF8tnTXuiaAJuML3ky+er10rcgNR/VqsVpcw+ThHmYcwiB1pbOxEbzJr7"         crossorigin="anonymous"></script>
         <link rel="stylesheet" href="https://example.com/cookie-consent.css" integrity="sha384-+/M6kredJcxdsqkczBUjMLvqyHb1K/JThDXWsBVxMEeZHEaMKEOEct339VItX1zB"        crossorigin="anonymous">
       content_security_policy:
         directives:
           script_src: "'self' 'unsafe-eval' https://example.com http://localhost:* https://www.google.com/recaptcha/ https://www.recaptcha.net/ https://www.gstatic.com/recaptcha/ https://apis.google.com"
           style_src: "'self' 'unsafe-inline' https://example.com"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}
 