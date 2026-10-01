package com.clinicmanager.service.AuthService;

import com.clinicmanager.enums.Role;                 // adapte si ton enum est dans un autre package
import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.model.User;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.util.PasswordUtil;
import com.clinicmanager.util.ValidationUtil;
import jakarta.persistence.PersistenceException;

public class RegisterService {

    private final UserRepository userRepository = new UserRepository();

    public User register(String firstName,String lastName, String email,
                         String phone, String password) {

        // garde-fous : le service ne fait pas confiance à l'appelant
        if (isBlank(lastName) || isBlank(firstName) || isBlank(email))
            throw new IllegalArgumentException("Nom, prénom et email sont obligatoires.");
        if (password == null || password.length() < 6)
            throw new IllegalArgumentException("Le mot de passe doit contenir au moins 6 caractères.");

        String normalizedEmail = email.trim().toLowerCase();

        if (userRepository.existsByEmail(normalizedEmail))
            throw new DuplicateEmailException("Email Already Exist.");

        User user = new User();
        user.setFirstName(firstName.trim());
        user.setLastName(lastName.trim());
        user.setEmail(normalizedEmail);
        user.setPhone(isBlank(phone) ? null : phone.trim());
        user.setPassword(PasswordUtil.hash(password));
        user.setRole(Role.PATIENT);
        user.setActive(true);

        try {
            return userRepository.save(user);
        } catch (PersistenceException e) {
            if (userRepository.existsByEmail(normalizedEmail))
                throw new DuplicateEmailException("Email Already Exist.");
            throw e;
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}