---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 创建双向镜像，在两个 Git 代码仓库之间推送和拉取变更。
title: 双向镜像
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 双向镜像可能会导致冲突。

双向[镜像](_index.md)将两个代码仓库配置为互相拉取和推送。无法保证任一代码仓库都能无错误地更新。

<a id="reduce-conflicts-in-bidirectional-mirroring"></a>

## 减少双向镜像中的冲突

如果您配置双向镜像，请让代码仓库做好应对冲突的准备。配置它们以减少冲突，并了解冲突发生时的解决方式：

- [仅镜像受保护分支](_index.md#mirror-only-protected-branches)。在任一远程上重写任何已镜像的提交都会导致冲突，并使镜像失败。
- 在要镜像的两个远程上[保护分支](../branches/protected.md)，以防止重写历史记录导致的冲突。
- 使用[推送事件 webhook](../../integrations/webhook_events.md#push-events) 减少镜像延迟。双向镜像会产生竞态条件，即几乎同时向同一分支提交的提交会导致冲突。推送事件 webhook 有助于缓解该竞态条件。当仅推送镜像受保护分支时，从极狐GitLab 发起的推送镜像速率限制为每分钟一次。
- [使用预接收钩子](#prevent-conflicts-by-using-a-pre-receive-hook) 防止冲突。

<a id="configure-a-webhook-to-trigger-an-immediate-pull-to-gitlab"></a>

## 配置 webhook 以触发立即拉取到极狐GitLab

下游实例中的[推送事件 webhook](../../integrations/webhook_events.md#push-events) 可以通过更频繁地同步变更来帮助减少竞态条件。

先决条件：

- 您已在极狐GitLab 上游实例中配置了[推送](push.md#set-up-a-push-mirror-to-another-gitlab-instance-with-2fa-activated)和[拉取](pull.md)镜像。

要在下游实例中创建 webhook：

1. 创建一个具有 `API` 范围的[个人访问令牌](../../../profile/personal_access_tokens.md)。
1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **Webhooks**。
1. 添加 webhook **URL**，在此情况下，它使用
   [拉取镜像 API](../../../../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project)
   请求在代码仓库更新后触发立即拉取：

   ```plaintext
   https://gitlab.example.com/api/v4/projects/:id/mirror/pull?private_token=<your_access_token>
   ```

1. [遮盖您的令牌](../../integrations/webhooks.md#mask-sensitive-portions-of-webhook-urls)。
1. 选择**推送事件**。
1. 选择**添加 Webhook**。

要测试该集成，请选择**测试**，并确认极狐GitLab 未返回错误消息。

<a id="prevent-conflicts-by-using-a-pre-receive-hook"></a>

## 使用预接收钩子防止冲突

> [!warning]
> 此解决方案会对 Git 推送操作的性能产生负面影响，因为这些操作会被代理到上游 Git 代码仓库。

在此配置中，一个 Git 代码仓库充当权威上游，另一个充当下游。此服务端 `pre-receive` 钩子仅在先将提交推送到上游代码仓库后才接受推送。请在下游代码仓库上安装此钩子。

例如：

```shell
#!/usr/bin/env bash

# --- Assume only one push mirror target
# Push mirroring remotes are named `remote_mirror_<id>`.
# This line finds the first remote and uses that.
TARGET_REPO=$(git remote | grep -m 1 remote_mirror)

proxy_push()
{
  # --- Arguments
  OLDREV=$(git rev-parse $1)
  NEWREV=$(git rev-parse $2)
  REFNAME="$3"

  # --- Pattern of branches to proxy pushes
  allowlist=$(expr "$branch" : "\(master\)")

  case "$refname" in
    refs/heads/*)
      branch=$(expr "$refname" : "refs/heads/\(.*\)")

      if [ "$allowlist" = "$branch" ]; then
        # handle https://git-scm.com/docs/git-receive-pack#_quarantine_environment
        unset GIT_QUARANTINE_PATH
        error="$(git push --quiet $TARGET_REPO $NEWREV:$REFNAME 2>&1)"
        fail=$?

        if [ "$fail" != "0" ]; then
          echo >&2 ""
          echo >&2 " Error: updates were rejected by upstream server"
          echo >&2 "   This is usually caused by another repository pushing changes"
          echo >&2 "   to the same ref. You may want to first integrate remote changes"
          echo >&2 ""
          return
        fi
      fi
      ;;
  esac
}

# Allow dual mode: run from the command line just like the update hook, or
# if no arguments are given, then run as a hook script:
if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
  # Output to the terminal in command line mode. If someone wanted to
  # resend an email, they could redirect the output to sendmail themselves
  PAGER= proxy_push $2 $3 $1
else
  # Push is proxied upstream one ref at a time. It is possible for some refs
  # to succeed, and others to fail. This results in a failed push.
  while read oldrev newrev refname
  do
    proxy_push $oldrev $newrev $refname
  done
fi
```

此示例有一些限制：

- 未经修改可能不适用于您的用例：
  - 它不考虑镜像的不同类型的身份验证机制。
  - 它不适用于强制更新（重写历史记录）。
  - 仅与 `allowlist` 模式匹配的分支会被代理推送。
- 该脚本绕过了 Git 钩子隔离环境，因为 `$TARGET_REPO`的更新被视为引用更新，Git 会对此显示警告。
