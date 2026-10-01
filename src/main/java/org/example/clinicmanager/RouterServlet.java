package org.example.clinicmanager;

import com.clinicmanager.controller.AuthController.LoginController;
import com.clinicmanager.controller.AuthController.RegisterController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/")
public class RouterServlet extends HttpServlet {
    private final LoginController loginController = new LoginController();
    private final RegisterController registerController = new RegisterController();
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        switch (getPath(request)) {

            case "":
            case "/":
                request.getRequestDispatcher(
                        "/WEB-INF/views/index.jsp"
                ).forward(request, response);
                break;

            case "/patients":
                request.getRequestDispatcher(
                        "/WEB-INF/views/patients.jsp"
                ).forward(request, response);
                break;

            case "/register":
                request.getRequestDispatcher(
                        "/WEB-INF/views/auth/register.jsp"
                ).forward(request, response);
                break;

            case "/login":
                request.getRequestDispatcher(
                        "/WEB-INF/views/auth/login.jsp"
                ).forward(request, response);
                break;

            default:
                getServletContext()
                        .getNamedDispatcher("default")
                        .forward(request, response);
        }
    }

    // RouterServlet
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        switch (getPath(req)) {
            case "/login" -> loginController.login(req, res);
            case "/register"    -> registerController.register(req, res);
            default -> res.sendError(405);
        }
    }

    private String getPath(HttpServletRequest request) {
        return request.getRequestURI().substring(request.getContextPath().length());
    }
}