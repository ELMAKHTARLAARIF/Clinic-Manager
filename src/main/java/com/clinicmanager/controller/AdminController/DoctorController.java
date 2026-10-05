package com.clinicmanager.controller.AdminController;

import com.clinicmanager.enums.BloodGroup;
import com.clinicmanager.enums.Gender;
import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.exception.DuplicateMatriculeException;
import com.clinicmanager.service.AdminService.DepartmentService;
import com.clinicmanager.service.AdminService.specialtyService;
import com.clinicmanager.service.AdminService.DoctorService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;

import static com.clinicmanager.util.ValidationUtil.*;

public class DoctorController {
    private static final String VIEWDOCTOR = "/WEB-INF/views/admin/doctors.jsp";

    private final DoctorService doctorService = new DoctorService();

    private void loadFormData(HttpServletRequest req) {
        req.setAttribute("departments", DepartmentService.findAll());   // list of DTOs: id, name
        req.setAttribute("specialties", specialtyService.findAll());
        req.setAttribute("doctors", doctorService.findAll()); // list of DTOs: id, name, departmentId
    }

    public void list(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        loadFormData(req);
        req.getRequestDispatcher(VIEWDOCTOR).forward(req, res);
    }



    public void createDoctor(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

        // 1. lire et nettoyer (les noms doivent être identiques à ceux du formulaire)
        String lastName = clean(req.getParameter("lastName"));
        String firstName = clean(req.getParameter("firstName"));
        String email = clean(req.getParameter("email"));
        String phone = clean(req.getParameter("phone"));
        String password = req.getParameter("password");
        String matricule = clean(req.getParameter("matricule"));
        String title = clean(req.getParameter("title"));
        Long departmentId = parseId(req.getParameter("departmentId"));
        Long specialtyId = parseId(req.getParameter("specialtyId"));
        Map<String, String> errors = validateData(lastName, firstName, email, phone, password);
        if (matricule.isEmpty() || matricule.length() > 30)
            errors.put("matricule", "Matriculate obligatory (30 car actress max).");
        if (departmentId == null) errors.put("departmentId", "Choosiness un department.");
        if (specialtyId == null) errors.put("specialtyId", "Choosiness une speciality.");

        if (!errors.isEmpty()) {
            showFormWithErrors(req, res, errors, null, VIEWDOCTOR);
            return;
        }

        try {
            doctorService.createDoctor(lastName, firstName, email, phone, password, matricule, title, departmentId, specialtyId);

            res.sendRedirect(req.getContextPath() + "/admin/doctors?created=1");

        } catch (DuplicateEmailException e) {
            errors.put("email", e.getMessage());
            showFormWithErrors(req, res, errors, null, VIEWDOCTOR);

        } catch (DuplicateMatriculeException e) {
            errors.put("matricule", e.getMessage());
            showFormWithErrors(req, res, errors, null, VIEWDOCTOR);

        } catch (IllegalArgumentException e) {
            showFormWithErrors(req, res, errors, e.getMessage(), VIEWDOCTOR);

        } catch (RuntimeException e) {
            e.printStackTrace();
            showFormWithErrors(req, res, errors, e.getMessage(), VIEWDOCTOR);
        }
    }

    private void showFormWithErrors(HttpServletRequest req, HttpServletResponse res, Map<String, String> errors, String globalError, String VIEW) throws ServletException, IOException {

        loadFormData(req);
        req.setAttribute("errors", errors);
        if (globalError != null) req.setAttribute("error", globalError);
        req.setAttribute("openModal", true);
        req.getRequestDispatcher(VIEW).forward(req, res);
    }

    private Long parseId(String value) {
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public Map validateData(String firstName, String lastName, String email, String phone, String password) {
        Map<String, String> errors = new LinkedHashMap<>();

        if (!isValidName(lastName)) errors.put("lastName", "Nom invalid.");
        if (!isValidName(firstName)) errors.put("firstName", "Prénom invalid.");
        if (!isValidEmail(email)) errors.put("email", "Address email invalid.");
        if (!phone.isEmpty() && !isValidPhone(phone)) errors.put("phone", "Téléphone invalid.");
        if (!hasMinLength(password, 6)) errors.put("password", "6 car actress minimum.");
        return errors;
    }

}
