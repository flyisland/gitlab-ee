---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 发布证据
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

每次创建发布时，极狐GitLab 会拍摄与其相关的数据快照。这些数据保存在一个 JSON 文件中，称为*发布证据*。该功能包括测试产物、关联的里程碑以及匹配的软件包，以便于内部流程，如外部审计。

要访问发布证据，在发布页面上，选择列在**证据收集**标题下的 JSON 文件链接。

你也可以[使用 API](../../../api/releases/_index.md#collect-release-evidence) 为现有发布生成发布证据。因此，每个发布可以有多个发布证据快照。你可以在发布页面上查看发布证据及其详细信息。

以下是一个发布证据对象的示例：

```json
{
  "release": {
    "id": 5,
    "tag_name": "v4.0",
    "name": "New release",
    "project": {
      "id": 20,
      "name": "Project name",
      "created_at": "2019-04-14T11:12:13.940Z",
      "description": "Project description"
    },
    "created_at": "2019-06-28 13:23:40 UTC",
    "description": "Release description",
    "milestones": [
      {
        "id": 11,
        "title": "v4.0-rc1",
        "state": "closed",
        "due_date": "2019-05-12 12:00:00 UTC",
        "created_at": "2019-04-17 15:45:12 UTC",
        "description": "milestone description",
      },
      {
        "id": 12,
        "title": "v4.0-rc2",
        "state": "closed",
        "due_date": "2019-05-30 18:30:00 UTC",
        "created_at": "2019-04-17 15:45:12 UTC",
        "description": "milestone description",
      }
    ],
    "packages": [
      {
        "id": 1,
        "name": "my-package",
        "version": "4.0",
        "package_type": "generic",
        "created_at": "2019-06-20 10:00:00 UTC"
      }
    ],
    "report_artifacts": [
      {
        "url":"https://gitlab.example.com/root/project-name/-/jobs/111/artifacts/download"
      }
    ]
  }
}
```

<a id="include-packages-as-release-evidence"></a>

## 将软件包包含为发布证据

{{< history >}}

- 在 极狐GitLab 18.11 中引入。

{{< /history >}}

创建发布时，极狐GitLab 会自动查询项目的[软件包仓库](../../packages/package_registry/_index.md)，寻找版本与发布标签匹配的软件包。匹配的软件包会包含在发布证据 JSON 的 `packages` 键下。

版本匹配规则如下：

- 如果发布标签带有 `v` 或 `V` 前缀（例如 `v1.0.0`），则在匹配前会去除前缀。标签 `v1.0.0` 匹配版本为 `1.0.0` 的软件包。
- 如果发布标签没有前缀（例如 `1.0.0`），则直接匹配。
- 仅包含[可显示的软件包](../../packages/package_registry/_index.md)。待销毁或处于错误状态的软件包会被排除。
- 多个软件包可以匹配同一个发布。例如，如果项目发布了版本为 `1.0.0` 的通用软件包和 npm 软件包，两者都会包含在证据中。

证据中的每个软件包条目包含以下字段：

| 字段          | 描述                                                    |
|----------------|----------------------------------------------------------------|
| `id`           | 软件包的唯一 ID。                                  |
| `name`         | 软件包的名称。                                       |
| `version`      | 软件包的版本字符串。                             |
| `package_type` | 软件包的类型（例如 `generic`、`npm`、`maven`）。 |
| `created_at`   | 软件包的创建时间戳。                    |

无需额外配置。只要项目软件包仓库中存在版本与发布标签匹配的软件包，它们在收集证据时就会自动包含。

<a id="collect-release-evidence"></a>

## 收集发布证据

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

创建发布时，发布证据会自动收集。要在其他时间启动证据收集，请使用 [API 调用](../../../api/releases/_index.md#collect-release-evidence)。你可以为一个发布多次收集发布证据。

证据收集快照会显示在发布页面上，同时显示证据收集的时间戳。

<a id="include-report-artifacts-as-release-evidence"></a>

## 将报告产物包含为发布证据

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建发布时，如果最后运行的流水线中包含[作业产物](../../../ci/yaml/_index.md#artifactsreports)，它们会自动作为发布证据包含在发布中。

虽然作业产物通常会过期，但包含在发布证据中的产物不会过期。

要启用作业产物收集，你必须同时指定：

1. [`artifacts:paths`](../../../ci/yaml/_index.md#artifactspaths)
1. [`artifacts:reports`](../../../ci/yaml/_index.md#artifactsreports)

```yaml
ruby:
  script:
    - gem install bundler
    - bundle install
    - bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml
  artifacts:
    paths:
      - rspec.xml
    reports:
      junit: rspec.xml
```

如果流水线成功运行，当你创建发布时，`rspec.xml` 文件将保存为发布证据。

如果你[计划发布证据收集](#schedule-release-evidence-collection)，某些产物可能在证据收集时已经过期。为避免这种情况，你可以使用 [`artifacts:expire_in`](../../../ci/yaml/_index.md#artifactsexpire_in) 关键字。

<a id="schedule-release-evidence-collection"></a>

## 计划发布证据收集

在 API 中：

- 如果你指定未来的 `released_at` 日期，发布将成为**即将发布的版本**，证据将在发布日期收集。在此之前无法收集发布证据。
- 如果你指定过去的 `released_at` 日期，发布将成为**历史发布**，不会收集证据。
- 如果你未指定 `released_at` 日期，发布证据将在发布创建日期收集。