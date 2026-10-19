---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为极狐GitLab 配置 Diagrams.net 集成。
gitlab_dedicated: yes
title: Diagrams.net
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 [diagrams.net](https://www.drawio.com/) 集成，在 Wiki 中创建并嵌入 SVG 图表。
图表编辑器在纯文本编辑器和富文本编辑器中均可使用。

此集成适用于所有 JihuLab.com 用户，无需额外配置。

对于极狐GitLab 私有化部署，您可以集成免费的 [diagrams.net](https://www.drawio.com/) 网站，也可以在离线环境中自行托管 diagrams.net 站点。

要设置该集成：

1. 选择集成免费的 diagrams.net 网站，或
   [配置您的 diagrams.net 服务器](#configure-your-diagramsnet-server)。
1. [启用该集成](#enable-diagramsnet-integration)。

完成集成后，diagrams.net 编辑器会使用您提供的 URL 打开。

<a id="configure-your-diagramsnet-server"></a>

## 配置您的 diagrams.net 服务器

您可以设置自己的 diagrams.net 服务器来生成图表。对于极狐GitLab 私有化部署离线安装，此步骤是必需的。

要在 Docker 中运行 diagrams.net 容器，请运行以下命令：

```shell
docker run -it --rm --name="draw" -p 8006:8080 -p 8443:8443 jgraph/drawio
```

> [!note]
> HTTP 端点请使用端口 `8006`。您应避免使用默认端口 `8080`，
> 因为 [Puma](../operations/puma.md) 会监听端口 `8080` 以获取指标。

请记下运行该容器的服务器的主机名。启用该集成时，您需要将此主机名用作
diagrams.net URL。

有关更多信息，请参阅[使用 Docker 运行您自己的 diagrams.net 服务器](https://www.drawio.com/blog/diagrams-docker-app)。

<a id="enable-diagramsnet-integration"></a>

## 启用 Diagrams.net 集成

1. 以[管理员](../../user/permissions.md)用户身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **Diagrams.net**。
1. 选中**启用 Diagrams.net** 复选框。
1. 输入 Diagrams.net URL。要连接到：
   - 免费的公共实例：输入 `https://embed.diagrams.net`。
   - 本地托管的 diagrams.net 实例：输入您[之前配置的](#configure-your-diagramsnet-server) URL。
1. 选择**保存更改**。
