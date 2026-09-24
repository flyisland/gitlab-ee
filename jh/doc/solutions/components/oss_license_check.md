---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Guide to setting up OSS license compliance in GitLab, including dependency scanning, approval policies, and keeping license lists up to date.
title: OSS 许可证检测
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

## 入门

### 下载方案组件

1. 从您的客户团队获取邀请码。
1. 使用您的邀请码，从[方案组件商店](https://cloud.gitlab-accelerator-marketplace.com)下载方案组件。

## OSS 库许可证检测 - 极狐GitLab 策略

本指南将帮助您根据 Blue Oak Council 许可证评级，为您的项目实现一个许可证合规策略。该策略将自动要求对任何使用了不在 Blue Oak Council 的 Gold、Silver 和 Bronze 等级中包含的许可证的依赖项进行审批。

您还可以使用提供的 Python 脚本 `update_licenses.py` 来[保持您的许可证列表为最新版本](#keeping-your-license-list-up-to-date)，该脚本会获取最新批准的许可证。

## 概览

OSS 库许可证检测提供：

- 对您项目中所有依赖项的自动化许可证扫描
- 预配置的策略，以允许被 Blue Oak Council 评为 [Gold](https://blueoakcouncil.org/list#gold)、[Silver](https://blueoakcouncil.org/list#silver) 和 [Bronze](https://blueoakcouncil.org/list#bronze) 等级的许可证
- 对任何不在此等级范围内的许可证的审批工作流

## 先决条件

- 极狐GitLab 旗舰版
- 对您的极狐GitLab 实例或群组具有管理员访问权限
- 为您的项目启用了[依赖项扫描](../../user/application_security/dependency_scanning/_index.md)（可以选择性地按照[依赖项扫描设置](#setting-up-dependency-scanning-from-scratch)说明，对指定范围内的所有项目启用并强制执行此功能）

## 实施指南

本指南涵盖两种主要场景：

1. [从头开始设置](#setting-up-from-scratch-using-the-ui)（没有现有的安全策略项目）
   - [从头设置依赖项扫描](#setting-up-dependency-scanning-from-scratch)
   - [从头设置许可证合规](#setting-up-license-compliance-from-scratch)
1. [添加到现有策略](#adding-to-an-existing-policy)（有现有的安全策略项目）

### 从头开始设置（使用 UI）

如果您还没有安全策略项目，则需要创建一个，然后设置依赖项扫描和许可证合规策略。

#### 从头设置依赖项扫描

1. 首先，确定您要将此策略应用于哪个群组。这将是策略可以应用的最高群组级别（您可以在此群组内包含或排除项目）。
1. 导航到该群组的 **安全** > **策略** 页面。
1. 点击 **新建策略**。
1. 选择 **扫描执行策略**。
1. 输入策略的名称（例如，“Dependency scanning policy”）。
1. 输入描述（例如，“强制执行依赖项扫描以获取使用的 OSS 许可证列表”）。
1. 选择“此群组中的所有项目”（并可选择设置例外），或者在“特定项目”下从下拉列表中选择项目，来设置**策略范围**。
1. 在 **动作** 部分下，将默认的 **密钥检测** 更改为 **依赖项扫描**。
1. 在 **条件** 部分下，如果您希望按计划而不是在每次提交时运行扫描，可以选择将“触发器：”更改为“计划：”。
1. 点击 **创建策略**。

#### 从头设置许可证合规

设置依赖项扫描后，按照以下步骤设置许可证合规策略：

1. 返回到同一群组的 **安全** > **策略** 页面。
1. 点击 **新建策略**。
1. 选择 **合并请求审批策略**。
1. 输入策略的名称（例如，“OSS Compliance Policy”）。
1. 输入描述（例如，“阻止任何未包含在 Blue Oak Council 的 Gold、Silver 或 Bronze 等级中的许可证”）。
1. 选择“此群组中的所有项目”（并可选择设置例外），或者在“特定项目”下从下拉列表中选择项目，来设置**策略范围**。
1. 在 **规则** 部分下，点击“选择扫描类型”下拉列表并选择 **许可证扫描**。
1. 设置目标分支（默认为所有受保护分支）。
1. 根据您是想只对新依赖项还是也对现有依赖项执行策略，将“状态为：”下拉列表更改为 **新检测到的** 或 **预先存在的**。
1. **重要**：将“许可证为：”下拉列表从默认的“匹配”更改为 **除了**（这能确保策略正确运行以阻止未批准的许可证）。
1. 向下滚动到 **动作** 部分，设置所需的审批数量。
1. 在“选择审批人类别”下拉列表中，选择应提供审批的用户、群组或角色（您可以通过点击“添加新审批人”在同一规则中添加多种审批人类别）。
1. 配置“覆盖项目审批设置”部分，并根据需要更改默认设置。
1. 滚动回页面顶部并点击 `.yaml 模式`。
1. 在 YAML 编辑器中，找到 `license_types` 部分，并将其替换为[完整策略配置](#complete-policy-configuration)中的完整已批准许可证列表。该部分将类似于以下内容：

```yaml
rules:
  - type: license_finding
    match_on_inclusion_license: false
    license_types:
    # 用"完整策略配置"部分中的完整许可证列表替换此部分
    - MIT License
    - Apache License 2.0
    # 等等...
```

1. 点击 **创建策略**。

### 添加到现有策略

如果您已有安全策略项目但没有依赖项和/或许可证合规策略：

1. 导航到您群组的安全策略项目。
1. 导航到 `.gitlab/security-policies/` 目录中的 `policy.yml` 文件。
1. 点击 **编辑** > **编辑单一文件**。
1. 将[完整策略配置](#complete-policy-configuration)中的 `scan_execution_policy` 和 `approval_policy` 部分添加进去。
1. 确保：
   - 保持现有的 YAML 结构
   - 将这些部分放置在与其它顶级部分相同的级别
   - 设置 `user_approvers_ids` 和/或 `group_approvers_ids` 和/或 `role_approvers`（至少需要一种）
     - 用适当的用户/群组 ID（请确保粘贴的是用户/群组 ID，例如 1234567，而不是用户名）替换 `YOUR_USER_ID_HERE` 或 `YOUR_GROUP_ID_HERE`
   - 如果您想将某些项目排除在策略之外，请替换 `YOUR_PROJECT_ID_HERE`（请确保粘贴的是项目 ID，例如 1234，而不是项目名称/路径）
   - 将 `approvals_required: 1` 设置为您希望要求的审批数量
   - 根据需要修改 `approval_settings` 部分（任何设置为 `true` 的项将覆盖项目审批设置）
1. 点击 **提交更改**，并提交到新分支。选择 **为此次更改创建合并请求**，以便可以合并此策略更改。

## 完整策略配置

作为参考，以下是完整的策略配置：

```yaml
scan_execution_policy:
- name: License scan policy
  description: 强制执行依赖项扫描以获取使用的 OSS 许可证列表，以遵守 OSS 使用指南。
  enabled: true
  policy_scope:
    projects:
      excluding:
      - id: YOUR_PROJECT_ID_HERE
      - id: YOUR_PROJECT_ID_HERE
  rules:
  - type: pipeline
    branch_type: all
  actions:
  - scan: dependency_scanning
  skip_ci:
    allowed: true
    allowlist:
      users: []
approval_policy:
- name: OSS Compliance Policy
  description: |-
    阻止任何未包含在 Blue Oak Council 的 Gold、Silver 或 Bronze 等级中的许可证。
    https://blueoakcouncil.org/list
  enabled: true
  policy_scope:
    projects:
      excluding:
      - id: YOUR_PROJECT_ID_HERE
      - id: YOUR_PROJECT_ID_HERE
  rules:
  - type: license_finding
    match_on_inclusion_license: false
    license_types:
    - BSD-2-Clause Plus Patent License
    - Amazon Digital Services License
    - Apache License 2.0
    - Adobe Postscript AFM License
    - BSD 1-Clause License
    - BSD 2-Clause "Simplified" License
    - BSD 2-Clause FreeBSD License
    - BSD 2-Clause NetBSD License
    - BSD 2-Clause with Views Sentence
    - Boost Software License 1.0
    - DSDP License
    - Educational Community License v1.0
    - Educational Community License v2.0
    - hdparm License
    - ImageMagick License
    - Intel ACPI Software License Agreement
    - ISC License
    - Linux Kernel Variant of OpenIB.org license
    - MIT License
    - MIT License Modern Variant
    - MIT testregex Variant
    - MIT Tom Wu Variant
    - Microsoft Public License
    - Mulan Permissive Software License, Version 1
    - Mup License
    - PostgreSQL License
    - Solderpad Hardware License v0.5
    - Spencer License 99
    - Universal Permissive License v1.0
    - Xerox License
    - Xfig License
    - BSD Zero Clause License
    - Academic Free License v1.1
    - Academic Free License v1.2
    - Academic Free License v2.0
    - Academic Free License v2.1
    - Academic Free License v3.0
    - AMD's plpa_map.c License
    - Apple MIT License
    - Academy of Motion Picture Arts and Sciences BSD
    - ANTLR Software Rights Notice
    - ANTLR Software Rights Notice with license fallback
    - Apache License 1.0
    - Apache License 1.1
    - Artistic License 2.0
    - Bahyph License
    - Barr License
    - bcrypt Solar Designer License
    - BSD 3-Clause "New" or "Revised" License
    - BSD with attribution
    - BSD 3-Clause Clear License
    - Hewlett-Packard BSD variant license
    - Lawrence Berkeley National Labs BSD variant license
    - BSD 3-Clause Modification
    - BSD 3-Clause No Nuclear License 2014
    - BSD 3-Clause No Nuclear Warranty
    - BSD 3-Clause Open MPI Variant
    - BSD 3-Clause Sun Microsystems
    - BSD 4-Clause "Original" or "Old" License
    - BSD 4-Clause Shortened
    - BSD-4-Clause (University of California-Specific)
    - BSD Source Code Attribution
    - bzip2 and libbzip2 License v1.0.5
    - bzip2 and libbzip2 License v1.0.6
    - Creative Commons Zero v1.0 Universal
    - CFITSIO License
    - Clips License
    - CNRI Jython License
    - CNRI Python License
    - CNRI Python Open Source GPL Compatible License Agreement
    - Cube License
    - curl License
    - eGenix.com Public License 1.1.0
    - Entessa Public License v1.0
    - Freetype Project License
    - fwlw License
    - Historical Permission Notice and Disclaimer - Fenneberg-Livingston variant
    - Historical Permission Notice and Disclaimer - sell regexpr variant
    - HTML Tidy License
    - IBM PowerPC Initialization and Boot Software
    - ICU License
    - Info-ZIP License
    - Intel Open Source License
    - JasPer License
    - libpng License
    - PNG Reference Library version 2
    - libtiff License
    - LaTeX Project Public License v1.3c
    - LZMA SDK License (versions 9.22 and beyond)
    - MIT No Attribution
    - Enlightenment License (e16)
    - CMU License
    - enna License
    - feh License
    - MIT Open Group Variant
    - MIT +no-false-attribs license
    - Matrix Template Library License
    - Mulan Permissive Software License, Version 2
    - Multics License
    - Naumen Public License
    - University of Illinois/NCSA Open Source License
    - Net-SNMP License
    - NetCDF license
    - NICTA Public Software License, Version 1.0
    - NIST Software License
    - NTP License
    - Open Government Licence - Canada
    - Open LDAP Public License v2.0 (or possibly 2.0A and 2.0B)
    - Open LDAP Public License v2.0.1
    - Open LDAP Public License v2.1
    - Open LDAP Public License v2.2
    - Open LDAP Public License v2.2.1
    - Open LDAP Public License 2.2.2
    - Open LDAP Public License v2.3
    - Open LDAP Public License v2.4
    - Open LDAP Public License v2.5
    - Open LDAP Public License v2.6
    - Open LDAP Public License v2.7
    - Open LDAP Public License v2.8
    - Open Market License
    - OpenSSL License
    - PHP License v3.0
    - PHP License v3.01
    - Plexus Classworlds License
    - Python Software Foundation License 2.0
    - Python License 2.0
    - Ruby License
    - Saxpath License
    - SGI Free Software License B v2.0
    - Standard ML of New Jersey License
    - SunPro License
    - Scheme Widget Library (SWL) Software License Agreement
    - Symlinks License
    - TCL/TK License
    - TCP Wrappers License
    - UCAR License
    - Unicode License Agreement - Data Files and Software (2015)
    - Unicode License Agreement - Data Files and Software (2016)
    - UnixCrypt License
    - The Unlicense
    - Vovida Software License v1.0
    - W3C Software Notice and License (2002-12-31)
    - X11 License
    - XFree86 License 1.1
    - xlock License
    - X.Net License
    - XPP License
    - zlib License
    - zlib/libpng License with Acknowledgment
    - Zope Public License 2.0
    - Zope Public License 2.1
    license_states:
    - newly_detected
    branch_type: default
  actions:
  - type: require_approval
    approvals_required: 1
    user_approvers_ids:
    # 替换为您合规审批人的用户 ID
    - YOUR_USER_ID_HERE
    - YOUR_USER_ID_HERE
    group_approvers_ids:
    # 替换为您合规审批人的群组 ID
    - YOUR_GROUP_ID_HERE
    - YOUR_GROUP_ID_HERE
    role_approvers:
    # 替换为您合规审批人的角色
    - owner
    - maintainer
  - type: send_bot_message
    enabled: true
  approval_settings:
    block_branch_modification: true
    block_group_branch_modification: true
    prevent_pushing_and_force_pushing: true
    prevent_approval_by_author: true
    prevent_approval_by_commit_author: true
    remove_approvals_with_new_commit: true
    require_password_to_approve: false
  fallback_behavior:
    fail: closed
```

## 工作原理

1. `scan_execution_policy` 部分配置极狐GitLab 在所有分支上运行依赖项扫描，这会生成一个 CycloneDX 格式的 SBOM 文件，供许可证审批策略使用。
1. `approval_policy` 部分创建了一条规则，该规则：
   - 包含一个预先批准的许可证列表（来自 Blue Oak Council 的 [Gold](https://blueoakcouncil.org/list#gold)、[Silver](https://blueoakcouncil.org/list#silver) 和 [Bronze](https://blueoakcouncil.org/list#bronze) 等级）
   - 要求对任何不在此列表中的许可证进行审批
   - 在检测到未批准的许可证时发送机器人消息
   - 在获得批准之前阻止合并

## 自定义选项

- **审批人**：您可以通过三种方式指定审批人：
  - `user_approvers_ids`：替换为应审批许可证的个人的用户 ID（例如，`1234567`）。
  - `group_approvers_ids`：替换为包含审批人的群组 ID（例如，`9876543`）。
  - `role_approvers`：指定可以审批的角色，选项为 `developer`、`maintainer` 或 `owner`。
- **项目排除**：将项目 ID 添加到 `policy_scope.projects.excluding` 部分，以将其排除在策略之外。
- **所需审批数量**：更改 `approvals_required: 1` 以要求更多审批。
- **机器人消息**：在 `send_bot_message` 下将 `enabled: false` 设置为禁用机器人通知。
- **覆盖项目审批设置**：根据需要修改 `approval_settings` 部分（任何设置为 `true` 的项将覆盖项目设置）。

## 保持您的许可证列表为最新版本

为了确保您批准的许可证列表与 Blue Oak Council 评级保持同步，您可以使用以下 Python 脚本获取最新的许可证数据：

```python
import requests

def fetch_license_data():
    url = "https://blueoakcouncil.org/list.json"
    try:
        response = requests.get(url)
        response.raise_for_status()  # 对错误的状态码引发异常
        return response.json()
    except requests.RequestException as e:
        print(f"获取数据时出错: {e}")
        return None

# 获取并打印数据以验证其是否工作
data = fetch_license_data()
if data:
    # 遍历每个评级部分
    target_tiers = ['Gold', 'Silver', 'Bronze']

    for rating in data['ratings']:
        if rating['name'] in target_tiers:
            # 打印此等级中的每个许可证名称
            for license in rating['licenses']:
                print(f"- {license['name']}")
```

使用此脚本：

1. 将其保存为 `update_licenses.py`。
1. 安装 requests 库（如果尚未安装）：`pip install requests`。
1. 运行脚本：`python update_licenses.py`。
1. 复制输出（许可证列表）并替换 `policy.yml` 文件中现有的 `license_types` 列表。

这可以确保您的策略始终反映最新的 Blue Oak Council 许可证评级。

## 故障排除

### 策略未应用

确保您修改的安全策略项目正确链接到您的群组。更多信息请参见[链接到安全策略项目](../../user/application_security/policies/enforcement/security_policy_projects.md#link-to-a-security-policy-project)。

### 依赖项扫描未运行

检查 CI/CD 配置中是否启用了依赖项扫描，并且是否存在依赖项文件。更多信息请参见[依赖项扫描故障排除](../../user/application_security/dependency_scanning/dependency_scanning_sbom/troubleshooting_ds_sbom_analyzer.md)。