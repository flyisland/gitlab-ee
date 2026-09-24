---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Jira DVCS 连接器故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [Jira DVCS 连接器](_index.md)时，您可能会遇到以下问题。

<a id="jira-cannot-access-the-gitlab-server"></a>

## Jira 无法访问极狐GitLab 服务器

如果您填写了**添加新账户**表单，授权了访问，但收到此错误，说明 Jira 和极狐GitLab 无法连接。在任何日志中都没有出现其他错误消息：

```plaintext
获取访问令牌时出错。无法从 Jira 访问 https://gitlab.example.com。
```

<a id="session-token-bug-in-jira"></a>

## Jira 中的会话令牌错误

当您将极狐GitLab 15.0 及更高版本与 Jira Server 一起使用时，可能会遇到 [Jira 中的会话令牌错误](https://jira.atlassian.com/browse/JSWSERVER-21389)。此错误影响 Jira Server 8.20.8、8.22.3、8.22.4、9.4.6 和 9.4.14。

要解决此问题，请确保您使用的是 Jira Server 8.20.11 及更高版本，或 9.1.0 及更高版本。

<a id="ssl-and-tls-problems"></a>

## SSL 和 TLS 问题

SSL 和 TLS 问题可能导致以下错误消息：

```plaintext
获取访问令牌时出错。无法从 Jira 访问 https://gitlab.example.com。
```

- [Jira 议题集成](../_index.md)要求极狐GitLab 连接到 Jira。由私有证书颁发机构或自签名证书引起的任何 TLS 问题，都将在[极狐GitLab 服务器](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)上解决，因为极狐GitLab 是 TLS 客户端。
- Jira 开发面板要求 Jira 连接到极狐GitLab，这导致 Jira 成为 TLS 客户端。如果您的极狐GitLab 服务器证书不是由公共证书颁发机构签发的，请将适当的证书（例如您组织的根证书）添加到 Jira Server 上的 Java 信任库中。

有关设置 Jira 的更多信息，请参阅 Atlassian 文档和 Atlassian 支持。

- [将证书](https://confluence.atlassian.com/kb/how-to-import-a-public-ssl-certificate-into-a-jvm-867025849.html)添加到信任库。
  - 最简单的方法是使用 [`keytool`](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)。
  - 向 Java 的默认信任库 (`cacerts`) 添加其他根证书，以允许 Jira 也信任公共证书颁发机构。
  - 如果在升级 Jira Java 运行时后集成停止工作，则 `cacerts` 信任库可能在升级过程中被替换。
- 使用 `SSLPoke` Java 类排查[直至 TLS 握手的连接](https://confluence.atlassian.com/kb/unable-to-connect-to-ssl-services-due-to-pkix-path-building-failed-error-779355358.html)问题。
- 从 Atlassian 知识库将类下载到 Jira Server 上的目录，例如 `/tmp`。
- 使用与 Jira 相同的 Java 运行时。
- 传递 Jira 调用时使用的所有网络相关参数，例如代理设置或替代根信任库 (`-Djavax.net.ssl.trustStore`)：

```shell
${JAVA_HOME}/bin/java -Djavax.net.ssl.trustStore=/var/atlassian/application-data/jira/cacerts -classpath /tmp SSLPoke gitlab.example.com 443
```

消息 `Successfully connected` 表示 TLS 握手成功。

如果有问题，Java TLS 库会生成错误，您可以查阅这些错误以获取更多详细信息。

<a id="scope-error-when-connecting-to-jira-with-dvcs"></a>

## 使用 DVCS 连接 Jira 时出现范围错误

```plaintext
请求的范围无效、未知或格式错误。
```

可能的解决方法：

1. 在 [Jira DVCS 连接器设置](https://confluence.atlassian.com/adminjiraserver/linking-gitlab-accounts-1027142272.html#LinkingGitLabaccounts-InJiraagain)中从 Jira 重定向后，验证浏览器中显示的 URL 查询字符串是否包含 `scope=api`。
1. 如果 URL 中缺少 `scope=api`，请编辑[极狐GitLab 账户配置](https://confluence.atlassian.com/adminjiraserver/linking-gitlab-accounts-1027142272.html#LinkingGitLabaccounts-InGitLab)。检查**范围**字段，确保已选中 `api` 复选框。

<a id="error-410-gone"></a>

## 错误：`410 Gone`

当您连接 Jira 并同步仓库时，可能会收到 `410 Gone` 错误。此问题在您使用 Jira DVCS 连接器且集成配置为使用 **GitHub Enterprise** 时发生。

<a id="synchronization-issues"></a>

## 同步问题

如果 Jira 显示的信息不正确（例如已删除的分支），您可能需要重新同步信息：

1. 在 Jira 中，选择 **Jira 管理** > **应用程序** > **DVCS 账户**。
1. 对于账户（群组或子群组），从 {{< icon name="ellipsis_h" >}}（省略号）菜单中选择**刷新仓库**。
1. 对于每个项目，在**最后活动**日期旁边：
   - 要执行软重新同步，请选择同步图标。
   - 要完成完全同步，请按 `Shift` 并选择同步图标。

有关更多信息，请参阅 [Atlassian 文档](https://support.atlassian.com/jira-cloud-administration/docs/integrate-with-development-tools/)。

<a id="error-sync-failed"></a>

## 错误：`同步失败`

当您为特定项目[刷新导入到 Jira 的仓库数据](_index.md#refresh-data-imported-to-jira)时，如果在 Jira 中收到 `同步失败` 错误，请检查您的 Jira DVCS 连接器日志。查找在执行对极狐GitLab API 资源的请求时发生的错误。例如：

```plaintext
Failed to execute request [https://gitlab.com/api/v4/projects/:id/merge_requests?page=1&per_page=100 GET https://gitlab.com/api/v4/projects/:id/merge_requests?page=1&per_page=100 returned a response status of 403 Forbidden] errors:
{"message":"403 Forbidden"}
```

如果您收到 `403 Forbidden` 错误，该项目的某些[极狐GitLab 功能可能已禁用](../../../user/project/settings/_index.md#configure-project-features-and-permissions)。在上面的示例中，合并请求功能已禁用。

要解决此问题，请启用相关功能：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 使用切换开关根据需要启用功能。

<a id="find-webhook-logs-in-a-dvcs-linked-project"></a>

## 在 DVCS 关联项目中查找 Webhook 日志

要在 DVCS 关联的项目中查找 Webhook 日志：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **Webhooks**。
1. 向下滚动到**项目钩子**。
1. 在指向您的 Jira 实例的日志旁边，选择**编辑**。
1. 向下滚动到**最近事件**。

如果在项目中找不到 Webhook 日志，请检查您的 DVCS 设置是否存在问题。