---
stage: none
group: Tutorials
description: Tutorial on how to create a shop application in Python with GitLab Duo.
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab Duo 创建 Python 商店应用'
---

<!-- vale gitlab_base.FutureTense = NO -->

你被一家在线书店聘为开发者。当前的库存管理系统混合使用电子表格和手动流程，导致库存错误和更新延迟。你的团队需要创建一个 Web 应用，能够：

- 实时跟踪图书库存。
- 使员工能够在图书到货时添加新书。
- 防止常见的数据录入错误，例如负价格或数量。
- 为未来的面向客户的功能奠定基础。

本教程是系列教程的第一部分，指导你创建和调试一个满足这些要求的、带有数据库后端的 [Python](https://www.python.org/) Web 应用。

你将使用 [极狐GitLab Duo Agentic Chat](../../gitlab_duo_chat/agentic_chat.md) 和 [极狐GitLab Duo 代码建议](../../duo_agent_platform/code_suggestions/_index.md) 来帮助你：

- 建立一个有组织的 Python 项目，包含标准目录和必要文件。
- 配置 Python 虚拟环境。
- 安装 [Flask](https://flask.palletsprojects.com/en/stable/) 框架作为 Web 应用的基础。
- 安装所需的依赖项，并为开发准备项目。
- 为 Flask 应用开发设置 Python 配置文件和环境变量。
- 实现核心功能，包括文章模型、数据库操作、API 路由和库存管理功能。
- 测试应用是否按预期工作，并将你的代码与示例代码文件进行比较。

<a id="before-you-begin"></a>

## 准备工作

- 在你的系统上 [安装最新版本的 Python](https://www.python.org/downloads/)。你可以向 Chat 询问如何在你的操作系统上执行此操作。
- 与管理员、群组所有者或项目所有者确认你是否有权访问极狐GitLab Duo。
- 在你偏好的 IDE 中安装扩展：
  - [Web IDE](../../project/web_ide/_index.md)：通过你的极狐GitLab 实例访问
- 从 IDE 中使用 [OAuth](../../../integration/google.md) 或 [具有 `api` 范围的个人访问令牌](../../profile/personal_access_tokens.md#create-a-personal-access-token) 向极狐GitLab 进行身份验证。

<a id="use-gitlab-duo-chat-and-code-suggestions"></a>

## 使用极狐GitLab Duo Chat 和代码建议

在本教程中，你将使用 Chat 和代码建议来创建 Python Web 应用。有多种方式可以使用这些功能。

<a id="use-gitlab-duo-chat"></a>

### 使用极狐GitLab Duo Chat

根据你的订阅附加组件，你可以在极狐GitLab UI、Web IDE 或你的 IDE 中使用 Chat。

<a id="use-chat-in-the-gitlab-ui"></a>

#### 在极狐GitLab UI 中使用 Chat

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在极狐GitLab Duo 侧边栏中，选择 **新会话** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中选择一个代理。

   Chat 对话会在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 在聊天文本框中输入你的问题，然后按 <kbd>Enter</kbd> 或选择 **发送**。
   交互式 AI 聊天可能需要几秒钟才能生成答案。

<a id="use-chat-in-the-web-ide"></a>

#### 在 Web IDE 中使用 Chat

1. 打开 Web IDE：
   1. 在极狐GitLab UI 的顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
   1. 选择一个文件。然后在右上角，选择 **编辑** > **在 Web IDE 中打开**。
1. 通过以下方法之一打开 Chat：
   - 在左侧边栏中，选择 **极狐GitLab Duo Chat**。
   - 在编辑器中打开的文件中，选择一些代码。
     1. 右键单击并选择 **极狐GitLab Duo Chat**。
     1. 选择 **解释所选代码**、**生成测试** 或 **重构**。
   - 使用键盘快捷键：<kbd>ALT</kbd>+<kbd>d</kbd>（在 Windows 和 Linux 上）或 <kbd>Option</kbd>+<kbd>d</kbd>（在 Mac 上）。
1. 在消息框中输入你的问题。按 **Enter** 或选择 **发送**。

<a id="use-code-suggestions"></a>

### 使用代码建议

要使用代码建议：

1. 在一个 [支持的 IDE](../../project/repository/code_suggestions/supported_extensions.md#supported-editor-extensions) 中打开你的 Git 项目。
1. 使用 [`git remote add`](../../../topics/git/commands.md#git-remote-add) 将项目添加为本地仓库的远程。
1. 将你的项目目录（包括隐藏的 `.git/` 文件夹）添加到你的 IDE 工作区或项目中。
1. 编写你的代码。
   当你输入时，建议会显示出来。代码建议根据光标位置提供代码片段或完成当前行。

1. 用自然语言描述需求。
   代码建议会根据提供的上下文生成函数和代码片段。

1. 当你收到建议时，可以执行以下任一操作：
   - 要接受建议，按 <kbd>Tab</kbd>。
   - 要接受部分建议，按 <kbd>Control</kbd>+<kbd>Right arrow</kbd> 或 <kbd>Command</kbd>+<kbd>Right arrow</kbd>。
   - 要拒绝建议，按 <kbd>Esc</kbd>。
   - 要忽略建议，继续正常输入即可。

更多信息，请参见 [代码建议](../../duo_agent_platform/code_suggestions/_index.md) 文档。

现在你已了解如何使用 Chat 和代码建议，让我们开始构建 Web 应用。首先，你将创建一个有组织的 Python 项目结构。

<a id="create-the-project-structure"></a>

## 创建项目结构

首先，你需要一个遵循 Python 最佳实践、组织良好的项目结构。合适的结构能让你的代码更易于维护、测试，也更容易被其他开发者理解。

你可以使用 Chat 来帮助你了解 Python 项目组织惯例并生成合适的文件。这能节省你研究最佳实践的时间，并确保你不会遗漏关键组件。

1. 在你的 IDE 中打开 Chat 并输入：

   ```plaintext
   对于 Python Web 应用，推荐的项目结构是什么？包括常见文件，并解释每个文件的作用。
   ```

   这个提示能帮助你在创建文件之前了解 Python 项目组织。

1. 为 Python 项目创建一个新文件夹，并根据 Chat 的响应创建目录和文件结构。它可能与以下内容类似：

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

1. 你必须填充 `.gitignore` 文件。在 Chat 中输入以下内容：

   ```plaintext
   为一个使用 Flask、SQLite 和虚拟环境的 Python 项目生成 .gitignore 文件。包括常见的 IDE 文件。
   ```

1. 将响应复制到 `.gitignore` 文件中。
1. 对于 `README` 文件，在 Chat 中输入以下内容：

   ```plaintext
   为一个管理书店库存的 Python Web 应用生成 README.md 文件。确保它包含所有关于需求、设置和使用的章节。
   ```

你现在已经创建了一个遵循行业最佳实践、结构合理的 Python 项目。这种组织方式使你的代码更易于维护和测试。接下来，你将设置开发环境以开始编写代码。

<a id="set-up-the-development-environment"></a>

## 设置开发环境

一个适当隔离的开发环境可以防止依赖冲突，并使你的应用可部署。

你将使用 Chat 来帮助你设置 Python 虚拟环境，并创建一个包含正确依赖项的 `requirements.txt` 文件。这能确保你拥有一个稳定的开发基础。

```plaintext
   python-shop-app/
   ├── LICENSE
   ├── README.md
   ├── requirements.txt <= 你正在更新的文件
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

1. 可选。向 Chat 询问 Python 和 Flask 如何协同工作以生成 Web 应用。

1. 使用 Chat 了解设置 Python 环境的最佳实践：

   ```plaintext
   使用 Flask 设置 Python 虚拟环境的推荐步骤是什么？包括有关 requirements.txt 和 pip 的信息。
   ```

   根据需要提出任何后续问题。例如：

   ```plaintext
   requirements.txt 在 Python Web 应用中起什么作用？
   ```

1. 根据响应，首先创建并激活虚拟环境（例如，在 MacOS 上使用 Homebrew 的 `python3` 包）：

   ```plaintext
   python3 -m venv myenv
   source myenv/bin/activate
   ```

1. 你还必须创建一个 `requirements.txt` 文件。向 Chat 询问以下内容：

   ```plaintext
   对于带有 SQLite 数据库和测试功能的 Flask Web 应用，requirements.txt 中应包含哪些内容？包括具体的版本号。
   ```

   将响应复制到 `requirements.txt` 文件中。

1. 安装 `requirements.txt`
{{< tabs >}}

{{< tab title="`setup.py`" >}}

```python
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

包含应用的环境变量。

```plaintext
# Flask 配置
FLASK_APP=app
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=your-secret-key-change-in-production

# 数据库配置
DATABASE_URL=sqlite:///bookstore.db
TEST_DATABASE_URL=sqlite:///test_bookstore.db

# 应用设置
BOOK_TITLE_MAX_LENGTH=100
MAX_PRICE=1000.00
MAX_QUANTITY=1000
```

{{< /tab >}}

{{< tab title="`app/models/article.py`" >}}

带有完整校验的 Article 类。

```python
class Article:
    """书店库存系统的 Article 类。"""

    def __init__(self, name, price, quantity, article_id=None):
        """
        初始化一个包含校验的文章对象。

        参数：
            name (str)：书籍的名称/标题
            price (float)：书籍价格
            quantity (int)：库存数量
            article_id (int, 可选)：文章的唯一标识符

        抛出：
            ValueError：如果字段校验失败
        """
        self.id = article_id
        self.set_name(name)
        self.set_price(price)
        self.set_quantity(quantity)

    def set_name(self, name):
        """
        设置名称并进行校验。

        参数：
            name (str)：书籍的名称/标题

        抛出：
            ValueError：如果名称为空或过长
        """
        if not name or not isinstance(name, str):
            raise ValueError("Book title cannot be empty and must be a string")

        if len(name) > 100:  # 最大长度校验
            raise ValueError("Book title cannot exceed 100 characters")

        self.name = name.strip()

    def set_price(self, price):
        """
        设置价格并进行校验。

        参数：
            price (float)：书籍价格

        抛出：
            ValueError：如果价格为负数或不是数字
        """
        try:
            price_float = float(price)
        except (ValueError, TypeError):
            raise ValueError("Price must be a number")

        if price_float < 0:
            raise ValueError("Price cannot be negative")

        if price_float > 1000:  # 最大价格校验
            raise ValueError("Price cannot exceed 1000")

        # 确保价格最多保留两位小数
        self.price = round(price_float, 2)

    def set_quantity(self, quantity):
        """
        设置数量并进行校验。

        参数：
            quantity (int)：库存数量

        抛出：
            ValueError：如果数量为负数或不是整数
        """
        try:
            quantity_int = int(quantity)
        except (ValueError, TypeError):
            raise ValueError("Quantity must be an integer")

        if quantity_int < 0:
            raise ValueError("Quantity cannot be negative")

        if quantity_int > 1000:  # 最大数量校验
            raise ValueError("Quantity cannot exceed 1000")

        self.quantity = quantity_int

    def to_dict(self):
        """
        将文章转换为字典。

        返回：
            dict：文章的字典表示
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
        从字典创建文章对象。

        参数：
            data (dict)：包含文章数据的字典

        返回：
            Article：新的文章实例
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

完整的 API 端点，包含错误处理。

```python
from flask import Blueprint, request, jsonify, current_app
from app.models.article import Article
from app import database
import logging

# 为商店路由创建蓝图
shop_bp = Blueprint('shop', __name__, url_prefix='/books')

# 设置日志记录
logger = logging.getLogger(__name__)

@shop_bp.route('', methods=['GET'])
def get_all_books():
    """获取库存中的所有书籍。"""
    try:
        books = database.get_all_articles()
        return jsonify([book.to_dict() for book in books]), 200
    except Exception as e:
        logger.error(f"获取所有书籍失败：{str(e)}")
        return jsonify({"error": "检索书籍失败"}), 500

@shop_bp.route('/<int:book_id>', methods=['GET'])
def get_book(book_id):
    """通过 ID 获取特定书籍。"""
    try:
        book = database.get_article_by_id(book_id)
        if book:
            return jsonify(book.to_dict()), 200
        return jsonify({"error": f"ID 为 {book_id} 的书籍未找到"}), 404
    except Exception as e:
        logger.error(f"获取书籍 {book_id} 失败：{str(e)}")
        return jsonify({"error": f"检索书籍 {book_id} 失败"}), 500

@shop_bp.route('', methods=['POST'])
def add_book():
    """添加新书籍到库存。"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "未提供数据"}), 400

    required_fields = ['name', 'price', 'quantity']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"缺少必需字段：{field}"}), 400

    try:
        # 通过创建 Article 对象验证数据
        new_book = Article(
            name=data['name'],
            price=data['price'],
            quantity=data['quantity']
        )

        # 保存到数据库
        book_id = database.add_article(new_book)

        # 返回新创建的书籍
        created_book = database.get_article_by_id(book_id)
        return jsonify(created_book.to_dict()), 201

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        logger.error(f"添加书籍失败：{str(e)}")
        return jsonify({"error": "添加书籍失败"}), 500

@shop_bp.route('/<int:book_id>', methods=['PUT'])
def update_book(book_id):
    """更新已有书籍。"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "未提供数据"}), 400

    try:
        # 检查书籍是否存在
        existing_book = database.get_article_by_id(book_id)
        if not existing_book:
            return jsonify({"error": f"ID 为 {book_id} 的书籍未找到"}), 404

        # 更新书籍属性
        if 'name' in data:
            existing_book.set_name(data['name'])
        if 'price' in data:
            existing_book.set_price(data['price'])
        if 'quantity' in data:
            existing_book.set_quantity(data['quantity'])

        # 保存更新后的书籍
        database.update_article(existing_book)

        # 返回更新后的书籍
        updated_book = database.get_article_by_id(book_id)
        return jsonify(updated_book.to_dict()), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        logger.error(f"更新书籍 {book_id} 失败：{str(e)}")
        return jsonify({"error": f"更新书籍 {book_id} 失败"}), 500

@shop_bp.route('/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    """从库存中删除书籍。"""
    try:
        # 检查书籍是否存在
        existing_book = database.get_article_by_id(book_id)
        if not existing_book:
            return jsonify({"error": f"ID 为 {book_id} 的书籍未找到"}), 404

        # 删除书籍
        database.delete_article(book_id)

        return jsonify({"message": f"ID 为 {book_id} 的书籍已成功删除"}), 200

    except Exception as e:
        logger.error(f"删除书籍 {book_id} 失败：{str(e)}")
        return jsonify({"error": f"删除书籍 {book_id} 失败"}), 500
```

{{< /tab >}}

{{< tab title="`app/database.py`" >}}

数据库操作，包含连接管理。

```python
import sqlite3
import os
import logging
from contextlib import contextmanager
from app.models.article import Article

# 设置日志记录
logger = logging.getLogger(__name__)

# 从环境变量获取数据库路径或使用默认值
DATABASE_PATH = os.environ.get('DATABASE_PATH', 'bookstore.db')

@contextmanager
def get_db_connection():
    """
    数据库连接的上下文管理器。
    自动处理连接打开、提交和关闭。

    生成：
        sqlite3.Connection：数据库连接对象
    """
    conn = None
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        # 配置连接以将行作为字典返回
        conn.row_factory = sqlite3.Row
        yield conn
        conn.commit()
    except sqlite3.Error as e:
        if conn:
            conn.rollback()
        logger.error(f"数据库错误：{str(e)}")
        raise
    finally:
        if conn:
            conn.close()

def initialize_database():
    """
    通过创建 articles 表（如果不存在）来初始化数据库。
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            # 创建 articles 表
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS articles (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    price REAL NOT NULL,
                    quantity INTEGER NOT NULL
                )
            ''')

            logger.info("数据库初始化成功")
    except sqlite3.Error as e:
        logger.error(f"数据库初始化失败：{str(e)}")
        raise

def add_article(article):
    """
    向数据库添加新文章。

    参数：
        article (Article)：要添加的 Article 对象

    返回：
        int：新添加文章的 ID
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute(
                "INSERT INTO articles (name, price, quantity) VALUES (?, ?, ?)",
                (article.name, article.price, article.quantity)
            )

            # 获取新插入文章的 ID
            article_id = cursor.lastrowid
            logger.info(f"已添加 ID 为 {article_id} 的文章")
            return article_id
    except sqlite3.Error as e:
        logger.error(f"添加文章失败：{str(e)}")
        raise

def get_article_by_id(article_id):
    """
    通过 ID 获取文章。

    参数：
        article_id (int)：要检索的文章 ID

    返回：
        Article：如果找到则返回 Article 对象，否则返回 None
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
        logger.error(f"获取文章 {article_id} 失败：{str(e)}")
        raise

def get_all_articles():
    """
    从数据库获取所有文章。

    返回：
        list：Article 对象列表
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
        logger.error(f"获取所有文章失败：{str(e)}")
        raise

def update_article(article):
    """
    更新数据库中的已有文章。

    参数：
        article (Article)：包含更新值的 Article 对象

    返回：
        bool：成功返回 True，如果未找到文章则返回 False
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute(
                "UPDATE articles SET name = ?, price = ?, quantity = ? WHERE id = ?",
                (article.name, article.price, article.quantity, article.id)
            )

            # 检查是否实际有文章被更新
            if cursor.rowcount == 0:
                logger.warning(f"未找到 ID 为 {article.id} 的文章")
                return False

            logger.info(f"已更新 ID 为 {article.id} 的文章")
            return True
    except sqlite3.Error as e:
        logger.error(f"更新文章 {article.id} 失败：{str(e)}")
        raise

def delete_article(article_id):
    """
    从数据库中删除文章。

    参数：
        article_id (int)：要删除的文章 ID

    返回：
        bool：成功返回 True，如果未找到文章则返回 False
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("DELETE FROM articles WHERE id = ?", (article_id,))

            # 检查是否实际有文章被删除
            if cursor.rowcount == 0:
                logger.warning(f"未找到 ID 为 {article_id} 的文章")
                return False

            logger.info(f"已删除 ID 为 {article_id} 的文章")
            return True
    except sqlite3.Error as e:
        logger.error(f"删除文章 {article_id} 失败：{str(e)}")
        raise
```

{{< /tab >}}

{{< tab title="`app/__init__.py`" >}}

Flask 应用工厂。

```python
import os
from flask import Flask
from dotenv import load_dotenv

def create_app(test_config=None):
    """
    用于创建 Flask 应用的应用工厂。

    参数：
        test_config (dict, 可选)：用于覆盖默认配置的测试配置

    返回：
        Flask：已配置的 Flask 应用
    """
    # 从 .env 文件加载环境变量
    load_dotenv()

    # 创建并配置应用
    app = Flask(__name__, instance_relative_config=True)

    # 设置默认配置
    app.config.from_mapping(
        SECRET_KEY=os.environ.get('SECRET_KEY', 'dev'),
        DATABASE_PATH=os.environ.get('DATABASE_URL', 'bookstore.db'),
        BOOK_TITLE_MAX_LENGTH=int(os.environ.get('BOOK_TITLE_MAX_LENGTH', 100)),
        MAX_PRICE=float(os.environ.get('MAX_PRICE', 1000.00)),
        MAX_QUANTITY=int(os.environ.get('MAX_QUANTITY', 1000))
    )

    # 如果提供了测试配置，则覆盖配置
    if test_config:
        app.config.update(test_config)

    # 确保实例文件夹存在
    os.makedirs(app.instance_path, exist_ok=True)

    # 初始化数据库
    from app import database
    database.initialize_database()

    # 注册蓝图
    from app.routes.shop import shop_bp
    app.register_blueprint(shop_bp)

    # 添加一个简单的索引路由
    @app.route('/')
    def index():
        return {
            "message": "欢迎使用 Bookstore Inventory API",
            "endpoints": {
                "books": "/books",
                "book_by_id": "/books/<id>"
            }
        }

    return app
```

{{< /tab >}}

{{< /tabs >}}

1. 参照这些示例检查你的代码文件。
1. 要验证你的代码是否正常工作，询问 Chat 如何启动本地应用服务器：

   ```plaintext
   如何为我的 Python Web 应用启动本地应用服务器？
   ```

1. 按照指示操作，检查你的应用是否工作。

如果应用正常工作，恭喜你！你已经成功使用极狐GitLab Duo Chat 和代码建议构建了一个正常运行的在线商店应用。

如果它不能正常工作，你需要找出原因。Chat 和代码建议可以帮助你创建测试，以确保你的应用按预期运行，并找出需要修复的问题。