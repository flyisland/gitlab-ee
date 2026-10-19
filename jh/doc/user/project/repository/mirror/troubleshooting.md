---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 故障排除极狐GitLab 项目代码仓库镜像的问题。
title: 故障排除代码仓库镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当镜像失败时，极狐GitLab 会在项目详情页显示警告。例如：
{{< icon name="warning-solid" >}} **拉取镜像在 1 小时前失败。**
选择警告文本以进入**镜像代码仓库**设置。

在受影响的代码仓库旁边，极狐GitLab 会显示**错误**徽章。要查看错误消息，请将鼠标悬停在徽章上。错误消息包含常见问题的具体详情，例如身份验证失败或分支分叉。其他错误可能直接来自 Git 操作。

<a id="received-rst_stream-with-error-code-2-with-github"></a>

## 使用 GitHub 时收到 RST_STREAM，错误代码为 2

如果您在镜像到 GitHub 代码仓库时收到此消息：

```plaintext
13:Received RST_STREAM with error code 2
```

可能出现以下问题之一：

1. 您的 GitHub 设置可能设置为阻止暴露您在提交中所用电子邮件地址的推送。要解决此问题，可以：
   - 将您的 GitHub 电子邮件地址设为公开。
   - 关闭[**阻止暴露我的电子邮件的命令行推送**](https://github.com/settings/emails)设置。
1. 您的代码仓库超过了 GitHub 100 MB 的文件大小限制。要解决此问题，
   请检查 GitHub 上配置的文件大小限制，并考虑使用
   [Git Large File Storage (LFS)](https://git-lfs.com/) 来管理大文件。

<a id="deadline-exceeded"></a>

## Deadline Exceeded

当您升级极狐GitLab 时，用户名表示方式的变化意味着您必须更新镜像用户名和密码，以确保将 `%40` 字符替换为 `@`。

<a id="connection-blocked-server-only-allows-public-key-authentication"></a>

## 连接被阻止：服务器仅允许公钥身份验证

极狐GitLab 与远程代码仓库之间的连接被阻止。即使
[TCP 检查](../../../../administration/raketasks/maintenance.md#check-tcp-connectivity-to-a-remote-site)
成功，您也必须检查从极狐GitLab 到远程服务器的路由中的所有网络组件是否存在阻塞。

当防火墙对出站数据包执行 `Deep SSH Inspection` 时，可能会出现此错误。

<a id="could-not-read-username-terminal-prompts-disabled"></a>

## 无法读取用户名：终端提示已禁用

如果您在使用
[极狐GitLab 外部仓库的 CI/CD](../../../../ci/ci_cd_for_external_repos/_index.md) 创建新项目后收到此错误：

- 在 Bitbucket Cloud 中：

  ```plaintext
  "2:fetch remote: "fatal: could not read Username for 'https://bitbucket.org':
  terminal prompts disabled\n": exit status 128."
  ```

- 在 Bitbucket Server（自托管）中：

  ```plaintext
  "2:fetch remote: "fatal: could not read Username for 'https://lab.example.com':
  terminal prompts disabled\n": exit status 128.
  ```

检查镜像代码仓库的 URL 中是否指定了代码仓库所有者：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**镜像代码仓库**。
1. 如果未指定代码仓库所有者，请删除 URL 并按以下格式重新添加，
   将 `OWNER`、`ACCOUNTNAME`、`PATH_TO_REPO` 和 `REPONAME` 替换为您的值：

   - 在 Bitbucket Cloud 中：

     ```plaintext
     https://OWNER@bitbucket.org/ACCOUNTNAME/REPONAME.git
     ```

   - 在 Bitbucket Server（自托管）中：

     ```plaintext
     https://OWNER@lab.example.com/PATH_TO_REPO/REPONAME.git
     ```

连接到 Cloud 或自托管 Bitbucket 代码仓库进行镜像时，字符串中必须包含代码仓库所有者。

<a id="push-mirror-lfs-objects-are-missing"></a>

## 推送镜像：`LFS objects are missing`

您可能会收到如下错误：

```plaintext
GitLab: GitLab: LFS objects are missing. Ensure LFS is properly set up or try a manual "git lfs push --all".
```

当您使用 SSH 代码仓库 URL 进行推送镜像时，会出现此问题。不支持通过 SSH 传输 LFS 文件的推送镜像。

变通方法是使用 HTTPS 代码仓库 URL 而不是 SSH 进行推送镜像。

[议题 249587](https://gitlab.com/gitlab-org/gitlab/-/issues/249587) 用于修复此问题。

<a id="error-committer-is-not-a-member-of-team"></a>

## 错误：`Committer is not a member of team`

您可能会收到如下错误：

```plaintext
remote: GitLab: Committer 'noreply@example.com' is not a member of team
```

当源项目对在极狐GitLab UI 中创建的提交进行签名，而目标项目开启了**检查提交作者是否为极狐GitLab 用户**
[推送规则](../push_rules.md#verify-users)时，会出现此问题。
由极狐GitLab 签名的提交使用实例电子邮件地址作为提交者，而该地址不属于任何极狐GitLab 用户。

极狐GitLab 19.3 及更高版本解决了此问题：推送规则不再检查
[由极狐GitLab 签名的提交](../push_rules.md#commits-signed-by-gitlab)的提交者电子邮件地址。
对于更早版本，变通方法是在目标项目上关闭推送规则。

<a id="pull-mirror-is-missing-lfs-files"></a>

## 拉取镜像缺少 LFS 文件

在某些情况下，拉取镜像不会传输 LFS 文件。当您使用 SSH 代码仓库 URL 时，会出现此问题。

变通方法是改用 HTTPS 代码仓库 URL。

<a id="pull-mirroring-is-not-triggering-pipelines"></a>

## 拉取镜像未触发流水线

流水线可能因多种原因未运行：

- [为镜像更新触发流水线](pull.md#trigger-pipelines-for-mirror-updates)
  可能未启用。此设置只能在最初
  [配置拉取镜像](pull.md#configure-pull-mirroring)时启用。之后检查项目时，
  该状态[不会显示](https://gitlab.com/gitlab-org/gitlab/-/issues/346630)。

  当使用 [外部仓库的 CI/CD](../../../../ci/ci_cd_for_external_repos/_index.md) 设置镜像时，
  此设置默认启用。如果手动重新配置代码仓库镜像，触发流水线
  默认关闭，这可能是流水线停止运行的原因。
- [`rules`](../../../../ci/yaml/_index.md#rules) 配置阻止任何作业被添加到流水线中。
- 流水线使用[设置拉取镜像的账号](https://gitlab.com/gitlab-org/gitlab/-/issues/13697)触发。
  如果该账号不再有效，流水线不会运行。
- [分支保护](../branches/protected.md#cicd-on-protected-branches)
  可能会阻止设置镜像的账号运行流水线。

<a id="the-repository-is-being-updated-but-neither-fails-nor-succeeds-visibly"></a>

## `The repository is being updated`，但既没有明显失败也没有明显成功

在极少数情况下，Redis 上的镜像槽可能会耗尽，可能是因为 Sidekiq 工作进程因内存不足（OoM）事件而被回收。发生这种情况时，镜像作业会快速启动和完成，但既不会失败也不会成功。它们也不会留下清晰的日志。要检查此问题：

1. 进入 [Rails 控制台](../../../../administration/operations/rails_console.md)
   并检查 Redis 镜像容量：

   ```ruby
   current = Gitlab::Redis::SharedState.with { |redis| redis.scard('MIRROR_PULL_CAPACITY') }.to_i
   maximum = Gitlab::CurrentSettings.mirror_max_capacity
   available = maximum - current
   ```

1. 如果镜像容量为 `0` 或非常低，您可以使用以下命令排空所有卡住的作业：

   ```ruby
   Gitlab::Redis::SharedState.with { |redis| redis.smembers('MIRROR_PULL_CAPACITY') }.each do |pid|
     Gitlab::Redis::SharedState.with { |redis| redis.srem('MIRROR_PULL_CAPACITY', pid) }
   end
   ```

1. 运行该命令后，[后台作业页面](../../../../administration/admin_area.md#background-jobs)
   应显示正在调度新的镜像作业，尤其是在
   [手动触发](_index.md#update-a-mirror)时。

<a id="invalid-url"></a>

## URL 无效

如果您在通过 [SSH](_index.md#ssh-authentication) 设置镜像时收到此错误，请确保 URL 格式有效。

镜像不支持形如
`git@gitlab.com:gitlab-org/gitlab.git`的 SCP 式克隆 URL，即主机和项目路径使用 `:` 分隔。
它需要包含 `ssh://` 协议的[标准 URL](https://git-scm.com/docs/git-clone#_git_urls)，
例如 `ssh://git@gitlab.com/gitlab-org/gitlab.git`。

<a id="host-key-verification-failed"></a>

## 主机密钥验证失败

当目标主机公共 SSH 密钥发生变化时，会返回此错误。公共 SSH 密钥很少变化。如果主机密钥验证失败，但您怀疑密钥仍然有效，则必须删除代码仓库镜像并重新创建。有关更多信息，请参阅[创建代码仓库镜像](_index.md#create-a-repository-mirror)。

<a id="repository-mirroring-disabled-because-mirror-user-was-deleted"></a>

## 由于镜像用户被删除，代码仓库镜像已禁用

您可能会收到类似以下内容的电子邮件通知：

```plaintext
Repository mirroring on <project_path> was disabled because the mirror user <username> was deleted.

To re-enable mirroring, update your repository mirroring settings.
```

出现此问题的原因是每个镜像都与配置它的用户绑定。当该用户的账号被删除时，极狐GitLab 会自动禁用该镜像。当用于创建镜像的群组访问令牌或项目访问令牌被撤销时，也会出现相同行为，因为关联的机器人用户也会被删除。

您无法将镜像重新分配给其他用户。要解决此问题，请使用其他用户重新设置镜像。

有关更多信息，请参阅[议题 488449](https://gitlab.com/gitlab-org/gitlab/-/work_items/488449)。

<a id="transfer-mirror-users-and-tokens-to-a-single-service-account"></a>

## 将镜像用户和令牌迁移到单个服务账号

这需要访问 [GitLab Rails 控制台](../../../../administration/operations/rails_console.md#starting-a-rails-console-session)。

用例：如果您有多个用户使用各自的 GitHub 凭据设置代码仓库镜像，当人员离开公司时，镜像会中断。使用此脚本将分散的镜像用户和令牌迁移到单个服务账号：

> [!warning]
> 更改数据的命令如果未正确运行或在错误条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

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

## `The requested URL returned error: 301`

使用 `http://` 或 `https://` 协议进行镜像时，请务必指定代码仓库的精确 URL：`https://gitlab.example.com/group/project.git`

不会跟随 HTTP 重定向，省略 `.git` 可能会导致 301 错误：

```plaintext
13:fetch remote: "fatal: unable to access 'https://gitlab.com/group/project': The requested URL returned error: 301\n": exit status 128.
```

<a id="push-mirror-from-gitlab-instance-to-geo-secondary-fails"></a>

## 从极狐GitLab 实例到 Geo 从站点的推送镜像失败

使用 HTTP 或 HTTPS 协议推送镜像极狐GitLab 代码仓库时，如果目标是 Geo 从节点，由于推送请求被代理到 Geo 主节点，操作会失败，并显示以下错误：

```plaintext
13:get remote references: create git ls-remote: exit status 128, stderr: "fatal: unable to access 'https://gitlab.example.com/group/destination.git/': The requested URL returned error: 302".
```

当配置了 Geo 统一 URL 且目标主机名解析为从节点的 IP 地址时，会发生此情况。

可以通过以下方式避免此错误：

- 将推送镜像配置为使用 SSH 协议。但是，代码仓库不得包含任何 LFS 对象，因为 LFS 对象始终通过 HTTP 或 HTTPS 传输，并且仍会被重定向。
- 使用反向代理将源实例的所有请求定向到 Geo 主节点。
- 在源上添加本地 `hosts` 文件条目，以强制目标主机名解析为 Geo 主节点的 IP 地址。
- 改为在目标上配置拉取镜像。

<a id="pull-or-push-mirror-fails-to-update-the-project-is-not-mirrored"></a>

## 拉取或推送镜像无法更新：`The project is not mirrored`

当启用[极狐GitLab 静默模式](../../../../administration/silent_mode/_index.md)时，拉取和推送镜像无法更新。
发生这种情况时，UI 上允许镜像的选项会被禁用。

管理员可以检查确认极狐GitLab 静默模式已禁用。

当镜像因静默模式而失败时，以下是调试步骤：

- [使用 API 触发镜像](pull.md#trigger-pipelines-for-mirror-updates)会显示：`The project is not mirrored`。
- 如果拉取或推送镜像已设置，但镜像代码仓库没有进一步更新，
  请确认[项目的拉取和推送镜像详情及状态](../../../../api/project_pull_mirroring.md#retrieve-project-pull-mirror-details)
  不是如下所示的最近状态。这表明镜像已暂停，禁用极狐GitLab 静默模式后会自动重新启动。

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

## 初始镜像失败：`Unable to pull mirror repo: Unable to get pack index`

您可能会收到类似以下内容的错误：

```plaintext
13:fetch remote: "error: Unable to open local file /var/opt/gitlab/git-data/repositories/+gitaly/tmp/quarantine-[OMITTED].idx.temp.temp\nerror: Unable to get pack index https://git.example.org/ebtables/objects/pack/pack-[OMITTED].idx\nerror: Unable to find fcde2b2edba56bf408601fb721fe9b5c338d10ee under https://git.example.org/ebtables
Cannot obtain needed object fcde2b2edba56bf408601fb721fe9b5c338d10ee
while processing commit 2c26b46b68ffc68ff99b453c1d30413413422d70.
error: fetch failed.\n": exit status 128.
```

出现此问题的原因是 Gitaly 不支持通过“哑”HTTP 协议镜像或导入代码仓库。

要确定服务器是“智能”还是“哑”，请使用 cURL 为
`git-upload-pack` 服务启动引用发现，并模拟 Git“智能”客户端：

```shell
$GIT_URL="https://git.example.org/project"
curl --silent --dump-header - "$GIT_URL/info/refs?service=git-upload-pack"\
  -o /dev/null | grep -Ei "$content-type:"
```

- [“智能”服务器](https://www.git-scm.com/docs/http-protocol#_smart_server_response)
  在 `Content-Type` 响应头中报告 `application/x-git-upload-pack-advertisement`。
- “哑”服务器在 `Content-Type` 响应头中报告 `text/plain`。

有关更多信息，请参阅[关于发现引用的 Git 文档](https://www.git-scm.com/docs/http-protocol#_discovering_references)。

要解决此问题，您可以执行以下任一操作：

- 将源代码仓库迁移到“智能”服务器。
- 使用 [SSH 协议](_index.md#ssh-authentication)镜像代码仓库（需要身份验证）。

<a id="pull-mirroring-fails-with-could-not-update-main"></a>

## 拉取镜像失败，错误为 `Could not update main`

您可能会收到类似以下内容的错误：

- `9:Could not update main. Please refresh and try again.`

如果目标代码仓库并非完全为空，则在初始拉取镜像更新期间可能会发生此情况。

例如，目标代码仓库可能已包含：

- 初始 README 提交。
- 许可证或 `.gitignore`。
- 现有分支或标签。

要解决此问题：

1. 将目标代码仓库重新创建为空代码仓库。
1. 确保代码仓库使用与源代码仓库相同的对象格式。
1. 不要使用 README、许可证或 `.gitignore` 初始化代码仓库。
1. 重新配置拉取镜像并运行**立即更新**。

作为变通方法，如果您必须保留现有目标代码仓库，请启用**覆盖分叉分支**并确保镜像用户有权覆盖目标分支。

<a id="error-mismatched-algorithms"></a>

## 错误：`mismatched algorithms`

您可能会收到类似以下内容的错误：

```plaintext
13:fetch remote: "fatal: mismatched algorithms: client sha1; server sha256": exit status 128.
```

当源代码仓库和目标代码仓库使用不同的对象格式时，会出现此错误，并且不支持在使用不同对象格式的代码仓库之间进行拉取镜像。

例如：

- 源代码仓库使用 SHA-1。
- 目标代码仓库使用 SHA-256，反之亦然。

要解决此问题，请使用与源代码仓库相同的对象格式重新创建目标代码仓库，然后重新配置镜像。

<a id="error-file-directory-conflict"></a>

## 错误：`File directory conflict`

您可能会收到类似以下内容的错误：

```plaintext
13:preparing reference update: file directory conflict
```

当源代码仓库和镜像代码仓库之间存在标签或分支名称冲突时，会出现此错误。例如：

- 镜像代码仓库中存在名为 `x/y`的标签或分支。
- 源代码仓库中存在名为 `x`的标签或分支。

要解决此问题，请删除冲突的标签或分支。如果您无法识别冲突的标签或分支，请从镜像代码仓库中删除所有标签。
另一种选择是[覆盖分叉分支](pull.md#overwrite-diverged-branches)。

> [!note]
> 删除标签可能会破坏镜像代码仓库中已完成的任何工作。

要从镜像代码仓库中删除并移除所有标签：

1. 在镜像代码仓库的本地副本上，运行：

   ```shell
   git tag -l | xargs -n 1 git push --delete origin
   ```

1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**镜像代码仓库**。
1. 选择**立即更新**（{{< icon name="retry" >}}）。

<a id="push-mirroring-stuck-with-large-lfs-files"></a>

## 推送镜像因大型 LFS 文件而卡住

推送镜像包含大型 LFS 对象的项目时，您可能会遇到超时问题。当 Git LFS 操作超过默认活动超时时，会出现此问题。此错误会出现在镜像日志中：

```plaintext
push to mirror: git push: exit status 1, stderr: "remote: GitLab: LFS objects are missing. Ensure LFS is properly set up or try a manual \"git lfs push --all\""
```

要解决此问题，请在配置镜像之前增加 LFS 活动超时值：

```shell
git config lfs.activitytimeout 240
```

此命令将超时设置为 `240` 秒。您可以根据文件大小和网络状况调整此值。
