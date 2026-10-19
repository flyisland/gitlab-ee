---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合规框架 GraphQL API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 GraphQL API 管理顶级群组的合规框架。

<a id="prerequisites"></a>

## 先决条件

- 要创建、编辑和删除合规框架，用户需满足以下任一条件：
  - 拥有顶级群组的所有者角色。
  - 被分配了具有 `admin_compliance_framework`
    [自定义权限](../../user/custom_roles/abilities.md#compliance-management)的[自定义角色](../../user/custom_roles/_index.md)。

<a id="create-a-compliance-framework-from-a-template"></a>

## 从模板创建合规框架

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

从预定义模板创建合规框架。模板包含与常见合规标准对齐的预配置要求和控制项。

<a id="list-available-templates"></a>

### 列出可用模板

列出所有可用的合规框架模板：

```graphql
query {
  complianceFrameworkTemplates {
    id
    name
    description
    color
    templateVersion
  }
}
```

按 ID 获取特定模板并查看其完整 JSON 结构：

```graphql
query {
  complianceFrameworkTemplates(
    id: "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/soc2"
  ) {
    id
    name
    description
    color
    templateVersion
    json
  }
}
```

可用的模板 ID：

| 模板 ID | 名称 |
|-------------|------|
| `cis_csc_v8-1` | CIS CSC v8.1 |
| `csa_ccm_v4` | CSA CCM v4 |
| `cyber_essentials` | Cyber Essentials |
| `dora` | DORA |
| `fedramp_high_r5` | FedRAMP High |
| `fedramp_low_r5` | FedRAMP Low |
| `fedramp_moderate_r5` | FedRAMP Moderate |
| `irap_official` | IRAP Official |
| `irap_protected` | IRAP Protected |
| `irap_secret` | IRAP 机密 |
| `irap_top_secret` | IRAP 绝密 |
| `ismap` | ISMAP |
| `iso_27001-2022` | ISO 27001:2022 |
| `nis_2` | NIS 2 |
| `nist_800-171_r3_cmmc` | NIST 800-171 Rev. 3 CMMC |
| `nist_800-218_v1-1` | NIST SP 800-218 |
| `nist_800-53_r5` | NIST 800-53 Revision 5 |
| `soc2` | SOC 2 |
| `tisax` | TISAX |

<a id="create-a-framework-from-a-template"></a>

### 从模板创建框架

要从模板创建合规框架，请使用
`createComplianceFrameworkFromTemplate` 变更操作。`templateId` 和
`namespacePath` 参数为必填项。其他所有参数均为可选的模板默认值覆盖项。

```graphql
mutation {
  createComplianceFrameworkFromTemplate(
    input: {
      namespacePath: "my-group"
      templateId: "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/soc2"
    }
  ) {
    framework {
      id
      name
      description
      color
    }
    errors
  }
}
```

您可以覆盖模板的默认名称、描述、颜色和默认状态：

```graphql
mutation {
  createComplianceFrameworkFromTemplate(
    input: {
      namespacePath: "my-group"
      templateId: "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/soc2"
      name: "Custom SOC 2"
      description: "Our organization's SOC 2 compliance framework"
      color: "#FCA121"
      default: true
    }
  ) {
    framework {
      id
      name
      description
      color
    }
    errors
  }
}
```

创建框架时，会预先填充模板中的所有要求和控制项。源模板 ID 和版本会记录为不可变的来源字段，创建后无法更改。

满足以下条件时，框架创建成功：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="create-a-compliance-framework"></a>

## 创建合规框架

为顶级群组创建新的合规框架。

要创建合规框架，请使用 `createComplianceFramework` 变更操作：

```graphql
mutation {
  createComplianceFramework(input: {
    namespacePath: "my-group",
    params: {
      name: "SOX Compliance",
      description: "Sarbanes-Oxley compliance framework for financial reporting",
      color: "#1f75cb",
      default: false
    }
  }) {
    errors
    framework {
      id
      name
      description
      color
      default
      namespace {
        name
      }
    }
  }
}
```

满足以下条件时，框架创建成功：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="create-a-framework-with-requirements"></a>

### 创建带要求的框架

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以创建带有特定要求和控制项的框架：

```graphql
mutation {
  createComplianceFramework(input: {
    namespacePath: "my-group",
    params: {
      name: "Security Framework",
      description: "Security compliance framework with SAST and dependency scanning",
      color: "#e24329",
      default: false
    }
  }) {
    errors
    framework {
      id
      name
      description
      color
      default
      namespace {
        name
      }
    }
  }
}
```

创建框架后，您可以使用创建变更操作返回的框架 ID 添加要求。

<a id="list-compliance-frameworks"></a>

## 列出合规框架

列出顶级群组的所有合规框架。

您可以使用 `group` 查询查看顶级群组的合规框架列表：

```graphql
query {
  group(fullPath: "my-group") {
    id
    complianceFrameworks {
      nodes {
        id
        name
        description
        color
        default
        pipelineConfigurationFullPath
      }
    }
  }
}
```

如果结果列表为空，则该群组不存在任何合规框架。

<a id="list-compliance-frameworks-assigned-to-a-project"></a>

## 列出分配给项目的合规框架

```graphql
query {
 project(fullPath: "my-project"){
  id
  name
  complianceFrameworks{
    nodes{
      id
      name
      }
    }
  }
}

```

将 `"my-project"` 替换为您项目的完整路径。

<a id="update-a-compliance-framework"></a>

## 更新合规框架

更新顶级群组的现有合规框架。

要更新合规框架，请使用 `updateComplianceFramework` 变更操作。您可以通过[列出该群组的所有合规框架](#list-compliance-frameworks)来获取框架 ID。

```graphql
mutation {
  updateComplianceFramework(input: {
    id: "gid://gitlab/ComplianceManagement::Framework/1",
    params: {
      name: "Updated SOX Compliance",
      description: "Updated Sarbanes-Oxley compliance framework",
      color: "#6b4fbb",
      default: true
    }
  }) {
    errors
    framework {
      id
      name
      description
      color
      default
      namespace {
        name
      }
    }
  }
}
```

满足以下条件时，框架更新成功：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="delete-a-compliance-framework"></a>

## 删除合规框架

从顶级群组删除合规框架。

要删除合规框架，请使用 `destroyComplianceFramework` 变更操作。您可以通过[列出该群组的所有合规框架](#list-compliance-frameworks)来获取框架 ID。

```graphql
mutation {
  destroyComplianceFramework(input: {
    id: "gid://gitlab/ComplianceManagement::Framework/1"
  }) {
    errors
  }
}
```

满足以下条件时，框架删除成功：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="apply-compliance-frameworks-to-projects"></a>

## 将合规框架应用到项目

将一个或多个合规框架应用到项目。

先决条件：

- 拥有项目的维护者或所有者角色。
- 项目必须属于具有合规框架的群组。

要将合规框架应用到项目，请使用 `projectUpdateComplianceFrameworks` 变更操作：

```graphql
mutation {
  projectUpdateComplianceFrameworks(input: {
    projectId: "gid://gitlab/Project/1",
    complianceFrameworkIds: [
      "gid://gitlab/ComplianceManagement::Framework/1",
      "gid://gitlab/ComplianceManagement::Framework/2"
    ]
  }) {
    errors
    project {
      id
      complianceFrameworks {
        nodes {
          id
          name
          color
        }
      }
    }
  }
}
```

满足以下条件时，框架应用成功：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="remove-compliance-frameworks-from-projects"></a>

### 从项目移除合规框架

要从项目移除所有合规框架，请传入空数组：

```graphql
mutation {
  projectUpdateComplianceFrameworks(input: {
    projectId: "gid://gitlab/Project/1",
    complianceFrameworkIds: []
  }) {
    errors
    project {
      id
      complianceFrameworks {
        nodes {
          id
          name
        }
      }
    }
  }
}
```

<a id="working-with-requirements-and-controls"></a>

## 使用要求和控制项

您可以使用 GraphQL 管理合规框架的要求和控制项。

<a id="query-framework-requirements"></a>

### 查询框架要求

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要查看合规框架的要求和控制项：

```graphql
query {
  group(fullPath: "my-group") {
    complianceFrameworks {
      nodes {
        id
        name
        requirements {
          nodes {
            id
            name
            description
            controls {
              nodes {
                id
                name
                controlId
                controlType
              }
            }
          }
        }
      }
    }
  }
}
```

<a id="add-requirements-to-a-framework"></a>

### 向框架添加要求

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要向现有框架添加带有极狐GitLab 合规控制项的要求：

```graphql
mutation {
  complianceFrameworkRequirementCreate(input: {
    frameworkId: "gid://gitlab/ComplianceManagement::Framework/1",
    name: "Security Scanning Requirement",
    description: "Ensure security scanning is enabled for all projects",
    controlIds: [
      "scanner_sast_running",
      "scanner_dep_scanning_running",
      "scanner_secret_detection_running"
    ]
  }) {
    errors
    requirement {
      id
      name
      description
      controls {
        nodes {
          id
          name
          controlId
        }
      }
    }
  }
}
```

<a id="add-external-controls"></a>

### 添加外部控制项

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要添加带有外部控制项的要求：

```graphql
mutation {
  createComplianceRequirement(
    input: {
      complianceFrameworkId: "gid://gitlab/ComplianceManagement::Framework/1",
      controls: [{
        controlType: "external",
        name: "external_control",
        externalControlName: "ServiceNowApproval",
        externalUrl: "https://mycompany.service-now.com/api/approval",
        secretToken: "my-secret-key"
      }],
      params: {
        name: "External Approval Requirement",
        description: "Require external system approval for deployments"
      }
    }
  ) {
    errors
    requirement {
      id
      name
      description
      complianceRequirementsControls {
        nodes {
          id
          name
          controlType
          externalUrl
        }
      }
    }
  }
}
```

<a id="update-requirements"></a>

### 更新要求

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要更新现有要求：

```graphql
mutation {
  updateComplianceRequirement(input: {
    id: "gid://gitlab/ComplianceManagement::ComplianceFramework::ComplianceRequirement/1",
    params: {
      name: "Updated Security Requirement",
      description: "Updated security scanning requirement with additional controls"
    },
    controls: [{
        expression: "{\"field\":\"scanner_sast_running\",\"operator\":\"=\",\"value\":true}",
        name: "scanner_sast_running"
      },
      {
        expression: "{\"field\":\"scanner_dep_scanning_running\",\"operator\":\"=\",\"value\":true}",
        name: "scanner_dep_scanning_running"
      },
      {
        expression: "{\"field\":\"scanner_secret_detection_running\",\"operator\":\"=\",\"value\":true}",
        name: "scanner_secret_detection_running"
      }]
  })
  {
    errors
    requirement {
      id
      name
      description
      complianceRequirementsControls {
        nodes {
          id
          name
        }
      }
    }
  }
}
```

<a id="delete-requirements"></a>

### 删除要求

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要从框架删除要求：

```graphql
mutation {
  destroyComplianceRequirement(input: {
    id: "gid://gitlab/ComplianceManagement::ComplianceFramework::ComplianceRequirement/1"
  }) {
    errors
  }
}
```

<a id="error-handling"></a>

## 错误处理

通过 GraphQL 使用合规框架时，您可能会遇到以下常见错误：

- **框架名称已存在**：每个框架名称在群组内必须唯一。
- **颜色格式无效**：颜色必须为十六进制格式（例如 `#1f75cb`）。
- **权限不足**：只有群组所有者或拥有 `admin_compliance_framework` 权限的用户才能管理框架。
- **控制项 ID 无效**：控制项 ID 必须与支持的[极狐GitLab 合规控制项](../../user/compliance/compliance_frameworks/_index.md#gitlab-compliance-controls)匹配。

请始终检查响应中的 `errors` 字段，以处理变更操作期间发生的任何问题。
