package com.clinicmanager.repository;

import com.clinicmanager.exception.AppointmentNotFoundException;
import com.clinicmanager.model.Department;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.Collections;
import java.util.List;

public class DepartmentRepository {

    public List<Department> findAll() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT dp FROM Department dp ORDER BY dp.name", Department.class)
                    .getResultList();
        }
    }
}
