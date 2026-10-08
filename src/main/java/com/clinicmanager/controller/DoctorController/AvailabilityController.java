package com.clinicmanager.controller.DoctorController;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.enums.AvailabilityStatus;
import com.clinicmanager.mapper.AvailabilityMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.Map;

import static com.clinicmanager.util.ValidationUtil.parseTime;

public class AvailabilityController {

    private static final String VIEW = "/WEB-INF/views/doctor/availabilities.jsp";
    private final com.clinicmanager.service.DoctorSpaceService.availabilityService availabilityService = new com.clinicmanager.service.DoctorSpaceService.availabilityService();
                    
    // GET /doctor/availabilities
    public void list(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        loadList(req);
        if ("1".equals(req.getParameter("created"))) req.setAttribute("success", "Disponibilité ajoutée.");
        if ("1".equals(req.getParameter("deleted"))) req.setAttribute("success", "Disponibilité supprimée.");
        req.getRequestDispatcher(VIEW).forward(req, res);
    }

    // POST /doctor/availabilities/create
    public void create(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

        // 1. lire SANS lever d'exception (les noms = ceux du formulaire)
        DayOfWeek day = DayOfWeek.valueOf(req.getParameter("dayOfWeek"));
        AvailabilityStatus status = AvailabilityStatus.valueOf(req.getParameter("status"));
        LocalTime start = parseTime(req.getParameter("startTime"));
        LocalTime end = parseTime(req.getParameter("endTime"));
        LocalDate validFrom = LocalDate.parse(req.getParameter("validFrom"));
        LocalDate validTo = LocalDate.parse(req.getParameter("validTo"));// facultatif

        // 2. valider champ par champ, puis la logique entre les champs
        Map<String, String> errors = new LinkedHashMap<>();

        if (day == null) errors.put("dayOfWeek", "Choisissez un jour.");
        else if (day == DayOfWeek.SUNDAY) errors.put("dayOfWeek", "Le dimanche est fermé.");

        if (status == null) errors.put("status", "Statut invalide.");
        if (start == null) errors.put("startTime", "Heure de début invalide.");
        if (end == null) errors.put("endTime", "Heure de fin invalide.");

        if (start != null && end != null) {
            if (!end.isAfter(start)) errors.put("endTime", "L'heure de fin doit être après l'heure de début.");
            else if (Duration.between(start, end).toMinutes() < 30)
                errors.put("endTime", "La plage doit durer au moins 30 minutes.");
        }

        if (validFrom == null) errors.put("validFrom", "Date de début invalide.");
        else if (validFrom.isBefore(LocalDate.now()))
            errors.put("validFrom", "La date de début ne peut pas être dans le passé.");

        if (validTo == null) errors.put("validTo", "Date de fin invalide.");
        else if (validTo != null && validTo.isBefore(validFrom))
            errors.put("validTo", "La date de fin ne peut pas précéder la date de début.");

        if (!errors.isEmpty()) {
            showFormWithErrors(req, res, errors, null);
            return;                                           // le service n'est pas appelé
        }

        // 3. règles métier (chevauchement...) : le médecin vient de la session
        try {
            availabilityService.create(currentUserId(req), day, status, start, end, validFrom, validTo);
            res.sendRedirect(req.getContextPath() + "/doctor/availabilities?created=1");

        } catch (IllegalArgumentException e) {                // chevauchement, dimanche, profil introuvable...
            showFormWithErrors(req, res, errors, e.getMessage());
        } catch (RuntimeException e) {
            e.printStackTrace();
            showFormWithErrors(req, res, errors, "La disponibilité n'a pas pu être enregistrée. Réessayez.");
        }
    }


    // POST /doctor/availabilities/delete
    public void delete(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            Long id = Long.valueOf(req.getParameter("id"));
            availabilityService.delete(currentUserId(req), id);
            res.sendRedirect(req.getContextPath() + "/doctor/availabilities?deleted=1");
        } catch (IllegalArgumentException e) {                // inclut NumberFormatException et "introuvable"
            loadList(req);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher(VIEW).forward(req, res);
        }
    }

    // ---------- helpers ----------
    private void loadList(HttpServletRequest req) {
        req.setAttribute("availabilities", availabilityService.findForUser(currentUserId(req)).stream().map(AvailabilityMapper::toDTO).toList());
    }

    private void showFormWithErrors(HttpServletRequest req, HttpServletResponse res, Map<String, String> errors, String globalError) throws ServletException, IOException {
        loadList(req);                                        // sinon le tableau devient vide
        req.setAttribute("errors", errors);
        if (globalError != null) req.setAttribute("error", globalError);
        req.setAttribute("openModal", true);
        req.getRequestDispatcher(VIEW).forward(req, res);
    }

    private Long currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        UserDTO user = (session == null) ? null : (UserDTO) session.getAttribute("currentUser");
        if (user == null) throw new IllegalStateException("Utilisateur non connecté");
        return user.getId();
    }
}