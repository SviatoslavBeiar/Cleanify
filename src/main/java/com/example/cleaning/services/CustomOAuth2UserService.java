//package com.example.buysell.services;
//
//import com.example.buysell.models.CustomOAuth2User;
//import com.example.buysell.models.User;
//import com.example.buysell.models.enums.Role;
//import com.example.buysell.repositories.UserRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
//import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
//import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
//import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
//import org.springframework.security.oauth2.core.user.OAuth2User;
//import org.springframework.stereotype.Service;
//
//import java.util.Collections;
//import java.util.Map;
//
//@Service
//@RequiredArgsConstructor
//public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {
//
//    private final UserRepository userRepository;
//
//    @Override
//    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
//        // Получаем данные пользователя от провайдера OAuth2 (Google)
//        OAuth2UserService<OAuth2UserRequest, OAuth2User> delegate = new DefaultOAuth2UserService();
//        OAuth2User oAuth2User = delegate.loadUser(userRequest);
//
//        // Извлекаем атрибуты пользователя
//        Map<String, Object> attributes = oAuth2User.getAttributes();
//
//        // Получаем email пользователя
//        String email = (String) attributes.get("email");
//
//        // Проверяем, существует ли пользователь в нашей базе данных
//        User user = userRepository.findByEmail(email);
//
//        if (user == null) {
//            // Если пользователя нет, создаем нового
//            user = new User();
//            user.setEmail(email);
//            user.setName((String) attributes.get("name"));
//            user.setActive(true);
//            user.setRoles(Collections.singleton(Role.ROLE_USER));
//            // Пароль можно оставить пустым или установить случайное значение
//            user.setPassword(""); // Или сгенерировать случайный пароль
//
//            userRepository.save(user);
//        } else {
//            // Обновляем информацию о пользователе, если это необходимо
//            user.setName((String) attributes.get("name"));
//            userRepository.save(user);
//        }
//
//        // Возвращаем объект OAuth2User с атрибутами
//        return new CustomOAuth2User(user, attributes);
//    }
//}
