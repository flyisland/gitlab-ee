---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 认证脚本
---

DAST 认证脚本提供了一种基于 JavaScript 的灵活方式，可处理各种复杂度的认证流程。
通过自定义脚本无缝集成 DAST 安全扫描，实现登录过程的自动化。

认证脚本使用专为 DAST 操作设计的自定义方法的 JavaScript。
这些脚本可以处理基本的用户名和密码认证，也支持复杂的多因素认证流程，包括基于时间的一次性密码（TOTP）。

认证脚本集成提供：

- 支持各种复杂度的认证工作流。
- 使用自定义 DAST 方法的 JavaScript 脚本。
- 与现有 DAST 扫描流程的无缝集成。
- 内置对一次性密码和 TOTP 生成的支持。
- 访问环境变量以安全地管理凭证。
- 支持所有 HTML 表单元素，包括文本输入框、单选按钮、复选框和下拉列表。
- 与其他 DAST 变量保持一致的选器语法。
- 全面的日志记录，便于调试认证流程。

虽然脚本语言是 JavaScript，但脚本无法访问浏览器或通用模块。

## 配置脚本

要在 DAST 中使用认证脚本，请配置以下变量：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_TARGET_URL: "https://your-app.example.com"
    DAST_AUTH_SCRIPT: "auth_script.js"
```

可用的配置选项如下：

| 变量 | 描述 | 是否必需 |
|----------|-------------|----------|
| `DAST_AUTH_SCRIPT` | 认证脚本文件的路径（本地文件或 URL） | 是 |

使用 `DAST_AUTH_SCRIPT` 时，无需其他认证变量。
如果指定了现有的成功和失败变量，它们是可选的，并且可以正常工作。

## 示例脚本

以下是一个基础认证脚本，用于登录应用程序：

```javascript
// 导航到登录页面
doc.navigateURL("https://example.com/login")

// 从环境变量中填写用户名和密码
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)

// 提交登录表单
doc.actionLeftClick("css:button[type=\"submit\"]")

// 验证认证成功
auth.successIfAtURL("https://example.com/dashboard")
```

对于需要双重认证的应用程序：

```javascript
// 初始登录步骤
doc.navigateURL("https://example.com/login")
doc.actionFormInput("id:email", process.env.USER_EMAIL)
doc.actionFormInput("id:password", process.env.USER_PASSWORD)
doc.actionLeftClick("id:login-button")

// 如果需要处理 TOTP
const totpCode = otp.generateTOTP()
doc.actionFormInput("id:totp-code", totpCode)
doc.actionLeftClick("id:verify-button")

// 确认认证成功
auth.successIfAtURL("https://example.com/app/home")
```

要运行脚本，请在 CI/CD 配置中添加以下内容：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_TARGET_URL: "https://example.com"
    DAST_AUTH_SCRIPT: "auth_script.js"
```

如果你使用了 `otp.generateTOTP()` 方法，请确保同时在 CI/CD 配置中添加 `DAST_AUTH_OTP_KEY` 变量。

## 文档交互方法

<a id="document-interaction-methods"></a>

| 方法 | 描述 |
|--------|-------------|
| `doc.getURL()` | 获取当前页面 URL。 |
| `doc.navigateURL(url)` | 前往指定的 URL。 |
| `doc.actionFormInput(path, value, dontClear)` | 在表单输入框中输入文本。 |
| `doc.actionFormSelectOption(optionPath)` | 选择下拉列表选项。 |
| `doc.actionFormRadioButton(buttonPath)` | 选择单选按钮。 |
| `doc.actionFormCheckbox(checkboxPath)` | 切换复选框。 |
| `doc.actionFormSubmit(formPath)` | 提交表单。 |
| `doc.actionLeftClick(onPath)` | 执行鼠标左键单击。 |

### `doc.getURL()`

<a id="docgeturl"></a>

以字符串形式返回当前页面的 URL。

用法：

获取当前浏览器地址，这对条件逻辑或调试非常有用。

示例：

```javascript
// 导航到登录页面
doc.navigateURL("https://example.com/login")

// 获取当前 URL 以用于日志记录或验证
const currentUrl = doc.getURL()
log.info("当前位于：" + currentUrl)

// 使用当前 URL 进行条件判断
if (currentUrl.includes("/login")) {
    log.info("在登录页面，继续认证")
    doc.actionFormInput("id:username", process.env.USERNAME)
}
```

### `doc.navigateURL(url)`

<a id="docnavigateurlurl"></a>

将浏览器导航到指定的 URL。

参数：

- `url` (string)：要前往的目标 URL。

用法：

在认证流程中，引导浏览器访问特定页面。这通常是大多数认证脚本中执行的第一个操作。

示例：

```javascript
// 导航到主登录页面
doc.navigateURL("https://app.example.com/auth/login")

// 对于多步认证，导航到不同页面
doc.navigateURL("https://app.example.com/auth/two-factor")

// 导航到特定的租户或子域名
doc.navigateURL("https://tenant1.example.com/login")
```

### `doc.actionFormInput(path, value, dontClear)`

<a id="docactionforminputpath-value-dontclear"></a>

在表单输入框中输入文本，例如文本框、密码框、邮箱字段和文本区域。

默认情况下，此方法在输入新文本前会清除字段中的现有内容。在以下情况下，请设置 `dontClear: true`：

- 保留或追加现有字段内容。
- 处理具有自动聚焦行为的字段，其中清除过程会干扰输入。
- 处理多部分输入，例如 OTP 字段在单个数字输入之间自动移动焦点。

参数：

- `path` (string)：元素选器路径，使用 DAST 选器语法。
- `value` (string)：要输入到字段中的文本值。
- `dontClear` (boolean，可选)：当为 `true` 时，方法在输入文本前不清除字段内容。默认值：`false`。

用法：

这是填写登录表单、搜索框和其他基于文本的输入字段的主要方法。

示例：

```javascript
// 基础登录表单输入
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)

// 使用不同的选器类型
doc.actionFormInput("name:email", "user@example.com")
doc.actionFormInput("css:input[placeholder='Enter your API key']", process.env.API_KEY)
doc.actionFormInput("xpath://input[@data-testid='login-field']", "testuser")

// 多步认证
doc.actionFormInput("id:verification-code", "123456")
doc.actionFormInput("css:.otp-input", otp.generateTOTP())

// 跳过清除 - 对于具有自动聚焦行为的字段非常有用
doc.actionFormInput("css:.ap-otp-inputs[data-index='0']", 1, true)
doc.actionFormInput("css:.ap-otp-inputs[data-index='1']", 2, true)
doc.actionFormInput("css:.ap-otp-inputs[data-index='2']", 3, true)

// 搜索或过滤字段
doc.actionFormInput("css:input[type='search']", "产品名称")
```

### `doc.actionFormSelectOption(optionPath)`

<a id="docactionformselectoptionoptionpath"></a>

从下拉列表中选择选项。

参数：

- `optionPath` (string)：指向要选择的选项的元素选器路径。

用法：

从下拉列表中选择一个特定选项，例如语言或租户。

示例：

```javascript
// 从下拉列表中选择特定租户
doc.actionFormSelectOption("css:option[value='tenant-prod']")

// 根据可见文本内容选择
doc.actionFormSelectOption("xpath://option[text()='生产环境']")

// 选择用户角色
doc.actionFormSelectOption("id:role-admin")

// 从国家下拉列表中选择
doc.actionFormSelectOption("css:select[name='country'] option[value='US']")

// 语言选择
doc.actionFormSelectOption("xpath://select[@id='language']//option[@value='en']")
```

### `doc.actionFormRadioButton(buttonPath)`

<a id="docactionformradiobuttonbuttonpath"></a>

从单选按钮组中选择一个单选按钮。

参数：

- `buttonPath` (string)：指向要选择的单选按钮的元素选器路径。

用法：

选择一个单选按钮以做出选择。例如，选择认证方式或账户类型。

示例：

```javascript
// 选择认证方式
doc.actionFormRadioButton("id:auth-method-sso")
doc.actionFormRadioButton("css:input[value='ldap']")

// 选择账户类型
doc.actionFormRadioButton("name:account-type[value='business']")

// 选择登录流程
doc.actionFormRadioButton("xpath://input[@name='flow' and @value='standard']")

// 选择安全问题
doc.actionFormRadioButton("css:input[type='radio'][data-question='pet-name']")
```

### `doc.actionFormCheckbox(checkboxPath)`

<a id="docactionformcheckboxcheckboxpath"></a>

选中或取消选中复选框。

参数：

- `checkboxPath` (string)：指向要切换的复选框的元素选器路径。

用法：

切换复选框。例如，同意条款和条件，或打开/关闭可选设置。

示例：

```javascript
// 勾选“记住我”选项
doc.actionFormCheckbox("id:remember-me")

// 接受条款和条件
doc.actionFormCheckbox("css:input[name='accept-terms']")

// 启用通知
doc.actionFormCheckbox("xpath://input[@type='checkbox' and @name='notifications']")

// 选择多个选项
doc.actionFormCheckbox("css:.feature-checkbox[data-feature='advanced-auth']")
doc.actionFormCheckbox("css:.feature-checkbox[data-feature='audit-logs']")

// 隐私设置
doc.actionFormCheckbox("id:privacy-analytics-opt-out")
```

### `doc.actionFormSubmit(formPath)`

<a id="docactionformsubmitformpath"></a>

通过直接定位表单元素来提交表单。

参数：

- `formPath` (string)：指向要提交的表单的元素选器路径。

用法：

使用此方法作为选择提交按钮的替代方法，尤其适用于使用 JavaScript 提交的表单，或提交按钮难以定位的情况。

示例：

```javascript
// 直接提交登录表单
doc.actionFormSubmit("id:login-form")

// 通过表单的 class 提交
doc.actionFormSubmit("css:.authentication-form")

// 通过 name 属性提交表单
doc.actionFormSubmit("name:user-login")

// 提交嵌套表单
doc.actionFormSubmit("xpath://div[@class='auth-container']//form")

// 完整的认证流程
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionFormSubmit("css:form[action='/authenticate']")
```

### `doc.actionLeftClick(onPath)`

<a id="docactionleftclickonpath"></a>

在任意可点击的元素上执行鼠标左键单击。

参数：

- `onPath` (string)：指向要单击的元素的元素选器路径。

用法：

左键单击按钮、链接、选项卡和其他交互式元素。

示例：

```javascript
// 单击提交按钮
doc.actionLeftClick("css:button[type='submit']")

// 通过 ID 单击登录按钮
doc.actionLeftClick("id:login-btn")

// 单击链接导航
doc.actionLeftClick("css:a[href='/dashboard']")

// 单击选项卡或导航元素
doc.actionLeftClick("xpath://li[@data-tab='profile']")

// 单击自定义按钮
doc.actionLeftClick("css:.btn-primary[data-action='authenticate']")

// 处理多步流程
doc.actionLeftClick("id:next-step")
doc.actionLeftClick("css:button[data-step='verify']")

// 单击模态框或覆盖层按钮
doc.actionLeftClick("css:.modal button[data-dismiss='modal']")
```

## 认证验证方法

<a id="authentication-validation-methods"></a>

你应该确保脚本中包含成功或失败的方法。
成功和失败的配置变量也可以与认证脚本一起使用。

| 方法 | 描述 |
|--------|-------------|
| `auth.successIfAtURL(url)` | 如果位于指定的 URL，则将认证标记为成功。 |
| `auth.successIfElementFound(path)` | 如果元素存在，则将认证标记为成功。 |
| `auth.failedIfAtURL(url)` | 如果位于指定的 URL，则将认证标记为失败。 |
| `auth.failedIfElementFound(path)` | 如果元素存在，则将认证标记为失败。 |

### `auth.successIfElementFound(path)`

<a id="authsuccessifelementfoundpath"></a>

如果当前页面上存在指定的元素，则将认证标记为成功。

参数：

- `path` (string)：认证成功后应该存在的元素选器路径。

用法：

当基于 URL 的验证不够充分时，例如对于单页应用，或当特定的 UI 元素指示认证状态时，使用此方法。

示例：

```javascript
// 查找用户个人资料菜单
auth.successIfElementFound("css:.user-profile-dropdown")

// 检查注销按钮
auth.successIfElementFound("id:logout-button")

// 查找欢迎消息
auth.successIfElementFound("xpath://div[contains(text(), '欢迎回来')]")

// 检查已认证的导航栏
auth.successIfElementFound("css:nav .authenticated-menu")

// 查找用户头像
auth.successIfElementFound("css:.header .user-avatar")

// 包含基于元素验证的完整示例
doc.navigateURL("https://spa.example.com")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionLeftClick("css:button[type='submit']")
auth.successIfElementFound("css:.dashboard-welcome")
```

### `auth.failedIfAtURL(url)`

<a id="authfailedifaturlurl"></a>

如果浏览器位于指定的 URL，则将认证标记为失败。

参数：

- `url` (string)：表示认证失败的 URL。

用法：

通过检查错误页面、登录页面重定向或特定的失败 URL，来检测认证失败。

示例：

```javascript
// 检测重定向回登录页面
auth.failedIfAtURL("https://app.example.com/login")

// 检查错误页面
auth.failedIfAtURL("https://app.example.com/auth/error")

// 查找访问被拒页面
auth.failedIfAtURL("https://app.example.com/access-denied")

// 账户被锁定页面
auth.failedIfAtURL("https://app.example.com/account-locked")

// 包含失败检测的完整示例
doc.navigateURL("https://app.example.com/login")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionLeftClick("css:button[type='submit']")
```

### `auth.failedIfElementFound(path)`

<a id="authfailedifelementfoundpath"></a>

如果指定元素存在于当前页面上，则将认证标记为失败。

参数：

- `path` (string)：指示认证失败的元素选器路径。

用法：

检测错误消息、警告横幅或其他表示认证问题的 UI 元素。

示例：

```javascript
// 查找错误消息
auth.failedIfElementFound("css:.error-message")

// 检查“无效的用户名或密码”消息
auth.failedIfElementFound("xpath://div[contains(text(), '无效的用户名或密码')]")

// 查找账户被锁定警告
auth.failedIfElementFound("id:account-locked-alert")

// 包含失败检测的综合认证流程
doc.navigateURL("https://app.example.com/login")
doc.actionFormInput("id:email", process.env.USER_EMAIL)
doc.actionFormInput("id:password", process.env.USER_PASSWORD)
doc.actionLeftClick("id:submit-btn")
auth.failedIfElementFound("css:.error-message")

// 多因素失败条件
auth.failedIfElementFound("css:.alert-danger")
auth.failedIfElementFound("xpath://div[@class='error' and contains(text(), '登录失败')]")
auth.failedIfAtURL("https://app.example.com/login?error=1")
```

## 一次性密码方法

<a id="one-time-password-methods"></a>

| 方法 | 描述 |
|--------|-------------|
| `otp.generateTOTP()` | 生成基于时间的一次性密码。 |

### `otp.generateTOTP()`

<a id="otpgeneratetotp"></a>

使用配置的密钥生成基于时间的一次性密码（TOTP）。

前提条件：

- TOTP 密钥必须采用 base32 编码，并通过 `DAST_AUTH_OTP_KEY` 提供。
- 应用程序必须接受标准 TOTP 代码（通常是每 30 秒刷新的 6 位数字代码）。

> [!warning]
> 为防止安全风险，请勿在 YAML 作业定义文件中定义 `DAST_AUTH_OTP_KEY`。
> 相反，应使用极狐GitLab UI 将其创建为已掩蔽的 CI/CD 变量。
> 更多信息，请参见[自定义 CI/CD 变量](../../../../../ci/variables/_index.md#for-a-project)。

用法：

对于需要使用 Google Authenticator、Authy 或类似基于 TOTP 的系统进行双重认证的应用程序，可以使用此方法。

返回值：

- 包含当前 TOTP 代码的字符串。

示例：

```javascript
// 基础的 TOTP 认证流程
doc.navigateURL("https://secure.example.com/login")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionFormInput("id:totp-code", otp.generateTOTP())
doc.actionLeftClick("css:button[type='submit']")
auth.successIfAtURL("https://secure.example.com/dashboard")
```

```javascript
// 带有错误处理的高级 TOTP 流程
doc.navigateURL("https://enterprise.example.com/sso")
doc.actionFormInput("id:employee-id", process.env.EMPLOYEE_ID)
doc.actionFormInput("id:password", process.env.EMPLOYEE_PASSWORD)
doc.actionLeftClick("css:.login-submit")

// 检查是否需要 TOTP
const currentUrl = doc.getURL()
if (currentUrl.includes("/mfa")) {
    log.info("需要 MFA，正在生成 TOTP")
    const code = otp.generateTOTP()
    doc.actionFormInput("css:.mfa-input", code)
    doc.actionLeftClick("css:.mfa-submit")
}

auth.successIfElementFound("css:.employee-portal")
```

## 日志方法

<a id="logging-methods"></a>

将消息添加到认证报告中。这在故障排查时非常有用。

| 方法 | 描述 |
|--------|-------------|
| `log.info(msg)` | 记录信息性消息。 |
| `log.debug(msg)` | 记录调试消息。 |
| `log.warn(msg)` | 记录警告消息。 |
| `log.trace(msg)` | 记录跟踪消息。 |
| `log.error(msg)` | 记录错误消息。 |
| `log.errorWithException(ex, msg)` | 记录带有异常详情的错误。 |

### `log.info(msg)`

<a id="loginfomsg"></a>

记录信息性消息，提供有关脚本执行的一般信息。

参数：

- `msg` (string)：要记录的消息。

用法：

记录脚本的总体进度、成功操作以及认证流程中的重要里程碑。

示例：

```javascript
log.info("正在启动认证流程")
doc.navigateURL("https://app.example.com/login")

log.info("正在填写登录凭证")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)

log.info("正在提交登录表单")
doc.actionLeftClick("css:button[type='submit']")

auth.successIfAtURL("https://app.example.com/dashboard")
log.info("认证已成功完成")
```

### `log.debug(msg)`

<a id="logdebugmsg"></a>

记录详细的调试信息，有助于排查脚本问题。

参数：

- `msg` (string)：要记录的调试消息。

用法：

记录逐步执行的详细信息、变量值以及用于脚本调试的诊断信息。

示例：

```javascript
log.debug("正在初始化认证脚本")
log.debug("目标 URL：https://app.example.com/login")

const username = process.env.USERNAME
log.debug("已从环境中获取用户名：" + (username ? "✓" : "✗"))

doc.navigateURL("https://app.example.com/login")
log.debug("导航完成")

const currentUrl = doc.getURL()
log.debug("导航后的当前 URL：" + currentUrl)

doc.actionFormInput("id:username", username)
log.debug("用户名字段已填充")

doc.actionFormInput("id:password", process.env.PASSWORD)
log.debug("密码字段已填充")

doc.actionLeftClick("css:button[type='submit']")
log.debug("登录表单已提交")
```

### `log.warn(msg)`

<a id="logwarnmsg"></a>

记录警告消息，用于指示可能存在但不影响执行的问题。

参数：

- `msg` (string)：要记录的警告消息。

用法：

记录可恢复的问题、回退场景或可能表明存在问题但不会停止认证流程的条件。

示例：

```javascript
// 检查必需的环境变量
if (!process.env.USERNAME) {
    log.warn("USERNAME 环境变量未设置，使用默认值")
    doc.actionFormInput("id:username", "defaultuser")
} else {
    doc.actionFormInput("id:username", process.env.USERNAME)
}

// 处理可选的 TOTP
const totpSecret = process.env.DAST_AUTH_OTP_KEY
if (!totpSecret) {
    log.warn("DAST_AUTH_OTP_KEY 未配置，跳过双重认证")
} else {
    const code = otp.generateTOTP()
    doc.actionFormInput("id:totp", code)
}

// 检查意外的页面内容
const currentUrl = doc.getURL()
if (!currentUrl.includes("expected-domain.com")) {
    log.warn("URL 中存在未知域名：" + currentUrl)
}
```

### `log.trace(msg)`

<a id="logtracemsg"></a>

记录非常详细的跟踪信息，用于细粒度的调试。

参数：

- `msg` (string)：要记录的跟踪消息。

用法：

记录包括每个微小步骤和操作的详细信息。通常用于复杂的调试场景。

示例：

```javascript
log.trace("脚本开始执行")
log.trace("正在检查环境变量")

log.trace("即将导航到登录页面")
doc.navigateURL("https://complex-app.example.com/auth/login")
log.trace("导航调用已完成")

log.trace("等待页面加载...")
const url = doc.getURL()
log.trace("当前 URL：" + url)

log.trace("定位用户名字段")
doc.actionFormInput("css:input[data-testid='username']", process.env.USERNAME)
log.trace("用户名字段交互完成")

log.trace("定位密码字段")
doc.actionFormInput("css:input[data-testid='password']", process.env.PASSWORD)
log.trace("密码字段交互完成")

log.trace("搜索提交按钮")
doc.actionLeftClick("css:button[data-testid='submit']")
log.trace("提交按钮单击完成")

log.trace("认证流程已完成")
```

### `log.error(msg)`

<a id="logerrormsg"></a>

记录错误消息，用于可能导致认证失败的严重问题。

参数：

- `msg` (string)：要记录的错误消息。

用法：

记录严重错误、认证失败或任何阻止脚本成功完成的条件。

**示例：**

```javascript
// 验证必需的环境变量
if (!process.env.USERNAME || !process.env.PASSWORD) {
    log.error("必需的环境变量 USERNAME 或 PASSWORD 未设置")
    return
}

try {
  // 可能抛出异常的自定义代码
} catch (e) {
  log.error("认证过程中出现严重错误：" + e.message)
}

doc.navigateURL("https://app.example.com/login")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionLeftClick("css:button[type='submit']")

// 检查错误条件
const currentUrl = doc.getURL()
if (currentUrl.includes("/error")) {
    log.error("认证失败 - 已重定向到错误页面")
    log.error("错误 URL：" + currentUrl)
}

auth.successIfAtURL("https://app.example.com/dashboard")
```

### `log.errorWithException(ex, msg)`

<a id="logerrorwithexceptionex-msg"></a>

记录错误消息以及异常详情，以提供全面的错误报告。

参数：

- `ex` (Exception)：包含错误详情的异常对象。
- `msg` (string)：关于错误的附加上下文消息。

用法：

在错误上下文和技术细节都很重要的情况下，捕获异常或处理复杂的错误场景。

示例：

```javascript
try {
  log.info("正在启动复杂的认证流程")

  // 多步认证
  doc.navigateURL("https://enterprise.example.com/login")
  doc.actionFormInput("id:username", process.env.USERNAME)
  doc.actionFormInput("id:password", process.env.PASSWORD)
  doc.actionLeftClick("id:login-btn")

  // 如果需要处理 TOTP
  if (doc.getURL().includes("/mfa")) {
    const totpCode = otp.generateTOTP()
    doc.actionFormInput("id:mfa-code", totpCode)
    doc.actionLeftClick("id:verify-btn")
  }

  auth.successIfAtURL("https://enterprise.example.com/portal")

} catch (authException) {
  log.errorWithException(authException, "登录过程中认证流程失败")

  // 附加的错误上下文
  const currentUrl = doc.getURL()
  log.error("失败时的当前 URL：" + currentUrl)

  throw authException
}

// 包含验证错误处理的示例
try {
  const username = process.env.USERNAME
  if (!username) {
    throw new Error("USERNAME 环境变量是必需的")
  }

  doc.actionFormInput("id:username", username)
} catch (validationError) {
  log.errorWithException(validationError, "验证必需的认证参数失败")
}
```

## 元素选器

<a id="element-selectors"></a>

认证脚本使用与其他 DAST 变量相同的选器语法：

- ID 选器：`id:element-id`
- CSS 选器：`css:.class-name` 或 `css:button[type="submit"]`
- 名称选器：`name:field-name`
- XPath 选器：`xpath://input[@id='username']`

## 环境变量

<a id="environment-variables"></a>

通过环境变量访问敏感的认证数据：

```javascript
// 使用环境变量传递凭证
doc.actionFormInput("id:username", process.env.DAST_AUTH_USERNAME)
doc.actionFormInput("id:password", process.env.DAST_AUTH_PASSWORD)
```
> [!warning]
> 为防止安全风险，请勿在 YAML 作业定义文件中定义敏感信息。
> 而应使用极狐GitLab UI 将其创建为屏蔽的 CI/CD 变量。
> 更多信息，请参阅[自定义 CI/CD 变量](../../../../../ci/variables/_index.md#for-a-project)。

<a id="debugging"></a>

## 调试

有两种方法可以了解脚本的执行情况及其执行的操作：身份验证报告和调试日志。两者都作为 DAST 作业的产物附加。

身份验证报告包含您身份验证脚本的每个步骤，并附有截图，以帮助调试脚本。该报告还包括 HTTP 请求和响应，以及文档对象模型 (DOM)。每个 DAST 作业都会生成身份验证报告，并作为作业产物收集。产物文件名为 `gl-dast-debug-auth-report.html`。

此外，身份验证脚本提供全面的日志记录，以帮助排查身份验证问题。记录到调试日志中，该日志作为名为 `gl-dast-scan.log` 的作业产物附加。所有脚本操作都会自动记录，并显示以下调试信息：

- 环境变量赋值（带有屏蔽的敏感值）
- 脚本执行步骤
- URL 导航操作
- 表单输入操作
- 点击操作
- 身份验证验证结果

示例调试输出：

```plaintext
DBG SCRIPT 运行用户脚本 script="auth_script.js"
DBG SCRIPT doc.navigateURL url="https://example.com/login"
DBG SCRIPT doc.actionFormInput onPath="id:username" value="********"
DBG SCRIPT doc.actionLeftClick onPath="css:button[type='submit']"
INF SCRIPT 满足要求，浏览器 URL 匹配模式
```

在脚本中使用日志记录方法添加自定义调试信息：

```javascript
log.info("开始身份验证过程")
log.debug("导航到登录页面")
// ... 身份验证步骤 ...
log.info("身份验证成功完成")
```

<a id="troubleshooting"></a>

## 故障排除

使用身份验证脚本时，您可能会遇到以下问题。

<a id="script-execution-failures"></a>

### 脚本执行失败

您的脚本可能无法运行，原因是 JavaScript 格式错误或缺少环境变量。

解决方法：

- 验证您的脚本语法是否是有效的 JavaScript。
- 检查是否设置了所有必需的环境变量。
- 使用 `log.debug()` 在身份验证流程中添加检查点。

<a id="element-selection-issues"></a>

### 元素选择问题

如果您的脚本在目标应用程序中选择元素时遇到问题：

- 在浏览器开发者工具中测试您的选择器。
- 查看包含 DOM 的身份验证报告。

<a id="authentication-validation-failures"></a>

### 身份验证验证失败

您的脚本可能无法对目标应用程序进行身份验证。

解决方法：

- 确保您的成功或失败条件准确反映身份验证状态。
- 检查可能更改预期 URL 的重定向。
- 使用基于元素的验证作为基于 URL 的验证的替代方法。