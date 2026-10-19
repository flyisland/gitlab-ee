---
stage: AI Clients
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 指定 Web IDE 用于隔离 VS Code 扩展和 Web 视图的通配符域名
title: Web IDE 扩展主机域名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

扩展主机域名是 Web IDE 用于隔离通过[扩展市场](../../user/project/web_ide/_index.md#manage-extensions)安装的第三方代码的通配符域名。Web IDE 依赖 Web 浏览器的[同源](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Same-origin_policy)策略，在沙箱环境中运行扩展。

极狐GitLab 提供默认的扩展主机域名 `*.cdn.web-ide.gitlab-static.net`，默认情况下所有极狐GitLab 交付方式均可使用。该通配符域名指向一个托管 VS Code 静态资源的外部 HTTP 服务器。每个扩展都从其各自的子域名提供。在离线环境中，用户的 Web 浏览器无法连接到此外部 HTTP 服务器，进而限制了 Web IDE 的能力。

为规避此限制，极狐GitLab 实例管理员可以设置自定义扩展主机域名。自定义扩展主机域名指向极狐GitLab 实例本身，该实例也可以像默认方案一样提供 VS Code 静态资源。

> [!warning]
> 在 Web IDE 扩展主机域名中配置过于宽泛的通配符域名会带来严重的安全风险。配置错误可能导致您的极狐GitLab 实例及所有相关数据遭到入侵。

<a id="set-up-custom-extension-host-domain"></a>

## 设置自定义扩展主机域名

先决条件：

- 您必须是管理员。

这些说明适用于使用默认 NGINX 安装的 [Linux 软件包安装](../../install/package/_index.md)。极狐GitLab 管理员和 DevOps 工程师应针对其他安装方式调整本指南。

1. 按照[将自定义设置插入 NGINX 配置](https://gitlab.cn/docs/omnibus/settings/nginx/#insert-custom-settings-into-the-nginx-configuration)指南添加一个 `server` 块。该块配置 NGINX 以处理扩展主机域名的请求。以下代码片段提供了参考配置。将 `<extension-host-domain-placeholder>` 替换为您的 Web IDE 扩展主机域名的通配符域名：

   ```nginx
   server {
     listen *:443 ssl;
     server_name *.<extension-host-domain-placeholder>;

     ssl_certificate /etc/gitlab/ssl/<extension-host-domain-placeholder>.pem;
     ssl_certificate_key /etc/gitlab/ssl/<extension-host-domain-placeholder>-key.pem;

     ## Individual nginx logs for this GitLab vhost
     access_log  /var/log/gitlab/nginx/gitlab_access.log gitlab_access;
     error_log   /var/log/gitlab/nginx/gitlab_error.log;

     location /assets/ {
       client_max_body_size 0;
       gzip off;

       proxy_read_timeout      300;
       proxy_connect_timeout   300;
       proxy_redirect          off;

       proxy_http_version 1.1;

       proxy_set_header    Host                $http_host;
       proxy_set_header    X-Real-IP           $remote_addr;
       proxy_set_header    X-Forwarded-For     $remote_addr;
       proxy_set_header    X-Forwarded-Proto   $scheme;

       proxy_pass http://gitlab-workhorse;
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。然后，打开极狐GitLab 应用程序。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **Web IDE**。
1. 在**扩展主机域名**文本框中，输入自定义扩展主机域名。
1. 选择**保存更改**。

保存更改后，您可以在 Web IDE 中打开一个项目，以验证编辑器是否使用了自定义扩展主机。

<a id="single-origin-fallback"></a>

## 单一源回退

> [!warning]
> 单一源回退默认启用，存在安全风险。您应禁用该回退，并改为确保扩展主机域名未被 CORS 配置、Web 浏览器安全策略或代理服务器阻止。

默认情况下，Web IDE 以多源模式运行，从单独的扩展主机域名提供 VS Code 静态资源。这种隔离可防止恶意行为者利用扩展主机向极狐GitLab 实例发起经过身份验证的请求。

但是，当扩展主机域名因网络或 CORS 限制而无法访问时，Web IDE 会自动回退到单一源模式。在此模式下，Web IDE 从与极狐GitLab 应用程序相同的源提供 VS Code 资源，这会增大攻击面并产生安全漏洞。

**启用单一源回退**设置控制当扩展主机域名无法访问时，Web IDE 是否可以回退到单一源模式。

先决条件：

- 管理员访问权限。

要配置此设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **Web IDE**。
1. 选中或清除**启用单一源回退**复选框。
1. 选择**保存更改**。
