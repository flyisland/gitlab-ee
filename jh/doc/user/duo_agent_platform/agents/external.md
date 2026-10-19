---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部 Agent
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- 不适用于自部署模型的极狐GitLab Duo

{{< /collapsible >}}

> [!flag]
> 此功能的可用性由功能标志控制，并已为已验证的客户启用。
> 要为您的客户命名空间或极狐GitLab 实例启用外部 Agent，请联系极狐GitLab 支持。

极狐GitLab Duo Agent 并行工作，帮助您同时创建代码、研究结果并执行任务。

您可以创建一个 Agent，并将其与外部 AI 模型提供商集成，以根据您组织的需求进行自定义。然后，在项目议题、史诗或合并请求中，您可以在评论或讨论中提及该外部 Agent，并要求该 Agent 完成某项任务。

外部 Agent：

- 读取并分析周围的上下文和代码仓库代码。
- 决定要采取的适当操作，同时遵守项目权限并保留审计事件记录。
- 运行 CI/CD 流水线，并在极狐GitLab 内以可合并的变更或行内评论的形式进行响应。

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../_index.md#prerequisites)。
- 已[开启任务流执行](../flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 已[开启外部 Agent](#turn-external-agents-on-or-off)。

<a id="security-considerations"></a>

## 安全注意事项

外部 Agent 与第三方 AI 模型提供商集成，其安全特性与极狐GitLab 内置 Agent 和任务流不同。使用外部 Agent 即表示您接受以下风险：

- **提示注入漏洞**：极狐GitLab 实现了第三方提示扫描，以降低提示注入的风险。此扫描不适用于外部 Agent。
- **第三方提供商依赖**：所有安全控制（包括提示扫描、监控和告警）均由外部 AI 模型提供商管理，而非极狐GitLab。
- **网络访问**：外部 Agent 会向第三方 AI 提供商发起网络调用。发送给这些提供商的数据受其安全策略和数据处理实践约束。
- **隔离有限**：外部 Agent 不具备应用于极狐GitLab 原生 Agent 和任务流的同等网络隔离和安全限制。

在您的组织中启用外部 Agent 之前，请审查您的安全要求以及您所选 AI 模型提供商提供的安全文档。

有关 Duo Agent Platform 中安全威胁和缓解措施的更广泛概述，请参阅 [Duo Agent Platform 安全威胁文档](../security_threats.md)。

<a id="quickstart-for-gitlab-managed-external-agents"></a>

## 极狐GitLab 管理的外部 Agent 快速入门

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

以下集成已由 GitLab 测试并可用：

- [Claude Code](https://code.claude.com/docs/en/overview)
- OpenAI Codex
- [Amazon Q](https://aws.amazon.com/q/)
- Gemini

在您创建 Agent 并将其与外部 AI 模型提供商集成之前，您必须满足[极狐GitLab Duo Agent Platform 的先决条件](../_index.md#prerequisites)。

受管外部 Agent 可以使用极狐GitLab 管理的凭据，并可在群组中启用，无需额外的 Agent 配置。

启用和使用受管 Agent 所需的步骤：

1. 在 AI 目录中访问该 Agent。搜索 Agent 名称，或使用直接 URL。

   极狐GitLab 管理的外部 Agent 会显示 GitLab 维护徽章（{{< icon name="tanuki-verified" >}}）。

1. [启用该 Agent](#enable-the-agent)。
1. 在议题、史诗或合并请求中[使用该外部 Agent](#use-an-external-agent)。

<a id="claude-code-agent"></a>

### Claude Code Agent

[由 GitLab 提供的 Claude Code Agent](https://gitlab.com/explore/ai-catalog/agents/2337/) 使用极狐GitLab 管理的凭据，无需额外配置。

<a id="codex-agent"></a>

### Codex Agent

[由 GitLab 提供的 Codex Agent](https://gitlab.com/explore/ai-catalog/agents/2334/) 使用极狐GitLab 管理的凭据，无需额外配置。

<a id="amazon-q-developer-agent"></a>

### Amazon Q Developer Agent

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

[Amazon Q Developer Agent](https://gitlab.com/explore/ai-catalog/agents/2332/) 不使用极狐GitLab 管理的凭据。要使用此 Agent，您必须提供自己的凭据。

要使用 Amazon Q Developer Agent：

- 将以下环境变量添加到项目的 CI/CD 设置中：

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION_NAME`
  - `AMAZON_Q_SIGV4`

<a id="develop-with-gemini-agent"></a>

### Develop with Gemini Agent

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

Develop with Gemini Agent 不使用极狐GitLab 管理的凭据。要使用此 Agent，您必须提供自己的凭据。

要使用 Develop with Gemini Agent：

- 将以下环境变量添加到项目的 CI/CD 设置中：

  - `GOOGLE_CREDENTIALS` - 添加 Google 凭据 JSON 文件的位置。有关详情，请参阅 [`GOOGLE_APPLICATION_CREDENTIALS` 环境变量](https://docs.cloud.google.com/docs/authentication/application-default-credentials#GAC)。
  - `GOOGLE_CLOUD_PROJECT`
  - `GOOGLE_CLOUD_LOCATION`

<a id="add-gitlab-managed-agents-to-other-instances"></a>

### 将极狐GitLab 管理的 Agent 添加到其他实例

{{< details >}}

- Offering: 私有化部署
- Status: 实验

{{< /details >}}

管理员可以将 Claude Agent 和 Codex Agent 添加到他们的极狐GitLab 实例中。

先决条件：

- 您必须是管理员。

要将外部 Agent 添加到您的实例：

{{< tabs >}}

{{< tab title="极狐GitLab UI" >}}

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **极狐GitLab 管理的外部 Agent** 下，选择 **添加到 AI 目录**。

{{< /tab >}}

{{< tab title="Rake task" >}}

对于 Linux 软件包（Omnibus）：

```shell
sudo gitlab-rake gitlab:ai_catalog:seed_external_agents
```

对于自行编译（源代码）：

```shell
bundle exec rake gitlab:ai_catalog:seed_external_agents
```

{{< /tab >}}

{{< /tabs >}}

您也可以使用 [API](../../../api/admin/ai_catalog.md) 添加外部 Agent。

<a id="access-credentials"></a>

### 访问凭据

外部 Agent 通过 AI 网关使用极狐GitLab 管理的凭据。

当您使用极狐GitLab 管理的凭据时：

- 在外部 Agent 配置中设置 `injectGatewayToken: true`。
- 将外部 Agent 配置为使用极狐GitLab AI 网关代理端点。

当 `injectGatewayToken` 为 `true` 时，会自动注入以下环境变量：

- `AI_FLOW_AI_GATEWAY_TOKEN`：AI 网关的身份验证令牌
- `AI_FLOW_AI_GATEWAY_HEADERS`：用于 API 请求的格式化请求头

极狐GitLab 管理的凭据仅适用于 Anthropic Claude 和 OpenAI Codex。

要对 Agent 进行极狐GitLab API 身份验证，请参阅[向极狐GitLab API 进行身份验证](#authenticate-to-the-gitlab-api)。

<a id="supported-models"></a>

### 支持的模型

对于极狐GitLab 管理的凭据，支持以下 AI 模型：

Anthropic Claude：

- `claude-haiku-4-5-20251001`
- `claude-opus-4-5-20251101`
- `claude-opus-4-6`
- `claude-sonnet-4-20250514`
- `claude-sonnet-4-5-20250929`
- `claude-sonnet-4-6`

OpenAI Codex：

- `gpt-5`
- `gpt-5-mini-2025-08-07`
- `gpt-5.1`
- `gpt-5.1-2025-11-13`
- `gpt-5.2-2025-12-11`
- `gpt-5.3-codex`
- `gpt-5.4-2026-03-05`
- `gpt-5.4-mini`
- `gpt-5.4-nano`

<a id="configure-cicd-variables"></a>

## 配置 CI/CD 变量

将变量添加到您的项目，以确定极狐GitLab 如何连接到第三方提供商。

先决条件：

- 您必须具有项目的维护者或所有者角色。

要在项目设置中添加或更新变量：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**并填写字段：
   - **类型**：选择**变量（默认）**。
   - **环境**：选择**所有（默认）**。
   - **可见性**：选择所需的可见性。

     对于 API 密钥和个人访问令牌变量，请选择**掩码**或**掩码且隐藏**。
   - 清除**保护变量**复选框。
   - 清除**展开变量引用**复选框。
   - **描述（可选）**：输入变量描述。
   - **键**：输入 CI/CD 变量的环境变量名称（例如 `GITLAB_HOST`）。
   - **值**：API 密钥、个人访问令牌或主机的值。
1. 选择**添加变量**。

有关更多信息，请参阅如何[将 CI/CD 变量添加到项目设置中](../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)。

<a id="cicd-variables-for-external-agents"></a>

### 外部 Agent 的 CI/CD 变量

以下 CI/CD 变量可用：

| 集成                | 环境变量         | 描述 |
|----------------------------|------------------------------|-------------|
| 全部                        | `GITLAB_TOKEN_<integration>` | 服务账号用户的个人访问令牌。 |
| 全部                        | `GITLAB_HOST`                | 极狐GitLab 实例主机名（例如 `gitlab.com`）。 |
| 全部                        | `ADDITIONAL_INSTRUCTIONS`    | Agent 在提示中包含的附加指令。 |
| Amazon Q                   | `AWS_SECRET_NAME`            | AWS 密钥管理器密钥名称。 |
| Amazon Q                   | `AWS_REGION_NAME`            | AWS 区域名称。 |
| Amazon Q                   | `AMAZON_Q_SIGV4`             | Amazon Q Sig V4 凭据。 |
| Google Gemini CLI          | `GOOGLE_CREDENTIALS`         | JSON 凭据文件内容。 |
| Google Gemini CLI          | `GOOGLE_CLOUD_PROJECT`       | Google Cloud 项目 ID。 |
| Google Gemini CLI          | `GOOGLE_CLOUD_LOCATION`      | Google Cloud 项目位置。 |

<a id="authenticate-to-the-gitlab-api"></a>

## 向极狐GitLab API 进行身份验证

每个外部 Agent 都会收到一个极狐GitLab OAuth 令牌，并将其设置为环境变量 `AI_FLOW_GITLAB_TOKEN`。这些令牌仅限于授予它们的范围。它们只能访问[具有 `ai_workflows` 范围的极狐GitLab API 端点](../flows/foundational_flows/software_development.md#apis-that-the-flow-has-access-to)。即使令牌发送正确，该范围之外的端点也会被拒绝。

要从外部 Agent 调用极狐GitLab API，请将 `AI_FLOW_GITLAB_TOKEN` 作为 `Authorization: Bearer` 令牌发送。如果您使用 `PRIVATE-TOKEN` 请求头发送令牌，API 会返回 `401 Unauthorized`。

```shell
curl --header "Authorization: Bearer $AI_FLOW_GITLAB_TOKEN" \
  "https://$AI_FLOW_GITLAB_HOSTNAME/api/v4/user"
```

要在您的 Agent 中使用 `glab` CLI，请将令牌写入 `~/.config/glab-cli/config.yml` 并设置 `is_oauth2: "true"`，以便 `glab` 正确发送令牌：

```yaml
hosts:
  $AI_FLOW_GITLAB_HOSTNAME:
    token: $AI_FLOW_GITLAB_TOKEN
    is_oauth2: "true"
```

极狐GitLab 管理的 Claude 和 Codex Agent 使用相同的模式。
有关可用的示例，请参阅[外部 Agent 配置示例](external_examples.md)。

<a id="authenticate-with-id-tokens"></a>

## 使用 ID 令牌进行身份验证

要使用第三方 OpenID Connect (OIDC) 服务对自定义外部 Agent 进行身份验证，
请在 Agent 配置中声明 [ID 令牌](../../../ci/secrets/id_token_authentication.md)。
极狐GitLab CI/CD 会生成一个签名的 JSON Web 令牌 (JWT) 并将其注入到 Agent 作业中。

使用 ID 令牌进行身份验证，无需存储长期凭据。例如，您可以从密钥管理器中检索密钥或对产物进行签名。

要配置 ID 令牌，请将 `id_tokens` 块添加到外部 Agent 配置中。每个令牌都需要一个 `aud`（受众）声明：

```yaml
injectGatewayToken: true
image: node:22-slim
commands:
  - my-authentication-script.sh "$VAULT_ID_TOKEN"
id_tokens:
  VAULT_ID_TOKEN:
    aud: https://vault.example.com
```

`aud` 声明可以是单个字符串或字符串列表。每个令牌在 Agent 作业中作为环境变量可用，该环境变量使用令牌的名称。

> [!warning]
> ID 令牌是一种凭据，可授予对任何信任其 `aud` 声明的服务的访问权限。
> 为每个令牌设置尽可能窄的 `aud` 值。

有关令牌负载的更多信息，请参阅
[使用 ID 令牌进行 OpenID Connect (OIDC) 身份验证](../../../ci/secrets/id_token_authentication.md)。

<a id="enable-the-agent"></a>

## 启用该 Agent

启用 Agent，以便从议题、合并请求或讨论中触发它。

当您在项目中启用某个 Agent 时，它同时会在该项目的顶级群组中启用。

先决条件：

- 您必须具有项目的维护者或所有者角色。

{{< tabs >}}

{{< tab title="从管理项目" >}}

要启用外部 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
1. 选择**受管**标签页，然后选择您要启用的 Agent。
1. 在右上角，选择**启用**。
1. 在**项目**下，选择您要在其中启用该 Agent 的项目。
1. 对于**添加触发器**，选择：
   - 一个或多个[触发事件类型](../triggers/_index.md#trigger-event-types)。
   - 如果触发事件类型需要，选择一个触发事件操作。
1. 选择**启用**。

{{< /tab >}}

{{< tab title="从 AI Catalog" >}}

要启用外部 Agent：

1. 在顶部栏中，选择**搜索或跳转到** > **探索**。
1. 选择 **AI 目录**，然后选择 **Agents** 标签页。
1. 选择您要启用的 Agent。
1. 在右上角，选择**启用**。
1. 在**项目**下，选择您要在其中启用该 Agent 的项目。

   要为多个项目开启公共或受限 Agent，请从**项目**下拉列表中
   选择相关项目。您最多可以选择 100 个项目。

1. 对于**添加触发器**，选择：
   - 一个或多个[触发事件类型](../triggers/_index.md#trigger-event-types)。
   - 如果触发事件类型需要，选择一个触发事件操作。
1. 选择**启用**。

{{< /tab >}}

{{< /tabs >}}

该外部 Agent 会出现在群组和项目的 **AI** > **Agents** 页面中。顶级群组中任何项目的成员现在都可以在其项目中启用该 Agent。

群组中会创建一个服务账号。该账号的名称遵循以下命名约定：`ai-<agent>-<group>`。

<a id="enable-in-a-project"></a>

## 在项目中启用

如果外部 Agent 已在顶级群组中启用，您可以在该群组的项目中启用它。

先决条件：

- 您必须具有项目的维护者或所有者角色。
- 该 Agent 必须已在项目的顶级群组中启用。

要在项目中启用外部 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
1. 在右上角，选择**从群组启用 Agent**。
1. 从下拉列表中，选择您要启用的外部 Agent。
1. 对于**添加触发器**，选择：
   - 一个或多个[触发事件类型](../triggers/_index.md#trigger-event-types)。
   - 如果触发事件类型需要，选择一个触发事件操作。
1. 选择**启用**。

该外部 Agent 会出现在项目的 **AI** > **Agents** 列表中。

顶级群组的服务账号会添加到该项目中。该账号被分配开发者角色。

<a id="use-an-external-agent"></a>

## 使用外部 Agent

先决条件：

- 您必须具有项目的开发者、维护者或所有者角色。
- 对于极狐GitLab 管理的外部 Agent 和在 AI 目录中创建的自定义外部 Agent，该外部 Agent 必须在您的项目中启用。
- 要允许该 Agent 推送到 Agent 创建的分支（以 ^duo/(fix|feature|refactor|docs/).*` 开头的分支），您可能需要创建[分支规则](../../project/repository/branches/branch_rules.md)。

1. 在您的项目中，打开一个议题、合并请求或史诗。
1. 提及、指派服务账号用户，或请求其进行评审。
   例如：

   ```plaintext
   @service-account-username Can you help analyze this code change?
   ```

1. 外部 Agent 完成任务后，您会看到确认信息，以及可合并的变更或行内评论。

<a id="create-a-custom-external-agent"></a>

## 创建自定义外部 Agent

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

在极狐GitLab 私有化部署上，如果启用了 `ai_catalog_create_third_party_flows` 功能标志，您可以使用 AI 目录创建外部 Agent，并将其配置为在您的环境中运行。

在 JihuLab.com 上，您无法创建自定义外部 Agent。
请改用[极狐GitLab 管理的外部 Agent](#quickstart-for-gitlab-managed-external-agents)。

推荐的工作流是：

1. 在 AI 目录中创建该 Agent。
1. 为您的项目启用该 Agent，并指定一个触发器，以确定您如何调用该 Agent。

在这种情况下，系统会为您创建一个服务账号。当该 Agent 运行时，它会结合使用用户的成员资格和服务账号的成员资格。这种组合称为[复合身份](../composite_identity.md)。

如果您愿意，也可以[手动创建外部 Agent](#create-an-external-agent-manually)。

<a id="agent-visibility"></a>

### Agent 可见性

创建自定义外部 Agent 时，您需要选择一个项目来管理它，并选择该 Agent 是公共、私有还是受限。

公共 Agent：

- 任何人都可以查看，并可在任何满足先决条件的项目中启用。

受限 Agent：

- 可由管理项目的顶级群组中任何项目的成员查看和使用。
- 可在同一顶级群组中的其他项目中启用。
- 无法在该顶级群组之外查看或开启。
- 无法在探索中的 AI 目录中查看。
- 只能从项目创建，不能从探索中的 AI 目录创建。

如果某个公共 Agent 已被该顶级群组之外的项目开启，则无法将其设为受限。

私有 Agent：

- 只能由管理项目中具有访客、计划者、
  报告者、开发者、维护者或所有者角色的成员查看。
- 无法在管理项目以外的项目中启用。

如果某个公共或受限 Agent 已被管理项目以外的项目开启，则无法将其设为私有。

<a id="create-the-agent-in-the-ai-catalog"></a>

### 在 AI 目录中创建该 Agent

首先在 AI 目录中创建外部 Agent。

先决条件：

- 您必须具有项目的维护者或所有者角色。

要创建外部 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
1. 选择**新建 Agent**。
1. 在**基本信息**下：
   1. 在**显示名称**中，输入一个名称。
   1. 在**描述**中，输入一个描述。
1. 在**可见性与访问权限**下，对于**可见性**，选择**私有**、**受限**或**公共**。
1. 在**配置**下：
   1. 选择**外部**。
   1. 输入您的外部 Agent 配置。
      您可以编写自己的 YAML，或编辑示例配置。
1. 选择**创建 Agent**。

该外部 Agent 会出现在 AI 目录中。

YAML 配置有最大大小限制。有关更多信息，请参阅[配置大小限制](../ai_catalog.md#configuration-size-limits)。

<a id="create-an-external-agent-manually"></a>

### 手动创建外部 Agent

如果您不想遵循 UI 流程，可以手动创建外部 Agent：

1. 在您的项目中创建一个配置文件。
1. 创建一个服务账号。
1. 创建一个触发器，以确定您如何调用该 Agent。
1. 使用该 Agent。

在这种情况下，您需要手动创建用于运行该 Agent 的服务账号。

<a id="create-a-configuration-file"></a>

#### 创建配置文件

如果您通过手动添加配置文件来创建外部 Agent，则必须为每个外部 Agent 创建不同的配置文件。

先决条件：

- 您必须具有项目的开发者、维护者或所有者角色。

要创建配置文件：

1. 在您的项目中，创建一个 YAML 文件，例如：`.gitlab/duo/flows/claude.yaml`
1. 使用[其中一个配置文件示例](external_examples.md)填充该文件。

<a id="create-a-service-account"></a>

#### 创建服务账号

您必须创建一个[服务账号](../../profile/service_accounts.md)，该账号有权访问您预期使用外部 Agent 的项目。

当该 Agent 运行时，它会结合使用用户的成员资格和服务账号的成员资格。这种组合称为[复合身份](../composite_identity.md)。

先决条件：

- 在极狐GitLab 私有化部署上，您必须具有以下之一：
  - 对实例的管理员访问权限。
  - 顶级群组的所有者角色，以及
    [创建服务账号的权限](../../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)。

每个提及外部 Agent 的项目都必须有一个唯一的[群组服务账号](../../profile/service_accounts.md)。在向外部 Agent 分配任务时，请提及该服务账号的用户名。

如果您从 AI 目录创建外部 Agent 并在顶级群组中启用它，系统会自动创建一个名为 `ai-<agent>-<group>` 的服务账号。例如，如果您在 `GitLab Duo` 群组中启用一个名为 `Claude code agent`的 Agent，则服务账号名称为 `ai-claude-code-agent-gitlab-duo`。

> [!warning]
> 如果您在多个项目中使用了同一个服务账号，那么附加到该服务账号的外部 Agent 将有权访问所有这些项目。

要设置服务账号，请执行以下操作。如果您没有足够的权限，请向您的实例管理员或顶级群组所有者寻求帮助。

1. 为顶级群组[创建服务账号](../../profile/service_accounts.md#create-a-service-account)。
   为实例创建的服务账号不受支持。

   > [!note]
   > 当您将现有服务账号配置为外部 Agent 时，
   > 无法将任何个人访问令牌与该账号关联。
   > 此行为旨在确保服务账号的安全。

1. 为服务账号[创建个人访问令牌](../../profile/service_accounts.md#create-a-personal-access-token-for-a-service-account)，并具有以下[范围](../../../security/tokens/access_token_scopes.md)：
   - `write_repository`
   - `api`
   - `ai_features`
1. 以开发者角色[将服务账号添加到您的项目](../../project/members/_index.md#add-users-to-a-project)。
   这可确保服务账号具有所需的最低权限。

将服务账号添加到您的项目时，您必须输入服务账号的准确名称。如果您输入错误的名称，外部 Agent 将无法工作。

<a id="create-a-trigger"></a>

#### 创建触发器

您现在必须[创建一个触发器](../triggers/_index.md)，以确定外部 Agent 何时运行。

例如，您可以指定当您在讨论中提及某个服务账号，或将服务账号指派为审核人时触发该 Agent。

<a id="turn-external-agents-on-or-off"></a>

## 开启或关闭外部 Agent

默认情况下，外部 Agent 处于开启状态。您可以为顶级群组或实例开启或关闭它们。

当外部 Agent 关闭时：

- 用户无法创建、启用、禁用、修改或执行外部 Agent。
  这包括极狐GitLab 管理的外部 Agent 和自定义外部 Agent。
- 现有外部 Agent 不再显示在
  项目的 **AI** > **Agents** > **已启用**下。
- 在项目中创建的外部 Agent 会显示在
  **AI** > **Agents** > **受管**下，但无法修改或执行。
- [自定义 Agent](custom.md) 和[内置 Agent](foundational_agents/_index.md) 仍然可用。

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 您必须具有该群组的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**自定义和外部 Agent 及任务流**下，选中或清除
   **允许外部 Agent** 复选框。
1. 选择**保存更改**。

此设置会级联到该群组中的所有子群组。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**自定义和外部 Agent 及任务流**下，选中或清除
   **允许外部 Agent** 复选框。
1. 选择**保存更改**。

当实例级设置关闭时，
群组级设置无法覆盖它。

{{< /tab >}}

{{< /tabs >}}
