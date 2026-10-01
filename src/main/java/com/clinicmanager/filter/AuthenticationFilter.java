package com.clinicmanager.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    private static final List<String> PUBLIC_PATHS =
            List.of("/", "/index.jsp", "/login", "/register", "/auth/", "/css/");

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getRequestURI().substring(request.getContextPath().length());

        boolean isPublic = PUBLIC_PATHS.stream().anyMatch(p ->
                path.equals(p) || (p.endsWith("/") && !p.equals("/") && path.startsWith(p)));

        HttpSession session = request.getSession(false);   // false = ne crée pas de session
        boolean loggedIn = session != null && session.getAttribute("user") != null;

        if (isPublic || loggedIn) {
            chain.doFilter(req, res);                       // laisser passer
        } else {
            response.sendRedirect(request.getContextPath() + "/login");   // bloquer
        }
    }
}