---
stage: Security Platform
group: Secrets Manager Application
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 密钥管理器
ignore_in_report: true
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab 密钥管理器安全地加密、存储和检索您的项目和群组的凭据，该功能由 [OpenBao](https://openbao.org/) 提供支持。您无需硬编码凭据或依赖 CI/CD 变量，而是可以使用极狐GitLab 访问模型和审计系统，通过[完整的可审计性](../../../user/compliance/audit_event_types.md#secrets-management)来检索密钥。

密钥代表您的 CI/CD 作业运行所需的敏感信息，例如访问令牌、数据库凭据或私钥。与默认情况下始终可供作业使用的 CI/CD 变量不同，密钥必须由作业显式请求。

您可以[在 CI/CD 作业中使用密钥](#use-secrets-in-job-scripts)，也可以[在 CI/CD 之外用于运行时工作负载](non_cicd_access.md)，例如 Kubernetes、Terraform，或通过 API 使用。

极狐GitLab 密钥管理器[消耗极狐GitLab Credits](credit_usage.md)。

欢迎在 [议题 598100](https://gitlab.com/gitlab-org/gitlab/-/work_items/598100)中分享您的反馈。

<a id="enable-gitlab-secrets-manager"></a>

## 启用极狐GitLab 密钥管理器

为顶级群组启用密钥管理器后，该群组中的所有子群组和项目也可以使用它。

在极狐GitLab 私有化部署上，管理员必须先为实例[安装并启用极狐GitLab 密钥管理器](../../../administration/secrets_manager/_index.md)。安装并启用密钥管理器后，您可以为实例上的特定群组和项目启用它。

<a id="for-gitlabcom"></a>

### 适用于 JihuLab.com

{{< details >}}

Status: 有限可用性

{{< /details >}}

先决条件：

- 您必须拥有顶级群组的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的顶级群组。
1. 在左侧边栏中，选择**安全** > **密钥管理器**。
1. 选择**开始 30 天试用**。

<a id="for-gitlab-self-managed"></a>

### 适用于极狐GitLab 私有化部署

{{< details >}}

- Status: 测试版

{{< /details >}}

> [!note]
> 极狐GitLab 密钥管理器在公开测试期间免费。极狐GitLab 会在正式发布前通知您，以便您有时间开始试用或接受极狐GitLab Credits 的用量计费条款。

<a id="for-a-project"></a>

#### 适用于项目

先决条件：

- 您必须拥有该项目的所有者角色。

要为项目启用或禁用极狐GitLab 密钥管理器：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 打开**极狐GitLab 密钥管理器**开关，并等待密钥管理器完成预配。

   > [!warning]
   > 如果您之后为该项目禁用密钥管理器，该项目的所有密钥都将被永久删除。
   > 这些密钥无法恢复。

为项目定义的密钥只能由同一项目的流水线访问。

<a id="for-a-group"></a>

#### 适用于群组

先决条件：

- 您必须拥有该群组的所有者角色。

要为群组启用或禁用极狐GitLab 密钥管理器：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中：
   - 在顶级群组中，选择**设置** > **安全**。
   - 在子群组中，选择**设置** > **通用**并展开**权限和群组功能**。
1. 打开**极狐GitLab 密钥管理器**开关，并等待密钥管理器完成预配。

   > [!warning]
   > 如果您之后为群组禁用密钥管理器，该群组的所有密钥都将被永久删除。
   > 这些密钥无法恢复。

为群组定义的密钥只能由直接位于该群组下或其子群组层级中的项目内的流水线访问。

<a id="define-a-secret"></a>

## 定义密钥

您可以将密钥添加到密钥管理器，以便将其用于安全的 CI/CD 流水线和工作流。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 选择**安全** > **密钥管理器**。
1. 选择**添加密钥**并填写详细信息：
   - **名称**：在创建该密钥的项目或群组中必须唯一，不超过 255 个字符，且只能包含字母、
     数字和下划线（`_`）。创建密钥后无法更改名称。
   - **值**：必须不超过 10 KB（10,000 字节）。
   - **描述**：最多 200 个字符。
   - **环境**：可以是：
     - **全部（默认）**（`*`）
     - 特定的[环境](../../environments/_index.md#types-of-environments)。
     - [通配符环境](../../environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。
   - **分支**：此选项仅存在于项目设置中。可以是：
     - 特定分支。
     - 通配符分支（必须包含 `*` 字符）。
   - **受保护**：此选项仅存在于群组设置中。可选。仅将密钥导出到在受保护分支上运行的流水线。
   - **轮换提醒**：可选。在设定的天数后发送电子邮件提醒以轮换密钥。
     最少 7 天。

[默认情况下](../../../administration/instance_limits.md#secrets-manager-limits)，每个项目最多可存储 100 个密钥，每个群组最多可存储 500 个密钥。子群组或成员项目中的密钥不计入父群组的限制。

创建密钥后：

- 您可以在流水线配置或作业脚本中使用它。
- 如果您编辑密钥，只能使用新值覆盖该值。
  您无法通过 UI 检索密钥值。有关更多信息，请查看
  [极狐GitLab 密钥管理器的权限](../../../user/permissions.md#project-secrets-manager)。

> [!warning]
> 密钥的值可供为创建或更新密钥时定义的特定环境或分支运行的所有 CI/CD 流水线作业访问。
> 请确保只有有权访问这些密钥值的用户才能为指定的环境或分支运行作业。

<a id="use-secrets-in-job-scripts"></a>

## 在作业脚本中使用密钥

默认情况下，与[文件类型 CI/CD 变量](../../variables/_index.md#use-file-type-cicd-variables)类似，密钥在作业中以文件的形式提供，并关联一个环境变量：

- 密钥的键是环境变量名称。
- 密钥的值保存到临时文件中。与掩码 CI/CD 变量不同，密钥可以包含空格和换行符。
- 临时文件的路径是环境变量的值。

在作业脚本中，使用接受文件作为输入的命令来使用密钥，或者可选地直接[将密钥用作环境变量](#use-a-secret-as-an-environment-variable-with-file-false)。

如果作业输出了密钥的值，极狐GitLab 会在作业日志中将该值替换为 `[MASKED]`。

<a id="for-project-secrets"></a>

### 适用于项目密钥

先决条件：

- 极狐GitLab Runner 19.0 或更高版本。

要访问为项目存储在密钥管理器中的密钥，请使用 [`secrets`](../../yaml/_index.md#secrets) 和 `gitlab_secrets_manager` 关键字。

例如：

```yaml
job:
  secrets:
    KUBE_CA_PEM:
      gitlab_secrets_manager:
        name: kube_cert
  script:
   - kubectl config set-cluster e2e --server="https://example.com" --certificate-authority="$KUBE_CA_PEM"
```

<a id="for-group-secrets"></a>

### 适用于群组密钥

先决条件：

- 极狐GitLab Runner 19.0 或更高版本。

要访问为群组存储在密钥管理器中的密钥：

- 使用 [`secrets`](../../yaml/_index.md#secrets) 和 `gitlab_secrets_manager` 关键字。
- 使用 `source` 字段将群组指定为密钥管理器来源；该字段的值以 `group/` 为前缀，后跟 `<full-path-to-group>`。

例如：

```yaml
job:
  secrets:
    KUBE_CA_PEM:
      gitlab_secrets_manager:
        name: kube_cert
        source: group/my-group/my-subgroup
  script:
   - kubectl config set-cluster e2e --server="https://example.com" --certificate-authority="$KUBE_CA_PEM"
```

<a id="use-a-secret-as-an-environment-variable-with-file-false"></a>

### 使用 `file: false` 将密钥用作环境变量

要将密钥用作环境变量而不将其存储在文件中，请为该密钥设置 `file: false`。例如：

```yaml
job:
  secrets:
    DEPLOY_SECRET:
      gitlab_secrets_manager:
        name: deploy_credentials
      file: false
  script:
    - my_deploy_command --user username --pass $DEPLOY_SECRET
```

在此示例中，密钥以 `DEPLOY_SECRET` 变量的形式提供给作业，您可以像使用任何其他环境变量一样使用它。

<a id="secret-rotation-notifications"></a>

## 密钥轮换通知

项目中拥有所有者角色的用户会在密钥配置中指定的日期收到轮换密钥的电子邮件通知。

<a id="access-secrets-from-non-cicd-workloads"></a>

## 从非 CI/CD 工作负载访问密钥

不以极狐GitLab CI/CD 作业形式运行的工作负载可以通过密钥管理器 API 读取密钥。有关更多信息，请参阅[从非 CI/CD 工作负载访问密钥](non_cicd_access.md)。

<a id="manage-secrets-permissions"></a>

## 管理密钥权限

<a id="for-a-project-1"></a>

### 适用于项目

先决条件：

- 您必须拥有该项目的所有者角色才能管理密钥权限。
- 拥有该项目维护者角色的用户可以查看已定义的权限。
- 必须为该项目启用密钥管理器。

要更新项目的密钥权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 在**极狐GitLab 密钥管理器**下，在**用户权限**部分中：
   - 选择**添加**为特定用户或角色添加权限规则。
   - 您可以将权限范围设置为读取元数据、读取值、写入（创建和更新）以及删除密钥。

对于在极狐GitLab 19.4 及更高版本中启用的密钥管理器，拥有该项目维护者角色的用户默认拥有读取和写入（创建和更新）权限。

拥有该项目开发者角色的用户默认拥有读取元数据和创建权限。创建权限不包括更新，因此这些用户可以添加密钥，但无法更改已存在的密钥。

拥有所有者角色的用户可以移除或更改这些默认权限。

<a id="for-a-group-1"></a>

### 适用于群组

先决条件：

- 您必须拥有该群组的所有者角色才能管理密钥权限。
  只有拥有该群组所有者角色的用户才能查看已定义的权限。
- 必须为该群组启用密钥管理器。

要更新群组的密钥权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中：
   - 在顶级群组中，选择**设置** > **安全**。
   - 在子群组中，选择**设置** > **通用**并展开**权限和群组功能**。
1. 在**极狐GitLab 密钥管理器**下，在**用户权限**部分中：
   - 选择**添加**为特定用户或角色添加权限规则。
   - 您可以将权限范围设置为读取元数据、读取值、写入（创建和更新）以及删除密钥。

拥有该群组所有者角色的用户始终拥有在密钥管理器中执行所有操作的权限。

<a id="deletion-of-a-project-or-group"></a>

## 删除项目或群组

当您[删除项目](../../../user/project/working_with_projects.md#delete-a-project)或[删除群组](../../../user/group/_index.md#schedule-a-group-for-deletion)且其中包含密钥时：

- 该项目或群组的密钥管理器将被禁用，并从密钥存储引擎中移除。
- 所有密钥都将被永久删除。

<a id="transfer-of-a-project-or-group"></a>

## 转移项目或群组

当您[转移项目](../../../user/project/working_with_projects.md#transfer-a-project)或[转移群组](../../../user/group/manage.md#transfer-a-group)且其中包含密钥时：

- 为该项目或群组定义的密钥不会转移到其新命名空间中的项目或群组。
- 该项目或群组的密钥管理器将被禁用，并从密钥存储引擎中移除。
- 所有密钥都将被永久删除。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-reading-from-vault-api-error-status-code-403"></a>

### 错误：`reading from Vault: api error: status code 403`

当 CI/CD 流水线作业尝试获取密钥时，可能会返回此错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: getting secret: get secret data: reading from Vault: api error: status code 403: 1 error occurred: * permission denied
```

当作业尝试获取不存在或已被删除的密钥时，会发生此错误。

<a id="error-inline-auth-jwt-is-required"></a>

### 错误：`inline auth JWT is required`

当 CI/CD 流水线作业尝试获取密钥时，可能会返回此错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: creating vault client: configuring inline auth: inline auth JWT is required
```

当预期密钥所属的项目或群组尚未预配密钥管理器实例时，会发生此错误。由于尚不存在密钥管理器角色，Runner 无法配置身份验证。

要解决此错误，请为您的项目或群组启用密钥管理器。

等待预配完成并创建密钥，然后重新运行流水线。

<a id="error-namespace-does-not-have-access-to-gitlab-secrets-manager"></a>

### 错误：`namespace does not have access to GitLab Secrets Manager`

当命名空间无权访问极狐GitLab 密钥管理器时，向极狐GitLab 密钥管理器请求密钥的作业会在 Runner 获取它们之前失败并显示此错误。

<a id="gitlabcom"></a>

#### JihuLab.com

JihuLab.com 上的可能原因：

- 试用已过期。
- 该群组没有可用的极狐GitLab Credits。
- 按需计费已关闭。
- 订阅宽限期已过。
- 公开测试已结束，且该命名空间未选择加入。

要为顶级群组恢复访问权限，请开始免费试用或为密钥管理器启用按需计费。如果订阅已失效，请续订。有关更多信息，请参阅[极狐GitLab 密钥管理器用量和计费](secrets_manager_billing.md)。

<a id="gitlab-self-managed"></a>

#### 极狐GitLab 私有化部署

在极狐GitLab 私有化部署上，极狐GitLab 在实例级别而非按群组解析对密钥管理器的访问权限。

可能原因：

- 该实例使用的是试用许可证。密钥管理器试用仅适用于付费订阅。
- 密钥管理器试用已过期。
- 该实例订阅不包含极狐GitLab 密钥管理器。
- 订阅宽限期已过。
- 对于离线许可证，该许可证不包含有效的极狐GitLab 密钥管理器附加组件。

要恢复访问权限，请让实例管理员将极狐GitLab 密钥管理器添加到实例订阅中。拥有付费订阅的实例也可以开始免费试用。
