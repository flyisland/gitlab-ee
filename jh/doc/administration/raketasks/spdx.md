---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Import the SPDX license list into GitLab, enabling accurate license matching for compliance policies
title: SPDX 许可证列表导入 Rake 任务
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了一个 Rake 任务，用于将最新的 [SPDX 许可证列表](https://spdx.org/licenses/) 副本上传到极狐GitLab 实例。此列表用于匹配 [许可证批准策略](../../user/compliance/license_approval_policies.md) 中的名称。

要导入最新的 SPDX 许可证列表副本，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:spdx:import

# source installations
bundle exec rake gitlab:spdx:import RAILS_ENV=production
```

要在 [离线环境](../../user/application_security/offline_deployments/_index.md#defining-offline-environments) 中执行此任务，应允许到 [`licenses.json`](https://spdx.org/licenses/licenses.json) 的出站连接。