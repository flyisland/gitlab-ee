---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代理资源
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理面向公众的极狐GitLab 实例时，一个可能的安全隐患是可以通过在议题和评论中引用图片来窃取用户的 IP 地址。

例如，在议题描述中添加 `![示例图片。](http://example.com/example.png)` 会导致图片从外部服务器加载以显示。但这也允许外部服务器记录用户的 IP 地址。

缓解此问题的一种方法是将所有外部图片代理到你控制的服务器。

极狐GitLab 可以配置为在请求议题和评论中的外部图片/视频/音频时使用资源代理服务器。这有助于确保在获取恶意图片时不会暴露用户的 IP 地址。

我们目前推荐使用 [cactus/go-camo](https://github.com/cactus/go-camo#how-it-works)，因为它支持代理视频和音频，并且可配置性更高。

<a id="installing-camo-server"></a>

## 安装 Camo 服务器

Camo 服务器用于充当代理。

要将 Camo 服务器安装为资源代理：

1. 部署一个 `go-camo` 服务器。有用的说明可以在[构建 cactus/go-camo](https://github.com/cactus/go-camo#building) 中找到。

   > [!warning]
   > 资源代理服务器应配置为使用正确的 Content Security Policy 标头，
   > 例如 `form-action 'none'`（以及默认的 `go-camo` 标头）。

1. 确保你的极狐GitLab 实例正在运行，并且你已经创建了私有 API 令牌。使用 API，在极狐GitLab 实例上配置资源代理设置。例如：

   ```shell
   curl --request "PUT" "https://gitlab.example.com/api/v4/application/settings?\
   asset_proxy_enabled=true&\
   asset_proxy_url=https://proxy.gitlab.example.com&\
   asset_proxy_secret_key=<somekey>" \
   --header 'PRIVATE-TOKEN: <my_private_token>'
   ```

   支持以下设置：

   | 属性                      | 描述                                                                                                                          |
   |:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|
   | `asset_proxy_enabled`    | 启用资源代理。如果启用，需要设置：`asset_proxy_url`。                                                                  |
   | `asset_proxy_secret_key` | 与资源代理服务器的共享密钥。                                                                                           |
   | `asset_proxy_url`        | 资源代理服务器的 URL。                                                                                                       |
   | `asset_proxy_whitelist`  | （已弃用：请改用 `asset_proxy_allowlist`）匹配这些域名的资源不会被代理。允许通配符。你的极狐GitLab 安装 URL 会自动添加到允许列表中。         |
   | `asset_proxy_allowlist`  | 匹配这些域名的资源不会被代理。允许通配符。你的极狐GitLab 安装 URL 会自动添加到允许列表中。         |

1. 重启服务器以使更改生效。每次更改资源代理的任何值时，都需要重启服务器。

<a id="using-the-camo-server"></a>

## 使用 Camo 服务器

一旦 Camo 服务器运行并且你已启用极狐GitLab 设置，任何引用外部源的图片、视频或音频都会被代理到 Camo 服务器。

例如，以下是指向 Markdown 中图片的链接：

```markdown
![极狐GitLab 标志。](https://gitlab.cn/images/press/logo/jpg/gitlab-icon-rgb.jpg)
```

以下是一个可能生成的源链接示例：

```plaintext
http://proxy.gitlab.example.com/f9dd2b40157757eb82afeedbf1290ffb67a3aeeb/68747470733a2f2f61626f75742e6769746c61622e636f6d2f696d616765732f70726573732f6c6f676f2f6a70672f6769746c61622d69636f6e2d7267622e6a7067
```