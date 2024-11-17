package com.example.cleaning.controllers;

import com.example.cleaning.exceptions.TimeSlotAlreadyBookedException;
import com.example.cleaning.models.Product;
import com.example.cleaning.models.User;
import com.example.cleaning.services.CommentService;
import com.example.cleaning.services.ProductRequestService;
import com.example.cleaning.services.ProductService;
import com.example.cleaning.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ProductController {
    @Autowired
    private final ProductService productService;
    private final UserService userService;
    private final CommentService commentService;
    private final ProductRequestService productRequestService;
    @Value("${google.maps.api.key}")
    private String googleMapsApiKey;
    // Обработка создания запроса на продукт

//    @PostMapping("/product/{id}/request")
//    public String createProductRequest(@PathVariable Long id,
//                                       @RequestParam("selectedDate") String selectedDate,
//                                       @RequestParam("selectedTime") String selectedTime,
//                                       Principal principal) {
//        productRequestService.createRequest(id, selectedDate, selectedTime, principal);
//        return "redirect:/product/" + id + "?requestSuccess";
//    }


//    @PostMapping("/product/{id}/request")
//    public String createProductRequest(@PathVariable Long id,
//                                       @RequestParam("selectedDate") String selectedDate,
//                                       @RequestParam("selectedTime") String selectedTime,
//                                       Principal principal,
//                                       Model model) {
//        try {
//            productRequestService.createRequest(id, selectedDate, selectedTime, principal);
//            return "redirect:/product/" + id + "?requestSuccess";
//        } catch (TimeSlotAlreadyBookedException e) {
//            model.addAttribute("errorMessage", e.getMessage());
//            // Добавьте необходимые атрибуты модели для корректного отображения страницы
//            model.addAttribute("product", productService.getProductById(id));
//            model.addAttribute("user", userService.getUserByPrincipal(principal));
//            model.addAttribute("images", productService.getProductById(id).getImages());
//            // Верните имя шаблона страницы продукта
//            return "product-info";
//        }
//    }



    @GetMapping("/product/{id}/booked-times")
    @ResponseBody
    public List<String> getBookedTimes(@PathVariable Long id, @RequestParam String date) {
        LocalDate selectedDate = LocalDate.parse(date);
        return productRequestService.getBookedTimes(id, selectedDate);
    }

    @GetMapping("/")
    public String products(@RequestParam(name = "searchWord", required = false) String title, Principal principal, Model model) {
        model.addAttribute("products", productService.listProducts(title));
        model.addAttribute("user", productService.getUserByPrincipal(principal));
        model.addAttribute("searchWord", title);
        return "products";
    }

//    @GetMapping("/product/{id}")
//    public String productInfo(@PathVariable Long id, Model model, Principal principal) {
//        Product product = productService.getProductById(id);
//        User user = userService.getUserByPrincipal(principal);
//        model.addAttribute("user", user);
//        model.addAttribute("product", product);
//        model.addAttribute("images", product.getImages());
//        model.addAttribute("comments", product.getComments());
//        model.addAttribute("authorProduct", product.getUser());
//        return "product-info";
//    }
    @GetMapping("/product/{id}")
    public String productInfo(@PathVariable Long id, Model model, Principal principal) {
        Product product = productService.getProductById(id);
        User user = userService.getUserByPrincipal(principal);
        model.addAttribute("user", user);
        model.addAttribute("product", product);
        model.addAttribute("images", product.getImages());
        model.addAttribute("comments", product.getComments());
        model.addAttribute("authorProduct", product.getUser());
        model.addAttribute("googleMapsApiKey", googleMapsApiKey);
        return "product-info";
    }
    @PostMapping("/product/{id}/comment")
    public String addComment(@PathVariable Long id, @RequestParam String text, Principal principal) {
        commentService.saveComment(id, text, principal);
        return "redirect:/product/" + id;
    }
//    @PostMapping("/product/create")
//    public String createProduct(@RequestParam("file1") MultipartFile file1, @RequestParam("file2") MultipartFile file2,
//                                @RequestParam("file3") MultipartFile file3, Product product, Principal principal) throws IOException {
//        productService.saveProduct(principal, product, file1, file2, file3);
//        return "redirect:/my/products";
//    }

//    @PostMapping("/product/delete/{id}")
//    public String deleteProduct(@PathVariable Long id, Principal principal) {
//        productService.deleteProduct(productService.getUserByPrincipal(principal), id);
//        return "redirect:/my/products";
//    }

    @GetMapping("/my/products")
    public String userProducts(Principal principal, Model model) {
        User user = productService.getUserByPrincipal(principal);
        model.addAttribute("user", user);
        model.addAttribute("products", user.getProducts());
        return "my-products";
    }

    // In ProductController.java

    @GetMapping("/product/{id}/available-time-windows")
    @ResponseBody
    public List<String> getAvailableTimeWindows(@PathVariable Long id,
                                                @RequestParam String date,
                                                @RequestParam double duration) {
        LocalDate selectedDate = LocalDate.parse(date);
        return productRequestService.getAvailableTimeWindows(id, selectedDate, duration);
    }

    @PostMapping("/product/{id}/request")
    public String createProductRequest(@PathVariable Long id,
                                       @RequestParam("selectedDate") String selectedDate,
                                       @RequestParam("selectedTimeWindow") String selectedTimeWindow,
                                       @RequestParam("apartmentSize") String apartmentSize,
                                       @RequestParam("address") String address,
                                       Principal principal,
                                       Model model) {
        try {
            productRequestService.createRequest(id, selectedDate, selectedTimeWindow, apartmentSize, address, principal);
            return "redirect:/product/" + id + "?requestSuccess";
        } catch (TimeSlotAlreadyBookedException e) {
            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("product", productService.getProductById(id));
            model.addAttribute("user", userService.getUserByPrincipal(principal));
            model.addAttribute("images", productService.getProductById(id).getImages());
            return "product-info";
        }
    }
// В ProductController.java

    @GetMapping("/product/{id}/available-teams")
    @ResponseBody
    public int getAvailableTeams(@PathVariable Long id,
                                 @RequestParam String date,
                                 @RequestParam String timeWindow) {
        LocalDate selectedDate = LocalDate.parse(date);
        String[] times = timeWindow.split("-");
        LocalTime startTime = LocalTime.parse(times[0], DateTimeFormatter.ofPattern("HH:mm"));
        LocalTime endTime = LocalTime.parse(times[1], DateTimeFormatter.ofPattern("HH:mm"));

        return productRequestService.getAvailableTeams(id, selectedDate, startTime, endTime);
    }

}
