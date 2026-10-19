---
stage: Tutorials
group: Tutorials
description: 教程：如何使用极狐GitLab Duo 修复 Python 商店应用中的错误。
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab Duo 修复 Python 商店应用中的错误'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程是系列教程的第二部分。在第一个教程中，您
[使用极狐GitLab Duo 创建了一个 Python 商店应用](fix_code_python_shop.md)。

如果您已按照第一个教程操作，且代码运行正常，可以通过从路由中移除错误处理来引入一些常见错误。例如，移除 `try` 和 `catch` 块以及输入验证。然后按照本教程，在极狐GitLab Duo 的帮助下将它们重新添加回来。

在本教程中，您将：

- 编写全面的测试用例，运行测试，并识别需要修复的问题。
- 改进数据库错误处理和连接管理。
- 实现数据验证。
- 在路由中添加健壮的错误处理。
- 改进 Flask 应用配置。
- 验证应用能够正确运行。

<a id="write-test-cases"></a>

## 编写测试用例

首先，您将使用 Chat 为我们的 Web 应用生成全面的测试用例。

编写良好、全面的测试用例可以：

- 系统地识别代码中不工作的部分。
- 帮助用户仔细思考代码的每个部分在正常和错误情况下应如何表现。
- 创建需要修复的问题的优先级列表。
- 让用户能够立即验证修复是否有效

要编写测试用例：

1. 在 IDE 中打开 Chat 并输入：

   ```plaintext
   I need to write comprehensive tests for a Flask API for a bookstore inventory.
   Here's the current minimal test file:

   import pytest

   def test_dummy():
       """A dummy test that always passes."""
       assert True

   Can you help me write proper tests for the application? The API has routes for:
   - GET /books - Get all books
   - GET /books/<id> - Get a specific book
   - POST /books - Add a new book
   - PUT /books/<id> - Update a book
   - DELETE /books/<id> - Delete a book

   I want to test both successful operations and error handling.
   ```

1. 查看 Chat 的回复。您应该会收到一份全面的
   测试计划，包括设置代码、fixture 定义以及每个路由的测试函数。

1. 查看 Chat 的回复后，可以考虑提出后续问题：

   - 尝试更好地理解测试 fixture 的设计：

     ```plaintext
     Can you explain why you're using these specific fixtures? What's the benefit of
     separating the app fixture from the client fixture?
     ```

   - 请 Chat 帮助您了解如何测试特定的错误情况：

     ```plaintext
     I'm particularly concerned about error handling for the POST and PUT routes.
     Can you enhance the tests to include more edge cases like invalid data types
     and missing required fields?
     ```

   - 如需有关 Flask 测试的更具体指导，请使用 `/help` 命令：

     ```plaintext
     /help Flask testing with pytest
     ```

   - 请 Chat 建议一种让测试运行更快的方法：

     ```plaintext
     These tests seem comprehensive but might be slow when running the full suite.
     Are there any optimizations you'd suggest for the test setup?
     ```

1. 根据需要修改测试计划。对计划满意后，请 Chat
   提供测试文件的完整实现：

   ```plaintext
   Based on the test plan, provide a complete implementation of the test_shop.py file that includes:
   1. Fixtures for setting up a test client and database
   2. Tests for each endpoint with both successful and error cases
   3. Proper cleanup after tests
   ```

1. 将建议的实现复制到您的 `tests/test_shop.py` 文件中。根据
   您对测试计划的修改方式，实现应类似于以下内容：

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

现在，您已经为 Python Web 应用创建了全面的测试用例。

接下来，您将运行测试以识别应用中的问题。

<a id="run-tests-to-identify-application-issues"></a>

## 运行测试以识别应用问题

运行您在上一节中创建的测试，以识别应用中的问题：

```python
pytest -v tests/test_shop.py
```

查看失败的测试，以识别必须修复的问题。

失败的测试结果将类似于以下内容。

<a id="test_delete_book---failure"></a>

### `test_delete_book` - 失败

此测试尝试删除一本书，然后尝试删除一本不存在的书（ID 为 `999`）。该测试期望以下行为：

- 成功删除返回 `200` 状态码
- 尝试删除不存在的书返回 `404` 状态码

此测试失败的原因如下：

- `app/database.py`中的 `delete_article` 函数不返回任何状态。
- `delete_book` 路由不会：

  - 在删除前检查书是否存在。
  - 处理书不存在的情况，因此即使书不存在，它也会返回 `200` 状态码。

<a id="test_update_book---partial-failure"></a>

### `test_update_book` - 部分失败

此测试更新一本现有的书，然后尝试更新一本不存在的书。不存在的书部分可能会通过，但存在以下问题：

- `database.py`中的 `update_article` 函数不返回状态。
- 未对输入数据执行验证。
- 缺少错误处理。

<a id="test_add_book---potential-failure"></a>

### `test_add_book` - 可能失败

此测试添加一本新书，并检查响应是否具有状态码 201。此测试可能失败，原因如下：

- `add_book` 路由中没有输入验证。
- 如果数据缺失或无效，没有错误处理。
- `Article` 类不会验证负价格等输入。

<a id="test-client-setup---potential-failure"></a>

### 测试客户端设置 - 可能失败

测试 fixture 可能失败，原因如下：

- 应用未正确处理测试配置。
- `create_app` 函数未使用提供的测试配置。
- 数据库路径是硬编码的，导致难以使用测试数据库。

<a id="general-issues-affecting-all-tests"></a>

### 影响所有测试的常见问题

代码库中的若干问题会影响所有测试：

- 数据库操作中没有错误处理。
- 整个应用中没有输入验证。
- 配置值是硬编码的。
- 缺少重要的环境变量。
- 数据库函数中没有连接管理。

您必须解决这些问题，才能使应用健壮且可测试。

<a id="next-steps-after-identifying-failing-tests"></a>

### 识别失败测试后的后续步骤

在了解哪些测试失败后，您将使用 Chat 和代码建议来系统地解决这些问题，具体方式如下：

- 改进数据库错误处理和连接管理。
- 在 Article 类中实现数据验证。
- 为路由函数添加适当的错误处理。
- 改进应用配置。
- 测试并验证修复。

<a id="improve-database-error-handling-and-connection-management"></a>

## 改进数据库错误处理和连接管理

现在，您将使用代码建议（具体来说是代码生成）来改进数据库错误处理和连接管理：

1. 在 IDE 中打开 `app/database.py` 文件。
1. 首先，修复硬编码的数据库路径。将光标定位到
   定义 `DATABASE_PATH`的行，并输入以下内容：

   ```python
   # Replace the hard coded database path with an environment variable for database path with a fallback
   DATABASE_PATH = 'bookstore.db'
   ```

1. 查看并根据需要调整生成的代码。它应类似于以下内容：

   ```python
   import os
   from dotenv import load_dotenv

   load_dotenv()

   # Use environment variable for database path with a fallback
   DATABASE_PATH = os.getenv('DATABASE_PATH', 'bookstore.db')
   ```

1. 接下来，使用错误处理改进 `get_db_connection()` 函数。将
   光标定位到该函数的末尾，并输入以下内容：

   ```plaintext
   # Add in missing error handling and connection management.
   ```

1. 查看生成的代码并根据需要调整。它应类似于
   以下内容：

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

1. 改进 `delete_article` 函数，以检查记录是否确实
   被删除并返回状态：

   ```plaintext
   # Modify the `delete_article` to return a boolean indicating success if article
   # was deleted, or failure if article was not found
   ```

1. 查看生成的代码并根据需要调整。它应类似于
   以下内容：

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

1. 最后，改进 `update_article` 函数，以返回表示成功的状态：

   ```plaintext
   # Modify the update_article function to return a boolean indicating success if article
   # was deleted, or failure if article was not found
   ```

1. 查看生成的代码并根据需要调整。它应类似于
   以下内容：

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

做得好，您已经使用代码建议改进了数据库错误处理和连接管理。接下来，您将使用 Chat 为 `Article` 类实现数据验证。

<a id="implement-data-validation"></a>

## 实现数据验证

现在，您将使用 Chat 帮助为 `Article` 类实现验证规则：

1. 在 IDE 中打开 Chat 并输入：

   ```plaintext
   How can I implement data validation rules for the Article class? I need to
   validate name as a non-empty string, price as a positive integer, quantity as
   a non-negative integer, and handle any validation errors.
   ```

1. 查看回复。可以考虑提出后续问题以迭代回复：

   - 请 Chat 解释验证实现的某个特定部分：

     ```plaintext
     Can you explain how the ValidationError class works in this implementation?
     Why is it defined as an inner class rather than separately?
     ```

   - 请 Chat 建议一种更高效的验证方法：

     ```plaintext
     The validation logic in the constructor feels verbose. Is there a more efficient
     way to handle the validation, perhaps using Python decorators or a validation library?
     ```

   - 请 Chat 重构验证代码：

     ```plaintext
     Can you refactor the validation code to make it more maintainable? Perhaps
     extract the validation logic into separate methods?
     ```

1. 查看重构后的代码回复，并实现改进后的 Article 类。
   它应类似于以下内容：

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

1. 可选。如需更专门的验证，请向 Chat 询问基本类型检查之外的
   其他 Python 数据验证技术。

   如有需要，请使用 `/explain` Slash 命令来了解任何其他技术。

您已经使用极狐GitLab Duo Chat 为 `Article` 类实现了数据验证。

接下来，您将使用代码建议改进路由中的错误处理。

<a id="implement-error-handling-in-routes"></a>

## 在路由中实现错误处理

现在，您将使用代码建议改进路由中的错误处理：

1. 在 IDE 中打开 `app/routes/shop.py` 文件。
1. 首先，让我们为 GET 路由添加更好的错误处理。将光标
   定位到 `get_all_books` 函数的开头，并输入以下内容：

   ```plaintext
   # Implement error handling in the get_all_books function
   ```

1. 查看生成的代码并根据需要调整。它应类似于
   以下内容：

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

1. 接下来，使用代码建议更新 `add_book` 函数，添加适当的
   验证和错误处理。在 `add_book` 函数的开头，输入
   以下内容：

   ```plaintext
   # Add validation for input data in the `add_book` route, implement proper
   # error handling, and enhance the `Article` class with validation for name,
   # price, and quantity
   ```

1. 查看生成的代码并根据需要调整。它应类似于
   以下内容：

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

1. 更新 `delete_book` 函数，以检查书是否存在并正确处理
   错误。在 `delete_book` 函数的开头，输入以下内容：

   ```plaintext
   # Update the `delete_book` route to check if the book exists before deletion,
   # and return a 404 status code if the book does not exist
   ```

1. 检查生成的代码并根据需要调整。它应类似于
   以下内容：

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

1. 最后，使用代码建议改进 `update_book`
   函数的错误处理。在 `update_book` 函数的开头，输入以下内容：

   ```plaintext
   # Update the `update_book` route to check if the book exists before updating,
   # update the book with price and quantity validation, save the updated book,
   # and return a 500 status code if the book does not exist
   ```

1. 检查生成的代码并根据需要调整。它应类似于
   以下内容：

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

        # Update book properties with validation
        try:
            if 'name' in data:
                existing_book.name = data['name']
            if 'price' in data:
                existing_book.price = float(data['price'])
                if existing_book.price <= 0:
                    return jsonify({"error": "Price must be a positive number"}), 400
            if 'quantity' in data:
                existing_book.quantity = int(data['quantity'])
                if existing_book.quantity < 0:
                    return jsonify({"error": "Quantity cannot be negative"}), 400
        except (ValueError, TypeError) as e:
            return jsonify({"error": "Invalid data format", "details": str(e)}), 400
        except Article.ValidationError as e:
            return jsonify({"error": "Validation error", "details": str(e)}), 400

        # Save updated book
        success = database.update_article(existing_book)
        if success:
            updated_book = database.get_article_by_id(book_id)
            return jsonify(updated_book.to_dict()), 200
        else:
            return jsonify({"error": "Failed to update book"}), 500

    except Exception as e:
        # Log the error
        print(f"Error updating book: {e}")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500
   ```

做得好，您已经成功改进了路由中的错误处理。

接下来，您将使用 Chat 改进 Flask 应用配置。

<a id="improve-flask-application-configuration"></a>

## 改进 Flask 应用配置

您要做的最后一项改进是使用 Chat 改进 Flask 应用配置。

1. 在 IDE 中打开 `app/__init__.py` 文件。
1. 在 IDE 中打开 Chat 并输入：

   ```plaintext
   I need to improve this Flask application initialization code, specifically
   the security configuration and environment variable handling defined in the
   `create_app` function.
   ```

1. 查看回复。可以考虑提出后续问题以改进 `create_app` 函数：

   - 询问具体的安全改进：

     ```plaintext
     What are the best practices for handling secret keys in a Flask application?
     How should I generate and manage them differently between development and production environments?
     ```

   - 询问 Flask 应用结构的最佳实践：

     ```plaintext
     Are there any architectural improvements you'd suggest for this Flask application
     beyond configuration handling? How would professional Flask applications structure
     this differently?
     ```

   - 请对方解释这些配置选择的影响：

     ```plaintext
     Can you explain the security implications of these configuration choices?
     What other Flask configuration settings should I be aware of for a secure deployment?
     ```

1. 根据回复改进 `create_app` 函数。根据您提出的后续
   问题，该函数应类似于以下内容：

   ```python
   from flask import Flask

   def create_app(test_config=None):
    """
    Application factory for creating the Flask app.

    Args:
        test_config (dict, optional): Test configuration to override default config

    Returns:
        Flask: Configured Flask application
    """
    # Create and configure the app
    app = Flask(__name__)

    # Set default configuration
    app.config.from_mapping(
        SECRET_KEY='dev',  # Hard coded secret key
    )

    # Missing configuration from environment variables
    # Missing test config handling

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
            "message": "Welcome to the Bookstore Inventory API"
        }

    return app
   ```

1. 接下来，您将更新 `create_app`，通过使用
   环境变量来设置数据库路径（而不是硬编码），从而正确处理测试配置。在 Chat 中输入
   以下内容。

   ```plaintext
   How can I update create_app to properly handle test configuration and use
   environment variables
   ```

1. 查看生成的代码并根据需要调整。它应类似于
   以下内容：

   ```python
   import os
   from flask import Flask
   from dotenv import load_dotenv

   load_dotenv()  # Load environment variables from .env file

   def create_app(test_config=None):
    """
    Application factory for creating the Flask app.

    Args:
        test_config (dict, optional): Test configuration to override default config

    Returns:
        Flask: Configured Flask application
    """
    # Create and configure the app
    app = Flask(__name__)

    # Set default configuration
    app.config.from_mapping(
        SECRET_KEY=os.getenv('SECRET_KEY', 'dev'),
        DATABASE_PATH=os.getenv('DATABASE_PATH', 'bookstore.db'),
        DEBUG=os.getenv('FLASK_ENV') == 'development',
    )

    # Override config with test config if provided
    if test_config:
        app.config.update(test_config)

    # Ensure instance folder exists
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
            "version": "1.0",
            "endpoints": {
                "GET /books": "Get all books",
                "GET /books/<id>": "Get a specific book",
                "POST /books": "Add a new book",
                "PUT /books/<id>": "Update a book",
                "DELETE /books/<id>": "Delete a book"
            }
        }

    # Add error handlers
    @app.errorhandler(404)
    def not_found(e):
        return {"error": "Not found"}, 404

    @app.errorhandler(500)
    def server_error(e):
        return {"error": "Internal server error"}, 500

    return app
   ```

1. 最后，创建一个配置正确的改进版 `.env` 文件：

   ```python
   FLASK_APP=app
   FLASK_ENV=development
   SECRET_KEY=your_secure_secret_key_for_development
   DATABASE_PATH=bookstore.db
   ```

1. 可选。向 Chat 询问有关环境变量的安全最佳实践，
   以进一步改进配置处理：

   ```plaintext
   /security What are the best practices for handling environment variables and
   sensitive configuration in a Flask application?
   ```

   使用提供的指导进一步改进您的配置处理。

<a id="run-tests-again-and-verify-the-application-works"></a>

## 再次运行测试并验证应用能够正常工作

现在您已经修复了问题并实施了改进，让我们验证一切都能正确运行：

1. 再次运行测试，确保所有测试都通过：

   ```python
   pytest -v tests/test_shop.py
   ```

1. 启动 Flask 应用：

   ```python
   flask run
   ```

1. 使用有效和无效输入测试 API 端点。为此，
   请使用 API 开发工具（如 [Postman](https://www.postman.com/) 或
   [curl](https://curl.se/)）测试以下端点。

   - 使用有效请求测试 `GET /books`。
   - 使用有效 ID 测试 `GET /books/1`。
   - 使用无效 ID 测试 `GET /books/999`。
   - 使用有效和无效（例如缺少字段、负价格）数据测试 `POST /books`。
   - 使用有效和无效数据测试 `PUT /books/1`。
   - 测试 `DELETE /books/1`。
   - 使用不存在的 ID 测试 `DELETE /books/999`。

1. 验证错误处理在所有错误情况下都能正确工作。
1. 可选。向 Chat 询问如何验证错误处理能够正确工作。

<a id="summary"></a>

## 总结

在本教程中，您使用了 Chat 和代码建议来：

- 编写全面的测试用例，运行测试，并识别需要修复的问题。
- 改进数据库错误处理和连接管理。
- 实现数据验证。
- 在路由中添加健壮的错误处理。
- 改进 Flask 应用配置。
- 验证应用能够正确运行。

这些改进使应用更加可靠、安全且易于维护。

<!-- markdownlint-enable -->
