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

{{< history >}}

- 在极狐GitLab 16.5 中引入。

{{< /history >}}

您可以使用极狐GitLab 项目通过 [AWS CodePipeline](https://aws.amazon.com/codepipeline/) 构建、测试和部署代码变更。为此，您需要使用：

- AWS CodeStar Connections 将您的 JihuLab.com 账户连接到 AWS。
- 该连接根据代码变更自动启动流水线。

<a id="create-a-connection-from-aws-codepipeline-to-gitlab"></a>

## 创建从 AWS CodePipeline 到极狐GitLab 的连接

先决条件：

- 您必须对正在与 AWS CodePipeline 连接的极狐GitLab 项目拥有所有者角色。
- 您必须拥有在 AWS 中创建连接的适当权限。
- 您必须使用受支持的 AWS 区域。不受支持的区域（也在 [AWS 文档](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab.html) 中列出）有：
  - 亚太地区（香港）。

要创建到 JihuLab.com 上项目的连接，您可以使用 AWS 管理控制台或 AWS 命令行界面 (AWS CLI)。

<a id="use-the-aws-management-console"></a>

### 使用 AWS 管理控制台

要将 AWS CodePipeline 中的新流水线或现有流水线与 JihuLab.com 连接，请首先授权 AWS 连接使用您的极狐GitLab 账户。

1. 登录 AWS 管理控制台，并打开 [AWS Developer Tools 控制台](https://console.aws.amazon.com/codesuite/settings/connections)。
1. 选择 **设置** > **连接** > **创建连接**。
1. 在 **选择提供商** 中，选择 **极狐GitLab**。
1. 在 **连接名称** 中，输入您要创建的连接名称，然后选择 **连接到极狐GitLab**。
1. 在极狐GitLab 登录页面中，输入您的凭据并选择 **登录**。
1. 将显示一个授权页面，其中包含请求授权连接访问您的极狐GitLab 账户的消息。选择 **授权**。
1. 浏览器返回到连接控制台页面。在 **创建极狐GitLab 连接** 部分，新连接显示在 **连接名称** 中。
1. 选择 **连接到极狐GitLab**。成功创建连接后，将显示成功横幅。连接详细信息显示在 **连接设置** 页面上。

现在，您已将 AWS CodeSuite 连接到 JihuLab.com，您可以在 AWS CodePipeline 中创建或编辑利用极狐GitLab 项目的流水线。

1. 登录 [AWS CodePipeline 控制台](https://console.aws.amazon.com/codesuite/codepipeline/start)。
1. 创建或编辑流水线：
   - 如果您正在创建流水线：
     - 完成第一个屏幕中的字段，然后选择 **下一步**。
     - 在 **源** 页面上的 **源提供商** 部分，选择 **极狐GitLab**。
   - 如果您正在编辑现有流水线：
     - 选择 **编辑** > **编辑阶段** 以添加或编辑您的源操作。
     - 在 **编辑操作** 页面上的 **操作名称** 部分，输入您的操作名称。
     - 在 **操作提供商** 中，选择 **极狐GitLab**。
1. 在 **连接** 中，选择您之前创建的连接。
1. 在 **仓库名称** 中，要选择您的极狐GitLab 项目名称，请指定包含命名空间和所有子群组的完整项目路径。
   例如，对于群组级项目，请按以下格式输入项目名称：`group-name/subgroup-name/project-name`。
   带有命名空间的项目路径位于极狐GitLab 的 URL 中。不要从 Web IDE 或原始视图复制 URL，因为它们包含其他特殊 URL 段。
   您也可以从对话框中选择一个选项，或手动输入新路径。
   有关更多信息：
   - 路径和命名空间，请参见 [项目 API](../../../api/projects.md#retrieve-a-project) 中的 `path_with_namespace` 字段。
   - 极狐GitLab 中的命名空间，请参见 [命名空间](../../namespace/_index.md)。

1. 在 **分支名称** 中，选择您希望流水线检测源变更的分支。
   如果分支名称未自动填充，可能是由于以下原因之一：
   - 您没有该项目的所有者角色。
   - 项目名称无效。
   - 使用的连接无权访问该项目。

1. 在 **输出产物格式** 中，选择产物的格式。要存储：
   - 使用默认方法从极狐GitLab 操作输出的产物，请选择 **CodePipeline 默认**。该操作会从极狐GitLab 仓库访问文件，并将产物以 ZIP 文件形式存储在流水线产物存储中。
   - 包含对仓库的 URL 引用的 JSON 文件，以便下游操作可以直接执行 Git 命令，请选择 **完整克隆**。此选项只能由 CodeBuild 下游操作使用。要选择此选项：
     - [更新 CodeBuild 项目服务角色的权限](https://docs.aws.amazon.com/codepipeline/latest/userguide/troubleshooting.html#codebuild-role-connections)。
     - 遵循 [AWS CodePipeline 关于如何将完整克隆与 GitHub 流水线源结合使用的教程](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-github-gitclone.html)。
1. 保存源操作并继续。

<a id="use-the-aws-cli"></a>

### 使用 AWS CLI

要使用 AWS CLI 创建连接：

- 使用 `create-connection` 命令。
- 前往 AWS 控制台使用您的 JihuLab.com 账户进行身份验证。
- 将您的极狐GitLab 项目连接到 AWS CodePipeline。

要使用 `create-connection` 命令：

1. 打开终端（Linux、macOS 或 Unix）或命令提示符（Windows）。使用 AWS CLI 运行 `create-connection` 命令，为您的连接指定 `--provider-type` 和 `--connection-name`。在此示例中，第三方提供商名称为 `GitLab`，指定的连接名称为 `MyConnection`。

   ```shell
   aws codestar-connections create-connection --provider-type GitLab --connection-name MyConnection
   ```

   如果成功，此命令将返回连接的 Amazon 资源名称 (ARN) 信息。例如：

   ```json
   {
   "ConnectionArn": "arn:aws:codestar-connections:us-west-2:account_id:connection/aEXAMPLE-8aad-4d5d-8878-dfcab0bc441f"
   }
   ```

1. 默认情况下，新连接创建时的状态为 `PENDING`。使用控制台将连接状态更改为 `AVAILABLE`。
1. [使用 AWS 控制台完成连接](#use-the-aws-management-console)。确保选择您待处理的极狐GitLab 连接。不要选择 **创建连接**。