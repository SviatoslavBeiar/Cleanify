package com.example.cleaning.services;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

@Service
@RequiredArgsConstructor
public class EmailService {
    private final JavaMailSender mailSender;

    public void sendVerificationEmail(String recipientEmail, String verificationLink) throws MessagingException {
        String subject = "Email Verification";
        String senderName = "Your Application Name";
        String content = "<p>Dear user,</p>"
                + "<p>Please click the link below to verify your email:</p>"
                + "<p><a href=\"" + verificationLink + "\">Verify Email</a></p>"
                + "<br>"
                + "<p>Thank you,<br>Your Application Team</p>";

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);

       // helper.setFrom("your-email@example.com", senderName);
        helper.setTo(recipientEmail);
        helper.setSubject(subject);
        helper.setText(content, true);

        mailSender.send(message);
    }
}
