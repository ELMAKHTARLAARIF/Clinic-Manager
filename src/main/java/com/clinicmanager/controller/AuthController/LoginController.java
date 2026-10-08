package com.clinicmanager.controller.AuthController;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.enums.Role;
import com.clinicmanager.model.User;
import com.clinicmanager.service.AuthService.LoginService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import static com.clinicmanager.util.ValidationUtil.*;

public class LoginController {
    private final LoginService loginService = new LoginService();

    private static final String LOGIN_VIEW = "/WEB-INF/views/auth/login.jsp";

    public void login(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException, ServletException {
        String email = clean(req.getParameter("email"));
        String password = req.getParameter("password"); // Never trim passwords

        Map<String, String> errors = new HashMap<>();

        if (email.isEmpty()) {
            errors.put("email", "Email est requires.");
        }
        if (password == null || password.isEmpty()) {
            errors.put("password", "Le mot de passe est requires.");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.getRequestDispatcher(LOGIN_VIEW).forward(req, res);
            return;
        }

        try {
            User user = loginService.login(email, password);
            UserDTO session_user = new UserDTO(user.getId(),user.getFirstName(),user.getLastName(),user.getEmail(), user.getPhone());
            req.getSession().setAttribute("currentUser", session_user);
            if (user.getRole().equals(Role.ADMIN)) {
                res.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else if (user.getRole().equals(Role.PATIENT)) {
                res.sendRedirect(req.getContextPath() + "/patient/book");            }
             else
                 res.sendRedirect(req.getContextPath() + "/doctor/dashboard");

        } catch (IllegalArgumentException e) {

            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher(LOGIN_VIEW).forward(req, res);
        }
    }
}

