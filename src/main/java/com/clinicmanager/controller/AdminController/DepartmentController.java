package com.clinicmanager.controller.AdminController;

import com.clinicmanager.service.AdminService.DepartmentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class DepartmentController {

    private static final String VIEW = "/WEB-INF/views/admin/departments.jsp";
    public void loardFormData(HttpServletRequest req){

        req.setAttribute("departments", DepartmentService.findAll());
    }

    public void list(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
           loardFormData(req);
           req.getRequestDispatcher(VIEW).forward(req,res);
    }
}
