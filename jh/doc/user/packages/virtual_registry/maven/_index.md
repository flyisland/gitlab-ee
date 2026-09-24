---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Maven 虚拟仓库
description: 使用 Maven 虚拟仓库来配置和管理多个私有和公共上游仓库。
---

{{< details >}}

- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.0 中引入，[带有一个功能标志](../../../../administration/feature_flags/_index.md)，名称为 `virtual_registry_maven`。默认禁用。
- 功能标志在 极狐GitLab 18.1 中[重命名](https://gitlab.com/gitlab-org/gitlab/-/issues/540276)为 `maven_virtual_registry`。
- 在 极狐GitLab 18.1 中从实验性[更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/540276)测试版。
- 在 极狐GitLab 18.2 中于 JihuLab.com、私有化部署上启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能处于[测试版](../../../../policy/development_stages_support.md#beta)阶段。
> 在使用此功能前，请仔细阅读文档。

Maven 虚拟仓库使用一个单一、众所周知的 URL 来管理和分发来自多个外部仓库的软件包。

使用 Maven 虚拟仓库可以：

- 创建虚拟仓库。
- 将虚拟仓库连接到公共和私有上游仓库。
- 配置 Maven 客户端从已配置的上游拉取软件包。
- 管理可用上游的缓存条目。

这种方法可以随着时间的推移提供更好的软件包性能，并使 Maven 软件包的管理更加容易。

有关管理虚拟仓库和上游仓库的一般信息，请参见[虚拟仓库](../_index.md)。

<a id="prerequisites"></a>

## 先决条件

在使用 Maven 虚拟仓库之前：

- 查阅使用虚拟仓库的[先决条件](../_index.md#prerequisites)。
- 配置对虚拟仓库的认证。更多信息，请参见[认证到虚拟仓库](../_index.md#authenticate-to-the-virtual-registry)。
- 在私有化部署实例上：允许向本地网络发出出站请求。更多信息，请参见[允许来自 webhooks 和集成的对本地网络的请求](../../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。

使用 Maven 虚拟仓库时，请记住以下限制：

- 每个顶级群组最多可以创建 20 个 Maven 虚拟仓库。
- 每个 Maven 虚拟仓库最多只能设置 20 个上游。
- 出于技术原因，`proxy_download` 设置被强制启用，无论[对象存储配置](../../../../administration/object_storage.md#proxy-download)中配置的值如何。
- 尚未实现 Geo 支持。你可以在议题 473033 中关注其进展。

<a id="manage-virtual-registries"></a>

## 管理虚拟仓库

{{< history >}}

- 在 极狐GitLab 18.5 中引入，[带有一个功能标志](../../../../administration/feature_flags/_index.md)，名称为 `ui_for_virtual_registries`。默认启用。
- 在 极狐GitLab 18.6 中[更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/525934)一个名为 `maven_virtual_registry` 的标志。默认启用。功能标志 `ui_for_virtual_registries` 已移除。

{{< /history >}}

为你的群组管理 Maven 虚拟仓库。

你也可以[使用 API](../../../../api/maven_virtual_registries.md#manage-maven-virtual-registries)。

<a id="create-a-maven-virtual-registry"></a>

### 创建 Maven 虚拟仓库

要创建 Maven 虚拟仓库：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。此群组必须位于顶级。
1. 选择 **部署** > **虚拟仓库**。
1. 如果你：
   - 已有现有仓库，选择 **创建仓库**。从下拉列表中，选择 **Maven**。
   - 没有现有仓库，从下拉列表中，选择 **Maven**。然后，选择 **创建仓库**。
1. 输入 **名称** 和可选的 **描述**。
1. 选择 **创建仓库**。

<a id="manage-upstream-registries"></a>

## 管理上游仓库

在虚拟仓库中管理上游 Maven 仓库。

<a id="create-a-maven-upstream-registry"></a>

### 创建 Maven 上游仓库

创建一个 Maven 上游仓库以连接到虚拟仓库。

先决条件：

- 你必须拥有一个 Maven 虚拟仓库。更多信息，请参见[创建虚拟仓库](#create-a-maven-virtual-registry)。

要创建 Maven 上游仓库：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。此群组必须位于顶级。
1. 选择 **部署** > **虚拟仓库**。
1. 在 **仓库类型** 下，选择 **查看仓库**。
1. 在 **仓库** 选项卡下，选择一个仓库。
1. 选择 **添加上游**。如果虚拟仓库已有现有上游，从下拉列表中，选择以下任一：
   - **创建新上游** 来配置上游。
   - **链接现有上游** > **选择现有上游**。
     1. 从下拉列表中，选择一个上游。
     1. 可选。选择 **测试上游** 以在创建之前测试上游连接。
     1. 选择 **添加上游**。
1. 填写字段。
   - 必须同时提供 **用户名** 和 **密码**，或两者都不提供。如果未设置，将使用公共（匿名）请求访问上游。
   - 如果你希望将上游连接到 Maven Central，请使用以下作为 **上游 URL**：

      ```plaintext
      https://repo1.maven.org/maven2
      ```

   - **产物缓存周期** 和 **元数据缓存周期** 默认为 24 小时。设置为 `0` 可禁用缓存条目检查，或者如果你正在使用 Maven Central。
   - 如果你希望在创建之前测试上游连接，请选择 **测试上游**。

1. 选择 **创建上游**。

有关缓存有效性设置的更多信息，请参见[设置缓存有效周期](../_index.md#set-the-cache-validity-period)。

<a id="use-the-maven-virtual-registry"></a>

## 使用 Maven 虚拟仓库

创建虚拟仓库后，你必须配置 Maven 客户端以通过虚拟仓库拉取依赖项。

<a id="configure-maven-clients"></a>

### 配置 Maven 客户端

Maven 虚拟仓库支持以下 Maven 客户端：

- [`mvn`](https://maven.apache.org/index.html)
- [`gradle`](https://gradle.org/)
- [`sbt`](https://www.scala-sbt.org/)

你必须在 Maven 客户端配置中声明虚拟仓库。

所有客户端都必须进行认证。对于客户端认证，你可以使用自定义 HTTP 头或基本认证。
你应该为每个客户端使用下面的一种配置。

{{< tabs >}}

{{< tab title="mvn" >}}

| 令牌类型             | 必须使用的名称     | 令牌                                                                   |
| -------------------- | ---------------- | ---------------------------------------------------------------------- |
| 个人访问令牌         | `Private-Token`  | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| 群组部署令牌         | `Deploy-Token`   | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| 群组访问令牌         | `Private-Token`  | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| CI/CD 作业令牌       | `Job-Token`      | `${CI_JOB_TOKEN}`                                                      |
| OAuth 2.0 令牌       | `Authorization`  | `Bearer <your_oauth_token>`                                            |

将以下节添加到你的
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

你可以通过以下两种方式之一在 `mvn` 应用程序中配置虚拟仓库：

- 作为默认仓库 (Maven Central) 之上的附加仓库。在此配置中，你可以从任何已声明的仓库中拉取同时存在于虚拟仓库和默认仓库中的项目依赖项。
- 作为默认仓库 (Maven Central) 的替代。使用此配置时，依赖项将通过虚拟仓库拉取。你应该将 Maven Central 配置为虚拟仓库的最后一个上游，以避免遗漏必需的公共依赖项。

要将 Maven 虚拟仓库配置为附加仓库，请在 `pom.xml` 文件中添加一个 `repository` 元素：

```xml
<repositories>
  <repository>
    <id>gitlab-maven</id>
    <url>https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id></url>
  </repository>
</repositories>
```

- `<id>`：与 `settings.xml` 中使用的 `<server>` 相同的 ID。
- `<registry_id>`：Maven 虚拟仓库的 ID。

要将 Maven 虚拟仓库配置为默认仓库的替代，请在 `settings.xml` 中添加一个 `mirrors` 元素：

```xml
<settings>
  <servers>
    ...
  </servers>
  <mirrors>
    <mirror>
      <id>central-proxy</id>
      <name>GitLab 中心仓库的代理</name>
      <url>https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id></url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

- `<registry_id>`：Maven 虚拟仓库的 ID。

{{< /tab >}}

{{< tab title="gradle" >}}

| 令牌类型             | 必须使用的名称     | 令牌                                                                   |
| -------------------- | ---------------- | ---------------------------------------------------------------------- |
| 个人访问令牌         | `Private-Token`  | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| 群组部署令牌         | `Deploy-Token`   | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| 群组访问令牌         | `Private-Token`  | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| CI/CD 作业令牌       | `Job-Token`      | `${CI_JOB_TOKEN}`                                                      |
| OAuth 2.0 令牌       | `Authorization`  | `Bearer <your_oauth_token>`                                            |

在你的 [`GRADLE_USER_HOME` 目录](https://docs.gradle.org/current/userguide/directory_layout.html#dir:gradle_user_home)中，
创建一个 `gradle.properties` 文件，包含以下内容：

```properties
gitLabPrivateToken=REPLACE_WITH_YOUR_TOKEN
```

在你的
[`build.gradle`](https://docs.gradle.org/current/userguide/tutorial_using_tasks.html) 文件中添加 `repositories` 部分。

- 使用 Groovy DSL：

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

- 使用 Kotlin DSL：

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

| 令牌类型             | 必须使用的用户名                                         | 令牌                                                                   |
| -------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------- |
| 个人访问令牌         | 用户的用户名                                           | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| 群组部署令牌         | 部署令牌的用户名                                       | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| 群组访问令牌         | 与访问令牌关联的用户的用户名                           | 按原样粘贴令牌，或定义一个环境变量来保存令牌。                         |
| CI/CD 作业令牌       | `gitlab-ci-token`                                      | `sys.env.get("CI_JOB_TOKEN").get`                                      |

[SBT](https://www.scala-sbt.org/index.html) 的认证基于
[HTTP 基本认证](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)。
你必须提供用户名和密码。

在你的 [`build.sbt`](https://www.scala-sbt.org/1.x/docs/Directories.html#sbt+build+definition+files) 文件中，添加以下行：

```scala
resolvers += ("gitlab" at "<endpoint_url>")

credentials += Credentials("GitLab Virtual Registry", "<host>", "<username>", "<token>")
```

- `<endpoint_url>`：Maven 虚拟仓库的 URL。
  例如，`https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id>`，其中 `<registry_id>` 是 Maven 虚拟仓库的 ID。
- `<host>`：`<endpoint_url>` 中的主机，不包含协议方案或端口。例如，`gitlab.example.com`。
- `<username>`：用户名。
- `<token>`：配置的令牌。

确保 `Credentials` 的第一个参数是 `"GitLab Virtual Registry"`。此领域名称必须与 Maven 虚拟仓库发送的[基本认证领域](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Authentication#www-authenticate_and_proxy-authenticate_headers)完全匹配。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

使用 Maven 虚拟仓库时，你可能会遇到以下问题。

<a id="error-connect-to-gitlabexamplecom443-failed-connection-timed-out"></a>

### 错误：`Connect to gitlab.example.com:443 failed: Connection timed out`

当你通过虚拟仓库拉取 Maven 依赖项时，可能会间歇性地出现连接超时错误，例如：

```plaintext
Connect to gitlab.example.com:443 失败：连接超时
```

此问题可能发生在私有化部署实例上，当上游仓库 URL 解析为本地网络地址时。默认情况下，极狐GitLab 出于安全原因阻止对本地网络地址的出站请求。

要解决此问题：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置 > 网络**。
1. 展开 **出站请求**。
1. 选中 **允许来自 webhooks 和集成的对本地网络的请求** 复选框。
1. 可选。如果你希望仅允许特定地址而不是所有本地网络请求，
   请在 **hooks 和集成可以访问的本地 IP 地址和域名** 中添加上游仓库的主机名或 IP 地址。
1. 选择 **保存更改**。

更多信息，请参见[允许来自 webhooks 和集成的对本地网络的请求](../../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。