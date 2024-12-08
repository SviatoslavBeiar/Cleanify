package com.example.cleaning.controllers;

import com.example.cleaning.models.ProductRequest;
import com.example.cleaning.models.User;
import com.example.cleaning.services.EmailService;
import com.example.cleaning.services.ProductRequestService;
import com.example.cleaning.services.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import javax.mail.MessagingException;
import javax.servlet.http.HttpServletRequest;
import java.security.Principal;
import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
public class UserController {
    private final UserService userService;
    private final ProductRequestService productRequestService;
    private final EmailService emailService;

    //    @GetMapping("/login")
//    public String login(Principal principal, Model model) {
//        model.addAttribute("user", userService.getUserByPrincipal(principal));
//        return "login";
//    }
    @GetMapping("/my/requests")
    public String myRequests(Principal principal, Model model) {
        User user = userService.getUserByPrincipal(principal);
        if (user == null) {
            // Optionally, handle the case where the user is not found.
            return "redirect:/login";
        }

        List<ProductRequest> requests = productRequestService.getRequestsByUser(user);
        model.addAttribute("requests", requests);
        model.addAttribute("user", user);
        return "my-requests"; // Refers to my-requests.ftlh
    }
    @GetMapping("/verify")
    public String verifyUser(@RequestParam("code") String code, Model model) {
        boolean verified = userService.verifyUser(code);
        if (verified) {
            model.addAttribute("message", "Email verification successful. You can now log in.");
        } else {
            model.addAttribute("message", "Invalid verification code.");
        }
        return "verify-result"; // Create a template for this view
    }
//    @GetMapping("/profile")
//    public String profile(Principal principal,
//                          Model model) {
//        User user = userService.getUserByPrincipal(principal);
//        model.addAttribute("user", user);
//        return "profile";
//    }

    @GetMapping("/registration")
    public String registration(Principal principal, Model model) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        return "registration";
    }
    @GetMapping("/login")
    public String login(Principal principal, Model model) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        return "login";
    }

    // ... other methods ...

    @GetMapping("/profile")
    public String profile(Principal principal, Model model) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        return "profile";
    }

    @PostMapping("/registration")
    public String createUser(User user, Model model, HttpServletRequest request) {
        User createdUser = userService.createUser(user);
        if (createdUser == null) {
            model.addAttribute("errorMessage", "Користувач з email: " + user.getEmail() + " вже існує.");
            return "registration";
        }

        // Формування базового URL динамічно
        String baseUrl = ServletUriComponentsBuilder.fromRequestUri(request)
                .replacePath(null)
                .build()
                .toUriString();

        String verifyURL = baseUrl + "/verify?code=" + createdUser.getVerificationCode();

        try {
            emailService.sendVerificationEmail(createdUser.getEmail(), verifyURL);
        } catch (MessagingException e) {
            log.error("Error sending verification email", e);
            model.addAttribute("errorMessage", "Error sending verification email. Please try again.");
            return "registration";
        }

        model.addAttribute("successMessage", "Registration successful! Please check your email for account verification.");
        return "registration";
    }


//    @GetMapping("/user/{user}")
//    public String userInfo(@PathVariable("user") User user, Model model, Principal principal) {
//        model.addAttribute("user", user);
//        model.addAttribute("userByPrincipal", userService.getUserByPrincipal(principal));
//        model.addAttribute("products", user.getProducts());
//        return "user-info";
//    }
}
