package com.example.cleaning.controllers;

import com.example.cleaning.models.User;
import com.example.cleaning.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping("/login")
    public String login(Principal principal, Model model) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        return "login";
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
    @GetMapping("/profile")
    public String profile(Principal principal,
                          Model model) {
        User user = userService.getUserByPrincipal(principal);
        model.addAttribute("user", user);
        return "profile";
    }

    @GetMapping("/registration")
    public String registration(Principal principal, Model model) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        return "registration";
    }


    @PostMapping("/registration")
    public String createUser(User user, Model model) {
        if (!userService.createUser(user)) {
            model.addAttribute("errorMessage", "A user with email: " + user.getEmail() + " already exists.");
            return "registration";
        }
        model.addAttribute("successMessage", "Registration successful! Please check your email to verify your account.");
        return "registration";
    }


    @GetMapping("/user/{user}")
    public String userInfo(@PathVariable("user") User user, Model model, Principal principal) {
        model.addAttribute("user", user);
        model.addAttribute("userByPrincipal", userService.getUserByPrincipal(principal));
        model.addAttribute("products", user.getProducts());
        return "user-info";
    }
}
