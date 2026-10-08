package com.clinicmanager.controller.DoctorController;

import com.clinicmanager.dto.DoctorOptionDTO;
import com.clinicmanager.dto.SpecialtyOptionDTO;
import com.clinicmanager.mapper.DoctorMapper;
import com.clinicmanager.service.AdminService.DoctorService;
import com.clinicmanager.service.AdminService.specialtyService;
import com.clinicmanager.service.Patient.AgendaService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

public class BookingController {

    private static final String VIEW = "/WEB-INF/views/patient/bookAppointment.jsp";
    private final DoctorService doctorService = new DoctorService();
    private final AgendaService agendaService = new AgendaService();

    private final Gson gson = new Gson();

    public void page(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

        List<DoctorOptionDTO> doctors = doctorService.findAllActive().stream().map(DoctorMapper::toOption).toList();

        List<SpecialtyOptionDTO> specialties = specialtyService.findAll().stream()   // adapte au nom de ta classe
                .map(s -> new SpecialtyOptionDTO(s.getId(), s.getName())).toList();

        req.setAttribute("doctorsJson", gson.toJson(doctors));
        req.setAttribute("specialtiesJson", gson.toJson(specialties));
        System.out.println("doctors=" + doctors.size() + " specialties=" + specialties.size());
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
                doctorIds = Arrays.stream(req.getParameter("doctorIds").split(","))
                        .filter(s -> !s.isBlank()).map(Long::parseLong).toList();
                from = to = LocalDate.parse(req.getParameter("date"));
            }
        } catch (RuntimeException e) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.getWriter().write(gson.toJson(agendaService.buildSlots(doctorIds, from, to)));
    }
}
 