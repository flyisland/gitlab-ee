---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: 通过集中式自定义规则集配置极狐GitLab 秘密检测，自动检测顶级群组中所有项目内的 PII 和明文密码。
title: 秘密检测
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="getting-started"></a>

## 开始使用

<a id="download-the-solution-component"></a>

### 下载解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用邀请码从[解决方案组件商店](https://cloud.gitlab-accelerator-marketplace.com)下载解决方案组件。

<a id="prerequisites"></a>

### 先决条件

- 极狐GitLab 旗舰版
- 拥有极狐GitLab 实例或群组的管理员访问权限
- 为您的项目启用[秘密检测](../../user/application_security/secret_detection/_index.md)

<a id="configure-secret-detection-custom-rules"></a>

## 配置秘密检测自定义规则

本指南帮助您在全局层面实施秘密检测策略。该解决方案扩展了默认的秘密检测规则，包含对 PII 数据元素（如社会安全号码）和明文密码的检测。规则扩展被视为远程规则集。

<a id="configure-custom-ruleset"></a>

### 配置自定义规则集

您可以按照以下步骤设置自定义规则集：

1. 创建一个顶级群组 `Secret Detection`
1. 从您下载的组件中，将项目 `Secret Detection Custom Ruleset` 复制到新创建的 `Secret Detection` 群组中。

此自定义规则集扩展了极狐GitLab 预置规则。该扩展可以检测并告警以下密钥：

- PII 数据元素：社会安全号码
- 明文密码。

<a id="custom-ruleset-file"></a>

#### 自定义规则集文件

自定义规则集定义在 `.gitlab/secret-detection-ruleset.toml` 中。规则可以使用 `regex` 定义。

<a id="pii-data-element-detection"></a>

#### PII 数据元素检测

用于 PII 数据元素检测的扩展规则：

```toml
[[rules]]
id = "ssn"
description = "社会安全号码"
regex = "[0-9]{3}-[0-9]{2}-[0-9]{4}"
tags = ["ssn", "social-security-number"]
keywords = ["ssn"]
```

<a id="password-in-plain-text"></a>

#### 明文密码

用于明文密码的扩展规则：

```toml
[[rules]]
id = "password-secret"
description = "检测以 Password 或 PASSWORD 开头的密钥"
regex = "(?i)Password[:=]\\s*['\"]?[^'\"]+['\"]?"
tags = ["password", "secret"]
keywords = ["password", "PASSWORD"]
```

<a id="access-defined-custom-ruleset"></a>

### 访问已定义的自定义规则集

为了访问自定义规则集，您需要创建一个群组访问令牌，该令牌会生成一个机器人用户。运行全局策略秘密检测的任何项目都可以使用该机器人用户进行身份验证并访问自定义规则集。

要设置访问和身份验证，请按照以下步骤操作：

1. 创建群组令牌：在 `Secret Detection` 群组中，进入 **设置** 菜单选项，创建群组访问令牌 `Secret Detection Group Token`，为该令牌授予 **报告者** 角色和 `read_repository` 权限。

   ![安全仪表板](img/secret_detection_group_token_v17_9.png)

1. 创建群组变量：复制令牌值并安全存储。在 **设置** 菜单选项下添加一个群组变量，键为 `SECRET_DETECTION_GROUP_TOKEN`，值为令牌内容。
1. 获取群组令牌机器人用户：在同一群组中，导航到 **管理** 菜单选项，选择 **成员**，查找群组访问令牌 `Secret Detection Group Token` 对应的机器人用户，复制代表该群组机器人用户的值，格式为 `@group_[group_id]_bot_[random_number]`。

   ![秘密检测群组令牌机器人](img/secret_detection_group_token_bot_v17_9.png)

<a id="implementation-guide"></a>

## 实施指南

本指南涵盖使用集中式自定义规则集为所有项目配置运行秘密检测策略的步骤。

<a id="configure-secret-detection-policy"></a>

### 配置秘密检测策略

要在流水线中自动运行秘密检测作为强制全局策略，请在最高层级（此处为顶级群组）设置策略。
要创建新的秘密检测策略：

1. 创建策略：在同一个群组 `Secret Detection` 中，导航到该群组的 **安全** > **策略** 页面。
1. 选择 **新建策略**。
1. 选择 **扫描执行策略**。
1. 配置策略：为策略命名 `Secret Detection Policy`，输入描述，并选择 `Secret Detection` 扫描。
1. 设置 **策略范围**：选择“此群组中的所有项目”（并可选设置例外）或“特定项目”（并从下拉列表中选择项目）。
1. 在 **操作** 部分，默认显示秘密检测。
1. 在 **条件** 部分，您可以选择将“触发器：”更改为“计划：”，如果您希望按计划运行扫描而不是在每次提交时触发。
1. 设置对自定义规则集的访问：添加 CI 变量，包含机器人用户、群组变量和自定义规则集项目的 URL。

   自定义规则集托管在不同的项目中，被视为远程规则集，因此必须使用 `SECRET_DETECTION_RULESET_GIT_REFERENCE`。

   ```yaml
   variables:
     SECRET_DETECTION_RULESET_GIT_REFERENCE: "group_[group_id]_bot_[random_number]:$SECRET_DETECTION_GROUP_TOKEN@[custom ruleset project URL]"
     SECRET_DETECTION_HISTORIC_SCAN: "true"
   ```

UI 配置如图所示：![安全仪表板](img/secret_detection_policy_v17_9.png)
有关此 CI 变量的详细信息，请查看[此文档了解详情](../../user/application_security/secret_detection/pipeline/configure.md#with-a-remote-ruleset)。

1. 点击 **创建策略**。

<a id="complete-policy-configuration"></a>

### 完成策略配置

创建策略后，以下是完整的策略配置参考：

```yaml
---
scan_execution_policy:
- name: 使用自定义规则进行秘密检测的扫描执行
  description: ''
  enabled: true
  policy_scope:
    projects:
      excluding: []
  rules:
  - type: pipeline
    branches:
    - "*"
  actions:
  - scan: secret_detection
    variables:
      SECRET_DETECTION_RULESET_GIT_REFERENCE: "@group_[group_id]_bot_[random_number]:$SECRET_DETECTION_GROUP_TOKEN@jihulab.com/example_group/secret-detection/secret-detection-custom-ruleset"
      SECRET_DETECTION_HISTORIC_SCAN: 'true'
  skip_ci:
    allowed: true
    allowlist:
      users: []
approval_policy: []
```

<a id="how-it-works"></a>

## 工作原理

策略运行后，与全局策略关联的所有项目将自动在流水线中运行 `secret_detection_0` 作业。
![安全仪表板](img/secret_detection_job_v17_9.png)

检测到的密钥会被发现并展示出来。如果有合并请求，新增的密钥将显示在 MR 挂件中。如果是默认分支合并，它们将显示在安全漏洞报告中，如下所示：
![秘密检测密码漏洞结果](img/secret_detection_pwd_vuln_v17_9.png)

以下是一个明文密码示例：
![秘密检测密码发现](img/secret_detection_pwd_v17_9.png)

<a id="troubleshooting"></a>

## 故障排除

<a id="policy-not-applying"></a>

### 策略未应用

确保您修改的安全策略项目已正确链接到您的群组。更多信息请参见[链接到安全策略项目](../../user/application_security/policies/enforcement/security_policy_projects.md#link-to-a-security-policy-project)。