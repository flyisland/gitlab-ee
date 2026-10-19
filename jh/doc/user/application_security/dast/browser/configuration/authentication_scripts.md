---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 认证脚本
---

DAST 认证脚本提供了一种灵活的、基于 JavaScript 的方法，用于处理各种复杂程度的认证流程。使用与 DAST 安全扫描无缝集成的自定义脚本，自动执行登录过程。

认证脚本使用 JavaScript，并采用专为 DAST 操作设计的自定义方法。这些脚本可以处理基本的用户名和密码认证，也可以处理复杂的多因素认证流程，并支持基于时间的一次性密码（TOTP）。

认证脚本集成包括：

- 支持各种复杂程度的认证工作流。
- 使用自定义 DAST 方法的基于 JavaScript 的脚本编写。
- 与现有 DAST 扫描流程无缝集成。
- 内置对一次性密码和 TOTP 生成的支持。
- 可访问环境变量，以实现安全的凭据管理。
- 支持所有 HTML 表单元素，包括文本输入框、单选按钮、复选框和下拉列表。
- 与其他 DAST 变量一致的选择器语法。
- 全面的日志记录，用于调试认证流程。

虽然脚本语言是 JavaScript，但脚本无法访问浏览器或常用模块。

<a id="configure-scripts"></a>

## 配置脚本

要将认证脚本与 DAST 配合使用，请配置以下变量：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_TARGET_URL: "https://your-app.example.com"
    DAST_AUTH_SCRIPT: "auth_script.js"
```

以下配置选项可用：

| 变量 | 描述 | 是否必需 |
|----------|-------------|----------|
| `DAST_AUTH_SCRIPT` | 认证脚本文件的路径（本地文件或 URL） | 是 |

使用 `DAST_AUTH_SCRIPT` 时，不需要其他认证变量。现有的成功和失败变量是可选的，如果指定了它们，也会生效。

<a id="example-scripts"></a>

## 示例脚本

以下基本认证脚本用于登录应用程序：

```javascript
// Navigate to the login page
doc.navigateURL("https://example.com/login")

// Fill in username and password from environment variables
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)

// Submit the login form
doc.actionLeftClick("css:button[type=\"submit\"]")

// Verify successful authentication
auth.successIfAtURL("https://example.com/dashboard")
```

对于需要双因素认证的应用程序：

```javascript
// Initial login steps
doc.navigateURL("https://example.com/login")
doc.actionFormInput("id:email", process.env.USER_EMAIL)
doc.actionFormInput("id:password", process.env.USER_PASSWORD)
doc.actionLeftClick("id:login-button")

// Handle TOTP if required
const totpCode = otp.generateTOTP()
doc.actionFormInput("id:totp-code", totpCode)
doc.actionLeftClick("id:verify-button")

// Confirm successful authentication
auth.successIfAtURL("https://example.com/app/home")
```

要运行脚本，请将以下内容添加到您的 CI/CD 配置中：

```yaml
include:
  - template: DAST.gitlab-ci.yml

dast:
  variables:
    DAST_TARGET_URL: "https://example.com"
    DAST_AUTH_SCRIPT: "auth_script.js"
```

如果您使用 `otp.generateTOTP()` 方法，请确保同时将 `DAST_AUTH_OTP_KEY` 变量添加到您的 CI/CD 配置中。

<a id="document-interaction-methods"></a>

## 文档交互方法

| 方法 | 描述 |
|--------|-------------|
| `doc.getURL()` | 获取当前页面 URL。 |
| `doc.navigateURL(url)` | 转到特定 URL。 |
| `doc.actionFormInput(path, value, dontClear)` | 在表单输入字段中输入文本。 |
| `doc.actionFormSelectOption(optionPath)` | 选择下拉列表选项。 |
| `doc.actionFormRadioButton(buttonPath)` | 选择单选按钮。 |
| `doc.actionFormCheckbox(checkboxPath)` | 切换复选框。 |
| `doc.actionFormSubmit(formPath)` | 提交表单。 |
| `doc.actionLeftClick(onPath)` | 执行鼠标左键点击。 |

<a id="docgeturl"></a>

### `doc.getURL()`

以字符串形式返回当前页面 URL。

用法：

获取当前浏览器位置，这对于条件逻辑或调试很有帮助。

示例：

```javascript
// Navigate to login page
doc.navigateURL("https://example.com/login")

// Get current URL for logging or validation
const currentUrl = doc.getURL()
log.info("Currently at: " + currentUrl)

// Use current URL for conditional logic
if (currentUrl.includes("/login")) {
    log.info("On login page, proceeding with authentication")
    doc.actionFormInput("id:username", process.env.USERNAME)
}
```

<a id="docnavigateurlurl"></a>

### `doc.navigateURL(url)`

将浏览器导航到指定的 URL。

参数：

- `url`（字符串）：要转到的目标 URL。

用法：

在认证流程中将浏览器定向到特定页面，通常作为大多数认证脚本中的第一个操作。

示例：

```javascript
// Navigate to the main login page
doc.navigateURL("https://app.example.com/auth/login")

// For multi-step authentication, navigate to different pages
doc.navigateURL("https://app.example.com/auth/two-factor")

// Navigate to a specific tenant or subdomain
doc.navigateURL("https://tenant1.example.com/login")
```

<a id="docactionforminputpath-value-dontclear"></a>

### `doc.actionFormInput(path, value, dontClear)`

在表单输入字段（如文本框、密码字段、电子邮件字段和文本区域）中输入文本。

默认情况下，此方法会在输入新文本之前清除字段中的任何现有内容。在以下情况下，请设置 `dontClear: true`：

- 保留现有字段内容或向其追加内容。
- 处理具有自动聚焦行为的字段，其中清除过程会干扰输入。
- 处理多部分输入，例如在单个数字输入之间自动移动焦点的 OTP 字段。

参数：

- `path`（字符串）：使用 DAST 选择器语法的元素选择器路径。
- `value`（字符串）：要输入到字段中的文本值。
- `dontClear`（布尔值，可选）：当为 `true` 时，该方法在输入文本之前不会清除字段。默认值：`false`。

用法：

将此方法用作填写登录表单、搜索框和其他基于文本的输入字段的主要方式。

示例：

```javascript
// Basic login form inputs
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)

// Using different selector types
doc.actionFormInput("name:email", "user@example.com")
doc.actionFormInput("css:input[placeholder='Enter your API key']", process.env.API_KEY)
doc.actionFormInput("xpath://input[@data-testid='login-field']", "testuser")

// Multi-step authentication
doc.actionFormInput("id:verification-code", "123456")
doc.actionFormInput("css:.otp-input", otp.generateTOTP())

// Skip clearing - useful for fields with auto-focus behavior
doc.actionFormInput("css:.ap-otp-inputs[data-index='0']", 1, true)
doc.actionFormInput("css:.ap-otp-inputs[data-index='1']", 2, true)
doc.actionFormInput("css:.ap-otp-inputs[data-index='2']", 3, true)

// Search or filter fields
doc.actionFormInput("css:input[type='search']", "product name")
```

<a id="docactionformselectoptionoptionpath"></a>

### `doc.actionFormSelectOption(optionPath)`

从下拉列表中选择一个选项。

参数：

- `optionPath`（字符串）：指向要选择的选项的元素选择器路径。

用法：

从下拉列表中选择特定选项，例如语言或租户。

示例：

```javascript
// Select a specific tenant from dropdown
doc.actionFormSelectOption("css:option[value='tenant-prod']")

// Select by visible text content
doc.actionFormSelectOption("xpath://option[text()='Production Environment']")

// Select user role
doc.actionFormSelectOption("id:role-admin")

// Select from a country dropdown
doc.actionFormSelectOption("css:select[name='country'] option[value='US']")

// Language selection
doc.actionFormSelectOption("xpath://select[@id='language']//option[@value='en']")
```

<a id="docactionformradiobuttonbuttonpath"></a>

### `doc.actionFormRadioButton(buttonPath)`

从单选按钮组中选择一个单选按钮。

参数：

- `buttonPath`（字符串）：指向要选择的单选按钮的元素选择器路径。

用法：

选择单选按钮以做出选择。例如，选择认证方法或账户类型。

示例：

```javascript
// Select authentication method
doc.actionFormRadioButton("id:auth-method-sso")
doc.actionFormRadioButton("css:input[value='ldap']")

// Account type selection
doc.actionFormRadioButton("name:account-type[value='business']")

// Select login flow
doc.actionFormRadioButton("xpath://input[@name='flow' and @value='standard']")

// Security question selection
doc.actionFormRadioButton("css:input[type='radio'][data-question='pet-name']")
```

<a id="docactionformcheckboxcheckboxpath"></a>

### `doc.actionFormCheckbox(checkboxPath)`

选中或清除复选框。

参数：

- `checkboxPath`（字符串）：指向要切换的复选框的元素选择器路径。

用法：

切换复选框。例如，同意条款和条件，或打开和关闭可选设置。

示例：

```javascript
// Check "Remember me" option
doc.actionFormCheckbox("id:remember-me")

// Accept terms and conditions
doc.actionFormCheckbox("css:input[name='accept-terms']")

// Enable notifications
doc.actionFormCheckbox("xpath://input[@type='checkbox' and @name='notifications']")

// Select multiple options
doc.actionFormCheckbox("css:.feature-checkbox[data-feature='advanced-auth']")
doc.actionFormCheckbox("css:.feature-checkbox[data-feature='audit-logs']")

// Privacy settings
doc.actionFormCheckbox("id:privacy-analytics-opt-out")
```

<a id="docactionformsubmitformpath"></a>

### `doc.actionFormSubmit(formPath)`

通过直接定位表单元素来提交表单。

参数：

- `formPath`（字符串）：指向要提交的表单的元素选择器路径。

用法：

将此方法用作选择提交按钮的替代方法，尤其是在使用 JavaScript 提交表单或提交按钮难以定位时。

示例：

```javascript
// Submit login form directly
doc.actionFormSubmit("id:login-form")

// Submit by form class
doc.actionFormSubmit("css:.authentication-form")

// Submit form by name attribute
doc.actionFormSubmit("name:user-login")

// Submit nested form
doc.actionFormSubmit("xpath://div[@class='auth-container']//form")

// Complete authentication flow
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionFormSubmit("css:form[action='/authenticate']")
```

<a id="docactionleftclickonpath"></a>

### `doc.actionLeftClick(onPath)`

对任何可点击元素执行鼠标左键点击。

参数：

- `onPath`（字符串）：指向要点击的元素的元素选择器路径。

用法：

左键点击按钮、链接、标签页和其他交互式元素。

示例：

```javascript
// Click submit button
doc.actionLeftClick("css:button[type='submit']")

// Click login button by ID
doc.actionLeftClick("id:login-btn")

// Click link to navigate
doc.actionLeftClick("css:a[href='/dashboard']")

// Click tab or navigation element
doc.actionLeftClick("xpath://li[@data-tab='profile']")

// Click custom button
doc.actionLeftClick("css:.btn-primary[data-action='authenticate']")

// Handle multi-step flows
doc.actionLeftClick("id:next-step")
doc.actionLeftClick("css:button[data-step='verify']")

// Click modal or overlay buttons
doc.actionLeftClick("css:.modal button[data-dismiss='modal']")
```

<a id="authentication-validation-methods"></a>

## 认证验证方法

您应确保脚本包含成功或失败方法。成功和失败的配置变量也可与认证脚本一起使用。

| 方法 | 描述 |
|--------|-------------|
| `auth.successIfAtURL(url)` | 如果位于指定 URL，则将认证标记为成功。 |
| `auth.successIfElementFound(path)` | 如果元素存在，则将认证标记为成功。 |
| `auth.failedIfAtURL(url)` | 如果位于指定 URL，则将认证标记为失败。 |
| `auth.failedIfElementFound(path)` | 如果元素存在，则将认证标记为失败。 |

<a id="authsuccessifelementfoundpath"></a>

### `auth.successIfElementFound(path)`

如果当前页面上存在指定元素，则将认证标记为成功。

参数：

- `path`（字符串）：成功认证后应存在的元素选择器路径。

用法：

当基于 URL 的验证不足时使用此方法，例如对于单页应用程序，或当特定 UI 元素指示认证状态时。

示例：

```javascript
// Look for user profile menu
auth.successIfElementFound("css:.user-profile-dropdown")

// Check for logout button
auth.successIfElementFound("id:logout-button")

// Look for welcome message
auth.successIfElementFound("xpath://div[contains(text(), 'Welcome back')]")

// Check for authenticated navigation
auth.successIfElementFound("css:nav .authenticated-menu")

// Look for user avatar
auth.successIfElementFound("css:.header .user-avatar")

// Complete example with element-based validation
doc.navigateURL("https://spa.example.com")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionLeftClick("css:button[type='submit']")
auth.successIfElementFound("css:.dashboard-welcome")
```

<a id="authfailedifaturlurl"></a>

### `auth.failedIfAtURL(url)`

如果浏览器位于指定的 URL，则将认证标记为失败。

参数：

- `url`（字符串）：指示认证失败的 URL。

用法：

通过检查错误页面、登录页面重定向或特定失败 URL 来检测认证失败。

示例：

```javascript
// Detect redirect back to login page
auth.failedIfAtURL("https://app.example.com/login")

// Check for error page
auth.failedIfAtURL("https://app.example.com/auth/error")

// Look for access denied page
auth.failedIfAtURL("https://app.example.com/access-denied")

// Account locked page
auth.failedIfAtURL("https://app.example.com/account-locked")

// Complete example with failure detection
doc.navigateURL("https://app.example.com/login")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionLeftClick("css:button[type='submit']")
```

<a id="authfailedifelementfoundpath"></a>

### `auth.failedIfElementFound(path)`

如果当前页面上存在指定元素，则将认证标记为失败。

参数：

- `path`（字符串）：指示认证失败的元素选择器路径。

用法：

检测错误消息、警告横幅或其他指示认证问题的 UI 元素。

示例：

```javascript
// Look for error message
auth.failedIfElementFound("css:.error-message")

// Check for invalid credentials message
auth.failedIfElementFound("xpath://div[contains(text(), 'Invalid username or password')]")

// Look for account locked warning
auth.failedIfElementFound("id:account-locked-alert")

// Comprehensive authentication with failure detection
doc.navigateURL("https://app.example.com/login")
doc.actionFormInput("id:email", process.env.USER_EMAIL)
doc.actionFormInput("id:password", process.env.USER_PASSWORD)
doc.actionLeftClick("id:submit-btn")
auth.failedIfElementFound("css:.error-message")

// Multiple failure conditions
auth.failedIfElementFound("css:.alert-danger")
auth.failedIfElementFound("xpath://div[@class='error' and contains(text(), 'Login failed')]")
auth.failedIfAtURL("https://app.example.com/login?error=1")
```

<a id="one-time-password-methods"></a>

## 一次性密码方法

| 方法 | 描述 |
|--------|-------------|
| `otp.generateTOTP()` | 生成基于时间的一次性密码。 |

<a id="otpgeneratetotp"></a>

### `otp.generateTOTP()`

使用配置的密钥生成基于时间的一次性密码（TOTP）。

先决条件：

- TOTP 密钥必须采用 base32 编码，并通过 `DAST_AUTH_OTP_KEY` 提供。
- 应用程序必须接受标准 TOTP 代码（通常是每 30 秒刷新一次的 6 位代码）。

> [!warning]
> 为防止安全风险，请勿在 YAML 作业定义文件中定义 `DAST_AUTH_OTP_KEY`。
> 而应使用极狐GitLab UI 将其创建为掩码 CI/CD 变量。
> 有关更多信息，请参阅[自定义 CI/CD 变量](../../../../../ci/variables/_index.md#for-a-project)。

用法：

对于需要通过 Google Authenticator、Authy 或类似基于 TOTP 的身份验证器应用完成双因素认证的应用程序，可使用此方法。

返回值：

- 包含当前 TOTP 代码的字符串。

示例：

```javascript
// Basic TOTP authentication flow
doc.navigateURL("https://secure.example.com/login")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionFormInput("id:totp-code", otp.generateTOTP())
doc.actionLeftClick("css:button[type='submit']")
auth.successIfAtURL("https://secure.example.com/dashboard")
```

```javascript
// Advanced TOTP with error handling
doc.navigateURL("https://enterprise.example.com/sso")
doc.actionFormInput("id:employee-id", process.env.EMPLOYEE_ID)
doc.actionFormInput("id:password", process.env.EMPLOYEE_PASSWORD)
doc.actionLeftClick("css:.login-submit")

// Check if TOTP is required
const currentUrl = doc.getURL()
if (currentUrl.includes("/mfa")) {
    log.info("MFA required, generating TOTP")
    const code = otp.generateTOTP()
    doc.actionFormInput("css:.mfa-input", code)
    doc.actionLeftClick("css:.mfa-submit")
}

auth.successIfElementFound("css:.employee-portal")
```

<a id="logging-methods"></a>

## 日志记录方法

将消息添加到认证报告中。这在故障排除时可能很有帮助。

| 方法 | 描述 |
|--------|-------------|
| `log.info(msg)` | 记录信息性消息。 |
| `log.debug(msg)` | 记录调试消息。 |
| `log.warn(msg)` | 记录警告消息。 |
| `log.trace(msg)` | 记录跟踪消息。 |
| `log.error(msg)` | 记录错误消息。 |
| `log.errorWithException(ex, msg)` | 记录带有异常详细信息的错误。 |

<a id="loginfomsg"></a>

### `log.info(msg)`

记录提供脚本执行一般信息的信息性消息。

参数：

- `msg`（字符串）：要记录的消息。

用法：

记录一般脚本进度、成功操作以及认证流程中的重要里程碑。

示例：

```javascript
log.info("Starting authentication process")
doc.navigateURL("https://app.example.com/login")

log.info("Filling login credentials")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)

log.info("Submitting login form")
doc.actionLeftClick("css:button[type='submit']")

auth.successIfAtURL("https://app.example.com/dashboard")
log.info("Authentication completed successfully")
```

<a id="logdebugmsg"></a>

### `log.debug(msg)`

记录有助于排查脚本问题的详细调试信息。

参数：

- `msg`（字符串）：要记录的调试消息。

用法：

记录详细的逐步信息、变量值和诊断信息，用于脚本调试。

示例：

```javascript
log.debug("Initializing authentication script")
log.debug("Target URL: https://app.example.com/login")

const username = process.env.USERNAME
log.debug("Username retrieved from environment: " + (username ? "✓" : "✗"))

doc.navigateURL("https://app.example.com/login")
log.debug("Navigation completed")

const currentUrl = doc.getURL()
log.debug("Current URL after navigation: " + currentUrl)

doc.actionFormInput("id:username", username)
log.debug("Username field populated")

doc.actionFormInput("id:password", process.env.PASSWORD)
log.debug("Password field populated")

doc.actionLeftClick("css:button[type='submit']")
log.debug("Login form submitted")
```

<a id="logwarnmsg"></a>

### `log.warn(msg)`

记录可能存在问题但不会阻止执行的条件的警告消息。

参数：

- `msg`（字符串）：要记录的警告消息。

用法：

记录可恢复的问题、回退场景或可能指示问题但不会停止认证流程的条件。

示例：

```javascript
// Check for required environment variables
if (!process.env.USERNAME) {
    log.warn("USERNAME environment variable not set, using default")
    doc.actionFormInput("id:username", "defaultuser")
} else {
    doc.actionFormInput("id:username", process.env.USERNAME)
}

// Handle optional TOTP
const totpSecret = process.env.DAST_AUTH_OTP_KEY
if (!totpSecret) {
    log.warn("DAST_AUTH_OTP_KEY not configured, skipping two-factor authentication")
} else {
    const code = otp.generateTOTP()
    doc.actionFormInput("id:totp", code)
}

// Check for unexpected page content
const currentUrl = doc.getURL()
if (!currentUrl.includes("expected-domain.com")) {
    log.warn("Unexpected domain in URL: " + currentUrl)
}
```

<a id="logtracemsg"></a>

### `log.trace(msg)`

记录非常详细的跟踪信息，用于细粒度调试。

参数：

- `msg`（字符串）：要记录的跟踪消息。

用法：

记录详细信息，包括每个细微步骤和操作。通常用于复杂的调试场景。

示例：

```javascript
log.trace("Script execution starting")
log.trace("Checking environment variables")

log.trace("About to navigate to login page")
doc.navigateURL("https://complex-app.example.com/auth/login")
log.trace("Navigation call completed")

log.trace("Waiting for page load...")
const url = doc.getURL()
log.trace("Current URL: " + url)

log.trace("Locating username field")
doc.actionFormInput("css:input[data-testid='username']", process.env.USERNAME)
log.trace("Username field interaction completed")

log.trace("Locating password field")
doc.actionFormInput("css:input[data-testid='password']", process.env.PASSWORD)
log.trace("Password field interaction completed")

log.trace("Searching for submit button")
doc.actionLeftClick("css:button[data-testid='submit']")
log.trace("Submit button click completed")

log.trace("Authentication flow finished")
```

<a id="logerrormsg"></a>

### `log.error(msg)`

记录可能导致认证失败的严重问题的错误消息。

参数：

- `msg`（字符串）：要记录的错误消息。

用法：

记录严重错误、认证失败或任何阻止脚本成功完成的条件。

**示例：**

```javascript
// Validate required environment variables
if (!process.env.USERNAME || !process.env.PASSWORD) {
    log.error("Required environment variables USERNAME or PASSWORD not set")
    return
}

try {
  // Custom code that can throw exceptions
} catch (e) {
  log.error("Critical error during authentication: " + e.message)
}

doc.navigateURL("https://app.example.com/login")
doc.actionFormInput("id:username", process.env.USERNAME)
doc.actionFormInput("id:password", process.env.PASSWORD)
doc.actionLeftClick("css:button[type='submit']")

// Check for error conditions
const currentUrl = doc.getURL()
if (currentUrl.includes("/error")) {
    log.error("Authentication failed - redirected to error page")
    log.error("Error URL: " + currentUrl)
}

auth.successIfAtURL("https://app.example.com/dashboard")
```

<a id="logerrorwithexceptionex-msg"></a>

### `log.errorWithException(ex, msg)`

记录错误消息以及异常详细信息，以实现全面的错误报告。

参数：

- `ex`（Exception）：包含错误详细信息的异常对象。
- `msg`（字符串）：关于该错误的附加上下文消息。

用法：

捕获异常或处理错误上下文和技术细节都很重要的复杂错误场景。

示例：

```javascript
try {
  log.info("Starting complex authentication flow")

  // Multi-step authentication
  doc.navigateURL("https://enterprise.example.com/login")
  doc.actionFormInput("id:username", process.env.USERNAME)
  doc.actionFormInput("id:password", process.env.PASSWORD)
  doc.actionLeftClick("id:login-btn")

  // Handle TOTP if required
  if (doc.getURL().includes("/mfa")) {
    const totpCode = otp.generateTOTP()
    doc.actionFormInput("id:mfa-code", totpCode)
    doc.actionLeftClick("id:verify-btn")
  }

  auth.successIfAtURL("https://enterprise.example.com/portal")

} catch (authException) {
  log.errorWithException(authException, "Authentication flow failed during login process")

  // Additional error context
  const currentUrl = doc.getURL()
  log.error("Current URL at time of failure: " + currentUrl)

  throw authException
}

// Example with validation error handling
try {
  const username = process.env.USERNAME
  if (!username) {
    throw new Error("USERNAME environment variable is required")
  }

  doc.actionFormInput("id:username", username)
} catch (validationError) {
  log.errorWithException(validationError, "Failed to validate required authentication parameters")
}
```

<a id="element-selectors"></a>

## 元素选择器

认证脚本使用与其他 DAST 变量相同的选择器语法：

- ID 选择器：`id:element-id`
- CSS 选择器：`css:.class-name` 或 `css:button[type="submit"]`
- 名称选择器：`name:field-name`
- XPath 选择器：`xpath://input[@id='username']`

<a id="environment-variables"></a>

## 环境变量

通过环境变量访问敏感认证数据：

```javascript
// Use environment variables for credentials
doc.actionFormInput("id:username", process.env.DAST_AUTH_USERNAME)
doc.actionFormInput("id:password", process.env.DAST_AUTH_PASSWORD)
```

> [!warning]
> 为防止安全风险，请勿在 YAML 作业定义文件中定义敏感信息。
> 而应使用极狐GitLab UI 将其创建为掩码 CI/CD 变量。
> 有关更多信息，请参阅[自定义 CI/CD 变量](../../../../../ci/variables/_index.md#for-a-project)。

<a id="debugging"></a>

## 调试

有两种方式可以了解脚本的执行方式及其执行的操作：认证报告和调试日志。两者都作为产物附加到 DAST 作业。

认证报告包含认证脚本的每个步骤以及屏幕截图，可帮助您调试脚本。报告还包含 HTTP 请求和响应，以及文档对象模型（DOM）。认证报告会为每个 DAST 作业生成，并作为作业产物收集。产物的文件名为 `gl-dast-debug-auth-report.html`。

此外，认证脚本还提供全面的日志记录，以帮助排查认证问题。日志记录会写入作为作业产物附加的调试日志中，文件名为 `gl-dast-scan.log`。所有脚本操作都会自动记录调试信息，显示：

- 环境变量赋值（敏感值已掩码）
- 脚本执行步骤
- URL 导航操作
- 表单输入操作
- 点击操作
- 认证验证结果

调试输出示例：

```plaintext
DBG SCRIPT running user script script="auth_script.js"
DBG SCRIPT doc.navigateURL url="https://example.com/login"
DBG SCRIPT doc.actionFormInput onPath="id:username" value="********"
DBG SCRIPT doc.actionLeftClick onPath="css:button[type='submit']"
INF SCRIPT requirement is satisfied, browser URL matches pattern
```

在脚本中使用日志记录方法添加自定义调试信息：

```javascript
log.info("Starting authentication process")
log.debug("Navigating to login page")
// ... authentication steps ...
log.info("Authentication completed successfully")
```

<a id="troubleshooting"></a>

## 故障排除

使用认证脚本时，您可能会遇到以下问题。

<a id="script-execution-failures"></a>

### 脚本执行失败

您的脚本可能因 JavaScript 格式错误或缺少环境变量而无法运行。

要解决此问题：

- 验证您的脚本语法是有效的 JavaScript。
- 检查是否已设置所有必需的环境变量。
- 使用 `log.debug()` 在认证流程中添加检查点。

<a id="element-selection-issues"></a>

### 元素选择问题

如果您的脚本在目标应用程序中选择元素时遇到问题：

- 在浏览器开发者工具中测试您的选择器。
- 查看包含 DOM 的认证报告。

<a id="authentication-validation-failures"></a>

### 认证验证失败

您的脚本可能无法通过目标应用程序的认证。

要解决此问题：

- 确保您的成功或失败条件准确反映认证状态。
- 检查可能更改预期 URL 的重定向。
- 使用基于元素的验证作为基于 URL 的验证的替代方法。
