---
stage: Package
group: Package Registry
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：为满足企业规模需求构建软件包仓库结构'
---

随着组织的发展，软件包管理可能会变得越来越复杂。极狐GitLab 软件包仓库模型为企业软件包管理提供了强大的解决方案。了解如何利用软件包仓库，对于安全、简单且大规模地使用软件包至关重要。

在本教程中，您将学习如何将极狐GitLab 软件包仓库模型融入企业群组结构。虽然此处提供的示例特定于 Maven 和 npm 软件包，但您可以将本教程的概念扩展到极狐GitLab 软件包仓库支持的任何软件包。

完成本教程后，您将了解如何：

1. [设置单个根群组或顶级群组来组织您的工作](#create-an-enterprise-structure)。
1. [为发布软件包配置项目并明确归属](#set-up-a-top-level-group)。
1. [设置通过顶级群组使用软件包，以简化访问](#publish-packages)。
1. [添加部署令牌，以便您的团队访问组织的软件包](#add-deploy-tokens)。
1. [配置 CI/CD 以安全地使用您的软件包](#use-packages-with-cicd)。

<a id="before-you-begin"></a>

## 开始之前

完成本教程需要以下内容：

- 一个 npm 或 Maven 软件包。
- 熟悉极狐GitLab 软件包仓库。
- 一个测试项目。您可以使用现有项目，或为本教程创建一个项目。

<a id="understand-the-gitlab-package-registry"></a>

## 了解极狐GitLab 软件包仓库

JFrog Artifactory 和 Sonatype Nexus 等传统软件包管理器使用单一的集中式仓库来存储和更新您的软件包。使用极狐GitLab，您可以直接在群组或项目中管理软件包。这意味着：

- 团队将软件包发布到存储代码的项目中。
- 团队从根群组仓库使用软件包，这些仓库会聚合其下的所有软件包。
- 访问控制继承自您现有的极狐GitLab 权限。

由于您的软件包像代码一样被存储和管理，您可以将软件包管理添加到现有项目或群组中。此模型具有多项优势：

- 软件包与其源代码一起具有明确的归属
- 无需额外配置即可实现精细的访问控制
- 简化的 CI/CD 集成
- 与团队结构自然契合
- 通过根群组使用软件包，使用单个 URL 即可访问公司的所有软件包

<a id="create-an-enterprise-structure"></a>

## 创建企业结构

考虑将您的代码组织在单个顶级群组下。例如：

```plaintext
company/ (top-level group)
├── retail-division/
│   ├── shared-libraries/    # Division-specific shared code
│   └── teams/
│       ├── checkout/        # Team publishes packages here
│       └── inventory/       # Team publishes packages here
├── banking-division/
│   ├── shared-libraries/    # Division-specific shared code
│   └── teams/
│       ├── payments/        # Team publishes packages here
│       └── fraud/           # Team publishes packages here
└── shared-platform/         # Enterprise-wide shared code
    ├── java-commons/        # Shared Java libraries
    └── ui-components/       # Shared UI components
```

在此结构中，公司中的所有团队都将代码和软件包发布到各自的项目中，同时继承顶级 `company/` 群组的配置。

<a id="set-up-a-top-level-group"></a>

## 设置顶级群组

如果您已有顶级群组，并且拥有所有者角色，则可以使用该群组。

如果您没有群组，请创建一个：

1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建群组**。
1. 在**群组名称**中，输入群组的名称。
1. 在**群组 URL**中，输入群组的路径，该路径将用作命名空间。
1. 选择[可见性级别](../../public_access.md)。
1. 可选。填写信息以个性化您的体验。
1. 选择**创建群组**。

此群组将存储您组织中的其他群组和项目。如果您有其他项目和群组，可以将它们[转移到新的顶级群组](../../group/manage.md#transfer-a-group)进行管理。

在继续之前，请确保您至少拥有：

- 一个顶级群组。
- 一个属于该顶级群组或其某个子群组的项目。

<a id="publish-packages"></a>

## 发布软件包

为保持明确的归属，团队应将软件包发布到各自的软件包仓库。这样可以将软件包与其源代码放在一起，并确保版本历史与项目活动相关联。

{{< tabs >}}

{{< tab title="Maven projects" >}}

发布 Maven 软件包：

- 配置您的 `pom.xml` 文件，以发布到项目的软件包仓库：

  ```xml
  <!-- checkout/pom.xml -->
  <distributionManagement>
      <repository>
          <id>gitlab-maven</id>
          <url>${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/maven</url>
      </repository>
  </distributionManagement>
  ```

{{< /tab >}}

{{< tab title="npm projects" >}}

发布 npm 软件包：

- 配置您的 `package.json` 文件：

  ```json
  // ui-components/package.json
  {
    "name": "@company/ui-components",
    "publishConfig": {
      "registry": "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/npm/"
    }
  }
  ```

{{< /tab >}}

{{< /tabs >}}

<a id="consume-packages"></a>

## 使用软件包

由于您的项目组织在单个顶级群组下，您的软件包仍可供整个组织访问。接下来，配置一个 API 端点，供您的团队使用软件包。

{{< tabs >}}

{{< tab title="Maven projects" >}}

- 配置您的 `pom.xml`，以从顶级群组访问软件包：

  ```xml
  <!-- Any project's pom.xml -->
  <repositories>
      <repository>
          <id>gitlab-maven</id>
          <url>https://gitlab.example.com/api/v4/groups/company/-/packages/maven</url>
      </repository>
  </repositories>
  ```

{{< /tab >}}

{{< tab title="npm projects" >}}

- 配置您的 `.npmrc` 文件：

  ```shell
  # Any project's .npmrc
  @company:registry=https://gitlab.example.com/api/v4/groups/company/-/packages/npm/
  ```

{{< /tab >}}

{{< /tabs >}}

此配置会自动提供对组织中所有软件包的访问权限，同时保留基于项目发布的优势。

<a id="add-deploy-tokens"></a>

## 添加部署令牌

接下来，添加一个只读部署令牌。此令牌提供对存储在组织子群组和项目中的软件包的访问权限，以便您的团队可以将其用于开发。

1. 在您的顶级群组中，在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署令牌**。
1. 选择**添加令牌**。
1. 填写字段，并将作用域设置为 `read_repository`。
1. 选择**创建部署令牌**。

您可以根据需要向顶级群组添加任意数量的部署令牌。请记得定期轮换令牌。如果您怀疑某个令牌已泄露，请立即撤销并替换它。

<a id="use-packages-with-cicd"></a>

## 将软件包与 CI/CD 结合使用

当 CI/CD 作业需要访问软件包仓库时，它们会使用预定义的 CI/CD 变量 `CI_JOB_TOKEN` 进行身份验证。此身份验证会自动进行，因此您无需进行任何额外配置：

```yaml
publish:
  script:
    - mvn deploy  # For Maven packages
    # or
    - npm publish # For npm packages
  # CI_JOB_TOKEN provides automatic authentication
```

<a id="summary-and-next-steps"></a>

## 总结和后续步骤

将您的极狐GitLab 项目组织在一个顶级群组下可带来多项优势：

- 简化的配置：
  - 所有软件包访问使用一个 URL
  - 各团队之间设置一致
  - 轻松轮换令牌
- 明确的归属：
  - 软件包与其源代码放在一起
  - 团队保持对发布的控制
  - 版本历史与项目活动相关联
- 自然的组织方式：
  - 您的群组与公司结构相匹配
  - 团队可以在保持自主的同时进行协作

极狐GitLab 软件包仓库模型为企业软件包管理提供了强大的解决方案。结合基于项目的软件包发布与基于顶级群组的软件包使用，您可以兼得两者的优势：明确的归属和简化的访问。

此方法可随您的组织自然扩展，同时保持安全性和易用性。您可以先在单个团队或部门中实施此模型，并在看到这种集成方法的优势后逐步扩展。请记住，虽然本教程侧重于 Maven 和 npm，但相同的原则适用于极狐GitLab 支持的所有软件包类型。
