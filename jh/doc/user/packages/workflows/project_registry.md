---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用专用、特定类型的仓库管理软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在顶级的制品管理群组中，通过专用项目按类型组织您的软件包。这种方式提供了清晰的所有权归属和特定类型的策略。

当您有以下需求时，可以使用此方法：

- 通过专用策略和设置按类型组织软件包。
- 为所有组织软件包提供单一的消费端点。
- 将软件包从第三方仓库迁移到结构化的极狐GitLab 设置中。
- 将软件包管理问题与应用程序源代码分离。
- 对不同的软件包类型应用不同的治理策略。
- 在保持清晰所有权的同时，实现组织范围内的访问。

<a id="example-walkthrough"></a>

## 示例演示

为了有效地通过此方法组织和管理您的软件包，您应该：

- 为制品管理创建一个专用的顶级群组，其中包含按软件包类型组织的项目。
- 将顶级群组限制为仅包含制品项目，以提高消费软件包时的性能。

<a id="recommended-structure"></a>

### 推荐结构

以下示例概述了您应该如何构建顶级群组和项目：

```plaintext
company_namespace/artifact_management/ # 顶级群组
├── java-packages/           # Maven 软件包
├── node-packages/           # npm 软件包
├── python-packages/         # PyPI 软件包
├── docker-images/           # 容器镜像仓库
├── terraform-modules/       # Terraform 模块
├── nuget-packages/          # NuGet 软件包
└── generic-packages/        # 通用文件软件包
```

> [!note]
> 一些组织倾向于根据软件包的生命周期或稳定性进行额外的分离。例如，您可以为 `java-releases/` 和 `java-snapshots/` 创建单独的项目。这样，您就可以为稳定版软件包和开发版软件包应用不同的清理策略、访问控制或审批工作流。

<a id="create-the-group-and-projects"></a>

### 创建群组和项目

为制品管理创建一个新的顶级群组：

1. 在顶部栏中，选择 **创建新...** ({{< icon name="plus" >}}) 和 **新建群组**。
1. 选择 **创建群组**。
1. 在 **群组名称** 文本框中，输入 `Artifact Management` 或类似名称。
1. 在 **群组 URL** 中，保留生成的路径。
1. 选择群组的[**可见性级别**](../../public_access.md)。
1. 选择 **创建群组**。

为您需要的每种软件包类型创建项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的制品管理群组。
1. 在左侧边栏中，选择 **创建新...** ({{< icon name="plus" >}}) 和 **新建项目/代码仓**。
1. 选择 **创建空白项目**。
1. 为您所需的软件包类型输入 **项目名称**。例如，`java-packages` 或 `node-packages`。
1. 设置适当的可见性级别。
1. 选择 **创建项目**。

从您组织最常用的软件包类型开始，然后在采用其他软件包格式时扩展此结构。这种方法可以自然扩展，同时保持安全性和易用性。

配置群组设置：

1. 在您的制品管理群组中，在左侧边栏中选择 **设置** > **软件包与镜像库**。
1. 配置您需要的任何群组策略，如 **重复软件包** 或 **软件包转发**。
1. 根据需要设置群组访问控制。

<a id="configure-authentication-and-access"></a>

## 配置认证和访问

认证方式因您的用例而异。请参考以下建议。有关认证的更多信息，请参见[使用仓库进行认证](../package_registry/supported_functionality.md#authenticate-with-the-registry)

对于本地开发（开发者）：

- 面向个人开发者的个人访问令牌
- 用于共享团队凭据的群组访问令牌

对于 CI/CD 流水线：

- CI/CD 作业令牌（首选）- 自动认证
- 用于特殊场景的项目访问令牌

对于外部系统：

- 用于只读消费的部署令牌
- 用于更精细控制的项目和群组访问令牌

<a id="set-up-top-level-group-access"></a>

### 设置顶级群组访问权限

创建一个群组部署令牌，用于组织范围内的软件包消费：

1. 在您的制品管理群组中，在左侧边栏中选择 **设置** > **代码仓**。
1. 展开 **部署令牌**。
1. 选择 **添加令牌** 并完成以下字段：
   - 对于 **名称**，输入 `package-consumption`。
   - 对于 **范围**，选择 `read_package_registry`。
1. 选择 **创建部署令牌**。

安全地保存令牌。

如果您想使用 CI/CD 作业令牌进行发布，请配置作业令牌允许列表：

1. 在每个特定于软件包类型的项目中，在左侧边栏中选择 **设置** > **CI/CD**。
1. 展开 **令牌访问**。
1. 添加允许将软件包发布到此软件包仓库的项目。

<a id="configure-project-settings"></a>

### 配置项目设置

对于每个特定于软件包类型的项目，配置：

- 适用于该软件包类型的 **生命周期策略**
- **受保护的软件包** 规则（如果需要）
- **受保护的容器标签** 规则（如果需要）
- 用于特定用例的 **项目访问令牌**

<a id="publish-packages"></a>

## 发布软件包

团队应将软件包发布到相应的特定类型的项目仓库。有关每种支持的软件包格式，请参见以下示例。

{{< tabs >}}

{{< tab title="Maven" >}}

配置您项目的 `pom.xml` 以便发布到 `java-packages` 项目：

```xml
<distributionManagement>
    <repository>
        <id>gitlab-maven</id>
        <url>${CI_API_V4_URL}/projects/JAVA_PACKAGES_PROJECT_ID/packages/maven</url>
    </repository>
    <snapshotRepository>
        <id>gitlab-maven</id>
        <url>${CI_API_V4_URL}/projects/JAVA_PACKAGES_PROJECT_ID/packages/maven</url>
    </snapshotRepository>
</distributionManagement>
```

在您的 `settings.xml` 中配置认证：

```xml
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
```

使用以下命令发布：

```shell
mvn deploy
```

{{< /tab >}}

{{< tab title="npm" >}}

配置您项目的 `package.json`：

```json
{
  "name": "@company/my-package",
  "publishConfig": {
    "registry": "${CI_API_V4_URL}/projects/NODE_PACKAGES_PROJECT_ID/packages/npm/"
  }
}
```

对于 CI/CD 发布，作业令牌会自动使用：

```yaml
publish:
  script:
    - npm publish
```

对于本地发布，请配置认证：

```shell
npm config set @company:registry https://gitlab.example.com/api/v4/projects/NODE_PACKAGES_PROJECT_ID/packages/npm/
npm config set //gitlab.example.com/api/v4/projects/NODE_PACKAGES_PROJECT_ID/packages/npm/:_authToken ${PERSONAL_ACCESS_TOKEN}
```

{{< /tab >}}

{{< tab title="PyPI" >}}

在您的 CI/CD 流水线中配置发布：

```yaml
publish:
  script:
    - pip install build twine
    - python -m build
    - TWINE_PASSWORD=${CI_JOB_TOKEN} TWINE_USERNAME=gitlab-ci-token twine upload --repository-url ${CI_API_V4_URL}/projects/PYTHON_PACKAGES_PROJECT_ID/packages/pypi dist/*
```

对于本地发布：

```shell
twine upload --repository-url https://gitlab.example.com/api/v4/projects/PYTHON_PACKAGES_PROJECT_ID/packages/pypi --username __token__ --password ${PERSONAL_ACCESS_TOKEN} dist/*
```

{{< /tab >}}

{{< tab title="容器镜像仓库" >}}

构建并推送 Docker 镜像：

```yaml
build-image:
  script:
    - docker build -t $CI_REGISTRY/artifact-management/docker-images/my-app:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY/artifact-management/docker-images/my-app:$CI_COMMIT_SHA
```

对于本地开发：

```shell
docker login gitlab.example.com -u ${USERNAME} -p ${PERSONAL_ACCESS_TOKEN}
docker push gitlab.example.com/artifact-management/docker-images/my-app:latest
```

{{< /tab >}}

{{< tab title="Terraform" >}}

发布 Terraform 模块：

```yaml
publish-module:
  script:
    - tar -czf module.tar.gz *.tf
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file module.tar.gz "${CI_API_V4_URL}/projects/TERRAFORM_PACKAGES_PROJECT_ID/packages/terraform/modules/my-module/my-provider/1.0.0/file"'
```

{{< /tab >}}

{{< tab title="NuGet" >}}

在您的项目文件或 CI/CD 流水线中配置发布：

```yaml
publish:
  script:
    - dotnet pack
    - dotnet nuget push "bin/Release/*.nupkg" --source ${CI_API_V4_URL}/projects/NUGET_PACKAGES_PROJECT_ID/packages/nuget/index.json --api-key ${CI_JOB_TOKEN}
```

对于本地发布：

```shell
dotnet nuget push package.nupkg --source https://gitlab.example.com/api/v4/projects/NUGET_PACKAGES_PROJECT_ID/packages/nuget/index.json --api-key ${PERSONAL_ACCESS_TOKEN}
```

{{< /tab >}}

{{< tab title="Generic" >}}

上传通用软件包：

```yaml
upload-package:
  script:
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file my-package.zip "${CI_API_V4_URL}/projects/GENERIC_PACKAGES_PROJECT_ID/packages/generic/my-package/1.0.0/my-package.zip"'
```

{{< /tab >}}

{{< /tabs >}}

<a id="consume-packages"></a>

## 消费软件包

对于软件包消费，您可以：

- 使用 Maven 虚拟仓库。
- 使用顶级群组端点。

<a id="using-the-maven-virtual-registry-beta"></a>

### 使用 Maven 虚拟仓库（测试版）

Maven 虚拟仓库可以通过聚合来自多个来源的软件包来增强您的制品管理设置。您可以：

- 通过将 Maven 的顶级群组端点作为上游来添加内部软件包（例如，`https://gitlab.example.com/api/v4/groups/artifact-management/-/packages/maven`）。
- 添加外部上游仓库，如 Maven Central 或私有仓库。
- 添加其他极狐GitLab 项目或群组。

此方法提供了一个单一的端点，该端点结合了内部和外部依赖项，并具有智能缓存和上游优先级排序功能。

当您有以下需求时，可以使用 Maven 虚拟仓库：

- 需要将内部极狐GitLab 软件包与外部上游仓库聚合
- 希望缓存外部依赖项以提高可靠性
- 需要将私有仓库优先于公共仓库
- 想要一个同时处理内部和外部依赖项的单一端点

Maven 虚拟仓库不支持发布。

更多信息，请参见[Maven 虚拟仓库](../virtual_registry/maven/_index.md)。

<a id="configure-the-maven-virtual-registry-within-a-top-level-artifact-management-group"></a>

#### 在顶级制品管理群组内配置 Maven 虚拟仓库

1. 在顶级群组中创建虚拟仓库：
   - 在您的 `artifact-management` 群组中，转到 **部署** > **虚拟仓库**。
   - 创建一个 Maven 虚拟仓库（例如，“Company Maven Registry”）。
1. 配置上游仓库：
   - 将您的内部 `java-packages` 项目添加为上游。
   - 添加外部仓库，如 Maven Central 或私有仓库。
   - 对上游进行排序，将私有仓库放在最前面，公共仓库放在最后面。
1. 配置 Maven 客户端以使用虚拟仓库：

```xml
   <mirrors>
     <mirror>
       <id>central-proxy</id>
       <name>极狐GitLab 虚拟仓库</name>
       <url>https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id></url>
       <mirrorOf>central</mirrorOf>
     </mirror>
   </mirrors>
```

虚拟仓库支持多种令牌类型，包括个人访问令牌、群组部署令牌、群组访问令牌和 CI/CD 作业令牌。每种令牌类型使用不同的 HTTP 头名称。更多信息，请参见[向虚拟仓库认证](../virtual_registry/_index.md#authenticate-to-the-virtual-registry)。

以下示例实现了个人访问令牌：

```xml
   <servers>
     <server>
       <id>gitlab-maven</id>
       <configuration>
         <httpHeaders>
           <property>
             <name>Private-Token</name>
             <value>${PERSONAL_ACCESS_TOKEN}</value>
           </property>
         </httpHeaders>
       </configuration>
     </server>
   </servers>
```

<a id="configure-a-top-level-group-endpoint"></a>

### 配置顶级群组端点

配置您的项目以从顶级群组端点消费软件包。此方法通过单一配置提供对所有软件包类型的访问：

{{< tabs >}}

{{< tab title="Maven" >}}

配置您的 `pom.xml` 以从群组仓库消费：

```xml
<repositories>
    <repository>
        <id>gitlab-maven</id>
        <url>https://gitlab.example.com/api/v4/groups/artifact-management/-/packages/maven</url>
    </repository>
</repositories>
```

在您的 `settings.xml` 中配置认证：

```xml
<settings>
    <servers>
        <server>
            <id>gitlab-maven</id>
            <username>deploy-token-username</username>
            <password>deploy-token-password</password>
        </server>
    </servers>
</settings>
```

{{< /tab >}}

{{< tab title="npm" >}}

配置您的 `.npmrc` 文件：

```ini
@company:registry=https://gitlab.example.com/api/v4/groups/artifact-management/-/packages/npm/
//gitlab.example.com/api/v4/groups/artifact-management/-/packages/npm/:_authToken=${DEPLOY_TOKEN}
```

{{< /tab >}}

{{< tab title="PyPI" >}}

配置 `pip` 以使用群组仓库：

```ini
# pip.conf 或 ~/.pip/pip.conf
[global]
extra-index-url = https://deploy-token-username:deploy-token-password@gitlab.example.com/api/v4/groups/artifact-management/-/packages/pypi/simple/
```

或使用环境变量：

```shell
pip install --index-url https://deploy-token-username:deploy-token-password@gitlab.example.com/api/v4/groups/artifact-management/-/packages/pypi/simple/ --no-index my-package
```

{{< /tab >}}

{{< tab title="容器镜像仓库" >}}

从群组仓库拉取镜像：

```shell
docker login gitlab.example.com -u deploy-token-username -p deploy-token-password
docker pull gitlab.example.com/artifact-management/docker-images/my-app:latest
```

{{< /tab >}}

{{< tab title="Terraform" >}}

使用环境变量配置 Terraform 以使用极狐GitLab 凭据：

```shell
export TF_TOKEN_gitlab_example_com="deploy-token-password"
```

然后在您的 Terraform 配置中引用模块：

```hcl
module "example" {
  source = "gitlab.example.com/artifact-management/terraform-modules//my-module"
  version = "1.0.0"
}
```

或使用项目特定的 URL：

```hcl
module "example" {
  source = "https://gitlab.example.com/api/v4/projects/TERRAFORM_PACKAGES_PROJECT_ID/packages/terraform/modules/my-module/my-provider/1.0.0"
}
```

{{< /tab >}}

{{< tab title="NuGet" >}}

配置 NuGet 以使用群组仓库：

```xml
<!-- nuget.config -->
<configuration>
  <packageSources>
    <add key="GitLab" value="https://gitlab.example.com/api/v4/groups/artifact-management/-/packages/nuget/index.json" />
  </packageSources>
  <packageSourceCredentials>
    <GitLab>
      <add key="Username" value="deploy-token-username" />
      <add key="ClearTextPassword" value="deploy-token-password" />
    </GitLab>
  </packageSourceCredentials>
</configuration>
```

{{< /tab >}}

{{< tab title="Generic" >}}

下载通用软件包：

```shell
curl --header "DEPLOY-TOKEN: ${DEPLOY_TOKEN}" "https://gitlab.example.com/api/v4/groups/artifact-management/-/packages/generic/my-package/1.0.0/my-package.zip" --output my-package.zip
```

{{< /tab >}}

{{< /tabs >}}

<a id="example-cicd-configuration"></a>

## 示例 CI/CD 配置

以下示例向您展示了一个项目可能如何消费来自多种软件包类型的软件包：

```yaml
stages:
  - build
  - test

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=${CI_PROJECT_DIR}/.m2/repository"

before_script:
  # 配置 npm 仓库
  - echo "@company:registry=${CI_API_V4_URL}/groups/artifact-management/-/packages/npm/" >> .npmrc
  - echo "//${CI_SERVER_HOST}/api/v4/groups/artifact-management/-/packages/npm/:_authToken=${CI_JOB_TOKEN}" >> .npmrc

build:
  stage: build
  script:
    # 从群组仓库安装 npm 依赖项
    - npm install
    # 使用来自群组仓库的 Maven 依赖项进行构建
    - mvn compile
  cache:
    paths:
      - .m2/repository/
      - node_modules/
```

<a id="publish-alongside-source-code"></a>

## 与源代码一起发布

一些组织更喜欢在应用程序源代码旁发布软件包，如[企业规模教程](../package_registry/enterprise_structure_tutorial.md)中所述。这种方法在以下情况下运作良好：

- 软件包与特定应用程序紧密耦合。
- 您希望软件包所有权与源代码所有权保持一致。
- 团队同时管理代码和软件包。

制品管理方法在以下情况下效果更佳：

- 您想要简化的软件包治理。
- 软件包在多个项目之间共享。
- 您需要特定类型的策略和控制。
- 您正在从传统的制品仓库迁移。

从您组织最常用的软件包类型开始，然后在采用其他软件包格式时扩展此结构。这种方法可以自然扩展，同时保持安全性和易用性。