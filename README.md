# CleaningWebService

## Table of Contents
- [Video](#video)
- [Description](#description)
- [Technologies Used](#technologies-used)
  - [Backend](#backend)
  - [Frontend](#frontend)
- [APIs](#apis)
  - [Google Maps API](#google-maps-api)
  - [PayPal API](#paypal-api)
  - [Google OAuth2 API](#google-oauth2-api)
- [External Libraries](#external-libraries)
- [Configuration](#configuration)
   - [Application Properties](#application-properties)

---

## Video
https://github.com/user-attachments/assets/ed620b52-4c40-486d-bede-e40e29f43258

---

## Description

**CleaningWebService** is a comprehensive web application designed to manage cleaning requests efficiently. It offers features such as user authentication, payment processing, geolocation services, and dynamic content generation. Leveraging a robust technology stack and various APIs, the application ensures a seamless and secure user experience.

  The application offers the following features:

- **User Authentication**: Registration through a login form with email verification, as well as via Google OAuth2 for convenience and security.
- **Payment Processing**: Integration with PayPal API ensures secure transactions.
- **Geolocation Services**: Utilizes Google Maps API for map display and distance calculations.
- **Dynamic Content Generation**: Server-side generation of HTML pages using FreeMarker.
- **Cleaning Request Confirmation**: Ability to confirm cleaning requests by scanning a QR code, simplifying the service completion process.
- **QR Codes**: Generation and scanning of QR codes to confirm the completion of cleaning, providing convenience and security for users.
- **Convenient Booking System with AJAX**: Implements a user-friendly booking system using AJAX, enabling seamless scheduling and management of cleaning requests without the need for full page reloads.
- **Address Verification**: Validates user-provided addresses using Google Maps API and AJAX, ensuring accuracy and consistency in service locations.
- **Map-Based Address Visualization**: Allows administrators to view all service addresses on an interactive map with status indicators:
  - **Yellow**: Requests scheduled for today.
  - **Blue**: Cleaning base locations.
  - **Purple**: Completed requests.
  - **Green**: Confirmed and paid requests.
- **Admin Panel Enhancements**:
  - **Role Management**: Easily assign and manage user roles.
  - **User Management**: Ability to ban users.
  - **Post/Offer Management with Soft Delete and Restoration**: Soft delete posts/offers to deactivate them without permanent removal, and restore them as needed to maintain data integrity and flexibility.
---

## Technologies Used

### Backend

- **Java 11**: The primary programming language used for backend development.
- **Spring Boot 2.5.6**: A powerful framework that simplifies the development of Java-based applications, providing features like embedded servers and automatic configuration.
- **Spring Data JPA**: Facilitates interaction with the MySQL database using the Java Persistence API, enabling seamless ORM (Object-Relational Mapping).
- **Spring Security**: Provides comprehensive security features, including authentication and authorization mechanisms to protect the application.
- **Hibernate**: An ORM tool used alongside Spring Data JPA for mapping Java classes to database tables.
- **MySQL**: A reliable relational database management system used to store and manage application data.
- **FreeMarker**: A versatile template engine for generating dynamic HTML content on the server side.
- **Lombok**: Reduces boilerplate code in Java by automatically generating getters, setters, constructors, and other common methods through annotations.
- **JUnit**: A widely-used testing framework for writing and executing unit tests in Java applications.
- **Spring Boot Test**: Provides utilities and annotations to facilitate testing of Spring Boot applications.

### Frontend

- **FreeMarker Templates**: For generating dynamic HTML on the server side.
- **Bootstrap 4.5.2**: A responsive CSS framework that streamlines the development of mobile-first, visually appealing web interfaces.
- **Font Awesome 6.4.0**: Provides a vast collection of icons to enhance the visual appeal and usability of the frontend.
- **jQuery**: Simplifies DOM manipulation, event handling, and AJAX interactions on the client side.
- **Google Maps JavaScript API**: Integrates interactive maps and geolocation functionalities to enhance user experience.
- **AJAX**: Enables asynchronous communication between the client and server without full page reloads.

---

## APIs

### Google Maps API

Integrates interactive maps and geolocation functionalities to enhance user experience.

- **Google Maps JavaScript API**: Renders interactive maps and handles map-related functionalities.
  - [Documentation](https://developers.google.com/maps/documentation/javascript/overview)
- **Google Geocoding API**: Converts addresses into geographic coordinates and vice versa.
  - [Documentation](https://developers.google.com/maps/documentation/geocoding/start)
- **Google Distance Matrix API**: Calculates travel distance and time between multiple locations.
  - [Documentation](https://developers.google.com/maps/documentation/distance-matrix/start)
- **Google Places API**: *(Potential Integration)* Provides detailed information about places, enabling features like autocomplete and place details.
  - [Documentation](https://developers.google.com/maps/documentation/places/web-service/overview)

### PayPal API

Facilitates secure payment processing within the application.

- **PayPal REST API**: Enables integration of PayPal payment functionalities, including transaction management.
  - [Documentation](https://developer.paypal.com/docs/api/overview/)

### Google OAuth2 API

Enables user authentication via Google accounts, enhancing security and user convenience.

- **Authentication API**: Manages user sign-in and access control using Google credentials.
  - [Documentation](https://developers.google.com/identity/protocols/oauth2)

---

## External Libraries

- **ZXing (Zebra Crossing)**: Utilized for generating and decoding QR codes within the application.
  - [GitHub Repository](https://github.com/zxing/zxing)
  - [Documentation](https://github.com/zxing/zxing/wiki)
  
- **Font Awesome**: Provides a vast collection of icons to enhance the visual appeal and usability of the frontend.
  - [Documentation](https://fontawesome.com/how-to-use)
  
- **Bootstrap 4.5.2**: A responsive CSS framework that streamlines the development of mobile-first, visually appealing web interfaces.
  - [Documentation](https://getbootstrap.com/docs/4.5/getting-started/introduction/)
  
- **jQuery**: Simplifies DOM manipulation, event handling, and AJAX interactions on the client side.
  - [Documentation](https://api.jquery.com/)
  
- **Spring Mail**: Enables the application to send emails, such as notifications and confirmations, via SMTP servers.
  - [Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-email)
  
- **Spring Boot Starter Test**: Provides a suite of testing utilities and libraries to ensure application reliability.
  - [Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-testing)
  
- **Spring Security Test**: Offers tools and annotations specifically designed for testing security-related components in Spring applications.
  - [Documentation](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#testing)
  
- **Project Lombok**: Enhances Java development by automating the creation of boilerplate code through annotations.
  - [Documentation](https://projectlombok.org/features/all)
  
- **JUnit**: A foundational framework for writing and executing unit tests in Java, ensuring code quality and functionality.
  - [Documentation](https://junit.org/junit4/)

---

## Configuration

### Application Properties

The application utilizes `application.properties` for configuring various aspects such as database connections, email settings, API keys, and security parameters.

#### Database Configuration
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/cleaningbd
spring.datasource.username=root
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
```
#### Email Configuration
```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your_email
spring.mail.password=your_email_password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```
#### PayPal Configuration
```properties
paypal.client-id=YOUR_PAYPAL_CLIENT_ID
paypal.client-secret=YOUR_PAYPAL_CLIENT_SECRET
paypal.mode=sandbox
```
#### Google Maps API Key
```properties
google.maps.api.key=YOUR_GOOGLE_MAPS_API_KEY
```
#### Security and OAuth2 Configuration
```properties
spring.security.oauth2.client.registration.google.client-id=YOUR_GOOGLE_CLIENT_ID
spring.security.oauth2.client.registration.google.client-secret=YOUR_GOOGLE_CLIENT_SECRET
spring.security.oauth2.client.registration.google.scope=profile,email
spring.security.oauth2.client.registration.google.redirect-uri={baseUrl}/login/oauth2/code/{registrationId}
spring.security.oauth2.client.provider.google.user-name-attribute=email
```
