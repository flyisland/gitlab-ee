---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Agent 技能
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中添加了对工作区级别 Agent 技能的支持。
  - 在极狐GitLab Duo CLI 8.73.0 中引入。
- 在极狐GitLab 19.0 中引入了对用户级别 Agent 技能的支持。
  - 在极狐GitLab Duo CLI 8.83.0 中作为[实验](../../../policy/development_stages_support.md#experiment)引入。

{{< /history >}}

极狐GitLab Duo 支持 [Agent Skills 规范](https://agentskills.io/specification)，这是一个为 Agent 赋予新能力和专业知识的新兴标准。

使用 Agent 技能可为 Agent 提供针对特定任务（例如使用特定框架编写测试）的专业知识和工作流。Agent 在遇到任务时会自动加载相关技能，并在工作中使用这些信息。

当你指定 `SKILL.md` 文件后，这些技能即可供极狐GitLab Duo Agent Platform 以及任何其他支持该规范的 AI 工具使用。

为极狐GitLab Duo 指定 Agent 技能，以便在以下场景中使用：

- 本地环境中的极狐GitLab Duo Chat。
- 基础流和自定义流（不包括代码审查流）。

用户级别技能仅可用于极狐GitLab Duo CLI。

<a id="how-gitlab-duo-uses-agent-skills"></a>

## 极狐GitLab Duo 如何使用 Agent 技能

当 Agent 开始工作时，极狐GitLab Duo 会将所有可用技能的元数据添加到 Agent 的上下文中。当 Agent 遇到与技能描述匹配的任务时，它会自动加载该技能并使用它来完成任务。

你也可以手动指示极狐GitLab Duo 按名称、文件路径或斜杠命令使用某个技能。

极狐GitLab Duo 支持以下类型的技能：

| 级别 | 极狐GitLab UI | 极狐GitLab Duo CLI |
|------|---------------|-------------------|
| 用户级别：应用于所有项目及 IDE 工作区 | {{< no >}} | {{< yes >}} |
| 工作区级别：仅应用于特定项目或 IDE 工作区 | {{< yes >}} <sup>1</sup> | {{< yes >}} |

**脚注**：

1. 在极狐GitLab UI 中，仅基础流和自定义流（不包括代码审查）支持工作区级别技能。极狐GitLab UI 中的极狐GitLab Duo Chat 不支持技能。

<a id="use-agent-skills-with-gitlab-duo"></a>

## 使用 Agent 技能与极狐GitLab Duo

> [!note]
> 现有会话和流不会自动获取新增或更新的技能。
> 请开启新会话，或要求极狐GitLab Duo 按名称或相对路径加载技能。

<a id="prerequisites"></a>

### 前提条件

- 满足[Agent Platform 前提条件](../_index.md#prerequisites)。
- 对于本地环境中的极狐GitLab Duo Chat，请安装并配置以下之一：
  - 对于工作区级别技能：
    - [极狐GitLab Duo CLI](../../gitlab_duo_cli/_index.md#set-up-the-gitlab-duo-cli) 8.73.0 或更高版本。
  - 对于用户级别技能：
    - [极狐GitLab Duo CLI](../../gitlab_duo_cli/_index.md#set-up-the-gitlab-duo-cli) 8.83.0 或更高版本。
- 对于使用自定义流的工作区级别技能，请更新流的配置文件以访问从执行器传递的 `workspace_agent_skills` 上下文：

  ```yaml
  components:
  - name: "my_agent"
     type: AgentComponent
     prompt_id: "my_prompt"
     inputs:
     - from: "context:inputs.workspace_agent_skills"
        as: "workspace_agent_skills"
      optional: true
  ```

  通过设置 `optional: true`，流可以优雅地处理不存在 Agent 技能的情况。
  无论是否有额外上下文，Agent 都能正常工作。

<a id="create-skills"></a>

### 创建技能

你可以在工作区级别或用户级别创建技能。

如果用户级别技能和工作区级别技能同名，则工作区级别技能优先。这允许你使用项目特定版本覆盖用户级别技能。

<a id="create-workspace-level-skills"></a>

#### 创建工作区级别技能

工作区级别技能应用于特定项目或工作区。你可以在项目的 `skills/<skill-name>/` 目录中的 `SKILL.md` 文件里定义它们。

要创建工作区级别技能：

1. 在项目工作区的根目录下，创建一个 `skills` 目录。
1. 在新目录中，为特定技能再创建一个目录。使用技能名称作为目录名。
1. 创建一个 `SKILL.md` 文件，并使用以下格式包含说明。
   `name` 和 `description` YAML 前置信息字段为必填项。

   ```markdown
   ---
   name: <skill_name>
   description: <skill_description>
   ---

   <your_instructions_and_context_for_the_skill>
   ```

   例如，在 `skills/cosign-blob/SKILL.md` 中用于[使用 cosign 签名产物](../../../ci/yaml/signing_examples.md)的技能：

   ````markdown
   ---
   name: cosign-blob
   description: 使用 cosign 通过本地密钥对和 Sigstore v3 捆绑包对产物进行签名。集成 1Password 以进行安全的密钥管理。
   ---

   ## Cosign Blob 签名

   使用 cosign 通过 Sigstore v3 捆绑包对产物进行本地签名，以实现产物验证和完整性。

   ### 生成本地密钥对

   生成一个新的 cosign 密钥对：

   ```shell
   cosign generate-key-pair
   ```

   这将创建两个文件：
   - `cosign.key` - 私钥（加密）
   - `cosign.pub` - 公钥

   将私钥安全存储，最好存储在如 1Password 这样的密码管理器中。

   ### 在 1Password 中存储私钥

   1. 在 1Password 中创建一个新的登录项，包含：
      - 标题：“Duo Skills cosign”
      - 用户名：（可选）
      - 密码：你的 cosign 私钥密码

   2. 保存密钥引用路径（例如，`op://Employee/Duo Skills cosign/password`）

   ### 使用 Cosign 签名产物

   签名文件并生成 Sigstore v3 捆绑包：

   ```shell
   COSIGN_PASSWORD=$(op read "op://Employee/Duo Skills cosign/password") \
     timeout -v 4 cosign sign-blob \
       --key ~/.gitlab/duo/cosign.key \
       --bundle <filename>.bundle \
       --new-bundle-format \
       --yes \
       <filename>
   ```

   替换：
   - `<filename>` 为要签名的文件（例如，`SKILL.md`）
   - 捆绑包输出将保存为 `<filename>.bundle`

   ### 关键点

   - 使用 timeout 实现快速失败并将错误报告给用户。
   - 对 Sigstore v3 捆绑包使用 `--bundle` 和 `$file.bundle` 格式
   - 使用 `--yes` 跳过交互式提示
   - 使用 `--new-bundle-format` 输出 v3 Sigstore 捆绑包而非旧格式
   - 设置 `COSIGN_PASSWORD` 环境变量以避免密码提示
   - 集成 1Password CLI 以实现安全的凭证管理
   - 捆绑包文件包含签名，可稍后进行验证
   ````

1. 保存文件。
1. 开始新的会话或流。每次更改或添加 `SKILL.md` 文件时，你都应执行此操作，以避免 Agent 出现上下文混淆。

<a id="create-user-level-skills"></a>

#### 创建用户级别技能

{{< details >}}

- 状态：实验

{{< /details >}}

用户级别技能应用于你的所有项目。你可以在主目录下的 `skills/<skill-name>/` 目录中的 `SKILL.md` 文件里定义它们。

用户级别技能仅可用于极狐GitLab Duo CLI。

##### 为用户级别技能创建目录

你可以在以下位置之一创建技能目录：

- 将技能与其他极狐GitLab Duo 自定义文件放在一起：
  - 对于 Linux 或 macOS，在 `~/.gitlab/duo/skills/` 创建目录。
  - 对于 Windows，在 `%APPDATA%\GitLab\duo\skills\` 创建目录。
  - 如果你设置了 `GLAB_CONFIG_DIR` 或 `XDG_CONFIG_HOME`，请使用 `$GLAB_CONFIG_DIR/skills/` 或 `$XDG_CONFIG_HOME/gitlab/duo/skills/`。如果两者都已设置，则 `GLAB_CONFIG_DIR` 优先。
- 与其他支持 Agent Skills 规范的 AI 工具共享技能：
  - 对于 Linux 或 macOS，在 `~/.agents/skills/` 创建目录。
  - 对于 Windows，在 `%USERPROFILE%\.agents\skills\` 创建目录。

##### 创建用户级别技能文件

要创建用户级别技能：

1. 启动极狐GitLab Duo CLI 时启用全局技能：

   {{< tabs >}}

   {{< tab title="glab" >}}

   ```shell
   glab duo cli --enable-global-skills
   ```

   {{< /tab >}}

   {{< tab title="duo" >}}

   ```shell
   duo --enable-global-skills
   ```

   {{< /tab >}}

   {{< /tabs >}}

   或者，设置环境变量：

   ```shell
   export GITLAB_ENABLE_GLOBAL_SKILLS=true
   ```

1. 在你的 `skills` 目录中，为特定技能再创建一个目录。
   使用技能名称作为目录名。例如，`~/.gitlab/duo/skills/<skill_name>/`。
1. 创建一个 `SKILL.md` 文件，并使用以下格式包含说明。
   `name` 和 `description` YAML 前置信息字段为必填项。

   ```markdown
   ---
   name: <skill_name>
   description: <skill_description>
   ---

   <your_instructions_and_context_for_the_skill>
   ```

1. 开始新的会话。该技能在任何项目中都可用。

<a id="expose-skills-as-slash-commands"></a>

### 将技能公开为斜杠命令

要将技能启用为自定义斜杠命令，请在 `SKILL.md` 文件的 YAML 前置信息中添加 `slash-command: enabled` 到元数据中：

```yaml
---
name: <skill_name>
description: <skill_description>
metadata:
  slash-command: enabled
---
```

添加元数据后，你可以在新会话中使用 `/<skill_name>` 来指示极狐GitLab Duo 使用该技能。例如，`/fix-bugs`。

<a id="use-skills-manually"></a>

### 手动使用技能

要指示极狐GitLab Duo 使用特定技能，请使用以下方法之一：

- 在提示词中指示极狐GitLab Duo 按名称或文件路径使用技能。
- 以技能的斜杠命令开始你的提示词。

要列出当前会话上下文中所有可用的技能，请使用 `/skills`。