package com.example.cleaning.models;

import com.example.cleaning.models.enums.RequestStatus;
import lombok.Data;

import javax.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "product_requests")
@Data
public class ProductRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // ID запроса

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user; // Пользователь, создавший запрос

//    @ManyToOne(fetch = FetchType.LAZY)
//    @JoinColumn(name = "product_id")
//    private Product product; // Продукт, на который создан запрос

    private LocalTime selectedTime; // Выбранное время

    private LocalDate selectedDate; // Выбранная дата

    private LocalDate dateOfCreated;
    // Дата создания запроса
    @Enumerated(EnumType.STRING)
    private RequestStatus status = RequestStatus.PENDING; // Статус запроса (по умолчанию PENDING)

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;


    @PrePersist
    private void onCreate() {
        dateOfCreated = LocalDate.now();
    }
    public String getFormattedSelectedDate() {
        return selectedDate.format(DateTimeFormatter.ofPattern("dd.MM.yyyy"));
    }
    public String getFormattedSelectedTime() {
        return selectedTime.format(DateTimeFormatter.ofPattern("HH:mm"));
    }
    public String getFormattedDateOfCreated() {
        return dateOfCreated.format(DateTimeFormatter.ofPattern("dd.MM.yyyy"));
    }
}
