package com.clinicmanager.service.AdminService;

import com.clinicmanager.exception.AppointmentNotFoundException;
import com.clinicmanager.model.Specialty;
import com.clinicmanager.repository.SpecialtyRepository;

import java.util.List;

public class specialtyService {

    static SpecialtyRepository specialtyRepository = new SpecialtyRepository();
    public static List<Specialty> findAll() {
        return specialtyRepository.findAll();
    }
}
