---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn about file path patterns, owners, comments, sections, and how rules are evaluated.
title: CODEOWNERS 文件语法
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`CODEOWNERS` 文件使用一种语法来定义所有权规则。
文件中的每一行都代表一条规则，并指定一个文件路径模式以及一个或多个所有者。
关键元素包括：

- 文件路径：具体的文件、目录或通配符。
- 代码所有者：使用提及用户、群组或角色的方式。
- 注释：以 `#` 开头的行会被忽略。不支持行内注释。
  任何在注释中列出的代码所有者都会被解析。
- 章节：可选的规则分组，使用 `[章节名称]` 定义。

> [!note]
> 如果某个条目在一个章节中重复出现，[将使用最后出现的条目](advanced.md#define-code-owners-for-specific-files-or-directories)。文件中后面定义的规则优先于前面的规则。

下面是一些示例：

```plaintext
# 使用通配符为所有文件指定默认代码所有者：
* @default-owner

# 为一个特定文件指定多个代码所有者：
README.md @doc-team @tech-lead

# 为具有特定扩展名的所有文件指定代码所有者：
*.rb @ruby-owner

# 使用用户名或电子邮件地址指定代码所有者：
LICENSE @legal janedoe@gitlab.com

# 使用群组名称来匹配群组和嵌套子群组：
README @group @group/with-nested/subgroup

# 为一个目录及其所有内容指定代码所有者：
/docs/ @all-docs
/docs/* @root-docs
/docs/**/*.md @markdown-docs  # 匹配任何子目录中的特定文件类型
/db/**/index.md @index-docs   # 匹配任何子目录中的特定文件名

# 使用章节来分组相关规则：
[Documentation]
ee/docs    @docs
docs       @docs

# 将角色指派为代码所有者：
/config/ @@maintainer
```

## 章节

在 `CODEOWNERS` 文件中，章节是被分别分析并始终强制执行的命名区域。在你定义一个章节之前，极狐GitLab 会将你的整个 `CODEOWNERS` 文件视为一个单一的章节。
添加更多章节会改变极狐GitLab 评估文件的方式：

- 极狐GitLab 将[没有章节的条目](advanced.md#regular-entries-and-sections)，包括在第一个章节标题之前定义的规则，视为另一个未命名的章节。
- 每个章节分别强制执行其规则。
- 当一个文件路径匹配某个章节中的多个条目时，只使用该章节中最后一个匹配的条目。
- 当一个文件路径匹配多个章节中的条目时，将使用每个章节中最后一个匹配的条目。

例如，在一个定义了 `README` 文件代码所有者的、包含章节的 `CODEOWNERS` 文件中：

```plaintext
* @admin

[README Owners]
README.md @user1 @user2
internal/README.md @user4

[README other owners]
README.md @user3
```

- 根目录中 `README.md` 的代码所有者是：
  - `@admin`，来自未命名章节。
  - `@user1` 和 `@user2`，来自 `[README Owners]`。
  - `@user3`，来自 `[README other owners]`。
- `internal/README.md` 的代码所有者是：
  - `@admin`，来自未命名章节。
  - `@user4`，来自 `[README Owners]`。该章节中的 `README.md` 和 `internal/README.md` 条目都匹配该文件，但只使用该章节中最后一个匹配的条目。
  - `@user3`，来自 `[README other owners]`。

要向 `CODEOWNERS` 文件添加一个章节，请输入一个用方括号括起来的章节名称，后面跟着文件或目录，以及用户、群组或子群组：

```plaintext
[README Owners]
README.md @user1 @user2
internal/README.md @user2
```

合并请求组件中的每个代码所有者都列在一个标签下。
下图显示了 `Default`、`Frontend` 和 `Technical Writing` 章节：

![合并请求组件按章节显示代码所有者分组。](img/sectional_code_owners_v17_4.png)

更多章节配置选项，请参见：

- [默认代码所有者和可选章节](advanced.md#default-code-owners-and-optional-sections)
- [常规条目和章节](advanced.md#regular-entries-and-sections)
- [具有重复名称的章节](advanced.md#sections-with-duplicate-names)

### 章节标题和名称

章节标题必须有一个名称。
章节名称不区分大小写，并且[具有重复名称的章节](advanced.md#sections-with-duplicate-names)会被合并。
仅对于受保护分支，它们可以：

- 要求审批（默认）。
- 是可选的（以 `^` 为前缀）。
- 要求特定数量的审批。更多信息，请参见[群组继承和资格](advanced.md#group-inheritance-and-eligibility)和[显示为可选的审批](troubleshooting.md#approvals-shown-as-optional)。
- 包含默认所有者。

示例：

```plaintext
# 必选章节
[Section name]

# 可选章节
^[Section name]

# 要求 5 个审批的章节
[Section name][5]

# 将 @username 作为默认所有者的章节
[Section name] @username

# 将 @group 和 @subgroup 作为默认所有者并要求 2 个审批的章节
[Section name][2] @group @subgroup
```

### 为章节设置默认代码所有者

如果一个章节内的多个文件路径共享相同的所有权，可以为该章节定义默认代码所有者。
该章节中的所有路径都会继承此默认设置，除非你在特定行上覆盖了章节默认值。

当没有为文件路径指定特定所有者时，将应用默认所有者。
在文件路径旁边定义的特定所有者会覆盖默认所有者。

例如：

```plaintext
[Documentation] @docs-team
docs/
README.md

[Database] @database-team @agarcia
model/db/
config/db/database-setup.md @docs-team
```

在此示例中：

- `@docs-team` 拥有 `Documentation` 章节中的所有项目。
- `@database-team` 和 `@agarcia` 拥有 `Database` 章节中的所有项目，除了 `config/db/database-setup.md`，它有一个覆盖项，将其分配给了 `@docs-team`。

将此行为与[一起使用常规条目和章节](advanced.md#regular-entries-and-sections)时的行为进行比较，在那种情况下，章节中的条目不会覆盖没有章节的条目。

### 可选章节

你可以在你的代码所有者文件中指定可选章节。
可选章节使你能够为代码库的各个部分指定负责方，但不需要他们审批。这种方法为项目中那些频繁更新但不需要严格审查的部分提供了一种更宽松的策略。

要将整个章节视为可选，请在章节名称前面加上脱字符 `^`。

在此示例中，`[Go]` 章节是可选的：

```plaintext
[Documentation]
*.md @root

[Ruby]
*.rb @root

^[Go]
*.go @root
```

可选代码所有者章节显示在合并请求的描述下方：

![合并请求组件显示可选代码所有者章节。](img/optional_code_owners_sections_v17_4.png)

如果一个章节在文件中重复出现，并且其中一个被标记为可选而另一个没有，则该章节是必选的。

只有当通过合并请求提交更改时，`CODEOWNERS` 文件中的可选章节才被视为可选。如果更改直接提交到受保护分支，则仍然需要代码所有者的审批，即使该章节被标记为可选。

## 合格的代码所有者

资格规则决定了谁可以成为有效的代码所有者。具体规则取决于 `CODEOWNERS` 文件中的引用方式：用户名、群组或角色。

### 用户资格

要成为合格的代码所有者，通过其用户名 (`@username`) 引用的用户必须被授权访问该项目。以下规则适用：

- 项目和群组的可见性设置不影响资格。
- [被禁止加入群组的用户](../../group/moderate_users.md)不能成为代码所有者。
- 合格用户包括：
  - 具有开发者、维护者或所有者角色的项目直接成员。
  - 项目所在群组的成员（直接或继承）。
  - 项目所在群组的任何父级群组的成员。
  - 已被邀请加入该项目的群组的直接或继承成员。
  - 已被邀请加入该项目所在群组的群组的直接成员（但不是继承成员）。
  - 已被邀请加入该项目所在群组的父级群组的群组的直接成员（但不是继承成员）。

### 群组资格

当使用群组名称 (`@group_name`) 或嵌套群组名称 (`@nested/group/names`) 引用群组时，适用以下规则：

- 群组可见性设置不影响资格。
- 只有被引用群组的直接成员才有资格。继承成员不包括在内。
- 合格群组包括：
  - 项目所在的群组。
  - 项目所在群组的父级群组。
  - 以开发者、维护者或所有者角色直接邀请加入项目的群组。
  - 与项目所在群组或其父级群组共享的群组。
    共享群组必须在父级群组中拥有开发者、维护者或所有者角色。
    更多信息，请参见[与父级群组共享的群组](advanced.md#groups-shared-with-parent-groups)。

### 角色资格

当引用角色 (`@@role`) 时，适用以下规则：

- 只有开发者、维护者和所有者角色可以用作代码所有者。
- 只有具有指定角色的直接项目成员才有资格。
- 角色不包括更高级别的角色。例如，指定 `@@developer` 不包括具有维护者或所有者角色的用户。

有关复杂的群组继承和资格的更多信息，
请参见[群组继承和资格](advanced.md#group-inheritance-and-eligibility)。

## 添加角色作为代码所有者

{{< history >}}

- 在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/282438) [带有功能标志](../../../administration/feature_flags/_index.md) 名为 `codeowner_role_approvers`。
- 在极狐GitLab 17.8 中[在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/497504)。
- 在极狐GitLab 17.9 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/512623) 功能标志 `codeowner_role_approvers` 移除。

{{< /history >}}

你可以为直接项目成员添加或设置一个角色作为代码所有者：

- 使用 `@@` 前缀来设置角色。
- 只有开发者、维护者和所有者角色可用。
- 角色不包括更高级别的角色。例如，指定 `@@developer` 不包括具有维护者或所有者角色的用户。
- 只有具有指定角色的直接项目成员是合格的代码所有者。
- 可以指定复数角色。例如，接受 `@@developers`。

以下示例将所有具有开发者或维护者角色的直接项目成员设置为 `file.md` 的代码所有者：

1. 打开 `CODEOWNERS` 文件。
1. 使用以下模式添加一行：

   ```plaintext
   file.md @@developer @@maintainer
   ```

1. 保存文件。
1. 提交并合并更改。

## 添加群组作为代码所有者

你可以将群组或子群组的直接成员设置为代码所有者。
有关分组成员资格的更多信息，请参见[成员资格类型](../members/_index.md#membership-types)。

先决条件：

- 必须已[邀请群组加入项目](../members/sharing_projects_groups.md#invite-a-group-to-a-project)。

要将群组或子群组的直接成员设置为代码所有者：

1. 打开 `CODEOWNERS` 文件。
1. 输入遵循以下模式之一的文本：

   ```plaintext
   # 所有直接群组成员作为文件的代码所有者
   file.md @group-x

   # 所有直接子群组成员作为文件的代码所有者
   file.md @group-x/subgroup-y

   # 所有直接群组和直接子群组成员作为文件的代码所有者
   file.md @group-x @group-x/subgroup-y
   ```

1. 保存文件。
1. 提交并合并更改。

### 配置示例

```plaintext
[Maintainers]
* @gitlab-org/maintainers/group-name
```

在此示例中：

- 群组 `group-name` 列在 `[Maintainers]` 章节下。
- `group-name` 包含以下直接成员：

  ![群组成员列表显示有资格成为代码所有者的用户。](img/direct_group_members_v17_9.png)

- 在合并请求审批组件中，相同的直接成员被列为 `Maintainers`：

  ![合并请求审批组件将群组成员列为维护者。](img/merge_request_maintainers_v17_9.png)

> [!note]
> 当启用了[全局 SAML 分组成员身份锁定](../../group/saml_sso/group_sync.md#global-saml-group-memberships-lock)时，你不能将群组或子群组设置为代码所有者。
> 更多信息，请参见[与全局 SAML 分组成员身份锁定的不兼容性](troubleshooting.md#incompatibility-with-global-group-memberships-locks)。

如果你遇到问题，请参见[用户未显示为可能的审批者](troubleshooting.md#user-not-shown-as-possible-approver)。

## 路径匹配

路径可以是绝对路径、相对路径、目录路径、通配符路径或 globstar 路径，并且会与仓库根目录进行匹配。

### 绝对路径

以 `/` 开头的路径从仓库根目录开始匹配：

```plaintext
# 仅匹配根目录中的 README.md。
/README.md

# 仅匹配 /docs 目录中的 README.md。
/docs/README.md
```

### 相对路径

没有前导 `/` 的路径被视为 [globstar 路径](#globstar-paths)：

```plaintext
# 匹配 /README.md, /internal/README.md, /app/lib/README.md
README.md @username

# 匹配 /internal/README.md, /docs/internal/README.md, /docs/api/internal/README.md
internal/README.md
```

> [!note]
> 使用 globstar 路径时，注意意外的匹配。
> 例如，没有前导 `/` 的 `README.md` 会匹配仓库任何目录或子目录中的任何 `README.md` 文件。

### 目录路径

以 `/` 结尾的路径会匹配该目录及其子目录中的所有文件：

```plaintext
# 匹配 /docs/ 及其子目录中的所有文件
/docs/
```

### 通配符路径

使用 `*` 来匹配多个字符：

```plaintext
# docs 目录中的任何 markdown 文件
/docs/*.md @username

# /docs/index 文件，无论其文件类型
# 例如：/docs/index.md, /docs/index.html, /docs/index.xml
/docs/index.* @username

# docs 目录中名称包含 'spec' 的任何文件。
# 例如：/docs/qa_specs.rb, /docs/spec_helpers.rb, /docs/runtime.spec
/docs/*spec* @username

# docs 目录下一级的 README.md 文件
# 例如：/docs/api/README.md
/docs/*/README.md @username
```

### Globstar 路径

使用 `**` 来匹配跨多个目录级别的文件或模式：

```plaintext
# 例如：/docs/index.md, /docs/api/index.md, 和 /docs/api/graphql/index.md.
/docs/**/index.md
```

要匹配目录中的所有文件，
请使用带有尾部斜杠 (`/`) 的[目录路径](#directory-paths)。

### 排除模式

{{< history >}}

- 在极狐GitLab 17.10 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/180162) [带有功能标志](../../../administration/feature_flags/_index.md) 名为 `codeowners_file_exclusions`。
- 在极狐GitLab 17.10 中[在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/517075)。
- 在极狐GitLab 17.11 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/517309)。功能标志 `codeowners_file_exclusions` 移除。

{{< /history >}}

在文件或路径前加上 `!` 可以将其豁免或排除，使其不需要代码所有者审批。
排除项在其所在的章节中生效。在以下示例中：

- `pom.xml` 排除项适用于默认章节。
- `/config/**/*.rb` 排除项只影响 Ruby 章节中的 Ruby 文件。

```plaintext
# 所有文件都需要 @username 审批
* @username

# 除了 pom.xml，它不需要审批
!pom.xml

[Ruby]
# 所有 ruby 文件都需要 @ruby-team 审批
*.rb @ruby-team

# 除了 config 目录中的 Ruby 文件
!/config/**/*.rb
```

以下指南解释了排除模式的行为方式：

- 排除项在其所在的章节中按顺序进行评估。例如：

  ```plaintext
  * @default-owner
  !*.rb                      # 排除所有 Ruby 文件。
  /special/*.rb @ruby-owner  # 这不会生效，因为 *.rb 已经被排除了。
  ```

- 在某个模式被排除后，它不能再在同一章节中被包含：

  ```plaintext
  [Ruby]
  *.rb @ruby-team           # 所有 Ruby 文件都需要 Ruby 团队审批。
  !/config/**/*.rb          # config 目录中的 Ruby 文件不需要 Ruby 团队审批。
  /config/routes.rb @ops    # 这不会生效，因为 config 目录的 Ruby 文件已被排除。
  ```

- 匹配排除模式的文件在该章节中不需要代码所有者审批。
  如果你需要为不同的所有者设置不同的排除项，请使用多个章节：

  ```plaintext
  [Ruby]
  *.rb @ruby-team
  !/config/**/*.rb        # Config 目录中的 Ruby 文件不需要 Ruby 团队审批。

  [Config]
  /config/ @ops-team      # Config 文件仍然需要 ops-team 审批。
  ```

- 对自动更新的文件使用排除项：

  ```plaintext
  * @default-owner

  # 由自动化更新文件不需要审批。
  !package-lock.json
  !yarn.lock
  !**/generated/          # 任何 generated 目录中的文件。
  !.gitlab-ci.yml
  ```

## 条目所有者

条目必须有一个或多个所有者。这些可以是群组、子群组和用户。

```plaintext
/path/to/entry.rb @group
/path/to/entry.rb @group/subgroup
/path/to/entry.rb @user
/path/to/entry.rb @group @group/subgroup @user
```

有关将群组添加为代码所有者的更多信息，请参见[添加群组作为代码所有者](#add-a-group-as-a-code-owner)。

## 相关主题

- [代码所有者](_index.md)
- [高级 `CODEOWNERS` 配置](advanced.md)
- [合并请求审批](../merge_requests/approvals/_index.md)
- [受保护分支](../repository/branches/protected.md)
- [排查代码所有者问题](troubleshooting.md)