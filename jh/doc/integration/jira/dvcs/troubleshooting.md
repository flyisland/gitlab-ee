---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 解决 Jira DVCS 连接器的访问、会话令牌和 SSL 或 TLS 连接错误。
title: Jira DVCS 连接器故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [Jira DVCS 连接器](_index.md) 时，您可能会遇到以下问题。

<a id="jira-cannot-access-the-gitlab-server"></a>

## Jira 无法访问极狐GitLab 服务器

如果您填写了 **添加新账户** 表单、授权访问，然后收到此错误，说明 Jira 和极狐GitLab 无法连接。任何日志中都不会出现其他错误消息：

```plaintext
Error obtaining access token. Cannot access https://gitlab.example.com from Jira.
```

<a id="session-token-bug-in-jira"></a>

## Jira 中的会话令牌缺陷

在 Jira Server 中使用极狐GitLab 时，您可能会遇到
[Jira 中的会话令牌缺陷](https://jira.atlassian.com/browse/JSWSERVER-21389)。
此缺陷影响 Jira Server 8.20.8、8.22.3、8.22.4、9.4.6 和 9.4.14。

要解决此问题，请确保使用 Jira Server 8.20.11 及更高版本，或 9.1.0 及更高版本。

<a id="ssl-and-tls-problems"></a>

## SSL 和 TLS 问题

SSL 和 TLS 问题可能会导致以下错误消息：

```plaintext
Error obtaining access token. Cannot access https://gitlab.example.com from Jira.
```

- [Jira 议题集成](../_index.md)需要
  极狐GitLab 连接到 Jira。由私有证书颁发机构或自签名证书
  引起的任何 TLS 问题，都在
  [极狐GitLab 服务器上](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)解决，
  因为极狐GitLab 是 TLS 客户端。
- Jira 开发面板需要 Jira 连接到极狐GitLab，这
  使得 Jira 成为 TLS 客户端。如果您的极狐GitLab 服务器证书不是
  由公共证书颁发机构签发的，请将相应的证书
  （例如您组织的根证书）添加到 Jira Server 上的 Java 信任库。

有关设置 Jira 的更多信息，请参阅 Atlassian 文档和 Atlassian 支持。

- [添加证书](https://confluence.atlassian.com/kb/how-to-import-a-public-ssl-certificate-into-a-jvm-867025849.html)
  到信任库。
  - 最简单的方法是使用 [`keytool`](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)。
  - 将其他根证书添加到 Java 的默认信任库（`cacerts`），以允许 Jira
    也信任公共证书颁发机构。
  - 如果升级 Jira Java 运行时后集成停止工作，
    `cacerts` 信任库可能在升级过程中被替换。
- 使用 `SSLPoke` Java 类排查连接问题
  [直至并包括 TLS 握手](https://confluence.atlassian.com/kb/unable-to-connect-to-ssl-services-due-to-pkix-path-building-failed-error-779355358.html)。
- 从 Atlassian 知识库下载该类到 Jira Server 上的某个目录，例如 `/tmp`。
- 使用与 Jira 相同的 Java 运行时。
- 传入调用 Jira 时使用的所有网络相关参数，例如代理
  设置或替代根信任库（`-Djavax.net.ssl.trustStore`）：

```shell
${JAVA_HOME}/bin/java -Djavax.net.ssl.trustStore=/var/atlassian/application-data/jira/cacerts -classpath /tmp SSLPoke gitlab.example.com 443
```

消息 `Successfully connected` 表示 TLS 握手成功。

如果存在问题，Java TLS 库会生成错误，您可以查阅这些错误以了解更多详情。

<a id="scope-error-when-connecting-to-jira-with-dvcs"></a>

## 使用 DVCS 连接到 Jira 时出现范围错误

```plaintext
The requested scope is invalid, unknown, or malformed.
```

可能的解决方法：

1. 验证在
   [Jira DVCS 连接器设置](https://confluence.atlassian.com/adminjiraserver/linking-gitlab-accounts-1027142272.html#LinkingGitLabaccounts-InJiraagain)中从 Jira 重定向后浏览器显示的 URL，其
   查询字符串中是否包含 `scope=api`。
1. 如果 URL 中缺少 `scope=api`，请编辑
   [极狐GitLab 账号配置](https://confluence.atlassian.com/adminjiraserver/linking-gitlab-accounts-1027142272.html#LinkingGitLabaccounts-InGitLab)。查看
   **范围** 部分，确保已选中 `api` 复选框。

<a id="error-410-gone"></a>

## 错误：`410 Gone`

当您连接到 Jira 并同步代码仓库时，可能会收到 `410 Gone` 错误。
当您使用 Jira DVCS 连接器且集成配置为使用 **GitHub Enterprise** 时，会出现此问题。

更多信息，请参阅[议题 340160](https://gitlab.com/gitlab-org/gitlab/-/issues/340160)。

<a id="synchronization-issues"></a>

## 同步问题

如果 Jira 显示不正确的信息，例如已删除的分支，您可能需要重新同步信息：

1. 在 Jira 中，选择 **Jira 管理** > **应用程序** > **DVCS 账户**。
1. 对于该账号（群组或子群组），从 {{< icon name="ellipsis_h" >}}（省略号）菜单中选择
   **刷新仓库**。
1. 对于每个项目，在 **最后活动** 日期旁边：
   - 要执行软重新同步，请选择同步图标。
   - 要完成完全同步，请按住 `Shift` 并选择同步图标。

更多信息，请参阅
[Atlassian 文档](https://support.atlassian.com/jira-cloud-administration/docs/integrate-with-development-tools/)。

<a id="error-sync-failed"></a>

## 错误：`Sync Failed`

如果您在 Jira 中为特定项目[刷新代码仓库数据](_index.md#refresh-data-imported-to-jira)时收到 `Sync Failed` 错误，请检查您的 Jira DVCS 连接器日志。查找执行对极狐GitLab 中 API 资源的请求时发生的错误。例如：

```plaintext
Failed to execute request [https://jihulab.com/api/v4/projects/:id/merge_requests?page=1&per_page=100 GET https://jihulab.com/api/v4/projects/:id/merge_requests?page=1&per_page=100 returned a response status of 403 Forbidden] errors:
{"message":"403 Forbidden"}
```

如果您收到 `403 Forbidden` 错误，则此项目可能关闭了一些[极狐GitLab 功能](../../../user/project/settings/_index.md#configure-project-features-and-permissions)。在上面的示例中，合并请求功能已关闭。

要解决此问题，请开启相关功能：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 根据需要，使用开关开启相应功能。

<a id="find-webhook-logs-in-a-dvcs-linked-project"></a>

## 在 DVCS 链接的项目中查找 webhook 日志

要在 DVCS 链接的项目中查找 webhook 日志：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **Webhooks**。
1. 向下滚动到 **项目钩子**。
1. 在指向您的 Jira 实例的日志旁边，选择**编辑**。
1. 向下滚动到 **最近事件**。

如果您在项目中找不到 webhook 日志，请检查您的 DVCS 设置是否存在问题。
