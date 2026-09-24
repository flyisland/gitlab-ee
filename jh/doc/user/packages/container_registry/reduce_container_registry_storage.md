---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少容器镜像仓库存储使用
description: Tips for monitoring and reducing storage usage for 极狐GitLab container registries.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

容器镜像仓库如果不加以管理，会随着时间推移而增大。例如，如果您添加大量的镜像或标签：

- 检索可用标签或镜像列表的速度会变慢。
- 它们会占用服务器上大量的存储空间。

您应该删除不必要的镜像和标签，并设置[容器镜像仓库清理策略](#cleanup-policy)，以自动管理容器镜像仓库的使用情况。

<a id="view-container-registry-usage"></a>

## 查看容器镜像仓库使用情况

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.7 中引入。

{{< /history >}}

查看容器镜像仓库的存储使用数据。

<a id="for-a-project"></a>

### 针对项目

**前提条件：**

- 对于私有化部署实例，管理员必须[启用容器镜像仓库元数据数据库](../../../administration/packages/container_registry_metadata_database.md)。
- 您必须具有项目的维护者或所有者角色，或者命名空间的所有者角色。

查看项目的存储使用情况：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 执行以下操作之一：
   - 要查看总存储使用量，选择 **设置** > **用量配额**。
     在 **命名空间实体** 下，选择 **容器镜像仓库** 以查看各个仓库。
   - 要直接按仓库查看存储使用量，选择 **部署** > **容器镜像仓库**。

您也可以使用：

- 使用项目 API 获取项目的容器镜像仓库总存储量。更多信息请参见[获取单个项目](../../../api/projects.md#retrieve-a-project)。
- 使用容器镜像仓库 API 获取特定仓库的大小数据。更多信息请参见[检索单个仓库的详细信息](../../../api/container_registry.md#retrieve-details-of-a-single-repository)。

<a id="for-a-group"></a>

### 针对群组

**前提条件：**

- 对于私有化部署实例，管理员必须[启用容器镜像仓库元数据数据库](../../../administration/packages/container_registry_metadata_database.md)。
- 您必须具有群组的所有者角色。

查看群组的存储使用情况：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **用量配额**。
1. 选择 **存储** 选项卡。

您也可以使用 [Groups API](../../../api/groups.md#list-all-groups) 获取群组中所有项目的容器镜像仓库总存储量。

<a id="storage-data-updates"></a>

### 存储数据更新

在启用元数据数据库后：

- 对于新的容器镜像，大小数据在推送后立即可用。
- 对于现有的容器镜像，大小数据在后台计算，可能需要长达 24 小时。

存储数据更新的时机：

- 在您推送或删除容器镜像时立即更新。
- 在您执行以下操作时实时更新：
  - 在 UI 中查看仓库镜像标签。
  - 使用容器镜像仓库 API [检索单个仓库的详细信息](../../../api/container_registry.md#retrieve-details-of-a-single-repository)。
- 在您推送或删除项目容器仓库中的标签时。
- 对于群组，每 5 分钟更新一次。

> [!note]
> 对于私有化部署实例，在管理员启用元数据数据库后，存储数据才可用。在 JihuLab.com 上，默认启用元数据数据库。

<a id="how-container-registry-usage-is-calculated"></a>

## 容器镜像仓库使用量如何计算

存储在容器镜像仓库中的镜像层在根命名空间级别去重。

在以下情况下，镜像仅计算一次：

- 您在同一个仓库中多次标记同一镜像。
- 您在同一根命名空间下的不同仓库中标记同一镜像。

在以下情况下，镜像层仅计算一次：

- 您在同一个容器仓库、项目或群组中的多个镜像之间共享该镜像层。
- 您在不同仓库之间共享该镜像层。

只有被标记镜像引用的层才会被计入。未标记的镜像以及仅由它们引用的任何层受[在线垃圾回收](delete_container_registry_images.md#garbage-collection)影响。未标记的镜像层如果在此期间未被引用，会在 24 小时后自动删除。

镜像层以原始（通常是压缩）格式存储在存储后端。这意味着任何给定镜像层的测量大小应与相应[镜像清单](https://github.com/opencontainers/image-spec/blob/main/manifest.md#example-image-manifest)上显示的大小相匹配。

命名空间使用量在命名空间下的任何容器仓库推送或删除标签几分钟后刷新。

<a id="delayed-refresh"></a>

### 延迟刷新

对于极其庞大的命名空间（约占命名空间的 1%），无法以最大精度实时计算容器镜像仓库使用量。为了让这些命名空间的维护者能够查看其使用量，存在一种延迟回退机制。

如果无法精确计算命名空间的使用量，极狐GitLab 将回退到延迟方法。在延迟方法中，显示的使用量大小是命名空间中所有唯一镜像层的总和。未标记的镜像层不会被忽略。因此，删除标签后，显示的使用量大小可能不会显著改变。相反，大小值仅在以下情况下变化：

- 自动化的[垃圾回收流程](delete_container_registry_images.md#garbage-collection)运行并删除未标记的镜像层。用户删除标签后，垃圾回收运行计划在 24 小时后开始。在该运行期间，将分析先前标记的镜像，并删除未被任何其他标记镜像引用的层。如果删除了任何层，命名空间使用量就会更新。
- 命名空间的镜像仓库使用量缩减到足以让极狐GitLab 以最大精度进行测量的程度。随着命名空间使用量的缩减，测量会自动从延迟方式切换到精确使用量测量。目前 UI 中没有位置可以确定正在使用哪种测量方法。

<a id="cleanup-policy"></a>

## 清理策略

{{< history >}}

- 在极狐GitLab 15.0 中，所需权限从开发者变更为维护者。

{{< /history >}}

清理策略是一项计划作业，可用于从容器镜像仓库中删除标签。对于定义了策略的项目，匹配正则表达式模式的标签会被删除，但其底层镜像层和镜像保留。

要删除不与任何标签关联的底层镜像层和镜像，管理员可以使用[垃圾回收](../../../administration/packages/container_registry.md#removing-untagged-manifests-and-unreferenced-layers)并带上 `-m` 开关。

<a id="enable-the-cleanup-policy"></a>

### 启用清理策略

> [!warning]
> 出于性能原因，对于 JihuLab.com 上没有容器镜像的项目，已启用的清理策略会自动禁用。

<a id="how-the-cleanup-policy-works"></a>

### 清理策略的工作原理

清理策略会收集容器镜像仓库中的所有标签，并排除标签，直到只剩下您想要删除的标签。

清理策略根据标签名称搜索镜像。

清理策略：

1. 收集给定仓库的所有标签到一个列表中。
1. 排除名为 `latest` 的标签。
1. 评估 `name_regex`（要过期的标签），排除不匹配的名称。
1. 排除与 `name_regex_keep` 值（要保留的标签）匹配的所有标签。
1. 排除任何没有清单的标签（不在 UI 选项中）。
1. 按 `created_date` 排序剩余的标签。
1. 根据 `keep_n` 值（要保留的标签数量）排除 N 个标签。
1. 排除早于 `older_than` 值（过期间隔）的标签。
1. 排除[受保护的标签](protected_container_tags.md)。
1. 排除[不可变标签](immutable_container_tags.md)。
1. 从容器镜像仓库中删除列表中剩余的标签。

> [!warning]
> 在 JihuLab.com 上，清理策略的执行时间有限。策略运行后，部分标签可能仍保留在容器镜像仓库中。下次策略运行时，这些剩余标签会被包含在内。
> 可能需要进行多次运行才能删除所有标签。
>
> 私有化部署实例支持符合 [Docker Registry HTTP API V2](https://distribution.github.io/distribution/spec/api/) 规范的第三方容器镜像仓库。但是，该规范不包括标签删除操作。因此，当与第三方容器镜像仓库交互时，极狐GitLab 使用一种变通方法来删除标签。由于实现可能有所不同，此变通方法无法保证以相同可预测的方式适用于所有第三方仓库。如果您使用极狐GitLab 容器镜像仓库，则无需此变通方法，因为极狐GitLab 实现了特殊的标签删除操作。在这种情况下，清理策略应该是一致且可预测的。

<a id="example-cleanup-policy-workflow"></a>

#### 示例清理策略工作流程

清理策略中保留规则和删除规则之间的交互可能很复杂。
例如，有一个项目配置了以下清理策略：

- **保留最近的**：每个镜像名保留 1 个标签。
- **保留匹配的标签**：`production-.*`
- **删除超过**：7 天前的标签。
- **删除匹配的标签**：`.*`

以及一个包含以下标签的容器仓库：

- `latest`，2 小时前发布。
- `production-v44`，3 天前发布。
- `production-v43`，6 天前发布。
- `production-v42`，11 天前发布。
- `dev-v44`，2 天前发布。
- `dev-v43`，5 天前发布。
- `dev-v42`，10 天前发布。
- `v44`，昨天发布。
- `v43`，12 天前发布。
- `v42`，20 天前发布。

在此示例中，下一次清理运行中将删除的标签是 `dev-v42`、`v43` 和 `v42`。
您可以理解为规则的优先级如下：

1. 保留规则具有最高优先级。当标签匹配任何保留规则时必须保留。
   - 必须保留 `latest` 标签，因为 `latest` 标签始终保留。
   - 必须保留 `production-v44`、`production-v43` 和 `production-v42` 标签，因为它们匹配 **保留匹配的标签** 规则。
   - 必须保留 `v44` 标签，因为它是最新的，匹配 **保留最近的** 规则。
1. 删除规则的优先级较低，只有当所有规则都匹配时才会删除标签。
   对于不匹配任何保留规则的标签（`dev-44`、`dev-v43`、`dev-v42`、`v43` 和 `v42`）：
   - `dev-44` 和 `dev-43` 不匹配 **删除超过**，因此被保留。
   - `dev-v42`、`v43` 和 `v42` 同时匹配 **删除超过** 和 **删除匹配的标签** 规则，因此这三个标签可以被删除。

<a id="create-a-cleanup-policy"></a>

### 创建清理策略

您可以通过 [API](#use-the-cleanup-policy-api) 或 UI 创建清理策略。

在 UI 中创建清理策略：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **软件包与镜像仓库**。
1. 展开 **容器镜像仓库**。
1. 在 **容器镜像仓库清理策略** 下，选择 **设置清理规则**。
1. 填写以下字段：

   | 字段 | 描述 |
   |----------------------------|-------------|
   | **开关** | 打开或关闭策略。 |
   | **运行清理** | 策略运行的频率。 |
   | **保留最近的** | 每个镜像始终要保留的标签数量。 |
   | **保留匹配的标签** | 决定要保留哪些标签的正则表达式模式。`latest` 标签始终保留。对于所有标签，请使用 `.*`。查看其他[正则表达式模式示例](#regex-pattern-examples)。 |
   | **删除超过** | 仅删除超过 X 天的标签。您应该从一个较高的数字开始，以便在首次清理时仅删除最旧的镜像。在监控清理后台工作器使用的资源后，可以逐步减少天数。 |
   | **删除匹配的标签** | 决定要删除哪些标签的正则表达式模式。此值不能为空。您应该从一个相对具体的正则表达式开始，以便在首次清理时仅删除少量镜像。在监控清理后台工作器使用的资源后，调整正则表达式使其更通用，最多可使用 `.*` 匹配所有标签。更多信息请参见[正则表达式模式示例](#regex-pattern-examples)。 |

   > [!note]
   > 保留和删除正则表达式模式都会自动被 `\A` 和 `\Z` 锚点包围，因此您无需包含它们。但是，在选择和测试正则表达式模式时，请务必考虑这一点。

1. 选择 **保存**。

策略将按照您选择的计划间隔运行。

> [!note]
> 如果您编辑策略并再次选择 **保存**，间隔将被重置。

<a id="regex-pattern-examples"></a>

### 正则表达式模式示例

清理策略在 UI 和 API 中都使用正则表达式模式来确定应保留或删除哪些标签。

极狐GitLab 在清理策略中使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax) 来表达正则表达式。

以下是您可以使用的一些正则表达式模式示例：

- 匹配所有标签：

  ```plaintext
  .*
  ```

  此模式是过期正则表达式的默认值。

- 匹配以 `v` 开头的标签：

  ```plaintext
  v.+
  ```

- 仅匹配名为 `main` 的标签：

  ```plaintext
  main
  ```

- 匹配名为 `release` 或以 `release` 开头的标签：

  ```plaintext
  release.*
  ```

- 匹配以 `v` 开头、名为 `main` 或以 `release` 开头的标签：

  ```plaintext
  (?:v.+|main|release.*)
  ```

<a id="set-cleanup-limits-to-conserve-resources"></a>

### 设置清理限制以节省资源

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

清理策略作为后台进程执行。根据要删除的标签数量，该过程可能需要一段时间才能完成。

您可以使用以下应用设置来防止服务器资源紧缺：

| 应用设置 | 类型 | 描述 |
|---------|------|-------------|
| `container_registry_expiration_policies_worker_capacity` | integer | 同时运行的最大清理工作器数量。默认为 `4`。将此值设置为 `0` 可移除所有工作器并停止清理策略运行。从一个较低的数字开始，并在监控后台工作器使用的资源后增加。 |
| `container_registry_delete_tags_service_timeout` | integer | 清理过程删除一批标签的最大时间（秒）。默认为 `250`。 |
| `container_registry_cleanup_tags_service_max_list_size` | integer | 单次执行中可删除的最大标签数量。默认为 `200`。额外的标签必须在另一次执行中删除。从一个较低的数字开始，并在验证容器镜像被正确删除后增加。 |
| `container_registry_expiration_policies_caching` | boolean | 策略执行期间标签创建时间戳的缓存。默认为 `true`。缓存的时间戳存储在 Redis 中。 |

**前提条件：**

- 管理员访问权限。

您可以在 [Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session) 中更改这些设置。例如：

```ruby
ApplicationSetting.last.update(container_registry_expiration_policies_worker_capacity: 3)
```

要在 **管理员** 区域更改这些设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **容器镜像仓库**。

<a id="use-the-cleanup-policy-api"></a>

### 使用清理策略 API

您可以使用极狐GitLab API 设置、更新和禁用清理策略。

示例：

- 选择所有标签，每个镜像至少保留 1 个标签，清理超过 14 天的任何标签，每月运行一次，保留任何名为 `main` 的镜像，并启用策略：

  ```shell
  curl --fail-with-body --request PUT --header 'Content-Type: application/json;charset=UTF-8'
       --header "PRIVATE-TOKEN: <your_access_token>" \
       --data-binary '{"container_expiration_policy_attributes":{"cadence":"1month","enabled":true,"keep_n":1,"older_than":"14d","name_regex":".*","name_regex_keep":".*-main"}}' \
       "https://gitlab.example.com/api/v4/projects/2"
  ```

使用 API 时，`cadence` 的有效值为：

- `1d`（每天）
- `7d`（每周）
- `14d`（每两周）
- `1month`（每月）
- `3month`（每季度）

使用 API 时，`keep_n`（每个镜像名称保留的标签数）的有效值为：

- `1`
- `5`
- `10`
- `25`
- `50`
- `100`

使用 API 时，`older_than`（自动删除标签的天数）的有效值为：

- `1d`
- `3d`
- `7d`
- `14d`
- `30d`
- `60d`
- `90d`
- `180d`
- `365d`
- `730d`
- `1095d`

更多详细信息请参见 API 文档：[编辑项目 API](../../../api/projects.md#update-a-project)。

<a id="use-with-external-container-registries"></a>

### 与外部容器镜像仓库一起使用

当使用[外部容器镜像仓库](../../../administration/packages/container_registry.md#use-an-external-container-registry-with-gitlab-as-an-auth-endpoint)时，在项目上运行清理策略可能会带来一些性能风险。如果项目运行策略删除数千个标签，极狐GitLab 后台作业可能会积压或完全失败。

<a id="more-container-registry-storage-reduction-options"></a>

## 更多容器镜像仓库存储缩减选项

以下是可用于减少项目容器镜像仓库存储使用的其他选项：

- 使用 [极狐GitLab UI](delete_container_registry_images.md#use-the-gitlab-ui) 删除单个镜像标签或包含所有标签的整个仓库。
- 使用 API [删除单个镜像标签](../../../api/container_registry.md#delete-a-registry-repository-tag)。
- 使用 API [删除包含所有标签的整个容器镜像仓库](../../../api/container_registry.md#delete-registry-repository)。
- 使用 API [批量删除镜像仓库标签](../../../api/container_registry.md#delete-registry-repository-tags-in-bulk)。

<a id="troubleshooting"></a>

## 故障排除

<a id="storage-size-is-not-available"></a>

### 存储大小不可用

如果您看不到容器镜像仓库的存储大小信息：

1. 请管理员验证[元数据数据库已正确配置](../../../administration/packages/container_registry_metadata_database.md)。
1. 验证镜像仓库存储后端已正确配置且可访问。
1. 检查镜像仓库日志中的存储相关错误：

   ```shell
   sudo gitlab-ctl tail registry
   ```

<a id="something-went-wrong-while-updating-the-cleanup-policy"></a>

### `更新清理策略时出错。`

如果您看到此错误消息，请检查正则表达式模式以确保它们有效。

您可以使用 [regex101 正则表达式测试器](https://regex101.com/) 测试它们，并选择 `Golang` 风格。查看一些常见的[正则表达式模式示例](#regex-pattern-examples)。

<a id="the-cleanup-policy-doesnt-delete-any-tags"></a>

### 清理策略未删除任何标签

这可能由不同原因引起：

- 如果您在私有化部署实例上，并且容器仓库中有 1000 多个标签，您可能会遇到容器镜像仓库令牌过期问题，日志中出现 `error authorizing context: invalid token`。

  要解决此问题，有两种变通方法：

  - 您可以[为清理策略设置限制](reduce_container_registry_storage.md#set-cleanup-limits-to-conserve-resources)。这会在时间上限制清理执行，并避免令牌过期错误。

  - [延长容器镜像仓库认证令牌的过期延迟](../../../administration/packages/container_registry.md#increase-token-duration)。此值默认为 5 分钟。

或者，您可以生成要删除的标签列表，并使用该列表删除标签。要创建列表并删除标签：

1. 运行以下 shell 脚本。`for` 循环之前的命令确保每次开始循环时 `list_o_tags.out` 都会重新初始化。运行此命令后，所有标签名称将写入 `list_o_tags.out` 文件：

   ```shell
   # 获取特定容器仓库中的所有标签列表，同时考虑 [分页](../../../api/rest/_index.md#pagination)
   echo -n "" > list_o_tags.out; for i in {1..N}; do curl --fail-with-body --header 'PRIVATE-TOKEN: <PAT>' "https://gitlab.example.com/api/v4/projects/<Project_id>/registry/repositories/<container_repo_id>/tags?per_page=100&page=${i}" | jq '.[].name' | sed 's:^.\(.*\).$:\1:' >> list_o_tags.out; done
   ```

   如果您有 Rails 控制台访问权限，可以输入以下命令来检索按日期限制的标签列表：

   ```shell
   output = File.open( "/tmp/list_o_tags.out","w" )
   Project.find(<Project_id>).container_repositories.find(<container_repo_id>).tags.each do |tag|
     output << tag.name + "\n" if tag.created_at < 1.month.ago
   end;nil
   output.close
   ```

   这组命令会创建一个 `/tmp/list_o_tags.out` 文件，列出所有 `created_at` 日期超过一个月的标签。

1. 从 `list_o_tags.out` 文件中删除您想要保留的标签。例如，您可以使用 `sed` 来解析文件并删除标签。

   {{< tabs >}}

   {{< tab title="Linux" >}}

   ```shell
   # 从文件中删除 `latest` 标签
   sed -i '/latest/d' list_o_tags.out

   # 从文件中删除前 N 个标签
   sed -i '1,Nd' list_o_tags.out

   # 从文件中删除以 `Av` 开头的标签
   sed -i '/^Av/d' list_o_tags.out

   # 从文件中删除以 `_v3` 结尾的标签
   sed -i '/_v3$/d' list_o_tags.out
   ```

   {{< /tab >}}

   {{< tab title="macOS" >}}

   ```shell
   # 从文件中删除 `latest` 标签
   sed -i .bak '/latest/d' list_o_tags.out

   # 从文件中删除前 N 个标签
   sed -i .bak '1,Nd' list_o_tags.out

   # 从文件中删除以 `Av` 开头的标签
   sed -i .bak '/^Av/d' list_o_tags.out

   # 从文件中删除以 `_v3` 结尾的标签
   sed -i .bak '/_v3$/d' list_o_tags.out
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 仔细检查 `list_o_tags.out` 文件，确保它只包含您想要删除的标签。

1. 运行此 shell 脚本以删除 `list_o_tags.out` 文件中的标签：

   ```shell
   # 遍历 list_o_tags.out，一次删除一个标签
   while read -r LINE || [[ -n $LINE ]]; do echo ${LINE}; curl --fail-with-body --request DELETE --header 'PRIVATE-TOKEN: <PAT>' "https://gitlab.example.com/api/v4/projects/<Project_id>/registry/repositories/<container_repo_id>/tags/${LINE}"; sleep 0.1; echo; done < list_o_tags.out > delete.logs
   ```