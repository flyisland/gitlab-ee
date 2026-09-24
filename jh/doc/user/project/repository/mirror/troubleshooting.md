---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 排查 极狐GitLab 项目仓库镜像问题的故障。
title: 故障排查仓库镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当镜像失败时，极狐GitLab 在项目详情页显示一个警告。例如：
{{< icon name="warning-solid" >}} **拉取镜像在 1 小时前失败。**
选择警告文本以进入 **镜像仓库** 设置。

在受影响的仓库旁边，极狐GitLab 显示一个 **错误** 徽章。要查看错误消息，请将鼠标悬停在该徽章上。错误消息包含针对常见问题（如身份验证失败或分支分歧）的具体细节。其他错误可能直接来自 Git 操作。

<a id="received-rst_stream-with-error-code-2-with-github"></a>

## 与 GitHub 的 RST_STREAM 错误码 2

如果您在镜像到 GitHub 仓库时收到此消息：

```plaintext
13:收到 RST_STREAM 且错误码为 2
```

以下问题之一可能正在发生：

1. 您的 GitHub 设置可能已设为阻止暴露您在提交中使用的电子邮件地址的推送。要解决此问题，可以：
   - 将您的 GitHub 电子邮件地址设为公开。
   - 关闭 [**阻止暴露我电子邮件的命令行推送**](https://github.com/settings/emails) 设置。
1. 您的仓库超过了 GitHub 100 MB 的文件大小限制。要解决此问题，请检查 GitHub 上配置的文件大小限制，并考虑使用 [Git 大文件存储 (LFS)](https://git-lfs.com/) 管理大文件。

<a id="deadline-exceeded"></a>

## 超出截止时间

当您升级极狐GitLab 时，用户名表示方式的更改意味着您必须更新镜像用户名和密码，以确保将 `%40` 字符替换为 `@`。

<a id="connection-blocked-server-only-allows-public-key-authentication"></a>

## 连接被阻止：服务器仅允许公钥认证

极狐GitLab 与远程仓库之间的连接被阻止。即使 [TCP 检查](../../../../administration/raketasks/maintenance.md#check-tcp-connectivity-to-a-remote-site) 成功，您也必须检查从极狐GitLab 到远程服务器路径中的任何网络组件是否存在阻止。

当防火墙对传出数据包执行 `深度 SSH 检查` 时，可能会出现此错误。

<a id="could-not-read-username-terminal-prompts-disabled"></a>

## 无法读取用户名：终端提示已禁用

如果您在使用 [极狐GitLab CI/CD 为外部仓库](../../../../ci/ci_cd_for_external_repos/_index.md) 创建新项目后收到此错误：

- 在 Bitbucket Cloud 中：

  ```plaintext
  "2:fetch remote: "fatal: 无法读取 'https://bitbucket.org' 的用户名：
  terminal prompts disabled\n": exit status 128."
  ```

- 在 Bitbucket Server（自托管）中：

  ```plaintext
  "2:fetch remote: "fatal: 无法读取 'https://lab.example.com' 的用户名：
  terminal prompts disabled\n": exit status 128.
  ```

检查镜像仓库的 URL 中是否指定了仓库所有者：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 如果未指定仓库所有者，请删除并以以下格式重新添加 URL，将 `OWNER`、`ACCOUNTNAME`、`PATH_TO_REPO` 和 `REPONAME` 替换为您的值：

   - 在 Bitbucket Cloud 中：

     ```plaintext
     https://OWNER@bitbucket.org/ACCOUNTNAME/REPONAME.git
     ```

   - 在 Bitbucket Server（自托管）中：

     ```plaintext
     https://OWNER@lab.example.com/PATH_TO_REPO/REPONAME.git
     ```

当连接至 Cloud 或自托管 Bitbucket 仓库进行镜像时，字符串中需要仓库所有者。

<a id="push-mirror-lfs-objects-are-missing"></a>

## 推送镜像：`LFS 对象缺失`

您可能会收到如下错误：

```plaintext
极狐GitLab: 极狐GitLab: LFS 对象缺失。请确保 LFS 已正确设置，或尝试手动执行 "git lfs push --all"。
```

当您使用 SSH 仓库 URL 进行推送镜像时，会出现此问题。不支持通过 SSH 传输 LFS 文件的推送镜像。

变通方法是使用 HTTPS 仓库 URL 而非 SSH 进行推送镜像。

存在 议题 249587 以解决此问题。

<a id="pull-mirror-is-missing-lfs-files"></a>

## 拉取镜像缺少 LFS 文件

在某些情况下，拉取镜像不会传输 LFS 文件。当您使用 SSH 仓库 URL 时，会出现此问题。

变通方法是使用 HTTPS 仓库 URL 替代。

<a id="pull-mirroring-is-not-triggering-pipelines"></a>

## 拉取镜像未触发流水线

流水线可能因多种原因未运行：

- [触发镜像更新的流水线](pull.md#trigger-pipelines-for-mirror-updates) 可能未启用。此设置只能在初始 [配置拉取镜像](pull.md#configure-pull-mirroring) 时启用。之后检查项目时，状态 不会显示（议题 346630）。

  当使用 [面向外部仓库的 CI/CD](../../../../ci/ci_cd_for_external_repos/_index.md) 设置镜像时，默认启用此设置。如果手动重新配置了仓库镜像，则触发流水线默认关闭，这可能是流水线停止运行的原因。
- [`rules`](../../../../ci/yaml/_index.md#rules) 配置阻止了任何作业被添加到流水线中。
- 流水线由 设置拉取镜像的账户（议题 13697） 触发。如果该账户不再有效，流水线将不会运行。
- [分支保护](../branches/protected.md#cicd-on-protected-branches) 可能会阻止设置镜像的账户运行流水线。

<a id="the-repository-is-being-updated-but-neither-fails-nor-succeeds-visibly"></a>

## `仓库正在更新`，但既未失败也未明显成功

在极少数情况下，Redis 上的镜像槽位可能会耗尽，可能由于 Sidekiq 工作线程因内存不足（OoM）事件被回收。发生这种情况时，镜像作业会快速启动并完成，但它们既不失败也不成功。它们也不会留下清晰的日志。要检查此问题：

1. 进入 [Rails 控制台](../../../../administration/operations/rails_console.md) 并检查 Redis 的镜像容量：

   ```ruby
   current = Gitlab::Redis::SharedState.with { |redis| redis.scard('MIRROR_PULL_CAPACITY') }.to_i
   maximum = Gitlab::CurrentSettings.mirror_max_capacity
   available = maximum - current
   ```

1. 如果镜像容量为 `0` 或非常低，您可以使用以下命令清空所有卡住的作业：

   ```ruby
   Gitlab::Redis::SharedState.with { |redis| redis.smembers('MIRROR_PULL_CAPACITY') }.each do |pid|
     Gitlab::Redis::SharedState.with { |redis| redis.srem('MIRROR_PULL_CAPACITY', pid) }
   end
   ```

1. 运行命令后，[后台作业页面](../../../../administration/admin_area.md#background-jobs) 应该显示新的镜像作业正在被调度，尤其是当 [手动触发](_index.md#update-a-mirror) 时。

<a id="invalid-url"></a>

## 无效的 URL

如果您在通过 [SSH](_index.md#ssh-authentication) 设置镜像时收到此错误，请确保 URL 格式有效。

镜像不支持类似 SCP 的克隆 URL，格式为 `git@gitlab.com:gitlab-org/gitlab.git`，主机和项目路径使用 `:` 分隔。它需要一个包含 `ssh://` 协议的 [标准 URL](https://git-scm.com/docs/git-clone#_git_urls)，例如 `ssh://git@gitlab.com/gitlab-org/gitlab.git`。

<a id="host-key-verification-failed"></a>

## 主机密钥验证失败

当目标主机公钥 SSH 密钥更改时，会返回此错误。公钥 SSH 密钥很少更改。如果主机密钥验证失败，但您怀疑密钥仍然有效，则必须删除仓库镜像并重新创建。有关更多信息，请参阅 [创建仓库镜像](_index.md#create-a-repository-mirror)。

<a id="transfer-mirror-users-and-tokens-to-a-single-service-account"></a>

## 将镜像用户和令牌转移到单个服务账户

这需要访问 [极狐GitLab Rails 控制台](../../../../administration/operations/rails_console.md#starting-a-rails-console-session)。

用例：如果有多个用户使用自己的 GitHub 凭据设置仓库镜像，那么当人们离开公司时，镜像就会中断。使用此脚本将分散的镜像用户和令牌迁移到单个服务账户：

> [!warning]
> 如果未正确运行或在适当条件下运行，更改数据的命令可能会造成损害。始终先在测试环境中运行命令，并准备一个备份实例以便恢复。

```ruby
svc_user = User.find_by(username: 'ourServiceUser')
token = 'githubAccessToken'

Project.where(mirror: true).each do |project|
  import_url = project.unsafe_import_url

  # The expected url output is https://token@project/path.git
  repo_url = if import_url.include?('@')
               # Case 1: The url is something like https://23423432@project/path.git
               import_url.split('@').last
             elsif import_url.include?('//')
               # Case 2: The url is something like https://project/path.git
               import_url.split('//').last
             end

  next unless repo_url

  final_url = "https://#{token}@#{repo_url}"

  project.mirror_user = svc_user
  project.import_url = final_url
  project.username_only_import_url = final_url
  project.save
end
```

<a id="the-requested-url-returned-error-301"></a>

## `请求的 URL 返回错误：301`

当使用 `http://` 或 `https://` 协议进行镜像时，请确保指定仓库的精确 URL：`https://gitlab.example.com/group/project.git`

HTTP 重定向不会被跟随，省略 `.git` 可能导致 301 错误：

```plaintext
13:fetch remote: "fatal: 无法访问 'https://gitlab.com/group/project'：请求的 URL 返回错误：301\n"：退出状态 128。
```

<a id="push-mirror-from-gitlab-instance-to-geo-secondary-fails"></a>

## 从极狐GitLab 实例到 Geo 辅助节点的推送镜像失败

当目标为 Geo 辅助节点时，使用 HTTP 或 HTTPS 协议推送镜像极狐GitLab 仓库会失败，因为推送请求被代理到 Geo 主节点，并显示以下错误：

```plaintext
13:get remote references: create git ls-remote: exit status 128, stderr: "fatal: 无法访问 'https://gitlab.example.com/group/destination.git/'：请求的 URL 返回错误：302"。
```

当配置了 Geo 统一 URL 且目标主机名解析到辅助节点的 IP 地址时，会发生此问题。

可以通过以下方式避免该错误：

- 配置推送镜像使用 SSH 协议。但是，仓库不得包含任何 LFS 对象，这些对象始终通过 HTTP 或 HTTPS 传输，并且仍会被重定向。
- 使用反向代理将源实例的所有请求直接定向到 Geo 主节点。
- 在源上添加本地 `hosts` 文件条目，强制目标主机名解析到 Geo 主节点的 IP 地址。
- 改为在目标上配置拉取镜像。

<a id="pull-or-push-mirror-fails-to-update-the-project-is-not-mirrored"></a>

## 拉取或推送镜像更新失败：`项目未镜像`

当启用 [极狐GitLab 静默模式](../../../../administration/silent_mode/_index.md) 时，拉取和推送镜像将无法更新。发生这种情况时，UI 上的允许镜像选项将被禁用。

管理员可以检查确认极狐GitLab 静默模式已禁用。

当由于静默模式导致镜像失败时，以下是调试步骤：

- [使用 API 触发镜像](pull.md#trigger-pipelines-for-mirror-updates) 显示：`项目未镜像`。
- 如果拉取或推送镜像已经设置，但镜像仓库没有进一步更新，请确认 [项目的拉取和推送镜像详情与状态](../../../../api/project_pull_mirroring.md#retrieve-project-pull-mirror-details) 不是如下所示的最近时间。这表明镜像已暂停，禁用极狐GitLab 静默模式将自动重新启动它。

例如，如果静默模式阻碍了您的导入，输出类似于以下内容：

```json
"id": 1,
"update_status": "finished",
"url": "https://test.git"
"last_error": null,
"last_update_at": null,
"last_update_started_at": "2023-12-12T00:01:02.222Z",
"last_successful_update_at": null
```

<a id="initial-mirroring-fails-unable-to-pull-mirror-repo-unable-to-get-pack-index"></a>

## 初始镜像失败：`无法拉取镜像仓库：无法获取包索引`

您可能会收到类似以下的错误：

```plaintext
13:fetch remote: "error: 无法打开本地文件 /var/opt/gitlab/git-data/repositories/+gitaly/tmp/quarantine-[OMITTED].idx.temp.temp\nerror: 无法获取包索引 https://git.example.org/ebtables/objects/pack/pack-[OMITTED].idx\nerror: 在 https://git.example.org/ebtables 下无法找到 fcde2b2edba56bf408601fb721fe9b5c338d10ee
在处理提交 2c26b46b68ffc68ff99b453c1d30413413422d70 时无法获取所需对象 fcde2b2edba56bf408601fb721fe9b5c338d10ee。
error: fetch failed.\n": exit status 128.
```

此问题发生是因为 Gitaly 不支持通过“哑” HTTP 协议进行镜像或导入仓库。

要确定服务器是“智能”还是“哑”，请使用 cURL 为 `git-upload-pack` 服务启动引用发现，并模拟 Git “智能”客户端：

```shell
$GIT_URL="https://git.example.org/project"
curl --silent --dump-header - "$GIT_URL/info/refs?service=git-upload-pack"\
  -o /dev/null | grep -Ei "$content-type:"
```

- [“智能”服务器](https://www.git-scm.com/docs/http-protocol#_smart_server_response) 在 `Content-Type` 响应头中报告 `application/x-git-upload-pack-advertisement`。
- “哑”服务器在 `Content-Type` 响应头中报告 `text/plain`。

更多信息，请参阅 [Git 文档关于发现引用](https://www.git-scm.com/docs/http-protocol#_discovering_references)。

要解决此问题，您可以执行以下任何一项操作：

- 将源仓库迁移到“智能”服务器。
- 使用 [SSH 协议](_index.md#ssh-authentication) 镜像仓库（需要身份验证）。

<a id="error-file-directory-conflict"></a>

## 错误：`文件目录冲突`

您可能会收到类似以下的错误：

```plaintext
13:preparing reference update: file directory conflict
```

当源仓库和镜像仓库之间存在标签或分支名称冲突时，会发生此错误。例如：

- 镜像仓库中存在名为 `x/y` 的标签或分支。
- 源仓库中存在名为 `x` 的标签或分支。

要解决此问题，请删除冲突的标签或分支。如果您无法识别冲突的标签或分支，请从镜像仓库中删除所有标签。另一种选择是 [覆盖分支分歧](pull.md#overwrite-diverged-branches)。

> [!note]
> 删除标签可能会对镜像仓库中完成的任何工作造成破坏。

要从镜像仓库中删除并移除所有标签：

1. 在镜像仓库的本地副本上，运行：

   ```shell
   git tag -l | xargs -n 1 git push --delete origin
   ```

1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 选择 **立即更新**（{{< icon name="retry" >}}）。

<a id="push-mirroring-stuck-with-large-lfs-files"></a>

## 推送镜像因大型 LFS 文件卡住

当推送镜像包含大型 LFS 对象的项目时，您可能会遇到超时问题。当 Git LFS 操作超出默认活动超时时，会出现此问题。此错误显示在镜像日志中：

```plaintext
push to mirror: git push: exit status 1, stderr: "remote: 极狐GitLab: LFS 对象缺失。请确保 LFS 已正确设置，或尝试手动 \"git lfs push --all\""
```

要解决此问题，请在配置镜像之前增加 LFS 活动超时值：

```shell
git config lfs.activitytimeout 240
```

此命令将超时设置为 `240` 秒。您可以根据文件大小和网络情况调整此值。