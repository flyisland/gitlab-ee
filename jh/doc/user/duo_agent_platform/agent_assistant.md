---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: CLI 代理
---

{{< details >}}

- Tier: 旗舰版
- 附加组件: GitLab Duo Enterprise
- Offering: JihuLab.com，私有化部署
- 状态: 实验

{{< /details >}}

{{< collapsible title="模型信息" >}}

- 暂不可在 [自部署模型的 GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 使用

{{< /collapsible >}}

{{< history >}}

- 在 极狐GitLab 18.3 中引入，带有名为 `ai_flow_triggers` 的[功能标志](../../administration/feature_flags/_index.md)。默认启用。

{{< /history >}}

{{< alert type="flag" >}}

该功能的可用性由功能标志控制
更多信息，参见历史记录

{{< /alert >}}

GitLab Duo Agent 可以并行工作，帮助你同时创建代码、调研结果并执行任务

你可以创建一个命令行界面（CLI）代理，并将其与第三方 AI 模型提供方集成，以便根据你组织的需求自定义该 CLI 代理。你使用你自己的 API 密钥与模型提供方集成

随后，在项目的议题、史诗或合并请求中，你可以在评论或讨论中提及该 CLI 代理，并请求其完成任务

CLI 代理将：

- 读取并分析周围上下文和代码仓代码
- 在遵循项目权限并保留审计记录的前提下，决定要采取的适当操作
- 运行 CI 流水线，并在 极狐GitLab 内以可合并的变更或行内评论进行响应

以下第三方集成已由极狐GitLab 测试并可用：

- 国内 SOTA 大模型

<a id="prerequisites"></a>

## 先决条件

在你创建 CLI 代理并与第三方 AI 模型提供方集成之前，你必须：

<a id="configure-your-gitlab-environment"></a>

### 配置你的 极狐GitLab 环境

- [开启测试版和实验性功能](../gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)
- [开启 GitLab Duo](../gitlab_duo/turn_on_off.md)
- 拥有已分配席位的 GitLab Duo Enterprise（[分配席位](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)）
- 拥有隶属于[群组命名空间](../namespace/_index.md)且订阅为 旗舰版 的项目

<a id="set-up-cicd"></a>

### 设置 CI/CD

在完成你的任务时，CLI 代理会运行 CI/CD 流水线

如果你使用 极狐GitLab 私有化部署，你必须[创建并注册 极狐GitLab Runner](../../tutorials/create_register_first_runner/_index.md)

<a id="ai-model-provider-credentials"></a>

### AI 模型提供方凭据

要将 CLI 代理与第三方 AI 模型提供方集成，你必须拥有访问凭据。你可以使用该模型提供方的 API 密钥，或使用 极狐GitLab 管理的凭据

<a id="api-keys"></a>

#### API 密钥

要将 CLI 代理与第三方 AI 模型提供方集成，你可以使用该模型提供方的 API 密钥：

- 针对 国内 SOTA 大模型，使用相应的 API Key
- 针对 国内 SOTA 大模型，使用相应的 API Key

<a id="gitlab-managed-credentials"></a>

#### 极狐GitLab 托管的凭据

{{< history >}}

- 在 极狐GitLab 18.4 中引入

{{< /history >}}

你可以通过 AI 网关，将 CLI 代理配置为使用 极狐GitLab 托管的凭据，而不是使用你自己的第三方 AI 模型提供方 API 密钥。这样，你无需自行管理和轮换 API 密钥

当你使用 极狐GitLab 托管的凭据时：

- 在你的流程配置文件中设置 `injectGatewayToken: true`
- 从你的 CI/CD 变量中移除 API 密钥变量（例如，`ANTHROPIC_API_KEY`）
- 将 CLI 代理配置为使用 极狐GitLab AI 网关代理端点

当 `injectGatewayToken` 为 `true` 时，会自动注入以下环境变量：

- `AI_FLOW_AI_GATEWAY_TOKEN`：AI 网关的身份验证令牌
- `AI_FLOW_AI_GATEWAY_HEADERS`：API 请求需要的已格式化请求头

极狐GitLab 托管的凭据仅适用于 国内 SOTA 大模型

<a id="create-a-service-account"></a>

## 创建服务账号

先决条件：

- 在 JihuLab.com 上，你必须拥有该项目所属顶级群组的 所有者 角色
- 在 极狐GitLab 私有化部署 上，你必须具备以下之一：
  - 实例的 管理员 访问权限
  - 顶级群组的 所有者 角色，并且[有权限创建服务账号](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)

在你希望提及 CLI 代理的每个项目中，必须存在一个唯一的[服务账号](../../user/profile/service_accounts.md)。该服务账号的用户名就是你在指派 CLI 代理任务时要提及的名称

{{< alert type="warning" >}}

如果你在多个项目中使用同一个服务账号，则附加到该服务账号的 CLI 代理将获得对这些项目的访问权限

{{< /alert >}}

要设置服务账号，请执行以下操作。如果你权限不足，请寻求实例管理员或顶级群组所有者的帮助

1. [创建服务账号](../../user/profile/service_accounts.md#create-a-service-account)
1. [为该服务账号创建个人访问令牌](../../user/profile/service_accounts.md#create-a-personal-access-token-for-a-service-account)，并授予以下[范围](../../user/profile/personal_access_tokens.md#personal-access-token-scopes)：
   - `write_repository`
   - `api`
   - `ai_features`
1. 以 开发者 角色[将服务账号添加到你的项目](../../user/project/members/_index.md#add-users-to-a-project)，以确保服务账号仅具备最低必要权限

将服务账号添加到项目时，你必须输入服务账号的准确名称。如果名称错误，CLI 代理将无法工作

<a id="configure-cicd-variables"></a>

## 配置 CI/CD 变量

先决条件：

- 你必须至少拥有该项目的 维护者 角色

将以下 CI/CD 变量添加到你的项目设置中：

| 集成               | 环境变量                     | 描述                                                                 |
| ------------------ | ---------------------------- | -------------------------------------------------------------------- |
| 全部               | `GITLAB_TOKEN_<integration>` | 服务账号用户的个人访问令牌                                           |
| 全部               | `GITLAB_HOST`                | 极狐GitLab 实例主机名（例如，`gitlab.com`）                          |
| 国内 SOTA 大模型   | `ANTHROPIC_API_KEY`          | 国内 SOTA 大模型 API Key（当设置 `injectGatewayToken: true` 时可选） |
| 国内 SOTA 大模型   | `OPENAI_API_KEY`             | 国内 SOTA 大模型 API Key                                             |
| 国内 SOTA 模型 CLI | `GOOGLE_CREDENTIALS`         | JSON 凭据文件内容                                                    |
| 国内 SOTA 模型 CLI | `GOOGLE_CLOUD_PROJECT`       | Google Cloud 项目 ID                                                 |
| 国内 SOTA 模型 CLI | `GOOGLE_CLOUD_LOCATION`      | Google Cloud 项目区域                                                |

在项目设置中添加或更新变量：

1. 在左侧边栏，选择 **搜索或跳转到** 并找到你的项目
1. 选择 **设置** > **CI/CD**
1. 展开 **变量**
1. 选择 **添加变量** 并填写字段：
   - **类型**：选择 **变量（默认）**
   - **环境**：选择 **全部（默认）**
   - **可见性**：选择所需的可见性

     对于 API Key 和个人访问令牌变量，选择 **掩码** 或 **掩码且隐藏**
   - 取消选中 **保护变量**
   - 取消选中 **展开变量引用**
   - **描述（可选）**：输入变量描述
   - **键**：输入该 CI/CD 变量的环境变量名（例如，`GITLAB_HOST`）
   - **值**：API Key、个人访问令牌或主机的值
1. 选择 **添加变量**

更多信息，参见[如何在项目设置中添加 CI/CD 变量](../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)

<a id="create-a-flow-configuration-file"></a>

## 创建流程配置文件

先决条件：

- 你必须至少拥有该项目的 开发者 角色

为了告知 极狐GitLab 如何在你的环境中运行 CLI 代理，请在你的项目中创建一个流程配置文件。例如，`.gitlab/duo/flows/claude.yaml`

你必须为每个 CLI 代理创建一个不同的 AI 流程配置文件

<a id="example-flow-configuration-files"></a>

### 流程配置文件示例

使用以下示例来创建你的流程配置文件。这些示例包含如下变量：

- `AI_FLOW_CONTEXT`：JSON 序列化的父对象，包括：
  - 在合并请求中，diff 和评论（有上限）
  - 在议题或史诗中，评论（有上限）
- `$AI_FLOW_EVENT`：流程事件的类型（例如，`mention`）
- `$AI_FLOW_INPUT`：用户在合并请求、议题或史诗中的评论中输入的提示

<a id="anthropic-claude"></a>

#### 国内 SOTA 大模型

```yaml
injectGatewayToken: true
image: node:22-slim
commands:
  - echo "正在安装 claude"
  - npm install --global @anthropic-ai/claude-code
  - echo "正在安装 glab"
  - export GITLAB_TOKEN=$GITLAB_TOKEN_CLAUDE
  - apt-get update --quiet && apt-get install --yes curl wget gpg git && rm --recursive --force /var/lib/apt/lists/*
  - curl --silent --show-error --location "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | bash
  - apt-get install --yes glab
  - echo "正在配置 git"
  - git config --global user.email "claudecode@gitlab.com"
  - git config --global user.name "Claude Code"
  - echo "正在配置 claude"
  - export ANTHROPIC_AUTH_TOKEN=$AI_FLOW_AI_GATEWAY_TOKEN
  - export ANTHROPIC_CUSTOM_HEADERS=$AI_FLOW_AI_GATEWAY_HEADERS
  - export ANTHROPIC_BASE_URL="https://cloud.jihulab.com/ai/v1/proxy/anthropic"
  - echo "正在运行 claude"
  - |
    claude --debug --allowedTools="Bash(glab:*),Bash(git:*)" --permission-mode acceptEdits --verbose --output-format stream-json -p "
    You are an AI assistant helping with GitLab operations.

    Context: $AI_FLOW_CONTEXT
    Task: $AI_FLOW_INPUT
    Event: $AI_FLOW_EVENT

    Please execute the requested task using the available GitLab tools.
    Be thorough in your analysis and provide clear explanations.

    <important>
    Use the glab CLI to access data from GitLab. The glab CLI has already been authenticated. You can run the corresponding commands.

    When you complete your work create a new Git branch, if you aren't already working on a feature branch, with the format of 'feature/<short description of feature>' and check in/push code.

    When you check in and push code, you will need to use the access token stored in GITLAB_TOKEN and the user ClaudeCode.
    Lastly, after pushing the code, if a merge request doesn't already exist, create a new merge request for the branch and link it to the issue using:
    `glab mr create --title "<title>" --description "<desc>" --source-branch <branch> --target-branch <branch>`

    If you are asked to summarize a merge request or issue, or asked to provide more information, then please post back a note to the merge request / issue so that the user can see it.

    </important>
    "
variables:
  - GITLAB_TOKEN_CLAUDE
  - GITLAB_HOST
```

<a id="openai-codex"></a>

#### 国内 SOTA 大模型

```yaml
image: node:22-slim
injectGatewayToken: true
commands:
  - echo "正在安装 codex"
  - npm install --global @openai/codex
  - echo "正在安装 glab"
  - export OPENAI_API_KEY=$AI_FLOW_AI_GATEWAY_TOKEN
  - export GITLAB_TOKEN=$GITLAB_TOKEN_CODEX
  - apt-get update --quiet && apt-get install --yes curl wget gpg git && rm --recursive --force /var/lib/apt/lists/*
  - curl --silent --show-error --location "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | bash
  - apt-get install --yes glab
  - echo "正在配置 git"
  - git config --global user.email "codex@gitlab.com"
  - git config --global user.name "OpenAI Codex"
  - echo "正在运行 Codex"
  - |
    # 解析 AI_FLOW_AI_GATEWAY_HEADERS（以换行分隔的 "Key: Value" 键值对）
    header_str="{"
    first=true
    while IFS= read -r line; do
      # 跳过空行
      [ -z "$line" ] && continue
      key="${line%%:*}"
      value="${line#*: }"
      if [ "$first" = true ]; then
        first=false
      else
        header_str+=", "
      fi
      header_str+="\"$key\" = \"$value\""
    done <<< "$AI_FLOW_AI_GATEWAY_HEADERS"
    header_str+="}"

    codex exec \
      --config 'model_provider="gitlab"' \
      --config 'model_providers.gitlab.name="GitLab Managed Codex"' \
      --config 'model_providers.gitlab.base_url="https://cloud.jihulab.com/ai/v1/proxy/openai/v1"' \
      --config 'model_providers.gitlab.env_key="OPENAI_API_KEY"' \
      --config 'model_providers.gitlab.wire_api="responses"' \
      --config "model_providers.gitlab.http_headers=${header_str}" \
      --dangerously-bypass-approvals-and-sandbox "
    You are an AI assistant helping with GitLab operations.

    Context: $AI_FLOW_CONTEXT
    Task: $AI_FLOW_INPUT
    Event: $AI_FLOW_EVENT

    Please execute the requested task using the available GitLab tools.
    Be thorough in your analysis and provide clear explanations.

    <important>
    Use the glab CLI to access data from GitLab. The glab CLI has already been authenticated. You can run the corresponding commands.

    When you complete your work create a new Git branch, if you aren't already working on a feature branch, with the format of 'feature/<short description of feature>' and check in/push code.

    When you check in and push code, you will need to use the access token stored in GITLAB_TOKEN and the user Codex.
    Lastly, after pushing the code, if a merge request doesn't already exist, create a new merge request for the branch and link it to the issue using:
    glab mr create --title \"<title>\" --description \"<desc>\" --source-branch \"<branch>\" --target-branch \"<branch>\"

    If you are asked to summarize a merge request or issue, or asked to provide more information then please post back a note to the merge request / issue so that the user can see it.

    </important>
    "
variables:
  - GITLAB_TOKEN_CODEX
  - GITLAB_HOST
```

<a id="opencode"></a>

#### Opencode

```yaml
image: node:22-slim
commands:
  - echo "正在安装 opencode"
  - npm install --global opencode-ai
  - echo "正在安装 glab"
  - export GITLAB_TOKEN=$GITLAB_TOKEN_OPENCODE
  - apt-get update --quiet && apt-get install --yes curl wget gpg git && rm --recursive --force /var/lib/apt/lists/*
  - curl --silent --show-error --location "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | bash
  - apt-get install --yes glab
  - echo "正在配置 glab"
  - echo $GITLAB_HOST
  - echo "正在创建 opencode 身份配置"
  - echo "正在配置 git"
  - git config --global user.email "opencode@gitlab.com"
  - git config --global user.name "Opencode"
  - echo "正在测试 glab"
  - glab issue list
  - echo "正在运行 Opencode"
  - |
    opencode run "
    You are an AI assistant helping with GitLab operations.

    Context: $AI_FLOW_CONTEXT
    Task: $AI_FLOW_INPUT
    Event: $AI_FLOW_EVENT

    Please execute the requested task using the available GitLab tools.
    Be thorough in your analysis and provide clear explanations.

    <important>
    Use the glab CLI to access data from GitLab. The glab CLI has already been authenticated. You can run the corresponding commands.

    When you complete your work create a new Git branch, if you aren't already working on a feature branch, with the format of 'feature/<short description of feature>' and check in/push code.

    When you check in and push code, you will need to use the access token stored in GITLAB_TOKEN and the user ClaudeCode.
    Lastly, after pushing the code, if a merge request doesn't already exist, create a new merge request for the branch and link it to the issue using:
    `glab mr create --title "<title>" --description "<desc>" --source-branch <branch> --target-branch <branch>`

    If you are asked to summarize a merge request or issue, or asked to provide more information then please post back a note to the merge request / issue so that the user can see it.

    </important>
    "
variables:
  - ANTHROPIC_API_KEY
  - GITLAB_TOKEN_OPENCODE
  - GITLAB_HOST
```

<a id="google-gemini-cli"></a>

#### 国内 SOTA 模型 CLI

```yaml
image: node:22-slim
commands:
  - echo "正在安装 glab"
  - export GITLAB_TOKEN=$GITLAB_TOKEN_GEMINI
  - apt-get update --quiet && apt-get install --yes curl wget gpg git unzip && rm --recursive --force /var/lib/apt/lists/*
  - curl --silent --show-error --location "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | bash
  - apt-get install --yes glab
  - echo "正在安装 gemini 客户端"
  - npm install --global @google/gemini-cli
  - echo $GOOGLE_CREDENTIALS > /root/credentials.json
  - echo "正在配置 git"
  - git config --global user.email "gemini@gitlab.com"
  - git config --global user.name "Gemini"
  - echo "正在运行 gemini"
  - |
    GOOGLE_GENAI_USE_VERTEXAI=true GOOGLE_APPLICATION_CREDENTIALS=/root/credentials.json gemini --yolo --debug --prompt "
    You are an AI assistant helping with GitLab operations.

    Context: $AI_FLOW_CONTEXT
    Task: $AI_FLOW_INPUT
    Event: $AI_FLOW_EVENT

    Please execute the requested task using the available GitLab tools.
    Be thorough in your analysis and provide clear explanations.

    <important>
    Use the glab CLI to access data from GitLab. The glab CLI has already been authenticated. You can run the corresponding commands.

    When you complete your work create a new Git branch, if you aren't already working on a feature branch, with the format of 'feature/<short description of feature>' and check in/push code.

    When you check in and push code you will need to use the access token stored in GITLAB_TOKEN and the user ClaudeCode.
    Lastly, after pushing the code, if a merge request doesn't already exist, create a new merge request for the branch and link it to the issue using:
    `glab mr create --title "<title>" --description "<desc>" --source-branch <branch> --target-branch <branch>`

    If you are asked to summarize a merge request or issue, or asked to provide more information then please post back a note to the merge request / issue so that the user can see it.

    </important>
    "
variables:
  - GITLAB_TOKEN_GEMINI
  - GITLAB_HOST
  - GOOGLE_CREDENTIALS
  - GOOGLE_CLOUD_PROJECT
  - GOOGLE_CLOUD_LOCATION
```

<a id="create-a-flow-trigger"></a>

## 创建流程触发器

{{< history >}}

- 在 极狐GitLab 18.5 中引入 **指派（Assign）** 事件类型

{{< /history >}}

先决条件：

- 你必须至少拥有该项目的 维护者 角色

流程触发器用于将服务账号、流程配置文件以及用户触发 CLI 代理的动作关联起来

创建流程触发器：

1. 在左侧边栏，选择 **搜索或跳转到** 并找到你的项目
1. 选择 **自动化** > **流程触发器**
1. 选择 **新建流程触发器**
1. 完成以下字段：
   - 在 **描述** 中，为流程触发器输入描述
   - 在 **事件类型** 下拉列表中，选择一个或多个事件类型：
     - **提及（Mention）**：当在议题或合并请求的评论中提及该服务账号用户时触发
     - **指派（Assign）**：当将该服务账号用户指派给议题或合并请求时触发
   - 在 **服务账号用户** 下拉列表中，选择服务账号用户
   - 在 **配置路径** 中，输入流程配置文件的位置（例如 `.gitlab/duo/flows/claude.yaml`）
1. 选择 **创建流程触发器**

你已创建流程触发器。检查其是否显示在 **自动化** > **流程触发器** 中

现在，你可以在评论中通过其服务账号用户名来提及该 CLI 代理以完成任务。CLI 代理随后会根据用户定义的流程触发器尝试完成该任务

<a id="edit-a-flow-trigger"></a>

### 编辑流程触发器

1. 在左侧边栏，选择 **搜索或跳转到** 并找到你的项目
1. 选择 **自动化** > **流程触发器**
1. 在你想要更改的流程触发器上，选择 **编辑流程触发器**（{{< icon name="pencil" >}}）
1. 完成更改并选择 **保存更改**

<a id="delete-a-flow-trigger"></a>

### 删除流程触发器

1. 在左侧边栏，选择 **搜索或跳转到** 并找到你的项目
1. 选择 **自动化** > **流程触发器**
1. 在你想要更改的流程触发器上，选择 **删除流程触发器**（{{< icon name="remove" >}}）
1. 在确认对话框中，选择 **确定**

<a id="use-the-cli-agent"></a>

## 使用 CLI 代理

先决条件：

- 你必须至少拥有该项目的 开发者 角色

1. 在你的项目中，打开一个议题、合并请求或史诗
1. 在你希望 CLI 代理完成的任务上添加评论，并提及该服务账号用户。例如：

   ```markdown
   @service-account-username 你能帮助分析这个代码变更吗？
   ```

1. 在你的评论下方，CLI 代理会回复 **正在处理请求并启动代理...**
1. 当 CLI 代理正在工作时，会显示评论 **代理已启动。你可以在此处查看进度**。你可以选择 **此处** 查看进行中的流水线
1. 当 CLI 代理完成任务后，你会看到确认信息，以及一个可合并的变更或一条行内评论

