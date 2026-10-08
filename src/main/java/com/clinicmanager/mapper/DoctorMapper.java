package com.clinicmanager.mapper;

import com.clinicmanager.dto.DoctorOptionDTO;
import com.clinicmanager.model.Doctor;

public final class DoctorMapper {
    private DoctorMapper() {}

    public static DoctorOptionDTO toOption(Doctor d) {
        String title = (d.getTitle() == null || d.getTitle().isBlank()) ? "" : d.getTitle() + " ";
        String name = title + d.getUser().getFirstName() + " " + d.getUser().getLastName();
        return new DoctorOptionDTO(d.getId(), name, d.getSpecialty().getId(), d.getDepartment().getName());
    }
}