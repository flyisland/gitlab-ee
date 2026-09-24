---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 保留的项目和群组名称
description: Naming conventions, restrictions, and reserved names.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为避免与极狐GitLab 使用的现有路由冲突，某些词语不能用作项目或群组名称。
这些词语列在 [`path_regex.rb` 文件](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/path_regex.rb) 中，其中：

- `TOP_LEVEL_ROUTES` 是保留为用户名或顶级群组的名称。
- `PROJECT_WILDCARD_ROUTES` 是保留给子群组或项目的名称。
- `GROUP_ROUTES` 是保留给所有群组或项目的名称。

<a id="rules-for-usernames-project-and-group-names-and-slugs"></a>

## 用户名、项目和群组名称及别名的规则

用户名必须以字母 (`a-zA-Z`) 或数字 (`0-9`) 开头和结尾。
例如，以下用户名满足这些条件：

- `A_Garcia`
- `a_garcia_1`

此外，用户名和群组名称只能包含字母 (`a-zA-Z`)、数字 (`0-9`)、表情符号、下划线 (`_`)、点 (`.`)、括号 (`()`)、破折号 (`-`) 或空格。例如：

- 有效用户名：`sidney.jones` 或 `sidney ⭐ jones`
- 有效群组名称：`Web Development Team (Frontend)`

项目名称只能包含字母 (`a-zA-Z`)、数字 (`0-9`)、表情符号、下划线 (`_`)、点 (`.`)、加号 (`+`)、破折号 (`-`) 或空格。例如：

- `web-app-v2+features`
- `web-analytics-dashboard`
- `Backend API Service 🚀`

用户名以及项目或群组别名：

- 必须以字母 (`a-zA-Z`) 或数字 (`0-9`) 开头和结尾。
- 不得包含连续的特殊字符。
- 不能以 `.git` 或 `.atom` 结尾。
- 只能包含字母 (`a-zA-Z`)、数字 (`0-9`)、下划线 (`_`)、点 (`.`) 或破折号 (`-`)。

有效用户名别名示例：

- `dev_user_1`
- `zhang.wei-2024`
- `maria.lopez`

有效项目别名示例：

- `api.service.v2`
- `user_management_portal`
- `docs_site_v3`

有效群组别名示例：

- `marketing-team-2024`
- `backend.services`
- `mobile-dev-team`

<a id="reserved-project-names"></a>

## 保留的项目名称

你不能使用以下名称创建项目：

- `\-`
- `badges`
- `blame`
- `blob`
- `builds`
- `commits`
- `create`
- `create_dir`
- `edit`
- `environments/folders`
- `files`
- `find_file`
- `gitlab-lfs/objects`
- `info/lfs/objects`
- `new`
- `preview`
- `raw`
- `refs`
- `tree`
- `update`
- `wikis`

<a id="reserved-group-names"></a>

## 保留的群组名称

你不能使用以下名称创建群组，因为它们是为顶级群组保留的：

- `\-`
- `.well-known`
- `404.html`
- `422.html`
- `500.html`
- `502.html`
- `503.html`
- `admin`
- `api`
- `apple-touch-icon.png`
- `assets`
- `dashboard`
- `deploy.html`
- `explore`
- `favicon.ico`
- `favicon.png`
- `files`
- `groups`
- `health_check`
- `help`
- `import`
- `jwt`
- `login`
- `oauth`
- `profile`
- `projects`
- `public`
- `robots.txt`
- `s`
- `search`
- `sitemap`
- `sitemap.xml`
- `sitemap.xml.gz`
- `slash-command-logo.png`
- `snippets`
- `unsubscribes`
- `uploads`
- `users`
- `v2`

你不能使用以下名称创建子群组：

- `\-`

