---
stage: Growth
group: Acquisition
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Experiments API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用此 API 与 A/B 实验交互。此 API 仅供内部使用。

先决条件：

- 您必须是[极狐GitLab 团队成员](https://gitlab.com/groups/gitlab-com/-/group_members)。

## 列出所有实验

列出极狐GitLab 实例上的所有实验。每个实验都有一个 `enabled` 状态，用以指示该实验是全局启用，还是仅在特定上下文中启用。

```plaintext
GET /experiments
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/experiments"
```

示例响应：

```json
[
  {
    "key": "code_quality_walkthrough",
    "definition": {
      "name": "code_quality_walkthrough",
      "introduced_by_url": "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/58900",
      "rollout_issue_url": "https://gitlab.com/gitlab-org/gitlab/-/issues/327229",
      "milestone": "13.12",
      "type": "experiment",
      "group": "group::activation",
      "default_enabled": false
    },
    "current_status": {
      "state": "conditional",
      "gates": [
        {
          "key": "boolean",
          "value": false
        },
        {
          "key": "percentage_of_actors",
          "value": 25
        }
      ]
    }
  },
  {
    "key": "ci_runner_templates",
    "definition": {
      "name": "ci_runner_templates",
      "introduced_by_url": "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/58357",
      "rollout_issue_url": "https://gitlab.com/gitlab-org/gitlab/-/issues/326725",
      "milestone": "14.0",
      "type": "experiment",
      "group": "group::activation",
      "default_enabled": false
    },
    "current_status": {
      "state": "off",
      "gates": [
        {
          "key": "boolean",
          "value": false
        }
      ]
    }
  }
]
```