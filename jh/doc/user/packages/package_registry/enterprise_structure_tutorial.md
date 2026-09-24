---
stage: Package
group: Package Registry
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: 教程：为企业级规模构建软件包仓库结构
---

随着组织发展，软件包管理会变得越来越复杂。
极狐GitLab 软件包仓库模型为企业级软件包管理提供了强大的解决方案。
了解如何利用软件包仓库，对于安全、简单且大规模地操作软件包至关重要。

在本教程中，你将学习如何将极狐GitLab 软件包仓库模型融入企业群组结构中。虽然此处提供的示例仅针对 Maven 和 npm 软件包，但你也可以将本教程的概念扩展到极狐GitLab 软件包仓库支持的任何软件包类型。

完成本教程后，你将掌握以下技能：

1. [建立单一根群组或顶级群组来组织工作](#create-an-enterprise-structure)。
1. [配置项目以发布具有明确所有权的软件包](#set-up-a-top-level-group)。
1. [设置顶级群组软件包消费以实现简化访问](#publish-packages)。
1. [添加部署令牌，以便团队访问组织的软件包](#add-deploy-tokens)。
1. [配置 CI/CD，安全地使用软件包](#use-packages-with-cicd)。

<a id="before-you-begin"></a>

## 开始之前

你需要具备以下内容才能完成本教程：

- 一个 npm 或 Maven 软件包。
- 熟悉极狐GitLab 软件包仓库。
- 一个测试项目。你可以使用现有项目，或为本教程创建一个。

<a id="understand-the-gitlab-package-registry"></a>

## 理解极狐GitLab 软件包仓库

传统的软件包管理器（如 JFrog Artifactory 和 Sonatype Nexus）使用单一的中央仓库来存储和更新你的软件包。
在极狐GitLab 中，你可以在群组或项目中直接管理软件包。这意味着：

- 团队将软件包发布到存储代码的项目中。
- 团队从汇总了其下所有软件包的根群组仓库中消费软件包。
- 访问控制继承自你现有的极狐GitLab 权限。

由于软件包的存储和管理方式与代码一样，你可以将软件包管理添加到现有项目或群组中。
该模型具有多项优势：

- 软件包与其源代码的所有权明确
- 无需额外配置即可实现细粒度的访问控制
- 简化的 CI/CD 集成
- 自然契合团队结构
- 通过根群组消费，可为所有公司软件包提供单一访问 URL

<a id="create-an-enterprise-structure"></a>

## 创建企业结构

请考虑将你的代码组织在单一顶级群组下。例如：

```plaintext
company/（顶级群组）
├── retail-division/
│   ├── shared-libraries/    # 分部特定共享代码
│   └── teams/
│       ├── checkout/        # 团队在此发布软件包
│       └── inventory/       # 团队在此发布软件包
├── banking-division/
│   ├── shared-libraries/    # 分部特定共享代码
│   └── teams/
│       ├── payments/        # 团队在此发布软件包
│       └── fraud/           # 团队在此发布软件包
└── shared-platform/         # 企业级共享代码
    ├── java-commons/        # 共享 Java 库
    └── ui-components/       # 共享 UI 组件
```

在此结构中，公司内的所有团队将代码和软件包发布到他们各自的项目中，
同时继承顶级 `company/` 群组的配置。

<a id="set-up-a-top-level-group"></a>

## 设置顶级群组

如果你已经拥有一个顶级群组，并且拥有所有者角色，则可以使用它。

如果你还没有群组，请创建一个：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建群组**。
1. 在 **群组名称** 中，输入群组名称。
1. 在 **群组 URL** 中，输入群组路径，该路径将用作命名空间。
1. 选择[可见性级别](../../public_access.md)。
1. 选填。填写信息以个性化你的体验。
1. 选择 **创建群组**。

该群组将存储你组织内的其他群组和项目。如果你已有其他项目和群组，可以
[将它们转移到新的顶级群组](../../group/manage.md#transfer-a-group)以便管理。

在继续之前，请确保你至少具备：

- 一个顶级群组。
- 一个属于该顶级群组或其子群组的项目。

<a id="publish-packages"></a>

## 发布软件包

为了保持明确的所有权，团队应将软件包发布到他们自己的软件包仓库中。
这将软件包与源代码保存在一起，并确保版本历史与项目活动紧密关联。

{{< tabs >}}

{{< tab title="Maven 项目" >}}

要发布 Maven 软件包：

- 配置你的 `pom.xml` 文件，以发布到项目的软件包仓库：

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

{{< tab title="npm 项目" >}}

要发布 npm 软件包：

- 配置你的 `package.json` 文件：

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

## 消费软件包

由于你的项目组织在单一顶级群组下，你的软件包仍然可以被组织访问。接下来，我们配置一个单一的 API 端点，让你的团队从中消费软件包。

{{< tabs >}}

{{< tab title="Maven 项目" >}}

- 配置你的 `pom.xml` 以从顶级群组访问软件包：

  ```xml
  <!-- 任何项目的 pom.xml -->
  <repositories>
      <repository>
          <id>gitlab-maven</id>
          <url>https://gitlab.example.com/api/v4/groups/company/-/packages/maven</url>
      </repository>
  </repositories>
  ```

{{< /tab >}}

{{< tab title="npm 项目" >}}

- 配置你的 `.npmrc` 文件：

  ```shell
  # 任何项目的 .npmrc
  @company:registry=https://gitlab.example.com/api/v4/groups/company/-/packages/npm/
  ```

{{< /tab >}}

{{< /tabs >}}

此配置会自动提供对整个组织内所有软件包的访问权限，同时保持基于项目发布的优势。

<a id="add-deploy-tokens"></a>

## 添加部署令牌

接下来，添加一个只读部署令牌。该令牌提供对组织子群组和项目中存储的软件包的访问权限，
以便你的团队在开发中使用它们。

1. 在你的顶级群组中，在左侧边栏选择 **设置** > **仓库**。
1. 展开 **部署令牌**。
1. 选择 **添加令牌**。
1. 填写字段，并将范围设置为 `read_repository`。
1. 选择 **创建部署令牌**。

你可以根据需要向顶级群组添加任意数量的部署令牌。
请记住定期轮换你的令牌。如果你怀疑令牌已被泄露，请立即撤销并替换。

<a id="use-packages-with-cicd"></a>

## 在 CI/CD 中使用软件包

当 CI/CD 作业需要访问软件包仓库时，它们会使用预定义的 CI/CD 变量 `CI_JOB_TOKEN` 进行身份认证。该认证自动完成，因此你无需进行任何额外配置：

```yaml
发布：
  脚本：
    - mvn deploy  # 针对 Maven 软件包
    # 或
    - npm publish # 针对 npm 软件包
  # CI_JOB_TOKEN 提供自动身份认证
```

<a id="summary-and-next-steps"></a>

## 总结和后续步骤

将你的极狐GitLab 项目组织在一个顶级群组下会带来多项好处：

- 简化配置：
  - 所有软件包访问使用一个 URL
  - 跨团队设置一致
  - 轻松轮换令牌
- 明确所有权：
  - 软件包与源代码并存
  - 团队保留发布控制权
  - 版本历史与项目活动关联
- 自然组织结构：
  - 群组匹配公司结构
  - 团队既协作又保持自治

极狐GitLab 软件包仓库模型为企业级软件包管理提供了强大的解决方案。通过将基于项目的发布与顶级群组消费相结合，
你就能两全其美：明确所有权与简化访问。

这种方法会随你的组织自然扩展，同时保持安全性和易用性。
可以先从一个团队或部门开始实施该模型，并在看到这种集成方法的好处后逐步推广。
请记住，虽然本教程侧重于 Maven 和 npm，但同样的原则也适用于极狐GitLab 支持的所有软件包类型。