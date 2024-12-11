package com.example.cleaning.repositories;// package com.example.buysell.repositories;

import com.example.cleaning.models.ProductRequest;
import com.example.cleaning.models.User;
import com.example.cleaning.models.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface ProductRequestRepository extends JpaRepository<ProductRequest, Long> {
    List<ProductRequest> findAllByProductIdAndSelectedDateAndStatus(
            Long productId, LocalDate selectedDate, RequestStatus status);
    List<ProductRequest> findAllByUser(User user);
   // boolean existsByProductIdAndSelectedDateAndSelectedTimeAndStatus(Long productId, LocalDate selectedDate, LocalTime selectedTime, RequestStatus status);
    ProductRequest findByCompletionToken(String completionToken);
}
