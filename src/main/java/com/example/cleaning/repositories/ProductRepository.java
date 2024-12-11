package com.example.cleaning.repositories;

import com.example.cleaning.models.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {
    //List<Product> findByTitle(String title);
    List<Product> findByTitleAndDeletedFalse(String title);
    List<Product> findByDeletedFalse();

}
