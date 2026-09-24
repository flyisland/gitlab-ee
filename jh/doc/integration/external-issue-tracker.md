---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部议题跟踪器
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 有自己的 [议题跟踪器](../user/project/issues/_index.md)，但你也可以为每个极狐GitLab 项目配置外部议题跟踪器。然后你可以使用：

- 外部议题跟踪器与极狐GitLab 议题跟踪器同时使用
- 仅使用外部议题跟踪器

使用外部跟踪器，你可以使用格式 `CODE-123` 在极狐GitLab 合并请求、提交和评论中提及外部议题，其中：

- `CODE` 是跟踪器的唯一代码。
- `123` 是跟踪器中的议题编号。

引用会显示为议题链接。

<a id="disable-the-gitlab-issue-tracker"></a>

## 禁用极狐GitLab 议题跟踪器

要禁用项目的工作项，包括极狐GitLab 议题跟踪器：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **工作项** 下，关闭切换开关。
1. 选择 **保存更改**。

禁用工作项设置后，**工作项** 在左侧边栏中不可见。如果你配置了 [外部议题跟踪器](#configure-an-external-issue-tracker)，它仍会保留在左侧边栏中。

<a id="configure-an-external-issue-tracker"></a>

## 配置外部议题跟踪器

你可以配置以下任一外部议题跟踪器：

- [Bugzilla](../user/project/integrations/bugzilla.md)
- [ClickUp](../user/project/integrations/clickup.md)
- [自定义议题跟踪器](../user/project/integrations/custom_issue_tracker.md)
- [Engineering Workflow Management (EWM)](../user/project/integrations/ewm.md)
- [Jira](jira/_index.md)
- [Linear](../user/project/integrations/linear.md)
- [Phorge](../user/project/integrations/phorge.md)
- [Redmine](../user/project/integrations/redmine.md)
- [YouTrack](../user/project/integrations/youtrack.md)

## 创建和链接 Kerberos 账户

你可以将 Kerberos 账户链接到现有极狐GitLab 账户，或者设置极狐GitLab 在 Kerberos 用户尝试登录时创建新账户。

### 将 Kerberos 账户链接到现有极狐GitLab 账户

{{< history >}}

- Kerberos SPNEGO 在极狐GitLab 15.4 中 [重命名](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/96335) 为 Kerberos。

{{< /history >}}

如果你是管理员，你可以将 Kerberos 账户链接到现有极狐GitLab 账户。操作如下：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 选择一个用户，然后选择 **身份** 选项卡。
1. 从 **提供者** 下拉列表中选择 **Kerberos**。
1. 确保 **标识符** 与 Kerberos 用户名对应。
1. 选择 **保存更改**。

如果你不是管理员：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏，选择 **访问** > **密码和身份验证**。
1. 在 **服务登录** 部分，选择 **连接 Kerberos**。如果没有看到 **服务登录** 的 Kerberos 选项，请按照 [启用单点登录](#enable-single-sign-on) 中的要求操作。

无论哪种情况，你现在应该能够使用 Kerberos 凭据登录你的极狐GitLab 账户。

### 首次登录时创建账户

用户首次使用其 Kerberos 账户登录极狐GitLab 时，极狐GitLab 会创建一个匹配的账户。
在继续之前，请查看 Linux 软件包和自行编译实例的 [通用配置设置](omniauth.md#configure-common-settings) 选项。你还必须包含 `kerberos`。

掌握这些信息后：

1. 在 `allow_single_sign_on` 设置中包含 `'kerberos'`。
1. 目前，接受默认的 `block_auto_created_users` 选项，即 true。
1. 当用户尝试使用 Kerberos 凭据登录时，极狐GitLab 会创建一个新账户。
   1. 如果 `block_auto_created_users` 为 true，Kerberos 用户可能会看到类似以下的消息：

      ```shell
      Your account has been blocked. Please contact your GitLab
      administrator if you think this is an error.
      ```

      1. 作为管理员，你可以确认新的已阻止账户：
         1. 在右上角，选择 **管理员**。
         1. 在左侧边栏，选择 **概览** > **用户**，然后查看 **已阻止** 选项卡。
      1. 你可以启用该用户。
   1. 如果 `block_auto_created_users` 为 false，则 Kerberos 用户通过身份验证并登录极狐GitLab。

> [!warning]
> 我们建议你保留 `block_auto_created_users` 的默认设置。在管理员不知情的情况下，Kerberos 用户在极狐GitLab 上创建账户可能存在安全风险。

## 将 Kerberos 和 LDAP 账户链接在一起

如果你的用户使用 Kerberos 登录，但你也启用了 [LDAP 集成](../administration/auth/ldap/_index.md)，那么用户首次登录时会链接到其 LDAP 账户。要实现这一点，必须满足一些先决条件：

Kerberos 用户名必须与 LDAP 用户的 UID 匹配。你可以在极狐GitLab [LDAP 配置](../administration/auth/ldap/_index.md#configure-ldap) 中选择哪个 LDAP 属性用作 UID，但对于 Active Directory，这应该是 `sAMAccountName`。

Kerberos 领域必须与 LDAP 用户可分辨名称的域部分匹配。例如，如果 Kerberos 领域是 `AD.EXAMPLE.COM`，那么 LDAP 用户的可分辨名称应以 `dc=ad,dc=example,dc=com` 结尾。

综合起来，这些规则意味着只有当用户的 Kerberos 用户名格式为 `foo@AD.EXAMPLE.COM`，并且其 LDAP 可分辨名称类似于 `sAMAccountName=foo,dc=ad,dc=example,dc=com` 时，链接才会生效。

### 自定义允许的领域

当用户的 Kerberos 领域与用户 LDAP DN 中的域不匹配时，你可以配置自定义允许的领域。配置值必须指定用户可能拥有的所有域。任何其他域都会被忽略，并且不会链接 LDAP 身份。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['kerberos_simple_ldap_linking_allowed_realms'] = ['example.com','kerberos.example.com']
   ```

1. 保存文件并 [重新配置](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   kerberos:
     simple_ldap_linking_allowed_realms: ['example.com','kerberos.example.com']
   ```

1. 保存文件并 [重启](../administration/restart_gitlab.md#self-compiled-installations) 极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

## HTTP Git 访问

链接的 Kerberos 账户使你能够使用 Kerberos 账户以及标准的极狐GitLab 凭据进行 `git pull` 和 `git push`。

拥有链接的 Kerberos 账户的极狐GitLab 用户还可以使用 Kerberos 令牌进行 `git pull` 和 `git push`。也就是说，无需在每次操作时发送密码。

> [!warning]
> 存在一个 [已知问题](https://github.com/curl/curl/issues/1261)，涉及版本低于 7.64.1 的 `libcurl`，它在协商时不重用连接。当推送大于 `http.postBuffer` 配置时，这会导致授权问题。确保 Git 至少使用 `libcurl` 7.64.1 以避免此问题。要了解已安装的 `libcurl` 版本，请运行 `curl-config --version`。

### 使用 Kerberos 令牌的 HTTP Git 访问（无密码身份验证）

由于 [当前 Git 版本中的一个错误](https://lore.kernel.org/git/YKNVop80H8xSTCjz@coredump.intra.peff.net/T/#mab47fd7dcb61fee651f7cc8710b8edc6f62983d5)，如果 HTTP 服务器提供 `negotiate` 身份验证方法，即使该方法失败（例如客户端没有 Kerberos 令牌），`git` CLI 命令也仅使用该方法。因此，如果 Kerberos 身份验证失败，无法回退到嵌入的用户名和密码（也称为 `basic`）身份验证。

为了让极狐GitLab 用户能够在当前 Git 版本中使用 `basic` 或 `negotiate` 身份验证，可以在不同的端口（例如 `8443`）上提供基于 Kerberos 票据的身份验证，而标准端口仅提供 `basic` 身份验证。

> [!note]
> [Git 2.4 及更高版本](https://github.com/git/git/blob/master/Documentation/RelNotes/2.4.0.adoc?plain=1#L225-L228) 支持在通过交互方式或凭据管理器传递用户名和密码时回退到 `basic` 身份验证。但是，当用户名和密码作为 URL 的一部分传递时，它无法回退。例如，在极狐GitLab CI/CD 作业中 [使用 CI/CD 作业令牌进行身份验证](../ci/jobs/ci_job_token.md) 时可能发生这种情况。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['kerberos_use_dedicated_port'] = true
   gitlab_rails['kerberos_port'] = 8443
   gitlab_rails['kerberos_https'] = true
   ```

1. [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）使用 HTTPS" >}}

1. 编辑极狐GitLab 的 NGINX 配置文件（例如 `/etc/nginx/sites-available/gitlab-ssl`），并配置 NGINX 除了标准 HTTPS 端口外还监听 `8443` 端口：

   ```conf
   server {
     listen 0.0.0.0:443 ssl;
     listen [::]:443 ipv6only=on ssl default_server;
     listen 0.0.0.0:8443 ssl;
     listen [::]:8443 ipv6only=on ssl;
   ```

1. 更新 [`gitlab.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/gitlab.yml.example) 中的 `kerberos` 部分：

   ```yaml
   kerberos:
     # 专用端口：Git 2.4 之前的版本在 Negotiate 失败时不会回退到 Basic 身份验证。
     # 为了支持旧版本 Git 同时使用 Basic 和 Negotiate 方法，请配置
     # nginx 在额外端口（例如：8443）上代理极狐GitLab，并取消注释以下行
     # 以将此端口专用于 Kerberos 身份验证。（默认：false）
     use_dedicated_port: true
     port: 8443
     https: true
   ```

1. [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations) 和 NGINX 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

完成此更改后，必须将 Git 远程 URL 更新为 `https://gitlab.example.com:8443/mygroup/myproject.git` 才能使用基于 Kerberos 票据的身份验证。

## 从基于密码的 Kerberos 登录升级到基于票据的登录

在极狐GitLab 的早期版本中，用户登录时必须向极狐GitLab 提交其 Kerberos 用户名和密码。

我们在极狐GitLab 15.0 中 [移除了](https://gitlab.com/gitlab-org/gitlab/-/issues/2908) 基于密码的 Kerberos 登录。

## 对 Active Directory Kerberos 环境的支持

在 Active Directory 域中使用基于 Kerberos 票据的身份验证时，可能需要增加 NGINX 允许的最大标头大小，因为 Kerberos 协议的扩展可能导致 HTTP 身份验证标头大于默认的 8 kB 大小。在 [NGINX 配置](https://nginx.org/en/docs/http/ngx_http_core_module.html#large_client_header_buffers) 中将 `large_client_header_buffers` 配置为更大的值。

### 使用通过仅 AES 加密创建的 Keytab 与 Windows AD

当你使用仅高级加密标准 (AES) 加密创建 keytab 时，必须在 AD 服务器中为该账户选中 **此账户支持 Kerberos AES <128/256> 位加密** 复选框。复选框是 128 位还是 256 位取决于创建 keytab 时使用的加密强度。要检查这一点，请在 Active Directory 服务器上：

1. 打开 **用户和组** 工具。
1. 找到用于创建 keytab 的账户。
1. 右键单击该账户并选择 **属性**。
1. 在 **账户** 选项卡的 **账户选项** 中，选中相应的 AES 加密支持复选框。
1. 保存并关闭。