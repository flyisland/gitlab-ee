---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Maven 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将 [Maven](https://maven.apache.org) 产物发布到项目的软件包仓库中。之后，当您需要将它们用作依赖项时，可以随时安装这些软件包。

有关 Maven 软件包管理器客户端所使用的特定 API 端点的文档，请参阅 [Maven API 文档](../../../api/packages/maven.md)。

支持的客户端：

- `mvn`。了解如何构建 [Maven](../workflows/build_packages.md#maven) 软件包。
- `gradle`。了解如何构建 [Gradle](../workflows/build_packages.md#gradle) 软件包。
- `sbt`。

<a id="publish-to-the-gitlab-package-registry"></a>

## 发布到极狐GitLab 软件包仓库

<a id="authenticate-to-the-package-registry"></a>

### 向软件包仓库进行身份验证

您需要一个令牌才能发布软件包。根据您想要实现的目标，可以使用不同的令牌。有关更多信息，请查看[令牌指南](../package_registry/supported_functionality.md#authenticate-with-the-registry)。

创建一个令牌并保存，以便在此过程的后续步骤中使用。

请勿使用此处记录之外的身份验证方法。未记录的身份验证方法可能会在未来被移除。

<a id="edit-the-client-configuration"></a>

#### 编辑客户端配置

更新您的配置，以通过 HTTP 向 Maven 仓库进行身份验证。

<a id="custom-http-header"></a>

##### 自定义 HTTP 请求头

您必须将身份验证详细信息添加到客户端的配置文件中。

{{< tabs >}}

{{< tab title="`mvn`" >}}

| 令牌类型              | 名称必须为      | 令牌                                                                   |
| --------------------- | --------------- | ---------------------------------------------------------------------- |
| 个人访问令牌          | `Private-Token` | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| 部署令牌              | `Deploy-Token`  | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| CI 作业令牌           | `Job-Token`     | `${CI_JOB_TOKEN}`                                                      |
| OAuth 令牌            | `Authorization` | 在令牌前加上 `Bearer`（例如 `Bearer <oauth_token>`）  |

> [!note]
> `<name>` 字段的名称必须与您选择的令牌相匹配。

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

{{< /tab >}}

{{< tab title="`gradle`" >}}

| 令牌类型              | 名称必须为      | 令牌                                                                   |
| --------------------- | --------------- | ---------------------------------------------------------------------- |
| 个人访问令牌          | `Private-Token` | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| 部署令牌              | `Deploy-Token`  | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| CI 作业令牌           | `Job-Token`     | `System.getenv("CI_JOB_TOKEN")`                                        |
| OAuth 令牌            | `Authorization` | 在令牌前加上 `Bearer`（例如 `Bearer <oauth_token>`）  |

> [!note]
> `<name>` 字段的名称必须与您选择的令牌相匹配。

在[您的 `GRADLE_USER_HOME` 目录](https://docs.gradle.org/current/userguide/directory_layout.html#dir:gradle_user_home)中，
创建一个包含以下内容的 `gradle.properties` 文件：

```properties
gitLabPrivateToken=REPLACE_WITH_YOUR_TOKEN
```

将 `repositories` 部分添加到您的
[`build.gradle`](https://docs.gradle.org/current/userguide/tutorial_using_tasks.html)
文件中：

- 在 Groovy DSL 中：

  ```groovy
  repositories {
      maven {
          url "https://gitlab.example.com/api/v4/groups/<group>/-/packages/maven"
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
          url = uri("https://gitlab.example.com/api/v4/groups/<group>/-/packages/maven")
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

{{< /tab >}}

{{< /tabs >}}

<a id="basic-http-authentication"></a>

##### 基本 HTTP 身份验证

您也可以使用基本 HTTP 身份验证向 Maven 软件包仓库进行身份验证。

{{< tabs >}}

{{< tab title="`mvn`" >}}

| 令牌类型              | 名称必须为                   | 令牌                                                                   |
| --------------------- | ---------------------------- | ---------------------------------------------------------------------- |
| 个人访问令牌          | 用户的用户名                 | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| 部署令牌              | 部署令牌的用户名             | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| CI 作业令牌           | `gitlab-ci-token`            | `${CI_JOB_TOKEN}`                                                      |

将以下部分添加到您的
[`settings.xml`](https://maven.apache.org/settings.html) 文件中。

```xml
<settings>
  <servers>
    <server>
      <id>gitlab-maven</id>
      <username>REPLACE_WITH_NAME</username>
      <password>REPLACE_WITH_TOKEN</password>
      <configuration>
        <authenticationInfo>
          <userName>REPLACE_WITH_NAME</userName>
          <password>REPLACE_WITH_TOKEN</password>
        </authenticationInfo>
      </configuration>
    </server>
  </servers>
</settings>
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

| 令牌类型              | 名称必须为                   | 令牌                                                                   |
| --------------------- | ---------------------------- | ---------------------------------------------------------------------- |
| 个人访问令牌          | 用户的用户名                 | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| 部署令牌              | 部署令牌的用户名             | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| CI 作业令牌           | `gitlab-ci-token`            | `System.getenv("CI_JOB_TOKEN")`                                        |

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
          url "https://gitlab.example.com/api/v4/groups/<group>/-/packages/maven"
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
          url = uri("https://gitlab.example.com/api/v4/groups/<group>/-/packages/maven")
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

{{< /tab >}}

{{< tab title="`sbt`" >}}

| 令牌类型              | 名称必须为                   | 令牌                                                                   |
|-----------------------|------------------------------|------------------------------------------------------------------------|
| 个人访问令牌          | 用户的用户名                 | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| 部署令牌              | 部署令牌的用户名             | 按原样粘贴令牌，或定义一个环境变量来保存该令牌 |
| CI 作业令牌           | `gitlab-ci-token`            | `sys.env.get("CI_JOB_TOKEN").get`                                      |

[SBT](https://www.scala-sbt.org/index.html)的身份验证基于
[基本 HTTP 身份验证](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)。
您必须提供名称和密码。

> [!note]
> 名称字段的名称必须与您选择的令牌相匹配。

要使用 `sbt` 从 Maven 极狐GitLab 软件包仓库安装软件包，您必须配置
一个 [Maven 解析器](https://www.scala-sbt.org/1.x/docs/Resolvers.html#Maven+resolvers)。
如果您要访问私有或内部项目或群组，则需要设置
[凭据](https://www.scala-sbt.org/1.x/docs/Publishing.html#Credentials)。
配置好解析器和身份验证后，您可以从项目、群组或命名空间安装软件包。

在您的 [`build.sbt`](https://www.scala-sbt.org/1.x/docs/Directories.html#sbt+build+definition+files)中，添加以下行：

```scala
resolvers += ("gitlab" at "<endpoint url>")

credentials += Credentials("GitLab Packages Registry", "<host>", "<name>", "<token>")
```

在此示例中：

- `<endpoint url>` 是[端点 URL](#endpoint-urls)。
  例如：`https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven`。
- `<host>` 是 `<endpoint url>` 中存在的主机名，不包含协议
  方案或端口。例如：`gitlab.example.com`。
- `<name>` 和 `<token>` 在上表中已有说明。

{{< /tab >}}

{{< /tabs >}}

<a id="naming-convention"></a>

### 命名约定

您可以使用三个端点之一来安装 Maven 软件包。您必须将软件包发布到项目，但您选择的端点决定了您为发布而添加到 `pom.xml` 文件中的设置。

这三个端点是：

- 项目：当您只有少量 Maven 软件包，且它们不在同一个极狐GitLab 群组中时使用。
- 群组：当您想要从同一极狐GitLab 群组中的许多不同项目安装软件包时使用。极狐GitLab 不保证群组内软件包名称的唯一性。您可能有两个项目具有相同的软件包名称和软件包版本。因此，极狐GitLab 会提供其中较新的那个。
- 实例：当您在不同极狐GitLab 群组中或各自的命名空间中有许多软件包时使用。

对于实例级端点，请确保 Maven 中 `pom.xml`的相关部分如下所示：

```xml
  <groupId>group-slug.subgroup-slug</groupId>
  <artifactId>project-slug</artifactId>
```

实例级端点仅公开与项目路径相同的软件包。

| 项目                | 软件包                           | 实例级端点可用                    |
| ------------------- | -------------------------------- | --------------------------------- |
| `foo/bar`           | `foo/bar/1.0-SNAPSHOT`           | 是                               |
| `gitlab-org/gitlab` | `foo/bar/1.0-SNAPSHOT`           | 否                                |
| `gitlab-org/gitlab` | `gitlab-org/gitlab/1.0-SNAPSHOT` | 是                               |

<a id="endpoint-urls"></a>

#### 端点 URL

| 端点 | `pom.xml`的端点 URL                                               | 附加信息 |
|----------|--------------------------------------------------------------------------|------------------------|
| 项目  | `https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven` | 将 `gitlab.example.com` 替换为您的域名。将 `<project_id>` 替换为您的项目 ID，可在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)中找到。 |
| 群组    | `https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/maven`   | 将 `gitlab.example.com` 替换为您的域名。将 `<group_id>` 替换为您的群组 ID，可在群组主页中找到。 |
| 实例 | `https://gitlab.example.com/api/v4/packages/maven`                       | 将 `gitlab.example.com` 替换为您的域名。 |

<a id="edit-the-configuration-file-for-publishing"></a>

### 编辑用于发布的配置文件

您必须将发布详细信息添加到客户端的配置文件中。

{{< tabs >}}

{{< tab title="`mvn`" >}}

无论您选择哪个端点，您都必须具备：

- `distributionManagement` 部分中特定于项目的 URL。
- `repository` 和 `distributionManagement` 部分。

Maven 中 `pom.xml`的相关 `repository` 部分应如下所示：

```xml
<repositories>
  <repository>
    <id>gitlab-maven</id>
    <url><your_endpoint_url></url>
  </repository>
</repositories>
<distributionManagement>
  <repository>
    <id>gitlab-maven</id>
    <url>https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven</url>
  </repository>
  <snapshotRepository>
    <id>gitlab-maven</id>
    <url>https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven</url>
  </snapshotRepository>
</distributionManagement>
```

- `id` 是您在 [`settings.xml`中定义的](#edit-the-client-configuration)。
- `<your_endpoint_url>` 取决于您选择的[端点](#endpoint-urls)。
- 将 `gitlab.example.com` 替换为您的域名。

{{< /tab >}}

{{< tab title="`gradle`" >}}

要使用 Gradle 发布软件包：

1. 将 Gradle 插件 [`maven-publish`](https://docs.gradle.org/current/userguide/publishing_maven.html) 添加到 plugins 部分：

   - 在 Groovy DSL 中：

     ```groovy
     plugins {
         id 'java'
         id 'maven-publish'
     }
     ```

   - 在 Kotlin DSL 中：

     ```kotlin
     plugins {
         java
         `maven-publish`
     }
     ```

1. 添加一个 `publishing` 部分：

   - 在 Groovy DSL 中：

     ```groovy
     publishing {
         publications {
             library(MavenPublication) {
                 from components.java
             }
         }
         repositories {
             maven {
                 url "https://gitlab.example.com/api/v4/projects/<PROJECT_ID>/packages/maven"
                 credentials(HttpHeaderCredentials) {
                     name = "REPLACE_WITH_TOKEN_NAME"
                     value = gitLabPrivateToken // the variable resides in $GRADLE_USER_HOME/gradle.properties
                 }
                 authentication {
                     header(HttpHeaderAuthentication)
                 }
             }
         }
     }
     ```

   - 在 Kotlin DSL 中：

     ```kotlin
     publishing {
         publications {
             create<MavenPublication>("library") {
                 from(components["java"])
             }
         }
         repositories {
             maven {
                 url = uri("https://gitlab.example.com/api/v4/projects/<PROJECT_ID>/packages/maven")
                 credentials(HttpHeaderCredentials::class) {
                     name = "REPLACE_WITH_TOKEN_NAME"
                     value =
                         findProperty("gitLabPrivateToken") as String? // the variable resides in $GRADLE_USER_HOME/gradle.properties
                 }
                 authentication {
                     create("header", HttpHeaderAuthentication::class)
                 }
             }
         }
     }
     ```

{{< /tab >}}

{{< /tabs >}}

<a id="publish-a-package"></a>

## 发布软件包

> [!warning]
> 使用 `DeployAtEnd` 选项可能导致上传被拒绝，并返回 `400 bad request {"message":"Validation failed: Name has already been taken"}`。有关更多详细信息，
> 请参阅[议题 424238](https://gitlab.com/gitlab-org/gitlab/-/issues/424238)。

在您设置好[身份验证](#authenticate-to-the-package-registry)并[选择了用于发布的端点](#naming-convention)之后，将 Maven 软件包发布到您的项目。

{{< tabs >}}

{{< tab title="`mvn`" >}}

要使用 Maven 发布软件包：

```shell
mvn deploy
```

如果部署成功，应显示构建成功消息：

```shell
...
[INFO] BUILD SUCCESS
...
```

该消息还应显示软件包已发布到正确的位置：

```shell
Uploading to gitlab-maven: https://example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/mydepartment/my-project/1.0-SNAPSHOT/my-project-1.0-20200128.120857-1.jar
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

运行 publish 任务：

```shell
gradle publish
```

转到项目的**软件包与镜像库**页面，查看已发布的软件包。

{{< /tab >}}

{{< tab title="`sbt`" >}}

在您的 `build.sbt` 文件中配置 `publishTo` 设置：

```scala
publishTo := Some("gitlab" at "<endpoint url>")
```

确保凭据被正确引用。有关更多信息，请参阅 [`sbt` 文档](https://www.scala-sbt.org/1.x/docs/Publishing.html#Credentials)。

要使用 `sbt` 发布软件包：

```shell
sbt publish
```

如果部署成功，将显示构建成功消息：

```shell
[success] Total time: 1 s, completed Jan 28, 2020 12:08:57 PM
```

检查成功消息，以确保软件包已发布到
正确的位置：

```shell
[info]  published my-project_2.12 to https://gitlab.example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/my-project_2.12/0.1.1-SNAPSHOT/my-project_2.12-0.1.1-SNAPSHOT.pom
```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 如果您在发布 Maven 软件包之前对其进行了保护，该软件包将被拒绝，并返回 `403 Forbidden` 错误和 `Authorization failed` 错误消息。
> 请确保在发布时 Maven 软件包未受保护。
> 有关软件包保护规则的更多信息，请参阅[如何保护软件包](../package_registry/package_protection_rules.md#protect-a-package)。

<a id="install-a-package"></a>

## 安装软件包

要从极狐GitLab 软件包仓库安装软件包，您必须配置[远程仓库并进行身份验证](#authenticate-to-the-package-registry)。完成此操作后，您可以从项目、群组或命名空间安装软件包。

如果多个软件包具有相同的名称和版本，当您安装软件包时，将检索最近发布的软件包。

{{< tabs >}}

{{< tab title="`mvn`" >}}

要使用 `mvn install` 安装软件包：

1. 将依赖项手动添加到项目的 `pom.xml` 文件中。
   要添加之前创建的示例，XML 应为：

   ```xml
   <dependency>
     <groupId>com.mycompany.mydepartment</groupId>
     <artifactId>my-project</artifactId>
     <version>1.0-SNAPSHOT</version>
   </dependency>
   ```

1. 在您的项目中，运行以下命令：

   ```shell
   mvn install
   ```

该消息应显示软件包正在从软件包仓库下载：

```shell
Downloading from gitlab-maven: http://gitlab.example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/mydepartment/my-project/1.0-SNAPSHOT/my-project-1.0-20200128.120857-1.pom
```

您也可以直接使用 Maven 的 [`dependency:get` 命令](https://maven.apache.org/plugins/maven-dependency-plugin/get-mojo.html)来安装软件包。

1. 在您的项目目录中，运行：

   ```shell
   mvn dependency:get -Dartifact=com.nickkipling.app:nick-test-app:1.1-SNAPSHOT -DremoteRepositories=gitlab-maven::::<gitlab endpoint url>  -s <path to settings.xml>
   ```

   - `<gitlab endpoint url>` 是极狐GitLab [端点](#endpoint-urls)的 URL。
   - `<path to settings.xml>` 是包含[身份验证详细信息](#edit-the-client-configuration)的 `settings.xml` 文件的路径。

> [!note]
> `gitlab-maven` 命令和 `settings.xml` 文件中的仓库 ID 必须匹配。

该消息应显示软件包正在从软件包仓库下载：

```shell
Downloading from gitlab-maven: http://gitlab.example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/mydepartment/my-project/1.0-SNAPSHOT/my-project-1.0-20200128.120857-1.pom
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

要使用 `gradle` 安装软件包：

1. 在 dependencies 部分中向 `build.gradle` 添加一个[依赖项](https://docs.gradle.org/current/userguide/declaring_dependencies.html)：

   - 在 Groovy DSL 中：

     ```groovy
     dependencies {
         implementation 'com.mycompany.mydepartment:my-project:1.0-SNAPSHOT'
     }
     ```

   - 在 Kotlin DSL 中：

     ```kotlin
     dependencies {
         implementation("com.mycompany.mydepartment:my-project:1.0-SNAPSHOT")
     }
     ```

1. 在您的项目中，运行以下命令：

   ```shell
   gradle build
   ```

{{< /tab >}}

{{< tab title="`sbt`" >}}

要使用 `sbt` 安装软件包：

1. 向 `build.sbt` 添加一个[内联依赖项](https://www.scala-sbt.org/1.x/docs/Library-Management.html#Dependencies)：

   ```scala
   libraryDependencies += "com.mycompany.mydepartment" % "my-project" % "8.4"
   ```

1. 在您的项目中，运行以下命令：

   ```shell
   sbt update
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="proxy-downloads-for-maven-packages"></a>

### Maven 软件包的代理下载

极狐GitLab Maven 软件包仓库使用[远程包含的校验和](https://maven.apache.org/resolver/expected-checksums.html#remote-included-checksums)。当您下载文件时，仓库会代理该文件，并在单个请求中将该文件及其相关校验和发送给 Maven 客户端。

对较新的 Maven 客户端使用远程包含的校验和：

- 减少客户端向极狐GitLab Maven 软件包仓库发出的 Web 请求数量。
- 降低极狐GitLab 实例的负载。
- 改善客户端命令的执行时间。

由于技术限制，当您使用对象存储时，Maven 软件包仓库会忽略对象存储配置中针对 `packages`的[代理下载](../../../administration/object_storage.md#proxy-download)设置。相反，Maven 软件包仓库下载始终启用代理下载。

> [!note]
> 如果您不使用对象存储，此行为对您的实例没有影响。

<a id="cicd-integration-for-maven-packages"></a>

## Maven 软件包的 CI/CD 集成

您可以使用 CI/CD 自动构建、测试和发布 Maven 软件包。本节中的示例涵盖以下场景：

- 多模块项目
- 带版本的发布
- 条件发布
- 与代码质量和安全扫描的集成

您可以根据项目的具体需求调整和组合这些示例。

请记住根据项目需求调整 Maven 版本、Java 版本和其他具体内容。此外，请确保您正确配置了发布到极狐GitLab 软件包仓库所需的凭据和设置。

<a id="basic-maven-package-build-and-publish"></a>

### 基本的 Maven 软件包构建和发布

此示例配置了一个构建并发布 Maven 软件包的流水线：

```yaml
default:
  image: maven:3.8.5-openjdk-17
  cache:
    paths:
      - .m2/repository/
      - target/

variables:
  MAVEN_CLI_OPTS: "-s .m2/settings.xml --batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"

stages:
  - build
  - test
  - publish

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test

publish:
  stage: publish
  script:
    - mvn $MAVEN_CLI_OPTS deploy
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

<a id="multi-module-maven-project-with-parallel-jobs"></a>

### 使用并行作业的多模块 Maven 项目

对于具有多个模块的较大项目，您可以使用并行作业来加快构建过程：

```yaml
default:
  image: maven:3.8.5-openjdk-17
  cache:
    paths:
      - .m2/repository/
      - target/

variables:
  MAVEN_CLI_OPTS: "-s .m2/settings.xml --batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"

stages:
  - build
  - test
  - publish

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile

test:
  stage: test
  parallel:
    matrix:
      - MODULE: [module1, module2, module3]
  script:
    - mvn $MAVEN_CLI_OPTS test -pl $MODULE

publish:
  stage: publish
  script:
    - mvn $MAVEN_CLI_OPTS deploy
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

<a id="versioned-releases-with-tags"></a>

### 使用标签的带版本发布

此示例在推送标签时创建带版本的发布：

```yaml
default:
  image: maven:3.8.5-openjdk-17
  cache:
    paths:
      - .m2/repository/
      - target/

variables:
  MAVEN_CLI_OPTS: "-s .m2/settings.xml --batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"

stages:
  - build
  - test
  - publish
  - release

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test

publish:
  stage: publish
  script:
    - mvn $MAVEN_CLI_OPTS deploy
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

release:
  stage: release
  script:
    - mvn versions:set -DnewVersion=${CI_COMMIT_TAG}
    - mvn $MAVEN_CLI_OPTS deploy
  rules:
    - if: $CI_COMMIT_TAG
```

<a id="conditional-publishing-based-on-changes"></a>

### 基于变更的条件发布

此示例仅在特定文件发生变更时发布软件包：

```yaml
default:
  image: maven:3.8.5-openjdk-17
  cache:
    paths:
      - .m2/repository/
      - target/

variables:
  MAVEN_CLI_OPTS: "-s .m2/settings.xml --batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"

stages:
  - build
  - test
  - publish

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test

publish:
  stage: publish
  script:
    - mvn $MAVEN_CLI_OPTS deploy
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      changes:
        - pom.xml
        - src/**/*
```

<a id="integration-with-code-quality-and-security-scans"></a>

### 与代码质量和安全扫描的集成

此示例将代码质量检查和安全扫描集成到流水线中：

```yaml
default:
  image: maven:3.8.5-openjdk-17
  cache:
    paths:
      - .m2/repository/
      - target/

variables:
  MAVEN_CLI_OPTS: "-s .m2/settings.xml --batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"

include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Code-Quality.gitlab-ci.yml

stages:
  - build
  - test
  - quality
  - publish

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test

code_quality:
  stage: quality

sast:
  stage: quality

publish:
  stage: publish
  script:
    - mvn $MAVEN_CLI_OPTS deploy
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

<a id="helpful-hints"></a>

## 实用提示

<a id="publishing-a-package-with-the-same-name-or-version"></a>

### 发布具有相同名称或版本的软件包

当您发布与现有软件包具有相同名称和版本的软件包时，新软件包文件会添加到现有软件包中。您仍然可以使用 UI 或 API 访问和查看现有软件包的较旧资产。

要删除较旧的软件包版本，请考虑使用软件包 API 或 UI。

<a id="do-not-allow-duplicate-maven-packages"></a>

### 不允许重复的 Maven 软件包

要防止用户发布重复的 Maven 软件包，您可以使用 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings) 或 UI。

在 UI 中：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **软件包与镜像库**。
1. 在**重复软件包**表格的 **Maven** 行中，关闭**允许重复**开关。
1. 可选。在**例外**文本框中，输入一个与要允许的软件包名称和版本匹配的正则表达式。

> [!note]
> 如果**允许重复**已打开，您可以在**例外**文本框中指定不应有重复项的软件包名称和版本。

您的更改会自动保存。

<a id="request-forwarding-to-maven-central"></a>

### 将请求转发到 Maven Central

> [!flag]
> 此功能的可用性由功能标志控制。

当在软件包仓库中找不到 Maven 软件包时，请求会被转发
到 [Maven Central](https://search.maven.org/)。

当功能标志启用时，管理员可以在[持续集成设置](../../../administration/settings/continuous_integration.md)中禁用此行为。

Maven 转发仅限于项目级和群组级[端点](#naming-convention)。实例级端点存在命名限制，使其无法用于不遵循该约定的软件包，并且还会为供应链式攻击带来过多的安全风险。

<a id="additional-configuration-for-mvn"></a>

#### `mvn`的附加配置

使用 `mvn` 时，有许多方法可以配置您的 Maven 项目，使其从极狐GitLab 请求
Maven Central 中的软件包。Maven 仓库会按
[特定顺序](https://maven.apache.org/guides/mini/guide-multiple-repositories.html#repository-order)查询。
默认情况下，Maven Central 通常通过
[Super POM](https://maven.apache.org/guides/introduction/introduction-to-the-pom.html#Super_POM) 首先被检查，因此
需要将极狐GitLab 配置为在 maven-central 之前被查询。

为确保所有软件包请求都发送到极狐GitLab 而不是 Maven Central，您可以通过向 `settings.xml` 添加 `<mirror>`
部分，将 Maven Central 覆盖为中央仓库：

```xml
<settings>
  <servers>
    <server>
      <id>central-proxy</id>
      <configuration>
        <httpHeaders>
          <property>
            <name>Private-Token</name>
            <value><personal_access_token></value>
          </property>
        </httpHeaders>
      </configuration>
    </server>
  </servers>
  <mirrors>
    <mirror>
      <id>central-proxy</id>
      <name>GitLab proxy of central repo</name>
      <url>https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

<a id="create-maven-packages-with-gitlab-cicd"></a>

### 使用极狐GitLab CI/CD 创建 Maven 软件包

在您将代码仓库配置为使用 Maven 的软件包仓库后，您可以配置极狐GitLab CI/CD 自动构建新软件包。

{{< tabs >}}

{{< tab title="`mvn`" >}}

您可以在每次更新默认分支时创建一个新软件包。

1. 创建一个 `ci_settings.xml` 文件，用作 Maven 的 `settings.xml` 文件。
1. 添加 `server` 部分，其 ID 与您在 `pom.xml` 文件中定义的 ID 相同。
   例如，使用 `gitlab-maven` 作为 ID：

   ```xml
   <settings xmlns="http://maven.apache.org/SETTINGS/1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd">
     <servers>
       <server>
         <id>gitlab-maven</id>
         <configuration>
           <httpHeaders>
             <property>
               <name>Job-Token</name>
               <value>${CI_JOB_TOKEN}</value>
             </property>
           </httpHeaders>
         </configuration>
       </server>
     </servers>
   </settings>
   ```

1. 确保您的 `pom.xml` 文件包含以下内容。
   您可以像此示例所示那样让 Maven 使用[预定义 CI/CD 变量](../../../ci/variables/predefined_variables.md)，
   也可以硬编码服务器的主机名和项目的 ID。

   ```xml
   <repositories>
     <repository>
       <id>gitlab-maven</id>
       <url>${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/maven</url>
     </repository>
   </repositories>
   <distributionManagement>
     <repository>
       <id>gitlab-maven</id>
       <url>${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/maven</url>
     </repository>
     <snapshotRepository>
       <id>gitlab-maven</id>
       <url>${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/maven</url>
     </snapshotRepository>
   </distributionManagement>
   ```

1. 向您的 `.gitlab-ci.yml` 文件添加一个 `deploy` 作业：

   ```yaml
   deploy:
     image: maven:3.6-jdk-11
     script:
       - 'mvn deploy -s ci_settings.xml'
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
   ```

1. 将这些文件推送到您的代码仓库。

下次 `deploy` 作业运行时，它会将 `ci_settings.xml` 复制到
用户的主目录位置。在此示例中：

- 用户是 `root`，因为该作业在 Docker 容器中运行。
- Maven 使用已配置的 CI/CD 变量。

{{< /tab >}}

{{< tab title="`gradle`" >}}

您可以在每次更新默认分支时
创建一个软件包。

1. 使用 [Gradle 中的 CI 作业令牌](#edit-the-client-configuration)进行身份验证。
1. 向您的 `.gitlab-ci.yml` 文件添加一个 `deploy` 作业：

   ```yaml
   deploy:
     image: gradle:6.5-jdk11
     script:
       - 'gradle publish'
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
   ```

1. 将文件提交到您的代码仓库。

当流水线成功时，Maven 软件包即被创建。

{{< /tab >}}

{{< /tabs >}}

<a id="version-validation"></a>

### 版本验证

版本字符串使用以下正则表达式进行验证。

```ruby
\A(?!.*\.\.)[\w+.-]+\z
```

您可以在[此正则表达式编辑器](https://rubular.com/r/rrLQqUXjfKEoL6)中试验该正则表达式并尝试您的版本字符串。

<a id="use-different-settings-for-snapshot-and-release-deployments"></a>

### 为快照和发布部署使用不同的设置

要为快照和发布使用不同的 URL 或设置：

- 在 `pom.xml` 文件的 `<distributionManagement>` 部分中，分别定义 `<repository>` 和 `<snapshotRepository>` 元素。

<a id="useful-maven-command-line-options"></a>

### 有用的 Maven 命令行选项

在使用极狐GitLab CI/CD 执行任务时，您可以使用一些 [Maven 命令行选项](https://maven.apache.org/ref/current/maven-embedder/cli.html)。

- 文件传输进度可能会使 CI 日志难以阅读。
  选项 `-ntp,--no-transfer-progress` 是在
  [3.6.1](https://maven.apache.org/docs/3.6.1/release-notes.html#User_visible_Changes)中添加的。
  或者，查看 `-B,--batch-mode`
  [或更低级别的日志记录更改。](https://stackoverflow.com/questions/21638697/disable-maven-download-progress-indication)

- 指定在哪里查找 `pom.xml` 文件（`-f,--file`）：

  ```yaml
  package:
    script:
      - 'mvn --no-transfer-progress -f helloworld/pom.xml package'
  ```

- 指定在哪里查找用户设置（`-s,--settings`），而不是
  [默认位置](https://maven.apache.org/settings.html)。还有一个 `-gs,--global-settings` 选项：

  ```yaml
  package:
    script:
      - 'mvn -s settings/ci.xml package'
  ```

<a id="supported-cli-commands"></a>

### 支持的 CLI 命令

极狐GitLab Maven 仓库支持以下 CLI 命令：

{{< tabs >}}

{{< tab title="`mvn`" >}}

- `mvn deploy`：将您的软件包发布到软件包仓库。
- `mvn install`：安装 Maven 项目中指定的软件包。
- `mvn dependency:get`：安装特定软件包。

{{< /tab >}}

{{< tab title="`gradle`" >}}

- `gradle publish`：将您的软件包发布到软件包仓库。
- `gradle build`：组装并测试此项目。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

在极狐GitLab 中使用 Maven 软件包时，您可能会遇到问题。要解决许多常见问题，请尝试以下步骤：

- 验证身份验证 - 确保您的身份验证令牌正确且未过期。
- 检查权限 - 确认您具有发布或安装软件包所需的权限。
- 验证 Maven 设置 - 仔细检查您的 `settings.xml` 文件配置是否正确。
- 查看极狐GitLab CI/CD 日志 - 对于 CI/CD 问题，请仔细检查作业日志中的错误消息。
- 确保端点 URL 正确 - 验证您为项目或群组使用的端点 URL 是否正确。
- 对 `mvn` 命令使用 -s 选项 - 始终使用 `-s` 选项运行 Maven 命令，例如 `mvn package -s settings.xml`。如果不使用此选项，身份验证设置将不会应用，Maven 可能无法找到软件包。

<a id="clear-the-cache"></a>

### 清除缓存

为提高性能，客户端会缓存与软件包相关的文件。如果您遇到问题，请使用以下命令清除缓存：

{{< tabs >}}

{{< tab title="`mvn`" >}}

```shell
rm -rf ~/.m2/repository
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

```shell
rm -rf ~/.gradle/caches # Or replace ~/.gradle with your custom GRADLE_USER_HOME
```

{{< /tab >}}

{{< /tabs >}}

<a id="review-network-trace-logs"></a>

### 查看网络跟踪日志

如果您在使用 Maven 仓库时遇到问题，您可能需要查看网络跟踪日志。查看网络跟踪日志可提供更详细的错误消息，而 Maven 客户端默认不包含这些消息。

例如，尝试使用 PAT 令牌在本地运行 `mvn deploy` 并使用以下选项：

```shell
mvn deploy \
-Dorg.slf4j.simpleLogger.log.org.apache.maven.wagon.providers.http.httpclient=trace \
-Dorg.slf4j.simpleLogger.log.org.apache.maven.wagon.providers.http.httpclient.wire=trace
```

> [!warning]
> 当您设置这些选项时，所有网络请求都会被记录，并会生成大量输出。

<a id="verify-your-maven-settings"></a>

### 验证您的 Maven 设置

如果您在 CI/CD 中遇到与 `settings.xml` 文件相关的问题，请尝试添加一个额外的脚本任务或作业来[验证有效设置](https://maven.apache.org/plugins/maven-help-plugin/effective-settings-mojo.html)。

help 插件还可以提供[系统属性](https://maven.apache.org/plugins/maven-help-plugin/system-mojo.html)，包括环境变量：

```yaml
mvn-settings:
  script:
    - 'mvn help:effective-settings'

package:
  script:
    - 'mvn help:system'
    - 'mvn package'
```

<a id="401-unauthorized-error-when-trying-to-publish-a-package"></a>

### 尝试发布软件包时出现 `401 Unauthorized` 错误

这通常表示身份验证问题。请检查：

- 您的身份验证令牌有效且未过期。
- 您使用的是正确的令牌类型（个人访问令牌、部署令牌或 CI 作业令牌）。
- 该令牌具有必要的权限（`api`、`read_api` 或 `read_repository`）。
- 对于 Maven 项目，您在 mvn 命令中使用了 `-s` 选项（例如 `mvn deploy -s settings.xml`）。如果不使用此选项，Maven 将不会应用 `settings.xml` 文件中的身份验证设置，从而导致未授权错误。

<a id="400-bad-request-error-with-message-validation-failed-version-is-invalid"></a>

### 出现 `400 Bad Request` 错误，消息为 "Validation failed: Version is invalid"

极狐GitLab 对版本字符串有特定要求。确保您的版本遵循以下格式：

```plaintext
^(?!.*\.\.)(?!.*\.$)[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*(\+[0-9A-Za-z-]+)?$
```

例如，"1.0.0"、"1.0-SNAPSHOT" 和 "1.0.0-alpha" 是有效的，但 "1..0" 或 "1.0." 无效。

<a id="403-forbidden-error-when-trying-to-publish-a-package"></a>

### 尝试发布软件包时出现 `403 Forbidden` 错误

带有 `Authorization failed` 消息的 `403 Forbidden` 错误通常表示身份验证或权限问题。请检查：

- 您使用的是正确的令牌类型（个人访问令牌、部署令牌或 CI/CD 作业令牌）。有关更多信息，请参阅[向软件包仓库进行身份验证](#authenticate-to-the-package-registry)。
- 该令牌具有必要的权限。只有具有开发者、维护者或所有者角色的用户才能发布软件包。有关更多信息，请参阅[极狐GitLab 权限](../../permissions.md#project-packages-and-registries)。
- 您要发布的软件包未受推送保护规则保护。有关软件包保护规则的更多信息，请参阅[如何保护软件包](../package_registry/package_protection_rules.md#protect-a-package)。

<a id="artifact-already-exists-errors-when-publishing"></a>

### 发布时出现 `Artifact already exists` 错误

当您尝试发布已存在的软件包版本时，会出现此错误。要解决：

- 在发布前递增您的软件包版本。
- 如果您使用 SNAPSHOT 版本，请确保在配置中允许 SNAPSHOT 覆盖。

<a id="published-package-not-appearing-in-the-ui"></a>

### 已发布的软件包未出现在 UI 中

如果您刚刚发布了软件包，它可能需要一些时间才会出现。如果它仍未显示：

- 验证您具有查看软件包所需的权限。
- 通过查看 CI/CD 日志或 Maven 输出，检查软件包是否已成功发布。
- 确保您在正确的项目或群组中查找。

<a id="maven-repository-dependency-conflicts"></a>

### Maven 仓库依赖冲突

依赖冲突可以通过以下方式解决：

- 在您的 `pom.xml`中显式定义版本。
- 使用 Maven 的依赖管理部分来控制版本。
- 使用 `<exclusions>` 标签排除冲突的传递依赖项。

<a id="unable-to-find-valid-certification-path-to-requested-target-error"></a>

### `Unable to find valid certification path to requested target` 错误

这通常是 SSL 证书问题。要解决：

- 确保您的 JDK 信任极狐GitLab 服务器的 SSL 证书。
- 如果使用自签名证书，请将其添加到 JDK 的信任库中。
- 作为最后的手段，您可以在 Maven 设置中禁用 SSL 验证。不建议在生产环境中使用。

<a id="no-plugin-found-for-prefix-pipeline-errors"></a>

### `No plugin found for prefix` 流水线错误

这通常意味着 Maven 找不到该插件。要修复：

- 确保该插件在您的 `pom.xml`中正确定义。
- 检查您的 CI/CD 配置是否使用了正确的 Maven 设置文件。
- 验证您的流水线是否有权访问所有必要的仓库。
