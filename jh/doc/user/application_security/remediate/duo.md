---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 AI 解决漏洞
---

{{< details >}}

- Tier: 旗舰版
- Add-on: 极狐GitLab Duo Enterprise, 极狐GitLab Duo with Amazon Q
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../gitlab_duo/model_selection.md#default-models)
- Amazon Q 的 LLM：Amazon Q Developer
- 是否可用于[自部署模型的极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md)：是

{{< /collapsible >}}

极狐GitLab Duo 漏洞解决功能可帮助您自动解决安全漏洞。


有关更多信息，请参阅[如何启用所有极狐GitLab Duo 功能](../../gitlab_duo/turn_on_off.md)。

<a id="use-ai-assistance-responsibly"></a>

## 负责任地使用 AI 辅助

与所有基于 AI 的系统一样，我们无法保证大语言模型每次都能产生正确的结果。在合并建议的更改之前，您应始终对其进行审查。审查时，请检查：

- 您应用程序的现有功能是否得到保留。
- 漏洞是否按照您组织的标准得到解决。

<a id="supported-vulnerabilities-for-vulnerability-resolution"></a>

## 漏洞解决功能支持的漏洞

为确保建议的解决方案质量高，漏洞解决功能仅适用于特定的一组漏洞。系统根据漏洞的通用弱点枚举（CWE）标识符来决定是否提供漏洞解决功能。

我们根据自动化系统和安全专家的测试，选定了当前这组漏洞。我们正在积极努力，将覆盖范围扩展到更多类型的漏洞。

<details><summary style="color:#5943b6; margin-top: 1em;"><a>查看漏洞解决功能支持的完整 CWE 列表</a></summary>

<ul>
  <li>CWE-23: 相对路径遍历</li>
  <li>CWE-73: 文件名或路径的外部控制</li>
  <li>CWE-78: 操作系统命令中特殊元素的不当中和（‘操作系统命令注入’）</li>
  <li>CWE-80: 网页中与脚本相关的 HTML 标签的不当中和（基本 XSS）</li>
  <li>CWE-89: SQL 命令中特殊元素的不当中和（‘SQL 注入’）</li>
  <li>CWE-116: 输出中的不正确编码或转义</li>
  <li>CWE-118: 可索引资源的不正确访问（‘范围错误’）</li>
  <li>CWE-119: 内存缓冲区边界内操作的不当限制</li>
  <li>CWE-120: 未检查输入大小的缓冲区复制（‘经典缓冲区溢出’）</li>
  <li>CWE-126: 缓冲区过度读取</li>
  <li>CWE-190: 整数溢出或环绕</li>
  <li>CWE-200: 敏感信息暴露给未授权行为者</li>
  <li>CWE-208: 可观察的时序差异</li>
  <li>CWE-209: 生成包含敏感信息的错误消息</li>
  <li>CWE-272: 最小特权违反</li>
  <li>CWE-287: 不当身份验证</li>
  <li>CWE-295: 不正确的证书验证</li>
  <li>CWE-297: 主机不匹配时证书的验证不正确</li>
  <li>CWE-305: 主要弱点导致的身份验证绕过</li>
  <li>CWE-310: 加密问题</li>
  <li>CWE-311: 敏感数据加密缺失</li>
  <li>CWE-323: 在加密中重用 Nonce、密钥对</li>
  <li>CWE-327: 使用已损坏或危险的加密算法</li>
  <li>CWE-328: 使用弱哈希</li>
  <li>CWE-330: 使用不足够随机的值</li>
  <li>CWE-338: 使用密码学上弱的伪随机数生成器（PRNG）</li>
  <li>CWE-345: 数据真实性验证不足</li>
  <li>CWE-346: 来源验证错误</li>
  <li>CWE-352: 跨站请求伪造</li>
  <li>CWE-362: 使用共享资源且同步不当的并发执行（‘竞争条件’）</li>
  <li>CWE-369: 除零错误</li>
  <li>CWE-377: 不安全的临时文件</li>
  <li>CWE-378: 创建具有不安全权限的临时文件</li>
  <li>CWE-400: 不受控的资源消耗</li>
  <li>CWE-489: 活跃调试代码</li>
  <li>CWE-521: 弱密码要求</li>
  <li>CWE-539: 使用包含敏感信息的持久 Cookie</li>
  <li>CWE-599: OpenSSL 证书验证缺失</li>
  <li>CWE-611: XML 外部实体引用的不当限制</li>
  <li>CWE-676: 使用可能危险的函数</li>
  <li>CWE-704: 不正确的类型转换或强制转换</li>
  <li>CWE-754: 对异常或例外情况的不当检查</li>
  <li>CWE-770: 无限制或节流地分配资源</li>
  <li>CWE-1004: 不带 ‘HttpOnly’ 标志的敏感 Cookie</li>
  <li>CWE-1275: 具有不适当 SameSite 属性的敏感 Cookie</li>
</ul>
</details>

<a id="data-shared-with-third-party-ai-apis-for-vulnerability-resolution"></a>

## 漏洞解决功能与第三方 AI API 共享的数据

以下数据会与第三方 AI API 共享：

- 漏洞名称
- 漏洞描述
- 标识符（CWE、OWASP）
- 包含易受攻击代码行的整个文件
- 易受攻击的代码行（行号）

<a id="workflows"></a>

## 工作流

漏洞解决功能可用于以下工作流：

- 从漏洞报告中解决现有漏洞。
- 在合并请求的上下文中解决漏洞。

<a id="resolve-a-vulnerability-from-the-vulnerability-report"></a>

### 从漏洞报告解决漏洞

先决条件：

- 项目的维护者或所有者角色。
- 该漏洞必须是来自受支持分析器的 SAST 发现项：
  - 任何[极狐GitLab 支持的分析器](../sast/analyzers.md)。
  - 正确集成的第三方 SAST 扫描器，且会报告每个漏洞的漏洞位置和 CWE 标识符。
- 该漏洞必须是[受支持的类型](#supported-vulnerabilities-for-vulnerability-resolution)。

要从漏洞报告解决漏洞：

1. 在左侧边栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 选择**安全** > **漏洞报告**。
1. 可选。要移除默认筛选条件，请选择**清除**（{{< icon name="clear" >}}）。
1. 在漏洞列表上方，选择筛选栏。
1. 在出现的下拉列表中，选择**活动**，然后在**极狐GitLab Duo (AI)** 类别中选择**漏洞解决可用**。
1. 在筛选字段外选择。漏洞严重性总计和匹配的漏洞列表会更新。
1. 选择您要解决的 SAST 漏洞。
   - 支持漏洞解决功能的漏洞旁边会显示一个蓝色图标。
1. 在右上角，选择**使用 AI 解决**。如果未显示该按钮，请选择
   **AI 操作**，然后选择**使用 AI 解决**。
   > [!warning]
   > 如果此项目是公开项目，请注意，创建合并请求将公开暴露
   > 该漏洞和提供的解决方案。要私下创建合并请求，
   > 请[创建私有 fork](../../project/merge_requests/confidential.md)，然后重复此
   > 过程。
1. 向合并请求添加一个额外的提交。这会强制运行新的流水线。
1. 在流水线完成后，在
   [流水线安全选项卡](../detect/security_scanning_results.md)上，确认该漏洞不再
   出现。
1. 在漏洞报告上，
   [手动更新该漏洞](../vulnerability_report/_index.md#change-status-of-vulnerabilities)。

包含 AI 修复建议的合并请求会打开。审查建议的更改，然后按照您的标准工作流处理该合并请求。

<a id="resolve-a-vulnerability-in-a-merge-request"></a>

### 在合并请求中解决漏洞

您可以在合并请求中使用极狐GitLab Duo 漏洞解决功能，在漏洞被合并之前修复它们。漏洞解决功能会自动创建一个合并请求建议评论，以解决该漏洞发现项。

先决条件：

- 项目的维护者或所有者角色。
- 该漏洞必须是来自受支持分析器的 SAST 发现项：
  - 任何[极狐GitLab 支持的分析器](../sast/analyzers.md)。
  - 正确集成的第三方 SAST 扫描器，且会报告每个漏洞的漏洞位置和 CWE 标识符。
- 该漏洞必须是[受支持的类型](#supported-vulnerabilities-for-vulnerability-resolution)。

要解决漏洞发现项：

1. 在左侧边栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 选择**合并请求**。
1. 选择一个合并请求。
   - 漏洞解决功能支持的漏洞发现项由 tanuki AI 图标（{{< icon name="tanuki-ai" >}}）标示。
1. 选择受支持的发现项，以打开安全发现项对话框。
1. 在右下角，选择**使用 AI 解决**。

   包含 AI 修复建议的评论会在合并请求中打开。
1. 审查建议的更改，然后按照您的标准工作流应用该合并请求建议。

<a id="troubleshooting"></a>

## 故障排除

漏洞解决功能有时无法生成建议的修复。常见原因包括：

- 检测到误报：
  - 在提出修复建议之前，AI 模型会评估该漏洞是否有效。它可能会判断该漏洞并非真正的漏洞，或者不值得修复。
  - 如果漏洞出现在测试代码中，就可能发生这种情况。即使漏洞出现在测试代码中，您的组织仍可能选择修复它们，但模型有时会将这些评估为误报。
  - 如果您同意该漏洞是误报或不值得修复，则应[忽略该漏洞](../vulnerabilities/_index.md#vulnerability-status-values)并[选择匹配的原因](../vulnerabilities/_index.md#vulnerability-dismissal-reasons)。
    - 要自定义 SAST 配置或报告极狐GitLab SAST 规则的问题，请参阅 [SAST 规则](../sast/rules.md)。
- 临时或意外错误：
  - 错误消息可能会指出 `an unexpected error has occurred`、`the upstream AI provider request timed out`、`something went wrong` 或类似原因。
  - 这些错误可能是由 AI 提供商或极狐GitLab Duo 的临时问题引起的。
  - 新请求可能会成功，因此您可以再次尝试解决该漏洞。
  - 如果您持续看到这些错误，请联系极狐GitLab 寻求帮助。
- `Resolution target could not be found in the merge request, unable to create suggestion` 错误：
  - 当目标分支尚未运行完整的安全扫描流水线时，可能会发生此错误。请参阅[合并请求文档](../detect/security_scanning_results.md)。
