package com.clinicmanager.service.AuthService;

import com.clinicmanager.exception.UserNotFoundException;
import com.clinicmanager.model.User;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.util.PasswordUtil;
import org.mindrot.jbcrypt.BCrypt;

public class LoginService {
    private final UserRepository userRepository = new UserRepository();
    public User login(String email, String password) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password."));

        if (!PasswordUtil.verify(password, user.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password.");
        }

        return user;
    }

}
