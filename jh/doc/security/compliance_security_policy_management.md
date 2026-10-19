---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to apply security policies and compliance frameworks across multiple groups and projects from a single, centralized location.
title: 实例级合规与安全策略管理
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.2 中引入，带有功能标志 `security_policies_csp`。默认禁用。
- 在极狐GitLab 18.3 中默认启用。
- 在极狐GitLab 18.5 中 GA。功能标志 `security_policies_csp` 已移除。

{{< /history >}}

为了从单个集中位置跨多个群组和项目应用安全策略和合规框架，实例管理员可以指定一个合规与安全策略（CSP）群组。这使实例管理员能够：

- 创建和配置自动应用于整个实例的安全策略。
- 创建集中式合规框架，使其可供其他顶级群组使用。
- 限定策略范围，以应用于合规框架、群组、项目或整个实例。
- 查看全面的策略覆盖范围，了解哪些策略处于活动状态以及它们在何处活动。
- 保持集中控制，同时允许团队创建自己的额外策略和框架。

## 先决条件

- 极狐GitLab 18.2 或更高版本。
- 您必须是实例管理员。
- 您必须有一个现有的顶级群组作为合规与安全策略群组。
- 要使用 REST API（可选），您必须拥有具有管理员访问权限的令牌。

<a id="set-up-instance-wide-compliance-and-security-policy-management"></a>

## 设置实例级合规与安全策略管理

要设置实例级合规与安全策略管理，您需要指定一个合规与安全策略群组，然后在该群组中创建策略和合规框架。

<a id="designate-a-compliance-and-security-policy-group"></a>

### 指定合规与安全策略群组

您可以使用极狐GitLab UI 或 REST API 指定合规与安全策略群组。

<a id="using-the-gitlab-ui"></a>

#### 使用极狐GitLab UI

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **安全与合规**。
1. 在 **指定 CSP 群组** 部分，从下拉列表中选择一个现有的顶级群组。
1. 选择 **保存更改**。

<a id="using-the-rest-api"></a>

#### 使用 REST API

您还可以通过 REST API 以编程方式指定合规与安全策略群组。该 API 对于自动化或管理多个实例非常有用。

要设置合规与安全策略群组：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"csp_namespace_id": 123456}' \
  --url "https://gitlab.example.com/api/v4/admin/security/policy_settings"
```

要清除合规与安全策略群组：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"csp_namespace_id": null}' \
  --url "https://gitlab.example.com/api/v4/admin/security/policy_settings"
```

要获取当前的合规与安全策略设置：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/security/policy_settings"
```

更多信息，请参阅 [策略设置 API 文档](../api/compliance_policy_settings.md)。

所选群组将成为您的合规与安全策略群组，作为管理整个实例的安全策略和合规框架的中央位置。

<a id="security-policy-management-in-the-compliance-and-security-policy-group"></a>

### 合规与安全策略群组中的安全策略管理

有关安全策略，请参阅 [合规与安全策略群组](../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md) 文档。

<a id="centralized-compliance-framework-management"></a>

### 集中式合规框架管理

指定合规与安全策略群组后，您可以创建合规框架，这些框架会自动提供给实例中的所有顶级群组。这为整个组织提供了一致的合规方法。

在合规与安全策略群组中创建的合规框架：

- 对实例中的其他顶级群组可见且可用。
- 可由群组所有者应用于项目。
- 对于合规与安全策略群组之外的用户是只读的。
- 可与安全策略集成，以增强合规执行。

有关创建和管理集中式合规框架的详细说明，请参阅 [集中式合规框架](../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)。

<a id="user-workflows"></a>

## 用户工作流

<a id="instance-administrators"></a>

### 实例管理员

实例管理员可以：

1. 从现有顶级群组中 **指定合规与安全策略群组**
1. 在指定群组中 **创建安全策略**
1. 在指定群组中 **创建合规框架**
1. **配置策略范围** 以确定策略的应用位置
1. **将策略范围限定到合规框架** 以对具有特定框架的项目执行策略
1. **查看策略覆盖范围** 以了解哪些策略在群组和项目中处于活动状态
1. 根据需要 **编辑和管理** 集中式策略和框架

<a id="group-administrators-and-owners"></a>

### 群组管理员和所有者

群组管理员和所有者可以：

- 在 **安全** > **策略** 中查看所有适用的策略，包括本地定义的和集中管理的策略。
- 查看集中式合规框架并将其应用于其群组中的项目。
- 除了集中管理的策略和框架外，还可以为特定群组或项目创建策略和框架。
- 通过清晰的指示器了解策略来源，显示策略是来自您的团队还是中央管理。

> [!note]
> **策略** 页面仅显示来自合规与安全策略群组的、当前应用于您群组的策略。

<a id="project-administrators-and-owners"></a>

### 项目管理员和所有者

项目管理员和所有者可以：

- 在 **安全** > **策略** 中查看所有适用的策略，包括本地定义的和集中管理的策略。
- 查看哪些合规框架应用于他们的项目，包括集中式框架。
- 除了集中管理的策略外，还可以创建项目特定的策略。
- 通过清晰的指示器了解策略来源，显示策略是来自您的项目、群组还是中央管理。

> [!note]
> **策略** 页面仅显示来自合规与安全策略的、当前应用于您群组的策略。

<a id="developers"></a>

### 开发者

开发者可以：

- 在 **安全** > **策略** 中查看适用于您工作的所有安全策略。
- 查看哪些合规框架应用于他们工作的项目。
- 通过清晰可见的集中强制策略了解安全与合规要求。

<a id="automate-your-migration-from-security-policy-projects"></a>

## 自动化从安全策略项目迁移

如果您已经使用安全策略项目在多个群组中执行策略，则可以将其中一个链接的群组指定为您的合规与安全策略群组。但是，您应该从所有不是合规与安全策略群组的群组中取消链接安全策略项目。否则，相同的策略会在这些群组中执行两次。一次来自链接的安全策略群组，另一次来自合规与安全策略群组。

要自动化将群组迁移到合规与安全策略群组的过程，您可以使用以下 `csp_designation.rb` 脚本。

该脚本将所有链接到合规与安全策略群组的策略项目的群组 ID 保存在指定的备份文件中。如有必要，这允许您恢复之前的状态，包括指向安全策略项目的链接。

先决条件：

- 您必须有一个安全策略项目链接到您要指定为合规与安全策略群组的群组。

要使用该脚本：

1. 从以下部分复制整个 `csp_designation.rb` 脚本。
1. 在终端窗口中，连接到您的实例。
1. 创建一个名为 `csp_designation.rb` 的新文件，并将脚本粘贴到该新文件中。
1. 运行以下命令以指定合规与安全策略群组，更改：
   - 将 `<group_id>` 更改为您要设置为合规与安全策略群组的群组的极狐GitLab ID。
   - 将第一个 `/path/to/` 实例更改为备份文件所需目录的完整路径。
   - 将第二个 `/path/to/` 实例更改为保存 `csp_designation.rb` 文件的目录的完整路径。

   ```shell
   CSP_GROUP_ID=<group-id> BACKUP_FILENAME="/path/to/csp_backup.txt" ACTION=assign sudo gitlab-rails runner /path/to/csp_designation.rb
   ```

1. 可选。如果您需要还原整个更改，请使用之前使用的相同群组 ID、备份文件路径和脚本路径运行此命令：

   ```shell
   CSP_GROUP_ID=<group-id> BACKUP_FILENAME="/path/to/csp_backup.txt" ACTION=unassign sudo gitlab-rails runner /path/to/csp_designation.rb
   ```

更多信息，请参阅 [Rails Runner 故障排除部分](../administration/operations/rails_console.md#troubleshooting)。

### `csp_designation.rb`

```ruby
class CspDesignation
  def initialize(csp_group_id, backup_filename)
    @backup_filename = backup_filename
    @csp_group = Group.find_by_id(csp_group_id)
    @csp_configuration = @csp_group&.security_orchestration_policy_configuration
    @user = @csp_configuration&.policy_last_updated_by
    @spp = @csp_configuration&.security_policy_management_project
  end

  def assign
    check_spp!

    config_ids, group_ids = Security::OrchestrationPolicyConfiguration.for_management_project(@spp)
                                                                      .where.not(namespace: @csp_group)
                                                                      .pluck(:id, :namespace_id)
                                                                      .transpose
    if group_ids.present?
      puts "Saving group IDs to #{@backup_filename} as backup: #{group_ids}..."
      File.write(@backup_filename, "#{group_ids.join("\n")}\n")
    end

    puts "Setting #{@csp_group.full_path} as CSP..."
    Security::PolicySetting.in_organization(Organizations::Organization.default_organization).update! csp_namespace: @csp_group

    if config_ids.present?
      puts "Unassigning the policy project #{@spp.id} from the groups in the background to remove duplicate policies..."
      config_ids.each do |config_id|
        ::Security::DeleteOrchestrationConfigurationWorker.perform_async(
          config_id, @user.id, @spp.id
        )
      end
    end
    puts "Done."
  end

  def unassign
    check_spp!

    puts "Unassigning #{@csp_group.full_path} as CSP..."
    Security::PolicySetting.in_organization(Organizations::Organization.default_organization).update! csp_namespace: nil

    if File.exist?(@backup_filename)
      puts "Reading group IDs from #{@backup_filename} to restore the policy project links..."
      namespace_ids = File.read(@backup_filename).split("\n").map(&:to_i).reject(&:zero?)
      Namespace.id_in(namespace_ids).find_each(batch_size: 100) do |namespace|
        puts "Assigning the policy project to #{namespace.full_path}..."
        result = ::Security::Orchestration::AssignService.new(
          container: namespace, current_user: @user,
          params: { policy_project_id: @spp.id }
        ).execute
        puts "Failed to assign policy project to #{namespace.full_path}: #{result[:message]}" if result.error?
      end
    end
  end

  private

  def check_spp!
    raise "CSP policy project doesn't exist" if @spp.blank?
  end
end

SUPPORTED_ACTIONS = %w[assign unassign].freeze
action = ENV['ACTION']
csp_group_id = ENV['CSP_GROUP_ID']
backup_filename = ENV['BACKUP_FILENAME']
raise "Unknown action: #{action}. Use either 'assign' or 'unassign'." unless action.in? SUPPORTED_ACTIONS
raise "Missing CSP_GROUP_ID" if csp_group_id.blank?
raise "Missing BACKUP_FILENAME" if backup_filename.blank?

CspDesignation.new(csp_group_id, backup_filename).public_send(action)
```

<a id="troubleshooting"></a>

## 故障排除

**无法指定合规与安全策略群组**

- 验证您是否具有实例管理员权限。
- 验证该群组是否为顶级群组（不是子群组）。
- 验证该群组是否存在且可访问。

<a id="feedback-and-support"></a>

## 反馈与支持

由于这是一个 Beta 版本，我们鼓励用户反馈。请通过您的常规极狐GitLab 支持渠道分享您的体验、建议和任何问题。

<a id="related-topics"></a>

## 相关主题

- [集中式合规框架](../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)
- [合规与安全策略群组](../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md)
- [合规中心](../user/compliance/compliance_center/_index.md)
- [合规框架](../user/compliance/compliance_frameworks/_index.md)