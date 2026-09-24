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

在项目的软件包仓库中发布 [Maven](https://maven.apache.org) 产物。随后，可以在需要时将这些软件包安装为依赖项。

有关 Maven 软件包管理器客户端使用的特定 API 端点的文档，请参阅 [Maven API 文档](../../../api/packages/maven.md)。

支持的客户端：

- `mvn`。了解如何构建 [Maven](../workflows/build_packages.md#maven) 软件包。
- `gradle`。了解如何构建 [Gradle](../workflows/build_packages.md#gradle) 软件包。
- `sbt`。

<a id="publish-to-the-gitlab-package-registry"></a>

## 发布到极狐GitLab 软件包仓库

<a id="authenticate-to-the-package-registry"></a>

### 认证到软件包仓库

你需要一个令牌（token）才能发布软件包。根据你的目标，可用的令牌类型不同。有关更多信息，请查看 [关于令牌的指南](../package_registry/supported_functionality.md#authenticate-with-the-registry)。

创建一个令牌并保存，以便在后续流程中使用。

不要使用本文档未记载的认证方法。未记载的认证方法可能会在未来被移除。

<a id="edit-the-client-configuration"></a>

#### 编辑客户端配置

更新你的配置，以通过 HTTP 向 Maven 仓库进行认证。

<a id="custom-http-header"></a>

##### 自定义 HTTP 标头

你必须将认证详情添加到客户端的配置文件中。

{{< tabs >}}

{{< tab title="`mvn`" >}}

| 令牌类型 | 名称必须为 | 令牌 |
| --------------------- | --------------- | ---------------------------------------------------------------------- |
| 个人访问令牌 | `Private-Token` | 原样粘贴令牌，或定义环境变量来保存令牌 |
| 部署令牌 | `Deploy-Token` | 原样粘贴令牌，或定义环境变量来保存令牌 |
| CI 任务令牌 | `Job-Token` | `${CI_JOB_TOKEN}` |
| OAuth 令牌 | `Authorization` | 在令牌前添加 `Bearer` 前缀（例如，`Bearer <oauth_token>`） |

> [!note]
> `<name>` 字段必须与你选择的令牌类型匹配。

将以下部分添加到你的
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

| 令牌类型 | 名称必须为 | 令牌 |
| --------------------- | --------------- | ---------------------------------------------------------------------- |
| 个人访问令牌 | `Private-Token` | 原样粘贴令牌，或定义环境变量来保存令牌 |
| 部署令牌 | `Deploy-Token` | 原样粘贴令牌，或定义环境变量来保存令牌 |
| CI 任务令牌 | `Job-Token` | `System.getenv("CI_JOB_TOKEN")` |
| OAuth 令牌 | `Authorization` | 在令牌前添加 `Bearer` 前缀（例如，`Bearer <oauth_token>`） |

> [!note]
> `<name>` 字段必须与你选择的令牌类型匹配。

在 [你的 `GRADLE_USER_HOME` 目录](https://docs.gradle.org/current/userguide/directory_layout.html#dir:gradle_user_home) 中，创建包含以下内容的 `gradle.properties` 文件：

```properties
gitLabPrivateToken=REPLACE_WITH_YOUR_TOKEN
```

将 `repositories` 部分添加到你的
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

##### 基本 HTTP 认证

你也可以使用基本 HTTP 认证向 Maven 软件包仓库进行认证。

{{< tabs >}}

{{< tab title="`mvn`" >}}

| 令牌类型 | 名称必须为 | 令牌 |
| --------------------- | ---------------------------- | ---------------------------------------------------------------------- |
| 个人访问令牌 | 用户的用户名 | 原样粘贴令牌，或定义环境变量来保存令牌 |
| 部署令牌 | 部署令牌的用户名 | 原样粘贴令牌，或定义环境变量来保存令牌 |
| CI 任务令牌 | `gitlab-ci-token` | `${CI_JOB_TOKEN}` |

将以下部分添加到你的
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

| 令牌类型 | 名称必须为 | 令牌 |
| --------------------- | ---------------------------- | ---------------------------------------------------------------------- |
| 个人访问令牌 | 用户的用户名 | 原样粘贴令牌，或定义环境变量来保存令牌 |
| 部署令牌 | 部署令牌的用户名 | 原样粘贴令牌，或定义环境变量来保存令牌 |
| CI 任务令牌 | `gitlab-ci-token` | `System.getenv("CI_JOB_TOKEN")` |

在 [你的 `GRADLE_USER_HOME` 目录](https://docs.gradle.org/current/userguide/directory_layout.html#dir:gradle_user_home) 中，创建包含以下内容的 `gradle.properties` 文件：

```properties
gitLabPrivateToken=REPLACE_WITH_YOUR_TOKEN
```

将 `repositories` 部分添加到你的
[`build.gradle`](https://docs.gradle.org/current/userguide/tutorial_using_tasks.html) 中。

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

| 令牌类型 | 名称必须为 | 令牌 |
|-----------------------|------------------------------|------------------------------------------------------------------------|
| 个人访问令牌 | 用户的用户名 | 原样粘贴令牌，或定义环境变量来保存令牌 |
| 部署令牌 | 部署令牌的用户名 | 原样粘贴令牌，或定义环境变量来保存令牌 |
| CI 任务令牌 | `gitlab-ci-token` | `sys.env.get("CI_JOB_TOKEN").get` |

[SBT](https://www.scala-sbt.org/index.html) 的认证基于
[基本 HTTP 认证](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)。
你必须提供名称和密码。

> [!note]
> 名称字段必须与你选择的令牌类型匹配。

要通过 `sbt` 从 Maven 极狐GitLab 软件包仓库安装软件包，你必须配置
一个 [Maven 解析器](https://www.scala-sbt.org/1.x/docs/Resolvers.html#Maven+resolvers)。
如果你访问的是私有或内部项目或群组，则需要设置
[凭证](https://www.scala-sbt.org/1.x/docs/Publishing.html#Credentials)。
配置好解析器和认证后，你可以从项目、群组或命名空间安装软件包。

在你的 [`build.sbt`](https://www.scala-sbt.org/1.x/docs/Directories.html#sbt+build+definition+files) 中，添加以下行：

```scala
resolvers += ("gitlab" at "<endpoint url>")

credentials += Credentials("GitLab Packages Registry", "<host>", "<name>", "<token>")
```

在这个例子中：

- `<endpoint url>` 是 [端点 URL](#endpoint-urls)。
  示例：`https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven`。
- `<host>` 是 `<endpoint url>` 中的主机名，不包含协议方案
  或端口。示例：`gitlab.example.com`。
- `<name>` 和 `<token>` 在上面的表格中进行了说明。

{{< /tab >}}

{{< /tabs >}}

<a id="naming-convention"></a>

### 命名规范

你可以使用三种端点之一来安装 Maven 软件包。你必须将软件包发布到项目，但选择的端点决定了添加到 `pom.xml` 文件中的发布设置。

这三种端点是：

- 项目：当你只有少量 Maven 软件包且它们不在同一个极狐GitLab 群组中时使用。
- 群组：当你想从同一极狐GitLab 群组中的多个不同项目安装软件包时使用。极狐GitLab 不保证群组内软件包名称的唯一性。你可能有两个项目具有相同的软件包名称和软件包版本。因此，极狐GitLab 会提供最新的那个。
- 实例：当你拥有许多分布在不同极狐GitLab 群组或各自命名空间中的软件包时使用。

对于实例级端点，请确保 Maven 中 `pom.xml` 的相关部分如下所示：

```xml
  <groupId>group-slug.subgroup-slug</groupId>
  <artifactId>project-slug</artifactId>
```

只有与项目路径相同的软件包才会通过实例级端点公开。

| 项目 | 软件包 | 实例级端点可用 |
| ------------------- | -------------------------------- | --------------------------------- |
| `foo/bar` | `foo/bar/1.0-SNAPSHOT` | 是 |
| `gitlab-org/gitlab` | `foo/bar/1.0-SNAPSHOT` | 否 |
| `gitlab-org/gitlab` | `gitlab-org/gitlab/1.0-SNAPSHOT` | 是 |

<a id="endpoint-urls"></a>

#### 端点 URL

| 端点 | `pom.xml` 的端点 URL | 附加信息 |
|----------|--------------------------------------------------------------------------|------------------------|
| 项目 | `https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven` | 将 `gitlab.example.com` 替换为你的域名。将 `<project_id>` 替换为你的项目 ID，可在 [项目概览页面](../../project/working_with_projects.md#find-the-project-id) 找到。 |
| 群组 | `https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/maven` | 将 `gitlab.example.com` 替换为你的域名。将 `<group_id>` 替换为你的群组 ID，可在群组首页找到。 |
| 实例 | `https://gitlab.example.com/api/v4/packages/maven` | 将 `gitlab.example.com` 替换为你的域名。 |

<a id="edit-the-configuration-file-for-publishing"></a>

### 编辑用于发布的配置文件

你必须将发布详情添加到客户端的配置文件中。

{{< tabs >}}

{{< tab title="`mvn`" >}}

无论你选择哪种端点，都必须具备以下内容：

- `distributionManagement` 部分中的项目特定 URL。
- `repository` 和 `distributionManagement` 部分。

Maven 中 `pom.xml` 的相关 `repository` 部分应如下所示：

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

- `id` 是你在 [`settings.xml`](#edit-the-client-configuration) 中定义的内容。
- `<your_endpoint_url>` 取决于你选择的 [端点](#endpoint-urls)。
- 将 `gitlab.example.com` 替换为你的域名。

{{< /tab >}}

{{< tab title="`gradle`" >}}

要使用 Gradle 发布软件包：

1. 将 Gradle 插件 [`maven-publish`](https://docs.gradle.org/current/userguide/publishing_maven.html) 添加到插件部分：

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

2. 添加 `publishing` 部分：

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
> 使用 `DeployAtEnd` 选项可能导致上传被拒绝，返回 `400 bad request {"message":"Validation failed: Name has already been taken"}`。更多详情，请参见议题 424238。

完成 [认证](#authenticate-to-the-package-registry) 并 [选择发布端点](#naming-convention) 后，即可将 Maven 软件包发布到你的项目。

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

消息还应显示软件包已发布到正确位置：

```shell
Uploading to gitlab-maven: https://example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/mydepartment/my-project/1.0-SNAPSHOT/my-project-1.0-20200128.120857-1.jar
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

运行发布任务：

```shell
gradle publish
```

转到项目的 **软件包与镜像仓库** 页面，查看已发布的软件包。

{{< /tab >}}

{{< tab title="`sbt`" >}}

在你的 `build.sbt` 文件中配置 `publishTo` 设置：

```scala
publishTo := Some("gitlab" at "<endpoint url>")
```

确保正确引用了凭证。有关更多信息，请参见 [`sbt` 文档](https://www.scala-sbt.org/1.x/docs/Publishing.html#Credentials)。

要使用 `sbt` 发布软件包：

```shell
sbt publish
```

如果部署成功，将显示构建成功消息：

```shell
[success] Total time: 1 s, completed Jan 28, 2020 12:08:57 PM
```

检查成功消息以确保软件包已发布到正确位置：

```shell
[info]  published my-project_2.12 to https://gitlab.example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/my-project_2.12/0.1.1-SNAPSHOT/my-project_2.12-0.1.1-SNAPSHOT.pom
```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 如果在发布之前对 Maven 软件包进行了保护，则该软件包将被拒绝，并返回 `403 Forbidden` 错误和 `Authorization failed` 错误消息。
> 确保在发布时 Maven 软件包未被保护。
> 有关软件包保护规则的更多信息，请参见 [如何保护软件包](../package_registry/package_protection_rules.md#protect-a-package)。

<a id="install-a-package"></a>

## 安装软件包

要从极狐GitLab 软件包仓库安装软件包，你必须配置 [远程仓库并进行认证](#authenticate-to-the-package-registry)。完成后，即可从项目、群组或命名空间安装软件包。

如果多个软件包具有相同的名称和版本，安装时将获取最近发布的软件包。

{{< tabs >}}

{{< tab title="`mvn`" >}}

要使用 `mvn install` 安装软件包：

1. 手动将依赖项添加到项目的 `pom.xml` 文件中。
   例如，要添加之前创建的示例，XML 内容如下：

   ```xml
   <dependency>
     <groupId>com.mycompany.mydepartment</groupId>
     <artifactId>my-project</artifactId>
     <version>1.0-SNAPSHOT</version>
   </dependency>
   ```

2. 在项目中，运行以下命令：

   ```shell
   mvn install
   ```

消息应显示软件包正从软件包仓库下载：

```shell
Downloading from gitlab-maven: http://gitlab.example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/mydepartment/my-project/1.0-SNAPSHOT/my-project-1.0-20200128.120857-1.pom
```

你也可以直接使用 Maven [`dependency:get` 命令](https://maven.apache.org/plugins/maven-dependency-plugin/get-mojo.html) 安装软件包。

1. 在项目目录中，运行：

   ```shell
   mvn dependency:get -Dartifact=com.nickkipling.app:nick-test-app:1.1-SNAPSHOT -DremoteRepositories=gitlab-maven::::<gitlab endpoint url>  -s <path to settings.xml>
   ```

   - `<gitlab endpoint url>` 是极狐GitLab [端点](#endpoint-urls) 的 URL。
   - `<path to settings.xml>` 是包含 [认证详情](#edit-the-client-configuration) 的 `settings.xml` 文件路径。

> [!note]
> `gitlab-maven` 命令和 `settings.xml` 文件中的仓库 ID 必须匹配。

消息应显示软件包正从软件包仓库下载：

```shell
Downloading from gitlab-maven: http://gitlab.example.com/api/v4/projects/PROJECT_ID/packages/maven/com/mycompany/mydepartment/my-project/1.0-SNAPSHOT/my-project-1.0-20200128.120857-1.pom
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

要使用 `gradle` 安装软件包：

1. 在 `build.gradle` 的 dependencies 部分添加 [依赖项](https://docs.gradle.org/current/userguide/declaring_dependencies.html)：

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

2. 在项目中，运行以下命令：

   ```shell
   gradle build
   ```

{{< /tab >}}

{{< tab title="`sbt`" >}}

要使用 `sbt` 安装软件包：

1. 在 `build.sbt` 中添加 [内联依赖项](https://www.scala-sbt.org/1.x/docs/Library-Management.html#Dependencies)：

   ```scala
   libraryDependencies += "com.mycompany.mydepartment" % "my-project" % "8.4"
   ```

2. 在项目中，运行以下命令：

   ```shell
   sbt update
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="proxy-downloads-for-maven-packages"></a>

### Maven 软件包的代理下载

{{< history >}}

- 在极狐GitLab 17.8 中引入。

{{< /history >}}

极狐GitLab Maven 软件包仓库使用 [远程包含校验和](https://maven.apache.org/resolver/expected-checksums.html#remote-included-checksums)。当你下载文件时，仓库会代理文件，并在一次请求中将文件及其相关校验和发送给 Maven 客户端。

对较新的 Maven 客户端使用远程包含校验和：

- 减少客户端向极狐GitLab Maven 软件包仓库发出的网络请求数量。
- 降低极狐GitLab 实例的负载。
- 缩短客户端命令的执行时间。

由于技术限制，当你使用对象存储时，Maven 软件包仓库会忽略 `packages` 对象存储配置中的 [代理下载](../../../administration/object_storage.md#proxy-download) 设置。相反，对于 Maven 软件包仓库下载，代理下载始终启用。

> [!note]
> 如果你不使用对象存储，此行为对你的实例没有影响。

<a id="ci-cd-integration-for-maven-packages"></a>

## Maven 软件包的 CI/CD 集成

你可以使用 CI/CD 自动构建、测试和发布 Maven 软件包。本节中的示例涵盖了以下几个场景：

- 多模块项目
- 版本化发布
- 条件发布
- 与代码质量和安全扫描集成

你可以调整和组合这些示例，以满足特定项目需求。

请根据项目要求调整 Maven 版本、Java 版本和其他具体设置。此外，确保已正确配置发布到极狐GitLab 软件包仓库所需的凭证和设置。

<a id="basic-maven-package-build-and-publish"></a>

### 基本 Maven 软件包构建与发布

本示例配置了一个构建并发布 Maven 软件包的流水线：

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

### 具有并行任务的多模块 Maven 项目

对于拥有多个模块的大型项目，你可以使用并行任务来加快构建过程：

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

### 使用标签的版本化发布

本示例在推送标签时创建版本化发布：

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
```
<a id="conditional-publishing-based-on-changes"></a>

### 基于更改的条件发布

此示例仅当特定文件发生更改时发布软件包：

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

### 集成代码质量与安全扫描

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

### 发布同名或同版本的软件包

当你发布一个与已存在软件包具有相同名称和版本的软件包时，新软件包的文件会被添加到现有软件包中。你仍可以使用 UI 或 API 访问和查看现有软件包的旧资产。

要删除旧版本的软件包，请考虑使用 Packages API 或 UI。

<a id="do-not-allow-duplicate-maven-packages"></a>

### 不允许重复的 Maven 软件包

{{< history >}}

- 在极狐GitLab 15.0 中，所需角色从开发者更改为维护者。
- 在极狐GitLab 17.0 中，所需角色从维护者更改为所有者。

{{< /history >}}

要阻止用户发布重复的 Maven 软件包，可以使用 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings) 或 UI。

在 UI 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **软件包与镜像仓库**。
1. 在 **重复软件包** 表格的 **Maven** 行中，关闭 **允许重复** 切换按钮。
1. 可选。在 **例外** 文本框中，输入一个匹配要允许的软件包名称和版本的正则表达式。

> [!note]
> 如果 **允许重复** 已打开，你可以在 **例外** 文本框中指定不应有重复的软件包名称和版本。

你的更改会自动保存。

<a id="request-forwarding-to-maven-central"></a>

### 请求转发到 Maven Central

{{< history >}}

- 在极狐GitLab 15.4 中引入，由一个名为 `maven_central_request_forwarding` 的功能标志控制。默认禁用。
- 在极狐GitLab 17.0 中，所需角色从维护者更改为所有者。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参阅历史。

当在软件包仓库中找不到 Maven 软件包时，请求会被转发到 [Maven Central](https://search.maven.org/)。

当功能标志启用时，管理员可以在 [持续集成设置](../../../administration/settings/continuous_integration.md) 中禁用此行为。

Maven 转发仅限于项目级别和群组级别的 [端点](#naming-convention)。实例级别的端点存在命名限制，导致其无法用于不遵循该约定的软件包，并且还会为供应链式攻击带来过多安全风险。

<a id="additional-configuration-for-mvn"></a>

#### 为 `mvn` 进行额外配置

使用 `mvn` 时，有多种方式来配置你的 Maven 项目，使其从极狐GitLab 请求 Maven Central 中的软件包。Maven 仓库按照 [特定顺序](https://maven.apache.org/guides/mini/guide-multiple-repositories.html#repository-order) 被查询。默认情况下，通常会通过 [Super POM](https://maven.apache.org/guides/introduction/introduction-to-the-pom.html#Super_POM) 首先检查 Maven Central，因此需要将极狐GitLab 配置为在 maven-central 之前被查询。

为确保所有软件包请求都被发送到极狐GitLab 而不是 Maven Central，你可以通过在你的 `settings.xml` 中添加一个 `<mirror>` 部分来覆盖 Maven Central 作为中央仓库：

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
      <name>极狐GitLab 代理中央仓库</name>
      <url>https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

<a id="create-maven-packages-with-gitlab-cicd"></a>

### 使用极狐GitLab CI/CD 创建 Maven 软件包

在将仓库配置为使用 Maven 软件包仓库后，你可以配置极狐GitLab CI/CD 来自动构建新软件包。

{{< tabs >}}

{{< tab title="`mvn`" >}}

你可以在每次默认分支更新时创建一个新软件包。

1. 创建一个 `ci_settings.xml` 文件作为 Maven 的 `settings.xml` 文件。
1. 添加 `server` 部分，其 ID 与你在 `pom.xml` 文件中定义的相同。例如，使用 `gitlab-maven` 作为 ID：

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

1. 确保你的 `pom.xml` 文件包含以下内容。你可以根据需要，如本示例所示，让 Maven 使用 [预定义的 CI/CD 变量](../../../ci/variables/predefined_variables.md)，也可以硬编码你的服务器主机名和项目 ID。

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

1. 将 `deploy` 作业添加到你的 `.gitlab-ci.yml` 文件中：

   ```yaml
   deploy:
     image: maven:3.6-jdk-11
     script:
       - 'mvn deploy -s ci_settings.xml'
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
   ```

1. 将这些文件推送到你的仓库。

下一次 `deploy` 作业运行时，它会将 `ci_settings.xml` 复制到用户的主目录。在此示例中：

- 用户是 `root`，因为作业在 Docker 容器中运行。
- Maven 使用配置的 CI/CD 变量。

{{< /tab >}}

{{< tab title="`gradle`" >}}

你可以在每次默认分支更新时创建一个软件包。

1. 使用 [Gradle 中的 CI 作业令牌进行认证](#edit-the-client-configuration)。
1. 将 `deploy` 作业添加到你的 `.gitlab-ci.yml` 文件中：

   ```yaml
   deploy:
     image: gradle:6.5-jdk11
     script:
       - 'gradle publish'
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
   ```

1. 提交文件到你的仓库。

当流水线成功时，Maven 软件包就会被创建。

{{< /tab >}}

{{< /tabs >}}

<a id="version-validation"></a>

### 版本验证

版本字符串通过以下正则表达式进行验证。

```ruby
\A(?!.*\.\.)[\w+.-]+\z
```

你可以在 [这个正则表达式编辑器](https://rubular.com/r/rrLQqUXjfKEoL6) 中尝试该正则表达式并测试你的版本字符串。

<a id="use-different-settings-for-snapshot-and-release-deployments"></a>

### 为快照和发布部署使用不同的设置

如需为快照和发布使用不同的 URL 或设置：

- 在 `pom.xml` 文件的 `<distributionManagement>` 部分中，分别定义 `<repository>` 和 `<snapshotRepository>` 元素。

<a id="useful-maven-command-line-options"></a>

### 有用的 Maven 命令行选项

在使用极狐GitLab CI/CD 执行任务时，你可以使用一些 [Maven 命令行选项](https://maven.apache.org/ref/current/maven-embedder/cli.html)。

- 文件传输进度可能会使 CI 日志难以阅读。选项 `-ntp,--no-transfer-progress` 在 [3.6.1](https://maven.apache.org/docs/3.6.1/release-notes.html#User_visible_Changes) 中添加。或者，也可以查看 `-B,--batch-mode` [或更低级别的日志更改](https://stackoverflow.com/questions/21638697/disable-maven-download-progress-indication)。

- 指定查找 `pom.xml` 文件的位置 (`-f,--file`)：

  ```yaml
  package:
    script:
      - 'mvn --no-transfer-progress -f helloworld/pom.xml package'
  ```

- 指定查找用户设置的位置 (`-s,--settings`)，而不是 [默认位置](https://maven.apache.org/settings.html)。还有 `-gs,--global-settings` 选项：

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

- `mvn deploy`：将你的软件包发布到软件包仓库。
- `mvn install`：安装你 Maven 项目中指定的软件包。
- `mvn dependency:get`：安装特定软件包。

{{< /tab >}}

{{< tab title="`gradle`" >}}

- `gradle publish`：将你的软件包发布到软件包仓库。
- `gradle build`：组装并测试此项目。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

在极狐GitLab 中使用 Maven 软件包时，你可能会遇到问题。要解决许多常见问题，请尝试以下步骤：

- 验证认证 - 确保你的认证令牌正确且未过期。
- 检查权限 - 确认你拥有发布或安装软件包所需的权限。
- 验证 Maven 设置 - 仔细检查你的 `settings.xml` 文件配置是否正确。
- 查看极狐GitLab CI/CD 日志 - 对于 CI/CD 问题，请仔细检查作业日志中的错误信息。
- 确保使用正确的端点 URL - 验证是否使用了项目或群组的正确端点 URL。
- 在 `mvn` 命令中使用 `-s` 选项 - 始终在运行 Maven 命令时使用 `-s` 选项，例如 `mvn package -s settings.xml`。如果不使用此选项，认证设置将不会被应用，Maven 可能无法找到软件包。

<a id="clear-the-cache"></a>

### 清除缓存

为了提高性能，客户端会缓存与软件包相关的文件。如果你遇到问题，请使用以下命令清除缓存：

{{< tabs >}}

{{< tab title="`mvn`" >}}

```shell
rm -rf ~/.m2/repository
```

{{< /tab >}}

{{< tab title="`gradle`" >}}

```shell
rm -rf ~/.gradle/caches # 或者将 ~/.gradle 替换为你自定义的 GRADLE_USER_HOME
```

{{< /tab >}}

{{< /tabs >}}

<a id="review-network-trace-logs"></a>

### 查看网络跟踪日志

如果你在使用 Maven 仓库时遇到问题，你可能希望查看网络跟踪日志。查看网络跟踪日志可提供更详细的错误信息，而这些信息在默认情况下是不包含在 Maven 客户端输出中的。

例如，尝试在本地使用 PAT 令牌运行 `mvn deploy`，并使用以下选项：

```shell
mvn deploy \
-Dorg.slf4j.simpleLogger.log.org.apache.maven.wagon.providers.http.httpclient=trace \
-Dorg.slf4j.simpleLogger.log.org.apache.maven.wagon.providers.http.httpclient.wire=trace
```

> [!warning]
> 当你设置这些选项时，所有网络请求都会被记录，并产生大量输出。

<a id="verify-your-maven-settings"></a>

### 验证你的 Maven 设置

如果在 CI/CD 中遇到与 `settings.xml` 文件相关的问题，请尝试添加一个额外的脚本任务或作业来 [验证生效的设置](https://maven.apache.org/plugins/maven-help-plugin/effective-settings-mojo.html)。

帮助插件也可以提供 [系统属性](https://maven.apache.org/plugins/maven-help-plugin/system-mojo.html)，包括环境变量：

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

这通常表示认证问题。请检查：

- 你的认证令牌有效且未过期。
- 你使用了正确的令牌类型（个人访问令牌、部署令牌或 CI 作业令牌）。
- 令牌具有必要的权限（`api`、`read_api` 或 `read_repository`）。
- 对于 Maven 项目，你在 `mvn` 命令中使用了 `-s` 选项（例如 `mvn deploy -s settings.xml`）。如果不使用此选项，Maven 不会应用 `settings.xml` 文件中的认证设置，从而导致未经授权的错误。

<a id="400-bad-request-error-with-message-validation-failed-version-is-invalid"></a>

### `400 Bad Request` 错误，提示 "Validation failed: Version is invalid"

极狐GitLab 对版本字符串有特定要求。请确保你的版本遵循以下格式：

```plaintext
^(?!.*\.\.)(?!.*\.$)[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*(\+[0-9A-Za-z-]+)?$
```

例如，"1.0.0"、"1.0-SNAPSHOT" 和 "1.0.0-alpha" 是有效的，但 "1..0" 或 "1.0." 无效。

<a id="403-forbidden-error-when-trying-to-publish-a-package"></a>

### 尝试发布软件包时出现 `403 Forbidden` 错误

返回 `403 Forbidden` 错误并附带消息 `Authorization failed` 通常表示认证或权限问题。请检查：

- 你使用了正确的令牌类型（个人访问令牌、部署令牌或 CI/CD 作业令牌）。更多信息，请参见 [认证到软件包仓库](#authenticate-to-the-package-registry)。
- 令牌具有必要的权限。只有具有开发者、维护者或所有者角色的用户才能发布软件包。更多信息，请参见 [极狐GitLab 权限](../../permissions.md#project-packages-and-registries)。
- 你要发布的软件包没有受到推送保护规则的保护。有关软件包保护规则的更多信息，请参见 [如何保护软件包](../package_registry/package_protection_rules.md#protect-a-package)。

<a id="artifact-already-exists-errors-when-publishing"></a>

### 发布时出现 `Artifact already exists` 错误

当你尝试发布一个已存在的软件包版本时会出现此错误。解决方法：

- 在发布前递增你的软件包版本。
- 如果你使用的是 SNAPSHOT 版本，请确保在配置中允许 SNAPSHOT 覆盖。

<a id="published-package-not-appearing-in-the-ui"></a>

### 已发布的软件包未在 UI 中显示

如果你刚刚发布了一个软件包，可能需要等待一段时间才会显示。如果仍然无法显示：

- 验证你是否具有查看软件包所需的权限。
- 通过查看 CI/CD 日志或 Maven 输出，检查软件包是否成功发布。
- 确保你查看的是正确的项目或群组。

<a id="maven-repository-dependency-conflicts"></a>

### Maven 仓库依赖冲突

依赖冲突可以通过以下方式解决：

- 在你的 `pom.xml` 中明确定义版本。
- 使用 Maven 的依赖管理部分来控制版本。
- 使用 `<exclusions>` 标签来排除冲突的传递性依赖。

<a id="unable-to-find-valid-certification-path-to-requested-target-error"></a>

### `Unable to find valid certification path to requested target` 错误

这通常是 SSL 证书问题。解决方法：

- 确保你的 JDK 信任极狐GitLab 服务器的 SSL 证书。
- 如果使用自签名证书，请将其添加到 JDK 的信任库中。
- 作为最后的手段，你可以在 Maven 设置中禁用 SSL 验证。不建议在生产环境中使用。

<a id="no-plugin-found-for-prefix-pipeline-errors"></a>

### `No plugin found for prefix` 流水线错误

这通常意味着 Maven 无法找到该插件。解决方法：

- 确保在 `pom.xml` 中正确定义了该插件。
- 检查你的 CI/CD 配置是否使用了正确的 Maven 设置文件。
- 验证你的流水线是否有权限访问所有必要的仓库。