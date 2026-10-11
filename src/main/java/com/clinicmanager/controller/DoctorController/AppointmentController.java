package com.clinicmanager.controller.DoctorController;

import com.clinicmanager.dto.AppointmentRowDTO;
import com.clinicmanager.dto.DoctorOptionDTO;
import com.clinicmanager.dto.SpecialtyOptionDTO;
import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.enums.AppointmentType;
import com.clinicmanager.exception.AppointmentConflictException;
import com.clinicmanager.exception.UnauthorizedActionException;
import com.clinicmanager.mapper.AppointmentMapper;
import com.clinicmanager.mapper.DoctorMapper;
import com.clinicmanager.service.AdminService.DoctorService;
import com.clinicmanager.service.AdminService.SpecialtyService;
import com.clinicmanager.service.Patient.AgendaService;
import com.clinicmanager.service.Patient.AppointmentService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.clinicmanager.util.ValidationUtil.clean;
import static com.clinicmanager.util.ValidationUtil.parseEnum;

public class AppointmentController {

    private static final String VIEW = "/WEB-INF/views/patient/bookAppointment.jsp";
    private static final String APP_VIEW = "/WEB-INF/views/patient/Myappointments.jsp";
    private static final int SLOT_MINUTES = 30;
    private static final int MAX_RANGE_DAYS = 7;

    private final DoctorService doctorService = new DoctorService();
    private final AgendaService agendaService = new AgendaService();
    private final AppointmentService appointmentService = new AppointmentService();

    private final Gson gson = new Gson();


    // GET /patient/book
    public void page(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        loadBookingData(req);
        req.getRequestDispatcher(VIEW).forward(req, res);
    }

    public void agendaJson(HttpServletRequest req, HttpServletResponse res) throws IOException {
        List<Long> doctorIds;
        LocalDate from, to;
        try {
            if (req.getParameter("doctorId") != null) {
                doctorIds = List.of(Long.parseLong(req.getParameter("doctorId")));
                from = LocalDate.parse(req.getParameter("from"));
                to = LocalDate.parse(req.getParameter("to"));
            } else {
                doctorIds = Arrays.stream(req.getParameter("doctorIds").split(",")).filter(s -> !s.isBlank()).map(Long::parseLong).toList();
                from = to = LocalDate.parse(req.getParameter("date"));
            }
        } catch (RuntimeException e) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // période incohérente ou trop longue : on refuse (sinon la boucle des jours peut devenir énorme)
        if (to.isBefore(from) || from.plusDays(MAX_RANGE_DAYS).isBefore(to)) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.getWriter().write(gson.toJson(agendaService.buildSlots(doctorIds, from, to)));
    }

    // POST /patient/appointments/create
    public void create(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {

        Map<String, String> errors = new HashMap<>();

        String doctorIdParam = clean(req.getParameter("doctorId"));
        String dateParam = clean(req.getParameter("date"));
        String startTimeParam = clean(req.getParameter("startTime"));
        String reason = clean(req.getParameter("reason"));
        AppointmentType type = parseEnum(AppointmentType.class, req.getParameter("type"));
        // le contrôleur lit un UserDTO (c'est ce que LoginController met en session)
        UserDTO currentUser = (UserDTO) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Long userId = currentUser.getId();      // id de l'UTILISATEUR : le service retrouve le Patient correspondant

        Long doctorId = null;

        if (doctorIdParam == null || doctorIdParam.isEmpty()) {
            errors.put("doctorId", "Le médecin est obligatoire.");
        } else {
            try {
                doctorId = Long.parseLong(doctorIdParam);
            } catch (NumberFormatException e) {
                errors.put("doctorId", "Identifiant du médecin invalide.");
            }
        }

        LocalDateTime startDateTime = null;
        LocalDateTime endDateTime = null;

        try {
            if (dateParam == null || dateParam.isEmpty()) {
                errors.put("date", "La date est obligatoire.");
            }

            if (startTimeParam == null || startTimeParam.isEmpty()) {
                errors.put("startTime", "L'heure de début est obligatoire.");
            }

            if (!errors.containsKey("date") && !errors.containsKey("startTime")) {

                startDateTime = LocalDateTime.parse(dateParam + "T" + startTimeParam);

                // le formulaire n'envoie pas d'heure de fin : un rendez-vous dure 30 minutes
                endDateTime = startDateTime.plusMinutes(SLOT_MINUTES);
            }

        } catch (DateTimeParseException e) {
            errors.put("date", "La date ou l'heure du rendez-vous est invalide.");
        }

        if (type == null) {
            errors.put("type", "Le type de rendez-vous est invalide.");
        }

        if (reason == null || reason.isEmpty()) {
            errors.put("reason", "Le motif est obligatoire.");
        } else if (reason.length() > 500) {
            errors.put("reason", "Le motif ne peut pas dépasser 500 caractères.");
        }

        if (!errors.isEmpty()) {
            showBookingWithErrors(req, res, errors, null);
            return;
        }

        try {
            appointmentService.create(userId, doctorId, startDateTime, endDateTime, String.valueOf(type), reason);

            res.sendRedirect(req.getContextPath() + "/patient/book?created=1");

        } catch (AppointmentConflictException e) {      // créneau pris ou trop proche
            showBookingWithErrors(req, res, errors, e.getMessage());

        } catch (IllegalArgumentException e) {                                     // médecin ou patient introuvable...
            showBookingWithErrors(req, res, errors, e.getMessage());

        } catch (RuntimeException e) {
            e.printStackTrace();
            showBookingWithErrors(req, res, errors, "Le rendez-vous n'a pas pu être créé. Réessayez.");
        }
    }

    public void list(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (currentUser(req) == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        loadAppointments(req);
        if ("1".equals(req.getParameter("created"))) req.setAttribute("success", "Rendez-vous créé avec succès.");
        if ("1".equals(req.getParameter("canceled"))) req.setAttribute("success", "Rendez-vous annulé.");
        req.getRequestDispatcher(APP_VIEW).forward(req, res);
    }


    public void cancel(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        UserDTO user = currentUser(req);
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            Long id = Long.valueOf(req.getParameter("id"));
            appointmentService.cancel(user.getId(), id);        // l'utilisateur vient de la session, jamais du formulaire
            res.sendRedirect(req.getContextPath() + "/patient/appointments?canceled=1");

        } catch (UnauthorizedActionException e) {               // moins de 12 h avant
            showWithError(req, res, e.getMessage());
        } catch (IllegalArgumentException e) {                  // introuvable, déjà annulé, id invalide
            showWithError(req, res, e.getMessage());
        } catch (RuntimeException e) {
            e.printStackTrace();
            showWithError(req, res, "L'annulation a échoué. Réessayez.");
        }
    }

    // ---------- helpers ----------

    private void showWithError(HttpServletRequest req, HttpServletResponse res, String message)
            throws ServletException, IOException {
        loadAppointments(req);                                  // sinon la liste devient vide
        req.setAttribute("error", message);
        req.getRequestDispatcher(VIEW).forward(req, res);
    }
    private void loadAppointments(HttpServletRequest req) {
        UserDTO user = currentUser(req);
        List<AppointmentRowDTO> rows = appointmentService.findForUser(user.getId()).stream().map(a -> AppointmentMapper.toRow(a, appointmentService.canCancel(a))).toList();
        req.setAttribute("appointments", rows);
    }

    private UserDTO currentUser(HttpServletRequest req) {
        return (UserDTO) req.getSession().getAttribute("currentUser");    // le nom utilisé par ton LoginController
    }

    /**
     * Les deux listes JSON dont la page a besoin (à remettre à chaque affichage de la page).
     */
    private void loadBookingData(HttpServletRequest req) {
        List<DoctorOptionDTO> doctors = doctorService.findAllActive().stream().map(DoctorMapper::toOption).toList();

        List<SpecialtyOptionDTO> specialties = SpecialtyService.findAll().stream()   // adapte au nom de ta classe
                .map(s -> new SpecialtyOptionDTO(s.getId(), s.getName())).toList();

        req.setAttribute("doctorsJson", gson.toJson(doctors));
        req.setAttribute("specialtiesJson", gson.toJson(specialties));
        System.out.println("doctors=" + doctors.size() + " specialties=" + specialties.size());
    }

    /**
     * Réaffiche la page de réservation avec les erreurs et la modale rouverte.
     */
    private void showBookingWithErrors(HttpServletRequest req, HttpServletResponse res, Map<String, String> errors, String globalError) throws ServletException, IOException {

        loadBookingData(req);                          // sinon l'agenda revient sans médecins
        req.setAttribute("errors", errors);
        if (globalError != null) req.setAttribute("error", globalError);
        req.setAttribute("openModal", true);
        req.getRequestDispatcher(VIEW).forward(req, res);
    }
}