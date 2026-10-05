//package com.clinicmanager.filter;
//
//import jakarta.servlet.*;
//import jakarta.servlet.annotation.WebFilter;
//import jakarta.servlet.http.*;
//import java.io.IOException;
//import java.util.Map;
//
//@WebFilter(urlPatterns = {"/admin/*", "/doctor/*", "/patient/*", "/staff/*"})
//public class RoleFilter implements Filter {
//
//    private static final Map<String, String> REQUIRED_ROLE = Map.of(
//            "/admin", "ADMIN",
//            "/doctor", "DOCTOR",
//            "/patient", "PATIENT",
//            "/staff", "STAFF");
//
//    @Override
//    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
//            throws IOException, ServletException {
//
//        HttpServletRequest request = (HttpServletRequest) req;
//        HttpServletResponse response = (HttpServletResponse) res;
//
//        String path = request.getRequestURI().substring(request.getContextPath().length());
//        String prefix = "/" + path.split("/")[1];            // ex: /admin
//        String required = REQUIRED_ROLE.get(prefix);
//
//        HttpSession session = request.getSession(false);
//        String role = (session == null) ? null : (String) session.getAttribute("role");
//
//        if (role == null) {
//            response.sendRedirect(request.getContextPath() + "/login");
//        } else if (!role.equals(required)) {
//            response.sendError(HttpServletResponse.SC_FORBIDDEN);   // 403
//        } else {
//            chain.doFilter(req, res);
//        }
//    }
//}