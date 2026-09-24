---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署密钥
description: 公共 SSH 密钥、仓库访问、机器人用户以及只读访问。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用部署密钥访问托管在 极狐GitLab 中的仓库。在大多数情况下，您可以使用部署密钥
从外部主机（例如构建服务器或持续集成 (CI) 服务器）访问仓库。

根据您的需求，您可能希望改用[部署令牌](../deploy_tokens/_index.md)来访问仓库。

| 属性                  |  部署密钥 | 部署令牌 |
|----------------------|-------------|--------------|
| 共享                  | 可在多个项目之间共享，即使是不同群组中的项目。 | 归属于一个项目或群组。 |
| 来源                  | 在外部主机上生成的公共 SSH 密钥。 | 在您的 极狐GitLab 实例上生成，仅在创建时提供给用户。 |
| 可访问的资源          | 通过 SSH 访问 Git 仓库 | 通过 HTTP 访问 Git 仓库、软件包仓库和容器镜像仓库。 |

如果启用了[外部授权](../../../administration/settings/external_authorization.md)，则部署密钥不能用于 Git 操作。

## 范围

<a id="scope"></a>

部署密钥在创建时具有已定义的范围：

- **项目部署密钥**：访问权限仅限于所选项目。
- **公共部署密钥**：可以授予对 极狐GitLab 实例中任何项目的访问权限。每个项目的访问权限必须由至少具有维护者角色的用户[授予](#grant-project-access-to-a-public-deploy-key)。

创建部署密钥后无法更改其范围。

## 权限

<a id="permissions"></a>

部署密钥在创建时会获得一个权限级别：

- **只读**：只读部署密钥只能从仓库读取。
- **读写**：读写部署密钥可以从仓库读取和写入。

创建部署密钥后，您可以更改其权限级别。更改项目部署密钥的权限仅适用于当前项目。

如果使用部署密钥的推送操作触发了其他进程，则密钥的创建者必须获得授权。例如：

- 当使用部署密钥将提交推送到[受保护的分支](../repository/branches/protected.md)时，部署密钥的创建者必须具有对该分支的访问权限。
- 当使用部署密钥推送触发 CI/CD 流水线的提交时，部署密钥的创建者必须有权访问 CI/CD 资源，包括受保护的环境和密钥变量。

### 安全影响

<a id="security-implications"></a>

部署密钥旨在促进非人工与 极狐GitLab 的交互。例如，您可以使用部署密钥为在您组织的服务器上自动运行的脚本授予权限。

您应该使用[服务账号](../../profile/service_accounts.md)，并使用该服务账号创建部署密钥。
如果您使用其他用户账户创建部署密钥，则该用户将被授予特权，这些特权将持续到部署密钥被撤销为止。

此外：

- 如果部署密钥的所有者被阻止，则部署密钥会被[拒绝](#deploy-key-is-rejected)。它不能用于任何仓库操作，包括拉取和推送。
- 当部署密钥所有者从群组或项目中移除时，部署密钥不会被拒绝。部署密钥将继续提供访问权限，直到被撤销。
- 当在受保护分支规则中指定了部署密钥时，部署密钥的创建者：
  - 获得对受保护分支以及部署密钥本身的访问权限。
  - 如果部署密钥具有读写权限，则可以推送到受保护分支。即使该分支被保护以防止所有用户更改，也是如此。

与所有敏感信息一样，您应确保只有需要访问密钥的人才能读取它。
对于人工交互，请使用与用户关联的凭据，例如个人访问令牌。

为了帮助检测潜在的密钥泄漏，您可以使用[审计事件](../../compliance/audit_event_schema.md#example-audit-event-payloads-for-git-over-ssh-events-with-deploy-key)功能。

## 查看部署密钥

<a id="view-deploy-keys"></a>

要查看项目可用的部署密钥：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署密钥**。

可用的部署密钥列表如下：

- **已启用的部署密钥**：具有项目访问权限的部署密钥。
- **私有可访问的部署密钥**：不具有项目访问权限的项目部署密钥。
- **公共可访问的部署密钥**：不具有项目访问权限的公共部署密钥。

[极狐GitLab CLI](../../../editor_extensions/gitlab_cli/_index.md) 提供了 `glab deploy-key list` 命令。

## 创建项目部署密钥

<a id="create-a-project-deploy-key"></a>

先决条件：

- 您必须具有项目的维护者或所有者角色。
- [生成 SSH 密钥对](../../ssh.md#generate-an-ssh-key-pair)。将私有 SSH 密钥放在需要访问仓库的主机上。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署密钥**。
1. 选择 **添加新密钥**。
1. 填写字段。
1. 可选。要授予 `读写` 权限，请选中 **授予此密钥写入权限** 复选框。
1. 可选。更新 **到期日期**。

项目部署密钥在创建时即被启用。您只能修改项目部署密钥的名称和权限。如果该部署密钥在多个项目中启用，则无法修改部署密钥名称。

[极狐GitLab CLI](../../../editor_extensions/gitlab_cli/_index.md) 提供了 `glab deploy-key add` 命令。

## 创建公共部署密钥

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须具有实例的管理员访问权限。
- 您必须[生成 SSH 密钥对](../../ssh.md#generate-an-ssh-key-pair)。
- 您必须将私有 SSH 密钥放在需要访问仓库的主机上。

要创建公共部署密钥：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **部署密钥**。
1. 选择 **新部署密钥**。
1. 填写字段。
   - 对 **名称** 使用有意义的描述。例如，包含使用该公共部署密钥的外部主机或应用程序的名称。

您只能修改公共部署密钥的名称。

## 授予项目对公共部署密钥的访问权限

<a id="grant-project-access-to-a-public-deploy-key"></a>

先决条件：

- 您必须具有项目的维护者或所有者角色。

要授予公共部署密钥对项目的访问权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署密钥**。
1. 选择 **公共可访问的部署密钥**。
1. 在密钥所在行，选择 **启用**。
1. 要授予公共部署密钥读写权限：
   1. 在密钥所在行，选择 **编辑**（{{< icon name="pencil" >}}）。
   1. 选中 **授予此密钥写入权限** 复选框。

### 编辑部署密钥的项目访问权限

<a id="edit-project-access-permissions-of-a-deploy-key"></a>

先决条件：

- 您必须具有项目的维护者或所有者角色。

要编辑部署密钥的项目访问权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署密钥**。
1. 在密钥所在行，选择 **编辑**（{{< icon name="pencil" >}}）。
1. 选中或清除 **授予此密钥写入权限** 复选框。

## 撤销部署密钥的项目访问权限

<a id="revoke-project-access-of-a-deploy-key"></a>

要撤销部署密钥对项目的访问权限，您可以禁用它。任何依赖部署密钥的服务在密钥被禁用时将停止工作。

先决条件：

- 您必须具有项目的维护者或所有者角色。

要禁用部署密钥：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署密钥**。
1. 选择 **禁用**（{{< icon name="cancel" >}}）。

部署密钥被禁用后的情况取决于以下内容：

- 如果密钥是公共可访问的，它将被从项目中移除，但在 **公共可访问的部署密钥** 选项卡中仍然可用。
- 如果密钥是私有可访问的且仅由此项目使用，则将被删除。
- 如果密钥是私有可访问的且还被其他项目使用，它将被从项目中移除，但在 **私有可访问的部署密钥** 选项卡中仍然可用。



## 故障排查

<a id="troubleshooting"></a>

### 部署密钥被拒绝

<a id="deploy-key-is-rejected"></a>

以下情况下部署密钥会被拒绝：

- 密钥所有者被阻止。
- 密钥已过期。

当部署密钥被拒绝时，它不能用于任何仓库操作，包括拉取和推送。

要解决此问题：

- 如果密钥所有者被阻止，请解除对该用户的阻止，或者[更改密钥所有者](#set-the-owner-of-a-deploy-key)为一个活跃用户。
- 如果密钥已过期，请创建一个新的部署密钥。

### 部署密钥无法推送到受保护的分支

<a id="deploy-key-cannot-push-to-a-protected-branch"></a>

在以下几种情况下，部署密钥无法推送到[受保护的分支](../repository/branches/protected.md)：

- 与部署密钥关联的所有者不具有该项目受保护分支的[成员资格](../members/_index.md)。
- 与部署密钥关联的所有者的[项目成员权限](../../permissions.md#project-permissions)低于查看项目代码所需的权限。
- 部署密钥不具有[项目的读写权限](#edit-project-access-permissions-of-a-deploy-key)。
- 部署密钥已被[撤销](#revoke-project-access-of-a-deploy-key)。
- 在受保护分支的[**允许推送和合并**部分](../repository/branches/protected.md#protect-a-branch)中选择了 **没有人**。

出现此问题是因为所有部署密钥都与一个账户关联。由于账户的权限可能会改变，这可能导致之前正常工作的部署密钥突然无法推送到受保护的分支。

要解决此问题，您可以使用部署密钥 API 为项目服务账号用户创建部署密钥，而不是为您自己的用户创建：

1. [创建一个服务账号用户](../../../api/service_accounts.md#create-a-group-service-account)。
1. [为该服务账号用户创建个人访问令牌](../../../api/service_accounts.md#create-a-personal-access-token-for-a-group-service-account)。此令牌必须至少具有 `api` 作用域。
1. [将服务账号用户邀请到项目中](../../profile/service_accounts.md#add-a-service-account-to-a-group-or-project)。
1. 使用部署密钥 API [为服务账号用户创建部署密钥](../../../api/deploy_keys.md#add-deploy-key)：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <service_account_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"title": "我的部署密钥", "key": "ssh-rsa AAAA...", "can_push": "true"}' \
     --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/"
   ```

#### 识别与非成员和被阻止用户关联的部署密钥

<a id="identify-deploy-keys-associated-with-non-member-and-blocked-users"></a>

如果您需要查找属于非成员或被阻止用户的密钥，可以使用[Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session)通过类似以下脚本来识别不可用的部署密钥：

```ruby
DeployKeysProject.with_write_access.find_each do |deploy_key_mapping|
  project = deploy_key_mapping.project
  deploy_key = deploy_key_mapping.deploy_key
  user = deploy_key.user

  access_checker = Gitlab::DeployKeyAccess.new(deploy_key, container: project)

  # can_push_for_ref? 测试部署密钥是否可以推送到默认分支，这很可能是受保护的
  can_push = access_checker.can_do_action?(:push_code)
  can_push_to_default = access_checker.can_push_for_ref?(project.repository.root_ref)

  next if access_checker.allowed? && can_push && can_push_to_default

  if user.nil? || user.ghost?
    username = '无'
    state = '-'
  else
    username = user.username
    user_state = user.state
  end

  puts "部署密钥: #{deploy_key.id}, 项目: #{project.full_path}, 可以推送?: " + (can_push ? '是' : '否') +
       ", 可以推送到默认分支 #{project.repository.root_ref}?: " + (can_push_to_default ? '是' : '否') +
       ", 用户: #{username}, 用户状态: #{user_state}"
end
```

#### 设置部署密钥的所有者

<a id="set-the-owner-of-a-deploy-key"></a>

部署密钥属于特定用户，当该用户被阻止时会被拒绝。
要在所有者被阻止时保持部署密钥正常工作，请将其所有者更改为一个活跃用户。

如果您拥有部署密钥的指纹，可以使用以下命令更改与部署密钥关联的用户：

```shell
k = Key.find_by(fingerprint: '5e:51:92:11:27:90:01:b5:83:c3:87:e3:38:82:47:2e')
k.user_id = User.find_by(username: '活跃用户').id
k.save()
```

