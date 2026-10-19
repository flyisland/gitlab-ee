---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置 Camo 资产代理服务器，以防止外部图片和媒体泄露用户 IP 地址。
title: 代理资产
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在管理面向公众的极狐GitLab 实例时，一个可能的安全隐患是：攻击者可以通过在议题和评论中引用图片来窃取用户的 IP 地址。

例如，在议题描述中添加 `![An example image.](http://example.com/example.png)` 会导致从外部服务器加载并显示该图片。然而，这也使得外部服务器能够记录用户的 IP 地址。

缓解此问题的一种方法是将所有外部图片代理到您控制的服务器。

您可以配置极狐GitLab，使其在议题和评论中请求外部图片/视频/音频时使用资产代理服务器。这有助于确保在获取恶意图片时不会泄露用户的 IP 地址。

您应使用 [cactus/go-camo](https://github.com/cactus/go-camo#how-it-works)，因为它支持代理视频和音频，并且可配置性更强。

<a id="installing-camo-server"></a>

## 安装 Camo 服务器

Camo 服务器用作代理。

要将 Camo 服务器安装为资产代理：

1. 部署一个 `go-camo` 服务器。可在
   [构建 cactus/go-camo](https://github.com/cactus/go-camo#building)中找到有用的说明。

   > [!warning]
   > 资产代理服务器应配置为使用正确的内容安全策略响应头，
   > 例如 `form-action 'none'`（以及默认的 `go-camo` 响应头）。

1. 确保您的极狐GitLab 实例正在运行，并且您已创建私有 API 令牌。
   使用 API 在您的极狐GitLab 实例上配置资产代理设置。例如：

   ```shell
   curl --request "PUT" "https://gitlab.example.com/api/v4/application/settings?\
   asset_proxy_enabled=true&\
   asset_proxy_url=https://proxy.gitlab.example.com&\
   asset_proxy_secret_key=<somekey>" \
   --header 'PRIVATE-TOKEN: <my_private_token>'
   ```

   支持以下设置：

   | 属性                | 描述                                                                                                                          |
   |:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|
   | `asset_proxy_enabled`    | 开启资产代理。如果开启，则需要：`asset_proxy_url`。                                                                |
   | `asset_proxy_secret_key` | 与资产代理服务器共享的密钥。                                                                                           |
   | `asset_proxy_url`        | 资产代理服务器的 URL。                                                                                                       |
   | `asset_proxy_whitelist`  | （已弃用：请改用 `asset_proxy_allowlist`）匹配这些域名的资产不会被代理。允许使用通配符。您的极狐GitLab 安装 URL 会自动加入允许名单。         |
   | `asset_proxy_allowlist`  | 匹配这些域名的资产不会被代理。允许使用通配符。您的极狐GitLab 安装 URL 会自动加入允许名单。         |

1. 重启服务器以使更改生效。每次更改资产代理的任何值后，都需要重启服务器。

<a id="using-the-camo-server"></a>

## 使用 Camo 服务器

在 Camo 服务器运行并且您开启极狐GitLab 设置后，任何引用外部来源的图片、视频或音频都会被代理到 Camo 服务器。

例如，以下是指向 Markdown 中图片的链接：

```markdown
![A GitLab logo.](https://about.gitlab.com/images/press/logo/jpg/gitlab-icon-rgb.jpg)
```

以下是一个可能生成的来源链接示例：

```plaintext
http://proxy.gitlab.example.com/f9dd2b40157757eb82afeedbf1290ffb67a3aeeb/68747470733a2f2f61626f75742e6769746c61622e636f6d2f696d616765732f70726573732f6c6f676f2f6a70672f6769746c61622d69636f6e2d7267622e6a7067
```
