package com.clinicmanager.controller.AdminController;

import com.clinicmanager.enums.BloodGroup;
import com.clinicmanager.enums.Gender;
import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.model.Patient;
import com.clinicmanager.service.AdminService.PatientService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static com.clinicmanager.util.ValidationUtil.*;

public class PatientController {
    private static final String VIEWPATIENT = "/WEB-INF/views/admin/patients.jsp";
    private static final PatientService patientService = new PatientService();


    private void loadFormData(HttpServletRequest req) {
        List<Patient> patients = patientService.findAll();
        req.setAttribute("patients", patients);
        System.out.println("patients = " + patients.size());     // size is more useful than printing the entities

    }

    public void list(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        loadFormData(req);
        if ("1".equals(req.getParameter("created"))) req.setAttribute("success", "Patient created  successfully.");
        req.getRequestDispatcher(VIEWPATIENT).forward(req, res);
    }


    public void createPatient(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String lastName = clean(req.getParameter("lastName"));
        String firstName = clean(req.getParameter("firstName"));
        String email = clean(req.getParameter("email"));
        String phone = clean(req.getParameter("phone"));
        String password = req.getParameter("password");
        String cin = clean(req.getParameter("cin"));
        String address = clean(req.getParameter("address"));

        String StringbirthDate = req.getParameter("birthDate");
        LocalDate birthDate = LocalDate.parse(StringbirthDate);
        Gender gender = Gender.valueOf(req.getParameter("gender"));
        BloodGroup bloodGroup = BloodGroup.valueOf(req.getParameter("bloodGroup"));

        Map<String, String> errors = validateData(lastName, firstName, email, phone, password);

        if (cin.isEmpty() || cin.length() > 20) errors.put("cin", "CIN obligatoire (20 caractères max).");

        if (birthDate == null) errors.put("birthDate", "Date de naissance invalide.");
        else if (birthDate.isAfter(LocalDate.now())) errors.put("birthDate", "La date ne peut pas être dans le futur.");
        else if (birthDate.isBefore(LocalDate.of(1900, 1, 1)))
            errors.put("birthDate", "Date de naissance trop ancienne.");

        if (gender == null) errors.put("gender", "Choisissez un genre.");
        if (bloodGroup == null) errors.put("bloodGroup", "Choisissez un groupe sanguin.");
        if (address.length() > 255) errors.put("address", "Adresse trop longue (255 max).");

        if (!errors.isEmpty()) {
            showFormWithErrors(req, res, errors, null);
            return;
        }

        try {
            patientService.createPatient(lastName, firstName, email, phone, password, cin, birthDate, gender, bloodGroup, address);

            res.sendRedirect(req.getContextPath() + "/admin/patients?created=1");

        } catch (DuplicateEmailException e) {
            errors.put("email", e.getMessage());
            showFormWithErrors(req, res, errors, null);

        } catch (IllegalArgumentException e) {
            showFormWithErrors(req, res, errors, e.getMessage());

        } catch (RuntimeException e) {
            e.printStackTrace();
            showFormWithErrors(req, res, errors, "Le patient n'a pas pu être créé. Réessayez.");
        }
    }

    private void showFormWithErrors(HttpServletRequest req, HttpServletResponse res, Map<String, String> errors, String globalError) throws ServletException, IOException {

        loadFormData(req);
        req.setAttribute("errors", errors);
        if (globalError != null) req.setAttribute("error", globalError);
        req.setAttribute("openModal", true);
        req.getRequestDispatcher(VIEWPATIENT).forward(req, res);
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

    public void deletePatient(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Long patientId = Long.valueOf(req.getParameter("id"));
            patientService.deletePatient(patientId);

            res.sendRedirect(req.getContextPath() + "/admin/patients?success=deleted");
        } catch (Exception e) {
            e.printStackTrace();
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error deleting patient.");
        }
    }

    public void getPatient(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Long id = parseId(req.getParameter("id"));
        Patient p = (id == null) ? null : patientService.findById(id).orElse(null);

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        if (p == null) {
            res.setStatus(HttpServletResponse.SC_NOT_FOUND);
            res.getWriter().write("{\"error\":\"Patient introuvable\"}");
            return;
        }

        Map<String, Object> json = new LinkedHashMap<>();
        json.put("id", p.getId());
        json.put("lastName", p.getUser().getLastName());
        json.put("firstName", p.getUser().getFirstName());
        json.put("email", p.getUser().getEmail());
        json.put("phone", p.getUser().getPhone());
        json.put("cin", p.getCin());
        json.put("birthDate", p.getBirthDate() == null ? null : p.getBirthDate().toString());   // yyyy-MM-dd
        json.put("gender", p.getGender() == null ? null : p.getGender().name());
        json.put("bloodGroup", p.getBloodGroup() == null ? null : p.getBloodGroup().name());
        json.put("address", p.getAddress());

        res.getWriter().write(new Gson().toJson(json));
    }

    public void updatePatient(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

        Long id = parseId(req.getParameter("id"));
        String lastName = clean(req.getParameter("lastName"));
        String firstName = clean(req.getParameter("firstName"));
        String email = clean(req.getParameter("email"));
        String phone = clean(req.getParameter("phone"));
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");
        String cin = clean(req.getParameter("cin"));
        String address = clean(req.getParameter("address"));
        String StringbirthDate = clean(req.getParameter("birthDate"));
        LocalDate birthDate = LocalDate.parse(StringbirthDate);
        Gender gender = Gender.valueOf(req.getParameter("gender"));
        BloodGroup bloodGroup = BloodGroup.valueOf(req.getParameter("bloodGroup"));

        Map<String, String> errors = new LinkedHashMap<>();
        if (id == null) errors.put("id", "Patient invalide.");
        if (!isValidName(lastName)) errors.put("lastName", "Nom invalide.");
        if (!isValidName(firstName)) errors.put("firstName", "Prénom invalide.");
        if (!isValidEmail(email)) errors.put("email", "Adresse email invalide.");
        if (!phone.isEmpty() && !isValidPhone(phone)) errors.put("phone", "Téléphone invalide.");
        if (!password.isEmpty() && !hasMinLength(password, 6))      // vide = on ne change pas
            errors.put("password", "6 caractères minimum.");
        if (cin.isEmpty() || cin.length() > 20) errors.put("cin", "CIN obligatoire (20 caractères max).");
        if (birthDate == null || birthDate.isAfter(LocalDate.now()))
            errors.put("birthDate", "Date de naissance invalide.");
        if (gender == null) errors.put("gender", "Choisissez un genre.");
        if (bloodGroup == null) errors.put("bloodGroup", "Choisissez un groupe sanguin.");

        if (!errors.isEmpty()) {
            showFormWithErrors(req, res, errors, null);   // la modale se rouvre en mode "modifier" (param.id)
            return;
        }

        try {
            patientService.updatePatient(id, lastName, firstName, email, phone, password, cin, birthDate, gender, bloodGroup, address);
            res.sendRedirect(req.getContextPath() + "/admin/patients?updated=1");

        } catch (DuplicateEmailException e) {
            errors.put("email", e.getMessage());
            showFormWithErrors(req, res, errors, null);
        } catch (IllegalArgumentException e) {
            showFormWithErrors(req, res, errors, e.getMessage());
        } catch (RuntimeException e) {
            e.printStackTrace();
            showFormWithErrors(req, res, errors, "La modification a échoué. Réessayez.");
        }
    }


    private Long parseId(String value) {
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
