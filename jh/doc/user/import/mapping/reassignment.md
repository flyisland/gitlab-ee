---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 重新分配贡献和成员资格
---

具有顶级群组所有者角色的用户可以将占位符用户的贡献和成员资格重新分配给现有的活跃非机器人用户。在目标实例上，具有顶级群组所有者角色的用户可以：

- 在 UI 中[请求用户审查贡献和成员资格的重新分配](#request-reassignment-in-ui)，或[通过 CSV 文件请求](#request-reassignment-by-using-a-csv-file)。对于大量占位符用户，您应该使用 CSV 文件。在这两种情况下，用户都会通过电子邮件收到请求以接受或拒绝重新分配。重新分配仅在所选用户[接受重新分配请求](#accept-contribution-reassignment)之后才开始。
- 选择不重新分配贡献和成员资格，并[将它们保留分配给占位符用户](#keep-as-placeholder)。

在极狐GitLab私有化部署中，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，而无需其确认。更多信息，请参阅[管理员重新分配占位符用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

<a id="bypass-confirmation-when-reassigning-placeholder-users"></a>

## 绕过确认以重新分配占位符用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 JihuLab.com 上于 极狐GitLab 18.1 中引入，带有功能标志 `group_owner_placeholder_confirmation_bypass`，默认禁用。
- 在 JihuLab.com 上于 极狐GitLab 18.4 中启用。
- 在 JihuLab.com 上于 极狐GitLab 18.7 中 GA。功能标志 `group_owner_placeholder_confirmation_bypass` 已移除。

{{< /history >}}

先决条件：

- 您必须具有该群组的所有者角色。

要在重新分配占位符时为[企业用户](../../enterprise_user/_index.md)绕过确认：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **权限和群组功能**。
1. 在 **占位符用户确认** 下，选中 **无需用户确认即可将占位符重新分配给企业用户** 复选框。
1. 在 **何时恢复用户确认** 中，为绕过用户确认选择一个结束日期。默认值为一天。
1. 选择 **保存更改**。

<a id="reassigning-contributions-from-multiple-placeholder-users"></a>

### 重新分配多个占位符用户的贡献

您可以将最初分配给单个占位符用户的所有贡献重新分配给目标实例上的单个活跃普通用户、服务账户、项目机器人和群组机器人。您不能将分配给单个占位符用户的贡献拆分给多个用户。

在目标实例上，如果占位符用户来自以下情况，您可以将多个占位符用户的贡献重新分配给同一用户：

- 不同的源实例
- 相同的源实例，但被导入到目标实例上不同的顶级群组

如果指定的用户在接受重新分配请求之前变为非活跃状态，挂起的重新分配将保持与该用户的关联，直到他们接受为止。

收到重新分配请求的用户可以：

- [接受请求](#accept-contribution-reassignment)。先前归属于占位符用户的所有贡献和成员资格将重新归属于接受请求的用户。此过程可能需要几分钟，具体取决于贡献的数量。
- [拒绝请求](#reject-contribution-reassignment)或将其报告为垃圾邮件。此选项在重新分配请求电子邮件中可用。

当您将贡献重新分配给服务账户、项目机器人和群组机器人时，重新分配请求会自动批准。

在后续导入到同一顶级群组时，属于同一源用户的贡献和成员资格将自动映射到先前为该源用户接受了重新分配的用户。

在极狐GitLab私有化部署中，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，而无需其确认。更多信息，请参阅[管理员重新分配占位符用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

<a id="completing-the-reassignment"></a>

### 完成重新分配

在以下操作之前，必须完全完成重新分配过程：

- [在同一 极狐GitLab 实例中移动已导入的群组](../../group/manage.md#transfer-a-group)。
- [将已导入的项目移动到其他群组](../../project/working_with_projects.md#transfer-a-project)。
- 复制已导入的议题。
- 将已导入的议题提升为史诗。

如果过程未完成，仍分配给占位符用户的贡献将无法重新分配给真实用户，并将保持与占位符用户的关联。

<a id="security-considerations"></a>

### 安全注意事项

贡献和成员资格的重新分配不可撤销，因此在开始之前请仔细检查一切。

将贡献和成员资格重新分配给不正确的用户会带来安全威胁，因为该用户会成为您群组的成员。因此，他们可以查看他们不应看到的信息。

默认情况下，将贡献重新分配给具有管理员访问权限的用户是禁用的，但您可以[启用此功能](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

#### 成员资格安全注意事项

由于 极狐GitLab 权限模型，当群组或项目被导入到现有的父群组中时，父群组的成员将被授予已导入群组或项目的[继承成员资格](../../project/members/_index.md#membership-types)。

选择已拥有已导入群组或项目的现有继承成员资格的用户来进行贡献和成员资格重新分配，可能会影响成员资格如何重新分配给他们。

极狐GitLab 不允许子项目或群组中的成员角色低于继承的成员角色。如果指定用户的已导入成员角色低于其现有的继承成员角色，则该已导入的成员资格不会重新分配给该用户。

这导致他们的已导入群组或项目成员资格高于在源上的角色。

<a id="request-reassignment-in-ui"></a>

### 在 UI 中请求重新分配

先决条件：

- 您必须具有该群组的所有者角色。

您可以在顶级群组中重新分配贡献和成员资格。要请求重新分配贡献和成员资格：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符以表格形式列出。
1. 对于每个占位符，查看表格列 **占位符用户** 和 **来源** 中的信息。
1. 在 **将占位符重新分配给** 列中，从下拉列表中选择一个用户。
1. 选择 **重新分配**。

只能将单个占位符用户的贡献重新分配给目标实例上的一个活跃非机器人用户。

在用户接受重新分配之前，您可以[取消请求](#cancel-reassignment-request)。

在极狐GitLab私有化部署中，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，而无需其确认。更多信息，请参阅[管理员重新分配占位符用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

<a id="request-reassignment-by-using-a-csv-file"></a>

### 使用 CSV 文件请求重新分配

{{< history >}}

- 在 极狐GitLab 17.10 中引入，带有功能标志 `importer_user_mapping_reassignment_csv`，默认启用。
- 在 极狐GitLab 18.0 中 GA。功能标志 `importer_user_mapping_reassignment_csv` 已移除。

{{< /history >}}

先决条件：

- 您必须具有该群组的所有者角色。

对于大量占位符用户，您可能希望使用 CSV 文件来重新分配贡献和成员资格。您可以下载一个预填充的 CSV 模板，其中包含以下信息。例如：

| 源主机                | 导入类型     | 源用户标识符 | 源用户名     | 源用户名称  |
|-----------------------|------------|------------|------------|-----------|
| `gitlab.example.com`  | `gitlab`   | `alice`    | `Alice Coder` | `a.coder` |

不要更新 **源主机**、**导入类型** 或 **源用户标识符**。这些信息在上传完成的 CSV 文件后用于定位相应的数据库记录。**源用户名** 和 **源用户名称** 用于识别源用户，并在上传 CSV 文件后不再使用。

您不必更新 CSV 文件的每一行。只有包含 **GitLab 用户名** 或 **GitLab 公共电子邮件** 的行才会被处理。所有其他行将被跳过。

要使用 CSV 文件请求重新分配贡献和成员资格：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 选择 **使用 CSV 重新分配**。
1. 下载预填充的 CSV 模板。
1. 在 **GitLab 用户名** 或 **GitLab 公共电子邮件** 中，输入目标实例上 极狐GitLab 用户的用户名或公共电子邮件地址。实例管理员可以重新分配任何已确认电子邮件地址的用户。
1. 上传完成的 CSV 文件。
1. 选择 **重新分配**。

您只能将单个占位符用户的贡献分配给目标实例上的每个活跃非机器人用户。用户将收到一封电子邮件，以审查并[接受您重新分配给他们的任何贡献](#accept-contribution-reassignment)。在用户审查之前，您可以[取消重新分配请求](#cancel-reassignment-request)。

在极狐GitLab私有化部署中，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，而无需其确认。更多信息，请参阅[管理员重新分配占位符用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

在您重新分配贡献后，极狐GitLab 会向您发送一封电子邮件，告知以下数量：

- 成功处理的行
- 未成功处理的行
- 跳过的行

如果有任何行未成功处理，该电子邮件会附带一个包含更详细结果的 CSV 文件。

要在不通过 UI 的情况下批量重新分配占位符用户，请参阅[群组占位符重新分配 API](../../../api/group_placeholder_reassignments.md)。

<a id="keep-as-placeholder"></a>

### 保持为占位符

{{< history >}}

- 在 极狐GitLab 18.5 中更改，该操作可以撤消。

{{< /history >}}

您可能不希望将贡献和成员资格重新分配给目标实例上的用户。例如，您可能有在源实例上做出贡献的前员工，但他们在目标实例上不作为用户存在。

在这些情况下，您可以将贡献保持分配给占位符用户。占位符用户不保留成员资格信息，因为他们[不能成为项目或群组的成员](post_migration_mapping.md#placeholder-user-attributes)。

因为占位符用户的姓名和用户名类似于源用户的姓名和用户名，您可保留大量历史上下文。

您可以逐个或批量地将贡献保持分配给占位符用户。当您批量重新分配贡献时，整个命名空间和具有以下[重新分配状态](#view-and-filter-by-reassignment-status)的用户将受到影响：

- `未开始`
- `已拒绝`

要逐个保持占位符用户：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符以表格形式列出。
1. 通过查看 **占位符用户** 和 **来源** 列来找到您想要保留的占位符用户。
1. 在 **将占位符重新分配给** 列中，选择 **不重新分配**。
1. 选择 **确认**。

要批量保持占位符用户：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 在列表上方，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **全部保持为占位符**。
1. 在确认对话框中，选择 **确认**。

要撤消此操作：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **已重新分配** 子选项卡，其中占位符以表格形式列出。
1. 在正确的行中选择 **撤消**。

<a id="cancel-reassignment-request"></a>

### 取消重新分配请求

在用户接受重新分配请求之前，您可以取消请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符以表格形式列出。
1. 在正确的行中选择 **取消**。

<a id="notify-user-again-about-pending-reassignment-requests"></a>

### 再次通知用户有关待处理的重新分配请求

如果用户未对重新分配请求进行操作，您可以通过再次发送电子邮件来提示他们：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符以表格形式列出。
1. 在正确的行中选择 **通知**。

<a id="view-and-filter-by-reassignment-status"></a>

### 查看和按重新分配状态过滤

要查看所有占位符用户的重新分配状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。该群组必须为顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **占位符** 选项卡。
1. 转到 **等待重新分配** 子选项卡，其中占位符以表格形式列出。
1. 在 **重新分配状态** 列中查看每个占位符用户的状态。

在 **等待重新分配** 选项卡中，可能的状态有：

- `未开始` - 重新分配尚未开始。
- `等待批准` - 重新分配正在等待用户批准。
- `重新分配中` - 重新分配正在进行中。
- `已拒绝` - 重新分配已被用户拒绝。
- `失败` - 重新分配失败。

在 **已重新分配** 选项卡中，可能的状态有：

- `成功` - 重新分配成功。
- `保持为占位符` - 占位符用户已变为永久。

默认情况下，表格按占位符用户名称的字母顺序排序。您也可以按重新分配状态对表格进行排序。

<a id="confirm-contribution-reassignment"></a>

## 确认贡献重新分配

当[**管理员重新分配占位符用户时跳过确认**](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)启用时：

- 管理员可以立即重新分配贡献，无需用户确认。
- 管理员可以将贡献重新分配给活跃和非活跃的非机器人用户。
- 您将收到一封电子邮件，通知您已被重新分配贡献。

如果此设置未启用，您可以[接受](#accept-contribution-reassignment)或[拒绝](#reject-contribution-reassignment)重新分配。

<a id="accept-contribution-reassignment"></a>

### 接受贡献重新分配

您可能会收到一封电子邮件，告知您已进行导入过程，并要求您确认将贡献重新分配给自己。

如果您已被通知此导入过程，您仍必须非常仔细地审查重新分配详情。电子邮件中列出的详情包括：

- **导入来源** - 导入内容来源的平台。例如，另一个 极狐GitLab 实例、GitHub 或 Bitbucket。
- **原始用户** - 源平台上的用户名称和用户名。这可能是您在该平台上的姓名和用户名。
- **导入到** - 新平台的名称，只能是 GitLab 实例。
- **重新分配给** - 您在 极狐GitLab 实例上的全名和用户名。
- **由谁重新分配** - 执行导入的同事或经理的全名和用户名。

<a id="reject-contribution-reassignment"></a>

### 拒绝贡献重新分配

如果您收到一封要求确认将贡献重新分配给自己的电子邮件，但您不认识这些信息或发现其中有误：

1. 完全不要继续操作，或拒绝贡献重新分配。
1. 与您信任的同事或经理交谈。

<a id="security-considerations-1"></a>

### 安全注意事项

您必须非常仔细地审查任何重新分配请求的重新分配详情。如果您尚未通过信任的同事或经理得知此过程，请格外小心。

对于任何您有疑虑的重新分配，与其接受，不如：

1. 不要处理这些电子邮件。
1. 与您信任的同事或经理交谈。

只接受您认识并信任的用户的重新分配。贡献的重新分配是永久的，不可撤销。接受重新分配可能导致贡献被错误地归属于您。

只有在您通过在 极狐GitLab 中选择 **批准重新分配** 接受重新分配请求之后，贡献重新分配过程才会开始。该过程不会通过选择电子邮件中的链接来启动。