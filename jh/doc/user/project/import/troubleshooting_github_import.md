---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 GitHub 迁移问题
description: "故障排除 GitHub 导入问题，包括进程失败、缺少前缀和大型项目错误。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将项目从 GitHub 导入到极狐GitLab 时，您可能会遇到以下问题。

<a id="manually-continue-a-previously-failed-import-process"></a>

## 手动继续之前失败的导入进程

在某些情况下，GitHub 导入进程可能无法导入代码仓库。这会导致极狐GitLab 中止项目导入进程，需要手动导入代码仓库。管理员可以为失败的导入进程手动导入代码仓库：

1. 打开 Rails 控制台。
1. 在控制台中运行以下命令序列：

   ```ruby
   project_id = <PROJECT_ID>
   github_access_token =  <GITHUB_ACCESS_TOKEN>
   github_repository_path = '<GROUP>/<REPOSITORY>'

   github_repository_url = "https://#{github_access_token}@github.com/#{github_repository_path}.git"

   # Find project by ID
   project = Project.find(project_id)
   # Set import URL and credentials
   project.import_url = github_repository_url
   project.import_type = 'github'
   project.import_source = github_repository_path
   project.save!
   # Create an import state if the project was created manually and not from a failed import
   project.create_import_state if project.import_state.blank?
   # Set state to start
   project.import_state.force_start

   # Optional: If your import had certain optional stages selected or a timeout strategy
   # set, you can reset them here. Below is an example.
   # The params follow the format documented in the API:
   # https://docs.gitlab.com/api/import/#import-repository-from-github
   Gitlab::GithubImport::Settings
   .new(project)
   .write(
     timeout_strategy: "optimistic",
     optional_stages: {
       attachments_import: true,
       collaborators_import: true
     }
   )

   # Trigger import from second step
   Gitlab::GithubImport::Stage::ImportRepositoryWorker.perform_async(project.id)
   ```

<a id="import-fails-due-to-missing-prefix"></a>

## 因缺少前缀导致导入失败

您可能会收到错误信息 `Import failed due to a GitHub error: (HTTP 406)`。

出现此问题是因为路径前缀 `api/v3` 已从 GitHub 导入器中移除。这是因为导入器不再使用 `Gitlab::LegacyGithubImport::Client`。该客户端在从 GitHub Enterprise URL 导入时会自动添加 `api/v3` 前缀。

要变通解决此错误，请在从 GitHub Enterprise URL 导入时[添加 `api/v3` 前缀](https://gitlab.com/gitlab-org/gitlab/-/issues/438358#note_1978902725)。

<a id="errors-when-importing-large-projects"></a>

## 导入大型项目时的错误

GitHub 导入器在导入大型项目时可能会遇到一些错误。

<a id="missing-comments"></a>

### 缺少评论

GitHub API 存在限制，最多只能导入约 30,000 条评论或差异评论。达到此限制时，GitHub API 会返回以下错误：

```plaintext
In order to keep the API fast for everyone, pagination is limited for this resource. Check the rel=last link relation in the Link response header to see how far back you can traverse.
```

此错误仅可能发生在极狐GitLab 19.3 及更早版本的项目导入中，且未选择**使用替代评论导入方法**选项时。此错误不会发生在极狐GitLab 19.4 及更高版本中配置的项目导入，因为该方法始终启用。
