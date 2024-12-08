package com.example.cleaning.controllers;

import com.example.cleaning.exceptions.TimeSlotAlreadyBookedException;
import com.example.cleaning.models.Product;
import com.example.cleaning.models.ProductRequest;
import com.example.cleaning.models.User;
import com.example.cleaning.services.*;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.paypal.api.payments.Links;
import com.paypal.api.payments.Payment;
import com.paypal.base.rest.PayPalRESTException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final UserService userService;
    private final CommentService commentService;
    private final ProductRequestService productRequestService;
    private final PayPalService payPalService;
    private final MailSenderService mailSenderService;
    private final JavaMailSenderImpl mailSender;

    @Value("${google.maps.api.key}")
    private String googleMapsApiKey;
   // @Value("${app.base-url}")
   // private String baseUrl;

    @GetMapping("/product/{id}/booked-times")
    @ResponseBody
    public List<String> getBookedTimes(@PathVariable Long id, @RequestParam String date) {
        LocalDate selectedDate = LocalDate.parse(date);
        return productRequestService.getBookedTimes(id, selectedDate);
    }


    @GetMapping("/")
    public String products(@RequestParam(name = "searchWord", required = false) String title, Principal principal, Model model) {
        model.addAttribute("products", productService.listActiveProducts(title));
        model.addAttribute("user", productService.getUserByPrincipal(principal));
        model.addAttribute("searchWord", title);
        return "products";
    }
    @GetMapping("/product/{id}")
    public String productInfo(@PathVariable Long id, Model model, Principal principal) {
        Product product = productService.getProductById(id);
        User user = userService.getUserByPrincipal(principal);
        model.addAttribute("user", user);
        model.addAttribute("product", product);
        model.addAttribute("images", product.getImages());
        model.addAttribute("comments", product.getComments());
        model.addAttribute("authorProduct", product.getUser());
        model.addAttribute("googleMapsApiKey", googleMapsApiKey);
        return "product-info";
    }
    @PostMapping("/product/{id}/comment")
    public String addComment(@PathVariable Long id, @RequestParam String text, Principal principal) {
        commentService.saveComment(id, text, principal);
        return "redirect:/product/" + id;
    }


    @GetMapping("/my/products")
    public String userProducts(Principal principal, Model model) {
        User user = productService.getUserByPrincipal(principal);
        model.addAttribute("user", user);
        model.addAttribute("products", user.getProducts());
        return "my-products";
    }

    // In ProductController.java

    @GetMapping("/product/{id}/available-time-windows")
    @ResponseBody
    public List<String> getAvailableTimeWindows(@PathVariable Long id,
                                                @RequestParam String date,
                                                @RequestParam double duration) {
        LocalDate selectedDate = LocalDate.parse(date);
        return productRequestService.getAvailableTimeWindows(id, selectedDate, duration);
    }

    @PostMapping("/product/{id}/request")
    public String createProductRequest(@PathVariable Long id,
                                       @RequestParam("selectedDate") String selectedDate,
                                       @RequestParam("selectedTimeWindow") String selectedTimeWindow,
                                       @RequestParam("apartmentSize") String apartmentSize,
                                       @RequestParam("address") String address,
                                       Principal principal,
                                       Model model) {
        try {
            productRequestService.createRequest(id, selectedDate, selectedTimeWindow, apartmentSize, address, principal);
            return "redirect:/product/" + id + "?requestSuccess";
        } catch (TimeSlotAlreadyBookedException e) {
            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("product", productService.getProductById(id));
            model.addAttribute("user", userService.getUserByPrincipal(principal));
            model.addAttribute("images", productService.getProductById(id).getImages());
            return "product-info";
        }
    }
// В ProductController.java

    @GetMapping("/product/{id}/available-teams")
    @ResponseBody
    public int getAvailableTeams(@PathVariable Long id,
                                 @RequestParam String date,
                                 @RequestParam String timeWindow) {
        LocalDate selectedDate = LocalDate.parse(date);
        String[] times = timeWindow.split("-");
        LocalTime startTime = LocalTime.parse(times[0], DateTimeFormatter.ofPattern("HH:mm"));
        LocalTime endTime = LocalTime.parse(times[1], DateTimeFormatter.ofPattern("HH:mm"));

        return productRequestService.getAvailableTeams(id, selectedDate, startTime, endTime);
    }





    @PostMapping("/product/{id}/pay")
    public String payForProduct(@PathVariable Long id,
                                @RequestParam("selectedDate") String selectedDate,
                                @RequestParam("selectedTimeWindow") String selectedTimeWindow,
                                @RequestParam("apartmentSize") String apartmentSize,
                                @RequestParam("address") String address,
                                Principal principal,
                                Model model,
                                HttpServletRequest request) {
        double cost = calculateCost(apartmentSize);
        HttpSession session = request.getSession();
        session.setAttribute("selectedDate", selectedDate);
        session.setAttribute("selectedTimeWindow", selectedTimeWindow);
        session.setAttribute("apartmentSize", apartmentSize);
        session.setAttribute("address", address);
        session.setAttribute("productId", id);

        // Побудова базового URL динамічно
        String baseUrl = ServletUriComponentsBuilder.fromRequestUri(request)
                .replacePath(null)
                .build()
                .toUriString();

        try {
            Payment payment = payPalService.createPayment(cost, "PLN", "paypal",
                    "sale", "Cleaning Service Payment",
                    baseUrl + "/product/" + id + "/pay/cancel",
                    baseUrl + "/product/" + id + "/pay/success");

            for (Links link : payment.getLinks()) {
                if (link.getRel().equals("approval_url")) {
                    return "redirect:" + link.getHref();
                }
            }
        } catch (PayPalRESTException e) {
            e.printStackTrace();
        }

        return "redirect:/";
    }

    @GetMapping("/product/{id}/pay/success")
    public String successPay(@PathVariable Long id,
                             @RequestParam("paymentId") String paymentId,
                             @RequestParam("PayerID") String payerId,
                             HttpServletRequest request,
                             Principal principal,
                             Model model) {
        try {
            Payment payment = payPalService.executePayment(paymentId, payerId);
            if ("approved".equals(payment.getState())) {
                HttpSession session = request.getSession();
                String selectedDate = (String) session.getAttribute("selectedDate");
                String selectedTimeWindow = (String) session.getAttribute("selectedTimeWindow");
                String apartmentSize = (String) session.getAttribute("apartmentSize");
                String address = (String) session.getAttribute("address");

                // Capture the created ProductRequest
                ProductRequest requestEntity = productRequestService.createRequest(
                        id, selectedDate, selectedTimeWindow, apartmentSize, address, principal);

                // Побудова базового URL динамічно
                String baseUrl = ServletUriComponentsBuilder.fromRequestUri(request)
                        .replacePath(null)
                        .build()
                        .toUriString();

                // Generate the completion URL using the token
                String completionUrl = baseUrl + "/complete/" + requestEntity.getCompletionToken();

                // Генерація QR коду
                ByteArrayOutputStream qrCodeStream = new ByteArrayOutputStream();
                QRCodeWriter qrCodeWriter = new QRCodeWriter();
                BitMatrix bitMatrix = qrCodeWriter.encode(completionUrl, BarcodeFormat.QR_CODE, 200, 200);
                MatrixToImageWriter.writeToStream(bitMatrix, "PNG", qrCodeStream);
                byte[] qrCodeBytes = qrCodeStream.toByteArray();

                // Підготовка та відправка електронної пошти
                if (principal != null) {
                    User user = userService.getUserByPrincipal(principal);
                    model.addAttribute("user", user);

                    String recipientEmail = user.getEmail();
                    String subject = "Payment Confirmation for \"" + productService.getProductById(id).getTitle() + "\"";

                    Product product = productService.getProductById(id);

                    String htmlContent = String.format(
                            "<html>"
                                    + "<body style='font-family: Arial, sans-serif; color: #333;'>"
                                    + "<h2>Payment Successful!</h2>"
                                    + "<p>Dear %s,</p>"
                                    + "<p>Thank you for your payment for the service <strong>\"%s\"</strong>.</p>"
                                    + "<h3>Details:</h3>"
                                    + "<ul>"
                                    + "<li><strong>Service Name:</strong> %s</li>"
                                    + "<li><strong>Date:</strong> %s</li>"
                                    + "<li><strong>Time:</strong> %s</li>"
                                    + "<li><strong>Apartment Size:</strong> %s</li>"
                                    + "<li><strong>Address:</strong> %s</li>"
                                    + "</ul>"
                                    + "<p>Please present this QR code to the worker:</p>"
                                    + "<img src=\"cid:qrCodeImage\" alt=\"QR Code\" />"
                                    + "<p>If you have any questions, please feel free to contact our support team.</p>"
                                    + "<p>Best regards,<br>Your Support Team</p>"
                                    + "</body>"
                                    + "</html>",
                            user.getName(),
                            product.getTitle(),
                            product.getTitle(),
                            selectedDate,
                            selectedTimeWindow,
                            apartmentSize,
                            address
                    );

                    try {
                        MimeMessage message = mailSender.createMimeMessage();
                        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

                        helper.setTo(recipientEmail);
                        helper.setSubject(subject);
                        helper.setText(htmlContent, true);

                        // Додавання QR коду як вбудованого зображення
                        helper.addInline("qrCodeImage", new ByteArrayResource(qrCodeBytes), "image/png");

                        mailSender.send(message);
                    } catch (MessagingException e) {
                        e.printStackTrace();
                    }
                }

                // Очищення атрибутів сесії
                session.removeAttribute("selectedDate");
                session.removeAttribute("selectedTimeWindow");
                session.removeAttribute("apartmentSize");
                session.removeAttribute("address");
                session.removeAttribute("productId");

                return "success";
            }
        } catch (PayPalRESTException | TimeSlotAlreadyBookedException | WriterException | IOException e) {
            e.printStackTrace();
        }
        return "redirect:/";
    }



    @GetMapping("/product/{id}/pay/cancel")
    public String cancelPay(@PathVariable Long id, HttpServletRequest request, Model model,Principal principal) {
        HttpSession session = request.getSession();
        session.removeAttribute("selectedDate");
        session.removeAttribute("selectedTimeWindow");
        session.removeAttribute("apartmentSize");
        session.removeAttribute("address");
        session.removeAttribute("productId");

        model.addAttribute("productId", id);

        if (principal != null) {
            User user = userService.getUserByPrincipal(principal);
            model.addAttribute("user", user);
        }

        model.addAttribute("productId", id);
        return "cancel";
    }


    private double calculateCost(String apartmentSize) {
        int size = Integer.parseInt(apartmentSize);
        double cost = 0;
        switch (size) {
            case 1:
                cost = 100;
                break;
            case 2:
                cost = 200;
                break;
            case 3:
                cost = 300;
                break;
            case 4:
                cost = 400;
                break;
            case 5:
                cost = 500;
                break;
            default:
                cost = 0;
                break;
        }
        return cost;
    }

}
