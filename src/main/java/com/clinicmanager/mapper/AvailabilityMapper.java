package com.clinicmanager.mapper;

import com.clinicmanager.dto.AvailabilityDTO;
import com.clinicmanager.model.Availability;

import java.time.format.TextStyle;
import java.util.Locale;

public final class AvailabilityMapper {
    private AvailabilityMapper() {}

    public static AvailabilityDTO toDTO(Availability a) {
        String day = a.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.FRENCH);   // "lundi"
        day = day.substring(0, 1).toUpperCase() + day.substring(1);                    // "Lundi"
        return new AvailabilityDTO(
                a.getId(),
                day,
                a.getStartTime().toString(),                    // 08:30
                a.getEndTime().toString(),
                a.getValidFrom().toString(),                    // 2026-10-12
                a.getValidTo() == null ? null : a.getValidTo().toString(),
                a.getStatus().name());
    }
}