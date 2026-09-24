---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create bidirectional mirrors to push and pull changes between two Git repositories.
title: 双向镜像
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 13.9 中移至极狐GitLab 专业版。

{{< /history >}}

> [!warning]
> 双向镜像可能导致冲突。

双向[镜像](_index.md)将配置两个仓库，使其相互拉取和推送变更。无法保证任一仓库能无错更新。

## 减少双向镜像中的冲突

如果配置双向镜像，请为仓库做好处理冲突的准备。通过配置来减少冲突，并在冲突发生时解决它们：

- [仅镜像受保护分支](_index.md#mirror-only-protected-branches)。在任一远程仓库中重写任何已镜像的提交都会导致冲突，并使镜像失败。
- [保护](../branches/protected.md)你希望在两个远程仓库中镜像的分支，以防因重写历史而导致冲突。
- 使用[推送事件 Webhook](../../integrations/webhook_events.md#push-events) 减少镜像延迟。双向镜像会产生竞态条件，如果对同一分支的提交间隔很近，就会导致冲突。推送事件 Webhook 有助于缓解这种竞态条件。极狐GitLab 的推送镜像限制为每分钟一次，仅推送镜像受保护分支。
- [通过 pre-receive 钩子防止冲突](#prevent-conflicts-by-using-a-pre-receive-hook)。

## 配置 Webhook 以立即触发向极狐GitLab 的拉取

在下游实例中设置[推送事件 Webhook](../../integrations/webhook_events.md#push-events) 有助于通过更频繁地同步变更来减少竞态条件。

先决条件：

- 你已在上游极狐GitLab 实例中配置了[推送](push.md#set-up-a-push-mirror-to-another-gitlab-instance-with-2fa-activated)和[拉取](pull.md)镜像。

要在下游实例中创建 Webhook：

1. 创建一个具有 `API` 作用域的[个人访问令牌](../../../profile/personal_access_tokens.md)。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **Webhooks**。
1. 添加 Webhook **URL**，该 URL（在此情况下）使用[拉取镜像 API](../../../../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project) 请求在仓库更新后立即触发拉取：

   ```plaintext
   https://gitlab.example.com/api/v4/projects/:id/mirror/pull?private_token=<your_access_token>
   ```

1. [为你的令牌添加掩码](../../integrations/webhooks.md#mask-sensitive-portions-of-webhook-urls)。
1. 选择 **推送事件**。
1. 选择 **添加 Webhook**。

要测试集成，请选择 **测试** 并确认极狐GitLab 未返回错误消息。

## 通过 pre-receive 钩子防止冲突

> [!warning]
> 此解决方案会对 Git 推送操作的性能产生负面影响，因为这些操作会被代理到上游 Git 仓库。

在此配置中，一个 Git 仓库充当权威上游，另一个作为下游。此服务器端 `pre-receive` 钩子仅在先将提交推送到上游仓库后才接受推送。请在你的下游仓库上安装此钩子。

例如：

```shell
#!/usr/bin/env bash

# --- 假设只有一个推送镜像目标
# 推送镜像的远程名称格式为 `remote_mirror_<id>`。
# 此行查找第一个远程并使用它。
TARGET_REPO=$(git remote | grep -m 1 remote_mirror)

proxy_push()
{
  # --- 参数
  OLDREV=$(git rev-parse $1)
  NEWREV=$(git rev-parse $2)
  REFNAME="$3"

  # --- 用于代理推送的分支模式
  allowlist=$(expr "$branch" : "\(master\)")

  case "$refname" in
    refs/heads/*)
      branch=$(expr "$refname" : "refs/heads/\(.*\)")

      if [ "$allowlist" = "$branch" ]; then
        # 处理 https://git-scm.com/docs/git-receive-pack#_quarantine_environment
        unset GIT_QUARANTINE_PATH
        error="$(git push --quiet $TARGET_REPO $NEWREV:$REFNAME 2>&1)"
        fail=$?

        if [ "$fail" != "0" ]; then
          echo >&2 ""
          echo >&2 " 错误：更新被上游服务器拒绝"
          echo >&2 "   这通常是由另一个仓库推送更改到相同引用所致"
          echo >&2 "   你可能需要先集成远程更改"
          echo >&2 ""
          return
        fi
      fi
      ;;
  esac
}

# 允许双模式：像 update 钩子一样从命令行运行，或者
# 如果没有提供参数，则作为钩子脚本运行：
if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
  # 在命令行模式下输出到终端。如果有人想要
  # 重新发送电子邮件，他们可以自行将输出重定向到 sendmail
  PAGER= proxy_push $2 $3 $1
else
  # 推送每次只代理一个 ref 到上游。某些 ref 可能成功，
  # 而另一些则失败。这会导致推送失败。
  while read oldrev newrev refname
  do
    proxy_push $oldrev $newrev $refname
  done
fi
```

此示例有一些限制：

- 它可能不经过修改就无法满足你的使用案例：
  - 它未考虑镜像的不同认证机制类型。
  - 它不支持强制更新（重写历史）。
  - 只有与 `allowlist` 模式匹配的分支才会被代理推送。
- 该脚本绕过了 Git 钩子隔离环境，因为 `$TARGET_REPO` 的更新被视为 ref 更新，Git 会显示相关警告。

## 相关主题

- 仓库镜像的[故障排查](troubleshooting.md)。
- [配置服务器钩子](../../../../administration/server_hooks.md)