---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 配置用户在极狐GitLab 私有化部署上可以创建的项目最大数量。配置附件、推送和代码仓库的大小限制。
title: 账户和限制设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 管理员可以配置其实例上的项目和账户限制，例如：

- 用户可以创建的项目数量。
- 附件、推送和代码仓库的大小限制。
- 会话时长和过期时间。
- 访问令牌设置，例如过期时间和前缀。
- 用户隐私和删除设置。
- 组织和顶级群组的创建规则。

<a id="default-projects-limit"></a>

## 默认项目限制

您可以配置新用户可以在其个人命名空间中创建的默认最大项目数。此限制仅影响您在更改设置后创建的新用户账户。此设置对现有用户不具有追溯性，但您可以单独编辑[现有用户的项目限制](#projects-limit-for-a-user)。

要为新用户配置个人命名空间中的最大项目数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 增加或减少 **默认项目限制** 值。

如果您将 **默认项目限制** 设置为 0，则不允许用户在其个人命名空间中创建项目。但是，仍然可以在群组中创建项目。

<a id="projects-limit-for-a-user"></a>

### 用户的项目限制

您可以编辑特定用户，并更改该用户可以在其个人命名空间中创建的最大项目数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 从用户列表中，选择一个用户。
1. 选择 **编辑**。
1. 增加或减少 **项目限制** 值。

<a id="max-attachment-size"></a>

## 最大附件大小

极狐GitLab 评论和回复中附件的最大文件大小为 100 MB。要更改最大附件大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 通过更改 **最大附件大小 (MiB)** 中的值来增加或减少。

如果您选择的大小大于为 Web 服务器配置的值，您可能会收到错误。有关更多信息，请参阅[故障排除部分](#troubleshooting)。

有关 JihuLab.com 的代码仓库大小限制，请参阅[账户和限制设置](../../user/jihulab_com/_index.md#account-and-limit-settings)。

<a id="max-push-size"></a>

## 最大推送大小

您可以更改实例的最大推送大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 通过更改 **最大推送大小 (MiB)** 中的值来增加或减少。

有关 JihuLab.com 的推送大小限制，请参阅[账户和限制设置](../../user/jihulab_com/_index.md#account-and-limit-settings)。

> [!note]
> 当您通过 Web UI [向代码仓库添加文件](../../user/project/repository/web_editor.md#create-a-file) 时，最大附件大小是限制因素。这是因为 Web 服务器必须在极狐GitLab 生成提交之前接收文件。使用 [Git LFS](../../topics/git/lfs/_index.md) 向代码仓库添加大文件。此设置不适用于推送 Git LFS 对象。

<a id="repository-size-limit"></a>

## 代码仓库大小限制

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 实例中的代码仓库可能会快速增长，尤其是在您使用 LFS 时。它们的大小可能呈指数级增长，迅速消耗可用存储空间。为防止这种情况发生，您可以为代码仓库的大小设置硬性限制。此限制可以全局设置、按群组设置或按项目设置，其中按项目设置的限制优先级最高。

代码仓库大小限制适用于私有项目和公共项目。它包括代码仓库文件和 Git LFS 对象（即使存储在外部对象存储中），但不包括：

- 产物
- 容器
- 软件包
- 代码片段
- 上传
- Wiki

在许多使用场景下，您可能需要为代码仓库大小设置限制。例如，请考虑以下工作流程：

1. 您的团队开发的应用需要在应用程序代码仓库中存储大文件。
1. 尽管您已为项目启用了 [Git LFS](../../topics/git/lfs/_index.md)，但您的存储空间已显著增长。
1. 在超出可用存储空间之前，您为每个代码仓库设置了 10 GB 的限制。

在极狐GitLab 私有化部署上，只有极狐GitLab 管理员可以设置这些限制。将限制设置为 `0` 表示没有限制。有关 JihuLab.com 的代码仓库大小限制，请参阅[账户和限制设置](../../user/jihulab_com/_index.md#account-and-limit-settings)。

这些设置可以在以下位置找到：

- 每个项目的设置：
  1. 从项目主页，转到 **设置** > **通用**。
  1. 在 **命名、主题、头像** 部分填写 **代码仓库大小限制 (MiB)** 字段。
  1. 选择 **保存更改**。
- 每个群组的设置：
  1. 从群组主页，转到 **设置** > **通用**。
  1. 在 **命名、可见性** 部分填写 **代码仓库大小限制 (MiB)** 字段。
  1. 选择 **保存更改**。
- 极狐GitLab 全局设置：
  1. 在右上角，选择 **管理员**。
  1. 选择 **设置** > **通用**。
  1. 展开 **账户和限制** 部分。
  1. 填写 **每个代码仓库的大小限制 (MiB)** 字段。
  1. 选择 **保存更改**。

新项目的首次推送（包括 LFS 对象）会检查大小。如果它们的大小总和超过允许的最大代码仓库大小，则推送将被拒绝。

<a id="check-repository-size"></a>

### 检查代码仓库大小

要确定项目是否接近其配置的代码仓库大小限制：

1. [查看您的存储使用情况](../../user/storage_usage_quotas.md#view-storage)。**代码仓库** 大小包括 Git 代码仓库文件和 [Git LFS](../../topics/git/lfs/_index.md) 对象。
1. 将当前使用情况与您配置的代码仓库大小限制进行比较，以估算剩余容量。

您还可以使用 [Projects API](../../api/projects.md) 检索代码仓库统计信息。

要减小代码仓库大小，请参阅[减小代码仓库大小的方法](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size)。

<a id="session-duration"></a>

## 会话时长

<a id="customize-the-default-session-duration"></a>

### 自定义默认会话时长

您可以更改用户在不活动的情况下保持登录状态的时间。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 填写 **会话时长（分钟）** 字段。
   > [!warning]
   > 将 **会话时长（分钟）** 设置为 `0` 会破坏您的极狐GitLab 实例。有关更多信息，请参阅[议题 19469](https://gitlab.com/gitlab-org/gitlab/-/issues/19469)。
1. 选择 **保存更改**。
如果启用了 [**记住我** 选项](#configure-the-remember-me-option)，用户的会话可以无限期保持活动状态。

有关详细信息，请参阅[用于登录的 Cookie](../../user/profile/_index.md#cookies-used-for-sign-in)。

<a id="set-sessions-to-expire-from-creation-date"></a>

### 设置会话从创建日期开始过期

默认情况下，会话在会话变为不活动后的一段时间后过期。您也可以将会话配置为在会话创建后的一段时间后过期。

当达到会话时长时，会话结束，用户被注销，即使：

- 用户仍在积极使用该会话。
- 用户在登录时选择了 [**记住我**](#configure-the-remember-me-option)。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选中 **从创建日期开始使会话过期** 复选框。

会话结束后，窗口会提示用户重新登录。

<a id="configure-the-remember-me-option"></a>

### 配置“记住我”选项

用户可以在登录时选择 **记住我** 复选框。从该特定浏览器访问时，他们的会话可以无限期保持活动状态。出于安全或合规目的，请关闭此设置以使会话过期。关闭此设置可确保用户的会话在您[自定义会话时长](#customize-the-default-session-duration)时设置的不活动分钟数后过期。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选中或清除 **记住我** 复选框以打开或关闭此设置。

<a id="customize-session-duration-for-git-operations-when-2fa-is-enabled"></a>

### 在启用 2FA 时自定义 Git 操作的会话时长

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- The history line is too old, but must remain until `feature_flags/development/two_factor_for_cli.yml` is removed -->

> [!flag]
> 此功能的可用性由功能标志控制。此功能尚未准备好用于生产环境。

极狐GitLab 管理员可以选择在启用 2FA 时自定义 Git 操作的会话时长（以分钟为单位）。默认值为 15，可以设置为 1 到 10080 之间的值。

要设置这些会话的有效时长限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 填写 **启用 2FA 时 Git 操作的会话时长（分钟）** 字段。
1. 选择 **保存更改**。

<a id="allow-top-level-group-owners-to-create-service-accounts"></a>

## 允许顶级群组所有者创建服务账号

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，只有管理员可以创建服务账号。您可以配置极狐GitLab 也允许顶级群组所有者创建服务账号。

先决条件：

- 您必须具有管理员访问权限。

要允许顶级群组所有者创建服务账号：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 在 **服务账号创建** 下，选中 **允许顶级群组所有者创建服务账号** 复选框。
1. 选择 **保存更改**。

<a id="require-expiration-dates-for-new-access-tokens"></a>

## 要求新访问令牌设置过期日期

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员。

您可以要求所有新访问令牌都设置过期日期。此设置默认开启，适用于：

- 非服务账号用户的个人访问令牌。
- 群组访问令牌。
- 项目访问令牌。

对于服务账号的个人访问令牌，请使用 [应用程序设置 API](../../api/settings.md) 中的 `service_access_tokens_expiration_enforced` 设置。

要要求新访问令牌设置过期日期：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选中 **个人 / 项目 / 群组访问令牌过期** 复选框。
1. 选择 **保存更改**。

当您要求新访问令牌设置过期日期时：

- 用户必须设置不超过新访问令牌允许生命周期的过期日期。
- 要控制最大访问令牌生命周期，请使用 [**限制访问令牌的生命周期** 设置](#limit-the-lifetime-of-access-tokens)。

<a id="inactive-project-and-group-access-token-retention-period"></a>

## 非活动项目和群组访问令牌保留期

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

默认情况下，极狐GitLab 会在令牌族中最后一个活动令牌变为非活动状态 30 天后，删除群组和项目访问令牌及其[令牌族](../../api/personal_access_tokens.md#automatic-reuse-detection)。此删除会移除令牌族中的所有令牌和关联的机器人用户，并将任何机器人贡献移至[幽灵用户](../../user/profile/account/delete_account.md#associated-records)。

先决条件：

- 管理员访问权限。

要修改非活动令牌的保留期：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 在 **非活动项目和群组访问令牌保留期** 文本框中，修改保留期。
   - 如果定义了数字，则所有群组和项目访问令牌在非活动指定天数后将被删除。
   - 如果该字段为空，则永远不会删除非活动令牌。
1. 选择 **保存更改**。

您还可以使用[应用程序设置 API](../../api/settings.md) 修改 `inactive_resource_access_tokens_delete_after_days` 属性。

<a id="personal-access-token-prefix"></a>

## 个人访问令牌前缀

您可以为个人访问令牌指定前缀。使用自定义前缀的好处包括：

- 令牌具有区分度且易于识别。
- 泄露的令牌在安全扫描中更容易识别。
- 降低不同实例之间令牌混淆的风险。

个人访问令牌的默认前缀是 `glpat-`，但管理员可以更改它。[项目访问令牌](../../user/project/settings/project_access_tokens.md) 和[群组访问令牌](../../user/group/settings/group_access_tokens.md) 也继承此前缀。

> [!warning]
> 默认情况下，客户端密钥检测、密钥推送保护和流水线密钥检测不会检测具有自定义前缀的令牌。这可能会导致漏报增加。但是，您可以[自定义流水线密钥检测](../../user/application_security/secret_detection/pipeline/configure.md#customize-analyzer-rulesets) 来检测这些令牌。

<a id="set-a-prefix"></a>

### 设置前缀

要更改默认的全局前缀：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 填写 **个人访问令牌前缀** 字段。
1. 选择 **保存更改**。

您还可以使用[设置 API](../../api/settings.md) 配置前缀。

<a id="instance-token-prefix"></a>

## 实例令牌前缀

> [!flag]
> 此功能的可用性由功能标志控制。此功能可用于测试，但尚未准备好用于生产环境。

您可以设置一个自定义前缀，该前缀将添加到实例上生成的所有令牌之前。使用自定义前缀的好处包括：

- 令牌具有区分度且易于识别。
- 泄露的令牌在安全扫描中更容易识别。
- 降低不同实例之间令牌混淆的风险。

> [!warning]
> 默认情况下，客户端密钥检测、密钥推送保护和流水线密钥检测不会检测具有自定义前缀的令牌。这可能会导致漏报增加。但是，您可以[自定义流水线密钥检测](../../user/application_security/secret_detection/pipeline/configure.md#customize-analyzer-rulesets) 来检测这些令牌。

自定义令牌前缀仅适用于以下令牌：

- [CI/CD 作业令牌](../../security/tokens/_index.md#cicd-job-tokens)
- [集群代理令牌](../../security/tokens/_index.md#gitlab-cluster-agent-tokens)
- [部署令牌](../../user/project/deploy_tokens/_index.md)
- [功能标志客户端令牌](../../operations/feature_flags.md#get-access-credentials)
- [Feed 令牌](../../security/tokens/_index.md#feed-token)
- [传入电子邮件令牌](../../security/tokens/_index.md#incoming-email-token)
- [OAuth 应用程序密钥](../../integration/oauth_provider.md)
- [个人访问令牌](../../user/profile/personal_access_tokens.md)
- [流水线触发器令牌](../../ci/triggers/_index.md#create-a-pipeline-trigger-token)
- [Runner 身份验证令牌](../../security/tokens/_index.md#runner-authentication-tokens)
- [SCIM 令牌](../../security/tokens/_index.md#token-prefixes)
- [工作区令牌](../../security/tokens/_index.md#workspace-token)

先决条件：

- 您必须对实例具有管理员访问权限。

要设置自定义令牌前缀：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 在 **实例令牌前缀** 字段中，输入您的自定义前缀。
1. 选择 **保存更改**。

`gl` 是保留前缀。在极狐GitLab 将默认实例令牌前缀从 `gl` 更改为无前缀之前保存其应用程序设置的实例，仍将 `gl` 存储为值。极狐GitLab 现在将存储的 `gl` 值视为与无前缀相同，因此您不能将实例令牌前缀设置为 `gl`。

<a id="limit-the-lifetime-of-access-tokens"></a>

## 限制访问令牌的生命周期

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 扩展的最大允许生命周期限制的可用性由功能标志控制。

用户可以选择为访问令牌指定最大生命周期（以天为单位）。这包括[个人](../../user/profile/personal_access_tokens.md)、[群组](../../user/group/settings/group_access_tokens.md) 和[项目](../../user/project/settings/project_access_tokens.md) 访问令牌。此生命周期不是强制要求，可以设置为任何大于 0 且小于或等于以下值的值：

- 默认 365 天。
如果此设置留空，则访问令牌的默认允许生命周期为：

- 默认 365 天。
访问令牌是程序化访问极狐GitLab 所需的唯一令牌。但是，有安全要求的组织可能希望通过要求定期轮换这些令牌来强制实施更多保护。

<a id="set-a-lifetime"></a>

### 设置生命周期

只有极狐GitLab 管理员可以设置生命周期。将其留空表示没有限制。

要设置访问令牌的有效时长：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 填写 **访问令牌的最大允许生命周期（天）** 字段。
1. 选择 **保存更改**。

设置访问令牌的生命周期后，极狐GitLab 将：

- 将生命周期应用于新的个人访问令牌，并要求用户设置过期日期，且日期不得晚于允许的生命周期。
- 三小时后，撤销没有过期日期或生命周期长于允许生命周期的旧令牌。留出三小时是为了让管理员在撤销发生之前更改或移除允许的生命周期。

<a id="limit-the-lifetime-of-ssh-keys"></a>

## 限制 SSH 密钥的生命周期

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

用户可以选择为 [SSH 密钥](../../user/ssh.md) 指定生命周期。此生命周期不是强制要求，可以设置为任意天数。

SSH 密钥是用户访问极狐GitLab 的凭据。但是，有安全要求的组织可能希望通过要求定期轮换这些密钥来强制实施更多保护。

<a id="set-a-lifetime-1"></a>

### 设置生命周期

只有极狐GitLab 管理员可以设置生命周期。将其留空表示没有限制。

要设置 SSH 密钥的有效时长：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 填写 **SSH 密钥的最大允许生命周期（天）** 字段。
1. 选择 **保存更改**。

设置 SSH 密钥的生命周期后，极狐GitLab 将：

- 要求用户为新 SSH 密钥设置不晚于允许生命周期的过期日期。最大允许生命周期为：
  - 默认 365 天。
- 将生命周期限制应用于现有 SSH 密钥。没有过期时间或生命周期大于最大值的密钥将立即失效。

> [!note]
> 当用户的 SSH 密钥失效时，他们可以删除并重新添加相同的密钥。

<a id="user-oauth-applications-setting"></a>

## 用户 OAuth 应用程序设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员。

**用户 OAuth 应用程序** 设置控制用户是否可以注册应用程序以使用极狐GitLab 作为 OAuth 提供程序。此设置影响用户拥有的 OAuth 应用程序，但不影响群组拥有的 OAuth 应用程序。

要打开或关闭 **用户 OAuth 应用程序** 设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 选中或清除 **用户 OAuth 应用程序** 复选框。
1. 选择 **保存更改**。

<a id="limit-the-lifetime-of-oauth-access-tokens"></a>

### 限制 OAuth 访问令牌的生命周期

默认情况下，OAuth 访问令牌在两小时（7200 秒）后过期。实例管理员可以为 OAuth 访问令牌配置自定义生命周期。

最小值为 300 秒（5 分钟）。未设置时，应用默认值 7200 秒（2 小时）。此设置适用于实例发出的所有新 OAuth 访问令牌。

先决条件：

- 您必须是管理员。

要为 OAuth 访问令牌设置生命周期：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制** 部分。
1. 填写 **OAuth 访问令牌生命周期（秒）** 字段。
1. 选择 **保存更改**。

您还可以使用[应用程序设置 API](../../api/settings.md) 和 `oauth_access_token_expires_in` 属性配置此设置。

<a id="turn-off-oauth-dynamic-client-registration"></a>

### 关闭 OAuth 动态客户端注册

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

OAuth 客户端（例如 MCP 客户端和 AI 工具）使用 OAuth 动态客户端注册 (DCR) 通过向 `POST /oauth/register` 发送请求来自动注册应用程序。默认情况下，DCR 已启用。

当您关闭 DCR 时，以下结果适用于 OAuth 客户端：

- OAuth 客户端无法自动注册应用程序。客户端必须改用预先注册的 OAuth 应用程序。
- 极狐GitLab 会删除动态注册的 OAuth 应用程序，并撤销其访问令牌和授权。

先决条件：

- 您必须是管理员。

要关闭 OAuth 动态客户端注册，请使用[应用程序设置 API](../../api/settings.md) 将 `dynamic_client_registration_enabled` 属性设置为 `false`。

<a id="disable-user-profile-name-changes"></a>

## 禁止用户更改个人资料名称

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为了维护[审计事件](../compliance/audit_event_reports.md) 中用户详细信息的完整性，极狐GitLab 管理员可以阻止用户更改其个人资料名称。

为此：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选择 **阻止用户更改其个人资料名称**。

选中后，极狐GitLab 管理员仍然可以在 [**管理员** 区域](../admin_area.md#administering-users) 或 [API](../../api/users.md#modify-a-user) 中更新用户名。

<a id="prevent-users-from-creating-organizations"></a>

## 阻止用户创建组织

{{< details >}}

- Status: 实验

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下此功能不可用。要使其可用，管理员可以[启用名为 `ui_for_organizations` 的功能标志](../feature_flags/_index.md)。在 JihuLab.com 上，此功能不可用。此功能尚未准备好用于生产环境。

默认情况下，用户可以创建组织。极狐GitLab 管理员可以阻止用户创建组织。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 清除 **允许用户创建组织** 复选框。

<a id="prevent-new-users-from-creating-top-level-groups"></a>

## 阻止新用户创建顶级群组

默认情况下，新用户可以创建顶级群组。极狐GitLab 管理员可以阻止新用户创建顶级群组：

- 在极狐GitLab UI 中，按照本节中的步骤操作。
- 使用[应用程序设置 API](../../api/settings.md#update-application-settings)。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 清除 **允许新用户创建顶级群组** 复选框。

> [!note]
> 此设置仅适用于您关闭该设置后添加的用户。现有用户仍然可以创建顶级群组。

<a id="prevent-non-members-from-creating-projects-and-groups"></a>

## 阻止非成员创建项目和群组

默认情况下，具有访客角色的用户可以创建项目和群组。极狐GitLab 管理员可以阻止此行为：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 清除 **允许具有访客角色的用户创建群组和个人项目** 复选框。
1. 选择 **保存更改**。

<a id="prevent-users-from-making-their-profiles-private"></a>

## 阻止用户将其个人资料设为私有

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，用户可以将其个人资料设为私有。极狐GitLab 管理员可以禁用此设置，以要求所有用户个人资料公开。此设置不影响[内部用户](../internal_users.md)（有时称为“机器人”）。

要阻止用户将其个人资料设为私有：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 清除 **允许用户将其个人资料设为私有** 复选框。
1. 选择 **保存更改**。

当您关闭此设置时：

- 所有私有用户个人资料都将变为公开。
- [默认将新用户的个人资料设为私有](#set-profiles-of-new-users-to-private-by-default) 的选项也会被关闭。

当您重新启用此设置时，将选中用户[先前设置的个人资料可见性](../../user/profile/_index.md#make-your-user-profile-page-private)。

<a id="set-profiles-of-new-users-to-private-by-default"></a>

## 默认将新用户的个人资料设为私有

默认情况下，新创建的用户拥有公开个人资料。极狐GitLab 管理员可以默认将新用户的个人资料设为私有：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选中 **默认将新用户的个人资料设为私有** 复选框。
1. 选择 **保存更改**。

> [!note]
> 如果 [**允许用户将其个人资料设为私有**](#prevent-users-from-making-their-profiles-private) 被禁用，则此设置也会被禁用。

<a id="prevent-users-from-deleting-their-accounts"></a>

## 阻止用户删除其账户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，用户可以删除自己的账户。极狐GitLab 管理员可以阻止用户删除自己的账户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 清除 **允许用户删除自己的账户** 复选框。

<a id="automatically-accept-achievements-for-all-users"></a>

## 自动接受所有用户的成就

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，用户必须明确接受[成就](../../user/profile/achievements.md)，然后它才会出现在其用户个人资料中。您也可以配置一个设置，为实例上的所有用户自动接受新授予的成就。

开启后，新成就将立即被接受并显示在接收者的用户个人资料上。极狐GitLab 仍会为成就发送电子邮件通知，但电子邮件不再包含接受链接。此设置不适用于在开启该设置之前授予的成就。

接收者仍然可以[从其个人资料中隐藏成就](../../user/profile/achievements.md#change-visibility-of-specific-achievements)。

要为所有用户自动接受成就：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **账户和限制**。
1. 选中 **自动接受所有用户的成就** 复选框。
1. 选择 **保存更改**。

<a id="troubleshooting"></a>

## 故障排除

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

<a id="413-request-entity-too-large"></a>

### 413 请求实体过大

在极狐GitLab 中向评论或回复附加文件时，[最大附件大小](#max-attachment-size) 可能大于 Web 服务器允许的值。

要在 [Linux 软件包](https://gitlab.cn/docs/omnibus/) 安装中将最大附件大小增加到 200 MB：

1. 将以下行添加到 `/etc/gitlab/gitlab.rb`：

   ```ruby
   nginx['client_max_body_size'] = "200m"
   ```

1. 增加最大附件大小。

<a id="this-repository-has-exceeded-its-size-limit"></a>

### 此代码仓库已超出其大小限制

如果您在 [Rails 异常日志](../logs/_index.md#exceptions_jsonlog) 中收到间歇性推送错误，如下所示：

```plaintext
Your push to this repository cannot be completed because this repository has exceeded the allocated storage for your project.
```

[维护](../housekeeping.md) 任务可能导致您的代码仓库大小增长。要解决此问题，以下任一选项在中短期内会有所帮助：

- 增加[代码仓库大小限制](#repository-size-limit)。
- [减小代码仓库大小](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size)。
