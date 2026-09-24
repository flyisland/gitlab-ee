---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Agent 工具
---

<!-- markdownlint-disable MD044 -->

<a id="tools-available-in-the-web-ui-and-ide"></a>

## 在 Web UI 和 IDE 中可用的工具

| 名称 | 工具 | 描述 |
|------|------|-------------|
| 添加新任务 | `add_new_task` | 添加一个任务。 |
| 构建审查合并请求上下文 | `build_review_merge_request_context` | 构建用于代码审查的全面合并请求上下文。 |
| CI Linter | `ci_linter` | 根据 CI/CD 语法规则验证 CI/CD YAML 配置。 |
| 确认漏洞 | `confirm_vulnerability` | 将项目中的漏洞状态更改为 `CONFIRMED`。 |
| 创建提交 | `create_commit` | 在代码仓库中创建包含多个文件操作的提交。 |
| 创建史诗 | `create_epic` | 在群组中创建史诗。 |
| 创建议题 | `create_issue` | 在项目中创建议题。 |
| 创建议题评论 | `create_issue_note` | 向议题添加评论。 |
| 创建合并请求 | `create_merge_request` | 在项目中创建合并请求。 |
| 创建合并请求评论 | `create_merge_request_note` | 向合并请求添加评论。不支持快捷操作。 |
| 创建计划 | `create_plan` | 创建任务列表。 |
| 创建漏洞议题 | `create_vulnerability_issue` | 创建链接到项目中安全漏洞的议题。 |
| 创建工作项 | `create_work_item` | 在群组或项目中创建工作项。不支持快捷操作。 |
| 创建工作项评论 | `create_work_item_note` | 向工作项添加评论。不支持快捷操作。 |
| 忽略漏洞 | `dismiss_vulnerability` | 忽略项目中的安全漏洞。 |
| 从文本中提取行 | `extract_lines_from_text` | 从文本中提取特定行。 |
| 获取提交 | `get_commit` | 从项目中获取一个提交。 |
| 获取提交评论 | `get_commit_comments` | 获取项目中一个提交的评论。 |
| 获取提交差异 | `get_commit_diff` | 获取项目中一个提交的差异。 |
| 获取当前用户 | `get_current_user` | 获取当前用户的以下信息：用户名、职位和首选语言。 |
| 获取史诗 | `get_epic` | 获取群组中的一个史诗。 |
| 获取史诗评论 | `get_epic_note` | 从一个史诗获取评论。 |
| 获取议题 | `get_issue` | 从项目中获取一个议题。 |
| 获取议题评论 | `get_issue_note` | 从一个议题获取评论。 |
| 获取作业日志 | `get_job_logs` | 获取作业的追踪信息。 |
| 获取合并请求 | `get_merge_request` | 获取合并请求的详细信息。 |
| 获取流水线错误 | `get_pipeline_errors` | 从合并请求的最新流水线中获取失败作业的日志。 |
| 获取流水线失败作业 | `get_pipeline_failing_jobs` | 获取流水线中失败作业的 ID。 |
| 获取计划 | `get_plan` | 获取任务列表。 |
| 获取前一会话上下文 | `get_previous_session_context` | 从前一会话获取上下文。 |
| 获取项目 | `get_project` | 获取项目的详细信息。 |
| 获取代码仓库文件 | `get_repository_file` | 从远程代码仓库获取文件内容。 |
| 获取安全发现详情 | `get_security_finding_details` | 通过 ID 和识别该漏洞的流水线扫描 ID 获取潜在漏洞的详细信息。 |
| 获取漏洞详情 | `get_vulnerability_details` | 获取指定 ID 漏洞的以下信息：基本漏洞信息、位置详情、CVE 丰富数据、检测流水线信息以及详细的漏洞报告数据。 |
| 获取 Wiki 页面 | `get_wiki_page` | 从项目或群组获取一个 Wiki 页面，包括所有评论。 |
| 获取工作项 | `get_work_item` | 从群组或项目获取工作项。 |
| 获取工作项评论 | `get_work_item_notes` | 获取一个工作项的所有评论。 |
| 极狐GitLab API 获取 | `gitlab_api_get` | 向任何 REST API 端点发起只读 GET 请求。 |
| 极狐GitLab Blob 搜索 | `gitlab_blob_search` | 在群组、项目或实例中搜索文件内容。要在群组或实例中搜索，你必须启用 [高级](../../../integration/advanced_search/elasticsearch.md#enable-code-search-with-advanced-search) 或 [精确代码](../../../integration/zoekt/_index.md#enable-exact-code-search) 搜索。 |
| 极狐GitLab 提交搜索 | `gitlab_commit_search` | 在项目或群组中搜索提交。 |
| 极狐GitLab 文档搜索 | `gitlab_documentation_search` | 搜索极狐GitLab 文档以获取信息。 |
| 极狐GitLab GraphQL | `gitlab_graphql` | 针对 GraphQL API 执行只读 GraphQL 查询。 |
| 极狐GitLab 群组项目搜索 | `gitlab_group_project_search` | 在群组中搜索项目。 |
| 极狐GitLab 议题搜索 | `gitlab_issue_search` | 在项目或群组中搜索议题。 |
| 极狐GitLab 合并请求搜索 | `gitlab_merge_request_search` | 在项目或群组中搜索合并请求。 |
| 极狐GitLab 里程碑搜索 | `gitlab_milestone_search` | 在项目或群组中搜索里程碑。 |
| 极狐GitLab 评论搜索 | `gitlab_note_search` | 在项目中搜索评论。 |
| 极狐GitLab 用户搜索 | `gitlab__user_search` | 在项目或群组中搜索用户。 |
| 极狐GitLab Wiki Blob 搜索 | `gitlab_wiki_blob_search` | 在项目或群组中搜索 Wiki 内容。 |
| 将漏洞链接到议题 | `link_vulnerability_to_issue` | 将议题链接到项目中的安全漏洞。 |
| 将漏洞链接到合并请求 | `link_vulnerability_to_merge_request` | 使用 GraphQL 将安全漏洞链接到项目中的合并请求。 |
| 列出所有合并请求评论 | `list_all_merge_request_notes` | 列出合并请求上的所有评论。 |
| 列出提交 | `list_commits` | 列出项目中的提交。 |
| 列出史诗评论 | `list_epic_notes` | 列出一个史诗的所有评论。 |
| 列出史诗 | `list_epics` | 列出一个群组及其子群组的所有史诗。 |
| 列出群组审计事件 | `list_group_audit_events` | 列出一个群组的审计事件。你必须拥有所有者角色才能访问群组审计事件。 |
| 列出实例审计事件 | `list_instance_audit_events` | 列出实例级别的审计事件。你必须是管理员才能查看实例审计事件。 |
| 列出议题评论 | `list_issue_notes` | 列出一个议题的所有评论。 |
| 列出议题 | `list_issues` | 列出项目中的所有议题。 |
| 列出合并请求差异 | `list_merge_request_diffs` | 列出合并请求中已更改文件的差异。 |
| 列出项目审计事件 | `list_project_audit_events` | 列出一个项目的审计事件。你必须拥有所有者角色才能访问项目审计事件。 |
| 列出代码仓库树 | `list_repository_tree` | 列出代码仓库中的文件和目录。 |
| 列出安全发现 | `list_security_findings` | 列出特定流水线安全扫描的临时安全发现。 |
| 列出漏洞 | `list_vulnerabilities` | 列出项目中的安全漏洞。 |
| 列出工作项 | `list_work_items` | 列出项目或群组中的工作项。 |
| 发布极狐GitLab Duo 代码审查 | `post_duo_code_review` | 向合并请求发布极狐GitLab Duo 代码审查。 |
| 发布 SAST 误报分析结果到极狐GitLab | `post_sast_fp_analysis_to_gitlab` | 发布 SAST 误报检测分析结果。 |
| 移除任务 | `remove_task` | 从任务列表中移除一个任务。 |
| 恢复为已检测漏洞 | `revert_to_detected_vulnerability` | 将漏洞状态恢复为 `detected`。 |
| 运行 GLQL 查询 | `run_glql_query` | 执行针对工作项、史诗和合并请求的 GLQL 查询。 |
| 运行测试 | `run_tests` | 为任何语言或框架执行测试命令。 |
| 设置任务状态 | `set_task_status` | 设置任务的状态。 |
| 更新史诗 | `update_epic` | 更新群组中的一个史诗。 |
| 更新议题 | `update_issue` | 更新项目中的一个议题。 |
| 更新合并请求 | `update_merge_request` | 更新一个合并请求。你可以更改目标分支、编辑标题，甚至关闭合并请求。 |
| 更新任务描述 | `update_task_description` | 更新任务的描述。 |
| 更新漏洞严重性 | `update_vulnerability_severity` | 更新项目中漏洞的严重性级别。 |
| 更新工作项 | `update_work_item` | 更新群组或项目中的现有工作项。不支持快捷操作。 |

<a id="tools-available-in-the-ide-only"></a>

## 仅在 IDE 中可用的工具

| 名称 | 工具 | 描述 |
|------|------|-------------|
| 创建文件并写入内容 | `create_file_with_contents` | 创建一个文件并向其中写入内容。 |
| 编辑文件 | `edit_file` | 编辑现有文件。 |
| 查找文件 | `find_files` | 递归地在项目中查找文件。 |
| Grep | `grep` | 递归地在文件中搜索文本模式。该工具遵循 `.gitignore` 文件规则。 |
| 列出目录 | `list_dir` | 列出相对于项目根目录的目录中的文件。 |
| 创建目录 | `mkdir` | 在当前工作树中创建一个目录。 |
| 读取文件 | `read_file` | 读取文件内容。 |
| 读取多个文件 | `read_files` | 读取多个文件的内容。 |
| 运行命令 | `run_command` | 在当前工作目录中运行 bash 命令。不支持 Git 命令。 |
| 运行 Git 命令 | `run_git_command` | 在当前工作目录中运行 Git 命令。 |