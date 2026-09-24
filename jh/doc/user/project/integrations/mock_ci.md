---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 模拟 CI
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 此集成仅在开发环境中可用。

要设置模拟 CI 服务服务器，请响应以下端点：

- `commit_status`: `#{project.namespace.path}/#{project.path}/status/#{sha}.json`
  - 让你的服务返回 `200 { status: ['failed'|'canceled'|'running'|'pending'|'success'|'success-with-warnings'|'skipped'|'not_found'] }`。
  - 如果服务返回 404，则该服务被解释为 `pending`。
- `build_page`: `#{project.namespace.path}/#{project.path}/status/#{sha}`
  - 构建链接到的位置（无论是否已实现）。

有关模拟 CI 服务器的示例，请参见 [`gitlab-org/gitlab-mock-ci-service`](https://jihulab.com/gitlab-cn/gitlab-mock-ci-service)。