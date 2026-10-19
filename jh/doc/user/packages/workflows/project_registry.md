---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用专用且按类型划分的仓库管理软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在顶级制品管理群组内的专用项目中，按类型组织您的软件包。这种方式可提供清晰的归属关系和按类型划分的策略。

在以下情况下使用这种方式：

- 按类型组织软件包，并使用专用的策略和设置。
- 为所有组织级软件包提供单一的消费端点。
- 将软件包从第三方仓库迁移到结构化的极狐GitLab 设置中。
- 将软件包管理关注点与应用源代码分离。
- 对不同的软件包类型应用不同的治理策略。
- 在保持清晰归属关系的同时，实现组织范围的访问。

<a id="example-walkthrough"></a>

## 示例演练

要使用这种方式有效地组织和管理您的软件包，您应该：

- 创建一个专用的顶级群组用于制品
  管理，并按软件包类型组织项目。
- 将顶级群组限制为仅包含带有
  制品的项目，以提高消费软件包时的性能。

<a id="recommended-structure"></a>

### 推荐结构

以下示例概述了您应如何组织顶级群组和项目：

```plaintext
company_namespace/artifact_management/ # top-level group
├── java-packages/           # Maven packages
├── node-packages/           # npm packages
├── python-packages/         # PyPI packages
├── docker-images/           # Container registry
├── terraform-modules/       # Terraform modules
├── nuget-packages/          # NuGet packages
└── generic-packages/        # Generic file packages
```

> [!note]
> 有些组织倾向于根据软件包生命周期或稳定性进行额外分离。例如，您可以为 `java-releases/` 和 `java-snapshots/` 创建单独的项目。这样，您就可以为稳定版软件包和开发版软件包应用不同的清理策略、访问控制或审批工作流。

<a id="create-the-group-and-projects"></a>

### 创建群组和项目

创建一个新的顶级群组用于制品管理：

1. 在顶部栏中，选择**创建新的**（{{< icon name="plus" >}}）和**新建群组**。
1. 选择**创建群组**。
1. 在**群组名称**文本框中，输入 `Artifact Management` 或类似名称。
1. 在**群组 URL**中，保留生成的路径。
1. 选择该群组的[**可见性级别**](../../public_access.md)。
1. 选择**创建群组**。

为您需要的每种软件包类型创建项目：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的制品管理群组。
1. 在左侧边栏中，选择**创建新的**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**创建空白项目**。
1. 为您所需的软件包类型输入**项目名称**。例如，`java-packages` 或 `node-packages`。
1. 设置适当的可见性级别。
1. 选择**创建项目**。

从您组织使用最多的软件包类型开始，然后在采用其他软件包格式时扩展该结构。这种方式可自然扩展，同时保持安全性和易用性。

配置群组设置：

1. 在您的制品管理群组中，在左侧边栏中，选择**设置** > **软件包与镜像库**。
1. 配置您需要的任何群组策略，例如**重复软件包**或**软件包转发**。
1. 根据需要设置群组访问控制。

<a id="configure-authentication-and-access"></a>

## 配置身份验证和访问

身份验证因您的使用场景而异。请参阅以下建议。有关身份验证的更多信息，请参阅[向仓库进行身份验证](../package_registry/supported_functionality.md#authenticate-with-the-registry)

对于本地开发（开发者）：

- 个人访问令牌，适用于单个开发者
- 群组访问令牌，适用于共享的团队凭据

对于 CI/CD 流水线：

- CI/CD 作业令牌（首选）- 自动身份验证
- 项目访问令牌，适用于特殊情况

对于外部系统：

- 部署令牌，用于只读消费
- 项目和群组访问令牌，用于更精细的控制

<a id="set-up-top-level-group-access"></a>

### 设置顶级群组访问

创建一个群组部署令牌，用于组织范围的软件包消费：

1. 在您的制品管理群组中，在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署令牌**。
1. 选择**添加令牌**并填写字段：
   - 对于**名称**，输入 `package-consumption`。
   - 对于**范围（至少选择一个）**，选择 `read_package_registry`。
1. 选择**创建部署令牌**。

请安全保存该令牌。

如果您想使用 CI/CD 作业令牌进行发布，请配置作业令牌允许名单：

1. 在每个特定于软件包的项目中，在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**令牌访问**。
1. 添加应被允许向此软件包仓库发布软件包的项目。

<a id="configure-project-settings"></a>

### 配置项目设置

对于每个软件包类型项目，配置：

- 适合该软件包类型的**生命周期策略**
- **受保护软件包**规则（如需要）
- **受保护容器标签**规则（如需要）
- 用于特定使用场景的**项目访问令牌**

<a id="publish-packages"></a>

## 发布软件包

团队应将软件包发布到相应的按类型划分的项目仓库。请参阅以下针对每种受支持软件包格式的示例。

{{< tabs >}}

{{< tab title="Maven" >}}

配置您项目的 `pom.xml` 以发布到 `java-packages` 项目：

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

在您的 `settings.xml`中配置身份验证：

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

对于 CI/CD 发布，会自动使用作业令牌：

```yaml
publish:
  script:
    - npm publish
```

对于本地发布，请配置身份验证：

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

{{< tab title="Container registry" >}}

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

- 通过将您的顶级群组 Maven 端点用作上游，添加内部软件包。
  例如，`https://gitlab.example.com/api/v4/groups/artifact-management/-/packages/maven`。
- 添加外部上游仓库，例如 Maven Central 或私有仓库。
- 添加其他极狐GitLab 项目或群组。

这种方式提供一个单一端点，将内部和外部依赖项与智能缓存和上游优先级相结合。

在以下情况下使用 Maven 虚拟仓库：

- 需要将内部极狐GitLab 软件包与外部上游仓库聚合
- 希望缓存外部依赖项以提高可靠性
- 需要优先使用私有仓库而非公共仓库
- 希望使用一个单一端点处理内部和外部依赖项

Maven 虚拟仓库不支持发布。

有关更多信息，请参阅 [Maven 虚拟仓库](../virtual_registry/maven/_index.md)。

<a id="configure-the-maven-virtual-registry-within-a-top-level-artifact-management-group"></a>

#### 在顶级制品管理群组中配置 Maven 虚拟仓库

1. 在顶级群组中创建虚拟仓库：
   - 在您的 `artifact-management` 群组中，转到**部署** > **虚拟仓库**。
   - 创建一个 Maven 虚拟仓库（例如，“Company Maven Registry”）。
1. 配置上游仓库：
   - 将您的内部 `java-packages` 项目添加为上游。
   - 添加外部仓库，例如 Maven Central 或私有仓库。
   - 将上游排序为私有仓库在前，公共仓库在后。
1. 配置 Maven 客户端以使用该虚拟仓库：

```xml
   <mirrors>
     <mirror>
       <id>central-proxy</id>
       <name>GitLab virtual registry</name>
       <url>https://gitlab.example.com/api/v4/virtual_registries/packages/maven/<registry_id></url>
       <mirrorOf>central</mirrorOf>
     </mirror>
   </mirrors>
```

虚拟仓库支持多种令牌类型，包括个人访问令牌、群组部署令牌、群组访问令牌和 CI/CD 作业令牌。每种令牌类型使用不同的 HTTP 请求头名称。有关更多信息，请参阅[向虚拟仓库进行身份验证](../virtual_registry/_index.md#authenticate-to-the-virtual-registry)。

以下示例实现个人访问令牌：

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

配置您的项目以从顶级群组端点消费软件包。这种方式通过单一配置提供对所有软件包类型的访问：

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

在您的 `settings.xml`中配置身份验证：

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
# pip.conf or ~/.pip/pip.conf
[global]
extra-index-url = https://deploy-token-username:deploy-token-password@gitlab.example.com/api/v4/groups/artifact-management/-/packages/pypi/simple/
```

或使用环境变量：

```shell
pip install --index-url https://deploy-token-username:deploy-token-password@gitlab.example.com/api/v4/groups/artifact-management/-/packages/pypi/simple/ --no-index my-package
```

{{< /tab >}}

{{< tab title="Container Registry" >}}

从群组仓库拉取镜像：

```shell
docker login gitlab.example.com -u deploy-token-username -p deploy-token-password
docker pull gitlab.example.com/artifact-management/docker-images/my-app:latest
```

{{< /tab >}}

{{< tab title="Terraform" >}}

配置 Terraform 以通过环境变量使用极狐GitLab 凭据：

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

或使用特定于项目的 URL：

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

以下示例展示了项目如何从多种软件包类型消费软件包：

```yaml
stages:
  - build
  - test

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=${CI_PROJECT_DIR}/.m2/repository"

before_script:
  # Configure npm registry
  - echo "@company:registry=${CI_API_V4_URL}/groups/artifact-management/-/packages/npm/" >> .npmrc
  - echo "//${CI_SERVER_HOST}/api/v4/groups/artifact-management/-/packages/npm/:_authToken=${CI_JOB_TOKEN}" >> .npmrc

build:
  stage: build
  script:
    # Install npm dependencies from group registry
    - npm install
    # Build with Maven dependencies from group registry
    - mvn compile
  cache:
    paths:
      - .m2/repository/
      - node_modules/
```

<a id="publish-alongside-source-code"></a>

## 与源代码一起发布

有些组织倾向于将软件包与其应用源代码一起发布，如[企业规模教程](../package_registry/enterprise_structure_tutorial.md)中所述。这种方式在以下情况下效果良好：

- 软件包与特定应用紧密耦合。
- 您希望软件包归属关系与源代码归属关系保持一致。
- 团队同时管理代码和软件包。

制品管理方式在以下情况下效果更好：

- 您希望简化软件包治理。
- 软件包在多个项目之间共享。
- 您需要按类型划分的策略和控制。
- 您正在从传统制品仓库迁移。

从您组织使用最多的软件包类型开始，然后在采用其他软件包格式时扩展该结构。这种方式可自然扩展，同时保持安全性和易用性。
