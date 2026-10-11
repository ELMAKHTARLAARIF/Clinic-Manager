package com.clinicmanager.mapper;

import com.clinicmanager.dto.AppointmentRowDTO;
import com.clinicmanager.enums.AppointmentType;
import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.Doctor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public final class AppointmentMapper {
    private static final DateTimeFormatter FULL = DateTimeFormatter.ofPattern("EEEE d MMMM yyyy", Locale.FRENCH);
    private static final DateTimeFormatter MONTH = DateTimeFormatter.ofPattern("MMM", Locale.FRENCH);

    private AppointmentMapper() {}

    public static AppointmentRowDTO toRow(Appointment a, boolean canCancel) {
        Doctor d = a.getDoctor();
        String title = (d.getTitle() == null || d.getTitle().isBlank()) ? "" : d.getTitle() + " ";
        String doctorName = title + d.getUser().getFirstName() + " " + d.getUser().getLastName();

        LocalDateTime start = a.getStartDateTime();
        String group = switch (a.getStatus()) {
            case CANCELED -> "canceled";
            case DONE -> "past";
            default -> start.isAfter(LocalDateTime.now()) ? "upcoming" : "past";   // planifié mais déjà passé
        };

        return new AppointmentRowDTO(
                a.getId(),
                String.valueOf(start.getDayOfMonth()),
                start.format(MONTH),
                start.format(FULL),
                start.toLocalTime().toString(),                       // 09:30
                a.getEndDateTime().toLocalTime().toString(),
                doctorName,
                d.getSpecialty().getName(),
                typeLabel(a.getType()),
                a.getReason(),
                a.getStatus().name(),
                group,
                canCancel);
    }

    private static String typeLabel(AppointmentType t) {
        return switch (t) {
            case CONSULTATION -> "Consultation";
            case FOLLOW_UP -> "Suivi";
            case URGENT -> "Urgent";
        };
    }
}