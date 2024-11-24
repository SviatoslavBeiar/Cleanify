package com.example.cleaning.services;// package com.example.buysell.services;

import com.example.cleaning.exceptions.TimeSlotAlreadyBookedException;
import com.example.cleaning.models.Product;
import com.example.cleaning.models.ProductRequest;
import com.example.cleaning.models.User;
import com.example.cleaning.models.enums.RequestStatus;
import com.example.cleaning.repositories.ProductRepository;
import com.example.cleaning.repositories.ProductRequestRepository;
import com.example.cleaning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.mail.MessagingException;
import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductRequestService {
    private final ProductRequestRepository productRequestRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final MailSenderService mailSenderService;

    public List<ProductRequest> getRequestsByUser(User user) {
        return productRequestRepository.findAllByUser(user);
    }

    public boolean isTimeSlotAvailable(Long productId, LocalDate date, LocalTime time) {
        return !productRequestRepository.existsByProductIdAndSelectedDateAndSelectedTimeAndStatus(
                productId, date, time, RequestStatus.APPROVED);
    }
    public double getCleaningDuration(int apartmentSize) {
        Map<Integer, Double> durationMap = new HashMap<>();
        durationMap.put(1, 1.0);
        durationMap.put(2, 1.5);
        durationMap.put(3, 2.0);
        durationMap.put(4, 2.5);
        durationMap.put(5, 3.0);
        return durationMap.getOrDefault(apartmentSize, 1.0);
    }
    public void createRequest(Long productId, String date, String time, Principal principal) throws TimeSlotAlreadyBookedException {
        User user = userRepository.findByEmail(principal.getName());
        Product product = productRepository.findById(productId).orElse(null);

        if (user != null && product != null) {
            LocalDate selectedDate = LocalDate.parse(date);
            LocalTime selectedTime = LocalTime.parse(time, DateTimeFormatter.ofPattern("HH:mm"));

            if (isTimeSlotAvailable(productId, selectedDate, selectedTime)) {
                ProductRequest request = new ProductRequest();
                request.setUser(user);
                request.setProduct(product);
                request.setSelectedDate(selectedDate);
                request.setSelectedTime(selectedTime);

                productRequestRepository.save(request);
            } else {
                throw new TimeSlotAlreadyBookedException("The selected time slot is already booked.");
            }
        }
    }




    public void approveRequest(Long requestId) {
        ProductRequest request = productRequestRepository.findById(requestId).orElse(null);
        if (request != null && request.getStatus() == RequestStatus.PENDING) {
            request.setStatus(RequestStatus.APPROVED);
            productRequestRepository.save(request);


            String recipientEmail = request.getUser().getEmail();
            String subject = "Request Approved: " + request.getProduct().getTitle();


            String htmlContent = String.format(
                    "<html>"
                            + "<body style='font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px;'>"
                            + "<div style='max-width: 600px; margin: 0 auto; background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);'>"
                            + "<h2 style='color: #4CAF50; text-align: center;'>Your Request Has Been Approved!</h2>"
                            + "<p style='font-size: 16px;'>Dear Customer,</p>"
                            + "<p style='font-size: 16px; line-height: 1.6;'>"
                            + "We are pleased to inform you that your request for the service <strong>\"%s\"</strong> has been successfully approved!"
                            + "</p>"
                            + "<h3 style='color: #4CAF50; border-bottom: 1px solid #ddd; padding-bottom: 5px;'>Details:</h3>"
                            + "<ul style='list-style-type: none; padding: 0; font-size: 16px; line-height: 1.6;'>"
                            + "<li><strong>Service Name:</strong> %s</li>"
                            + "<li><strong>Time:</strong> %s O'clock</li>"
                            + "<li><strong>Date:</strong> %s</li>"
                            + "</ul>"
                            + "<p style='font-size: 16px; line-height: 1.6;'>"
                            + "Thank you for choosing us! If you have any questions, feel free to contact our support team."
                            + "</p>"
                            + "<p style='margin-top: 20px; font-size: 16px; line-height: 1.6;'>"
                            + "Best regards,<br>"
                            + "<strong>Your Support Team</strong>"
                            + "</p>"
                            + "</div>"
                            + "</body>"
                            + "</html>",
                    request.getProduct().getTitle(),
                    request.getProduct().getTitle(),
                    request.getSelectedTime(),
                    request.getSelectedDate()
            );

            // html message
            try {
                mailSenderService.sendHtmlEmail(recipientEmail, subject, htmlContent);
            } catch (MessagingException e) {
                e.printStackTrace();
            }
        }
    }




    public void rejectRequest(Long requestId) {
        ProductRequest request = productRequestRepository.findById(requestId).orElse(null);
        if (request != null && request.getStatus() == RequestStatus.PENDING) {
            request.setStatus(RequestStatus.REJECTED);
            productRequestRepository.save(request);
        }
    }

    public List<ProductRequest> getAllRequests() {
        return productRequestRepository.findAll();
    }


    public List<String> getBookedTimes(Long productId, LocalDate date) {
        List<ProductRequest> requests = productRequestRepository.findAllByProductIdAndSelectedDateAndStatus(
                productId, date, RequestStatus.APPROVED);

        return requests.stream()
                .map(request -> request.getSelectedTime().format(DateTimeFormatter.ofPattern("HH:mm")))
                .collect(Collectors.toList());
    }


    public boolean isTimeWindowAvailable(Long productId, LocalDate date, LocalTime startTime, LocalTime endTime) {
        int totalTeams = 5; // Total available teams

        // Get all approved requests for the date
        List<ProductRequest> requests = productRequestRepository.findAllByProductIdAndSelectedDateAndStatus(
                productId, date, RequestStatus.APPROVED);

        // Map to store the number of teams booked at each time slot
        Map<LocalTime, Integer> timeSlotBookings = new HashMap<>();

        // Mark booked time slots
        for (ProductRequest request : requests) {
            LocalTime reqStartTime = request.getSelectedTime();
            LocalTime reqEndTime = request.getEndTime();
            for (LocalTime time = reqStartTime; !time.isAfter(reqEndTime.minusHours(1)); time = time.plusHours(1)) {
                timeSlotBookings.put(time, timeSlotBookings.getOrDefault(time, 0) + 1);
            }
        }

        // Check availability for the requested time window
        for (LocalTime time = startTime; !time.isAfter(endTime.minusHours(1)); time = time.plusHours(1)) {
            int bookings = timeSlotBookings.getOrDefault(time, 0);
            if (bookings >= totalTeams) {
                return false;
            }
        }
        return true;
    }


    public ProductRequest createRequest(Long productId, String date, String timeWindow, String apartmentSizeStr, String address, Principal principal) throws TimeSlotAlreadyBookedException {
        User user = userRepository.findByEmail(principal.getName());
        Product product = productRepository.findById(productId).orElse(null);

        if (user != null && product != null) {
            LocalDate selectedDate = LocalDate.parse(date);
            String[] times = timeWindow.split("-");
            LocalTime selectedTime = LocalTime.parse(times[0], DateTimeFormatter.ofPattern("HH:mm"));
            LocalTime endTime = LocalTime.parse(times[1], DateTimeFormatter.ofPattern("HH:mm"));
            int apartmentSize = Integer.parseInt(apartmentSizeStr);
            double duration = getCleaningDuration(apartmentSize);

            if (isTimeWindowAvailable(productId, selectedDate, selectedTime, endTime)) {
                ProductRequest request = new ProductRequest();
                request.setUser(user);
                request.setProduct(product);
                request.setSelectedDate(selectedDate);
                request.setSelectedTime(selectedTime);
                request.setEndTime(endTime);
                request.setApartmentSize(apartmentSize);
                request.setAddress(address);
                request.setStatus(RequestStatus.APPROVED);

                // Generate a unique completion token
                String token = UUID.randomUUID().toString();
                request.setCompletionToken(token);

                productRequestRepository.save(request);

                return request; // Return the created request
            } else {
                throw new TimeSlotAlreadyBookedException("The selected time window is not available.");
            }
        }

        throw new IllegalArgumentException("User or Product not found");
    }


    public List<String> getAvailableTimeWindows(Long productId, LocalDate date, double duration) {
        int totalTeams = 5; // Total available teams

        // Get all approved requests for the date
        List<ProductRequest> requests = productRequestRepository.findAllByProductIdAndSelectedDateAndStatus(
                productId, date, RequestStatus.APPROVED);

        // Map to store the number of teams booked at each time slot
        Map<LocalTime, Integer> timeSlotBookings = new HashMap<>();

        // Mark booked time slots
        for (ProductRequest request : requests) {
            LocalTime reqStartTime = request.getSelectedTime();
            LocalTime reqEndTime = request.getEndTime();
            for (LocalTime time = reqStartTime; !time.isAfter(reqEndTime.minusHours(1)); time = time.plusHours(1)) {
                timeSlotBookings.put(time, timeSlotBookings.getOrDefault(time, 0) + 1);
            }
        }

        // Generate all possible start times
        LocalTime startTime = LocalTime.of(10, 0);
        LocalTime endTime = LocalTime.of(22, 0);
        List<LocalTime> allStartTimes = new ArrayList<>();
        for (LocalTime time = startTime; !time.isAfter(endTime.minusMinutes((long)(duration * 60) - 60)); time = time.plusHours(1)) {
            allStartTimes.add(time);
        }

        // Check availability for each time window
        List<String> availableTimeWindows = new ArrayList<>();
        for (LocalTime time : allStartTimes) {
            boolean isAvailable = true;
            for (LocalTime t = time; !t.isAfter(time.plusMinutes((long)(duration * 60) - 60)); t = t.plusHours(1)) {
                int bookings = timeSlotBookings.getOrDefault(t, 0);
                if (bookings >= totalTeams) {
                    isAvailable = false;
                    break;
                }
            }
            if (isAvailable) {
                String timeWindow = time.format(DateTimeFormatter.ofPattern("HH:mm")) + "-" +
                        time.plusMinutes((long)(duration * 60)).format(DateTimeFormatter.ofPattern("HH:mm"));
                availableTimeWindows.add(timeWindow);
            }
        }
        return availableTimeWindows;
    }

    // В ProductRequestService.java

    public int getAvailableTeams(Long productId, LocalDate date, LocalTime startTime, LocalTime endTime) {
        int totalTeams = 5; // Общее количество команд

        // Получаем все утвержденные запросы на эту дату
        List<ProductRequest> requests = productRequestRepository.findAllByProductIdAndSelectedDateAndStatus(
                productId, date, RequestStatus.APPROVED);

        // Счетчик занятых команд в заданное время
        int maxTeamsBooked = 0;

        // Проверяем количество занятых команд в каждом часовом слоте внутри заданного временного окна
        for (LocalTime time = startTime; !time.isAfter(endTime.minusHours(1)); time = time.plusHours(1)) {
            int teamsBookedAtTime = 0;
            for (ProductRequest request : requests) {
                LocalTime reqStartTime = request.getSelectedTime();
                LocalTime reqEndTime = request.getEndTime();

                // Проверяем, пересекается ли время
                if (!(reqEndTime.isBefore(time.plusHours(1)) || reqStartTime.isAfter(time))) {
                    teamsBookedAtTime++;
                }
            }
            if (teamsBookedAtTime > maxTeamsBooked) {
                maxTeamsBooked = teamsBookedAtTime;
            }
        }

        return totalTeams - maxTeamsBooked;
    }
    public boolean markAsCompletedByToken(String token) {
        ProductRequest request = productRequestRepository.findByCompletionToken(token);
        if (request != null && !Boolean.TRUE.equals(request.getCompleted())) {
            request.setCompleted(true);
            productRequestRepository.save(request);

            // Optionally, send an email to the user about the completion
            sendCompletionEmail(request);

            return true;
        }
        return false;
    }

    private void sendCompletionEmail(ProductRequest request) {
        String recipientEmail = request.getUser().getEmail();
        String subject = "The work has been successfully completed: " + request.getProduct().getTitle();

        String htmlContent = String.format(
                "<html>"
                        + "<body style='font-family: Arial, sans-serif; color: #333;'>"
                        + "<h2>Your task has been successfully completed!</h2>"
                        + "<p>Dear %s,</p>"
                        + "<p>We are pleased to inform you that the task for your order <strong>\"%s\"</strong> has been successfully completed!</p>"
                        + "<h3>Details:</h3>"
                        + "<ul>"
                        + "<li><strong>Service Name:</strong> %s</li>"
                        + "<li><strong>Date:</strong> %s</li>"
                        + "<li><strong>Time:</strong> %s</li>"
                        + "</ul>"
                        + "<p>Thank you for choosing us! If you have any questions, please contact our support team.</p>"
                        + "<p>Best regards,<br>Your Support Team</p>"
                        + "</body>"
                        + "</html>",
                request.getUser().getName(),
                request.getProduct().getTitle(),
                request.getProduct().getTitle(),
                request.getSelectedDate().toString(),
                request.getSelectedTime().toString()
        );

        try {
            mailSenderService.sendHtmlEmail(recipientEmail, subject, htmlContent);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }



    public void markAsCompleted(Long requestId) {
        ProductRequest request = productRequestRepository.findById(requestId).orElse(null);
        if (request != null && request.getStatus() == RequestStatus.APPROVED && !Boolean.TRUE.equals(request.getCompleted())) {
            request.setCompleted(true);
            productRequestRepository.save(request);

            // Отправка письма о завершении работы
            String recipientEmail = request.getUser().getEmail();
            String subject = "The work has been successfully completed: " + request.getProduct().getTitle();

            String htmlContent = String.format(
                    "<html>"
                            + "<body style='font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px;'>"
                            + "<div style='max-width: 600px; margin: 0 auto; background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);'>"
                            + "<h2 style='color: #4CAF50; text-align: center;'>Your task has been successfully completed!</h2>"
                            + "<p style='font-size: 16px;'>Dear Customer,</p>"
                            + "<p style='font-size: 16px; line-height: 1.6;'>"
                            + "We are pleased to inform you that the task for your order <strong>\"%s\"</strong> has been successfully completed!"
                            + "</p>"
                            + "<h3 style='color: #4CAF50; border-bottom: 1px solid #ddd; padding-bottom: 5px;'>Details:</h3>"
                            + "<ul style='list-style-type: none; padding: 0; font-size: 16px; line-height: 1.6;'>"
                            + "<li><strong>Service Name:</strong> %s</li>"
                            + "<li><strong>Time:</strong> %s</li>"
                            + "<li><strong>Date:</strong> %s</li>"
                            + "</ul>"
                            + "<p style='font-size: 16px; line-height: 1.6;'>"
                            + "Thank you for choosing us! If you have any questions, please contact our support team."
                            + "</p>"
                            + "<p style='margin-top: 20px; font-size: 16px; line-height: 1.6;'>"
                            + "Best regards,<br>"
                            + "<strong>Your Support Team</strong>"
                            + "</p>"
                            + "</div>"
                            + "</body>"
                            + "</html>",
                    request.getProduct().getTitle(),
                    request.getProduct().getTitle(),
                    request.getSelectedTime(),
                    request.getSelectedDate()
            );


            try {
                mailSenderService.sendHtmlEmail(recipientEmail, subject, htmlContent);
            } catch (MessagingException e) {
                e.printStackTrace();
                // Рекомендуется добавить логирование ошибки
            }
        }
    }

}
