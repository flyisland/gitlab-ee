---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解文件路径模式、所有者、评论、区段，以及规则如何被评估。
title: '`CODEOWNERS` 文件的语法'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`CODEOWNERS` 文件使用一种语法来定义所有权规则。文件中的每一行代表一条规则，并指定一个文件路径模式和一个或多个所有者。关键元素包括：

- 文件路径：特定文件、目录或通配符。
- 代码所有者：使用提及来指定用户、群组或角色。
- 评论：以 `#` 开头的行会被忽略。不支持行内评论。
  评论中列出的任何代码所有者都会被解析。
- 区段：可选的规则分组，使用 `[Section name]` 定义。

> [!note]
> 如果某个条目在区段中重复出现，[则使用最后一个条目](advanced.md#define-code-owners-for-specific-files-or-directories)。文件中后面定义的规则优先于前面的规则。

以下是一些示例：

```plaintext
# Specify a default Code Owner for all files with a wildcard:
* @default-owner

# Specify multiple Code Owners to a specific file:
README.md @doc-team @tech-lead

# Specify a Code Owner to all files with a specific extension:
*.rb @ruby-owner

# Specify Code Owners with usernames or email addresses:
LICENSE @legal janedoe@gitlab.com

# Use group names to match groups and nested groups:
README @group @group/with-nested/subgroup

# Specify a Code Owner to a directory and all its contents:
/docs/ @all-docs
/docs/* @root-docs
/docs/**/*.md @markdown-docs  # Match specific file types in any subdirectory
/db/**/index.md @index-docs   # Match a specific file name in any subdirectory

# Use a section to group related rules:
[Documentation]
ee/docs    @docs
docs       @docs

# Assign a role as a Code Owner:
/config/ @@maintainer
```

<a id="sections"></a>

## 区段

在 `CODEOWNERS` 文件中，区段是单独分析的命名区域，并且始终强制执行。在您定义区段之前，极狐GitLab 会将整个 `CODEOWNERS` 文件视为单个区段。添加更多区段会改变极狐GitLab 评估该文件的方式：

- 极狐GitLab 会将[没有区段的条目](advanced.md#regular-entries-and-sections)（包括在第一个区段标题之前定义的规则）
  视为另一个未命名区段。
- 每个区段单独执行其规则。
- 当某个文件路径匹配一个区段中的多个条目时，只使用该区段中最后一个匹配的条目。
- 当某个文件路径匹配多个区段中的条目时，会使用每个区段中最后一个匹配的条目。

例如，在一个包含多个区段的 `CODEOWNERS` 文件中，这些区段定义了 `README` 文件的代码所有者：

```plaintext
* @admin

[README Owners]
README.md @user1 @user2
internal/README.md @user4

[README other owners]
README.md @user3
```

- 根目录中 `README.md`的代码所有者是：
  - `@admin`，来自未命名区段。
  - `@user1` 和 `@user2`，来自 `[README Owners]`。
  - `@user3`，来自 `[README other owners]`。
- `internal/README.md`的代码所有者是：
  - `@admin`，来自未命名区段。
  - `@user4`，来自 `[README Owners]`。该区段中的 `README.md` 和 `internal/README.md` 条目
    都匹配该文件，但只使用该区段中最后一个匹配的条目。
  - `@user3`，来自 `[README other owners]`。

要向 `CODEOWNERS` 文件添加区段，请在方括号中输入区段名称，后跟文件或目录，以及用户、群组或子群组：

```plaintext
[README Owners]
README.md @user1 @user2
internal/README.md @user2
```

合并请求小组件中的每个代码所有者都列在一个标记下。下图显示了 `Default`、`Frontend` 和 `Technical Writing` 区段：

![显示按区段分组的代码所有者的合并请求小组件。](img/sectional_code_owners_v17_4.png)

有关更多区段配置选项，请参阅：

- [默认代码所有者和可选区段](advanced.md#default-code-owners-and-optional-sections)
- [常规条目和区段](advanced.md#regular-entries-and-sections)
- [名称重复的区段](advanced.md#sections-with-duplicate-names)

<a id="section-headings-and-names"></a>

### 区段标题和名称

区段标题必须具有名称。区段名称不区分大小写，并且[名称重复的区段](advanced.md#sections-with-duplicate-names)会被合并。仅对于受保护分支，它们可以：

- 要求审批（默认）。
- 设为可选（以 `^` 为前缀）。
- 要求特定数量的审批。有关更多信息，请参阅[群组继承和资格](advanced.md#group-inheritance-and-eligibility)和[审批显示为可选](troubleshooting.md#approvals-shown-as-optional)。
- 包含默认所有者。

示例：

```plaintext
# Required section
[Section name]

# Optional section
^[Section name]

# Section requiring 5 approvals
[Section name][5]

# Section with @username as default owner
[Section name] @username

# Section with @group and @subgroup as default owners and requiring 2 approvals
[Section name][2] @group @subgroup
```

<a id="set-default-code-owner-for-a-section"></a>

### 为区段设置默认代码所有者

如果区段内的多个文件路径共享相同的所有权，请为该区段定义默认代码所有者。该区段中的所有路径都会继承此默认值，除非您在特定行上覆盖该区段默认值。

当未为文件路径指定特定所有者时，会应用默认所有者。在文件路径旁定义的特定所有者会覆盖默认所有者。

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

- `@docs-team` 拥有 `Documentation` 区段中的所有项。
- `@database-team` 和 `@agarcia` 拥有 `Database` 区段中的所有项，但
  `config/db/database-setup.md` 除外，它有一个覆盖设置将其分配给 `@docs-team`。

将此行为与[同时使用常规条目和区段](advanced.md#regular-entries-and-sections)时进行比较，此时区段中的条目不会覆盖没有区段的条目。

<a id="optional-sections"></a>

### 可选区段

您可以在代码所有者文件中指定可选区段。可选区段使您能够为代码库的各个部分指定负责方，但不要求他们审批。此方法为项目中频繁更新但不需要严格评审的部分提供了更宽松的策略。

要将整个区段视为可选，请在区段名称前加上脱字符 `^`。

在此示例中，`[Go]` 区段是可选的：

```plaintext
[Documentation]
*.md @root

[Ruby]
*.rb @root

^[Go]
*.go @root
```

可选代码所有者区段会显示在合并请求的描述下方：

![显示可选代码所有者区段的合并请求小组件。](img/optional_code_owners_sections_v17_4.png)

如果某个区段在文件中重复出现，且其中一个被标记为可选而另一个没有，则该区段为必需。

`CODEOWNERS` 文件中的可选区段仅在通过合并请求提交更改时才被视为可选。如果更改直接提交到受保护分支，则仍然需要代码所有者的审批，即使该区段被标记为可选。

<a id="eligible-code-owners"></a>

## 符合条件的代码所有者

资格规则决定谁可以成为有效的代码所有者。根据 `CODEOWNERS` 文件中的引用方式（用户名、群组或角色），适用不同的具体规则。

<a id="user-eligibility"></a>

### 用户资格

要通过用户名（`@username`）引用而成为符合条件的代码所有者，用户必须获得该项目的授权。适用以下规则：

- 项目和群组可见性设置不影响资格。
- [被群组禁止](../../group/moderate_users.md)的用户不能成为代码所有者。
- 符合条件的用户包括具有以下身份的用户：
  - 以开发者、维护者或所有者角色直接成为项目成员。
  - 是项目所属群组的成员（直接或继承）。
  - 是项目所属群组的任一上级群组的成员。
  - 是被邀请加入项目的群组的直接或继承成员。
  - 是被邀请加入项目所属群组的群组的直接成员（但不是继承成员）。
  - 是被邀请加入项目所属群组的上级群组的群组的直接成员（但不是继承成员）。

<a id="group-eligibility"></a>

### 群组资格

当使用群组名称（`@group_name`）或嵌套群组名称（`@nested/group/names`）引用群组时，适用以下规则：

- 群组可见性设置不影响资格。
- 只有被引用群组的直接成员才符合条件。不包括继承成员。
- 符合条件的群组包括：
  - 项目所属群组。
  - 项目所属群组的上级群组。
  - 以开发者、维护者或所有者角色直接邀请加入项目的群组。
  - 与项目所属群组或其上级群组共享的群组。
    该共享群组必须在父群组中具有开发者、维护者或所有者角色。
    有关更多信息，请参阅[与父群组共享的群组](advanced.md#groups-shared-with-parent-groups)。

<a id="role-eligibility"></a>

### 角色资格

当引用角色（`@@role`）时，适用以下规则：

- 只有开发者、维护者和所有者角色可以用作代码所有者。
- 只有具有指定角色的直接项目成员才符合条件。
- 角色不包含更高角色。例如，指定 `@@developer` 不包括
  具有维护者或所有者角色的用户。

有关复杂群组继承和资格的更多信息，请参阅[群组继承和资格](advanced.md#group-inheritance-and-eligibility)。

<a id="add-a-role-as-a-code-owner"></a>

## 添加角色作为代码所有者

您可以为直接项目成员添加或设置角色作为代码所有者：

- 使用 `@@` 前缀来设置角色。
- 只有开发者、维护者和所有者角色可用。
- 角色不包含更高角色。例如，指定 `@@developer`
  不包括具有维护者或所有者角色的用户。
- 只有具有指定角色的直接项目成员才是符合条件的代码所有者。
- 可以指定复数形式的角色。例如，`@@developers` 是可接受的。

以下示例将具有开发者或维护者角色的所有直接项目成员设置为 `file.md`的代码所有者：

1. 打开 `CODEOWNERS` 文件。
1. 使用以下模式添加一行：

   ```plaintext
   file.md @@developer @@maintainer
   ```

1. 保存文件。
1. 提交并合并更改。

<a id="add-a-group-as-a-code-owner"></a>

## 添加群组作为代码所有者

您可以将群组或子群组的直接成员设置为代码所有者。有关群组成员资格的更多信息，请参阅[成员资格类型](../members/_index.md#membership-types)。

先决条件：

- 该群组必须[被邀请加入项目](../members/sharing_projects_groups.md#invite-a-group-to-a-project)。

要将群组或子群组的直接成员设置为代码所有者：

1. 打开 `CODEOWNERS` 文件。
1. 输入符合以下模式之一的文本：

   ```plaintext
   # All direct group members as Code Owners for a file
   file.md @group-x

   # All direct subgroup members as Code Owners for a file
   file.md @group-x/subgroup-y

   # All direct group and direct subgroup members as Code Owners for a file
   file.md @group-x @group-x/subgroup-y
   ```

1. 保存文件。
1. 提交并合并更改。

<a id="example-configuration"></a>

### 示例配置

```plaintext
[Maintainers]
* @gitlab-org/maintainers/group-name
```

在此示例中：

- 群组 `group-name` 列在 `[Maintainers]` 区段下。
- `group-name` 包含以下直接成员：

  ![显示符合代码所有者资格的用户群组成员列表。](img/direct_group_members_v17_9.png)

- 在合并请求审批小组件中，相同的直接成员被列为 `Maintainers`：

  ![列出群组成员为维护者的合并请求审批小组件。](img/merge_request_maintainers_v17_9.png)

> [!note]
> 当启用[全局 SAML 群组成员资格锁定](../../group/saml_sso/group_sync.md#global-saml-group-memberships-lock)时，
> 您无法将群组或子群组设置为代码所有者。
> 有关更多信息，请参阅[与全局 SAML 群组成员资格锁定不兼容](troubleshooting.md#incompatibility-with-global-group-memberships-locks)。

如果您遇到问题，请参阅[用户未显示为可能的审批人](troubleshooting.md#user-not-shown-as-possible-approver)。

<a id="path-matching"></a>

## 路径匹配

路径可以是绝对路径、相对路径、目录、通配符或 globstar，并且会针对代码仓库根目录进行匹配。

<a id="absolute-paths"></a>

### 绝对路径

以 `/` 开头的路径从代码仓库根目录开始匹配：

```plaintext
# Matches only README.md in the root.
/README.md

# Matches only README.md inside the /docs directory.
/docs/README.md
```

<a id="relative-paths"></a>

### 相对路径

不带前导 `/` 的路径被视为 [globstar 路径](#globstar-paths)：

```plaintext
# Matches /README.md, /internal/README.md, /app/lib/README.md
README.md @username

# Matches /internal/README.md, /docs/internal/README.md, /docs/api/internal/README.md
internal/README.md
```

> [!note]
> 使用 globstar 路径时，请注意意外的匹配。
> 例如，不带前导 `/` 的 `README.md` 会匹配代码仓库中
> 任何目录或子目录中的任何 `README.md` 文件。

<a id="directory-paths"></a>

### 目录路径

以 `/` 结尾的路径会匹配该目录及其子目录中的所有文件：

```plaintext
# Matches all files in /docs/ and its subdirectories
/docs/
```

<a id="wildcard-paths"></a>

### 通配符路径

使用 `*` 匹配多个字符：

```plaintext
# Any markdown files in the docs directory
/docs/*.md @username

# /docs/index file of any filetype
# For example: /docs/index.md, /docs/index.html, /docs/index.xml
/docs/index.* @username

# Any file in the docs directory with 'spec' in the name.
# For example: /docs/qa_specs.rb, /docs/spec_helpers.rb, /docs/runtime.spec
/docs/*spec* @username

# README.md files one level deep within the docs directory
# For example: /docs/api/README.md
/docs/*/README.md @username
```

<a id="globstar-paths"></a>

### Globstar 路径

使用 `**` 匹配跨多个目录层级的文件或模式：

```plaintext
# For example: /docs/index.md, /docs/api/index.md, and /docs/api/graphql/index.md.
/docs/**/index.md
```

要匹配目录中的所有文件，请使用带尾部斜杠（`/`）的[目录路径](#directory-paths)。

<a id="exclusion-patterns"></a>

### 排除模式

在文件或路径前加上 `!`，可使其免于或排除在需要代码所有者审批的范围之外。排除项在其所在区段中生效。在以下示例中：

- `pom.xml` 排除项适用于默认区段。
- `/config/**/*.rb` 排除项仅影响 Ruby 区段中的 Ruby 文件。

```plaintext
# All files require approval from @username
* @username

# Except pom.xml which needs no approval
!pom.xml

[Ruby]
# All ruby files require approval from @ruby-team
*.rb @ruby-team

# Except Ruby files in the config directory
!/config/**/*.rb
```

以下准则说明了排除模式的行为方式：

- 排除项在其所在区段中按顺序评估。例如：

  ```plaintext
  * @default-owner
  !*.rb                      # Excludes all Ruby files.
  /special/*.rb @ruby-owner  # This won't take effect as *.rb is already excluded.
  ```

- 某个模式被排除后，就不能在同一区段中再次被包含：

  ```plaintext
  [Ruby]
  *.rb @ruby-team           # All Ruby files need Ruby team approval.
  !/config/**/*.rb          # Ruby files in config don't need Ruby team approval.
  /config/routes.rb @ops    # This won't take effect as config Ruby files are excluded.
  ```

- 匹配排除模式的文件在该区段中不需要代码所有者审批。
  如果您需要为不同的所有者设置不同的排除项，请使用多个区段：

  ```plaintext
  [Ruby]
  *.rb @ruby-team
  !/config/**/*.rb        # Config Ruby files don't need Ruby team approval.

  [Config]
  /config/ @ops-team      # Config files still require ops-team approval.
  ```

- 对自动更新的文件使用排除项：

  ```plaintext
  * @default-owner

  # Files updated by automation don't need approval.
  !package-lock.json
  !yarn.lock
  !**/generated/          # Any files in generated directories.
  !.gitlab-ci.yml
  ```

<a id="entry-owners"></a>

## 条目所有者

条目必须具有一个或多个所有者。这些所有者可以是群组、子群组和用户。

```plaintext
/path/to/entry.rb @group
/path/to/entry.rb @group/subgroup
/path/to/entry.rb @user
/path/to/entry.rb @group @group/subgroup @user
```

有关将群组添加为代码所有者的更多信息，请参阅[添加群组作为代码所有者](#add-a-group-as-a-code-owner)。
