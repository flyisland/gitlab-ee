---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 教程：从你的提交中移除密钥
---

如果您的应用程序使用外部资源，通常需要使用 **密钥**（如令牌或密钥）对应用程序进行身份验证。如果密钥被推送到远程仓库中，任何有仓库访问权限的人都可以冒充您或您的应用程序。如果您意外提交了某个密钥，仍可以在推送之前将其移除。

在本教程中，您将提交一个伪造的密钥，然后在将其推送到项目之前，从提交历史中移除该密钥。您还将了解当密钥被推送到仓库时该如何处理。

<a id="before-you-begin"></a>

## 开始之前

在完成本教程之前，请确保您具备以下条件：

- 一个测试项目。您可以使用任何喜欢的项目，但建议专门为本教程创建一个测试项目。
- 对命令行 Git 有一定了解。

<a id="commit-a-secret"></a>

## 提交一个密钥

极狐GitLab 通过匹配特定的字母、数字和符号模式来识别密钥。这些模式也用于识别密钥的类型。例如，伪造的密钥 `glpat-12345678901234567890` <!-- gitleaks:allow --> 属于个人访问令牌，因为它以字符串 `glpat-` 开头。

尽管许多密钥可以通过格式进行识别，但您在仓库中工作时仍可能意外提交密钥。我们来模拟一下意外提交密钥的情形：

1. 在您的测试仓库中，检出一个新分支：

   ```shell
   git checkout -b secret-tutorial
   ```

1. 创建一个包含以下内容的新文本文件，移除 `-` 前后的空格以匹配个人访问令牌的精确格式：

   ```txt
   fake-secret: glpat - 12345678901234567890
   message: hello, world!
   ```

1. 将文件提交到您的分支：

   ```shell
   git add .
   git commit -m "Add fake secret"
   ```

这会带来一个问题：如果这些更改被推送，文本文件中的个人访问令牌就会泄露！在继续之前，必须从提交历史中移除该密钥。

<a id="remove-the-secret-from-the-history"></a>

## 从历史记录中移除密钥

如果包含密钥的唯一次提交是 Git 历史中的最近一次提交，您可以通过修订历史来将其移除：

1. 打开文本文件并移除伪造的密钥：

   ```txt
   fake-secret:
   message: hello, world!
   ```

1. 用更改覆盖之前的提交：

   ```shell
   git add .
   git commit --amend
   ```

密钥已从文件和提交历史中移除，您可以安全地推送更改了。

<a id="amending-multiple-commits"></a>

### 修订多次提交

有时，您在进行多次其他提交后才发现添加了密钥。此时，仅从最近一次提交中删除密钥是不够的。您需要对添加密钥之后的每次提交都进行更改：

1. 将伪造的密钥添加到文件中，并将其提交到分支。
1. 至少再进行一次额外的提交。当您查看历史记录时，应该会看到类似以下内容：

   ```shell
   $ git log
   commit 456def

       Do other things

   commit 123abc

       Add fake secret

   ...
   ```

   即使从提交 `456def` 中移除了密钥，它仍然存在于历史中，如果此时推送更改，密钥就会暴露。
1. 要修复历史记录，请从引入密钥的提交开始进行交互式变基：

   ```shell
   git rebase -i 123abc~1
   ```

1. 在编辑窗口中，对于包含密钥的每个提交，将 `pick` 更改为 `edit`：

   ```txt
   edit 456def Do other things
   edit 123abc Add fake secret
   ```

1. 打开文本文件并移除伪造的密钥。
1. 提交您的更改：

   ```shell
   git add .
   git commit --amend
   ```

1. 可选。当您删除密钥时，可能会移除提交中唯一的差异。如果发生这种情况，Git 会显示以下消息：

   ```shell
   No changes
   You asked to amend the most recent commit, but doing so would make it empty.
   ```

   删除空提交：

   ```shell
   git reset HEAD^
   ```

1. 继续变基：

   ```shell
   git rebase --continue
   ```

1. 从下一个提交中移除密钥并继续变基。重复此过程，直到变基完成：

   ```shell
   Successfully rebased and updated refs/heads/secret-tutorial
   ```

密钥已被移除，您可以安全地将更改推送到远程仓库。

<a id="what-to-do-when-you-push-a-secret"></a>

## 当您推送了密钥时该做什么

有时，人们会在注意到更改中包含密钥之前就推送了更改。如果项目中启用了密钥推送保护，推送将被自动阻止，并且会显示违规的提交。

但是，如果密钥被成功推送到远程仓库，它将不再安全，您应立即撤销它。即使您认为没有多少人能访问该密钥，您也应该更换它。暴露的密钥是重大的安全风险。

<a id="next-steps"></a>

## 下一步

为了提高应用程序安全性，请考虑在您的项目中启用至少一种[密钥检测](_index.md)方法。