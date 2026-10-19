---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 GraphQL 列出项目分支规则
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用以下方法查询给定项目中的分支规则：

- GraphiQL。
- [`cURL`](getting_started.md#command-line)。
- [极狐GitLab 开发工具包 (GDK)](#use-the-gdk)。

<a id="use-graphiql"></a>

## 使用 GraphiQL

您可以使用 GraphiQL 列出项目的分支规则。

1. 打开 GraphiQL：
   - 对于 JihuLab.com，使用：`https://jihulab.com/-/graphql-explorer`
   - 对于私有化部署，使用：`https://gitlab.example.com/-/graphql-explorer`
1. 复制以下文本并将其粘贴到左侧窗口中。此查询通过项目的完整路径搜索项目，例如 `gitlab-org/gitlab-docs`。它请求项目所有已配置的分支规则。

   ```graphql
   query {
     project(fullPath: "gitlab-org/gitlab-docs") {
       branchRules {
         nodes {
           name
           isDefault
           isProtected
           matchingBranchesCount
           createdAt
           updatedAt
           branchProtection {
             allowForcePush
             codeOwnerApprovalRequired
             mergeAccessLevels {
               nodes {
                 accessLevel
                 accessLevelDescription
                 user {
                   name
                 }
                 group {
                   name
                 }
               }
             }
             pushAccessLevels {
               nodes {
                 accessLevel
                 accessLevelDescription
                 user {
                   name
                 }
                 group {
                   name
                 }
               }
             }
             unprotectAccessLevels {
               nodes {
                 accessLevel
                 accessLevelDescription
                 user {
                   name
                 }
                 group {
                   name
                 }
               }
             }
           }
           externalStatusChecks {
             nodes {
               id
               name
               externalUrl
             }
           }
           approvalRules {
             nodes {
               id
               name
               type
               approvalsRequired
               eligibleApprovers {
                 nodes {
                   name
                 }
               }
             }
           }
         }
       }
     }
   }
   ```

1. 选择 **运行**。

如果没有显示分支规则，可能是因为：

- 没有配置分支规则。
- 您的角色没有查看分支规则的权限。管理员可以访问所有资源。

<a id="use-the-gdk"></a>

## 使用 GDK

相比于请求访问权限，在 [极狐GitLab 开发工具包 (GDK)](https://jihulab.com/gitlab-cn/gitlab-development-kit) 中运行查询可能更方便。

1. 使用默认管理员 `root` 登录，凭据来自 [GDK 文档](https://gitlab-org.gitlab.io/gitlab-development-kit/gdk_commands/#get-the-login-credentials)。
1. 确保您已为 `flightjs/Flight` 项目配置了一些分支规则。
1. 在您的 GDK 实例中，打开 GraphiQL：`http://gdk.test:3000/-/graphql-explorer`。
1. 复制查询并将其粘贴到左侧窗口中。
1. 用以下路径替换完整路径：

   ```graphql
   query {
     project(fullPath: "flightjs/Flight") {
   ```

1. 选择 **运行**。

