package com.example.cleaning.repositories;

import com.example.cleaning.models.Image;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

public interface ImageRepository extends JpaRepository<Image, Long> {

    @Transactional
    void deleteByProductId(Long productId);
}
