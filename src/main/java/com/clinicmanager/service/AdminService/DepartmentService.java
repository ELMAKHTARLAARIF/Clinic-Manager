package com.clinicmanager.service.AdminService;

import com.clinicmanager.model.Department;
import com.clinicmanager.repository.DepartmentRepository;

import java.util.List;

public class DepartmentService {
           static DepartmentRepository departementRepository = new DepartmentRepository();
    public static List<Department> findAll() {
        return departementRepository.findAll();
    }
}
