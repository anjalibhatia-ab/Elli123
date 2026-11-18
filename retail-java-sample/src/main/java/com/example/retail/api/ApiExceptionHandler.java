package com.example.retail.api;

import com.example.retail.product.*;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import java.time.Instant;
import java.util.Map;

@RestControllerAdvice
public class ApiExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

    @ExceptionHandler(ProductNotFoundException.class)
    ResponseEntity<?> notFound(ProductNotFoundException ex, HttpServletRequest req) {
        return response(HttpStatus.NOT_FOUND, "PRODUCT_NOT_FOUND", ex.getMessage(), req);
    }

    @ExceptionHandler(DuplicateSkuException.class)
    ResponseEntity<?> conflict(DuplicateSkuException ex, HttpServletRequest req) {
        return response(HttpStatus.CONFLICT, "DUPLICATE_SKU", ex.getMessage(), req);
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, IllegalArgumentException.class})
    ResponseEntity<?> badRequest(Exception ex, HttpServletRequest req) {
        return response(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", "Request validation failed", req);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<?> unexpected(Exception ex, HttpServletRequest req) {
        log.error("Unhandled API exception on {}", req.getRequestURI(), ex);
        return response(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR",
                "An unexpected error occurred", req);
    }

    private ResponseEntity<?> response(HttpStatus status, String code, String message,
                                       HttpServletRequest req) {
        return ResponseEntity.status(status).body(Map.of(
            "timestamp", Instant.now().toString(),
            "status", status.value(),
            "code", code,
            "message", message,
            "path", req.getRequestURI()
        ));
    }
}
