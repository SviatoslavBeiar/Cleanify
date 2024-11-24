package com.example.cleaning.controllers;

import com.example.cleaning.models.Product;
import com.example.cleaning.models.User;
import com.example.cleaning.models.enums.Role;
import com.example.cleaning.services.ProductRequestService;
import com.example.cleaning.services.ProductService;
import com.example.cleaning.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.security.Principal;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('ROLE_ADMIN')")
public class AdminController {
    private final UserService userService;
    private final ProductRequestService productRequestService;
    private final ProductService productService;
    @Value("${google.maps.api.key}")
    private String googleMapsApiKey;
/////////////
//    @PostMapping("/product/delete/{id}")
//        public String deleteProduct(@PathVariable Long id, Principal principal) {
//        productService.deleteProduct(productService.getUserByPrincipal(principal), id);
//        return "redirect:/my/products";
//    }
    @PostMapping("/product/create")
    public String createProduct(@RequestParam("file1") MultipartFile file1, @RequestParam("file2") MultipartFile file2,
                                @RequestParam("file3") MultipartFile file3, Product product, Principal principal) throws IOException {
        productService.saveProduct(principal, product, file1, file2, file3);
        return "redirect:/my/products";
    }
//////////////


    @PostMapping("/admin/requests/complete/{id}")
    public String completeRequest(@PathVariable Long id) {
        productRequestService.markAsCompleted(id);
        return "redirect:/admin/requests";
    }

    @GetMapping("/complete/{token}")
    public String completeByToken(@PathVariable String token, Model model, Principal principal) {
        boolean success = productRequestService.markAsCompletedByToken(token);
        model.addAttribute("success", success);
        if (principal != null) {
            User user = userService.getUserByPrincipal(principal);
            model.addAttribute("user", user);
        }
        return "completion-confirmation"; // Шаблон подтверждения
    }

    @PostMapping("/product/delete/{id}")
public String deleteProduct(@PathVariable Long id, Principal principal) {
    User user = userService.getUserByPrincipal(principal);
    productService.deleteProduct(user, id); // Используется softDelete
    return "redirect:/my/products";
}
    @PostMapping("/product/restore/{id}")
    public String restoreProduct(@PathVariable Long id) {
        productService.restoreProduct(id);
        return "redirect:/my/products";
    }

    // Метод для отображения всех продуктов (включая удаленные)
    @GetMapping("/admin/products")
    public String viewAllProducts(Model model, Principal principal) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        model.addAttribute("products", productService.listAllProducts());
        return "admin-products"; // Создайте этот шаблон
    }
    // Метод для одобрения запроса
    @PostMapping("/admin/requests/approve/{id}")
    public String approveRequest(@PathVariable Long id) {
        productRequestService.approveRequest(id);
        return "redirect:/admin/requests";
    }


    @PostMapping("/admin/requests/reject/{id}")
    public String rejectRequest(@PathVariable Long id) {
        productRequestService.rejectRequest(id);
        return "redirect:/admin/requests";
    }
    @GetMapping("/admin")
    public String admin(Model model, Principal principal) {
        model.addAttribute("users", userService.list());
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        return "admin";
    }
    // Отображение всех запросов
    @GetMapping("/admin/requests")
    public String viewRequests(Model model, Principal principal) {
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        model.addAttribute("requests", productRequestService.getAllRequests());
        model.addAttribute("googleMapsApiKey", googleMapsApiKey);
        return "requests";
    }
    @PostMapping("/admin/user/ban/{id}")
    public String userBan(@PathVariable("id") Long id) {
        userService.banUser(id);
        return "redirect:/admin";
    }

    @GetMapping("/admin/user/edit/{user}")
    public String userEdit(@PathVariable("user") User user, Model model, Principal principal) {
        model.addAttribute("user", user);
        model.addAttribute("user", userService.getUserByPrincipal(principal));
        model.addAttribute("roles", Role.values());
        return "user-edit";
    }

    @PostMapping("/admin/user/edit")
    public String userEdit(@RequestParam("userId") User user, @RequestParam Map<String, String> form) {
        userService.changeUserRoles(user, form);
        return "redirect:/admin";
    }
}
