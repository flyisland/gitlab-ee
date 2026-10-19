---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 使用极狐GitLab 私有化部署配置 PlantUML 集成。
title: PlantUML
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 [PlantUML](https://plantuml.com) 集成，在代码片段、Wiki 和代码仓库中创建图表。
JihuLab.com 为所有用户集成了 PlantUML，无需额外配置。

要在您的极狐GitLab 私有化部署实例上设置该集成，您必须[配置您的 PlantUML 服务器](#configure-your-plantuml-server)。

完成集成后，PlantUML 会将 `plantuml`
代码块转换为 HTML 图片标签，其源指向 PlantUML 实例。PlantUML
图表分隔符 `@startuml`/`@enduml` 不是必需的，因为它们会被 `plantuml` 代码块替换：

- 扩展名为 `.md`的 Markdown 文件：

  ````markdown
  ```plantuml
  Bob -> Alice : hello
  Alice -> Bob : hi
  ```
  ````

  有关其他可接受的扩展名，请查看
  [`languages.yaml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/vendor/languages.yml#L3174) 文件。

- 扩展名为 `.asciidoc`、`.adoc` 或 `.asc`的 AsciiDoc 文件：

  ```plaintext
  [plantuml, format="png", id="myDiagram", width="200px"]
  ----
  Bob->Alice : hello
  Alice -> Bob : hi
  ----
  ```

- reStructuredText：

  ```plaintext
  .. plantuml::
     :caption: Caption with **bold** and *italic*

     Bob -> Alice: hello
     Alice -> Bob: hi
  ```

  尽管您可以使用 `uml::` 指令来兼容
  [`sphinxcontrib-plantuml`](https://pypi.org/project/sphinxcontrib-plantuml/)，
  但极狐GitLab 仅支持 `caption` 选项。

如果 PlantUML 服务器配置正确，这些示例应渲染出图表，而不是代码块：

```plantuml
Bob -> Alice : hello
Alice -> Bob : hi
```

在代码块中，添加 PlantUML 支持的任何图表，例如：

- [活动图](https://plantuml.com/activity-diagram-legacy)
- [类图](https://plantuml.com/class-diagram)
- [组件图](https://plantuml.com/component-diagram)
- [对象图](https://plantuml.com/object-diagram)
- [时序图](https://plantuml.com/sequence-diagram)
- [状态图](https://plantuml.com/state-diagram)
- [用例图](https://plantuml.com/use-case-diagram)

向代码块定义中添加参数：

- `id`：添加到图表 HTML 标签的 CSS ID。
- `width`：添加到图片标签的宽度属性。
- `height`：添加到图片标签的高度属性。

Markdown 不支持任何参数，并且始终使用 PNG 格式。

<a id="include-diagram-files"></a>

## 包含图表文件

要包含或嵌入代码仓库中单独文件里的 PlantUML 图表，请使用 `include` 指令。使用该指令可将复杂图表保存在专用文件中，或复用图表。例如：

- Markdown：

  ````markdown
  ```plantuml
  ::include{file=diagram.puml}
  ```
  ````

- AsciiDoc：

  ```plaintext
  [plantuml, format="png", id="myDiagram", width="200px"]
  ----
  include::diagram.puml[]
  ----
  ```

> [!note]
> `::include` 指令仅在文件提交到代码仓库后才会解析。
> Markdown 编辑器预览不会渲染包含的文件。要验证图表
> 是否正确渲染，请提交文件并在代码仓库文件浏览器中查看。

<a id="configure-your-plantuml-server"></a>

## 配置您的 PlantUML 服务器

在极狐GitLab 中启用 PlantUML 之前，请先设置您自己的 PlantUML
服务器以生成图表：

- [Docker](#docker)（推荐）
- [Debian/Ubuntu](#debianubuntu)

<a id="docker"></a>

### Docker

要在 Docker 中运行 PlantUML 容器，请运行以下命令：

```shell
docker run -d --name plantuml -p 8005:8080 plantuml/plantuml-server:tomcat
```

**PlantUML URL** 是运行该容器的服务器的主机名。

在 Docker 中运行极狐GitLab 时，它必须能够访问 PlantUML 容器。
为此，请使用 [Docker Compose](https://docs.docker.com/compose/)。
在这个基本的 `docker-compose.yml` 文件中，极狐GitLab 可通过 URL
`http://plantuml:8080/` 访问 PlantUML：

```yaml
services:
  gitlab:
    image: 'registry.gitlab.cn/omnibus/gitlab-jh:18.9.1-jh.0'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        nginx['custom_gitlab_server_config'] = "location /-/plantuml/ { \n    rewrite ^/-/plantuml/(.*) /$1 break;\n proxy_cache off; \n    proxy_pass  http://plantuml:8080/; \n}\n"

  plantuml:
    image: 'plantuml/plantuml-server:tomcat'
    container_name: plantuml
    ports:
     - "8005:8080"
```

接下来，您可以：

1. [配置本地 PlantUML 访问](#configure-local-plantuml-access)
1. [验证 PlantUML 安装](#verify-the-plantuml-installation)是否成功

<a id="debianubuntu"></a>

### Debian/Ubuntu

您可以在 Debian/Ubuntu 发行版中使用 Tomcat 或 Jetty 安装并配置 PlantUML 服务器。
以下说明适用于 Tomcat。

先决条件：

- JRE/JDK 版本 11 或更高版本。
- （推荐）Jetty 版本 11 或更高版本。
- （推荐）Tomcat 版本 10 或更高版本。

<a id="installation"></a>

#### 安装

PlantUML 建议安装 Tomcat 10.1 或更高版本。本页面的范围仅包括设置基本的 Tomcat 服务器。有关更接近生产环境的配置，
请参阅 [Tomcat 文档](https://tomcat.apache.org/tomcat-10.1-doc/index.html)。

1. 安装 JDK/JRE 11：

   ```shell
   sudo apt update
   sudo apt install default-jre-headless graphviz git
   ```

1. 为 Tomcat 添加用户：

   ```shell
   sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat
   ```

1. 安装并配置 Tomcat 10.1：

   ```shell
   wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.33/bin/apache-tomcat-10.1.33.tar.gz -P /tmp
   sudo tar xzvf /tmp/apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1
   sudo chown -R tomcat:tomcat /opt/tomcat/
   sudo chmod -R u+x /opt/tomcat/bin
   ```

1. 创建 systemd 服务。编辑 `/etc/systemd/system/tomcat.service` 文件并添加：

   ```shell
   [Unit]
   Description=Tomcat
   After=network.target

   [Service]
   Type=forking

   User=tomcat
   Group=tomcat

   Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
   Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
   Environment="CATALINA_BASE=/opt/tomcat"
   Environment="CATALINA_HOME=/opt/tomcat"
   Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
   Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

   ExecStart=/opt/tomcat/bin/startup.sh
   ExecStop=/opt/tomcat/bin/shutdown.sh

   RestartSec=10
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

   `JAVA_HOME` 应与 `sudo update-java-alternatives -l`中显示的路径相同。

1. 要配置端口，请编辑您的 `/opt/tomcat/conf/server.xml` 并选择您的
   端口。推荐：

   - 将 Tomcat 关闭端口从 `8005` 更改为 `8006`
   - 将端口 `8005` 用于 Tomcat HTTP 端点。应避免使用默认端口 `8080`，
     因为 [Puma](../operations/puma.md) 会监听端口 `8080` 以获取指标。

   ```diff
   - <Server port="8006" shutdown="SHUTDOWN">
   + <Server port="8005" shutdown="SHUTDOWN">

   - <Connector port="8005" protocol="HTTP/1.1"
   + <Connector port="8080" protocol="HTTP/1.1"
   ```

1. 重新加载并启动 Tomcat：

   ```shell
   sudo systemctl daemon-reload
   sudo systemctl start tomcat
   sudo systemctl status tomcat
   sudo systemctl enable tomcat
   ```

   Java 进程应监听以下端口：

   ```shell
   root@gitlab-omnibus:/plantuml-server# ❯ ss -plnt | grep java
   LISTEN   0        1          [::ffff:127.0.0.1]:8006                   *:*       users:(("java",pid=27338,fd=52))
   LISTEN   0        100                         *:8005                   *:*       users:(("java",pid=27338,fd=43))
   ```

1. 安装 PlantUML 并复制 `.war` 文件：

   使用 `plantuml-jsp`的[最新版本](https://github.com/plantuml/plantuml-server/releases)
   （例如：`plantuml-jsp-v1.2024.8.war`）。
   有关背景信息，请参阅[议题 265](https://github.com/plantuml/plantuml-server/issues/265)。

   ```shell
   wget -P /tmp https://github.com/plantuml/plantuml-server/releases/download/v1.2024.8/plantuml-jsp-v1.2024.8.war
   sudo cp /tmp/plantuml-jsp-v1.2024.8.war /opt/tomcat/webapps/plantuml.war
   sudo chown tomcat:tomcat /opt/tomcat/webapps/plantuml.war
   sudo systemctl restart tomcat
   ```

Tomcat 服务应重新启动。重新启动完成后，PlantUML 集成即准备就绪，并监听端口 `8005`：
`http://localhost:8005/plantuml`。

要更改 Tomcat 默认值，请编辑 `/opt/tomcat/conf/server.xml` 文件。

> [!note]
> 使用此方法时，默认 URL 不同。基于 Docker 的镜像
> 使服务在根 URL 上可用，没有相对路径。请相应地调整
> 下面的配置。

接下来，您可以：

1. [配置本地 PlantUML 访问](#configure-local-plantuml-access)。确保链接中配置的 `proxy_pass` 端口
   与 `server.xml`中的 Connector 端口一致。
1. [验证 PlantUML 安装](#verify-the-plantuml-installation)是否成功。

<a id="configure-local-plantuml-access"></a>

### 配置本地 PlantUML 访问

PlantUML 服务器在您的服务器上本地运行，因此默认情况下无法从外部访问。您的服务器必须捕获对 `https://gitlab.example.com/-/plantuml/` 的外部 PlantUML 调用，并将其重定向到本地 PlantUML 服务器。根据您的设置，URL 为以下之一：

- `http://plantuml:8080/`
- `http://localhost:8080/plantuml/`
- `http://plantuml:8005/`
- `http://localhost:8005/plantuml/`

如果您在 [TLS 保护下运行极狐GitLab](https://gitlab.cn/docs/omnibus/settings/ssl/)，则必须配置此重定向，因为 PlantUML 使用不安全的 HTTP 协议。较新的浏览器不会在通过 HTTPS 提供的页面上加载不安全的 HTTP 资源。

<a id="use-bundled-gitlab-nginx"></a>

#### 使用内置的 GitLab NGINX

如果您可以修改 `/etc/gitlab/gitlab.rb`，请配置内置的 NGINX 来处理重定向：

1. 根据您的设置方法，在 `/etc/gitlab/gitlab.rb`中添加以下行：

   ```ruby
   # Docker install
   nginx['custom_gitlab_server_config'] = "location /-/plantuml/ { \n  rewrite ^/-/plantuml/(.*) /$1 break;\n  proxy_cache off; \n    proxy_pass  http://plantuml:8005/; \n}\n"

   # Debian/Ubuntu install
   nginx['custom_gitlab_server_config'] = "location /-/plantuml/ { \n  rewrite ^/-/plantuml/(.*) /$1 break;\n  proxy_cache off; \n    proxy_pass  http://localhost:8005/plantuml; \n}\n"
   ```

1. 要激活更改，请运行以下命令：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="use-https-plantuml-server"></a>

#### 使用 HTTPS PlantUML 服务器

如果您无法修改 `gitlab.rb` 文件，请将您的 PlantUML 服务器配置为直接
使用 HTTPS。

此设置使用 NGINX 处理 SSL 终止并将请求代理到 PlantUML
容器。您也可以使用基于云的负载均衡器（如 AWS Application Load Balancer (ALB)）进行
SSL 终止。

1. 创建 `nginx.conf` 文件：

   ```nginx
   events {
       worker_connections 1024;
   }

   http {
       server {
           listen 443 ssl;
           server_name _;
           ssl_certificate /etc/nginx/ssl/plantuml.crt;
           ssl_certificate_key /etc/nginx/ssl/plantuml.key;
           location / {
               proxy_pass http://plantuml:8080;
               proxy_set_header Host $host;
               proxy_set_header X-Real-IP $remote_addr;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
               proxy_set_header X-Forwarded-Proto $scheme;
           }
       }
   }
   ```

1. 将 `plantuml.crt` 和 `plantuml.key` 文件添加到 `ssl` 目录。
1. 配置 `docker-compose.yml` 文件：

   ```yaml
   version: '3.8'

   services:
     plantuml:
       image: plantuml/plantuml-server:tomcat
       container_name: plantuml
       networks:
         - plantuml-net

     plantuml-ssl:
       image: nginx
       container_name: plantuml-ssl
       ports:
         - "8443:443"
       volumes:
         - ./nginx.conf:/etc/nginx/nginx.conf:ro
         - ./ssl:/etc/nginx/ssl:ro
       depends_on:
         - plantuml
       networks:
         - plantuml-net

   networks:
     plantuml-net:
       driver: bridge
   ```

1. 使用 `docker-compose up` 启动您的 PlantUML 服务器。
1. 使用 URL `https://your-server:8443` [启用 PlantUML 集成](#enable-plantuml-integration)。

<a id="verify-the-plantuml-installation"></a>

### 验证 PlantUML 安装

要验证安装是否成功：

1. 直接测试 PlantUML 服务器：

   ```shell
   # Docker install
   curl --location --verbose "http://localhost:8005/svg/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000"

   # Debian/Ubuntu install
   curl --location --verbose "http://localhost:8005/plantuml/svg/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000"
   ```

   您应收到包含文本 `hello`的 SVG 输出。

1. 通过访问以下地址，测试极狐GitLab 能否通过 NGINX 访问 PlantUML：

   ```plaintext
   http://gitlab.example.com/-/plantuml/svg/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000
   ```

   将 `gitlab.example.com` 替换为您的极狐GitLab 实例 URL。您应看到渲染出的
   PlantUML 图表，其中显示 `hello`。

   ```plaintext
   Bob -> Alice : hello
   ```

<a id="configure-plantuml-security"></a>

### 配置 PlantUML 安全性

PlantUML 具有允许获取网络资源的功能。如果您自行托管 PlantUML 服务器，请设置网络控制措施以将其隔离。例如，使用 PlantUML 的[安全配置文件](https://plantuml.com/security)。

```plaintext
@startuml
start
    ' ...
    !include http://localhost/
stop;
@enduml
```

<a id="secure-plantuml-svg-diagram-output"></a>

#### 保护 PlantUML SVG 图表输出

以 SVG 格式生成 PlantUML 图表时，请配置您的服务器以增强安全性。在 NGINX 配置中禁用 SVG 输出路由，以防止潜在的安全问题。

要禁用 SVG 输出路由，请将以下配置添加到托管
PlantUML 服务的 NGINX 服务器：

```nginx
location ~ ^/-/plantuml/svg/ {
    return 403;
}
```

此配置可防止潜在的恶意图表代码在浏览器中执行。

<a id="enable-plantuml-integration"></a>

## 启用 PlantUML 集成

配置好本地 PlantUML 服务器后，您就可以启用 PlantUML 集成了：

1. 以[管理员](../../user/permissions.md)用户身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，转到**设置** > **通用**并展开 **PlantUML** 部分。
1. 选中 **启用 PlantUML** 复选框。
1. 将 PlantUML 实例设置为 `https://gitlab.example.com/-/plantuml/`，
   然后选择**保存更改**。

要防止浏览器将图表内容发送到外部 PlantUML 服务，请使用[图表代理](diagram_proxy.md)。

根据您的 PlantUML 和极狐GitLab 版本号，您可能还需要执行以下步骤：

- 对于运行 v1.2020.9 及更高版本的 PlantUML 服务器，例如 [plantuml.com](https://plantuml.com)，
  您必须设置 `PLANTUML_ENCODING` 环境变量以启用 `deflate`
  压缩。在 Linux 软件包安装中，您可以使用以下命令在 `/etc/gitlab/gitlab.rb`中设置此值：

  ```ruby
  gitlab_rails['env'] = { 'PLANTUML_ENCODING' => 'deflate' }
  ```

  在 GitLab Helm chart 中，您可以通过向
  [global.extraEnv](https://jihulab.com/gitlab-cn/charts/gitlab/-/blob/master/doc/charts/globals.md#extraenv)
  部分添加变量来设置它，如下所示：

  ```yaml
  global:
  extraEnv:
    PLANTUML_ENCODING: deflate
  ```

- `deflate` 是 PlantUML 的默认编码类型。要使用其他编码类型，PlantUML 集成
  [需要在 URL 中添加标头前缀](https://plantuml.com/text-encoding)
  以区分不同的编码类型。

<a id="troubleshooting"></a>

## 故障排除

<a id="rendered-diagram-url-remains-the-same-after-update"></a>

### 更新后渲染的图表 URL 保持不变

渲染的图表会被缓存。要查看更新，请尝试以下步骤：

- 如果图表位于 Markdown 文件中，请对 Markdown 文件做一个小改动并提交。这会触发重新渲染。
- [使 Markdown 缓存失效](../invalidate_markdown_cache.md#invalidate-the-cache)，以强制清除数据库或 Redis 中
  缓存的 Markdown。

如果您仍然看不到更新后的 URL，请检查以下内容：

- 确保可以从您的极狐GitLab 实例访问 PlantUML 服务器。
- 验证您的极狐GitLab 设置中已启用 PlantUML 集成。
- 检查极狐GitLab 日志中与 PlantUML 渲染相关的错误。
- [清除您的极狐GitLab Redis 缓存](../raketasks/maintenance.md#clear-redis-cache)。

<a id="404-error-when-opening-the-plantuml-page-in-the-browser"></a>

### 在浏览器中打开 PlantUML 页面时出现 `404` 错误

当 PlantUML 服务器[在 Debian 或 Ubuntu 中](#debianubuntu)设置时，
访问 `https://gitlab.example.com/-/plantuml/` 可能会遇到 `404` 错误。

即使集成正常工作，也可能发生这种情况。这并不一定表示您的 PlantUML 服务器或配置有问题。

要确认 PlantUML 是否正常工作，您可以[验证 PlantUML 安装](#verify-the-plantuml-installation)。
