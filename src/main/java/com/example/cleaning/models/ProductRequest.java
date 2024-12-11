package com.example.cleaning.models;

import com.example.cleaning.models.enums.RequestStatus;
import lombok.*;

import javax.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "product_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Boolean completed = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user; // Пользователь, создавший запрос



    private LocalTime selectedTime;

    private LocalDate selectedDate;


    private String completionToken;



    private LocalDate dateOfCreated;
    // Дата создания запроса
    @Enumerated(EnumType.STRING)
    private RequestStatus status = RequestStatus.PENDING;
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
    public String getFormattedEndTime() {
        return endTime != null ? endTime.format(DateTimeFormatter.ofPattern("HH:mm")) : "N/A";
    }
    // In ProductRequest.java
    private LocalTime endTime;

    private int apartmentSize;

    private String address;




}
