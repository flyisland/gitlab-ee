---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 重新分配贡献和成员资格
---

拥有顶级群组所有者角色的用户可以将占位用户的贡献和成员资格重新分配给现有的活跃非机器人用户。在目标实例上，拥有顶级群组所有者角色的用户可以：

- [在 UI 中](#request-reassignment-in-ui)或[通过 CSV 文件](#request-reassignment-by-using-a-csv-file)请求用户审阅贡献和成员资格的重新分配。
  对于大量占位用户，您应使用 CSV 文件。
  在这两种情况下，用户都会通过电子邮件收到请求，以接受或拒绝重新分配。
  只有在所选用户[接受重新分配请求](#accept-contribution-reassignment)后，重新分配才会开始。
- 选择不重新分配贡献和成员资格，[将其保留为分配给占位用户](#keep-as-placeholder)。

在极狐GitLab 私有化部署上，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，无需其确认。有关更多信息，请参阅[管理员重新分配占位用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

<a id="bypass-confirmation-when-reassigning-placeholder-users"></a>

## 重新分配占位用户时绕过确认

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

先决条件：

- 您必须拥有该群组的所有者角色。

要在重新分配占位用户时绕过[企业用户](../../enterprise_user/_index.md)的确认：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**设置** > **常规**。
1. 展开**权限和群组功能**。
1. 在**占位符用户确认**下，选中**无需用户确认即可将占位符重新分配给企业用户**复选框。
1. 在**何时恢复用户确认**中，选择绕过用户确认的结束日期。
   默认值为一天。
1. 选择**保存更改**。

<a id="reassigning-contributions-from-multiple-placeholder-users"></a>

### 重新分配多个占位用户的贡献

您可以将最初分配给单个占位用户的所有贡献重新分配给目标实例上的单个活跃常规用户、服务账号、项目机器人和群组机器人。您不能将分配给单个占位用户的贡献拆分给多个用户。

如果占位用户来自以下来源，您可以将多个占位用户的贡献重新分配给目标实例上的同一用户：

- 不同的源实例
- 同一源实例，并且导入到目标实例上的不同顶级群组

如果被分配的用户在接受重新分配请求之前变为非活跃状态，待处理的重新分配会一直与该用户关联，直到其接受为止。

收到重新分配请求的用户可以：

- [接受请求](#accept-contribution-reassignment)。之前归属于占位用户的所有贡献和成员资格都会重新归属于接受请求的用户。此过程可能需要几分钟，具体取决于贡献的数量。
- [拒绝请求](#reject-contribution-reassignment)或将其报告为垃圾邮件。此选项在重新分配请求电子邮件中提供。

当您将贡献重新分配给服务账号、项目机器人和群组机器人时，重新分配请求会自动批准。

在后续导入到同一顶级群组时，属于同一源用户的贡献和成员资格会自动映射到之前为该源用户接受重新分配的用户。

在极狐GitLab 私有化部署上，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，无需其确认。有关更多信息，请参阅[管理员重新分配占位用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

<a id="completing-the-reassignment"></a>

### 完成重新分配

在您执行以下操作之前，必须完全完成重新分配过程：

- [在同一极狐GitLab 实例中移动已导入的群组](../../group/manage.md#transfer-a-group)。
- [将已导入的项目移动到其他群组](../../project/working_with_projects.md#transfer-a-project)。
- 复制已导入的议题。
- 将已导入的议题提升为史诗。

如果该过程未完成，仍分配给占位用户的贡献无法重新分配给真实用户，它们会继续与占位用户关联。

<a id="security-considerations"></a>

### 安全注意事项

贡献和成员资格的重新分配无法撤销，因此在开始之前请仔细检查所有内容。

将贡献和成员资格重新分配给错误的用户会构成安全威胁，因为该用户会成为您群组的成员。因此，他们可以查看本不应看到的信息。

默认情况下，将贡献重新分配给具有管理员访问权限的用户处于禁用状态，但您可以[启用](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)它。

<a id="membership-security-considerations"></a>

#### 成员资格安全注意事项

由于极狐GitLab 的权限模型，当群组或项目导入到现有父群组时，父群组的成员会被授予已导入群组或项目的[继承成员资格](../../project/members/_index.md#membership-types)。

如果为贡献和成员资格重新分配选择的用户已经拥有已导入群组或项目的现有继承成员资格，则可能影响成员资格重新分配给他们的方式。

极狐GitLab 不允许子项目或群组中的成员资格角色低于继承成员资格。如果被分配用户的已导入成员资格角色低于其现有继承成员资格，则已导入的成员资格不会重新分配给该用户。

这会导致他们在已导入群组或项目中的成员资格高于其在源上的成员资格。

<a id="request-reassignment-in-ui"></a>

### 在 UI 中请求重新分配

先决条件：

- 您必须拥有该群组的所有者角色。

您可以在顶级群组中重新分配贡献和成员资格。要请求重新分配贡献和成员资格：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 转到**等待重新分配**子标签页，占位用户会在表格中列出。
1. 对于每个占位用户，查看表格列**占位符用户**和**来源**中的信息。
1. 在**将占位符重新分配给**列中，从下拉列表中选择一个用户。
1. 选择**重新分配**。

只能将一个占位用户的贡献重新分配给目标实例上的一个活跃非机器人用户。

在用户接受重新分配之前，您可以[取消请求](#cancel-reassignment-request)。

在极狐GitLab 私有化部署上，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，无需其确认。有关更多信息，请参阅[管理员重新分配占位用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

<a id="request-reassignment-by-using-a-csv-file"></a>

### 使用 CSV 文件请求重新分配

先决条件：

- 您必须拥有该群组的所有者角色。

对于大量占位用户，您可能希望使用 CSV 文件重新分配贡献和成员资格。您可以下载包含以下信息的预填 CSV 模板。例如：

| 源主机          | 导入类型 | 源用户标识符 | 源用户名称 | 源用户名 |
|----------------------|-------------|------------------------|------------------|-----------------|
| `gitlab.example.com` | `gitlab`    | `alice`                | `Alice Coder`    | `a.coder`       |

不要更新**源主机**、**导入类型**或**源用户标识符**。此信息用于在您上传填写好的 CSV 文件后定位相应的数据库记录。**源用户名称**和**源用户名**用于标识源用户，在您上传 CSV 文件后不再使用。

您不必更新 CSV 文件的每一行。只有包含**极狐GitLab 用户名**或**极狐GitLab 公开电子邮件**的行会被处理。所有其他行都会被跳过。

要使用 CSV 文件请求重新分配贡献和成员资格：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 选择**使用 CSV 重新分配**。
1. 下载预填的 CSV 模板。
1. 在**极狐GitLab 用户名**或**极狐GitLab 公开电子邮件**中，输入目标实例上极狐GitLab 用户的用户名或公开电子邮件地址。
   实例管理员可以重新分配具有任何已确认电子邮件地址的用户。
1. 上传填写好的 CSV 文件。
1. 选择**重新分配**。

您只能将单个占位用户的贡献分配给目标实例上的每个活跃非机器人用户。用户会收到一封电子邮件，以审阅并[接受您重新分配给他们的任何贡献](#accept-contribution-reassignment)。您可以在用户审阅之前[取消重新分配请求](#cancel-reassignment-request)。

在极狐GitLab 私有化部署上，管理员可以立即将贡献和成员资格重新分配给活跃和非活跃的非机器人用户，无需其确认。有关更多信息，请参阅[管理员重新分配占位用户时跳过确认](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)。要将贡献和成员资格重新分配给管理员，请参阅[允许将贡献映射到管理员](../../../administration/settings/import_and_export_settings.md#allow-contribution-mapping-to-administrators)。

在您重新分配贡献后，极狐GitLab 会向您发送一封电子邮件，其中包含以下数量：

- 成功处理的行数
- 未成功处理的行数
- 跳过的行数

如果有任何行未成功处理，该电子邮件会附带一个包含更详细结果的 CSV 文件。

要在不使用 UI 的情况下批量重新分配占位用户，请参阅[群组占位用户重新分配 API](../../../api/group_placeholder_reassignments.md)。

<a id="keep-as-placeholder"></a>

### 保留为占位用户

您可能不希望将贡献和成员资格重新分配给目标实例上的用户。例如，您可能有曾在源实例上做出贡献的前员工，但他们在目标实例上并不作为用户存在。

在这些情况下，您可以将贡献保留为分配给占位用户。占位用户不保留成员资格信息，因为他们[不能成为项目或群组的成员](post_migration_mapping.md#placeholder-user-attributes)。

由于占位用户的名称和用户名与源用户的名称和用户名相似，您可以保留大量历史上下文。

您可以逐个或批量将贡献保留为分配给占位用户。当您批量重新分配贡献时，整个命名空间以及具有以下[重新分配状态](#view-and-filter-by-reassignment-status)的用户都会受到影响：

- `Not started`
- `Rejected`

要逐个保留占位用户：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 转到**等待重新分配**子标签页，占位用户会在表格中列出。
1. 通过查看**占位符用户**和**来源**列，找到您要保留的占位用户。
1. 在**将占位符重新分配给**列中，选择**不重新分配**。
1. 选择**确认**。

要批量保留占位用户：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 在列表上方，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **全部保留为占位符**。
1. 在确认对话框中，选择**确认**。

要撤销该操作：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 转到**已重新分配**子标签页，占位用户会在表格中列出。
1. 在正确的行中选择**撤销**。

<a id="cancel-reassignment-request"></a>

### 取消重新分配请求

在用户接受重新分配请求之前，您可以取消该请求：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 转到**等待重新分配**子标签页，占位用户会在表格中列出。
1. 在正确的行中选择**取消**。

<a id="notify-user-again-about-pending-reassignment-requests"></a>

### 再次通知用户有关待处理的重新分配请求

如果用户未对重新分配请求采取行动，您可以通过发送另一封电子邮件再次提醒他们：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 转到**等待重新分配**子标签页，占位用户会在表格中列出。
1. 在正确的行中选择**通知**。

<a id="view-and-filter-by-reassignment-status"></a>

### 查看并按重新分配状态筛选

要查看所有占位用户的重新分配状态：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   该群组必须位于顶级。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**占位符**标签页。
1. 转到**等待重新分配**子标签页，占位用户会在表格中列出。
1. 在**重新分配状态**列中查看每个占位用户的状态。

在**等待重新分配**标签页中，可能的状态有：

- `Not started` - 重新分配尚未开始。
- `Pending approval` - 重新分配正在等待用户批准。
- `Reassigning` - 重新分配正在进行中。
- `Rejected` - 重新分配被用户拒绝。
- `Failed` - 重新分配失败。

在**已重新分配**标签页中，可能的状态有：

- `Success` - 重新分配成功。
- `Kept as placeholder` - 占位用户已被设为永久。

默认情况下，表格按占位用户名称的字母顺序排序。您也可以按重新分配状态对表格排序。

<a id="confirm-contribution-reassignment"></a>

## 确认贡献重新分配

当[**管理员重新分配占位符用户时跳过确认**](../../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users)已启用时：

- 管理员可以立即重新分配贡献，无需用户确认。
- 管理员可以将贡献重新分配给活跃和非活跃的非机器人用户。
- 您会收到一封电子邮件，通知您贡献已被重新分配给您。

如果未启用此设置，您可以[接受](#accept-contribution-reassignment)或[拒绝](#reject-contribution-reassignment)重新分配。

<a id="accept-contribution-reassignment"></a>

### 接受贡献重新分配

您可能会收到一封电子邮件，通知您发生了导入过程，并要求您确认将贡献重新分配给您自己。

如果您已被告知此导入过程，您仍必须非常仔细地审阅重新分配详细信息。电子邮件中列出的详细信息包括：

- **导入自** - 导入内容来源的平台。例如，另一个极狐GitLab 实例、GitHub 或 Bitbucket。
- **原用户** - 源平台上用户的名称和用户名。这可能是您在该平台上的名称和用户名。
- **导入到** - 新平台的名称，只能是极狐GitLab 实例。
- **重新分配给** - 您在极狐GitLab 实例上的全名和用户名。
- **重新分配者** - 执行导入的同事或经理的全名和用户名。

<a id="reject-contribution-reassignment"></a>

### 拒绝贡献重新分配

如果您收到一封要求您确认将贡献重新分配给您自己的电子邮件，并且您不认识或注意到此信息中有错误：

1. 完全不要继续，或拒绝贡献重新分配。
1. 与您信任的同事或经理沟通。

<a id="security-considerations-1"></a>

### 安全注意事项

您必须非常仔细地审阅任何重新分配请求的重新分配详细信息。如果您尚未由信任的同事或经理告知此过程，请格外小心。

对于您有任何疑问的任何重新分配，不要接受，而是：

1. 不要对电子邮件采取行动。
1. 与您信任的同事或经理沟通。

只接受您认识和信任的用户的重新分配。贡献的重新分配是永久性的，无法撤销。接受重新分配可能会导致贡献被错误地归属于您。

贡献重新分配过程只有在您通过在极狐GitLab 中选择**批准重新分配**接受重新分配请求后才会开始。该过程不会通过选择电子邮件中的链接而开始。
