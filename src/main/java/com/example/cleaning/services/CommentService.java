package com.example.cleaning.services;

import com.example.cleaning.models.Comment;
import com.example.cleaning.models.Product;
import com.example.cleaning.models.User;
import com.example.cleaning.repositories.CommentRepository;
import com.example.cleaning.repositories.ProductRepository;
import com.example.cleaning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.security.Principal;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepository commentRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    public void saveComment(Long productId, String text, Principal principal) {
        User user = userRepository.findByEmail(principal.getName());
        Product product = productRepository.findById(productId).orElse(null);
        if (product == null || user == null) {
            return;
        }

        Comment comment = new Comment();
        comment.setText(text);
        comment.setProduct(product);
        comment.setUser(user);

        commentRepository.save(comment);
    }
}
