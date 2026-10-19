---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何修改极狐GitLab 实例的 HTML 头部标签。
title: 自定义 HTML 头部标签
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}


<a id="security-implications"></a>

## 安全影响

在启用此功能之前，您应了解它可能带来的安全影响。

一个原本合法的外部资源可能会被入侵，然后被用来从极狐GitLab 实例中的任何用户处提取几乎任何数据。因此，您绝不应添加来自不受信任的外部来源的资源。如有可能，您应始终对第三方资源使用诸如[子资源完整性](https://www.w3.org/TR/sri/)之类的完整性检查，以确认所加载资源的真实性。

请将您通过 HTML 头部标签添加的功能限制在最低限度。否则，例如当您与极狐GitLab 的其他应用代码交互时，也可能导致稳定性或功能问题。

<a id="add-a-custom-html-header-tag"></a>

## 添加自定义 HTML 头部标签

您必须将外部来源添加到内容安全策略中，该策略可通过 `content_security_policy` 选项进行配置。对于以下示例，您必须扩展 `script_src` 和 `style_src`。

要添加自定义 HTML 头部标签：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Self-compiled (Source)" >}}

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
