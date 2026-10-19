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

每次创建发布时，极狐GitLab 都会对与之相关的数据生成快照。这些数据保存在一个 JSON 文件中，称为*发布证据*。该功能包含测试产物、关联的里程碑和匹配的软件包，以支持内部流程，例如外部审计。

要访问发布证据，请在发布页面上，选择 **证据收集** 标题下列出的 JSON 文件链接。

您也可以[使用 API](../../../api/releases/_index.md#collect-release-evidence) 为现有发布生成发布证据。因此，每个发布可以有多个发布证据快照。您可以在发布页面上查看发布证据及其详细信息。

当议题跟踪器被禁用时，发布证据[无法下载](https://gitlab.com/gitlab-org/gitlab/-/issues/208397)。

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

## 将软件包包含在发布证据中

创建发布时，极狐GitLab 会自动查询项目的[软件包仓库](../../packages/package_registry/_index.md)，查找版本与发布标签匹配的软件包。匹配的软件包会包含在发布证据 JSON 的 `packages` 键下。

版本匹配规则如下：

- 如果发布标签带有 `v` 或 `V` 前缀（例如 `v1.0.0`），则匹配前会去除该前缀。标签 `v1.0.0` 会匹配版本为 `1.0.0`的软件包。
- 如果发布标签没有前缀（例如 `1.0.0`），则直接进行匹配。
- 仅包含[可显示的软件包](../../packages/package_registry/_index.md)。待销毁或处于错误状态的软件包会被排除。
- 多个软件包可以匹配同一个发布。例如，如果项目同时发布了版本为 `1.0.0`的通用软件包和 npm 软件包，则两者都会包含在证据中。

证据中的每个软件包条目都包含以下字段：

| 字段          | 描述                                                    |
|----------------|----------------------------------------------------------------|
| `id`           | 软件包的唯一 ID。                                  |
| `name`         | 软件包的名称。                                       |
| `version`      | 软件包的版本字符串。                             |
| `package_type` | 软件包的类型（例如 `generic`、`npm`、`maven`）。 |
| `created_at`   | 软件包创建时的时间戳。                    |

无需额外配置。只要项目软件包仓库中存在版本与发布标签匹配的软件包，收集证据时就会自动将其包含在内。

<a id="collect-release-evidence"></a>

## 收集发布证据

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

创建发布时，会自动收集发布证据。要在其他任何时间启动证据收集，请使用 [API 调用](../../../api/releases/_index.md#collect-release-evidence)。您可以为同一个发布多次收集发布证据。

证据收集快照会显示在发布页面上，并附有证据收集的时间戳。

<a id="include-report-artifacts-as-release-evidence"></a>

## 将报告产物包含在发布证据中

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建发布时，如果最后运行的流水线中包含[作业产物](../../../ci/yaml/_index.md#artifactsreports)，它们会自动作为发布证据包含在发布中。

虽然作业产物通常会过期，但包含在发布证据中的产物不会过期。

要启用作业产物收集，您必须同时指定：

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

如果流水线运行成功，当您创建发布时，`rspec.xml` 文件会保存为发布证据。

如果您[计划发布证据收集](#schedule-release-evidence-collection)，某些产物在证据收集时可能已经过期。为避免这种情况，您可以使用 [`artifacts:expire_in`](../../../ci/yaml/_index.md#artifactsexpire_in) 关键字。更多信息，请参见 [议题 222351](https://gitlab.com/gitlab-org/gitlab/-/issues/222351)。

<a id="schedule-release-evidence-collection"></a>

## 计划发布证据收集

在 API 中：

- 如果您指定未来的 `released_at` 日期，该发布将成为**即将发布的版本**，并且证据会在发布日期当天收集。在此之前您无法收集发布证据。
- 如果您指定过去的 `released_at` 日期，该发布将成为**历史发布**，并且不会收集证据。
- 如果您未指定 `released_at` 日期，发布证据会在发布创建当天收集。
