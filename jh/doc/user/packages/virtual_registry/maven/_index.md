---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Maven 虚拟仓库
description: 使用 Maven 虚拟仓库配置和管理多个私有和公共上游仓库。
---

{{< details >}}

- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能在[测试版](../../../../policy/development_stages_support.md#beta)中可用。
> 使用此功能前，请仔细阅读文档。

Maven 虚拟仓库使用单个众所周知的 URL 来管理和分发来自极狐GitLab 中多个外部仓库的软件包。

使用 Maven 虚拟仓库可以：

- 创建虚拟仓库。
- 将虚拟仓库连接到公共和私有上游仓库。
- 配置 Maven 客户端以从已配置的上游拉取软件包。
- 管理可用上游的缓存条目。

这种方法可以随着时间的推移提供更好的软件包性能，并使您更轻松地管理 Maven 软件包。

有关管理虚拟仓库和上游仓库的一般信息，请参阅[虚拟仓库](../_index.md)。

<a id="prerequisites"></a>

## 先决条件

在使用 Maven 虚拟仓库之前：

- 查看使用虚拟仓库的[先决条件](../_index.md#prerequisites)。
- 配置对虚拟仓库的身份验证。有关更多信息，请参阅[向虚拟仓库进行身份验证](../_index.md#authenticate-to-the-virtual-registry)。
- 在极狐GitLab 私有化部署上：允许对本地网络的出站请求。有关更多信息，请参阅[允许对本地网络的请求](../../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。

使用 Maven 虚拟仓库时，请记住以下限制：

- 每个顶级群组最多可以创建 `20` 个 Maven 虚拟仓库。
- 对于给定的 Maven 虚拟仓库，最多可以设置 `20` 个上游。
- 由于技术原因，无论[对象存储配置](../../../../administration/object_storage.md#proxy-download)中的值如何配置，`proxy_download` 设置都会被强制启用。
- 未实现 Geo 支持。您可以在[议题 473033](https://gitlab.com/gitlab-org/gitlab/-/issues/473033)中关注其开发进展。

<a id="manage-virtual-registries"></a>

## 管理虚拟仓库

为您的群组管理 Maven 虚拟仓库。

您也可以[使用 API](../../../../api/maven_virtual_registries.md#manage-maven-virtual-registries)。

<a id="create-a-maven-virtual-registry"></a>

### 创建 Maven 虚拟仓库

要创建 Maven 虚拟仓库：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。该群组必须位于顶级。
1. 选择**部署** > **虚拟仓库**。
1. 如果您：
   - 已有仓库，请选择**创建仓库**。从下拉列表中，选择 **Maven**。
   - 没有现有仓库，请从下拉列表中选择 **Maven**。然后，选择**创建仓库**。
1. 输入**名称**和可选的**描述**。
1. 选择**创建仓库**。

<a id="manage-upstream-registries"></a>

## 管理上游仓库

在虚拟仓库中管理上游 Maven 仓库。

<a id="create-a-maven-upstream-registry"></a>

### 创建 Maven 上游仓库

创建 Maven 上游仓库以连接到虚拟仓库。

先决条件：

- 您必须有一个 Maven 虚拟仓库。有关更多信息，请参阅[创建虚拟仓库](#create-a-maven-virtual-registry)。

要创建 Maven 上游仓库：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。该群组必须位于顶级。
1. 选择**部署** > **虚拟仓库**。
1. 在**仓库类型**下，选择**查看仓库**。
1. 在**仓库**标签页下，选择一个仓库。
1. 选择**添加上游**。如果虚拟仓库已有上游，请从下拉列表中选择以下之一：
   - **创建新上游**以配置上游。
   - **链接现有上游** > **选择现有上游**。
     1. 从下拉列表中，选择一个上游。
     1. 可选。选择**测试上游**以在创建之前测试上游连接。
     1. 选择**添加上游**。
1. 填写字段。
   - 同时包含**用户名**和**密码**，或两者都不包含。如果未设置，则使用公共（匿名）请求访问上游。
   - 如果您想将上游连接到 Maven Central，请使用以下内容作为**上游 URL**：

      ```plaintext
      https://repo1.maven.org/maven2
      ```

   - **制品缓存周期**和**元数据缓存周期**默认为 24 小时。设置为 `0` 可禁用缓存条目检查，或者如果您使用的是 Maven Central。
   - 如果您想在创建之前测试上游连接，请选择**测试上游**。

1. 选择**创建上游**。

有关缓存有效期设置的更多信息，请参阅[设置缓存有效期](../_index.md#set-the-cache-validity-period)。

<a id="use-the-maven-virtual-registry"></a>

## 使用 Maven 虚拟仓库

创建虚拟仓库后，您必须配置 Maven 客户端以通过虚拟仓库拉取依赖项。

<a id="configure-maven-clients"></a>

### 配置 Maven 客户端

Maven 虚拟仓库支持以下 Maven 客户端：

- [`mvn`](https://maven.apache.org/index.html)
- [`gradle`](https://gradle.org/)
- [`sbt`](https://www.scala-sbt.org/)

您必须在 Maven 客户端配置中声明虚拟仓库。

所有客户端都必须经过身份验证。对于客户端身份验证，您可以使用自定义 HTTP 请求头或基本身份验证。您应该为每个客户端使用以下配置之一。

{{< tabs >}}

{{< tab title="mvn" >}}

| 令牌类型            | 名称必须为    | 令牌                                                                   |
| --------------------- | --------------- | ----------------------------------------------------------------------- |
| 个人访问令牌 | `Private-Token` | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| 群组部署令牌    | `Deploy-Token`  | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| 群组访问令牌    | `Private-Token` | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| CI/CD 作业令牌          | `Job-Token`     | `${CI_JOB_TOKEN}`                                                       |
| OAuth 2.0 令牌       | `Authorization` | `Bearer <your_oauth_token>`                                             |

将以下部分添加到您的
[`settings.xml`](https://maven.apache.org/settings.html) 文件中。

```xml
<settings>
  <servers>
    <server>
      <id>gitlab-maven</id>
      <configuration>
        <httpHeaders>
          <property>
            <name>REPLACE_WITH_NAME</name>
            <value>REPLACE_WITH_TOKEN</value>
          </property>
        </httpHeaders>
      </configuration>
    </server>
  </servers>
</settings>
```

您可以通过以下两种方式之一在 `mvn` 应用程序中配置虚拟仓库：

- 作为默认仓库（Maven central）之上的附加仓库。在此配置中，您可以从任何已声明的仓库拉取同时存在于虚拟仓库和默认仓库中的项目依赖项。
- 作为默认仓库（Maven central）的替代。使用此配置，依赖项将通过虚拟仓库拉取。您应该将 Maven central 配置为虚拟仓库的最后一个上游，以避免缺少所需的公共依赖项。

要将 Maven 虚拟仓库配置为附加仓库，请在 `pom.xml` 文件中添加一个 `repository` 元素：

```xml
<repositories>
  <repository>
    <id>gitlab-maven</id>
    <url>https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id></url>
  </repository>
</repositories>
```

- `<id>`：与 `settings.xml`中的 `<server>` 相同的 ID。
- `<registry_id>`：Maven 虚拟仓库的 ID。

要将 Maven 虚拟仓库配置为默认仓库的替代，请在 `settings.xml`中添加一个 `mirrors` 元素：

```xml
<settings>
  <servers>
    ...
  </servers>
  <mirrors>
    <mirror>
      <id>central-proxy</id>
      <name>GitLab proxy of central repo</name>
      <url>https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id></url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

- `<registry_id>`：Maven 虚拟仓库的 ID。

{{< /tab >}}

{{< tab title="gradle" >}}

| 令牌类型            | 名称必须为    | 令牌                                                                   |
| --------------------- | --------------- | ----------------------------------------------------------------------- |
| 个人访问令牌 | `Private-Token` | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| 群组部署令牌    | `Deploy-Token`  | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| 群组访问令牌    | `Private-Token` | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| CI/CD 作业令牌          | `Job-Token`     | `${CI_JOB_TOKEN}`                                                       |
| OAuth 2.0 令牌       | `Authorization` | `Bearer <your_oauth_token>`                                             |

在[您的 `GRADLE_USER_HOME` 目录](https://docs.gradle.org/current/userguide/directory_layout.html#dir:gradle_user_home)中，
创建一个包含以下内容的 `gradle.properties` 文件：

```properties
gitLabPrivateToken=REPLACE_WITH_YOUR_TOKEN
```

将 `repositories` 部分添加到您的
[`build.gradle`](https://docs.gradle.org/current/userguide/tutorial_using_tasks.html)。

- 在 Groovy DSL 中：

  ```groovy
  repositories {
      maven {
          url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id>"
          name "GitLab"
          credentials(HttpHeaderCredentials) {
              name = 'REPLACE_WITH_NAME'
              value = gitLabPrivateToken
          }
          authentication {
              header(HttpHeaderAuthentication)
          }
      }
  }
  ```

- 在 Kotlin DSL 中：

  ```kotlin
  repositories {
      maven {
          url = uri("https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id>")
          name = "GitLab"
          credentials(HttpHeaderCredentials::class) {
              name = "REPLACE_WITH_NAME"
              value = findProperty("gitLabPrivateToken") as String?
          }
          authentication {
              create("header", HttpHeaderAuthentication::class)
          }
      }
  }
  ```

- `<registry_id>`：Maven 虚拟仓库的 ID。

{{< /tab >}}

{{< tab title="sbt" >}}

| 令牌类型            | 用户名必须为                                        | 令牌                                                                   |
| --------------------- | ------------------------------------------------------- | ----------------------------------------------------------------------- |
| 个人访问令牌 | 用户的用户名                                | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| 群组部署令牌    | 部署令牌的用户名                            | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| 群组访问令牌    | 与访问令牌关联的用户的用户名     | 按原样粘贴令牌，或定义环境变量来保存令牌。 |
| CI/CD 作业令牌          | `gitlab-ci-token`                                       | `sys.env.get("CI_JOB_TOKEN").get`                                       |

[SBT](https://www.scala-sbt.org/index.html)的身份验证基于
[基本 HTTP 身份验证](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)。
您必须提供名称和密码。

在您的 [`build.sbt`](https://www.scala-sbt.org/1.x/docs/Directories.html#sbt+build+definition+files)中，添加以下行：

```scala
resolvers += ("gitlab" at "<endpoint_url>")

credentials += Credentials("GitLab Virtual Registry", "<host>", "<username>", "<token>")
```

- `<endpoint_url>`：Maven 虚拟仓库 URL。
  例如，`https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id>`，其中 `<registry_id>` 是 Maven 虚拟仓库的 ID。
- `<host>`：`<endpoint_url>` 中存在的主机名，不含协议方案或端口。例如，`gitlab.example.com`。
- `<username>`：用户名。
- `<token>`：已配置的令牌。

确保 `Credentials`的第一个参数为 `"GitLab Virtual Registry"`。此领域名称必须与 Maven 虚拟仓库发送的[基本身份验证领域](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Authentication#www-authenticate_and_proxy-authenticate_headers)完全匹配。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

使用 Maven 虚拟仓库时，您可能会遇到以下问题。

<a id="error-connect-to-gitlabexamplecom443-failed-connection-timed-out"></a>

### 错误：`Connect to gitlab.example.com:443 failed: Connection timed out`

通过虚拟仓库拉取 Maven 依赖项时，您可能会遇到间歇性连接超时错误，例如：

```plaintext
Connect to gitlab.example.com:443 failed: Connect timed out
```

当上游仓库 URL 解析到本地网络地址时，此问题可能会在极狐GitLab 私有化部署实例上出现。默认情况下，极狐GitLab 出于安全原因会阻止对本地网络地址的出站请求。

要解决此问题：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置 > 网络**。
1. 展开**出站请求**。
1. 选中**允许来自 webhooks 和集成对本地网络的请求**复选框。
1. 可选。如果您希望仅允许特定地址而不是所有本地网络请求，
   请在 **Webhook 和服务可以访问的本地 IP 地址和域名。**中，
   添加上游仓库的主机名或 IP 地址。
1. 选择**保存更改**。

有关更多信息，请参阅[允许对本地网络的请求](../../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。
