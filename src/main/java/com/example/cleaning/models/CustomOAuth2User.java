//package com.example.buysell.models;
//
//import org.springframework.security.core.GrantedAuthority;
//import org.springframework.security.oauth2.core.user.OAuth2User;
//
//import java.util.Collection;
//import java.util.Map;
//
//public class CustomOAuth2User implements OAuth2User {
//
//    private final User user;
//    private final Map<String, Object> attributes;
//
//    public CustomOAuth2User(User user, Map<String, Object> attributes) {
//        this.user = user;
//        this.attributes = attributes;
//    }
//
//    @Override
//    public Map<String, Object> getAttributes() {
//        return attributes;
//    }
//
//    @Override
//    public Collection<? extends GrantedAuthority> getAuthorities() {
//        return user.getAuthorities();
//    }
//
//    @Override
//    public String getName() {
//        // Возвращаем уникальный идентификатор пользователя
//        return user.getUsername();
//    }
//
//    public User getUser() {
//        return user;
//    }
//}
