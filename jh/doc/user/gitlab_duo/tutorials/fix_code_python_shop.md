---
stage: Tutorials
group: Tutorials
description: 教程：如何使用极狐GitLab Duo 通过 Python 创建商店应用程序。
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab Duo 通过 Python 创建商店应用程序'
---

<!-- vale gitlab_base.FutureTense = NO -->

您被一家在线书店聘为开发者。当前用于管理库存的系统由电子表格和手动流程混合而成，导致库存错误和更新延迟。您的团队需要创建一个 Web 应用程序，它能够：

- 实时跟踪图书库存。
- 让员工在图书到货时添加新书。
- 防止常见的数据录入错误，例如负数价格或数量。
- 为未来面向客户的功能提供基础。

本教程是系列教程的第一部分，将指导您创建并调试一个带有数据库后端的 [Python](https://www.python.org/) Web 应用程序，以满足这些要求。

您将使用[极狐GitLab Duo Agentic Chat](../../gitlab_duo_chat/agentic_chat.md) 和[极狐GitLab Duo 代码建议](../../duo_agent_platform/code_suggestions/_index.md)来帮助您：

- 使用标准目录和必要文件搭建一个组织良好的 Python 项目。
- 配置 Python 虚拟环境。
- 安装 [Flask](https://flask.palletsprojects.com/en/stable/) 框架，作为 Web 应用程序的基础。
- 安装所需的依赖项，并为开发准备好项目。
- 为 Flask 应用程序开发设置 Python 配置文件和环境变量。
- 实现核心功能，包括 article 模型、数据库操作、API 路由和库存管理功能。
- 测试应用程序是否按预期工作，并将您的代码与示例代码文件进行比较。

<a id="before-you-begin"></a>

## 开始之前

- 在您的系统上[安装最新版本的 Python](https://www.python.org/downloads/)。您可以询问 Chat 如何针对您的操作系统进行安装。
- 与管理员、群组所有者或项目所有者确认您有权访问极狐GitLab Duo。
- 在您首选的 IDE 中安装扩展：
  - [Web IDE](../../project/web_ide/_index.md)：通过您的极狐GitLab 实例访问
  - [VS Code](../../../editor_extensions/visual_studio_code/setup.md)
  - [Visual Studio](../../../editor_extensions/visual_studio/setup.md)
  - [JetBrains IDE](../../../editor_extensions/jetbrains_ide/_index.md)
  - [Neovim](../../../editor_extensions/neovim/setup.md)
- 从 IDE 使用 [OAuth](../../../integration/google.md) 或[具有 `api` 范围的个人访问令牌](../../profile/personal_access_tokens.md#create-a-personal-access-token)向极狐GitLab 进行身份验证。

<a id="use-gitlab-duo-chat-and-code-suggestions"></a>

## 使用极狐GitLab Duo Chat 和代码建议

在本教程中，您将使用 Chat 和代码建议来创建 Python Web 应用程序。使用这些功能有多种方式。

<a id="use-gitlab-duo-chat"></a>

### 使用极狐GitLab Duo Chat

根据您的订阅附加组件，您可以在极狐GitLab UI、Web IDE 或您的 IDE 中使用 Chat。

<a id="use-chat-in-the-gitlab-ui"></a>

#### 在极狐GitLab UI 中使用 Chat

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在极狐GitLab Duo 边栏中，选择 **添加新聊天**（{{< icon name="pencil-square" >}}）。
1. 从下拉列表中选择一个 Agent。

   一个 Chat 对话会在屏幕右侧的极狐GitLab Duo 边栏中打开。
1. 在聊天文本框中输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。
   交互式 AI 聊天可能需要几秒钟才能生成答案。

<a id="use-chat-in-the-web-ide"></a>

#### 在 Web IDE 中使用 Chat

1. 打开 Web IDE：
   1. 在极狐GitLab UI 的顶部栏中，选择**搜索或跳转到**并找到您的项目。
   1. 选择一个文件。然后在右上角，选择**编辑** > **在 Web IDE 中打开**。
1. 使用以下方法之一打开 Chat：
   - 在左侧边栏中，选择**极狐GitLab Duo Chat**。
   - 在编辑器中打开的文件中，选择一些代码。
     1. 右键单击并选择**极狐GitLab Duo Chat**。
     1. 选择**解释所选代码**、**生成测试**或**重构**。
   - 使用键盘快捷键：<kbd>ALT</kbd>+<kbd>d</kbd>（在 Windows 和 Linux 上）或
     <kbd>Option</kbd>+<kbd>d</kbd>（在 Mac 上）。
1. 在消息框中，输入您的问题。按 **Enter**，或选择**发送**。

<a id="use-chat-in-your-ide"></a>

#### 在您的 IDE 中使用 Chat

在 IDE 中使用 Chat 的方式因您使用的 IDE 而异。

{{< tabs >}}

{{< tab title="VS Code" >}}

1. 在 VS Code 中，打开一个文件。该文件不必是 Git 代码仓库中的文件。
1. 在左侧边栏中，选择**极狐GitLab Duo Chat**（{{< icon name="duo-chat" >}}）。
1. 在消息框中，输入您的问题。按 **Enter**，或选择**发送**。
1. 在聊天窗格的右上角，选择**显示状态**以在命令面板中显示信息。

您还可以在处理部分代码时与极狐GitLab Duo Chat 交互。

1. 在 VS Code 中，打开一个文件。该文件不必是 Git 代码仓库中的文件。
1. 在该文件中，选择一些代码。
1. 右键单击并选择**极狐GitLab Duo Chat**。
1. 选择一个选项，或选择**打开快速聊天**并提问，例如
   `Can you simplify this code?`，然后按 <kbd>Enter</kbd>。

有关更多信息，请参阅[在 VS Code 中使用极狐GitLab Duo Chat](../../gitlab_duo_chat/agentic_chat.md#use-gitlab-duo-chat-in-vs-code)。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 在支持 Python 的 JetBrains IDE 中打开一个项目，例如
   [PyCharm](https://www.jetbrains.com/pycharm/) 或 [IntelliJ IDEA](https://www.jetbrains.com/idea/)。
1. [使用极狐GitLab Duo Chat](../../gitlab_duo_chat/agentic_chat.md#use-gitlab-duo-chat-in-jetbrains-ides)。

{{< /tab >}}

{{< /tabs >}}

<a id="use-code-suggestions"></a>

### 使用代码建议

要使用代码建议：

1. 在[受支持的 IDE](../../project/repository/code_suggestions/supported_extensions.md#supported-editor-extensions)中打开您的 Git 项目。

   本地项目必须配置一个指向极狐GitLab 上代码仓库的 Git 远程仓库。如果尚未配置，请使用 [`git remote add`](../../../topics/git/commands.md#git-remote-add) 来关联该项目。
1. 编写您的代码。
   在您输入时，会显示建议。代码建议会根据光标位置提供代码片段或补全当前行。

1. 用自然语言描述需求。
   代码建议会根据提供的上下文生成函数和代码片段。

1. 当您收到建议时，您可以执行以下任一操作：
   - 要接受建议，请按 <kbd>Tab</kbd>。
   - 要接受部分建议，请按 <kbd>Control</kbd>+<kbd>Right arrow</kbd> 或
     <kbd>Command</kbd>+<kbd>Right arrow</kbd>。
   - 要拒绝建议，请按 <kbd>Esc</kbd>。
   - 要忽略建议，请像平常一样继续输入。

有关更多信息，请参阅[代码建议](../../duo_agent_platform/code_suggestions/_index.md)文档。

现在您已经知道如何使用 Chat 和代码建议，让我们开始构建 Web 应用程序。首先，您将创建一个组织良好的 Python 项目结构。

<a id="create-the-project-structure"></a>

## 创建项目结构

首先，您需要一个遵循 Python 最佳实践、组织良好的项目结构。合适的结构能让您的代码更易于维护、测试，也更容易让其他开发者理解。

您可以使用 Chat 来帮助您了解 Python 项目组织约定并生成相应的文件。这可以节省您研究最佳实践的时间，并确保您不会遗漏关键组件。

1. 在您的 IDE 中打开 Chat 并输入：

   ```plaintext
   What is the recommended project structure for a Python web application? Include
   common files, and explain the purpose of each file.
   ```

   此提示可帮助您在创建文件之前了解 Python 项目组织方式。

1. 为 Python 项目创建一个新文件夹，并根据 Chat 的回复创建目录和文件结构。它可能与以下内容类似：

   ```plaintext
   python-shop-app/
   ├── LICENSE
   ├── README.md
   ├── requirements.txt
   ├── setup.py
   ├── .gitignore
   ├── .env
   ├── app/
   │   ├── __init__.py
   │   ├── models/
   │   │   ├── __init__.py
   │   │   └── article.py
   │   ├── routes/
   │   │   ├── __init__.py
   │   │   └── shop.py
   │   └── database.py
   └── tests/
       ├── __init__.py
       └── test_shop.py
   ```

1. 您必须填充 `.gitignore` 文件。在 Chat 中输入以下内容：

   ```plaintext
   Generate a .gitignore file for a Python project that uses Flask, SQLite, and
   virtual environments. Include common IDE files.
   ```

1. 将回复复制到 `.gitignore` 文件中。
1. 对于 `README` 文件，在 Chat 中输入以下内容：

   ```plaintext
   Generate a README.md file for a Python web application that manages a bookstore
   inventory. Make sure that it includes all sections for requirements, setup, and usage.
   ```

现在您已经创建了一个遵循行业最佳实践、结构合理的 Python 项目。这种组织方式使您的代码更易于维护和测试。接下来，您将设置开发环境以开始编写代码。

<a id="set-up-the-development-environment"></a>

## 设置开发环境

正确隔离的开发环境可以防止依赖冲突，并使您的应用程序可部署。

您将使用 Chat 来帮助您设置 Python 虚拟环境，并创建一个包含正确依赖项的 `requirements.txt` 文件。这可以确保您拥有稳定的开发基础。

```plaintext
   python-shop-app/
   ├── LICENSE
   ├── README.md
   ├── requirements.txt <= File you are updating
   ├── setup.py
   ├── .gitignore
   ├── .env
   ├── app/
   │   ├── __init__.py
   │   ├── models/
   │   │   ├── __init__.py
   │   │   └── article.py
   │   ├── routes/
   │   │   ├── __init__.py
   │   │   └── shop.py
   │   └── database.py
   └── tests/
       ├── __init__.py
       └── test_shop.py
```

1. 可选。向 Chat 询问 Python 和 Flask 如何协同工作以生成 Web 应用程序。

1. 使用 Chat 了解设置 Python 环境的最佳实践：

   ```plaintext
   What are the recommended steps for setting up a Python virtual environment with
   Flask? Include information about requirements.txt and pip.
   ```

   根据需要提出任何后续问题。例如：

   ```plaintext
   What does the requirements.txt do in a Python web app?
   ```

1. 根据回复，首先创建并激活虚拟环境（例如，在 MacOS 上使用 Homebrew 的 `python3` 软件包）：

   ```plaintext
   python3 -m venv myenv
   source myenv/bin/activate
   ```

1. 您还必须创建一个 `requirements.txt` 文件。向 Chat 询问以下内容：

   ```plaintext
   What should be included in requirements.txt for a Flask web application with
   SQLite database and testing capabilities? Include specific version numbers.
   ```

   将回复复制到 `requirements.txt` 文件中。

1. 安装 `requirements.txt` 文件中列出的依赖项：

   ```plaintext
   pip install -r requirements.txt
   ```

您的开发环境现已配置好所有必要的依赖项，并隔离在虚拟环境中以防止冲突。接下来，您将配置项目的软件包和环境设置。

<a id="configure-the-project"></a>

## 配置项目

正确的配置（包括环境变量）能让您的应用程序在不同环境中一致地运行。

您将使用代码建议来帮助生成和完善配置。然后，您将请 Chat 解释每项设置的作用，以便您了解自己在配置什么以及为什么这样配置。

1. 您已经在项目文件夹中创建了一个名为 `setup.py`的 Python 配置文件：

   ```plaintext
      python-shop-app/
      ├── LICENSE
      ├── README.md
      ├── requirements.txt
      ├── setup.py <= File you are updating
      ├── .gitignore
      ├── .env
      ├── app/
      │   ├── __init__.py
      │   ├── models/
      │   │   ├── __init__.py
      │   │   └── article.py
      │   ├── routes/
      │   │   ├── __init__.py
      │   │   └── shop.py
      │   └── database.py
      └── tests/
          ├── __init__.py
          └── test_shop.py
   ```

   打开此文件，并在文件顶部输入以下注释：

   ```plaintext
   # Populate this setup.py configuration file for a Flask web application
   # Include dependencies for Flask, testing, and database functionality
   # Use semantic versioning
   ```

   代码建议会为您生成配置。

1. 可选。选择生成的配置代码，并使用以下[斜杠命令](../../gitlab_duo_chat/examples.md#gitlab-duo-chat-slash-commands)：

   - 使用 [`/explain`](../../gitlab_duo_chat/examples.md#explain-selected-code) 来了解每项配置设置的作用。
   - 使用 [`/refactor`](../../gitlab_duo_chat/examples.md#refactor-code-in-the-ide) 来识别配置结构中潜在的改进之处。

1. 根据需要审阅并调整生成的代码。

   如果您不确定可以在配置文件中调整什么，请询问 Chat。

   如果您想询问 Chat 可以调整什么，请在 IDE 中的 `setup.py` 文件里进行，而不是在极狐GitLab UI 中。这样可以为 Chat 提供[您所处的工作上下文](../../duo_agent_platform/context.md#gitlab-duo-agentic-chat)，包括您刚刚创建的 `setup.py` 文件。

   ```plaintext
   You have used Code Suggestions to generate a Python configuration file, `setup.py`,
   for a Flask web application. This file includes dependencies for Flask, testing,
   and database functionality. If I were to review this file, what might I want
   to change and adjust?
   ```

1. 保存文件。

<a id="set-the-environment-variables"></a>

### 设置环境变量

接下来，您将同时使用 Chat 和代码建议来设置环境变量。

1. 在 Chat 中，询问以下内容：

   ```plaintext
   In a Python project, what environment variables should be set for a Flask application in development mode? Include database configuration.
   ```

1. 您已经创建了一个 `.env` 文件来存储环境变量。

   ```plaintext
      python-shop-app/
      ├── LICENSE
      ├── README.md
      ├── requirements.txt
      ├── setup.py
      ├── .gitignore
      ├── .env <= File you are updating
      ├── app/
      │   ├── __init__.py
      │   ├── models/
      │   │   ├── __init__.py
      │   │   └── article.py
      │   ├── routes/
      │   │   ├── __init__.py
      │   │   └── shop.py
      │   └── database.py
      └── tests/
          ├── __init__.py
          └── test_shop.py
   ```

   打开此文件，并在文件顶部输入以下注释，其中包含 Chat 推荐的环境变量：

   ```plaintext
   # Populate this .env file to store environment variables
   # Include the following
   # ...
   # Use semantic versioning
   ```

1. 根据需要审阅并调整生成的代码，然后保存文件。

您已经配置了项目并设置了环境变量。这可以确保您的应用程序能够在不同环境中一致地部署。接下来，您将创建库存系统的应用程序代码。

<a id="create-the-application-code"></a>

## 创建应用程序代码

Flask Web 框架有三个核心组件：

- 模型：包含数据和业务逻辑，以及数据库模型。在 `article.py` 文件中指定。
- 视图：处理 HTTP 请求和响应。在 `shop.py` 文件中指定。
- 控制器：管理数据的存储和检索。在 `database.py` 文件中指定。

您将使用 Chat 和代码建议来帮助您在 Python 项目结构的三个文件中定义这三个组件：

- `article.py` 定义模型组件，具体来说是数据库模型。
- `shop.py` 定义视图组件，具体来说是 API 路由。
- `database.py` 定义控制器组件。

<a id="create-the-article-file-to-define-the-database-model"></a>

### 创建 article 文件以定义数据库模型

您的书店需要数据库模型和操作来有效管理库存。

要为书店库存系统创建应用程序代码，您将使用 article 文件来定义 article 数据库模型。

您将使用代码建议来帮助生成代码，并使用 Chat 来实现数据建模和数据库管理的最佳实践。

1. 您已经创建了一个 `article.py` 文件：

   ```plaintext
      python-shop-app/
      ├── LICENSE
      ├── README.md
      ├── requirements.txt
      ├── setup.py
      ├── .gitignore
      ├── .env
      ├── app/
      │   ├── __init__.py
      │   ├── models/
      │   │   ├── __init__.py
      │   │   └── article.py <= File you are updating
      │   ├── routes/
      │   │   ├── __init__.py
      │   │   └── shop.py
      │   └── database.py
      └── tests/
          ├── __init__.py
          └── test_shop.py
   ```

   在此文件中，使用代码建议并输入以下内容：

   ```plaintext
   # Create an Article class for a bookstore inventory system
   # Include fields for: name, price, quantity
   # Add data validation for each field
   # Add methods to convert to/from dictionary format
   ```

1. 可选。使用以下[斜杠命令](../../gitlab_duo_chat/examples.md#gitlab-duo-chat-slash-commands)：

   - 使用 [`/explain`](../../gitlab_duo_chat/examples.md#explain-selected-code) 来了解 article 类如何工作及其设计模式。
   - 使用 [`/refactor`](../../gitlab_duo_chat/examples.md#refactor-code-in-the-ide) 来识别类结构和方法中潜在的改进之处。

1. 根据需要审阅并调整生成的代码，然后保存文件。

接下来您将定义 API 路由。

<a id="create-the-shop-file-to-define-the-api-routes"></a>

### 创建 shop 文件以定义 API 路由

现在您已经创建了 article 文件来定义数据库模型，接下来您将创建 API 路由。

API 路由对 Web 应用程序至关重要，因为它们：

- 定义供客户端与您的应用程序交互的公共 API。
- 将 HTTP 请求映射到应用程序中的相应代码。
- 处理输入验证和错误响应。
- 在您的内部模型和 API 客户端期望的 JSON 格式之间转换数据。

对于您的书店库存系统，这些路由将允许员工：

- 查看库存中的所有图书。
- 按 ID 查找特定图书。
- 在图书到货时添加新书。
- 更新图书信息，例如价格或数量。
- 移除不再需要的图书。

在 Flask 中，路由是处理对特定 URL 端点请求的函数。例如，`GET /books`的路由会返回所有图书的列表，而 `POST /books` 会向库存中添加一本新书。

您将使用 Chat 和代码建议在您已在项目结构中设置好的 `shop.py` 文件中创建这些路由：

```plaintext
python-shop-app/
├── LICENSE
├── README.md
├── requirements.txt
├── setup.py
├── .gitignore
├── .env
├── app/
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── article.py
│   ├── routes/
│   │   ├── __init__.py
│   │   └── shop.py <= File you are updating
│   └── database.py
└── tests/
   ├── __init__.py
   └── test_shop.py
```

<a id="create-the-flask-application-and-routes"></a>

#### 创建 Flask 应用程序和路由

1. 打开 `shop.py` 文件。要使用代码建议，请在文件顶部输入以下注释：

   ```plaintext
   # Create Flask routes for a bookstore inventory system
   # Include routes for:
   # - Getting all books (GET /books)
   # - Getting a single book by ID (GET /books/<id>)
   # - Adding a new book (POST /books)
   # - Updating a book (PUT /books/<id>)
   # - Deleting a book (DELETE /books/<id>)
   # Use the Article class from models.article and database from database.py
   # Include proper error handling and HTTP status codes
   ```

1. 审阅生成的代码。它应包含：

   - 针对 Flask、request 和 `jsonify`的导入语句。
   - 针对您的 Article 类和数据库模块的导入语句。
   - 所有 CRUD 操作（创建、读取、更新、删除）的路由定义。
   - 适当的错误处理和 HTTP 状态码。

1. 可选。使用以下斜杠命令：

   - 使用 [`/explain`](../../gitlab_duo_chat/examples.md#explain-selected-code) 来了解 Flask 路由如何工作。
   - 使用 [`/refactor`](../../gitlab_duo_chat/examples.md#refactor-code-in-the-ide) 来识别潜在的改进之处。

1. 如果生成的代码不能完全满足您的需求，或者您想了解如何改进它，您可以在 `shop.py` 文件中向 Chat 提问：

   ```plaintext
   Can you suggest improvements for my Flask routes in this shop.py file?
   I want to ensure that:
   1. The routes follow RESTful API design principles
   2. Responses include appropriate HTTP status codes
   3. Input validation is handled properly
   4. The code follows Flask best practices
   ```

1. 您还需要在 `app` 目录内的 `__init__.py` 文件中创建 Flask 应用程序实例。打开此文件并使用代码建议生成相应的代码：

   ```plaintext
   # Create a Flask application factory
   # Configure the app with settings from environment variables
   # Register the shop blueprint
   # Return the configured app
   ```

1. 保存这两个文件。

<a id="create-the-database-file-to-manage-data-storage-and-retrieval"></a>

### 创建数据库文件以管理数据存储和检索

最后，您将创建数据库操作代码。您已经创建了一个 `database.py` 文件：

```plaintext
   python-shop-app/
   ├── LICENSE
   ├── README.md
   ├── requirements.txt
   ├── setup.py
   ├── .gitignore
   ├── .env
   ├── app/
   │   ├── __init__.py
   │   ├── models/
   │   │   ├── __init__.py
   │   │   └── article.py
   │   ├── routes/
   │   │   ├── __init__.py
   │   │   └── shop.py
   │   └── database.py <= File you are updating
   └── tests/
       ├── __init__.py
       └── test_shop.py
```

1. 在 Chat 中输入以下内容：

   ```plaintext
   Generate a Python class that manages SQLite database operations for a bookstore inventory. Include:
   - Context manager for connections
   - Table creation
   - CRUD operations
   - Error handling
   Show the complete code with comments.
   ```

1. 根据需要审阅并调整生成的代码，然后保存文件。

您已成功为库存管理系统创建了基础代码，并定义了使用 Flask 框架构建的 Python Web 应用程序的核心组件。

接下来，您将把创建的代码与示例代码文件进行对照检查。

<a id="check-your-code-against-example-code-files"></a>

## 将您的代码与示例代码文件进行对照检查

以下示例展示了完整、可运行的代码，它们应与您按照本教程操作后得到的代码类似。

{{< tabs >}}

{{< tab title="`.gitignore`" >}}

此文件展示了标准的 Python 项目排除项：

```plaintext
# Virtual Environment
myenv/
venv/
ENV/
env/
.venv/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# SQLite database files
*.db
*.sqlite
*.sqlite3

# Environment variables
.env
.env.local
.env.*.local

# IDE specific files
.idea/
.vscode/
*.swp
*.swo
.DS_Store
```

{{< /tab >}}

{{< tab title="`README.md`" >}}

一份包含设置和使用说明的完整 `README` 文件。

````markdown
# Bookstore Inventory Management System

A Python web application for managing bookstore inventory, built with Flask and SQLite.

## Features

- Track book inventory in real time.
- Add, update, and remove books.
- Data validation to prevent common errors.
- RESTful API for inventory management.

## Requirements

- Python 3.8 or higher.
- Flask 2.2.0 or higher.
- SQLite 3.

## Installation

1. Clone the repository:

   ```shell
   git clone https://gitlab.com/your-username/python-shop-app.git
   cd python-shop-app
   ```

2. Create and activate a virtual environment:

   ```shell
   python -m venv myenv
   source myenv/bin/activate  # On Windows: myenv\Scripts\activate
   ```

3. Install dependencies:

   ```shell
   pip install -r requirements.txt
   ```

4. Set up environment variables:

   Copy `.env.example` to `.env` and modify as needed.

## Usage

1. Start the Flask application:

   ```shell
   flask run
   ```

2. The API will be available at `http://localhost:5000/`

## API Endpoints

- `GET /books` - Get all books
- `GET /books/<id>` - Get a specific book
- `POST /books` - Add a new book
- `PUT /books/<id>` - Update a book
- `DELETE /books/<id>` - Delete a book

## Testing

Run tests with `pytest`:

```python
python -m pytest
```
````

{{< /tab >}}

{{< tab title="`requirements.txt`" >}}

列出所有必需的 Python 软件包及其版本。

```plaintext
Flask==2.2.3
pytest==7.3.1
pytest-flask==1.2.0
Flask-SQLAlchemy==3.0.3
SQLAlchemy==2.0.9
python-dotenv==1.0.0
Werkzeug==2.2.3
requests==2.28.2
```

{{< /tab >}}

{{< tab title="`setup.py`" >}}

用于打包的项目配置。

```python
from setuptools import setup, find_packages

setup(
    name="bookstore-inventory",
    version="0.1.0",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "Flask>=2.2.0",
        "Flask-SQLAlchemy>=3.0.0",
        "SQLAlchemy>=2.0.0",
        "pytest>=7.0.0",
        "pytest-flask>=1.2.0",
        "python-dotenv>=1.0.0",
    ],
    python_requires=">=3.8",
    author="Your Name",
    author_email="your.email@example.com",
    description="A Flask web application for managing bookstore inventory",
    keywords="flask, inventory, bookstore",
    url="https://gitlab.com/your-username/python-shop-app",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Web Environment",
        "Framework :: Flask",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
    ],
)
```

{{< /tab >}}

{{< tab title="`.env`" >}}

包含应用程序的环境变量。

```plaintext
# Flask configuration
FLASK_APP=app
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=your-secret-key-change-in-production

# Database configuration
DATABASE_URL=sqlite:///bookstore.db
TEST_DATABASE_URL=sqlite:///test_bookstore.db

# Application settings
BOOK_TITLE_MAX_LENGTH=100
MAX_PRICE=1000.00
MAX_QUANTITY=1000
```

{{< /tab >}}

{{< tab title="`app/models/article.py`" >}}

带有完整验证的 Article 类。

```python
class Article:
    """Article class for a bookstore inventory system."""

    def __init__(self, name, price, quantity, article_id=None):
        """
        Initialize an article with validation.

        Args:
            name (str): The name/title of the book
            price (float): The price of the book
            quantity (int): The quantity in stock
            article_id (int, optional): The unique identifier for the article

        Raises:
            ValueError: If any of the fields fail validation
        """
        self.id = article_id
        self.set_name(name)
        self.set_price(price)
        self.set_quantity(quantity)

    def set_name(self, name):
        """
        Set the name with validation.

        Args:
            name (str): The name/title of the book

        Raises:
            ValueError: If name is empty or too long
        """
        if not name or not isinstance(name, str):
            raise ValueError("Book title cannot be empty and must be a string")

        if len(name) > 100:  # Max length validation
            raise ValueError("Book title cannot exceed 100 characters")

        self.name = name.strip()

    def set_price(self, price):
        """
        Set the price with validation.

        Args:
            price (float): The price of the book

        Raises:
            ValueError: If price is negative or not a number
        """
        try:
            price_float = float(price)
        except (ValueError, TypeError):
            raise ValueError("Price must be a number")

        if price_float < 0:
            raise ValueError("Price cannot be negative")

        if price_float > 1000:  # Max price validation
            raise ValueError("Price cannot exceed 1000")

        # Ensure price has at most 2 decimal places
        self.price = round(price_float, 2)

    def set_quantity(self, quantity):
        """
        Set the quantity with validation.

        Args:
            quantity (int): The quantity in stock

        Raises:
            ValueError: If quantity is negative or not an integer
        """
        try:
            quantity_int = int(quantity)
        except (ValueError, TypeError):
            raise ValueError("Quantity must be an integer")

        if quantity_int < 0:
            raise ValueError("Quantity cannot be negative")

        if quantity_int > 1000:  # Max quantity validation
            raise ValueError("Quantity cannot exceed 1000")

        self.quantity = quantity_int

    def to_dict(self):
        """
        Convert the article to a dictionary.

        Returns:
            dict: Dictionary representation of the article
        """
        return {
            "id": self.id,
            "name": self.name,
            "price": self.price,
            "quantity": self.quantity
        }

    @classmethod
    def from_dict(cls, data):
        """
        Create an article from a dictionary.

        Args:
            data (dict): Dictionary with article data

        Returns:
            Article: New article instance
        """
        article_id = data.get("id")
        return cls(
            name=data["name"],
            price=data["price"],
            quantity=data["quantity"],
            article_id=article_id
        )
```

{{< /tab >}}

{{< tab title="`app/routes/shop.py`" >}}

带有错误处理的完整 API 端点。

```python
from flask import Blueprint, request, jsonify, current_app
from app.models.article import Article
from app import database
import logging

# Create a blueprint for the shop routes
shop_bp = Blueprint('shop', __name__, url_prefix='/books')

# Set up logging
logger = logging.getLogger(__name__)

@shop_bp.route('', methods=['GET'])
def get_all_books():
    """Get all books from the inventory."""
    try:
        books = database.get_all_articles()
        return jsonify([book.to_dict() for book in books]), 200
    except Exception as e:
        logger.error(f"Error getting all books: {str(e)}")
        return jsonify({"error": "Failed to retrieve books"}), 500

@shop_bp.route('/<int:book_id>', methods=['GET'])
def get_book(book_id):
    """Get a specific book by ID."""
    try:
        book = database.get_article_by_id(book_id)
        if book:
            return jsonify(book.to_dict()), 200
        return jsonify({"error": f"Book with ID {book_id} not found"}), 404
    except Exception as e:
        logger.error(f"Error getting book {book_id}: {str(e)}")
        return jsonify({"error": f"Failed to retrieve book {book_id}"}), 500

@shop_bp.route('', methods=['POST'])
def add_book():
    """Add a new book to the inventory."""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    required_fields = ['name', 'price', 'quantity']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    try:
        # Validate data by creating an Article object
        new_book = Article(
            name=data['name'],
            price=data['price'],
            quantity=data['quantity']
        )

        # Save to database
        book_id = database.add_article(new_book)

        # Return the created book
        created_book = database.get_article_by_id(book_id)
        return jsonify(created_book.to_dict()), 201

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        logger.error(f"Error adding book: {str(e)}")
        return jsonify({"error": "Failed to add book"}), 500

@shop_bp.route('/<int:book_id>', methods=['PUT'])
def update_book(book_id):
    """Update an existing book."""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    try:
        # Check if book exists
        existing_book = database.get_article_by_id(book_id)
        if not existing_book:
            return jsonify({"error": f"Book with ID {book_id} not found"}), 404

        # Update book properties
        if 'name' in data:
            existing_book.set_name(data['name'])
        if 'price' in data:
            existing_book.set_price(data['price'])
        if 'quantity' in data:
            existing_book.set_quantity(data['quantity'])

        # Save updated book
        database.update_article(existing_book)

        # Return the updated book
        updated_book = database.get_article_by_id(book_id)
        return jsonify(updated_book.to_dict()), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        logger.error(f"Error updating book {book_id}: {str(e)}")
        return jsonify({"error": f"Failed to update book {book_id}"}), 500

@shop_bp.route('/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    """Delete a book from the inventory."""
    try:
        # Check if book exists
        existing_book = database.get_article_by_id(book_id)
        if not existing_book:
            return jsonify({"error": f"Book with ID {book_id} not found"}), 404

        # Delete the book
        database.delete_article(book_id)

        return jsonify({"message": f"Book with ID {book_id} deleted successfully"}), 200

    except Exception as e:
        logger.error(f"Error deleting book {book_id}: {str(e)}")
        return jsonify({"error": f"Failed to delete book {book_id}"}), 500
```

{{< /tab >}}

{{< tab title="`app/database.py`" >}}

带有连接管理的数据库操作。

```python
import sqlite3
import os
import logging
from contextlib import contextmanager
from app.models.article import Article

# Set up logging
logger = logging.getLogger(__name__)

# Get database path from environment variable or use default
DATABASE_PATH = os.environ.get('DATABASE_PATH', 'bookstore.db')

@contextmanager
def get_db_connection():
    """
    Context manager for database connections.
    Automatically handles connection opening, committing, and closing.

    Yields:
        sqlite3.Connection: Database connection object
    """
    conn = None
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        # Configure connection to return rows as dictionaries
        conn.row_factory = sqlite3.Row
        yield conn
        conn.commit()
    except sqlite3.Error as e:
        if conn:
            conn.rollback()
        logger.error(f"Database error: {str(e)}")
        raise
    finally:
        if conn:
            conn.close()

def initialize_database():
    """
    Initialize the database by creating the articles table if it doesn't exist.
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            # Create articles table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS articles (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    price REAL NOT NULL,
                    quantity INTEGER NOT NULL
                )
            ''')

            logger.info("Database initialized successfully")
    except sqlite3.Error as e:
        logger.error(f"Failed to initialize database: {str(e)}")
        raise

def add_article(article):
    """
    Add a new article to the database.

    Args:
        article (Article): Article object to add

    Returns:
        int: ID of the newly added article
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute(
                "INSERT INTO articles (name, price, quantity) VALUES (?, ?, ?)",
                (article.name, article.price, article.quantity)
            )

            # Get the ID of the newly inserted article
            article_id = cursor.lastrowid
            logger.info(f"Added article with ID {article_id}")
            return article_id
    except sqlite3.Error as e:
        logger.error(f"Failed to add article: {str(e)}")
        raise

def get_article_by_id(article_id):
    """
    Get an article by its ID.

    Args:
        article_id (int): ID of the article to retrieve

    Returns:
        Article: Article object if found, None otherwise
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("SELECT * FROM articles WHERE id = ?", (article_id,))
            row = cursor.fetchone()

            if row:
                return Article(
                    name=row['name'],
                    price=row['price'],
                    quantity=row['quantity'],
                    article_id=row['id']
                )
            return None
    except sqlite3.Error as e:
        logger.error(f"Failed to get article {article_id}: {str(e)}")
        raise

def get_all_articles():
    """
    Get all articles from the database.

    Returns:
        list: List of Article objects
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("SELECT * FROM articles")
            rows = cursor.fetchall()

            articles = []
            for row in rows:
                article = Article(
                    name=row['name'],
                    price=row['price'],
                    quantity=row['quantity'],
                    article_id=row['id']
                )
                articles.append(article)

            return articles
    except sqlite3.Error as e:
        logger.error(f"Failed to get all articles: {str(e)}")
        raise

def update_article(article):
    """
    Update an existing article in the database.

    Args:
        article (Article): Article object with updated values

    Returns:
        bool: True if successful, False if article not found
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute(
                "UPDATE articles SET name = ?, price = ?, quantity = ? WHERE id = ?",
                (article.name, article.price, article.quantity, article.id)
            )

            # Check if an article was actually updated
            if cursor.rowcount == 0:
                logger.warning(f"No article found with ID {article.id}")
                return False

            logger.info(f"Updated article with ID {article.id}")
            return True
    except sqlite3.Error as e:
        logger.error(f"Failed to update article {article.id}: {str(e)}")
        raise

def delete_article(article_id):
    """
    Delete an article from the database.

    Args:
        article_id (int): ID of the article to delete

    Returns:
        bool: True if successful, False if article not found
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("DELETE FROM articles WHERE id = ?", (article_id,))

            # Check if an article was actually deleted
            if cursor.rowcount == 0:
                logger.warning(f"No article found with ID {article_id}")
                return False

            logger.info(f"Deleted article with ID {article_id}")
            return True
    except sqlite3.Error as e:
        logger.error(f"Failed to delete article {article_id}: {str(e)}")
        raise
```

{{< /tab >}}

{{< tab title="`app/__init__.py`" >}}

Flask 应用程序工厂。

```python
import os
from flask import Flask
from dotenv import load_dotenv

def create_app(test_config=None):
    """
    Application factory for creating the Flask app.

    Args:
        test_config (dict, optional): Test configuration to override default config

    Returns:
        Flask: Configured Flask application
    """
    # Load environment variables from .env file
    load_dotenv()

    # Create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    # Set default configuration
    app.config.from_mapping(
        SECRET_KEY=os.environ.get('SECRET_KEY', 'dev'),
        DATABASE_PATH=os.environ.get('DATABASE_URL', 'bookstore.db'),
        BOOK_TITLE_MAX_LENGTH=int(os.environ.get('BOOK_TITLE_MAX_LENGTH', 100)),
        MAX_PRICE=float(os.environ.get('MAX_PRICE', 1000.00)),
        MAX_QUANTITY=int(os.environ.get('MAX_QUANTITY', 1000))
    )

    # Override config with test config if provided
    if test_config:
        app.config.update(test_config)

    # Ensure the instance folder exists
    os.makedirs(app.instance_path, exist_ok=True)

    # Initialize database
    from app import database
    database.initialize_database()

    # Register blueprints
    from app.routes.shop import shop_bp
    app.register_blueprint(shop_bp)

    # Add a simple index route
    @app.route('/')
    def index():
        return {
            "message": "Welcome to the Bookstore Inventory API",
            "endpoints": {
                "books": "/books",
                "book_by_id": "/books/<id>"
            }
        }

    return app
```

{{< /tab >}}

{{< /tabs >}}

1. 将您的代码文件与这些示例进行对照检查。
1. 要验证您的代码是否正常工作，请询问 Chat 如何启动本地应用程序服务器：

   ```plaintext
   How do I start a local application server for my Python web application?
   ```

1. 按照说明操作，并检查您的应用程序是否正常工作。

如果您的应用程序正常工作，恭喜！您已成功使用极狐GitLab Duo Chat 和代码建议构建了一个可运行的在线商店应用程序。

如果它不能正常工作，那么您需要找出原因。Chat 和代码建议可以帮助您创建测试，以确保您的应用程序按预期工作，并识别需要修复的任何问题。
