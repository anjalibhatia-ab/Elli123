import java.math.BigDecimal;
import java.util.Objects;
import java.util.UUID;

public final class OrderService {

    private final PaymentGateway paymentGateway;
    private final OrderRepository orderRepository;

    public OrderService(
            PaymentGateway paymentGateway,
            OrderRepository orderRepository
    ) {
        this.paymentGateway = Objects.requireNonNull(paymentGateway);
        this.orderRepository = Objects.requireNonNull(orderRepository);
    }

    public Order createOrder(String customerId, BigDecimal amount) {
        validate(customerId, amount);

        var order = new Order(
                UUID.randomUUID(),
                customerId,
                amount
        );

        paymentGateway.charge(customerId, amount);
        orderRepository.save(order);

        return order;
    }

    private static void validate(String customerId, BigDecimal amount) {
        if (customerId == null || customerId.isBlank()) {
            throw new IllegalArgumentException("Customer ID is required");
        }

        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("Amount must be greater than zero");
        }
    }

    public record Order(
            UUID id,
            String customerId,
            BigDecimal amount
    ) {
        public Order {
            Objects.requireNonNull(id);
            Objects.requireNonNull(customerId);
            Objects.requireNonNull(amount);
        }
    }

    public interface PaymentGateway {
        void charge(String customerId, BigDecimal amount);
    }

    public interface OrderRepository {
        void save(Order order);
    }
}
