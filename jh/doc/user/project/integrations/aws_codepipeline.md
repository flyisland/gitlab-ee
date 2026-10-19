---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
title: AWS CodePipeline
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

您可以使用极狐GitLab 项目，通过 [AWS CodePipeline](https://aws.amazon.com/codepipeline/) 构建、测试和部署代码变更。为此，您需要使用：

- AWS CodeStar Connections 将您的 JihuLab.com 账号连接到 AWS。
- 该连接会根据代码变更自动启动流水线。

<a id="create-a-connection-from-aws-codepipeline-to-gitlab"></a>

## 从 AWS CodePipeline 创建到极狐GitLab 的连接

先决条件：

- 您必须在要与 AWS CodePipeline 连接的极狐GitLab 项目上拥有所有者角色。
- 您必须拥有在 AWS 中创建连接的相应权限。
- 您必须使用受支持的 AWS 区域。不受支持的区域（也在 [AWS 文档](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab.html)中列出）包括：
  - 亚太地区（香港）。
  - AWS GovCloud（美国西部和美国东部）。

要创建到 JihuLab.com 上项目的连接，您可以使用 AWS 管理控制台或 AWS 命令行界面（AWS CLI）。

<a id="use-the-aws-management-console"></a>

### 使用 AWS 管理控制台

要将 AWS CodePipeline 中的新流水线或现有流水线与 JihuLab.com 连接，请先授权 AWS 连接使用您的极狐GitLab 账号。

1. 登录 AWS 管理控制台，并打开 [AWS Developer Tools 控制台](https://console.aws.amazon.com/codesuite/settings/connections)。
1. 选择 **设置** > **连接** > **创建连接**。
1. 在 **选择提供商**中，选择 **GitLab**。
1. 在 **连接名称**中，输入要创建的连接名称，然后选择 **连接到 GitLab**。
1. 在极狐GitLab 登录页面中，输入您的凭据并选择 **登录**。
1. 此时会显示一个授权页面，其中包含请求授权该连接访问您的极狐GitLab 账号的消息。选择 **授权**。
1. 浏览器会返回连接控制台页面。在 **创建 GitLab 连接** 部分，新连接会显示在 **连接名称**中。
1. 选择 **连接到 GitLab**。连接成功创建后，会显示成功横幅。连接详情会显示在 **连接设置** 页面上。

现在您已将 AWS CodeSuite 连接到 JihuLab.com，可以在 AWS CodePipeline 中创建或编辑流水线，以利用您的极狐GitLab 项目。

1. 登录 [AWS CodePipeline 控制台](https://console.aws.amazon.com/codesuite/codepipeline/start)。
1. 创建或编辑流水线：
   - 如果要创建流水线：
     - 填写第一个屏幕中的字段，然后选择 **下一步**。
     - 在 **源** 页面上的 **源提供商** 部分，选择 **GitLab**。
   - 如果要编辑现有流水线：
     - 选择 **编辑** > **编辑阶段** 以添加或编辑您的源操作。
     - 在 **编辑操作** 页面上的 **操作名称** 部分，输入您的操作名称。
     - 在 **操作提供商**中，选择 **GitLab**。
1. 在 **连接**中，选择您之前创建的连接。
1. 在 **代码仓库名称**中，要选择极狐GitLab 项目的名称，请指定包含命名空间和所有子群组的完整项目路径。
   例如，对于群组级项目，请按以下格式输入项目名称：`group-name/subgroup-name/project-name`。
   包含命名空间的项目路径位于极狐GitLab 中的 URL 中。请勿从 Web IDE 或原始视图复制 URL，因为它们包含其他特殊 URL 段。
   您也可以从对话框中选择一个选项，或手动输入新路径。
   有关以下内容的更多信息：
   - 路径和命名空间，请参阅 [项目 API](../../../api/projects.md#retrieve-a-project)中的 `path_with_namespace` 字段。
   - 极狐GitLab 中的命名空间，请参阅[命名空间](../../namespace/_index.md)。

1. 在 **分支名称**中，选择您希望流水线检测源变更的分支。
   如果分支名称未自动填充，可能是因为以下原因之一：
   - 您没有该项目的所有者角色。
   - 项目名称无效。
   - 所使用的连接无权访问该项目。

1. 在 **输出产物格式**中，选择产物的格式。要存储：
   - 使用默认方法存储来自 GitLab 操作的输出产物，请选择 **CodePipeline 默认**。该操作会从极狐GitLab 代码仓库访问文件，并将产物以 ZIP 文件形式存储在流水线产物存储中。
   - 存储一个包含代码仓库 URL 引用的 JSON 文件，以便下游操作可以直接执行 Git 命令，请选择 **完整克隆**。此选项只能由 CodeBuild 下游操作使用。要选择此选项：
     - [更新您的 CodeBuild 项目服务角色的权限](https://docs.aws.amazon.com/codepipeline/latest/userguide/troubleshooting.html#codebuild-role-connections)。
     - 遵循 [AWS CodePipeline 教程，了解如何对 GitHub 流水线源使用完整克隆](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-github-gitclone.html)。
1. 保存源操作并继续。

<a id="use-the-aws-cli"></a>

### 使用 AWS CLI

要使用 AWS CLI 创建连接：

- 使用 `create-connection` 命令。
- 转到 AWS 控制台，使用您的 JihuLab.com 账号进行身份验证。
- 将您的极狐GitLab 项目连接到 AWS CodePipeline。

要使用 `create-connection` 命令：

1. 打开终端（Linux、macOS 或 Unix）或命令提示符（Windows）。使用 AWS CLI 运行 `create-connection` 命令，为您的连接指定 `--provider-type` 和 `--connection-name`。在此示例中，第三方提供商名称为 `GitLab`，指定的连接名称为 `MyConnection`。

   ```shell
   aws codestar-connections create-connection --provider-type GitLab --connection-name MyConnection
   ```

   如果成功，此命令会返回连接的 Amazon 资源名称（ARN）信息。例如：

   ```json
   {
   "ConnectionArn": "arn:aws:codestar-connections:us-west-2:account_id:connection/aEXAMPLE-8aad-4d5d-8878-dfcab0bc441f"
   }
   ```

1. 新连接默认以 `PENDING` 状态创建。使用控制台将连接状态更改为 `AVAILABLE`。
1. [使用 AWS 控制台完成连接](#use-the-aws-management-console)。请确保选择您待处理的极狐GitLab 连接。请勿选择 **创建连接**。
