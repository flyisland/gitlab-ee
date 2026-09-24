---
stage: none
group: Tutorials
description: Tutorial on how to fix errors in a shop application in Python with GitLab Duo.
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab Duo 修复 Python 商店应用程序中的错误'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程是系列教程的第二部分。在第一部分中，你
[使用极狐GitLab Duo 创建了一个 Python 商店应用程序](fix_code_python_shop.md)。

如果你已完成第一部分，并且代码运行完美，请通过移除路由中的错误处理来引入一些常见错误。例如，移除 `try` 和 `catch` 块以及输入验证。
然后跟随本教程，在极狐GitLab Duo 的帮助下将它们重新添加回来。

在本教程中，你将：

- 编写全面的测试用例，运行测试，并识别需要修复的问题。
- 改进数据库错误处理和连接管理。
- 实现数据验证。
- 在路由中添加健壮的错误处理。
- 改进 Flask 应用程序配置。
- 验证应用程序是否正常工作。

<a id="write-test-cases"></a>

## 编写测试用例

首先，你将使用 Chat 为我们的 Web 应用程序生成全面的测试用例。

编写良好的、全面的测试用例可以：

- 系统地识别代码中无法正常工作的部分。
- 帮助用户仔细思考每一部分代码在标准和错误条件下应有的行为。
- 创建一个需要修复的问题的优先级列表。
- 允许用户立即验证修复是否有效。

要编写测试用例：

1. 在你的 IDE 中打开 Chat 并输入：

   ```plaintext
   我需要为一个书店库存的 Flask API 编写全面的测试。
   这是当前的最小化测试文件：

   import pytest

   def test_dummy():
       """A dummy test that always passes."""
       assert True

   你能帮我为这个应用程序编写适当的测试吗？该 API 具有以下路由：
   - GET /books - 获取所有图书
   - GET /books/<id> - 获取特定图书
   - POST /books - 添加新书
   - PUT /books/<id> - 更新图书
   - DELETE /books/<id> - 删除图书

   我想测试成功操作和错误处理。
   ```

1. 查看 Chat 的响应。你应该得到一个全面的测试计划，包括设置代码、夹具定义以及每个路由的测试函数。

1. 在查看 Chat 的响应后，可以考虑提出后续问题：

   - 尝试更好地理解测试夹具设计：

     ```plaintext
     你能解释一下为什么使用这些特定的夹具吗？将应用程序夹具与客户端夹具分开有什么好处？
     ```

   - 请 Chat 帮助你了解如何测试特定的错误条件：

     ```plaintext
     我特别关注 POST 和 PUT 路由的错误处理。
     你能增强测试，以覆盖更多边缘情况，如无效数据类型和缺失的必填字段吗？
     ```

   - 要获取有关 Flask 测试的更具体指导，请使用 `/help` 命令：

     ```plaintext
     /help 使用 pytest 进行 Flask 测试
     ```

   - 请 Chat 建议一种让测试运行更快的方法：

     ```plaintext
     这些测试看起来很全面，但在运行整个套件时可能会很慢。
     对于测试设置，你有什么优化建议吗？
     ```

1. 根据需要修改测试计划。在对计划满意后，请 Chat 提供一个完整的测试文件实现：

   ```plaintext
   基于测试计划，提供一个完整的 test_shop.py 文件实现，包括：
   1. 用于设置测试客户端和数据库的夹具
   2. 每个端点的测试，涵盖成功和错误情况
   3. 测试后适当的清理
   ```

1. 将建议的实现复制到你的 `tests/test_shop.py` 文件中。根据你对测试计划的修改，实现应该类似于以下内容：

   ```python
   import pytest
   import json
   from app import create_app
   from app.database import initialize_database, get_db_connection

   @pytest.fixture
   def app():
       """Create and configure a Flask app for testing."""
       app = create_app({"TESTING": True, "DATABASE": "test_bookstore.db"})

       # Initialize the test database
       with app.app_context():
            initialize_database()

       yield app

       # Clean up the test database
       import os
       if os.path.exists("test_bookstore.db"):
          os.remove("test_bookstore.db")

   @pytest.fixture
   def client(app):
       """A test client for the app."""
       return app.test_client()

   @pytest.fixture
   def init_database(app):
       """Initialize the database with test data."""
       conn = get_db_connection()
       cursor = conn.cursor()

       # Add test books
       cursor.execute(
           "INSERT INTO articles (name, price, quantity) VALUES (?, ?, ?)",
           ("Test Book 1", 10.99, 5)
       )
       cursor.execute(
           "INSERT INTO articles (name, price, quantity) VALUES (?, ?, ?)",
           ("Test Book 2", 15.99, 10)
       )

       conn.commit()
       conn.close()

   def test_get_all_books(client, init_database):
       """Test retrieving all books."""
       response = client.get('/books')
       assert response.status_code == 200

       data = json.loads(response.data)
       assert len(data) == 2
       assert data[0]['name'] == 'Test Book 1'
       assert data[1]['name'] == 'Test Book 2'

   def test_get_book_by_id(client, init_database):
       """Test retrieving a specific book by ID."""
       # Test successful retrieval
       response = client.get('/books/1')
       assert response.status_code == 200

       data = json.loads(response.data)
       assert data['name'] == 'Test Book 1'
       assert data['price'] == 10.99

       # Test book not found
       response = client.get('/books/999')
       assert response.status_code == 404

   def test_add_book(client):
       """Test adding a new book."""
       new_book = {
           'name': 'New Test Book',
           'price': 20.99,
           'quantity': 15
       }

       response = client.post('/books',
                            data=json.dumps(new_book),
                            content_type='application/json')

       assert response.status_code == 201

       data = json.loads(response.data)
       assert data['name'] == 'New Test Book'
       assert data['price'] == 20.99
       assert data['quantity'] == 15
       assert 'id' in data

   def test_update_book(client, init_database):
       """Test updating an existing book."""
       update_data = {
           'price': 12.99,
           'quantity': 8
       }

       # Test successful update
       response = client.put('/books/1',
                           data=json.dumps(update_data),
                           content_type='application/json')

       assert response.status_code == 200

       data = json.loads(response.data)
       assert data['name'] == 'Test Book 1'  # Name unchanged
       assert data['price'] == 12.99  # Price updated
       assert data['quantity'] == 8  # Quantity updated

       # Test update for non-existent book
       response = client.put('/books/999',
                           data=json.dumps(update_data),
                           content_type='application/json')

       assert response.status_code == 404

   def test_delete_book(client, init_database):
       """Test deleting a book."""
       # Test successful deletion
       response = client.delete('/books/1')
       assert response.status_code == 200

       # Verify book was deleted
       response = client.get('/books/1')
       assert response.status_code == 404

       # Test deletion of non-existent book
       response = client.delete('/books/999')
       assert response.status_code == 404 # This might fail with current implementation
   ```

你已经为你的 Python Web 应用程序创建了全面的测试用例。

接下来，你将运行测试以识别应用程序中的问题。

<a id="run-tests-to-identify-application-issues"></a>

## 运行测试以识别应用程序问题

运行你在上一部分创建的测试，以识别应用程序中的问题：

```python
pytest -v tests/test_shop.py
```

查看失败的测试，以确定必须修复的问题。

失败的测试结果将类似于以下内容。

<a id="test_delete_book-failure"></a>

### `test_delete_book` - 失败

此测试尝试删除一本书，然后尝试删除一本不存在的书（ID 为 `999`）。测试期望以下行为：

- 成功删除返回 `200` 状态码
- 尝试删除不存在的书返回 `404` 状态码

此测试失败的原因是：

- `app/database.py` 中的 `delete_article` 函数不返回任何状态。
- `delete_book` 路由不会：

  - 在删除前检查书是否存在。
  - 处理书不存在的情况，因此即使对于不存在的书也会返回 `200` 状态码。

<a id="test_update_book-partial-failure"></a>

### `test_update_book` - 部分失败

此测试更新一个现有的书，然后尝试更新一本不存在的书。
不存在的书的部分可能通过，但存在以下问题：

- `database.py` 中的 `update_article` 函数不返回状态。
- 对输入数据没有进行验证。
- 缺少错误处理。

<a id="test_add_book-potential-failure"></a>

### `test_add_book` - 潜在失败

此测试添加一本新书并检查响应是否具有状态码 201。此测试可能会失败，因为：

- `add_book` 路由中没有输入验证。
- 如果数据缺失或无效，没有错误处理。
- `Article` 类不会验证如负价格之类的输入。

<a id="test-client-setup-potential-failure"></a>

### 测试客户端设置 - 潜在失败

测试夹具可能会失败，因为：

- 应用程序没有正确处理测试配置。
- `create_app` 函数没有使用提供的测试配置。
- 数据库路径是硬编码的，因此难以使用测试数据库。

<a id="general-issues-affecting-all-tests"></a>

### 影响所有测试的通用问题

代码库中的几个问题会影响所有测试：

- 数据库操作中没有错误处理。
- 整个应用程序中没有输入验证。
- 硬编码的配置值。
- 缺少重要的环境变量。
- 数据库函数中没有连接管理。

你必须解决这些问题，以使应用程序健壯且可测试。

<a id="next-steps-after-identifying-failing-tests"></a>

### 识别失败测试后的下一步

在看到哪些测试失败后，你将使用 Chat 和代码建议通过以下方式系统地解决这些问题：

- 改进数据库错误处理和连接管理。
- 在 Article 类中实现数据验证。
- 向路由函数添加适当的错误处理。
- 改进应用程序配置。
- 测试并验证修复。

<a id="improve-database-error-handling-and-connection-management"></a>

## 改进数据库错误处理和连接管理

现在，你将使用代码建议（特别是代码生成）来改进数据库错误处理和连接管理：

1. 在你的 IDE 中打开 `app/database.py` 文件。
1. 首先，修复硬编码的数据库路径。将光标定位在定义 `DATABASE_PATH` 的行上，并输入以下内容：

   ```python
   # Replace the hard coded database path with an environment variable for database path with a fallback
   DATABASE_PATH = 'bookstore.db'
   ```

1. 根据需要查看并调整生成的代码。它应该类似于以下内容：

   ```python
   import os
   from dotenv import load_dotenv

   load_dotenv()

   # Use environment variable for database path with a fallback
   DATABASE_PATH = os.getenv('DATABASE_PATH', 'bookstore.db')
   ```

1. 接下来，通过错误处理改进 `get_db_connection()` 函数。将光标定位在函数末尾并输入以下内容：

   ```plaintext
   # Add in missing error handling and connection management.
   ```

1. 查看生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   def get_db_connection():
    """
    Get a database connection.

    Returns:
        sqlite3.Connection: Database connection object

    Raises:
        sqlite3.Error: If connection to database fails
    """
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    except sqlite3.Error as e:
        # Log the error
        print(f"Database connection error: {e}")
        raise
   ```

1. 改进 `delete_article` 函数，以检查是否确实删除了一条记录并返回状态：

   ```plaintext
   # Modify the `delete_article` to return a boolean indicating success if article
   # was deleted, or failure if article was not found
   ```

1. 查看生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   def delete_article(article_id):
    """
    Delete an article from the database.

    Args:
        article_id (int): ID of the article to delete

    Returns:
        bool: True if article was deleted, False if article was not found
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM articles WHERE id = ?", (article_id,))

        deleted = cursor.rowcount > 0
        conn.commit()
        conn.close()
        return deleted
    except sqlite3.Error as e:
        print(f"Error deleting article: {e}")
        return False
   ```

1. 最后，改进 `update_article` 函数以返回表示成功的状态：

   ```plaintext
   # Modify the update_article function to return a boolean indicating success if article
   # was deleted, or failure if article was not found
   ```

1. 查看生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   def update_article(article):
    """
    Update an existing article in the database.

    Args:
        article (Article): Article object with updated values

    Returns:
        bool: True if article was updated, False if article was not found
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute(
            "UPDATE articles SET name = ?, price = ?, quantity = ? WHERE id = ?",
            (article.name, article.price, article.quantity, article.id)
        )

        updated = cursor.rowcount > 0
        conn.commit()
        conn.close()
        return updated
    except sqlite3.Error as e:
        print(f"Error updating article: {e}")
        return False
   ```

做得很好，你已经使用代码建议改进了数据库错误处理和连接管理。接下来，你将使用 Chat 为 `Article` 类实现数据验证。

<a id="implement-data-validation"></a>

## 实现数据验证

现在，你将使用 Chat 来帮助实现 `Article` 类的验证规则：

1. 在你的 IDE 中打开 Chat 并输入：

   ```plaintext
   如何为 Article 类实现数据验证规则？我需要将名称验证为非空字符串，将价格验证为正整数，将数量验证为非负整数，并处理任何验证错误。
   ```

1. 查看响应。考虑提出后续问题以迭代响应：

   - 请 Chat 解释验证实现的某个特定部分：

     ```plaintext
     你能解释一下在这个实现中 ValidationError 类是如何工作的吗？为什么它被定义为内部类而不是单独定义？
     ```

   - 请求 Chat 建议一种更高效的验证方法：

     ```plaintext
     构造函数中的验证逻辑感觉过于冗长。是否有更高效的方式来处理验证，也许使用 Python 装饰器或验证库？
     ```

   - 请 Chat 重构验证代码：

     ```plaintext
     你能重构验证代码使其更易于维护吗？也许将验证逻辑提取到单独的方法中？
     ```

1. 查看重构后的代码响应并实现改进后的 Article 类。它应该类似于以下内容：

   ```python
   class Article:
    """Article class for a bookstore inventory system."""

    class ValidationError(Exception):
        """Exception raised for validation errors in article attributes."""
        pass

    def __init__(self, name, price, quantity, article_id=None):
        """
        Initialize an article.

        Args:
            name (str): The name/title of the book
            price (float): The price of the book
            quantity (int): The quantity in stock
            article_id (int, optional): The unique identifier for the article

        Raises:
            ValidationError: If any of the inputs fail validation
        """
        self.id = article_id

        # Validate name
        if not name or not isinstance(name, str) or len(name.strip()) == 0:
            raise self.ValidationError("Article name must be a non-empty string")
        self.name = name.strip()

        # Validate price
        try:
            price_float = float(price)
            if price_float <= 0:
                raise self.ValidationError("Price must be a positive number")
            self.price = price_float
        except (ValueError, TypeError):
            raise self.ValidationError("Price must be a valid number")

        # Validate quantity
        try:
            quantity_int = int(quantity)
            if quantity_int < 0:
                raise self.ValidationError("Quantity cannot be negative")
            self.quantity = quantity_int
        except (ValueError, TypeError):
            raise self.ValidationError("Quantity must be a valid integer")

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

        Raises:
            ValidationError: If the dictionary is missing required fields or data fails validation
            KeyError: If a required key is missing from the dictionary
        """
        # Validate required fields
        required_fields = ["name", "price", "quantity"]
        for field in required_fields:
            if field not in data:
                raise cls.ValidationError(f"Missing required field: {field}")

        article_id = data.get("id")

        # Create and return new article with validation
        return cls(
            name=data["name"],
            price=data["price"],
            quantity=data["quantity"],
            article_id=article_id
        )
   ```

1. 可选。要获得更专业的验证，请向 Chat 询问除基本类型检查之外的其他 Python 数据验证技术。

   如果需要，可以使用 `/explain` 斜杠命令来了解任何额外的技术。

你已经使用极狐GitLab Duo Chat 为 `Article` 类实现了数据验证。

接下来，你将使用代码建议来改进路由中的错误处理。

<a id="implement-error-handling-in-routes"></a>

## 在路由中实现错误处理

现在，你将使用代码建议来改进路由中的错误处理：

1. 在你的 IDE 中打开 `app/routes/shop.py` 文件。
1. 首先，让我们为 GET 路由添加更好的错误处理。将光标定位在 `get_all_books` 函数的开头，然后输入以下内容：

   ```plaintext
   # Implement error handling in the get_all_books function
   ```

1. 查看生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   @shop_bp.route('', methods=['GET'])
   def get_all_books():
    """Get all books from the inventory."""
    try:
        books = database.get_all_articles()
        return jsonify([book.to_dict() for book in books])
    except Exception as e:
        # Log the error
        print(f"Error retrieving books: {e}")
        return jsonify({"error": "Failed to retrieve books", "details": str(e)}), 500
   ```

1. 接下来，使用代码建议更新 `add_book` 函数，使其具有适当的验证和错误处理。在 `add_book` 函数的开头输入以下内容：

   ```plaintext
   # Add validation for input data in the `add_book` route, implement proper
   # error handling, and enhance the `Article` class with validation for name,
   # price, and quantity
   ```

1. 查看生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   @shop_bp.route('', methods=['POST'])
   def add_book():
    """Add a new book to the inventory."""
    try:
        # Check if request contains JSON data
        if not request.is_json:
            return jsonify({"error": "Request must be JSON"}), 400

        data = request.get_json()

        # Validate required fields
        required_fields = ["name", "price", "quantity"]
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400

        # Create new book with validation
        try:
            new_book = Article(
                name=data['name'],
                price=data['price'],
                quantity=data['quantity']
            )
        except Article.ValidationError as e:
            return jsonify({"error": "Validation error", "details": str(e)}), 400

        # Add to database
        book_id = database.add_article(new_book)
        if book_id:
            created_book = database.get_article_by_id(book_id)
            return jsonify(created_book.to_dict()), 201
        else:
            return jsonify({"error": "Failed to add book to database"}), 500

    except Exception as e:
        # Log the error
        print(f"Error adding book: {e}")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500
   ```

1. 更新 `delete_book` 函数，以检查书是否存在并正确处理错误。在 `delete_book` 函数的开头输入以下内容：

   ```plaintext
   # Update the `delete_book` route to check if the book exists before deletion,
   # and return a 404 status code if the book does not exist
   ```

1. 检查生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   @shop_bp.route('/<int:book_id>', methods=['DELETE'])
   def delete_book(book_id):
    """Delete a book from the inventory."""
    try:
        # Check if book exists before deletion
        existing_book = database.get_article_by_id(book_id)
        if not existing_book:
            return jsonify({"error": "Book not found"}), 404

        # Delete the book
        success = database.delete_article(book_id)
        if success:
            return jsonify({"message": "Book deleted successfully"}), 200
        else:
            return jsonify({"error": "Failed to delete book"}), 500

    except Exception as e:
        # Log the error
        print(f"Error deleting book: {e}")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500
   ```

1. 最后，使用代码建议来改进 `update_book` 函数的错误处理。在 `update_book` 函数的开头输入以下内容：

   ```plaintext
   # Update the `update_book` route to check if the book exists before updating,
   # update the book with price and quantity validation, save the updated book,
   # and return a 500 status code if the book does not exist
   ```

1. 检查生成的代码并根据需要进行调整。它应该类似于以下内容：

   ```python
   @shop_bp.route('/<int:book_id>', methods=['PUT'])
   def update_book(book_id):
    """Update an existing book."""
    try:
        # Check if request contains JSON data
        if not request.is_json:
            return jsonify({"error": "Request must be JSON"}), 400

        data = request.get_json()

        # Check if book exists
        existing_book = database.get_article_by_id(book_id)
        if not existing_book:
            return jsonify({"error": "Book not found"}), 404

    ```
<a id="improve-flask-application-configuration"></a>

## 改进 Flask 应用配置

你要做的最后一项改进是使用 Chat 来优化 Flask 应用配置。

1. 在你的 IDE 中打开 `app/__init__.py` 文件。
1. 在你的 IDE 中打开 Chat 并输入：

   ```plaintext
   我需要改进这个 Flask 应用初始化代码，特别是 `create_app` 函数中定义的安全配置和环境变量处理。
   ```

1. 查看回复。可以考虑问以下后续问题来进一步改进 `create_app` 函数：

   - 询问具体的安全改进：

     ```plaintext
     处理 Flask 应用中密钥的最佳实践是什么？如何在开发和生产环境中以不同方式生成和管理密钥？
     ```

   - 询问 Flask 应用结构的最佳实践：

     ```plaintext
     除了配置处理，你对这个 Flask 应用还有哪些架构改进建议？专业的 Flask 应用通常会如何以不同方式组织这些代码？
     ```

   - 询问配置选择的影响：

     ```plaintext
     你能解释一下这些配置选择的安全影响吗？为了实现安全部署，我还应该了解哪些其他 Flask 配置选项？
     ```

1. 根据回复改进 `create_app` 函数。根据你提出的后续问题，该函数应该类似于以下内容：

   ```python
   from flask import Flask

   def create_app(test_config=None):
    """
    创建 Flask 应用的应用工厂。

    参数:
        test_config (dict, 可选): 用于覆盖默认配置的测试配置

    返回:
        Flask: 配置好的 Flask 应用
    """
    # 创建并配置应用
    app = Flask(__name__)

    # 设置默认配置
    app.config.from_mapping(
        SECRET_KEY='dev',  # 硬编码的密钥
    )

    # 缺少来自环境变量的配置
    # 缺少测试配置处理

    # 初始化数据库
    from app import database
    database.initialize_database()

    # 注册蓝图
    from app.routes.shop import shop_bp
    app.register_blueprint(shop_bp)

    # 添加简单的索引路由
    @app.route('/')
    def index():
        return {
            "message": "欢迎使用书店库存 API"
        }

    return app
   ```

1. 接下来，你将更新 `create_app` 来正确处理测试配置，通过使用环境变量来指定数据库路径，而不是硬编码。在 Chat 中输入以下内容。

   ```plaintext
   如何更新 create_app 来正确处理测试配置并使用环境变量？
   ```

1. 查看生成的代码并根据需要进行调整。它应该看起来类似于以下内容：

   ```python
   import os
   from flask import Flask
   from dotenv import load_dotenv

   load_dotenv()  # 从 .env 文件加载环境变量

   def create_app(test_config=None):
    """
    创建 Flask 应用的应用工厂。

    参数:
        test_config (dict, 可选): 用于覆盖默认配置的测试配置

    返回:
        Flask: 配置好的 Flask 应用
    """
    # 创建并配置应用
    app = Flask(__name__)

    # 设置默认配置
    app.config.from_mapping(
        SECRET_KEY=os.getenv('SECRET_KEY', 'dev'),
        DATABASE_PATH=os.getenv('DATABASE_PATH', 'bookstore.db'),
        DEBUG=os.getenv('FLASK_ENV') == 'development',
    )

    # 如果提供了测试配置，则覆盖
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

    # 添加简单的索引路由
    @app.route('/')
    def index():
        return {
            "message": "欢迎使用书店库存 API",
            "version": "1.0",
            "endpoints": {
                "GET /books": "获取所有书籍",
                "GET /books/<id>": "获取特定书籍",
                "POST /books": "添加新书",
                "PUT /books/<id>": "更新书籍",
                "DELETE /books/<id>": "删除书籍"
            }
        }

    # 添加错误处理器
    @app.errorhandler(404)
    def not_found(e):
        return {"error": "未找到"}, 404

    @app.errorhandler(500)
    def server_error(e):
        return {"error": "内部服务器错误"}, 500

    return app
   ```

1. 最后，创建一个改进的 `.env` 文件，包含正确的配置：

   ```python
   FLASK_APP=app
   FLASK_ENV=development
   SECRET_KEY=your_secure_secret_key_for_development
   DATABASE_PATH=bookstore.db
   ```

1. 可选。向 Chat 询问有关环境变量的安全最佳实践，以进一步改进配置处理：

   ```plaintext
   /security 处理 Flask 应用中环境变量和敏感配置的最佳实践是什么？
   ```

   根据提供的指导进一步改进你的配置处理。

<a id="run-tests-again-and-verify-the-application-works"></a>

## 再次运行测试并验证应用程序正常工作

现在你已经修复了问题并做出了改进，让我们验证一切是否正常运行：

1. 再次运行测试以确保所有测试通过：

   ```python
   pytest -v tests/test_shop.py
   ```

1. 启动 Flask 应用：

   ```python
   flask run
   ```

1. 使用有效和无效的输入测试 API 端点。你可以使用像 [Postman](https://www.postman.com/) 或 [curl](https://curl.se/) 这样的 API 开发工具，对以下端点进行测试。

   - 发送有效请求的 `GET /books`。
   - 使用有效 ID 的 `GET /books/1`。
   - 使用无效 ID 的 `GET /books/999`。
   - 使用有效和无效数据（例如，缺少字段、负价格）的 `POST /books`。
   - 使用有效和无效数据的 `PUT /books/1`。
   - `DELETE /books/1`。
   - 使用不存在 ID 的 `DELETE /books/999`。

1. 验证所有错误情况下的错误处理是否正常工作。
1. 可选。询问 Chat 如何验证错误处理是否正确工作。

<a id="summary"></a>

## 总结

在本教程中，你使用 Chat 和代码建议完成了以下工作：

- 编写全面的测试用例，运行测试，并找出需要修复的问题。
- 改进数据库错误处理和连接管理。
- 实现数据验证。
- 在路由中添加健壮的错误处理。
- 改进 Flask 应用配置。
- 验证应用程序是否正常工作。

这些改进使应用变得更加可靠、安全和易于维护。