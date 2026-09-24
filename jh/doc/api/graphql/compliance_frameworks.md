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

- 要创建、编辑和删除合规框架，用户需满足以下条件之一：
  - 拥有顶级群组的所有者角色。
  - 被分配了具有 `admin_compliance_framework` [自定义权限](../../user/custom_roles/abilities.md#compliance-management) 的[自定义角色](../../user/custom_roles/_index.md)。

<a id="create-a-compliance-framework"></a>

## 创建合规框架

为顶级群组创建新的合规框架。

要创建合规框架，请使用 `createComplianceFramework` 变更：

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

如果满足以下条件，则框架创建成功：

- 返回的 `errors` 对象为空
- API 返回 `200 OK`

<a id="create-a-framework-with-requirements"></a>

### 创建带要求的框架

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以创建具有特定要求和控制的框架：

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

创建框架后，您可以使用创建变更返回的框架 ID 添加要求。

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

更新顶级群组现有合规框架。

要更新合规框架，请使用 `updateComplianceFramework` 变更。您可以通过[列出所有合规框架](#list-compliance-frameworks)来获取框架 ID。

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

如果满足以下条件，则框架更新成功：

- 返回的 `errors` 对象为空
- API 返回 `200 OK`

<a id="delete-a-compliance-framework"></a>

## 删除合规框架

从顶级群组中删除合规框架。

要删除合规框架，请使用 `destroyComplianceFramework` 变更。您可以通过[列出所有合规框架](#list-compliance-frameworks)来获取框架 ID。

```graphql
mutation {
  destroyComplianceFramework(input: {
    id: "gid://gitlab/ComplianceManagement::Framework/1"
  }) {
    errors
  }
}
```

如果满足以下条件，则框架删除成功：

- 返回的 `errors` 对象为空
- API 返回 `200 OK`

<a id="apply-compliance-frameworks-to-projects"></a>

## 将合规框架应用到项目

将一个或多个合规框架应用到项目。

先决条件：

- 项目拥有维护者或所有者角色
- 项目必须属于拥有合规框架的群组

要应用合规框架到项目，请使用 `projectUpdateComplianceFrameworks` 变更：

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

如果满足以下条件，则框架应用成功：

- 返回的 `errors` 对象为空
- API 返回 `200 OK`

<a id="remove-compliance-frameworks-from-projects"></a>

### 从项目中移除合规框架

要从项目中移除所有合规框架，请传递一个空数组：

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

## 处理要求和控制

您可以使用 GraphQL 管理合规框架的要求和控制。

<a id="query-framework-requirements"></a>

### 查询框架要求

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要查看合规框架的要求和控制：

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

要添加一个带有极狐GitLab 合规控制的要求到现有框架：

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

### 添加外部控制

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

要添加一个带有外部控制的要求：

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

要从框架中删除要求：

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

- **框架名称已存在**：每个框架名称在群组内必须唯一
- **无效的颜色格式**：颜色必须为十六进制格式（例如 `#1f75cb`）
- **权限不足**：仅群组所有者或拥有 `admin_compliance_framework` 权限的用户可以管理框架
- **无效的控制 ID**：控制 ID 必须与受支持的[极狐GitLab 合规控制](../../user/compliance/compliance_frameworks/_index.md#gitlab-compliance-controls) 匹配

请始终检查响应中的 `errors` 字段，以处理变更过程中出现的任何问题。