package com.example.cleaning.repositories;

import com.example.cleaning.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByEmail(String email);
    User findByVerificationCode(String code);
}
