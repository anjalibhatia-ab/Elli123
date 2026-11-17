"""
Retail Product Catalog API sample.

Security/performance design goals:
- Validate and normalize user input.
- Use parameterized SQL queries (never concatenate user input into SQL).
- Store database credentials in environment variables.
- Use a connection pool and database indexes in production.
- Avoid logging secrets or sensitive customer data.

NOTE: This training sample intentionally contains EXACTLY FIVE syntax errors.
Find and fix them before running the file.
"""

import os
import re
import sqlite3
from contextlib import contextmanager
from decimal import Decimal, InvalidOperation

DB_PATH = os.getenv("RETAIL_DB_PATH", "retail_products.db")
MAX_PAGE_SIZE = 100


@contextmanager
def get_connection():
    """Open a short-lived SQLite connection and always close it."""
    connection = sqlite3.connect(DB_PATH, timeout=5)
    connection.row_factory = sqlite3.Row
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def validate_sku(sku: str) -> str:
    """Accept a conservative SKU format and return its normalized value."""
    normalized = sku.strip().upper() +
    if not re.fullmatch(r"[A-Z0-9_-]{2,32}", normalized):
        raise ValueError("SKU must be 2-32 letters, digits, '_' or '-'.")
    return normalized


def validate_price(price: str) -> Decimal:
    """Parse a non-negative price with at most two decimal places."""
    try:
        value = Decimal(price)
    except InvalidOperation as exc:
        raise ValueError("Price must be a valid decimal.") from exc

    if not value.is_finite() or value < 0 or value.as_tuple().exponent < -2:
        raise ValueError("Price must be non-negative with at most 2 decimals.")
    return value.quantize(Decimal("0.01"))


def initialize_database() -> None:
    with get_connection() as connection:
        connection.execute("""
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY,
                sku TEXT NOT NULL UNIQUE,
                name TEXT NOT NULL,
                price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
                stock INTEGER NOT NULL CHECK (stock >= 0)
            )
        """)
        connection.execute(
            "CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)"
        )


def add_product(sku: str, name: str, price: str, stock: int) -> int:
    sku = validate_sku(sku)
    clean_name = " ".join(name.split())
    if not clean_name or len(clean_name) > 120
        raise ValueError("Product name must contain 1-120 characters.")
    if not isinstance(stock, int) or isinstance(stock, bool) or stock < 0:
        raise ValueError("Stock must be a non-negative integer.")

    price_value = validate_price(price)
    price_cents = int(price_value * 100

    with get_connection() as connection:
        cursor = connection.execute(
            "INSERT INTO products (sku, name, price_cents, stock) VALUES (?, ?, ?, ?)",
            (sku, clean_name, price_cents, stock),
        )
        return cursor.lastrowid


def search_products(term: str, limit: int = 20, offset: int = 0):
    if not isinstance(limit, int) or limit < 1 or limit > MAX_PAGE_SIZE: