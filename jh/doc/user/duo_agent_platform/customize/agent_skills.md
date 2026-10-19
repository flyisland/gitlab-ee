---
stage: Agent Foundations
group: Agent Developer
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Agent Skills
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Duo 支持 [Agent Skills 规范](https://agentskills.io/specification)，这是一项
为 Agent 赋予新能力和专业知识的新兴标准。

使用 Agent Skills 可为 Agent 提供针对特定任务的专门知识和工作流，例如使用特定框架编写测试。Agent 在遇到任务时会自动加载相关 skills，并在工作过程中使用这些信息。

当您指定 `SKILL.md` 文件后，这些 skills 可供极狐GitLab Duo Agent Platform 以及任何
其他支持该规范的 AI 工具使用。

您还可以将 skills 作为极狐GitLab Duo CLI 插件的一部分进行分发和安装。更多
信息，请参见[极狐GitLab Duo CLI 插件](../../gitlab_duo_cli/customize.md#plugins)。

为极狐GitLab Duo 指定 Agent Skills，以便与以下内容配合使用：

- 本地环境中的极狐GitLab Duo Chat。
- 内置任务流和自定义任务流，代码评审任务流除外。

用户级 skills 仅可与极狐GitLab Duo CLI 配合使用。

<a id="how-gitlab-duo-uses-agent-skills"></a>

## 极狐GitLab Duo 如何使用 Agent Skills

当 Agent 开始工作时，极狐GitLab Duo 会将所有可用 skills 的元数据添加到 Agent 的
上下文中。当 Agent 遇到与某个 skill 描述匹配的任务时，它会自动加载该 skill 并使用它来完成任务。

您也可以通过名称、文件路径或斜杠命令手动指示极狐GitLab Duo 使用某个 skill。

极狐GitLab Duo 支持以下类型的 skills：

| 级别                                                              | 极狐GitLab UI | 编辑器扩展 | 极狐GitLab Duo CLI |
|--------------------------------------------------------------------|-------------------------------|-------------------|----------------|
| 用户级：应用于您的所有项目      | {{< no >}}                    | {{< no >}}        | {{< yes >}}    |
| 项目级：仅应用于特定项目 | {{< yes >}} <sup>1</sup>                   | {{< yes >}}       | {{< yes >}}    |

**脚注**：

1. 在极狐GitLab UI 中，只有内置任务流和自定义任务流（代码评审除外）支持项目级
   skills。极狐GitLab UI 中的极狐GitLab Duo Chat 不支持 skills。

<a id="use-agent-skills-with-gitlab-duo"></a>

## 将 Agent Skills 与极狐GitLab Duo 配合使用

> [!note]
> 现有对话和任务流不会自动获得新增或更新的 skills。
> 请开始新对话，或要求极狐GitLab Duo 按名称或相对路径加载某个 skill。

<a id="prerequisites"></a>

### 先决条件

- 满足 [Agent Platform 先决条件](../_index.md#prerequisites)。
- 对于本地环境中的极狐GitLab Duo Chat，请安装并配置以下之一：
  - 对于项目级 skills：
    - [GitLab for VS Code](../../../editor_extensions/visual_studio_code/setup.md) 6.71.4 或更高版本。
    - [极狐GitLab Duo CLI](../../gitlab_duo_cli/set_up.md) 8.73.0 或更高版本。
  - 对于用户级 skills：
    - [极狐GitLab Duo CLI](../../gitlab_duo_cli/set_up.md) 8.83.0 或更高版本。
- 对于使用自定义任务流的项目级 skills，请更新任务流的配置文件，以访问
  由执行器传入的 `workspace_agent_skills` 上下文：

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

  通过设置 `optional: true`，任务流可以妥善处理不存在任何 Agent skills 的情况。
  Agent 无论是否有额外上下文都能正常工作。

<a id="create-skills"></a>

### 创建 skills

您可以在项目级或用户级创建 skills。

如果您在 IDE 中使用多根工作区，可以为工作区中的每个项目创建项目级 skills。

如果用户级 skill 和项目级 skill 同名，则项目级 skill 优先。这样您就可以用项目专属版本覆盖用户级 skill。

在多根工作区中，如果多个项目定义了同名的 skills，极狐GitLab Duo 会加载它遇到的第一个。

<a id="create-project-level-skills"></a>

#### 创建项目级 skills

项目级 skills 应用于特定项目。您可以在项目的 `skills/<skill-name>/` 目录中的 `SKILL.md` 文件中定义它们。

创建项目级 skill：

1. 在项目的根目录中，创建一个 `skills` 目录。
1. 在新目录中，为该特定 skill 再创建一个目录。使用 skill 名称作为
   目录名称。
1. 创建一个 `SKILL.md` 文件，并使用以下格式添加指令。
   `name` 和 `description` YAML 前置信息字段为必填项。

   ```markdown
   ---
   name: <skill_name>
   description: <skill_description>
   ---

   <your_instructions_and_context_for_the_skill>
   ```

   例如，一个在
   `skills/cosign-blob/SKILL.md`中[使用 cosign 签名产物](../../../ci/yaml/signing_examples.md)的 skill：

    ````markdown
    ---
    name: cosign-blob
    description: Sign artifacts using cosign with local keypairs and Sigstore v3 bundles. Integrate with 1Password for secure key management.
    ---

    ## Cosign Blob Signing

    Sign artifacts locally using cosign with Sigstore v3 bundles for artifact verification and integrity.

    ### Generate a Local Keypair

    Generate a new cosign keypair:

    ```shell
    cosign generate-key-pair
    ```

    This creates two files:
    - `cosign.key` - Private key (encrypted)
    - `cosign.pub` - Public key

    Store the private key securely, preferably in a password manager like 1Password.

    ### Store Private Key in 1Password

    1. Create a new login item in 1Password with:
      - Title: "Duo Skills cosign"
      - Username: (optional)
      - Password: Your cosign private key password

    2. Save the secret reference path (for example, `op://Employee/Duo Skills cosign/password`)

    ### Sign Artifacts with Cosign

    Sign a file and generate a Sigstore v3 bundle:

    ```shell
    COSIGN_PASSWORD=$(op read "op://Employee/Duo Skills cosign/password") \
      timeout -v 4 cosign sign-blob \
        --key ~/.gitlab/duo/cosign.key \
        --bundle <filename>.bundle \
        --new-bundle-format \
        --yes \
        <filename>
    ```

    Replace:
    - `<filename>` with the file to sign (for example, `SKILL.md`)
    - The bundle output will be saved as `<filename>.bundle`

    ### Key Points

    - Use timeout to fail-fast and report the error back to the user.
    - Use `--bundle` with `$file.bundle` format for Sigstore v3 bundles
    - Use `--yes` to skip interactive prompts
    - Use `--new-bundle-format` to output a v3 Sigstore bundle rather than the legacy format
    - Set `COSIGN_PASSWORD` environment variable to avoid password prompts
    - Integrate with 1Password CLI for secure credential management
    - The bundle file contains the signature and can be verified later
    ````

1. 保存文件。
1. 开始新对话或任务流。每次更改或添加 `SKILL.md`
   文件时都应这样做，以避免 Agent 的上下文混乱。

<a id="create-user-level-skills"></a>

#### 创建用户级 skills

{{< details >}}

- Status: 实验

{{< /details >}}

用户级 skills 应用于您的所有项目。您可以在主目录中的 `skills/<skill-name>/` 目录下的 `SKILL.md` 文件中定义它们。

用户级 skills 仅可与极狐GitLab Duo CLI 配合使用。

<a id="create-a-directory-for-user-level-skills"></a>

##### 为用户级 skills 创建目录

您可以在以下位置之一创建 skills 目录：

- 要将 skills 与其他极狐GitLab Duo 自定义文件放在一起：
  - 对于 Linux 或 macOS，在 `~/.gitlab/duo/skills/` 创建目录。
  - 对于 Windows，在 `%APPDATA%\GitLab\duo\skills\` 创建目录。
  - 如果您设置了 `GLAB_CONFIG_DIR` 或 `XDG_CONFIG_HOME`，请使用 `$GLAB_CONFIG_DIR/skills/` 或 `$XDG_CONFIG_HOME/gitlab/duo/skills/`。如果两者都已设置，则 `GLAB_CONFIG_DIR` 优先。
- 要与其他支持 Agent Skills 规范的 AI 工具共享 skills：
  - 对于 Linux 或 macOS，在 `~/.agents/skills/` 创建目录。
  - 对于 Windows，在 `%USERPROFILE%\.agents\skills\` 创建目录。

<a id="create-a-user-level-skill-file"></a>

##### 创建用户级 skill 文件

创建用户级 skill：

1. 在启动极狐GitLab Duo CLI 时启用全局 skills：

   {{< tabs >}}

   {{< tab title="glab" >}}

   ```shell
   glab duo cli --enable-global-skills true
   ```

   {{< /tab >}}

   {{< tab title="duo" >}}

   ```shell
   duo --enable-global-skills true
   ```

   {{< /tab >}}

   {{< /tabs >}}

   或者，设置环境变量：

   ```shell
   export GITLAB_ENABLE_GLOBAL_SKILLS=true
   ```

1. 在您的 `skills` 目录中，为该特定 skill 再创建一个目录。
   使用 skill 名称作为目录名称。例如，`~/.gitlab/duo/skills/<skill_name>/`。
1. 创建一个 `SKILL.md` 文件，并使用以下格式添加指令。
   `name` 和 `description` YAML 前置信息字段为必填项。

   ```markdown
   ---
   name: <skill_name>
   description: <skill_description>
   ---

   <your_instructions_and_context_for_the_skill>
   ```

1. 开始新对话。该 skill 可在任何项目中使用。

<a id="expose-skills-as-slash-commands"></a>

#### 将 skills 公开为斜杠命令

要将某个 skill 启用为自定义斜杠命令，请在 `SKILL.md` 文件的
YAML 前置信息元数据中添加 `slash-command: enabled`：

```yaml
---
name: <skill_name>
description: <skill_description>
metadata:
  slash-command: enabled
---
```

添加元数据后，您可以在新会话中使用 `/<skill_name>` 指示极狐GitLab Duo 使用该
skill。例如，`/fix-bugs`。

<a id="use-skills-manually"></a>

### 手动使用 skills

要指示极狐GitLab Duo 使用特定 skill，请使用以下方法之一：

- 在提示中按名称或文件路径指示极狐GitLab Duo 使用该 skill。
- 在提示开头使用该 skill 的斜杠命令。

要列出当前会话上下文中所有可用的 skills，请使用 `/skills`。
