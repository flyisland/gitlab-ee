---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署密钥
description: 公共 SSH 密钥、代码仓库访问权限、机器人用户和只读访问权限。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用部署密钥访问托管在极狐GitLab 中的代码仓库。大多数情况下，您使用部署密钥从外部主机（例如构建服务器或持续集成（CI）服务器）访问代码仓库。

根据您的需求，您也可以改用[部署令牌](../deploy_tokens/_index.md)来访问代码仓库。

| 属性        |  部署密钥 | 部署令牌 |
|------------------|-------------|--------------|
| 共享          | 可在多个项目之间共享，即使这些项目位于不同的群组中。 | 属于某个项目或群组。 |
| 来源           | 在外部主机上生成的公共 SSH 密钥。 | 在您的极狐GitLab 实例上生成，仅在创建时提供给用户。 |
| 可访问的资源  | 通过 SSH 访问 Git 代码仓库 | 通过 HTTP 访问 Git 代码仓库、软件包仓库和容器镜像仓库。 |

如果启用了[外部授权](../../../administration/settings/external_authorization.md)，则部署密钥不能用于 Git 操作。

<a id="scope"></a>

## 范围

部署密钥在创建时会定义范围：

- **项目部署密钥**：访问权限仅限于所选项目。
- **公共部署密钥**：可授予对极狐GitLab 实例中任意项目的访问权限。对每个项目的访问权限必须由至少具有
  维护者角色的用户[授予](#grant-project-access-to-a-public-deploy-key)。

创建部署密钥后，您无法更改其范围。

<a id="permissions"></a>

## 权限

部署密钥在创建时会被赋予一个权限级别：

- **只读**：只读部署密钥只能从代码仓库读取。
- **读写**：读写部署密钥可以从代码仓库读取，也可以向代码仓库写入。

创建部署密钥后，您可以更改其权限级别。更改项目部署密钥的权限仅对当前项目生效。

如果使用部署密钥的推送触发了其他流程，则密钥的创建者必须获得授权。例如：

- 当使用部署密钥将提交推送到[受保护分支](../repository/branches/protected.md)时，
  部署密钥的创建者必须具有该分支的访问权限。
- 当使用部署密钥推送提交并触发 CI/CD 流水线时，部署密钥的创建者
  必须具有 CI/CD 资源的访问权限，包括受保护环境和密钥
  变量。

<a id="security-implications"></a>

### 安全影响

部署密钥旨在促进与极狐GitLab 的非人工交互。例如，您可以使用部署密钥为在您组织的服务器上自动运行的脚本授予权限。

您应使用[服务账号](../../profile/service_accounts.md)，并使用该服务账号创建部署密钥。如果您使用其他用户账号创建部署密钥，该用户会被授予特权，这些特权会一直保留，直到部署密钥被撤销。

此外：

- 如果部署密钥所有者被阻止，该部署密钥会被
  [拒绝](#deploy-key-is-rejected)。它不能用于任何代码仓库操作，
  包括拉取和推送。
- 当部署密钥所有者从群组或项目中移除时，部署密钥不会被拒绝。
  该部署密钥会继续提供访问权限，直到被撤销。
- 当在受保护分支规则中指定了部署密钥时，部署密钥的创建者：
  - 会获得对受保护分支以及部署密钥本身的访问权限。
  - 如果部署密钥具有读写权限，则可以推送到受保护分支。
    即使该分支被保护为禁止所有用户更改，也是如此。

与所有敏感信息一样，您应确保只有需要访问该密钥的人才能读取它。对于人工交互，请使用与用户绑定的凭证，例如个人访问令牌。

为帮助检测潜在的密钥泄露，您可以使用[审计事件](../../compliance/audit_event_schema.md#example-audit-event-payloads-for-git-over-ssh-events-with-deploy-key)功能。

<a id="view-deploy-keys"></a>

## 查看部署密钥

要查看项目可用的部署密钥：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署密钥**。

系统会列出可用的部署密钥：

- **已启用的部署密钥**：有权访问该项目的部署密钥。
- **私有可访问的部署密钥**：无权访问该项目的项目部署密钥。
- **公共可访问的部署密钥**：无权访问该项目的公共部署密钥。

[GitLab CLI](../../../editor_extensions/gitlab_cli/_index.md) 提供了 `glab deploy-key list` 命令。

<a id="create-a-project-deploy-key"></a>

## 创建项目部署密钥

先决条件：

- 您必须具有该项目的维护者或所有者角色。
- [生成 SSH 密钥对](../../ssh.md#generate-an-ssh-key-pair)。将私有 SSH
  密钥放在需要访问该代码仓库的主机上。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署密钥**。
1. 选择**添加新密钥**。
1. 填写各字段。
1. 可选。要授予 `read-write` 权限，请选中**授予此密钥写入权限**
   复选框。
1. 可选。更新**过期日期**。

项目部署密钥在创建时即启用。您只能修改项目部署密钥的名称和权限。如果该部署密钥在多个项目中启用，则无法修改该部署密钥名称。

[GitLab CLI](../../../editor_extensions/gitlab_cli/_index.md) 提供了 `glab deploy-key add` 命令。

<a id="create-a-public-deploy-key"></a>

## 创建公共部署密钥

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须具有该实例的管理员访问权限。
- 您必须[生成 SSH 密钥对](../../ssh.md#generate-an-ssh-key-pair)。
- 您必须将私有 SSH 密钥放在需要访问该代码仓库的主机上。

要创建公共部署密钥：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**部署密钥**。
1. 选择**新建部署密钥**。
1. 填写各字段。
   - 为**名称**使用有意义的描述。例如，包含使用该公共部署密钥的外部主机
     或应用程序的名称。

您只能修改公共部署密钥的名称。

<a id="grant-project-access-to-a-public-deploy-key"></a>

## 授予公共部署密钥项目访问权限

先决条件：

- 您必须具有该项目的维护者或所有者角色。

要授予公共部署密钥对项目的访问权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署密钥**。
1. 选择**公共可访问的部署密钥**。
1. 在该密钥所在行中，选择**启用**。
1. 要授予该公共部署密钥读写权限：
   1. 在该密钥所在行中，选择**编辑**（{{< icon name="pencil" >}}）。
   1. 选中**授予此密钥写入权限**复选框。

<a id="edit-project-access-permissions-of-a-deploy-key"></a>

### 编辑部署密钥的项目访问权限

先决条件：

- 您必须具有该项目的维护者或所有者角色。

要编辑部署密钥的项目访问权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署密钥**。
1. 在该密钥所在行中，选择**编辑**（{{< icon name="pencil" >}}）。
1. 选中或清除**授予此密钥写入权限**复选框。

<a id="revoke-project-access-of-a-deploy-key"></a>

## 撤销部署密钥的项目访问权限

要撤销部署密钥对项目的访问权限，您可以将其禁用。任何依赖部署密钥的服务都会在密钥被禁用时停止工作。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

要禁用部署密钥：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**部署密钥**。
1. 选择**禁用**（{{< icon name="cancel" >}}）。

部署密钥被禁用时会发生什么取决于以下情况：

- 如果该密钥是公共可访问的，它会从项目中移除，但仍可在
  **公共可访问的部署密钥**标签页中找到。
- 如果该密钥是私有可访问的，且仅由该项目使用，则它会被删除。
- 如果该密钥是私有可访问的，且也被其他项目使用，则它会从
  该项目中移除，但仍可在**私有可访问的部署密钥**标签页中找到。

<a id="troubleshooting"></a>

## 故障排除

<a id="deploy-key-is-rejected"></a>

### 部署密钥被拒绝

部署密钥会在以下情况下被拒绝：

- 密钥所有者被阻止。
- 密钥已过期。

当部署密钥被拒绝时，它不能用于任何代码仓库操作，包括拉取和推送。

要解决此问题：

- 如果密钥所有者被阻止，请解除对该用户的阻止，或[更改密钥所有者](#set-the-owner-of-a-deploy-key)为活跃用户。
- 如果密钥已过期，请创建新的部署密钥。

<a id="deploy-key-cannot-push-to-a-protected-branch"></a>

### 部署密钥无法推送到受保护分支

在以下几种情况下，部署密钥无法推送到[受保护分支](../repository/branches/protected.md)。

- 与部署密钥关联的所有者不具有受保护分支所属项目的[成员资格](../members/_index.md)。
- 与部署密钥关联的所有者具有的[项目成员权限](../../permissions.md#project-permissions)低于**查看项目代码**所需的权限。
- 该部署密钥不具有[项目的读写权限](#edit-project-access-permissions-of-a-deploy-key)。
- 该部署密钥已被[撤销](#revoke-project-access-of-a-deploy-key)。
- 在受保护分支的[**允许推送和合并**部分](../repository/branches/protected.md#protect-a-branch)中，**未选择任何人**。

出现此问题是因为所有部署密钥都与某个账号关联。由于账号的权限可能会发生变化，这可能导致原本正常工作的部署密钥突然无法推送到受保护分支。

要解决此问题，您可以使用部署密钥 API 为项目服务账号用户创建部署密钥，而不是为您自己的用户创建：

1. [创建服务账号用户](../../../api/service_accounts.md#create-a-group-service-account)。
1. 为该服务账号用户[创建个人访问令牌](../../../api/service_accounts.md#create-a-personal-access-token-for-a-group-service-account)。该令牌必须至少具有 `api` 范围。
1. [邀请该服务账号用户加入项目](../../profile/service_accounts.md#add-a-service-account-to-a-group-or-project)。
1. 使用部署密钥 API [为该服务账号用户创建部署密钥](../../../api/deploy_keys.md#add-deploy-key)：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <service_account_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"title": "My deploy key", "key": "ssh-rsa AAAA...", "can_push": "true"}' \
     --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/"
   ```

<a id="identify-deploy-keys-associated-with-non-member-and-blocked-users"></a>

#### 识别与非成员和被阻止用户关联的部署密钥

如果您需要查找属于非成员或被阻止用户的密钥，可以使用 [Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session)，通过类似以下脚本识别不可用的部署密钥：

```ruby
DeployKeysProject.with_write_access.find_each do |deploy_key_mapping|
  project = deploy_key_mapping.project
  deploy_key = deploy_key_mapping.deploy_key
  user = deploy_key.user

  access_checker = Gitlab::DeployKeyAccess.new(deploy_key, container: project)

  # can_push_for_ref? tests if deploy_key can push to default branch, which is likely to be protected
  can_push = access_checker.can_do_action?(:push_code)
  can_push_to_default = access_checker.can_push_for_ref?(project.repository.root_ref)

  next if access_checker.allowed? && can_push && can_push_to_default

  if user.nil? || user.ghost?
    username = 'none'
    state = '-'
  else
    username = user.username
    user_state = user.state
  end

  puts "Deploy key: #{deploy_key.id}, Project: #{project.full_path}, Can push?: " + (can_push ? 'YES' : 'NO') +
       ", Can push to default branch #{project.repository.root_ref}?: " + (can_push_to_default ? 'YES' : 'NO') +
       ", User: #{username}, User state: #{user_state}"
end
```

<a id="set-the-owner-of-a-deploy-key"></a>

#### 设置部署密钥的所有者

部署密钥属于特定用户，并在该用户被阻止时被拒绝。要在所有者被阻止时保持部署密钥正常工作，请将其所有者更改为活跃用户。

如果您有该部署密钥的指纹，可以使用以下命令更改与部署密钥关联的用户：

```shell
k = Key.find_by(fingerprint: '5e:51:92:11:27:90:01:b5:83:c3:87:e3:38:82:47:2e')
k.user_id = User.find_by(username: 'anactiveuser').id
k.save()
```
