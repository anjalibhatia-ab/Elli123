package com.example.retail.product;

import com.example.retail.product.ProductDtos.*;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.*;
import java.math.BigDecimal;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ProductServiceTest {
    @Test
    void listMapsProductsToResponseAndUsesRepositoryPage() {
        ProductRepository repository = mock(ProductRepository.class);
        ProductService service = new ProductService(repository);
        Product product = new Product("SKU-100", "Coffee", new BigDecimal("12.50"), 20);
        Pageable pageable = PageRequest.of(0, 25, Sort.by("name"));
        when(repository.findByActiveTrue(pageable))
                .thenReturn(new PageImpl<>(List.of(product), pageable, 1));

        Page<ProductResponse> result = service.list(pageable);

        assertEquals(1, result.getTotalElements());
        assertEquals("SKU-100", result.getContent().getFirst().sku());
        verify(repository).findByActiveTrue(pageable);
    }
}
