package com.example.retail.product;

public class DuplicateSkuException extends RuntimeException {
    public DuplicateSkuException(String sku) { super("SKU already exists: " + sku); }
}
