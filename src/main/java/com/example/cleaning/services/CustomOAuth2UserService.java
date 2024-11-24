package com.example.cleaning.services;

import com.example.cleaning.models.User;
import com.example.cleaning.models.enums.Role;
import com.example.cleaning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) {
        OAuth2User oauthUser = super.loadUser(userRequest);

        String email = oauthUser.getAttribute("email");
        if (email == null) {
            throw new RuntimeException("Email not found from OAuth2 provider");
        }

        User user = userRepository.findByEmail(email);
        if (user == null) {
            // Create a new user if not exist
            user = new User();
            user.setEmail(email);
            user.setName(email); // Use email as name
            user.setActive(true);
            user.setEnabled(true);
            user.setPhoneNumber("null");
            user.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
            user.getRoles().add(Role.ROLE_USER);

            userRepository.save(user);
        }

        // Map roles to GrantedAuthority
        return new DefaultOAuth2User(user.getAuthorities(), oauthUser.getAttributes(), "email");
    }
}
