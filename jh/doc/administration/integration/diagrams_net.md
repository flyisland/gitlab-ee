---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure a Diagrams.net integration for GitLab.
gitlab_dedicated: yes
title: Diagrams.net
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 离线环境支持在极狐GitLab 16.1 中引入。

{{< /history >}}

使用 [diagrams.net](https://www.drawio.com/) 集成在 wiki 中创建和嵌入 SVG 图表。图表编辑器在纯文本编辑器和富文本编辑器中均可用。

此集成对所有 JihuLab.com 用户可用，无需额外配置。

对于极狐GitLab 私有化部署，你可以集成免费的 [diagrams.net](https://www.drawio.com/) 网站，或在离线环境中托管你自己的 diagrams.net 站点。

要设置此集成：

1. 选择集成免费的 diagrams.net 网站或[配置你的 diagrams.net 服务器](#configure-your-diagramsnet-server)。
1. [启用集成](#enable-diagramsnet-integration)。

完成集成后，diagrams.net 编辑器将使用你提供的 URL 打开。

<a id="configure-your-diagramsnet-server"></a>

## 配置你的 diagrams.net 服务器

你可以设置你自己的 diagrams.net 服务器来生成图表。对于极狐GitLab 私有化部署的离线安装，此步骤是必需的。

要在 Docker 中运行 diagrams.net 容器，请运行以下命令：

```shell
docker run -it --rm --name="draw" -p 8006:8080 -p 8443:8443 jgraph/drawio
```

> [!note]
> 对 HTTP 端点使用端口 `8006`。你应该避免使用默认端口 `8080`，因为 [Puma](../operations/puma.md) 监听端口 `8080` 以获取指标。

记下运行容器的服务器的主机名。你将在启用集成时使用此主机名作为 diagrams.net URL。

更多信息，请参见[使用 Docker 运行你自己的 diagrams.net 服务器](https://www.drawio.com/blog/diagrams-docker-app)。

<a id="enable-diagramsnet-integration"></a>

## 启用 Diagrams.net 集成

1. 以[管理员](../../user/permissions.md)身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **Diagrams.net**。
1. 选中 **启用 Diagrams.net** 复选框。
1. 输入 Diagrams.net URL。要连接到：
   - 免费公共实例：输入 `https://embed.diagrams.net`。
   - 本地托管的 diagrams.net 实例：输入你[之前配置](#configure-your-diagramsnet-server)的 URL。
1. 选择 **保存更改**。

<end>