package com.example.retail.product;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.UUID;

public final class ProductDtos {
    private ProductDtos() {}

    public record CreateProductRequest(
        @NotBlank @Size(max = 64) String sku,
        @NotBlank @Size(max = 160) String name,
        @NotNull @DecimalMin("0.01") @Digits(integer = 10, fraction = 2) BigDecimal price,
        @Min(0) @Max(1_000_000) int stock
    ) {}

    public record ProductResponse(UUID id, String sku, String name,
                                  BigDecimal price, int stock, long version) {
        static ProductResponse from(Product p) {
            return new ProductResponse(p.getId(), p.getSku(), p.getName(),
                    p.getPrice(), p.getStock(), p.getVersion());
        }
    }
}
