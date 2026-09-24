---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Common commands and workflows.
title: 暂存、提交和推送更改
---

当你更改代码仓中的文件时，Git 会跟踪这些更改，并与检出分支的最新版本进行对比。你可以使用 Git 命令审查更改并将其提交到分支，然后将工作成果推送到极狐GitLab。

## 添加并提交本地更改

当你准备好将更改写入分支时，可以提交它们。提交包含一条注释，用于记录关于这些更改的信息，并且通常会变成分支的新顶端。

Git 不会自动将你移动、更改或删除的任何文件包含在提交中。这可以防止你意外地包含某个更改或文件，例如临时目录。要将更改包含在提交中，请使用 `git add` 暂存它们。

要暂存并提交你的更改：

1.  在你的代码仓中，对于你想要添加的每个文件或目录，运行 `git add <文件名称或路径>`。

   要暂存当前工作目录中的所有文件，请运行 `git add .`。
1.  确认文件已添加到暂存区：

   ```shell
   git status
   ```

   文件会以绿色显示。
1.  提交已暂存的文件：

   ```shell
   git commit -m "<描述更改的注释>"
   ```

更改即被提交到分支。

### 编写良好的提交消息

Chris Beams 在 [如何编写 Git 提交消息](https://cbea.ms/git-commit/) 中发布的指南可以帮助你编写良好的提交消息：

- 提交主题和正文必须用空行分隔。
- 提交主题必须以大写字母开头。
- 提交主题长度不得超过 72 个字符。
- 提交主题不能以句号结尾。
- 提交正文每行不能超过 72 个字符。
- 提交主题或正文不得包含表情符号。
- 如果在至少 3 个文件中更改了 30 行或更多代码，应在提交正文中描述这些更改。
- 对议题、里程碑和合并请求使用完整的 URL，而不是短引用，因为它们在极狐GitLab 外部会显示为纯文本。
- 合并请求不应包含超过 10 条提交消息。
- 提交主题应至少包含 3 个单词。

## 提交所有更改

你可以用一个命令暂存所有更改并提交它们：

```shell
git commit -a -m "<描述更改的注释>"
```

请注意，你的提交不要包含你不想记录到远程代码仓的文件。通常，在提交更改前，请务必检查本地代码仓的状态。

## 将更改发送到极狐GitLab

要将所有本地更改推送到远程代码仓：

```shell
git push <远程> <分支名称>
```

例如，要将你的本地提交推送到 `origin` 远程的 `main` 分支：

```shell
git push origin main
```

有时 Git 不允许你推送到代码仓，这种情况下，你必须[强制更新](git_rebase.md#force-push-to-a-remote-branch)。

## 推送选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当你将更改推送到分支时，可以使用客户端 [Git 推送选项](https://git-scm.com/docs/git-push#Documentation/git-push.txt--oltoptiongt)。在 Git 2.10 及更高版本中，使用 Git 推送选项可以：

- [跳过 CI 作业](#push-options-for-gitlab-cicd)
- [推送到合并请求](#push-options-for-merge-requests)

在 Git 2.18 及更高版本中，你可以使用长格式 (`--push-option`) 或更短的 `-o`：

```shell
git push -o <push_option>
```

在 Git 2.10 到 2.17 中，你必须使用长格式：

```shell
git push --push-option=<push_option>
```

关于服务端控制和最佳实践的执行，请参见[推送规则](../../user/project/repository/push_rules.md)和[服务器钩子](../../administration/server_hooks.md)。

### 极狐GitLab CI/CD 的推送选项

你可以使用推送选项来跳过 CI/CD 流水线，或传递 CI/CD 变量。

> [!note]
> 推送选项不适用于合并请求流水线。更多信息，请参见[议题 373212](https://gitlab.com/gitlab-org/gitlab/-/issues/373212)。

| 推送选项                    | 描述 | 示例 |
|--------------------------------|-------------|---------|
| `ci.input=<name>=<value>`      | 将输入参数传递给流水线。 | `git push -o ci.input='stage=test' -o ci.input='security_scan=false'`。数组输入：`git push -o ci.input='my_array=["string", "double", "quotes"]'` |
| `ci.skip`                      | 跳过此次推送的流水线。仅影响分支流水线，不影响[合并请求流水线](../../ci/pipelines/merge_request_pipelines.md)。不会跳过如 Jenkins 等 CI/CD 集成。 | `git push -o ci.skip` |
| `ci.no_pipeline`               | 阻止为最新推送创建任何流水线。 | `git push -o ci.no_pipeline` |
| `ci.variable="<name>=<value>"` | 为流水线设置 [CI/CD 变量](../../ci/variables/_index.md)。仅影响分支流水线，不影响[合并请求流水线](../../ci/pipelines/merge_request_pipelines.md)。 | `git push -o ci.variable="MAX_RETRIES=10" -o ci.variable="MAX_TIME=600"` |

### 用于集成的推送选项

你可以使用推送选项来跳过集成 CI/CD 流水线。

| 推送选项                    | 描述 | 示例 |
|--------------------------------|-------------|---------|
| `integrations.skip_ci`         | 跳过 CI/CD 集成（如 Atlassian Bamboo、Buildkite、Drone、Jenkins 和 JetBrains TeamCity）的推送事件。于[极狐GitLab 16.2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/123837) 引入。 | `git push -o integrations.skip_ci` |

### 用于合并请求的推送选项

Git 推送选项可以在推送更改时为合并请求执行操作：

| 推送选项                                  | 描述 |
|----------------------------------------------|-------------|
| `merge_request.create`                       | 为推送的分支创建一个新的合并请求。从默认分支推送时，你必须使用 `merge_request.target` 选项指定目标分支才能创建合并请求。 |
| `merge_request.target=<branch_name>`         | 将合并请求的目标设置为特定分支，例如：`git push -o merge_request.target=branch_name`。从默认分支创建合并请求时必需。 |
| `merge_request.target_project=<project>`     | 将合并请求的目标设置为特定的上游项目，例如：`git push -o merge_request.target_project=path/to/project`。于[极狐GitLab 16.6](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/132475) 引入。 |
| `merge_request.merge_when_pipeline_succeeds` | 已于极狐GitLab 17.11 [弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/185368)，推荐使用 `auto_merge` 选项。 |
| `merge_request.auto_merge` | 将合并请求设置为[自动合并](../../user/project/merge_requests/auto_merge.md)。 |
| `merge_request.remove_source_branch`         | 设置合并请求在合并后删除源分支。 |
| `merge_request.squash`                       | 设置合并请求在合并时将所有提交压缩为一个提交。于[极狐GitLab 17.2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/158778) 引入。 |
| `merge_request.title="<title>"`              | 设置合并请求的标题。例如：`git push -o merge_request.title="我想要的标题"`。 |
| `merge_request.description="<description>"`  | 设置合并请求的描述。例如：`git push -o merge_request.description="我想要的描述"`。 |
| `merge_request.draft`                        | 将合并请求标记为草稿。例如：`git push -o merge_request.draft`。 |
| `merge_request.milestone="<milestone>"`      | 设置合并请求的里程碑。例如：`git push -o merge_request.milestone="3.0"`。 |
| `merge_request.label="<label>"`              | 向合并请求添加标签。如果标签不存在，则会创建。例如，对于两个标签：`git push -o merge_request.label="label1" -o merge_request.label="label2"`。 |
| `merge_request.unlabel="<label>"`            | 从合并请求中移除标签。例如，对于两个标签：`git push -o merge_request.unlabel="label1" -o merge_request.unlabel="label2"`。 |
| `merge_request.assign="<user>"`              | 为合并请求指派用户。接受用户名或用户 ID。例如，对于两个用户：`git push -o merge_request.assign="user1" -o merge_request.assign="user2"`。 |
| `merge_request.unassign="<user>"`            | 从合并请求中移除指派人。接受用户名或用户 ID。例如，对于两个用户：`git push -o merge_request.unassign="user1" -o merge_request.unassign="user2"`。 |

### 用于密钥推送保护的推送选项

你可以使用推送选项来跳过[密钥推送保护](../../user/application_security/secret_detection/secret_push_protection/_index.md)。

| 推送选项                    | 描述 | 示例 |
|--------------------------------|-------------|---------|
| `secret_push_protection.skip_all` | 不对本次推送中的任何提交执行密钥推送保护。 | `git push -o secret_push_protection.skip_all` |

### 用于安全策略的推送选项

你可以使用推送选项来[绕过安全策略](../../user/application_security/policies/merge_request_approval_policies.md#allowing-users-to-bypass-security-policies)。

| 推送选项                    | 描述 | 示例 |
|--------------------------------|-------------|---------|
| `security_policy.bypass_reason` | 设置绕过安全策略的原因。 | `git push -o security_policy.bypass_reason="Hot fix"` |

### 用于 GitGuardian 集成的推送选项

你可以使用与[密钥推送保护相同的推送选项](#push-options-for-secret-push-protection)来跳过 GitGuardian 密钥检测。

| 推送选项                    | 描述 | 示例 |
|--------------------------------|-------------|---------|
| `secret_detection.skip_all` | 已在极狐GitLab 17.2 中弃用。请改用 `secret_push_protection.skip_all`。 | `git push -o secret_detection.skip_all` |
| `secret_push_protection.skip_all` | 不执行 GitGuardian 密钥检测。 | `git push -o secret_push_protection.skip_all` |

### 推送选项的格式

如果你的推送选项需要包含空格的文本，请将文本用双引号 (`"`) 括起来。如果没有空格，则可以省略引号。部分示例：

```shell
git push -o merge_request.label="包含空格的标签"
git push -o merge_request.label=不包含空格的标签
```

要组合使用推送选项以同时完成多个任务，请使用多个 `-o`（或 `--push-option`）标记。此命令会创建一个新的合并请求，并指定目标分支 (`my-target-branch`) 和设置自动合并：

```shell
git push -o merge_request.create -o merge_request.target=my-target-branch -o merge_request.auto_merge
```

要从默认分支创建针对其他分支的新合并请求：

```shell
git push -o merge_request.create -o merge_request.target=feature-branch
```

### 为推送创建 Git 别名

在 Git 命令中添加推送选项可能会产生非常长的命令。如果你经常使用相同的推送选项，可以为其创建 Git 别名。Git 别名是更长的 Git 命令的命令行快捷方式。

要为[自动合并 Git 推送选项](#push-options-for-merge-requests)创建并使用 Git 别名：

1.  在你的终端窗口中，运行此命令：

   ```shell
   git config --global alias.mwps "push -o merge_request.create -o merge_request.target=main -o merge_request.auto_merge"
   ```

1.  要使用该别名推送一个以默认分支 (`main`) 为目标并自动合并的本地分支，请运行此命令：

   ```shell
   git mwps origin <本地分支名称>
   ```

## 相关主题

- [常用 Git 命令](commands.md)