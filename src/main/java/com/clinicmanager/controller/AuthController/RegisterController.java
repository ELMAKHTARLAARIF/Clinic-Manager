package com.clinicmanager.controller.AuthController;

import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.service.AuthService.RegisterService;
import com.clinicmanager.service.AuthService.RegisterService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import static com.clinicmanager.util.ValidationUtil.*;

public class RegisterController {

    private static final String VIEW = "/WEB-INF/views/auth/register.jsp";
    private final RegisterService registerService = new RegisterService();

    // GET /register


    // POST /register
    public void register(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. lire et nettoyer
        String lastName  = clean(request.getParameter("lastName"));
        String firstName = clean(request.getParameter("firstName"));
        String email     = clean(request.getParameter("email"));
        String phone     = clean(request.getParameter("phone"));
        String password  = request.getParameter("password");          // pas de trim sur un mot de passe
        String confirm   = request.getParameter("confirmPassword");

        // 2. valider le format (champ par champ)
        Map<String, String> errors = new LinkedHashMap<>();

        if (!isValidName(lastName))
            errors.put("lastName", "Nom invalide (lettres uniquement, 100 max).");
        if (!isValidName(firstName))
            errors.put("firstName", "Prénom invalide (lettres uniquement, 100 max).");
        if (!isValidEmail(email))
            errors.put("email", "Adresse email invalide.");
        if (!phone.isEmpty() && !isValidPhone(phone))
            errors.put("phone", "Téléphone invalide (8 à 20 chiffres, + autorisé).");
        if (!hasMinLength(password, 6))
            errors.put("password", "Le mot de passe doit contenir au moins 6 caractères.");
        else if (!password.equals(confirm))
            errors.put("confirmPassword", "Les mots de passe ne correspondent pas.");

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;                                   // le service n'est jamais appelé
        }

        // 3. données valides : appeler le service (règles métier)
        try {
            registerService.register(firstName,lastName, email, phone, password);

            response.sendRedirect(request.getContextPath() + "/login?registered=1");

        } catch (DuplicateEmailException e) {
            errors.put("email", e.getMessage());
            request.setAttribute("errors", errors);
            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher(VIEW).forward(request, response);
        }
    }
}