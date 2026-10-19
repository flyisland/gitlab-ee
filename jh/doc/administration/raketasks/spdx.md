---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将 SPDX 许可证列表导入极狐GitLab，以便为合规策略准确匹配许可证
title: SPDX 许可证列表导入 Rake 任务
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了一个 Rake 任务，用于将最新版本的 [SPDX 许可证列表](https://spdx.org/licenses/)上传到极狐GitLab 实例。该列表用于匹配[许可证审批策略](../../user/compliance/license_approval_policies.md)中的许可证名称。

要导入最新版本的 SPDX 许可证列表，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:spdx:import

# source installations
bundle exec rake gitlab:spdx:import RAILS_ENV=production
```

要在[离线环境](../../user/application_security/offline_deployments/_index.md#defining-offline-environments)中执行此任务，应允许对 [`licenses.json`](https://spdx.org/licenses/licenses.json) 建立出站连接。
