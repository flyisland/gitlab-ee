---
stage: Security Platform
group: Secrets Manager Application
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Secrets Manager
ignore_in_report: true
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab Secrets Manager 安全地存储和管理项目和群组的密钥及凭据。

密钥是您的 CI/CD 作业运行所需的敏感信息。密钥可以是访问令牌、数据库凭据、私钥或类似内容。与 CI/CD 变量（默认情况下作业始终可用）不同，作业必须显式请求密钥。

极狐GitLab Secrets Manager [消耗极狐GitLab Credits](secrets_manager_billing.md)。

在公开测试版期间，请在 [反馈议题 598100](https://gitlab.com/gitlab-org/gitlab/-/work_items/598100) 中分享您的反馈。

<a id="enable-gitlab-secrets-manager"></a>

## 启用极狐GitLab Secrets Manager

当为顶级群组启用 Secrets Manager 时，该群组中的所有子群组和项目也可使用它。

在极狐GitLab 私有化部署上，管理员必须首先为实例 [安装并启用极狐GitLab Secrets Manager](../../../administration/secrets_manager/_index.md)。安装并启用 Secrets Manager 后，您可以为实例上的特定群组和项目启用它。

<a id="for-gitlabcom"></a>

### 对于 JihuLab.com

{{< details >}}

Status: 限量提供

{{< /details >}}

- 您可以开始 30 天试用，使用临时评估 Credits 体验极狐GitLab Secrets Manager。试用期结束后，极狐GitLab Secrets Manager 将开始消耗极狐GitLab Credits。为避免服务中断，请在试用期结束前购买月度承诺 Credits 池或启用按需计费。有关更多信息，请参阅 [极狐GitLab Secrets Manager 使用量和计费](secrets_manager_billing.md)。
- 如果您在 2026 年 8 月 21 日之前选择加入测试版，您的环境将有一个宽限期，可持续访问至 2026 年 9 月 21 日。宽限期结束后，极狐GitLab 将禁用访问权限。要继续访问，请在宽限期结束前开始试用。

先决条件：

- 您必须对顶级群组具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 在左侧边栏中，选择 **安全** > **Secrets Manager**。
1. 选择 **开始 30 天试用**。

<a id="for-gitlab-self-managed"></a>

### 对于极狐GitLab 私有化部署

{{< details >}}

- Status: 测试版

{{< /details >}}

> [!note]
> 极狐GitLab Secrets Manager 在公开测试版期间免费。极狐GitLab 会在正式发布前通知您，以便您有时间开始试用或选择为极狐GitLab Credits 启用按需计费。

<a id="for-a-project"></a>

#### 对于项目

先决条件：

- 您必须对项目具有所有者角色。

要为项目启用或禁用极狐GitLab Secrets Manager：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **可见性、项目功能、权限**。
1. 打开 **Secrets manager** 开关，并等待密钥管理器完成预配。

   > [!warning]
   > 如果您之后为项目禁用 Secrets Manager，项目的所有密钥将被永久删除。
   > 这些密钥无法恢复。

为项目定义的密钥只能由同一项目的流水线访问。

<a id="for-a-group"></a>

#### 对于群组

先决条件：

- 您必须对群组具有所有者角色。

要为群组启用或禁用极狐GitLab Secrets Manager：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **权限和群组功能**。
1. 打开 **Secrets manager** 开关，并等待密钥管理器完成预配。

   > [!warning]
   > 如果您之后为群组禁用 Secrets Manager，群组的所有密钥将被永久删除。
   > 这些密钥无法恢复。

为群组定义的密钥只能由该群组直属项目或其子群组层级中项目的流水线访问。

<a id="define-a-secret"></a>

## 定义密钥

您可以向密钥管理器添加密钥，以便将其用于安全的 CI/CD 流水线和工作流。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **安全** > **Secrets manager**。
1. 选择 **添加密钥** 并填写详细信息：
   - **名称**：在项目中必须唯一。
   - **值**：必须为 10 KB（10,000 字节）或更小。
   - **描述**：最多 200 个字符。
   - **环境**：可以是：
     - **全部（默认）** (`*`)
     - 特定的[环境](../../environments/_index.md#types-of-environments)。
     - [通配符环境](../../environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。
   - **分支**：此选项仅存在于项目设置中。可以是：
     - 特定分支。
     - 通配符分支（必须包含 `*` 字符）。
   - **受保护**：此选项仅存在于群组设置中。可选。仅将密钥导出到在受保护分支上运行的流水线。
   - **轮换提醒**：可选。在设定的天数后发送电子邮件提醒以轮换密钥。
     最少 7 天。

创建密钥后，您可以在流水线配置或作业脚本中使用它。

> [!warning]
> 密钥的值可供为创建或更新密钥时定义的特定环境或分支运行的所有 CI/CD 流水线作业访问。请确保只有有权访问这些密钥值的用户才能为指定环境或分支运行作业。

<a id="use-secrets-in-job-scripts"></a>

## 在作业脚本中使用密钥

默认情况下，与[文件类型 CI/CD 变量](../../variables/_index.md#use-file-type-cicd-variables)类似，密钥在作业中作为带有相关环境变量的文件提供：

- 密钥的键是环境变量名称。
- 密钥的值保存到临时文件中。与掩码 CI/CD 变量不同，密钥可以包含空格和换行符。
- 临时文件的路径是环境变量的值。

在作业脚本中，使用接受文件作为输入的命令来使用密钥，或者可选地直接[将密钥用作环境变量](#use-a-secret-as-an-environment-variable-with-file-false)。

如果作业输出了密钥的值，极狐GitLab 会在作业日志中将该值替换为 `[MASKED]`。

<a id="for-project-secrets"></a>

### 对于项目密钥

先决条件：

- 极狐GitLab Runner 19.0 或更高版本。

要访问项目中 Secrets Manager 存储的密钥，请使用 [`secrets`](../../yaml/_index.md#secrets) 和 `gitlab_secrets_manager` 关键字。

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

### 对于群组密钥

先决条件：

- 极狐GitLab Runner 19.0 或更高版本。

要访问群组中 Secrets Manager 存储的密钥：

- 使用 [`secrets`](../../yaml/_index.md#secrets) 和 `gitlab_secrets_manager` 关键字。
- 使用 `source` 字段并带有 `group/` 前缀，后跟 `<full-path-to-group>`，将群组指定为密钥管理器源。

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

要将密钥用作环境变量而不将其存储在文件中，请为密钥设置 `file: false`。例如：

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

在此示例中，密钥作为 `DEPLOY_SECRET` 变量提供给作业，您可以像使用任何其他环境变量一样使用它。

<a id="manage-secrets-permissions"></a>

## 管理密钥权限

<a id="for-a-project-1"></a>

### 对于项目

先决条件：

- 您必须对项目具有所有者角色才能管理密钥权限。
- 对项目具有维护者角色的用户可以查看已定义的权限。
- 必须为项目启用 Secrets Manager。

要更新项目的密钥权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **Secrets manager** 下的 **Secrets manager 用户权限** 部分，您可以管理用户权限：
   - 选择 **添加** 为特定用户、群组或角色添加权限规则。
   - 您可以设置权限范围以读取、写入（创建和更新）和删除密钥。

<a id="for-a-group-1"></a>

### 对于群组

先决条件：

- 您必须对群组具有所有者角色才能管理密钥权限。
  只有对群组具有所有者角色的用户才能查看已定义的权限。
- 必须为群组启用 Secrets Manager。

要更新群组的密钥权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **权限和群组功能**。
1. 在 **Secrets manager** 下的 **Secrets manager 用户权限** 部分，您可以管理用户权限：
   - 选择 **添加** 为特定用户、群组或角色添加权限规则。
   - 您可以设置权限范围以读取、写入（创建和更新）和删除密钥。

对群组具有所有者角色的用户始终拥有在 Secrets Manager 中执行所有操作的权限。

<a id="deletion-of-a-project-or-group"></a>

## 删除项目或群组

当您[删除项目](../../../user/project/working_with_projects.md#delete-a-project)或[删除群组](../../../user/group/_index.md#schedule-a-group-for-deletion)，且其中存有密钥时：

- 项目或群组的密钥管理器将被禁用并从密钥存储引擎中移除。
- 所有密钥将被永久删除。

<a id="transfer-of-a-project-or-group"></a>

## 转移项目或群组

当您[转移项目](../../../user/project/working_with_projects.md#transfer-a-project)或[转移群组](../../../user/group/manage.md#transfer-a-group)，且其中存有密钥时：

- 为项目或群组定义的密钥不会转移到其新命名空间中的项目或群组。
- 项目或群组的密钥管理器将被禁用并从密钥存储引擎中移除。
- 所有密钥将被永久删除。

<a id="secret-rotation-notifications"></a>

## 密钥轮换通知

对项目具有所有者角色的用户会在密钥配置中指定的日期收到轮换密钥的电子邮件通知。

<a id="access-secrets-from-non-cicd-workloads"></a>

## 从非 CI/CD 工作负载访问密钥

不作为极狐GitLab CI/CD 作业运行的工作负载可以通过 Secrets Manager API 读取密钥。有关更多信息，请参阅[从非 CI/CD 工作负载访问密钥](non_cicd_access.md)。

<a id="troubleshooting"></a>

## 故障排查

<a id="error-reading-from-vault-api-error-status-code-403"></a>

### 错误：`reading from Vault: api error: status code 403`

当 CI/CD 流水线作业尝试获取密钥时，可能会返回此错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: getting secret: get secret data: reading from Vault: api error: status code 403: 1 error occurred: * permission denied
```

当作业尝试获取不存在或已删除的密钥时，会发生此错误。

<a id="error-inline-auth-jwt-is-required"></a>

### 错误：`inline auth JWT is required`

当 CI/CD 流水线作业尝试获取密钥时，可能会返回此错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: creating vault client: configuring inline auth: inline auth JWT is required
```

当预期密钥所属的项目或群组的密钥管理器实例尚未完成预配时，会发生此错误。由于尚不存在密钥管理器角色，Runner 无法配置身份验证。

要解决此错误，请为您的项目或群组启用 Secrets Manager。

等待预配完成并创建密钥，然后重新运行流水线。

<a id="error-namespace-does-not-have-access-to-gitlab-secrets-manager"></a>

### 错误：`namespace does not have access to GitLab Secrets Manager`

当顶级群组无权访问极狐GitLab Secrets Manager 时，请求极狐GitLab Secrets Manager 密钥的作业会在 Runner 获取它们之前失败并显示此错误。可能的原因：

- 试用已过期。
- 群组没有可用的极狐GitLab Credits。
- 按需计费已关闭。
- 订阅宽限期已过期。
- 公开测试版已结束，命名空间未选择加入。

要恢复访问权限，请为顶级群组开始试用或购买极狐GitLab Secrets Manager。或者，确保顶级群组有可用的极狐GitLab Credits 并已启用按需计费。
