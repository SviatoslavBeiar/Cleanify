package com.example.cleaning.services;

import com.example.cleaning.models.User;
import com.example.cleaning.models.enums.Role;
import com.example.cleaning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import javax.mail.MessagingException;
import java.security.Principal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    public boolean createUser(User user) {
        String email = user.getEmail();
        if (userRepository.findByEmail(email) != null) return false;
        user.setActive(false);
        user.setEnabled(false);
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.getRoles().add(Role.ROLE_USER);

        // Generate verification code
        String verificationCode = UUID.randomUUID().toString();
        user.setVerificationCode(verificationCode);

        log.info("Saving new User with email: {}", email);
        userRepository.save(user);

        // Send verification email
        String siteURL = "http://localhost:8080"; // Replace with your site's URL
        String verifyURL = siteURL + "/verify?code=" + verificationCode;

        try {
            emailService.sendVerificationEmail(user.getEmail(), verifyURL);
        } catch (MessagingException e) {
            log.error("Error sending verification email", e);
            return false;
        }

        return true;
    }
    public boolean verifyUser(String verificationCode) {
        User user = userRepository.findByVerificationCode(verificationCode);
        if (user == null) {
            return false;
        } else {
            user.setVerificationCode(null);
            user.setEnabled(true);
            user.setActive(true);
            userRepository.save(user);
            return true;
        }
    }
    public List<User> list() {
        return userRepository.findAll();
    }

    public void banUser(Long id) {
        User user = userRepository.findById(id).orElse(null);
        if (user != null) {
            if (user.isActive()) {
                user.setActive(false);
                log.info("Ban user with id = {}; email: {}", user.getId(), user.getEmail());
            } else {
                user.setActive(true);
                log.info("Unban user with id = {}; email: {}", user.getId(), user.getEmail());
            }
        }
        userRepository.save(user);
    }

    public void changeUserRoles(User user, Map<String, String> form) {
        Set<String> roles = Arrays.stream(Role.values())
                .map(Role::name)
                .collect(Collectors.toSet());
        user.getRoles().clear();
        for (String key : form.keySet()) {
            if (roles.contains(key)) {
                user.getRoles().add(Role.valueOf(key));
            }
        }
        userRepository.save(user);
    }

    public User getUserByPrincipal(Principal principal) {
        if (principal == null) return new User();
        String email = null;

        if (principal instanceof Authentication) {
            Object principalObj = ((Authentication) principal).getPrincipal();
            if (principalObj instanceof UserDetails) {
                email = ((UserDetails) principalObj).getUsername();
            } else if (principalObj instanceof OAuth2User) {
                email = ((OAuth2User) principalObj).getAttribute("email");
            }
        }
        if (email != null) {
            return userRepository.findByEmail(email);
        }
        return new User();
    }
}
