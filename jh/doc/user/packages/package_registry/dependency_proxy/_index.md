---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包依赖代理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 在 GitLab 16.6 [引入](https://jihulab.com/groups/gitlab-org/-/epics/3610) ，[带有一个功能标志](../../../../administration/feature_flags/_index.md)命名为 `packages_dependency_proxy_maven`。默认关闭。
- 在 GitLab 16.8 于 JihuLab.com 和私有化部署版本上启用。功能标志 `packages_dependency_proxy_maven` 被移除。

{{< /history >}}

> [!warning]
> 依赖代理目前处于 [测试版](../../../../policy/development_stages_support.md#beta) 阶段。在使用此功能之前，请仔细阅读文档。

极狐GitLab 依赖代理是一个本地代理服务器，可以下载并存储软件包的副本。

当你第一次请求一个软件包时，极狐GitLab 会从上游软件包仓库获取它，并在你的项目中保存一个副本。当你再次请求相同的软件包时，极狐GitLab 会在项目的软件包仓库中提供已保存的副本。

这种方法减少了从外部源下载的次数，并使软件包构建更快。

<a id="enable-the-dependency-proxy"></a>

## 启用依赖代理

要使用软件包的依赖代理，请确保你的项目配置正确，并且从缓存中拉取的用户具有必要的认证：

1. 在全局配置中，如果以下功能被禁用，请启用它们：
   - [`软件包` 功能](../../../../administration/packages/_index.md#enable-or-disable-the-package-registry)。默认启用。
   - [`依赖代理` 功能](../../../../administration/packages/dependency_proxy.md#turn-on-the-dependency-proxy)。默认启用。
1. 在项目设置中，如果 [`软件包` 功能](../_index.md#turn-off-the-package-registry) 被禁用，请启用它。默认启用。
1. [添加认证方法](#configure-a-client)。依赖代理支持与软件包仓库相同的 [认证方法](../supported_functionality.md#authenticate-with-the-registry)：
   - [个人访问令牌](../../../profile/personal_access_tokens.md)
   - [项目部署令牌](../../../project/deploy_tokens/_index.md)
   - [群组部署令牌](../../../project/deploy_tokens/_index.md)
   - [作业令牌](../../../../ci/jobs/ci_job_token.md)

<a id="advanced-caching"></a>

## 高级缓存

在可能的情况下，软件包的依赖代理会使用高级缓存将软件包存储在项目的软件包仓库中。

高级缓存会验证项目软件包仓库与上游软件包仓库之间的一致性。如果上游仓库更新了文件，依赖代理会使用它们来更新缓存的文件。

当不支持高级缓存时，依赖代理会回退到默认行为：

- 如果在项目软件包仓库中找到请求的文件，则返回该文件。
- 如果未找到文件，则从上游软件包仓库获取。

高级缓存支持取决于上游软件包仓库如何响应依赖代理请求，以及你使用的软件包格式。

对于 Maven 软件包：

| 软件包仓库                                                                                                                               | 是否支持高级缓存？ |
|---------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [极狐GitLab](../../maven_repository/_index.md)                                                                                            | {{< 是 >}} |
| [Maven Central](https://mvnrepository.com/repos/central)                                                                              | {{< 是 >}} |
| [Artifactory](https://jfrog.com/integration/maven-repository/)                                                                        | {{< 是 >}} |
| [Sonatype Nexus](https://help.sonatype.com/en/maven-repositories.html)                                                                | {{< 是 >}} |
| [GitHub Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry) | {{< 否 >}} |

<a id="permissions"></a>

### 权限

当依赖代理拉取文件时，会发生以下情况：

1. 依赖代理在项目软件包仓库中搜索文件。这是一个读取操作。
1. 依赖代理可能会将软件包文件发布到项目软件包仓库。这是一个写入操作。

这两个步骤是否都执行取决于用户权限。依赖代理使用 [与软件包仓库相同的权限](../_index.md#package-registry-visibility-permissions)。

| 项目可见性 | 最低[角色](../../../permissions.md#roles) | 可以读取软件包文件？ | 可以写入软件包文件？ | 行为 |
|--------|-----------------------------------------------|----------------|----------------|------|
| 公开     | 匿名用户                                          | {{< 否 >}}      | {{< 否 >}}      | 请求被拒绝。 |
| 公开     | 访客                                            | {{< 是 >}}     | {{< 否 >}}      | 从缓存或远程注册表返回软件包文件。 |
| 公开     | 开发者                                           | {{< 是 >}}     | {{< 是 >}}     | 从缓存或远程注册表返回软件包文件。文件被发布到缓存。 |
| 内部     | 匿名用户                                          | {{< 否 >}}      | {{< 否 >}}      | 请求被拒绝 |
| 内部     | 访客                                            | {{< 是 >}}     | {{< 否 >}}      | 从缓存或远程注册表返回软件包文件。 |
| 内部     | 开发者                                           | {{< 是 >}}     | {{< 是 >}}     | 从缓存或远程注册表返回软件包文件。文件被发布到缓存。 |
| 私有     | 匿名用户                                          | {{< 否 >}}      | {{< 否 >}}      | 请求被拒绝 |
| 私有     | 报告者                                           | {{< 是 >}}     | {{< 否 >}}      | 从缓存或远程注册表返回软件包文件。 |
| 私有     | 开发者                                           | {{< 是 >}}     | {{< 是 >}}     | 从缓存或远程注册表返回软件包文件。文件被发布到缓存。 |

至少，任何可以使用依赖代理的用户也可以使用项目的软件包仓库。

为了确保缓存随时间推移被正确填充，你应该确保具有开发者、维护者或所有者角色的用户使用依赖代理拉取软件包。

<a id="configure-a-client"></a>

## 配置客户端

为依赖代理配置客户端与为 [软件包仓库](../supported_functionality.md#pulling-packages) 配置客户端类似。

<a id="for-maven-packages"></a>

### 对于 Maven 软件包

对于 Maven 软件包，软件包仓库支持的 [所有客户端](../../maven_repository/_index.md) 均受依赖代理支持：

- `mvn`
- `gradle`
- `sbt`

对于认证，你可以使用被 [Maven 软件包仓库](../../maven_repository/_index.md#edit-the-client-configuration) 接受的所有方法。你应该使用 [基本 HTTP 认证](../../maven_repository/_index.md#basic-http-authentication) 方法，因为它不那么复杂。

要配置客户端：

1. 请遵循 [基本 HTTP 认证](../../maven_repository/_index.md#basic-http-authentication) 中的说明。

   确保你使用的是端点 URL `https://gitlab.example.com/api/v4/projects/<project_id>/dependency_proxy/packages/maven`。

1. 完成你的客户端配置：

{{< tabs >}}

{{< tab title="mvn" >}}

[基本 HTTP 认证](../../maven_repository/_index.md#basic-http-authentication) 是被接受的。但是，你应该使用 [自定义 HTTP 头认证](../../maven_repository/_index.md#custom-http-header)，以便 `mvn` 使用更少的网络请求。

在 `pom.xml` 文件中添加一个 `<repository>` 元素：

```xml
<repositories>
  <repository>
    <id>gitlab-maven</id>
    <url>https://gitlab.example.com/api/v4/projects/<project_id>/dependency_proxy/packages/maven</url>
  </repository>
</repositories>
```

其中：

- `<project_id>` 是要用作依赖代理的项目的 ID。
- `<id>` 包含在 [认证配置](../../maven_repository/_index.md#basic-http-authentication) 中使用的 `<server>` 名称。

默认情况下，Maven Central 会通过 [Super POM](https://maven.apache.org/guides/introduction/introduction-to-the-pom.html#Super_POM) 被首先检查。但是，你可能想强制 `mvn` 先检查极狐GitLab 端点。要执行此操作，请遵循 [请求转发](../../maven_repository/_index.md#additional-configuration-for-mvn) 中的说明。

{{< /tab >}}

{{< tab title="gradle" >}}

在你的 [`build.gradle`](https://docs.gradle.org/current/userguide/tutorial_using_tasks.html) 文件中添加一个 `repositories` 部分。

- 在 Groovy DSL 中：

  ```groovy
  repositories {
      maven {
          url "https://gitlab.example.com/api/v4/projects/<project_id>/dependency_proxy/packages/maven"
          name "GitLab"
          credentials(PasswordCredentials) {
              username = 'REPLACE_WITH_NAME'
              password = gitLabPrivateToken
          }
          authentication {
              basic(BasicAuthentication)
          }
      }
  }
  ```

- 在 Kotlin DSL 中：

  ```kotlin
  repositories {
      maven {
          url = uri("https://gitlab.example.com/api/v4/projects/<project_id>/dependency_proxy/packages/maven")
          name = "GitLab"
          credentials(BasicAuthentication::class) {
              username = "REPLACE_WITH_NAME"
              password = findProperty("gitLabPrivateToken") as String?
          }
          authentication {
              create("basic", BasicAuthentication::class)
          }
      }
  }
  ```

在这个例子中：

- `<project_id>` 是要用作依赖代理的项目的 ID。
- `REPLACE_WITH_NAME` 在 [基本 HTTP 认证](../../maven_repository/_index.md#basic-http-authentication) 部分中有所解释。

{{< /tab >}}

{{< tab title="sbt" >}}

在你的 [`build.sbt`](https://www.scala-sbt.org/1.x/docs/Directories.html#sbt+build+definition+files) 中，添加以下行：

```scala
resolvers += ("gitlab" at "https://gitlab.example.com/api/v4/projects/<project_id>/dependency_proxy/packages/maven")

credentials += Credentials("GitLab Packages Registry", "<host>", "<name>", "<token>")
```

在这个例子中：

- `<project_id>` 是要用作依赖代理的项目的 ID。
- `<host>` 是端点 URL 中不带协议方案或端口的主机。示例：`gitlab.example.com`。
- `<name>` 和 `<token>` 在 [基本 HTTP 认证](../../maven_repository/_index.md#basic-http-authentication) 部分中有所解释。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-the-remote-registry"></a>

## 配置远程注册表

依赖代理必须配置：

- 远程软件包仓库的 URL。
- 可选。所需的凭据。

要设置这些参数：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和库**。
1. 展开 **软件包仓库**。
1. 在 **依赖代理** 下，为你的软件包格式填写表单：

{{< tabs >}}

{{< tab title="Maven" >}}

任何 Maven 软件包仓库都可以连接到依赖代理。你可以通过 Maven 软件包仓库的用户名和密码来授权连接。

要设置或更新远程 Maven 软件包仓库，请更新表单中的以下字段：

- `URL` - 远程注册表的 URL。
- `用户名` - 可选。用于远程注册表的用户名。
- `密码` - 可选。用于远程注册表的密码。

你必须同时设置用户名和密码，或者将这两个字段都留空。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

<a id="manual-file-pull-errors"></a>

### 手动文件拉取错误

你可以使用 cURL 手动拉取文件。但是，你可能会遇到以下响应之一：

- `404 未找到` - 未找到依赖代理设置对象，因为它不存在，或者因为未满足 [要求](#enable-the-dependency-proxy)。
- `401 未授权` - 用户已正确认证，但没有访问依赖代理对象的适当权限。
- `403 禁止` - [极狐GitLab 许可证级别](#enable-the-dependency-proxy) 存在问题。
- `502 错误网关` - 远程软件包仓库无法满足文件请求。请验证 [依赖代理设置](#configure-the-remote-registry)。
- `504 网关超时` - 远程软件包仓库超时。请验证 [依赖代理设置](#configure-the-remote-registry)。

{{< tabs >}}

{{< tab title="Maven" >}}

```shell
curl --fail-with-body --verbose "https://<用户名>:<个人访问令牌>@gitlab.example.com/api/v4/projects/<项目_id>/dependency_proxy/packages/maven/<group_id_and_artifact_id>/<版本>/<文件名称>"
```

- `<用户名>` 和 `<个人访问令牌>` 是用于访问极狐GitLab 实例依赖代理的凭据。
- `<project_id>` 是项目 ID。
- `<group_id_and_artifact_id>` 是以斜杠连接的 [Maven 软件包 group ID 和 artifact ID](https://maven.apache.org/pom.html#Maven_Coordinates)。
- `<版本>` 是软件包版本。
- `文件名称` 是文件的精确名称。

例如，给定一个具有以下属性的软件包：

- group ID: `com.my_company`。
- artifact ID: `my_package`。
- 版本: `1.2.3`。

手动拉取软件包的请求是：

```shell
curl --fail-with-body --verbose "https://<用户名>:<个人访问令牌>@gitlab.example.com/api/v4/projects/<project_id>/dependency_proxy/packages/maven/com/my_company/my_package/1.2.3/my_package-1.2.3.pom"
```

{{< /tab >}}

{{< /tabs >}}