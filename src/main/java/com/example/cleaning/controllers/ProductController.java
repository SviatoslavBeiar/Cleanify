package com.example.cleaning.controllers;

import com.example.cleaning.exceptions.TimeSlotAlreadyBookedException;
import com.example.cleaning.models.Product;
import com.example.cleaning.models.User;
import com.example.cleaning.services.*;
import com.paypal.api.payments.Links;
import com.paypal.api.payments.Payment;
import com.paypal.base.rest.PayPalRESTException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.mail.MessagingException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ProductController {
    @Autowired
    private final ProductService productService;
    private final UserService userService;
    private final CommentService commentService;
    private final ProductRequestService productRequestService;
    @Value("${google.maps.api.key}")
    private String googleMapsApiKey;
    @Autowired
    private PayPalService payPalService;
    @Autowired
    private MailSenderService mailSenderService;


    @GetMapping("/product/{id}/booked-times")
    @ResponseBody
    public List<String> getBookedTimes(@PathVariable Long id, @RequestParam String date) {
        LocalDate selectedDate = LocalDate.parse(date);
        return productRequestService.getBookedTimes(id, selectedDate);
    }

//    @GetMapping("/")
//    public String products(@RequestParam(name = "searchWord", required = false) String title, Principal principal, Model model) {
//        model.addAttribute("products", productService.listProducts(title));
//        model.addAttribute("user", productService.getUserByPrincipal(principal));
//        model.addAttribute("searchWord", title);
//        return "products";
//    }
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

        try {
            Payment payment = payPalService.createPayment(cost, "PLN", "paypal",
                    "sale", "Cleaning Service Payment",
                    "http://localhost:8080/product/" + id + "/pay/cancel",
                    "http://localhost:8080/product/" + id + "/pay/success");

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



//    @GetMapping("/product/{id}/pay/success")
//    public String successPay(@PathVariable Long id,
//                             @RequestParam("paymentId") String paymentId,
//                             @RequestParam("PayerID") String payerId,
//                             HttpServletRequest request,
//                             Principal principal,
//                             Model model) {
//        try {
//            Payment payment = payPalService.executePayment(paymentId, payerId);
//            if (payment.getState().equals("approved")) {
//                HttpSession session = request.getSession();
//                String selectedDate = (String) session.getAttribute("selectedDate");
//                String selectedTimeWindow = (String) session.getAttribute("selectedTimeWindow");
//                String apartmentSize = (String) session.getAttribute("apartmentSize");
//                String address = (String) session.getAttribute("address");
//
//                productRequestService.createRequest(id, selectedDate, selectedTimeWindow, apartmentSize, address, principal);
//
//                session.removeAttribute("selectedDate");
//                session.removeAttribute("selectedTimeWindow");
//                session.removeAttribute("apartmentSize");
//                session.removeAttribute("address");
//                session.removeAttribute("productId");
//
//                // Добавляем переменную 'user' в модель
//                if (principal != null) {
//                    User user = userService.getUserByPrincipal(principal);
//                    model.addAttribute("user", user);
//                }
//
//                return "success"; // Возвращаем название шаблона success.ftlh
//            }
//        } catch (PayPalRESTException | TimeSlotAlreadyBookedException e) {
//            e.printStackTrace();
//        }
//        return "redirect:/";
//    }

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

                // Create the ProductRequest
                productRequestService.createRequest(
                        id, selectedDate, selectedTimeWindow, apartmentSize, address, principal);

                // Clear session attributes
                session.removeAttribute("selectedDate");
                session.removeAttribute("selectedTimeWindow");
                session.removeAttribute("apartmentSize");
                session.removeAttribute("address");
                session.removeAttribute("productId");

                if (principal != null) {
                    User user = userService.getUserByPrincipal(principal);
                    model.addAttribute("user", user);

                    // Prepare email details
                    String recipientEmail = user.getEmail();
                    String subject = "Payment Confirmation for \"" + productService.getProductById(id).getTitle() + "\"";

                    // Fetch product details
                    Product product = productService.getProductById(id);

                    String htmlContent = String.format(
                            "<html>"
                                    + "<body style='font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px;'>"
                                    + "<div style='max-width: 600px; margin: 0 auto; background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);'>"
                                    + "<h2 style='color: #4CAF50; text-align: center;'>Payment Successful!</h2>"
                                    + "<p style='font-size: 16px;'>Dear %s,</p>"
                                    + "<p style='font-size: 16px; line-height: 1.6;'>"
                                    + "Thank you for your payment for the service <strong>\"%s\"</strong>."
                                    + "</p>"
                                    + "<h3 style='color: #4CAF50; border-bottom: 1px solid #ddd; padding-bottom: 5px;'>Details:</h3>"
                                    + "<ul style='list-style-type: none; padding: 0; font-size: 16px; line-height: 1.6;'>"
                                    + "<li><strong>Service Name:</strong> %s</li>"
                                    + "<li><strong>Date:</strong> %s</li>"
                                    + "<li><strong>Time:</strong> %s</li>"
                                    + "<li><strong>Apartment Size:</strong> %s</li>"
                                    + "<li><strong>Address:</strong> %s</li>"
                                    + "</ul>"
                                    + "<p style='font-size: 16px; line-height: 1.6;'>"
                                    + "If you have any questions, please feel free to contact our support team."
                                    + "</p>"
                                    + "<p style='margin-top: 20px; font-size: 16px; line-height: 1.6;'>"
                                    + "Best regards,<br>"
                                    + "<strong>Your Support Team</strong>"
                                    + "</p>"
                                    + "</div>"
                                    + "</body>"
                                    + "</html>",
                            user.getName(), // Assuming User has getFirstName()
                            product.getTitle(),
                            product.getTitle(),
                            selectedDate,
                            selectedTimeWindow,
                            apartmentSize,
                            address
                    );

                    try {
                        mailSenderService.sendHtmlEmail(recipientEmail, subject, htmlContent);
                    } catch (MessagingException e) {
                        e.printStackTrace();
                        // Optionally, handle the exception (e.g., log it, notify admin, etc.)
                    }
                }

                return "success"; // Return the name of the success template (e.g., success.html)
            }
        } catch (PayPalRESTException | TimeSlotAlreadyBookedException e) {
            e.printStackTrace();
            // Optionally, add error handling (e.g., redirect to an error page)
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

        model.addAttribute("productId", id); // Добавляем productId в модель для использования в шаблоне
        return "cancel"; // Возвращаем название шаблона cancel.ftlh
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
