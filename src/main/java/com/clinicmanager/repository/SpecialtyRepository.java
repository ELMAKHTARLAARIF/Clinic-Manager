package com.clinicmanager.repository;

import com.clinicmanager.exception.SpecialtyNotFoundException;
import com.clinicmanager.model.Specialty;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

public class SpecialtyRepository {


    public List<Specialty> findAll() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT sp FROM Specialty sp ORDER BY sp.name", Specialty.class)
                    .getResultList();
        }
    }
}
